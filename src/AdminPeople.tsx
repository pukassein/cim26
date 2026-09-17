import { useEffect, useMemo, useState } from 'react'
import { Check, Download, Pencil, Plus, Save, Trash2, X } from 'lucide-react'
import { createClient } from '@supabase/supabase-js'
import './people.css'

const url = import.meta.env.VITE_SUPABASE_URL || 'https://placeholder.supabase.co'
const key = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY || 'missing-publishable-key'
const db = createClient(url, key)

export type PersonKind = 'speakers' | 'committee'
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
})

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
  const [query, setQuery] = useState('')
  const [busy, setBusy] = useState(false)
  const [loading, setLoading] = useState(true)
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')

  const table = kind === 'speakers' ? 'speakers' : 'scientific_committee'
  const singular = kind === 'speakers' ? 'Ponente' : 'Integrante'
  const title = kind === 'speakers' ? 'Gestionar Ponentes' : 'Gestionar Comité Científico'

  const load = async () => {
    setLoading(true)
    const result = await db.from(table).select('*').order('sort_order').order('name')
    if (result.error) setError(result.error.message)
    else setItems((result.data || []) as Person[])
    setLoading(false)
  }

  useEffect(() => { void load() }, [table])

  const visible = useMemo(() => {
    const normalized = query.trim().toLowerCase()
    if (!normalized) return items
    return items.filter(person => `${person.name} ${person.institution} ${person.role || person.specialty || ''}`.toLowerCase().includes(normalized))
  }, [items, query])

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
    // The two tables are intentionally not identical: speakers have no role
    // or specialty columns, while scientific_committee has both.
    const data = kind === 'speakers'
      ? commonData
      : { ...commonData, role: editing.role?.trim() || null, specialty: editing.specialty?.trim() || null }
    const result = id.startsWith('new-')
      ? await db.from(table).insert(data)
      : await db.from(table).update(data).eq('id', id)

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
    const result = confirming.id.startsWith('new-')
      ? { error: null }
      : await db.from(table).delete().eq('id', confirming.id)

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

  const downloadExcel = () => {
    const headers = ['Nombre completo', 'Institución/Afiliación', 'Cargo, área o especialidad', 'URL de imagen', 'Biografía o descripción', 'Orden de visualización']
    const escape = (value: unknown) => `"${String(value ?? '').replace(/"/g, '""')}"`
    const csv = [headers, ...items.map(person => [person.name, person.institution, person.role || person.specialty, person.photo_url, person.biography, person.sort_order])]
      .map(row => row.map(escape).join(';')).join('\n')
    const blob = new Blob([`\ufeff${csv}`], { type: 'text/csv;charset=utf-8;' })
    const link = document.createElement('a')
    link.href = URL.createObjectURL(blob)
    link.download = `${kind === 'speakers' ? 'ponentes' : 'comite-cientifico'}.csv`
    link.click()
    URL.revokeObjectURL(link.href)
  }

  return <section className="people-panel" aria-labelledby="people-heading">
    <div className="people-panel-head">
      <div>
        <span className="admin-overline">GESTIÓN DE PERSONAS</span>
        <h2 id="people-heading">{title}</h2>
        <p>{items.length} {items.length === 1 ? 'registro' : 'registros'} disponibles</p>
      </div>
      <div className="people-panel-actions">
        <button className="admin-outline" onClick={downloadExcel}><Download size={16} /> Descargar Excel</button>
        <button className="admin-primary" onClick={openNew}><Plus size={17} /> Nuevo {singular}</button>
      </div>
    </div>

    <div className="people-toolbar">
      <input aria-label="Buscar personas" placeholder="Buscar por nombre o institución" value={query} onChange={event => setQuery(event.target.value)} />
    </div>

    {error && <p className="admin-error" role="alert">{error}</p>}
    {message && <p className="admin-success" role="status"><Check size={16} /> {message}</p>}

    {loading ? <div className="people-empty">Cargando registros…</div> : visible.length ? <div className="people-grid">
      {visible.map(person => <article className="person-card" key={person.id}>
        <PersonAvatar person={person} />
        <div className="person-info">
          <h3 title={person.name}>{person.name || 'Sin nombre'}</h3>
          <p title={person.institution}>{person.institution || 'Sin institución'}</p>
          {(person.role || person.specialty) && <small title={person.role || person.specialty}>{person.role || person.specialty}</small>}
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
          <label>Cargo, área o especialidad<input value={fieldValue(editing, 'role') || fieldValue(editing, 'specialty')} onChange={event => updateDraft('role', event.target.value)} /></label>
          <label>URL de imagen<input type="url" value={fieldValue(editing, 'photo_url')} onChange={event => updateDraft('photo_url', event.target.value)} /></label>
          <label className="wide-field">Biografía o descripción<textarea rows={5} value={fieldValue(editing, 'biography')} onChange={event => updateDraft('biography', event.target.value)} /></label>
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
  </section>
}

export default PeopleManagement
