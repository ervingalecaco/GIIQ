import type { ReactNode } from 'react'
import { Alert, Badge, Spinner } from 'flowbite-react'
import { HiInformationCircle } from 'react-icons/hi'
import { apiError } from '../api/client'

export function Cargando() {
  return (
    <div className="flex items-center gap-3 text-sm text-gray-500">
      <Spinner size="sm" /> Cargando…
    </div>
  )
}

/** Muestra un error de API (o un texto) como Alert de Flowbite. */
export function ErrorAlert({ error, children }: { error?: unknown; children?: ReactNode }) {
  return (
    <Alert color="failure" icon={HiInformationCircle}>
      {children ?? apiError(error)}
    </Alert>
  )
}

export function ActivoBadge({ activo }: { activo: boolean }) {
  return activo
    ? <Badge color="success" className="w-fit">Activo</Badge>
    : <Badge color="gray" className="w-fit">Inactivo</Badge>
}

/** Encabezado de página: título + acciones a la derecha. */
export function PageHeader({ title, subtitle, children }: { title: string; subtitle?: string; children?: ReactNode }) {
  return (
    <div className="flex items-center justify-between gap-3 flex-wrap">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">{title}</h1>
        {subtitle && <p className="text-sm text-gray-500 mt-1">{subtitle}</p>}
      </div>
      {children && <div className="flex items-center gap-3 flex-wrap">{children}</div>}
    </div>
  )
}
