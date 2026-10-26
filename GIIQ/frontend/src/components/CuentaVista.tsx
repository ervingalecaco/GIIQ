import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  Alert, Badge, Button, Label, Spinner, Table, TableBody, TableCell, TableHead, TableHeadCell, TableRow, TextInput,
} from 'flowbite-react'
import { HiCheckCircle, HiDocumentText, HiExclamation } from 'react-icons/hi'
import { cuentasApi, textoCausa } from '../api/bajas'
import { apiError } from '../api/client'
import { ErrorAlert } from './Feedback'
import { MiniaturaArticulo } from './ImagenArticulo'
import { Modal } from './Modal'
import { Paginador, usePaginacion } from './Paginacion'
import type { Cargo, CuentaDetalle } from '../types'

const fecha = (s?: string | null) =>
  s ? new Date(s).toLocaleDateString('es', { day: '2-digit', month: 'short', year: 'numeric' }) : '—'

/**
 * Cuenta de un estudiante: cargos (piezas por reponer) y reposiciones recibidas.
 * Bodega puede registrar reposiciones y, sin piezas pendientes, emitir la constancia de solvencia.
 */
export function CuentaVista({ cuenta, puedeReponer = false, puedeEmitir = false, onCambio }: {
  cuenta: CuentaDetalle
  puedeReponer?: boolean
  puedeEmitir?: boolean
  onCambio?: () => void
}) {
  const navigate = useNavigate()
  const { resumen, cargos, reposiciones } = cuenta
  const solvente = resumen.piezasPendientes <= 0
  const [reponer, setReponer] = useState<Cargo | null>(null)
  const [emitiendo, setEmitiendo] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const pagCargos = usePaginacion(cargos)
  const pagRepos = usePaginacion(reposiciones)

  async function emitir() {
    setError(null)
    setEmitiendo(true)
    try {
      const c = await cuentasApi.emitirConstancia(resumen.estudianteId)
      navigate(`/constancias/${c.folio}`)
    } catch (err) {
      setError(apiError(err, 'No se pudo emitir la constancia.'))
    } finally {
      setEmitiendo(false)
    }
  }

  return (
    <div className="space-y-5">
      {/* Estado de la cuenta */}
      <section className={`flex flex-wrap items-center gap-4 rounded-lg border px-5 py-4 ${
        solvente ? 'border-emerald-200 bg-emerald-50/60' : 'border-amber-200 bg-amber-50/60'}`}>
        {solvente
          ? <HiCheckCircle className="h-8 w-8 shrink-0 text-emerald-700" aria-hidden />
          : <HiExclamation className="h-8 w-8 shrink-0 text-amber-700" aria-hidden />}
        <div className="min-w-0 flex-1">
          <div className="rotulo text-gray-500">Estado de la cuenta</div>
          <div className={`text-lg font-semibold ${solvente ? 'text-emerald-800' : 'text-amber-800'}`}>
            {solvente
              ? 'Solvente: no debe cristalería'
              : `Debe reponer ${resumen.piezasPendientes} pieza(s) en ${resumen.cargosPendientes} cargo(s)`}
          </div>
          {!solvente && (
            <p className="text-sm text-gray-600">Se salda entregando en bodega una pieza igual a la quebrada.</p>
          )}
        </div>
        {puedeEmitir && (
          <Button size="sm" disabled={!solvente || emitiendo} onClick={emitir}
            title={solvente ? undefined : 'Disponible cuando no deba ninguna pieza'}>
            {emitiendo ? <Spinner size="sm" light className="me-2" /> : <HiDocumentText className="me-1.5 h-4 w-4" />}
            Emitir constancia de solvencia
          </Button>
        )}
      </section>
      {error && <ErrorAlert>{error}</ErrorAlert>}

      {/* Cargos */}
      <section className="rounded-lg border border-gray-200 bg-white">
        <h2 className="border-b border-gray-200 px-4 py-3 text-base font-semibold text-gray-900">
          Cargos <span className="font-mono text-xs font-normal text-gray-500">{cargos.length}</span>
        </h2>
        {cargos.length === 0
          ? <p className="px-4 py-6 text-sm text-gray-400">Sin cargos registrados.</p>
          : (
            <>
              <Table theme={{ root: { wrapper: 'relative overflow-x-auto' } }}>
                <TableHead>
                  <TableRow>
                    <TableHeadCell className="w-16"><span className="sr-only">Imagen</span></TableHeadCell>
                    <TableHeadCell>Artículo</TableHeadCell>
                    <TableHeadCell>Fecha</TableHeadCell>
                    <TableHeadCell>Causa</TableHeadCell>
                    <TableHeadCell className="text-right">Debe</TableHeadCell>
                    <TableHeadCell className="text-right">Repuesto</TableHeadCell>
                    <TableHeadCell>Estado</TableHeadCell>
                    {puedeReponer && <TableHeadCell className="text-right">Acciones</TableHeadCell>}
                  </TableRow>
                </TableHead>
                <TableBody className="divide-y divide-gray-100">
                  {pagCargos.visibles?.map((c) => (
                    <TableRow key={c.id} className="bg-white">
                      <TableCell className="py-2 pe-0">
                        <MiniaturaArticulo articulo={{ id: c.articuloId, nombre: c.articulo, codigo: c.codigo, imagenActualizada: c.imagenActualizada }} />
                      </TableCell>
                      <TableCell>
                        <div className="font-medium text-gray-900">{c.articulo}</div>
                        <div className="font-mono text-xs text-gray-500">
                          {c.codigo}{c.solicitudId ? ` · solicitud #${c.solicitudId}` : ''}
                        </div>
                        {c.observacion && <div className="text-xs text-gray-500">{c.observacion}</div>}
                      </TableCell>
                      <TableCell className="font-mono text-xs whitespace-nowrap">{fecha(c.fecha)}</TableCell>
                      <TableCell>{textoCausa(c.causa)}</TableCell>
                      <TableCell className="text-right font-mono text-xs tabular-nums">{c.cantidad} {c.unidad}</TableCell>
                      <TableCell className="text-right font-mono text-xs tabular-nums">{c.cantidadRepuesta}</TableCell>
                      <TableCell>
                        {c.estado === 'PENDIENTE'
                          ? <Badge color="warning" className="w-fit">Pendiente</Badge>
                          : <Badge color="success" className="w-fit" title={`Saldado el ${fecha(c.saldadoEn)}`}>Saldado</Badge>}
                      </TableCell>
                      {puedeReponer && (
                        <TableCell className="text-right">
                          {c.estado === 'PENDIENTE' && (
                            <Button size="xs" onClick={() => setReponer(c)}>Registrar reposición</Button>
                          )}
                        </TableCell>
                      )}
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
              {pagCargos.total > 10 && (
                <div className="border-t border-gray-200 px-4 py-3"><Paginador p={pagCargos} nombre="cargos" /></div>
              )}
            </>
          )}
      </section>

      {/* Reposiciones */}
      {reposiciones.length > 0 && (
        <section className="rounded-lg border border-gray-200 bg-white">
          <h2 className="border-b border-gray-200 px-4 py-3 text-base font-semibold text-gray-900">
            Reposiciones recibidas <span className="font-mono text-xs font-normal text-gray-500">{reposiciones.length}</span>
          </h2>
          <Table theme={{ root: { wrapper: 'relative overflow-x-auto' } }}>
            <TableHead>
              <TableRow>
                <TableHeadCell>Fecha</TableHeadCell>
                <TableHeadCell>Artículo</TableHeadCell>
                <TableHeadCell className="text-right">Cantidad</TableHeadCell>
                <TableHeadCell>Recibido por</TableHeadCell>
                <TableHeadCell>Observación</TableHeadCell>
              </TableRow>
            </TableHead>
            <TableBody className="divide-y divide-gray-100">
              {pagRepos.visibles?.map((r) => (
                <TableRow key={r.id} className="bg-white">
                  <TableCell className="font-mono text-xs whitespace-nowrap">{fecha(r.fecha)}</TableCell>
                  <TableCell className="text-gray-900">{r.articulo}</TableCell>
                  <TableCell className="text-right font-mono text-xs tabular-nums">{r.cantidad}</TableCell>
                  <TableCell>{r.recibidoPor}</TableCell>
                  <TableCell className="text-gray-500">{r.observacion ?? '—'}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
          {pagRepos.total > 10 && (
            <div className="border-t border-gray-200 px-4 py-3"><Paginador p={pagRepos} nombre="reposiciones" /></div>
          )}
        </section>
      )}

      {reponer && (
        <ReposicionModal cargo={reponer} onClose={() => setReponer(null)}
          onDone={() => { setReponer(null); onCambio?.() }} />
      )}
    </div>
  )
}

/** Registra que el estudiante entregó piezas iguales a las quebradas (vuelven al stock). */
function ReposicionModal({ cargo, onClose, onDone }: { cargo: Cargo; onClose: () => void; onDone: () => void }) {
  const pendiente = cargo.cantidad - cargo.cantidadRepuesta
  const [cantidad, setCantidad] = useState(String(pendiente))
  const [observacion, setObservacion] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [guardando, setGuardando] = useState(false)

  async function guardar(e: FormEvent) {
    e.preventDefault()
    const n = Number(cantidad)
    if (!(n > 0) || n > pendiente) { setError(`La cantidad debe estar entre 1 y ${pendiente}.`); return }
    setError(null)
    setGuardando(true)
    try {
      await cuentasApi.reponer(cargo.id, n, observacion.trim() || null)
      onDone()
    } catch (err) {
      setError(apiError(err, 'No se pudo registrar la reposición.'))
    } finally {
      setGuardando(false)
    }
  }

  return (
    <Modal title="Registrar reposición" onClose={onClose}>
      <form onSubmit={guardar} className="space-y-4">
        <div className="flex items-center gap-3">
          <MiniaturaArticulo articulo={{ id: cargo.articuloId, nombre: cargo.articulo, codigo: cargo.codigo, imagenActualizada: cargo.imagenActualizada }} />
          <div>
            <div className="font-medium text-gray-900">{cargo.articulo}</div>
            <div className="font-mono text-xs text-gray-500">Pendiente: {pendiente} {cargo.unidad}</div>
          </div>
        </div>
        <Alert color="info">
          Verifica que la pieza entregada sea igual a la quebrada y esté en buen estado: vuelve al stock.
        </Alert>
        <div className="grid gap-3 sm:grid-cols-[1fr_2fr]">
          <div>
            <Label htmlFor="rep-cant" className="mb-1 block">Piezas entregadas</Label>
            <TextInput id="rep-cant" type="number" min={1} max={pendiente} step="1" value={cantidad}
              onChange={(e) => setCantidad(e.target.value)} required />
          </div>
          <div>
            <Label htmlFor="rep-obs" className="mb-1 block">Observación <span className="font-normal text-gray-500">(opcional)</span></Label>
            <TextInput id="rep-obs" maxLength={255} value={observacion} placeholder="Ej. marca, estado"
              onChange={(e) => setObservacion(e.target.value)} />
          </div>
        </div>
        {error && <ErrorAlert>{error}</ErrorAlert>}
        <div className="flex justify-end gap-2 border-t border-gray-200 pt-4">
          <Button type="button" color="light" onClick={onClose}>Cancelar</Button>
          <Button type="submit" disabled={guardando}>
            {guardando ? <><Spinner size="sm" light className="me-2" /> Guardando…</> : 'Registrar reposición'}
          </Button>
        </div>
      </form>
    </Modal>
  )
}
