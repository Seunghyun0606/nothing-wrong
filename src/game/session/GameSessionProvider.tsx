import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useState,
  type PropsWithChildren,
} from 'react'

import { createInitialGameState, reconcileGameStateTickets } from '../domain/gameState'
import { applyReview } from '../progression/applyReview'
import { transitionTicketStatus } from '../domain/ticketStateMachine'
import type {
  BugReport,
  GameState,
  ProgressionReward,
  ReviewResult,
} from '../domain/schemas'
import { loadGameState, saveGameState } from '../../persistence/gameStateStorage'
import { isTicketUnlocked, TICKET_CATALOG } from '../../scenarios/shoply/tickets'

interface GameSessionValue {
  state: GameState
  startTicket: (ticketId: string) => void
  completeReview: (
    report: BugReport,
    review: ReviewResult,
    reward?: ProgressionReward,
  ) => void
}

const GameSessionContext = createContext<GameSessionValue | null>(null)

function loadOrCreateGameState(): GameState {
  const ticketIds = TICKET_CATALOG.map((ticket) => ticket.id)
  const savedState = loadGameState()
  return savedState
    ? reconcileGameStateTickets(savedState, ticketIds)
    : createInitialGameState(ticketIds)
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
          if (!isTicketUnlocked(ticketId, current)) {
            throw new Error(`Ticket is locked: ${ticketId}`)
          }

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
      completeReview(report, review, reward) {
        setState((current) => applyReview(current, report, review, reward))
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
