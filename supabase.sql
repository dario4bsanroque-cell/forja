-- Forja Gym: pega esto en Supabase → SQL Editor → New query → Run (solo una vez).
create table if not exists public.forja (
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  col        text not null check (col in ('perfil', 'entrenos', 'pesos')),
  id         text not null,
  data       jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, col, id)
);
alter table public.forja enable row level security;
drop policy if exists "cada uno lo suyo" on public.forja;
create policy "cada uno lo suyo" on public.forja
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
