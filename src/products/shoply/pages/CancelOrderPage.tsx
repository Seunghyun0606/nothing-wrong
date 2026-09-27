import { ShoplyHeader } from '../components/ShoplyHeader'
import { getShoplyOrder } from '../domain/orders'
import { ProductLink } from '../ProductNavigation'

interface CancelOrderPageProps {
  orderId: string
}

export function CancelOrderPage({ orderId }: CancelOrderPageProps) {
  const order = getShoplyOrder(orderId)

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
      <section className="order-flow-card" data-evidence-target="orders.cancelFlow">
        <p className="order-flow-kicker">ORDER {order.id.replace('order-', '#')}</p>
        <h1>Cancel your order</h1>
        <p>Select a reason below. We will stop fulfillment and return the payment to your original method.</p>
        <fieldset>
          <legend>Why are you cancelling?</legend>
          <label><input defaultChecked name="reason" type="radio" /> Ordered by mistake</label>
          <label><input name="reason" type="radio" /> Need to change the delivery address</label>
          <label><input name="reason" type="radio" /> Found another product</label>
        </fieldset>
        <button className="shoply-button" type="button">Confirm cancellation</button>
        <ProductLink to={`/shoply/orders/${order.id}`}>Keep this order</ProductLink>
      </section>
    </main>
  )
}
