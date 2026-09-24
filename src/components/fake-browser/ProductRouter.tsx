import { CartPage } from '../../products/shoply/pages/CartPage'
import { CheckoutPage } from '../../products/shoply/pages/CheckoutPage'
import { ProductPage } from '../../products/shoply/pages/ProductPage'

interface ProductRouterProps {
  path: string
}

export function ProductRouter({ path }: ProductRouterProps) {
  const normalizedPath = path.split(/[?#]/)[0]?.replace(/\/$/, '') ?? path
  const productMatch = normalizedPath.match(/^\/shoply\/product\/([^/]+)$/)

  if (productMatch?.[1]) {
    return <ProductPage productId={decodeURIComponent(productMatch[1])} />
  }

  if (normalizedPath === '/shoply/cart') {
    return <CartPage />
  }

  if (normalizedPath === '/shoply/checkout') {
    return <CheckoutPage />
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
