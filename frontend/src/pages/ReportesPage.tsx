import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { articulosApi } from '../api/catalogos'
import { descargarArchivo, reportesApi } from '../api/reportes'
import { apiError } from '../api/client'

const REPORTES = [
  { key: 'existencias', label: 'Existencias' },
  { key: 'vencer', label: 'Próximos a vencer' },
  { key: 'consumo', label: 'Consumo por laboratorio' },
  { key: 'kardex', label: 'Kardex por artículo' },
] as const
type RepKey = typeof REPORTES[number]['key']

const btnExcel = 'rounded-md bg-emerald-600 text-white px-4 py-1.5 text-sm font-medium hover:bg-emerald-700'
const input = 'rounded-md border border-slate-300 px-3 py-1.5 text-sm bg-white'
const th = 'px-4 py-2.5 font-medium'

export function ReportesPage() {
  const [rep, setRep] = useState<RepKey>('existencias')
  return (
    <div className="space-y-5">
      <h1 className="text-2xl font-semibold">Reportes</h1>
      <div className="flex flex-wrap gap-1 border-b border-slate-200">
        {REPORTES.map((r) => (
          <button key={r.key} onClick={() => setRep(r.key)}
            className={`px-4 py-2 text-sm font-medium -mb-px border-b-2 ${
              rep === r.key ? 'border-teal-600 text-teal-700' : 'border-transparent text-slate-500 hover:text-slate-700'
            }`}>
            {r.label}
          </button>
        ))}
      </div>

      {rep === 'existencias' && <Existencias />}
      {rep === 'vencer' && <ProximosVencer />}
      {rep === 'consumo' && <Consumo />}
      {rep === 'kardex' && <KardexRep />}
    </div>
  )
}

function Tabla({ headers, children }: { headers: string[]; children: React.ReactNode }) {
  return (
    <div className="bg-white rounded-xl border border-slate-200 overflow-x-auto">
      <table className="w-full text-sm">
        <thead className="bg-slate-50 text-slate-500 text-left">
          <tr>{headers.map((h) => <th key={h} className={th}>{h}</th>)}</tr>
        </thead>
        <tbody className="divide-y divide-slate-100">{children}</tbody>
      </table>
    </div>
  )
}

