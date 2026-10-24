import { useMemo, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import {
  Badge, Button, Table, TableBody, TableCell, TableHead, TableHeadCell, TableRow, TextInput,
} from 'flowbite-react'
import { HiArrowLeft, HiSearch } from 'react-icons/hi'
import { cuentasApi } from '../api/bajas'
import { useAuth } from '../auth/AuthContext'
import { CuentaVista } from '../components/CuentaVista'
import { Cargando, ErrorAlert, PageHeader } from '../components/Feedback'
import { Paginador, usePaginacion } from '../components/Paginacion'

const sinAcentos = (s: string) => s.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase()
const fecha = (s?: string | null) =>
  s ? new Date(s).toLocaleDateString('es', { day: '2-digit', month: 'short', year: 'numeric' }) : '—'

type Vista = 'deben' | 'solventes'

/** Estudiantes con cristalería por reponer (y los que ya saldaron), para bodega. */
export function CuentasPage() {
  const navigate = useNavigate()
  const { data, isLoading, error } = useQuery({ queryKey: ['cuentas'], queryFn: cuentasApi.list })
  const [vista, setVista] = useState<Vista>('deben')
  const [buscar, setBuscar] = useState('')

  const filtradas = useMemo(() => {
    const q = sinAcentos(buscar.trim())
    return data?.filter((c) => !q || sinAcentos(`${c.codigo ?? ''} ${c.estudiante}`).includes(q))
  }, [data, buscar])
  const conteo = {
    deben: filtradas?.filter((c) => c.piezasPendientes > 0).length ?? 0,
    solventes: filtradas?.filter((c) => c.piezasPendientes <= 0).length ?? 0,
  }
  const visibles = filtradas?.filter((c) => (vista === 'deben' ? c.piezasPendientes > 0 : c.piezasPendientes <= 0))
  const pag = usePaginacion(visibles, [vista, buscar])

  return (
    <div className="space-y-5">
      <PageHeader title="Cuentas de estudiantes"
        subtitle="Cristalería quebrada pendiente de reponer. Sin deuda, se emite la constancia de solvencia para culminar estudios." />

      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}

      {data && visibles && (
        <section className="rounded-lg border border-gray-200 bg-white">
          <div className="flex flex-wrap items-center justify-between gap-3 border-b border-gray-200 px-4">
            <div role="tablist" aria-label="Estado de las cuentas" className="flex flex-wrap gap-1">
              {([['deben', 'Con piezas pendientes'], ['solventes', 'Saldadas']] as [Vista, string][]).map(([k, label]) => {
                const sel = vista === k
                return (
                  <button key={k} type="button" role="tab" aria-selected={sel} onClick={() => setVista(k)}
                    className={`-mb-px flex h-12 items-center gap-2 border-b-2 px-3 text-sm focus:outline-none focus-visible:ring-2 focus-visible:ring-primary-300 ${
                      sel ? 'border-primary-700 font-semibold text-gray-900' : 'border-transparent font-medium text-gray-500 hover:text-gray-900'}`}>
                    {label}
                    <span className={`rounded px-1.5 py-px font-mono text-[11px] ${
                      sel ? 'bg-primary-100 text-primary-900' : 'bg-gray-100 text-gray-600'}`}>{conteo[k]}</span>
                  </button>
                )
              })}
            </div>
            <div className="py-2">
              <TextInput sizing="sm" icon={HiSearch} className="w-full sm:w-72" aria-label="Buscar estudiante"
                placeholder="Buscar por código o nombre" value={buscar} onChange={(e) => setBuscar(e.target.value)} />
            </div>
          </div>

          <Table hoverable theme={{ root: { wrapper: 'relative overflow-x-auto' } }}>
            <TableHead>
              <TableRow>
                <TableHeadCell>Código</TableHeadCell>
                <TableHeadCell>Estudiante</TableHeadCell>
                <TableHeadCell className="text-right">Piezas pendientes</TableHeadCell>
                <TableHeadCell className="text-right">Cargos</TableHeadCell>
                <TableHeadCell>Última baja</TableHeadCell>
                <TableHeadCell>Estado</TableHeadCell>
                <TableHeadCell className="text-right">Acciones</TableHeadCell>
              </TableRow>
            </TableHead>
            <TableBody className="divide-y divide-gray-100">
              {visibles.length === 0 && (
                <TableRow>
                  <TableCell colSpan={7} className="text-center text-gray-400">
                    {buscar ? 'Ningún estudiante coincide con la búsqueda.'
                      : vista === 'deben' ? 'Ningún estudiante debe cristalería.' : 'Aún no hay cuentas saldadas.'}
                  </TableCell>
                </TableRow>
              )}
              {pag.visibles?.map((c) => (
                <TableRow key={c.estudianteId} className="bg-white cursor-pointer"
                  onClick={() => navigate(`/cuentas/${c.estudianteId}`)}>
                  <TableCell className="font-mono text-xs font-medium text-primary-700">{c.codigo ?? '—'}</TableCell>
                  <TableCell className="font-medium text-gray-900">
                    {c.estudiante}
                    {!c.activo && <Badge color="gray" className="ms-2 inline-flex w-fit">Inactivo</Badge>}
                  </TableCell>
                  <TableCell className="text-right font-mono text-xs tabular-nums">
                    {c.piezasPendientes > 0 ? <span className="font-semibold text-amber-800">{c.piezasPendientes}</span> : '0'}
                  </TableCell>
                  <TableCell className="text-right font-mono text-xs tabular-nums">{c.cargosPendientes} / {c.cargosTotales}</TableCell>
                  <TableCell className="font-mono text-xs">{fecha(c.ultimaBaja)}</TableCell>
                  <TableCell>
                    {c.piezasPendientes > 0
                      ? <Badge color="warning" className="w-fit">Debe reponer</Badge>
                      : <Badge color="success" className="w-fit">Solvente</Badge>}
                  </TableCell>
                  <TableCell className="text-right">
                    <Button size="xs" color="light" onClick={(e) => { e.stopPropagation(); navigate(`/cuentas/${c.estudianteId}`) }}>
                      Ver cuenta
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
          {pag.total > 0 && (
            <div className="border-t border-gray-200 px-4 py-3"><Paginador p={pag} nombre="estudiantes" /></div>
          )}
        </section>
      )}
    </div>
  )
}

/** Cuenta de un estudiante (bodega): reposiciones y constancia de solvencia. */
export function CuentaEstudiantePage() {
  const { id } = useParams()
  const estudianteId = Number(id)
  const { hasPerm } = useAuth()
  const qc = useQueryClient()
  const { data, isLoading, error } = useQuery({
    queryKey: ['cuenta', estudianteId],
    queryFn: () => cuentasApi.detalle(estudianteId),
    enabled: estudianteId > 0,
  })

  return (
    <div className="space-y-5">
      <Link to="/cuentas" className="inline-flex items-center gap-1.5 text-sm font-medium text-primary-700 hover:text-primary-900">
        <HiArrowLeft className="h-4 w-4" /> Cuentas de estudiantes
      </Link>
      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}
      {data && (
        <>
          <PageHeader title={data.resumen.estudiante}
            subtitle={`Código ${data.resumen.codigo ?? '—'} · cuenta de cristalería`} />
          <CuentaVista cuenta={data}
            puedeReponer={hasPerm('reposicion.registrar')} puedeEmitir={hasPerm('solvencia.emitir')}
            onCambio={() => {
              qc.invalidateQueries({ queryKey: ['cuenta', estudianteId] })
              qc.invalidateQueries({ queryKey: ['cuentas'] })
            }} />
        </>
      )}
    </div>
  )
}

/** Cuenta del estudiante que inició sesión (solo lectura). */
export function MiCuentaPage() {
  const { data, isLoading, error } = useQuery({ queryKey: ['cuenta', 'mia'], queryFn: cuentasApi.mia })
  return (
    <div className="space-y-5">
      <PageHeader title="Mi cuenta"
        subtitle="Cristalería que quebraste en prácticas. Para saldarla, entrega en bodega una pieza igual." />
      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}
      {data && <CuentaVista cuenta={data} />}
    </div>
  )
}
