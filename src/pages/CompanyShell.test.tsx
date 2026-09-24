import { fireEvent, render, screen } from '@testing-library/react'

import { App } from '../app/App'
import { createInitialGameState } from '../game/domain/gameState'
import { saveGameState } from '../persistence/gameStateStorage'
import { TICKET_CATALOG } from '../scenarios/shoply/tickets'

function renderAt(path: string) {
  window.history.pushState({}, '', path)
  return render(<App />)
}

describe('Company Shell', () => {
  beforeEach(() => {
    window.localStorage.clear()
  })

  it('moves a fresh player from Start through Login to Dashboard', async () => {
    renderAt('/start')

    fireEvent.click(screen.getByRole('link', { name: /start work/i }))
    expect(screen.getByRole('heading', { name: 'Company login' })).toBeInTheDocument()

    fireEvent.click(screen.getByRole('button', { name: 'Enter workspace' }))

    expect(
      await screen.findByRole('heading', { name: 'Good morning, J. PARK.' }),
    ).toBeInTheDocument()
    expect(screen.getByText('Junior QA')).toBeInTheDocument()
    expect(screen.getByText('0 XP')).toBeInTheDocument()
    expect(screen.getByText('100')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: /Checkout confirmation design review/i })).toBeInTheDocument()
    expect(screen.queryByRole('link', { name: /Cart subtotal verification/i })).not.toBeInTheDocument()
    expect(screen.getByText('Cart subtotal verification')).toBeInTheDocument()
    expect(screen.getByText('Locked')).toBeInTheDocument()
  })

  it('opens T01 details and starts the normal Shoply test path', async () => {
    renderAt('/tickets/T01')

    expect(
      screen.getByRole('heading', { name: 'Checkout confirmation design review' }),
    ).toBeInTheDocument()
    expect(screen.getByText('REQ-T01-02')).toBeInTheDocument()
    expect(screen.getByText('BASIC')).toBeInTheDocument()

    fireEvent.click(screen.getByRole('button', { name: 'Start test' }))

    expect(
      await screen.findByRole('heading', { name: 'Everyday Carry Pack' }),
    ).toBeInTheDocument()
    expect(window.location.pathname).toBe('/test/T01')
  })

  it('shows a useful not-found state for an unknown Ticket', () => {
    renderAt('/tickets/T99')

    expect(screen.getByRole('heading', { name: 'No request matches “T99”.' })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Return to dashboard' })).toBeInTheDocument()
  })

  it('unlocks T02 after persisted T01 resolution', () => {
    const state = createInitialGameState(TICKET_CATALOG.map((ticket) => ticket.id))
    state.tickets.T01 = {
      status: 'RESOLVED',
      reportIds: ['REPORT-T01'],
      resolvedAt: 1,
    }
    saveGameState(state)

    renderAt('/dashboard')

    expect(
      screen.getByRole('link', { name: /Cart subtotal verification/i }),
    ).toBeInTheDocument()
    expect(screen.getByText('1 open')).toBeInTheDocument()
  })

  it('blocks direct access to T02 before T01 resolution', () => {
    renderAt('/tickets/T02')

    expect(
      screen.getByRole('heading', { name: 'Resolve the previous Ticket to unlock T02.' }),
    ).toBeInTheDocument()
  })
})
