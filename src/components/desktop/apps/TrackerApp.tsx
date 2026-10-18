import { useState } from 'react'

import type { Scenario } from '../../../game/domain/schemas'
import { createBugReport } from '../../../game/reporting/createBugReport'
import { reviewBugReport } from '../../../game/reporting/reviewBugReport'
import { useGameSession } from '../../../game/session/GameSessionProvider'
import { useWorkspaceSession } from '../../../game/session/WorkspaceSessionProvider'
import { STORY_CHAPTERS } from '../../../scenarios/shoply/chapter1'
import {
  getScenario,
  isTicketUnlocked,
  SCENARIO_CATALOG,
  TICKET_CATALOG,
} from '../../../scenarios/shoply/tickets'
import { ReportBuilder } from '../../reporting/ReportBuilder'
import { ReviewResultPanel } from '../../reporting/ReviewResultPanel'
import { CaseFile } from '../../story/CaseFile'
import { displayAddress, docUrl, shoplyUrl } from '../browserAddress'
import { useDesktop } from '../DesktopProvider'
import { useQaContext } from '../useQaContext'

const STATUS_LABELS = {
  NEW: 'New',
  ACCEPTED: 'Accepted',
  TESTING: 'In testing',
  REPORTED: 'Reported',
  REVIEWED: 'Reviewed',
  RESOLVED: 'Resolved',
  NO_ISSUE: 'No issue',
} as const

function reputationLabel(reputation: number): string {
  if (reputation >= 110) return 'Highly trusted'
  if (reputation >= 100) return 'Trusted'
  if (reputation >= 90) return 'Under watch'
  return 'Needs improvement'
}

function TicketDetail({ scenario }: { scenario: Scenario }) {
  const desktop = useDesktop()
  const { state, startTicket } = useGameSession()
  const { evidenceForTicket } = useWorkspaceSession()
  const [message, setMessage] = useState('')
  const ticket = scenario.ticket
  const status = state.tickets[ticket.id]?.status ?? ticket.status
  const intro = scenario.guide?.ticketIntro
  const startUrl = shoplyUrl(ticket.startingContext.currentPath)
  const hasReview = (state.tickets[ticket.id]?.reportIds.length ?? 0) > 0

  function createReport() {
    if (evidenceForTicket(ticket.id).length === 0) {
      setMessage('Capture at least one piece of Evidence in the Browser before creating a report.')
      return
    }
    setMessage('')
    desktop.showTicket(ticket.id, 'report')
  }

  return (
    <article className="tracker-ticket">
      <header className="tracker-ticket-header">
        <div>
          <p className="ticket-meta">
            <span className="ticket-id">{ticket.id}</span>
            <span className={`priority priority-${ticket.priority.toLowerCase()}`}>{ticket.priority}</span>
            <span className="ticket-status">{STATUS_LABELS[status]}</span>
          </p>
          <h1>{ticket.title}</h1>
          <p>From {ticket.sender.name} · {ticket.sender.role}</p>
        </div>
        <div className="tracker-actions">
          {status === 'NEW' || status === 'ACCEPTED' ? (
            <button className="button button-primary" type="button" onClick={() => startTicket(ticket.id)}>
              Start test
            </button>
          ) : status === 'TESTING' ? (
            <>
              <button className="button button-primary" type="button" onClick={createReport}>
                Create report
              </button>
              {hasReview && (
                <button className="button button-secondary" type="button" onClick={() => desktop.showTicket(ticket.id, 'review')}>
                  Last review
                </button>
              )}
            </>
          ) : (
            <button className="button button-secondary" type="button" onClick={() => desktop.showTicket(ticket.id, 'review')}>
              View review
            </button>
          )}
        </div>
      </header>
      {message && <p className="report-entry-message" role="status">{message}</p>}
      {status === 'TESTING' && (
        <p className="tracker-callout">
          Testing. Open{' '}
          <button className="text-link" type="button" onClick={() => desktop.openUrl(startUrl)}>
            {displayAddress(startUrl)}
          </button>{' '}
          in the Browser. Captures collect in QA Notes.
        </p>
      )}
      {intro && status !== 'RESOLVED' && (
        <section className="first-ticket-intro" aria-label={intro.label}>
          <div>
            <p className="card-label">{scenario.guide?.label}</p>
            <h2>{intro.heading}</h2>
            <p>{intro.body}</p>
          </div>
          <ol>
            {intro.steps.map((step) => <li key={step}>{step}</li>)}
          </ol>
        </section>
      )}
      <div className="tracker-ticket-grid">
        <section>
          <p className="card-label">Request</p>
          <p className="request-copy">{ticket.request}</p>
          <p className="card-label">Acceptance requirements</p>
          <ol className="requirement-list">
            {ticket.requirements.map((requirement) => (
              <li key={requirement.id}>
                <span>{requirement.id}</span>
                <p>{requirement.description}</p>
              </li>
            ))}
          </ol>
        </section>
        <aside>
          <p className="card-label">Test scope</p>
          <ul className="scope-list">
            {ticket.scope.map((item) => <li key={item}>{item}</li>)}
          </ul>
          <p className="card-label">Starting context</p>
          <dl className="context-list">
            <div><dt>Account</dt><dd>{ticket.startingContext.account}</dd></div>
            <div><dt>Viewport</dt><dd>{ticket.startingContext.viewport}</dd></div>
            <div><dt>Locale</dt><dd>{ticket.startingContext.locale}</dd></div>
          </dl>
          {ticket.attachments && ticket.attachments.length > 0 && (
            <>
              <p className="card-label">Attachments</p>
              <ul className="tracker-docs">
                {ticket.attachments.map((attachment) => (
                  <li key={attachment.id}>
                    <button className="text-link" type="button" onClick={() => desktop.openUrl(docUrl(attachment.name))}>
                      📎 {attachment.name}
                    </button>
                  </li>
                ))}
              </ul>
            </>
          )}
          {ticket.hints && ticket.hints.length > 0 && (
            <details className="ticket-hint">
              <summary>Need a hint?</summary>
              <ul>{ticket.hints.map((hint) => <li key={hint.id}>{hint.text}</li>)}</ul>
            </details>
          )}
        </aside>
      </div>
    </article>
  )
}

