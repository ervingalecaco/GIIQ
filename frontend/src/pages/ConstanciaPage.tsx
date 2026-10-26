import { useNavigate, useParams } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { Button } from 'flowbite-react'
import { HiArrowLeft, HiPrinter } from 'react-icons/hi'
import { cuentasApi } from '../api/bajas'
import { Cargando, ErrorAlert } from '../components/Feedback'
import { INSTITUCION } from '../institucion'
import { useLogo } from '../logo'
import { SISTEMA } from '../sistema'

/**
 * Constancia de solvencia lista para imprimir (o guardar como PDF desde el navegador).
 * Va fuera del menú para que la hoja salga limpia; la barra de botones no se imprime.
 */
export function ConstanciaPage() {
  const { folio } = useParams()
  const logo = useLogo()
  const navigate = useNavigate()
  const { data, isLoading, error } = useQuery({
    queryKey: ['constancia', Number(folio)],
    queryFn: () => cuentasApi.constancia(Number(folio)),
  })
  const fechaLarga = data && new Date(data.fecha).toLocaleDateString('es', { day: 'numeric', month: 'long', year: 'numeric' })

  return (
    <div className="min-h-screen bg-gray-100 py-8 print:bg-white print:py-0">
      <div className="mx-auto mb-4 flex max-w-[210mm] items-center justify-between gap-3 px-4 print:hidden">
        <Button size="sm" color="light" onClick={() => navigate(-1)}>
          <HiArrowLeft className="me-1.5 h-4 w-4" /> Volver
        </Button>
        <Button size="sm" onClick={() => window.print()} disabled={!data}>
          <HiPrinter className="me-1.5 h-4 w-4" /> Imprimir o guardar PDF
        </Button>
      </div>

      {isLoading && <div className="mx-auto max-w-[210mm] px-4"><Cargando /></div>}
      {error && <div className="mx-auto max-w-[210mm] px-4"><ErrorAlert error={error} /></div>}

      {data && (
        <article className="mx-auto flex min-h-[297mm] max-w-[210mm] flex-col bg-white px-[22mm] py-[20mm] text-[#0f1b2a] shadow-sm
                            print:min-h-0 print:shadow-none">
          <header className="flex items-center gap-5 border-b-2 border-[#1b476d] pb-5">
            {logo && <img src={logo} alt="" className="h-16 w-auto object-contain" />}
            <div>
              <div className="text-lg font-semibold">{INSTITUCION.nombre}</div>
              <div className="text-sm text-gray-600">{INSTITUCION.dependencia}</div>
            </div>
            <div className="ms-auto text-right font-mono text-xs text-gray-600">
              <div>FOLIO</div>
              <div className="text-base font-semibold text-[#0f1b2a]">{String(data.folio).padStart(6, '0')}</div>
            </div>
          </header>

          <h1 className="mt-14 text-center text-xl font-semibold tracking-wide">CONSTANCIA DE SOLVENCIA</h1>
          <p className="mt-1 text-center text-sm text-gray-600">Cristalería de laboratorio</p>

          <div className="mt-12 space-y-5 text-[15px] leading-7 text-justify">
            <p>
              El {INSTITUCION.dependencia} de {INSTITUCION.nombre} hace constar que el (la) estudiante{' '}
              <strong>{data.estudiante}</strong>
              {data.codigo && <>, con código <strong className="font-mono">{data.codigo}</strong></>},{' '}
              <strong>no tiene cristalería pendiente de reponer</strong> en este laboratorio a la fecha de emisión
              de este documento.
            </p>
            <p>
              Se extiende la presente a solicitud del interesado para los trámites de culminación de estudios que estime
              convenientes, en {INSTITUCION.ciudad}, a los {fechaLarga}.
            </p>
          </div>

          <div className="mt-auto pt-28">
            <div className="mx-auto w-72 border-t border-[#0f1b2a] pt-2 text-center text-sm">
              <div className="font-medium">{data.emitidaPor}</div>
              <div className="text-gray-600">{INSTITUCION.cargoFirma}</div>
            </div>
          </div>

          <footer className="mt-14 border-t border-gray-200 pt-3 font-mono text-[10px] leading-4 text-gray-500">
            Emitida por el sistema {SISTEMA.nombre} ({SISTEMA.nombreCompleto}) · folio {data.folio} ·{' '}
            {new Date(data.fecha).toLocaleString('es', { dateStyle: 'short', timeStyle: 'short' })}.
            Válida únicamente con firma y sello del laboratorio.
          </footer>
        </article>
      )}
    </div>
  )
}
