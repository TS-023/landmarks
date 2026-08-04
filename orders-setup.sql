-- ============================================================
-- Bestellingen-tabel voor de Mollie-betaalintegratie
-- Plak dit in: Supabase dashboard → SQL Editor → New query → Run
-- (Voer eerst supabase-setup.sql uit als je dat nog niet had gedaan,
--  deze tabel hergebruikt de set_updated_at()-functie van daaruit.)
-- ============================================================

create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  items jsonb not null,
  total numeric not null,
  status text not null default 'open', -- open | paid | failed | expired | canceled
  mollie_payment_id text,
  customer_name text,
  customer_email text,
  shipping_address text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table orders enable row level security;

-- Bewust GEEN select/insert/update policies voor anon of authenticated:
-- alleen de Edge Functions (die de service_role key gebruiken) mogen deze
-- tabel aanraken. Zo blijven namen, e-mailadressen en adressen privé en
-- kan niemand via de browser bestellingen inzien of prijzen vervalsen.
-- Jijzelf kunt bestellingen gewoon inzien via Table Editor in het Supabase-dashboard.

create trigger orders_set_updated_at
  before update on orders
  for each row
  execute function set_updated_at();
