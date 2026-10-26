import { useMemo, useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Alert, Button, Card, Checkbox, Label, ListGroup, ListGroupItem, Spinner } from 'flowbite-react'
import { HiInformationCircle } from 'react-icons/hi'
import { rolesApi } from '../api/admin'
import { apiError } from '../api/client'
import { Cargando, ErrorAlert, PageHeader } from '../components/Feedback'
import type { Permiso } from '../types'
import { useDialogos } from '../components/Dialogos'

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

  const { avisar } = useDialogos()
  const guardar = useMutation({
    mutationFn: () => rolesApi.setPermisos(selId!, [...checked]),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['roles'] })
      avisar('Permisos actualizados. Los usuarios de ese rol los verán al volver a iniciar sesión.', 'exito')
    },
    onError: (e) => avisar(apiError(e), 'error'),
  })

  return (
    <div className="space-y-5">
      <PageHeader title="Roles y permisos" />

      {roles.isLoading && <Cargando />}
      {roles.error && <ErrorAlert error={roles.error} />}

      <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
        {/* Lista de roles */}
        {roles.data && (
          <ListGroup className="h-fit w-full">
            {roles.data.map((r) => (
              <ListGroupItem key={r.id} active={selId === r.id} onClick={() => seleccionar(r.id)}>
                <div className="text-left">
                  <div className="font-semibold">{r.nombre}</div>
                  <div className="text-xs font-normal opacity-75">{r.permisos.length} permisos · {r.descripcion}</div>
                </div>
              </ListGroupItem>
            ))}
          </ListGroup>
        )}

        {/* Editor de permisos */}
        <div className="md:col-span-2">
          {!rolSel && (
            <Alert color="info" icon={HiInformationCircle}>
              Selecciona un rol para ver y editar sus permisos.
            </Alert>
          )}
          {rolSel && (
            <Card>
              <div className="flex items-center justify-between gap-3 flex-wrap">
                <h2 className="text-lg font-semibold text-gray-900">Permisos de «{rolSel.nombre}»</h2>
                <Button size="sm" onClick={() => guardar.mutate()} disabled={guardar.isPending || esAdmin}>
                  {guardar.isPending ? <><Spinner size="sm" light className="me-2" /> Guardando…</> : 'Guardar cambios'}
                </Button>
              </div>

              {esAdmin && (
                <Alert color="warning" icon={HiInformationCircle}>
                  El rol Administrador siempre tiene acceso total; sus permisos no se editan.
                </Alert>
              )}

              <div className="space-y-4">
                {porModulo.map(([modulo, lista]) => (
                  <fieldset key={modulo} className="border border-gray-200 rounded-lg p-4">
                    <legend className="text-xs font-semibold uppercase tracking-wide text-gray-500 px-1">{modulo}</legend>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                      {lista.map((p) => (
                        <div key={p.codigo} className={`flex items-start gap-2 ${esAdmin ? 'opacity-60' : ''}`}>
                          <Checkbox id={`perm-${p.codigo}`} className="mt-0.5" disabled={esAdmin}
                            checked={esAdmin || checked.has(p.codigo)}
                            onChange={() => toggle(p.codigo)} />
                          <Label htmlFor={`perm-${p.codigo}`} className="leading-tight font-normal">
                            <span className="block text-sm text-gray-700">{p.descripcion ?? p.codigo}</span>
                            <span className="block font-mono text-[11px] text-gray-400">{p.codigo}</span>
                          </Label>
                        </div>
                      ))}
                    </div>
                  </fieldset>
                ))}
              </div>
            </Card>
          )}
        </div>
      </div>
    </div>
  )
}
