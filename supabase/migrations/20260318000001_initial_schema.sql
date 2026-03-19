-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ============================================
-- TEAMS
-- ============================================
create table public.teams (
  id uuid primary key default uuid_generate_v4(),
  name text not null check (char_length(name) between 1 and 100),
  owner_uid uuid not null references auth.users(id) on delete cascade,
  sport text default '' check (char_length(sport) <= 50),
  season_year integer default extract(year from now()) check (season_year between 2020 and 2100),
  member_uids uuid[] not null default '{}',
  invite_code text unique not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_teams_owner on public.teams (owner_uid);
create index idx_teams_invite_code on public.teams (invite_code);
create index idx_teams_member_uids on public.teams using gin (member_uids);

-- ============================================
-- EVENTS
-- ============================================
create type public.event_type as enum ('training', 'wedstrijd');

create table public.events (
  id uuid primary key default uuid_generate_v4(),
  team_id uuid not null references public.teams(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 200),
  type public.event_type not null default 'training',
  date_time timestamptz not null,
  end_date_time timestamptz,
  location text default '' check (char_length(location) <= 200),
  notes text default '' check (char_length(notes) <= 2000),
  recurring boolean not null default false,
  recurring_pattern jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_events_team on public.events (team_id);
create index idx_events_datetime on public.events (date_time);

-- ============================================
-- ATTENDANCES
-- ============================================
create type public.attendance_status as enum ('aanwezig', 'afwezig', 'onzeker');

create table public.attendances (
  id uuid primary key default uuid_generate_v4(),
  event_id uuid not null references public.events(id) on delete cascade,
  user_uid uuid not null references auth.users(id) on delete cascade,
  user_name text not null default '' check (char_length(user_name) <= 100),
  status public.attendance_status not null,
  reason text default '' check (char_length(reason) <= 500),
  responded_at timestamptz default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (event_id, user_uid)
);

create index idx_attendances_event on public.attendances (event_id);
create index idx_attendances_user on public.attendances (user_uid);

-- ============================================
-- NOTIFICATIONS
-- ============================================
create type public.notification_type as enum ('event_reminder', 'attendance_request', 'team_invite');

create table public.notifications (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) <= 200),
  body text default '' check (char_length(body) <= 1000),
  type public.notification_type not null,
  read boolean not null default false,
  data jsonb,
  created_at timestamptz not null default now()
);

create index idx_notifications_user on public.notifications (user_id);
create index idx_notifications_user_read on public.notifications (user_id, read);

