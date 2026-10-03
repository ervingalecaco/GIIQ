import type { UsuarioInfo } from '../types'

const TOKEN_KEY = 'labquim.token'
const USER_KEY = 'labquim.user'

export function getToken(): string | null {
  try { return localStorage.getItem(TOKEN_KEY) } catch { return null }
}

export function getUser(): UsuarioInfo | null {
  try {
    const raw = localStorage.getItem(USER_KEY)
    return raw ? (JSON.parse(raw) as UsuarioInfo) : null
  } catch { return null }
}

export function setAuth(token: string, user: UsuarioInfo): void {
  try {
    localStorage.setItem(TOKEN_KEY, token)
    localStorage.setItem(USER_KEY, JSON.stringify(user))
  } catch { /* almacenamiento no disponible */ }
}

export function clearAuth(): void {
  try {
    localStorage.removeItem(TOKEN_KEY)
    localStorage.removeItem(USER_KEY)
  } catch { /* noop */ }
}
