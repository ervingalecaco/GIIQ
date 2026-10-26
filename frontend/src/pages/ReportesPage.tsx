import { useMemo, useRef, useState, type ReactNode } from 'react'
import { Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import {
  Alert, Badge, Button, Checkbox, Label, TabItem, Table, TableBody, TableCell, TableHead, TableHeadCell, TableRow,
  Tabs, TextInput, type TabsRef,
} from 'flowbite-react'
import { HiChevronRight, HiInformationCircle, HiSearch } from 'react-icons/hi'
import type { ColDef, ICellRendererParams } from 'ag-grid-community'
import { articulosApi } from '../api/catalogos'
import { reportesApi } from '../api/reportes'
import { Cargando, ErrorAlert, PageHeader, TipoBadge } from '../components/Feedback'
import { SelectBuscable } from '../components/SelectBuscable'
import { TablaDatos } from '../components/TablaDatos'
import { BotonExcel } from '../components/BotonExcel'
import { DatoDetalle, PanelDetalle } from '../components/PanelDetalle'
import { Paginador, usePaginacion } from '../components/Paginacion'
import type { ConsumoLaboratorio, Existencia, Kardex, ProximoVencer } from '../types'

const REPORTES = [
  { key: 'existencias', label: 'Existencias' },
  { key: 'vencer', label: 'Próximos a vencer' },
  { key: 'consumo', label: 'Consumo por laboratorio' },
  { key: 'kardex', label: 'Kardex por artículo' },
] as const
type RepKey = typeof REPORTES[number]['key']

export function ReportesPage() {
  const [rep, setRep] = useState<RepKey>('existencias')
  const tabs = useRef<TabsRef>(null)
  // Artículo con el que se abre el kardex cuando se llega desde el detalle de existencias.
  const [kardexDe, setKardexDe] = useState<number | ''>('')
  function verKardex(articuloId: number) {
    setKardexDe(articuloId)
    tabs.current?.setActiveTab(REPORTES.findIndex((r) => r.key === 'kardex'))
  }
  return (
    <div className="space-y-5">
      <PageHeader title="Reportes" subtitle="Toca una fila de existencias o de consumo para ver su detalle." />
      <Tabs ref={tabs} variant="underline" onActiveTabChange={(i) => setRep(REPORTES[i].key)}>
        {REPORTES.map((r) => (
          <TabItem key={r.key} title={r.label} active={rep === r.key}>
            {rep === r.key && r.key === 'existencias' && <Existencias onVerKardex={verKardex} />}
            {rep === r.key && r.key === 'vencer' && <ProximosVencer />}
            {rep === r.key && r.key === 'consumo' && <Consumo />}
            {rep === r.key && r.key === 'kardex' && <KardexRep inicial={kardexDe} />}
          </TabItem>
        ))}
      </Tabs>
    </div>
  )
}

/** Búsqueda rápida sobre todas las columnas de un reporte. */
function Buscador({ valor, onChange }: { valor: string; onChange: (v: string) => void }) {
  return (
    <TextInput sizing="sm" icon={HiSearch} className="w-full sm:w-80" aria-label="Buscar en el reporte"
      placeholder="Buscar en todas las columnas" value={valor} onChange={(e) => onChange(e.target.value)} />
  )
}

// Clases de celda compartidas por los reportes.
const CELDA_CODIGO = 'font-mono text-xs font-medium text-primary-700'
const CELDA_NUMERO = 'ag-right-aligned-cell font-mono text-xs tabular-nums'

/** Fecha de la API ('2026-10-23' o con hora) como Date local, para el filtro de fechas de AG Grid. */
function aFecha(s?: string | null) {
  if (!s) return null
  const d = new Date(s.length === 10 ? `${s}T00:00:00` : s)
  return new Date(d.getFullYear(), d.getMonth(), d.getDate())
}
const fechaCorta = (s?: string | null) =>
  s ? (aFecha(s) as Date).toLocaleDateString('es', { day: '2-digit', month: 'short', year: 'numeric' }) : '—'

function Vacio({ children }: { children: ReactNode }) {
  return <Alert color="gray" icon={HiInformationCircle}>{children}</Alert>
}

/** Fila clicable: abre el panel de detalle. */
const FILA_CON_DETALLE = 'cursor-pointer'

const numero = (n: number) => n.toLocaleString('es', { maximumFractionDigits: 3 })

function SeccionDetalle({ titulo, children }: { titulo: string; children: ReactNode }) {
  return (
    <section>
      <h3 className="rotulo mb-2 text-gray-500">{titulo}</h3>
      {children}
    </section>
  )
}

// ------------------------------------------------------------------ Existencias
function Existencias({ onVerKardex }: { onVerKardex: (articuloId: number) => void }) {
  const [bajo, setBajo] = useState(false)
  const [buscar, setBuscar] = useState('')
  const [sel, setSel] = useState<Existencia | null>(null)
  const { data, isLoading, error } = useQuery({
    queryKey: ['rep-existencias', bajo],
    queryFn: () => reportesApi.existencias(bajo),
  })
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div className="flex items-center gap-2">
          <Checkbox id="bajo" checked={bajo} onChange={(e) => setBajo(e.target.checked)} />
          <Label htmlFor="bajo">Solo bajo stock mínimo</Label>
        </div>
        <BotonExcel url={`/api/reportes/existencias/excel?bajoMinimo=${bajo}`} archivo='existencias.xlsx' />
      </div>
      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}
      {data && (
        <>
          <Buscador valor={buscar} onChange={setBuscar} />
          <TablaDatos<Existencia> rowData={data} columnDefs={COLUMNAS_EXISTENCIAS} quickFilterText={buscar}
            getRowId={(p) => String(p.data.articuloId)} rowClass={FILA_CON_DETALLE}
            onRowClicked={(e) => e.data && setSel(e.data)} />
        </>
      )}
      <DetalleExistencia existencia={sel} onCerrar={() => setSel(null)}
        onVerKardex={(id) => { setSel(null); onVerKardex(id) }} />
    </div>
  )
}

