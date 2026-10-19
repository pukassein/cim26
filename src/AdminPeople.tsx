import { useEffect, useMemo, useRef, useState } from 'react'
import { ArrowRight, Check, Download, Pencil, Plus, Save, Settings, Trash2, Upload, X } from 'lucide-react'
import { createClient } from '@supabase/supabase-js'
import './people.css'

const url = import.meta.env.VITE_SUPABASE_URL || 'https://placeholder.supabase.co'
const key = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY || 'missing-publishable-key'
const supabaseConfigured = Boolean(import.meta.env.VITE_SUPABASE_URL && import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY)
const db = createClient(url, key)

export type PersonKind = 'speakers' | 'committee' | 'organizing'
export type Person = {
  id: string
  name: string
  institution: string
  role?: string
  specialty?: string
  biography?: string
  photo_url?: string
  sort_order?: number
  is_published?: boolean
  thematic_axis?: number | null
}

const thematicAxes = [
  { number: 1, title: 'Una Salud, Bienestar Humano y Entornos Sostenibles' },
  { number: 2, title: 'Innovación, Energía, Tecnología y Gestión de Riesgos ante el Cambio Global' },
  { number: 3, title: 'Economía Circular, Finanzas Sostenibles, Paz, Ética, Justicia e Instituciones Sólidas y Políticas Laborales' },
  { number: 4, title: 'Educación, Salud Mental y Comunidades Inclusivas' },
  { number: 5, title: 'Vivienda, Hábitat y Derecho a la Ciudad desde lo Local a lo Global' },
]

function errorMessage(error: unknown) {
  if (error instanceof Error) return error.message
  if (typeof error === 'object' && error !== null && 'message' in error) return String(error.message)
  return String(error || 'Error desconocido')
}

const emptyPerson = (order: number): Person => ({
  id: `new-${Date.now()}`,
  name: '',
  institution: '',
  role: '',
  specialty: '',
  biography: '',
  photo_url: '',
  sort_order: order,
  is_published: true,
  thematic_axis: null,
})

function parseDelimited(text: string) {
  const candidates = [';', ',', '\t']
  const sample = text.split(/\r?\n/).slice(0, 25).join('\n')
  const countOutsideQuotes = (delimiter: string) => {
    let count = 0
    let quoted = false
    for (let index = 0; index < sample.length; index += 1) {
      if (sample[index] === '"' && sample[index + 1] === '"') index += 1
      else if (sample[index] === '"') quoted = !quoted
      else if (sample[index] === delimiter && !quoted) count += 1
    }
    return count
  }
  const delimiter = candidates.sort((a, b) => countOutsideQuotes(b) - countOutsideQuotes(a))[0]
  const rows: string[][] = []
  let row: string[] = []
  let value = ''
  let quoted = false

  for (let index = 0; index < text.length; index += 1) {
    const character = text[index]
    if (character === '"' && quoted && text[index + 1] === '"') { value += '"'; index += 1 }
    else if (character === '"') quoted = !quoted
    else if (character === delimiter && !quoted) { row.push(value.trim()); value = '' }
    else if ((character === '\n' || character === '\r') && !quoted) {
      if (character === '\r' && text[index + 1] === '\n') index += 1
      row.push(value.trim()); value = ''
      if (row.some(Boolean)) rows.push(row)
      row = []
    } else value += character
  }
  row.push(value.trim())
  if (row.some(Boolean)) rows.push(row)
  return rows
}

function normalize(value: string) {
  return value.normalize('NFD').replace(/[\u0300-\u036f]/g, '').trim().toLowerCase()
}

