import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Badge, Table, TableBody, TableCell, TableHead, TableHeadCell, TableRow, TextInput } from 'flowbite-react'
import { HiSearch } from 'react-icons/hi'
import { inventarioApi } from '../api/catalogos'
import { Cargando, ErrorAlert, PageHeader, TipoBadge } from '../components/Feedback'
import { Paginador, usePaginacion } from '../components/Paginacion'
import { sinAcentos } from '../components/SelectBuscable'
import { TarjetaFiltro } from '../components/TarjetaFiltro'
import type { TipoArticulo } from '../types'

type Stock = 'BAJO' | 'AGOTADO'

export function InventarioPage() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['existencias'],
    queryFn: inventarioApi.existencias,
  })
  const [tipo, setTipo] = useState<TipoArticulo | ''>('')
  const [stock, setStock] = useState<Stock | ''>('')
  const [buscar, setBuscar] = useState('')

  const agotado = (e: { existencia: number }) => e.existencia <= 0
  const bajo = (e: { existencia: number; bajoMinimo: boolean }) => e.bajoMinimo && !agotado(e)

  // Cada filtro se aplica en orden; las tarjetas de tipo cuentan sobre la búsqueda,
  // y las de existencias sobre la búsqueda + el tipo elegido.
  const q = sinAcentos(buscar.trim())
  const buscados = data?.filter((e) => !q || sinAcentos(`${e.codigo} ${e.nombre}`).includes(q))
  const delTipo = buscados?.filter((e) => !tipo || e.tipo === tipo)
  const filtrados = delTipo?.filter((e) => !stock || (stock === 'AGOTADO' ? agotado(e) : bajo(e)))
  const pag = usePaginacion(filtrados, [tipo, stock, q])

  const cuantos = (t: TipoArticulo) => buscados?.filter((e) => e.tipo === t).length ?? 0
  // Tocar la tarjeta activa la desactiva (vuelve a "todos").
  const alternarTipo = (t: TipoArticulo | '') => setTipo(tipo === t ? '' : t)
  const alternarStock = (s: Stock) => setStock(stock === s ? '' : s)

  return (
    <div className="space-y-5">
      <PageHeader title="Inventario" subtitle="Existencias actuales por artículo (suma de sus lotes)." />

      <div className="flex flex-wrap items-center gap-2">
        <TarjetaFiltro texto="Todos" numero={buscados?.length ?? 0} color="text-primary-700"
          activa={!tipo} onClick={() => setTipo('')} />
        <TarjetaFiltro texto="Reactivos" numero={cuantos('REACTIVO')} color="text-blue-600"
          activa={tipo === 'REACTIVO'} onClick={() => alternarTipo('REACTIVO')} />
        <TarjetaFiltro texto="Cristalería" numero={cuantos('CRISTALERIA')} color="text-cyan-600"
          activa={tipo === 'CRISTALERIA'} onClick={() => alternarTipo('CRISTALERIA')} />
        <span className="mx-1 hidden h-6 border-l border-gray-300 sm:block" aria-hidden />
        <TarjetaFiltro texto="Bajo mínimo" numero={delTipo?.filter(bajo).length ?? 0} color="text-orange-500"
          activa={stock === 'BAJO'} onClick={() => alternarStock('BAJO')} />
        <TarjetaFiltro texto="Agotados" numero={delTipo?.filter(agotado).length ?? 0} color="text-red-600"
          activa={stock === 'AGOTADO'} onClick={() => alternarStock('AGOTADO')} />
      </div>

      <TextInput icon={HiSearch} placeholder="Buscar por código o nombre…" value={buscar}
        onChange={(e) => setBuscar(e.target.value)} className="max-w-md" />

      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}

      {data && (
        <Table hoverable>
          <TableHead>
            <TableRow>
              <TableHeadCell>Código</TableHeadCell>
              <TableHeadCell>Artículo</TableHeadCell>
              <TableHeadCell>Tipo</TableHeadCell>
              <TableHeadCell className="text-right">Existencia</TableHeadCell>
              <TableHeadCell className="text-right">Mínimo</TableHeadCell>
              <TableHeadCell>Estado</TableHeadCell>
            </TableRow>
          </TableHead>
          <TableBody className="divide-y">
            {filtrados?.length === 0 && (
              <TableRow><TableCell colSpan={6} className="text-center text-gray-400">
                No hay artículos con estos filtros.
              </TableCell></TableRow>
            )}
            {pag.visibles?.map((e) => (
              <TableRow key={e.articuloId} className="bg-white">
                <TableCell className="font-mono text-xs">{e.codigo}</TableCell>
                <TableCell className="text-gray-900">{e.nombre}</TableCell>
                <TableCell><TipoBadge tipo={e.tipo} /></TableCell>
                <TableCell className="text-right tabular-nums">{e.existencia} {e.unidad}</TableCell>
                <TableCell className="text-right tabular-nums">{e.stockMinimo}</TableCell>
                <TableCell>
                  {agotado(e)
                    ? <Badge color="failure" className="w-fit">Agotado</Badge>
                    : e.bajoMinimo
                      ? <Badge color="warning" className="w-fit">Bajo mínimo</Badge>
                      : <Badge color="success" className="w-fit">OK</Badge>}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
      {data && <Paginador p={pag} nombre="artículos" />}
    </div>
  )
}
