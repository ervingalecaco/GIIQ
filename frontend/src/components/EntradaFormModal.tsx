import { useState, type FormEvent } from 'react'
import { useQuery } from '@tanstack/react-query'
import { catalogosApi, inventarioApi } from '../api/catalogos'
import { apiError } from '../api/client'
import { Modal } from './Modal'
import type { Articulo } from '../types'

const input = 'w-full rounded-md border border-slate-300 px-3 py-2 text-sm'
const label = 'block text-sm font-medium text-slate-700 mb-1'

export function EntradaFormModal({ articulo, onClose, onSaved }: {
  articulo: Articulo
  onClose: () => void
  onSaved: () => void
}) {
  const esReactivo = articulo.tipo === 'REACTIVO'
  const proveedores = useQuery({ queryKey: ['proveedores'], queryFn: catalogosApi.proveedores })
  const ubicaciones = useQuery({ queryKey: ['ubicaciones'], queryFn: catalogosApi.ubicaciones })

  const [cantidad, setCantidad] = useState('')
  const [codigoLote, setCodigoLote] = useState('')
  const [fechaVenc, setFechaVenc] = useState('')
  const [proveedorId, setProveedorId] = useState<number | ''>('')
  const [ubicacionId, setUbicacionId] = useState<number | ''>('')
  const [motivo, setMotivo] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    if (!(Number(cantidad) > 0)) { setError('La cantidad debe ser mayor que cero.'); return }
    setSaving(true)
    try {
      await inventarioApi.entrada({
        articuloId: articulo.id,
        cantidad: Number(cantidad),
        codigoLote: codigoLote || null,
        fechaVencimiento: esReactivo && fechaVenc ? fechaVenc : null,
        proveedorId: proveedorId ? Number(proveedorId) : null,
        ubicacionId: ubicacionId ? Number(ubicacionId) : null,
        motivo: motivo || null,
      })
      onSaved()
    } catch (err) {
      setError(apiError(err, 'No se pudo registrar la entrada.'))
    } finally {
      setSaving(false)
    }
  }

  return (
    <Modal title={`Ingresar stock — ${articulo.nombre}`} onClose={onClose}>
      <form onSubmit={onSubmit} className="space-y-4">
        <div className="grid grid-cols-2 gap-3">
          <div>
            <label className={label} htmlFor="cant">Cantidad ({articulo.unidad})</label>
            <input id="cant" type="number" step="0.001" min="0" className={input}
              value={cantidad} onChange={(e) => setCantidad(e.target.value)} required autoFocus />
          </div>
          <div>
            <label className={label} htmlFor="lote">Código de lote</label>
            <input id="lote" className={input} value={codigoLote} onChange={(e) => setCodigoLote(e.target.value)} />
          </div>
        </div>

        {esReactivo && (
          <div>
            <label className={label} htmlFor="venc">Fecha de vencimiento</label>
            <input id="venc" type="date" className={input} value={fechaVenc} onChange={(e) => setFechaVenc(e.target.value)} />
          </div>
        )}

        <div className="grid grid-cols-2 gap-3">
          <div>
            <label className={label} htmlFor="prov">Proveedor</label>
            <select id="prov" className={input} value={proveedorId}
              onChange={(e) => setProveedorId(e.target.value ? Number(e.target.value) : '')}>
              <option value="">…</option>
              {proveedores.data?.map((p) => <option key={p.id} value={p.id}>{p.nombre}</option>)}
            </select>
          </div>
          <div>
            <label className={label} htmlFor="ubi">Ubicación</label>
            <select id="ubi" className={input} value={ubicacionId}
              onChange={(e) => setUbicacionId(e.target.value ? Number(e.target.value) : '')}>
              <option value="">…</option>
              {ubicaciones.data?.map((u) => <option key={u.id} value={u.id}>{u.nombre}</option>)}
            </select>
          </div>
        </div>

        <div>
          <label className={label} htmlFor="mot">Motivo / nota</label>
          <input id="mot" className={input} value={motivo} onChange={(e) => setMotivo(e.target.value)} />
        </div>

        {error && <p className="text-sm text-rose-600">{error}</p>}

        <div className="flex gap-3 pt-1">
          <button type="submit" disabled={saving}
            className="rounded-md bg-teal-700 text-white px-5 py-2 text-sm font-medium hover:bg-teal-800 disabled:opacity-50">
            {saving ? 'Guardando…' : 'Registrar entrada'}
          </button>
          <button type="button" onClick={onClose}
            className="rounded-md border border-slate-300 px-5 py-2 text-sm hover:bg-slate-100">Cancelar</button>
        </div>
      </form>
    </Modal>
  )
}
