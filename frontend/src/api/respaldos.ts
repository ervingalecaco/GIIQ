import { api } from './client'
import type { Respaldo } from '../types'

export const respaldosApi = {
  list: () => api.get<Respaldo[]>('/api/respaldos').then((r) => r.data),
  crear: () => api.post<Respaldo>('/api/respaldos').then((r) => r.data),
  restore: (archivo: File) => {
    const fd = new FormData()
    fd.append('archivo', archivo)
    return api.post('/api/respaldos/restore', fd).then((r) => r.data)
  },
}
