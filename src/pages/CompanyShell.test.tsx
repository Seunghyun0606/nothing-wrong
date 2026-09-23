import { fireEvent, render, screen } from '@testing-library/react'

import { App } from '../app/App'

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
    expect(window.location.pathname).toBe('/shoply/product/everyday-pack')
  })

  it('shows a useful not-found state for an unknown Ticket', () => {
    renderAt('/tickets/T99')

    expect(screen.getByRole('heading', { name: 'No request matches “T99”.' })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Return to dashboard' })).toBeInTheDocument()
  })
})
