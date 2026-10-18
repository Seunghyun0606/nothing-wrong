import { useEffect, useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'

import { useGameSession } from '../../game/session/GameSessionProvider'

export function LoginPage() {
  const navigate = useNavigate()
  const { state } = useGameSession()
  const [accessCode, setAccessCode] = useState('first-shift')
  const [now, setNow] = useState(() => new Date())

  useEffect(() => {
    const timer = window.setInterval(() => setNow(new Date()), 30_000)
    return () => window.clearInterval(timer)
  }, [])

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    navigate('/desktop')
  }

  return (
    <main className="lock-screen">
      <section className="lock-clock" aria-label="Clock">
        <p className="lock-time">
          {new Intl.DateTimeFormat('en-US', { hour: '2-digit', minute: '2-digit' }).format(now)}
        </p>
        <p className="lock-date">
          {new Intl.DateTimeFormat('en-US', { weekday: 'long', month: 'long', day: 'numeric' }).format(now)}
        </p>
      </section>
      <form className="lock-card" onSubmit={handleSubmit}>
        <span className="lock-avatar" aria-hidden="true">JP</span>
        <h1>{state.profile.name}</h1>
        <p>Nothing Wrong · QA workstation 0142</p>
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
        <button className="button button-primary" type="submit">Sign in</button>
        <p className="form-note">Training environment · Local session</p>
      </form>
    </main>
  )
}
