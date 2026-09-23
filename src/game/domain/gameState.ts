import {
  GameStateSchema,
  PlayerTicketStateSchema,
  type GameState,
  type PlayerTicketState,
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
