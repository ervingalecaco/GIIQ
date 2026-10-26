import { useEffect, useRef, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { HiBell } from 'react-icons/hi'
import { haceCuanto, notificacionesApi, type Notificacion } from '../api/notificaciones'

/** Cada cuánto se consulta el contador (las notificaciones las crea el servidor al actuar otro usuario). */
const CADA_MS = 30_000

/**
 * Campana de notificaciones de la barra superior: contador de no leídas y, al abrirla,
 * las más recientes. Tocar una la marca como leída y lleva a lo que avisa.
 * `oscura`: versión para la barra marino del celular.
 */
export function Campana({ oscura = false }: { oscura?: boolean }) {
  const navigate = useNavigate()
  const qc = useQueryClient()
  const [abierta, setAbierta] = useState(false)
  const caja = useRef<HTMLDivElement>(null)

  const conteo = useQuery({
    queryKey: ['notificaciones', 'no-leidas'],
    queryFn: notificacionesApi.noLeidas,
    refetchInterval: CADA_MS,
    refetchOnWindowFocus: true,
  })
  const lista = useQuery({
    queryKey: ['notificaciones', 'recientes'],
    queryFn: () => notificacionesApi.list({ limite: 8 }),
    enabled: abierta,
  })
  const noLeidas = conteo.data ?? 0

  // Si llegan avisos nuevos, lo que se ve en pantalla puede haber cambiado (estado de solicitudes, cuentas).
  const anterior = useRef<number | null>(null)
  useEffect(() => {
    if (anterior.current !== null && noLeidas > anterior.current) {
      for (const k of ['solicitudes', 'solicitud', 'dashboard', 'cuenta', 'cuentas']) qc.invalidateQueries({ queryKey: [k] })
    }
    anterior.current = noLeidas
  }, [noLeidas, qc])

  // Cerrar al hacer clic fuera o con Escape.
  useEffect(() => {
    if (!abierta) return
    const fuera = (e: MouseEvent) => { if (!caja.current?.contains(e.target as Node)) setAbierta(false) }
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') setAbierta(false) }
    document.addEventListener('mousedown', fuera)
    document.addEventListener('keydown', esc)
    return () => { document.removeEventListener('mousedown', fuera); document.removeEventListener('keydown', esc) }
  }, [abierta])

  function refrescar() {
    qc.invalidateQueries({ queryKey: ['notificaciones'] })
  }

  async function abrir(n: Notificacion) {
    setAbierta(false)
    if (!n.leida) { await notificacionesApi.marcarLeida(n.id); refrescar() }
    if (n.enlace) navigate(n.enlace)
  }

  async function marcarTodas() {
    await notificacionesApi.marcarTodas()
    refrescar()
  }

  return (
    <div ref={caja} className="relative">
      <button type="button" onClick={() => setAbierta((v) => !v)} aria-expanded={abierta} aria-haspopup="true"
        aria-label={noLeidas ? `Notificaciones: ${noLeidas} sin leer` : 'Notificaciones'}
        className={`relative inline-flex h-9 w-9 items-center justify-center rounded-md focus:outline-none
                    focus-visible:ring-2 focus-visible:ring-primary-300 ${oscura
                      ? 'text-slate-200 hover:bg-white/10'
                      : 'text-gray-500 hover:bg-gray-100 hover:text-gray-900'}`}>
        <HiBell className="h-5 w-5" />
        {noLeidas > 0 && (
          <span className="absolute -right-0.5 -top-0.5 min-w-[18px] rounded-full bg-red-600 px-1 text-center
                           font-mono text-[10px] font-semibold leading-[18px] text-white">
            {noLeidas > 99 ? '99+' : noLeidas}
          </span>
        )}
      </button>

      {abierta && (
        <div role="dialog" aria-label="Notificaciones"
          className="absolute right-0 z-50 mt-2 w-[22rem] max-w-[calc(100vw-2rem)] overflow-hidden rounded-lg border border-gray-200 bg-white shadow-lg">
          <div className="flex items-center justify-between border-b border-gray-100 px-4 py-3">
            <h2 className="text-sm font-semibold text-gray-900">Notificaciones</h2>
            {noLeidas > 0 && (
              <button type="button" onClick={marcarTodas} className="text-xs font-medium text-primary-700 hover:text-primary-900">
                Marcar todas como leídas
              </button>
            )}
          </div>
          <div className="max-h-[26rem] overflow-y-auto">
            {lista.isLoading && <p className="px-4 py-6 text-sm text-gray-400">Cargando…</p>}
            {lista.data?.items.length === 0 && (
              <p className="px-4 py-8 text-center text-sm text-gray-400">No tienes notificaciones.</p>
            )}
            {lista.data?.items.map((n) => (
              <button key={n.id} type="button" onClick={() => abrir(n)}
                className={`flex w-full gap-3 border-b border-gray-100 px-4 py-3 text-left last:border-b-0 hover:bg-gray-50 ${
                  n.leida ? '' : 'bg-primary-50/60'}`}>
                <span className={`mt-1.5 h-2 w-2 shrink-0 rounded-full ${n.leida ? 'bg-transparent' : 'bg-primary-600'}`}
                  aria-hidden />
                <span className="min-w-0 flex-1">
                  <span className={`block text-sm ${n.leida ? 'font-medium text-gray-700' : 'font-semibold text-gray-900'}`}>
                    {n.titulo}
                  </span>
                  <span className="mt-0.5 block text-[13px] leading-snug text-gray-600">{n.mensaje}</span>
                  <span className="mt-1 block font-mono text-[11px] text-gray-400">{haceCuanto(n.creadaEn)}</span>
                </span>
              </button>
            ))}
          </div>
          <Link to="/notificaciones" onClick={() => setAbierta(false)}
            className="block border-t border-gray-100 px-4 py-2.5 text-center text-sm font-medium text-primary-700 hover:bg-gray-50">
            Ver todas
          </Link>
        </div>
      )}
    </div>
  )
}
