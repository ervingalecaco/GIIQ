import { useMemo, useState, type ReactNode } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Alert, Badge, Button, Checkbox, Label, TabItem, Tabs, TextInput } from 'flowbite-react'
import { HiDownload, HiInformationCircle, HiSearch } from 'react-icons/hi'
import type { ColDef, ICellRendererParams } from 'ag-grid-community'
import { articulosApi } from '../api/catalogos'
import { descargarArchivo, reportesApi } from '../api/reportes'
import { Cargando, ErrorAlert, PageHeader, TipoBadge } from '../components/Feedback'
import { SelectBuscable } from '../components/SelectBuscable'
import { TablaDatos } from '../components/TablaDatos'
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
  return (
    <div className="space-y-5">
      <PageHeader title="Reportes" />
      <Tabs variant="underline" onActiveTabChange={(i) => setRep(REPORTES[i].key)}>
        {REPORTES.map((r) => (
          <TabItem key={r.key} title={r.label} active={rep === r.key}>
            {rep === r.key && r.key === 'existencias' && <Existencias />}
            {rep === r.key && r.key === 'vencer' && <ProximosVencer />}
            {rep === r.key && r.key === 'consumo' && <Consumo />}
            {rep === r.key && r.key === 'kardex' && <KardexRep />}
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

function BotonExcel({ onClick }: { onClick: () => void }) {
  return (
    <Button size="sm" color="green" onClick={onClick}>
      <HiDownload className="me-1.5 h-4 w-4" /> Exportar a Excel
    </Button>
  )
}

function Vacio({ children }: { children: ReactNode }) {
  return <Alert color="gray" icon={HiInformationCircle}>{children}</Alert>
}

// ------------------------------------------------------------------ Existencias
function Existencias() {
  const [bajo, setBajo] = useState(false)
  const [buscar, setBuscar] = useState('')
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
        <BotonExcel onClick={() => descargarArchivo(`/api/reportes/existencias/excel?bajoMinimo=${bajo}`, 'existencias.xlsx')} />
      </div>
      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}
      {data && (
        <>
          <Buscador valor={buscar} onChange={setBuscar} />
          <TablaDatos<Existencia> rowData={data} columnDefs={COLUMNAS_EXISTENCIAS} quickFilterText={buscar}
            getRowId={(p) => String(p.data.articuloId)} />
        </>
      )}
    </div>
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
        <BotonExcel onClick={() => descargarArchivo(`/api/reportes/proximos-vencer/excel?dias=${dias}`, 'proximos_a_vencer.xlsx')} />
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
        <BotonExcel onClick={() => descargarArchivo(`/api/reportes/consumo-laboratorio/excel?${qs}`, 'consumo_laboratorio.xlsx')} />
      </div>
      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}
      {data && (data.length === 0
        ? <Vacio>Sin consumo en el período.</Vacio>
        : (
          <>
            <Buscador valor={buscar} onChange={setBuscar} />
            <TablaDatos<ConsumoLaboratorio> rowData={data} columnDefs={COLUMNAS_CONSUMO} quickFilterText={buscar} />
          </>
        ))}
    </div>
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
function KardexRep() {
  const articulos = useQuery({ queryKey: ['articulos'], queryFn: () => articulosApi.list() })
  const [articuloId, setArticuloId] = useState<number | ''>('')
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
          <BotonExcel onClick={() => descargarArchivo(`/api/reportes/kardex/excel?articuloId=${articuloId}`, 'kardex.xlsx')} />
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
  ENTRADA: 'success', SALIDA: 'warning', DEVOLUCION: 'info', AJUSTE: 'gray',
}
const TEXTO_MOVIMIENTO: Record<string, string> = {
  ENTRADA: 'Entrada', SALIDA: 'Salida', DEVOLUCION: 'Devolución', AJUSTE: 'Ajuste',
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
