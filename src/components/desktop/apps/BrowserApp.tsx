import { useEffect, useRef, useState, type FormEvent } from 'react'

import { captureEvidence } from '../../../game/evidence/captureEvidence'
import { MutationRuntimeProvider } from '../../../game/mutations/MutationRuntimeProvider'
import { useGameSession } from '../../../game/session/GameSessionProvider'
import { useWorkspaceSession } from '../../../game/session/WorkspaceSessionProvider'
import type { Viewport } from '../../../game/domain/schemas'
import { ProductNavigationProvider } from '../../../products/shoply/ProductNavigation'
import { ProductTelemetryProvider } from '../../../products/shoply/ProductTelemetry'
import { useShoply } from '../../../products/shoply/ShoplyProvider'
import { SCENARIO_CATALOG } from '../../../scenarios/shoply/tickets'
import { ProductRouter } from '../../fake-browser/ProductRouter'
import { AccountSwitcher } from '../../qa-tools/AccountSwitcher'
import { ViewportSwitcher } from '../../qa-tools/ViewportSwitcher'
import { docSlug, formatAddress, parseAddress, shoplyLocation, type BrowserLocation } from '../browserAddress'
import { useDesktop } from '../DesktopProvider'
import { useQaContext } from '../useQaContext'

const VIEWPORT_WIDTHS: Record<Viewport, string> = {
  DESKTOP: '100%',
  TABLET: '768px',
  MOBILE: '390px',
}

function DocsPage({ slug }: { slug: string }) {
  const { state } = useGameSession()
  const docs = SCENARIO_CATALOG.filter(
    (scenario) =>
      state.tickets[scenario.ticket.id] !== undefined && scenario.ticket.attachments,
  ).flatMap((scenario) => scenario.ticket.attachments ?? [])
  const desktop = useDesktop()
  const doc = docs.find((candidate) => docSlug(candidate.name) === slug)

  if (!doc) {
    return (
      <main className="intranet-page">
        <p className="intranet-brand">Nothing Wrong · Intranet</p>
        <h1>{slug ? 'Document not found' : 'Documents'}</h1>
        <ul className="intranet-index">
          {docs.map((candidate) => (
            <li key={candidate.id}>
              <button
                className="text-link"
                type="button"
                onClick={() => desktop.navigate({ kind: 'docs', slug: docSlug(candidate.name) })}
              >
                {candidate.name}
              </button>
            </li>
          ))}
        </ul>
      </main>
    )
  }

  return (
    <main className="intranet-page">
      <p className="intranet-brand">Nothing Wrong · Intranet · {doc.reference}</p>
      <h1>{doc.name}</h1>
      <ul>
        {(doc.content ?? ['No content published yet.']).map((line) => <li key={line}>{line}</li>)}
      </ul>
    </main>
  )
}

