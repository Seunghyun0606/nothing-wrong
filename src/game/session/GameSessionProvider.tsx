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
import { answerDeduction } from '../story/answerDeduction'
import { transitionTicketStatus } from '../domain/ticketStateMachine'
import type {
  BugReport,
  Deduction,
  GameState,
  ProgressionReward,
  ReviewResult,
} from '../domain/schemas'
import { loadGameStateWithRecovery, saveGameState } from '../../persistence/gameStateStorage'
import { isTicketUnlocked, SCENARIO_CATALOG, TICKET_CATALOG } from '../../scenarios/shoply/tickets'

interface GameSessionValue {
  state: GameState
  /** True when an unreadable save was set aside and a fresh game started. */
  recoveredFromUnreadableSave: boolean
  startTicket: (ticketId: string) => void
  completeReview: (
    report: BugReport,
    review: ReviewResult,
    reward?: ProgressionReward,
  ) => void
  answerDeduction: (deduction: Deduction, optionId: string) => void
  markMessagesDelivered: (count: number) => void
  markMessagesRead: (count: number) => void
  resetProgress: () => void
}

const GameSessionContext = createContext<GameSessionValue | null>(null)

function createFreshGameState(): GameState {
  return createInitialGameState(TICKET_CATALOG.map((ticket) => ticket.id))
}

function loadOrCreateGameState(): { state: GameState; recovered: boolean } {
  const ticketIds = TICKET_CATALOG.map((ticket) => ticket.id)
  const { state, recovered } = loadGameStateWithRecovery()
  return {
    state: state
      ? reconcileGameStateTickets(state, ticketIds, SCENARIO_CATALOG)
      : createFreshGameState(),
    recovered,
  }
}

export function GameSessionProvider({ children }: PropsWithChildren) {
  const [initial] = useState(loadOrCreateGameState)
  const [state, setState] = useState(initial.state)

  useEffect(() => {
    saveGameState(state)
  }, [state])

  const value = useMemo<GameSessionValue>(
    () => ({
      state,
      recoveredFromUnreadableSave: initial.recovered,
      startTicket(ticketId) {
        if (!isTicketUnlocked(ticketId, state)) {
          throw new Error(`Ticket is locked: ${ticketId}`)
        }
        if (!state.tickets[ticketId]) {
          throw new Error(`Unknown Ticket: ${ticketId}`)
        }

        setState((current) => {
          const ticketState = current.tickets[ticketId]
          if (!ticketState) return current

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
      answerDeduction(deduction, optionId) {
        setState((current) => answerDeduction(current, deduction, optionId))
      },
      markMessagesDelivered(count) {
        setState((current) =>
          count <= current.story.deliveredCount
            ? current
            : { ...current, story: { ...current.story, deliveredCount: count } },
        )
      },
      markMessagesRead(count) {
        setState((current) =>
          count <= current.story.readCount
            ? current
            : { ...current, story: { ...current.story, readCount: count } },
        )
      },
      resetProgress() {
        setState(createFreshGameState())
      },
    }),
    [initial.recovered, state],
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
