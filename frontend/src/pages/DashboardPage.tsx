import { useQuery } from '@tanstack/react-query'
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer,
  CartesianGrid, LineChart, Line, Cell,
} from 'recharts'
import { dashboardApi } from '../api/reportes'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'

const TONES: Record<string, string> = {
  teal: 'text-teal-700', rose: 'text-rose-600', emerald: 'text-emerald-600', amber: 'text-amber-700',
}

function Tile({ label, value, tone = 'teal' }: { label: string; value: number; tone?: string }) {
  return (
    <div className="bg-white rounded-xl border border-slate-200 p-5">
      <div className="text-xs uppercase tracking-wide text-slate-500">{label}</div>
      <div className={`mt-2 text-3xl font-semibold tabular-nums ${TONES[tone]}`}>{value}</div>
    </div>
  )
}

function Card({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="bg-white rounded-xl border border-slate-200 p-5">
      <h2 className="text-sm font-semibold text-slate-700 mb-4">{title}</h2>
      {children}
    </div>
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
      <div>
        <h1 className="text-2xl font-semibold">Hola, {user?.nombre}</h1>
        <p className="text-slate-500 text-sm mt-1">Rol: {user?.rol}</p>
      </div>

      {isLoading && <p className="text-slate-500">Cargando…</p>}
      {error && <p className="text-rose-600">{apiError(error)}</p>}

      {data && (
        <>
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            <Tile label="Artículos activos" value={data.totalArticulos} tone="teal" />
            <Tile label="Bajo stock mínimo" value={data.bajoMinimo} tone={data.bajoMinimo > 0 ? 'rose' : 'emerald'} />
            <Tile label="Próximos a vencer (30 d)" value={data.proximosAVencer} tone={data.proximosAVencer > 0 ? 'amber' : 'emerald'} />
            <Tile label="Solicitudes pendientes" value={data.solicitudesPendientes} tone="amber" />
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
            <Card title="Artículos por categoría">
              <ResponsiveContainer width="100%" height={260}>
                <BarChart data={data.articulosPorCategoria} layout="vertical" margin={{ left: 20 }}>
                  <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#e2e8f0" />
                  <XAxis type="number" allowDecimals={false} tick={{ fontSize: 12, fill: '#64748b' }} />
                  <YAxis type="category" dataKey="etiqueta" width={110} tick={{ fontSize: 12, fill: '#334155' }} />
                  <Tooltip />
                  <Bar dataKey="cantidad" fill="#0f766e" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </Card>

            <Card title="Lotes por vencimiento">
              <ResponsiveContainer width="100%" height={260}>
                <BarChart data={data.vencimientos}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                  <XAxis dataKey="etiqueta" tick={{ fontSize: 12, fill: '#334155' }} />
                  <YAxis allowDecimals={false} tick={{ fontSize: 12, fill: '#64748b' }} />
                  <Tooltip />
                  <Bar dataKey="cantidad" radius={[4, 4, 0, 0]}>
                    {data.vencimientos.map((v) => (
                      <Cell key={v.etiqueta} fill={VENC_COLORS[v.etiqueta] ?? '#0f766e'} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </Card>

            <Card title="Consumo por mes (despachos)">
              <ResponsiveContainer width="100%" height={260}>
                <LineChart data={data.consumoPorMes}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis dataKey="etiqueta" tick={{ fontSize: 12, fill: '#334155' }} />
                  <YAxis allowDecimals={false} tick={{ fontSize: 12, fill: '#64748b' }} />
                  <Tooltip />
                  <Line type="monotone" dataKey="cantidad" stroke="#0f766e" strokeWidth={2} dot={{ r: 4 }} />
                </LineChart>
              </ResponsiveContainer>
            </Card>
          </div>
        </>
      )}
    </div>
  )
}
