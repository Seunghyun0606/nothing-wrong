import { useState } from 'react'

import { ShoplyHeader } from '../components/ShoplyHeader'
import { getShoplyProduct } from '../domain/catalog'
import { formatMoney } from '../components/OrderSummaryCard'
import { ProductLink } from '../ProductNavigation'
import { useShoply } from '../ShoplyProvider'
import { useProductTelemetry } from '../ProductTelemetry'

interface ProductPageProps {
  productId: string
}

export function ProductPage({ productId }: ProductPageProps) {
  const product = getShoplyProduct(productId)
  const { addToCart } = useShoply()
  const recordInteraction = useProductTelemetry()
  const [added, setAdded] = useState(false)

  if (!product) {
    return <main className="shoply-page"><ShoplyHeader /><p>Product not found.</p></main>
  }

  const activeProduct = product

  function handleAddToCart() {
    addToCart(activeProduct.id)
    recordInteraction({ type: 'ADD_TO_CART', target: activeProduct.id })
    setAdded(true)
  }

  return (
    <main className="shoply-page">
      <ShoplyHeader />
      <section className="product-layout">
        <div className={`product-art product-art-${activeProduct.accent}`} aria-label="Everyday Carry Pack product image">
          <span className="pack-shadow" />
          <span className="pack-body"><i /><b /></span>
          <p>18L / RECYCLED SHELL</p>
        </div>
        <div className="product-copy">
          <p className="product-category">{activeProduct.category}</p>
          <h1>{activeProduct.name}</h1>
          <p className="product-price">{formatMoney(activeProduct.price)}</p>
          <p className="product-description">{activeProduct.description}</p>
          <ul className="product-features">
            <li>Fits up to 15-inch laptops</li>
            <li>Water-resistant finish</li>
            <li>Lifetime repair guarantee</li>
          </ul>
          <button className="shoply-button" type="button" onClick={handleAddToCart}>
            Add to bag
          </button>
          {added && <p className="added-message" role="status">Added to bag. <ProductLink to="/shoply/cart">View bag</ProductLink></p>}
          <p className="stock-note">In stock · Ships in 1–2 business days</p>
        </div>
      </section>
    </main>
  )
}
