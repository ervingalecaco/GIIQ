import { createContext, useCallback, useContext, useRef, useState, type FormEvent, type ReactNode } from 'react'
import { Button, Label, Modal, ModalBody, ModalHeader, Textarea, TextInput } from 'flowbite-react'
import { HiCheckCircle, HiExclamationCircle, HiInformationCircle, HiX } from 'react-icons/hi'

/**
 * Diálogos propios de la app, en lugar de los cuadros nativos del navegador
 * (prompt / alert), que no se ven como parte del sistema:
 *   - pedirTexto: ventana para pedir un dato (motivo de rechazo, contraseña) con validación.
 *   - avisar: aviso breve de éxito, error o información en la esquina superior derecha.
 */

interface PedirTextoOpciones {
  titulo: string
  etiqueta: string
  /** Explicación sobre el campo (p. ej. quién verá el motivo). */
  descripcion?: ReactNode
  placeholder?: string
  /** Texto del botón de confirmar. */
  confirmar?: string
  /** Botón rojo, para acciones como rechazar. */
  peligro?: boolean
  multilinea?: boolean
  tipo?: 'text' | 'password'
  minimo?: number
  maximo?: number
}

type TipoAviso = 'exito' | 'error' | 'info'
interface Aviso { id: number; tipo: TipoAviso; mensaje: string }

interface DialogosApi {
  /** Resuelve con el texto escrito, o null si se canceló. */
  pedirTexto: (o: PedirTextoOpciones) => Promise<string | null>
  avisar: (mensaje: string, tipo?: TipoAviso) => void
}

const DialogosContext = createContext<DialogosApi | null>(null)

export function useDialogos() {
  const ctx = useContext(DialogosContext)
  if (!ctx) throw new Error('useDialogos debe usarse dentro de <DialogosProvider>')
  return ctx
}

const DURACION: Record<TipoAviso, number> = { exito: 4000, info: 5000, error: 8000 }

export function DialogosProvider({ children }: { children: ReactNode }) {
  const [pedido, setPedido] = useState<PedirTextoOpciones | null>(null)
  const resolver = useRef<((v: string | null) => void) | null>(null)
  const [avisos, setAvisos] = useState<Aviso[]>([])
  const siguiente = useRef(1)

  const pedirTexto = useCallback((o: PedirTextoOpciones) => new Promise<string | null>((resolve) => {
    resolver.current = resolve
    setPedido(o)
  }), [])

  const cerrarPedido = (valor: string | null) => {
    resolver.current?.(valor)
    resolver.current = null
    setPedido(null)
  }

  const quitar = (id: number) => setAvisos((a) => a.filter((x) => x.id !== id))
  const avisar = useCallback((mensaje: string, tipo: TipoAviso = 'info') => {
    const id = siguiente.current++
    setAvisos((a) => [...a, { id, tipo, mensaje }])
    setTimeout(() => quitar(id), DURACION[tipo])
  }, [])

  return (
    <DialogosContext.Provider value={{ pedirTexto, avisar }}>
      {children}
      {pedido && <PedirTexto opciones={pedido} onCerrar={cerrarPedido} />}
      <div aria-live="polite" className="pointer-events-none fixed right-4 top-4 z-[100] flex w-[22rem] max-w-[calc(100vw-2rem)] flex-col gap-2">
        {avisos.map((a) => <AvisoTarjeta key={a.id} aviso={a} onCerrar={() => quitar(a.id)} />)}
      </div>
    </DialogosContext.Provider>
  )
}

function PedirTexto({ opciones: o, onCerrar }: { opciones: PedirTextoOpciones; onCerrar: (v: string | null) => void }) {
  const [valor, setValor] = useState('')
  const [error, setError] = useState<string | null>(null)
  const minimo = o.minimo ?? 1
  const texto = o.tipo === 'password' ? valor : valor.trim()

  function enviar(e: FormEvent) {
    e.preventDefault()
    if (texto.length < minimo) {
      setError(minimo > 1 ? `Escribe al menos ${minimo} caracteres.` : 'Este campo es obligatorio.')
      return
    }
    onCerrar(texto)
  }

  return (
    <Modal show onClose={() => onCerrar(null)} size="md" dismissible>
      <ModalHeader>{o.titulo}</ModalHeader>
      <ModalBody>
        <form onSubmit={enviar} className="space-y-4">
          {o.descripcion && <p className="text-sm text-gray-600">{o.descripcion}</p>}
          <div>
            <Label htmlFor="dialogo-texto" className="mb-1.5 block">{o.etiqueta}</Label>
            {o.multilinea
              ? <Textarea id="dialogo-texto" rows={4} autoFocus value={valor} maxLength={o.maximo} placeholder={o.placeholder}
                  color={error ? 'failure' : undefined}
                  onChange={(e) => { setValor(e.target.value); setError(null) }} />
              : <TextInput id="dialogo-texto" type={o.tipo ?? 'text'} autoFocus value={valor} maxLength={o.maximo}
                  placeholder={o.placeholder} color={error ? 'failure' : undefined}
                  autoComplete={o.tipo === 'password' ? 'new-password' : 'off'}
                  onChange={(e) => { setValor(e.target.value); setError(null) }} />}
            <div className="mt-1 flex justify-between gap-3 text-xs">
              <span className="text-red-700">{error}</span>
              {o.maximo && <span className="font-mono text-gray-400">{valor.length}/{o.maximo}</span>}
            </div>
          </div>
          <div className="flex justify-end gap-2 border-t border-gray-200 pt-4">
            <Button type="button" color="light" onClick={() => onCerrar(null)}>Cancelar</Button>
            <Button type="submit" color={o.peligro ? 'red' : 'default'}>{o.confirmar ?? 'Aceptar'}</Button>
          </div>
        </form>
      </ModalBody>
    </Modal>
  )
}

const ESTILO_AVISO: Record<TipoAviso, { caja: string; icono: ReactNode }> = {
  exito: { caja: 'border-emerald-200', icono: <HiCheckCircle className="h-5 w-5 shrink-0 text-emerald-700" aria-hidden /> },
  error: { caja: 'border-red-200', icono: <HiExclamationCircle className="h-5 w-5 shrink-0 text-red-700" aria-hidden /> },
  info: { caja: 'border-primary-200', icono: <HiInformationCircle className="h-5 w-5 shrink-0 text-primary-700" aria-hidden /> },
}

function AvisoTarjeta({ aviso, onCerrar }: { aviso: Aviso; onCerrar: () => void }) {
  const e = ESTILO_AVISO[aviso.tipo]
  return (
    <div role={aviso.tipo === 'error' ? 'alert' : 'status'}
      className={`pointer-events-auto flex items-start gap-3 rounded-lg border bg-white px-4 py-3 shadow-lg ${e.caja}`}>
      {e.icono}
      <p className="min-w-0 flex-1 text-sm text-gray-800">{aviso.mensaje}</p>
      <button type="button" onClick={onCerrar} aria-label="Cerrar aviso"
        className="-m-1 rounded p-1 text-gray-400 hover:bg-gray-100 hover:text-gray-700">
        <HiX className="h-4 w-4" />
      </button>
    </div>
  )
}
