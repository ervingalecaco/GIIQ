import { useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  Alert, Button, Table, TableBody, TableCell, TableHead, TableHeadCell, TableRow,
} from 'flowbite-react'
import { HiCheckCircle, HiChevronDown, HiEye, HiPlus } from 'react-icons/hi'
import { solicitudesApi } from '../api/solicitudes'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'
import { EstadoBadge } from '../components/EstadoBadge'
import { Cargando, ErrorAlert, PageHeader } from '../components/Feedback'
import { Modal } from '../components/Modal'
import { DevolucionModal } from '../components/DevolucionModal'
import { Paginador, usePaginacion } from '../components/Paginacion'
import { TarjetaFiltro } from '../components/TarjetaFiltro'
import {
  describirPeriodo, FiltroPeriodo, PERIODO_INICIAL, rangoDe, type Periodo,
} from '../components/FiltroPeriodo'
import { anioTexto } from '../anios'
import type { EstadoSolicitud, SolicitudHeader, TipoArticulo } from '../types'
import { TIPO_SOLICITUD } from '../tiposSolicitud'
import { useDialogos } from '../components/Dialogos'

/** Estados por los que pasa cada tipo (los reactivos no quedan ENTREGADA: se cierran al entregar). */
const ESTADOS: Record<TipoArticulo, EstadoSolicitud[]> = {
  REACTIVO: ['PENDIENTE_PROFESOR', 'PENDIENTE', 'APROBADA', 'PREPARADA', 'CERRADA', 'RECHAZADA'],
  CRISTALERIA: ['PENDIENTE_PROFESOR', 'PENDIENTE', 'APROBADA', 'PREPARADA', 'ENTREGADA', 'CERRADA', 'RECHAZADA'],
}

/** Estados en los que ya hubo despacho, y tiene sentido mostrar preparado/devuelto. */
const CON_DESPACHO: EstadoSolicitud[] = ['PREPARADA', 'ENTREGADA', 'DEVUELTA', 'CERRADA']

/** `devolucion`: en vez de ejecutar `fn`, abre el diálogo para registrar piezas quebradas. */
interface Accion { label: string; color: string; fn: () => Promise<unknown>; devolucion?: boolean }

/** Acciones del flujo disponibles para una solicitud según su estado y los permisos del usuario. */
function useAcciones() {
  const { user, hasPerm } = useAuth()
  const { pedirTexto } = useDialogos()
  // Motivo del rechazo en una ventana propia; null = se canceló y no se hace nada.
  const pedirMotivo = (s: SolicitudHeader, quienLoVera: string) => pedirTexto({
    titulo: `Rechazar solicitud #${s.id}`,
    etiqueta: 'Motivo del rechazo',
    descripcion: `${quienLoVera} este motivo en la solicitud y en sus notificaciones.`,
    placeholder: 'Ej. La cantidad solicitada excede lo necesario para la práctica.',
    confirmar: 'Rechazar solicitud',
    peligro: true, multilinea: true, minimo: 5, maximo: 255,
  })
  return (s: SolicitudHeader): Accion[] => {
    const btns: Accion[] = []
    // Visto bueno del profesor responsable a la solicitud de su estudiante.
    const esSuProfesor = s.profesorId === user?.id || user?.rol === 'Administrador'
    if (s.estado === 'PENDIENTE_PROFESOR' && hasPerm('solicitud.avalar') && esSuProfesor) {
      btns.push({ label: 'Avalar', color: 'default', fn: () => solicitudesApi.avalar(s.id) })
      btns.push({
        label: 'Rechazar', color: 'red',
        fn: async () => {
          const motivo = await pedirMotivo(s, 'El estudiante verá')
          if (motivo) await solicitudesApi.rechazarProfesor(s.id, motivo)
        },
      })
    }
    if (s.estado === 'PENDIENTE' && hasPerm('solicitud.aprobar')) {
      btns.push({ label: 'Aprobar', color: 'default', fn: () => solicitudesApi.aprobar(s.id) })
      btns.push({
        label: 'Rechazar', color: 'red',
        fn: async () => {
          const motivo = await pedirMotivo(s, s.estudianteId ? 'El estudiante y su profesor verán' : 'El profesor verá')
          if (motivo) await solicitudesApi.rechazar(s.id, motivo)
        },
      })
    }
    if (s.estado === 'APROBADA' && hasPerm('solicitud.preparar'))
      btns.push({ label: 'Preparar', color: 'default', fn: () => solicitudesApi.preparar(s.id) })
    if (s.estado === 'PREPARADA' && hasPerm('solicitud.entregar'))
      btns.push({ label: 'Entregar', color: 'default', fn: () => solicitudesApi.entregar(s.id) })
    if (s.estado === 'ENTREGADA' && hasPerm('solicitud.devolver'))
      btns.push({ label: 'Devolver', color: 'default', fn: () => solicitudesApi.devolver(s.id), devolucion: true })
    return btns
  }
}

