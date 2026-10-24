/**
 * Tarjeta compacta con contador que funciona como filtro: tocarla filtra la lista,
 * y la activa se resalta. La lógica de activar/quitar la decide quien la usa.
 */
export function TarjetaFiltro({ texto, numero, color, activa, onClick }: {
  texto: string; numero: number; color: string; activa: boolean; onClick: () => void
}) {
  return (
    <button type="button" onClick={onClick} aria-pressed={activa}
      className={`flex h-9 items-center gap-2 whitespace-nowrap rounded-md border px-3 transition-colors focus:outline-none focus:ring-2 focus:ring-primary-300 ${
        activa ? 'border-primary-700 bg-primary-700' : 'border-gray-300 bg-white hover:bg-gray-50'}`}>
      <span className={`text-[13px] font-medium ${activa ? 'text-white' : 'text-gray-700'}`}>{texto}</span>
      <span className={`font-mono text-xs font-semibold tabular-nums ${activa ? 'text-primary-100' : color}`}>{numero}</span>
    </button>
  )
}
