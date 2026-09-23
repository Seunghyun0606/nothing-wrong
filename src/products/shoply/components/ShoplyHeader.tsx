import { Link } from 'react-router-dom'

import { useShoply } from '../ShoplyProvider'

export function ShoplyHeader() {
  const { itemCount, user } = useShoply()

  return (
    <header className="shoply-header">
      <Link className="shoply-logo" to="/shoply/product/everyday-pack">
        shoply<span>.</span>
      </Link>
      <nav aria-label="Shoply navigation">
        <a href="#new">New</a>
        <a href="#essentials">Essentials</a>
        <a href="#stories">Stories</a>
      </nav>
      <div className="shoply-actions">
        <span className="shoply-account">{user.name}</span>
        <Link className="cart-link" to="/shoply/cart" aria-label={`Cart, ${itemCount} items`}>
          Bag <span>{itemCount}</span>
        </Link>
      </div>
    </header>
  )
}
