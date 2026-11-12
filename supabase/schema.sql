-- MoodMeal · Supabase schema
-- Run this once in the Supabase SQL editor, then start the app with:
--   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
--
-- The app works fully offline without these tables. They only mirror the
-- user's own profile, check-ins and favourites in the cloud.

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null default 'Friend',
  email text,
  avatar text not null default '🌤️',
  photo text not null default '',
  allergies text[] not null default '{}',
  conditions text[] not null default '{}',
  avoid text[] not null default '{}',
  language text not null default 'en',
  reminder_enabled boolean not null default true,
  reminder_hour int not null default 8 check (reminder_hour between 0 and 23),
  reminder_minute int not null default 0 check (reminder_minute between 0 and 59),
  reminder_days int[] not null default '{1,2,3,4,5,6,7}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Existing projects: add the profile-photo column without dropping data.
alter table public.profiles
  add column if not exists photo text not null default '';

create table if not exists public.mood_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  mood text not null check (
    mood in ('calm', 'happy', 'stressed', 'sad', 'tired', 'excited', 'angry', 'bored')
  ),
  intensity int not null default 3 check (intensity between 1 and 5),
  note text not null default '',
  tags text[] not null default '{}',
  created_at timestamptz not null default now()
);

create index if not exists mood_entries_user_created_idx
  on public.mood_entries (user_id, created_at desc);

create table if not exists public.favourites (
  user_id uuid not null references auth.users (id) on delete cascade,
  meal_id text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, meal_id)
);

create table if not exists public.meal_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  meal_id text not null,
  created_at timestamptz not null default now()
);

create index if not exists meal_logs_user_created_idx
  on public.meal_logs (user_id, created_at desc);

-- ---------------------------------------------------------------------------
-- Row level security: every row belongs to exactly one user.
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.mood_entries enable row level security;
alter table public.favourites enable row level security;
alter table public.meal_logs enable row level security;

drop policy if exists "profiles are owned by their user" on public.profiles;
create policy "profiles are owned by their user"
  on public.profiles for all
  using (auth.uid() = id)
  with check (auth.uid() = id);

drop policy if exists "moods are owned by their user" on public.mood_entries;
create policy "moods are owned by their user"
  on public.mood_entries for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "favourites are owned by their user" on public.favourites;
create policy "favourites are owned by their user"
  on public.favourites for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "meal logs are owned by their user" on public.meal_logs;
create policy "meal logs are owned by their user"
  on public.meal_logs for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- Keep updated_at fresh on profiles.
-- ---------------------------------------------------------------------------

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_touch_updated_at on public.profiles;
create trigger profiles_touch_updated_at
  before update on public.profiles
  for each row execute procedure public.touch_updated_at();

-- ---------------------------------------------------------------------------
-- Create a profile row whenever a user signs up. The app also upserts on its
-- first load, so this trigger is a convenience rather than a requirement.
-- ---------------------------------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', split_part(coalesce(new.email, ''), '@', 1)),
    new.email
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
