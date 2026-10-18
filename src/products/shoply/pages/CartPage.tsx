import { useState } from 'react'

import { OrderSummaryCard, formatMoney } from '../components/OrderSummaryCard'
import { ShoplyHeader } from '../components/ShoplyHeader'
import { evaluateCoupon } from '../domain/rules'
import { ProductLink } from '../ProductNavigation'
import { useShoply } from '../ShoplyProvider'
import { useProductTelemetry } from '../ProductTelemetry'

export function CartPage() {
  const { items, coupon, setCoupon, setQuantity, removeFromCart, user } = useShoply()
  const recordInteraction = useProductTelemetry()
  const [couponInput, setCouponInput] = useState(coupon)
  const couponResult = evaluateCoupon(
    items.reduce((sum, item) => sum + item.product.price * item.quantity, 0),
    coupon,
    user.tier,
  )

  return (
    <main className="shoply-page">
      <ShoplyHeader />
      <section className="cart-heading">
        <p>YOUR SELECTION</p>
        <h1>Shopping bag</h1>
      </section>
      {items.length === 0 ? (
        <section className="shoply-empty">
          <h2>Your bag is empty.</h2>
          <p>Thoughtful essentials are waiting.</p>
          <ProductLink className="shoply-button inline-button" to="/shoply/product/everyday-pack">Explore the collection</ProductLink>
        </section>
      ) : (
        <div className="cart-layout">
          <section className="cart-items" aria-label="Cart items">
            {items.map((item) => (
              <article className="cart-item" key={item.productId}>
                <div className="cart-thumbnail"><span /></div>
                <div className="cart-item-copy">
                  <p>{item.product.category}</p>
                  <h2>{item.product.name}</h2>
                  <button type="button" onClick={() => {
                    removeFromCart(item.productId)
                    recordInteraction({ type: 'REMOVE_FROM_CART', target: item.productId })
                  }}>Remove</button>
                </div>
                <label
                  data-evidence-target="cart.quantity"
                  data-evidence-label="Quantity"
                  data-evidence-value={String(item.quantity)}
                >
                  Qty
                  <select
                    aria-label={`Quantity for ${item.product.name}`}
                    value={item.quantity}
                    onChange={(event) => {
                      const quantity = Number(event.target.value)
                      setQuantity(item.productId, quantity)
                      recordInteraction({
                        type: 'CHANGE_QUANTITY',
                        target: item.productId,
                        payload: { quantity },
                      })
                    }}
                  >
                    {[1, 2, 3, 4].map((quantity) => <option key={quantity}>{quantity}</option>)}
                  </select>
                </label>
                <strong data-evidence-target="cart.lineTotal" data-evidence-label="Line total">{formatMoney(item.product.price * item.quantity)}</strong>
              </article>
            ))}
            <form
              className="coupon-form"
              onSubmit={(event) => {
                event.preventDefault()
                const code = couponInput.trim().toUpperCase()
                setCoupon(code)
                recordInteraction({ type: 'APPLY_COUPON', payload: { code } })
              }}
            >
              <label htmlFor="coupon">Coupon code</label>
              <div><input id="coupon" value={couponInput} onChange={(event) => setCouponInput(event.target.value)} placeholder="SAVE10" /><button type="submit">Apply</button></div>
              {coupon && <p className={couponResult.valid ? 'coupon-valid' : 'coupon-error'} data-evidence-target="cart.couponMessage" data-evidence-label="Coupon message" role="status">{couponResult.message}</p>}
            </form>
          </section>
          <aside>
            <OrderSummaryCard items={items} coupon={coupon} tier={user.tier} />
            <ProductLink className="shoply-button inline-button" to="/shoply/checkout">Continue to checkout</ProductLink>
            <p className="secure-note">Secure checkout · 30-day returns</p>
          </aside>
        </div>
      )}
    </main>
  )
}
