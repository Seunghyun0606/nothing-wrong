import { Link, useNavigate, useParams } from 'react-router-dom'

import { CompanyHeader } from '../../components/company/CompanyHeader'
import { useGameSession } from '../../game/session/GameSessionProvider'
import { getTicket } from '../../scenarios/shoply/tickets'

export function TicketDetailPage() {
  const { ticketId = '' } = useParams()
  const ticket = getTicket(ticketId)
  const navigate = useNavigate()
  const { state, startTicket } = useGameSession()

  if (!ticket) {
    return (
      <main className="company-page">
        <CompanyHeader />
        <section className="empty-state">
          <p className="kicker">Ticket not found</p>
          <h1>No request matches “{ticketId}”.</h1>
          <Link className="text-link" to="/dashboard">Return to dashboard</Link>
        </section>
      </main>
    )
  }

  const activeTicket = ticket
  const currentStatus = state.tickets[activeTicket.id]?.status ?? activeTicket.status

  function handleStartTest() {
    startTicket(activeTicket.id)
    navigate(`/test/${activeTicket.id}`)
  }

  return (
    <main className="company-page">
      <CompanyHeader />
      <div className="ticket-detail-toolbar">
        <Link className="text-link" to="/dashboard">← Ticket queue</Link>
        <span className="ticket-status">{currentStatus.replace('_', ' ')}</span>
      </div>
      <article className="ticket-detail">
        <header className="ticket-detail-header">
          <div>
            <div className="ticket-meta">
              <span className="ticket-id">{activeTicket.id}</span>
              <span className={`priority priority-${activeTicket.priority.toLowerCase()}`}>
                {activeTicket.priority}
              </span>
            </div>
            <h1>{activeTicket.title}</h1>
            <p>From {activeTicket.sender.name} · {activeTicket.sender.role}</p>
          </div>
          <button className="button button-primary" type="button" onClick={handleStartTest}>
            {currentStatus === 'TESTING' ? 'Continue test' : 'Start test'}
          </button>
        </header>
        <div className="ticket-detail-grid">
          <section>
            <p className="card-label">Request</p>
            <p className="request-copy">{activeTicket.request}</p>
          </section>
          <aside>
            <p className="card-label">Test scope</p>
            <ul className="scope-list">
              {activeTicket.scope.map((item) => <li key={item}>{item}</li>)}
            </ul>
          </aside>
          <section>
            <p className="card-label">Acceptance requirements</p>
            <ol className="requirement-list">
              {activeTicket.requirements.map((requirement) => (
                <li key={requirement.id}>
                  <span>{requirement.id}</span>
                  <p>{requirement.description}</p>
                </li>
              ))}
            </ol>
          </section>
          <aside>
            <p className="card-label">Starting context</p>
            <dl className="context-list">
              <div><dt>Account</dt><dd>{activeTicket.startingContext.account}</dd></div>
              <div><dt>Viewport</dt><dd>{activeTicket.startingContext.viewport}</dd></div>
              <div><dt>Locale</dt><dd>{activeTicket.startingContext.locale}</dd></div>
            </dl>
          </aside>
        </div>
      </article>
    </main>
  )
}
