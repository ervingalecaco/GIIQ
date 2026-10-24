import { useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  Badge, Button, TabItem, Table, TableBody, TableCell, TableHead, TableHeadCell, TableRow, Tabs,
} from 'flowbite-react'
import { HiPlus } from 'react-icons/hi'
import { usuariosApi } from '../api/admin'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'
import { UsuarioFormModal } from '../components/UsuarioFormModal'
import { ActivoBadge, Cargando, ErrorAlert, PageHeader } from '../components/Feedback'
import { Paginador, usePaginacion } from '../components/Paginacion'
import type { UsuarioAdmin } from '../types'

const TODOS = '__todos__'

/** Roles que deben tener código (de estudiante o de profesor). */
const CODIGO_REQUERIDO = ['Profesor', 'Estudiante']

type EstadoVista = 'activos' | 'inactivos' | 'todos'
const ESTADOS: { key: EstadoVista; label: string }[] = [
  { key: 'activos', label: 'Activos' },
  { key: 'inactivos', label: 'Inactivos' },
  { key: 'todos', label: 'Todos' },
]

/** Roles del sistema en el orden del flujo, con su nombre en plural para las pestañas. */
const ROLES = [
  { nombre: 'Administrador', plural: 'Administradores' },
  { nombre: 'Supervisor', plural: 'Supervisores' },
  { nombre: 'Profesor', plural: 'Profesores' },
  { nombre: 'Bodega', plural: 'Bodega' },
  { nombre: 'Estudiante', plural: 'Estudiantes' },
]

