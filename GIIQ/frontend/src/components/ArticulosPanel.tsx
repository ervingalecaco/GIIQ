import { useMemo, useState, type ReactNode } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  Badge, Button, Select, Table, TableBody, TableCell, TableHead, TableHeadCell, TableRow, TextInput,
} from 'flowbite-react'
import { HiPlus, HiSearch, HiUpload } from 'react-icons/hi'
import { articulosApi, inventarioApi } from '../api/catalogos'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'
import { ArticuloFormModal } from './ArticuloFormModal'
import { EntradaFormModal } from './EntradaFormModal'
import { ImportarCristaleriaModal } from './ImportarCristaleriaModal'
import { Cargando, ErrorAlert, TipoBadge } from './Feedback'
import { Paginador, usePaginacion } from './Paginacion'
import { RomboNfpa } from './RomboNfpa'
import { MiniaturaArticulo } from './ImagenArticulo'
import { especialesDe, NFPA_ESPECIALES, tieneRombo } from '../nfpa'
import type { Articulo, TipoArticulo } from '../types'
import { useDialogos } from './Dialogos'

const sinAcentos = (s: string) => s.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase()

/** Filtros para clasificar los reactivos según su rombo NFPA 704. */
const FILTROS_NFPA: { valor: string; texto: string; cumple: (a: Articulo) => boolean }[] = [
  { valor: 'sin', texto: 'Sin rombo (pendientes)', cumple: (a) => !tieneRombo(a) },
  { valor: 'salud', texto: 'Salud: alto riesgo (3-4)', cumple: (a) => (a.nfpaSalud ?? -1) >= 3 },
  { valor: 'inflamable', texto: 'Inflamabilidad: alta (3-4)', cumple: (a) => (a.nfpaInflamabilidad ?? -1) >= 3 },
  { valor: 'reactivo', texto: 'Reactividad: alta (3-4)', cumple: (a) => (a.nfpaReactividad ?? -1) >= 3 },
  ...NFPA_ESPECIALES.map((e) => ({
    valor: `esp-${e.codigo}`,
    texto: `Especial ${e.etiqueta}: ${e.texto}`,
    cumple: (a: Articulo) => especialesDe(a.nfpaEspecial).includes(e.codigo),
  })),
]

type Vista = 'activos' | 'inactivos' | 'todos'
const VISTAS: { key: Vista; label: string }[] = [
  { key: 'activos', label: 'Activos' },
  { key: 'inactivos', label: 'Inactivos' },
  { key: 'todos', label: 'Todos' },
]

const NUEVO: Record<TipoArticulo, string> = {
  REACTIVO: 'Nuevo reactivo',
  CRISTALERIA: 'Nueva cristalería',
}

/**
 * Tabla de artículos con existencias y acciones (crear, editar, ingresar stock, activar).
 * Con `tipo` muestra solo ese tipo y los nuevos se crean de ese tipo.
 */
