import { useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  Badge, Button, Select, Table, TableBody, TableCell, TableHead, TableHeadCell, TableRow,
} from 'flowbite-react'
import { HiPlus } from 'react-icons/hi'
import { articulosApi } from '../api/catalogos'
import { apiError } from '../api/client'
import { useAuth } from '../auth/AuthContext'
import { ArticuloFormModal } from '../components/ArticuloFormModal'
import { EntradaFormModal } from '../components/EntradaFormModal'
import { ActivoBadge, Cargando, ErrorAlert, PageHeader } from '../components/Feedback'
import type { Articulo } from '../types'

export function ArticulosPage() {
  const { hasPerm } = useAuth()
  const qc = useQueryClient()
  const [tipo, setTipo] = useState('')
  const [editar, setEditar] = useState<number | 'nuevo' | null>(null)
  const [entrada, setEntrada] = useState<Articulo | null>(null)

  const { data, isLoading, error } = useQuery({
    queryKey: ['articulos', tipo || 'ALL'],
    queryFn: () => articulosApi.list(tipo || undefined),
  })

  const estado = useMutation({
    mutationFn: ({ id, activo }: { id: number; activo: boolean }) =>
      articulosApi.cambiarEstado(id, activo),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['articulos'] }),
    onError: (e) => alert(apiError(e)),
  })

  function refrescar() {
    qc.invalidateQueries({ queryKey: ['articulos'] })
    qc.invalidateQueries({ queryKey: ['existencias'] })
  }

  return (
    <div className="space-y-5">
      <PageHeader title="Artículos">
        <Select sizing="sm" value={tipo} onChange={(e) => setTipo(e.target.value)}>
          <option value="">Todos</option>
          <option value="REACTIVO">Reactivos</option>
          <option value="MATERIAL">Materiales</option>
        </Select>
        {hasPerm('articulos.crear') && (
          <Button size="sm" onClick={() => setEditar('nuevo')}>
            <HiPlus className="me-1.5 h-4 w-4" /> Nuevo artículo
          </Button>
        )}
      </PageHeader>

      {isLoading && <Cargando />}
      {error && <ErrorAlert error={error} />}

      {data && (
        <Table hoverable>
          <TableHead>
            <TableRow>
              <TableHeadCell>Código</TableHeadCell>
              <TableHeadCell>Nombre</TableHeadCell>
              <TableHeadCell>Tipo</TableHeadCell>
              <TableHeadCell>Categoría</TableHeadCell>
              <TableHeadCell>Unidad</TableHeadCell>
              <TableHeadCell className="text-right">Mínimo</TableHeadCell>
              <TableHeadCell>Estado</TableHeadCell>
              <TableHeadCell className="text-right">Acciones</TableHeadCell>
            </TableRow>
          </TableHead>
          <TableBody className="divide-y">
            {data.length === 0 && (
              <TableRow><TableCell colSpan={8} className="text-center text-gray-400">Sin artículos.</TableCell></TableRow>
            )}
            {data.map((a) => (
              <TableRow key={a.id} className={`bg-white ${!a.activo ? 'opacity-60' : ''}`}>
                <TableCell className="font-mono text-xs">{a.codigo}</TableCell>
                <TableCell className="text-gray-900">{a.nombre}</TableCell>
                <TableCell>
                  {a.tipo === 'REACTIVO'
                    ? <Badge color="purple" className="w-fit">Reactivo</Badge>
                    : <Badge color="cyan" className="w-fit">Material</Badge>}
                </TableCell>
                <TableCell>{a.categoria}</TableCell>
                <TableCell>{a.unidad}</TableCell>
                <TableCell className="text-right tabular-nums">{a.stockMinimo}</TableCell>
                <TableCell><ActivoBadge activo={a.activo} /></TableCell>
                <TableCell>
                  <div className="flex gap-2 justify-end">
                    {hasPerm('entrada.registrar') && a.activo && (
                      <Button size="xs" onClick={() => setEntrada(a)}>Ingresar</Button>
                    )}
                    {hasPerm('articulos.editar') && (
                      <Button size="xs" color="light" onClick={() => setEditar(a.id)}>Editar</Button>
                    )}
                    {hasPerm('articulos.eliminar') && (
                      <Button size="xs" color="light" disabled={estado.isPending}
                        onClick={() => estado.mutate({ id: a.id, activo: !a.activo })}>
                        {a.activo ? 'Desactivar' : 'Activar'}
                      </Button>
                    )}
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}

      {editar !== null && (
        <ArticuloFormModal
          articuloId={editar}
          onClose={() => setEditar(null)}
          onSaved={() => { setEditar(null); refrescar() }}
        />
      )}

      {entrada && (
        <EntradaFormModal
          articulo={entrada}
          onClose={() => setEntrada(null)}
          onSaved={() => { setEntrada(null); refrescar() }}
        />
      )}
    </div>
  )
}
