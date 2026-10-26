import { api } from './client'
import type { Baja, CausaBaja, Constancia, CuentaDetalle, CuentaResumen, EstudianteOpcion } from '../types'

export const bajasApi = {
  /** desde / hasta: yyyy-mm-dd; sin ellos, los últimos 90 días. */
  list: (rango: { desde?: string; hasta?: string } = {}) =>
    api.get<Baja[]>('/api/bajas', { params: rango }).then((r) => r.data),
  registrar: (payload: { articuloId: number; cantidad: number; causa: CausaBaja; estudianteId?: number | null; observacion?: string | null }) =>
    api.post<{ bajaId: number }>('/api/bajas', payload).then((r) => r.data),
}

export const cuentasApi = {
  list: () => api.get<CuentaResumen[]>('/api/cuentas').then((r) => r.data),
  detalle: (estudianteId: number) => api.get<CuentaDetalle>(`/api/cuentas/${estudianteId}`).then((r) => r.data),
  /** La cuenta del estudiante que inició sesión. */
  mia: () => api.get<CuentaDetalle>('/api/cuentas/mia').then((r) => r.data),
  estudiantes: () => api.get<EstudianteOpcion[]>('/api/cuentas/estudiantes').then((r) => r.data),
  reponer: (cargoId: number, cantidad: number, observacion?: string | null) =>
    api.post(`/api/cuentas/cargos/${cargoId}/reposicion`, { cantidad, observacion }).then((r) => r.data),
  emitirConstancia: (estudianteId: number) =>
    api.post<Constancia>(`/api/cuentas/${estudianteId}/constancia`).then((r) => r.data),
  constancia: (folio: number) => api.get<Constancia>(`/api/cuentas/constancias/${folio}`).then((r) => r.data),
}

/** Texto de cada causa de baja. */
export const CAUSAS: { valor: CausaBaja; texto: string }[] = [
  { valor: 'QUEBRADO', texto: 'Quebrado' },
  { valor: 'EXTRAVIADO', texto: 'Extraviado' },
  { valor: 'DETERIORADO', texto: 'Deteriorado' },
]
export const textoCausa = (c: CausaBaja) => CAUSAS.find((x) => x.valor === c)?.texto ?? c
