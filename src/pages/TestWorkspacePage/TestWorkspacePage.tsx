import { useCallback, useEffect, useRef, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'

import { FakeBrowser } from '../../components/fake-browser/FakeBrowser'
import { QAToolbar, type InspectorTab } from '../../components/qa-tools/QAToolbar'
import { captureEvidence } from '../../game/evidence/captureEvidence'
import { MutationRuntimeProvider } from '../../game/mutations/MutationRuntimeProvider'
import { useGameSession } from '../../game/session/GameSessionProvider'
import { useWorkspaceSession } from '../../game/session/WorkspaceSessionProvider'
import type { Evidence, Viewport } from '../../game/domain/schemas'
import { ProductTelemetryProvider } from '../../products/shoply/ProductTelemetry'
import { useShoply } from '../../products/shoply/ShoplyProvider'
import { getScenario, isTicketUnlocked } from '../../scenarios/shoply/tickets'

function actionForPath(path: string): string {
  if (path.includes('/payment')) return 'OPEN_PAYMENT'
  if (path.includes('/orders/')) return 'OPEN_ORDER'
  if (path.endsWith('/orders')) return 'OPEN_ORDERS'
  if (path.includes('/checkout')) return 'OPEN_CHECKOUT'
  if (path.includes('/cart')) return 'OPEN_CART'
  if (path.includes('/product/')) return 'OPEN_PRODUCT'
  return 'NAVIGATE'
}

function formatCapturedAt(timestamp: number): string {
  return new Intl.DateTimeFormat('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  }).format(timestamp)
}

function EvidencePreview({ evidence }: { evidence: Evidence }) {
  const heading =
    typeof evidence.snapshot.heading === 'string'
      ? evidence.snapshot.heading
      : 'Shoply page'

  return (
    <article className="evidence-card">
      <div
        className="evidence-thumbnail"
        role="img"
        aria-label={`Evidence preview: ${evidence.preview}`}
      >
        <span>SHOPLY</span>
        <strong>{heading}</strong>
        <i />
      </div>
      <div className="evidence-card-copy">
        <strong>{heading}</strong>
        <span>{evidence.context.viewport} · {formatCapturedAt(evidence.capturedAt)}</span>
        <code>{evidence.context.currentPath}</code>
      </div>
    </article>
  )
}

export function TestWorkspacePage() {
  const { ticketId = '' } = useParams()
  const navigate = useNavigate()
  const scenario = getScenario(ticketId)
  const ticket = scenario?.ticket
  const { state: gameState } = useGameSession()
  const unlocked = ticket ? isTicketUnlocked(ticket.id, gameState) : false
  const readyForTesting = gameState.tickets[ticketId]?.status === 'TESTING'
  const shoply = useShoply()
  const {
    state,
    setNote,
    addEvidence,
    recordInteraction,
    evidenceForTicket,
    interactionsForTicket,
  } = useWorkspaceSession()
  const [activeTab, setActiveTab] = useState<InspectorTab>('ticket')
  const [viewport, setViewport] = useState<Viewport>(
    ticket?.startingContext.viewport ?? 'DESKTOP',
  )
  const [history, setHistory] = useState(() => [
    ticket?.startingContext.currentPath ?? '/shoply/product/everyday-pack',
  ])
  const [historyIndex, setHistoryIndex] = useState(0)
  const [reloadKey, setReloadKey] = useState(0)
  const [reportMessage, setReportMessage] = useState('')
  const browserRef = useRef<HTMLDivElement>(null)
  const initialPathRecorded = useRef(false)

  const currentPath = history[historyIndex] ?? '/shoply/product/everyday-pack'
  const ticketEvidence = evidenceForTicket(ticketId)
  const interactions = interactionsForTicket(ticketId)
  const mutationContext = {
    test: {
      account: ticket?.startingContext.account ?? 'GUEST',
      viewport,
      locale: ticket?.startingContext.locale ?? 'en-US',
      currentPath,
    },
    productState: {
      cart: {
        quantity: shoply.items.reduce((total, item) => total + item.quantity, 0),
      },
      coupon: shoply.coupon,
    },
  } as const

  const recordPath = useCallback(
    (path: string) => {
      recordInteraction({ ticketId, type: actionForPath(path), target: path })
    },
    [recordInteraction, ticketId],
  )

  useEffect(() => {
    if (ticket && unlocked && readyForTesting && !initialPathRecorded.current) {
      initialPathRecorded.current = true
      recordPath(ticket.startingContext.currentPath)
    }
  }, [readyForTesting, recordPath, ticket, unlocked])

  if (!ticket) {
    return (
      <main className="workspace-missing">
        <p className="kicker">Test workspace</p>
        <h1>Ticket {ticketId} is not available.</h1>
        <Link className="text-link" to="/dashboard">Return to dashboard</Link>
      </main>
    )
  }

  if (!unlocked || !readyForTesting) {
    return (
      <main className="workspace-missing">
        <p className="kicker">Test workspace unavailable</p>
        <h1>
          {unlocked
            ? 'Start this Ticket before opening the Test Workspace.'
            : `Resolve the previous Ticket to unlock ${ticket.id}.`}
        </h1>
        <Link className="text-link" to={`/tickets/${ticket.id}`}>Return to Ticket</Link>
      </main>
    )
  }

  const activeTicket = ticket

  function navigateProduct(path: string) {
    if (!path.startsWith('/shoply/')) return
    setHistory((current) => [...current.slice(0, historyIndex + 1), path])
    setHistoryIndex((current) => current + 1)
    recordPath(path)
  }

  function moveHistory(nextIndex: number) {
    const path = history[nextIndex]
    if (!path) return
    setHistoryIndex(nextIndex)
    recordPath(path)
  }

  function changeViewport(nextViewport: Viewport) {
    setViewport(nextViewport)
    recordInteraction({
      ticketId,
      type: 'CHANGE_VIEWPORT',
      target: nextViewport,
    })
  }

  function handleCapture() {
    const productRoot = browserRef.current?.querySelector('.fake-browser-viewport')
    const heading = productRoot?.querySelector('h1')?.textContent?.trim() || 'Shoply page'
    const controls = Array.from(
      productRoot?.querySelectorAll<HTMLElement>('[data-evidence-target]') ?? [],
    ).map((element) => ({
      target: element.dataset.evidenceTarget,
      text: element.textContent?.trim(),
      className: element.className,
    }))

    const evidence = captureEvidence({
      ticketId,
      context: {
        account: activeTicket.startingContext.account,
        viewport,
        locale: activeTicket.startingContext.locale,
        currentPath,
      },
      preview: `Shoply · ${heading} · ${viewport}`,
      snapshot: {
        product: 'shoply',
        heading,
        visibleTargets: controls.map((control) => control.target),
        controls,
        productState: mutationContext.productState,
      },
    })

    addEvidence(evidence)
    recordInteraction({
      ticketId,
      type: 'CAPTURE_EVIDENCE',
      target: currentPath,
      payload: { evidenceId: evidence.id },
    })
    setActiveTab('evidence')
    setReportMessage('')
  }

  function handleCreateReport() {
    if (ticketEvidence.length === 0) {
      setReportMessage('Capture at least one piece of evidence before creating a report.')
      return
    }

    navigate(`/reports/${ticketId}`)
  }

  return (
    <main className="test-workspace">
      <QAToolbar
        ticketId={activeTicket.id}
        activeTab={activeTab}
        viewport={viewport}
        evidenceCount={ticketEvidence.length}
        onSelectTab={setActiveTab}
        onViewportChange={changeViewport}
        onCapture={handleCapture}
        onCreateReport={handleCreateReport}
      />
      <div className="workspace-body">
        <div className="workspace-browser" ref={browserRef}>
          <ProductTelemetryProvider
            onInteraction={(action) => recordInteraction({ ticketId, ...action })}
          >
            <MutationRuntimeProvider
              mutations={scenario.mutations}
              context={mutationContext}
            >
              <FakeBrowser
                path={currentPath}
                viewport={viewport}
                canGoBack={historyIndex > 0}
                canGoForward={historyIndex < history.length - 1}
                reloadKey={reloadKey}
                onNavigate={navigateProduct}
                onBack={() => moveHistory(historyIndex - 1)}
                onForward={() => moveHistory(historyIndex + 1)}
                onReload={() => {
                  setReloadKey((current) => current + 1)
                  recordInteraction({ ticketId, type: 'RELOAD_PAGE', target: currentPath })
                }}
              />
            </MutationRuntimeProvider>
          </ProductTelemetryProvider>
        </div>
        <aside className="workspace-inspector" aria-label="QA inspector">
          <div className="inspector-heading">
            <span>{activeTab.toUpperCase()}</span>
            <Link to={`/tickets/${activeTicket.id}`}>Open full ticket ↗</Link>
          </div>
          {activeTab === 'ticket' && (
            <section className="ticket-panel">
              <p className="inspector-ticket-id">{activeTicket.id} · {activeTicket.priority}</p>
              <h1>{activeTicket.title}</h1>
              <p>{activeTicket.request}</p>
              <h2>Requirements</h2>
              <ol>
                {activeTicket.requirements.map((requirement) => (
                  <li key={requirement.id}>{requirement.description}</li>
                ))}
              </ol>
              <dl>
                <div><dt>Account</dt><dd>{activeTicket.startingContext.account}</dd></div>
                <div><dt>Locale</dt><dd>{activeTicket.startingContext.locale}</dd></div>
              </dl>
            </section>
          )}
          {activeTab === 'notes' && (
            <section className="notes-panel">
              <label htmlFor="ticket-notes">Working notes</label>
              <textarea
                id="ticket-notes"
                value={state.notes[activeTicket.id] ?? ''}
                onChange={(event) => setNote(activeTicket.id, event.target.value)}
                placeholder="Record observations, hypotheses, and reproduction details…"
              />
              <p>Saved locally · Notes are never included in Review scoring.</p>
            </section>
          )}
          {activeTab === 'evidence' && (
            <section className="evidence-panel">
              <div className="evidence-summary">
                <span>{ticketEvidence.length} captured</span>
                <span>{interactions.length} actions recorded</span>
              </div>
              {ticketEvidence.length === 0 ? (
                <div className="inspector-empty">
                  <strong>No evidence yet.</strong>
                  <p>Navigate to the relevant state, then capture the current Test Context.</p>
                </div>
              ) : (
                ticketEvidence.map((evidence) => (
                  <EvidencePreview evidence={evidence} key={evidence.id} />
                ))
              )}
            </section>
          )}
          {reportMessage && <p className="report-entry-message" role="status">{reportMessage}</p>}
        </aside>
      </div>
    </main>
  )
}
