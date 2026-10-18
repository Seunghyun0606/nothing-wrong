import { useEffect, useRef } from 'react'

import { useGameSession } from '../../../game/session/GameSessionProvider'
import type { MessengerEntry } from '../../../game/story/messengerLog'
import { displayAddress } from '../browserAddress'
import { useDesktop } from '../DesktopProvider'
import { useMessengerLog } from '../useMessenger'

function initials(name: string): string {
  return name
    .split(/\s+/)
    .map((part) => part.charAt(0))
    .join('')
    .slice(0, 2)
    .toUpperCase()
}

function ChatEntry({ entry }: { entry: MessengerEntry }) {
  const desktop = useDesktop()

  switch (entry.kind) {
    case 'message':
      return (
        <li className="chat-message">
          <span className="chat-avatar" aria-hidden="true">{initials(entry.from)}</span>
          <div>
            <p className="chat-author"><strong>{entry.from}</strong> · {entry.role}</p>
            <p className="chat-text">{entry.text}</p>
            {entry.links && entry.links.length > 0 && (
              <div className="chat-links">
                {entry.links.map((link) => (
                  <button
                    className="chat-link"
                    key={link.url}
                    type="button"
                    title={displayAddress(link.url)}
                    onClick={() => desktop.openUrl(link.url)}
                  >
                    🔗 {link.label}
                  </button>
                ))}
              </div>
            )}
          </div>
        </li>
      )
    case 'ticket':
      return (
        <li className="chat-card">
          <p className="card-label">Ticket assigned · {entry.ticketId}</p>
          <strong>{entry.title}</strong>
          <button className="chat-link" type="button" onClick={() => desktop.showTicket(entry.ticketId)}>
            Open {entry.ticketId} in QA Tracker
          </button>
        </li>
      )
    case 'clue':
      return (
        <li className="chat-card chat-clue">
          <p className="card-label">New clue · Case File</p>
          <strong>{entry.title}</strong>
          <p>{entry.text}</p>
        </li>
      )
    case 'player':
      return (
        <li className="chat-player">
          <p className="chat-author"><strong>You</strong></p>
          <p className="chat-text">{entry.text}</p>
        </li>
      )
    case 'system':
      return <li className="chat-system" role="status">{entry.text}</li>
  }
}

export function MessengerApp() {
  const { state, answerDeduction } = useGameSession()
  const { entries, delivered, pendingDeduction } = useMessengerLog()
  const visible = entries.slice(0, delivered)
  const next = entries[delivered]
  const listRef = useRef<HTMLOListElement>(null)
  const waitingForReply = pendingDeduction !== undefined && delivered >= entries.length
  const attempts = pendingDeduction
    ? (state.story.deductions[pendingDeduction.id]?.attempts ?? [])
    : []

  useEffect(() => {
    const list = listRef.current
    if (list && typeof list.scrollTo === 'function') {
      list.scrollTo({ top: list.scrollHeight })
    }
  }, [delivered])

  return (
    <div className="messenger">
      <header className="messenger-channel">
        <strong># shoply-autumn-release</strong>
        <span>Maya Kim, Daniel Reyes, Priya Nair, Sam Ortiz, you</span>
      </header>
      <ol className="chat-log" ref={listRef} aria-label="Team chat">
        {visible.length === 0 && !next && <li className="chat-system">No messages yet.</li>}
        {visible.map((entry) => <ChatEntry entry={entry} key={entry.id} />)}
        {next && next.kind === 'message' && (
          <li className="chat-typing" aria-live="polite">{next.from} is typing…</li>
        )}
      </ol>
      <footer className="messenger-composer">
        {waitingForReply && pendingDeduction ? (
          <div className="reply-options" role="group" aria-label="Reply">
            <p>{pendingDeduction.askedBy.from} is waiting for your answer. A wrong guess costs nothing.</p>
            {pendingDeduction.options
              .filter((option) => !attempts.includes(option.id))
              .map((option) => (
                <button
                  className="reply-option"
                  key={option.id}
                  type="button"
                  onClick={() => answerDeduction(pendingDeduction, option.id)}
                >
                  {option.text}
                </button>
              ))}
          </div>
        ) : (
          <p className="composer-idle">{next ? 'The team is typing…' : 'No reply needed right now.'}</p>
        )}
      </footer>
    </div>
  )
}
