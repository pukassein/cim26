-- Actualización del programa FACSA del jueves 5 de noviembre de 2026.
-- Fuente: RESÚMEN FACSA jueves.docx
--
-- Esta versión sustituye el cronograma FACSA anterior de esa fecha. No toca
-- las actividades FACYT ni las de ninguna otra facultad. Puede ejecutarse más
-- de una vez sin crear duplicados.

begin;

alter table public.program_items
  add column if not exists end_time time,
  add column if not exists faculty text not null default 'CIM26',
  add column if not exists track text not null default 'General',
  add column if not exists venue text,
  add column if not exists activity_type text not null default 'session',
  add column if not exists confirmation_status text not null default 'confirmed',
  add column if not exists source_reference text;

-- La nueva matriz es una revisión completa de FACSA, por eso se eliminan
-- primero todas las filas FACSA del jueves, sin depender del nombre de la
-- fuente anterior.
delete from public.program_items
where faculty = 'FACSA'
  and event_date = date '2026-11-05';

insert into public.program_items
  (event_date, start_time, end_time, title, description, faculty, track, venue,
   activity_type, confirmation_status, source_reference, sort_order, is_published)
values
  (date '2026-11-05', time '08:00', time '08:30',
   'Acreditación y recepción', 'Café de bienvenida.',
   'FACSA', 'General', 'Aula Magna', 'registration', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 601, true),

  (date '2026-11-05', time '08:00', time '09:00',
   'Marco legal para la importación, tenencia y manejo de productos controlados',
   'Estupefacientes y otros productos controlados · SENAD.',
   'FACSA', 'Química y Farmacia', 'Salón Hugo Rivarola', 'conference', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 602, true),

  (date '2026-11-05', time '08:00', time '10:30',
   'Pendientes y desafíos actuales de la medición en psicología',
   'Taller · Enrique Morosini.',
   'FACSA', 'Psicología', 'Sala 21', 'workshop', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 603, true),

  (date '2026-11-05', time '08:00', time '11:00',
   'Taller de láminas de hematología', 'Dirigido a estudiantes.',
   'FACSA', 'Ciencias Químicas', 'Laboratorio', 'workshop', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 604, true),

  (date '2026-11-05', time '09:00', time '09:30',
   'Apertura oficial del día de FACSA', null,
   'FACSA', 'General', 'Aula Magna', 'session', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 605, true),

  (date '2026-11-05', time '09:30', time '09:45',
   'Receso', null,
   'FACSA', 'General', 'Todas las salas', 'break', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 606, true),

  (date '2026-11-05', time '09:45', time '10:30',
   'Riesgo de los procedimientos estéticos',
   'Conferencia magistral 1 · Dra. Gabriela Mafei.',
   'FACSA', 'Medicina', 'Aula Magna', 'keynote', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 607, true),

  (date '2026-11-05', time '10:30', time '10:45',
   'Preguntas, respuestas y debate interdisciplinario',
   'Dra. Gabriela Mafei, Medicina, y Dra. Ybete Welter, Derecho.',
   'FACSA', 'Medicina / Odontología', 'Aula Magna', 'session', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 608, true),

  (date '2026-11-05', time '10:45', time '11:30',
   'Tendencias actuales en regeneración periodontal',
   'Dra. Constanza Pontarolo · UBA.',
   'FACSA', 'Odontología', 'Aula Magna', 'conference', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 609, true),

  (date '2026-11-05', time '10:45', time '11:30',
   'Aspectos legales de fármacos y equipos médicos',
   'Seminario · DINAVISA.',
   'FACSA', 'Química y Farmacia', 'Salón Hugo Rivarola', 'conference', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 610, true),

  (date '2026-11-05', time '10:45', time '11:30',
   'Terapia láser: lo que el odontólogo debe conocer',
   'Dra. Nora Rivas.',
   'FACSA', 'Odontología', 'Sala 21', 'conference', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 611, true),

  (date '2026-11-05', time '11:30', time '12:30',
   'Cirugía plástica en recesiones gingivales',
   'Conferencia · Dra. Jennifer Alberichi · UBA.',
   'FACSA', 'Odontología', 'Aula Magna', 'conference', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 612, true),

  (date '2026-11-05', time '12:30', time '13:30',
   'Receso / almuerzo libre', null,
   'FACSA', 'General', 'Todas las salas', 'lunch', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 613, true),

  (date '2026-11-05', time '13:30', time '14:30',
   'Enzimas de suelo: evaluación del estado nutricional de suelos y compostaje',
   'Charla magistral · Enzume Green Tech · Dra. Fátima Yubero.',
   'FACSA', 'Ciencias Químicas', 'Salón Hugo Rivarola', 'keynote', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 614, true),

  (date '2026-11-05', time '14:00', time '15:30',
   'Trabajos orales de Medicina y Psicología',
   'Presentaciones de 15 minutos cada una.',
   'FACSA', 'Medicina / Psicología', 'Aula Magna', 'scientific_session', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 615, true),

  (date '2026-11-05', time '14:00', time '17:00',
   'Taller de láminas: Hematología avanzada', null,
   'FACSA', 'Ciencias Químicas', 'Laboratorio', 'workshop', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 616, true),

  (date '2026-11-05', time '15:30', time '16:00',
   'Exposición de pósteres', null,
   'FACSA', 'General', 'Aula Magna', 'poster', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 617, true),

  (date '2026-11-05', time '15:30', time '16:00',
   'Taller de Bioquímica', null,
   'FACSA', 'Ciencias Químicas', 'Laboratorio', 'workshop', 'pending',
   'RESÚMEN FACSA jueves.docx', 618, true),

  (date '2026-11-05', time '15:30', time '16:00',
   'Taller de RCP básico',
   'La matriz coloca esta actividad en la celda del Laboratorio; ubicación por confirmar.',
   'FACSA', 'Medicina', 'Por confirmar', 'workshop', 'pending',
   'RESÚMEN FACSA jueves.docx', 619, true),

  (date '2026-11-05', time '16:00', time '16:30',
   'Agrotóxico y el riesgo social',
   'Panel debate · Dr. Fabián Franco.',
   'FACSA', 'Medicina', 'Aula Magna', 'conference', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 620, true),

  (date '2026-11-05', time '16:00', time '16:30',
   'Estudio psicométrico del MMPI-2-RF',
   'Conferencia · Dra. Elizabeth Flor.',
   'FACSA', 'Psicología', 'Sala 21', 'conference', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 621, true),

  (date '2026-11-05', time '16:45', time '17:00',
   'Preguntas, respuestas y cierre', null,
   'FACSA', 'Medicina', 'Aula Magna', 'closing', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 622, true),

  (date '2026-11-05', time '16:45', time '17:00',
   'Salud mental en la educación superior',
   'Aportes de la Terapia Dialéctica Conductual · Dra. María Victoria Vergara. El documento indica 30 minutos dentro de una franja de 15 minutos; horario por confirmar.',
   'FACSA', 'Psicología', 'Sala 21', 'conference', 'pending',
   'RESÚMEN FACSA jueves.docx', 623, true),

  (date '2026-11-05', time '17:00', time '17:30',
   'Tabaquismo y vapeadores',
   'Conferencia magistral 2 · Dra. Graciela Gamarra.',
   'FACSA', 'Medicina', 'Aula Magna', 'keynote', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 624, true),

  (date '2026-11-05', time '17:30', time '18:00',
   'Preguntas y respuestas de la conferencia magistral 2', null,
   'FACSA', 'Medicina', 'Aula Magna', 'session', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 625, true),

  (date '2026-11-05', time '17:30', time '18:00',
   'Perfil cognitivo mediante el WISC-V',
   'Conferencia · Dra. Elizabeth Flor y Lic. Ramona Benítez.',
   'FACSA', 'Psicología', 'Sala 21', 'conference', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 626, true),

  (date '2026-11-05', time '18:00', time '18:30',
   'Coffee break de cierre', null,
   'FACSA', 'General', 'Hall', 'break', 'confirmed',
   'RESÚMEN FACSA jueves.docx', 627, true);

create index if not exists program_items_schedule_idx
  on public.program_items (event_date, start_time, faculty, track);

commit;

