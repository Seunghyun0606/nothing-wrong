import { ProductLink } from '../ProductNavigation'
import { useShoply } from '../ShoplyProvider'

export function ShoplyHeader() {
  const { itemCount, user } = useShoply()

  return (
    <header className="shoply-header">
      <ProductLink className="shoply-logo" to="/shoply/product/everyday-pack">
        shoply<span>.</span>
      </ProductLink>
      <nav aria-label="Shoply navigation">
        <ProductLink to="/shoply/product/everyday-pack">Shop</ProductLink>
      </nav>
      <div className="shoply-actions">
        <span className="shoply-account">{user.name}</span>
        <ProductLink className="orders-link" to="/shoply/orders">Orders</ProductLink>
        <ProductLink className="cart-link" to="/shoply/cart" aria-label={`Cart, ${itemCount} items`}>
          Bag <span>{itemCount}</span>
        </ProductLink>
      </div>
    </header>
  )
}
