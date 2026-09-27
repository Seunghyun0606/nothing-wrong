import { fireEvent, render, screen, within } from '@testing-library/react'

import { App } from '../../app/App'

function renderAt(path: string) {
  window.history.pushState({}, '', path)
  return render(<App />)
}

describe('normal Shoply purchase flow', () => {
  beforeEach(() => {
    window.localStorage.clear()
  })

  it('moves from Product through Cart to Checkout with normal totals', async () => {
    renderAt('/shoply/product/everyday-pack')

    expect(screen.getByRole('heading', { name: 'Everyday Carry Pack' })).toBeInTheDocument()
    fireEvent.click(screen.getByRole('button', { name: 'Add to bag' }))
    fireEvent.click(screen.getByRole('link', { name: 'View bag' }))

    expect(await screen.findByRole('heading', { name: 'Shopping bag' })).toBeInTheDocument()
    const summary = screen.getByRole('region', { name: 'Order summary' })
    expect(within(summary).getByText('$30.00')).toBeInTheDocument()
    expect(within(summary).getByText('$35.00')).toBeInTheDocument()

    fireEvent.change(screen.getByLabelText('Coupon code'), { target: { value: 'save10' } })
    fireEvent.click(screen.getByRole('button', { name: 'Apply' }))
    expect(screen.getByText('SAVE10 applied — 10% off')).toBeInTheDocument()
    expect(screen.getByText('−$3.00')).toBeInTheDocument()

    fireEvent.change(screen.getByLabelText('Quantity for Everyday Carry Pack'), {
      target: { value: '2' },
    })
    expect(screen.getByText('Free')).toBeInTheDocument()
    expect(screen.getByText('$54.00')).toBeInTheDocument()

    fireEvent.click(screen.getByRole('link', { name: 'Continue to checkout' }))
    expect(await screen.findByRole('heading', { name: 'Delivery details' })).toBeInTheDocument()

    const confirmButton = screen.getByRole('button', { name: 'Confirm order' })
    expect(confirmButton).toHaveClass('shoply-confirm-button')
    expect(confirmButton).toHaveAttribute('data-variant', 'primary')
    fireEvent.click(confirmButton)
    expect(await screen.findByRole('heading', { name: 'Thanks, Jordan Park.' })).toBeInTheDocument()
  })

  it('renders useful empty states for Cart and Checkout', () => {
    const { unmount } = renderAt('/shoply/cart')
    expect(screen.getByRole('heading', { name: 'Your bag is empty.' })).toBeInTheDocument()
    unmount()

    renderAt('/shoply/checkout')
    expect(
      screen.getByRole('heading', { name: 'Your bag is ready for something useful.' }),
    ).toBeInTheDocument()
  })

  it('keeps SAVE20 unavailable to the normal Basic account', async () => {
    renderAt('/shoply/product/everyday-pack')
    fireEvent.click(screen.getByRole('button', { name: 'Add to bag' }))
    fireEvent.click(screen.getByRole('link', { name: /Cart, 1 items/i }))
    await screen.findByRole('heading', { name: 'Shopping bag' })

    fireEvent.change(screen.getByLabelText('Coupon code'), { target: { value: 'SAVE20' } })
    fireEvent.click(screen.getByRole('button', { name: 'Apply' }))

    expect(screen.getByText('SAVE20 is available to Gold members only')).toBeInTheDocument()
    expect(screen.queryByText('−$6.00')).not.toBeInTheDocument()
  })

  it('opens the normal cancellation flow from a processing order', async () => {
    renderAt('/shoply/orders')

    expect(screen.getByRole('heading', { name: 'Orders' })).toBeInTheDocument()
    fireEvent.click(screen.getByRole('link', { name: 'View order →' }))
    expect(
      await screen.findByRole('heading', { name: 'Order details' }),
    ).toBeInTheDocument()

    fireEvent.click(screen.getByRole('link', { name: 'Cancel order' }))

    expect(
      await screen.findByRole('heading', { name: 'Cancel your order' }),
    ).toBeInTheDocument()
    expect(screen.queryByRole('heading', { name: 'Payment details' })).not.toBeInTheDocument()
    expect(window.location.pathname).toBe('/shoply/orders/order-1042/cancel')
  })
})
