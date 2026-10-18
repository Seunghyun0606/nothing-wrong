import { useState } from 'react'

import { resolveGuideStep } from '../../game/guide/resolveGuideStep'
import { useGameSession } from '../../game/session/GameSessionProvider'
import { useDesktop } from './DesktopProvider'
import { useMessengerLog } from './useMessenger'
import { useQaContext } from './useQaContext'

interface GuideStepView {
  label: string
  title: string
  instruction: string
  action?: { label: string; run: () => void }
}

/** A sticky note that points at the next useful action. Content comes from Scenario guides. */
export function GuideNote() {
  const desktop = useDesktop()
  const { state } = useGameSession()
  const qa = useQaContext()
  const messenger = useMessengerLog()
  const [hidden, setHidden] = useState(false)
  const scenario = qa.focusScenario
  const guide = scenario?.guide
  const ticketId = scenario?.ticket.id
  const status = ticketId ? state.tickets[ticketId]?.status : undefined

  const awaitingReply =
    messenger.pendingDeduction !== undefined && messenger.delivered >= messenger.entries.length
  const noteLabel = awaitingReply ? 'Case notes' : (guide?.label ?? 'Guide')

  let step: GuideStepView | undefined
  if (awaitingReply) {
    step = {
      label: 'Team chat',
      title: 'The team is waiting for your answer.',
      instruction: 'Open Messenger, read the debrief, and reply with your conclusion.',
      action: { label: 'Open Messenger', run: () => desktop.openApp('messenger') },
    }
  } else if (guide && messenger.unread > 0) {
    step = {
      label: 'New message',
      title: 'You have a new message.',
      instruction: 'Open Messenger to read your briefing.',
      action: { label: 'Open Messenger', run: () => desktop.openApp('messenger') },
    }
  } else if (guide && ticketId && (status === 'NEW' || status === 'ACCEPTED')) {
    step = {
      label: 'Accept the Ticket',
      title: `${ticketId} is waiting in QA Tracker.`,
      instruction: 'Open QA Tracker, read the requirements, and select Start test.',
      action: { label: 'Open QA Tracker', run: () => desktop.showTicket(ticketId) },
    }
  } else if (guide?.workspace && status === 'TESTING') {
    step = resolveGuideStep(guide.workspace, qa.mutationContext)
  }

  if (!step) return null

  if (hidden) {
    return (
      <button className="guide-note-tab" type="button" onClick={() => setHidden(false)}>
        📌 {noteLabel}
      </button>
    )
  }

  return (
    <aside className="guide-note" aria-label={noteLabel} aria-live="polite" aria-atomic="true">
      <header>
        <span>📌 {noteLabel} · {step.label}</span>
        <button type="button" aria-label="Hide guide" onClick={() => setHidden(true)}>–</button>
      </header>
      <p><strong>{step.title}</strong> {step.instruction}</p>
      {step.action && (
        <button className="text-link" type="button" onClick={step.action.run}>{step.action.label} →</button>
      )}
    </aside>
  )
}