function useEjecutar(id?: number) {
  const qc = useQueryClient()
  const { avisar } = useDialogos()
  return useMutation({
    mutationFn: (fn: () => Promise<unknown>) => fn(),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['solicitudes'] })
      if (id) qc.invalidateQueries({ queryKey: ['solicitud', id] })
    },
    onError: (e) => avisar(apiError(e), 'error'),
  })
}

/** Texto de cada tarjeta de estado (en plural: cuenta solicitudes). */
const ESTADO_TARJETA: Record<EstadoSolicitud, string> = {
  BORRADOR: 'Borradores',
  PENDIENTE_PROFESOR: 'Esperan profesor',
  PENDIENTE: 'Pendientes',
  APROBADA: 'Aprobadas',
  PREPARADA: 'Preparadas',
  ENTREGADA: 'Entregadas',
  DEVUELTA: 'Devueltas',
  CERRADA: 'Cerradas',
  RECHAZADA: 'Rechazadas',
}

/** En cristalería, CERRADA significa que el material ya volvió a bodega. */
const textoTarjeta = (e: EstadoSolicitud, tipo: TipoArticulo) =>
  e === 'CERRADA' && tipo === 'CRISTALERIA' ? 'Devueltas' : ESTADO_TARJETA[e]

/** Color del número, en línea con el de la etiqueta de estado. */
const ESTADO_COLOR: Record<EstadoSolicitud, string> = {
  BORRADOR: 'text-gray-600',
  PENDIENTE_PROFESOR: 'text-pink-600',
  PENDIENTE: 'text-yellow-600',
  APROBADA: 'text-cyan-600',
  PREPARADA: 'text-blue-600',
  ENTREGADA: 'text-purple-600',
  DEVUELTA: 'text-teal-600',
  CERRADA: 'text-green-600',
  RECHAZADA: 'text-red-600',
}

const fecha = (s?: string | null) => (s ? new Date(s).toLocaleDateString() : '—')