/** Detalle de un artículo del reporte de existencias: de qué lotes sale su existencia. */
function DetalleExistencia({ existencia: e, onCerrar, onVerKardex }: {
  existencia: Existencia | null
  onCerrar: () => void
  onVerKardex: (articuloId: number) => void
}) {
  const { data, isLoading, error } = useQuery({
    queryKey: ['rep-lotes', e?.articuloId],
    queryFn: () => reportesApi.lotesArticulo(e!.articuloId),
    enabled: !!e,
  })
  const pag = usePaginacion(data, [e?.articuloId])
  const estado = ESTADO_EXISTENCIA(e ?? undefined)
  return (
    <PanelDetalle abierto={!!e} onCerrar={onCerrar} rotulo={e?.codigo} titulo={e?.nombre}
      subtitulo={e && (
        <div className="flex flex-wrap items-center gap-2">
          <TipoBadge tipo={e.tipo} />
          <Badge color={estado === 'Disponible' ? 'success' : estado === 'Agotado' ? 'failure' : 'warning'}>{estado}</Badge>
        </div>
      )}
      acciones={e && (
        <Button size="sm" color="light" onClick={() => onVerKardex(e.articuloId)}>
          Ver kardex del artículo <HiChevronRight className="ms-1 h-4 w-4" />
        </Button>
      )}>
      {e && (
        <>
          <div className="grid grid-cols-3 gap-2">
            <DatoDetalle etiqueta="Existencia">
              {numero(e.existencia)} <span className="text-xs font-normal text-gray-500">{e.unidad}</span>
            </DatoDetalle>
            <DatoDetalle etiqueta="Mínimo">{numero(e.stockMinimo)}</DatoDetalle>
            <DatoDetalle etiqueta="Lotes">{data?.length ?? '—'}</DatoDetalle>
          </div>
          <SeccionDetalle titulo="Lotes con existencia · primero los que vencen antes">
            {isLoading && <Cargando />}
            {error && <ErrorAlert error={error} />}
            {data && data.length === 0 && <Vacio>Este artículo no tiene lotes con existencia.</Vacio>}
            {data && data.length > 0 && (
              <div className="overflow-x-auto rounded-md border border-gray-200">
                <Table>
                  <TableHead>
                    <TableRow>
                      <TableHeadCell>Lote</TableHeadCell>
                      <TableHeadCell>Vence</TableHeadCell>
                      <TableHeadCell className="text-right">Cantidad</TableHeadCell>
                      <TableHeadCell>Ubicación</TableHeadCell>
                    </TableRow>
                  </TableHead>
                  <TableBody className="divide-y">
                    {pag.visibles?.map((l) => (
                      <TableRow key={l.id}>
                        <TableCell className="font-mono text-xs">
                          {l.codigoLote ?? '—'}
                          {l.proveedor && <span className="mt-0.5 block font-sans text-[11px] text-gray-400">{l.proveedor}</span>}
                        </TableCell>
                        <TableCell className="whitespace-nowrap font-mono text-xs">
                          {fechaCorta(l.fechaVencimiento)}
                          {l.diasRestantes != null && (
                            <span className={`mt-0.5 block text-[11px] ${l.diasRestantes < 0 ? 'text-red-700'
                              : l.diasRestantes <= 30 ? 'text-amber-700' : 'text-gray-400'}`}>
                              {l.diasRestantes < 0 ? `vencido hace ${-l.diasRestantes} d` : `en ${l.diasRestantes} d`}
                            </span>
                          )}
                        </TableCell>
                        <TableCell className="text-right font-mono text-xs tabular-nums">{numero(l.cantidadActual)}</TableCell>
                        <TableCell className="text-sm">{l.ubicacion ?? '—'}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            )}
            {pag.total > 10 && <div className="mt-3"><Paginador p={pag} nombre="lotes" /></div>}
          </SeccionDetalle>
        </>
      )}
    </PanelDetalle>
  )
}

const ESTADO_EXISTENCIA = (e?: Existencia) => (!e ? '' : e.existencia <= 0 ? 'Agotado' : e.bajoMinimo ? 'Bajo mínimo' : 'Disponible')

/** Columnas del reporte de existencias: orden y filtro en todas; números a la derecha, en mono. */
const COLUMNAS_EXISTENCIAS: ColDef<Existencia>[] = [
  {
    field: 'codigo', headerName: 'CÓDIGO', width: 170, filter: 'agTextColumnFilter',
    cellClass: CELDA_CODIGO,
  },
  { field: 'nombre', headerName: 'ARTÍCULO', flex: 2, minWidth: 200, filter: 'agTextColumnFilter', cellClass: 'font-medium' },
  {
    field: 'tipo', headerName: 'TIPO', width: 140, filter: 'agTextColumnFilter',
    filterValueGetter: (p) => (p.data?.tipo === 'REACTIVO' ? 'Reactivo' : 'Cristalería'),
    cellClass: 'celda-centrada',
    cellRenderer: (p: ICellRendererParams<Existencia>) => <TipoBadge tipo={p.value} />,
  },
  {
    field: 'existencia', headerName: 'EXISTENCIA', width: 140, type: 'rightAligned', filter: 'agNumberColumnFilter',
    cellClass: CELDA_NUMERO,
    valueFormatter: (p) => `${p.value} ${p.data?.unidad ?? ''}`,
  },
  {
    field: 'stockMinimo', headerName: 'MÍNIMO', width: 120, type: 'rightAligned', filter: 'agNumberColumnFilter',
    cellClass: CELDA_NUMERO,
  },
  {
    colId: 'estado', headerName: 'ESTADO', width: 150, filter: 'agTextColumnFilter',
    valueGetter: (p) => ESTADO_EXISTENCIA(p.data),
    cellClass: 'celda-centrada',
    // Lo que falta primero: Agotado → Bajo mínimo → Disponible.
    comparator: (a: string, b: string) => ORDEN_ESTADO.indexOf(a) - ORDEN_ESTADO.indexOf(b),
    cellRenderer: (p: ICellRendererParams<Existencia>) => (
      <Badge color={p.value === 'Disponible' ? 'success' : p.value === 'Agotado' ? 'failure' : 'warning'} className="w-fit">
        {p.value}
      </Badge>
    ),
  },
]
const ORDEN_ESTADO = ['Agotado', 'Bajo mínimo', 'Disponible']

// ------------------------------------------------------------------ Próximos a vencer
function ProximosVencer() {
  const [dias, setDias] = useState(90)
  const [buscar, setBuscar] = useState('')
  const { data, isLoading, error } = useQuery({
    queryKey: ['rep-vencer', dias],
    queryFn: () => reportesApi.proximosVencer(dias),
  })
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div className="flex items-center gap-2 text-sm text-gray-700">
          <Label htmlFor="dias">Dentro de</Label>
          <TextInput id="dias" sizing="sm" type="number" min={1} className="w-24" value={dias}
            onChange={(e) => setDias(Number(e.target.value) || 1)} />
          días
        </div>
        <BotonExcel url={`/api/reportes/proximos-vencer/excel?dias=${dias}`} archivo='proximos_a_vencer.xlsx' />
      </div>
      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}
      {data && (data.length === 0
        ? <Vacio>Sin lotes por vencer en el rango.</Vacio>
        : (
          <>
            <Buscador valor={buscar} onChange={setBuscar} />
            <TablaDatos<ProximoVencer> rowData={data} columnDefs={COLUMNAS_VENCER} quickFilterText={buscar} />
          </>
        ))}
    </div>
  )
}

/** Columnas de próximos a vencer: por defecto, primero lo que vence antes. */
const COLUMNAS_VENCER: ColDef<ProximoVencer>[] = [
  { field: 'codigo', headerName: 'CÓDIGO', width: 150, filter: 'agTextColumnFilter', cellClass: CELDA_CODIGO },
  { field: 'nombre', headerName: 'ARTÍCULO', flex: 2, minWidth: 200, filter: 'agTextColumnFilter', cellClass: 'font-medium' },
  {
    field: 'codigoLote', headerName: 'LOTE', width: 140, filter: 'agTextColumnFilter', cellClass: 'font-mono text-xs',
    valueFormatter: (p) => p.value ?? '—',
  },
  {
    field: 'fechaVencimiento', headerName: 'VENCE', width: 140, filter: 'agDateColumnFilter', cellClass: 'font-mono text-xs',
    filterValueGetter: (p) => aFecha(p.data?.fechaVencimiento),
    valueFormatter: (p) => fechaCorta(p.value),
  },
  {
    field: 'diasRestantes', headerName: 'DÍAS', width: 110, type: 'rightAligned', filter: 'agNumberColumnFilter',
    sort: 'asc', cellClass: 'ag-right-aligned-cell celda-centrada justify-end',
    cellRenderer: (p: ICellRendererParams<ProximoVencer>) => (
      <Badge color={p.value <= 30 ? 'warning' : 'gray'} className="w-fit font-mono tabular-nums">{p.value}</Badge>
    ),
  },
  {
    field: 'cantidadActual', headerName: 'CANTIDAD', width: 130, type: 'rightAligned', filter: 'agNumberColumnFilter',
    cellClass: CELDA_NUMERO,
  },
  {
    field: 'ubicacion', headerName: 'UBICACIÓN', flex: 1, minWidth: 140, filter: 'agTextColumnFilter',
    valueFormatter: (p) => p.value ?? '—',
  },
]

// ------------------------------------------------------------------ Consumo por laboratorio
function Consumo() {
  const [desde, setDesde] = useState('')
  const [hasta, setHasta] = useState('')
  const [buscar, setBuscar] = useState('')
  const [sel, setSel] = useState<ConsumoLaboratorio | null>(null)
  const { data, isLoading, error } = useQuery({
    queryKey: ['rep-consumo', desde, hasta],
    queryFn: () => reportesApi.consumoLaboratorio(desde || undefined, hasta || undefined),
  })
  const qs = `desde=${desde}&hasta=${hasta}`
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div className="flex items-center gap-2 flex-wrap">
          <Label htmlFor="desde">Desde</Label>
          <TextInput id="desde" sizing="sm" type="date" value={desde} onChange={(e) => setDesde(e.target.value)} />
          <Label htmlFor="hasta">Hasta</Label>
          <TextInput id="hasta" sizing="sm" type="date" value={hasta} onChange={(e) => setHasta(e.target.value)} />
        </div>
        <BotonExcel url={`/api/reportes/consumo-laboratorio/excel?${qs}`} archivo='consumo_laboratorio.xlsx' />
      </div>
      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}
      {data && (data.length === 0
        ? <Vacio>Sin consumo en el período.</Vacio>
        : (
          <>
            <Buscador valor={buscar} onChange={setBuscar} />
            <TablaDatos<ConsumoLaboratorio> rowData={data} columnDefs={COLUMNAS_CONSUMO} quickFilterText={buscar}
              rowClass={FILA_CON_DETALLE} onRowClicked={(e) => e.data && setSel(e.data)} />
          </>
        ))}
      <DetalleConsumo consumo={sel} desde={desde} hasta={hasta} onCerrar={() => setSel(null)} />
    </div>
  )
}

