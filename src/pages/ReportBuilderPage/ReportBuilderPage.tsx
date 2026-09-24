import { Link, useNavigate, useParams } from 'react-router-dom'

import { ReportBuilder } from '../../components/reporting/ReportBuilder'
import { createBugReport } from '../../game/reporting/createBugReport'
import { reviewBugReport } from '../../game/reporting/reviewBugReport'
import { useGameSession } from '../../game/session/GameSessionProvider'
import { useWorkspaceSession } from '../../game/session/WorkspaceSessionProvider'
import { getScenario } from '../../scenarios/shoply/tickets'

export function ReportBuilderPage() {
  const { ticketId = '' } = useParams()
  const navigate = useNavigate()
  const scenario = getScenario(ticketId)
  const { state, completeReview } = useGameSession()
  const { evidenceForTicket, interactionsForTicket } = useWorkspaceSession()
  const evidence = evidenceForTicket(ticketId)
  const interactions = interactionsForTicket(ticketId)

  if (!scenario) {
    return <main className="report-page"><h1>Scenario not found.</h1></main>
  }

  const ticketState = state.tickets[ticketId]
  if (!ticketState || ticketState.status !== 'TESTING') {
    return (
      <main className="report-page report-page-empty">
        <p className="kicker">Report unavailable</p>
        <h1>This Ticket is not in testing.</h1>
        <Link className="text-link" to={`/tickets/${ticketId}`}>Return to Ticket</Link>
      </main>
    )
  }

  if (evidence.length === 0) {
    return (
      <main className="report-page report-page-empty">
        <p className="kicker">Evidence required</p>
        <h1>Capture the failing state before writing a Report.</h1>
        <Link className="text-link" to={`/test/${ticketId}`}>Return to Test Workspace</Link>
      </main>
    )
  }

  const expectedBug = scenario.expectedBugs[0]
  const expectedCandidates = expectedBug
    ? [expectedBug.expected, expectedBug.actual, 'No defined visual hierarchy']
    : ['Behavior matches the requirement']
  const actualCandidates = expectedBug
    ? [expectedBug.actual, expectedBug.expected, 'Action is unavailable']
    : ['Behavior differs from the requirement']

  return (
    <main className="report-page">
      <Link className="report-back-link" to={`/test/${ticketId}`}>← Back to Test Workspace</Link>
      <ReportBuilder
        ticketId={ticketId}
        initialTitle={`${scenario.ticket.title}: observed issue`}
        evidence={evidence}
        interactions={interactions}
        expectedCandidates={expectedCandidates}
        actualCandidates={actualCandidates}
        onSubmit={(input) => {
          const report = createBugReport(input, evidence)
          const review = reviewBugReport(report, scenario, evidence)
          completeReview(report, review, scenario.progression)
          navigate(`/review/${ticketId}`)
        }}
      />
    </main>
  )
}
