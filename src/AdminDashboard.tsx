import { useEffect, useState } from 'react'
import { CalendarDays, Check, CheckCircle2, ChevronDown, Clock, ListChecks, MapPin, Pencil, Save, Search, Users, Landmark, Plus, Trash2 } from 'lucide-react'
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
const mainFacultyByDay = ['FACYT', 'FCCA', 'FCJ', 'FACSA', 'CIM26']
const activityTypes = [
  ['session', 'Actividad'], ['registration', 'Acreditación'], ['keynote', 'Conferencia magistral'], ['scientific_session', 'Trabajos científicos'], ['break', 'Receso'], ['lunch', 'Almuerzo'], ['poster', 'Pósteres'], ['conference', 'Conferencia'], ['business_session', 'Espacio empresarial'], ['workshop', 'Taller'], ['technical_visit', 'Visita técnica'], ['thesis_showcase', 'TFG'], ['awards', 'Reconocimientos'], ['closing', 'Cierre'],
] as const
const activityTypeLabel = Object.fromEntries(activityTypes)
type Tab = PersonKind | 'program'
type ProgramItem = { id: string; day: number; date: string; time: string; endTime: string; title: string; detail: string; faculty: string; track: string; venue: string; activityType: string; confirmationStatus: string }

function AdminLogo() {
  return <div className="organizer-logo"><img src={logoMarkUrl} alt="CIM26" /></div>
}