function committeeRowsFromCsv(text: string) {
  let currentAxis: number | null = null
  let header: string[] | null = null
  const people: Array<Omit<Person, 'id'>> = []

  for (const row of parseDelimited(text.replace(/^\ufeff/, ''))) {
    const first = normalize(row[0] || '')
    const axisMatch = first.match(/^eje\s*(\d+)/)
    if (axisMatch) { currentAxis = Number(axisMatch[1]); header = null; continue }
    if (first.includes('nombre') && first.includes('miembro')) { header = row.map(normalize); continue }
    if (!row[0]?.trim()) continue

    const indexOf = (words: string[], fallback: number) => {
      const index = header?.findIndex(cell => words.some(word => cell.includes(word))) ?? -1
      return index >= 0 ? index : fallback
    }
    const name = row[indexOf(['nombre'], 0)]?.trim()
    if (!name || normalize(name).includes('nombre del miembro')) continue
    const specialty = row[indexOf(['especialidad', 'perfil'], 1)]?.trim() || ''
    const institution = row[indexOf(['institucion', 'afiliacion'], 2)]?.trim() || ''
    const axisCell = row[indexOf(['eje'], 3)] || ''
    const explicitAxis = Number(axisCell.match(/\d+/)?.[0])
    people.push({ name, specialty, institution, thematic_axis: explicitAxis || currentAxis, sort_order: people.length + 1, is_published: true })
  }
  return people
}

function initials(name: string) {
  return name.trim().split(/\s+/).slice(0, 2).map(word => word[0]).join('').toUpperCase() || '?'
}

function PersonAvatar({ person }: { person: Person }) {
  const [imageFailed, setImageFailed] = useState(false)
  return <div className="person-avatar" aria-hidden="true">
    {person.photo_url && !imageFailed
      ? <img src={person.photo_url} alt="" onError={() => setImageFailed(true)} />
      : <span>{initials(person.name)}</span>}
  </div>
}

function fieldValue(person: Person, field: keyof Person) {
  return String(person[field] ?? '')
}

