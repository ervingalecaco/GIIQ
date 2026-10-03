import { useQuery } from '@tanstack/react-query'
import { inventarioApi } from '../api/catalogos'
import { apiError } from '../api/client'

export function InventarioPage() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['existencias'],
    queryFn: inventarioApi.existencias,
  })

  return (
    <div className="space-y-5">
      <h1 className="text-2xl font-semibold">Inventario — existencias</h1>

      {isLoading && <p className="text-slate-500">Cargando…</p>}
      {error && <p className="text-rose-600">{apiError(error)}</p>}

      {data && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-left">
              <tr>
                <th className="px-4 py-2.5 font-medium">Código</th>
                <th className="px-4 py-2.5 font-medium">Artículo</th>
                <th className="px-4 py-2.5 font-medium">Tipo</th>
                <th className="px-4 py-2.5 font-medium text-right">Existencia</th>
                <th className="px-4 py-2.5 font-medium text-right">Mínimo</th>
                <th className="px-4 py-2.5 font-medium">Estado</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {data.map((e) => (
                <tr key={e.articuloId} className="hover:bg-slate-50">
                  <td className="px-4 py-2.5 font-mono text-xs">{e.codigo}</td>
                  <td className="px-4 py-2.5">{e.nombre}</td>
                  <td className="px-4 py-2.5 text-slate-500">{e.tipo}</td>
                  <td className="px-4 py-2.5 text-right tabular-nums">{e.existencia} {e.unidad}</td>
                  <td className="px-4 py-2.5 text-right tabular-nums text-slate-500">{e.stockMinimo}</td>
                  <td className="px-4 py-2.5">
                    {e.bajoMinimo
                      ? <span className="text-xs font-medium text-rose-600">Bajo mínimo</span>
                      : <span className="text-xs text-emerald-600">OK</span>}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
