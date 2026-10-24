import { forwardRef, useState, type ComponentProps, type FC } from 'react'
import { Link, Outlet, useLocation, useNavigate } from 'react-router-dom'
import {
  Avatar, Button, Drawer, DrawerItems, Navbar,
  Sidebar, SidebarItem, SidebarItemGroup, SidebarItems,
} from 'flowbite-react'
import {
  HiBeaker, HiChartBar, HiChartPie, HiClipboardList, HiCube, HiDatabase, HiIdentification,
  HiLogout, HiMenu, HiMinusCircle, HiShieldCheck, HiTag, HiUserGroup, HiUsers,
} from 'react-icons/hi'
import { TbTestPipe } from 'react-icons/tb'
import { useAuth } from '../auth/AuthContext'
import { useLogo } from '../logo'

type Icono = FC<ComponentProps<'svg'>>
/** `rol`: solo para ese rol (p. ej. "Mi cuenta", que el Administrador no tiene aunque tenga todos los permisos). */
interface NavItem { to: string; label: string; perm?: string; rol?: string; icon: Icono }
/** Sección del menú: un rótulo y sus páginas. */
interface NavSeccion { titulo: string; items: NavItem[] }

const NAV: NavSeccion[] = [
  {
    titulo: 'Operación',
    items: [
      { to: '/',                        label: 'Panel general',              perm: 'dashboard.ver', icon: HiChartPie },
      { to: '/solicitudes/reactivos',   label: 'Solicitudes de reactivos',   perm: 'solicitud.ver', icon: HiClipboardList },
      { to: '/solicitudes/cristaleria', label: 'Solicitudes de cristalería', perm: 'solicitud.ver', icon: HiClipboardList },
      { to: '/cuentas',                 label: 'Cuentas de estudiantes',     perm: 'cuentas.ver',   icon: HiUserGroup },
      { to: '/mi-cuenta',               label: 'Mi cuenta',                  perm: 'cuenta.propia', rol: 'Estudiante', icon: HiIdentification },
    ],
  },
  {
    titulo: 'Existencias',
    items: [
      { to: '/reactivos',   label: 'Reactivos',         perm: 'articulos.ver',  icon: HiBeaker },
      { to: '/cristaleria', label: 'Cristalería',       perm: 'articulos.ver',  icon: TbTestPipe },
      { to: '/inventario',  label: 'Inventario y lotes', perm: 'inventario.ver', icon: HiCube },
      { to: '/bajas',       label: 'Bajas',             perm: 'cuentas.ver',    icon: HiMinusCircle },
    ],
  },
  {
    titulo: 'Análisis',
    items: [
      { to: '/reportes', label: 'Reportes', perm: 'reporte.ver', icon: HiChartBar },
    ],
  },
  {
    titulo: 'Administración',
    items: [
      { to: '/catalogos', label: 'Catálogos', perm: 'catalogos.gestionar', icon: HiTag },
      { to: '/usuarios',  label: 'Usuarios',  perm: 'usuarios.ver',        icon: HiUsers },
      { to: '/roles',     label: 'Roles',     perm: 'roles.gestionar',     icon: HiShieldCheck },
      { to: '/respaldos', label: 'Respaldos', perm: 'respaldo.gestionar',  icon: HiDatabase },
    ],
  },
]

/** Adaptador para que SidebarItem navegue con react-router (recibe href). */
const RouterLink = forwardRef<HTMLAnchorElement, ComponentProps<'a'>>(
  ({ href = '/', ...props }, ref) => <Link ref={ref} to={href} {...props} />,
)

/** Logo sobre el fondo marino: el de la institución va en una placa blanca para conservar sus colores. */
function Logo({ alto = 'h-12' }: { alto?: string }) {
  const logo = useLogo()
  return (
    <Link to="/" className="flex flex-1 items-center gap-3" aria-label="Inicio">
      {logo ? (
        <span className="flex flex-1 justify-center rounded-md bg-white px-3 py-2">
          <img src={logo} alt="BioQ — Reactivos y Cristalería" className={`${alto} max-w-full w-auto object-contain`} />
        </span>
      ) : (
        <>
          <span className="inline-flex h-9 w-9 items-center justify-center rounded-md bg-primary-600">
            <HiBeaker className="h-5 w-5 text-white" />
          </span>
          <span>
            <span className="block text-[17px] font-bold text-white">LabQuim</span>
            <span className="block text-xs text-slate-400">Reactivos y Cristalería</span>
          </span>
        </>
      )}
    </Link>
  )
}

function iniciales(nombre?: string) {
  return (nombre ?? '?').split(' ').filter(Boolean).slice(0, 2).map((p) => p[0]).join('').toUpperCase()
}