export function ArticulosPanel({ tipo, toolbar }: { tipo?: TipoArticulo; toolbar?: ReactNode }) {
  const { hasPerm } = useAuth()
  const qc = useQueryClient()
  const [editar, setEditar] = useState<number | 'nuevo' | null>(null)
  const [entrada, setEntrada] = useState<Articulo | null>(null)
  const [importar, setImportar] = useState(false)
  const verExistencias = hasPerm('inventario.ver')

  const { data, isLoading, error } = useQuery({
    queryKey: ['articulos', tipo ?? 'ALL'],
    queryFn: () => articulosApi.list(tipo),
  })
  const existencias = useQuery({
    queryKey: ['existencias'],
    queryFn: inventarioApi.existencias,
    enabled: verExistencias,
  })
  const stock = useMemo(
    () => new Map((existencias.data ?? []).map((e) => [e.articuloId, e])),
    [existencias.data],
  )

  // Búsqueda local por código, nombre o categoría (sin distinguir mayúsculas ni acentos).
  const [buscar, setBuscar] = useState('')
  // Clasificación por rombo NFPA (solo en Reactivos).
  const conRombo = tipo === 'REACTIVO'
  // Foto de referencia (solo en Cristalería).
  const conImagen = tipo === 'CRISTALERIA'
  const [filtroNfpa, setFiltroNfpa] = useState('')
  const filtrados = useMemo(() => {
    const q = sinAcentos(buscar.trim())
    const filtro = FILTROS_NFPA.find((f) => f.valor === filtroNfpa)
    return data?.filter((a) =>
      (!q || sinAcentos(`${a.codigo} ${a.nombre} ${a.categoria ?? ''}`).includes(q))
      && (!filtro || filtro.cumple(a)))
  }, [data, buscar, filtroNfpa])

  // Pestañas por estado: lo desactivado sale de "Activos" y pasa a "Inactivos".
  const [vista, setVista] = useState<Vista>('activos')
  const conteo = {
    activos: filtrados?.filter((a) => a.activo).length ?? 0,
    inactivos: filtrados?.filter((a) => !a.activo).length ?? 0,
    todos: filtrados?.length ?? 0,
  }
  const visibles = filtrados?.filter((a) =>
    vista === 'activos' ? a.activo : vista === 'inactivos' ? !a.activo : true)
  const pag = usePaginacion(visibles, [vista, buscar, filtroNfpa])

  const { avisar } = useDialogos()
  const estado = useMutation({
    mutationFn: ({ id, activo }: { id: number; activo: boolean }) =>
      articulosApi.cambiarEstado(id, activo),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['articulos'] }),
    onError: (e) => avisar(apiError(e), 'error'),
  })

  function refrescar() {
    qc.invalidateQueries({ queryKey: ['articulos'] })
    qc.invalidateQueries({ queryKey: ['articulo'] })
    qc.invalidateQueries({ queryKey: ['existencias'] })
  }

  const columnas = 6 + (tipo ? 0 : 1) + (conRombo ? 1 : 0) + (conImagen ? 1 : 0)

  return (
    <div className="space-y-4">
      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}

      {data && visibles && (
        <section className="rounded-lg border border-gray-200 bg-white">
          {/* Pestañas por estado con contador, y las acciones a la derecha. */}
          <div className="flex flex-wrap items-center justify-between gap-3 border-b border-gray-200 px-4">
            <div role="tablist" aria-label="Estado de los artículos" className="flex flex-wrap gap-1">
              {VISTAS.map((v) => {
                const sel = vista === v.key
                return (
                  <button key={v.key} type="button" role="tab" aria-selected={sel} onClick={() => setVista(v.key)}
                    className={`-mb-px flex h-12 items-center gap-2 border-b-2 px-3 text-sm focus:outline-none focus-visible:ring-2 focus-visible:ring-primary-300 ${
                      sel ? 'border-primary-700 font-semibold text-gray-900' : 'border-transparent font-medium text-gray-500 hover:text-gray-900'}`}>
                    {v.label}
                    <span className={`rounded px-1.5 py-px font-mono text-[11px] ${sel ? 'bg-primary-100 text-primary-900' : 'bg-gray-100 text-gray-600'}`}>
                      {conteo[v.key]}
                    </span>
                  </button>
                )
              })}
            </div>
            <div className="flex items-center gap-2 py-2">
              {tipo === 'CRISTALERIA' && hasPerm('articulos.crear') && hasPerm('entrada.registrar') && (
                <Button size="sm" color="light" onClick={() => setImportar(true)}>
                  <HiUpload className="me-1.5 h-4 w-4" /> Importar Excel
                </Button>
              )}
              {hasPerm('articulos.crear') && (
                <Button size="sm" onClick={() => setEditar('nuevo')}>
                  <HiPlus className="me-1.5 h-4 w-4" /> {tipo ? NUEVO[tipo] : 'Nuevo artículo'}
                </Button>
              )}
            </div>
          </div>

          <div className="flex flex-wrap items-center gap-3 border-b border-gray-200 px-4 py-3">
            <TextInput sizing="sm" icon={HiSearch} className="w-full sm:w-72" placeholder="Buscar por código, nombre o categoría"
              aria-label="Buscar artículo" value={buscar} onChange={(e) => setBuscar(e.target.value)} />
            {conRombo && (
              <Select sizing="sm" aria-label="Clasificación NFPA" value={filtroNfpa}
                onChange={(e) => setFiltroNfpa(e.target.value)}>
                <option value="">Clasificación NFPA: todos</option>
                {FILTROS_NFPA.map((f) => <option key={f.valor} value={f.valor}>{f.texto}</option>)}
              </Select>
            )}
            {(buscar || filtroNfpa) && (
              <span className="font-mono text-xs text-gray-500">{filtrados?.length ?? 0} de {data.length}</span>
            )}
            {toolbar}
          </div>

          <Table hoverable theme={{ root: { wrapper: 'relative overflow-x-auto' } }}>
            <TableHead>
              <TableRow>
                {conImagen && <TableHeadCell className="w-16"><span className="sr-only">Imagen</span></TableHeadCell>}
                <TableHeadCell>Código</TableHeadCell>
                <TableHeadCell>Nombre</TableHeadCell>
                {!tipo && <TableHeadCell>Tipo</TableHeadCell>}
                {conRombo && <TableHeadCell>NFPA 704</TableHeadCell>}
                <TableHeadCell>Categoría</TableHeadCell>
                <TableHeadCell className="min-w-44">{verExistencias ? 'Existencia' : 'Mínimo'}</TableHeadCell>
                <TableHeadCell>Estado</TableHeadCell>
                <TableHeadCell className="text-right">Acciones</TableHeadCell>
              </TableRow>
            </TableHead>
            <TableBody className="divide-y divide-gray-100">
              {visibles.length === 0 && (
                <TableRow>
                  <TableCell colSpan={columnas} className="text-center text-gray-400">
                    {buscar
                      ? 'Ningún artículo coincide con la búsqueda.'
                      : vista === 'inactivos' ? 'No hay artículos inactivos.'
                      : tipo === 'REACTIVO' ? 'Sin reactivos.' : tipo === 'CRISTALERIA' ? 'Sin cristalería.' : 'Sin artículos.'}
                  </TableCell>
                </TableRow>
              )}
              {pag.visibles?.map((a) => {
                const ex = stock.get(a.id)
                return (
                  <TableRow key={a.id} className={`bg-white ${!a.activo && vista === 'todos' ? 'opacity-60' : ''}`}>
                    {conImagen && <TableCell className="py-2 pe-0"><MiniaturaArticulo articulo={a} /></TableCell>}
                    <TableCell className="font-mono text-xs font-medium text-primary-700 whitespace-nowrap">{a.codigo}</TableCell>
                    <TableCell className="font-medium text-gray-900">{a.nombre}</TableCell>
                    {!tipo && <TableCell><TipoBadge tipo={a.tipo} /></TableCell>}
                    {conRombo && (
                      <TableCell className="py-1.5">
                        {tieneRombo(a)
                          ? <RomboNfpa tamano={44} {...a} />
                          : <Badge color="warning" className="w-fit" title="Edita el reactivo para completar su rombo">Sin rombo</Badge>}
                      </TableCell>
                    )}
                    <TableCell className="text-gray-700">{a.categoria}</TableCell>
                    <TableCell>
                      {verExistencias
                        ? <Existencia existencia={ex?.existencia ?? 0} minimo={a.stockMinimo} unidad={ex?.unidad ?? a.unidad} />
                        : <span className="font-mono text-xs tabular-nums">{a.stockMinimo} {a.unidad}</span>}
                    </TableCell>
                    <TableCell>
                      <EstadoStock activo={a.activo} existencia={verExistencias ? ex?.existencia ?? 0 : undefined}
                        bajoMinimo={ex?.bajoMinimo} />
                    </TableCell>
                    <TableCell>
                      <div className="flex gap-2 justify-end">
                        {hasPerm('entrada.registrar') && a.activo && (
                          <Button size="xs" onClick={() => setEntrada(a)}>Ingresar</Button>
                        )}
                        {hasPerm('articulos.editar') && (
                          <Button size="xs" color="light" onClick={() => setEditar(a.id)}>Editar</Button>
                        )}
                        {hasPerm('articulos.eliminar') && (
                          <Button size="xs" color="light" disabled={estado.isPending}
                            onClick={() => estado.mutate({ id: a.id, activo: !a.activo })}>
                            {a.activo ? 'Desactivar' : 'Activar'}
                          </Button>
                        )}
                      </div>
                    </TableCell>
                  </TableRow>
                )
              })}
            </TableBody>
          </Table>
          {pag.total > 0 && (
            <div className="border-t border-gray-200 px-4 py-3">
              <Paginador p={pag} nombre={tipo === 'REACTIVO' ? 'reactivos' : tipo === 'CRISTALERIA' ? 'artículos de cristalería' : 'artículos'} />
            </div>
          )}
        </section>
      )}

      {editar !== null && (
        <ArticuloFormModal
          articuloId={editar}
          tipoFijo={tipo}
          onClose={() => setEditar(null)}
          onSaved={() => { setEditar(null); refrescar() }}
        />
      )}

      {importar && (
        <ImportarCristaleriaModal onClose={() => setImportar(false)} onSaved={refrescar} />
      )}

      {entrada && (
        <EntradaFormModal
          articulo={entrada}
          onClose={() => setEntrada(null)}
          onSaved={() => { setEntrada(null); refrescar() }}
        />
      )}
    </div>
  )
}

