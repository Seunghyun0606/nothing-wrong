import { useMutationValue } from '../../../game/mutations/MutationRuntimeProvider'
import { ShoplyHeader } from '../components/ShoplyHeader'
import { formatMoney } from '../components/OrderSummaryCard'
import { getShoplyProduct } from '../domain/catalog'
import { getShoplyOrder } from '../domain/orders'
import { ProductLink } from '../ProductNavigation'
import { useProductTelemetry } from '../ProductTelemetry'

interface OrderDetailPageProps {
  orderId: string
}

export function OrderDetailPage({ orderId }: OrderDetailPageProps) {
  const order = getShoplyOrder(orderId)
  const recordInteraction = useProductTelemetry()
  const normalDestination = `/shoply/orders/${orderId}/cancel`
  const cancelDestination = useMutationValue(
    'orders.cancelAction.destination',
    normalDestination,
  )

  if (!order) {
    return (
      <main className="shoply-page">
        <ShoplyHeader />
        <section className="shoply-empty"><h1>Order not found.</h1></section>
      </main>
    )
  }

  const product = getShoplyProduct(order.productId)

  return (
    <main className="shoply-page">
      <ShoplyHeader />
      <section className="order-detail-heading">
        <ProductLink to="/shoply/orders">← All orders</ProductLink>
        <p>ORDER {order.id.replace('order-', '#')}</p>
        <h1>Order details</h1>
        <span className="order-status">{order.status.toLowerCase()}</span>
      </section>
      <div className="order-detail-layout">
        <section className="order-detail-card">
          <h2>{product?.name ?? 'Shoply item'}</h2>
          <dl>
            <div><dt>Placed</dt><dd>{order.placedAt}</dd></div>
            <div><dt>Quantity</dt><dd>{order.quantity}</dd></div>
            <div><dt>Delivery</dt><dd>Standard shipping</dd></div>
            <div><dt>Total</dt><dd>{formatMoney(order.total)}</dd></div>
          </dl>
        </section>
        <aside className="order-actions-card">
          <h2>Need to make a change?</h2>
          <p>This order is still processing and can be cancelled before shipment.</p>
          <ProductLink
            className="shoply-button inline-button"
            data-evidence-target="orders.cancelAction"
            onClick={() => recordInteraction({
              type: 'CANCEL_ORDER',
              target: order.id,
              payload: { destination: cancelDestination },
            })}
            to={cancelDestination}
          >
            Cancel order
          </ProductLink>
        </aside>
      </div>
    </main>
  )
}
