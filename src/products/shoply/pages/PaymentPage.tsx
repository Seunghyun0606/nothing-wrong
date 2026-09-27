import { ShoplyHeader } from '../components/ShoplyHeader'
import { ProductLink } from '../ProductNavigation'

export function PaymentPage() {
  return (
    <main className="shoply-page">
      <ShoplyHeader />
      <section className="payment-card" data-evidence-target="payment.form">
        <p className="order-flow-kicker">SECURE CHECKOUT</p>
        <h1>Payment details</h1>
        <p>Enter a card to continue with this purchase.</p>
        <div className="payment-fields">
          <label>Card number<input aria-label="Card number" placeholder="4242 4242 4242 4242" /></label>
          <label>Name on card<input aria-label="Name on card" placeholder="Jordan Park" /></label>
          <label>Expiry<input aria-label="Expiry" placeholder="MM / YY" /></label>
          <label>Security code<input aria-label="Security code" placeholder="CVC" /></label>
        </div>
        <button className="shoply-button" type="button">Pay now</button>
        <ProductLink to="/shoply/orders">Return to orders</ProductLink>
      </section>
    </main>
  )
}
