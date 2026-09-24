import { Link } from 'react-router-dom'

import { CompanyHeader } from '../../components/company/CompanyHeader'
import { useGameSession } from '../../game/session/GameSessionProvider'
import { TICKET_CATALOG } from '../../scenarios/shoply/tickets'

const STATUS_LABELS = {
  NEW: 'New',
  ACCEPTED: 'Accepted',
  TESTING: 'In testing',
  REPORTED: 'Reported',
  REVIEWED: 'Reviewed',
  RESOLVED: 'Resolved',
  NO_ISSUE: 'No issue',
} as const

export function DashboardPage() {
  const { state } = useGameSession()
  const { profile } = state
  const openTicketCount = TICKET_CATALOG.filter(
    (ticket) => state.tickets[ticket.id]?.status !== 'RESOLVED',
  ).length

  return (
    <main className="company-page">
      <CompanyHeader />
      <section className="dashboard-hero">
        <div>
          <p className="kicker">Thursday / Morning shift</p>
          <h1>Good morning, {profile.name}.</h1>
          <p>One request is ready for investigation.</p>
        </div>
        <div className="availability-badge">
          <span className="status-dot" aria-hidden="true" /> Available
        </div>
      </section>

      <section className="career-grid" aria-label="Player and career overview">
        <article className="profile-card">
          <p className="card-label">Player</p>
          <div className="profile-avatar" aria-hidden="true">
            JP
          </div>
          <div>
            <h2>{profile.name}</h2>
            <p>{profile.career === 'JUNIOR_QA' ? 'Junior QA' : 'QA Engineer'}</p>
          </div>
        </article>
        <article className="metric-card">
          <p className="card-label">Career level</p>
          <strong>{profile.level.toString().padStart(2, '0')}</strong>
          <span>Junior track</span>
        </article>
        <article className="metric-card">
          <p className="card-label">Experience</p>
          <strong>{profile.xp} XP</strong>
          <span>100 XP to next level</span>
        </article>
        <article className="metric-card">
          <p className="card-label">Reputation</p>
          <strong>{profile.reputation}</strong>
          <span>Trusted</span>
        </article>
      </section>

      <section className="ticket-section" aria-labelledby="ticket-list-heading">
        <div className="section-heading">
          <div>
            <p className="kicker">Assigned to you</p>
            <h2 id="ticket-list-heading">Ticket queue</h2>
          </div>
          <span>{openTicketCount} open</span>
        </div>
        <div className="ticket-table">
          {TICKET_CATALOG.map((ticket) => {
            const status = state.tickets[ticket.id]?.status ?? ticket.status
            return (
              <Link
                className="ticket-row"
                key={ticket.id}
                to={`/tickets/${ticket.id}`}
              >
                <span className="ticket-id">{ticket.id}</span>
                <span>
                  <strong>{ticket.title}</strong>
                  <small>{ticket.projectId} · {ticket.scope.join(' / ')}</small>
                </span>
                <span className={`priority priority-${ticket.priority.toLowerCase()}`}>
                  {ticket.priority}
                </span>
                <span className="ticket-status">{STATUS_LABELS[status]}</span>
                <span className="row-arrow" aria-hidden="true">↗</span>
              </Link>
            )
          })}
        </div>
      </section>
    </main>
  )
}
