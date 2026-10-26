import { useEffect, useState } from 'react'

// Logo del sistema: un archivo `logo.*` en src/assets (tiene prioridad) o el logo de GIIQ
// en assets-app (el mismo del que salen los íconos de la app Android).
// Si no hay ninguno, `logoUrl` queda undefined y se muestra la marca de texto.
const propios = import.meta.glob('./assets/logo.{svg,png,jpg,jpeg,webp}', {
  eager: true,
  import: 'default',
}) as Record<string, string>
const giiq = import.meta.glob('../assets-app/GIIQ_logo_transparente.png', {
  eager: true,
  import: 'default',
}) as Record<string, string>

export const logoUrl: string | undefined = Object.values(propios)[0] ?? Object.values(giiq)[0]

// Versión para el menú marino: el mismo logo con las letras en blanco.
const menu = import.meta.glob('../assets-app/GIIQ_logo_letras_blancas.png', {
  eager: true,
  import: 'default',
}) as Record<string, string>
const logoMenuUrl: string | undefined = Object.values(menu)[0]

let recortado: Promise<string> | null = null

/**
 * Quita el margen blanco/transparente que rodea al dibujo (el archivo trae mucho
 * espacio alrededor). Se hace una sola vez en el navegador, así funciona con
 * cualquier logo que se copie en src/assets sin editar el archivo.
 */
function recortarMargen(url: string, soloTransparencia = false): Promise<string> {
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
          // Un logo con letras blancas se recorta solo por transparencia (si no, se cortarían las letras).
          const visible = data[i + 3] > 20 && (soloTransparencia || Math.min(data[i], data[i + 1], data[i + 2]) < 235)
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

let claro: Promise<string> | null = null
let deMenu: Promise<string> | null = null

/**
 * Versión de una tinta blanca del logo, para fondos oscuros (menú marino).
 * Cada píxel queda blanco con una opacidad según qué tan oscuro era: las letras y lo
 * azul marino salen plenos, los tonos medios semitransparentes y los claros apenas se insinúan.
 * Un filtro CSS de blanco puro no sirve: rellenaría el círculo y escondería el matraz.
 */
function versionClara(url: string): Promise<string> {
  return new Promise((resolve) => {
    const img = new Image()
    img.onload = () => {
      const canvas = document.createElement('canvas')
      canvas.width = img.width; canvas.height = img.height
      const ctx = canvas.getContext('2d')
      if (!ctx) return resolve(url)
      ctx.drawImage(img, 0, 0)
      const datos = ctx.getImageData(0, 0, img.width, img.height)
      const d = datos.data
      for (let i = 0; i < d.length; i += 4) {
        const luz = (0.2126 * d[i] + 0.7152 * d[i + 1] + 0.0722 * d[i + 2]) / 255
        const tinta = Math.min(1, Math.max(0, (1 - luz) * 1.25))
        d[i + 3] = Math.round(d[i + 3] * tinta)
        d[i] = d[i + 1] = d[i + 2] = 255
      }
      ctx.putImageData(datos, 0, 0)
      resolve(canvas.toDataURL('image/png'))
    }
    img.onerror = () => resolve(url)
    img.src = url
  })
}

/**
 * Logo para el menú marino: el de letras blancas recortado o, si no está, la versión blanca
 * de una tinta del logo normal. `undefined` = no hay logo (va la marca de texto);
 * `null` = hay logo pero aún se procesa (se reserva el espacio).
 */
export function useLogoMenu(): string | null | undefined {
  const [url, setUrl] = useState<string | null | undefined>(logoMenuUrl || logoUrl ? null : undefined)
  useEffect(() => {
    let promesa: Promise<string>
    if (logoMenuUrl) {
      promesa = deMenu ??= recortarMargen(logoMenuUrl, true)
    } else if (logoUrl) {
      recortado ??= recortarMargen(logoUrl)
      promesa = claro ??= recortado.then(versionClara)
    } else return
    let vigente = true
    promesa.then((u) => { if (vigente) setUrl(u) })
    return () => { vigente = false }
  }, [])
  return url
}

let emblema: Promise<string> | null = null

/**
 * Emblema del logo (círculo y matraz, sin las letras) para el menú contraído. Se recorta la
 * parte izquierda del logo de letras blancas, donde no llegan las letras (~45 % del ancho),
 * y se centra en un lienzo cuadrado transparente.
 */
function recortarEmblema(url: string, fraccion = 0.45): Promise<string> {
  return new Promise((resolve) => {
    const img = new Image()
    img.onload = () => {
      const w = Math.round(img.width * fraccion), h = img.height
      const lado = Math.max(w, h)
      const canvas = document.createElement('canvas')
      canvas.width = lado; canvas.height = lado
      const ctx = canvas.getContext('2d')
      if (!ctx) return resolve(url)
      ctx.drawImage(img, 0, 0, w, h, (lado - w) / 2, (lado - h) / 2, w, h)
      resolve(canvas.toDataURL('image/png'))
    }
    img.onerror = () => resolve(url)
    img.src = url
  })
}

/** Emblema para el menú contraído; `undefined` si no hay logo de letras blancas (va el ícono del matraz). */
export function useEmblemaMenu(): string | undefined {
  const [url, setUrl] = useState<string | undefined>(undefined)
  useEffect(() => {
    if (!logoMenuUrl) return
    deMenu ??= recortarMargen(logoMenuUrl, true)
    emblema ??= deMenu.then((u) => recortarEmblema(u))
    let vigente = true
    emblema.then((u) => { if (vigente) setUrl(u) })
    return () => { vigente = false }
  }, [])
  return url
}
