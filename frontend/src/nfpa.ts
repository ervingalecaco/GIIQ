/** Rombo de seguridad NFPA 704: escalas y códigos (textos según la norma). */

export type CuadranteNfpa = 'salud' | 'inflamabilidad' | 'reactividad'

export const NFPA_CUADRANTES: Record<CuadranteNfpa, {
  titulo: string
  color: string
  niveles: string[]  // índice = nivel 0..4
}> = {
  salud: {
    titulo: 'Salud',
    color: '#4a90e2', // azul (como el rombo de ejemplo: claro, con número negro)
    niveles: [
      'Sin riesgo: no representa un riesgo en diversas condiciones.',
      'Ligeramente peligroso: solo causa daños menores, sin tratamiento médico.',
      'Peligroso: puede causar incapacidad temporal o daños permanentes con manejo continuo.',
      'Extremadamente peligroso: daños temporales o permanentes aun con poca exposición.',
      'Mortal: puede causar la muerte o un daño permanente.',
    ],
  },
  inflamabilidad: {
    titulo: 'Inflamabilidad',
    color: '#e3262e', // rojo
    niveles: [
      'No arde.',
      'Arde a los 93 °C (sobre 93 °C).',
      'Entra en ignición debajo de los 93 °C.',
      'Entra en ignición debajo de los 37 °C.',
      'Entra en ignición debajo de los 25 °C.',
    ],
  },
  reactividad: {
    titulo: 'Reactividad',
    color: '#ffd400', // amarillo
    niveles: [
      'Estable: se mantiene estable aun bajo ciertas exposiciones.',
      'Inestable si se calienta.',
      'Posibilidad de cambio: puede reaccionar violentamente con temperatura y presión elevadas.',
      'Puede detonar con golpe o calentamiento.',
      'Detona con facilidad: se desestabiliza muy rápidamente.',
    ],
  },
}

/** Cuadrante blanco: riesgo específico (se guardan los códigos; XN se muestra "Xn"). */
export const NFPA_ESPECIALES: { codigo: string; texto: string; etiqueta: string }[] = [
  { codigo: 'R',    etiqueta: 'R',    texto: 'Material radiactivo' },
  { codigo: 'COR',  etiqueta: 'COR',  texto: 'Material corrosivo' },
  { codigo: 'BIO',  etiqueta: 'BIO',  texto: 'Riesgo biológico' },
  { codigo: 'CRYO', etiqueta: 'CRYO', texto: 'Material criogénico' },
  { codigo: 'XN',   etiqueta: 'Xn',   texto: 'Nocivo (riesgo epidemiológico)' },
  { codigo: 'ALC',  etiqueta: 'ALC',  texto: 'Material alcalino' },
  { codigo: 'W',    etiqueta: 'W',    texto: 'Reacciona con agua (no usar agua)' },
  { codigo: 'OX',   etiqueta: 'OX',   texto: 'Material oxidante' },
  { codigo: 'ACID', etiqueta: 'ACID', texto: 'Sustancia ácida' },
]

export const etiquetaEspecial = (codigo: string) =>
  NFPA_ESPECIALES.find((e) => e.codigo === codigo)?.etiqueta ?? codigo

/** "OX,COR" -> ['OX', 'COR'] */
export const especialesDe = (valor?: string | null) =>
  (valor ?? '').split(',').map((s) => s.trim()).filter(Boolean)

export interface RomboNfpaValores {
  nfpaSalud?: number | null
  nfpaInflamabilidad?: number | null
  nfpaReactividad?: number | null
  nfpaEspecial?: string | null
}

export const tieneRombo = (r: RomboNfpaValores) =>
  r.nfpaSalud != null && r.nfpaInflamabilidad != null && r.nfpaReactividad != null
