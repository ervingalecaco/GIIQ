import { Navigate, Outlet } from 'react-router-dom'
import { useAuth } from './AuthContext'

export function ProtectedRoute({ perm }: { perm?: string }) {
  const { user, hasPerm } = useAuth()
  if (!user) return <Navigate to="/login" replace />
  if (perm && !hasPerm(perm)) return <Navigate to="/" replace />
  return <Outlet />
}