/** Detalle del consumo de un laboratorio: qué artículos se le despacharon y en qué solicitudes. */
function DetalleConsumo({ consumo: c, desde, hasta, onCerrar }: {
  consumo: ConsumoLaboratorio | null
  desde: string
  hasta: string
  onCerrar: () => void
}) {
  const { data, isLoading, error } = useQuery({
    queryKey: ['rep-consumo-detalle', c?.laboratorioId, desde, hasta],
    queryFn: () => reportesApi.consumoLaboratorioDetalle(c!.laboratorioId, desde || undefined, hasta || undefined),
    enabled: !!c,
  })
  const pagArt = usePaginacion(data?.articulos, [c?.laboratorioId])
  const pagDesp = usePaginacion(data?.despachos, [c?.laboratorioId])
  const periodo = desde || hasta
    ? `${desde ? fechaCorta(desde) : 'el inicio'} – ${hasta ? fechaCorta(hasta) : 'hoy'}`
    : 'Últimos 30 días'
  return (
    <PanelDetalle abierto={!!c} onCerrar={onCerrar} rotulo="Consumo por laboratorio" titulo={c?.laboratorio}
      subtitulo={<span className="font-mono text-xs">{periodo}</span>}>
      {c && (
        <>
          <div className="grid grid-cols-3 gap-2">
            <DatoDetalle etiqueta="Despachos">{c.despachos}</DatoDetalle>
            <DatoDetalle etiqueta="Líneas">{c.lineas}</DatoDetalle>
            <DatoDetalle etiqueta="Artículos">{data?.articulos.length ?? '—'}</DatoDetalle>
          </div>
          {isLoading && <Cargando />}
          {error && <ErrorAlert error={error} />}
          {data && (
            <>
              <SeccionDetalle titulo="Artículos despachados · de más a menos">
                <div className="overflow-x-auto rounded-md border border-gray-200">
                  <Table>
                    <TableHead>
                      <TableRow>
                        <TableHeadCell>Artículo</TableHeadCell>
                        <TableHeadCell className="text-right">Cantidad</TableHeadCell>
                        <TableHeadCell className="text-right">Despachos</TableHeadCell>
                      </TableRow>
                    </TableHead>
                    <TableBody className="divide-y">
                      {pagArt.visibles?.map((a) => (
                        <TableRow key={a.articuloId}>
                          <TableCell>
                            <span className="block font-mono text-[11px] font-medium text-primary-700">{a.codigo}</span>
                            <span className="text-sm font-medium text-gray-900">{a.nombre}</span>
                          </TableCell>
                          <TableCell className="whitespace-nowrap text-right font-mono text-xs tabular-nums">
                            {numero(a.cantidad)} {a.unidad}
                          </TableCell>
                          <TableCell className="text-right font-mono text-xs tabular-nums">{a.despachos}</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
                {pagArt.total > 10 && <div className="mt-3"><Paginador p={pagArt} nombre="artículos" /></div>}
              </SeccionDetalle>

              <SeccionDetalle titulo="Despachos · más recientes primero">
                <ul className="divide-y divide-gray-100 rounded-md border border-gray-200">
                  {pagDesp.visibles?.map((d) => (
                    <li key={`${d.solicitudId}-${d.fecha}`}>
                      <Link to={`/solicitudes/${d.tipo === 'REACTIVO' ? 'reactivos' : 'cristaleria'}?ver=${d.solicitudId}`}
                        className="flex items-center gap-3 px-3 py-2.5 hover:bg-gray-50">
                        <span className="w-12 shrink-0 font-mono text-xs font-medium text-primary-700">#{d.solicitudId}</span>
                        <span className="min-w-0 flex-1">
                          <span className="block truncate text-sm font-medium text-gray-900">{d.solicitante}</span>
                          <span className="block truncate text-xs text-gray-500">
                            {d.practica ?? 'Sin práctica'} · {d.lineas} {d.lineas === 1 ? 'línea' : 'líneas'}
                          </span>
                        </span>
                        <span className="shrink-0 font-mono text-[11px] text-gray-400">{fechaCorta(d.fecha)}</span>
                        <HiChevronRight className="h-4 w-4 shrink-0 text-gray-300" aria-hidden />
                      </Link>
                    </li>
                  ))}
                </ul>
                {pagDesp.total > 10 && <div className="mt-3"><Paginador p={pagDesp} nombre="despachos" /></div>}
              </SeccionDetalle>
            </>
          )}
        </>
      )}
    </PanelDetalle>
  )
}

/** Columnas de consumo: por defecto, el laboratorio con más despachos arriba. */
const COLUMNAS_CONSUMO: ColDef<ConsumoLaboratorio>[] = [
  { field: 'laboratorio', headerName: 'LABORATORIO', flex: 2, minWidth: 200, filter: 'agTextColumnFilter', cellClass: 'font-medium' },
  {
    field: 'despachos', headerName: 'DESPACHOS', flex: 1, minWidth: 130, type: 'rightAligned', filter: 'agNumberColumnFilter',
    sort: 'desc', cellClass: CELDA_NUMERO,
  },
  {
    field: 'lineas', headerName: 'LÍNEAS', flex: 1, minWidth: 130, type: 'rightAligned', filter: 'agNumberColumnFilter',
    headerTooltip: 'Artículos despachados (una línea por artículo de cada solicitud)', cellClass: CELDA_NUMERO,
  },
]

// ------------------------------------------------------------------ Kardex
function KardexRep({ inicial = '' }: { inicial?: number | '' }) {
  const articulos = useQuery({ queryKey: ['articulos'], queryFn: () => articulosApi.list() })
  const [articuloId, setArticuloId] = useState<number | ''>(inicial)
  const [buscar, setBuscar] = useState('')
  const { data, isLoading, error } = useQuery({
    queryKey: ['rep-kardex', articuloId],
    queryFn: () => reportesApi.kardex(articuloId as number),
    enabled: articuloId !== '',
  })
  const unidad = articulos.data?.find((a) => a.id === articuloId)?.unidad
  // Memorizadas: si cambiaran en cada render, AG Grid perdería el orden elegido.
  const columnas = useMemo(() => columnasKardex(unidad), [unidad])
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div className="w-full max-w-md">
          <SelectBuscable id="kardex-articulo" value={articuloId} onChange={setArticuloId}
            placeholder="Escribe el código o nombre del artículo…" vacio="Ningún artículo coincide."
            opciones={articulos.data?.map((a) => ({ id: a.id, nombre: `${a.codigo} — ${a.nombre}` })) ?? []} />
        </div>
        {articuloId !== '' && (
          <BotonExcel url={`/api/reportes/kardex/excel?articuloId=${articuloId}`} archivo='kardex.xlsx' />
        )}
      </div>
      {articuloId === '' && <Vacio>Elige un artículo para ver su kardex.</Vacio>}
      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}
      {data && articuloId !== '' && (data.length === 0
        ? <Vacio>Sin movimientos.</Vacio>
        : (
          <>
            <Buscador valor={buscar} onChange={setBuscar} />
            <TablaDatos<Kardex> rowData={data} columnDefs={columnas} quickFilterText={buscar} />
          </>
        ))}
    </div>
  )
}

/** Color de cada tipo de movimiento: lo que entra en verde, lo que sale en ámbar. */
const COLOR_MOVIMIENTO: Record<string, string> = {
  ENTRADA: 'success', SALIDA: 'warning', DEVOLUCION: 'info', AJUSTE: 'gray', BAJA: 'failure', REPOSICION: 'success',
}
const TEXTO_MOVIMIENTO: Record<string, string> = {
  ENTRADA: 'Entrada', SALIDA: 'Salida', DEVOLUCION: 'Devolución', AJUSTE: 'Ajuste', BAJA: 'Baja', REPOSICION: 'Reposición',
}

/** Columnas del kardex, en orden cronológico como viene de la API. */
const columnasKardex = (unidad?: string): ColDef<Kardex>[] => [
  {
    field: 'fecha', headerName: 'FECHA', width: 180, filter: 'agDateColumnFilter', cellClass: 'font-mono text-xs',
    filterValueGetter: (p) => aFecha(p.data?.fecha),
    valueFormatter: (p) => (p.value ? new Date(p.value).toLocaleString('es', { dateStyle: 'medium', timeStyle: 'short' }) : '—'),
  },
  {
    field: 'tipo', headerName: 'MOVIMIENTO', width: 150, filter: 'agTextColumnFilter', cellClass: 'celda-centrada',
    filterValueGetter: (p) => TEXTO_MOVIMIENTO[p.data?.tipo ?? ''] ?? p.data?.tipo,
    cellRenderer: (p: ICellRendererParams<Kardex>) => (
      <Badge color={COLOR_MOVIMIENTO[p.value] ?? 'gray'} className="w-fit">{TEXTO_MOVIMIENTO[p.value] ?? p.value}</Badge>
    ),
  },
  {
    field: 'cantidad', headerName: 'CANTIDAD', width: 130, type: 'rightAligned', filter: 'agNumberColumnFilter',
    cellClass: CELDA_NUMERO, valueFormatter: (p) => `${p.value}${unidad ? ` ${unidad}` : ''}`,
  },
  {
    field: 'codigoLote', headerName: 'LOTE', width: 140, filter: 'agTextColumnFilter', cellClass: 'font-mono text-xs',
    valueFormatter: (p) => p.value ?? '—',
  },
  {
    field: 'motivo', headerName: 'MOTIVO', flex: 1, minWidth: 200, filter: 'agTextColumnFilter', tooltipField: 'motivo',
    valueFormatter: (p) => p.value ?? '—',
  },
]
