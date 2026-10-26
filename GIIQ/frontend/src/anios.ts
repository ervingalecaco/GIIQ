/** Años de la carrera en que se agrupan las clases. */
export const ANIOS = [
  { id: 1, nombre: 'Primer año' },
  { id: 2, nombre: 'Segundo año' },
  { id: 3, nombre: 'Tercer año' },
  { id: 4, nombre: 'Cuarto año' },
  { id: 5, nombre: 'Quinto año' },
]

export const anioTexto = (anio?: number | null) => ANIOS.find((a) => a.id === anio)?.nombre ?? ''
