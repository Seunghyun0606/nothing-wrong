import { GameStateSchema, type BugReport, type GameState, type ProgressionReward, type ReviewResult } from '../domain/schemas'
import { transitionTicketStatus } from '../domain/ticketStateMachine'

export function applyReview(
  state: GameState,
  report: BugReport,
  review: ReviewResult,
  reward: ProgressionReward | undefined,
  reviewedAt: number = Date.now(),
): GameState {
  const ticketState = state.tickets[report.ticketId]
  if (!ticketState) {
    throw new Error(`Unknown Ticket: ${report.ticketId}`)
  }

  if (ticketState.reportIds.includes(report.id)) {
    return state
  }

  if (ticketState.status !== 'TESTING') {
    throw new Error(`Ticket ${report.ticketId} is not ready for Report submission`)
  }

  const reportedStatus = transitionTicketStatus(ticketState.status, 'REPORTED')
  const reviewedStatus = transitionTicketStatus(reportedStatus, 'REVIEWED')
  const finalStatus = review.valid
    ? transitionTicketStatus(reviewedStatus, 'RESOLVED')
    : transitionTicketStatus(reviewedStatus, 'TESTING')
  const nextXp = state.profile.xp + review.xp
  const unlockedTools = [
    ...new Set([...state.unlockedTools, ...(reward?.unlockedTools ?? [])]),
  ]

  return GameStateSchema.parse({
    ...state,
    profile: {
      ...state.profile,
      xp: nextXp,
      level: Math.floor(nextXp / 100) + 1,
      reputation: state.profile.reputation + review.reputationDelta,
    },
    tickets: {
      ...state.tickets,
      [report.ticketId]: {
        ...ticketState,
        status: finalStatus,
        reportIds: [...ticketState.reportIds, report.id],
        reviewedAt,
        ...(review.valid ? { resolvedAt: reviewedAt } : {}),
      },
    },
    currentTicketId: review.valid ? undefined : report.ticketId,
    unlockedTools,
    reportHistory: [...state.reportHistory, report],
    reviewHistory: [...state.reviewHistory, review],
  })
}
