import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  Button, Select, Table, TableBody, TableCell, TableHead, TableHeadCell, TableRow,
} from 'flowbite-react'
import { HiPlus } from 'react-icons/hi'
import { solicitudesApi } from '../api/solicitudes'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'
import { EstadoBadge } from '../components/EstadoBadge'
import { Cargando, ErrorAlert, PageHeader } from '../components/Feedback'
import { Modal } from '../components/Modal'
import type { EstadoSolicitud, SolicitudHeader } from '../types'

const ESTADOS: EstadoSolicitud[] = [
  'PENDIENTE', 'APROBADA', 'PREPARADA', 'ENTREGADA', 'CERRADA', 'RECHAZADA',
]

export function SolicitudesPage() {
  const { hasPerm } = useAuth()
  const navigate = useNavigate()
  const qc = useQueryClient()
  const [estado, setEstado] = useState<string>('')
  const [detalleId, setDetalleId] = useState<number | null>(null)

  const { data, isLoading, error } = useQuery({
    queryKey: ['solicitudes', estado || 'ALL'],
    queryFn: () => solicitudesApi.list(estado || undefined),
  })

  const run = useMutation({
    mutationFn: (fn: () => Promise<unknown>) => fn(),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['solicitudes'] }),
    onError: (e) => alert(apiError(e)),
  })

  function acciones(s: SolicitudHeader) {
    const btns: { label: string; fn: () => Promise<unknown>; color: string }[] = []
    if (s.estado === 'PENDIENTE' && hasPerm('solicitud.aprobar')) {
      btns.push({ label: 'Aprobar', color: 'blue', fn: () => solicitudesApi.aprobar(s.id) })
      btns.push({
        label: 'Rechazar', color: 'red',
        fn: () => {
          const motivo = window.prompt('Motivo del rechazo:')
          if (!motivo) return Promise.resolve()
          return solicitudesApi.rechazar(s.id, motivo)
        },
      })
    }
    if (s.estado === 'APROBADA' && hasPerm('solicitud.preparar'))
      btns.push({ label: 'Preparar', color: 'indigo', fn: () => solicitudesApi.preparar(s.id) })
    if (s.estado === 'PREPARADA' && hasPerm('solicitud.entregar'))
      btns.push({ label: 'Entregar', color: 'indigo', fn: () => solicitudesApi.entregar(s.id) })
    if (s.estado === 'ENTREGADA' && hasPerm('solicitud.devolver'))
      btns.push({ label: 'Devolver', color: 'green', fn: () => solicitudesApi.devolver(s.id) })
    return btns
  }

  return (
    <div className="space-y-5">
      <PageHeader title="Solicitudes">
        <Select sizing="sm" value={estado} onChange={(e) => setEstado(e.target.value)}>
          <option value="">Todos los estados</option>
          {ESTADOS.map((e) => <option key={e} value={e}>{e}</option>)}
        </Select>
        {hasPerm('solicitud.crear') && (
          <Button size="sm" onClick={() => navigate('/solicitudes/nueva')}>
            <HiPlus className="me-1.5 h-4 w-4" /> Nueva solicitud
          </Button>
        )}
      </PageHeader>

      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}

      {data && (
        <Table hoverable>
          <TableHead>
            <TableRow>
              <TableHeadCell>#</TableHeadCell>
              <TableHeadCell>Estado</TableHeadCell>
              <TableHeadCell>Profesor</TableHeadCell>
              <TableHeadCell>Laboratorio</TableHeadCell>
              <TableHeadCell>Fecha</TableHeadCell>
              <TableHeadCell className="text-right">Acciones</TableHeadCell>
            </TableRow>
          </TableHead>
          <TableBody className="divide-y">
            {data.length === 0 && (
              <TableRow><TableCell colSpan={6} className="text-center text-gray-400">Sin solicitudes.</TableCell></TableRow>
            )}
            {data.map((s) => (
              <TableRow key={s.id} className="bg-white">
                <TableCell>
                  <button className="font-medium text-primary-700 hover:underline" onClick={() => setDetalleId(s.id)}>
                    {s.id}
                  </button>
                </TableCell>
                <TableCell><EstadoBadge estado={s.estado} /></TableCell>
                <TableCell className="text-gray-900">{s.profesor}</TableCell>
                <TableCell>{s.laboratorio}</TableCell>
                <TableCell>{new Date(s.fechaSolicitud).toLocaleDateString()}</TableCell>
                <TableCell>
                  <div className="flex gap-2 justify-end">
                    {acciones(s).map((b) => (
                      <Button key={b.label} size="xs" color={b.color} disabled={run.isPending}
                        onClick={() => run.mutate(b.fn)}>
                        {b.label}
                      </Button>
                    ))}
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}

      {detalleId && <Detalle id={detalleId} onClose={() => setDetalleId(null)} />}
    </div>
  )
}

function Detalle({ id, onClose }: { id: number; onClose: () => void }) {
  const { data, isLoading } = useQuery({
    queryKey: ['solicitud', id],
    queryFn: () => solicitudesApi.get(id),
  })

  return (
    <Modal title={`Detalle de la solicitud #${id}`} onClose={onClose} size="2xl">
      {isLoading && <Cargando />}
      {data && (
        <div className="space-y-3">
          <div className="flex items-center gap-3 text-sm text-gray-600 flex-wrap">
            <EstadoBadge estado={data.cabecera.estado} />
            {[data.cabecera.profesor, data.cabecera.laboratorio].filter(Boolean).join(' · ')}
          </div>
          {data.cabecera.motivoRechazo && (
            <ErrorAlert>Rechazo: {data.cabecera.motivoRechazo}</ErrorAlert>
          )}
          {data.cabecera.observaciones && (
            <p className="text-sm text-gray-500">Obs: {data.cabecera.observaciones}</p>
          )}
          <Table>
            <TableHead>
              <TableRow>
                <TableHeadCell>Artículo</TableHeadCell>
                <TableHeadCell>Tipo</TableHeadCell>
                <TableHeadCell className="text-right">Solicitada</TableHeadCell>
                <TableHeadCell className="text-right">Preparada</TableHeadCell>
                <TableHeadCell className="text-right">Devuelta</TableHeadCell>
              </TableRow>
            </TableHead>
            <TableBody className="divide-y">
              {data.lineas.map((l) => (
                <TableRow key={l.id} className="bg-white">
                  <TableCell className="text-gray-900">{l.articulo}</TableCell>
                  <TableCell>{l.tipo}</TableCell>
                  <TableCell className="text-right tabular-nums">{l.cantSolicitada} {l.unidad}</TableCell>
                  <TableCell className="text-right tabular-nums">{l.cantPreparada}</TableCell>
                  <TableCell className="text-right tabular-nums">{l.cantDevuelta}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      )}
    </Modal>
  )
}
