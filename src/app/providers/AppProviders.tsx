import type { PropsWithChildren } from 'react'

import {
  GameSessionProvider,
  useGameSession,
} from '../../game/session/GameSessionProvider'
import { WorkspaceSessionProvider } from '../../game/session/WorkspaceSessionProvider'
import { ShoplyProvider } from '../../products/shoply/ShoplyProvider'

function ShoplySessionProvider({ children }: PropsWithChildren) {
  const { state } = useGameSession()

  return (
    <ShoplyProvider key={state.currentTicketId ?? 'standalone'}>
      {children}
    </ShoplyProvider>
  )
}

export function AppProviders({ children }: PropsWithChildren) {
  return (
    <GameSessionProvider>
      <WorkspaceSessionProvider>
        <ShoplySessionProvider>{children}</ShoplySessionProvider>
      </WorkspaceSessionProvider>
    </GameSessionProvider>
  )
}
