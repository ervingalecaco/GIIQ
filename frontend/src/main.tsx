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

// Ajustes globales de Flowbite: las tablas hacen scroll horizontal en pantallas angostas.
const theme = createTheme({
  table: {
    root: { wrapper: 'relative overflow-x-auto rounded-lg border border-gray-200 bg-white' },
  },
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
