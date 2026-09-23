import type { PropsWithChildren } from 'react'

import { GameSessionProvider } from '../../game/session/GameSessionProvider'
import { ShoplyProvider } from '../../products/shoply/ShoplyProvider'

export function AppProviders({ children }: PropsWithChildren) {
  return (
    <GameSessionProvider>
      <ShoplyProvider>{children}</ShoplyProvider>
    </GameSessionProvider>
  )
}
