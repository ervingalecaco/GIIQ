import { api } from './client'
import type { Articulo, ArticuloDetalle, CatalogoItem, Existencia, Unidad } from '../types'

export const catalogosApi = {
  laboratorios: () => api.get<CatalogoItem[]>('/api/catalogos/laboratorios').then((r) => r.data),
  unidades: () => api.get<Unidad[]>('/api/catalogos/unidades').then((r) => r.data),
  categorias: () => api.get<CatalogoItem[]>('/api/catalogos/categorias').then((r) => r.data),
  proveedores: () => api.get<CatalogoItem[]>('/api/catalogos/proveedores').then((r) => r.data),
  ubicaciones: () => api.get<CatalogoItem[]>('/api/catalogos/ubicaciones').then((r) => r.data),
}

export interface ArticuloPayload {
  nombre: string
  categoriaId: number
  unidadId: number
  stockMinimo: number
  cas?: string | null
  formula?: string | null
  clasificacionPeligro?: string | null
  estadoFisico?: string | null
  concentracion?: string | null
  condicionesAlmacenamiento?: string | null
}

export const articulosApi = {
  list: (tipo?: string) =>
    api.get<Articulo[]>('/api/articulos', { params: { tipo } }).then((r) => r.data),
  get: (id: number) =>
    api.get<ArticuloDetalle>(`/api/articulos/${id}`).then((r) => r.data),
  crear: (payload: ArticuloPayload & { tipo: string; codigo: string }) =>
    api.post<{ articuloId: number }>('/api/articulos', payload).then((r) => r.data),
  editar: (id: number, payload: ArticuloPayload) =>
    api.put(`/api/articulos/${id}`, payload).then((r) => r.data),
  cambiarEstado: (id: number, activo: boolean) =>
    api.post(`/api/articulos/${id}/estado`, { activo }).then((r) => r.data),
}

export interface EntradaPayload {
  articuloId: number
  codigoLote?: string | null
  fechaVencimiento?: string | null
  cantidad: number
  proveedorId?: number | null
  ubicacionId?: number | null
  motivo?: string | null
}

export const inventarioApi = {
  existencias: () => api.get<Existencia[]>('/api/inventario/existencias').then((r) => r.data),
  entrada: (payload: EntradaPayload) =>
    api.post('/api/inventario/entradas', payload).then((r) => r.data),
}
