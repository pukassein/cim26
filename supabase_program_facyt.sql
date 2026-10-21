-- Integración del cronograma FACYT en el programa CIM 2026.
-- Fuente: Cronograma FACYT.xlsx
-- Es seguro volver a ejecutar este archivo: reemplaza solo los registros FACYT
-- importados desde esta fuente y no elimina actividades de otras facultades.

begin;

alter table public.program_items
  add column if not exists end_time time,
  add column if not exists faculty text not null default 'CIM26',
  add column if not exists track text not null default 'General',
  add column if not exists venue text,
  add column if not exists activity_type text not null default 'session',
  add column if not exists confirmation_status text not null default 'confirmed',
  add column if not exists source_reference text;

-- Las actividades ya cargadas para el martes mediante supabase_program_nov_03.sql
-- pertenecen a FCCA. Esta actualización no toca filas que ya tengan otra facultad.
update public.program_items
set faculty = 'FCCA', track = 'General'
where event_date = date '2026-11-03'
  and faculty = 'CIM26'
  and title in (
    'Acreditaciones y Recepción',
    'Inversiones Financieras',
    'Evolución del comercio exterior en los últimos 10 años: efectos y expectativas',
    'Inteligencia Emocional',
    'Presentación de trabajos en modalidad oral y póster'
  );

delete from public.program_items
where faculty = 'FACYT'
  and source_reference = 'Cronograma FACYT.xlsx'
  and event_date between date '2026-11-02' and date '2026-11-06';

insert into public.program_items
  (event_date, start_time, end_time, title, description, faculty, track, venue,
   activity_type, confirmation_status, source_reference, sort_order, is_published)
