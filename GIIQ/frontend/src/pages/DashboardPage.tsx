import type { ReactNode } from 'react'
import { Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer,
  CartesianGrid, Cell,
} from 'recharts'
import { Badge } from 'flowbite-react'
import { dashboardApi, reportesApi } from '../api/reportes'
import { inventarioApi } from '../api/catalogos'
import { solicitudesApi } from '../api/solicitudes'
import { useAuth } from '../auth/AuthContext'
import { EstadoBadge } from '../components/EstadoBadge'
import { Cargando, ErrorAlert, PageHeader } from '../components/Feedback'
import type { EstadoSolicitud } from '../types'

/** Tono del indicador: el número y el cuadrito del rótulo comparten color. */
const TONOS = {
  neutro:  { num: 'text-gray-900',    marca: 'bg-gray-400' },
  marca:   { num: 'text-primary-800', marca: 'bg-primary-700' },
  alerta:  { num: 'text-red-700',     marca: 'bg-red-700' },
  aviso:   { num: 'text-amber-700',   marca: 'bg-amber-600' },
  ok:      { num: 'text-emerald-700', marca: 'bg-emerald-600' },
}

function Indicador({ label, value, nota, tono }: {
  label: string; value: number; nota?: string; tono: keyof typeof TONOS
}) {
  return (
    <div className="rounded-lg border border-gray-200 bg-white px-5 py-4">
      <div className="rotulo flex items-center gap-2 text-gray-500">
        <span className={`h-2 w-2 rounded-sm ${TONOS[tono].marca}`} />{label}
      </div>
      <div className={`mt-2 text-[34px] leading-none font-semibold tabular-nums ${TONOS[tono].num}`}>{value}</div>
      {nota && <div className="mt-2 text-[13px] text-gray-500">{nota}</div>}
    </div>
  )
}

function Panel({ title, subtitle, accion, children, className = '' }: {
  title: string; subtitle?: string; accion?: ReactNode; children: ReactNode; className?: string
}) {
  return (
    <section className={`min-w-0 rounded-lg border border-gray-200 bg-white ${className}`}>
      <div className="flex items-center justify-between gap-3 border-b border-gray-100 px-5 py-3.5">
        <div>
          <h2 className="text-base font-semibold text-gray-900">{title}</h2>
          {subtitle && <p className="text-[13px] text-gray-500">{subtitle}</p>}
        </div>
        {accion}
      </div>
      {children}
    </section>
  )
}

/** Azul acero del logo (primary-600) para barras; el mes en curso en primary-700. */
const COLOR_MARCA = '#3474a2'
const COLOR_SUAVE = '#9db4c9'

const VENC_COLORS: Record<string, string> = {
  'Vencido': '#b42318', '≤ 30 días': '#dc6803', '31–90 días': COLOR_MARCA, '> 90 días': COLOR_SUAVE,
}

const EJE = { fontSize: 12, fill: '#5a6878', fontFamily: 'IBM Plex Mono, monospace' }

/** Estados en los que la solicitud todavía espera a alguien. */
const POR_ATENDER: EstadoSolicitud[] = ['PENDIENTE_PROFESOR', 'PENDIENTE', 'APROBADA', 'PREPARADA']

const fechaCorta = (s?: string | null) =>
  s ? new Date(s).toLocaleDateString('es', { day: '2-digit', month: 'short' }) : '—'

const Vacio = ({ children }: { children: ReactNode }) => (
  <p className="px-5 py-6 text-sm text-gray-400">{children}</p>
)

