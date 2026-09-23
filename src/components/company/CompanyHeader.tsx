import { Link } from 'react-router-dom'

export function CompanyHeader() {
  return (
    <header className="company-header">
      <Link className="company-wordmark" to="/dashboard" aria-label="Nothing Wrong dashboard">
        NOTHING WRONG<span aria-hidden="true">.</span>
      </Link>
      <p>Quality Operations / Internal</p>
    </header>
  )
}
