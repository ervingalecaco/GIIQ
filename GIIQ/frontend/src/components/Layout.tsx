import { forwardRef, useState, type ComponentProps, type FC } from 'react'
import { Link, Outlet, useLocation, useNavigate } from 'react-router-dom'
import {
  Avatar, Button, Drawer, DrawerItems, Navbar,
  Sidebar, SidebarItem, SidebarItemGroup, SidebarItems,
} from 'flowbite-react'
import {
  HiBeaker, HiChartBar, HiChartPie, HiChevronDoubleLeft, HiChevronDoubleRight, HiClipboardList, HiCube, HiDatabase, HiIdentification,
  HiLogout, HiMenu, HiMinusCircle, HiShieldCheck, HiTag, HiUserGroup, HiUsers,
} from 'react-icons/hi'
import { TbTestPipe } from 'react-icons/tb'
import { useAuth } from '../auth/AuthContext'
import { Campana } from './Campana'
import { useEmblemaMenu, useLogoMenu } from '../logo'
import { SISTEMA } from '../sistema'

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

/**
 * Logo sobre el fondo marino: la versión con letras blancas (el de letras marino no contrasta).
 * `soloMarca`: menú contraído, solo el ícono del matraz.
 */
function Logo({ alto = 'h-12', soloMarca = false }: { alto?: string; soloMarca?: boolean }) {
  const logo = useLogoMenu()
  const emblema = useEmblemaMenu()
  if (soloMarca) {
    return emblema
      ? (
        <Link to="/" aria-label="Inicio" title={SISTEMA.nombre} className="inline-flex h-10 w-10 items-center justify-center">
          <img src={emblema} alt="" className="h-full w-full object-contain" />
        </Link>
      )
      : (
        <Link to="/" aria-label="Inicio" title={SISTEMA.nombre}
          className="inline-flex h-9 w-9 items-center justify-center rounded-md bg-primary-600">
          <HiBeaker className="h-5 w-5 text-white" />
        </Link>
      )
  }
  return (
    <Link to="/" className="flex flex-1 items-center gap-3" aria-label="Inicio">
      {logo !== undefined ? (
        <span className={`flex flex-1 justify-center ${alto}`}>
          {logo && <img src={logo} alt={SISTEMA.nombre} className="h-full max-w-full w-auto object-contain" />}
        </span>
      ) : (
        <>
          <span className="inline-flex h-9 w-9 items-center justify-center rounded-md bg-primary-600">
            <HiBeaker className="h-5 w-5 text-white" />
          </span>
          <span>
            <span className="block text-[17px] font-bold tracking-wide text-white">{SISTEMA.nombre}</span>
            <span className="block text-[11px] leading-tight text-slate-400">{SISTEMA.nombreCompleto}</span>
          </span>
        </>
      )}
    </Link>
  )
}

function iniciales(nombre?: string) {
  return (nombre ?? '?').split(' ').filter(Boolean).slice(0, 2).map((p) => p[0]).join('').toUpperCase()
}

const CLAVE_CONTRAIDO = 'giiq.menuContraido'
function leerContraido() {
  try { return localStorage.getItem(CLAVE_CONTRAIDO) === '1' } catch { return false }
}

