import { useMutationValue } from '../../../game/mutations/MutationRuntimeProvider'
import { calculateOrderSummary } from '../domain/rules'
import type { PricedCartItem, ShoplyTier } from '../domain/types'

interface OrderSummaryCardProps {
  items: readonly PricedCartItem[]
  coupon: string
  tier: ShoplyTier
}

export function formatMoney(value: number): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(value)
}

export function OrderSummaryCard({ items, coupon, tier }: OrderSummaryCardProps) {
  const summary = calculateOrderSummary(items, coupon, tier)
  const displayedSubtotal = useMutationValue('cart.subtotal', summary.subtotal)
  const normalDiscountRate = summary.subtotal === 0
    ? 0
    : summary.discount / summary.subtotal
  const displayedDiscountRate = useMutationValue('cart.discountRate', normalDiscountRate)
  const displayedDiscount = Math.round(summary.subtotal * displayedDiscountRate * 100) / 100
  const displayedTotal = Math.round(
    (summary.subtotal - displayedDiscount + summary.shipping) * 100,
  ) / 100

  return (
    <section className="order-summary" aria-labelledby="order-summary-heading">
      <h2 id="order-summary-heading">Order summary</h2>
      <dl>
        <div>
          <dt>Subtotal</dt>
          <dd data-evidence-target="cart.subtotal">{formatMoney(displayedSubtotal)}</dd>
        </div>
        {summary.discount > 0 && (
          <div className="discount-row"><dt>Discount</dt><dd data-evidence-target="cart.discount">−{formatMoney(displayedDiscount)}</dd></div>
        )}
        <div><dt>Shipping</dt><dd>{summary.shipping === 0 ? 'Free' : formatMoney(summary.shipping)}</dd></div>
        <div className="summary-total"><dt>Total</dt><dd>{formatMoney(displayedTotal)}</dd></div>
      </dl>
    </section>
  )
}
