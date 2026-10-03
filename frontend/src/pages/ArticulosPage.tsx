import { useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { articulosApi } from '../api/catalogos'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'
import { ArticuloFormModal } from '../components/ArticuloFormModal'
import { EntradaFormModal } from '../components/EntradaFormModal'
import type { Articulo } from '../types'

export function ArticulosPage() {
  const { hasPerm } = useAuth()
  const qc = useQueryClient()
  const [tipo, setTipo] = useState('')
  const [editar, setEditar] = useState<number | 'nuevo' | null>(null)
  const [entrada, setEntrada] = useState<Articulo | null>(null)

  const { data, isLoading, error } = useQuery({
    queryKey: ['articulos', tipo || 'ALL'],
    queryFn: () => articulosApi.list(tipo || undefined),
  })

  const estado = useMutation({
    mutationFn: ({ id, activo }: { id: number; activo: boolean }) =>
      articulosApi.cambiarEstado(id, activo),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['articulos'] }),
    onError: (e) => alert(apiError(e)),
  })

  function refrescar() {
    qc.invalidateQueries({ queryKey: ['articulos'] })
    qc.invalidateQueries({ queryKey: ['existencias'] })
  }

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <h1 className="text-2xl font-semibold">Artículos</h1>
        <div className="flex items-center gap-3">
          <select value={tipo} onChange={(e) => setTipo(e.target.value)}
            className="rounded-md border border-slate-300 px-3 py-1.5 text-sm bg-white">
            <option value="">Todos</option>
            <option value="REACTIVO">Reactivos</option>
            <option value="MATERIAL">Materiales</option>
          </select>
          {hasPerm('articulos.crear') && (
            <button onClick={() => setEditar('nuevo')}
              className="rounded-md bg-teal-700 text-white px-4 py-1.5 text-sm font-medium hover:bg-teal-800">
              Nuevo artículo
            </button>
          )}
        </div>
      </div>

      {isLoading && <p className="text-slate-500">Cargando…</p>}
      {error && <p className="text-rose-600">{apiError(error)}</p>}

      {data && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-left">
              <tr>
                <th className="px-4 py-2.5 font-medium">Código</th>
                <th className="px-4 py-2.5 font-medium">Nombre</th>
                <th className="px-4 py-2.5 font-medium">Tipo</th>
                <th className="px-4 py-2.5 font-medium">Categoría</th>
                <th className="px-4 py-2.5 font-medium">Unidad</th>
                <th className="px-4 py-2.5 font-medium text-right">Mínimo</th>
                <th className="px-4 py-2.5 font-medium">Estado</th>
                <th className="px-4 py-2.5 font-medium text-right">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {data.length === 0 && (
                <tr><td colSpan={8} className="px-4 py-6 text-center text-slate-400">Sin artículos.</td></tr>
              )}
              {data.map((a) => (
                <tr key={a.id} className={`hover:bg-slate-50 ${!a.activo ? 'opacity-50' : ''}`}>
                  <td className="px-4 py-2.5 font-mono text-xs">{a.codigo}</td>
                  <td className="px-4 py-2.5">{a.nombre}</td>
                  <td className="px-4 py-2.5 text-slate-500">{a.tipo === 'REACTIVO' ? 'Reactivo' : 'Material'}</td>
                  <td className="px-4 py-2.5 text-slate-500">{a.categoria}</td>
                  <td className="px-4 py-2.5 text-slate-500">{a.unidad}</td>
                  <td className="px-4 py-2.5 text-right tabular-nums">{a.stockMinimo}</td>
                  <td className="px-4 py-2.5">
                    {a.activo
                      ? <span className="text-xs text-emerald-600">Activo</span>
                      : <span className="text-xs text-slate-400">Inactivo</span>}
                  </td>
                  <td className="px-4 py-2.5">
                    <div className="flex gap-2 justify-end">
                      {hasPerm('entrada.registrar') && a.activo && (
                        <button onClick={() => setEntrada(a)}
                          className="rounded-md bg-teal-600 text-white px-3 py-1 text-xs font-medium hover:opacity-90">
                          Ingresar
                        </button>
                      )}
                      {hasPerm('articulos.editar') && (
                        <button onClick={() => setEditar(a.id)}
                          className="rounded-md border border-slate-300 px-3 py-1 text-xs hover:bg-slate-100">
                          Editar
                        </button>
                      )}
                      {hasPerm('articulos.eliminar') && (
                        <button
                          onClick={() => estado.mutate({ id: a.id, activo: !a.activo })}
                          disabled={estado.isPending}
                          className="rounded-md border border-slate-300 px-3 py-1 text-xs hover:bg-slate-100 disabled:opacity-50">
                          {a.activo ? 'Desactivar' : 'Activar'}
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

      {editar !== null && (
        <ArticuloFormModal
          articuloId={editar}
          onClose={() => setEditar(null)}
          onSaved={() => { setEditar(null); refrescar() }}
        />
      )}

      {entrada && (
        <EntradaFormModal
          articulo={entrada}
          onClose={() => setEntrada(null)}
          onSaved={() => { setEntrada(null); refrescar() }}
        />
      )}
    </div>
  )
}
