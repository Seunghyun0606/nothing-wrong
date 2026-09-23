import { createInitialGameState } from './gameState'

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
})
