import { AppErrorBoundary } from './AppErrorBoundary'
import { AppProviders } from './providers/AppProviders'
import { AppRouter } from './router/AppRouter'

export function App() {
  return (
    <AppErrorBoundary>
      <AppProviders>
        <AppRouter />
      </AppProviders>
    </AppErrorBoundary>
  )
}
