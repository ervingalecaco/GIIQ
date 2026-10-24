import { useEffect, useState, type FormEvent } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Button, Checkbox, Label, Select, Spinner, TextInput } from 'flowbite-react'
import { articulosApi, catalogosApi, type ArticuloPayload } from '../api/catalogos'
import { apiError } from '../api/client'
import { ErrorAlert } from './Feedback'
import { Modal } from './Modal'
import type { TipoArticulo } from '../types'
import { especialesDe, NFPA_CUADRANTES, NFPA_ESPECIALES, type CuadranteNfpa } from '../nfpa'
import { RomboNfpa } from './RomboNfpa'
import { CampoImagen } from './ImagenArticulo'
import { useAuth } from '../auth/AuthContext'

const label = 'mb-2 block'

export function ArticuloFormModal({ articuloId, tipoFijo, onClose, onSaved }: {
  articuloId: number | 'nuevo'
  /** Si viene, el artículo nuevo se crea con este tipo y no se puede cambiar. */
  tipoFijo?: TipoArticulo
  onClose: () => void
  onSaved: () => void
}) {
  const esNuevo = articuloId === 'nuevo'
  const { hasPerm } = useAuth()
  const categorias = useQuery({ queryKey: ['categorias'], queryFn: catalogosApi.categorias })
  const unidades = useQuery({ queryKey: ['unidades'], queryFn: catalogosApi.unidades })
  const detalle = useQuery({
    queryKey: ['articulo', articuloId],
    queryFn: () => articulosApi.get(articuloId as number),
    enabled: !esNuevo,
  })

  const [tipo, setTipo] = useState<TipoArticulo>(tipoFijo ?? 'REACTIVO')
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
  // Rombo NFPA 704: '' = sin elegir; especiales = códigos del cuadrante blanco.
  const [nfpa, setNfpa] = useState<Record<CuadranteNfpa, number | ''>>({ salud: '', inflamabilidad: '', reactividad: '' })
  const [especiales, setEspeciales] = useState<string[]>([])
  // Foto de referencia (solo cristalería): se sube después de guardar el artículo.
  const [imagenNueva, setImagenNueva] = useState<Blob | null>(null)
  const [quitarImagen, setQuitarImagen] = useState(false)
  const conImagen = tipo === 'CRISTALERIA' && hasPerm('articulos.editar')
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
      setNfpa({
        salud: d.nfpaSalud ?? '', inflamabilidad: d.nfpaInflamabilidad ?? '', reactividad: d.nfpaReactividad ?? '',
      })
      setEspeciales(especialesDe(d.nfpaEspecial))
    }
  }, [detalle.data])

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    if (!categoriaId || !unidadId) { setError('Categoría y unidad son obligatorias.'); return }
    const esReactivo = tipo === 'REACTIVO'
    if (esReactivo && (nfpa.salud === '' || nfpa.inflamabilidad === '' || nfpa.reactividad === '')) {
      setError('Completa el rombo de seguridad: salud, inflamabilidad y reactividad.')
      return
    }

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
      nfpaSalud: esReactivo ? Number(nfpa.salud) : null,
      nfpaInflamabilidad: esReactivo ? Number(nfpa.inflamabilidad) : null,
      nfpaReactividad: esReactivo ? Number(nfpa.reactividad) : null,
      nfpaEspecial: esReactivo && especiales.length ? especiales.join(',') : null,
    }

    setSaving(true)
    try {
      const id = esNuevo
        ? (await articulosApi.crear({ ...payload, tipo, codigo })).articuloId
        : articuloId as number
      if (!esNuevo) await articulosApi.editar(id, payload)
      if (conImagen) {
        try {
          if (imagenNueva) await articulosApi.subirImagen(id, imagenNueva)
          else if (quitarImagen) await articulosApi.quitarImagen(id)
        } catch (err) {
          // El artículo ya quedó guardado: se avisa y se puede reintentar editándolo.
          alert(`El artículo se guardó, pero la imagen no: ${apiError(err)}`)
        }
      }
      onSaved()
    } catch (err) {
      setError(apiError(err, 'No se pudo guardar el artículo.'))
    } finally {
      setSaving(false)
    }
  }

  return (
    <Modal title={`${esNuevo ? 'Nuevo' : 'Editar'} ${tipo === 'REACTIVO' ? 'reactivo' : 'artículo de cristalería'}`}
      onClose={onClose} size="2xl">
      <form onSubmit={onSubmit} className="space-y-4">
        <div className="grid grid-cols-2 gap-3">
          <div>
            <Label className={label} htmlFor="tipo">Tipo</Label>
            <Select id="tipo" value={tipo} disabled={!esNuevo || !!tipoFijo}
              onChange={(e) => setTipo(e.target.value as TipoArticulo)}>
              <option value="REACTIVO">Reactivo</option>
              <option value="CRISTALERIA">Cristalería</option>
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

        {tipo === 'REACTIVO' && (
          <fieldset className="border border-gray-200 rounded-lg p-4">
            <legend className="text-xs font-semibold uppercase tracking-wide text-gray-500 px-1">
              Rombo de seguridad (NFPA 704) *
            </legend>
            <div className="flex flex-col sm:flex-row gap-5">
              <div className="flex-1 space-y-3">
                {(Object.keys(NFPA_CUADRANTES) as CuadranteNfpa[]).map((k) => {
                  const q = NFPA_CUADRANTES[k]
                  return (
                    <div key={k}>
                      <Label className="mb-1.5 flex items-center gap-2" htmlFor={`nfpa-${k}`}>
                        <span className="inline-block h-3.5 w-3.5 rotate-45 border border-gray-700"
                          style={{ backgroundColor: q.color }} />
                        {q.titulo}
                      </Label>
                      <Select id={`nfpa-${k}`} sizing="sm" value={nfpa[k]}
                        onChange={(e) => setNfpa((v) => ({ ...v, [k]: e.target.value === '' ? '' : Number(e.target.value) }))}>
                        <option value="">Selecciona el nivel…</option>
                        {q.niveles.map((texto, nivel) => (
                          <option key={nivel} value={nivel}>{nivel} — {texto}</option>
                        ))}
                      </Select>
                    </div>
                  )
                })}
                <div>
                  <Label className="mb-1.5 flex items-center gap-2">
                    <span className="inline-block h-3.5 w-3.5 rotate-45 border border-gray-700 bg-white" />
                    Riesgo específico <span className="font-normal text-gray-500">(opcional)</span>
                  </Label>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-x-4 gap-y-1.5">
                    {NFPA_ESPECIALES.map((e) => (
                      <div key={e.codigo} className="flex items-center gap-2">
                        <Checkbox id={`esp-${e.codigo}`} checked={especiales.includes(e.codigo)}
                          onChange={() => setEspeciales((v) =>
                            v.includes(e.codigo) ? v.filter((x) => x !== e.codigo) : [...v, e.codigo])} />
                        <Label htmlFor={`esp-${e.codigo}`} className="font-normal text-sm">
                          <strong className="font-mono">{e.etiqueta}</strong> — {e.texto}
                        </Label>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
              {/* Vista previa del rombo */}
              <div className="flex flex-col items-center justify-center gap-2 sm:w-40">
                <RomboNfpa tamano={140} nfpaSalud={nfpa.salud === '' ? null : nfpa.salud}
                  nfpaInflamabilidad={nfpa.inflamabilidad === '' ? null : nfpa.inflamabilidad}
                  nfpaReactividad={nfpa.reactividad === '' ? null : nfpa.reactividad}
                  nfpaEspecial={especiales.join(',')} />
                <span className="text-xs text-gray-500">Vista previa</span>
              </div>
            </div>
          </fieldset>
        )}

        {conImagen && (
          <CampoImagen
            actual={esNuevo ? undefined : { id: articuloId as number, version: detalle.data?.imagenActualizada }}
            nueva={imagenNueva} quitar={quitarImagen}
            onElegir={(b) => { setImagenNueva(b); setQuitarImagen(false) }}
            onQuitar={() => { setImagenNueva(null); setQuitarImagen(true) }} />
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
