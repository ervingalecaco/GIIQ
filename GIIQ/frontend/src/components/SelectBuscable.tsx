import { useEffect, useId, useMemo, useRef, useState, type KeyboardEvent } from 'react'
import { Badge, Checkbox, Label, TextInput } from 'flowbite-react'
import { HiCheck, HiSearch, HiX } from 'react-icons/hi'

export const sinAcentos = (s: string) => s.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase()

/**
 * El texto contiene todas las palabras buscadas, en cualquier orden y sin importar
 * mayúsculas ni tildes ("condensador espiral" encuentra "Condensador en espiral").
 */
export function coincide(texto: string, busqueda: string) {
  const t = sinAcentos(texto)
  return sinAcentos(busqueda).split(/\s+/).filter(Boolean).every((p) => t.includes(p))
}

interface Opcion { id: number; nombre: string }

/**
 * Selección múltiple con búsqueda: casillas filtrables por texto (sin mayúsculas ni acentos).
 * Lo elegido se muestra arriba como etiquetas, aunque el filtro lo oculte de la lista.
 */
export function MultiSelectBuscable({ id, opciones, value, onChange, placeholder = 'Buscar…', vacio = 'Sin resultados.' }: {
  id: string
  opciones: Opcion[]
  value: number[]
  onChange: (ids: number[]) => void
  placeholder?: string
  vacio?: string
}) {
  const [texto, setTexto] = useState('')
  const filtradas = opciones.filter((o) => coincide(o.nombre, texto))
  const elegidas = opciones.filter((o) => value.includes(o.id))
  const alternar = (oid: number) =>
    onChange(value.includes(oid) ? value.filter((x) => x !== oid) : [...value, oid])

  return (
    <div className="rounded-lg border border-gray-200">
      <div className="space-y-2 border-b border-gray-200 p-3">
        <TextInput id={id} sizing="sm" icon={HiSearch} placeholder={placeholder} autoComplete="off"
          value={texto} onChange={(e) => setTexto(e.target.value)} />
        {elegidas.length > 0 && (
          <div className="flex flex-wrap gap-1.5">
            {elegidas.map((o) => (
              <Badge key={o.id} color="blue" className="cursor-pointer" title="Quitar"
                onClick={() => alternar(o.id)}>
                <span className="inline-flex items-center gap-1">{o.nombre} <HiX className="h-3 w-3" /></span>
              </Badge>
            ))}
          </div>
        )}
      </div>
      <div className="max-h-48 space-y-2 overflow-y-auto p-3">
        {filtradas.length === 0 && <p className="text-sm text-gray-400">{opciones.length ? vacio : 'No hay opciones disponibles.'}</p>}
        {filtradas.map((o) => (
          <div key={o.id} className="flex items-center gap-2">
            <Checkbox id={`${id}-${o.id}`} checked={value.includes(o.id)} onChange={() => alternar(o.id)} />
            <Label htmlFor={`${id}-${o.id}`} className="font-normal">{o.nombre}</Label>
          </div>
        ))}
      </div>
      <p className="border-t border-gray-200 px-3 py-1.5 text-xs text-gray-500">
        {value.length} seleccionado{value.length === 1 ? '' : 's'}
        {texto.trim() && ` · ${filtradas.length} de ${opciones.length} coinciden`}
      </p>
    </div>
  )
}

/**
 * Selector con búsqueda (combobox): se escribe para filtrar y se elige de la lista.
 * Ignora mayúsculas y acentos. Teclado: ↑/↓ para moverse, Enter para elegir, Esc para cerrar.
 */
export function SelectBuscable({ id, opciones, value, onChange, placeholder, vacio = 'Sin resultados.' }: {
  id?: string
  opciones: Opcion[]
  value: number | ''
  onChange: (id: number | '') => void
  placeholder?: string
  vacio?: string
}) {
  const listaId = useId()
  const contenedor = useRef<HTMLDivElement>(null)
  const elegida = opciones.find((o) => o.id === value)
  const [texto, setTexto] = useState(elegida?.nombre ?? '')
  const [abierto, setAbierto] = useState(false)
  const [activo, setActivo] = useState(0)

  // Si cambia la selección desde fuera (o llegan las opciones), refleja el nombre elegido.
  useEffect(() => { setTexto(elegida?.nombre ?? '') }, [elegida?.nombre])

  // Cerrar al hacer clic fuera, restaurando el texto de la opción elegida.
  useEffect(() => {
    function fuera(e: MouseEvent) {
      if (!contenedor.current?.contains(e.target as Node)) {
        setAbierto(false)
        setTexto(elegida?.nombre ?? '')
      }
    }
    document.addEventListener('mousedown', fuera)
    return () => document.removeEventListener('mousedown', fuera)
  }, [elegida?.nombre])

  // Si el texto es exactamente el elegido, se muestran todas (para poder cambiar de opción).
  const filtradas = useMemo(() => {
    if (texto === elegida?.nombre) return opciones
    return opciones.filter((o) => coincide(o.nombre, texto))
  }, [opciones, texto, elegida?.nombre])

  function elegir(o: Opcion) {
    onChange(o.id)
    setTexto(o.nombre)
    setAbierto(false)
  }

  function onKeyDown(e: KeyboardEvent<HTMLInputElement>) {
    if (e.key === 'ArrowDown') {
      e.preventDefault(); setAbierto(true); setActivo((i) => Math.min(i + 1, filtradas.length - 1))
    } else if (e.key === 'ArrowUp') {
      e.preventDefault(); setActivo((i) => Math.max(i - 1, 0))
    } else if (e.key === 'Enter' && abierto) {
      e.preventDefault(); if (filtradas[activo]) elegir(filtradas[activo])
    } else if (e.key === 'Escape') {
      setAbierto(false); setTexto(elegida?.nombre ?? '')
    }
  }

  return (
    <div ref={contenedor} className="relative">
      <TextInput
        id={id}
        icon={HiSearch}
        placeholder={placeholder}
        autoComplete="off"
        role="combobox"
        aria-expanded={abierto}
        aria-controls={listaId}
        value={texto}
        onFocus={() => setAbierto(true)}
        onChange={(e) => {
          setTexto(e.target.value); setAbierto(true); setActivo(0)
          if (value !== '') onChange('') // al escribir se descarta la selección anterior
        }}
        onKeyDown={onKeyDown}
      />
      {value !== '' && (
        <button type="button" aria-label="Quitar selección"
          className="absolute inset-y-0 right-0 flex items-center pe-3 text-gray-400 hover:text-gray-600"
          onClick={() => { onChange(''); setTexto(''); setAbierto(true) }}>
          <HiX className="h-4 w-4" />
        </button>
      )}

      {abierto && (
        <ul id={listaId} role="listbox"
          className="absolute z-20 mt-1 max-h-60 w-full overflow-y-auto rounded-lg border border-gray-200 bg-white py-1 text-sm shadow-lg">
          {filtradas.length === 0 && <li className="px-3 py-2 text-gray-400">{vacio}</li>}
          {filtradas.map((o, i) => (
            <li key={o.id} role="option" aria-selected={o.id === value}
              // onMouseDown: elegir antes de que el input pierda el foco
              onMouseDown={(e) => { e.preventDefault(); elegir(o) }}
              onMouseEnter={() => setActivo(i)}
              className={`flex cursor-pointer items-center justify-between px-3 py-2 ${
                i === activo ? 'bg-primary-50 text-primary-800' : 'text-gray-700'}`}>
              {o.nombre}
              {o.id === value && <HiCheck className="h-4 w-4 text-primary-600" />}
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
