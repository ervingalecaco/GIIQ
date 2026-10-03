import { useEffect, useState, type FormEvent } from 'react'
import { useQuery } from '@tanstack/react-query'
import { rolesApi, usuariosApi } from '../api/admin'
import { apiError } from '../api/client'
import { Modal } from './Modal'
import type { UsuarioAdmin } from '../types'

const input = 'w-full rounded-md border border-slate-300 px-3 py-2 text-sm'
const label = 'block text-sm font-medium text-slate-700 mb-1'

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
          <label className={label} htmlFor="nom">Nombre completo</label>
          <input id="nom" className={input} value={nombreCompleto} onChange={(e) => setNombre(e.target.value)} required />
        </div>
        <div className="grid grid-cols-2 gap-3">
          <div>
            <label className={label} htmlFor="usr">Usuario</label>
            <input id="usr" className={input} value={nombreUsuario} disabled={!esNuevo}
              onChange={(e) => setUsuario(e.target.value)} required autoComplete="off" />
          </div>
          <div>
            <label className={label} htmlFor="rol">Rol</label>
            <select id="rol" className={input} value={rolId}
              onChange={(e) => setRolId(e.target.value ? Number(e.target.value) : '')}>
              <option value="">…</option>
              {roles.data?.map((r) => <option key={r.id} value={r.id}>{r.nombre}</option>)}
            </select>
          </div>
        </div>
        {esNuevo && (
          <div>
            <label className={label} htmlFor="pwd">Contraseña</label>
            <input id="pwd" type="password" className={input} value={password}
              onChange={(e) => setPassword(e.target.value)} required minLength={6} autoComplete="new-password" />
          </div>
        )}
        <div>
          <label className={label} htmlFor="mail">Email</label>
          <input id="mail" type="email" className={input} value={email} onChange={(e) => setEmail(e.target.value)} />
        </div>

        {error && <p className="text-sm text-rose-600">{error}</p>}

        <div className="flex gap-3 pt-1">
          <button type="submit" disabled={saving}
            className="rounded-md bg-teal-700 text-white px-5 py-2 text-sm font-medium hover:bg-teal-800 disabled:opacity-50">
            {saving ? 'Guardando…' : 'Guardar'}
          </button>
          <button type="button" onClick={onClose}
            className="rounded-md border border-slate-300 px-5 py-2 text-sm hover:bg-slate-100">Cancelar</button>
        </div>
      </form>
    </Modal>
  )
}
