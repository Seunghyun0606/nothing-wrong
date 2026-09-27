import { ShoplyHeader } from '../components/ShoplyHeader'
import { formatMoney } from '../components/OrderSummaryCard'
import { getShoplyProduct } from '../domain/catalog'
import { ProductLink } from '../ProductNavigation'
import { useShoply } from '../ShoplyProvider'

export function OrdersPage() {
  const { orders } = useShoply()
  return (
    <main className="shoply-page">
      <ShoplyHeader />
      <section className="cart-heading">
        <p>YOUR ACCOUNT</p>
        <h1>Orders</h1>
      </section>
      <section className="orders-list" aria-label="Order history">
        {orders.map((order) => {
          const product = getShoplyProduct(order.productId)
          return (
            <article className="order-row" key={order.id}>
              <div>
                <span>Order {order.id.replace('order-', '#')}</span>
                <strong>{product?.name ?? 'Shoply item'}</strong>
                <small>Placed {order.placedAt} · Qty {order.quantity}</small>
              </div>
              <span className="order-status">{order.status.toLowerCase()}</span>
              <strong>{formatMoney(order.total)}</strong>
              <ProductLink to={`/shoply/orders/${order.id}`}>View order →</ProductLink>
            </article>
          )
        })}
      </section>
    </main>
  )
}
