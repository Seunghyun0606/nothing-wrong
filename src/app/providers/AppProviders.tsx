import type { PropsWithChildren } from 'react'

import {
  GameSessionProvider,
  useGameSession,
} from '../../game/session/GameSessionProvider'
import { WorkspaceSessionProvider } from '../../game/session/WorkspaceSessionProvider'
import { ShoplyProvider } from '../../products/shoply/ShoplyProvider'
import { getScenario } from '../../scenarios/shoply/tickets'

function ShoplySessionProvider({ children }: PropsWithChildren) {
  const { state } = useGameSession()
  const startingAccount = state.currentTicketId
    ? getScenario(state.currentTicketId)?.ticket.startingContext.account
    : undefined

  return (
    <ShoplyProvider
      key={state.currentTicketId ?? 'standalone'}
      initialAccount={startingAccount === 'GOLD' ? 'GOLD' : 'BASIC'}
    >
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
