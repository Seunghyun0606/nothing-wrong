import type { Scenario, Ticket } from '../../game/domain/schemas'
import { T01_SCENARIO } from './t01'

export const SCENARIO_CATALOG: readonly Scenario[] = [T01_SCENARIO]
export const TICKET_CATALOG: readonly Ticket[] = SCENARIO_CATALOG.map(
  (scenario) => scenario.ticket,
)

export function getScenario(ticketId: string): Scenario | undefined {
  return SCENARIO_CATALOG.find((scenario) => scenario.ticket.id === ticketId)
}

export function getTicket(ticketId: string): Ticket | undefined {
  return getScenario(ticketId)?.ticket
}
