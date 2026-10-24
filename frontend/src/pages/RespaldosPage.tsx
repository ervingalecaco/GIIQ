import { useRef, useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  Button, Card, FileInput, Label, Modal, ModalBody, ModalHeader, Spinner,
  Table, TableBody, TableCell, TableHead, TableHeadCell, TableRow,
} from 'flowbite-react'
import { HiDatabase, HiDownload, HiExclamation } from 'react-icons/hi'
import { respaldosApi } from '../api/respaldos'
import { descargarArchivo } from '../api/reportes'
import { apiError } from '../api/client'
import { Cargando, ErrorAlert, PageHeader } from '../components/Feedback'
import { Paginador, usePaginacion } from '../components/Paginacion'

function tamano(bytes?: number | null): string {
  if (!bytes) return '—'
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / 1024 / 1024).toFixed(1)} MB`
}

export function RespaldosPage() {
  const qc = useQueryClient()
  const fileRef = useRef<HTMLInputElement>(null)
  const [archivo, setArchivo] = useState<File | null>(null)
  const [confirmar, setConfirmar] = useState(false)

  const { data, isLoading, error } = useQuery({ queryKey: ['respaldos'], queryFn: respaldosApi.list })
  const pag = usePaginacion(data)

  const crear = useMutation({
    mutationFn: respaldosApi.crear,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['respaldos'] }),
    onError: (e) => alert(apiError(e)),
  })

  const restaurar = useMutation({
    mutationFn: (f: File) => respaldosApi.restore(f),
    onSuccess: () => {
      alert('Base de datos restaurada correctamente.')
      setArchivo(null)
      if (fileRef.current) fileRef.current.value = ''
      qc.invalidateQueries()
    },
    onError: (e) => alert(apiError(e)),
  })

  function ejecutarRestaurar() {
    setConfirmar(false)
    if (archivo) restaurar.mutate(archivo)
  }

  return (
    <div className="space-y-6">
      <PageHeader title="Respaldos" />

      {/* Crear respaldo */}
      <Card>
        <div className="flex items-center justify-between gap-3 flex-wrap">
          <div className="flex items-center gap-3">
            <span className="inline-flex h-10 w-10 items-center justify-center rounded-lg bg-primary-100 text-primary-700">
              <HiDatabase className="h-5 w-5" />
            </span>
            <div>
              <h2 className="font-semibold text-gray-900">Crear respaldo</h2>
              <p className="text-sm text-gray-500">Genera una copia completa de la base (incluye procedimientos).</p>
            </div>
          </div>
          <Button onClick={() => crear.mutate()} disabled={crear.isPending}>
            {crear.isPending ? <><Spinner size="sm" light className="me-2" /> Generando…</> : 'Crear respaldo ahora'}
          </Button>
        </div>
      </Card>

      {/* Restaurar */}
      <Card className="border-red-200">
        <div className="flex items-center gap-3">
          <span className="inline-flex h-10 w-10 items-center justify-center rounded-lg bg-red-100 text-red-600">
            <HiExclamation className="h-5 w-5" />
          </span>
          <div>
            <h2 className="font-semibold text-red-700">Restaurar</h2>
            <p className="text-sm text-gray-500">
              Sube un archivo <code className="font-mono text-xs">.sql</code> para restaurar.
              Reemplaza <strong>todos</strong> los datos actuales.
            </p>
          </div>
        </div>
        <div className="flex items-end gap-3 flex-wrap">
          <div className="flex-1 min-w-60">
            <Label htmlFor="archivo" className="mb-2 block sr-only">Archivo .sql</Label>
            <FileInput id="archivo" ref={fileRef} accept=".sql"
              onChange={(e) => setArchivo(e.target.files?.[0] ?? null)} />
          </div>
          <Button color="red" onClick={() => setConfirmar(true)} disabled={!archivo || restaurar.isPending}>
            {restaurar.isPending ? <><Spinner size="sm" light className="me-2" /> Restaurando…</> : 'Restaurar'}
          </Button>
        </div>
      </Card>

      {/* Historial */}
      <div className="space-y-3">
        <h2 className="text-lg font-semibold text-gray-900">Historial de respaldos</h2>
        {isLoading && <Cargando />}
        {error && <ErrorAlert error={error} />}
        {data && (
          <Table hoverable>
            <TableHead>
              <TableRow>
                <TableHeadCell>Archivo</TableHeadCell>
                <TableHeadCell>Fecha</TableHeadCell>
                <TableHeadCell>Usuario</TableHeadCell>
                <TableHeadCell className="text-right">Tamaño</TableHeadCell>
                <TableHeadCell className="text-right">Acciones</TableHeadCell>
              </TableRow>
            </TableHead>
            <TableBody className="divide-y">
              {data.length === 0 && (
                <TableRow><TableCell colSpan={5} className="text-center text-gray-400">Aún no hay respaldos.</TableCell></TableRow>
              )}
              {pag.visibles?.map((r) => (
                <TableRow key={r.id} className="bg-white">
                  <TableCell className="font-mono text-xs text-gray-900">{r.archivo}</TableCell>
                  <TableCell>{new Date(r.fecha).toLocaleString()}</TableCell>
                  <TableCell>{r.usuario ?? '—'}</TableCell>
                  <TableCell className="text-right tabular-nums">{tamano(r.tamanoBytes)}</TableCell>
                  <TableCell>
                    <div className="flex justify-end">
                      <Button size="xs" color="light"
                        onClick={() => descargarArchivo(`/api/respaldos/${r.id}/download`, r.archivo)}>
                        <HiDownload className="me-1 h-3.5 w-3.5" /> Descargar
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
        {data && <Paginador p={pag} nombre="respaldos" />}
      </div>

      {/* Confirmación de restauración */}
      <Modal show={confirmar} size="md" onClose={() => setConfirmar(false)} popup>
        <ModalHeader />
        <ModalBody>
          <div className="text-center">
            <HiExclamation className="mx-auto mb-4 h-14 w-14 text-red-500" />
            <h3 className="mb-2 text-lg font-semibold text-gray-900">
              ¿Restaurar la base desde «{archivo?.name}»?
            </h3>
            <p className="mb-5 text-sm text-gray-500">
              Esto <strong>reemplaza todos los datos actuales</strong>. Esta acción no se puede deshacer.
            </p>
            <div className="flex justify-center gap-3">
              <Button color="red" onClick={ejecutarRestaurar}>Sí, restaurar</Button>
              <Button color="light" onClick={() => setConfirmar(false)}>Cancelar</Button>
            </div>
          </div>
        </ModalBody>
      </Modal>
    </div>
  )
}