function TicketReport({ scenario }: { scenario: Scenario }) {
  const desktop = useDesktop()
  const { completeReview } = useGameSession()
  const { evidenceForTicket, interactionsForTicket } = useWorkspaceSession()
  const ticketId = scenario.ticket.id
  const evidence = evidenceForTicket(ticketId)

  return (
    <div className="tracker-report">
      <button className="text-link report-back-link" type="button" onClick={() => desktop.showTicket(ticketId)}>
        ← Back to {ticketId}
      </button>
      <ReportBuilder
        ticketId={ticketId}
        initialTitle={`${scenario.ticket.title}: observed issue`}
        requirements={scenario.ticket.requirements}
        evidence={evidence}
        interactions={interactionsForTicket(ticketId)}
        guideSteps={scenario.guide?.report}
        onSubmit={(input) => {
          const report = createBugReport(input, evidence)
          const review = reviewBugReport(report, scenario, evidence)
          completeReview(report, review, scenario.progression)
          desktop.showTicket(ticketId, 'review')
        }}
      />
    </div>
  )
}

function TicketReview({ scenario }: { scenario: Scenario }) {
  const desktop = useDesktop()
  const { state } = useGameSession()
  const ticketId = scenario.ticket.id
  const reportId = state.tickets[ticketId]?.reportIds.at(-1)
  const reportIndex = state.reportHistory.findIndex((report) => report.id === reportId)
  const result = reportIndex >= 0 ? state.reviewHistory[reportIndex] : undefined

  if (!result) {
    return <p className="tracker-empty">No Review is available for this Ticket yet.</p>
  }

  const isLatestReview = reportIndex === state.reportHistory.length - 1
  const previousLevel = Math.floor((state.profile.xp - result.xp) / 100) + 1
  const leveledUp = result.valid && isLatestReview && state.profile.level > previousLevel
  const guideMessage = scenario.guide?.review
    ? result.valid ? scenario.guide.review.valid : scenario.guide.review.invalid
    : undefined

  return (
    <div className="tracker-review">
      <ReviewResultPanel result={result} />
      {leveledUp && <p className="level-up" role="status">Level up! You are now Level {state.profile.level}.</p>}
      {guideMessage && <p className="first-ticket-review-guide">{guideMessage}</p>}
      <div className="review-actions">
        {result.valid ? (
          <>
            {scenario.story && (
              <button className="button button-primary" type="button" onClick={() => desktop.openApp('messenger')}>
                The team replied · Open Messenger
              </button>
            )}
            <button className="button button-secondary" type="button" onClick={() => desktop.setTrackerView('casefile')}>
              Open Case File
            </button>
          </>
        ) : (
          <button className="button button-primary" type="button" onClick={() => desktop.showTicket(ticketId)}>
            Back to {ticketId}
          </button>
        )}
      </div>
    </div>
  )
}

