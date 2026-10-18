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
  const scenario = state.currentTicketId ? getScenario(state.currentTicketId) : undefined
  const startingAccount = scenario?.ticket.startingContext.account

  return (
    <ShoplyProvider
      sessionKey={state.currentTicketId ?? 'standalone'}
      initialAccount={startingAccount === 'GOLD' ? 'GOLD' : 'BASIC'}
      seed={scenario?.seed.productState}
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