const hoy = () => new Date().toLocaleDateString('es', { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' })

export function Layout() {
  const { user, logout, hasPerm } = useAuth()
  const navigate = useNavigate()
  const { pathname } = useLocation()
  const [menuAbierto, setMenuAbierto] = useState(false)

  const permitido = (i: NavItem) => (!i.perm || hasPerm(i.perm)) && (!i.rol || user?.rol === i.rol)
  // Las secciones se muestran solo si el usuario puede ver al menos una de sus páginas.
  const secciones = NAV
    .map((s) => ({ ...s, items: s.items.filter(permitido) }))
    .filter((s) => s.items.length > 0)
  const activo = (to: string) => (to === '/' ? pathname === '/' : pathname.startsWith(to))
  // Ruta para la barra superior: "Existencias · Reactivos".
  const actual = NAV.flatMap((s) => s.items.map((i) => ({ seccion: s.titulo, ...i })))
    .filter((i) => activo(i.to))
    .sort((a, b) => b.to.length - a.to.length)[0]

  function salir() {
    logout()
    navigate('/login', { replace: true })
  }

  const menu = (
    <Sidebar aria-label="Menú principal" className="w-full"
      theme={{
        root: { inner: 'sin-barra h-full overflow-y-auto overflow-x-hidden bg-[var(--marino)] px-3 py-4 rounded-none' },
        itemGroup: { base: 'mt-5 space-y-0.5 border-t-0 pt-0 first:mt-0' },
        item: {
          base: 'rounded-md px-2.5 py-2 text-sm font-normal text-slate-300 hover:bg-white/5 hover:text-white',
          active: 'bg-primary-800 font-medium text-white hover:bg-primary-800',
          icon: { base: 'h-5 w-5 text-slate-400 group-hover:text-white', active: 'text-white' },
        },
      }}>
      <SidebarItems>
        {secciones.map((s) => (
          <SidebarItemGroup key={s.titulo}>
            <li className="rotulo px-2.5 pb-1.5 text-slate-400">{s.titulo}</li>
            {s.items.map((i) => (
              <SidebarItem key={i.to} as={RouterLink} href={i.to} icon={i.icon}
                active={activo(i.to)} onClick={() => setMenuAbierto(false)}>
                {i.label}
              </SidebarItem>
            ))}
          </SidebarItemGroup>
        ))}
      </SidebarItems>
    </Sidebar>
  )

  const usuario = (
    <div className="p-4 border-t border-[var(--marino-linea)] flex items-center gap-3">
      <Avatar placeholderInitials={iniciales(user?.nombre)} rounded size="sm"
        theme={{ root: { initials: { base: 'bg-primary-700', text: 'font-semibold text-white' } } }} />
      <div className="min-w-0 flex-1">
        <div className="text-sm font-medium text-white truncate">{user?.nombre}</div>
        <div className="text-xs text-slate-400 truncate">{user?.rol}</div>
      </div>
      <button type="button" onClick={salir} title="Cerrar sesión" aria-label="Cerrar sesión"
        className="inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-md border border-[#2b4a6b]
                   text-slate-300 hover:bg-white/5 hover:text-white focus:outline-none focus:ring-2 focus:ring-primary-400">
        <HiLogout className="h-4 w-4" />
      </button>
    </div>
  )

  return (
    <div className="min-h-screen md:flex">
      {/* Escritorio: menú lateral fijo */}
      <aside className="hidden md:flex md:flex-col md:w-64 md:shrink-0 md:h-screen md:sticky md:top-0 bg-[var(--marino)]">
        <div className="h-28 flex items-center px-4 border-b border-[var(--marino-linea)]"><Logo alto="h-16" /></div>
        <div className="flex-1 min-h-0">{menu}</div>
        {usuario}
      </aside>

      {/* Móvil: barra superior + menú desplegable */}
      <Navbar fluid className="md:hidden sticky top-0 z-30 bg-[var(--marino)] border-b border-[var(--marino-linea)]">
        <div className="flex max-w-52"><Logo alto="h-9" /></div>
        <Button color="light" size="sm" onClick={() => setMenuAbierto(true)} aria-label="Abrir menú">
          <HiMenu className="h-5 w-5" />
        </Button>
      </Navbar>
      <Drawer open={menuAbierto} onClose={() => setMenuAbierto(false)}
        className="md:hidden p-0 w-72 bg-[var(--marino)]">
        <div className="h-28 flex items-center px-4 border-b border-[var(--marino-linea)]"><Logo alto="h-16" /></div>
        <DrawerItems className="flex flex-col h-[calc(100%-7rem)]">
          <div className="flex-1">{menu}</div>
          {usuario}
        </DrawerItems>
      </Drawer>

      <main className="flex-1 min-w-0">
        <div className="hidden md:flex items-center gap-4 h-14 px-8 bg-white border-b border-gray-200">
          <div className="text-sm text-gray-500">
            {actual
              ? <>{actual.seccion} · <span className="font-medium text-gray-900">{actual.label}</span></>
              : 'LabQuim'}
          </div>
          <div className="ms-auto font-mono text-xs text-gray-500 first-letter:uppercase">{hoy()}</div>
        </div>
        <div className="max-w-6xl mx-auto px-4 py-6 md:px-8 md:py-8">
          <Outlet />
        </div>
      </main>
    </div>
  )
}