// ------------------------------------------------------------------ Existencias
function Existencias() {
  const [bajo, setBajo] = useState(false)
  const { data, isLoading, error } = useQuery({
    queryKey: ['rep-existencias', bajo],
    queryFn: () => reportesApi.existencias(bajo),
  })
  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <label className="flex items-center gap-2 text-sm">
          <input type="checkbox" checked={bajo} onChange={(e) => setBajo(e.target.checked)}
            className="rounded border-slate-300 text-teal-600" />
          Solo bajo stock mínimo
        </label>
        <button className={btnExcel}
          onClick={() => descargarArchivo(`/api/reportes/existencias/excel?bajoMinimo=${bajo}`, 'existencias.xlsx')}>
          Exportar a Excel
        </button>
      </div>
      {isLoading && <p className="text-slate-500">Cargando…</p>}
      {error && <p className="text-rose-600">{apiError(error)}</p>}
      {data && (
        <Tabla headers={['Código', 'Artículo', 'Tipo', 'Existencia', 'Mínimo', 'Estado']}>
          {data.map((e) => (
            <tr key={e.articuloId} className="hover:bg-slate-50">
              <td className="px-4 py-2.5 font-mono text-xs">{e.codigo}</td>
              <td className="px-4 py-2.5">{e.nombre}</td>
              <td className="px-4 py-2.5 text-slate-500">{e.tipo}</td>
              <td className="px-4 py-2.5 tabular-nums">{e.existencia} {e.unidad}</td>
              <td className="px-4 py-2.5 tabular-nums text-slate-500">{e.stockMinimo}</td>
              <td className="px-4 py-2.5">
                {e.bajoMinimo ? <span className="text-xs text-rose-600">Bajo mínimo</span>
                  : <span className="text-xs text-emerald-600">OK</span>}
              </td>
            </tr>
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
    <div className="space-y-3">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <label className="flex items-center gap-2 text-sm">
          Dentro de
          <input type="number" min={1} value={dias} onChange={(e) => setDias(Number(e.target.value) || 1)}
            className={`${input} w-24`} /> días
        </label>
        <button className={btnExcel}
          onClick={() => descargarArchivo(`/api/reportes/proximos-vencer/excel?dias=${dias}`, 'proximos_a_vencer.xlsx')}>
          Exportar a Excel
        </button>
      </div>
      {isLoading && <p className="text-slate-500">Cargando…</p>}
      {error && <p className="text-rose-600">{apiError(error)}</p>}
      {data && (data.length === 0
        ? <p className="text-slate-400 text-sm">Sin lotes por vencer en el rango.</p>
        : (
          <Tabla headers={['Código', 'Artículo', 'Lote', 'Vence', 'Días', 'Cantidad', 'Ubicación']}>
            {data.map((d, i) => (
              <tr key={i} className="hover:bg-slate-50">
                <td className="px-4 py-2.5 font-mono text-xs">{d.codigo}</td>
                <td className="px-4 py-2.5">{d.nombre}</td>
                <td className="px-4 py-2.5">{d.codigoLote ?? '—'}</td>
                <td className="px-4 py-2.5">{d.fechaVencimiento ?? '—'}</td>
                <td className={`px-4 py-2.5 tabular-nums ${d.diasRestantes <= 30 ? 'text-amber-700 font-medium' : ''}`}>{d.diasRestantes}</td>
                <td className="px-4 py-2.5 tabular-nums">{d.cantidadActual}</td>
                <td className="px-4 py-2.5 text-slate-500">{d.ubicacion ?? '—'}</td>
              </tr>
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
    <div className="space-y-3">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div className="flex items-center gap-2 text-sm">
          <span>Desde</span><input type="date" value={desde} onChange={(e) => setDesde(e.target.value)} className={input} />
          <span>Hasta</span><input type="date" value={hasta} onChange={(e) => setHasta(e.target.value)} className={input} />
        </div>
        <button className={btnExcel}
          onClick={() => descargarArchivo(`/api/reportes/consumo-laboratorio/excel?${qs}`, 'consumo_laboratorio.xlsx')}>
          Exportar a Excel
        </button>
      </div>
      {isLoading && <p className="text-slate-500">Cargando…</p>}
      {error && <p className="text-rose-600">{apiError(error)}</p>}
      {data && (data.length === 0
        ? <p className="text-slate-400 text-sm">Sin consumo en el período.</p>
        : (
          <Tabla headers={['Laboratorio', 'Despachos', 'Líneas']}>
            {data.map((c, i) => (
              <tr key={i} className="hover:bg-slate-50">
                <td className="px-4 py-2.5">{c.laboratorio}</td>
                <td className="px-4 py-2.5 tabular-nums">{c.despachos}</td>
                <td className="px-4 py-2.5 tabular-nums">{c.lineas}</td>
              </tr>
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
    <div className="space-y-3">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <select value={articuloId} onChange={(e) => setArticuloId(e.target.value ? Number(e.target.value) : '')} className={input}>
          <option value="">Selecciona un artículo…</option>
          {articulos.data?.map((a) => <option key={a.id} value={a.id}>{a.codigo} — {a.nombre}</option>)}
        </select>
        {articuloId !== '' && (
          <button className={btnExcel}
            onClick={() => descargarArchivo(`/api/reportes/kardex/excel?articuloId=${articuloId}`, 'kardex.xlsx')}>
            Exportar a Excel
          </button>
        )}
      </div>
      {articuloId === '' && <p className="text-slate-400 text-sm">Elige un artículo para ver su kardex.</p>}
      {isLoading && <p className="text-slate-500">Cargando…</p>}
      {error && <p className="text-rose-600">{apiError(error)}</p>}
      {data && articuloId !== '' && (data.length === 0
        ? <p className="text-slate-400 text-sm">Sin movimientos.</p>
        : (
          <Tabla headers={['Fecha', 'Tipo', 'Cantidad', 'Lote', 'Motivo']}>
            {data.map((k, i) => (
              <tr key={i} className="hover:bg-slate-50">
                <td className="px-4 py-2.5 text-slate-500">{new Date(k.fecha).toLocaleString()}</td>
                <td className="px-4 py-2.5">{k.tipo}</td>
                <td className="px-4 py-2.5 tabular-nums">{k.cantidad}</td>
                <td className="px-4 py-2.5">{k.codigoLote ?? '—'}</td>
                <td className="px-4 py-2.5 text-slate-500">{k.motivo ?? '—'}</td>
              </tr>
            ))}
          </Tabla>
        ))}
    </div>
  )
}
