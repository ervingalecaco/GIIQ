import { useState, type FormEvent } from 'react'
import { useMutation, useQueries, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  Button, Label, Select, Spinner, TabItem, Table, TableBody, TableCell, TableHead, TableHeadCell,
  TableRow, Tabs, TextInput,
} from 'flowbite-react'
import { HiPlus } from 'react-icons/hi'
import { catalogosApi } from '../api/catalogos'
import {
  catAdminApi, ENTIDADES, type CatRow, type EntidadCat, type FuenteOpciones,
} from '../api/catalogosAdmin'
import type { CatalogoItem } from '../types'
import { ANIOS, anioTexto } from '../anios'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'
import { ActivoBadge, Cargando, ErrorAlert, PageHeader } from '../components/Feedback'
import { Modal } from '../components/Modal'
import { MultiSelectBuscable, SelectBuscable } from '../components/SelectBuscable'
import { Paginador, usePaginacion } from '../components/Paginacion'

// Reactivos y Cristalería no van aquí: tienen su propia sección en el menú.
export function CatalogosPage() {
  const [activa, setActiva] = useState(ENTIDADES[0].key)

  return (
    <div className="space-y-5">
      <PageHeader title="Catálogos" />

      <Tabs variant="underline" onActiveTabChange={(i) => setActiva(ENTIDADES[i].key)}>
        {ENTIDADES.map((e) => (
          <TabItem key={e.key} title={e.label} active={activa === e.key}>
            {activa === e.key && <CatalogoGenerico entidad={e} />}
          </TabItem>
        ))}
      </Tabs>
    </div>
  )
}

