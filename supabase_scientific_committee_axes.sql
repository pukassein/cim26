-- Comité Científico CIM26: especialidad/perfil y eje temático.
-- Ejecutar una sola vez en Supabase > SQL Editor.
--
-- Nota sobre el nombre: por compatibilidad con los datos y el sitio actuales,
-- el Comité Científico público está almacenado en organizing_committee.

begin;

alter table public.organizing_committee
  add column if not exists specialty text,
  add column if not exists thematic_axis smallint;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'organizing_committee_thematic_axis_check'
      and conrelid = 'public.organizing_committee'::regclass
  ) then
    alter table public.organizing_committee
      add constraint organizing_committee_thematic_axis_check
      check (thematic_axis between 1 and 5);
  end if;
end $$;

create index if not exists organizing_committee_axis_sort_idx
  on public.organizing_committee (thematic_axis, sort_order, name);

comment on column public.organizing_committee.specialty is
  'Especialidad o perfil académico del integrante del Comité Científico.';

comment on column public.organizing_committee.thematic_axis is
  'Eje temático CIM26 (1 a 5) al que pertenece el integrante.';

commit;

-- Hace que PostgREST recargue el esquema inmediatamente.
notify pgrst, 'reload schema';
