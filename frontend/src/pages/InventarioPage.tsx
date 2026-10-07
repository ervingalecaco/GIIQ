import { useQuery } from '@tanstack/react-query'
import { Badge, Table, TableBody, TableCell, TableHead, TableHeadCell, TableRow } from 'flowbite-react'
import { inventarioApi } from '../api/catalogos'
import { Cargando, ErrorAlert, PageHeader } from '../components/Feedback'

export function InventarioPage() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['existencias'],
    queryFn: inventarioApi.existencias,
  })

  return (
    <div className="space-y-5">
      <PageHeader title="Inventario" subtitle="Existencias actuales por artículo (suma de sus lotes)." />

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
            {data.map((e) => (
              <TableRow key={e.articuloId} className="bg-white">
                <TableCell className="font-mono text-xs">{e.codigo}</TableCell>
                <TableCell className="text-gray-900">{e.nombre}</TableCell>
                <TableCell>{e.tipo}</TableCell>
                <TableCell className="text-right tabular-nums">{e.existencia} {e.unidad}</TableCell>
                <TableCell className="text-right tabular-nums">{e.stockMinimo}</TableCell>
                <TableCell>
                  {e.bajoMinimo
                    ? <Badge color="failure" className="w-fit">Bajo mínimo</Badge>
                    : <Badge color="success" className="w-fit">OK</Badge>}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  )
}
