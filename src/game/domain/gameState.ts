import {
  GameStateSchema,
  PlayerTicketStateSchema,
  type GameState,
  type PlayerTicketState,
  type Scenario,
} from './schemas'

export const INITIAL_PROFILE = {
  name: 'J. PARK',
  level: 1,
  career: 'JUNIOR_QA',
  xp: 0,
  reputation: 100,
} as const

export function createInitialTicketState(): PlayerTicketState {
  return PlayerTicketStateSchema.parse({
    status: 'NEW',
    reportIds: [],
  })
}

export function createInitialGameState(ticketIds: readonly string[] = []): GameState {
  if (new Set(ticketIds).size !== ticketIds.length) {
    throw new Error('Ticket ids must be unique')
  }

  const tickets = Object.fromEntries(
    ticketIds.map((ticketId) => [ticketId, createInitialTicketState()]),
  )

  return GameStateSchema.parse({
    profile: INITIAL_PROFILE,
    tickets,
    unlockedTools: [],
    reportHistory: [],
    reviewHistory: [],
  })
}

export function reconcileGameStateTickets(
  state: GameState,
  ticketIds: readonly string[],
  scenarios: readonly Scenario[] = [],
): GameState {
  if (new Set(ticketIds).size !== ticketIds.length) {
    throw new Error('Ticket ids must be unique')
  }

  const missingTickets = ticketIds.filter((ticketId) => !state.tickets[ticketId])
  const earnedTools = scenarios.flatMap((scenario) =>
    state.tickets[scenario.ticket.id]?.status === 'RESOLVED'
      ? (scenario.progression?.unlockedTools ?? [])
      : [],
  )
  const unlockedTools = [...new Set([...state.unlockedTools, ...earnedTools])]
  if (missingTickets.length === 0 && unlockedTools.length === state.unlockedTools.length) {
    return state
  }

  return GameStateSchema.parse({
    ...state,
    tickets: {
      ...state.tickets,
      ...Object.fromEntries(
        missingTickets.map((ticketId) => [ticketId, createInitialTicketState()]),
      ),
    },
    unlockedTools,
  })
}
