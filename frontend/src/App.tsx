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
import { ReportesPage } from './pages/ReportesPage'
import { RespaldosPage } from './pages/RespaldosPage'

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />

      <Route element={<ProtectedRoute />}>
        <Route element={<Layout />}>
          <Route index element={<DashboardPage />} />

          <Route element={<ProtectedRoute perm="solicitud.ver" />}>
            <Route path="solicitudes" element={<SolicitudesPage />} />
          </Route>
          <Route element={<ProtectedRoute perm="solicitud.crear" />}>
            <Route path="solicitudes/nueva" element={<NuevaSolicitudPage />} />
          </Route>
          <Route element={<ProtectedRoute perm="articulos.ver" />}>
            <Route path="articulos" element={<ArticulosPage />} />
          </Route>
          <Route element={<ProtectedRoute perm="inventario.ver" />}>
            <Route path="inventario" element={<InventarioPage />} />
          </Route>
          <Route element={<ProtectedRoute perm="reporte.ver" />}>
            <Route path="reportes" element={<ReportesPage />} />
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