/** Listado de solicitudes de un solo tipo (cada tipo tiene su propia sección en el menú). */
export function SolicitudesPage({ tipo }: { tipo: TipoArticulo }) {
  const t = TIPO_SOLICITUD[tipo]
  const { hasPerm } = useAuth()
  const navigate = useNavigate()
  const [params, setParams] = useSearchParams()
  const [estado, setEstado] = useState<string>('')
  // Solicitud cuya devolución se está registrando (diálogo de piezas quebradas).
  const [devolverId, setDevolverId] = useState<number | null>(null)
  const qc = useQueryClient()
  const acciones = useAcciones()
  const run = useEjecutar()

  // El detalle abierto vive en la URL (?ver=12) para poder abrirlo al volver de "Nueva solicitud".
  const detalleId = Number(params.get('ver')) || null
  const verDetalle = (id: number | null) => setParams(id ? { ver: String(id) } : {}, { replace: true })

  // Filtro por fecha de solicitud (por defecto, los últimos 30 días); lo aplica la API.
  const [periodo, setPeriodo] = useState<Periodo>(PERIODO_INICIAL)
  const rango = rangoDe(periodo)

  // Se traen todas las del período; las tarjetas de estado cuentan y filtran sobre ellas.
  const { data, isLoading, error } = useQuery({
    queryKey: ['solicitudes', tipo, rango.desde ?? '', rango.hasta ?? ''],
    queryFn: () => solicitudesApi.list(tipo, rango),
  })
  const filtradas = estado ? data?.filter((s) => s.estado === estado) : data
  const pag = usePaginacion(filtradas, [estado, rango.desde, rango.hasta])
  const contar = (e: EstadoSolicitud) => data?.filter((s) => s.estado === e).length ?? 0

  return (
    <div className="space-y-5">
      <PageHeader title={t.titulo} subtitle={t.subtitulo}>
        {hasPerm('solicitud.crear') && (
          <Button size="sm" onClick={() => navigate(`${t.ruta}/nueva`)}>
            <HiPlus className="me-1.5 h-4 w-4" /> Nueva solicitud
          </Button>
        )}
      </PageHeader>

      <div className="flex items-center gap-3 flex-wrap">
        <FiltroPeriodo valor={periodo} onChange={setPeriodo} />
        <span className="text-sm text-gray-500">Solicitudes {describirPeriodo(periodo)}</span>
      </div>

      {/* Tarjetas por estado: tocar una filtra la lista; tocarla otra vez (o "Todas") quita el filtro. */}
      <div className="flex flex-wrap gap-2">
        <TarjetaFiltro texto="Todas" numero={data?.length ?? 0} color="text-primary-700"
          activa={!estado} onClick={() => setEstado('')} />
        {ESTADOS[tipo].map((e) => (
          <TarjetaFiltro key={e} texto={textoTarjeta(e, tipo)} numero={contar(e)} color={ESTADO_COLOR[e]}
            activa={estado === e} onClick={() => setEstado(estado === e ? '' : e)} />
        ))}
      </div>

      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}

      {data && (
        <section className="rounded-lg border border-gray-200 bg-white">
        <Table hoverable theme={{ root: { wrapper: 'relative overflow-x-auto rounded-t-lg' } }}>
          <TableHead>
            <TableRow>
              <TableHeadCell>#</TableHeadCell>
              <TableHeadCell>Estado</TableHeadCell>
              <TableHeadCell>Profesor</TableHeadCell>
              <TableHeadCell>Estudiante</TableHeadCell>
              <TableHeadCell>Clase / práctica</TableHeadCell>
              <TableHeadCell>Laboratorio</TableHeadCell>
              <TableHeadCell>Fecha</TableHeadCell>
              <TableHeadCell>Requerida</TableHeadCell>
              <TableHeadCell className="text-right">Acciones</TableHeadCell>
            </TableRow>
          </TableHead>
          <TableBody className="divide-y divide-gray-100">
            {filtradas?.length === 0 && (
              <TableRow><TableCell colSpan={9} className="text-center text-gray-400">
                {estado ? `Sin solicitudes ${textoTarjeta(estado as EstadoSolicitud, tipo).toLowerCase()} en este período.` : 'Sin solicitudes en este período.'}
              </TableCell></TableRow>
            )}
            {pag.visibles?.map((s) => (
              <TableRow key={s.id} className="bg-white cursor-pointer" onClick={() => verDetalle(s.id)}>
                <TableCell className="font-mono text-xs font-medium text-primary-700">#{s.id}</TableCell>
                <TableCell><EstadoBadge estado={s.estado} tipo={s.tipo} /></TableCell>
                <TableCell className="text-gray-900">{s.profesor}</TableCell>
                <TableCell>{s.estudiante ?? <span className="text-gray-400">—</span>}</TableCell>
                <TableCell>
                  {s.practica
                    ? <>
                        <div className="font-medium text-gray-900">{s.practica}</div>
                        <div className="text-xs text-gray-500">{s.clase} · {anioTexto(s.claseAnio)}</div>
                      </>
                    : <span className="text-gray-400">—</span>}
                </TableCell>
                <TableCell>{s.laboratorio}</TableCell>
                <TableCell className="font-mono text-xs whitespace-nowrap">{fecha(s.fechaSolicitud)}</TableCell>
                <TableCell className="font-mono text-xs whitespace-nowrap">{fecha(s.fechaRequerida)}</TableCell>
                <TableCell>
                  {/* stopPropagation: los botones no deben abrir además el detalle de la fila */}
                  <div className="flex gap-2 justify-end" onClick={(e) => e.stopPropagation()}>
                    <Button size="xs" color="light" onClick={() => verDetalle(s.id)}>
                      <HiEye className="me-1 h-3.5 w-3.5" /> Ver
                    </Button>
                    {acciones(s).map((b) => (
                      <Button key={b.label} size="xs" color={b.color} disabled={run.isPending}
                        onClick={() => (b.devolucion ? setDevolverId(s.id) : run.mutate(b.fn))}>
                        {b.label}
                      </Button>
                    ))}
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        {pag.total > 0 && (
          <div className="border-t border-gray-200 px-4 py-3">
            <Paginador p={pag} nombre={`solicitudes de ${t.plural}`} />
          </div>
        )}
        </section>
      )}

      {detalleId && (
        <Detalle id={detalleId} recienCreada={params.get('nueva') === '1'} onClose={() => verDetalle(null)}
          onDevolver={setDevolverId} />
      )}

      {devolverId && (
        <DevolucionModal solicitudId={devolverId} onClose={() => setDevolverId(null)}
          onDone={() => {
            setDevolverId(null)
            qc.invalidateQueries({ queryKey: ['solicitudes'] })
            qc.invalidateQueries({ queryKey: ['solicitud', devolverId] })
          }} />
      )}
    </div>
  )
}

/**
 * Pasos del flujo de una solicitud, con el actual resaltado: creada → visto bueno del profesor
 * (solo si la hizo un estudiante) → aprobación del supervisor → preparada → entregada (→ devuelta).
 */
function FlujoSolicitud({ cab }: { cab: SolicitudHeader }) {
  const pasos = [
    { clave: 'CREADA', label: 'Creada', fecha: fecha(cab.fechaSolicitud) },
    ...(cab.estudiante ? [{ clave: 'PENDIENTE_PROFESOR', label: 'Visto bueno del profesor', fecha: cab.fechaAvalProfesor ? fecha(cab.fechaAvalProfesor) : null }] : []),
    { clave: 'PENDIENTE', label: 'Aprobación del supervisor', fecha: null },
    { clave: 'APROBADA', label: 'Preparada en bodega', fecha: null },
    { clave: 'PREPARADA', label: cab.tipo === 'CRISTALERIA' ? 'Entregada' : 'Entregada y cerrada', fecha: null },
    ...(cab.tipo === 'CRISTALERIA' ? [{ clave: 'ENTREGADA', label: 'Devuelta a bodega', fecha: null }] : []),
  ]
  // Paso en curso: el que espera la acción que corresponde al estado actual.
  const rechazada = cab.estado === 'RECHAZADA'
  const enCurso = cab.estado === 'CERRADA' || cab.estado === 'DEVUELTA'
    ? pasos.length
    : rechazada
      ? pasos.findIndex((p) => p.clave === (cab.estudiante && !cab.fechaAvalProfesor ? 'PENDIENTE_PROFESOR' : 'PENDIENTE'))
      : Math.max(0, pasos.findIndex((p) => p.clave === cab.estado))

  return (
    <ol aria-label="Flujo de la solicitud" className="flex flex-wrap gap-y-3 rounded-lg border border-gray-200 px-4 py-3">
      {pasos.map((p, i) => {
        const hecho = i < enCurso
        const actual = i === enCurso
        return (
          <li key={p.clave} aria-current={actual ? 'step' : undefined}
            className="flex min-w-24 flex-1 items-start gap-2">
            <span className={`mt-1 h-3 w-3 shrink-0 rounded-full box-border ${
              hecho ? 'bg-primary-700'
                : actual ? (rechazada ? 'bg-white border-[3px] border-red-700' : 'bg-white border-[3px] border-amber-600')
                : 'bg-white border-2 border-gray-300'}`} />
            <span className="min-w-0 pe-2">
              <span className={`block text-[13px] leading-snug ${hecho || actual ? 'font-semibold text-gray-900' : 'text-gray-500'}`}>
                {p.label}
              </span>
              <span className="block font-mono text-[11px] text-gray-500">
                {actual ? (rechazada ? 'Rechazada' : 'En espera') : hecho ? (p.fecha ?? 'Hecho') : '—'}
              </span>
            </span>
          </li>
        )
      })}
    </ol>
  )
}

function Dato({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <div className="text-xs font-medium uppercase tracking-wide text-gray-500">{label}</div>
      <div className="mt-0.5 text-sm text-gray-900">{children}</div>
    </div>
  )
}

function Detalle({ id, recienCreada, onClose, onDevolver }: {
  id: number; recienCreada: boolean; onClose: () => void; onDevolver: (id: number) => void
}) {
  const acciones = useAcciones()
  const run = useEjecutar(id)
  const [verInfo, setVerInfo] = useState(false)
  const { data, isLoading, error } = useQuery({
    queryKey: ['solicitud', id],
    queryFn: () => solicitudesApi.get(id),
  })

  const cab = data?.cabecera
  const despachada = cab ? CON_DESPACHO.includes(cab.estado) : false
  // Solo la cristalería se devuelve; en las de reactivos no hay columna "Devuelto".
  const conDevolucion = despachada && cab?.tipo === 'CRISTALERIA'
  // Columna de quebradas solo si en la devolución se dio algo de baja.
  const conQuebradas = conDevolucion && !!data?.lineas.some((l) => l.cantQuebrada > 0)

  return (
    <Modal title={cab ? `Solicitud de ${TIPO_SOLICITUD[cab.tipo].plural} #${id}` : `Solicitud #${id}`}
      onClose={onClose} size="2xl">
      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}
      {data && cab && (
        <div className="space-y-4">
          {recienCreada && (
            <Alert color="success" icon={HiCheckCircle}>
              {cab.estado === 'PENDIENTE_PROFESOR'
                ? <>Solicitud creada. Primero debe avalarla tu profesor, <strong>{cab.profesor}</strong>; luego pasa al supervisor.</>
                : <>Solicitud creada. Queda <strong>PENDIENTE</strong> hasta que un supervisor la apruebe.</>}
            </Alert>
          )}

          <FlujoSolicitud cab={cab} />

          {/* Acordeón: cerrado solo muestra estado y un resumen, para que los artículos queden a la vista. */}
          <div className="rounded-lg border border-gray-200 bg-gray-50">
            <button type="button" onClick={() => setVerInfo((v) => !v)} aria-expanded={verInfo}
              className="flex w-full items-center gap-3 px-4 py-3 text-left rounded-lg hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-primary-300">
              <EstadoBadge estado={cab.estado} tipo={cab.tipo} />
              <span className="min-w-0 flex-1 truncate text-sm text-gray-700">
                {[cab.practica, cab.estudiante ?? cab.profesor, fecha(cab.fechaSolicitud)].filter(Boolean).join(' · ')}
              </span>
              <span className="shrink-0 text-sm font-medium text-primary-700">{verInfo ? 'Ocultar' : 'Ver información'}</span>
              <HiChevronDown className={`h-4 w-4 shrink-0 text-primary-700 transition-transform ${verInfo ? 'rotate-180' : ''}`} />
            </button>
          {verInfo && (
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-4 border-t border-gray-200 p-4">
            <Dato label={cab.estudiante ? 'Profesor responsable' : 'Profesor'}>{cab.profesor ?? '—'}</Dato>
            {cab.estudiante && <Dato label="Estudiante">{cab.estudiante}</Dato>}
            {cab.clase && <Dato label="Clase">{cab.clase} · {anioTexto(cab.claseAnio)}</Dato>}
            {cab.practica && <Dato label="Práctica">{cab.practica}</Dato>}
            <Dato label="Laboratorio">{cab.laboratorio ?? '—'}</Dato>
            <Dato label="Fecha de solicitud">{fecha(cab.fechaSolicitud)}</Dato>
            <Dato label="Fecha requerida">{fecha(cab.fechaRequerida)}</Dato>
            {cab.estudiante && (
              <Dato label="Visto bueno del profesor">
                {cab.fechaAvalProfesor
                  ? fecha(cab.fechaAvalProfesor)
                  : <span className="text-gray-400">{cab.estado === 'PENDIENTE_PROFESOR' ? 'Pendiente' : 'No avalada'}</span>}
              </Dato>
            )}
            {cab.observaciones && (
              <div className="col-span-2 sm:col-span-3">
                <Dato label="Observaciones"><span className="whitespace-pre-line">{cab.observaciones}</span></Dato>
              </div>
            )}
          </div>
          )}
          </div>

          {cab.motivoRechazo && <ErrorAlert>Motivo del rechazo: {cab.motivoRechazo}</ErrorAlert>}

          <h4 className="text-sm font-semibold text-gray-900">
            Artículos <span className="font-normal text-gray-500">({data.lineas.length})</span>
          </h4>
          <Table>
            <TableHead>
              <TableRow>
                <TableHeadCell>Artículo</TableHeadCell>
                <TableHeadCell className="text-right">Solicitado</TableHeadCell>
                {despachada && <TableHeadCell className="text-right">Preparado</TableHeadCell>}
                {conDevolucion && <TableHeadCell className="text-right">Devuelto</TableHeadCell>}
                {conQuebradas && <TableHeadCell className="text-right">Quebrado</TableHeadCell>}
              </TableRow>
            </TableHead>
            <TableBody className="divide-y">
              {data.lineas.map((l) => (
                <TableRow key={l.id} className="bg-white">
                  <TableCell className="text-gray-900">{l.articulo}</TableCell>
                  <TableCell className="text-right tabular-nums">{l.cantSolicitada} {l.unidad}</TableCell>
                  {despachada && <TableCell className="text-right tabular-nums">{l.cantPreparada}</TableCell>}
                  {conDevolucion && (
                    <TableCell className="text-right tabular-nums">
                      {l.tipo === 'REACTIVO' ? <span className="text-gray-400">consumido</span> : l.cantDevuelta}
                    </TableCell>
                  )}
                  {conQuebradas && (
                    <TableCell className="text-right tabular-nums">
                      {l.cantQuebrada > 0 ? <span className="font-medium text-red-700">{l.cantQuebrada}</span> : '—'}
                    </TableCell>
                  )}
                </TableRow>
              ))}
            </TableBody>
          </Table>

          <div className="flex flex-wrap justify-end gap-2 border-t border-gray-200 pt-4">
            {acciones(cab).map((b) => (
              <Button key={b.label} size="sm" color={b.color} disabled={run.isPending}
                onClick={() => (b.devolucion ? onDevolver(id) : run.mutate(b.fn))}>
                {b.label}
              </Button>
            ))}
            <Button size="sm" color="light" onClick={onClose}>Cerrar</Button>
          </div>
        </div>
      )}
    </Modal>
  )
}
