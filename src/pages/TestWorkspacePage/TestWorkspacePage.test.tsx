import { fireEvent, render, screen } from '@testing-library/react'

import { App } from '../../app/App'
import { createInitialGameState } from '../../game/domain/gameState'
import { saveGameState } from '../../persistence/gameStateStorage'
import { loadWorkspaceState } from '../../persistence/workspaceStorage'
import { TICKET_CATALOG } from '../../scenarios/shoply/tickets'

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

  it('blocks direct workspace access until the Ticket is unlocked and started', () => {
    const gameState = createInitialGameState(
      TICKET_CATALOG.map((ticket) => ticket.id),
    )
    saveGameState(gameState)
    window.history.pushState({}, '', '/test/T02')

    render(<App />)

    expect(
      screen.getByRole('heading', { name: 'Resolve the previous Ticket to unlock T02.' }),
    ).toBeInTheDocument()
    expect(screen.queryByRole('region', { name: 'Shoply test browser' })).not.toBeInTheDocument()
    expect(loadWorkspaceState()?.interactions).toEqual([])
  })

  it('requires an unlocked Ticket to be started before direct workspace access', () => {
    const gameState = createInitialGameState(
      TICKET_CATALOG.map((ticket) => ticket.id),
    )
    saveGameState(gameState)
    window.history.pushState({}, '', '/test/T01')

    render(<App />)

    expect(
      screen.getByRole('heading', {
        name: 'Start this Ticket before opening the Test Workspace.',
      }),
    ).toBeInTheDocument()
    expect(screen.queryByRole('region', { name: 'Shoply test browser' })).not.toBeInTheDocument()
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
        visibleTargets: ['cart.subtotal', 'checkout.confirmButton'],
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

  it('renders and captures the T02 subtotal Mutation at quantity two', () => {
    const gameState = createInitialGameState(
      TICKET_CATALOG.map((ticket) => ticket.id),
    )
    gameState.tickets.T01 = {
      status: 'RESOLVED',
      reportIds: ['REPORT-T01'],
      resolvedAt: 1,
    }
    gameState.tickets.T02 = {
      status: 'TESTING',
      reportIds: [],
      acceptedAt: 2,
    }
    gameState.currentTicketId = 'T02'
    saveGameState(gameState)
    window.history.pushState({}, '', '/test/T02')
    render(<App />)

    fireEvent.click(screen.getByRole('button', { name: 'Add to bag' }))
    fireEvent.click(screen.getByRole('link', { name: 'View bag' }))
    fireEvent.change(screen.getByLabelText('Quantity for Everyday Carry Pack'), {
      target: { value: '2' },
    })

    const subtotal = document.querySelector('[data-evidence-target="cart.subtotal"]')
    expect(subtotal).toHaveTextContent('$50.00')
    expect(screen.getAllByText('$60.00')).toHaveLength(2)

    fireEvent.click(screen.getByRole('button', { name: 'Capture evidence' }))
    expect(loadWorkspaceState()?.evidence.at(-1)).toMatchObject({
      ticketId: 'T02',
      context: {
        currentPath: '/shoply/cart',
        account: 'BASIC',
      },
      snapshot: {
        visibleTargets: ['cart.subtotal'],
        productState: { cart: { quantity: 2 }, coupon: '' },
      },
    })
  })

  it('routes T03 Cancel Order to payment and captures the behavior defect', () => {
    const gameState = createInitialGameState(
      TICKET_CATALOG.map((ticket) => ticket.id),
    )
    gameState.tickets.T01 = {
      status: 'RESOLVED',
      reportIds: ['REPORT-T01'],
      resolvedAt: 1,
    }
    gameState.tickets.T02 = {
      status: 'RESOLVED',
      reportIds: ['REPORT-T02'],
      resolvedAt: 2,
    }
    gameState.tickets.T03 = {
      status: 'TESTING',
      reportIds: [],
      acceptedAt: 3,
    }
    gameState.currentTicketId = 'T03'
    saveGameState(gameState)
    window.history.pushState({}, '', '/test/T03')
    render(<App />)

    expect(screen.getByRole('heading', { name: 'Order details' })).toBeInTheDocument()
    expect(screen.queryByRole('group', { name: 'Shoply account' })).not.toBeInTheDocument()
    fireEvent.click(screen.getByRole('link', { name: 'Cancel order' }))

    expect(screen.getByRole('heading', { name: 'Payment details' })).toBeInTheDocument()
    expect(screen.getByLabelText('Fake URL')).toHaveTextContent(
      'https://shoply.local/payment',
    )
    fireEvent.click(screen.getByRole('button', { name: 'Capture evidence' }))

    expect(loadWorkspaceState()?.evidence.at(-1)).toMatchObject({
      ticketId: 'T03',
      context: { currentPath: '/shoply/payment', account: 'BASIC' },
      snapshot: { visibleTargets: ['payment.form'] },
    })
    expect(loadWorkspaceState()?.interactions.map((action) => action.type)).toEqual(
      expect.arrayContaining(['OPEN_ORDER', 'CANCEL_ORDER', 'OPEN_PAYMENT']),
    )
  })

  it('unlocks account switching for T04 and captures the Gold quantity-three discount', () => {
    const gameState = createInitialGameState(TICKET_CATALOG.map((ticket) => ticket.id))
    for (const [index, id] of ['T01', 'T02', 'T03'].entries()) {
      gameState.tickets[id] = {
        status: 'RESOLVED',
        reportIds: [`REPORT-${id}`],
        resolvedAt: index + 1,
      }
    }
    gameState.tickets.T04 = { status: 'TESTING', reportIds: [], acceptedAt: 4 }
    gameState.currentTicketId = 'T04'
    saveGameState(gameState)
    window.history.pushState({}, '', '/test/T04')
    render(<App />)

    expect(screen.getByRole('group', { name: 'Shoply account' })).toBeInTheDocument()
    fireEvent.click(screen.getByRole('button', { name: 'Add to bag' }))
    fireEvent.click(screen.getByRole('link', { name: 'View bag' }))
    fireEvent.change(screen.getByLabelText('Coupon code'), { target: { value: 'SAVE20' } })
    fireEvent.click(screen.getByRole('button', { name: 'Apply' }))
    expect(screen.getByText('SAVE20 is available to Gold members only')).toBeInTheDocument()

    fireEvent.click(screen.getByRole('button', { name: 'Gold' }))
    expect(screen.getByText('−$6.00')).toBeInTheDocument()
    fireEvent.change(screen.getByLabelText('Quantity for Everyday Carry Pack'), {
      target: { value: '3' },
    })
    expect(document.querySelector('[data-evidence-target="cart.discount"]')).toHaveTextContent('−$9.00')
    expect(screen.getByText('$81.00')).toBeInTheDocument()

    fireEvent.click(screen.getByRole('button', { name: 'Capture evidence' }))
    expect(loadWorkspaceState()?.evidence.at(-1)).toMatchObject({
      ticketId: 'T04',
      context: { account: 'GOLD', currentPath: '/shoply/cart' },
      snapshot: {
        visibleTargets: ['cart.subtotal', 'cart.discount'],
        productState: { cart: { quantity: 3 }, coupon: 'SAVE20' },
      },
    })
    expect(loadWorkspaceState()?.interactions.map((action) => action.type)).toContain(
      'CHANGE_ACCOUNT',
    )
  })
})
