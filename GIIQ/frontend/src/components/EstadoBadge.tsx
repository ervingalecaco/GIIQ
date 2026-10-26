import { Badge } from 'flowbite-react'
import type { EstadoSolicitud, TipoArticulo } from '../types'

const COLORS: Record<EstadoSolicitud, string> = {
  BORRADOR:           'gray',
  PENDIENTE_PROFESOR: 'pink',
  PENDIENTE:          'warning',
  APROBADA:           'info',
  RECHAZADA:          'failure',
  PREPARADA:          'blue',
  ENTREGADA:          'purple',
  DEVUELTA:           'teal',
  CERRADA:            'success',
}

/** Texto a mostrar; PENDIENTE espera al Supervisor y PENDIENTE_PROFESOR al profesor. */
export const ESTADO_LABEL: Partial<Record<EstadoSolicitud, string>> = {
  PENDIENTE_PROFESOR: 'PENDIENTE PROFESOR',
}

/**
 * Nombre visible del estado según el tipo. La cristalería se cierra cuando vuelve a bodega,
 * así que su CERRADA se muestra como DEVUELTA (en la base sigue siendo CERRADA).
 */
export function nombreEstado(estado: EstadoSolicitud, tipo?: TipoArticulo): string {
  if (estado === 'CERRADA' && tipo === 'CRISTALERIA') return 'DEVUELTA'
  return ESTADO_LABEL[estado] ?? estado
}

export function EstadoBadge({ estado, tipo }: { estado: EstadoSolicitud; tipo?: TipoArticulo }) {
  return (
    <Badge color={COLORS[estado] ?? 'gray'} className="w-fit whitespace-nowrap font-mono text-[11px] font-medium tracking-wide">
      {nombreEstado(estado, tipo)}
    </Badge>
  )
}
