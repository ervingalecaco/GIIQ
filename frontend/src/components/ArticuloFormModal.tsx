import { useEffect, useState, type FormEvent } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Button, Label, Select, Spinner, TextInput } from 'flowbite-react'
import { articulosApi, catalogosApi, type ArticuloPayload } from '../api/catalogos'
import { apiError } from '../api/client'
import { ErrorAlert } from './Feedback'
import { Modal } from './Modal'

const label = 'mb-2 block'

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
    <Modal title={esNuevo ? 'Nuevo artículo' : 'Editar artículo'} onClose={onClose} size="2xl">
      <form onSubmit={onSubmit} className="space-y-4">
        <div className="grid grid-cols-2 gap-3">
          <div>
            <Label className={label} htmlFor="tipo">Tipo</Label>
            <Select id="tipo" value={tipo} disabled={!esNuevo}
              onChange={(e) => setTipo(e.target.value as 'REACTIVO' | 'MATERIAL')}>
              <option value="REACTIVO">Reactivo</option>
              <option value="MATERIAL">Material / cristalería</option>
            </Select>
          </div>
          <div>
            <Label className={label} htmlFor="codigo">Código</Label>
            <TextInput id="codigo" value={codigo} disabled={!esNuevo}
              onChange={(e) => setCodigo(e.target.value)} required />
          </div>
        </div>

        <div>
          <Label className={label} htmlFor="nombre">Nombre</Label>
          <TextInput id="nombre" value={nombre} onChange={(e) => setNombre(e.target.value)} required />
        </div>

        <div className="grid grid-cols-3 gap-3">
          <div>
            <Label className={label} htmlFor="cat">Categoría</Label>
            <Select id="cat" value={categoriaId}
              onChange={(e) => setCategoriaId(e.target.value ? Number(e.target.value) : '')}>
              <option value="">…</option>
              {categorias.data?.map((c) => <option key={c.id} value={c.id}>{c.nombre}</option>)}
            </Select>
          </div>
          <div>
            <Label className={label} htmlFor="uni">Unidad</Label>
            <Select id="uni" value={unidadId}
              onChange={(e) => setUnidadId(e.target.value ? Number(e.target.value) : '')}>
              <option value="">…</option>
              {unidades.data?.map((u) => <option key={u.id} value={u.id}>{u.abreviatura}</option>)}
            </Select>
          </div>
          <div>
            <Label className={label} htmlFor="min">Stock mínimo</Label>
            <TextInput id="min" type="number" step="0.001" min="0"
              value={stockMinimo} onChange={(e) => setStockMinimo(e.target.value)} />
          </div>
        </div>

        {tipo === 'REACTIVO' && (
          <fieldset className="border border-gray-200 rounded-lg p-4 space-y-3 bg-gray-50">
            <legend className="text-xs font-semibold uppercase tracking-wide text-gray-500 px-1">Ficha del reactivo</legend>
            <div className="grid grid-cols-3 gap-3">
              <div>
                <Label className={label} htmlFor="cas">CAS</Label>
                <TextInput id="cas" value={cas} onChange={(e) => setCas(e.target.value)} />
              </div>
              <div>
                <Label className={label} htmlFor="formula">Fórmula</Label>
                <TextInput id="formula" value={formula} onChange={(e) => setFormula(e.target.value)} />
              </div>
              <div>
                <Label className={label} htmlFor="ef">Estado físico</Label>
                <Select id="ef" value={estadoFisico} onChange={(e) => setEstadoFisico(e.target.value)}>
                  <option value="">…</option>
                  <option value="SOLIDO">Sólido</option>
                  <option value="LIQUIDO">Líquido</option>
                  <option value="GAS">Gas</option>
                </Select>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <Label className={label} htmlFor="conc">Concentración</Label>
                <TextInput id="conc" value={concentracion} onChange={(e) => setConcentracion(e.target.value)} placeholder="ej. 37%, 1 M" />
              </div>
              <div>
                <Label className={label} htmlFor="peligro">Clasificación de peligro (GHS)</Label>
                <TextInput id="peligro" value={peligro} onChange={(e) => setPeligro(e.target.value)} placeholder="ej. Corrosivo, Inflamable" />
              </div>
            </div>
            <div>
              <Label className={label} htmlFor="cond">Condiciones de almacenamiento</Label>
              <TextInput id="cond" value={condiciones} onChange={(e) => setCondiciones(e.target.value)} />
            </div>
          </fieldset>
        )}

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
