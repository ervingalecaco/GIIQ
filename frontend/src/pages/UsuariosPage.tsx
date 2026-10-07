import { useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  Badge, Button, Table, TableBody, TableCell, TableHead, TableHeadCell, TableRow,
} from 'flowbite-react'
import { HiPlus } from 'react-icons/hi'
import { usuariosApi } from '../api/admin'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'
import { UsuarioFormModal } from '../components/UsuarioFormModal'
import { ActivoBadge, Cargando, ErrorAlert, PageHeader } from '../components/Feedback'
import type { UsuarioAdmin } from '../types'

export function UsuariosPage() {
  const { hasPerm } = useAuth()
  const qc = useQueryClient()
  const [form, setForm] = useState<UsuarioAdmin | 'nuevo' | null>(null)

  const { data, isLoading, error } = useQuery({ queryKey: ['usuarios'], queryFn: usuariosApi.list })

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
        <Table hoverable>
          <TableHead>
            <TableRow>
              <TableHeadCell>Nombre</TableHeadCell>
              <TableHeadCell>Usuario</TableHeadCell>
              <TableHeadCell>Rol</TableHeadCell>
              <TableHeadCell>Email</TableHeadCell>
              <TableHeadCell>Estado</TableHeadCell>
              <TableHeadCell className="text-right">Acciones</TableHeadCell>
            </TableRow>
          </TableHead>
          <TableBody className="divide-y">
            {data.map((u) => (
              <TableRow key={u.id} className={`bg-white ${!u.activo ? 'opacity-60' : ''}`}>
                <TableCell className="text-gray-900 font-medium">{u.nombreCompleto}</TableCell>
                <TableCell className="font-mono text-xs">{u.usuario}</TableCell>
                <TableCell><Badge color="indigo" className="w-fit">{u.rol}</Badge></TableCell>
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

      {form !== null && (
        <UsuarioFormModal
          usuario={form}
          onClose={() => setForm(null)}
          onSaved={() => { setForm(null); qc.invalidateQueries({ queryKey: ['usuarios'] }) }}
        />
      )}
    </div>
  )
}
