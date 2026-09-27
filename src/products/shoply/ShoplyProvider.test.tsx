import { fireEvent, render, screen } from '@testing-library/react'

import { ShoplyProvider, useShoply } from './ShoplyProvider'

function AccountPolicyHarness() {
  const shoply = useShoply()

  return (
    <div>
      <span data-testid="account">{shoply.user.tier}</span>
      <span data-testid="quantity">{shoply.itemCount}</span>
      <span data-testid="coupon">{shoply.coupon}</span>
      <button type="button" onClick={() => shoply.addToCart('everyday-pack')}>Add product</button>
      <button type="button" onClick={() => shoply.setCoupon('SAVE20')}>Set coupon</button>
      <button type="button" onClick={() => shoply.switchAccount('GOLD', false)}>Preserve switch</button>
      <button type="button" onClick={() => shoply.switchAccount('BASIC', true)}>Reset switch</button>
    </div>
  )
}

describe('Shoply account switch policy', () => {
  it('preserves or resets Product state according to the supplied Scenario policy', () => {
    render(
      <ShoplyProvider>
        <AccountPolicyHarness />
      </ShoplyProvider>,
    )

    fireEvent.click(screen.getByRole('button', { name: 'Add product' }))
    fireEvent.click(screen.getByRole('button', { name: 'Set coupon' }))
    fireEvent.click(screen.getByRole('button', { name: 'Preserve switch' }))
    expect(screen.getByTestId('account')).toHaveTextContent('GOLD')
    expect(screen.getByTestId('quantity')).toHaveTextContent('1')
    expect(screen.getByTestId('coupon')).toHaveTextContent('SAVE20')

    fireEvent.click(screen.getByRole('button', { name: 'Reset switch' }))
    expect(screen.getByTestId('account')).toHaveTextContent('BASIC')
    expect(screen.getByTestId('quantity')).toHaveTextContent('0')
    expect(screen.getByTestId('coupon')).toBeEmptyDOMElement()
  })
})
