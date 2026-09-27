import { createInitialGameState } from '../../game/domain/gameState'
import { getScenario, isTicketUnlocked, TICKET_CATALOG } from './tickets'

describe('Shoply Ticket catalog', () => {
  it('keeps Tickets catalog-driven and unlocks them in order', () => {
    const state = createInitialGameState(TICKET_CATALOG.map((ticket) => ticket.id))

    expect(getScenario('T02')?.mutations[0]?.target).toBe('cart.subtotal')
    expect(getScenario('T03')?.mutations[0]?.target).toBe(
      'orders.cancelAction.destination',
    )
    expect(getScenario('T04')?.mutations[0]?.target).toBe('cart.discountRate')
    expect(isTicketUnlocked('T01', state)).toBe(true)
    expect(isTicketUnlocked('T02', state)).toBe(false)
    expect(isTicketUnlocked('T03', state)).toBe(false)
    expect(isTicketUnlocked('T04', state)).toBe(false)

    state.tickets.T01 = { status: 'RESOLVED', reportIds: [], resolvedAt: 1 }
    expect(isTicketUnlocked('T02', state)).toBe(true)
    expect(isTicketUnlocked('T03', state)).toBe(false)

    state.tickets.T02 = { status: 'RESOLVED', reportIds: [], resolvedAt: 2 }
    expect(isTicketUnlocked('T03', state)).toBe(true)
    expect(isTicketUnlocked('T04', state)).toBe(false)

    state.tickets.T03 = { status: 'RESOLVED', reportIds: [], resolvedAt: 3 }
    expect(isTicketUnlocked('T04', state)).toBe(true)
  })
})
