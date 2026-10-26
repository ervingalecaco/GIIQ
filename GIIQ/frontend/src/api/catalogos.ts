import { api } from './client'
import type {
  Articulo, ArticuloDetalle, CatalogoItem, ClaseItem, Existencia, PracticaItem, Unidad,
} from '../types'

export const catalogosApi = {
  laboratorios: () => api.get<CatalogoItem[]>('/api/catalogos/laboratorios').then((r) => r.data),
  profesores: () => api.get<CatalogoItem[]>('/api/catalogos/profesores').then((r) => r.data),
  /** Todas las clases activas. */
  clases: () => api.get<ClaseItem[]>('/api/catalogos/clases').then((r) => r.data),
  clasesDeProfesor: (profesorId: number) =>
    api.get<ClaseItem[]>(`/api/catalogos/profesores/${profesorId}/clases`).then((r) => r.data),
  practicasDeClase: (claseId: number) =>
    api.get<PracticaItem[]>(`/api/catalogos/clases/${claseId}/practicas`).then((r) => r.data),
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
  /** Rombo NFPA 704: obligatorio para reactivos (0 a 4); especial = códigos separados por coma. */
  nfpaSalud?: number | null
  nfpaInflamabilidad?: number | null
  nfpaReactividad?: number | null
  nfpaEspecial?: string | null
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

  /** Foto de referencia (cristalería). `version` = su fecha, para que la caché no muestre una vieja. */
  imagen: (id: number, version: string) =>
    api.get<Blob>(`/api/articulos/${id}/imagen`, { params: { v: version }, responseType: 'blob' }).then((r) => r.data),
  subirImagen: (id: number, imagen: Blob) => {
    const fd = new FormData()
    fd.append('archivo', imagen, 'imagen.jpg')
    return api.put(`/api/articulos/${id}/imagen`, fd).then((r) => r.data)
  },
  quitarImagen: (id: number) =>
    api.delete(`/api/articulos/${id}/imagen`).then((r) => r.data),

  /** Paso 1: lee el Excel de cristalería y devuelve las filas propuestas (no guarda nada). */
  previsualizarCristaleria: (archivo: File) => {
    const fd = new FormData()
    fd.append('archivo', archivo)
    return api.post<FilaImportacion[]>('/api/articulos/importar/cristaleria/previsualizar', fd)
      .then((r) => r.data)
  },
  /** Paso 2: crea los artículos revisados con su existencia inicial. */
  importarCristaleria: (filas: FilaImportar[]) =>
    api.post<{ creados: number; omitidos: number }>('/api/articulos/importar/cristaleria', { filas })
      .then((r) => r.data),
}

export interface FilaImportar {
  codigo: string
  nombre: string
  categoria: string
  ubicacion: string | null
  unidad: string
  cantidad: number
}

export interface FilaImportacion extends FilaImportar {
  fila: number
  nombreOriginal: string
  /** Ya hay un artículo con ese código: no se importará. */
  existe: boolean
  avisos: string[]
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
