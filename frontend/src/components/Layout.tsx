import { forwardRef, useState, type ComponentProps, type FC } from 'react'
import { Link, Outlet, useLocation, useNavigate } from 'react-router-dom'
import {
  Avatar, Button, Drawer, DrawerItems, Navbar,
  Sidebar, SidebarItem, SidebarItemGroup, SidebarItems,
} from 'flowbite-react'
import {
  HiBeaker, HiChartBar, HiChartPie, HiClipboardList, HiCube, HiDatabase,
  HiLogout, HiMenu, HiShieldCheck, HiTag, HiUsers,
} from 'react-icons/hi'
import { useAuth } from '../auth/AuthContext'

interface NavItem { to: string; label: string; perm?: string; icon: FC<ComponentProps<'svg'>> }

const NAV: NavItem[] = [
  { to: '/',            label: 'Dashboard',   perm: 'dashboard.ver',       icon: HiChartPie },
  { to: '/solicitudes', label: 'Solicitudes', perm: 'solicitud.ver',       icon: HiClipboardList },
  { to: '/articulos',   label: 'Artículos',   perm: 'articulos.ver',       icon: HiBeaker },
  { to: '/inventario',  label: 'Inventario',  perm: 'inventario.ver',      icon: HiCube },
  { to: '/reportes',    label: 'Reportes',    perm: 'reporte.ver',         icon: HiChartBar },
  { to: '/catalogos',   label: 'Catálogos',   perm: 'catalogos.gestionar', icon: HiTag },
  { to: '/usuarios',    label: 'Usuarios',    perm: 'usuarios.ver',        icon: HiUsers },
  { to: '/roles',       label: 'Roles',       perm: 'roles.gestionar',     icon: HiShieldCheck },
  { to: '/respaldos',   label: 'Respaldos',   perm: 'respaldo.gestionar',  icon: HiDatabase },
]

/** Adaptador para que SidebarItem navegue con react-router (recibe href). */
const RouterLink = forwardRef<HTMLAnchorElement, ComponentProps<'a'>>(
  ({ href = '/', ...props }, ref) => <Link ref={ref} to={href} {...props} />,
)

function Logo() {
  return (
    <Link to="/" className="flex items-center gap-2.5">
      <span className="inline-flex items-center justify-center h-8 w-8 rounded-lg brand-gradient
                       text-white font-bold text-sm shadow-md shadow-indigo-500/30">Lq</span>
      <span className="font-extrabold text-lg tracking-tight brand-text-gradient">LabQuim</span>
    </Link>
  )
}

function iniciales(nombre?: string) {
  return (nombre ?? '?').split(' ').filter(Boolean).slice(0, 2).map((p) => p[0]).join('').toUpperCase()
}

export function Layout() {
  const { user, logout, hasPerm } = useAuth()
  const navigate = useNavigate()
  const { pathname } = useLocation()
  const [menuAbierto, setMenuAbierto] = useState(false)

  const items = NAV.filter((i) => !i.perm || hasPerm(i.perm))
  const activo = (to: string) => (to === '/' ? pathname === '/' : pathname.startsWith(to))

  function salir() {
    logout()
    navigate('/login', { replace: true })
  }

  const menu = (
    <Sidebar aria-label="Menú principal" className="w-full"
      theme={{ root: { inner: 'h-full overflow-y-auto overflow-x-hidden bg-white px-3 py-4' } }}>
      <SidebarItems>
        <SidebarItemGroup>
          {items.map((i) => (
            <SidebarItem key={i.to} as={RouterLink} href={i.to} icon={i.icon}
              active={activo(i.to)} onClick={() => setMenuAbierto(false)}>
              {i.label}
            </SidebarItem>
          ))}
        </SidebarItemGroup>
      </SidebarItems>
    </Sidebar>
  )

  const usuario = (
    <div className="p-3 border-t border-gray-200 flex items-center gap-3">
      <Avatar placeholderInitials={iniciales(user?.nombre)} rounded size="sm" />
      <div className="min-w-0 flex-1">
        <div className="text-sm font-medium text-gray-900 truncate">{user?.nombre}</div>
        <div className="text-xs text-gray-500 truncate">{user?.rol}</div>
      </div>
      <Button color="light" size="xs" onClick={salir} title="Cerrar sesión">
        <HiLogout className="h-4 w-4" />
      </Button>
    </div>
  )

  return (
    <div className="min-h-screen bg-gray-50 md:flex">
      {/* Escritorio: sidebar fijo */}
      <aside className="hidden md:flex md:flex-col md:w-64 md:shrink-0 md:h-screen md:sticky md:top-0
                        bg-white border-r border-gray-200">
        <div className="h-16 flex items-center px-5 border-b border-gray-200"><Logo /></div>
        <div className="flex-1 min-h-0">{menu}</div>
        {usuario}
      </aside>

      {/* Móvil: navbar + drawer */}
      <Navbar fluid className="md:hidden border-b border-gray-200 sticky top-0 z-30">
        <Logo />
        <Button color="light" size="sm" onClick={() => setMenuAbierto(true)} aria-label="Abrir menú">
          <HiMenu className="h-5 w-5" />
        </Button>
      </Navbar>
      <Drawer open={menuAbierto} onClose={() => setMenuAbierto(false)} className="md:hidden p-0 w-72">
        <div className="h-16 flex items-center px-5 border-b border-gray-200"><Logo /></div>
        <DrawerItems className="flex flex-col h-[calc(100%-4rem)]">
          <div className="flex-1">{menu}</div>
          {usuario}
        </DrawerItems>
      </Drawer>

      <main className="flex-1 min-w-0">
        <div className="max-w-6xl mx-auto px-4 py-6 md:px-8 md:py-8">
          <Outlet />
        </div>
      </main>
    </div>
  )
}
