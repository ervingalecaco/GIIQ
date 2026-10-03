import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { solicitudesApi } from '../api/solicitudes'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'
import { EstadoBadge } from '../components/EstadoBadge'
import type { EstadoSolicitud, SolicitudHeader } from '../types'

const ESTADOS: EstadoSolicitud[] = [
  'PENDIENTE', 'APROBADA', 'PREPARADA', 'ENTREGADA', 'CERRADA', 'RECHAZADA',
]

export function SolicitudesPage() {
  const { hasPerm } = useAuth()
  const qc = useQueryClient()
  const [estado, setEstado] = useState<string>('')
  const [detalleId, setDetalleId] = useState<number | null>(null)

  const { data, isLoading, error } = useQuery({
    queryKey: ['solicitudes', estado || 'ALL'],
    queryFn: () => solicitudesApi.list(estado || undefined),
  })

  const run = useMutation({
    mutationFn: (fn: () => Promise<unknown>) => fn(),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['solicitudes'] }),
    onError: (e) => alert(apiError(e)),
  })

  function acciones(s: SolicitudHeader) {
    const btns: { label: string; fn: () => Promise<unknown>; cls: string }[] = []
    if (s.estado === 'PENDIENTE' && hasPerm('solicitud.aprobar')) {
      btns.push({ label: 'Aprobar', cls: 'bg-sky-600', fn: () => solicitudesApi.aprobar(s.id) })
      btns.push({
        label: 'Rechazar', cls: 'bg-rose-600',
        fn: () => {
          const motivo = window.prompt('Motivo del rechazo:')
          if (!motivo) return Promise.resolve()
          return solicitudesApi.rechazar(s.id, motivo)
        },
      })
    }
    if (s.estado === 'APROBADA' && hasPerm('solicitud.preparar'))
      btns.push({ label: 'Preparar', cls: 'bg-indigo-600', fn: () => solicitudesApi.preparar(s.id) })
    if (s.estado === 'PREPARADA' && hasPerm('solicitud.entregar'))
      btns.push({ label: 'Entregar', cls: 'bg-teal-600', fn: () => solicitudesApi.entregar(s.id) })
    if (s.estado === 'ENTREGADA' && hasPerm('solicitud.devolver'))
      btns.push({ label: 'Devolver', cls: 'bg-emerald-600', fn: () => solicitudesApi.devolver(s.id) })
    return btns
  }

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <h1 className="text-2xl font-semibold">Solicitudes</h1>
        <div className="flex items-center gap-3">
          <select
            value={estado} onChange={(e) => setEstado(e.target.value)}
            className="rounded-md border border-slate-300 px-3 py-1.5 text-sm bg-white"
          >
            <option value="">Todos los estados</option>
            {ESTADOS.map((e) => <option key={e} value={e}>{e}</option>)}
          </select>
          {hasPerm('solicitud.crear') && (
            <Link to="/solicitudes/nueva" className="rounded-md bg-teal-700 text-white px-4 py-1.5 text-sm font-medium hover:bg-teal-800">
              Nueva solicitud
            </Link>
          )}
        </div>
      </div>

      {isLoading && <p className="text-slate-500">Cargando…</p>}
      {error && <p className="text-rose-600">{apiError(error)}</p>}

      {data && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-left">
              <tr>
                <th className="px-4 py-2.5 font-medium">#</th>
                <th className="px-4 py-2.5 font-medium">Estado</th>
                <th className="px-4 py-2.5 font-medium">Profesor</th>
                <th className="px-4 py-2.5 font-medium">Laboratorio</th>
                <th className="px-4 py-2.5 font-medium">Fecha</th>
                <th className="px-4 py-2.5 font-medium text-right">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {data.length === 0 && (
                <tr><td colSpan={6} className="px-4 py-6 text-center text-slate-400">Sin solicitudes.</td></tr>
              )}
              {data.map((s) => (
                <tr key={s.id} className="hover:bg-slate-50">
                  <td className="px-4 py-2.5">
                    <button className="text-teal-700 hover:underline font-medium"
                      onClick={() => setDetalleId(detalleId === s.id ? null : s.id)}>
                      {s.id}
                    </button>
                  </td>
                  <td className="px-4 py-2.5"><EstadoBadge estado={s.estado} /></td>
                  <td className="px-4 py-2.5">{s.profesor}</td>
                  <td className="px-4 py-2.5">{s.laboratorio}</td>
                  <td className="px-4 py-2.5 text-slate-500">{new Date(s.fechaSolicitud).toLocaleDateString()}</td>
                  <td className="px-4 py-2.5">
                    <div className="flex gap-2 justify-end">
                      {acciones(s).map((b) => (
                        <button key={b.label} disabled={run.isPending}
                          onClick={() => run.mutate(b.fn)}
                          className={`${b.cls} text-white rounded-md px-3 py-1 text-xs font-medium hover:opacity-90 disabled:opacity-50`}>
                          {b.label}
                        </button>
                      ))}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {detalleId && <Detalle id={detalleId} onClose={() => setDetalleId(null)} />}
    </div>
  )
}

function Detalle({ id, onClose }: { id: number; onClose: () => void }) {
  const { data, isLoading } = useQuery({
    queryKey: ['solicitud', id],
    queryFn: () => solicitudesApi.get(id),
  })

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-5">
      <div className="flex items-center justify-between mb-3">
        <h2 className="font-semibold">Detalle de la solicitud #{id}</h2>
        <button onClick={onClose} className="text-sm text-slate-500 hover:text-slate-700">Cerrar</button>
      </div>
      {isLoading && <p className="text-slate-500">Cargando…</p>}
      {data && (
        <>
          {data.cabecera.motivoRechazo && (
            <p className="text-sm text-rose-600 mb-2">Rechazo: {data.cabecera.motivoRechazo}</p>
          )}
          {data.cabecera.observaciones && (
            <p className="text-sm text-slate-500 mb-3">Obs: {data.cabecera.observaciones}</p>
          )}
          <table className="w-full text-sm">
            <thead className="text-slate-500 text-left">
              <tr>
                <th className="py-1.5 font-medium">Artículo</th>
                <th className="py-1.5 font-medium">Tipo</th>
                <th className="py-1.5 font-medium text-right">Solicitada</th>
                <th className="py-1.5 font-medium text-right">Preparada</th>
                <th className="py-1.5 font-medium text-right">Devuelta</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {data.lineas.map((l) => (
                <tr key={l.id}>
                  <td className="py-1.5">{l.articulo}</td>
                  <td className="py-1.5 text-slate-500">{l.tipo}</td>
                  <td className="py-1.5 text-right tabular-nums">{l.cantSolicitada} {l.unidad}</td>
                  <td className="py-1.5 text-right tabular-nums">{l.cantPreparada}</td>
                  <td className="py-1.5 text-right tabular-nums">{l.cantDevuelta}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </>
      )}
    </div>
  )
}
