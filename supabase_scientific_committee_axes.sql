-- Comité Científico CIM26: reemplazo completo de integrantes.
-- Ejecutar en Supabase > SQL Editor.
--
-- IMPORTANTE: este script elimina primero todos los integrantes actuales del
-- Comité Científico y luego carga exactamente los 44 registros incluidos aquí.
-- Si algo falla, la transacción completa se revierte.
--
-- Por compatibilidad con la estructura actual de la app, el Comité Científico
-- público está almacenado en public.organizing_committee.

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

-- Reemplazo completo para evitar duplicados.
delete from public.organizing_committee;

insert into public.organizing_committee
  (name, specialty, institution, thematic_axis, sort_order, is_published)
values
  -- EJE 1: Una Salud, Bienestar Humano y Entornos Sostenibles
  ('Dra. Nancy Segovia Coronel', 'Microbiología, Salud Pública e Investigación Biomédica', 'FACISA - UNE', 1, 1, true),
  ('Dra. Nidia Viviana Ruiz Prieto', 'Clínica Médica, Epidemiología, UTI y Salud Pública', 'Universidad María Serrana / IPS', 1, 2, true),
  ('Dra. Graciela Gamarra', 'Neumología, Alergología, Salud Pública y Bioestadística', 'MSPYBS / UNINTER', 1, 3, true),
  ('Dra. Leticia Ojeda', 'Salud Integral y Ciencias Biomédicas', 'UNE', 1, 4, true),
  ('Dr. Rúben Viveros', 'Odontología, Armonización Orofacial y Aspectos Clínicos', 'Facultad de Odontología (FOP)', 1, 5, true),
  ('Dra. Zoraida Caballero', 'Odontología inclusiva.', 'UNC', 1, 6, true),
  ('Lic. Biol. Cecilio Correa, MSc', 'Entomología, agua y ecosistemas acuáticos', 'UNILA', 1, 7, true),
  ('Bioq. Carmen Coronel Escurra', 'Fitoquímica, plantas medicinales', 'ITAIPU', 1, 8, true),
  ('Bioq. Ángela Vergara Franco', 'Biotecnología, microbiología ambiental', 'Sector Privado', 1, 9, true),
  ('Lic. Luana Knaul, MSc', 'Química analítica, pesticidas y lípidos.', 'UNILA', 1, 10, true),
  ('Lic. Domitila Villaba', 'Química de productos naturales', 'UNA', 1, 11, true),
  ('Mag. QF. Mirna Portillo', 'Salud Pública, Química Farmacéutica, Farmacobotánica, Epidemiología, Salud Ocupacional', 'UPE/UNINORTE', 1, 12, true),

  -- EJE 2: Innovación, Energía, Tecnología y Gestión de Riesgos
  ('Dr. Marcelo Honnicke', 'Física de la Materia Condensada, Rayos X y Nuevos Materiales', 'UNILA (Brasil)', 2, 13, true),
  ('Dr. Fabio Plut Fernandes', 'Tecnología Energética, Innovación y Ensayos Industriales', 'Itaipu Parquetec', 2, 14, true),
  ('Dr. Jorge Galeano-Cabral', 'Sistemas de Control Avanzado, Modelado y Optimización Matemática', 'FSU - Florida State University (EE.UU.)', 2, 15, true),
  ('Dr. Diego Pinto', 'Algoritmos de Optimización de Redes y Computación Científica', 'FPUNA (Facultad Politécnica - UNA)', 2, 16, true),
  ('Dr. Jose Agustín Riveros Insfran', 'Ciencias Computacionales y Tecnologías de la Información', 'FPUNA (Facultad Politécnica - UNA)', 2, 17, true),
  ('Dr. Miguel Garcia', 'Sistemas Energéticos, Termodinámica e Ingeniería de Procesos', 'Universidad Pablo de Olavide (España)', 2, 18, true),
  ('Dr. Dario Aviso', 'Modelado de Procesos, Análisis de Ciclo de Vida y Resiliencia Energética', 'FIUNA', 2, 19, true),
  ('Dr. Ing. Joylan', 'Inteligencia Artificial Aplicada, Machine Learning y Computación', 'UNILA (Brasil)', 2, 20, true),
  ('MSc. Hussein Moussa', 'Electroquímica, ciencia de materiales, almacenamiento de energía, supercapacitores y desarrollo de software', 'USP (Brasil)', 2, 21, true),
  ('Dr. Ing. José Luis Vázquez Noguera', 'Ingeniería Aplicada, Tecnologías Emergentes y Computación', '', 2, 22, true),
  ('Dr. Jorge Ledezma', '', '', 2, 23, true),

  -- EJE 3: Economía Circular, Finanzas Sostenibles, Paz, Ética y Justicia
  ('Mag. Victor DeJesús Ocampos Linares', 'Economía y Comercio Internacional', 'UNE, UNINORTE', 3, 24, true),
  ('Mag. Aurelia González', 'Contabilidad, Administración de Empresas, Auditoría y Metodología de la Investigación', 'UNINORTE, UNICAN, UCA', 3, 25, true),
  ('Mag. Carmelo Defrancesco Castro', 'Contabilidad, Tributación y Auditoría Laboral', 'Un. Iberoamericano y Fotriem', 3, 26, true),
  ('Mag. Jorge Ignacio Rojas Barra', 'Contabilidad, Auditoría y Administración de Empresas', 'Universidad Americana', 3, 27, true),
  ('Mag. Noelia López Santillan', 'Contabilidad Superior y Auditoría', 'Universidad Autónoma de Asunción y UNINORTE', 3, 28, true),
  ('Mag. Rosanna Mabel Villagra de González', 'Contabilidad y Auditoría Impositiva', 'UNE, Fotriem', 3, 29, true),
  ('Mag. Alice María Sanabria González', 'Contabilidad, Administración de Empresas, Auditoría Impositiva', 'UCA, Fotriem', 3, 30, true),
  ('Mag. María Belèn Oruè Gamarra', 'Contabilidad, Tributación y Auditoría Impositiva', 'Univ. Columbia de Paraguay, Fotriem', 3, 31, true),
  ('Mag. Jorgelina Garay Peña', 'Contabilidad y Auditoría', 'Fotriem', 3, 32, true),
  ('Mag. Mirian González Gómez', 'Contabilidad y Auditoría', 'UNA', 3, 33, true),
  ('Abog. Octavio Loprete', 'Libertad Religiosa y ética', 'Presidente Consorcio Latinoamericano de Libertad Religiosa - Argentina', 3, 34, true),
  ('Mg. Claudio Salinas', 'Libertad Religiosa, Constitucional y Penal', 'Poder Judicial - Asunción', 3, 35, true),
  ('Dr. Arsenio Arguello', 'Civil y Comercial', 'Abogado Independiente, Docente', 3, 36, true),
  ('Dr. Adalberto Soto', 'Penal y Procesal Penal', 'Juez de Garantías', 3, 37, true),

  -- EJE 4: Educación, Salud Mental y Comunidades Inclusivas
  ('Dra. Maria das Graças', 'Innovación Pedagógica, Educación y Transformación en la Era de la IA', 'UNILA (Brasil)', 4, 38, true),
  ('Dr. Andrés Canese', 'Educación Médica y Programas Comunitarios de Prevención', 'UCA - Asunción', 4, 39, true),
  ('Mg. Josefina Diaz', 'Derechos humanos, bioquímica y derecho.', 'ANEAES', 4, 40, true),
  ('Dr. Amado Torales', 'Psicología Clínica', 'UNE', 4, 41, true),
  ('Lic. Sonia Rivas', 'Lic. en Administración y Psicologia', 'UNE', 4, 42, true),

  -- EJE 5: Vivienda, Hábitat y Derecho a la Ciudad
  ('Dr. Carlos Peris', 'Sociologia', 'UC', 5, 43, true),
  ('MSc. Victor Jara', 'Sociologia', '', 5, 44, true);

commit;

-- Hace que la API de Supabase recargue las columnas nuevas inmediatamente.
notify pgrst, 'reload schema';

-- Resultado esperado: 44 integrantes en total.
select thematic_axis as eje, count(*) as integrantes
from public.organizing_committee
group by thematic_axis
order by thematic_axis;
