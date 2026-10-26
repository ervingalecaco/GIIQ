import { useMemo, useState, type FormEvent } from 'react'
import { Link } from 'react-router-dom'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import {
  Badge, Button, Label, Select, Spinner, Table, TableBody, TableCell, TableHead, TableHeadCell, TableRow, TextInput,
} from 'flowbite-react'
import { HiPlus, HiSearch } from 'react-icons/hi'
import { articulosApi } from '../api/catalogos'
import { bajasApi, CAUSAS, cuentasApi, textoCausa } from '../api/bajas'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'
import { BotonExcel } from '../components/BotonExcel'
import { Cargando, ErrorAlert, PageHeader } from '../components/Feedback'
import { describirPeriodo, FiltroPeriodo, PERIODO_INICIAL, rangoDe, type Periodo } from '../components/FiltroPeriodo'
import { MiniaturaArticulo } from '../components/ImagenArticulo'
import { Modal } from '../components/Modal'
import { Paginador, usePaginacion } from '../components/Paginacion'
import { SelectBuscable } from '../components/SelectBuscable'
import type { CausaBaja } from '../types'

const sinAcentos = (s: string) => s.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase()
const fechaHora = (s: string) => new Date(s).toLocaleString('es', { dateStyle: 'medium', timeStyle: 'short' })

