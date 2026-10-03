import { useEffect, useState, type FormEvent } from 'react'
import { useQuery } from '@tanstack/react-query'
import { articulosApi, catalogosApi, type ArticuloPayload } from '../api/catalogos'
import { apiError } from '../api/client'
import { Modal } from './Modal'

const input = 'w-full rounded-md border border-slate-300 px-3 py-2 text-sm'
const label = 'block text-sm font-medium text-slate-700 mb-1'

export function ArticuloFormModal({ articuloId, onClose, onSaved }: {
  articuloId: number | 'nuevo'
  onClose: () => void
  onSaved: () => void
}) {
  const esNuevo = articuloId === 'nuevo'
  const categorias = useQuery({ queryKey: ['categorias'], queryFn: catalogosApi.categorias })
  const unidades = useQuery({ queryKey: ['unidades'], queryFn: catalogosApi.unidades })
  const detalle = useQuery({
    queryKey: ['articulo', articuloId],
    queryFn: () => articulosApi.get(articuloId as number),
    enabled: !esNuevo,
  })

  const [tipo, setTipo] = useState<'REACTIVO' | 'MATERIAL'>('REACTIVO')
  const [codigo, setCodigo] = useState('')
  const [nombre, setNombre] = useState('')
  const [categoriaId, setCategoriaId] = useState<number | ''>('')
  const [unidadId, setUnidadId] = useState<number | ''>('')
  const [stockMinimo, setStockMinimo] = useState('0')
  const [cas, setCas] = useState('')
  const [formula, setFormula] = useState('')
  const [peligro, setPeligro] = useState('')
  const [estadoFisico, setEstadoFisico] = useState('')
  const [concentracion, setConcentracion] = useState('')
  const [condiciones, setCondiciones] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (detalle.data) {
      const d = detalle.data
      setTipo(d.tipo); setCodigo(d.codigo); setNombre(d.nombre)
      setCategoriaId(d.categoriaId); setUnidadId(d.unidadId)
      setStockMinimo(String(d.stockMinimo))
      setCas(d.cas ?? ''); setFormula(d.formula ?? ''); setPeligro(d.clasificacionPeligro ?? '')
      setEstadoFisico(d.estadoFisico ?? ''); setConcentracion(d.concentracion ?? '')
      setCondiciones(d.condicionesAlmacenamiento ?? '')
    }
  }, [detalle.data])

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    if (!categoriaId || !unidadId) { setError('Categoría y unidad son obligatorias.'); return }

    const payload: ArticuloPayload = {
      nombre,
      categoriaId: Number(categoriaId),
      unidadId: Number(unidadId),
      stockMinimo: Number(stockMinimo) || 0,
      cas: tipo === 'REACTIVO' ? cas || null : null,
      formula: tipo === 'REACTIVO' ? formula || null : null,
      clasificacionPeligro: tipo === 'REACTIVO' ? peligro || null : null,
      estadoFisico: tipo === 'REACTIVO' ? estadoFisico || null : null,
      concentracion: tipo === 'REACTIVO' ? concentracion || null : null,
      condicionesAlmacenamiento: tipo === 'REACTIVO' ? condiciones || null : null,
    }

    setSaving(true)
    try {
      if (esNuevo) await articulosApi.crear({ ...payload, tipo, codigo })
      else await articulosApi.editar(articuloId as number, payload)
      onSaved()
    } catch (err) {
      setError(apiError(err, 'No se pudo guardar el artículo.'))
    } finally {
      setSaving(false)
    }
  }

  return (
    <Modal title={esNuevo ? 'Nuevo artículo' : 'Editar artículo'} onClose={onClose}>
      <form onSubmit={onSubmit} className="space-y-4">
        <div className="grid grid-cols-2 gap-3">
          <div>
            <label className={label} htmlFor="tipo">Tipo</label>
            <select id="tipo" className={input} value={tipo} disabled={!esNuevo}
              onChange={(e) => setTipo(e.target.value as 'REACTIVO' | 'MATERIAL')}>
              <option value="REACTIVO">Reactivo</option>
              <option value="MATERIAL">Material / cristalería</option>
            </select>
          </div>
          <div>
            <label className={label} htmlFor="codigo">Código</label>
            <input id="codigo" className={input} value={codigo} disabled={!esNuevo}
              onChange={(e) => setCodigo(e.target.value)} required />
          </div>
        </div>

        <div>
          <label className={label} htmlFor="nombre">Nombre</label>
          <input id="nombre" className={input} value={nombre} onChange={(e) => setNombre(e.target.value)} required />
        </div>

        <div className="grid grid-cols-3 gap-3">
          <div>
            <label className={label} htmlFor="cat">Categoría</label>
            <select id="cat" className={input} value={categoriaId}
              onChange={(e) => setCategoriaId(e.target.value ? Number(e.target.value) : '')}>
              <option value="">…</option>
              {categorias.data?.map((c) => <option key={c.id} value={c.id}>{c.nombre}</option>)}
            </select>
          </div>
          <div>
            <label className={label} htmlFor="uni">Unidad</label>
            <select id="uni" className={input} value={unidadId}
              onChange={(e) => setUnidadId(e.target.value ? Number(e.target.value) : '')}>
              <option value="">…</option>
              {unidades.data?.map((u) => <option key={u.id} value={u.id}>{u.abreviatura}</option>)}
            </select>
          </div>
          <div>
            <label className={label} htmlFor="min">Stock mínimo</label>
            <input id="min" type="number" step="0.001" min="0" className={input}
              value={stockMinimo} onChange={(e) => setStockMinimo(e.target.value)} />
          </div>
        </div>

        {tipo === 'REACTIVO' && (
          <fieldset className="border border-slate-200 rounded-lg p-3 space-y-3">
            <legend className="text-xs font-medium text-slate-500 px-1">Ficha del reactivo</legend>
            <div className="grid grid-cols-3 gap-3">
              <div>
                <label className={label} htmlFor="cas">CAS</label>
                <input id="cas" className={input} value={cas} onChange={(e) => setCas(e.target.value)} />
              </div>
              <div>
                <label className={label} htmlFor="formula">Fórmula</label>
                <input id="formula" className={input} value={formula} onChange={(e) => setFormula(e.target.value)} />
              </div>
              <div>
                <label className={label} htmlFor="ef">Estado físico</label>
                <select id="ef" className={input} value={estadoFisico} onChange={(e) => setEstadoFisico(e.target.value)}>
                  <option value="">…</option>
                  <option value="SOLIDO">Sólido</option>
                  <option value="LIQUIDO">Líquido</option>
                  <option value="GAS">Gas</option>
                </select>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className={label} htmlFor="conc">Concentración</label>
                <input id="conc" className={input} value={concentracion} onChange={(e) => setConcentracion(e.target.value)} placeholder="ej. 37%, 1 M" />
              </div>
              <div>
                <label className={label} htmlFor="peligro">Clasificación de peligro (GHS)</label>
                <input id="peligro" className={input} value={peligro} onChange={(e) => setPeligro(e.target.value)} placeholder="ej. Corrosivo, Inflamable" />
              </div>
            </div>
            <div>
              <label className={label} htmlFor="cond">Condiciones de almacenamiento</label>
              <input id="cond" className={input} value={condiciones} onChange={(e) => setCondiciones(e.target.value)} />
            </div>
          </fieldset>
        )}

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
