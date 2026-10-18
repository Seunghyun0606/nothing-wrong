import { Component, type ErrorInfo, type PropsWithChildren } from 'react'

import { resetGameState } from '../persistence/gameStateStorage'
import { resetWorkspaceState } from '../persistence/workspaceStorage'

interface AppErrorBoundaryState {
  error: Error | null
}

/** Last-resort recovery screen so a broken state never leaves the player on a blank page. */
export class AppErrorBoundary extends Component<PropsWithChildren, AppErrorBoundaryState> {
  state: AppErrorBoundaryState = { error: null }

  static getDerivedStateFromError(error: Error): AppErrorBoundaryState {
    return { error }
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error('Nothing Wrong crashed', error, info.componentStack)
  }

  private restart = () => {
    window.location.assign('/start')
  }

  private resetAndRestart = () => {
    resetGameState()
    resetWorkspaceState()
    window.location.assign('/start')
  }

  render() {
    if (!this.state.error) return this.props.children

    return (
      <main className="start-page">
        <section className="start-content" aria-labelledby="crash-title">
          <p className="kicker">Something went wrong</p>
          <h1 id="crash-title">The workstation needs a restart.</h1>
          <p className="start-tagline">{this.state.error.message}</p>
          <div className="crash-actions">
            <button className="button button-primary" type="button" onClick={this.restart}>
              Restart
            </button>
            <button className="text-link" type="button" onClick={this.resetAndRestart}>
              Reset progress and restart
            </button>
          </div>
        </section>
      </main>
    )
  }
}
