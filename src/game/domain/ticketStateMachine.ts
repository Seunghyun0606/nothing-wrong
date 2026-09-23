import type { TicketStatus } from './schemas'

const ALLOWED_TRANSITIONS: Readonly<Record<TicketStatus, readonly TicketStatus[]>> = {
  NEW: ['ACCEPTED'],
  ACCEPTED: ['TESTING'],
  TESTING: ['REPORTED', 'NO_ISSUE'],
  REPORTED: ['REVIEWED'],
  NO_ISSUE: ['REVIEWED'],
  REVIEWED: ['RESOLVED'],
  RESOLVED: [],
}

export class InvalidTicketTransitionError extends Error {
  constructor(from: TicketStatus, to: TicketStatus) {
    super(`Invalid Ticket status transition: ${from} -> ${to}`)
    this.name = 'InvalidTicketTransitionError'
  }
}

export function canTransitionTicket(from: TicketStatus, to: TicketStatus): boolean {
  return ALLOWED_TRANSITIONS[from].includes(to)
}

export function transitionTicketStatus(
  current: TicketStatus,
  next: TicketStatus,
): TicketStatus {
  if (!canTransitionTicket(current, next)) {
    throw new InvalidTicketTransitionError(current, next)
  }

  return next
}
