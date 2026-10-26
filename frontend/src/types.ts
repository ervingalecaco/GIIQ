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
  | 'BORRADOR' | 'PENDIENTE_PROFESOR' | 'PENDIENTE' | 'APROBADA' | 'RECHAZADA'
  | 'PREPARADA' | 'ENTREGADA' | 'DEVUELTA' | 'CERRADA'

export interface SolicitudHeader {
  id: number
  tipo: TipoArticulo
  estado: EstadoSolicitud
  /** Profesor responsable: quien la creó, o el que eligió el estudiante. */
  profesorId: number
  profesor?: string
  /** Estudiante que la creó (vacío si la creó el profesor). */
  estudianteId?: number | null
  estudiante?: string | null
  fechaAvalProfesor?: string | null
  /** Práctica y su clase (vacías en solicitudes anteriores a este cambio). */
  practicaId?: number | null
  practica?: string | null
  claseId?: number | null
  clase?: string | null
  claseAnio?: number | null
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
  /** Piezas de cristalería quebradas al devolver (dadas de baja). */
  cantQuebrada: number
  loteId?: number
}

export interface SolicitudDetalle {
  cabecera: SolicitudHeader
  lineas: SolicitudLinea[]
}

export type TipoArticulo = 'REACTIVO' | 'CRISTALERIA'

export interface Articulo {
  id: number
  tipo: TipoArticulo
  codigo: string
  nombre: string
  categoria?: string
  unidadId: number
  unidad?: string
  stockMinimo: number
  activo: boolean
  /** Rombo NFPA 704 (solo reactivos; vacío si aún no se clasificó). */
  nfpaSalud?: number | null
  nfpaInflamabilidad?: number | null
  nfpaReactividad?: number | null
  nfpaEspecial?: string | null
  /** Fecha de la foto de referencia (cristalería); vacía si no tiene. */
  imagenActualizada?: string | null
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
  tipo: TipoArticulo
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
  nfpaSalud?: number | null
  nfpaInflamabilidad?: number | null
  nfpaReactividad?: number | null
  nfpaEspecial?: string | null
  /** Fecha de la foto de referencia (cristalería); vacía si no tiene. */
  imagenActualizada?: string | null
}

export interface CatalogoItem {
  id: number
  nombre: string
}

export interface ClaseItem extends CatalogoItem {
  /** Año de la carrera (1 a 5). */
  anio: number
}

export interface PracticaItem extends CatalogoItem {
  laboratorio?: string | null
}

export interface UsuarioAdmin {
  id: number
  nombres: string
  apellidos: string
  /** Calculado: nombres + apellidos. */
  nombreCompleto: string
  /** Código de estudiante o de profesor (vacío en los demás roles). */
  codigo?: string | null
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
  laboratorioId: number
  laboratorio: string
  despachos: number
  lineas: number
}

/** Lote con existencia de un artículo (detalle del reporte de existencias). */
export interface LoteExistencia {
  id: number
  codigoLote?: string | null
  fechaVencimiento?: string | null
  diasRestantes?: number | null
  cantidadActual: number
  ubicacion?: string | null
  proveedor?: string | null
  fechaIngreso: string
}

/** Detalle del consumo de un laboratorio en el período. */
export interface ConsumoDetalle {
  articulos: { articuloId: number; codigo: string; nombre: string; tipo: string; unidad: string; cantidad: number; despachos: number }[]
  despachos: { solicitudId: number; fecha: string; tipo: string; solicitante: string; practica?: string | null; lineas: number }[]
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

// ---------------------------------------------------------------- Bajas y cuentas
export type CausaBaja = 'QUEBRADO' | 'EXTRAVIADO' | 'DETERIORADO'

export interface Baja {
  id: number
  fecha: string
  articuloId: number
  codigo: string
  articulo: string
  unidad?: string
  cantidad: number
  causa: CausaBaja
  solicitudId?: number | null
  estudianteId?: number | null
  estudiante?: string | null
  estudianteCodigo?: string | null
  registradoPor?: string
  observacion?: string | null
  /** Estado del cargo que generó; vacío si no hubo responsable. */
  estadoCargo?: 'PENDIENTE' | 'SALDADO' | null
}

export interface CuentaResumen {
  estudianteId: number
  codigo?: string | null
  estudiante: string
  activo: boolean
  cargosPendientes: number
  piezasPendientes: number
  cargosTotales: number
  ultimaBaja?: string | null
}

export interface Cargo {
  id: number
  bajaId: number
  fecha: string
  articuloId: number
  codigo: string
  articulo: string
  unidad?: string
  cantidad: number
  cantidadRepuesta: number
  estado: 'PENDIENTE' | 'SALDADO'
  saldadoEn?: string | null
  causa: CausaBaja
  solicitudId?: number | null
  observacion?: string | null
  imagenActualizada?: string | null
}

export interface Reposicion {
  id: number
  cargoId: number
  fecha: string
  articulo: string
  cantidad: number
  recibidoPor?: string
  observacion?: string | null
}

export interface CuentaDetalle {
  resumen: CuentaResumen
  cargos: Cargo[]
  reposiciones: Reposicion[]
}

export interface EstudianteOpcion { id: number; codigo?: string | null; nombre: string }

export interface Constancia {
  folio: number
  fecha: string
  estudiante: string
  codigo?: string | null
  emitidaPor?: string
}
