import { ShoplyHeader } from '../components/ShoplyHeader'
import { ProductLink } from '../ProductNavigation'
import { useProductTelemetry } from '../ProductTelemetry'
import { useShoply } from '../ShoplyProvider'

interface CancelOrderPageProps {
  orderId: string
}

export function CancelOrderPage({ orderId }: CancelOrderPageProps) {
  const { orders, cancelOrder } = useShoply()
  const recordInteraction = useProductTelemetry()
  const order = orders.find((candidate) => candidate.id === orderId)

  if (!order) {
    return (
      <main className="shoply-page">
        <ShoplyHeader />
        <section className="shoply-empty"><h1>Order not found.</h1></section>
      </main>
    )
  }

  return (
    <main className="shoply-page">
      <ShoplyHeader />
      <section
        className="order-flow-card"
        data-evidence-target="orders.cancelFlow"
        data-evidence-label="Screen shown"
        data-evidence-value={order.status === 'PROCESSING' ? 'Cancel your order' : 'Order cancelled'}
      >
        <p className="order-flow-kicker">ORDER {order.id.replace('order-', '#')}</p>
        {order.status === 'PROCESSING' ? (
          <>
            <h1>Cancel your order</h1>
            <p>Select a reason below. We will stop fulfillment and return the payment to your original method.</p>
            <fieldset>
              <legend>Why are you cancelling?</legend>
              <label><input defaultChecked name="reason" type="radio" /> Ordered by mistake</label>
              <label><input name="reason" type="radio" /> Need to change the delivery address</label>
              <label><input name="reason" type="radio" /> Found another product</label>
            </fieldset>
            <button
              className="shoply-button"
              type="button"
              onClick={() => {
                cancelOrder(order.id)
                recordInteraction({ type: 'CONFIRM_CANCELLATION', target: order.id })
              }}
            >
              Confirm cancellation
            </button>
            <ProductLink to={`/shoply/orders/${order.id}`}>Keep this order</ProductLink>
          </>
        ) : (
          <>
            <h1>Order cancelled</h1>
            <p>Fulfillment has stopped. Your refund will return to the original payment method.</p>
            <ProductLink to="/shoply/orders">Return to orders</ProductLink>
          </>
        )}
      </section>
    </main>
  )
}
