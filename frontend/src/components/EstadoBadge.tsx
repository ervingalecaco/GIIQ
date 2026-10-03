import type { EstadoSolicitud } from '../types'

const COLORS: Record<EstadoSolicitud, string> = {
  BORRADOR:  'bg-slate-100 text-slate-600',
  PENDIENTE: 'bg-amber-100 text-amber-800',
  APROBADA:  'bg-sky-100 text-sky-800',
  RECHAZADA: 'bg-rose-100 text-rose-800',
  PREPARADA: 'bg-indigo-100 text-indigo-800',
  ENTREGADA: 'bg-teal-100 text-teal-800',
  DEVUELTA:  'bg-emerald-100 text-emerald-800',
  CERRADA:   'bg-emerald-600 text-white',
}

export function EstadoBadge({ estado }: { estado: EstadoSolicitud }) {
  return (
    <span className={`inline-block rounded-full px-2.5 py-0.5 text-xs font-medium ${COLORS[estado] ?? 'bg-slate-100 text-slate-600'}`}>
      {estado}
    </span>
  )
}
