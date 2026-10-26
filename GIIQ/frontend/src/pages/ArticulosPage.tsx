import { ArticulosPanel } from '../components/ArticulosPanel'
import { PageHeader } from '../components/Feedback'
import type { TipoArticulo } from '../types'

const TEXTOS: Record<TipoArticulo, { title: string; subtitle: string }> = {
  REACTIVO: {
    title: 'Reactivos',
    subtitle: 'Reactivos químicos del laboratorio. Se consumen al despacharse (FEFO).',
  },
  CRISTALERIA: {
    title: 'Cristalería',
    subtitle: 'Material de vidrio y equipo. Se presta en las solicitudes y se devuelve.',
  },
}

/** Sección de artículos de un solo tipo (una entrada propia en el menú). */
export function ArticulosPage({ tipo }: { tipo: TipoArticulo }) {
  return (
    <div className="space-y-5">
      <PageHeader {...TEXTOS[tipo]} />
      {/* key: al pasar de Reactivos a Cristalería se reinicia el estado (búsqueda, modales) */}
      <ArticulosPanel key={tipo} tipo={tipo} />
    </div>
  )
}
