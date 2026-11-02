-- Cronograma detallado de presentaciones orales CIM 2026.
-- Fuente: Cronograma_Presentaciones_Orales_CIM2026_Sala21_TallerB.xlsx
-- Fecha inferida del bloque FACYT “Presentaciones de Trabajos Científicos”.

begin;

create table if not exists public.oral_presentations (
  id uuid primary key default gen_random_uuid(),
  event_date date not null,
  start_time time not null,
  end_time time not null,
  submission_id integer not null,
  title text not null,
  authors text not null,
  institution text,
  room text not null,
  evaluators text,
  sort_order integer not null default 0,
  is_published boolean not null default true,
  source_reference text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint oral_presentations_valid_time check (end_time > start_time),
  constraint oral_presentations_unique_submission unique (event_date, submission_id)
);

alter table public.oral_presentations enable row level security;

grant select on table public.oral_presentations to anon, authenticated;

drop policy if exists "Public can view published oral presentations"
  on public.oral_presentations;

create policy "Public can view published oral presentations"
  on public.oral_presentations
  for select
  to anon, authenticated
  using (is_published = true);

-- Elimina cualquier versión anterior de estos 12 trabajos, aunque haya sido
-- cargada antes de agregar source_reference o conserve los nombres de sala viejos.
delete from public.oral_presentations
where event_date = date '2026-11-02'
  and submission_id in (90, 55, 42, 32, 43, 57, 75, 54, 46, 80, 44, 98);

-- Vincula el cronograma detallado con su bloque en el programa general.
update public.program_items
set track = 'Presentaciones orales',
    venue = 'Aula Magna / Taller A',
    description = '12 trabajos en dos salas simultáneas. Cada presentación dispone de 15 minutos y 5 minutos para preguntas.'
where event_date = date '2026-11-02'
  and start_time = time '14:00'
  and faculty = 'FACYT'
  and activity_type = 'scientific_session';

insert into public.oral_presentations
  (event_date, start_time, end_time, submission_id, title, authors, institution,
   room, evaluators, sort_order, is_published, source_reference)
