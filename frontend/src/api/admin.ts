import { api } from './client'
import type { Permiso, Rol, UsuarioAdmin } from '../types'

export interface CrearUsuarioPayload {
  nombres: string
  apellidos: string
  codigo?: string | null
  usuario: string
  password: string
  email?: string | null
  rolId: number
}

export interface EditarUsuarioPayload {
  nombres: string
  apellidos: string
  codigo?: string | null
  email?: string | null
  rolId: number
}

export const usuariosApi = {
  list: () => api.get<UsuarioAdmin[]>('/api/usuarios').then((r) => r.data),
  /** ¿Están libres el usuario y/o el código? excluirId: el propio usuario al editar. */
  disponibilidad: (params: { usuario?: string; codigo?: string; excluirId?: number }) =>
    api.get<{ usuarioDisponible: boolean; codigoDisponible: boolean }>('/api/usuarios/disponibilidad', { params })
      .then((r) => r.data),
  crear: (payload: CrearUsuarioPayload) =>
    api.post<{ usuarioId: number }>('/api/usuarios', payload).then((r) => r.data),
  editar: (id: number, payload: EditarUsuarioPayload) =>
    api.put(`/api/usuarios/${id}`, payload).then((r) => r.data),
  cambiarEstado: (id: number, activo: boolean) =>
    api.post(`/api/usuarios/${id}/estado`, { activo }).then((r) => r.data),
  cambiarPassword: (id: number, password: string) =>
    api.post(`/api/usuarios/${id}/password`, { password }).then((r) => r.data),
}

export const rolesApi = {
  roles: () => api.get<Rol[]>('/api/roles').then((r) => r.data),
  permisos: () => api.get<Permiso[]>('/api/permisos').then((r) => r.data),
  setPermisos: (id: number, permisos: string[]) =>
    api.put(`/api/roles/${id}/permisos`, { permisos }).then((r) => r.data),
}
