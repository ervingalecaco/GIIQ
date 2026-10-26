import axios from 'axios'
import { getToken, clearAuth } from '../auth/storage'

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL as string,
})

api.interceptors.request.use((config) => {
  const token = getToken()
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

api.interceptors.response.use(
  (res) => res,
  (error) => {
    if (error.response?.status === 401) {
      clearAuth()
      if (window.location.pathname !== '/login') window.location.href = '/login'
    }
    return Promise.reject(error)
  },
)

/**
 * Extrae el mensaje de error del backend: `detail` (ProblemDetails del middleware)
 * o, si es un error de validación del modelo, los mensajes de cada campo.
 */
export function apiError(error: unknown, fallback = 'Ocurrió un error.'): string {
  if (axios.isAxiosError(error)) {
    const data = error.response?.data as { detail?: string; errors?: Record<string, string[]> } | undefined
    if (data?.detail) return data.detail
    if (data?.errors) return [...new Set(Object.values(data.errors).flat())].join(' ')
    return error.message ?? fallback
  }
  return fallback
}
