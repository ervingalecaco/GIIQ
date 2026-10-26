import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { Button, Card, Label, Select, Spinner, Textarea, TextInput } from 'flowbite-react'
import { HiPlus, HiTrash } from 'react-icons/hi'
import { articulosApi, catalogosApi } from '../api/catalogos'
import { solicitudesApi } from '../api/solicitudes'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'
import { ErrorAlert, PageHeader, TipoBadge } from '../components/Feedback'
import { SelectBuscable } from '../components/SelectBuscable'
import { MiniaturaArticulo } from '../components/ImagenArticulo'
import { ANIOS, anioTexto } from '../anios'
import { TIPO_SOLICITUD } from '../tiposSolicitud'
import type { TipoArticulo } from '../types'

interface LineaForm { articuloId: number | ''; cantidad: string }

export function NuevaSolicitudPage({ tipo }: { tipo: TipoArticulo }) {
  const t = TIPO_SOLICITUD[tipo]
  const navigate = useNavigate()
  const { user } = useAuth()
  // El estudiante elige a su profesor responsable, que avalará la solicitud.
  const esEstudiante = user?.rol === 'Estudiante'
  const esProfesor = user?.rol === 'Profesor'
  const [profesorId, setProfesorId] = useState<number | ''>('')
  const [claseId, setClaseId] = useState<number | ''>('')
  const [practicaId, setPracticaId] = useState<number | ''>('')
  const [fechaRequerida, setFechaRequerida] = useState('')
  const [observaciones, setObservaciones] = useState('')
  const [lineas, setLineas] = useState<LineaForm[]>([{ articuloId: '', cantidad: '' }])
  const [error, setError] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)

  // Solo artículos activos del tipo de la solicitud (no se mezclan reactivos y cristalería).
  const articulos = useQuery({ queryKey: ['articulos', tipo], queryFn: () => articulosApi.list(tipo) })
  const opcionesArticulo = (articulos.data ?? [])
    .filter((a) => a.activo)
    .map((a) => ({ id: a.id, nombre: `${a.codigo} — ${a.nombre}` }))
  const profesores = useQuery({
    queryKey: ['profesores'], queryFn: catalogosApi.profesores, enabled: esEstudiante,
  })

  // Clases disponibles: las del profesor elegido (estudiante), las propias (profesor)
  // o todas (Administrador, que puede crear para cualquier clase).
  const profesorDeClases = esEstudiante ? profesorId : esProfesor ? (user?.id ?? '') : null
  const clases = useQuery({
    queryKey: ['clases-form', profesorDeClases],
    queryFn: () => (profesorDeClases === null
      ? catalogosApi.clases()
      : catalogosApi.clasesDeProfesor(Number(profesorDeClases))),
    enabled: profesorDeClases !== '',
  })
  const practicas = useQuery({
    queryKey: ['practicas-form', claseId],
    queryFn: () => catalogosApi.practicasDeClase(Number(claseId)),
    enabled: claseId !== '',
  })

  function elegirProfesor(id: number | '') {
    setProfesorId(id); setClaseId(''); setPracticaId('')
  }
  function elegirClase(id: number | '') {
    setClaseId(id); setPracticaId('')
  }

  function setLinea(i: number, patch: Partial<LineaForm>) {
    setLineas((ls) => ls.map((l, idx) => (idx === i ? { ...l, ...patch } : l)))
  }
  const addLinea = () => setLineas((ls) => [...ls, { articuloId: '', cantidad: '' }])
  const delLinea = (i: number) => setLineas((ls) => ls.filter((_, idx) => idx !== i))

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)

    if (esEstudiante && !profesorId) { setError('Elige a tu profesor responsable.'); return }
    if (!claseId) { setError('Selecciona la clase.'); return }
    if (!practicaId) { setError('Selecciona la práctica.'); return }
    const items = lineas.filter((l) => l.articuloId !== '' && Number(l.cantidad) > 0)
    if (items.length === 0) { setError('Agrega al menos una línea válida.'); return }

    const payloadLineas = items.map((l) => {
      const art = articulos.data!.find((a) => a.id === l.articuloId)!
      return { articuloId: Number(l.articuloId), unidadId: art.unidadId, cantidad: Number(l.cantidad) }
    })

    setSaving(true)
    try {
      const { solicitudId } = await solicitudesApi.crear({
        tipo,
        practicaId: Number(practicaId),
        profesorId: esEstudiante ? Number(profesorId) : null,
        fechaRequerida: fechaRequerida || null,
        observaciones: observaciones || null,
        lineas: payloadLineas,
      })
      // Abre directamente el detalle de lo que se acaba de generar.
      navigate(`${t.ruta}?ver=${solicitudId}&nueva=1`)
    } catch (err) {
      setError(apiError(err, 'No se pudo crear la solicitud.'))
    } finally {
      setSaving(false)
    }
  }

  // Resumen en vivo de lo que se va a generar (solo líneas completas).
  const profesor = profesores.data?.find((p) => p.id === profesorId)
  const clase = clases.data?.find((c) => c.id === claseId)
  const practica = practicas.data?.find((p) => p.id === practicaId)
  const resumen = lineas.flatMap((l) => {
    const art = articulos.data?.find((a) => a.id === l.articuloId)
    return art && Number(l.cantidad) > 0 ? [{ art, cantidad: Number(l.cantidad) }] : []
  })

  return (
    <div className="space-y-5">
      <PageHeader title={`Nueva solicitud de ${t.plural}`}
        subtitle={tipo === 'REACTIVO' ? 'Pide reactivos para una práctica.' : 'Pide cristalería prestada para una práctica.'} />

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-5 items-start">
      <Card className="lg:col-span-2">
        <form onSubmit={onSubmit} className="flex flex-col gap-5">
          {esEstudiante && (
            <div>
              <Label htmlFor="prof" className="mb-2 block">Profesor responsable</Label>
              <SelectBuscable id="prof" opciones={profesores.data ?? []} value={profesorId}
                onChange={elegirProfesor} placeholder="Escribe el nombre de tu profesor…"
                vacio="Ningún profesor coincide." />
              <p className="mt-1 text-xs text-gray-500">
                Tu profesor debe dar el visto bueno antes de que la solicitud pase al supervisor.
              </p>
            </div>
          )}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <Label htmlFor="clase" className="mb-2 block">Clase</Label>
              <Select id="clase" value={claseId} disabled={profesorDeClases === '' || !clases.data?.length}
                onChange={(e) => elegirClase(e.target.value ? Number(e.target.value) : '')}>
                <option value="">
                  {profesorDeClases === '' ? 'Primero elige a tu profesor'
                    : clases.isLoading ? 'Cargando clases…'
                    : clases.data?.length ? 'Selecciona la clase…' : 'Sin clases asignadas'}
                </option>
                {/* Agrupadas por año: Primer año, Segundo año… (solo los años que tienen clases) */}
                {ANIOS.map((a) => {
                  const delAnio = clases.data?.filter((c) => c.anio === a.id) ?? []
                  return delAnio.length > 0 && (
                    <optgroup key={a.id} label={a.nombre}>
                      {delAnio.map((c) => <option key={c.id} value={c.id}>{c.nombre}</option>)}
                    </optgroup>
                  )
                })}
              </Select>
              {clases.data?.length === 0 && (
                <p className="mt-1 text-xs text-amber-700">
                  {esEstudiante ? 'Este profesor no tiene' : 'No tienes'} clases asignadas. Pide al administrador que las registre en Catálogos.
                </p>
              )}
            </div>
            <div>
              <Label htmlFor="practica" className="mb-2 block">Práctica</Label>
              <Select id="practica" value={practicaId} disabled={claseId === '' || !practicas.data?.length}
                onChange={(e) => setPracticaId(e.target.value ? Number(e.target.value) : '')}>
                <option value="">
                  {claseId === '' ? 'Primero elige la clase'
                    : practicas.isLoading ? 'Cargando prácticas…'
                    : practicas.data?.length ? 'Selecciona la práctica…' : 'La clase no tiene prácticas'}
                </option>
                {practicas.data?.map((p) => <option key={p.id} value={p.id}>{p.nombre}</option>)}
              </Select>
              {practica?.laboratorio && (
                <p className="mt-1 text-xs text-gray-500">Se realiza en: {practica.laboratorio}</p>
              )}
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
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
                    {/* En cristalería, la foto confirma que se eligió el material correcto. */}
                    {tipo === 'CRISTALERIA' && <MiniaturaArticulo articulo={art} tamano="h-10 w-10" />}
                    <div className="flex-1">
                      <SelectBuscable id={`art-${i}`} opciones={opcionesArticulo} value={l.articuloId}
                        onChange={(id) => setLinea(i, { articuloId: id })}
                        placeholder={tipo === 'REACTIVO' ? 'Buscar reactivo…' : 'Buscar cristalería…'}
                        vacio="Ningún artículo coincide." />
                    </div>
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
            <Button type="button" color="light" onClick={() => navigate(t.ruta)}>Cancelar</Button>
          </div>
        </form>
      </Card>

      {/* Resumen de lo que se va a generar */}
      <Card className="lg:sticky lg:top-6">
        <h2 className="text-base font-semibold text-gray-900">Resumen de la solicitud</h2>
        <dl className="space-y-2 text-sm">
          {esEstudiante && (
            <div className="flex justify-between gap-3">
              <dt className="text-gray-500">Profesor</dt>
              <dd className="text-right text-gray-900">{profesor?.nombre ?? <span className="text-gray-400">Sin elegir</span>}</dd>
            </div>
          )}
          {[
            ['Clase', clase && `${clase.nombre} · ${anioTexto(clase.anio)}`],
            ['Práctica', practica?.nombre],
            ['Laboratorio', practica?.laboratorio],
          ].map(([etiqueta, valor]) => (
            <div key={etiqueta} className="flex justify-between gap-3">
              <dt className="text-gray-500">{etiqueta}</dt>
              <dd className="text-right text-gray-900">{valor ?? <span className="text-gray-400">Sin elegir</span>}</dd>
            </div>
          ))}
          <div className="flex justify-between gap-3">
            <dt className="text-gray-500">Fecha requerida</dt>
            <dd className="text-gray-900">
              {fechaRequerida
                ? new Date(`${fechaRequerida}T00:00`).toLocaleDateString()
                : <span className="text-gray-400">Sin fecha</span>}
            </dd>
          </div>
        </dl>

        <div className="border-t border-gray-200 pt-3">
          {resumen.length === 0
            ? <p className="text-sm text-gray-400">Agrega artículos con su cantidad para verlos aquí.</p>
            : (
              <ul className="divide-y divide-gray-100">
                {resumen.map(({ art, cantidad }, i) => (
                  <li key={i} className="flex items-center justify-between gap-3 py-2">
                    <div className="min-w-0">
                      <div className="truncate text-sm text-gray-900">{art.nombre}</div>
                      <TipoBadge tipo={art.tipo} />
                    </div>
                    <span className="shrink-0 text-sm font-medium tabular-nums text-gray-900">
                      {cantidad} {art.unidad}
                    </span>
                  </li>
                ))}
              </ul>
            )}
        </div>

        {resumen.length > 0 && (
          <p className="border-t border-gray-200 pt-3 text-xs text-gray-500">
            {resumen.length} artículo{resumen.length === 1 ? '' : 's'}.{' '}
            {tipo === 'REACTIVO'
              ? 'Los reactivos se consumen: la solicitud se cierra al entregarse.'
              : 'La cristalería se presta: debe devolverse para cerrar la solicitud.'}
          </p>
        )}
      </Card>
      </div>
    </div>
  )
}
