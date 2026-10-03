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

export interface CampoCat {
  name: string
  label: string
  required?: boolean
  type?: 'text' | 'email'
}

export interface EntidadCat {
  key: string
  label: string
  columnas: { name: string; label: string }[]
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
]
