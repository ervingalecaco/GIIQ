import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { Button } from 'flowbite-react'
import { haceCuanto, notificacionesApi, type Notificacion } from '../api/notificaciones'
import { Cargando, ErrorAlert, PageHeader } from '../components/Feedback'
import { Paginador, usePaginacion } from '../components/Paginacion'

type Vista = 'noLeidas' | 'todas'

/** Todas las notificaciones del usuario, con pestañas de no leídas y todas. */
export function NotificacionesPage() {
  const navigate = useNavigate()
  const qc = useQueryClient()
  const [vista, setVista] = useState<Vista>('noLeidas')
  const { data, isLoading, error } = useQuery({
    queryKey: ['notificaciones', 'todas'],
    queryFn: () => notificacionesApi.list({ limite: 500 }),
  })
  const items = data?.items ?? []
  const conteo = { noLeidas: items.filter((n) => !n.leida).length, todas: items.length }
  const visibles = vista === 'noLeidas' ? items.filter((n) => !n.leida) : items
  const pag = usePaginacion(visibles, [vista])

  const refrescar = () => qc.invalidateQueries({ queryKey: ['notificaciones'] })

  async function abrir(n: Notificacion) {
    if (!n.leida) { await notificacionesApi.marcarLeida(n.id); refrescar() }
    if (n.enlace) navigate(n.enlace)
  }

  return (
    <div className="space-y-5">
      <PageHeader title="Notificaciones" subtitle="Avisos de tus solicitudes y de lo que espera tu acción.">
        {conteo.noLeidas > 0 && (
          <Button size="sm" color="light" onClick={async () => { await notificacionesApi.marcarTodas(); refrescar() }}>
            Marcar todas como leídas
          </Button>
        )}
      </PageHeader>

      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}

      {data && (
        <section className="rounded-lg border border-gray-200 bg-white">
          <div role="tablist" aria-label="Filtro de notificaciones" className="flex gap-1 border-b border-gray-200 px-4">
            {([['noLeidas', 'No leídas'], ['todas', 'Todas']] as [Vista, string][]).map(([k, label]) => {
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

          {visibles.length === 0 && (
            <p className="px-4 py-10 text-center text-sm text-gray-400">
              {vista === 'noLeidas' ? 'Estás al día: no tienes notificaciones sin leer.' : 'Aún no tienes notificaciones.'}
            </p>
          )}
          {pag.visibles?.map((n) => (
            <button key={n.id} type="button" onClick={() => abrir(n)}
              className={`flex w-full gap-3 border-b border-gray-100 px-4 py-3.5 text-left hover:bg-gray-50 ${
                n.leida ? '' : 'bg-primary-50/60'}`}>
              <span className={`mt-1.5 h-2 w-2 shrink-0 rounded-full ${n.leida ? 'bg-gray-200' : 'bg-primary-600'}`} aria-hidden />
              <span className="min-w-0 flex-1">
                <span className={`block text-sm ${n.leida ? 'font-medium text-gray-700' : 'font-semibold text-gray-900'}`}>{n.titulo}</span>
                <span className="mt-0.5 block text-sm text-gray-600">{n.mensaje}</span>
              </span>
              <span className="shrink-0 font-mono text-xs text-gray-400">{haceCuanto(n.creadaEn)}</span>
            </button>
          ))}
          {pag.total > 0 && (
            <div className="px-4 py-3"><Paginador p={pag} nombre="notificaciones" /></div>
          )}
        </section>
      )}
    </div>
  )
}
