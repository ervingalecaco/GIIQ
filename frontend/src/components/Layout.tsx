import { NavLink, Outlet, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'

interface NavItem { to: string; label: string; perm?: string }

const NAV: NavItem[] = [
  { to: '/',            label: 'Dashboard',   perm: 'dashboard.ver' },
  { to: '/solicitudes', label: 'Solicitudes', perm: 'solicitud.ver' },
  { to: '/articulos',   label: 'Artículos',   perm: 'articulos.ver' },
  { to: '/inventario',  label: 'Inventario',  perm: 'inventario.ver' },
  { to: '/reportes',    label: 'Reportes',    perm: 'reporte.ver' },
  { to: '/catalogos',   label: 'Catálogos',   perm: 'catalogos.gestionar' },
  { to: '/usuarios',    label: 'Usuarios',    perm: 'usuarios.ver' },
  { to: '/roles',       label: 'Roles',       perm: 'roles.gestionar' },
  { to: '/respaldos',   label: 'Respaldos',   perm: 'respaldo.gestionar' },
]

export function Layout() {
  const { user, logout, hasPerm } = useAuth()
  const navigate = useNavigate()

  const items = NAV.filter((i) => !i.perm || hasPerm(i.perm))

  function salir() {
    logout()
    navigate('/login', { replace: true })
  }

  return (
    <div className="min-h-screen bg-slate-50 md:flex">
      <aside className="bg-white border-slate-200 border-b md:border-b-0 md:border-r
                        flex flex-col md:w-60 md:shrink-0 md:h-screen md:sticky md:top-0">
        <div className="h-14 flex items-center px-5 border-b border-slate-100">
          <span className="font-semibold text-teal-700 text-lg tracking-tight">LabQuim</span>
        </div>

        <nav className="p-3 flex flex-wrap md:flex-col gap-1 md:flex-1">
          {items.map((i) => (
            <NavLink
              key={i.to}
              to={i.to}
              end={i.to === '/'}
              className={({ isActive }) =>
                `px-3 py-2 rounded-md text-sm font-medium transition ${
                  isActive ? 'bg-teal-50 text-teal-700' : 'text-slate-600 hover:bg-slate-100'
                }`
              }
            >
              {i.label}
            </NavLink>
          ))}
        </nav>

        <div className="mt-auto p-3 border-t border-slate-100 flex items-center justify-between gap-2">
          <div className="min-w-0">
            <div className="text-sm font-medium truncate">{user?.nombre}</div>
            <div className="text-xs text-slate-500">{user?.rol}</div>
          </div>
          <button
            onClick={salir}
            className="px-3 py-1.5 rounded-md text-sm border border-slate-300 hover:bg-slate-100 shrink-0"
          >
            Salir
          </button>
        </div>
      </aside>

      <main className="flex-1 min-w-0">
        <div className="max-w-6xl mx-auto px-4 py-6">
          <Outlet />
        </div>
      </main>
    </div>
  )
}