/** Historial de bajas de cristalería y registro de bajas fuera de una devolución. */
export function BajasPage() {
  const { hasPerm } = useAuth()
  const qc = useQueryClient()
  const [periodo, setPeriodo] = useState<Periodo>(PERIODO_INICIAL)
  const rango = rangoDe(periodo)
  const [buscar, setBuscar] = useState('')
  const [nueva, setNueva] = useState(false)
  const { data, isLoading, error } = useQuery({
    queryKey: ['bajas', rango.desde ?? '', rango.hasta ?? ''],
    queryFn: () => bajasApi.list(rango),
  })
  const filtradas = useMemo(() => {
    const q = sinAcentos(buscar.trim())
    return data?.filter((b) => !q || sinAcentos(`${b.codigo} ${b.articulo} ${b.estudiante ?? ''} ${b.estudianteCodigo ?? ''}`).includes(q))
  }, [data, buscar])
  const pag = usePaginacion(filtradas, [buscar, rango.desde, rango.hasta])
  const piezas = filtradas?.reduce((t, b) => t + b.cantidad, 0) ?? 0

  return (
    <div className="space-y-5">
      <PageHeader title="Bajas de cristalería"
        subtitle="Piezas quebradas, extraviadas o deterioradas que salieron del inventario.">
        <BotonExcel url={`/api/bajas/excel?${new URLSearchParams(Object.entries(rango).filter(([, v]) => v) as [string, string][])}`} archivo="bajas.xlsx" />
        {hasPerm('baja.registrar') && (
          <Button size="sm" onClick={() => setNueva(true)}><HiPlus className="me-1.5 h-4 w-4" /> Registrar baja</Button>
        )}
      </PageHeader>

      <div className="flex flex-wrap items-center gap-3">
        <FiltroPeriodo valor={periodo} onChange={setPeriodo} />
        <span className="text-sm text-gray-500">Bajas {describirPeriodo(periodo)}</span>
      </div>

      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}

      {data && filtradas && (
        <section className="rounded-lg border border-gray-200 bg-white">
          <div className="flex flex-wrap items-center justify-between gap-3 border-b border-gray-200 px-4 py-3">
            <TextInput sizing="sm" icon={HiSearch} className="w-full sm:w-80" aria-label="Buscar baja"
              placeholder="Buscar por artículo o estudiante" value={buscar} onChange={(e) => setBuscar(e.target.value)} />
            <span className="font-mono text-xs text-gray-500">{filtradas.length} bajas · {piezas} piezas</span>
          </div>
          <Table hoverable theme={{ root: { wrapper: 'relative overflow-x-auto' } }}>
            <TableHead>
              <TableRow>
                <TableHeadCell>Fecha</TableHeadCell>
                <TableHeadCell>Artículo</TableHeadCell>
                <TableHeadCell className="text-right">Cantidad</TableHeadCell>
                <TableHeadCell>Causa</TableHeadCell>
                <TableHeadCell>Responsable</TableHeadCell>
                <TableHeadCell>Cargo</TableHeadCell>
                <TableHeadCell>Registró</TableHeadCell>
              </TableRow>
            </TableHead>
            <TableBody className="divide-y divide-gray-100">
              {filtradas.length === 0 && (
                <TableRow>
                  <TableCell colSpan={7} className="text-center text-gray-400">
                    {buscar ? 'Ninguna baja coincide con la búsqueda.' : 'Sin bajas en este período.'}
                  </TableCell>
                </TableRow>
              )}
              {pag.visibles?.map((b) => (
                <TableRow key={b.id} className="bg-white">
                  <TableCell className="font-mono text-xs whitespace-nowrap">{fechaHora(b.fecha)}</TableCell>
                  <TableCell>
                    <div className="font-medium text-gray-900">{b.articulo}</div>
                    <div className="font-mono text-xs text-gray-500">
                      {b.codigo}{b.solicitudId ? ` · solicitud #${b.solicitudId}` : ''}
                    </div>
                    {b.observacion && <div className="text-xs text-gray-500">{b.observacion}</div>}
                  </TableCell>
                  <TableCell className="text-right font-mono text-xs tabular-nums">{b.cantidad} {b.unidad}</TableCell>
                  <TableCell>{textoCausa(b.causa)}</TableCell>
                  <TableCell>
                    {b.estudianteId
                      ? <Link to={`/cuentas/${b.estudianteId}`} className="text-primary-700 hover:text-primary-900">
                          {b.estudiante}
                          {b.estudianteCodigo && <span className="block font-mono text-xs text-gray-500">{b.estudianteCodigo}</span>}
                        </Link>
                      : <span className="text-gray-400">Sin responsable</span>}
                  </TableCell>
                  <TableCell>
                    {b.estadoCargo === 'PENDIENTE' && <Badge color="warning" className="w-fit">Pendiente</Badge>}
                    {b.estadoCargo === 'SALDADO' && <Badge color="success" className="w-fit">Saldado</Badge>}
                    {!b.estadoCargo && <span className="text-gray-400">—</span>}
                  </TableCell>
                  <TableCell className="text-gray-700">{b.registradoPor}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
          {pag.total > 0 && (
            <div className="border-t border-gray-200 px-4 py-3"><Paginador p={pag} nombre="bajas" /></div>
          )}
        </section>
      )}

      {nueva && (
        <NuevaBajaModal onClose={() => setNueva(false)} onDone={() => {
          setNueva(false)
          qc.invalidateQueries({ queryKey: ['bajas'] })
          qc.invalidateQueries({ queryKey: ['cuentas'] })
          qc.invalidateQueries({ queryKey: ['articulos'] })
          qc.invalidateQueries({ queryKey: ['existencias'] })
        }} />
      )}
    </div>
  )
}

/** Baja fuera de una devolución: lo que se quiebra en bodega o en el laboratorio. */
function NuevaBajaModal({ onClose, onDone }: { onClose: () => void; onDone: () => void }) {
  const articulos = useQuery({ queryKey: ['articulos', 'CRISTALERIA'], queryFn: () => articulosApi.list('CRISTALERIA') })
  const estudiantes = useQuery({ queryKey: ['cuentas-estudiantes'], queryFn: cuentasApi.estudiantes })
  const [articuloId, setArticuloId] = useState<number | ''>('')
  const [cantidad, setCantidad] = useState('1')
  const [causa, setCausa] = useState<CausaBaja>('QUEBRADO')
  const [estudianteId, setEstudianteId] = useState<number | ''>('')
  const [observacion, setObservacion] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [guardando, setGuardando] = useState(false)
  const art = articulos.data?.find((a) => a.id === articuloId)

  async function guardar(e: FormEvent) {
    e.preventDefault()
    if (articuloId === '') { setError('Elige la cristalería.'); return }
    if (!(Number(cantidad) > 0)) { setError('La cantidad debe ser mayor que cero.'); return }
    setError(null)
    setGuardando(true)
    try {
      await bajasApi.registrar({
        articuloId, cantidad: Number(cantidad), causa,
        estudianteId: estudianteId === '' ? null : estudianteId, observacion: observacion.trim() || null,
      })
      onDone()
    } catch (err) {
      setError(apiError(err, 'No se pudo registrar la baja.'))
    } finally {
      setGuardando(false)
    }
  }

  return (
    <Modal title="Registrar baja de cristalería" onClose={onClose} size="xl">
      <form onSubmit={guardar} className="space-y-4">
        <div>
          <Label htmlFor="baja-art" className="mb-1 block">Cristalería</Label>
          <div className="flex items-center gap-2">
            <MiniaturaArticulo articulo={art} tamano="h-10 w-10" />
            <div className="flex-1">
              <SelectBuscable id="baja-art" value={articuloId} onChange={setArticuloId}
                placeholder="Buscar por código o nombre…" vacio="Ninguna cristalería coincide."
                opciones={articulos.data?.filter((a) => a.activo).map((a) => ({ id: a.id, nombre: `${a.codigo} — ${a.nombre}` })) ?? []} />
            </div>
          </div>
        </div>
        <div className="grid gap-3 sm:grid-cols-2">
          <div>
            <Label htmlFor="baja-cant" className="mb-1 block">Cantidad {art?.unidad ? `(${art.unidad})` : ''}</Label>
            <TextInput id="baja-cant" type="number" min={1} step="1" value={cantidad} onChange={(e) => setCantidad(e.target.value)} required />
          </div>
          <div>
            <Label htmlFor="baja-causa" className="mb-1 block">Causa</Label>
            <Select id="baja-causa" value={causa} onChange={(e) => setCausa(e.target.value as CausaBaja)}>
              {CAUSAS.map((c) => <option key={c.valor} value={c.valor}>{c.texto}</option>)}
            </Select>
          </div>
        </div>
        <div>
          <Label htmlFor="baja-est" className="mb-1 block">
            Estudiante responsable <span className="font-normal text-gray-500">(opcional)</span>
          </Label>
          <SelectBuscable id="baja-est" value={estudianteId} onChange={setEstudianteId}
            placeholder="Buscar por código o nombre…" vacio="Ningún estudiante coincide."
            opciones={estudiantes.data?.map((e) => ({ id: e.id, nombre: `${e.codigo ? `${e.codigo} — ` : ''}${e.nombre}` })) ?? []} />
          <p className="mt-1 text-xs text-gray-500">
            {estudianteId === '' ? 'Sin responsable: solo sale del inventario.' : 'Se le carga a su cuenta hasta que reponga la pieza.'}
          </p>
        </div>
        <div>
          <Label htmlFor="baja-obs" className="mb-1 block">Observación <span className="font-normal text-gray-500">(opcional)</span></Label>
          <TextInput id="baja-obs" maxLength={255} value={observacion} placeholder="Qué pasó"
            onChange={(e) => setObservacion(e.target.value)} />
        </div>
        {error && <ErrorAlert>{error}</ErrorAlert>}
        <div className="flex justify-end gap-2 border-t border-gray-200 pt-4">
          <Button type="button" color="light" onClick={onClose}>Cancelar</Button>
          <Button type="submit" disabled={guardando}>
            {guardando ? <><Spinner size="sm" light className="me-2" /> Guardando…</> : 'Registrar baja'}
          </Button>
        </div>
      </form>
    </Modal>
  )
}
