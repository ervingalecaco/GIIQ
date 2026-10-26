import { lazy, Suspense } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import { ProtectedRoute } from './auth/ProtectedRoute'
import { Layout } from './components/Layout'
import { LoginPage } from './pages/LoginPage'
import { DashboardPage } from './pages/DashboardPage'
import { SolicitudesPage } from './pages/SolicitudesPage'
import { NuevaSolicitudPage } from './pages/NuevaSolicitudPage'
import { InventarioPage } from './pages/InventarioPage'
import { ArticulosPage } from './pages/ArticulosPage'
import { UsuariosPage } from './pages/UsuariosPage'
import { RolesPage } from './pages/RolesPage'
import { CatalogosPage } from './pages/CatalogosPage'
import { RespaldosPage } from './pages/RespaldosPage'
import { BajasPage } from './pages/BajasPage'
import { CuentaEstudiantePage, CuentasPage, MiCuentaPage } from './pages/CuentasPage'
import { ConstanciaPage } from './pages/ConstanciaPage'
import { NotificacionesPage } from './pages/NotificacionesPage'
import { Cargando } from './components/Feedback'

// Reportes usa AG Grid (pesado): se descarga solo al abrir esa pantalla.
const ReportesPage = lazy(() => import('./pages/ReportesPage').then((m) => ({ default: m.ReportesPage })))

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />

      <Route element={<ProtectedRoute />}>
        {/* Documento imprimible: fuera del menú para que la hoja salga limpia. */}
        <Route element={<ProtectedRoute perm="solvencia.emitir" />}>
          <Route path="constancias/:folio" element={<ConstanciaPage />} />
        </Route>
        <Route element={<Layout />}>
          <Route index element={<DashboardPage />} />
          <Route path="notificaciones" element={<NotificacionesPage />} />

          <Route element={<ProtectedRoute perm="solicitud.ver" />}>
            <Route path="solicitudes" element={<Navigate to="/solicitudes/reactivos" replace />} />
            <Route path="solicitudes/reactivos" element={<SolicitudesPage key="R" tipo="REACTIVO" />} />
            <Route path="solicitudes/cristaleria" element={<SolicitudesPage key="C" tipo="CRISTALERIA" />} />
          </Route>
          <Route element={<ProtectedRoute perm="solicitud.crear" />}>
            <Route path="solicitudes/reactivos/nueva" element={<NuevaSolicitudPage key="R" tipo="REACTIVO" />} />
            <Route path="solicitudes/cristaleria/nueva" element={<NuevaSolicitudPage key="C" tipo="CRISTALERIA" />} />
          </Route>
          <Route element={<ProtectedRoute perm="cuentas.ver" />}>
            <Route path="bajas" element={<BajasPage />} />
            <Route path="cuentas" element={<CuentasPage />} />
            <Route path="cuentas/:id" element={<CuentaEstudiantePage />} />
          </Route>
          <Route element={<ProtectedRoute perm="cuenta.propia" />}>
            <Route path="mi-cuenta" element={<MiCuentaPage />} />
          </Route>
          <Route element={<ProtectedRoute perm="articulos.ver" />}>
            <Route path="reactivos" element={<ArticulosPage tipo="REACTIVO" />} />
            <Route path="cristaleria" element={<ArticulosPage tipo="CRISTALERIA" />} />
            <Route path="articulos" element={<Navigate to="/reactivos" replace />} />
          </Route>
          <Route element={<ProtectedRoute perm="inventario.ver" />}>
            <Route path="inventario" element={<InventarioPage />} />
          </Route>
          <Route element={<ProtectedRoute perm="reporte.ver" />}>
            <Route path="reportes" element={<Suspense fallback={<Cargando />}><ReportesPage /></Suspense>} />
          </Route>
          <Route element={<ProtectedRoute perm="catalogos.ver" />}>
            <Route path="catalogos" element={<CatalogosPage />} />
          </Route>
          <Route element={<ProtectedRoute perm="usuarios.ver" />}>
            <Route path="usuarios" element={<UsuariosPage />} />
          </Route>
          <Route element={<ProtectedRoute perm="roles.gestionar" />}>
            <Route path="roles" element={<RolesPage />} />
          </Route>
          <Route element={<ProtectedRoute perm="respaldo.gestionar" />}>
            <Route path="respaldos" element={<RespaldosPage />} />
          </Route>
        </Route>
      </Route>

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}
