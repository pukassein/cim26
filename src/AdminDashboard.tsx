import { useEffect, useState } from 'react'
import { CalendarDays, Check, ListChecks, Save, Users, Landmark, Plus, Trash2 } from 'lucide-react'
import { createClient } from '@supabase/supabase-js'
import { PeopleManagement } from './AdminPeople'
import type { PersonKind } from './AdminPeople'
import './admin.css'

const db = createClient(
  import.meta.env.VITE_SUPABASE_URL || 'https://placeholder.supabase.co',
  import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY || 'missing-publishable-key',
)
const logoMarkUrl = 'https://qbkjuubbinvetvpgxzrb.supabase.co/storage/v1/object/public/CIM26/logo_CIM.PNG'
const days = ['Lun 02 NOV', 'Mar 03 NOV', 'Mié 04 NOV', 'Jue 05 NOV', 'Vie 06 NOV']
type Tab = PersonKind | 'program'
type ProgramItem = { id: string; day: number; date: string; time: string; title: string; detail: string }

function AdminLogo() {
  return <div className="organizer-logo"><img src={logoMarkUrl} alt="CIM26" /></div>
}

function ProgramManagement() {
  const [items, setItems] = useState<ProgramItem[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [saved, setSaved] = useState(false)
  const [error, setError] = useState('')

  const load = async () => {
    setLoading(true)
    const result = await db.from('program_items').select('id,event_date,start_time,title,description').order('event_date').order('sort_order')
    if (result.error) setError(result.error.message)
    else setItems((result.data || []).map(item => ({
      id: item.id,
      date: item.event_date,
      day: Math.max(0, Math.round((new Date(`${item.event_date}T00:00:00`).getTime() - new Date('2026-11-02T00:00:00').getTime()) / 86400000)),
      time: item.start_time?.slice(0, 5) || '',
      title: item.title || '',
      detail: item.description || '',
    })))
    setLoading(false)
  }

  useEffect(() => { void load() }, [])

  const update = (id: string, field: keyof ProgramItem, value: string | number) => {
    setItems(current => current.map(item => item.id === id ? { ...item, [field]: value } : item))
  }

  const add = () => setItems(current => [...current, {
    id: `new-${Date.now()}`,
    day: 0,
    date: '2026-11-02',
    time: '09:00',
    title: '',
    detail: '',
  }])

  const save = async () => {
    setError('')
    if (items.some(item => !item.title.trim())) {
      setError('Cada actividad debe tener un título.')
      return
    }
    setSaving(true)
    const results = await Promise.all(items.map(item => {
      const row = { event_date: item.date || `2026-11-${String(2 + item.day).padStart(2, '0')}`, start_time: item.time || null, title: item.title.trim(), description: item.detail.trim() || null, is_published: true, sort_order: items.indexOf(item) + 1 }
      return item.id.startsWith('new-') ? db.from('program_items').insert(row) : db.from('program_items').update(row).eq('id', item.id)
    }))
    const failure = results.find(result => result.error)
    if (failure?.error) setError(`No se pudo guardar el programa: ${failure.error.message}`)
    else { setSaved(true); await load(); window.setTimeout(() => setSaved(false), 1800) }
    setSaving(false)
  }

  const remove = async (item: ProgramItem) => {
    if (!window.confirm('¿Eliminar esta actividad?')) return
    if (!item.id.startsWith('new-')) {
      const result = await db.from('program_items').delete().eq('id', item.id)
      if (result.error) { setError(result.error.message); return }
    }
    setItems(current => current.filter(row => row.id !== item.id))
  }

  return <section className="program-panel" aria-labelledby="program-heading">
    <div className="program-panel-head">
      <div><span className="admin-overline">AGENDA DEL CONGRESO</span><h2 id="program-heading">Gestionar Programa</h2><p>{items.length} {items.length === 1 ? 'actividad' : 'actividades'} disponibles</p></div>
      <div className="people-panel-actions"><button className="admin-primary" onClick={add}><Plus size={17} /> Nueva actividad</button><button className="admin-primary" onClick={() => void save()} disabled={saving}><Save size={16} /> {saving ? 'Guardando…' : saved ? 'Guardado' : 'Guardar cambios'}</button></div>
    </div>
    {error && <p className="admin-error" role="alert">{error}</p>}
    {loading ? <div className="people-empty">Cargando actividades…</div> : items.length ? <div className="program-admin-list">{items.map(item => <div className="program-admin-row" key={item.id}>
      <div className="program-admin-fields">
        <label>Día<select value={item.day} onChange={event => update(item.id, 'day', Number(event.target.value))}>{days.map((day, index) => <option value={index} key={day}>{day}</option>)}</select></label>
        <label>Hora<input type="time" value={item.time} onChange={event => update(item.id, 'time', event.target.value)} /></label>
        <label className="program-title-field">Actividad<input value={item.title} onChange={event => update(item.id, 'title', event.target.value)} /></label>
        <label className="program-detail-field">Detalle<input value={item.detail} onChange={event => update(item.id, 'detail', event.target.value)} /></label>
      </div>
      <button className="program-delete" onClick={() => void remove(item)} aria-label="Eliminar actividad"><Trash2 size={17} /></button>
    </div>)}</div> : <div className="people-empty"><div className="empty-icon"><CalendarDays size={20} /></div><strong>Todavía no hay actividades.</strong><span>Agregá la primera actividad para comenzar.</span></div>}
  </section>
}

export default function AdminDashboard({ onExit }: { onExit: () => void }) {
  const [tab, setTab] = useState<Tab>('speakers')
  const [counts, setCounts] = useState({ speakers: 0, committee: 0, program: 0 })

  useEffect(() => {
    Promise.all([
      db.from('speakers').select('*', { count: 'exact', head: true }),
      db.from('scientific_committee').select('*', { count: 'exact', head: true }),
      db.from('program_items').select('*', { count: 'exact', head: true }),
    ]).then(([speakers, committee, program]) => setCounts({ speakers: speakers.count || 0, committee: committee.count || 0, program: program.count || 0 }))
  }, [tab])

  const tabs: { key: Tab; label: string; icon: typeof Users }[] = [
    { key: 'speakers', label: 'Ponentes', icon: Users },
    { key: 'committee', label: 'Comité Científico', icon: Landmark },
    { key: 'program', label: 'Programa', icon: ListChecks },
  ]

  return <div className="admin-shell organizer-shell">
    <header className="organizer-header">
      <div className="organizer-header-inner">
        <div className="organizer-title"><AdminLogo /><div><span className="admin-overline">CIM26 · ADMINISTRACIÓN</span><h1>Panel del Organizador</h1></div></div>
        <div className="organizer-actions"><button className="logout-action" onClick={onExit}>Salir</button><button className="site-action" onClick={onExit}>Volver al sitio</button></div>
      </div>
    </header>
    <main className="organizer-main">
      <nav className="organizer-tabs" aria-label="Secciones de administración">
        {tabs.map(({ key, label, icon: Icon }) => <button key={key} className={tab === key ? 'active' : ''} onClick={() => setTab(key)} aria-selected={tab === key}><Icon size={17} />{label}<span>{counts[key]}</span></button>)}
      </nav>
      <div className="organizer-content" key={tab}>{tab === 'program' ? <ProgramManagement /> : <PeopleManagement kind={tab} />}</div>
    </main>
  </div>
}
