import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useState,
  type PropsWithChildren,
} from 'react'

import { createInitialGameState } from '../domain/gameState'
import { transitionTicketStatus } from '../domain/ticketStateMachine'
import type { GameState } from '../domain/schemas'
import { loadGameState, saveGameState } from '../../persistence/gameStateStorage'
import { TICKET_CATALOG } from '../../scenarios/shoply/tickets'

interface GameSessionValue {
  state: GameState
  startTicket: (ticketId: string) => void
}

const GameSessionContext = createContext<GameSessionValue | null>(null)

function loadOrCreateGameState(): GameState {
  return (
    loadGameState() ?? createInitialGameState(TICKET_CATALOG.map((ticket) => ticket.id))
  )
}

export function GameSessionProvider({ children }: PropsWithChildren) {
  const [state, setState] = useState(loadOrCreateGameState)

  useEffect(() => {
    saveGameState(state)
  }, [state])

  const value = useMemo<GameSessionValue>(
    () => ({
      state,
      startTicket(ticketId) {
        setState((current) => {
          const ticketState = current.tickets[ticketId]
          if (!ticketState) {
            throw new Error(`Unknown Ticket: ${ticketId}`)
          }

          if (ticketState.status === 'TESTING') {
            return { ...current, currentTicketId: ticketId }
          }

          const acceptedStatus = transitionTicketStatus(ticketState.status, 'ACCEPTED')
          const testingStatus = transitionTicketStatus(acceptedStatus, 'TESTING')

          return {
            ...current,
            currentTicketId: ticketId,
            tickets: {
              ...current.tickets,
              [ticketId]: {
                ...ticketState,
                status: testingStatus,
                acceptedAt: ticketState.acceptedAt ?? Date.now(),
              },
            },
          }
        })
      },
    }),
    [state],
  )

  return <GameSessionContext.Provider value={value}>{children}</GameSessionContext.Provider>
}

export function useGameSession(): GameSessionValue {
  const value = useContext(GameSessionContext)
  if (!value) {
    throw new Error('useGameSession must be used inside GameSessionProvider')
  }
  return value
}
