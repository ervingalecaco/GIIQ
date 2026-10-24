import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { createTheme, ThemeProvider } from 'flowbite-react'
import { AuthProvider } from './auth/AuthContext'
import { ThemeInit } from '../.flowbite-react/init'
import App from './App'
import './index.css'

const queryClient = new QueryClient({
  defaultOptions: { queries: { retry: 1, refetchOnWindowFocus: false } },
})

// Ajustes globales de Flowbite (se combinan con sus clases por defecto):
// tablas con scroll horizontal en pantallas angostas y encabezados técnicos en mono,
// tarjetas planas con borde fino y esquinas sobrias.
const theme = createTheme({
  table: {
    root: {
      base: 'text-gray-600',
      wrapper: 'relative overflow-x-auto rounded-lg border border-gray-200 bg-white',
    },
    head: {
      base: 'font-mono text-[11px] font-medium tracking-wider text-gray-500',
      cell: { base: 'bg-slate-50 px-4 py-2.5 border-b border-gray-200' },
    },
    body: { cell: { base: 'px-4 py-3' } },
    row: { hovered: 'hover:bg-primary-50/50' },
  },
  card: { root: { base: 'rounded-lg shadow-none' } },
  button: { base: 'rounded-md' },
  badge: { root: { base: 'rounded' } },
})

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ThemeInit />
    <ThemeProvider theme={theme}>
      <QueryClientProvider client={queryClient}>
        <BrowserRouter>
          <AuthProvider>
            <App />
          </AuthProvider>
        </BrowserRouter>
      </QueryClientProvider>
    </ThemeProvider>
  </StrictMode>,
)
