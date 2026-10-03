import { createContext, useContext, useState, type ReactNode } from 'react'
import { api } from '../api/client'
import { clearAuth, getUser, setAuth } from './storage'
import type { LoginResponse, UsuarioInfo } from '../types'

interface AuthState {
  user: UsuarioInfo | null
  login: (usuario: string, password: string) => Promise<void>
  logout: () => void
  hasPerm: (code: string) => boolean
  isRole: (rol: string) => boolean
}

const AuthContext = createContext<AuthState | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<UsuarioInfo | null>(() => getUser())

  async function login(usuario: string, password: string) {
    const { data } = await api.post<LoginResponse>('/api/auth/login', { usuario, password })
    setAuth(data.token, data.usuario)
    setUser(data.usuario)
  }

  function logout() {
    clearAuth()
    setUser(null)
  }

  const hasPerm = (code: string) =>
    !!user && (user.rol === 'Administrador' || user.permisos.includes(code))

  const isRole = (rol: string) => user?.rol === rol

  return (
    <AuthContext.Provider value={{ user, login, logout, hasPerm, isRole }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth(): AuthState {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth debe usarse dentro de <AuthProvider>')
  return ctx
}
