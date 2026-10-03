import { useMemo, useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { rolesApi } from '../api/admin'
import { apiError } from '../api/client'
import type { Permiso } from '../types'

export function RolesPage() {
  const qc = useQueryClient()
  const roles = useQuery({ queryKey: ['roles'], queryFn: rolesApi.roles })
  const permisos = useQuery({ queryKey: ['permisos'], queryFn: rolesApi.permisos })

  const [selId, setSelId] = useState<number | null>(null)
  const [checked, setChecked] = useState<Set<string>>(new Set())

  const porModulo = useMemo(() => {
    const map = new Map<string, Permiso[]>()
    for (const p of permisos.data ?? []) {
      const m = p.modulo ?? 'otros'
      if (!map.has(m)) map.set(m, [])
      map.get(m)!.push(p)
    }
    return [...map.entries()]
  }, [permisos.data])

  const rolSel = roles.data?.find((r) => r.id === selId)
  const esAdmin = rolSel?.nombre === 'Administrador'

  function seleccionar(id: number) {
    setSelId(id)
    const rol = roles.data?.find((r) => r.id === id)
    setChecked(new Set(rol?.permisos ?? []))
  }

  function toggle(codigo: string) {
    setChecked((prev) => {
      const next = new Set(prev)
      if (next.has(codigo)) next.delete(codigo); else next.add(codigo)
      return next
    })
  }

  const guardar = useMutation({
    mutationFn: () => rolesApi.setPermisos(selId!, [...checked]),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['roles'] })
      alert('Permisos actualizados.')
    },
    onError: (e) => alert(apiError(e)),
  })

  return (
    <div className="space-y-5">
      <h1 className="text-2xl font-semibold">Roles y permisos</h1>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
        {/* Lista de roles */}
        <div className="bg-white rounded-xl border border-slate-200 divide-y divide-slate-100 h-fit">
          {roles.data?.map((r) => (
            <button key={r.id} onClick={() => seleccionar(r.id)}
              className={`w-full text-left px-4 py-3 hover:bg-slate-50 ${selId === r.id ? 'bg-teal-50' : ''}`}>
              <div className="font-medium">{r.nombre}</div>
              <div className="text-xs text-slate-500">{r.permisos.length} permisos · {r.descripcion}</div>
            </button>
          ))}
        </div>

        {/* Editor de permisos */}
        <div className="md:col-span-2">
          {!rolSel && <p className="text-slate-500">Selecciona un rol para ver y editar sus permisos.</p>}
          {rolSel && (
            <div className="bg-white rounded-xl border border-slate-200 p-5 space-y-4">
              <div className="flex items-center justify-between">
                <h2 className="font-semibold">Permisos de «{rolSel.nombre}»</h2>
                <button onClick={() => guardar.mutate()} disabled={guardar.isPending || esAdmin}
                  className="rounded-md bg-teal-700 text-white px-4 py-1.5 text-sm font-medium hover:bg-teal-800 disabled:opacity-50">
                  {guardar.isPending ? 'Guardando…' : 'Guardar cambios'}
                </button>
              </div>

              {esAdmin && (
                <p className="text-xs text-amber-700 bg-amber-50 rounded-md px-3 py-2">
                  El rol Administrador siempre tiene acceso total; sus permisos no se editan.
                </p>
              )}

              <div className="space-y-4">
                {porModulo.map(([modulo, lista]) => (
                  <fieldset key={modulo} className="border border-slate-200 rounded-lg p-3">
                    <legend className="text-xs font-semibold uppercase tracking-wide text-slate-500 px-1">{modulo}</legend>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-1.5">
                      {lista.map((p) => (
                        <label key={p.codigo} className={`flex items-start gap-2 ${esAdmin ? 'opacity-60' : ''}`}>
                          <input type="checkbox" disabled={esAdmin}
                            checked={esAdmin || checked.has(p.codigo)}
                            onChange={() => toggle(p.codigo)}
                            className="mt-0.5 rounded border-slate-300 text-teal-600 focus:ring-teal-500" />
                          <span className="leading-tight">
                            <span className="block text-sm text-slate-700">{p.descripcion ?? p.codigo}</span>
                            <span className="block font-mono text-[11px] text-slate-400">{p.codigo}</span>
                          </span>
                        </label>
                      ))}
                    </div>
                  </fieldset>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
