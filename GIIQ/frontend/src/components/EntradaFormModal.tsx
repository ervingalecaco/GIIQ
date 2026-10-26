import { useState, type FormEvent } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Button, Label, Select, Spinner, TextInput } from 'flowbite-react'
import { catalogosApi, inventarioApi } from '../api/catalogos'
import { apiError } from '../api/client'
import { ErrorAlert } from './Feedback'
import { Modal } from './Modal'
import type { Articulo } from '../types'

const label = 'mb-2 block'

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
            <Label className={label} htmlFor="cant">Cantidad ({articulo.unidad})</Label>
            <TextInput id="cant" type="number" step="0.001" min="0"
              value={cantidad} onChange={(e) => setCantidad(e.target.value)} required autoFocus />
          </div>
          <div>
            <Label className={label} htmlFor="lote">Código de lote</Label>
            <TextInput id="lote" value={codigoLote} onChange={(e) => setCodigoLote(e.target.value)} />
          </div>
        </div>

        {esReactivo && (
          <div>
            <Label className={label} htmlFor="venc">Fecha de vencimiento</Label>
            <TextInput id="venc" type="date" value={fechaVenc} onChange={(e) => setFechaVenc(e.target.value)} />
          </div>
        )}

        <div className="grid grid-cols-2 gap-3">
          <div>
            <Label className={label} htmlFor="prov">Proveedor</Label>
            <Select id="prov" value={proveedorId}
              onChange={(e) => setProveedorId(e.target.value ? Number(e.target.value) : '')}>
              <option value="">…</option>
              {proveedores.data?.map((p) => <option key={p.id} value={p.id}>{p.nombre}</option>)}
            </Select>
          </div>
          <div>
            <Label className={label} htmlFor="ubi">Ubicación</Label>
            <Select id="ubi" value={ubicacionId}
              onChange={(e) => setUbicacionId(e.target.value ? Number(e.target.value) : '')}>
              <option value="">…</option>
              {ubicaciones.data?.map((u) => <option key={u.id} value={u.id}>{u.nombre}</option>)}
            </Select>
          </div>
        </div>

        <div>
          <Label className={label} htmlFor="mot">Motivo / nota</Label>
          <TextInput id="mot" value={motivo} onChange={(e) => setMotivo(e.target.value)} />
        </div>

        {error && <ErrorAlert>{error}</ErrorAlert>}

        <div className="flex gap-3 pt-1">
          <Button type="submit" disabled={saving}>
            {saving ? <><Spinner size="sm" light className="me-2" /> Guardando…</> : 'Registrar entrada'}
          </Button>
          <Button type="button" color="light" onClick={onClose}>Cancelar</Button>
        </div>
      </form>
    </Modal>
  )
}
