import { useState, type FormEvent } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { catAdminApi, ENTIDADES, type CatRow, type EntidadCat } from '../api/catalogosAdmin'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'
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

  return (
    <div className="space-y-5">
      <h1 className="text-2xl font-semibold">Catálogos</h1>

      {/* Pestañas */}
      <div className="flex flex-wrap gap-1 border-b border-slate-200">
        {ENTIDADES.map((e) => (
          <button key={e.key}
            onClick={() => setEntidad(e)}
            className={`px-4 py-2 text-sm font-medium -mb-px border-b-2 ${
              entidad.key === e.key
                ? 'border-teal-600 text-teal-700'
                : 'border-transparent text-slate-500 hover:text-slate-700'
            }`}>
            {e.label}
          </button>
        ))}
      </div>

      <div className="flex justify-end">
        {puedeGestionar && (
          <button onClick={() => setEditar('nuevo')}
            className="rounded-md bg-teal-700 text-white px-4 py-1.5 text-sm font-medium hover:bg-teal-800">
            Nuevo
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
                {entidad.columnas.map((c) => <th key={c.name} className="px-4 py-2.5 font-medium">{c.label}</th>)}
                <th className="px-4 py-2.5 font-medium">Estado</th>
                {puedeGestionar && <th className="px-4 py-2.5 font-medium text-right">Acciones</th>}
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {data.length === 0 && (
                <tr><td colSpan={entidad.columnas.length + 2} className="px-4 py-6 text-center text-slate-400">Sin registros.</td></tr>
              )}
              {data.map((row) => (
                <tr key={row.id} className={`hover:bg-slate-50 ${!row.activo ? 'opacity-50' : ''}`}>
                  {entidad.columnas.map((c) => (
                    <td key={c.name} className="px-4 py-2.5">{String(row[c.name] ?? '—')}</td>
                  ))}
                  <td className="px-4 py-2.5">
                    {row.activo
                      ? <span className="text-xs text-emerald-600">Activo</span>
                      : <span className="text-xs text-slate-400">Inactivo</span>}
                  </td>
                  {puedeGestionar && (
                    <td className="px-4 py-2.5">
                      <div className="flex gap-2 justify-end">
                        <button onClick={() => setEditar(row)}
                          className="rounded-md border border-slate-300 px-3 py-1 text-xs hover:bg-slate-100">Editar</button>
                        <button onClick={() => estado.mutate({ id: row.id, activo: !row.activo })}
                          disabled={estado.isPending}
                          className="rounded-md border border-slate-300 px-3 py-1 text-xs hover:bg-slate-100 disabled:opacity-50">
                          {row.activo ? 'Desactivar' : 'Activar'}
                        </button>
                      </div>
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

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
    <Modal title={`${esNuevo ? 'Nuevo' : 'Editar'} — ${entidad.label}`} onClose={onClose}>
      <form onSubmit={onSubmit} className="space-y-4">
        {entidad.campos.map((c) => (
          <div key={c.name}>
            <label htmlFor={c.name} className="block text-sm font-medium text-slate-700 mb-1">
              {c.label}{c.required && ' *'}
            </label>
            <input id={c.name} type={c.type ?? 'text'} required={c.required}
              value={valores[c.name]}
              onChange={(e) => setValores((v) => ({ ...v, [c.name]: e.target.value }))}
              className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm" />
          </div>
        ))}
        {error && <p className="text-sm text-rose-600">{error}</p>}
        <div className="flex gap-3 pt-1">
          <button type="submit" disabled={saving}
            className="rounded-md bg-teal-700 text-white px-5 py-2 text-sm font-medium hover:bg-teal-800 disabled:opacity-50">
            {saving ? 'Guardando…' : 'Guardar'}
          </button>
          <button type="button" onClick={onClose}
            className="rounded-md border border-slate-300 px-5 py-2 text-sm hover:bg-slate-100">Cancelar</button>
        </div>
      </form>
    </Modal>
  )
}
