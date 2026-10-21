-- Integración del cronograma FACSA del jueves 5 de noviembre de 2026.
-- Fuente: planilla congresoFACSA.xlsx
-- Es seguro volver a ejecutar este archivo: reemplaza solo las filas FACSA
-- importadas desde esta planilla y conserva el programa de las demás facultades.

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
where faculty = 'FACSA'
  and source_reference = 'planilla congresoFACSA.xlsx'
  and event_date = date '2026-11-05';

insert into public.program_items
  (event_date, start_time, end_time, title, description, faculty, track, venue,
   activity_type, confirmation_status, source_reference, sort_order, is_published)
values
  (date '2026-11-05', time '08:00', time '08:30',
   'Acreditación y recepción', 'Café de bienvenida.',
   'FACSA', 'Plenaria', null, 'registration', 'confirmed', 'planilla congresoFACSA.xlsx', 601, true),
  (date '2026-11-05', time '08:00', time '10:30',
   'Pendientes y desafíos actuales de la medición en psicología y ciencias de la salud',
   'Enrique Morosini · Taller presencial teórico-práctico · Paraguay',
   'FACSA', 'Psicología', null, 'workshop', 'confirmed', 'planilla congresoFACSA.xlsx', 602, true),
  (date '2026-11-05', time '08:00', time '11:00',
   'Taller sobre láminas de hematología', 'Dirigido a estudiantes.',
   'FACSA', 'Ciencias Químicas', null, 'workshop', 'confirmed', 'planilla congresoFACSA.xlsx', 603, true),
  (date '2026-11-05', time '09:00', time '09:30',
   'Apertura oficial del día de FACSA',
   'Palabras del Decano y del Coordinador General.',
   'FACSA', 'Plenaria', null, 'session', 'confirmed', 'planilla congresoFACSA.xlsx', 604, true),
  (date '2026-11-05', time '09:30', time '09:45',
   'Receso', null,
   'FACSA', 'Plenaria', null, 'break', 'confirmed', 'planilla congresoFACSA.xlsx', 605, true),
  (date '2026-11-05', time '09:45', time '10:30',
   'Riesgo de los procedimientos estéticos',
   'Conferencia magistral 1 · Dra. Gabriela Mafei Aguilera',
   'FACSA', 'Medicina', null, 'keynote', 'confirmed', 'planilla congresoFACSA.xlsx', 606, true),
  (date '2026-11-05', time '10:30', time '10:45',
   'Preguntas y respuestas de la conferencia magistral 1', null,
   'FACSA', 'Medicina', null, 'session', 'confirmed', 'planilla congresoFACSA.xlsx', 607, true),
  (date '2026-11-05', time '10:30', time '10:45',
   'Debate interdisciplinario',
   'Dra. Gabriela Mafei Aguilera, Medicina, y Dra. Ybete Welter, Derecho.',
   'FACSA', 'Odontología', null, 'session', 'confirmed', 'planilla congresoFACSA.xlsx', 608, true),
  (date '2026-11-05', time '10:45', time '11:30',
   'Agrotóxico y riesgo social', 'Panel debate · Dr. Fabián Franco',
   'FACSA', 'Medicina', null, 'conference', 'confirmed', 'planilla congresoFACSA.xlsx', 609, true),
  (date '2026-11-05', time '10:45', time '11:30',
   'Terapia láser: lo que el odontólogo debe conocer', 'Dra. Nora Rivas',
   'FACSA', 'Odontología', null, 'conference', 'confirmed', 'planilla congresoFACSA.xlsx', 610, true),
  (date '2026-11-05', time '10:45', time '11:30',
   'Aspectos legales de los fármacos y equipos médicos', 'Seminario · DINAVISA',
   'FACSA', 'Ciencias Químicas', null, 'conference', 'confirmed', 'planilla congresoFACSA.xlsx', 611, true),
  (date '2026-11-05', time '11:30', time '12:30',
   'Preguntas, respuestas y cierre del bloque de Medicina', null,
   'FACSA', 'Medicina', null, 'session', 'confirmed', 'planilla congresoFACSA.xlsx', 612, true),
  (date '2026-11-05', time '12:30', time '13:30',
   'Receso', null,
   'FACSA', 'Plenaria', null, 'lunch', 'confirmed', 'planilla congresoFACSA.xlsx', 613, true),
  (date '2026-11-05', time '13:30', time '14:30',
   'Charla magistral de Enzume Green Tech', 'CEO Prof. Dra. Fátima Yubero',
   'FACSA', 'Ciencias Químicas', null, 'keynote', 'confirmed', 'planilla congresoFACSA.xlsx', 614, true),
  (date '2026-11-05', time '14:00', time '15:30',
   'Sesión de trabajos orales de Medicina', 'Presentaciones de 15 minutos cada una.',
   'FACSA', 'Medicina', null, 'scientific_session', 'confirmed', 'planilla congresoFACSA.xlsx', 615, true),
  (date '2026-11-05', time '14:00', time '15:30',
   'Sesión de trabajos orales de Psicología', 'Presentaciones de 15 minutos cada una.',
   'FACSA', 'Psicología', null, 'scientific_session', 'confirmed', 'planilla congresoFACSA.xlsx', 616, true),
  (date '2026-11-05', time '14:00', time '17:00',
   'Taller de láminas: Hematología avanzada', null,
   'FACSA', 'Ciencias Químicas', null, 'workshop', 'confirmed', 'planilla congresoFACSA.xlsx', 617, true),
  (date '2026-11-05', time '14:30', time '15:30',
   'Cómo realizar revisiones sistemáticas', 'Taller · M.Sc. Julieta Méndez',
   'FACSA', 'Odontología', null, 'workshop', 'confirmed', 'planilla congresoFACSA.xlsx', 618, true),
  (date '2026-11-05', time '14:30', time '16:00',
   'Sesión de trabajos orales',
   'Presentaciones de 15 minutos cada una. La carrera o sala no está identificada en la planilla.',
   'FACSA', 'Track por confirmar', null, 'scientific_session', 'pending', 'planilla congresoFACSA.xlsx', 619, true),
  (date '2026-11-05', time '15:30', time '16:00',
   'Taller práctico de RCP básico', 'Actividad opcional, sujeta a disponibilidad.',
   'FACSA', 'Medicina', null, 'workshop', 'pending', 'planilla congresoFACSA.xlsx', 620, true),
  (date '2026-11-05', time '15:30', time '16:00',
   'Taller práctico de Bioquímica', 'Actividad opcional, sujeta a disponibilidad.',
   'FACSA', 'Ciencias Químicas', null, 'workshop', 'pending', 'planilla congresoFACSA.xlsx', 621, true),
  (date '2026-11-05', time '16:00', time '16:30',
   'Coffee break y exposición de pósteres', null,
   'FACSA', 'Plenaria', null, 'poster', 'confirmed', 'planilla congresoFACSA.xlsx', 622, true),
  (date '2026-11-05', time '16:00', time '16:30',
   'Estudio psicométrico del MMPI-2-RF a nivel país, 2024',
   'Conferencia · Dra. Elizabeth Flor · Paraguay',
   'FACSA', 'Psicología', null, 'conference', 'confirmed', 'planilla congresoFACSA.xlsx', 623, true),
  (date '2026-11-05', time '16:30', time '17:00',
   'Salud mental en la educación superior',
   'Aportes de la Terapia Dialéctica Conductual al desarrollo de habilidades para la vida · Dra. María Victoria Vergara · Paraguay',
   'FACSA', 'Psicología', null, 'conference', 'confirmed', 'planilla congresoFACSA.xlsx', 624, true),
  (date '2026-11-05', time '17:00', time '17:30',
   'Perfil cognitivo mediante WISC-V en una muestra clínica infantil de APAMAP',
   'Dra. Elizabeth Flor y Lic. Ramona Benítez · Paraguay',
   'FACSA', 'Psicología', null, 'conference', 'confirmed', 'planilla congresoFACSA.xlsx', 625, true),
  (date '2026-11-05', time '17:00', time '17:30',
   'Tabaquismo y vapeadores: datos recientes y marco legal',
   'Conferencia magistral 2 · Dra. Graciela Gamarra',
   'FACSA', 'Medicina', null, 'keynote', 'confirmed', 'planilla congresoFACSA.xlsx', 626, true),
  (date '2026-11-05', time '17:30', time '18:00',
   'Preguntas y respuestas de la conferencia magistral 2', null,
   'FACSA', 'Medicina', null, 'session', 'confirmed', 'planilla congresoFACSA.xlsx', 627, true),
  (date '2026-11-05', time '18:00', time '18:30',
   'Coffee break de cierre', 'Espacio de confraternización.',
   'FACSA', 'Plenaria', null, 'break', 'confirmed', 'planilla congresoFACSA.xlsx', 628, true);

create index if not exists program_items_schedule_idx
  on public.program_items (event_date, start_time, faculty, track);

commit;

-- La sección de cierre del viernes incluida en la planilla no se importa aquí:
-- este archivo carga exclusivamente el cronograma FACSA del jueves solicitado.
