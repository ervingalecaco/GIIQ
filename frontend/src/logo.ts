import { useEffect, useState } from 'react'

// Logo de la institución: cualquier archivo `logo.*` dentro de src/assets.
// Si todavía no se ha copiado, `logoUrl` queda undefined y se muestra el logo provisional.
const encontrados = import.meta.glob('./assets/logo.{svg,png,jpg,jpeg,webp}', {
  eager: true,
  import: 'default',
}) as Record<string, string>

export const logoUrl: string | undefined = Object.values(encontrados)[0]

let recortado: Promise<string> | null = null

/**
 * Quita el margen blanco/transparente que rodea al dibujo (el archivo trae mucho
 * espacio alrededor). Se hace una sola vez en el navegador, así funciona con
 * cualquier logo que se copie en src/assets sin editar el archivo.
 */
function recortarMargen(url: string): Promise<string> {
  return new Promise((resolve) => {
    const img = new Image()
    img.onload = () => {
      const escala = Math.min(1, 1200 / Math.max(img.width, img.height))
      const w = Math.round(img.width * escala), h = Math.round(img.height * escala)
      const canvas = document.createElement('canvas')
      canvas.width = w; canvas.height = h
      const ctx = canvas.getContext('2d')
      if (!ctx) return resolve(url)
      ctx.drawImage(img, 0, 0, w, h)
      const { data } = ctx.getImageData(0, 0, w, h)

      let minX = w, minY = h, maxX = -1, maxY = -1
      for (let y = 0; y < h; y++) {
        for (let x = 0; x < w; x++) {
          const i = (y * w + x) * 4
          const visible = data[i + 3] > 20 && Math.min(data[i], data[i + 1], data[i + 2]) < 235
          if (visible) {
            if (x < minX) minX = x
            if (x > maxX) maxX = x
            if (y < minY) minY = y
            if (y > maxY) maxY = y
          }
        }
      }
      if (maxX < 0) return resolve(url) // imagen vacía: se deja tal cual

      const pad = Math.round(Math.max(maxX - minX, maxY - minY) * 0.03)
      const x0 = Math.max(0, minX - pad), y0 = Math.max(0, minY - pad)
      const cw = Math.min(w, maxX + pad + 1) - x0, ch = Math.min(h, maxY + pad + 1) - y0
      const salida = document.createElement('canvas')
      salida.width = cw; salida.height = ch
      salida.getContext('2d')!.drawImage(canvas, x0, y0, cw, ch, 0, 0, cw, ch)
      resolve(salida.toDataURL('image/png'))
    }
    img.onerror = () => resolve(url)
    img.src = url
  })
}

/** URL del logo ya recortado (mientras se procesa, devuelve el original). */
export function useLogo(): string | undefined {
  const [url, setUrl] = useState<string | undefined>(logoUrl)
  useEffect(() => {
    if (!logoUrl) return
    recortado ??= recortarMargen(logoUrl)
    let vigente = true
    recortado.then((u) => { if (vigente) setUrl(u) })
    return () => { vigente = false }
  }, [])
  return url
}