const hoy = () => new Date().toLocaleDateString('es', { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' })

export function Layout() {
  const { user, logout, hasPerm } = useAuth()
  const navigate = useNavigate()
  const { pathname } = useLocation()
  const [menuAbierto, setMenuAbierto] = useState(false)
  // Escritorio: menú contraído a solo íconos (preferencia guardada en este navegador).
  const [contraido, setContraido] = useState(leerContraido)
  function alternarMenu() {
    const nuevo = !contraido
    setContraido(nuevo)
    try { localStorage.setItem(CLAVE_CONTRAIDO, nuevo ? '1' : '0') } catch { /* sin almacenamiento: solo esta vez */ }
  }

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

  const menu = (chico: boolean) => (
    <Sidebar aria-label="Menú principal" className="w-full" collapsed={chico}
      theme={{
        root: {
          inner: `sin-barra h-full overflow-y-auto overflow-x-hidden bg-[var(--marino)] py-4 rounded-none ${chico ? 'px-2' : 'px-3'}`,
          collapsed: { on: 'w-full', off: 'w-full' },
        },
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
            {chico
              ? <li className="mx-2 mb-2 border-t border-white/10" aria-hidden />
              : <li className="rotulo px-2.5 pb-1.5 text-slate-400">{s.titulo}</li>}
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

  const usuario = (chico: boolean) => (
    <div className={`border-t border-[var(--marino-linea)] flex items-center gap-3 ${chico ? 'flex-col py-3' : 'p-4'}`}>
      <Avatar placeholderInitials={iniciales(user?.nombre)} rounded size="sm" title={chico ? `${user?.nombre} · ${user?.rol}` : undefined}
        theme={{ root: { initials: { base: 'bg-primary-700', text: 'font-semibold text-white' } } }} />
      {!chico && (
        <div className="min-w-0 flex-1">
          <div className="text-sm font-medium text-white truncate">{user?.nombre}</div>
          <div className="text-xs text-slate-400 truncate">{user?.rol}</div>
        </div>
      )}
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
      <aside className={`hidden md:flex md:flex-col md:shrink-0 md:h-screen md:sticky md:top-0 bg-[var(--marino)]
                         transition-[width] duration-200 ${contraido ? 'md:w-[68px]' : 'md:w-60'}`}>
        <div className={`h-14 flex items-center border-b border-[var(--marino-linea)] ${contraido ? 'justify-center' : 'px-4'}`}>
          <Logo alto="h-10" soloMarca={contraido} />
        </div>
        <div className="flex-1 min-h-0">{menu(contraido)}</div>
        {usuario(contraido)}
      </aside>

      {/* Móvil: barra superior + menú desplegable */}
      <Navbar fluid className="md:hidden sticky top-0 z-30 bg-[var(--marino)] border-b border-[var(--marino-linea)]">
        <div className="flex max-w-52"><Logo alto="h-11" /></div>
        <div className="flex items-center gap-2">
          <Campana oscura />
          <Button color="light" size="sm" onClick={() => setMenuAbierto(true)} aria-label="Abrir menú">
            <HiMenu className="h-5 w-5" />
          </Button>
        </div>
      </Navbar>
      <Drawer open={menuAbierto} onClose={() => setMenuAbierto(false)}
        className="md:hidden p-0 w-72 bg-[var(--marino)]">
        <div className="h-20 flex items-center px-4 border-b border-[var(--marino-linea)]"><Logo alto="h-14" /></div>
        <DrawerItems className="flex flex-col h-[calc(100%-5rem)]">
          <div className="flex-1">{menu(false)}</div>
          {usuario(false)}
        </DrawerItems>
      </Drawer>

      <main className="flex-1 min-w-0">
        <div className="hidden md:flex items-center gap-4 h-14 ps-4 pe-8 bg-white border-b border-gray-200">
          <button type="button" onClick={alternarMenu} aria-expanded={!contraido}
            aria-label={contraido ? 'Expandir menú' : 'Contraer menú'} title={contraido ? 'Expandir menú' : 'Contraer menú'}
            className="inline-flex h-9 w-9 items-center justify-center rounded-md text-gray-500 hover:bg-gray-100 hover:text-gray-900
                       focus:outline-none focus-visible:ring-2 focus-visible:ring-primary-300">
            {contraido ? <HiChevronDoubleRight className="h-5 w-5" /> : <HiChevronDoubleLeft className="h-5 w-5" />}
          </button>
          <div className="text-sm text-gray-500">
            {actual
              ? <>{actual.seccion} · <span className="font-medium text-gray-900">{actual.label}</span></>
              : pathname.startsWith('/notificaciones')
                ? <span className="font-medium text-gray-900">Notificaciones</span>
                : SISTEMA.nombre}
          </div>
          <div className="ms-auto flex items-center gap-4">
            <span className="font-mono text-xs text-gray-500 first-letter:uppercase">{hoy()}</span>
            <Campana />
          </div>
        </div>
        <div className="max-w-6xl mx-auto px-4 py-6 md:px-8 md:py-8">
          <Outlet />
        </div>
      </main>
    </div>
  )
}
