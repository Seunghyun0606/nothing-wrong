import { CartPage } from '../../products/shoply/pages/CartPage'
import { CheckoutPage } from '../../products/shoply/pages/CheckoutPage'
import { CancelOrderPage } from '../../products/shoply/pages/CancelOrderPage'
import { OrderDetailPage } from '../../products/shoply/pages/OrderDetailPage'
import { OrdersPage } from '../../products/shoply/pages/OrdersPage'
import { PaymentPage } from '../../products/shoply/pages/PaymentPage'
import { ProductPage } from '../../products/shoply/pages/ProductPage'
import { useLocation } from 'react-router-dom'

interface ProductRouterProps {
  path?: string
}

export function ProductRouter({ path: explicitPath }: ProductRouterProps) {
  const location = useLocation()
  const path = explicitPath ?? location.pathname
  const normalizedPath = path.split(/[?#]/)[0]?.replace(/\/$/, '') ?? path
  const productMatch = normalizedPath.match(/^\/shoply\/product\/([^/]+)$/)
  const cancelOrderMatch = normalizedPath.match(/^\/shoply\/orders\/([^/]+)\/cancel$/)
  const orderMatch = normalizedPath.match(/^\/shoply\/orders\/([^/]+)$/)

  if (productMatch?.[1]) {
    return <ProductPage productId={decodeURIComponent(productMatch[1])} />
  }

  if (normalizedPath === '/shoply/cart') {
    return <CartPage />
  }

  if (normalizedPath === '/shoply/checkout') {
    return <CheckoutPage />
  }

  if (normalizedPath === '/shoply/orders') {
    return <OrdersPage />
  }

  if (cancelOrderMatch?.[1]) {
    return <CancelOrderPage orderId={decodeURIComponent(cancelOrderMatch[1])} />
  }

  if (orderMatch?.[1]) {
    return <OrderDetailPage orderId={decodeURIComponent(orderMatch[1])} />
  }

  if (normalizedPath === '/shoply/payment') {
    return <PaymentPage />
  }

  return (
    <main className="shoply-page">
      <section className="shoply-empty">
        <h1>Page not found.</h1>
        <p>The requested Shoply page does not exist.</p>
      </section>
    </main>
  )
}
