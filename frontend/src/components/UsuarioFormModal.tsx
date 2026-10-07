import { useEffect, useState, type FormEvent } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Button, Label, Select, Spinner, TextInput } from 'flowbite-react'
import { rolesApi, usuariosApi } from '../api/admin'
import { apiError } from '../api/client'
import { ErrorAlert } from './Feedback'
import { Modal } from './Modal'
import type { UsuarioAdmin } from '../types'

const label = 'mb-2 block'

export function UsuarioFormModal({ usuario, onClose, onSaved }: {
  usuario: UsuarioAdmin | 'nuevo'
  onClose: () => void
  onSaved: () => void
}) {
  const esNuevo = usuario === 'nuevo'
  const roles = useQuery({ queryKey: ['roles'], queryFn: rolesApi.roles })

  const [nombreCompleto, setNombre] = useState('')
  const [nombreUsuario, setUsuario] = useState('')
  const [password, setPassword] = useState('')
  const [email, setEmail] = useState('')
  const [rolId, setRolId] = useState<number | ''>('')
  const [error, setError] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (usuario !== 'nuevo') {
      setNombre(usuario.nombreCompleto)
      setUsuario(usuario.usuario)
      setEmail(usuario.email ?? '')
      setRolId(usuario.rolId)
    }
  }, [usuario])

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    if (!rolId) { setError('Selecciona un rol.'); return }
    setSaving(true)
    try {
      if (esNuevo) {
        await usuariosApi.crear({
          nombreCompleto, usuario: nombreUsuario, password,
          email: email || null, rolId: Number(rolId),
        })
      } else {
        await usuariosApi.editar(usuario.id, {
          nombreCompleto, email: email || null, rolId: Number(rolId),
        })
      }
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
        <div>
          <Label className={label} htmlFor="nom">Nombre completo</Label>
          <TextInput id="nom" value={nombreCompleto} onChange={(e) => setNombre(e.target.value)} required />
        </div>
        <div className="grid grid-cols-2 gap-3">
          <div>
            <Label className={label} htmlFor="usr">Usuario</Label>
            <TextInput id="usr" value={nombreUsuario} disabled={!esNuevo}
              onChange={(e) => setUsuario(e.target.value)} required autoComplete="off" />
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
          <Button type="submit" disabled={saving}>
            {saving ? <><Spinner size="sm" light className="me-2" /> Guardando…</> : 'Guardar'}
          </Button>
          <Button type="button" color="light" onClick={onClose}>Cancelar</Button>
        </div>
      </form>
    </Modal>
  )
}
