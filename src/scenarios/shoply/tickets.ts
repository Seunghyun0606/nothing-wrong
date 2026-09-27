import type { GameState, Scenario, Ticket } from '../../game/domain/schemas'
import { T01_SCENARIO } from './t01'
import { T02_SCENARIO } from './t02'
import { T03_SCENARIO } from './t03'

export const SCENARIO_CATALOG: readonly Scenario[] = [
  T01_SCENARIO,
  T02_SCENARIO,
  T03_SCENARIO,
]
export const TICKET_CATALOG: readonly Ticket[] = SCENARIO_CATALOG.map(
  (scenario) => scenario.ticket,
)

export function getScenario(ticketId: string): Scenario | undefined {
  return SCENARIO_CATALOG.find((scenario) => scenario.ticket.id === ticketId)
}

export function getTicket(ticketId: string): Ticket | undefined {
  return getScenario(ticketId)?.ticket
}

export function isTicketUnlocked(ticketId: string, state: GameState): boolean {
  const ticketIndex = TICKET_CATALOG.findIndex((ticket) => ticket.id === ticketId)
  if (ticketIndex < 0) return false

  return TICKET_CATALOG.slice(0, ticketIndex).every(
    (ticket) => state.tickets[ticket.id]?.status === 'RESOLVED',
  )
}
