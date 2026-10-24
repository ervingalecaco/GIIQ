import { AgGridReact, type AgGridReactProps } from 'ag-grid-react'
import { AllCommunityModule, ModuleRegistry, themeQuartz } from 'ag-grid-community'
import { AG_GRID_LOCALE_ES } from '@ag-grid-community/locale'

ModuleRegistry.registerModules([AllCommunityModule])

/**
 * Tema de AG Grid con la línea de LabQuim: Plex Sans para el texto, encabezados en Plex Mono,
 * azul acero del logo como acento, bordes finos y sin sombras.
 */
const temaLabQuim = themeQuartz.withParams({
  accentColor: '#3474a2',
  foregroundColor: '#0f1b2a',
  backgroundColor: '#ffffff',
  borderColor: '#e5e7eb',
  wrapperBorderRadius: 8,
  borderRadius: 4,
  fontFamily: 'IBM Plex Sans, system-ui, sans-serif',
  fontSize: 14,
  headerFontFamily: 'IBM Plex Mono, ui-monospace, monospace',
  headerFontSize: 11,
  headerFontWeight: 500,
  headerTextColor: '#5a6878',
  headerBackgroundColor: '#f8fafc',
  rowHeight: 48,
  headerHeight: 40,
  rowHoverColor: 'rgba(52, 116, 162, 0.06)',
  cellHorizontalPadding: 16,
})

/**
 * Tabla de datos para reportes (AG Grid Community): orden y filtro por columna,
 * columnas redimensionables y paginación de 10/25/50 como el resto del sistema.
 */
export function TablaDatos<T>(props: AgGridReactProps<T>) {
  return (
    <div className="ag-labquim">
      <AgGridReact<T>
        theme={temaLabQuim}
        localeText={AG_GRID_LOCALE_ES}
        domLayout="autoHeight"
        pagination
        paginationPageSize={10}
        paginationPageSizeSelector={[10, 25, 50]}
        suppressCellFocus
        enableCellTextSelection
        {...props}
        defaultColDef={{ sortable: true, filter: true, resizable: true, minWidth: 90, ...props.defaultColDef }}
      />
    </div>
  )
}
