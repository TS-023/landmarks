-- ============================================================
-- Setup voor de Europa-kaart met landmarks (Supabase)
-- Plak dit in: Supabase dashboard → SQL Editor → New query → Run
-- ============================================================

-- 1. Tabel voor prijzen + foto's per landmark
create table if not exists products (
  slug text primary key,
  stl_price numeric not null default 34.95,
  art_price numeric not null default 54.95,
  images jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

-- 2. Row Level Security aanzetten
alter table products enable row level security;

-- 3. Iedereen (ook niet-ingelogde bezoekers) mag lezen
create policy "Iedereen mag producten lezen"
  on products for select
  using (true);

-- 4. Alleen ingelogde gebruikers (jij, de beheerder) mogen schrijven
create policy "Alleen ingelogd mag producten wijzigen"
  on products for insert
  with check (auth.role() = 'authenticated');

create policy "Alleen ingelogd mag producten updaten"
  on products for update
  using (auth.role() = 'authenticated');

create policy "Alleen ingelogd mag producten verwijderen"
  on products for delete
  using (auth.role() = 'authenticated');

-- 5. Automatisch updated_at bijwerken bij elke wijziging
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger products_set_updated_at
  before update on products
  for each row
  execute function set_updated_at();

-- ============================================================
-- Storage policies voor de buckets landmarks-stl en landmarks-photos
-- Vereist dat je beide buckets al hebt aangemaakt (als "Public bucket")
-- ============================================================

-- landmarks-stl: iedereen mag lezen, alleen ingelogd mag schrijven
create policy "Publiek lezen landmarks-stl"
on storage.objects for select
using (bucket_id = 'landmarks-stl');

create policy "Ingelogd uploaden landmarks-stl"
on storage.objects for insert
with check (bucket_id = 'landmarks-stl' and auth.role() = 'authenticated');

create policy "Ingelogd updaten landmarks-stl"
on storage.objects for update
using (bucket_id = 'landmarks-stl' and auth.role() = 'authenticated');

create policy "Ingelogd verwijderen landmarks-stl"
on storage.objects for delete
using (bucket_id = 'landmarks-stl' and auth.role() = 'authenticated');

-- landmarks-photos: iedereen mag lezen, alleen ingelogd mag schrijven
create policy "Publiek lezen landmarks-photos"
on storage.objects for select
using (bucket_id = 'landmarks-photos');

create policy "Ingelogd uploaden landmarks-photos"
on storage.objects for insert
with check (bucket_id = 'landmarks-photos' and auth.role() = 'authenticated');

create policy "Ingelogd updaten landmarks-photos"
on storage.objects for update
using (bucket_id = 'landmarks-photos' and auth.role() = 'authenticated');

create policy "Ingelogd verwijderen landmarks-photos"
on storage.objects for delete
using (bucket_id = 'landmarks-photos' and auth.role() = 'authenticated');
