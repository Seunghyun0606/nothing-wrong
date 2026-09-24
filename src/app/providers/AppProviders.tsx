import type { PropsWithChildren } from 'react'

import { GameSessionProvider } from '../../game/session/GameSessionProvider'
import { WorkspaceSessionProvider } from '../../game/session/WorkspaceSessionProvider'
import { ShoplyProvider } from '../../products/shoply/ShoplyProvider'

export function AppProviders({ children }: PropsWithChildren) {
  return (
    <GameSessionProvider>
      <WorkspaceSessionProvider>
        <ShoplyProvider>{children}</ShoplyProvider>
      </WorkspaceSessionProvider>
    </GameSessionProvider>
  )
}
