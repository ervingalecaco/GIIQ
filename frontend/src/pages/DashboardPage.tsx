import type { ComponentProps, FC, ReactNode } from 'react'
import { useQuery } from '@tanstack/react-query'
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer,
  CartesianGrid, LineChart, Line, Cell,
} from 'recharts'
import { Card } from 'flowbite-react'
import { HiBeaker, HiClipboardList, HiClock, HiExclamation } from 'react-icons/hi'
import { dashboardApi } from '../api/reportes'
import { useAuth } from '../auth/AuthContext'
import { Cargando, ErrorAlert, PageHeader } from '../components/Feedback'

const TONES: Record<string, { text: string; bg: string }> = {
  indigo:  { text: 'text-indigo-700',  bg: 'bg-indigo-100 text-indigo-600' },
  rose:    { text: 'text-rose-600',    bg: 'bg-rose-100 text-rose-600' },
  emerald: { text: 'text-emerald-600', bg: 'bg-emerald-100 text-emerald-600' },
  amber:   { text: 'text-amber-700',   bg: 'bg-amber-100 text-amber-600' },
}

function Tile({ label, value, tone, icon: Icon }: {
  label: string; value: number; tone: keyof typeof TONES; icon: FC<ComponentProps<'svg'>>
}) {
  return (
    <Card>
      <div className="flex items-center justify-between gap-3">
        <div>
          <div className="text-xs font-medium uppercase tracking-wide text-gray-500">{label}</div>
          <div className={`mt-1 text-3xl font-bold tabular-nums ${TONES[tone].text}`}>{value}</div>
        </div>
        <span className={`inline-flex h-11 w-11 shrink-0 items-center justify-center rounded-lg ${TONES[tone].bg}`}>
          <Icon className="h-6 w-6" />
        </span>
      </div>
    </Card>
  )
}

function ChartCard({ title, children }: { title: string; children: ReactNode }) {
  return (
    <Card>
      <h2 className="text-base font-semibold text-gray-900">{title}</h2>
      {children}
    </Card>
  )
}

const VENC_COLORS: Record<string, string> = {
  'Vencido': '#e11d48', '≤ 30 días': '#f59e0b', '31–90 días': '#0ea5e9', '> 90 días': '#10b981',
}

export function DashboardPage() {
  const { user, hasPerm } = useAuth()
  const { data, isLoading, error } = useQuery({
    queryKey: ['dashboard'],
    queryFn: dashboardApi.get,
    enabled: hasPerm('dashboard.ver'),
  })

  return (
    <div className="space-y-6">
      <PageHeader title={`Hola, ${user?.nombre ?? ''}`} subtitle={`Rol: ${user?.rol ?? ''}`} />

      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}

      {data && (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <Tile label="Artículos activos" value={data.totalArticulos} tone="indigo" icon={HiBeaker} />
            <Tile label="Bajo stock mínimo" value={data.bajoMinimo}
              tone={data.bajoMinimo > 0 ? 'rose' : 'emerald'} icon={HiExclamation} />
            <Tile label="Próximos a vencer (30 d)" value={data.proximosAVencer}
              tone={data.proximosAVencer > 0 ? 'amber' : 'emerald'} icon={HiClock} />
            <Tile label="Solicitudes pendientes" value={data.solicitudesPendientes} tone="amber" icon={HiClipboardList} />
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
            <ChartCard title="Artículos por categoría">
              <ResponsiveContainer width="100%" height={260}>
                <BarChart data={data.articulosPorCategoria} layout="vertical" margin={{ left: 20 }}>
                  <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#e5e7eb" />
                  <XAxis type="number" allowDecimals={false} tick={{ fontSize: 12, fill: '#6b7280' }} />
                  <YAxis type="category" dataKey="etiqueta" width={110} tick={{ fontSize: 12, fill: '#374151' }} />
                  <Tooltip />
                  <Bar dataKey="cantidad" fill="#4f46e5" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </ChartCard>

            <ChartCard title="Lotes por vencimiento">
              <ResponsiveContainer width="100%" height={260}>
                <BarChart data={data.vencimientos}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e5e7eb" />
                  <XAxis dataKey="etiqueta" tick={{ fontSize: 12, fill: '#374151' }} />
                  <YAxis allowDecimals={false} tick={{ fontSize: 12, fill: '#6b7280' }} />
                  <Tooltip />
                  <Bar dataKey="cantidad" radius={[4, 4, 0, 0]}>
                    {data.vencimientos.map((v) => (
                      <Cell key={v.etiqueta} fill={VENC_COLORS[v.etiqueta] ?? '#4f46e5'} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </ChartCard>

            <ChartCard title="Consumo por mes (despachos)">
              <ResponsiveContainer width="100%" height={260}>
                <LineChart data={data.consumoPorMes}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                  <XAxis dataKey="etiqueta" tick={{ fontSize: 12, fill: '#374151' }} />
                  <YAxis allowDecimals={false} tick={{ fontSize: 12, fill: '#6b7280' }} />
                  <Tooltip />
                  <Line type="monotone" dataKey="cantidad" stroke="#4f46e5" strokeWidth={2} dot={{ r: 4 }} />
                </LineChart>
              </ResponsiveContainer>
            </ChartCard>
          </div>
        </>
      )}
    </div>
  )
}
