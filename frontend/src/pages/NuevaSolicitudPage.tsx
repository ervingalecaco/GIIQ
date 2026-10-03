import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { articulosApi, catalogosApi } from '../api/catalogos'
import { solicitudesApi } from '../api/solicitudes'
import { apiError } from '../api/client'

interface LineaForm { articuloId: number | ''; cantidad: string }

export function NuevaSolicitudPage() {
  const navigate = useNavigate()
  const [laboratorioId, setLaboratorioId] = useState<number | ''>('')
  const [fechaRequerida, setFechaRequerida] = useState('')
  const [observaciones, setObservaciones] = useState('')
  const [lineas, setLineas] = useState<LineaForm[]>([{ articuloId: '', cantidad: '' }])
  const [error, setError] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)

  const labs = useQuery({ queryKey: ['laboratorios'], queryFn: catalogosApi.laboratorios })
  const articulos = useQuery({ queryKey: ['articulos'], queryFn: () => articulosApi.list() })

  function setLinea(i: number, patch: Partial<LineaForm>) {
    setLineas((ls) => ls.map((l, idx) => (idx === i ? { ...l, ...patch } : l)))
  }
  const addLinea = () => setLineas((ls) => [...ls, { articuloId: '', cantidad: '' }])
  const delLinea = (i: number) => setLineas((ls) => ls.filter((_, idx) => idx !== i))

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)

    if (!laboratorioId) { setError('Selecciona un laboratorio.'); return }
    const items = lineas.filter((l) => l.articuloId !== '' && Number(l.cantidad) > 0)
    if (items.length === 0) { setError('Agrega al menos una línea válida.'); return }

    const payloadLineas = items.map((l) => {
      const art = articulos.data!.find((a) => a.id === l.articuloId)!
      return { articuloId: Number(l.articuloId), unidadId: art.unidadId, cantidad: Number(l.cantidad) }
    })

    setSaving(true)
    try {
      await solicitudesApi.crear({
        laboratorioId: Number(laboratorioId),
        fechaRequerida: fechaRequerida || null,
        observaciones: observaciones || null,
        lineas: payloadLineas,
      })
      navigate('/solicitudes')
    } catch (err) {
      setError(apiError(err, 'No se pudo crear la solicitud.'))
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="max-w-2xl">
      <h1 className="text-2xl font-semibold mb-5">Nueva solicitud</h1>

      <form onSubmit={onSubmit} className="bg-white rounded-xl border border-slate-200 p-6 space-y-5">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label htmlFor="lab" className="block text-sm font-medium text-slate-700 mb-1">Laboratorio / práctica</label>
            <select id="lab" value={laboratorioId}
              onChange={(e) => setLaboratorioId(e.target.value ? Number(e.target.value) : '')}
              className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm bg-white">
              <option value="">Selecciona…</option>
              {labs.data?.map((l) => <option key={l.id} value={l.id}>{l.nombre}</option>)}
            </select>
          </div>
          <div>
            <label htmlFor="fecha" className="block text-sm font-medium text-slate-700 mb-1">Fecha requerida</label>
            <input id="fecha" type="date" value={fechaRequerida} onChange={(e) => setFechaRequerida(e.target.value)}
              className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm" />
          </div>
        </div>

        <div>
          <div className="flex items-center justify-between mb-2">
            <label className="block text-sm font-medium text-slate-700">Artículos solicitados</label>
            <button type="button" onClick={addLinea} className="text-sm text-teal-700 hover:underline">+ Agregar línea</button>
          </div>
          <div className="space-y-2">
            {lineas.map((l, i) => {
              const art = articulos.data?.find((a) => a.id === l.articuloId)
              return (
                <div key={i} className="flex gap-2 items-center">
                  <select value={l.articuloId}
                    onChange={(e) => setLinea(i, { articuloId: e.target.value ? Number(e.target.value) : '' })}
                    className="flex-1 rounded-md border border-slate-300 px-3 py-2 text-sm bg-white">
                    <option value="">Artículo…</option>
                    {articulos.data?.map((a) => (
                      <option key={a.id} value={a.id}>{a.nombre} ({a.tipo === 'REACTIVO' ? 'R' : 'M'})</option>
                    ))}
                  </select>
                  <input type="number" step="0.001" min="0" placeholder="Cant." value={l.cantidad}
                    onChange={(e) => setLinea(i, { cantidad: e.target.value })}
                    className="w-24 rounded-md border border-slate-300 px-3 py-2 text-sm" />
                  <span className="w-10 text-sm text-slate-500">{art?.unidad ?? ''}</span>
                  {lineas.length > 1 && (
                    <button type="button" onClick={() => delLinea(i)} className="text-slate-400 hover:text-rose-600 px-1">✕</button>
                  )}
                </div>
              )
            })}
          </div>
        </div>

        <div>
          <label htmlFor="obs" className="block text-sm font-medium text-slate-700 mb-1">Observaciones</label>
          <textarea id="obs" value={observaciones} onChange={(e) => setObservaciones(e.target.value)} rows={2}
            className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm" />
        </div>

        {error && <p className="text-sm text-rose-600">{error}</p>}

        <div className="flex gap-3">
          <button type="submit" disabled={saving}
            className="rounded-md bg-teal-700 text-white px-5 py-2 text-sm font-medium hover:bg-teal-800 disabled:opacity-50">
            {saving ? 'Guardando…' : 'Crear solicitud'}
          </button>
          <button type="button" onClick={() => navigate('/solicitudes')}
            className="rounded-md border border-slate-300 px-5 py-2 text-sm hover:bg-slate-100">
            Cancelar
          </button>
        </div>
      </form>
    </div>
  )
}