export function TrackerApp() {
  const desktop = useDesktop()
  const { state } = useGameSession()
  const qa = useQaContext()
  const { profile } = state
  const selectedId = desktop.trackerTicketId ?? qa.focusTicketId ?? TICKET_CATALOG[0]?.id
  const scenario = selectedId ? getScenario(selectedId) : undefined
  const unlocked = scenario ? isTicketUnlocked(scenario.ticket.id, state) : false
  const view = desktop.trackerView

  return (
    <div className="tracker">
      <header className="tracker-header">
        <div className="tracker-profile">
          <span className="profile-avatar" aria-hidden="true">JP</span>
          <div>
            <strong>{profile.name}</strong>
            <span>{profile.career === 'JUNIOR_QA' ? 'Junior QA' : 'QA Engineer'}</span>
          </div>
        </div>
        <dl className="tracker-stats">
          <div><dt>Level</dt><dd>{profile.level.toString().padStart(2, '0')}</dd></div>
          <div><dt>Experience</dt><dd>{profile.xp} XP</dd><span>{profile.level * 100 - profile.xp} XP to next level</span></div>
          <div><dt>Reputation</dt><dd>{profile.reputation}</dd><span>{reputationLabel(profile.reputation)}</span></div>
        </dl>
        <nav className="tracker-tabs" aria-label="QA Tracker sections">
          <button aria-pressed={view !== 'casefile'} type="button" onClick={() => desktop.setTrackerView('detail')}>
            Ticket queue
          </button>
          <button aria-pressed={view === 'casefile'} type="button" onClick={() => desktop.setTrackerView('casefile')}>
            Case File
          </button>
        </nav>
      </header>
      {view === 'casefile' ? (
        <div className="tracker-casefile">
          {STORY_CHAPTERS.map((chapter) => (
            <CaseFile chapter={chapter} key={chapter.id} scenarios={SCENARIO_CATALOG} state={state} />
          ))}
        </div>
      ) : (
        <div className="tracker-body">
          <nav className="tracker-queue" aria-label="Ticket queue">
            {TICKET_CATALOG.map((ticket) => {
              const ticketUnlocked = isTicketUnlocked(ticket.id, state)
              const status = state.tickets[ticket.id]?.status ?? ticket.status
              return (
                <button
                  aria-pressed={ticket.id === selectedId}
                  className="tracker-queue-row"
                  disabled={!ticketUnlocked}
                  key={ticket.id}
                  type="button"
                  onClick={() => desktop.showTicket(ticket.id)}
                >
                  <span className="ticket-id">{ticket.id}</span>
                  <strong>{ticket.title}</strong>
                  <small>{ticketUnlocked ? STATUS_LABELS[status] : 'Locked'}</small>
                </button>
              )
            })}
          </nav>
          <div className="tracker-pane">
            {!scenario || !unlocked ? (
              <p className="tracker-empty">Resolve the previous Ticket to unlock this one.</p>
            ) : view === 'report' && state.tickets[scenario.ticket.id]?.status === 'TESTING' ? (
              <TicketReport key={scenario.ticket.id} scenario={scenario} />
            ) : view === 'review' ? (
              <TicketReview scenario={scenario} />
            ) : (
              <TicketDetail key={scenario.ticket.id} scenario={scenario} />
            )}
          </div>
        </div>
      )}
    </div>
  )
}
