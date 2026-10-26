import { useEffect, useState } from 'react'
import { Pagination, Select } from 'flowbite-react'

const OPCIONES_POR_PAGINA = [10, 25, 50]

/**
 * Paginación en el navegador para cualquier listado.
 * `reiniciarCon`: valores que, al cambiar (pestaña, búsqueda, filtro), devuelven a la página 1.
 */
export function usePaginacion<T>(items: T[] | undefined, reiniciarCon: unknown[] = [], porPaginaInicial = 10) {
  const [pagina, setPagina] = useState(1)
  const [porPagina, setPorPaginaState] = useState(porPaginaInicial)

  // eslint-disable-next-line react-hooks/exhaustive-deps
  useEffect(() => { setPagina(1) }, [JSON.stringify(reiniciarCon)])

  const total = items?.length ?? 0
  const totalPaginas = Math.max(1, Math.ceil(total / porPagina))
  // Si al filtrar o desactivar quedan menos páginas, no quedarse en una página vacía.
  const actual = Math.min(pagina, totalPaginas)
  const visibles = items?.slice((actual - 1) * porPagina, actual * porPagina)

  return {
    visibles,
    pagina: actual,
    setPagina,
    porPagina,
    setPorPagina: (n: number) => { setPorPaginaState(n); setPagina(1) },
    total,
    totalPaginas,
  }
}

type Paginacion = ReturnType<typeof usePaginacion>

/** Pie de tabla: "Mostrando 11–20 de 57", filas por página y botones de página. */
export function Paginador({ p, nombre = 'registros' }: { p: Paginacion; nombre?: string }) {
  if (p.total === 0) return null
  const desde = (p.pagina - 1) * p.porPagina + 1
  const hasta = Math.min(p.pagina * p.porPagina, p.total)

  return (
    <div className="flex flex-wrap items-center justify-between gap-3 text-sm text-gray-600">
      <div className="flex items-center gap-3">
        <span>
          Mostrando <strong className="text-gray-900">{desde}–{hasta}</strong> de{' '}
          <strong className="text-gray-900">{p.total}</strong> {nombre}
        </span>
        <Select sizing="sm" aria-label="Filas por página" value={p.porPagina}
          onChange={(e) => p.setPorPagina(Number(e.target.value))}>
          {OPCIONES_POR_PAGINA.map((n) => <option key={n} value={n}>{n} por página</option>)}
        </Select>
      </div>
      {p.totalPaginas > 1 && (
        <Pagination currentPage={p.pagina} totalPages={p.totalPaginas} onPageChange={p.setPagina}
          showIcons previousLabel="Anterior" nextLabel="Siguiente" className="[&_ul]:mt-0" />
      )}
    </div>
  )
}
