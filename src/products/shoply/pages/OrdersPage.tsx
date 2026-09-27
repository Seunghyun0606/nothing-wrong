import { ShoplyHeader } from '../components/ShoplyHeader'
import { formatMoney } from '../components/OrderSummaryCard'
import { getShoplyProduct } from '../domain/catalog'
import { SHOPLY_ORDERS } from '../domain/orders'
import { ProductLink } from '../ProductNavigation'

export function OrdersPage() {
  return (
    <main className="shoply-page">
      <ShoplyHeader />
      <section className="cart-heading">
        <p>YOUR ACCOUNT</p>
        <h1>Orders</h1>
      </section>
      <section className="orders-list" aria-label="Order history">
        {SHOPLY_ORDERS.map((order) => {
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
