import { api } from './client'
import type { SolicitudDetalle, SolicitudHeader } from '../types'

export interface CrearSolicitudPayload {
  laboratorioId: number
  fechaRequerida?: string | null
  observaciones?: string | null
  lineas: { articuloId: number; unidadId: number; cantidad: number }[]
}

export const solicitudesApi = {
  list: (estado?: string) =>
    api.get<SolicitudHeader[]>('/api/solicitudes', { params: { estado } }).then((r) => r.data),

  get: (id: number) =>
    api.get<SolicitudDetalle>(`/api/solicitudes/${id}`).then((r) => r.data),

  crear: (payload: CrearSolicitudPayload) =>
    api.post<{ solicitudId: number; lineas: number }>('/api/solicitudes', payload).then((r) => r.data),

  aprobar: (id: number) => api.post(`/api/solicitudes/${id}/aprobar`).then((r) => r.data),
  rechazar: (id: number, motivo: string) =>
    api.post(`/api/solicitudes/${id}/rechazar`, { motivo }).then((r) => r.data),
  preparar: (id: number) => api.post(`/api/solicitudes/${id}/preparar`).then((r) => r.data),
  entregar: (id: number) => api.post(`/api/solicitudes/${id}/entregar`).then((r) => r.data),
  devolver: (id: number) => api.post(`/api/solicitudes/${id}/devolver`).then((r) => r.data),
}
