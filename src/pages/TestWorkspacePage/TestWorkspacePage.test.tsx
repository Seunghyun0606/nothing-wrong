import { fireEvent, render, screen } from '@testing-library/react'

import { App } from '../../app/App'
import { createInitialGameState } from '../../game/domain/gameState'
import { saveGameState } from '../../persistence/gameStateStorage'
import { loadWorkspaceState } from '../../persistence/workspaceStorage'

function renderWorkspace() {
  const gameState = createInitialGameState(['T01'])
  gameState.tickets.T01 = {
    ...gameState.tickets.T01!,
    status: 'TESTING',
    acceptedAt: 1,
  }
  saveGameState(gameState)
  window.history.pushState({}, '', '/test/T01')
  return render(<App />)
}

describe('Test Workspace', () => {
  beforeEach(() => {
    window.localStorage.clear()
  })

  it('renders isolated Fake Browser chrome, QA Toolbar, and real viewport widths', () => {
    renderWorkspace()

    expect(screen.getByRole('region', { name: 'Shoply test browser' })).toBeInTheDocument()
    expect(screen.getByLabelText('Fake URL')).toHaveTextContent(
      'https://shoply.local/product/everyday-pack',
    )
    expect(screen.getByRole('button', { name: 'Capture evidence' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Create report' })).toBeInTheDocument()

    const productViewport = screen.getByTestId('product-viewport')
    expect(productViewport).toHaveStyle({ width: '100%' })

    fireEvent.click(screen.getByRole('button', { name: 'Tablet' }))
    expect(productViewport).toHaveStyle({ width: '768px' })

    fireEvent.click(screen.getByRole('button', { name: 'Mobile' }))
    expect(productViewport).toHaveStyle({ width: '390px' })
  })

  it('auto-saves Ticket Notes outside reviewable Game State', () => {
    const firstRender = renderWorkspace()

    fireEvent.click(screen.getByRole('button', { name: 'notes' }))
    fireEvent.change(screen.getByLabelText('Working notes'), {
      target: { value: 'CTA looks visually secondary on checkout.' },
    })

    expect(loadWorkspaceState()?.notes.T01).toBe(
      'CTA looks visually secondary on checkout.',
    )
    expect(window.localStorage.getItem('nothingwrong.gameState')).not.toContain(
      'CTA looks visually secondary on checkout.',
    )

    firstRender.unmount()
    renderWorkspace()
    fireEvent.click(screen.getByRole('button', { name: 'notes' }))

    expect(screen.getByLabelText('Working notes')).toHaveValue(
      'CTA looks visually secondary on checkout.',
    )
  })

  it('records the Shoply journey and captures complete visible Evidence', () => {
    renderWorkspace()

    fireEvent.click(screen.getByRole('button', { name: 'Add to bag' }))
    fireEvent.click(screen.getByRole('link', { name: 'View bag' }))
    fireEvent.change(screen.getByLabelText('Quantity for Everyday Carry Pack'), {
      target: { value: '2' },
    })
    fireEvent.click(screen.getByRole('link', { name: 'Continue to checkout' }))

    expect(screen.getByLabelText('Fake URL')).toHaveTextContent(
      'https://shoply.local/checkout',
    )
    expect(screen.getByRole('button', { name: 'Confirm order' })).toHaveAttribute(
      'data-variant',
      'secondary',
    )
    expect(window.location.pathname).toBe('/test/T01')

    fireEvent.click(screen.getByRole('button', { name: 'Capture evidence' }))

    expect(
      screen.getByRole('img', { name: /Evidence preview: Shoply · Delivery details · DESKTOP/ }),
    ).toBeInTheDocument()

    const workspace = loadWorkspaceState()
    expect(workspace?.evidence[0]).toMatchObject({
      ticketId: 'T01',
      type: 'SCREENSHOT',
      context: {
        currentPath: '/shoply/checkout',
        viewport: 'DESKTOP',
        account: 'BASIC',
      },
      snapshot: {
        heading: 'Delivery details',
        visibleTargets: ['checkout.confirmButton'],
      },
    })
    expect(workspace?.evidence[0]?.capturedAt).toEqual(expect.any(Number))
    expect(workspace?.evidence[0]?.preview).toContain('Delivery details')
    expect(workspace?.interactions.map((action) => action.type)).toEqual(
      expect.arrayContaining([
        'OPEN_PRODUCT',
        'ADD_TO_CART',
        'OPEN_CART',
        'CHANGE_QUANTITY',
        'OPEN_CHECKOUT',
        'CAPTURE_EVIDENCE',
      ]),
    )

    fireEvent.click(screen.getByRole('button', { name: 'Create report' }))
    expect(
      screen.getByRole('heading', { name: 'Document what you can prove.' }),
    ).toBeInTheDocument()
  })
})
