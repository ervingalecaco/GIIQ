import type { ReactNode } from 'react'
import { Drawer } from 'flowbite-react'
import { HiX } from 'react-icons/hi'

/**
 * Panel lateral derecho para ver el detalle de una fila de un reporte (maestro-detalle)
 * sin perder de vista la tabla. Se cierra con la ✕, con Escape o al tocar fuera.
 */
export function PanelDetalle({ abierto, onCerrar, rotulo, titulo, subtitulo, acciones, children }: {
  abierto: boolean
  onCerrar: () => void
  /** Texto pequeño sobre el título (p. ej. el código del artículo). */
  rotulo?: ReactNode
  titulo: ReactNode
  subtitulo?: ReactNode
  /** Botones al pie del panel. */
  acciones?: ReactNode
  children: ReactNode
}) {
  return (
    <Drawer open={abierto} onClose={onCerrar} position="right" aria-label="Detalle"
      className="flex w-full max-w-xl flex-col p-0">
      <div className="flex items-start gap-3 border-b border-gray-200 px-5 py-4">
        <div className="min-w-0 flex-1">
          {rotulo && <p className="rotulo mb-1 text-gray-500">{rotulo}</p>}
          <h2 className="text-lg font-semibold text-gray-900">{titulo}</h2>
          {subtitulo && <div className="mt-1.5 text-sm text-gray-600">{subtitulo}</div>}
        </div>
        <button type="button" onClick={onCerrar} aria-label="Cerrar detalle"
          className="-me-1 rounded-md p-1.5 text-gray-400 hover:bg-gray-100 hover:text-gray-700
                     focus:outline-none focus-visible:ring-2 focus-visible:ring-primary-300">
          <HiX className="h-5 w-5" />
        </button>
      </div>
      <div className="flex-1 space-y-6 overflow-y-auto px-5 py-5">{children}</div>
      {acciones && <div className="flex justify-end gap-2 border-t border-gray-200 px-5 py-3">{acciones}</div>}
    </Drawer>
  )
}

/** Dato resumido (etiqueta + valor) para la cabecera del detalle. */
export function DatoDetalle({ etiqueta, children }: { etiqueta: string; children: ReactNode }) {
  return (
    <div className="rounded-md border border-gray-200 px-3 py-2.5">
      <p className="rotulo text-gray-500">{etiqueta}</p>
      <p className="mt-0.5 font-mono text-base font-semibold tabular-nums text-gray-900">{children}</p>
    </div>
  )
}
