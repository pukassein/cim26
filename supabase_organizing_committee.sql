-- Comité de Organización para CIM26
create table if not exists public.organizing_committee (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  institution text not null default '',
  sort_order integer not null default 1,
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists organizing_committee_sort_order_idx
  on public.organizing_committee (sort_order, name);

alter table public.organizing_committee enable row level security;

drop policy if exists public_read_published_organizing_committee on public.organizing_committee;
create policy public_read_published_organizing_committee
  on public.organizing_committee for select
  using (is_published = true);

-- Add an authenticated-admin write policy after enabling Supabase Auth for admins.
-- The current client-side admin password does not authenticate a Supabase user.
