import type { Evidence, PlayerAction } from '../../../game/domain/schemas'
import { describeObservation, observationsOf } from '../../../game/evidence/observations'
import { useGameSession } from '../../../game/session/GameSessionProvider'
import { useWorkspaceSession } from '../../../game/session/WorkspaceSessionProvider'
import { getScenario, isTicketUnlocked, TICKET_CATALOG } from '../../../scenarios/shoply/tickets'
import { displayAddress, docUrl, shoplyUrl } from '../browserAddress'
import { useDesktop } from '../DesktopProvider'
import { useQaContext } from '../useQaContext'

function formatTime(timestamp: number): string {
  return new Intl.DateTimeFormat('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  }).format(timestamp)
}

export function EvidenceCard({ evidence }: { evidence: Evidence }) {
  const heading =
    typeof evidence.snapshot.heading === 'string' ? evidence.snapshot.heading : 'Shoply page'
  const observations = observationsOf(evidence)

  return (
    <article className="evidence-card">
      <div className="evidence-thumbnail" role="img" aria-label={`Evidence preview: ${evidence.preview}`}>
        <span>SHOPLY</span>
        <strong>{heading}</strong>
        <i />
      </div>
      <div className="evidence-card-copy">
        <strong>{heading}</strong>
        <span>{evidence.context.account} · {evidence.context.viewport} · {formatTime(evidence.capturedAt)}</span>
        <code>{displayAddress(shoplyUrl(evidence.context.currentPath))}</code>
        {observations.length > 0 && (
          <ul className="evidence-observations" aria-label="Captured values">
            {observations.map((observation) => (
              <li key={observation.target}>{describeObservation(observation)}</li>
            ))}
          </ul>
        )}
      </div>
    </article>
  )
}

function actionLabel(action: PlayerAction): string {
  return `${action.type.replaceAll('_', ' ').toLowerCase()}${action.target ? ` · ${action.target}` : ''}`
}

export function NotesApp() {
  const desktop = useDesktop()
  const { state } = useGameSession()
  const workspace = useWorkspaceSession()
  const qa = useQaContext()
  const tickets = TICKET_CATALOG.filter((ticket) => isTicketUnlocked(ticket.id, state))
  const ticketId = desktop.notesTicketId ?? qa.focusTicketId ?? tickets[0]?.id
  const scenario = ticketId ? getScenario(ticketId) : undefined
  const ticket = scenario?.ticket

  if (!ticket) {
    return <div className="notes-app"><p className="notes-empty">No Tickets assigned yet.</p></div>
  }

  const evidence = workspace.evidenceForTicket(ticket.id)
  const interactions = workspace.interactionsForTicket(ticket.id)
  const startUrl = shoplyUrl(ticket.startingContext.currentPath)

  return (
    <div className="notes-app">
      <nav className="notes-files" aria-label="Note files">
        {tickets.map((candidate) => (
          <button
            aria-pressed={candidate.id === ticket.id}
            key={candidate.id}
            type="button"
            onClick={() => desktop.showNotes(candidate.id)}
          >
            📝 {candidate.id}.txt
          </button>
        ))}
      </nav>
      <div className="notes-document">
        <section className="notes-sheet" aria-label="Ticket sheet">
          <p className="card-label">{ticket.id} · {state.tickets[ticket.id]?.status.replace('_', ' ')}</p>
          <h2>{ticket.title}</h2>
          <p>
            Start here:{' '}
            <button className="text-link" type="button" onClick={() => desktop.openUrl(startUrl)}>
              {displayAddress(startUrl)}
            </button>
          </p>
          {ticket.attachments?.map((attachment) => (
            <p key={attachment.id}>
              Doc:{' '}
              <button className="text-link" type="button" onClick={() => desktop.openUrl(docUrl(attachment.name))}>
                {attachment.name}
              </button>
            </p>
          ))}
          <ol>
            {ticket.requirements.map((requirement) => (
              <li key={requirement.id}><code>{requirement.id}</code> {requirement.description}</li>
            ))}
          </ol>
        </section>

        <section className="notes-section">
          <label htmlFor="ticket-notes">My notes</label>
          <textarea
            id="ticket-notes"
            value={workspace.state.notes[ticket.id] ?? ''}
            onChange={(event) => workspace.setNote(ticket.id, event.target.value)}
            placeholder="Observations, hypotheses, reproduction details…"
          />
          <small>Saved automatically · Notes are never scored.</small>
        </section>

        <section className="notes-section" aria-label="Evidence">
          <p className="card-label">Evidence · {evidence.length}</p>
          {evidence.length === 0 ? (
            <p className="notes-empty">Nothing captured yet. Select Capture in the Browser while the problem is on screen.</p>
          ) : (
            <div className="notes-evidence">
              {[...evidence].reverse().map((item) => <EvidenceCard evidence={item} key={item.id} />)}
            </div>
          )}
        </section>

        <section className="notes-section" aria-label="Activity log">
          <p className="card-label">Activity log · {interactions.length}</p>
          <ol className="notes-activity">
            {interactions.slice(-30).map((action) => (
              <li key={action.id}><time>{formatTime(action.timestamp)}</time> {actionLabel(action)}</li>
            ))}
          </ol>
        </section>
      </div>
    </div>
  )
}