export function UsuariosPage() {
  const { hasPerm } = useAuth()
  const qc = useQueryClient()
  const [form, setForm] = useState<UsuarioAdmin | 'nuevo' | null>(null)

  const { data, isLoading, error } = useQuery({ queryKey: ['usuarios'], queryFn: usuariosApi.list })

  // Pestañas por rol: los 5 roles del sistema en orden del flujo, más cualquier rol extra que exista.
  const [vista, setVista] = useState<string>(TODOS)
  const roles = [
    ...ROLES.map((r) => r.nombre),
    ...[...new Set((data ?? []).map((u) => u.rol))].filter((r) => !ROLES.some((x) => x.nombre === r)),
  ]
  // Segunda fila: estado. Ambos filtros se combinan (ej. Profesores + Inactivos).
  const [estadoVista, setEstadoVista] = useState<EstadoVista>('activos')
  const deRol = (u: UsuarioAdmin, rol: string) => rol === TODOS || u.rol === rol
  const deEstado = (u: UsuarioAdmin, e: EstadoVista) => e === 'todos' || u.activo === (e === 'activos')

  // Cada contador respeta el filtro de la otra fila.
  const pestanas = [
    { key: TODOS, label: 'Todos' },
    ...roles.map((r) => ({ key: r, label: ROLES.find((x) => x.nombre === r)?.plural ?? r })),
  ].map((p) => ({ ...p, n: data?.filter((u) => deRol(u, p.key) && deEstado(u, estadoVista)).length ?? 0 }))
  const estados = ESTADOS.map((e) => ({
    ...e, n: data?.filter((u) => deRol(u, vista) && deEstado(u, e.key)).length ?? 0,
  }))
  const visibles = data?.filter((u) => deRol(u, vista) && deEstado(u, estadoVista))
  const pag = usePaginacion(visibles, [vista, estadoVista])

  const estado = useMutation({
    mutationFn: ({ id, activo }: { id: number; activo: boolean }) => usuariosApi.cambiarEstado(id, activo),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['usuarios'] }),
    onError: (e) => alert(apiError(e)),
  })

  const password = useMutation({
    mutationFn: ({ id, pwd }: { id: number; pwd: string }) => usuariosApi.cambiarPassword(id, pwd),
    onSuccess: () => alert('Contraseña actualizada.'),
    onError: (e) => alert(apiError(e)),
  })

  function resetPassword(u: UsuarioAdmin) {
    const pwd = window.prompt(`Nueva contraseña para ${u.usuario} (mín. 6):`)
    if (pwd && pwd.length >= 6) password.mutate({ id: u.id, pwd })
    else if (pwd !== null) alert('La contraseña debe tener al menos 6 caracteres.')
  }

  return (
    <div className="space-y-5">
      <PageHeader title="Usuarios">
        {hasPerm('usuarios.crear') && (
          <Button size="sm" onClick={() => setForm('nuevo')}>
            <HiPlus className="me-1.5 h-4 w-4" /> Nuevo usuario
          </Button>
        )}
      </PageHeader>

      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}

      {data && (
        <div className="space-y-3">
          <Tabs variant="underline" aria-label="Usuarios por rol" theme={{ tabpanel: 'hidden' }}
            onActiveTabChange={(i) => setVista(pestanas[i].key)}>
            {pestanas.map((p) => (
              <TabItem key={p.key} active={vista === p.key} title={`${p.label} (${p.n})`} />
            ))}
          </Tabs>
          <Tabs variant="pills" aria-label="Usuarios por estado" theme={{ tabpanel: 'hidden' }}
            onActiveTabChange={(i) => setEstadoVista(ESTADOS[i].key)}>
            {estados.map((e) => (
              <TabItem key={e.key} active={estadoVista === e.key} title={`${e.label} (${e.n})`} />
            ))}
          </Tabs>
        </div>
      )}

      {visibles && (
        <Table hoverable>
          <TableHead>
            <TableRow>
              <TableHeadCell>Nombre</TableHeadCell>
              <TableHeadCell>Usuario</TableHeadCell>
              <TableHeadCell>Código</TableHeadCell>
              {vista === TODOS && <TableHeadCell>Rol</TableHeadCell>}
              <TableHeadCell>Email</TableHeadCell>
              <TableHeadCell>Estado</TableHeadCell>
              <TableHeadCell className="text-right">Acciones</TableHeadCell>
            </TableRow>
          </TableHead>
          <TableBody className="divide-y">
            {visibles.length === 0 && (
              <TableRow>
                <TableCell colSpan={vista === TODOS ? 7 : 6} className="text-center text-gray-400">
                  {estadoVista === 'inactivos' ? 'No hay usuarios inactivos aquí.' : 'No hay usuarios con este rol.'}
                </TableCell>
              </TableRow>
            )}
            {pag.visibles?.map((u) => (
              <TableRow key={u.id} className={`bg-white ${!u.activo && estadoVista === 'todos' ? 'opacity-60' : ''}`}>
                <TableCell className="text-gray-900 font-medium">{u.nombreCompleto}</TableCell>
                <TableCell className="font-mono text-xs">{u.usuario}</TableCell>
                <TableCell className="font-mono text-xs">
                  {u.codigo ?? (CODIGO_REQUERIDO.includes(u.rol)
                    ? <span className="font-sans text-amber-700" title="Edita el usuario para asignarle su código">Sin código</span>
                    : <span className="text-gray-400">—</span>)}
                </TableCell>
                {vista === TODOS && <TableCell><Badge color="blue" className="w-fit">{u.rol}</Badge></TableCell>}
                <TableCell>{u.email ?? '—'}</TableCell>
                <TableCell><ActivoBadge activo={u.activo} /></TableCell>
                <TableCell>
                  <div className="flex gap-2 justify-end">
                    {hasPerm('usuarios.editar') && (
                      <>
                        <Button size="xs" color="light" onClick={() => setForm(u)}>Editar</Button>
                        <Button size="xs" color="light" onClick={() => resetPassword(u)}>Clave</Button>
                      </>
                    )}
                    {hasPerm('usuarios.eliminar') && (
                      <Button size="xs" color="light" disabled={estado.isPending}
                        onClick={() => estado.mutate({ id: u.id, activo: !u.activo })}>
                        {u.activo ? 'Desactivar' : 'Activar'}
                      </Button>
                    )}
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
      {visibles && <Paginador p={pag} nombre="usuarios" />}

      {form !== null && (
        <UsuarioFormModal
          usuario={form}
          rolInicial={vista === TODOS ? undefined : vista}
          onClose={() => setForm(null)}
          onSaved={() => { setForm(null); qc.invalidateQueries({ queryKey: ['usuarios'] }) }}
        />
      )}
    </div>
  )
}
