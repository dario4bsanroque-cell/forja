-- Forja Gym · parte 2: ranking del grupo, máquinas del gimnasio y fotos privadas.
-- Pega todo en Supabase → SQL Editor → New query → Run (solo una vez).

-- 1) Ranking: cada uno escribe su fila, todos los que tienen cuenta pueden verlo.
create table if not exists public.forja_ranking (
  user_id    uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  nombre     text not null,
  data       jsonb not null,
  updated_at timestamptz not null default now()
);
alter table public.forja_ranking enable row level security;
drop policy if exists "ranking ver" on public.forja_ranking;
drop policy if exists "ranking crear" on public.forja_ranking;
drop policy if exists "ranking cambiar" on public.forja_ranking;
drop policy if exists "ranking borrar" on public.forja_ranking;
create policy "ranking ver"     on public.forja_ranking for select to authenticated using (true);
create policy "ranking crear"   on public.forja_ranking for insert to authenticated with check (auth.uid() = user_id);
create policy "ranking cambiar" on public.forja_ranking for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "ranking borrar"  on public.forja_ranking for delete to authenticated using (auth.uid() = user_id);

-- 2) Máquinas del gimnasio y cambios de ejercicios: una lista compartida por el grupo.
create table if not exists public.forja_gimnasio (
  id         text primary key,
  data       jsonb not null,
  updated_by uuid default auth.uid(),
  updated_at timestamptz not null default now()
);
alter table public.forja_gimnasio enable row level security;
drop policy if exists "gimnasio ver" on public.forja_gimnasio;
drop policy if exists "gimnasio crear" on public.forja_gimnasio;
drop policy if exists "gimnasio cambiar" on public.forja_gimnasio;
create policy "gimnasio ver"     on public.forja_gimnasio for select to authenticated using (true);
create policy "gimnasio crear"   on public.forja_gimnasio for insert to authenticated with check (true);
create policy "gimnasio cambiar" on public.forja_gimnasio for update to authenticated using (true) with check (true);

-- 3) Fotos del cuerpo: carpeta privada por persona (solo la ve su dueño).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('fotos', 'fotos', false, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;
drop policy if exists "fotos ver las mias" on storage.objects;
drop policy if exists "fotos subir las mias" on storage.objects;
drop policy if exists "fotos borrar las mias" on storage.objects;
create policy "fotos ver las mias" on storage.objects for select to authenticated
  using (bucket_id = 'fotos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "fotos subir las mias" on storage.objects for insert to authenticated
  with check (bucket_id = 'fotos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "fotos borrar las mias" on storage.objects for delete to authenticated
  using (bucket_id = 'fotos' and (storage.foldername(name))[1] = auth.uid()::text);
