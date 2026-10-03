export interface UsuarioInfo {
  id: number
  usuario: string
  nombre: string
  rol: string
  permisos: string[]
}

export interface LoginResponse {
  token: string
  expiraEn: string
  usuario: UsuarioInfo
}

export type EstadoSolicitud =
  | 'BORRADOR' | 'PENDIENTE' | 'APROBADA' | 'RECHAZADA'
  | 'PREPARADA' | 'ENTREGADA' | 'DEVUELTA' | 'CERRADA'

export interface SolicitudHeader {
  id: number
  estado: EstadoSolicitud
  profesorId: number
  profesor?: string
  supervisorId?: number
  bodegaId?: number
  laboratorioId: number
  laboratorio?: string
  fechaSolicitud: string
  fechaRequerida?: string
  motivoRechazo?: string
  observaciones?: string
}

export interface SolicitudLinea {
  id: number
  articuloId: number
  articulo?: string
  tipo?: string
  unidad?: string
  cantSolicitada: number
  cantPreparada: number
  cantDevuelta: number
  loteId?: number
}

export interface SolicitudDetalle {
  cabecera: SolicitudHeader
  lineas: SolicitudLinea[]
}

export interface Articulo {
  id: number
  tipo: 'REACTIVO' | 'MATERIAL'
  codigo: string
  nombre: string
  categoria?: string
  unidadId: number
  unidad?: string
  stockMinimo: number
  activo: boolean
}

export interface Existencia {
  articuloId: number
  codigo: string
  nombre: string
  tipo: string
  unidad?: string
  stockMinimo: number
  existencia: number
  bajoMinimo: boolean
}

export interface ArticuloDetalle {
  id: number
  tipo: 'REACTIVO' | 'MATERIAL'
  codigo: string
  nombre: string
  categoriaId: number
  categoria?: string
  unidadId: number
  unidad?: string
  stockMinimo: number
  activo: boolean
  cas?: string | null
  formula?: string | null
  clasificacionPeligro?: string | null
  estadoFisico?: string | null
  concentracion?: string | null
  condicionesAlmacenamiento?: string | null
}

export interface CatalogoItem {
  id: number
  nombre: string
}

export interface UsuarioAdmin {
  id: number
  nombreCompleto: string
  usuario: string
  email?: string | null
  rolId: number
  rol: string
  activo: boolean
}

export interface Rol {
  id: number
  nombre: string
  descripcion?: string | null
  permisos: string[]
}

export interface Permiso {
  id: number
  codigo: string
  descripcion?: string | null
  modulo?: string | null
}

export interface Conteo {
  etiqueta: string
  cantidad: number
}

export interface DashboardData {
  totalArticulos: number
  bajoMinimo: number
  proximosAVencer: number
  solicitudesPendientes: number
  articulosPorCategoria: Conteo[]
  vencimientos: Conteo[]
  consumoPorMes: Conteo[]
}

export interface ProximoVencer {
  articuloId: number
  codigo: string
  nombre: string
  codigoLote?: string | null
  fechaVencimiento?: string | null
  diasRestantes: number
  cantidadActual: number
  ubicacion?: string | null
}

export interface ConsumoLaboratorio {
  laboratorio: string
  despachos: number
  lineas: number
}

export interface Kardex {
  fecha: string
  tipo: string
  cantidad: number
  codigoLote?: string | null
  motivo?: string | null
}

export interface Unidad {
  id: number
  nombre: string
  abreviatura: string
}

export interface Respaldo {
  id: number
  archivo: string
  tamanoBytes?: number | null
  fecha: string
  usuario?: string | null
  observacion?: string | null
}
