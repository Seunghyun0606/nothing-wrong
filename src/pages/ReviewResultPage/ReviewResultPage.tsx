import { Link, useParams } from 'react-router-dom'

import { ReviewResultPanel } from '../../components/reporting/ReviewResultPanel'
import { useGameSession } from '../../game/session/GameSessionProvider'
import { getTicket } from '../../scenarios/shoply/tickets'

export function ReviewResultPage() {
  const { ticketId = '' } = useParams()
  const ticket = getTicket(ticketId)
  const { state } = useGameSession()
  const reportId = state.tickets[ticketId]?.reportIds.at(-1)
  const reportIndex = state.reportHistory.findIndex((report) => report.id === reportId)
  const result = reportIndex >= 0 ? state.reviewHistory[reportIndex] : undefined

  if (!ticket || !result) {
    return (
      <main className="review-page review-page-empty">
        <p className="kicker">QA Review</p>
        <h1>No Review is available for this Ticket.</h1>
        <Link className="text-link" to="/dashboard">Return to Dashboard</Link>
      </main>
    )
  }

  return (
    <main className="review-page">
      <div className="review-page-heading">
        <p className="kicker">{ticket.id} · {ticket.projectId}</p>
        <h2>{ticket.title}</h2>
      </div>
      <ReviewResultPanel result={result} />
      <Link
        className="button button-primary review-dashboard-link"
        to={result.valid ? '/dashboard' : `/test/${ticketId}`}
      >
        {result.valid ? 'Return to Dashboard' : 'Return to Test Workspace'}
      </Link>
    </main>
  )
}