export function DashboardPage() {
  const { user, hasPerm } = useAuth()
  const { data, isLoading, error } = useQuery({
    queryKey: ['dashboard'],
    queryFn: dashboardApi.get,
    enabled: hasPerm('dashboard.ver'),
  })

  // Alertas: artículos bajo mínimo y lotes vencidos o por vencer en 30 días.
  const existencias = useQuery({
    queryKey: ['existencias'],
    queryFn: inventarioApi.existencias,
    enabled: hasPerm('inventario.ver'),
  })
  const vencen = useQuery({
    queryKey: ['proximos-vencer', 30],
    queryFn: () => reportesApi.proximosVencer(30),
    enabled: hasPerm('reporte.ver'),
  })
  const vencidos = useQuery({
    queryKey: ['lotes-vencidos'],
    queryFn: reportesApi.lotesVencidos,
    enabled: hasPerm('reporte.ver'),
  })
  const alertas = [
    ...(vencidos.data ?? []).map((v) => ({
      clave: `v${v.articuloId}-${v.codigoLote}`, codigo: v.codigo, nombre: v.nombre, lote: v.codigoLote,
      motivo: `Vencido ${fechaCorta(v.fechaVencimiento)}`, color: 'failure', detalle: `${v.cantidadActual}`,
    })),
    ...(existencias.data ?? []).filter((e) => e.bajoMinimo).map((e) => ({
      clave: `m${e.articuloId}`, codigo: e.codigo, nombre: e.nombre, lote: null,
      motivo: e.existencia <= 0 ? 'Agotado' : 'Bajo mínimo', color: e.existencia <= 0 ? 'failure' : 'warning',
      detalle: `${e.existencia} / ${e.stockMinimo} ${e.unidad ?? ''}`,
    })),
    ...(vencen.data ?? []).filter((v) => v.diasRestantes >= 0).map((v) => ({
      clave: `p${v.articuloId}-${v.codigoLote}`, codigo: v.codigo, nombre: v.nombre, lote: v.codigoLote,
      motivo: `Vence ${fechaCorta(v.fechaVencimiento)}`, color: 'warning', detalle: `${v.cantidadActual}`,
    })),
  ]

  // Solicitudes que esperan una acción, las de fecha requerida más próxima primero.
  const verSolicitudes = hasPerm('solicitud.ver')
  const solReactivos = useQuery({
    queryKey: ['solicitudes', 'REACTIVO', 'dashboard'],
    queryFn: () => solicitudesApi.list('REACTIVO'),
    enabled: verSolicitudes,
  })
  const solCristaleria = useQuery({
    queryKey: ['solicitudes', 'CRISTALERIA', 'dashboard'],
    queryFn: () => solicitudesApi.list('CRISTALERIA'),
    enabled: verSolicitudes,
  })
  const porAtender = [...(solReactivos.data ?? []), ...(solCristaleria.data ?? [])]
    .filter((s) => POR_ATENDER.includes(s.estado))
    .sort((a, b) => (a.fechaRequerida ?? a.fechaSolicitud).localeCompare(b.fechaRequerida ?? b.fechaSolicitud))

  return (
    <div className="space-y-6">
      <PageHeader title="Panel general"
        subtitle={`${user?.nombre ?? ''} · ${user?.rol ?? ''} — estado del almacén de reactivos y cristalería.`} />

      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}

      {data && (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <Indicador label="Artículos activos" value={data.totalArticulos} tono="neutro"
              nota="Reactivos y cristalería" />
            <Indicador label="Bajo stock mínimo" value={data.bajoMinimo}
              tono={data.bajoMinimo > 0 ? 'alerta' : 'ok'}
              nota={data.bajoMinimo > 0 ? 'Requieren reposición' : 'Todo por encima del mínimo'} />
            <Indicador label="Vencen en 30 días" value={data.proximosAVencer}
              tono={data.proximosAVencer > 0 ? 'aviso' : 'ok'} nota="Lotes con fecha de caducidad" />
            <Indicador label="Solicitudes pendientes" value={data.solicitudesPendientes} tono="marca"
              nota="Esperan aprobación" />
          </div>

          <div className="flex flex-wrap gap-4 items-start">
            {(hasPerm('inventario.ver') || hasPerm('reporte.ver')) && (
              <Panel title="Alertas que requieren acción" className="flex-[3_1_520px]"
                accion={hasPerm('reporte.ver') &&
                  <Link to="/reportes" className="text-sm font-medium text-primary-700 hover:text-primary-900">Ver reportes</Link>}>
                {alertas.length === 0
                  ? <Vacio>Sin alertas: existencias y vencimientos en orden.</Vacio>
                  : (
                    <div className="overflow-x-auto">
                      <table className="w-full min-w-[520px] text-sm">
                        <thead>
                          <tr className="rotulo text-left text-gray-500">
                            <th className="px-5 py-2.5 font-medium">Artículo</th>
                            <th className="px-3 py-2.5 font-medium">Lote</th>
                            <th className="px-3 py-2.5 font-medium">Motivo</th>
                            <th className="px-5 py-2.5 font-medium text-right">Cantidad</th>
                          </tr>
                        </thead>
                        <tbody>
                          {alertas.slice(0, 6).map((a) => (
                            <tr key={a.clave} className="border-t border-gray-100">
                              <td className="px-5 py-2.5">
                                <div className="font-medium text-gray-900">{a.nombre}</div>
                                <div className="font-mono text-xs text-gray-500">{a.codigo}</div>
                              </td>
                              <td className="px-3 py-2.5 font-mono text-xs">{a.lote ?? '—'}</td>
                              <td className="px-3 py-2.5"><Badge color={a.color} className="w-fit">{a.motivo}</Badge></td>
                              <td className="px-5 py-2.5 text-right font-mono text-xs tabular-nums">{a.detalle}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                      {alertas.length > 6 && (
                        <p className="border-t border-gray-100 px-5 py-2.5 text-xs text-gray-500">
                          y {alertas.length - 6} alertas más en Reportes.
                        </p>
                      )}
                    </div>
                  )}
              </Panel>
            )}

            {verSolicitudes && (
              <Panel title="Solicitudes por atender" className="flex-[2_1_340px]">
                {porAtender.length === 0
                  ? <Vacio>No hay solicitudes esperando una acción.</Vacio>
                  : porAtender.slice(0, 5).map((s) => (
                    <Link key={s.id}
                      to={`/solicitudes/${s.tipo === 'REACTIVO' ? 'reactivos' : 'cristaleria'}?ver=${s.id}`}
                      className="flex items-start gap-3 border-t border-gray-100 px-5 py-3 first:border-t-0 hover:bg-primary-50/50">
                      <span className="min-w-12 pt-0.5 font-mono text-xs font-medium text-primary-700">#{s.id}</span>
                      <span className="min-w-0 flex-1">
                        <span className="block truncate text-sm font-medium text-gray-900">
                          {s.practica ?? (s.tipo === 'REACTIVO' ? 'Solicitud de reactivos' : 'Solicitud de cristalería')}
                        </span>
                        <span className="block truncate text-xs text-gray-500">
                          {[s.clase, s.laboratorio, `requerida ${fechaCorta(s.fechaRequerida)}`].filter(Boolean).join(' · ')}
                        </span>
                      </span>
                      <EstadoBadge estado={s.estado} tipo={s.tipo} />
                    </Link>
                  ))}
              </Panel>
            )}
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
            <Panel title="Lotes por vencimiento" subtitle="Reactivos con fecha de caducidad registrada">
              <div className="px-3 py-4">
                <ResponsiveContainer width="100%" height={240}>
                  <BarChart data={data.vencimientos}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e6ebf0" />
                    <XAxis dataKey="etiqueta" tick={EJE} />
                    <YAxis allowDecimals={false} tick={EJE} />
                    <Tooltip />
                    <Bar dataKey="cantidad" radius={[2, 2, 0, 0]} maxBarSize={56}>
                      {data.vencimientos.map((v) => (
                        <Cell key={v.etiqueta} fill={VENC_COLORS[v.etiqueta] ?? COLOR_MARCA} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </Panel>

            <Panel title="Consumo por mes" subtitle="Despachos entregados">
              <div className="px-3 py-4">
                <ResponsiveContainer width="100%" height={240}>
                  <BarChart data={data.consumoPorMes}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e6ebf0" />
                    <XAxis dataKey="etiqueta" tick={EJE} />
                    <YAxis allowDecimals={false} tick={EJE} />
                    <Tooltip />
                    <Bar dataKey="cantidad" radius={[2, 2, 0, 0]} maxBarSize={56}>
                      {data.consumoPorMes.map((c, i) => (
                        <Cell key={c.etiqueta} fill={i === data.consumoPorMes.length - 1 ? '#295e86' : COLOR_SUAVE} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </Panel>

            <Panel title="Artículos por categoría" className="lg:col-span-2">
              <div className="px-3 py-4">
                <ResponsiveContainer width="100%" height={Math.max(200, data.articulosPorCategoria.length * 34)}>
                  <BarChart data={data.articulosPorCategoria} layout="vertical" margin={{ left: 20 }}>
                    <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#e6ebf0" />
                    <XAxis type="number" allowDecimals={false} tick={EJE} />
                    <YAxis type="category" dataKey="etiqueta" width={150}
                      tick={{ fontSize: 12, fill: '#344054', fontFamily: 'IBM Plex Sans, sans-serif' }} />
                    <Tooltip />
                    <Bar dataKey="cantidad" fill={COLOR_MARCA} radius={[0, 2, 2, 0]} barSize={18} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </Panel>
          </div>
        </>
      )}
    </div>
  )
}
