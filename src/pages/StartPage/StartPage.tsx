import { Link } from 'react-router-dom'

export function StartPage() {
  return (
    <main className="start-page">
      <div className="start-grid" aria-hidden="true" />
      <section className="start-content" aria-labelledby="start-title">
        <p className="kicker">Quality Operations Simulator</p>
        <h1 id="start-title">NOTHING WRONG</h1>
        <p className="start-tagline">
          Read the request. Test the product. Prove what happened.
        </p>
        <Link className="button button-primary button-large" to="/login">
          Start work <span aria-hidden="true">→</span>
        </Link>
      </section>
      <p className="build-mark">BUILD 0.1 / M1</p>
    </main>
  )
}
