import { Badge } from 'flowbite-react'
import type { EstadoSolicitud } from '../types'

const COLORS: Record<EstadoSolicitud, string> = {
  BORRADOR:  'gray',
  PENDIENTE: 'warning',
  APROBADA:  'info',
  RECHAZADA: 'failure',
  PREPARADA: 'indigo',
  ENTREGADA: 'purple',
  DEVUELTA:  'teal',
  CERRADA:   'success',
}

export function EstadoBadge({ estado }: { estado: EstadoSolicitud }) {
  return <Badge color={COLORS[estado] ?? 'gray'} className="w-fit">{estado}</Badge>
}
