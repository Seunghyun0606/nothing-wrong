import { createInitialGameState } from '../../game/domain/gameState'
import { getScenario, isTicketUnlocked, TICKET_CATALOG } from './tickets'

describe('Shoply Ticket catalog', () => {
  it('keeps T02 catalog-driven and locked until T01 is resolved', () => {
    const state = createInitialGameState(TICKET_CATALOG.map((ticket) => ticket.id))

    expect(getScenario('T02')?.mutations[0]?.target).toBe('cart.subtotal')
    expect(isTicketUnlocked('T01', state)).toBe(true)
    expect(isTicketUnlocked('T02', state)).toBe(false)

    state.tickets.T01 = { status: 'RESOLVED', reportIds: [], resolvedAt: 1 }
    expect(isTicketUnlocked('T02', state)).toBe(true)
  })
})
