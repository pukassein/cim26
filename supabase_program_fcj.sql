-- Integración del cronograma FCJ del miércoles 4 de noviembre de 2026.
-- Fuente: CRONOGRAMA GENERAL DE ACTIVIDADES (1).docx
-- Es seguro volver a ejecutar este archivo: reemplaza solo las filas FCJ
-- importadas desde este documento y conserva las actividades de otras facultades.

begin;

alter table public.program_items
  add column if not exists end_time time,
  add column if not exists faculty text not null default 'CIM26',
  add column if not exists track text not null default 'General',
  add column if not exists venue text,
  add column if not exists activity_type text not null default 'session',
  add column if not exists confirmation_status text not null default 'confirmed',
  add column if not exists source_reference text;

delete from public.program_items
where faculty = 'FCJ'
  and source_reference = 'CRONOGRAMA GENERAL DE ACTIVIDADES (1).docx'
  and event_date = date '2026-11-04';

insert into public.program_items
  (event_date, start_time, end_time, title, description, faculty, track, venue,
   activity_type, confirmation_status, source_reference, sort_order, is_published)
values
  (date '2026-11-04', time '16:00', time '16:20',
   'Acreditaciones y Recepción', 'Responsable: Comité Logístico',
   'FCJ', 'Plenaria', null, 'registration', 'confirmed', 'CRONOGRAMA GENERAL DE ACTIVIDADES (1).docx', 701, true),
  (date '2026-11-04', time '16:20', time '17:00',
   'Libertad Religiosa: particularidades en Argentina',
   'Dr. Octavio Loprete · Presidente del Consorcio Latinoamericano de Libertad Religiosa',
   'FCJ', 'Plenaria', null, 'conference', 'confirmed', 'CRONOGRAMA GENERAL DE ACTIVIDADES (1).docx', 702, true),
  (date '2026-11-04', time '17:00', time '17:40',
   'Desafíos para la libertad religiosa en América Latina',
   'Dra. Carmen Aida Domínguez Hidalgo',
   'FCJ', 'Plenaria', null, 'conference', 'confirmed', 'CRONOGRAMA GENERAL DE ACTIVIDADES (1).docx', 703, true),
  (date '2026-11-04', time '17:40', time '18:20',
   'La Libertad Religiosa en Paraguay: avances y desafíos',
   'Mag. Abog. Claudio Salinas',
   'FCJ', 'Plenaria', null, 'conference', 'confirmed', 'CRONOGRAMA GENERAL DE ACTIVIDADES (1).docx', 704, true),
  (date '2026-11-04', time '18:20', time '19:00',
   'Creencias psicosociales sobre el amor, violencia de parejas y salud mental',
   'Estudio de las experiencias de personas denunciantes y las percepciones de los operadores de justicia en Ciudad del Este · Dra. Stella Mary Morinigo Abbate',
   'FCJ', 'Plenaria', null, 'conference', 'confirmed', 'CRONOGRAMA GENERAL DE ACTIVIDADES (1).docx', 705, true),
  (date '2026-11-04', time '19:00', time '19:20',
   'Cuando los derechos entran en conflicto',
   'Vacunación obligatoria y protección integral de niños, niñas y adolescentes · Mag. Milta Alexandra Bobadilla Cabrera',
   'FCJ', 'Plenaria', null, 'conference', 'confirmed', 'CRONOGRAMA GENERAL DE ACTIVIDADES (1).docx', 706, true),
  (date '2026-11-04', time '19:20', time '19:40',
   'Pena perpetua revisable en Paraguay: viabilidad constitucional y convencional',
   'Dra. Maria Alexandra Lopez De Moreira',
   'FCJ', 'Plenaria', null, 'conference', 'confirmed', 'CRONOGRAMA GENERAL DE ACTIVIDADES (1).docx', 707, true),
  (date '2026-11-04', time '19:40', time '20:00',
   'Coffee Break', 'Responsable: Comité Logístico',
   'FCJ', 'Plenaria', null, 'break', 'confirmed', 'CRONOGRAMA GENERAL DE ACTIVIDADES (1).docx', 708, true),
  (date '2026-11-04', time '20:00', time '21:20',
   'Presentaciones de Trabajos Científicos',
   'Responsable: Comité Científico de Facultad',
   'FCJ', 'Plenaria', null, 'scientific_session', 'confirmed', 'CRONOGRAMA GENERAL DE ACTIVIDADES (1).docx', 709, true),
  (date '2026-11-04', time '21:20', time '21:30',
   'Cierre de Jornada y Avisos Institucionales',
   'Responsable: Coordinación de Facultad',
   'FCJ', 'Plenaria', null, 'closing', 'confirmed', 'CRONOGRAMA GENERAL DE ACTIVIDADES (1).docx', 710, true);

create index if not exists program_items_schedule_idx
  on public.program_items (event_date, start_time, faculty, track);

commit;