/** Tabla CRUD de un catálogo simple (categorías, unidades, proveedores…). */
function CatalogoGenerico({ entidad }: { entidad: EntidadCat }) {
  const { hasPerm } = useAuth()
  const qc = useQueryClient()
  const [editar, setEditar] = useState<CatRow | 'nuevo' | null>(null)
  const puedeGestionar = hasPerm('catalogos.gestionar')

  const { data, isLoading, error } = useQuery({
    queryKey: ['catalogo', entidad.key],
    queryFn: () => catAdminApi.list(entidad.key),
  })
  const pag = usePaginacion(data)

  const estado = useMutation({
    mutationFn: ({ id, activo }: { id: number; activo: boolean }) =>
      catAdminApi.estado(entidad.key, id, activo),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['catalogo', entidad.key] }),
    onError: (e) => alert(apiError(e)),
  })

  return (
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
            {pag.visibles?.map((row) => (
              <TableRow key={row.id} className={`bg-white ${!row.activo ? 'opacity-60' : ''}`}>
                {entidad.columnas.map((c, i) => (
                  <TableCell key={c.name} className={i === 0 ? 'text-gray-900 font-medium' : ''}>
                    {c.fmt === 'anio' ? anioTexto(Number(row[c.name])) : String(row[c.name] ?? '—')}
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
      {data && <Paginador p={pag} nombre={entidad.label.toLowerCase()} />}

      {editar !== null && (
        <CatalogoFormModal
          entidad={entidad}
          registro={editar}
          onClose={() => setEditar(null)}
          onSaved={() => {
            setEditar(null)
            qc.invalidateQueries({ queryKey: ['catalogo'] }) // ej. el conteo de prácticas en Clases
            for (const k of ['opciones', 'clases-form', 'practicas-form']) qc.invalidateQueries({ queryKey: [k] })
          }}
        />
      )}
    </div>
  )
}

type Valor = string | number[]

/** Fuentes con pocas opciones fijas: lista desplegable normal; el resto lleva búsqueda. */
const FUENTES_FIJAS: FuenteOpciones[] = ['anios']

const FUENTES: Record<FuenteOpciones, () => Promise<CatalogoItem[]>> = {
  laboratorios: catalogosApi.laboratorios,
  // Con el año en el texto: el mismo nombre puede existir en dos años distintos.
  clases: () => catalogosApi.clases().then((cs) =>
    cs.map((c) => ({ id: c.id, nombre: `${anioTexto(c.anio)} — ${c.nombre}` }))),
  profesores: catalogosApi.profesores,
  anios: async () => ANIOS,
}

/** Carga solo las fuentes de opciones que usan los campos de esta entidad. */
function useOpciones(entidad: EntidadCat) {
  const fuentes = [...new Set(entidad.campos.flatMap((c) => (c.fuente ? [c.fuente] : [])))]
  const consultas = useQueries({
    queries: fuentes.map((f) => ({ queryKey: ['opciones', f], queryFn: FUENTES[f] })),
  })
  const opciones: Partial<Record<FuenteOpciones, CatalogoItem[]>> = {}
  fuentes.forEach((f, i) => { opciones[f] = consultas[i].data })
  return opciones
}

function CatalogoFormModal({ entidad, registro, onClose, onSaved }: {
  entidad: EntidadCat
  registro: CatRow | 'nuevo'
  onClose: () => void
  onSaved: () => void
}) {
  const opciones = useOpciones(entidad)
  const esNuevo = registro === 'nuevo'
  const inicial: Record<string, Valor> = {}
  for (const c of entidad.campos) {
    const fila = esNuevo ? undefined : (registro as CatRow)
    inicial[c.name] = c.type === 'multi'
      ? String(fila?.[c.desde ?? c.name] ?? '').split(',').filter(Boolean).map(Number)
      : String(fila?.[c.name] ?? '')
  }

  const [valores, setValores] = useState<Record<string, Valor>>(inicial)
  const [error, setError] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    const faltante = entidad.campos.find((c) =>
      c.required && (c.type === 'multi' ? (valores[c.name] as number[]).length === 0 : !valores[c.name]))
    if (faltante) { setError(`Completa el campo «${faltante.label}».`); return }
    setSaving(true)
    const payload: Record<string, unknown> = {}
    for (const c of entidad.campos) {
      const v = valores[c.name]
      payload[c.name] = c.type === 'multi' ? v : c.type === 'select' ? (v ? Number(v) : null) : (v || null)
    }
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
            {c.type === 'select' && c.fuente && FUENTES_FIJAS.includes(c.fuente) ? (
              <Select id={c.name} value={valores[c.name] as string}
                onChange={(e) => setValores((v) => ({ ...v, [c.name]: e.target.value }))}>
                <option value="">Selecciona…</option>
                {opciones[c.fuente]?.map((o) => <option key={o.id} value={o.id}>{o.nombre}</option>)}
              </Select>
            ) : c.type === 'select' && c.fuente ? (
              // Listas que pueden crecer (clases, laboratorios): selector con búsqueda.
              <SelectBuscable id={c.name} opciones={opciones[c.fuente] ?? []}
                value={valores[c.name] ? Number(valores[c.name]) : ''}
                onChange={(id) => setValores((v) => ({ ...v, [c.name]: id === '' ? '' : String(id) }))}
                placeholder={`Buscar ${c.label.toLowerCase()}…`}
                vacio={`Ninguna opción coincide.`} />
            ) : c.type === 'multi' && c.fuente ? (
              <MultiSelectBuscable id={c.name} opciones={opciones[c.fuente] ?? []}
                value={valores[c.name] as number[]}
                onChange={(ids) => setValores((v) => ({ ...v, [c.name]: ids }))}
                placeholder={c.fuente === 'profesores' ? 'Buscar profesor…' : 'Buscar…'}
                vacio={c.fuente === 'profesores' ? 'Ningún profesor coincide.' : 'Sin resultados.'} />
            ) : (
              <TextInput id={c.name} type={c.type ?? 'text'} required={c.required}
                value={valores[c.name] as string}
                onChange={(e) => setValores((v) => ({ ...v, [c.name]: e.target.value }))} />
            )}
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
