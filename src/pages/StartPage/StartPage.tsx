import { useState } from 'react'
import { Link } from 'react-router-dom'

import { useGameSession } from '../../game/session/GameSessionProvider'
import { useWorkspaceSession } from '../../game/session/WorkspaceSessionProvider'

export function StartPage() {
  const { state, recoveredFromUnreadableSave, resetProgress } = useGameSession()
  const workspace = useWorkspaceSession()
  const [confirmingReset, setConfirmingReset] = useState(false)
  const [resetDone, setResetDone] = useState(false)
  const hasProgress =
    state.reportHistory.length > 0 ||
    Object.values(state.tickets).some((ticket) => ticket.status !== 'NEW')

  function reset() {
    resetProgress()
    workspace.reset()
    setConfirmingReset(false)
    setResetDone(true)
  }

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
          {hasProgress ? 'Continue work' : 'Start work'} <span aria-hidden="true">→</span>
        </Link>
        {recoveredFromUnreadableSave && (
          <p className="start-notice" role="status">
            Your previous save could not be read, so a new game was started. The old data was kept as a backup.
          </p>
        )}
        {resetDone && <p className="start-notice" role="status">Progress reset. A new shift begins.</p>}
        {hasProgress && (
          <div className="start-reset">
            {confirmingReset ? (
              <>
                <span>Erase all progress, Evidence, and notes?</span>
                <button className="text-link" type="button" onClick={reset}>Yes, start a new game</button>
                <button className="text-link" type="button" onClick={() => setConfirmingReset(false)}>Cancel</button>
              </>
            ) : (
              <button className="text-link" type="button" onClick={() => setConfirmingReset(true)}>
                New game
              </button>
            )}
          </div>
        )}
      </section>
      <p className="build-mark">BUILD 0.2 / M2</p>
    </main>
  )
}
