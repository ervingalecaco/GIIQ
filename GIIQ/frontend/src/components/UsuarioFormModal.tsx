import { useEffect, useState, type FormEvent, type ReactNode } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Button, HelperText, Label, Select, Spinner, TextInput } from 'flowbite-react'
import { rolesApi, usuariosApi } from '../api/admin'
import { apiError } from '../api/client'
import { ErrorAlert } from './Feedback'
import { Modal } from './Modal'
import type { UsuarioAdmin } from '../types'

const label = 'mb-2 block'

// Mismas reglas que el backend y los procedimientos almacenados.
/** Solo letras (con tildes y Ñ), espacio, apóstrofo y guion: sin emojis, números ni símbolos. */
const RE_NOMBRE = /^[A-ZÁÉÍÓÚÜÑ]+([ '-]+[A-ZÁÉÍÓÚÜÑ]+)*$/
const RE_USUARIO = /^[A-Za-z0-9._-]{3,50}$/
const RE_CODIGO = /^[A-Z0-9]+(-[A-Z0-9]+)*$/

/** Roles que llevan código propio, con la etiqueta del campo. */
const CODIGO_POR_ROL: Record<string, string> = {
  Profesor: 'Código de profesor',
  Estudiante: 'Código de estudiante',
}

function errorNombre(valor: string, campo: string): string | null {
  const v = valor.trim()
  if (!v) return null // "obligatorio" lo marca el navegador (required)
  return RE_NOMBRE.test(v) ? null : `${campo}: solo letras, espacios, apóstrofo o guion (sin emojis, números ni símbolos).`
}

type Estado = 'idle' | 'verificando' | 'libre' | 'ocupado'

/** Consulta al backend si un usuario/código está libre, 500 ms después de dejar de escribir. */
function useDisponible(campo: 'usuario' | 'codigo', valor: string, activo: boolean, excluirId?: number): Estado {
  const [estado, setEstado] = useState<Estado>('idle')
  useEffect(() => {
    if (!activo || !valor) { setEstado('idle'); return }
    setEstado('verificando')
    let vigente = true
    const t = setTimeout(async () => {
      try {
        const r = await usuariosApi.disponibilidad({ [campo]: valor, excluirId })
        if (vigente) setEstado((campo === 'usuario' ? r.usuarioDisponible : r.codigoDisponible) ? 'libre' : 'ocupado')
      } catch {
        if (vigente) setEstado('idle') // si falla la consulta, lo valida el servidor al guardar
      }
    }, 500)
    return () => { vigente = false; clearTimeout(t) }
  }, [campo, valor, activo, excluirId])
  return estado
}

/** Texto de ayuda bajo un campo: error de formato o resultado de la verificación. */
function Ayuda({ error, estado, ocupado }: { error: string | null; estado: Estado; ocupado: string }): ReactNode {
  if (error) return <HelperText color="failure">{error}</HelperText>
  if (estado === 'verificando') return <HelperText>Verificando…</HelperText>
  if (estado === 'ocupado') return <HelperText color="failure">{ocupado}</HelperText>
  if (estado === 'libre') return <HelperText color="success">Disponible.</HelperText>
  return null
}

export function UsuarioFormModal({ usuario, rolInicial, onClose, onSaved }: {
  usuario: UsuarioAdmin | 'nuevo'
  /** Nombre del rol a preseleccionar al crear (ej. la pestaña de rol activa). */
  rolInicial?: string
  onClose: () => void
  onSaved: () => void
}) {
  const esNuevo = usuario === 'nuevo'
  const roles = useQuery({ queryKey: ['roles'], queryFn: rolesApi.roles })

  const [nombres, setNombres] = useState('')
  const [apellidos, setApellidos] = useState('')
  const [codigo, setCodigo] = useState('')
  const [nombreUsuario, setUsuario] = useState('')
  const [password, setPassword] = useState('')
  const [email, setEmail] = useState('')
  const [rolId, setRolId] = useState<number | ''>('')
  const [error, setError] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (usuario !== 'nuevo') {
      setNombres(usuario.nombres)
      setApellidos(usuario.apellidos)
      setCodigo(usuario.codigo ?? '')
      setUsuario(usuario.usuario)
      setEmail(usuario.email ?? '')
      setRolId(usuario.rolId)
    }
  }, [usuario])

  // Usuario nuevo: preselecciona el rol indicado cuando llega la lista de roles.
  useEffect(() => {
    if (usuario === 'nuevo' && rolInicial && roles.data) {
      const rol = roles.data.find((r) => r.nombre === rolInicial)
      if (rol) setRolId((actual) => actual || rol.id)
    }
  }, [usuario, rolInicial, roles.data])

  const rolNombre = roles.data?.find((r) => r.id === rolId)?.nombre ?? ''
  const etiquetaCodigo = CODIGO_POR_ROL[rolNombre]
  const usaCodigo = !!etiquetaCodigo
  const excluirId = esNuevo ? undefined : usuario.id

  // Validaciones de formato (en vivo).
  const errNombres = errorNombre(nombres, 'Nombres')
  const errApellidos = errorNombre(apellidos, 'Apellidos')
  const errUsuario = esNuevo && nombreUsuario && !RE_USUARIO.test(nombreUsuario)
    ? 'De 3 a 50 letras, números, punto, guion o guion bajo (sin espacios ni emojis).' : null
  const cod = codigo.trim()
  const errCodigo = usaCodigo && cod && (cod.length < 3 || cod.length > 20 || !RE_CODIGO.test(cod))
    ? 'De 3 a 20 letras o números; puede llevar guion (ej. EST-2026-001).' : null

  // Verificación de que no existan ya.
  const estUsuario = useDisponible('usuario', nombreUsuario, esNuevo && !errUsuario, excluirId)
  const estCodigo = useDisponible('codigo', cod, usaCodigo && !errCodigo, excluirId)

  const hayErrores = !!(errNombres || errApellidos || errUsuario || errCodigo)
    || estUsuario === 'ocupado' || estCodigo === 'ocupado'

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    if (!rolId) { setError('Selecciona un rol.'); return }
    if (usaCodigo && !cod) { setError(`El ${etiquetaCodigo.toLowerCase()} es obligatorio.`); return }
    if (hayErrores) { setError('Corrige los campos marcados en rojo.'); return }
    setSaving(true)
    try {
      const datos = {
        nombres: nombres.trim(), apellidos: apellidos.trim(),
        codigo: usaCodigo ? cod : null, email: email || null, rolId: Number(rolId),
      }
      if (esNuevo) await usuariosApi.crear({ ...datos, usuario: nombreUsuario, password })
      else await usuariosApi.editar(usuario.id, datos)
      onSaved()
    } catch (err) {
      setError(apiError(err, 'No se pudo guardar el usuario.'))
    } finally {
      setSaving(false)
    }
  }

  return (
    <Modal title={esNuevo ? 'Nuevo usuario' : 'Editar usuario'} onClose={onClose}>
      <form onSubmit={onSubmit} className="space-y-4">
        <div className="grid grid-cols-2 gap-3">
          <div>
            <Label className={label} htmlFor="nom">Nombres</Label>
            <TextInput id="nom" value={nombres} required maxLength={60} autoComplete="off"
              placeholder="EJ. MARÍA JOSÉ" color={errNombres ? 'failure' : undefined}
              onChange={(e) => setNombres(e.target.value.toUpperCase())} />
            {errNombres && <HelperText color="failure">{errNombres}</HelperText>}
          </div>
          <div>
            <Label className={label} htmlFor="ape">Apellidos</Label>
            <TextInput id="ape" value={apellidos} required maxLength={60} autoComplete="off"
              placeholder="EJ. LÓPEZ SOLÍS" color={errApellidos ? 'failure' : undefined}
              onChange={(e) => setApellidos(e.target.value.toUpperCase())} />
            {errApellidos && <HelperText color="failure">{errApellidos}</HelperText>}
          </div>
        </div>

        <div className="grid grid-cols-2 gap-3">
          <div>
            <Label className={label} htmlFor="usr">Usuario</Label>
            <TextInput id="usr" value={nombreUsuario} disabled={!esNuevo} required maxLength={50} autoComplete="off"
              color={errUsuario || estUsuario === 'ocupado' ? 'failure' : estUsuario === 'libre' ? 'success' : undefined}
              onChange={(e) => setUsuario(e.target.value.trim())} />
            {esNuevo && <Ayuda error={errUsuario} estado={estUsuario} ocupado="Ya existe un usuario con ese nombre." />}
          </div>
          <div>
            <Label className={label} htmlFor="rol">Rol</Label>
            <Select id="rol" value={rolId}
              onChange={(e) => setRolId(e.target.value ? Number(e.target.value) : '')}>
              <option value="">…</option>
              {roles.data?.map((r) => <option key={r.id} value={r.id}>{r.nombre}</option>)}
            </Select>
          </div>
        </div>

        {usaCodigo && (
          <div>
            <Label className={label} htmlFor="cod">{etiquetaCodigo}</Label>
            <TextInput id="cod" value={codigo} required maxLength={20} autoComplete="off"
              placeholder={rolNombre === 'Estudiante' ? 'EJ. EST-2026-001' : 'EJ. PROF-001'}
              color={errCodigo || estCodigo === 'ocupado' ? 'failure' : estCodigo === 'libre' ? 'success' : undefined}
              onChange={(e) => setCodigo(e.target.value.toUpperCase())} />
            <Ayuda error={errCodigo} estado={estCodigo} ocupado="Ese código ya está asignado a otro usuario." />
          </div>
        )}

        {esNuevo && (
          <div>
            <Label className={label} htmlFor="pwd">Contraseña</Label>
            <TextInput id="pwd" type="password" value={password}
              onChange={(e) => setPassword(e.target.value)} required minLength={6} autoComplete="new-password" />
          </div>
        )}
        <div>
          <Label className={label} htmlFor="mail">Email</Label>
          <TextInput id="mail" type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
        </div>

        {error && <ErrorAlert>{error}</ErrorAlert>}

        <div className="flex gap-3 pt-1">
          <Button type="submit" disabled={saving || hayErrores}>
            {saving ? <><Spinner size="sm" light className="me-2" /> Guardando…</> : 'Guardar'}
          </Button>
          <Button type="button" color="light" onClick={onClose}>Cancelar</Button>
        </div>
      </form>
    </Modal>
  )
}
