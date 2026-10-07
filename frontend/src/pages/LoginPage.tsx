import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button, Card, Label, Spinner, TextInput } from 'flowbite-react'
import { HiLockClosed, HiUser } from 'react-icons/hi'
import { useAuth } from '../auth/AuthContext'
import { apiError } from '../api/client'
import { ErrorAlert } from '../components/Feedback'

export function LoginPage() {
  const { login } = useAuth()
  const navigate = useNavigate()
  const [usuario, setUsuario] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setLoading(true)
    try {
      await login(usuario, password)
      navigate('/', { replace: true })
    } catch (err) {
      setError(apiError(err, 'No se pudo iniciar sesión.'))
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="relative min-h-screen flex items-center justify-center px-4 overflow-hidden bg-gray-50">
      {/* Glow de fondo */}
      <div aria-hidden className="pointer-events-none absolute inset-0">
        <div className="absolute -top-40 left-1/2 -translate-x-1/2 h-96 w-[48rem] rounded-full
                        bg-gradient-to-tr from-indigo-300/40 via-indigo-200/30 to-sky-200/30 blur-3xl" />
      </div>

      <div className="relative w-full max-w-sm">
        <div className="text-center mb-7">
          <div className="inline-flex items-center justify-center h-12 w-12 rounded-xl brand-gradient
                          text-white font-bold text-lg shadow-lg shadow-indigo-500/30 mb-4">Lq</div>
          <h1 className="text-3xl font-extrabold tracking-tight brand-text-gradient">LabQuim</h1>
          <p className="text-sm text-gray-500 mt-1">Inventario de laboratorio de química</p>
        </div>

        <Card className="shadow-xl shadow-gray-200/60">
          <form onSubmit={onSubmit} className="flex flex-col gap-4">
            <div>
              <Label htmlFor="usuario" className="mb-2 block">Usuario</Label>
              <TextInput id="usuario" icon={HiUser} value={usuario}
                onChange={(e) => setUsuario(e.target.value)} autoComplete="username" required />
            </div>
            <div>
              <Label htmlFor="password" className="mb-2 block">Contraseña</Label>
              <TextInput id="password" type="password" icon={HiLockClosed} value={password}
                onChange={(e) => setPassword(e.target.value)} autoComplete="current-password" required />
            </div>
            {error && <ErrorAlert>{error}</ErrorAlert>}
            <Button type="submit" disabled={loading} className="brand-gradient">
              {loading ? <><Spinner size="sm" light className="me-2" /> Entrando…</> : 'Entrar'}
            </Button>
          </form>
        </Card>

        <p className="text-center text-xs text-gray-400 mt-6">
          Examen de grado · Sistema de control y gestión de inventario
        </p>
      </div>
    </div>
  )
}
