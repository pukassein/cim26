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

-- The current panel uses the publishable (anonymous) Supabase key. These policies
-- mirror that architecture so its create, edit, delete and move actions work.
-- Replace them with authenticated-admin policies when Supabase Auth is enabled.
drop policy if exists panel_insert_organizing_committee on public.organizing_committee;
create policy panel_insert_organizing_committee
  on public.organizing_committee for insert
  to anon, authenticated
  with check (true);

drop policy if exists panel_update_organizing_committee on public.organizing_committee;
create policy panel_update_organizing_committee
  on public.organizing_committee for update
  to anon, authenticated
  using (true)
  with check (true);

drop policy if exists panel_delete_organizing_committee on public.organizing_committee;
create policy panel_delete_organizing_committee
  on public.organizing_committee for delete
  to anon, authenticated
  using (true);
