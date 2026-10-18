import { useState, type FormEvent } from 'react'

import { useMutationValue } from '../../../game/mutations/MutationRuntimeProvider'
import { OrderSummaryCard } from '../components/OrderSummaryCard'
import { ShoplyHeader } from '../components/ShoplyHeader'
import type { ShoplyOrder } from '../domain/types'
import { ProductLink } from '../ProductNavigation'
import { useShoply } from '../ShoplyProvider'
import { useProductTelemetry } from '../ProductTelemetry'

function describeVariant(variant: string): string {
  return `${variant.charAt(0).toUpperCase()}${variant.slice(1)} action style`
}

export function CheckoutPage() {
  const { items, coupon, user, placeOrder } = useShoply()
  const recordInteraction = useProductTelemetry()
  const [confirmedOrder, setConfirmedOrder] = useState<ShoplyOrder>()
  const confirmButtonVariant = useMutationValue(
    'checkout.confirmButton',
    'primary',
  )

  function submitOrder(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    recordInteraction({ type: 'CONFIRM_ORDER', target: 'checkout.confirmButton' })
    setConfirmedOrder(placeOrder())
  }

  return (
    <main className="shoply-page">
      <ShoplyHeader />
      <div className="checkout-progress" aria-label="Checkout progress">
        <span className="complete">Bag</span><i /><span className={confirmedOrder ? 'complete' : 'active'}>Details</span><i /><span className={confirmedOrder ? 'active' : undefined}>Confirmation</span>
      </div>
      {confirmedOrder ? (
        <section className="confirmation-card" role="status">
          <p className="product-category">ORDER CONFIRMED · {confirmedOrder.id.replace('order-', '#')}</p>
          <h1>Thanks, {user.name}.</h1>
          <p>Your order is confirmed and will ship within two business days.</p>
          <ProductLink to={`/shoply/orders/${confirmedOrder.id}`}>View order</ProductLink>
          {' · '}
          <ProductLink to="/shoply/product/everyday-pack">Continue shopping</ProductLink>
        </section>
      ) : items.length === 0 ? (
        <section className="shoply-empty">
          <h1>Your bag is ready for something useful.</h1>
          <ProductLink className="shoply-button inline-button" to="/shoply/product/everyday-pack">Return to product</ProductLink>
        </section>
      ) : (
        <form className="checkout-layout" onSubmit={submitOrder}>
          <section className="checkout-form">
            <p className="product-category">SECURE CHECKOUT</p>
            <h1>Delivery details</h1>
            <div className="form-grid">
              <label className="span-two">Full name<input name="name" defaultValue={user.name} required /></label>
              <label className="span-two">Street address<input name="address" defaultValue="42 Mercer Street" required /></label>
              <label>City<input name="city" defaultValue="Portland" required /></label>
              <label>Postal code<input name="postal" defaultValue="97205" required /></label>
              <label className="span-two">Card number<input name="card" inputMode="numeric" defaultValue="4242 4242 4242 4242" required /></label>
              <label>Expiry<input name="expiry" defaultValue="10/29" required /></label>
              <label>Security code<input name="cvc" inputMode="numeric" defaultValue="123" required /></label>
            </div>
          </section>
          <aside>
            <OrderSummaryCard items={items} coupon={coupon} tier={user.tier} />
            <button
              className="shoply-button shoply-confirm-button"
              data-evidence-target="checkout.confirmButton"
              data-evidence-label="Confirm order button"
              data-evidence-value={describeVariant(confirmButtonVariant)}
              data-variant={confirmButtonVariant}
              type="submit"
            >
              Confirm order
            </button>
            <p className="secure-note">Your payment details are encrypted.</p>
          </aside>
        </form>
      )}
    </main>
  )
}
