import type { CapacitorConfig } from '@capacitor/cli'

// App Android de BioQ: empaqueta el build web (dist/) con Capacitor.
// La URL de la API sale de .env.movil (build con `npm run build:movil`).
const config: CapacitorConfig = {
  appId: 'com.bioq.inventario',
  appName: 'BioQ',
  webDir: 'dist',
  server: {
    // La app se sirve como http://localhost dentro del celular, así puede llamar
    // a la API por http en la red local (con https lo bloquearía como "contenido mixto").
    androidScheme: 'http',
    cleartext: true,
  },
}

export default config
