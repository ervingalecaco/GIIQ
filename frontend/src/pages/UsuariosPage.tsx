import { useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { usuariosApi } from '../api/admin'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'
import { UsuarioFormModal } from '../components/UsuarioFormModal'
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
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <h1 className="text-2xl font-semibold">Usuarios</h1>
        {hasPerm('usuarios.crear') && (
          <button onClick={() => setForm('nuevo')}
            className="rounded-md bg-teal-700 text-white px-4 py-1.5 text-sm font-medium hover:bg-teal-800">
            Nuevo usuario
          </button>
        )}
      </div>

      {isLoading && <p className="text-slate-500">Cargando…</p>}
      {error && <p className="text-rose-600">{apiError(error)}</p>}

      {data && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-left">
              <tr>
                <th className="px-4 py-2.5 font-medium">Nombre</th>
                <th className="px-4 py-2.5 font-medium">Usuario</th>
                <th className="px-4 py-2.5 font-medium">Rol</th>
                <th className="px-4 py-2.5 font-medium">Email</th>
                <th className="px-4 py-2.5 font-medium">Estado</th>
                <th className="px-4 py-2.5 font-medium text-right">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {data.map((u) => (
                <tr key={u.id} className={`hover:bg-slate-50 ${!u.activo ? 'opacity-50' : ''}`}>
                  <td className="px-4 py-2.5">{u.nombreCompleto}</td>
                  <td className="px-4 py-2.5 font-mono text-xs">{u.usuario}</td>
                  <td className="px-4 py-2.5 text-slate-500">{u.rol}</td>
                  <td className="px-4 py-2.5 text-slate-500">{u.email ?? '—'}</td>
                  <td className="px-4 py-2.5">
                    {u.activo
                      ? <span className="text-xs text-emerald-600">Activo</span>
                      : <span className="text-xs text-slate-400">Inactivo</span>}
                  </td>
                  <td className="px-4 py-2.5">
                    <div className="flex gap-2 justify-end">
                      {hasPerm('usuarios.editar') && (
                        <>
                          <button onClick={() => setForm(u)}
                            className="rounded-md border border-slate-300 px-3 py-1 text-xs hover:bg-slate-100">Editar</button>
                          <button onClick={() => resetPassword(u)}
                            className="rounded-md border border-slate-300 px-3 py-1 text-xs hover:bg-slate-100">Clave</button>
                        </>
                      )}
                      {hasPerm('usuarios.eliminar') && (
                        <button onClick={() => estado.mutate({ id: u.id, activo: !u.activo })}
                          disabled={estado.isPending}
                          className="rounded-md border border-slate-300 px-3 py-1 text-xs hover:bg-slate-100 disabled:opacity-50">
                          {u.activo ? 'Desactivar' : 'Activar'}
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
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