values
  (date '2026-11-02', time '14:00', time '14:20', 90,
   'Análisis del nivel del río Paraná en Ciudad del Este mediante modelos de regresión lineal y cuadrática',
   'Alan Bernardo Giménez Fernández, Camila Naiara López Benítez (Tutor: Ing. Lucas Moreira)',
   'Universidad Católica “Nuestra Señora de la Asunción”',
   'Aula Magna', 'Dr. Fernando Benítez (FPUNA) e Ing. Ladislao Aranda (UC)', 101, true,
   'Cronograma_Presentaciones_Orales_CIM2026_Sala21_TallerB.xlsx'),

  (date '2026-11-02', time '14:00', time '14:20', 55,
   'Optimización de la eficiencia estructural de una cercha representativa de la cubierta metálica de la Facultad',
   'Sabrina Sánchez, Stefany Arzamendia, Thais Molinas, Antonio Acosta, Santiago Giménez, Jesús Borja, Luz Cardozo, Clara Ortiz',
   'Universidad Católica, Campus Alto Paraná',
   'Taller A', 'Dr. Pedro Gardel (UC) y M.Sc. Ing. Hussein Moussa (USP)', 102, true,
   'Cronograma_Presentaciones_Orales_CIM2026_Sala21_TallerB.xlsx'),

  (date '2026-11-02', time '14:20', time '14:40', 42,
   'Desplazamiento de cargas flexibles considerando tarifas horarias para la reducción de costos de una microrred',
   'Marília Berti Peruzzo, Bruno M. Olmedo Chavez, Gabriel Brugues Soares, Pedro G. Agripino Cruz, Victor H. Wentz, Joylan N. Maciel, Leandro A. Ensina, Oswaldo H. Ando Junior, Jorge J. Gimenez Ledesma',
   'UNILA / UFPB / UTFPR',
   'Aula Magna', 'Dr. Fernando Benítez (FPUNA) e Ing. Ladislao Aranda (UC)', 201, true,
   'Cronograma_Presentaciones_Orales_CIM2026_Sala21_TallerB.xlsx'),

  (date '2026-11-02', time '14:20', time '14:40', 32,
   'Algoritmo de carga inteligente con pulsos adaptativos y gestión de recarga para baterías de Li-ion',
   'Alejandro R. Acevedo Gurpegui, Rafael M. Adorno Almeida, Yessica Monges Villasboa',
   'Universidad Católica / Parque Tecnológico Itaipu (PTI-PY)',
   'Taller A', 'Dr. Pedro Gardel (UC) y M.Sc. Ing. Hussein Moussa (USP)', 202, true,
   'Cronograma_Presentaciones_Orales_CIM2026_Sala21_TallerB.xlsx'),

  (date '2026-11-02', time '14:40', time '15:00', 43,
   'Calibración conformal temporal para la predicción probabilística de la demanda eléctrica del Paraguay: un estudio comparativo',
   'Diego D. Apolinário, Edgar M. Carreño Franco, Gabriel Brugues Soares, Marília L. Berti Peruzzo, Joylan N. Maciel, Oswaldo H. Ando Junior, Jorge J. Gimenez Ledesma',
   'UNILA / UNIOESTE / UFPB',
   'Aula Magna', 'Dr. Fernando Benítez (FPUNA) e Ing. Ladislao Aranda (UC)', 301, true,
   'Cronograma_Presentaciones_Orales_CIM2026_Sala21_TallerB.xlsx'),

  (date '2026-11-02', time '14:40', time '15:00', 57,
   'Planificador de rutas para vehículo autónomo a escala basado en redes neuronales y visión computacional',
   'Rodrigo Javier Báez Maciel',
   'Universidad Católica “Nuestra Señora de la Asunción”',
   'Taller A', 'Dr. Pedro Gardel (UC) y M.Sc. Ing. Hussein Moussa (USP)', 302, true,
   'Cronograma_Presentaciones_Orales_CIM2026_Sala21_TallerB.xlsx'),

  (date '2026-11-02', time '15:00', time '15:20', 75,
   'Mantenimiento de redes de distribución mediante priorización por matriz de riesgo en OpenDSS',
   'Victor Antonio Cuenca Fleitas, Gabriel Brugues Soares, Rodrigo Delfim Guarizi, Jorge Javier Gimenez Ledesma',
   'UNILA / UFPB / Itaipu Parquetec',
   'Aula Magna', 'Dr. Fernando Benítez (FPUNA) e Ing. Ladislao Aranda (UC)', 401, true,
   'Cronograma_Presentaciones_Orales_CIM2026_Sala21_TallerB.xlsx'),

  (date '2026-11-02', time '15:00', time '15:20', 54,
   'Evaluación experimental del compromiso entre exactitud y costo computacional en modelos de potencia fotovoltaica',
   'Bruno Manuel Olmedo Chavez, Marília Berti Peruzzo, Pedro Germano Agripino Cruz, Leandro Augusto Ensina, Oswaldo Hideo Ando Junior, Joylan Nunes Maciel, Victor Hugo Wentz, Jorge Gimenez Ledesma',
   'UNILA / UFPB / UTFPR',
   'Taller A', 'Dr. Pedro Gardel (UC) y M.Sc. Ing. Hussein Moussa (USP)', 402, true,
   'Cronograma_Presentaciones_Orales_CIM2026_Sala21_TallerB.xlsx'),

  (date '2026-11-02', time '15:20', time '15:40', 46,
   'Segunda vida para computadoras en desuso: reacondicionamiento con GNU/Linux en Ciudad Presidente Franco',
   'Matthias G. Ruiz Villalba, José S. Balbuena Avalos, José A. González Ascona, Eduardo J. Ayala Pereira, Alejandro J. Burcio Rojas, Carlos E. Báez Velázquez, Carlos G. Espínola González, Nicolás D. Llorens Ayala, Rodolfo F. Oliver Ayala, Luis D. Molinas, María Luisa Hermosilla de Olmedo',
   'Universidad Privada del Este, Presidente Franco',
   'Aula Magna', 'Dr. Fernando Benítez (FPUNA) e Ing. Ladislao Aranda (UC)', 501, true,
   'Cronograma_Presentaciones_Orales_CIM2026_Sala21_TallerB.xlsx'),

  (date '2026-11-02', time '15:20', time '15:40', 80,
   'Evaluación técnica de la implementación de una flota 100% eléctrica de buses en Hernandarias: infraestructura de carga, demanda y optimización operacional',
   'Antonio Alderete, Enrique Vergara',
   'Universidad Católica, Campus Alto Paraná',
   'Taller A', 'Dr. Pedro Gardel (UC) y M.Sc. Ing. Hussein Moussa (USP)', 502, true,
   'Cronograma_Presentaciones_Orales_CIM2026_Sala21_TallerB.xlsx'),

  (date '2026-11-02', time '15:40', time '16:00', 44,
   'Gestión de energía basada en reglas para una embarcación híbrida hidrógeno–fotovoltaica–baterías: estudio de caso con datos operativos reales',
   'Grupo de Investigación en Energía e Hidrógeno',
   'UNILA / Itaipu Parquetec',
   'Aula Magna', 'Dr. Fernando Benítez (FPUNA) e Ing. Ladislao Aranda (UC)', 601, true,
   'Cronograma_Presentaciones_Orales_CIM2026_Sala21_TallerB.xlsx'),

  (date '2026-11-02', time '15:40', time '16:00', 98,
   'Evaluación técnico-económica post-implantación de un sistema fotovoltaico: análisis de los desvíos entre el desempeño proyectado y el desempeño realizado',
   'Grupo de Investigación en Sistemas Fotovoltaicos',
   'Presentación Oral ID 98',
   'Taller A', 'Dr. Pedro Gardel (UC) y M.Sc. Ing. Hussein Moussa (USP)', 602, true,
   'Cronograma_Presentaciones_Orales_CIM2026_Sala21_TallerB.xlsx');

create index if not exists oral_presentations_schedule_idx
  on public.oral_presentations (event_date, start_time, room, sort_order);

commit;