function NewTabPage({ visited }: { visited: readonly BrowserLocation[] }) {
  const desktop = useDesktop()
  const addresses = [...new Set(visited.map((location) => formatAddress(location)))].filter(Boolean)

  return (
    <main className="newtab-page">
      <p className="intranet-brand">NW Browser</p>
      <h1>Where to?</h1>
      <p>Type an address in the bar above. Work sites end in <code>.local</code>.</p>
      {addresses.length > 0 && (
        <>
          <p className="card-label">Recently visited</p>
          <ul>
            {addresses.slice(-5).reverse().map((address) => (
              <li key={address}>
                <button className="text-link" type="button" onClick={() => desktop.openUrl(address)}>
                  {address.replace(/^https:\/\//, '')}
                </button>
              </li>
            ))}
          </ul>
        </>
      )}
    </main>
  )
}

function UnreachablePage({ address }: { address: string }) {
  const host = address.replace(/^[a-z]+:\/\//i, '').split('/')[0]
  return (
    <main className="unreachable-page">
      <h1>This site can't be reached</h1>
      <p>Check if there is a typo in <strong>{host}</strong>.</p>
      <p className="unreachable-code">DNS_PROBE_FINISHED_NXDOMAIN</p>
    </main>
  )
}

export function BrowserApp() {
  const desktop = useDesktop()
  const { state: gameState } = useGameSession()
  const { addEvidence, recordInteraction } = useWorkspaceSession()
  const shoply = useShoply()
  const qa = useQaContext()
  const { location } = desktop
  const [address, setAddress] = useState(formatAddress(location))
  const [visited, setVisited] = useState<BrowserLocation[]>([])
  const viewportRef = useRef<HTMLDivElement>(null)
  const stageRef = useRef<HTMLDivElement>(null)
  const activeTicketId = qa.activeTicketId
  const accountSwitcherUnlocked = gameState.unlockedTools.includes('ACCOUNT_SWITCHER')

  useEffect(() => {
    setAddress(formatAddress(location))
    if (location.kind !== 'newtab') setVisited((current) => [...current, location])
    if (stageRef.current) stageRef.current.scrollTop = 0
  }, [location])

  function submitAddress(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    desktop.navigate(parseAddress(address))
  }

  function changeAccount(nextAccount: 'BASIC' | 'GOLD') {
    if (!accountSwitcherUnlocked || nextAccount === shoply.user.tier) return
    const resetProductState = qa.activeScenario?.accountSwitchPolicy?.resetProductState ?? false
    shoply.switchAccount(nextAccount, resetProductState)
    if (resetProductState) desktop.reload()
    if (activeTicketId) {
      recordInteraction({ ticketId: activeTicketId, type: 'CHANGE_ACCOUNT', target: nextAccount })
    }
  }

  function capture() {
    if (!activeTicketId || location.kind !== 'shoply') return
    const productRoot = viewportRef.current
    const heading = productRoot?.querySelector('h1')?.textContent?.trim() || 'Shoply page'
    const controls = Array.from(
      productRoot?.querySelectorAll<HTMLElement>('[data-evidence-target]') ?? [],
    ).map((element) => ({
      target: element.dataset.evidenceTarget,
      label: element.dataset.evidenceLabel,
      value: element.dataset.evidenceValue ?? element.textContent?.trim().replace(/\s+/g, ' '),
      text: element.textContent?.trim(),
      className: element.className,
    }))
    const evidence = captureEvidence({
      ticketId: activeTicketId,
      context: qa.mutationContext.test,
      preview: `Shoply · ${heading} · ${desktop.viewport}`,
      snapshot: {
        product: 'shoply',
        heading,
        visibleTargets: controls.map((control) => control.target),
        controls,
        productState: qa.mutationContext.productState,
      },
    })
    addEvidence(evidence)
    recordInteraction({
      ticketId: activeTicketId,
      type: 'CAPTURE_EVIDENCE',
      target: location.path,
      payload: { evidenceId: evidence.id },
    })
    desktop.pushToast({
      title: 'Evidence saved',
      text: `${heading} was saved to QA Notes.`,
      app: 'notes',
    })
  }

  const canCapture = activeTicketId !== undefined && location.kind === 'shoply'

  return (
    <div className="browser">
      <div className="browser-toolbar">
        <button type="button" aria-label="Go back" disabled={!desktop.canGoBack} onClick={desktop.goBack}>←</button>
        <button type="button" aria-label="Go forward" disabled={!desktop.canGoForward} onClick={desktop.goForward}>→</button>
        <button type="button" aria-label="Reload page" onClick={desktop.reload}>↻</button>
        <form className="browser-address" onSubmit={submitAddress} role="search">
          <input
            aria-label="Address"
            autoComplete="off"
            placeholder="Type an address"
            spellCheck={false}
            value={address}
            onChange={(event) => setAddress(event.target.value)}
            onFocus={(event) => event.currentTarget.select()}
          />
        </form>
      </div>
      <div className="browser-qa-bar" aria-label="QA tools">
        <span className="browser-qa-ticket">
          {activeTicketId ? `QA · ${activeTicketId}` : 'QA · no active Ticket'}
        </span>
        <ViewportSwitcher value={desktop.viewport} onChange={desktop.setViewport} />
        {accountSwitcherUnlocked && (
          <AccountSwitcher value={shoply.user.tier} onChange={changeAccount} />
        )}
        <button
          className="qa-capture"
          type="button"
          disabled={!canCapture}
          title={canCapture ? 'Save this screen to QA Notes' : 'Start a Ticket in QA Tracker and open Shoply to capture'}
          onClick={capture}
        >
          Capture
        </button>
      </div>
      <div className="browser-stage" ref={stageRef}>
        {location.kind === 'shoply' ? (
          <div
            className="fake-browser-viewport"
            data-testid="product-viewport"
            data-viewport={desktop.viewport}
            ref={viewportRef}
            style={{ width: VIEWPORT_WIDTHS[desktop.viewport] }}
          >
            <ProductTelemetryProvider
              onInteraction={(action) => {
                if (activeTicketId) recordInteraction({ ticketId: activeTicketId, ...action })
              }}
            >
              <MutationRuntimeProvider
                mutations={qa.activeScenario?.mutations ?? []}
                context={qa.mutationContext}
              >
                <ProductNavigationProvider
                  currentPath={location.path}
                  onNavigate={(path) => desktop.navigate(shoplyLocation(path))}
                >
                  <div key={desktop.reloadKey} data-testid="product-router">
                    <ProductRouter path={location.path} />
                  </div>
                </ProductNavigationProvider>
              </MutationRuntimeProvider>
            </ProductTelemetryProvider>
          </div>
        ) : location.kind === 'docs' ? (
          <DocsPage slug={location.slug} />
        ) : location.kind === 'unreachable' ? (
          <UnreachablePage address={location.address} />
        ) : (
          <NewTabPage visited={visited} />
        )}
      </div>
    </div>
  )
}
