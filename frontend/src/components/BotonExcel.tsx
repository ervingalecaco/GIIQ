import { useState } from 'react'
import { Button, Spinner } from 'flowbite-react'
import { HiDownload } from 'react-icons/hi'
import { apiError } from '../api/client'
import { descargarArchivo } from '../api/reportes'
import { useDialogos } from './Dialogos'

/** Descarga en Excel lo que genera `url` (endpoint autenticado); avisa si falla. */
export function BotonExcel({ url, archivo }: { url: string; archivo: string }) {
  const { avisar } = useDialogos()
  const [bajando, setBajando] = useState(false)
  async function descargar() {
    setBajando(true)
    try { await descargarArchivo(url, archivo) }
    catch (e) { avisar(`No se pudo exportar: ${apiError(e)}`, 'error') }
    finally { setBajando(false) }
  }
  return (
    <Button size="sm" color="green" onClick={descargar} disabled={bajando}>
      {bajando ? <Spinner size="sm" className="me-1.5" /> : <HiDownload className="me-1.5 h-4 w-4" />} Exportar a Excel
    </Button>
  )
}
