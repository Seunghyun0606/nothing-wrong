import { fireEvent, render, screen } from '@testing-library/react'

import { App } from '../app/App'
import { createInitialGameState } from '../game/domain/gameState'
import type { Evidence, PlayerAction } from '../game/domain/schemas'
import { loadGameState, saveGameState } from '../persistence/gameStateStorage'
import { saveWorkspaceState } from '../persistence/workspaceStorage'

const evidence: Evidence = {
  id: 'EVIDENCE-T01',
  ticketId: 'T01',
  type: 'SCREENSHOT',
  preview: 'Shoply · Delivery details · DESKTOP',
  capturedAt: 2,
  context: {
    account: 'BASIC',
    viewport: 'DESKTOP',
    locale: 'en-US',
    currentPath: '/shoply/checkout',
  },
  snapshot: {
    visibleTargets: ['checkout.confirmButton'],
    productState: { cart: { quantity: 1 }, coupon: '' },
  },
}

const interactions: PlayerAction[] = [
  {
    id: 'ACTION-1',
    ticketId: 'T01',
    timestamp: 1,
    type: 'OPEN_PRODUCT',
    target: '/shoply/product/everyday-pack',
  },
  {
    id: 'ACTION-2',
    ticketId: 'T01',
    timestamp: 2,
    type: 'OPEN_CHECKOUT',
    target: '/shoply/checkout',
  },
]

function seedReportingState() {
  const gameState = createInitialGameState(['T01'])
  gameState.currentTicketId = 'T01'
  gameState.tickets.T01 = {
    status: 'TESTING',
    reportIds: [],
    acceptedAt: 1,
  }
  saveGameState(gameState)
  saveWorkspaceState({ notes: {}, evidence: [evidence], interactions })
}

describe('T01 reporting flow', () => {
  beforeEach(() => {
    window.localStorage.clear()
    seedReportingState()
    window.history.pushState({}, '', '/reports/T01')
  })

  it('renders Report Builder and deterministic Review Result components', () => {
    render(<App />)

    expect(
      screen.getByRole('heading', { name: 'Document what you can prove.' }),
    ).toBeInTheDocument()
    expect(screen.getByLabelText('Report title')).toHaveValue(
      'Checkout confirmation design review: observed issue',
    )
    expect(screen.getByText('Shoply · Delivery details · DESKTOP')).toBeInTheDocument()

    fireEvent.change(screen.getByLabelText('Expected behavior'), {
      target: { value: 'Primary action style' },
    })
    fireEvent.change(screen.getByLabelText('Actual behavior'), {
      target: { value: 'Secondary action style' },
    })
    fireEvent.click(screen.getByRole('button', { name: 'Submit for QA Review' }))

    expect(screen.getByRole('heading', { name: 'VALID' })).toBeInTheDocument()
    expect(screen.getByText('100 / 100')).toBeInTheDocument()
    expect(screen.getByLabelText('Progression reward')).toHaveTextContent('XP+100')
  })

  it('persists the resolved Dashboard state across a fresh render', () => {
    const firstRender = render(<App />)
    fireEvent.change(screen.getByLabelText('Expected behavior'), {
      target: { value: 'Primary action style' },
    })
    fireEvent.change(screen.getByLabelText('Actual behavior'), {
      target: { value: 'Secondary action style' },
    })
    fireEvent.click(screen.getByRole('button', { name: 'Submit for QA Review' }))

    expect(loadGameState()).toMatchObject({
      profile: { xp: 100, level: 2, reputation: 102 },
      tickets: { T01: { status: 'RESOLVED' } },
    })

    firstRender.unmount()
    window.history.pushState({}, '', '/dashboard')
    render(<App />)

    expect(screen.getByText('100 XP')).toBeInTheDocument()
    expect(screen.getByText('102')).toBeInTheDocument()
    expect(screen.getByText('Resolved')).toBeInTheDocument()
    expect(screen.getByText('1 open')).toBeInTheDocument()
  })
})
