import { useState, type ReactNode } from 'react'
import { useQuery } from '@tanstack/react-query'
import {
  Alert, Badge, Button, Checkbox, Label, Select, TabItem, Table, TableBody, TableCell, TableHead,
  TableHeadCell, TableRow, Tabs, TextInput,
} from 'flowbite-react'
import { HiDownload, HiInformationCircle } from 'react-icons/hi'
import { articulosApi } from '../api/catalogos'
import { descargarArchivo, reportesApi } from '../api/reportes'
import { Cargando, ErrorAlert, PageHeader } from '../components/Feedback'

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

function Tabla({ headers, children }: { headers: string[]; children: ReactNode }) {
  return (
    <Table hoverable>
      <TableHead>
        <TableRow>{headers.map((h) => <TableHeadCell key={h}>{h}</TableHeadCell>)}</TableRow>
      </TableHead>
      <TableBody className="divide-y">{children}</TableBody>
    </Table>
  )
}

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
        <Tabla headers={['Código', 'Artículo', 'Tipo', 'Existencia', 'Mínimo', 'Estado']}>
          {data.map((e) => (
            <TableRow key={e.articuloId} className="bg-white">
              <TableCell className="font-mono text-xs">{e.codigo}</TableCell>
              <TableCell className="text-gray-900">{e.nombre}</TableCell>
              <TableCell>{e.tipo}</TableCell>
              <TableCell className="tabular-nums">{e.existencia} {e.unidad}</TableCell>
              <TableCell className="tabular-nums">{e.stockMinimo}</TableCell>
              <TableCell>
                {e.bajoMinimo
                  ? <Badge color="failure" className="w-fit">Bajo mínimo</Badge>
                  : <Badge color="success" className="w-fit">OK</Badge>}
              </TableCell>
            </TableRow>
          ))}
        </Tabla>
      )}
    </div>
  )
}

// ------------------------------------------------------------------ Próximos a vencer
function ProximosVencer() {
  const [dias, setDias] = useState(90)
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
          <Tabla headers={['Código', 'Artículo', 'Lote', 'Vence', 'Días', 'Cantidad', 'Ubicación']}>
            {data.map((d, i) => (
              <TableRow key={i} className="bg-white">
                <TableCell className="font-mono text-xs">{d.codigo}</TableCell>
                <TableCell className="text-gray-900">{d.nombre}</TableCell>
                <TableCell>{d.codigoLote ?? '—'}</TableCell>
                <TableCell>{d.fechaVencimiento ?? '—'}</TableCell>
                <TableCell>
                  <Badge color={d.diasRestantes <= 30 ? 'warning' : 'gray'} className="w-fit tabular-nums">
                    {d.diasRestantes}
                  </Badge>
                </TableCell>
                <TableCell className="tabular-nums">{d.cantidadActual}</TableCell>
                <TableCell>{d.ubicacion ?? '—'}</TableCell>
              </TableRow>
            ))}
          </Tabla>
        ))}
    </div>
  )
}

// ------------------------------------------------------------------ Consumo por laboratorio
function Consumo() {
  const [desde, setDesde] = useState('')
  const [hasta, setHasta] = useState('')
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
          <Tabla headers={['Laboratorio', 'Despachos', 'Líneas']}>
            {data.map((c, i) => (
              <TableRow key={i} className="bg-white">
                <TableCell className="text-gray-900">{c.laboratorio}</TableCell>
                <TableCell className="tabular-nums">{c.despachos}</TableCell>
                <TableCell className="tabular-nums">{c.lineas}</TableCell>
              </TableRow>
            ))}
          </Tabla>
        ))}
    </div>
  )
}

// ------------------------------------------------------------------ Kardex
function KardexRep() {
  const articulos = useQuery({ queryKey: ['articulos'], queryFn: () => articulosApi.list() })
  const [articuloId, setArticuloId] = useState<number | ''>('')
  const { data, isLoading, error } = useQuery({
    queryKey: ['rep-kardex', articuloId],
    queryFn: () => reportesApi.kardex(articuloId as number),
    enabled: articuloId !== '',
  })
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <Select sizing="sm" aria-label="Artículo" value={articuloId}
          onChange={(e) => setArticuloId(e.target.value ? Number(e.target.value) : '')}>
          <option value="">Selecciona un artículo…</option>
          {articulos.data?.map((a) => <option key={a.id} value={a.id}>{a.codigo} — {a.nombre}</option>)}
        </Select>
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
          <Tabla headers={['Fecha', 'Tipo', 'Cantidad', 'Lote', 'Motivo']}>
            {data.map((k, i) => (
              <TableRow key={i} className="bg-white">
                <TableCell>{new Date(k.fecha).toLocaleString()}</TableCell>
                <TableCell><Badge color="indigo" className="w-fit">{k.tipo}</Badge></TableCell>
                <TableCell className="tabular-nums">{k.cantidad}</TableCell>
                <TableCell>{k.codigoLote ?? '—'}</TableCell>
                <TableCell>{k.motivo ?? '—'}</TableCell>
              </TableRow>
            ))}
          </Tabla>
        ))}
    </div>
  )
}
