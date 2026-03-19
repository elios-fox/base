-- ============================================
-- SEED DATA
-- ============================================
-- NOTE: Supabase auth users cannot be created via plain SQL migrations.
-- Create test users via the Supabase Dashboard or via the Auth API:
--
--   coach@clubhub.test      / testtest123  -> "Jan de Vries"
--   speler1@clubhub.test    / testtest123  -> "Pieter Bakker"
--   speler2@clubhub.test    / testtest123  -> "Klaas Jansen"
--
-- After creating those users, copy their UUIDs into the placeholders below
-- and run this migration manually, or use `supabase/seed.sql` instead.
-- ============================================

-- Placeholder UUIDs (replace with real user IDs after signup)
do $$
declare
  coach_uid   uuid := '00000000-0000-0000-0000-000000000001';
  speler1_uid uuid := '00000000-0000-0000-0000-000000000002';
  speler2_uid uuid := '00000000-0000-0000-0000-000000000003';
  team_id     uuid;
  event_ids   uuid[];
  ev_id       uuid;
  base_time   timestamptz := now();
  statuses    public.attendance_status[] := array['aanwezig','aanwezig','afwezig','onzeker','aanwezig'];
  player_uids uuid[];
  player_names text[];
  status_idx  int;
begin
  player_uids  := array[coach_uid, speler1_uid, speler2_uid];
  player_names := array['Jan de Vries', 'Pieter Bakker', 'Klaas Jansen'];

  -- ==========================================
  -- Team: Heren 1
  -- ==========================================
  insert into public.teams (name, owner_uid, sport, season_year, member_uids, invite_code)
  values (
    'Heren 1',
    coach_uid,
    'Voetbal',
    2026,
    array[coach_uid, speler1_uid, speler2_uid],
    'HRN1-2026'
  )
  returning id into team_id;

  -- ==========================================
  -- Events (5 events with offsets from now)
  -- ==========================================
  -- Event 1: Training, 3 days ago at 19:00
  insert into public.events (team_id, title, type, date_time, location, recurring)
  values (team_id, 'Training', 'training',
    date_trunc('day', base_time) - interval '3 days' + interval '19 hours',
    'Sportpark Noord veld 2', true)
  returning id into ev_id;
  event_ids := array[ev_id];

  -- Event 2: Wedstrijd, 1 day ago at 14:30
  insert into public.events (team_id, title, type, date_time, location, recurring)
  values (team_id, 'vs. FC Tegenstander', 'wedstrijd',
    date_trunc('day', base_time) - interval '1 day' + interval '14 hours 30 minutes',
    'Sportpark Zuid', false)
  returning id into ev_id;
  event_ids := array_append(event_ids, ev_id);

  -- Event 3: Training, 2 days from now at 19:00
  insert into public.events (team_id, title, type, date_time, location, recurring)
  values (team_id, 'Training', 'training',
    date_trunc('day', base_time) + interval '2 days' + interval '19 hours',
    'Sportpark Noord veld 2', true)
  returning id into ev_id;
  event_ids := array_append(event_ids, ev_id);

  -- Event 4: Training, 5 days from now at 19:00
  insert into public.events (team_id, title, type, date_time, location, recurring)
  values (team_id, 'Training', 'training',
    date_trunc('day', base_time) + interval '5 days' + interval '19 hours',
    'Sportpark Noord veld 1', true)
  returning id into ev_id;
  event_ids := array_append(event_ids, ev_id);

  -- Event 5: Wedstrijd, 8 days from now at 14:30
  insert into public.events (team_id, title, type, date_time, location, recurring)
  values (team_id, 'vs. SV Rivaal', 'wedstrijd',
    date_trunc('day', base_time) + interval '8 days' + interval '14 hours 30 minutes',
    'Sportpark Oost', false)
  returning id into ev_id;
  event_ids := array_append(event_ids, ev_id);

  -- ==========================================
  -- Attendances for the first 2 (past) events
  -- ==========================================
  for i in 1..2 loop
    for j in 1..3 loop
      status_idx := ((i - 1) * 3 + (j - 1)) % 5 + 1;
      insert into public.attendances (event_id, user_uid, user_name, status, reason)
      values (
        event_ids[i],
        player_uids[j],
        player_names[j],
        statuses[status_idx],
        case when statuses[status_idx] = 'afwezig' then 'Blessure' else '' end
      );
    end loop;
  end loop;
end $$;
