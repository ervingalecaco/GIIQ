import { useRef, useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { respaldosApi } from '../api/respaldos'
import { descargarArchivo } from '../api/reportes'
import { apiError } from '../api/client'

function tamano(bytes?: number | null): string {
  if (!bytes) return '—'
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / 1024 / 1024).toFixed(1)} MB`
}

export function RespaldosPage() {
  const qc = useQueryClient()
  const fileRef = useRef<HTMLInputElement>(null)
  const [archivo, setArchivo] = useState<File | null>(null)

  const { data, isLoading, error } = useQuery({ queryKey: ['respaldos'], queryFn: respaldosApi.list })

  const crear = useMutation({
    mutationFn: respaldosApi.crear,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['respaldos'] }),
    onError: (e) => alert(apiError(e)),
  })

  const restaurar = useMutation({
    mutationFn: (f: File) => respaldosApi.restore(f),
    onSuccess: () => {
      alert('Base de datos restaurada correctamente.')
      setArchivo(null)
      if (fileRef.current) fileRef.current.value = ''
      qc.invalidateQueries()
    },
    onError: (e) => alert(apiError(e)),
  })

  function confirmarRestaurar() {
    if (!archivo) return
    if (window.confirm(
      `¿Restaurar la base desde "${archivo.name}"?\n\n` +
      'ATENCIÓN: esto REEMPLAZA todos los datos actuales. Esta acción no se puede deshacer.'
    )) {
      restaurar.mutate(archivo)
    }
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-semibold">Respaldos</h1>

      {/* Crear respaldo */}
      <div className="bg-white rounded-xl border border-slate-200 p-5 flex items-center justify-between gap-3 flex-wrap">
        <div>
          <h2 className="font-semibold text-slate-700">Crear respaldo</h2>
          <p className="text-sm text-slate-500">Genera una copia completa de la base (incluye procedimientos).</p>
        </div>
        <button onClick={() => crear.mutate()} disabled={crear.isPending}
          className="rounded-md bg-teal-700 text-white px-4 py-2 text-sm font-medium hover:bg-teal-800 disabled:opacity-50">
          {crear.isPending ? 'Generando…' : 'Crear respaldo ahora'}
        </button>
      </div>

      {/* Restaurar */}
      <div className="bg-white rounded-xl border border-rose-200 p-5 space-y-3">
        <div>
          <h2 className="font-semibold text-rose-700">Restaurar</h2>
          <p className="text-sm text-slate-500">
            Sube un archivo <code className="font-mono text-xs">.sql</code> para restaurar.
            Reemplaza <strong>todos</strong> los datos actuales.
          </p>
        </div>
        <div className="flex items-center gap-3 flex-wrap">
          <input ref={fileRef} type="file" accept=".sql"
            onChange={(e) => setArchivo(e.target.files?.[0] ?? null)}
            className="text-sm" />
          <button onClick={confirmarRestaurar} disabled={!archivo || restaurar.isPending}
            className="rounded-md bg-rose-600 text-white px-4 py-2 text-sm font-medium hover:bg-rose-700 disabled:opacity-50">
            {restaurar.isPending ? 'Restaurando…' : 'Restaurar'}
          </button>
        </div>
      </div>

      {/* Historial */}
      <div>
        <h2 className="font-semibold text-slate-700 mb-3">Historial de respaldos</h2>
        {isLoading && <p className="text-slate-500">Cargando…</p>}
        {error && <p className="text-rose-600">{apiError(error)}</p>}
        {data && (
          <div className="bg-white rounded-xl border border-slate-200 overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-slate-50 text-slate-500 text-left">
                <tr>
                  <th className="px-4 py-2.5 font-medium">Archivo</th>
                  <th className="px-4 py-2.5 font-medium">Fecha</th>
                  <th className="px-4 py-2.5 font-medium">Usuario</th>
                  <th className="px-4 py-2.5 font-medium text-right">Tamaño</th>
                  <th className="px-4 py-2.5 font-medium text-right">Acciones</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {data.length === 0 && (
                  <tr><td colSpan={5} className="px-4 py-6 text-center text-slate-400">Aún no hay respaldos.</td></tr>
                )}
                {data.map((r) => (
                  <tr key={r.id} className="hover:bg-slate-50">
                    <td className="px-4 py-2.5 font-mono text-xs">{r.archivo}</td>
                    <td className="px-4 py-2.5 text-slate-500">{new Date(r.fecha).toLocaleString()}</td>
                    <td className="px-4 py-2.5 text-slate-500">{r.usuario ?? '—'}</td>
                    <td className="px-4 py-2.5 text-right tabular-nums">{tamano(r.tamanoBytes)}</td>
                    <td className="px-4 py-2.5 text-right">
                      <button onClick={() => descargarArchivo(`/api/respaldos/${r.id}/download`, r.archivo)}
                        className="rounded-md border border-slate-300 px-3 py-1 text-xs hover:bg-slate-100">
                        Descargar
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  )
}
