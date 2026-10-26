import { Select, TextInput } from 'flowbite-react'
import { HiCalendar } from 'react-icons/hi'

export type Atajo = 'hoy' | '7d' | '30d' | 'mes' | 'mesAnterior' | 'anio' | 'todo' | 'personalizado'

export interface Periodo {
  atajo: Atajo
  /** Solo se usan con el atajo "personalizado" (formato yyyy-mm-dd). */
  desde: string
  hasta: string
}

const ATAJOS: { valor: Atajo; texto: string }[] = [
  { valor: 'hoy', texto: 'Hoy' },
  { valor: '7d', texto: 'Últimos 7 días' },
  { valor: '30d', texto: 'Últimos 30 días' },
  { valor: 'mes', texto: 'Este mes' },
  { valor: 'mesAnterior', texto: 'Mes anterior' },
  { valor: 'anio', texto: 'Este año' },
  { valor: 'todo', texto: 'Todo' },
  { valor: 'personalizado', texto: 'Personalizado…' },
]

export const PERIODO_INICIAL: Periodo = { atajo: '30d', desde: '', hasta: '' }

/** Fecha local en formato yyyy-mm-dd (sin pasar por UTC, que cambiaría el día por la noche). */
const iso = (d: Date) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`

/** Rango de fechas (yyyy-mm-dd) que representa el período; undefined = sin límite. */
export function rangoDe(p: Periodo): { desde?: string; hasta?: string } {
  const hoy = new Date()
  const y = hoy.getFullYear(), m = hoy.getMonth()
  const haceDias = (n: number) => { const d = new Date(hoy); d.setDate(d.getDate() - n); return iso(d) }
  switch (p.atajo) {
    case 'hoy': return { desde: iso(hoy), hasta: iso(hoy) }
    case '7d': return { desde: haceDias(6), hasta: iso(hoy) }
    case '30d': return { desde: haceDias(29), hasta: iso(hoy) }
    case 'mes': return { desde: iso(new Date(y, m, 1)), hasta: iso(hoy) }
    case 'mesAnterior': return { desde: iso(new Date(y, m - 1, 1)), hasta: iso(new Date(y, m, 0)) }
    case 'anio': return { desde: iso(new Date(y, 0, 1)), hasta: iso(hoy) }
    case 'todo': return {}
    case 'personalizado': return { desde: p.desde || undefined, hasta: p.hasta || undefined }
  }
}

const fechaCorta = (s: string) => {
  const [y, m, d] = s.split('-')
  return `${d}/${m}/${y}`
}

/** Texto legible del rango, ej. "del 16/09/2026 al 15/10/2026". */
export function describirPeriodo(p: Periodo): string {
  const { desde, hasta } = rangoDe(p)
  if (!desde && !hasta) return 'todas las fechas'
  if (desde && hasta) return desde === hasta ? `del ${fechaCorta(desde)}` : `del ${fechaCorta(desde)} al ${fechaCorta(hasta)}`
  return desde ? `desde el ${fechaCorta(desde)}` : `hasta el ${fechaCorta(hasta!)}`
}

/** Selector de período: atajos comunes y, en "Personalizado…", campos Desde / Hasta. */
export function FiltroPeriodo({ valor, onChange }: { valor: Periodo; onChange: (p: Periodo) => void }) {
  function elegirAtajo(atajo: Atajo) {
    // Al pasar a "Personalizado" se parte del rango que se estaba viendo.
    if (atajo === 'personalizado') {
      const r = rangoDe(valor)
      onChange({ atajo, desde: r.desde ?? '', hasta: r.hasta ?? '' })
    } else {
      onChange({ ...valor, atajo })
    }
  }

  return (
    <div className="flex items-center gap-2 flex-wrap">
      <Select sizing="sm" icon={HiCalendar} aria-label="Período" value={valor.atajo} className="min-w-48"
        onChange={(e) => elegirAtajo(e.target.value as Atajo)}>
        {ATAJOS.map((a) => <option key={a.valor} value={a.valor}>{a.texto}</option>)}
      </Select>
      {valor.atajo === 'personalizado' && (
        <>
          <TextInput sizing="sm" type="date" aria-label="Desde" value={valor.desde} max={valor.hasta || undefined}
            onChange={(e) => onChange({ ...valor, desde: e.target.value })} />
          <span className="text-sm text-gray-500">a</span>
          <TextInput sizing="sm" type="date" aria-label="Hasta" value={valor.hasta} min={valor.desde || undefined}
            onChange={(e) => onChange({ ...valor, hasta: e.target.value })} />
        </>
      )}
    </div>
  )
}
