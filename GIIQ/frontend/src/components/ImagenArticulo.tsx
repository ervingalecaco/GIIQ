import { useEffect, useRef, useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Button } from 'flowbite-react'
import { HiPhotograph, HiTrash } from 'react-icons/hi'
import { TbTestPipe } from 'react-icons/tb'
import { articulosApi } from '../api/catalogos'
import { Modal } from './Modal'

/** Lado mayor de la foto guardada: suficiente para identificar el material sin pesar de más. */
const LADO_MAXIMO = 1000

/**
 * Reduce la foto en el navegador antes de subirla: lado mayor de 1000 px, JPEG al 85 %
 * (unos 100 KB). Las transparencias de un PNG quedan sobre fondo blanco.
 */
export function reducirImagen(archivo: File): Promise<Blob> {
  return new Promise((resolve, reject) => {
    const url = URL.createObjectURL(archivo)
    const img = new Image()
    img.onload = () => {
      URL.revokeObjectURL(url)
      const escala = Math.min(1, LADO_MAXIMO / Math.max(img.width, img.height))
      const canvas = document.createElement('canvas')
      canvas.width = Math.round(img.width * escala)
      canvas.height = Math.round(img.height * escala)
      const ctx = canvas.getContext('2d')
      if (!ctx) return reject(new Error('El navegador no pudo procesar la imagen.'))
      ctx.fillStyle = '#ffffff'
      ctx.fillRect(0, 0, canvas.width, canvas.height)
      ctx.drawImage(img, 0, 0, canvas.width, canvas.height)
      canvas.toBlob((b) => (b ? resolve(b) : reject(new Error('No se pudo comprimir la imagen.'))), 'image/jpeg', 0.85)
    }
    img.onerror = () => {
      URL.revokeObjectURL(url)
      reject(new Error('El archivo no es una imagen válida.'))
    }
    img.src = url
  })
}

/** URL local (object URL) de un Blob, que se libera al cambiar o desmontar. */
function useObjectUrl(blob?: Blob | null) {
  const [url, setUrl] = useState<string>()
  useEffect(() => {
    if (!blob) { setUrl(undefined); return }
    const u = URL.createObjectURL(blob)
    setUrl(u)
    return () => URL.revokeObjectURL(u)
  }, [blob])
  return url
}

/**
 * Foto de referencia de un artículo. Se pide con el token (la API exige sesión) y la fecha
 * de la foto va en la clave: al cambiarla se descarga la nueva y la anterior queda en desuso.
 */
export function useImagenArticulo(id?: number, version?: string | null) {
  const { data } = useQuery({
    queryKey: ['articulo-imagen', id, version],
    queryFn: () => articulosApi.imagen(id!, version!),
    enabled: !!id && !!version,
    staleTime: Infinity,
  })
  return useObjectUrl(data)
}

interface ConImagen { id: number; nombre: string; codigo?: string; imagenActualizada?: string | null }

/**
 * Miniatura cuadrada de la cristalería. Con foto, al tocarla se abre ampliada;
 * sin foto muestra un ícono gris (no es clicable).
 */
export function MiniaturaArticulo({ articulo, tamano = 'h-11 w-11' }: { articulo?: ConImagen; tamano?: string }) {
  const url = useImagenArticulo(articulo?.id, articulo?.imagenActualizada)
  const [ampliada, setAmpliada] = useState(false)
  const caja = `${tamano} shrink-0 overflow-hidden rounded-md border border-gray-200 bg-slate-50`

  if (!articulo?.imagenActualizada || !url) {
    return (
      <span className={`${caja} inline-flex items-center justify-center text-gray-300`}
        title={articulo?.imagenActualizada ? 'Cargando imagen…' : 'Sin imagen de referencia'}>
        <TbTestPipe className="h-1/2 w-1/2" aria-hidden />
      </span>
    )
  }
  return (
    <>
      <button type="button" onClick={() => setAmpliada(true)} aria-label={`Ver imagen de ${articulo.nombre}`}
        className={`${caja} cursor-zoom-in focus:outline-none focus:ring-2 focus:ring-primary-300`}>
        <img src={url} alt="" className="h-full w-full object-cover" />
      </button>
      {ampliada && (
        <Modal title={articulo.nombre} onClose={() => setAmpliada(false)} size="2xl">
          <figure className="space-y-3">
            <img src={url} alt={`Imagen de referencia: ${articulo.nombre}`}
              className="mx-auto max-h-[65vh] w-auto rounded-md border border-gray-200 bg-white object-contain" />
            {articulo.codigo && (
              <figcaption className="text-center font-mono text-xs text-gray-500">{articulo.codigo}</figcaption>
            )}
          </figure>
        </Modal>
      )}
    </>
  )
}

/**
 * Campo del formulario para la foto de referencia: muestra la actual o la recién elegida,
 * y permite cambiarla o quitarla. No sube nada: quien lo usa guarda al enviar el formulario.
 */
export function CampoImagen({ actual, nueva, quitar, onElegir, onQuitar }: {
  /** Foto guardada (id y versión); sin versión = no tiene. */
  actual?: { id: number; version?: string | null }
  nueva: Blob | null
  quitar: boolean
  onElegir: (b: Blob) => void
  onQuitar: () => void
}) {
  const input = useRef<HTMLInputElement>(null)
  const urlActual = useImagenArticulo(actual?.id, quitar ? null : actual?.version)
  const urlNueva = useObjectUrl(nueva)
  const url = urlNueva ?? urlActual
  const [error, setError] = useState<string | null>(null)
  const [procesando, setProcesando] = useState(false)

  async function elegir(f?: File) {
    if (!f) return
    setError(null)
    setProcesando(true)
    try { onElegir(await reducirImagen(f)) } catch (e) { setError((e as Error).message) } finally { setProcesando(false) }
  }

  return (
    <fieldset className="rounded-lg border border-gray-200 p-4">
      <legend className="rotulo px-1 text-gray-500">Imagen de referencia</legend>
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
        <div className="flex h-36 w-36 shrink-0 items-center justify-center overflow-hidden rounded-md border border-gray-200 bg-slate-50">
          {url
            ? <img src={url} alt="Vista previa de la imagen de referencia" className="h-full w-full object-contain" />
            : <TbTestPipe className="h-12 w-12 text-gray-300" aria-hidden />}
        </div>
        <div className="space-y-2">
          <p className="text-sm text-gray-600">
            Una foto clara del material sobre fondo neutro ayuda a reconocerlo al solicitarlo y al despacharlo.
          </p>
          <p className="text-xs text-gray-500">JPG, PNG o WebP. Se reduce automáticamente antes de guardarse.</p>
          <div className="flex flex-wrap gap-2">
            <input ref={input} type="file" accept="image/jpeg,image/png,image/webp" className="hidden"
              onChange={(e) => { elegir(e.target.files?.[0]); e.target.value = '' }} />
            <Button type="button" size="xs" color="light" disabled={procesando} onClick={() => input.current?.click()}>
              <HiPhotograph className="me-1.5 h-4 w-4" /> {url ? 'Cambiar imagen' : 'Elegir imagen'}
            </Button>
            {url && (
              <Button type="button" size="xs" color="light" onClick={onQuitar}>
                <HiTrash className="me-1.5 h-4 w-4" /> Quitar
              </Button>
            )}
          </div>
          {procesando && <p className="text-xs text-gray-500">Procesando imagen…</p>}
          {error && <p className="text-xs text-red-700">{error}</p>}
        </div>
      </div>
    </fieldset>
  )
}
