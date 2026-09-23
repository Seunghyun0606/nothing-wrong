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

  return (
    <section className="order-summary" aria-labelledby="order-summary-heading">
      <h2 id="order-summary-heading">Order summary</h2>
      <dl>
        <div><dt>Subtotal</dt><dd>{formatMoney(summary.subtotal)}</dd></div>
        {summary.discount > 0 && (
          <div className="discount-row"><dt>Discount</dt><dd>−{formatMoney(summary.discount)}</dd></div>
        )}
        <div><dt>Shipping</dt><dd>{summary.shipping === 0 ? 'Free' : formatMoney(summary.shipping)}</dd></div>
        <div className="summary-total"><dt>Total</dt><dd>{formatMoney(summary.total)}</dd></div>
      </dl>
    </section>
  )
}
