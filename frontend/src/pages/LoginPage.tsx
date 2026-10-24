import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button, Label, Spinner, TextInput } from 'flowbite-react'
import { HiOutlineEye, HiOutlineEyeOff, HiOutlineLockClosed, HiOutlineUser } from 'react-icons/hi'
import { useAuth } from '../auth/AuthContext'
import { apiError } from '../api/client'
import { ErrorAlert } from '../components/Feedback'
import { useLogo } from '../logo'

/** Logo grande del panel izquierdo; si aún no hay archivo en src/assets, uno provisional. */
function LogoGrande() {
  const logo = useLogo()
  if (logo) {
    return <img src={logo} alt="BioQ — Reactivos y Cristalería" className="w-full max-w-md object-contain" />
  }
  return (
    <div className="flex items-center gap-4">
      <span className="inline-flex h-20 w-20 items-center justify-center rounded-2xl brand-gradient
                       text-3xl font-bold text-white shadow-lg shadow-primary-600/30">Lq</span>
      <div>
        <div className="text-4xl font-extrabold tracking-tight brand-text-gradient">LabQuim</div>
        <div className="text-sm text-gray-500">Inventario de laboratorio de química</div>
      </div>
    </div>
  )
}

export function LoginPage() {
  const { login } = useAuth()
  const navigate = useNavigate()
  const [usuario, setUsuario] = useState('')
  const [password, setPassword] = useState('')
  const [verClave, setVerClave] = useState(false)
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
    <div className="min-h-screen grid grid-cols-1 lg:grid-cols-2">
      {/* Panel izquierdo: logo */}
      <div className="flex items-center justify-center bg-white px-8 py-10 lg:py-0">
        <LogoGrande />
      </div>

      {/* Panel derecho: formulario */}
      <div className="flex items-center justify-center bg-primary-50/60 px-4 pb-12 lg:py-0 lg:border-l lg:border-gray-100">
        <div className="w-full max-w-md rounded-2xl bg-white p-8 sm:p-10 shadow-xl shadow-gray-200/70">
          <h1 className="text-2xl font-bold text-gray-900">Iniciar sesión</h1>
          <p className="mt-1 text-gray-500">Entra con el usuario que te asignó el laboratorio.</p>

          <form onSubmit={onSubmit} className="mt-7 flex flex-col gap-5">
            <div>
              <Label htmlFor="usuario" className="mb-2 block text-base">Usuario</Label>
              <TextInput id="usuario" sizing="lg" icon={HiOutlineUser} value={usuario}
                onChange={(e) => setUsuario(e.target.value)} autoComplete="username" required />
            </div>
            <div>
              <Label htmlFor="password" className="mb-2 block text-base">Contraseña</Label>
              <div className="relative">
                <TextInput id="password" sizing="lg" type={verClave ? 'text' : 'password'}
                  icon={HiOutlineLockClosed} value={password} className="[&_input]:pe-12"
                  onChange={(e) => setPassword(e.target.value)} autoComplete="current-password" required />
                <button type="button" onClick={() => setVerClave((v) => !v)}
                  aria-label={verClave ? 'Ocultar contraseña' : 'Mostrar contraseña'}
                  className="absolute inset-y-0 right-0 flex items-center pe-4 text-gray-500 hover:text-gray-700">
                  {verClave ? <HiOutlineEyeOff className="h-5 w-5" /> : <HiOutlineEye className="h-5 w-5" />}
                </button>
              </div>
            </div>

            {error && <ErrorAlert>{error}</ErrorAlert>}

            <Button type="submit" size="lg" disabled={loading} className="mt-1 w-full">
              {loading ? <><Spinner size="sm" light className="me-2" /> Ingresando…</> : 'Ingresar'}
            </Button>
          </form>
        </div>
      </div>
    </div>
  )
}
