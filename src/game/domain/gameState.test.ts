import { createInitialGameState, reconcileGameStateTickets } from './gameState'
import { T03_SCENARIO } from '../../scenarios/shoply/t03'

describe('createInitialGameState', () => {
  it('creates the canonical initial profile and NEW Ticket states', () => {
    const state = createInitialGameState(['T01', 'T02'])

    expect(state.profile).toEqual({
      name: 'J. PARK',
      level: 1,
      career: 'JUNIOR_QA',
      xp: 0,
      reputation: 100,
    })
    expect(state.tickets.T01?.status).toBe('NEW')
    expect(state.tickets.T02?.status).toBe('NEW')
    expect(state.unlockedTools).toEqual([])
  })

  it('rejects duplicate Ticket ids', () => {
    expect(() => createInitialGameState(['T01', 'T01'])).toThrow(
      'Ticket ids must be unique',
    )
  })

  it('adds newly shipped Tickets without replacing persisted progress', () => {
    const state = createInitialGameState(['T01'])
    state.tickets.T01 = {
      status: 'RESOLVED',
      reportIds: ['REPORT-T01'],
      resolvedAt: 10,
    }

    const reconciled = reconcileGameStateTickets(state, ['T01', 'T02'])

    expect(reconciled.tickets.T01).toEqual(state.tickets.T01)
    expect(reconciled.tickets.T02).toEqual({ status: 'NEW', reportIds: [] })
  })

  it('restores earned tools for a saved resolved Ticket without duplicating them', () => {
    const state = createInitialGameState(['T03'])
    state.tickets.T03 = { status: 'RESOLVED', reportIds: [], resolvedAt: 3 }

    const reconciled = reconcileGameStateTickets(state, ['T03', 'T04'], [T03_SCENARIO])

    expect(reconciled.tickets.T04).toEqual({ status: 'NEW', reportIds: [] })
    expect(reconciled.unlockedTools).toEqual(['ACCOUNT_SWITCHER'])
    expect(reconcileGameStateTickets(reconciled, ['T03', 'T04'], [T03_SCENARIO])).toBe(
      reconciled,
    )
  })
})
