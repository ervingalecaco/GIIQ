import { useState } from 'react'
import { useMutation, useQuery } from '@tanstack/react-query'
import {
  Alert, Badge, Button, Checkbox, FileInput, Label, Spinner,
  Table, TableBody, TableCell, TableHead, TableHeadCell, TableRow, TextInput, Tooltip,
} from 'flowbite-react'
import { HiCheckCircle, HiExclamation } from 'react-icons/hi'
import { articulosApi, catalogosApi, type FilaImportacion } from '../api/catalogos'
import { apiError } from '../api/client'
import { ErrorAlert } from './Feedback'
import { Modal } from './Modal'
import { Paginador, usePaginacion } from './Paginacion'

/** Fila en revisión: lo que vino del Excel + si el usuario la quiere importar. */
type Fila = FilaImportacion & { incluir: boolean }

/**
 * Importa la cristalería desde el Excel del laboratorio en dos pasos:
 * 1) se sube el archivo y se ve cómo quedaría cada artículo (nombres ya corregidos);
 * 2) se ajusta lo necesario y se confirma. Todo entra en una sola operación.
 */
export function ImportarCristaleriaModal({ onClose, onSaved }: { onClose: () => void; onSaved: () => void }) {
  const [archivo, setArchivo] = useState<File | null>(null)
  const [filas, setFilas] = useState<Fila[] | null>(null)
  const [resultado, setResultado] = useState<{ creados: number; omitidos: number } | null>(null)

  const categorias = useQuery({ queryKey: ['catalogo', 'categorias'], queryFn: catalogosApi.categorias })
  const ubicaciones = useQuery({ queryKey: ['catalogo', 'ubicaciones'], queryFn: catalogosApi.ubicaciones })

  const leer = useMutation({
    mutationFn: (f: File) => articulosApi.previsualizarCristaleria(f),
    onSuccess: (data) => setFilas(data.map((f) => ({ ...f, incluir: !f.existe }))),
  })
  const importar = useMutation({
    mutationFn: () => articulosApi.importarCristaleria(
      (filas ?? []).filter((f) => f.incluir && !f.existe).map((f) => ({
        codigo: f.codigo, nombre: f.nombre.trim(), categoria: f.categoria.trim(),
        ubicacion: f.ubicacion?.trim() || null, unidad: f.unidad, cantidad: f.cantidad,
      }))),
    onSuccess: (r) => { setResultado(r); onSaved() },
  })

  const pag = usePaginacion(filas ?? undefined, [filas?.length])
  const cambiar = (codigo: string, cambios: Partial<Fila>) =>
    setFilas((fs) => fs && fs.map((f) => (f.codigo === codigo ? { ...f, ...cambios } : f)))

  const nuevas = filas?.filter((f) => !f.existe) ?? []
  const elegidas = nuevas.filter((f) => f.incluir)
  const incompletas = elegidas.filter((f) => !f.nombre.trim() || !f.categoria.trim() || !(f.cantidad >= 0))
  const conAvisos = filas?.filter((f) => f.avisos.length > 0).length ?? 0

  return (
    <Modal title="Importar cristalería desde Excel" onClose={onClose} size="7xl">
      {resultado ? (
        <div className="space-y-4">
          <Alert color="success" icon={HiCheckCircle}>
            Se crearon <strong>{resultado.creados}</strong> artículos de cristalería con su existencia inicial
            {resultado.omitidos > 0 && <> · {resultado.omitidos} se omitieron porque su código ya existía</>}.
            La entrada quedó registrada en el kardex como «Importación de cristalería desde Excel».
          </Alert>
          <div className="flex justify-end"><Button size="sm" onClick={onClose}>Listo</Button></div>
        </div>
      ) : !filas ? (
        <div className="space-y-4">
          <p className="text-sm text-gray-600">
            Sube el Excel del inventario de cristalería. Se usa la hoja <strong>cristaleria</strong> y sus columnas
            Nombre_Tecnico, Capacidad, Unidad_Medida, Material, Cantidad_Stock y Ubicacion_Laboratorio.
            Antes de guardar vas a poder revisar y corregir cada artículo.
          </p>
          <div>
            <Label htmlFor="excel-cristaleria" className="mb-1 block">Archivo .xlsx</Label>
            <FileInput id="excel-cristaleria" accept=".xlsx"
              onChange={(e) => { setArchivo(e.target.files?.[0] ?? null); leer.reset() }} />
          </div>
          {leer.error && <ErrorAlert>{apiError(leer.error)}</ErrorAlert>}
          <div className="flex justify-end gap-2">
            <Button size="sm" color="light" onClick={onClose}>Cancelar</Button>
            <Button size="sm" disabled={!archivo || leer.isPending} onClick={() => archivo && leer.mutate(archivo)}>
              {leer.isPending && <Spinner size="sm" className="me-2" />} Leer Excel
            </Button>
          </div>
        </div>
      ) : (
        <div className="space-y-4">
          <div className="flex flex-wrap items-center gap-2 text-sm">
            <Badge color="info">{filas.length} filas en el Excel</Badge>
            <Badge color="success">{nuevas.length} nuevas</Badge>
            {filas.length - nuevas.length > 0 && <Badge color="gray">{filas.length - nuevas.length} ya existen (se omiten)</Badge>}
            {conAvisos > 0 && <Badge color="warning">{conAvisos} con avisos</Badge>}
            <span className="text-gray-500">
              Los nombres ya vienen corregidos; puedes editar cualquier dato antes de importar.
            </span>
          </div>

          <datalist id="imp-categorias">{categorias.data?.map((c) => <option key={c.id} value={c.nombre} />)}</datalist>
          <datalist id="imp-ubicaciones">{ubicaciones.data?.map((u) => <option key={u.id} value={u.nombre} />)}</datalist>

          <div className="overflow-x-auto">
            <Table>
              <TableHead>
                <TableRow>
                  <TableHeadCell className="w-10">
                    <Checkbox aria-label="Importar todas" checked={nuevas.length > 0 && elegidas.length === nuevas.length}
                      onChange={(e) => setFilas((fs) => fs && fs.map((f) => (f.existe ? f : { ...f, incluir: e.target.checked })))} />
                  </TableHeadCell>
                  <TableHeadCell>Código</TableHeadCell>
                  <TableHeadCell className="min-w-72">Nombre</TableHeadCell>
                  <TableHeadCell className="min-w-44">Categoría</TableHeadCell>
                  <TableHeadCell className="min-w-44">Ubicación</TableHeadCell>
                  <TableHeadCell className="text-right">Cantidad</TableHeadCell>
                  <TableHeadCell />
                </TableRow>
              </TableHead>
              <TableBody className="divide-y">
                {pag.visibles?.map((f) => {
                  const off = f.existe || !f.incluir
                  return (
                    <TableRow key={f.codigo} className={f.existe ? 'bg-gray-50' : 'bg-white'}>
                      <TableCell>
                        <Checkbox aria-label={`Importar ${f.nombre}`} checked={f.incluir} disabled={f.existe}
                          onChange={(e) => cambiar(f.codigo, { incluir: e.target.checked })} />
                      </TableCell>
                      <TableCell className="font-mono text-xs whitespace-nowrap">
                        {f.codigo}
                        <div className="font-sans text-[11px] text-gray-400">fila {f.fila}</div>
                      </TableCell>
                      <TableCell>
                        {f.existe ? (
                          <span className="text-gray-500">{f.nombre} <Badge color="gray" className="ms-1 inline-flex">Ya existe</Badge></span>
                        ) : (
                          <>
                            <TextInput sizing="sm" value={f.nombre} disabled={off} maxLength={150}
                              color={f.incluir && !f.nombre.trim() ? 'failure' : undefined}
                              onChange={(e) => cambiar(f.codigo, { nombre: e.target.value })} />
                            {f.nombreOriginal !== f.nombre && (
                              <div className="mt-0.5 text-[11px] text-gray-400">Excel: {f.nombreOriginal}</div>
                            )}
                          </>
                        )}
                      </TableCell>
                      <TableCell>
                        <TextInput sizing="sm" list="imp-categorias" value={f.categoria} disabled={off} maxLength={80}
                          color={f.incluir && !f.existe && !f.categoria.trim() ? 'failure' : undefined}
                          onChange={(e) => cambiar(f.codigo, { categoria: e.target.value })} />
                      </TableCell>
                      <TableCell>
                        <TextInput sizing="sm" list="imp-ubicaciones" value={f.ubicacion ?? ''} disabled={off} maxLength={80}
                          onChange={(e) => cambiar(f.codigo, { ubicacion: e.target.value })} />
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center justify-end gap-1.5">
                          <TextInput sizing="sm" type="number" min={0} step="any" className="w-24" value={f.cantidad}
                            disabled={off} aria-label="Cantidad"
                            onChange={(e) => cambiar(f.codigo, { cantidad: e.target.value === '' ? NaN : Number(e.target.value) })} />
                          <span className="text-xs text-gray-500 w-8">{f.unidad}</span>
                        </div>
                      </TableCell>
                      <TableCell>
                        {f.avisos.length > 0 && (
                          <Tooltip content={<div className="max-w-xs space-y-1">{f.avisos.map((a) => <div key={a}>{a}</div>)}</div>}>
                            <HiExclamation className="h-5 w-5 text-yellow-500" aria-label={f.avisos.join(' ')} />
                          </Tooltip>
                        )}
                      </TableCell>
                    </TableRow>
                  )
                })}
              </TableBody>
            </Table>
          </div>
          <Paginador p={pag} nombre="filas" />

          {incompletas.length > 0 && (
            <Alert color="warning">
              Hay {incompletas.length} fila(s) marcadas sin nombre, sin categoría o con cantidad inválida.
            </Alert>
          )}
          {importar.error && <ErrorAlert>{apiError(importar.error)}</ErrorAlert>}

          <div className="flex flex-wrap items-center justify-between gap-2 border-t border-gray-200 pt-4">
            <Button size="sm" color="light" onClick={() => { setFilas(null); leer.reset() }}>Elegir otro archivo</Button>
            <div className="flex gap-2">
              <Button size="sm" color="light" onClick={onClose}>Cancelar</Button>
              <Button size="sm" disabled={elegidas.length === 0 || incompletas.length > 0 || importar.isPending}
                onClick={() => importar.mutate()}>
                {importar.isPending && <Spinner size="sm" className="me-2" />}
                Importar {elegidas.length} artículo{elegidas.length === 1 ? '' : 's'}
              </Button>
            </div>
          </div>
        </div>
      )}
    </Modal>
  )
}
