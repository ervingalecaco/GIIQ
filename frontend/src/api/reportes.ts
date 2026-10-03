import { api } from './client'
import type { ConsumoLaboratorio, DashboardData, Existencia, Kardex, ProximoVencer } from '../types'

export const dashboardApi = {
  get: () => api.get<DashboardData>('/api/dashboard').then((r) => r.data),
}

export const reportesApi = {
  existencias: (bajoMinimo = false) =>
    api.get<Existencia[]>('/api/reportes/existencias', { params: { bajoMinimo } }).then((r) => r.data),
  proximosVencer: (dias = 30) =>
    api.get<ProximoVencer[]>('/api/reportes/proximos-vencer', { params: { dias } }).then((r) => r.data),
  lotesVencidos: () =>
    api.get<ProximoVencer[]>('/api/reportes/lotes-vencidos').then((r) => r.data),
  consumoLaboratorio: (desde?: string, hasta?: string) =>
    api.get<ConsumoLaboratorio[]>('/api/reportes/consumo-laboratorio', { params: { desde, hasta } }).then((r) => r.data),
  kardex: (articuloId: number, desde?: string, hasta?: string) =>
    api.get<Kardex[]>('/api/reportes/kardex', { params: { articuloId, desde, hasta } }).then((r) => r.data),
}

/** Descarga un archivo (blob) desde un endpoint autenticado. */
export async function descargarArchivo(url: string, nombreFallback: string): Promise<void> {
  const res = await api.get(url, { responseType: 'blob' })
  const blob = new Blob([res.data as BlobPart], { type: res.headers['content-type'] as string })
  const enlace = document.createElement('a')
  enlace.href = URL.createObjectURL(blob)
  enlace.download = nombreFallback
  document.body.appendChild(enlace)
  enlace.click()
  enlace.remove()
  URL.revokeObjectURL(enlace.href)
}
