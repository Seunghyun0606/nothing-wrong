import { render, screen } from '@testing-library/react'

import { App } from './App'

describe('App', () => {
  beforeEach(() => {
    window.localStorage.clear()
  })

  it('renders the Start route', () => {
    window.history.pushState({}, '', '/start')

    render(<App />)

    expect(screen.getByRole('heading', { name: 'NOTHING WRONG' })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: /start work/i })).toHaveAttribute(
      'href',
      '/login',
    )
  })

  it('redirects unknown routes to Start', async () => {
    window.history.pushState({}, '', '/unknown')

    render(<App />)

    expect(
      await screen.findByRole('heading', { name: 'NOTHING WRONG' }),
    ).toBeInTheDocument()
    expect(window.location.pathname).toBe('/start')
  })
})