values
  -- Lunes 2: día principal de FACYT
  (date '2026-11-02', time '08:30', time '09:00',
   'Acreditaciones y Recepción', null,
   'FACYT', 'General', null, 'registration', 'confirmed', 'Cronograma FACYT.xlsx', 101, true),
  (date '2026-11-02', time '09:00', time '09:30',
   'Conferencia Inaugural', null,
   'FACYT', 'General', null, 'keynote', 'confirmed', 'Cronograma FACYT.xlsx', 102, true),
  (date '2026-11-02', time '09:30', time '10:30',
   'Presentaciones de Trabajos Científicos — Bloque Mañana I', null,
   'FACYT', 'General', null, 'scientific_session', 'confirmed', 'Cronograma FACYT.xlsx', 103, true),
  (date '2026-11-02', time '10:30', time '11:00',
   'Coffee Break', null,
   'FACYT', 'General', null, 'break', 'confirmed', 'Cronograma FACYT.xlsx', 104, true),
  (date '2026-11-02', time '11:00', time '12:00',
   'Presentaciones de Trabajos Científicos — Bloque Mañana II', null,
   'FACYT', 'General', null, 'scientific_session', 'confirmed', 'Cronograma FACYT.xlsx', 105, true),
  (date '2026-11-02', time '12:00', time '14:00',
   'Pausa / Almuerzo Libre', null,
   'FACYT', 'General', null, 'lunch', 'confirmed', 'Cronograma FACYT.xlsx', 106, true),
  (date '2026-11-02', time '14:00', time '15:00',
   'Presentaciones de Trabajos Científicos — Bloque Tarde I', null,
   'FACYT', 'General', null, 'scientific_session', 'confirmed', 'Cronograma FACYT.xlsx', 107, true),
  (date '2026-11-02', time '15:00', time '16:00',
   'Presentaciones de Trabajos Científicos — Bloque Tarde II', null,
   'FACYT', 'General', null, 'scientific_session', 'confirmed', 'Cronograma FACYT.xlsx', 108, true),
  (date '2026-11-02', time '16:00', time '17:00',
   'Apertura de Exposición de Pósteres', null,
   'FACYT', 'General', null, 'poster', 'confirmed', 'Cronograma FACYT.xlsx', 109, true),
  (date '2026-11-02', time '17:00', time '18:00',
   'Proyectos de Investigación e Innovación en Salud usando IA',
   'Dr. José Luis Vazquez · FPUNA, Paraguay',
   'FACYT', 'General', null, 'conference', 'confirmed', 'Cronograma FACYT.xlsx', 110, true),
  (date '2026-11-02', time '18:00', time '19:00',
   'Inteligencia Artificial aplicada a drones aéreos',
   'Dra. Gabriela Cáceres · España / Paraguay',
   'FACYT', 'General', null, 'conference', 'confirmed', 'Cronograma FACYT.xlsx', 111, true),

  -- Martes 3: actividades FACYT paralelas al día principal de FCCA
  (date '2026-11-03', time '09:00', time '09:30',
   'Actividad con MSc. Ing. Christian Gonzalez',
   'UC, Paraguay · Título de la actividad pendiente de confirmación.',
   'FACYT', 'General', null, 'session', 'pending', 'Cronograma FACYT.xlsx', 201, true),
  (date '2026-11-03', time '14:00', time '16:00',
   'Espacio Empresarial',
   'Empresa, tema y ubicación pendientes de confirmación.',
   'FACYT', 'General', null, 'business_session', 'pending', 'Cronograma FACYT.xlsx', 202, true),
  (date '2026-11-03', time '16:00', time '17:00',
   'Impresión 3D: herramienta para la presentación de proyectos',
   'Ing. Lucas Ricardo · FPTI, Paraguay. La secuencia o track no está especificada en el cronograma recibido.',
   'FACYT', 'Track por confirmar', null, 'conference', 'pending', 'Cronograma FACYT.xlsx', 203, true),
  (date '2026-11-03', time '16:00', time '17:00',
   'Interacción suelo-estructura aplicada',
   'Ing. José Duarte · JD Ingeniería y Construcción, Paraguay. Herramienta computacional para el análisis de fundaciones superficiales y profundas; la secuencia o track está pendiente de confirmación.',
   'FACYT', 'Track por confirmar', null, 'conference', 'pending', 'Cronograma FACYT.xlsx', 204, true),
  (date '2026-11-03', time '17:00', time '18:00',
   'Actividad con Ing. Paulo Melgarejo',
   'FPTI, Paraguay · Título de la actividad pendiente de confirmación.',
   'FACYT', 'General', null, 'session', 'pending', 'Cronograma FACYT.xlsx', 205, true),
  (date '2026-11-03', time '18:00', time '20:00',
   'Difusión de TFG de Ingeniería Electromecánica, Ingeniería Civil y Arquitectura', null,
   'FACYT', 'General', null, 'thesis_showcase', 'confirmed', 'Cronograma FACYT.xlsx', 206, true),

  -- Miércoles 4: dos tracks FACYT en paralelo
  (date '2026-11-04', time '08:30', time '12:00',
   'Workshop “Paisajes Invisibles: territorios en reconciliación con sistemas hídricos”',
   'Arq. Juan Manuel Bernal y Arq. Laura Urueña · Colombia',
   'FACYT', 'Track 1', null, 'workshop', 'confirmed', 'Cronograma FACYT.xlsx', 301, true),
  (date '2026-11-04', time '08:30', time '10:30',
   'Visita técnica a obra civil OTIFF Cell Shop',
   'Actividad indicada como “a confirmar” en el cronograma recibido.',
   'FACYT', 'Track 2', 'OTIFF Cell Shop', 'technical_visit', 'pending', 'Cronograma FACYT.xlsx', 302, true),
  (date '2026-11-04', time '14:00', time '17:00',
   'Workshop “Paisajes Invisibles: territorios en reconciliación con sistemas hídricos”',
   'Arq. Juan Manuel Bernal y Arq. Laura Urueña · Colombia',
   'FACYT', 'Track 1', null, 'workshop', 'confirmed', 'Cronograma FACYT.xlsx', 303, true),
  (date '2026-11-04', time '14:00', time '16:00',
   'Introducción a Dinámica de Fluidos Computacional',
   'Dr. Vinicius Poletto · UTFPR, Brasil',
   'FACYT', 'Track 2', null, 'workshop', 'confirmed', 'Cronograma FACYT.xlsx', 304, true),

  -- Jueves 5: dos tracks FACYT en paralelo
  (date '2026-11-05', time '08:30', time '12:00',
   'Workshop “Paisajes Invisibles: territorios en reconciliación con sistemas hídricos”',
   'Arq. Juan Manuel Bernal y Arq. Laura Urueña · Colombia',
   'FACYT', 'Track 1', null, 'workshop', 'confirmed', 'Cronograma FACYT.xlsx', 401, true),
  (date '2026-11-05', time '09:30', time '12:00',
   'Visita técnica a la Planta Solar Flotante', null,
   'FACYT', 'Track 2', 'ITAIPU', 'technical_visit', 'confirmed', 'Cronograma FACYT.xlsx', 402, true),
  (date '2026-11-05', time '14:00', time '17:00',
   'Workshop “Paisajes Invisibles: territorios en reconciliación con sistemas hídricos”',
   'Arq. Juan Manuel Bernal y Arq. Laura Urueña · Colombia',
   'FACYT', 'Track 1', null, 'workshop', 'confirmed', 'Cronograma FACYT.xlsx', 403, true),
  (date '2026-11-05', time '14:00', time '16:00',
   'Tecnologías del Hidrógeno',
   'Dr. Isnel Ubaque Diaz · Brasil · Cupo: 30 personas',
   'FACYT', 'Track 2', 'Sala 21', 'workshop', 'confirmed', 'Cronograma FACYT.xlsx', 404, true),
  (date '2026-11-05', time '16:00', time '18:00',
   'Bloque de Energía: Política Energética en la UC',
   'Ing. Sergio Oddone · MADES, Paraguay',
   'FACYT', 'Track 2', null, 'conference', 'confirmed', 'Cronograma FACYT.xlsx', 405, true),

  -- Viernes 6: dos tracks por la mañana y cierre compartido
  (date '2026-11-06', time '08:30', time '09:30',
   'Herramientas de diseño y proyecto eléctrico SIMARIS Suite',
   'Espacio Empresarial · Riedertech, Paraguay',
   'FACYT', 'Track 1', null, 'business_session', 'confirmed', 'Cronograma FACYT.xlsx', 501, true),
  (date '2026-11-06', time '08:30', time '12:00',
   'Workshop “Paisajes Invisibles: territorios en reconciliación con sistemas hídricos”',
   'Arq. Juan Manuel Bernal y Arq. Laura Urueña · Colombia',
   'FACYT', 'Track 2', null, 'workshop', 'confirmed', 'Cronograma FACYT.xlsx', 502, true),
  (date '2026-11-06', time '09:30', time '12:00',
   'Visita técnica a la Planta de Hidrógeno', null,
   'FACYT', 'Track 1', 'PTI-PY', 'technical_visit', 'confirmed', 'Cronograma FACYT.xlsx', 503, true),
  (date '2026-11-06', time '14:00', time '17:00',
   'Workshop “Paisajes Invisibles: territorios en reconciliación con sistemas hídricos”',
   'Arq. Juan Manuel Bernal y Arq. Laura Urueña · Colombia',
   'FACYT', 'Track 2', null, 'workshop', 'confirmed', 'Cronograma FACYT.xlsx', 504, true),
  (date '2026-11-06', time '16:00', time '17:00',
   'Hidrógeno verde: rutas de producción y principales aplicaciones en el contexto regional',
   'Dr. Isnel Ubaque Diaz · SENAI, Brasil',
   'FACYT', 'Track 1', null, 'conference', 'confirmed', 'Cronograma FACYT.xlsx', 505, true),
  (date '2026-11-06', time '17:00', time '18:00',
   'La Ciencia en Paraguay',
   'Disertación magistral · Dr. Benjamín Barán, Ministro Presidente de CONACYT, Paraguay',
   'FACYT', 'General', null, 'keynote', 'confirmed', 'Cronograma FACYT.xlsx', 506, true),
  (date '2026-11-06', time '18:00', time '19:00',
   'Entrega de reconocimientos a los mejores trabajos científicos por cada eje', null,
   'FACYT', 'General', null, 'awards', 'confirmed', 'Cronograma FACYT.xlsx', 507, true),
  (date '2026-11-06', time '19:00', time '20:00',
   'Cierre de jornada y avisos institucionales', null,
   'FACYT', 'General', null, 'closing', 'confirmed', 'Cronograma FACYT.xlsx', 508, true);

create index if not exists program_items_schedule_idx
  on public.program_items (event_date, start_time, faculty, track);

commit;

-- Nota de revisión: el Dr. Ing. Marcelo Romero figura entre los disertantes
-- confirmados del archivo fuente, pero no posee horario asignado; por eso no se
-- inserta hasta que FACYT confirme su día y hora.
