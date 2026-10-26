import { api } from './client'
import type { CausaBaja, SolicitudDetalle, SolicitudHeader, TipoArticulo } from '../types'

export interface CrearSolicitudPayload {
  /** Todas las líneas deben ser de este tipo. */
  tipo: TipoArticulo
  /** Práctica de la solicitud (el laboratorio sale de ella). */
  practicaId: number
  /** Solo para estudiantes: su profesor responsable. */
  profesorId?: number | null
  fechaRequerida?: string | null
  observaciones?: string | null
  lineas: { articuloId: number; unidadId: number; cantidad: number }[]
}

export interface PiezaQuebrada {
  articuloId: number
  cantidad: number
  /** Estudiante responsable; sin él, la baja no genera cargo. */
  estudianteId?: number | null
  causa: CausaBaja
  observacion?: string | null
}

export const solicitudesApi = {
  /** desde / hasta: yyyy-mm-dd (hasta incluye todo ese día); sin ellos, todas las fechas. */
  list: (tipo: TipoArticulo, filtros: { estado?: string; desde?: string; hasta?: string } = {}) =>
    api.get<SolicitudHeader[]>('/api/solicitudes', { params: { tipo, ...filtros } }).then((r) => r.data),

  get: (id: number) =>
    api.get<SolicitudDetalle>(`/api/solicitudes/${id}`).then((r) => r.data),

  crear: (payload: CrearSolicitudPayload) =>
    api.post<{ solicitudId: number; lineas: number }>('/api/solicitudes', payload).then((r) => r.data),

  avalar: (id: number) => api.post(`/api/solicitudes/${id}/avalar`).then((r) => r.data),
  rechazarProfesor: (id: number, motivo: string) =>
    api.post(`/api/solicitudes/${id}/rechazar-profesor`, { motivo }).then((r) => r.data),

  aprobar: (id: number) => api.post(`/api/solicitudes/${id}/aprobar`).then((r) => r.data),
  rechazar: (id: number, motivo: string) =>
    api.post(`/api/solicitudes/${id}/rechazar`, { motivo }).then((r) => r.data),
  preparar: (id: number) => api.post(`/api/solicitudes/${id}/preparar`).then((r) => r.data),
  entregar: (id: number) => api.post(`/api/solicitudes/${id}/entregar`).then((r) => r.data),
  /** Cierra la devolución; `quebradas` = piezas que no volvieron (se dan de baja y se cargan al responsable). */
  devolver: (id: number, quebradas: PiezaQuebrada[] = []) =>
    api.post(`/api/solicitudes/${id}/devolver`, { quebradas }).then((r) => r.data),
}
