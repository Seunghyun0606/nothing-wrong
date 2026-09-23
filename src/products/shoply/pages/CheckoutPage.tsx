import { useState, type FormEvent } from 'react'
import { Link } from 'react-router-dom'

import { OrderSummaryCard } from '../components/OrderSummaryCard'
import { ShoplyHeader } from '../components/ShoplyHeader'
import { useShoply } from '../ShoplyProvider'

export function CheckoutPage() {
  const { items, coupon, user } = useShoply()
  const [confirmed, setConfirmed] = useState(false)

  function submitOrder(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setConfirmed(true)
  }

  return (
    <main className="shoply-page">
      <ShoplyHeader />
      <div className="checkout-progress" aria-label="Checkout progress">
        <span className="complete">Bag</span><i /><span className="active">Details</span><i /><span>Confirmation</span>
      </div>
      {items.length === 0 ? (
        <section className="shoply-empty">
          <h1>Your bag is ready for something useful.</h1>
          <Link className="shoply-button inline-button" to="/shoply/product/everyday-pack">Return to product</Link>
        </section>
      ) : confirmed ? (
        <section className="confirmation-card" role="status">
          <p className="product-category">ORDER CONFIRMED</p>
          <h1>Thanks, {user.name}.</h1>
          <p>Your order is confirmed and will ship within two business days.</p>
          <Link to="/shoply/product/everyday-pack">Continue shopping</Link>
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
            <button className="shoply-button shoply-confirm-button" type="submit">Confirm order</button>
            <p className="secure-note">Your payment details are encrypted.</p>
          </aside>
        </form>
      )}
    </main>
  )
}
