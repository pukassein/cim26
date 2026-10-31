-- Integración del cronograma FACYT actualizado en el programa CIM 2026.
-- Fuente principal: Cronograma Seminario FACYT 2026.xlsx - Cronograma.pdf
-- El PDF actualiza los seminarios; se preservan los talleres confirmados de
-- “Paisajes Invisibles” incluidos en Cronograma FACYT.xlsx.
-- Es seguro volver a ejecutar este archivo: reemplaza solo los registros FACYT
-- importados desde estas fuentes y no elimina actividades de otras facultades.

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
  and event_date between date '2026-11-02' and date '2026-11-06'
  and source_reference in (
    'Cronograma FACYT.xlsx',
    'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv',
    'Cronograma Seminario FACYT 2026.xlsx - Cronograma.pdf',
    'Cronograma FACYT.xlsx - visitas técnicas preservadas',
    'Cronograma FACYT.xlsx - talleres preservados'
  );

insert into public.program_items
  (event_date, start_time, end_time, title, description, faculty, track, venue,
   activity_type, confirmation_status, source_reference, sort_order, is_published)
values
  -- Lunes 2: programa actualizado con actividades paralelas en Aula Magna y Taller B.
  (date '2026-11-02', time '08:30', time '09:00', 'Acreditaciones y Recepción', null,
   'FACYT', 'General', null, 'registration', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 101, true),
  (date '2026-11-02', time '09:00', time '09:30', 'Entre Sistemas: lectura urbana y visión de Ciudad del Este',
   'Arq. Arline Cañiza, Arq. Andrea Velázquez, Luján Torres y Alejandra Riveros',
   'FACYT', 'Aula Magna', 'Aula Magna', 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 102, true),
  (date '2026-11-02', time '09:30', time '10:30', 'Lanzamiento del Workshop Paisajes Invisibles',
   'Arq. Juan Manuel Bernal y Arq. Laura Urueña · Colombia',
   'FACYT', 'Aula Magna', 'Aula Magna', 'workshop', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 103, true),
  (date '2026-11-02', time '10:30', time '11:00', 'Coffee Break', null,
   'FACYT', 'General', null, 'break', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 104, true),
  (date '2026-11-02', time '14:00', time '16:00', 'Presentaciones de Trabajos Científicos', null,
   'FACYT', 'General', null, 'scientific_session', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 105, true),
  (date '2026-11-02', time '16:00', time '17:00', 'Exposición de Pósteres Científicos', null,
   'FACYT', 'General', null, 'poster', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 106, true),
  (date '2026-11-02', time '17:00', time '17:30', 'De Corea del Sur al Paraguay: matricería y manufactura avanzada, el camino hacia la Industria 4.0',
   'Ing. Paulo Melgarejo', 'FACYT', 'Aula Magna', 'Aula Magna', 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 107, true),
  (date '2026-11-02', time '17:00', time '17:30', 'Proyectos de Investigación e Innovación en Salud usando IA',
   'Dr. José Luis Vázquez', 'FACYT', 'Taller B', 'Taller B', 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 108, true),
  (date '2026-11-02', time '17:30', time '18:00', 'Itaipu Digital Substation Innovation Laboratory for Testing, Validation and Education',
   'Ing. Frankz Lindstrom', 'FACYT', 'Aula Magna', 'Aula Magna', 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 109, true),
  (date '2026-11-02', time '17:30', time '18:00', 'Desafíos de la Combustión',
   'Dr. Darío Alviso', 'FACYT', 'Taller B', 'Taller B', 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 110, true),
  (date '2026-11-02', time '18:00', time '18:15', 'Lanzamiento del libro “Imaginería Misionera”',
   'Dra. Arq. Ana Burró', 'FACYT', 'Aula Magna', 'Aula Magna', 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 111, true),
  (date '2026-11-02', time '18:00', time '18:15', 'Producción científica, aciertos y desaciertos en la carrera de Arquitectura, en la Universidad Católica Nuestra Señora de la Asunción, Campus Itapúa',
   'Dr. Arq. Arnoldo Eduardo Álvarez López', 'FACYT', 'Taller B', 'Taller B', 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 112, true),
  (date '2026-11-02', time '18:15', time '18:30', 'Experiencias en la aplicación de QGIS y Claude AI en la elaboración de capas espaciales como avances para el ordenamiento urbano y territorial',
   'Dr. Arq. Arnoldo Eduardo Álvarez López', 'FACYT', 'Taller B', 'Taller B', 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 113, true),

  -- Martes 3: actividades FACYT paralelas al día principal de FCCA.
  (date '2026-11-03', time '09:00', time '09:30', 'Cementos LC3: una alternativa sostenible para la construcción',
   'Ing. Christian González', 'FACYT', 'Aula Magna', 'Aula Magna', 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 201, true),
  (date '2026-11-03', time '09:30', time '10:00', 'De la Escuela a la Universidad: experiencias y retos en la Robótica Educativa',
   'Leslie Maldonado y Dulce Duro', 'FACYT', 'Aula Magna', 'Aula Magna', 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 202, true),
  (date '2026-11-03', time '10:00', time '10:30', 'Arasy Sat: el despegue de una idea',
   'Equipo Arasy-SAT', 'FACYT', 'Aula Magna', 'Aula Magna', 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 203, true),
  (date '2026-11-03', time '16:00', time '16:30', 'Impresión 3D: herramienta para la presentación de proyectos',
   'Ing. Lucas Ricardo', 'FACYT', 'Aula Magna', 'Aula Magna', 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 204, true),
  (date '2026-11-03', time '16:30', time '17:00', 'Interacción suelo-estructura aplicada: una herramienta computacional para el análisis de fundaciones superficiales y profundas en diferentes tipos de estratos',
   'Ing. José Duarte', 'FACYT', 'Aula Magna', 'Aula Magna', 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 205, true),
  (date '2026-11-03', time '18:00', time '19:00', 'Difusión de TFG', null,
   'FACYT', 'General', null, 'thesis_showcase', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 206, true),
  (date '2026-11-03', time '19:00', time '21:00', 'Minicurso: redacción de artículos científicos',
   'Ing. Willians Panadero Bogarín', 'FACYT', 'General', null, 'workshop', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 207, true),

  -- Miércoles 4: seminarios actualizados y taller confirmado preservado.
  (date '2026-11-04', time '08:30', time '12:00',
   'Workshop “Paisajes Invisibles: territorios en reconciliación con sistemas hídricos”',
   'Arq. Juan Manuel Bernal y Arq. Laura Urueña · Colombia',
   'FACYT', 'Track 1', null, 'workshop', 'confirmed', 'Cronograma FACYT.xlsx - talleres preservados', 300, true),
  (date '2026-11-04', time '09:30', time '13:30', 'Concurso de Puentes',
   'Grupo de Investigación Concreto Mbarete', 'FACYT', 'Aula Magna', 'Aula Magna', 'scientific_session', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 301, true),
  (date '2026-11-04', time '13:30', time '14:00', 'Ensayo de Puentes y Premiación',
   'Grupo de Investigación Concreto Mbarete', 'FACYT', 'Aula Magna', 'Aula Magna', 'awards', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 302, true),
  (date '2026-11-04', time '14:00', time '16:00', 'Introducción a Dinámica de Fluidos Computacional',
   'Dr. Vinicius Poletto', 'FACYT', 'General', null, 'workshop', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 303, true),
  (date '2026-11-04', time '16:00', time '16:30', 'NASA Space Apps Challenge — Ciudad del Este',
   null, 'FACYT', 'Taller C', 'Taller C', 'workshop', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 304, true),
  (date '2026-11-04', time '16:30', time '17:00', 'Conociendo más del IEEE: una puerta al mundo de la tecnología',
   'Ing. Verónica Lambaré, Ing. Lucas Moreira e Ing. Esteban Bravo', 'FACYT', 'Taller C', 'Taller C', 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 305, true),
  (date '2026-11-04', time '17:00', time '17:30', 'Panel WIE (Women in Engineering)',
   'Dra. Ing. Gabriela Cáceres, Ing. Yanine Mendoza e Ing. Verónica Lambaré', 'FACYT', 'General', null, 'panel', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 306, true),
  (date '2026-11-04', time '17:30', time '18:00', 'Inteligencia Artificial aplicada a drones aéreos',
   'Dra. Gabriela Cáceres', 'FACYT', 'General', null, 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 307, true),
  (date '2026-11-04', time '14:00', time '17:00',
   'Workshop “Paisajes Invisibles: territorios en reconciliación con sistemas hídricos”',
   'Arq. Juan Manuel Bernal y Arq. Laura Urueña · Colombia',
   'FACYT', 'Track 1', null, 'workshop', 'confirmed', 'Cronograma FACYT.xlsx - talleres preservados', 308, true),

  -- Jueves 5: seminarios actualizados y taller confirmado preservado.
  (date '2026-11-05', time '08:30', time '12:00',
   'Workshop “Paisajes Invisibles: territorios en reconciliación con sistemas hídricos”',
   'Arq. Juan Manuel Bernal y Arq. Laura Urueña · Colombia',
   'FACYT', 'Track 1', null, 'workshop', 'confirmed', 'Cronograma FACYT.xlsx - talleres preservados', 400, true),
  (date '2026-11-05', time '13:00', time '16:00', 'Tecnologías del Hidrógeno',
   'Dr. Isnel Ubaque Díaz', 'FACYT', 'General', 'Sala 21', 'workshop', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 401, true),
  (date '2026-11-05', time '16:00', time '17:00', 'Política Energética en la UC',
   'Ing. Sergio Oddone Costanzo', 'FACYT', 'Bloque de Energía', null, 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 402, true),
  (date '2026-11-05', time '17:00', time '18:00', 'Normas Técnicas de Eficiencia Energética',
   'INTN, CTN 51', 'FACYT', 'Bloque de Energía', null, 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 403, true),
  (date '2026-11-05', time '18:00', time '19:00', 'Eficiencia Energética en el Protocolo de Montreal y Enmienda de Kigali',
   'Ozono/DGA — MADES', 'FACYT', 'Bloque de Energía', null, 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 404, true),
  (date '2026-11-05', time '14:00', time '17:00',
   'Workshop “Paisajes Invisibles: territorios en reconciliación con sistemas hídricos”',
   'Arq. Juan Manuel Bernal y Arq. Laura Urueña · Colombia',
   'FACYT', 'Track 1', null, 'workshop', 'confirmed', 'Cronograma FACYT.xlsx - talleres preservados', 405, true),

  -- Viernes 6: seminarios actualizados y taller confirmado preservado.
  (date '2026-11-06', time '08:30', time '12:00',
   'Workshop “Paisajes Invisibles: territorios en reconciliación con sistemas hídricos”',
   'Arq. Juan Manuel Bernal y Arq. Laura Urueña · Colombia',
   'FACYT', 'Track 2', null, 'workshop', 'confirmed', 'Cronograma FACYT.xlsx - talleres preservados', 500, true),
  (date '2026-11-06', time '08:30', time '09:30', 'Herramientas de diseño y proyecto eléctrico SIMARIS Suite',
   'Riedertech Paraguay', 'FACYT', 'General', null, 'business_session', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 501, true),
  (date '2026-11-06', time '16:30', time '17:00', 'Hidrógeno verde: rutas de producción y principales aplicaciones en el contexto regional',
   'Dr. Isnel Ubaque Díaz', 'FACYT', 'General', null, 'conference', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 502, true),
  (date '2026-11-06', time '17:00', time '17:30', 'La Ciencia en Paraguay',
   'Dr. Benjamín Barán', 'FACYT', 'General', null, 'keynote', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 503, true),
  (date '2026-11-06', time '17:30', time '18:00', 'Entrega de premios a los mejores trabajos científicos',
   'Dr. Benjamín Barán', 'FACYT', 'General', null, 'awards', 'confirmed', 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv', 504, true),
  (date '2026-11-06', time '14:00', time '17:00',
   'Workshop “Paisajes Invisibles: territorios en reconciliación con sistemas hídricos”',
   'Arq. Juan Manuel Bernal y Arq. Laura Urueña · Colombia',
   'FACYT', 'Track 2', null, 'workshop', 'confirmed', 'Cronograma FACYT.xlsx - talleres preservados', 505, true);

-- La carga se construyó inicialmente desde el CSV exportado, pero fue verificada
-- y corregida contra el PDF definitivo. Se guarda el PDF como fuente canónica.
update public.program_items
set source_reference = 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.pdf'
where faculty = 'FACYT'
  and event_date between date '2026-11-02' and date '2026-11-06'
  and source_reference = 'Cronograma Seminario FACYT 2026.xlsx - Cronograma.csv';

create index if not exists program_items_schedule_idx
  on public.program_items (event_date, start_time, faculty, track);

commit;

-- Supuestos de duración derivados de las celdas combinadas del PDF:
-- 1. Las celdas vacías bajo una actividad representan su continuación hasta la
--    siguiente franja con contenido en la misma columna.
-- 2. Difusión de TFG del martes se fija de 18:00 a 19:00, antes del minicurso.
-- 3. Concurso de Puentes se fija de 09:30 a 13:30, antes de ensayo y premiación.
