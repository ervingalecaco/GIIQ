import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { Button, Card, Label, Select, Spinner, Textarea, TextInput } from 'flowbite-react'
import { HiPlus, HiTrash } from 'react-icons/hi'
import { articulosApi, catalogosApi } from '../api/catalogos'
import { solicitudesApi } from '../api/solicitudes'
import { apiError } from '../api/client'
import { ErrorAlert, PageHeader } from '../components/Feedback'

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
    <div className="max-w-2xl space-y-5">
      <PageHeader title="Nueva solicitud" subtitle="Pide reactivos y materiales para una práctica." />

      <Card>
        <form onSubmit={onSubmit} className="flex flex-col gap-5">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <Label htmlFor="lab" className="mb-2 block">Laboratorio / práctica</Label>
              <Select id="lab" value={laboratorioId}
                onChange={(e) => setLaboratorioId(e.target.value ? Number(e.target.value) : '')}>
                <option value="">Selecciona…</option>
                {labs.data?.map((l) => <option key={l.id} value={l.id}>{l.nombre}</option>)}
              </Select>
            </div>
            <div>
              <Label htmlFor="fecha" className="mb-2 block">Fecha requerida</Label>
              <TextInput id="fecha" type="date" value={fechaRequerida} onChange={(e) => setFechaRequerida(e.target.value)} />
            </div>
          </div>

          <div>
            <div className="flex items-center justify-between mb-2">
              <Label>Artículos solicitados</Label>
              <Button type="button" size="xs" color="light" onClick={addLinea}>
                <HiPlus className="me-1 h-3.5 w-3.5" /> Agregar línea
              </Button>
            </div>
            <div className="space-y-2">
              {lineas.map((l, i) => {
                const art = articulos.data?.find((a) => a.id === l.articuloId)
                return (
                  <div key={i} className="flex gap-2 items-center">
                    <Select className="flex-1" value={l.articuloId} aria-label="Artículo"
                      onChange={(e) => setLinea(i, { articuloId: e.target.value ? Number(e.target.value) : '' })}>
                      <option value="">Artículo…</option>
                      {articulos.data?.map((a) => (
                        <option key={a.id} value={a.id}>{a.nombre} ({a.tipo === 'REACTIVO' ? 'R' : 'M'})</option>
                      ))}
                    </Select>
                    <TextInput className="w-28" type="number" step="0.001" min="0" placeholder="Cant."
                      aria-label="Cantidad" value={l.cantidad}
                      onChange={(e) => setLinea(i, { cantidad: e.target.value })} />
                    <span className="w-10 text-sm text-gray-500">{art?.unidad ?? ''}</span>
                    {lineas.length > 1 && (
                      <Button type="button" size="xs" color="light" onClick={() => delLinea(i)} aria-label="Quitar línea">
                        <HiTrash className="h-4 w-4 text-gray-500" />
                      </Button>
                    )}
                  </div>
                )
              })}
            </div>
          </div>

          <div>
            <Label htmlFor="obs" className="mb-2 block">Observaciones</Label>
            <Textarea id="obs" value={observaciones} onChange={(e) => setObservaciones(e.target.value)} rows={2} />
          </div>

          {error && <ErrorAlert>{error}</ErrorAlert>}

          <div className="flex gap-3">
            <Button type="submit" disabled={saving}>
              {saving ? <><Spinner size="sm" light className="me-2" /> Guardando…</> : 'Crear solicitud'}
            </Button>
            <Button type="button" color="light" onClick={() => navigate('/solicitudes')}>Cancelar</Button>
          </div>
        </form>
      </Card>
    </div>
  )
}
