import { useState, type FormEvent } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  Button, Label, Spinner, TabItem, Table, TableBody, TableCell, TableHead, TableHeadCell, TableRow,
  Tabs, TextInput,
} from 'flowbite-react'
import { HiPlus } from 'react-icons/hi'
import { catAdminApi, ENTIDADES, type CatRow, type EntidadCat } from '../api/catalogosAdmin'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'
import { ActivoBadge, Cargando, ErrorAlert, PageHeader } from '../components/Feedback'
import { Modal } from '../components/Modal'

export function CatalogosPage() {
  const { hasPerm } = useAuth()
  const qc = useQueryClient()
  const [entidad, setEntidad] = useState<EntidadCat>(ENTIDADES[0])
  const [editar, setEditar] = useState<CatRow | 'nuevo' | null>(null)
  const puedeGestionar = hasPerm('catalogos.gestionar')

  const { data, isLoading, error } = useQuery({
    queryKey: ['catalogo', entidad.key],
    queryFn: () => catAdminApi.list(entidad.key),
  })

  const estado = useMutation({
    mutationFn: ({ id, activo }: { id: number; activo: boolean }) =>
      catAdminApi.estado(entidad.key, id, activo),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['catalogo', entidad.key] }),
    onError: (e) => alert(apiError(e)),
  })

  const contenido = (
    <div className="space-y-4">
      {puedeGestionar && (
        <div className="flex justify-end">
          <Button size="sm" onClick={() => setEditar('nuevo')}>
            <HiPlus className="me-1.5 h-4 w-4" /> Nuevo
          </Button>
        </div>
      )}

      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}

      {data && (
        <Table hoverable>
          <TableHead>
            <TableRow>
              {entidad.columnas.map((c) => <TableHeadCell key={c.name}>{c.label}</TableHeadCell>)}
              <TableHeadCell>Estado</TableHeadCell>
              {puedeGestionar && <TableHeadCell className="text-right">Acciones</TableHeadCell>}
            </TableRow>
          </TableHead>
          <TableBody className="divide-y">
            {data.length === 0 && (
              <TableRow>
                <TableCell colSpan={entidad.columnas.length + 2} className="text-center text-gray-400">Sin registros.</TableCell>
              </TableRow>
            )}
            {data.map((row) => (
              <TableRow key={row.id} className={`bg-white ${!row.activo ? 'opacity-60' : ''}`}>
                {entidad.columnas.map((c, i) => (
                  <TableCell key={c.name} className={i === 0 ? 'text-gray-900 font-medium' : ''}>
                    {String(row[c.name] ?? '—')}
                  </TableCell>
                ))}
                <TableCell><ActivoBadge activo={row.activo} /></TableCell>
                {puedeGestionar && (
                  <TableCell>
                    <div className="flex gap-2 justify-end">
                      <Button size="xs" color="light" onClick={() => setEditar(row)}>Editar</Button>
                      <Button size="xs" color="light" disabled={estado.isPending}
                        onClick={() => estado.mutate({ id: row.id, activo: !row.activo })}>
                        {row.activo ? 'Desactivar' : 'Activar'}
                      </Button>
                    </div>
                  </TableCell>
                )}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  )

  return (
    <div className="space-y-5">
      <PageHeader title="Catálogos" />

      <Tabs variant="underline" onActiveTabChange={(i) => setEntidad(ENTIDADES[i])}>
        {ENTIDADES.map((e) => (
          <TabItem key={e.key} title={e.label} active={entidad.key === e.key}>
            {entidad.key === e.key && contenido}
          </TabItem>
        ))}
      </Tabs>

      {editar !== null && (
        <CatalogoFormModal
          entidad={entidad}
          registro={editar}
          onClose={() => setEditar(null)}
          onSaved={() => { setEditar(null); qc.invalidateQueries({ queryKey: ['catalogo', entidad.key] }) }}
        />
      )}
    </div>
  )
}

function CatalogoFormModal({ entidad, registro, onClose, onSaved }: {
  entidad: EntidadCat
  registro: CatRow | 'nuevo'
  onClose: () => void
  onSaved: () => void
}) {
  const esNuevo = registro === 'nuevo'
  const inicial: Record<string, string> = {}
  for (const c of entidad.campos)
    inicial[c.name] = esNuevo ? '' : String((registro as CatRow)[c.name] ?? '')

  const [valores, setValores] = useState<Record<string, string>>(inicial)
  const [error, setError] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setSaving(true)
    const payload: Record<string, unknown> = {}
    for (const c of entidad.campos) payload[c.name] = valores[c.name] || null
    try {
      if (esNuevo) await catAdminApi.crear(entidad.key, payload)
      else await catAdminApi.editar(entidad.key, (registro as CatRow).id, payload)
      onSaved()
    } catch (err) {
      setError(apiError(err, 'No se pudo guardar.'))
    } finally {
      setSaving(false)
    }
  }

  return (
    <Modal title={`${esNuevo ? 'Nuevo' : 'Editar'} — ${entidad.label}`} onClose={onClose} size="md">
      <form onSubmit={onSubmit} className="space-y-4">
        {entidad.campos.map((c) => (
          <div key={c.name}>
            <Label htmlFor={c.name} className="mb-2 block">
              {c.label}{c.required && ' *'}
            </Label>
            <TextInput id={c.name} type={c.type ?? 'text'} required={c.required}
              value={valores[c.name]}
              onChange={(e) => setValores((v) => ({ ...v, [c.name]: e.target.value }))} />
          </div>
        ))}
        {error && <ErrorAlert>{error}</ErrorAlert>}
        <div className="flex gap-3 pt-1">
          <Button type="submit" disabled={saving}>
            {saving ? <><Spinner size="sm" light className="me-2" /> Guardando…</> : 'Guardar'}
          </Button>
          <Button type="button" color="light" onClick={onClose}>Cancelar</Button>
        </div>
      </form>
    </Modal>
  )
}
