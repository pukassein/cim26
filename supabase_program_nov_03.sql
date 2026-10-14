-- Programa del martes 3 de noviembre de 2026 — CIM 2026
-- Ejecutar una sola vez en el SQL Editor de Supabase.

begin;

-- La web muestra rangos horarios, por lo que agregamos la hora de finalización.
alter table public.program_items
  add column if not exists end_time time;

-- Sustituye únicamente el cronograma de esta fecha. No modifica otros días.
delete from public.program_items
where event_date = date '2026-11-03';

insert into public.program_items
  (event_date, start_time, end_time, title, description, sort_order, is_published)
values
  (
    date '2026-11-03', time '18:00', time '18:30',
    'Acreditaciones y Recepción', null, 1, true
  ),
  (
    date '2026-11-03', time '18:30', time '18:50',
    'Inversiones Financieras', 'Econ. Gustavo Rivas Masi', 2, true
  ),
  (
    date '2026-11-03', time '18:50', time '19:30',
    'Evolución del comercio exterior en los últimos 10 años: efectos y expectativas',
    'Mag. Víctor Ocampos', 3, true
  ),
  (
    date '2026-11-03', time '19:30', time '20:10',
    'Inteligencia Emocional', 'Lic. William Federico Bernal Valiente', 4, true
  ),
  (
    date '2026-11-03', time '20:20', time '22:00',
    'Presentación de trabajos en modalidad oral y póster', null, 5, true
  );

commit;
