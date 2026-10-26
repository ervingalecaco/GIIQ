import type { TipoArticulo } from './types'

/** Textos y rutas de cada tipo de solicitud (reactivos / cristalería). */
export const TIPO_SOLICITUD: Record<TipoArticulo, {
  ruta: string
  titulo: string
  plural: string
  subtitulo: string
}> = {
  REACTIVO: {
    ruta: '/solicitudes/reactivos',
    titulo: 'Solicitudes de reactivos',
    plural: 'reactivos',
    subtitulo: 'Los reactivos se consumen: la solicitud se cierra al entregarse.',
  },
  CRISTALERIA: {
    ruta: '/solicitudes/cristaleria',
    titulo: 'Solicitudes de cristalería',
    plural: 'cristalería',
    subtitulo: 'La cristalería se presta: la solicitud se cierra cuando se devuelve.',
  },
}
