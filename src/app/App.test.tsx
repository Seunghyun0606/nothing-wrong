import { render, screen } from '@testing-library/react'

import { App } from './App'

describe('App', () => {
  it('renders the foundation route', () => {
    window.history.pushState({}, '', '/start')

    render(<App />)

    expect(
      screen.getByRole('heading', { name: 'Project foundation ready' }),
    ).toBeInTheDocument()
    expect(screen.getByText('M1 · First Playable')).toBeInTheDocument()
  })

  it('redirects unknown routes to the foundation route', async () => {
    window.history.pushState({}, '', '/unknown')

    render(<App />)

    expect(
      await screen.findByRole('heading', { name: 'Project foundation ready' }),
    ).toBeInTheDocument()
    expect(window.location.pathname).toBe('/start')
  })
})
