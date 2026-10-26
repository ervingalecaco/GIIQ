import { etiquetaEspecial, especialesDe, NFPA_CUADRANTES, NFPA_ESPECIALES, type RomboNfpaValores } from '../nfpa'

/**
 * Rombo de seguridad NFPA 704 dibujado en SVG:
 * arriba rojo (inflamabilidad), izquierda azul (salud), derecha amarillo (reactividad),
 * abajo blanco (riesgo específico). Los cuadrantes sin valor se ven vacíos.
 */
export function RomboNfpa({ nfpaSalud, nfpaInflamabilidad, nfpaReactividad, nfpaEspecial, tamano = 96 }:
  RomboNfpaValores & { tamano?: number }) {
  const especiales = especialesDe(nfpaEspecial)
  const num = (v?: number | null) => (v == null ? '' : String(v))
  const textoEspecial = especiales.map(etiquetaEspecial).join(' ')
  const chico = especiales.length > 1 || textoEspecial.length > 3

  const titulo = [
    `Salud: ${num(nfpaSalud) || '—'}`,
    `Inflamabilidad: ${num(nfpaInflamabilidad) || '—'}`,
    `Reactividad: ${num(nfpaReactividad) || '—'}`,
    `Especial: ${especiales.map((c) => NFPA_ESPECIALES.find((e) => e.codigo === c)?.texto ?? c).join(', ') || 'ninguno'}`,
  ].join(' · ')

  return (
    <svg viewBox="0 0 100 100" width={tamano} height={tamano} role="img" aria-label={`Rombo NFPA. ${titulo}`}>
      <title>{titulo}</title>
      <polygon points="50,2 74,26 50,50 26,26" fill={NFPA_CUADRANTES.inflamabilidad.color} />
      <polygon points="26,26 50,50 26,74 2,50" fill={NFPA_CUADRANTES.salud.color} />
      <polygon points="74,26 98,50 74,74 50,50" fill={NFPA_CUADRANTES.reactividad.color} />
      <polygon points="50,50 74,74 50,98 26,74" fill="#ffffff" />
      {/* Bordes */}
      <polygon points="50,2 98,50 50,98 2,50" fill="none" stroke="#111827" strokeWidth="2.5" />
      <line x1="26" y1="26" x2="74" y2="74" stroke="#111827" strokeWidth="1.2" />
      <line x1="74" y1="26" x2="26" y2="74" stroke="#111827" strokeWidth="1.2" />
      <g fontFamily="Inter, Arial, sans-serif" fontWeight="800" textAnchor="middle" dominantBaseline="central" fill="#111827">
        <text x="50" y="27" fontSize="20">{num(nfpaInflamabilidad)}</text>
        <text x="26" y="51" fontSize="20">{num(nfpaSalud)}</text>
        <text x="74" y="51" fontSize="20">{num(nfpaReactividad)}</text>
        <text x="50" y="74" fontSize={chico ? 8 : 12}
          textDecoration={especiales.length === 1 && especiales[0] === 'W' ? 'line-through' : undefined}>
          {textoEspecial}
        </text>
      </g>
    </svg>
  )
}
