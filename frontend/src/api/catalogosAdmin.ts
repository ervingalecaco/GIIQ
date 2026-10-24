import { api } from './client'

export type CatRow = Record<string, unknown> & { id: number; activo: boolean }

const base = '/api/admin'

export const catAdminApi = {
  list: (entidad: string) => api.get<CatRow[]>(`${base}/${entidad}`).then((r) => r.data),
  crear: (entidad: string, payload: Record<string, unknown>) =>
    api.post(`${base}/${entidad}`, payload).then((r) => r.data),
  editar: (entidad: string, id: number, payload: Record<string, unknown>) =>
    api.put(`${base}/${entidad}/${id}`, payload).then((r) => r.data),
  estado: (entidad: string, id: number, activo: boolean) =>
    api.post(`${base}/${entidad}/${id}/estado`, { activo }).then((r) => r.data),
}

/** Catálogo del que salen las opciones de un campo select/multi. */
export type FuenteOpciones = 'laboratorios' | 'clases' | 'profesores' | 'anios'

export interface CampoCat {
  name: string
  label: string
  required?: boolean
  /** select: un id de `fuente`; multi: varios ids (checkboxes) de `fuente`. */
  type?: 'text' | 'email' | 'select' | 'multi'
  fuente?: FuenteOpciones
  /** Para multi: columna de la fila que trae los ids separados por coma (ej. "2,7"). */
  desde?: string
}

export interface EntidadCat {
  key: string
  label: string
  /** fmt 'anio': muestra el número de año como texto ("Primer año"). */
  columnas: { name: string; label: string; fmt?: 'anio' }[]
  campos: CampoCat[]
}

export const ENTIDADES: EntidadCat[] = [
  {
    key: 'categorias', label: 'Categorías',
    columnas: [{ name: 'nombre', label: 'Nombre' }, { name: 'descripcion', label: 'Descripción' }],
    campos: [
      { name: 'nombre', label: 'Nombre', required: true },
      { name: 'descripcion', label: 'Descripción' },
    ],
  },
  {
    key: 'unidades', label: 'Unidades',
    columnas: [{ name: 'nombre', label: 'Nombre' }, { name: 'abreviatura', label: 'Abreviatura' }],
    campos: [
      { name: 'nombre', label: 'Nombre', required: true },
      { name: 'abreviatura', label: 'Abreviatura', required: true },
    ],
  },
  {
    key: 'proveedores', label: 'Proveedores',
    columnas: [
      { name: 'nombre', label: 'Nombre' }, { name: 'contacto', label: 'Contacto' },
      { name: 'telefono', label: 'Teléfono' }, { name: 'email', label: 'Email' },
    ],
    campos: [
      { name: 'nombre', label: 'Nombre', required: true },
      { name: 'contacto', label: 'Contacto' },
      { name: 'telefono', label: 'Teléfono' },
      { name: 'email', label: 'Email', type: 'email' },
      { name: 'direccion', label: 'Dirección' },
    ],
  },
  {
    key: 'ubicaciones', label: 'Ubicaciones',
    columnas: [{ name: 'nombre', label: 'Nombre' }, { name: 'condiciones', label: 'Condiciones' }],
    campos: [
      { name: 'nombre', label: 'Nombre', required: true },
      { name: 'descripcion', label: 'Descripción' },
      { name: 'condiciones', label: 'Condiciones', },
    ],
  },
  {
    key: 'laboratorios', label: 'Laboratorios',
    columnas: [{ name: 'nombre', label: 'Nombre' }, { name: 'descripcion', label: 'Descripción' }],
    campos: [
      { name: 'nombre', label: 'Nombre', required: true },
      { name: 'descripcion', label: 'Descripción' },
    ],
  },
  {
    key: 'clases', label: 'Clases',
    columnas: [
      { name: 'anio', label: 'Año', fmt: 'anio' },
      { name: 'nombre', label: 'Clase' }, { name: 'profesores', label: 'Profesores' },
      { name: 'practicas', label: 'Prácticas' },
    ],
    campos: [
      { name: 'anio', label: 'Año', required: true, type: 'select', fuente: 'anios' },
      { name: 'nombre', label: 'Nombre de la clase', required: true },
      { name: 'descripcion', label: 'Descripción' },
      { name: 'profesorIds', label: 'Profesores que la imparten', required: true, type: 'multi', fuente: 'profesores', desde: 'profesorIds' },
    ],
  },
  {
    key: 'practicas', label: 'Prácticas',
    columnas: [
      { name: 'claseAnio', label: 'Año', fmt: 'anio' },
      { name: 'clase', label: 'Clase' }, { name: 'nombre', label: 'Práctica' },
      { name: 'laboratorio', label: 'Laboratorio' },
    ],
    campos: [
      { name: 'claseId', label: 'Clase', required: true, type: 'select', fuente: 'clases' },
      { name: 'nombre', label: 'Nombre de la práctica', required: true },
      { name: 'laboratorioId', label: 'Laboratorio', required: true, type: 'select', fuente: 'laboratorios' },
      { name: 'descripcion', label: 'Descripción' },
    ],
  },
]
