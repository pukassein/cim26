# Cómo cargar el Comité Científico desde Excel

La aplicación ya puede importar directamente la hoja con el formato mostrado:

- una fila que comienza con `EJE 1: ...`, `EJE 2: ...`, etc.;
- debajo, las columnas `Nombre del Miembro`, `Especialidad / Perfil` e `Institución`;
- luego los integrantes de ese eje.

## 1. Preparar Supabase

Abrí **Supabase → SQL Editor**, copiá todo el contenido de
`supabase_scientific_committee_axes.sql` y ejecutalo una sola vez. El script es
seguro para volver a ejecutar: conserva los registros existentes.

## 2. Exportar el Excel

En Excel:

1. Abrí la hoja que contiene todos los ejes.
2. Elegí **Archivo → Guardar como**.
3. Seleccioná **CSV UTF-8 (delimitado por comas)**. Si Excel genera el archivo
   con punto y coma por la configuración regional, también funciona.
4. Si Excel avisa que solo guardará la hoja activa, aceptá.

No hace falta pedirle a ChatGPT que genere JSON ni modificar los nombres. El
importador reconoce automáticamente cada fila `EJE N`, los encabezados
repetidos y las comas dentro de las especialidades.

## 3. Importar en el panel

1. Entrá a `#admin` en el sitio.
2. Abrí **Comité Científico**.
3. Pulsá **Importar CSV** y elegí el archivo exportado.
4. Revisá la cantidad detectada y confirmá.

Los nuevos registros se agregan a los existentes; no se eliminan ni reemplazan
nombres. Después podés editar individualmente el eje, la especialidad, la
institución y el orden. La web pública los muestra agrupados por eje. Los que no
tengan eje quedan visibles en **Sin eje asignado** para que sea fácil corregirlos.

## Formato alternativo simple

También se acepta un CSV plano con una fila por integrante:

```csv
Nombre del Miembro;Especialidad / Perfil;Institución;Eje
Dra. Ejemplo;Salud Pública;Universidad Ejemplo;EJE 1
Dr. Ejemplo Dos;Inteligencia Artificial;Institución Ejemplo;EJE 2
```

Antes de una carga grande conviene descargar el CSV actual desde el mismo panel
como respaldo.
