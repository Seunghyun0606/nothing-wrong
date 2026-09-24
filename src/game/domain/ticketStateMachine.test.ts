import {
  InvalidTicketTransitionError,
  canTransitionTicket,
  transitionTicketStatus,
} from './ticketStateMachine'

describe('Ticket state machine', () => {
  it.each([
    ['NEW', 'ACCEPTED'],
    ['ACCEPTED', 'TESTING'],
    ['TESTING', 'REPORTED'],
    ['TESTING', 'NO_ISSUE'],
    ['REPORTED', 'REVIEWED'],
    ['NO_ISSUE', 'REVIEWED'],
    ['REVIEWED', 'TESTING'],
    ['REVIEWED', 'RESOLVED'],
  ] as const)('accepts %s -> %s', (from, to) => {
    expect(canTransitionTicket(from, to)).toBe(true)
  })

  it('returns the requested status for a valid transition', () => {
    expect(transitionTicketStatus('NEW', 'ACCEPTED')).toBe('ACCEPTED')
  })

  it('rejects invalid and terminal transitions', () => {
    expect(canTransitionTicket('TESTING', 'RESOLVED')).toBe(false)
    expect(() => transitionTicketStatus('NEW', 'RESOLVED')).toThrow(
      InvalidTicketTransitionError,
    )
    expect(() => transitionTicketStatus('RESOLVED', 'TESTING')).toThrow(
      'RESOLVED -> TESTING',
    )
  })
})