function ProgramManagement() {
  const [items, setItems] = useState<ProgramItem[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [saved, setSaved] = useState(false)
  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')
  const [selectedDay, setSelectedDay] = useState(0)
  const [facultyFilter, setFacultyFilter] = useState('all')
  const [query, setQuery] = useState('')
  const [openId, setOpenId] = useState<string | null>(null)
  const [confirmingId, setConfirmingId] = useState<string | null>(null)

  const load = async () => {
    setLoading(true)
    const result = await db.from('program_items').select('id,event_date,start_time,end_time,title,description,faculty,track,venue,activity_type,confirmation_status').order('event_date').order('start_time').order('sort_order')
    if (result.error) setError(result.error.message)
    else {
      const loaded = (result.data || []).map(item => ({
        id: item.id,
        date: item.event_date,
        day: Math.max(0, Math.round((new Date(`${item.event_date}T00:00:00`).getTime() - new Date('2026-11-02T00:00:00').getTime()) / 86400000)),
        time: item.start_time?.slice(0, 5) || '',
        endTime: item.end_time?.slice(0, 5) || '',
        title: item.title || '',
        detail: item.description || '',
        faculty: item.faculty || 'CIM26',
        track: item.track || 'General',
        venue: item.venue || '',
        activityType: item.activity_type || 'session',
        confirmationStatus: item.confirmation_status || 'confirmed',
      }))
      setItems(loaded)
      if (loaded.length && !loaded.some(item => item.day === selectedDay)) setSelectedDay(Math.min(...loaded.map(item => item.day)))
    }
    setLoading(false)
  }

  useEffect(() => { void load() }, [])

  const update = (id: string, field: keyof ProgramItem, value: string | number) => {
    setItems(current => current.map(item => {
      if (item.id !== id) return item
      if (field === 'day') return { ...item, day: Number(value), date: `2026-11-${String(2 + Number(value)).padStart(2, '0')}` }
      return { ...item, [field]: value }
    }))
  }

  const selectDay = (day: number) => { setSelectedDay(day); setFacultyFilter('all'); setOpenId(null) }

  const add = () => {
    const id = `new-${Date.now()}`
    const faculty = facultyFilter === 'all' ? mainFacultyByDay[selectedDay] : facultyFilter
    setItems(current => [...current, { id, day:selectedDay, date:`2026-11-${String(2 + selectedDay).padStart(2, '0')}`, time:'09:00', endTime:'10:00', title:'', detail:'', faculty, track:'General', venue:'', activityType:'session', confirmationStatus:'confirmed' }])
    setOpenId(id)
  }

  const save = async () => {
    setError('')
    if (items.some(item => !item.title.trim())) {
      setError('Cada actividad debe tener un título.')
      return
    }
    setSaving(true)
    const results = await Promise.all(items.map(item => {
      const row = { event_date: item.date || `2026-11-${String(2 + item.day).padStart(2, '0')}`, start_time: item.time || null, end_time: item.endTime || null, title: item.title.trim(), description: item.detail.trim() || null, faculty: item.faculty.trim() || 'CIM26', track: item.track.trim() || 'General', venue: item.venue.trim() || null, activity_type: item.activityType || 'session', confirmation_status: item.confirmationStatus || 'confirmed', is_published: true, sort_order: items.indexOf(item) + 1 }
      return item.id.startsWith('new-') ? db.from('program_items').insert(row) : db.from('program_items').update(row).eq('id', item.id)
    }))
    const failure = results.find(result => result.error)
    if (failure?.error) setError(`No se pudo guardar el programa: ${failure.error.message}`)
    else { setSaved(true); setNotice('Cambios guardados correctamente.'); setOpenId(null); await load(); window.setTimeout(() => { setSaved(false); setNotice('') }, 2200) }
    setSaving(false)
  }

  const confirmItem = async (item: ProgramItem) => {
    setError('')
    setConfirmingId(item.id)
    if (!item.id.startsWith('new-')) {
      const result = await db.from('program_items').update({ confirmation_status:'confirmed' }).eq('id',item.id)
      if (result.error) { setError(`No se pudo confirmar la actividad: ${result.error.message}`); setConfirmingId(null); return }
    }
    setItems(current=>current.map(row=>row.id===item.id?{...row,confirmationStatus:'confirmed'}:row))
    setNotice(`Actividad confirmada: ${item.title}`)
    setConfirmingId(null)
    window.setTimeout(()=>setNotice(''),2200)
  }

  const remove = async (item: ProgramItem) => {
    if (!window.confirm('¿Eliminar esta actividad?')) return
    if (!item.id.startsWith('new-')) {
      const result = await db.from('program_items').delete().eq('id', item.id)
      if (result.error) { setError(result.error.message); return }
    }
    setItems(current => current.filter(row => row.id !== item.id))
  }

  const dayItems = items.filter(item=>item.day===selectedDay)
  const faculties = [...new Set(dayItems.map(item=>item.faculty))].sort()
  const visibleItems = dayItems.filter(item=>(facultyFilter==='all'||item.faculty===facultyFilter)&&`${item.title} ${item.detail} ${item.track} ${item.venue}`.toLowerCase().includes(query.toLowerCase())).sort((a,b)=>a.time.localeCompare(b.time)||a.title.localeCompare(b.title))
  const visibleFaculties = [...new Set(visibleItems.map(item=>item.faculty))]
  const pendingTotal = items.filter(item=>item.confirmationStatus==='pending').length

  return <section className="program-panel" aria-labelledby="program-heading">
    <div className="program-panel-head">
      <div><span className="admin-overline">AGENDA DEL CONGRESO</span><h2 id="program-heading">Gestionar Programa</h2><p>{items.length} actividades en total · {pendingTotal} por confirmar</p></div>
      <div className="people-panel-actions"><button className="admin-primary" onClick={add}><Plus size={17} /> Nueva actividad</button><button className="admin-primary" onClick={() => void save()} disabled={saving}><Save size={16} /> {saving ? 'Guardando…' : saved ? 'Guardado' : 'Guardar cambios'}</button></div>
    </div>
    {error && <p className="admin-error" role="alert">{error}</p>}
    {notice&&<p className="admin-success"><Check size={17}/>{notice}</p>}
    {loading ? <div className="people-empty">Cargando actividades…</div> : <>
      <nav className="program-day-picker" aria-label="Elegir día">{days.map((day,index)=>{const count=items.filter(item=>item.day===index).length;const pending=items.filter(item=>item.day===index&&item.confirmationStatus==='pending').length;return <button className={selectedDay===index?'active':''} onClick={()=>selectDay(index)} key={day}><span>{day}</span><strong>{count} actividades</strong>{pending>0&&<small>{pending} por confirmar</small>}</button>})}</nav>
      <div className="program-admin-toolbar"><label><Search size={16}/><input value={query} onChange={event=>setQuery(event.target.value)} placeholder="Buscar actividad, track o ubicación"/></label><div className="program-faculty-filters"><button className={facultyFilter==='all'?'active':''} onClick={()=>setFacultyFilter('all')}>Todas</button>{faculties.map(faculty=><button className={facultyFilter===faculty?'active':''} onClick={()=>setFacultyFilter(faculty)} key={faculty}>{faculty}<span>{dayItems.filter(item=>item.faculty===faculty).length}</span></button>)}</div></div>
      <div className="program-day-summary"><div><CalendarDays size={19}/><span><strong>{days[selectedDay]}</strong>{dayItems.length} actividades en esta jornada</span></div><button className="admin-outline" onClick={add}><Plus size={15}/> Agregar en {facultyFilter==='all'?mainFacultyByDay[selectedDay]:facultyFilter}</button></div>
      {visibleItems.length?<div className="program-faculty-groups">{visibleFaculties.map(faculty=>{const facultyItems=visibleItems.filter(item=>item.faculty===faculty);const pending=facultyItems.filter(item=>item.confirmationStatus==='pending').length;return <section className="program-faculty-group" key={faculty}><header><div><span>FACULTAD / ORGANIZACIÓN</span><h3>{faculty}</h3></div><p>{facultyItems.length} actividades{pending>0&&<strong>{pending} por confirmar</strong>}</p></header><div className="program-activity-list">{facultyItems.map(item=><article className={'program-activity-card '+(openId===item.id?'expanded':'')} key={item.id}><div className="program-activity-summary"><div className="program-time"><Clock size={15}/><strong>{item.time}</strong><span>{item.endTime&&`— ${item.endTime}`}</span></div><div className="program-activity-copy"><div className="program-card-badges"><span>{item.track||'General'}</span><span>{activityTypeLabel[item.activityType]||item.activityType}</span>{item.venue&&<span><MapPin size={11}/>{item.venue}</span>}</div><h4>{item.title||'Nueva actividad sin título'}</h4>{item.detail&&<p>{item.detail}</p>}</div><span className={'program-status '+item.confirmationStatus}>{item.confirmationStatus==='pending'?'Por confirmar':'Confirmado'}</span><div className="program-card-actions">{item.confirmationStatus==='pending'&&<button className="program-confirm" disabled={confirmingId===item.id} onClick={()=>void confirmItem(item)}><CheckCircle2 size={15}/>{confirmingId===item.id?'Confirmando…':'Confirmar'}</button>}<button className="program-edit" onClick={()=>setOpenId(openId===item.id?null:item.id)}><Pencil size={14}/>{openId===item.id?'Cerrar':'Editar'}<ChevronDown size={14}/></button><button className="program-delete" onClick={()=>void remove(item)} aria-label={`Eliminar ${item.title}`}><Trash2 size={16}/></button></div></div>{openId===item.id&&<div className="program-editor"><section><h5>Horario y contenido</h5><div className="program-admin-fields"><label>Día<select value={item.day} onChange={event => update(item.id, 'day', Number(event.target.value))}>{days.map((day, index) => <option value={index} key={day}>{day}</option>)}</select></label><label>Inicio<input type="time" value={item.time} onChange={event => update(item.id, 'time', event.target.value)} /></label><label>Fin<input type="time" value={item.endTime} onChange={event => update(item.id, 'endTime', event.target.value)} /></label><label className="program-title-field">Actividad<input value={item.title} onChange={event => update(item.id, 'title', event.target.value)} placeholder="Nombre de la actividad"/></label><label className="program-detail-field">Detalle<textarea value={item.detail} onChange={event => update(item.id, 'detail', event.target.value)} placeholder="Ponente, institución u otra información útil"/></label></div></section><section><h5>Organización y publicación</h5><div className="program-admin-fields program-organization-fields"><label>Facultad<input value={item.faculty} onChange={event => update(item.id, 'faculty', event.target.value)} /></label><label>Track<input value={item.track} onChange={event => update(item.id, 'track', event.target.value)} /></label><label>Ubicación<input value={item.venue} onChange={event => update(item.id, 'venue', event.target.value)} /></label><label>Tipo<select value={item.activityType} onChange={event => update(item.id, 'activityType', event.target.value)}>{activityTypes.map(([value,label])=><option value={value} key={value}>{label}</option>)}</select></label><label>Estado<select value={item.confirmationStatus} onChange={event => update(item.id, 'confirmationStatus', event.target.value)}><option value="confirmed">Confirmado</option><option value="pending">Por confirmar</option></select></label></div></section><div className="program-editor-actions"><span>Los cambios se publican al presionar “Guardar cambios”.</span><button className="admin-primary" onClick={()=>void save()} disabled={saving}><Save size={15}/>{saving?'Guardando…':'Guardar cambios'}</button></div></div>}</article>)}</div></section>})}</div>:<div className="people-empty"><div className="empty-icon"><CalendarDays size={20}/></div><strong>No hay actividades para esta selección.</strong><span>Cambiá el filtro o agregá una nueva actividad.</span></div>}
    </>}
  </section>
}

export default function AdminDashboard({ onExit }: { onExit: () => void }) {
  const [tab, setTab] = useState<Tab>('speakers')
  const [counts, setCounts] = useState({ speakers: 0, committee: 0, organizing: 0, program: 0 })

  useEffect(() => {
    Promise.all([
      db.from('speakers').select('*', { count: 'exact', head: true }),
      db.from('scientific_committee').select('*', { count: 'exact', head: true }),
      db.from('organizing_committee').select('*', { count: 'exact', head: true }),
      db.from('program_items').select('*', { count: 'exact', head: true }),
    ]).then(([speakers, committee, organizing, program]) => setCounts({ speakers: speakers.count || 0, committee: committee.count || 0, organizing: organizing.count || 0, program: program.count || 0 }))
  }, [tab])

  const tabs: { key: Tab; label: string; icon: typeof Users }[] = [
    { key: 'speakers', label: 'Ponentes', icon: Users },
    { key: 'committee', label: 'Comité de Organización', icon: Users },
    { key: 'organizing', label: 'Comité Científico', icon: Landmark },
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