export function PeopleManagement({ kind }: { kind: PersonKind }) {
  const [items, setItems] = useState<Person[]>([])
  const [editing, setEditing] = useState<Person | null>(null)
  const [confirming, setConfirming] = useState<Person | null>(null)
  const [moving, setMoving] = useState<Person[]>([])
  const [selected, setSelected] = useState<Set<string>>(new Set())
  const [moveMode, setMoveMode] = useState(false)
  const [query, setQuery] = useState('')
  const [busy, setBusy] = useState(false)
  const [loading, setLoading] = useState(true)
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')
  const [axisFilter, setAxisFilter] = useState('')
  const importInput = useRef<HTMLInputElement>(null)

  const table = kind === 'speakers' ? 'speakers' : kind === 'committee' ? 'scientific_committee' : 'organizing_committee'
  const singular = kind === 'speakers' ? 'Ponente' : 'Integrante'
  const title = kind === 'speakers' ? 'Gestionar Ponentes' : kind === 'committee' ? 'Gestionar Comité de Organización' : 'Gestionar Comité Científico'

  const load = async () => {
    setLoading(true)
    if (!supabaseConfigured) {
      setError('Supabase no está configurado en el despliegue. Agregá VITE_SUPABASE_URL y VITE_SUPABASE_PUBLISHABLE_KEY en las variables de entorno y volvé a desplegar.')
      setLoading(false)
      return
    }
    try {
      const result = await db.from(table).select('*').order('sort_order').order('name')
      if (result.error) setError(result.error.message)
      else setItems((result.data || []) as Person[])
    } catch (caught) {
      setError(`No se pudo conectar con Supabase: ${caught instanceof Error ? caught.message : 'Failed to fetch'}`)
    }
    setLoading(false)
  }

  useEffect(() => { void load() }, [table])

  const visible = useMemo(() => {
    const normalized = query.trim().toLowerCase()
    return items.filter(person => {
      const matchesQuery = !normalized || `${person.name} ${person.institution} ${person.role || person.specialty || ''}`.toLowerCase().includes(normalized)
      const matchesAxis = kind !== 'organizing' || !axisFilter || String(person.thematic_axis || '') === axisFilter
      return matchesQuery && matchesAxis
    })
  }, [items, query, axisFilter, kind])

  const openNew = () => {
    setError('')
    setEditing(emptyPerson(items.length + 1))
  }

  const openEdit = (person: Person) => {
    setError('')
    setEditing({ ...person })
  }

  const updateDraft = (field: keyof Person, value: string | number) => {
    setEditing(current => current ? { ...current, [field]: value } : current)
  }

  const save = async (event: React.FormEvent) => {
    event.preventDefault()
    if (!editing) return
    if (!editing.name.trim()) {
      setError('El nombre completo es obligatorio.')
      return
    }

    setBusy(true)
    setError('')
    const { id } = editing
    const commonData = {
      name: editing.name.trim(),
      institution: editing.institution?.trim() || '',
      biography: editing.biography?.trim() || null,
      photo_url: editing.photo_url?.trim() || null,
      sort_order: Number(editing.sort_order) || items.length + 1,
      is_published: editing.is_published ?? true,
    }
    // Speakers need the optional role column added by the Supabase migration;
    // committee members support both role and specialty natively.
    const data = kind === 'speakers'
      ? { ...commonData, role: editing.role?.trim() || null }
      : kind === 'committee'
        ? { ...commonData, role: editing.role?.trim() || null, specialty: editing.specialty?.trim() || null }
        : { name: commonData.name, institution: commonData.institution, specialty: editing.specialty?.trim() || null, thematic_axis: editing.thematic_axis || null, sort_order: commonData.sort_order, is_published: commonData.is_published }
    let result: { error: { message: string } | null }
    try {
      result = id.startsWith('new-')
        ? await db.from(table).insert(data)
        : await db.from(table).update(data).eq('id', id)
    } catch (caught) {
      setError(`No se pudo conectar con Supabase: ${caught instanceof Error ? caught.message : 'Failed to fetch'}`)
      setBusy(false)
      return
    }

    if (result.error) {
      setError(`No se pudo guardar el registro: ${result.error.message}`)
      setBusy(false)
      return
    }

    setEditing(null)
    setBusy(false)
    setMessage(`${singular} ${id.startsWith('new-') ? 'agregado' : 'actualizado'} correctamente.`)
    await load()
    window.setTimeout(() => setMessage(''), 2800)
  }

  const remove = async () => {
    if (!confirming) return
    setBusy(true)
    setError('')
    let result: { error: { message: string } | null }
    try {
      result = confirming.id.startsWith('new-')
        ? { error: null }
        : await db.from(table).delete().eq('id', confirming.id)
    } catch (caught) {
      setError(`No se pudo conectar con Supabase: ${caught instanceof Error ? caught.message : 'Failed to fetch'}`)
      setConfirming(null)
      setBusy(false)
      return
    }

    if (result.error) {
      setError(`No se pudo eliminar el registro: ${result.error.message}`)
      setConfirming(null)
      setBusy(false)
      return
    }

    setConfirming(null)
    setBusy(false)
    setMessage(`${singular} eliminado correctamente.`)
    await load()
    window.setTimeout(() => setMessage(''), 2800)
  }

  const moveToOrganizingCommittee = async () => {
    const people = moving.filter(person => !person.id.startsWith('new-'))
    if (!people.length) return
    setBusy(true)
    setError('')

    try {
      const orderResult = await db
        .from('organizing_committee')
        .select('sort_order')
        .order('sort_order', { ascending: false })
        .limit(1)
        .maybeSingle()
      if (orderResult.error) throw orderResult.error

      const firstOrder = Number(orderResult.data?.sort_order || 0) + 1
      const insertResult = await db.from('organizing_committee').insert(people.map((person, index) => ({
        name: person.name.trim(),
        institution: person.institution?.trim() || '',
        specialty: person.role?.trim() || null,
        thematic_axis: null,
        sort_order: firstOrder + index,
        is_published: person.is_published ?? true,
      })))
      if (insertResult.error) throw insertResult.error

      const deleteResult = await db.from('speakers').delete().in('id', people.map(person => person.id))
      if (deleteResult.error) throw deleteResult.error

      setMoving([])
      setSelected(new Set())
      setMoveMode(false)
      setMessage(people.length === 1
        ? `${people[0].name} fue movido al Comité Científico.`
        : `${people.length} personas fueron movidas al Comité Científico.`)
      await load()
      window.setTimeout(() => setMessage(''), 2800)
    } catch (caught) {
      setError(`No se pudo mover ${people.length === 1 ? 'el registro' : 'los registros'}: ${errorMessage(caught)}`)
    } finally {
      setBusy(false)
    }
  }

  const selectedPeople = items.filter(person => selected.has(person.id))
  const toggleSelected = (id: string) => setSelected(current => {
    const next = new Set(current)
    if (next.has(id)) next.delete(id)
    else next.add(id)
    return next
  })

  const toggleAllVisible = () => setSelected(current => {
    const next = new Set(current)
    const allSelected = visible.length > 0 && visible.every(person => next.has(person.id))
    visible.forEach(person => allSelected ? next.delete(person.id) : next.add(person.id))
    return next
  })

  const toggleMoveMode = () => {
    setMoveMode(current => {
      if (current) setSelected(new Set())
      return !current
    })
  }

  const downloadExcel = () => {
    const headers = kind === 'organizing'
      ? ['Nombre del Miembro', 'Especialidad / Perfil', 'Institución', 'Eje', 'Orden de visualización']
      : ['Nombre completo', 'Institución/Afiliación', 'Cargo, área o especialidad', 'URL de imagen', 'Biografía o descripción', 'Orden de visualización']
    const escape = (value: unknown) => `"${String(value ?? '').replace(/"/g, '""')}"`
    const csvRows = kind === 'organizing'
      ? items.map(person => [person.name, person.specialty, person.institution, person.thematic_axis ? `EJE ${person.thematic_axis}` : '', person.sort_order])
      : items.map(person => [person.name, person.institution, person.role || person.specialty, person.photo_url, person.biography, person.sort_order])
    const csv = [headers, ...csvRows]
      .map(row => row.map(escape).join(';')).join('\n')
    const blob = new Blob([`\ufeff${csv}`], { type: 'text/csv;charset=utf-8;' })
    const link = document.createElement('a')
    link.href = URL.createObjectURL(blob)
    link.download = `${kind === 'speakers' ? 'ponentes' : kind === 'committee' ? 'comite-organizacion' : 'comite-cientifico'}.csv`
    link.click()
    URL.revokeObjectURL(link.href)
  }

  const importCsv = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    event.target.value = ''
    if (!file) return
    setError('')
    try {
      const rows = committeeRowsFromCsv(await file.text())
      if (!rows.length) throw new Error('No se encontraron integrantes. Verificá que el archivo conserve las columnas Nombre, Especialidad e Institución.')
      if (!window.confirm(`Se encontraron ${rows.length} integrantes. ¿Querés agregarlos al Comité Científico?`)) return
      setBusy(true)
      const firstOrder = Math.max(0, ...items.map(item => Number(item.sort_order) || 0)) + 1
      const result = await db.from('organizing_committee').insert(rows.map((row, index) => ({ ...row, sort_order: firstOrder + index })))
      if (result.error) throw result.error
      setMessage(`${rows.length} integrantes importados correctamente.`)
      await load()
      window.setTimeout(() => setMessage(''), 3500)
    } catch (caught) {
      setError(`No se pudo importar el archivo: ${errorMessage(caught)}`)
    } finally {
      setBusy(false)
    }
  }

  return <section className="people-panel" aria-labelledby="people-heading">
    <div className="people-panel-head">
      <div>
        <span className="admin-overline">GESTIÓN DE PERSONAS</span>
        <h2 id="people-heading">{title}</h2>
        <p>{items.length} {items.length === 1 ? 'registro' : 'registros'} disponibles</p>
      </div>
      <div className="people-panel-actions">
        {kind === 'speakers' && <button className={`management-toggle${moveMode ? ' active' : ''}`} onClick={toggleMoveMode} aria-label={moveMode ? 'Cerrar modo de selección' : 'Administrar movimiento de ponentes'} aria-pressed={moveMode} title="Mover ponentes al Comité Científico"><Settings size={18} /></button>}
        {kind === 'organizing' && <><input ref={importInput} className="visually-hidden" type="file" accept=".csv,text/csv" onChange={event => void importCsv(event)} /><button className="admin-outline" onClick={() => importInput.current?.click()} disabled={busy}><Upload size={16} /> Importar CSV</button></>}
        <button className="admin-outline" onClick={downloadExcel}><Download size={16} /> Descargar CSV</button>
        <button className="admin-primary" onClick={openNew}><Plus size={17} /> Nuevo {singular}</button>
      </div>
    </div>

    <div className="people-toolbar">
      <input aria-label="Buscar personas" placeholder="Buscar por nombre o institución" value={query} onChange={event => setQuery(event.target.value)} />
      {kind === 'organizing' && <select aria-label="Filtrar por eje" value={axisFilter} onChange={event => setAxisFilter(event.target.value)}><option value="">Todos los ejes</option>{thematicAxes.map(axis => <option key={axis.number} value={axis.number}>EJE {axis.number}</option>)}</select>}
      {kind === 'speakers' && moveMode && <>
        <button className="admin-outline select-all-action" onClick={toggleAllVisible} disabled={!visible.length}>{visible.length > 0 && visible.every(person => selected.has(person.id)) ? 'Quitar selección' : 'Seleccionar visibles'}</button>
        <button className="admin-primary bulk-move-action" onClick={() => setMoving(selectedPeople)} disabled={!selectedPeople.length}><ArrowRight size={16} /> Mover seleccionados{selectedPeople.length ? ` (${selectedPeople.length})` : ''}</button>
      </>}
    </div>

    {error && <p className="admin-error" role="alert">{error}</p>}
    {message && <p className="admin-success" role="status"><Check size={16} /> {message}</p>}

    {loading ? <div className="people-empty">Cargando registros…</div> : visible.length ? <div className="people-grid">
      {visible.map(person => <article className="person-card" key={person.id}>
        {kind === 'speakers' && moveMode && <label className="person-select" title={`Seleccionar a ${person.name}`}><input type="checkbox" aria-label={`Seleccionar a ${person.name}`} checked={selected.has(person.id)} onChange={() => toggleSelected(person.id)} /></label>}
        <PersonAvatar person={person} />
        <div className="person-info">
          <h3 title={person.name}>{person.name || 'Sin nombre'}</h3>
          <p title={person.institution}>{person.institution || 'Sin institución'}</p>
          {(person.role || person.specialty) && <small title={person.role || person.specialty}>{person.role || person.specialty}</small>}
          {kind === 'organizing' && person.thematic_axis && <b>EJE {person.thematic_axis}</b>}
        </div>
        <div className="person-actions">
          <button className="edit-action" onClick={() => openEdit(person)}><Pencil size={14} /> Editar</button>
          <button className="delete-action" onClick={() => setConfirming(person)}><Trash2 size={14} /> Excluir</button>
        </div>
      </article>)}
    </div> : <div className="people-empty">
      <div className="empty-icon"><Plus size={20} /></div>
      <strong>{query ? 'No encontramos registros' : `Todavía no hay ${kind === 'speakers' ? 'ponentes' : 'integrantes'}.`}</strong>
      <span>{query ? 'Probá con otro nombre o institución.' : `Agregá el primer ${kind === 'speakers' ? 'ponente' : 'integrante'} para comenzar.`}</span>
    </div>}

    {editing && <div className="person-modal-backdrop" role="presentation" onMouseDown={event => { if (event.target === event.currentTarget && !busy) setEditing(null) }}>
      <form className="person-modal" onSubmit={save} role="dialog" aria-modal="true" aria-labelledby="person-modal-title">
        <div className="person-modal-head">
          <div>
            <span className="admin-overline">{editing.id.startsWith('new-') ? 'NUEVO REGISTRO' : 'EDITAR REGISTRO'}</span>
            <h2 id="person-modal-title">{editing.id.startsWith('new-') ? `Nuevo ${singular}` : `Editar ${singular}`}</h2>
          </div>
          <button type="button" className="modal-close" onClick={() => setEditing(null)} aria-label="Cerrar"><X size={20} /></button>
        </div>
        <div className="person-form-grid">
          <label>Nombre completo <span>*</span><input required value={fieldValue(editing, 'name')} onChange={event => updateDraft('name', event.target.value)} /></label>
          <label>Institución/Afiliación<input value={fieldValue(editing, 'institution')} onChange={event => updateDraft('institution', event.target.value)} /></label>
          {kind === 'speakers' && <>
            <label>Cargo / especialidad<input value={fieldValue(editing, 'role')} onChange={event => updateDraft('role', event.target.value)} /></label>
            <label>URL de foto<input type="url" placeholder="https://…" value={fieldValue(editing, 'photo_url')} onChange={event => updateDraft('photo_url', event.target.value)} /></label>
          </>}
          {kind === 'organizing' && <>
            <label>Especialidad / Perfil<input value={fieldValue(editing, 'specialty')} onChange={event => updateDraft('specialty', event.target.value)} /></label>
            <label>Eje temático<select value={fieldValue(editing, 'thematic_axis')} onChange={event => updateDraft('thematic_axis', Number(event.target.value) || 0)}><option value="">Sin asignar</option>{thematicAxes.map(axis => <option key={axis.number} value={axis.number}>EJE {axis.number}: {axis.title}</option>)}</select></label>
          </>}
          <label>Orden de visualización<input type="number" min="1" value={fieldValue(editing, 'sort_order')} onChange={event => updateDraft('sort_order', Number(event.target.value))} /></label>
        </div>
        {error && <p className="admin-error modal-error" role="alert">{error}</p>}
        <div className="person-modal-actions">
          <button type="button" className="admin-quiet" onClick={() => setEditing(null)} disabled={busy}>Cancelar</button>
          <button type="submit" className="admin-primary" disabled={busy}><Save size={16} /> {busy ? 'Guardando…' : 'Guardar'}</button>
        </div>
      </form>
    </div>}

    {confirming && <div className="confirm-backdrop" role="presentation">
      <div className="confirm-dialog" role="alertdialog" aria-modal="true" aria-labelledby="confirm-title">
        <div className="confirm-icon"><Trash2 size={19} /></div>
        <h2 id="confirm-title">¿Está seguro de que desea eliminar este registro?</h2>
        <p>Se eliminará a <strong>{confirming.name || 'esta persona'}</strong> de la lista.</p>
        <div className="confirm-actions"><button className="admin-quiet" onClick={() => setConfirming(null)} disabled={busy}>Cancelar</button><button className="danger-button" onClick={() => void remove()} disabled={busy}>{busy ? 'Eliminando…' : 'Excluir'}</button></div>
      </div>
    </div>}

    {moving.length > 0 && <div className="confirm-backdrop" role="presentation">
      <div className="confirm-dialog" role="alertdialog" aria-modal="true" aria-labelledby="move-confirm-title">
        <div className="confirm-icon move-confirm-icon"><ArrowRight size={19} /></div>
        <h2 id="move-confirm-title">¿Mover {moving.length === 1 ? 'esta persona' : `estas ${moving.length} personas`} al Comité Científico?</h2>
        <p>{moving.length === 1 ? <><strong>{moving[0].name || 'Esta persona'}</strong> dejará de aparecer en Ponentes.</> : <>Las personas seleccionadas dejarán de aparecer en Ponentes y pasarán al Comité Científico.</>}</p>
        <div className="confirm-actions"><button className="admin-quiet" onClick={() => setMoving([])} disabled={busy}>Cancelar</button><button className="admin-primary" onClick={() => void moveToOrganizingCommittee()} disabled={busy}>{busy ? 'Moviendo…' : `Mover ${moving.length === 1 ? 'persona' : 'personas'}`}</button></div>
      </div>
    </div>}
  </section>
}

export default PeopleManagement