-- ============================================
-- CHECKLISTS
-- ============================================
create table public.checklists (
  id uuid primary key default uuid_generate_v4(),
  title text not null check (char_length(title) between 1 and 200),
  description text default '' check (char_length(description) <= 1000),
  owner_uid uuid not null references auth.users(id) on delete cascade,
  team_id uuid references public.teams(id) on delete set null,
  items jsonb not null default '[]',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_checklists_owner on public.checklists (owner_uid);
create index idx_checklists_team on public.checklists (team_id);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================
alter table public.teams enable row level security;
alter table public.events enable row level security;
alter table public.attendances enable row level security;
alter table public.notifications enable row level security;
alter table public.checklists enable row level security;

-- Teams: members can view, owner can modify
create policy "Team members can view" on public.teams
  for select using (auth.uid() = any(member_uids));

create policy "Authenticated users can create teams" on public.teams
  for insert with check (auth.uid() = owner_uid);

create policy "Team owner can update" on public.teams
  for update using (auth.uid() = owner_uid);

create policy "Team owner can delete" on public.teams
  for delete using (auth.uid() = owner_uid);

-- Events: team members can view/create, owner can modify
create policy "Team members can view events" on public.events
  for select using (
    exists (
      select 1 from public.teams
      where teams.id = events.team_id
      and auth.uid() = any(teams.member_uids)
    )
  );

create policy "Team members can create events" on public.events
  for insert with check (
    exists (
      select 1 from public.teams
      where teams.id = events.team_id
      and auth.uid() = any(teams.member_uids)
    )
  );

create policy "Team owner can update events" on public.events
  for update using (
    exists (
      select 1 from public.teams
      where teams.id = events.team_id
      and auth.uid() = teams.owner_uid
    )
  );

create policy "Team owner can delete events" on public.events
  for delete using (
    exists (
      select 1 from public.teams
      where teams.id = events.team_id
      and auth.uid() = teams.owner_uid
    )
  );

-- Attendances: users can manage own
create policy "Users can view attendances" on public.attendances
  for select using (auth.uid() is not null);

create policy "Users can insert own attendance" on public.attendances
  for insert with check (auth.uid() = user_uid);

create policy "Users can update own attendance" on public.attendances
  for update using (auth.uid() = user_uid);

create policy "Users can delete own attendance" on public.attendances
  for delete using (auth.uid() = user_uid);

-- Notifications: users can see/update own
create policy "Users can view own notifications" on public.notifications
  for select using (auth.uid() = user_id);

create policy "Users can update own notifications" on public.notifications
  for update using (auth.uid() = user_id);

-- System can insert notifications (via triggers with security definer)
create policy "Service can insert notifications" on public.notifications
  for insert with check (true);

-- Checklists: owner can manage
create policy "Owner can view checklists" on public.checklists
  for select using (auth.uid() = owner_uid);

create policy "Authenticated can create checklists" on public.checklists
  for insert with check (auth.uid() = owner_uid);

create policy "Owner can update checklists" on public.checklists
  for update using (auth.uid() = owner_uid);

create policy "Owner can delete checklists" on public.checklists
  for delete using (auth.uid() = owner_uid);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Auto-update updated_at
create or replace function public.update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger teams_updated_at before update on public.teams
  for each row execute function public.update_updated_at();
create trigger events_updated_at before update on public.events
  for each row execute function public.update_updated_at();
create trigger attendances_updated_at before update on public.attendances
  for each row execute function public.update_updated_at();
create trigger checklists_updated_at before update on public.checklists
  for each row execute function public.update_updated_at();

-- Auto-generate invite code for teams
create or replace function public.generate_invite_code()
returns trigger as $$
declare
  chars text := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  code text := '';
  i integer;
begin
  if new.invite_code = '' or new.invite_code is null then
    for i in 1..8 loop
      code := code || substr(chars, floor(random() * length(chars) + 1)::int, 1);
    end loop;
    new.invite_code := code;
  end if;
  -- Ensure owner is in member_uids
  if not (new.owner_uid = any(new.member_uids)) then
    new.member_uids := array_append(new.member_uids, new.owner_uid);
  end if;
  return new;
end;
$$ language plpgsql;

create trigger teams_generate_invite_code before insert on public.teams
  for each row execute function public.generate_invite_code();

-- Auto-set responded_at on attendance
create or replace function public.set_responded_at()
returns trigger as $$
begin
  new.responded_at = now();
  return new;
end;
$$ language plpgsql;

create trigger attendances_set_responded_at before insert or update on public.attendances
  for each row execute function public.set_responded_at();

-- Notify team on new event
create or replace function public.notify_team_on_event()
returns trigger as $$
declare
  team_record record;
  member_uid uuid;
begin
  select * into team_record from public.teams where id = new.team_id;
  if team_record is not null then
    foreach member_uid in array team_record.member_uids loop
      insert into public.notifications (user_id, title, body, type, data)
      values (
        member_uid,
        'Nieuw event',
        new.title || ' op ' || to_char(new.date_time, 'DD-MM-YYYY HH24:MI'),
        'attendance_request',
        jsonb_build_object('eventId', new.id, 'teamId', new.team_id)
      );
    end loop;
  end if;
  return new;
end;
$$ language plpgsql security definer;

create trigger events_notify_team after insert on public.events
  for each row execute function public.notify_team_on_event();

-- Notify coach on attendance response
create or replace function public.notify_coach_on_attendance()
returns trigger as $$
declare
  event_record record;
  team_record record;
  status_text text;
begin
  select * into event_record from public.events where id = new.event_id;
  select * into team_record from public.teams where id = event_record.team_id;

  case new.status
    when 'aanwezig' then status_text := 'is aanwezig bij';
    when 'afwezig' then status_text := 'is afwezig bij';
    when 'onzeker' then status_text := 'is onzeker over';
  end case;

  insert into public.notifications (user_id, title, body, type, data)
  values (
    team_record.owner_uid,
    'Aanwezigheid bijgewerkt',
    new.user_name || ' ' || status_text || ' ' || event_record.title,
    'attendance_request',
    jsonb_build_object('eventId', new.event_id, 'teamId', team_record.id)
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger attendances_notify_coach after insert on public.attendances
  for each row execute function public.notify_coach_on_attendance();

-- Notify team on event update (title or datetime changed)
create or replace function public.notify_team_on_event_update()
returns trigger as $$
declare
  team_record record;
  member_uid uuid;
begin
  if old.title != new.title or old.date_time != new.date_time then
    select * into team_record from public.teams where id = new.team_id;
    if team_record is not null then
      foreach member_uid in array team_record.member_uids loop
        insert into public.notifications (user_id, title, body, type, data)
        values (
          member_uid,
          'Event gewijzigd',
          new.title || ' is gewijzigd. Controleer de details.',
          'event_reminder',
          jsonb_build_object('eventId', new.id, 'teamId', new.team_id)
        );
      end loop;
    end if;
  end if;
  return new;
end;
$$ language plpgsql security definer;

create trigger events_notify_on_update after update on public.events
  for each row execute function public.notify_team_on_event_update();

-- RPC: Join team by invite code
create or replace function public.join_team(p_invite_code text, p_user_uid uuid)
returns jsonb as $$
declare
  team_record record;
begin
  select * into team_record from public.teams where invite_code = p_invite_code;

  if team_record is null then
    raise exception 'Team niet gevonden met deze code.';
  end if;

  if p_user_uid = any(team_record.member_uids) then
    raise exception 'Je bent al lid van dit team.';
  end if;

  update public.teams
  set member_uids = array_append(member_uids, p_user_uid)
  where id = team_record.id;

  return jsonb_build_object(
    'team_id', team_record.id,
    'team_name', team_record.name
  );
end;
$$ language plpgsql security definer;
