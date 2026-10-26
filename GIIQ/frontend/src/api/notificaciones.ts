import { api } from './client'

export interface Notificacion {
  id: number
  tipo: string
  titulo: string
  mensaje: string
  /** Ruta de la app a la que lleva (p. ej. /solicitudes/reactivos?ver=12). */
  enlace?: string | null
  solicitudId?: number | null
  leida: boolean
  creadaEn: string
}

export const notificacionesApi = {
  list: (opciones: { soloNoLeidas?: boolean; limite?: number } = {}) =>
    api.get<{ noLeidas: number; items: Notificacion[] }>('/api/notificaciones', { params: opciones }).then((r) => r.data),
  noLeidas: () => api.get<{ noLeidas: number }>('/api/notificaciones/no-leidas').then((r) => r.data.noLeidas),
  marcarLeida: (id: number) => api.post(`/api/notificaciones/${id}/leida`).then((r) => r.data),
  marcarTodas: () => api.post('/api/notificaciones/leidas').then((r) => r.data),
}

/** "hace 5 min", "hace 2 h", "ayer", o la fecha si es más antigua. */
export function haceCuanto(fecha: string) {
  const min = Math.round((Date.now() - new Date(fecha).getTime()) / 60000)
  if (min < 1) return 'ahora'
  if (min < 60) return `hace ${min} min`
  const h = Math.round(min / 60)
  if (h < 24) return `hace ${h} h`
  if (h < 48) return 'ayer'
  return new Date(fecha).toLocaleDateString('es', { day: '2-digit', month: 'short', year: 'numeric' })
}