/** Existencia frente al mínimo: cantidades en mono y una barra que llega al 100 % con el doble del mínimo. */
function Existencia({ existencia, minimo, unidad }: { existencia: number; minimo: number; unidad?: string | null }) {
  const pct = minimo > 0 ? Math.min(100, Math.round((existencia / (minimo * 2)) * 100)) : 100
  const color = existencia <= 0 ? 'bg-red-700' : existencia < minimo ? 'bg-amber-600' : 'bg-primary-600'
  return (
    <div>
      <div className="flex justify-between gap-3 font-mono text-xs tabular-nums whitespace-nowrap">
        <span className="text-gray-900">{existencia} {unidad}</span>
        <span className="text-gray-500">mín. {minimo}</span>
      </div>
      <div className="mt-1.5 h-1 rounded-sm bg-gray-100">
        <div className={`h-1 rounded-sm ${color}`} style={{ width: `${pct}%` }} />
      </div>
    </div>
  )
}

/** Estado del artículo: si está activo y se ven existencias, el estado de su stock. */
function EstadoStock({ activo, existencia, bajoMinimo }: { activo: boolean; existencia?: number; bajoMinimo?: boolean }) {
  if (!activo) return <Badge color="gray" className="w-fit">Inactivo</Badge>
  if (existencia === undefined) return <Badge color="success" className="w-fit">Activo</Badge>
  if (existencia <= 0) return <Badge color="failure" className="w-fit">Agotado</Badge>
  if (bajoMinimo) return <Badge color="warning" className="w-fit">Bajo mínimo</Badge>
  return <Badge color="success" className="w-fit">Disponible</Badge>
}
