alter table public.teams
  add column photo_url text default null check (char_length(photo_url) <= 500),
  add column dominant_color text default null check (char_length(dominant_color) <= 7);

-- Create public storage bucket for team photos
insert into storage.buckets (id, name, public)
values ('uploads', 'uploads', true)
on conflict do nothing;
