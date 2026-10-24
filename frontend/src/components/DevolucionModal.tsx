import { useState, type FormEvent } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Alert, Button, Label, Select, Spinner, TextInput } from 'flowbite-react'
import { HiExclamation } from 'react-icons/hi'
import { solicitudesApi, type PiezaQuebrada } from '../api/solicitudes'
import { CAUSAS, cuentasApi } from '../api/bajas'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'
import { Cargando, ErrorAlert } from './Feedback'
import { Modal } from './Modal'
import { SelectBuscable } from './SelectBuscable'
import type { CausaBaja } from '../types'

interface Fila { quebradas: string; estudianteId: number | ''; causa: CausaBaja; observacion: string }

/**
 * Recepción de la cristalería prestada. Por cada artículo se indica cuántas piezas
 * no volvieron; esas se dan de baja y, con responsable, se cargan a su cuenta
 * (debe reponer la misma pieza). Por defecto el responsable es el estudiante de la solicitud.
 */
export function DevolucionModal({ solicitudId, onClose, onDone }: {
  solicitudId: number
  onClose: () => void
  onDone: () => void
}) {
  const { hasPerm } = useAuth()
  const detalle = useQuery({ queryKey: ['solicitud', solicitudId], queryFn: () => solicitudesApi.get(solicitudId) })
  const estudiantes = useQuery({
    queryKey: ['cuentas-estudiantes'],
    queryFn: cuentasApi.estudiantes,
    enabled: hasPerm('baja.registrar'),
  })
  const [filas, setFilas] = useState<Record<number, Fila>>({})
  const [error, setError] = useState<string | null>(null)
  const [guardando, setGuardando] = useState(false)

  const cab = detalle.data?.cabecera
  const lineas = detalle.data?.lineas.filter((l) => l.tipo === 'CRISTALERIA' && l.cantPreparada > 0) ?? []
  const fila = (articuloId: number): Fila =>
    filas[articuloId] ?? { quebradas: '', estudianteId: cab?.estudianteId ?? '', causa: 'QUEBRADO', observacion: '' }
  const cambiar = (articuloId: number, cambio: Partial<Fila>) =>
    setFilas((f) => ({ ...f, [articuloId]: { ...fila(articuloId), ...cambio } }))

  const opciones = estudiantes.data?.map((e) => ({ id: e.id, nombre: `${e.codigo ? `${e.codigo} — ` : ''}${e.nombre}` })) ?? []
  const totalQuebradas = lineas.reduce((t, l) => t + (Number(fila(l.articuloId).quebradas) || 0), 0)

  async function confirmar(e: FormEvent) {
    e.preventDefault()
    setError(null)
    const quebradas: PiezaQuebrada[] = []
    for (const l of lineas) {
      const f = fila(l.articuloId)
      const n = Number(f.quebradas) || 0
      if (n < 0 || n > l.cantPreparada) {
        setError(`${l.articulo}: las piezas quebradas deben estar entre 0 y ${l.cantPreparada}.`)
        return
      }
      if (n > 0) {
        quebradas.push({
          articuloId: l.articuloId, cantidad: n, causa: f.causa,
          estudianteId: f.estudianteId === '' ? null : f.estudianteId,
          observacion: f.observacion.trim() || null,
        })
      }
    }
    setGuardando(true)
    try {
      await solicitudesApi.devolver(solicitudId, quebradas)
      onDone()
    } catch (err) {
      setError(apiError(err, 'No se pudo registrar la devolución.'))
    } finally {
      setGuardando(false)
    }
  }

  return (
    <Modal title={`Recibir devolución · solicitud #${solicitudId}`} onClose={onClose} size="2xl">
      {detalle.isLoading && <Cargando />}
      {detalle.error && <ErrorAlert error={detalle.error} />}
      {cab && (
        <form onSubmit={confirmar} className="space-y-4">
          <p className="text-sm text-gray-600">
            Revisa la cristalería que vuelve. Si alguna pieza no regresa en buen estado, indica cuántas y quién es el
            responsable: se dan de baja y quedan en su cuenta hasta que las reponga.
          </p>

          <div className="divide-y divide-gray-100 rounded-lg border border-gray-200">
            {lineas.map((l) => {
              const f = fila(l.articuloId)
              const n = Number(f.quebradas) || 0
              return (
                <div key={l.id} className="space-y-3 p-4">
                  <div className="flex flex-wrap items-end gap-4">
                    <div className="min-w-0 flex-1">
                      <div className="font-medium text-gray-900">{l.articulo}</div>
                      <div className="font-mono text-xs text-gray-500">Entregado: {l.cantPreparada} {l.unidad}</div>
                    </div>
                    <div className="w-36">
                      <Label htmlFor={`queb-${l.id}`} className="mb-1 block text-xs">Piezas quebradas</Label>
                      <TextInput id={`queb-${l.id}`} sizing="sm" type="number" min={0} max={l.cantPreparada} step="1"
                        placeholder="0" value={f.quebradas} onChange={(e) => cambiar(l.articuloId, { quebradas: e.target.value })} />
                    </div>
                    <div className="w-28 text-right font-mono text-xs text-gray-500">
                      Vuelve: <span className="text-gray-900">{Math.max(0, l.cantPreparada - n)}</span>
                    </div>
                  </div>

                  {n > 0 && (
                    <div className="grid gap-3 rounded-md bg-amber-50/60 p-3 sm:grid-cols-[2fr_1fr]">
                      <div>
                        <Label htmlFor={`resp-${l.id}`} className="mb-1 block text-xs">Responsable</Label>
                        {hasPerm('baja.registrar')
                          ? <SelectBuscable id={`resp-${l.id}`} opciones={opciones} value={f.estudianteId}
                              onChange={(id) => cambiar(l.articuloId, { estudianteId: id })}
                              placeholder="Buscar estudiante por código o nombre…" vacio="Ningún estudiante coincide." />
                          : <p className="text-xs text-gray-500">No tienes permiso para asignar responsables.</p>}
                        <p className="mt-1 text-xs text-gray-500">
                          {f.estudianteId === '' ? 'Sin responsable: se da de baja sin cargo.' : 'Deberá reponer la misma pieza.'}
                        </p>
                      </div>
                      <div>
                        <Label htmlFor={`causa-${l.id}`} className="mb-1 block text-xs">Causa</Label>
                        <Select id={`causa-${l.id}`} sizing="sm" value={f.causa}
                          onChange={(e) => cambiar(l.articuloId, { causa: e.target.value as CausaBaja })}>
                          {CAUSAS.map((c) => <option key={c.valor} value={c.valor}>{c.texto}</option>)}
                        </Select>
                      </div>
                      <div className="sm:col-span-2">
                        <Label htmlFor={`obs-${l.id}`} className="mb-1 block text-xs">Observación <span className="font-normal text-gray-500">(opcional)</span></Label>
                        <TextInput id={`obs-${l.id}`} sizing="sm" maxLength={255} value={f.observacion}
                          placeholder="Qué pasó" onChange={(e) => cambiar(l.articuloId, { observacion: e.target.value })} />
                      </div>
                    </div>
                  )}
                </div>
              )
            })}
          </div>

          {totalQuebradas > 0 && (
            <Alert color="warning" icon={HiExclamation}>
              Se darán de baja <strong>{totalQuebradas}</strong> pieza(s). Revisa el responsable antes de confirmar.
            </Alert>
          )}
          {error && <ErrorAlert>{error}</ErrorAlert>}

          <div className="flex flex-wrap justify-end gap-2 border-t border-gray-200 pt-4">
            <Button type="button" color="light" onClick={onClose}>Cancelar</Button>
            <Button type="submit" disabled={guardando}>
              {guardando ? <><Spinner size="sm" light className="me-2" /> Registrando…</> : 'Confirmar devolución'}
            </Button>
          </div>
        </form>
      )}
    </Modal>
  )
}
