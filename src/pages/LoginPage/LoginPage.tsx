import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'

export function LoginPage() {
  const navigate = useNavigate()
  const [employeeId, setEmployeeId] = useState('qa-0142')
  const [accessCode, setAccessCode] = useState('first-shift')

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    navigate('/dashboard')
  }

  return (
    <main className="auth-page">
      <section className="auth-brand" aria-labelledby="login-heading">
        <p className="kicker">Nothing Wrong / Employee Access</p>
        <h1 id="login-heading">Your shift starts here.</h1>
        <p>
          Investigate product behavior, preserve evidence, and make the call only when
          the facts support it.
        </p>
      </section>
      <form className="login-card" onSubmit={handleSubmit}>
        <div className="login-card-heading">
          <span className="status-dot" aria-hidden="true" />
          <div>
            <p>Secure workstation</p>
            <h2>Company login</h2>
          </div>
        </div>
        <label>
          Employee ID
          <input
            autoComplete="username"
            value={employeeId}
            onChange={(event) => setEmployeeId(event.target.value)}
            required
          />
        </label>
        <label>
          Access code
          <input
            autoComplete="current-password"
            type="password"
            value={accessCode}
            onChange={(event) => setAccessCode(event.target.value)}
            required
          />
        </label>
        <button className="button button-primary" type="submit">
          Enter workspace
        </button>
        <p className="form-note">Training environment · Local session</p>
      </form>
    </main>
  )
}
