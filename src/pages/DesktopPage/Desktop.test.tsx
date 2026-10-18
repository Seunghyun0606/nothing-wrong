import { fireEvent, render, screen, within } from '@testing-library/react'

import { App } from '../../app/App'
import { createInitialGameState } from '../../game/domain/gameState'
import type { GameState } from '../../game/domain/schemas'
import { loadGameState, saveGameState } from '../../persistence/gameStateStorage'
import { loadWorkspaceState } from '../../persistence/workspaceStorage'
import { TICKET_CATALOG } from '../../scenarios/shoply/tickets'

function renderAt(path: string) {
  window.history.pushState({}, '', path)
  return render(<App />)
}

function freshState(): GameState {
  return createInitialGameState(TICKET_CATALOG.map((ticket) => ticket.id))
}

function desktopIcon(name: string) {
  return within(screen.getByRole('navigation', { name: 'Desktop' })).getByRole('button', { name })
}

function windowNamed(name: string) {
  return screen.getByRole('region', { name })
}

function playT01ToReview(observation: RegExp) {
  fireEvent.click(desktopIcon('Messenger'))
  fireEvent.click(screen.getByRole('button', { name: 'Open T01 in QA Tracker' }))
  fireEvent.click(within(windowNamed('QA Tracker')).getByRole('button', { name: 'Start test' }))
  fireEvent.click(within(windowNamed('Messenger')).getByRole('button', { name: /shoply\.local\/product\/everyday-pack/ }))

  const browser = windowNamed('Browser')
  fireEvent.click(within(browser).getByRole('button', { name: 'Add to bag' }))
  fireEvent.click(within(browser).getByRole('link', { name: 'View bag' }))
  fireEvent.click(within(browser).getByRole('link', { name: 'Continue to checkout' }))
  fireEvent.click(within(browser).getByRole('button', { name: 'Capture' }))

  const tracker = windowNamed('QA Tracker')
  fireEvent.click(within(tracker).getByRole('button', { name: 'Create report' }))
  fireEvent.click(within(tracker).getByRole('radio', { name: /final confirmation control is presented as the primary action/ }))
  fireEvent.click(within(tracker).getByRole('radio', { name: observation }))
  fireEvent.click(within(tracker).getByRole('radio', { name: /^LOW/ }))
  fireEvent.click(within(tracker).getByRole('button', { name: 'Submit for QA Review' }))
}

describe('QA workstation desktop', () => {
  beforeEach(() => {
    window.localStorage.clear()
  })

  it('moves from Start through the lock screen to a desktop with a waiting briefing', () => {
    renderAt('/start')
    fireEvent.click(screen.getByRole('link', { name: /start work/i }))
    expect(screen.getByRole('heading', { name: 'J. PARK' })).toBeInTheDocument()
    fireEvent.click(screen.getByRole('button', { name: 'Sign in' }))

    expect(window.location.pathname).toBe('/desktop')
    expect(screen.getByRole('button', { name: /Messenger, \d+ unread/ })).toBeInTheDocument()
    expect(screen.getByRole('complementary', { name: 'First Ticket tutorial' })).toHaveTextContent(
      'Open Messenger to read your briefing.',
    )

    fireEvent.click(desktopIcon('Messenger'))
    const chat = screen.getByRole('list', { name: 'Team chat' })
    expect(chat).toHaveTextContent('Nothing wrong with this build.')
    expect(within(chat).getByText('Checkout confirmation design review')).toBeInTheDocument()
    expect(
      within(screen.getByRole('navigation', { name: 'Taskbar' })).getByRole('button', { name: 'Messenger' }),
    ).toBeInTheDocument()
    expect(loadGameState()?.story.readCount).toBe(loadGameState()?.story.deliveredCount)
  })

  it('accepts a Ticket in QA Tracker and keeps later Tickets locked', () => {
    saveGameState(freshState())
    renderAt('/desktop')
    fireEvent.click(desktopIcon('Messenger'))
    fireEvent.click(screen.getByRole('button', { name: 'Open T01 in QA Tracker' }))

    const tracker = windowNamed('QA Tracker')
    expect(within(tracker).getByRole('heading', { name: 'Checkout confirmation design review' })).toBeInTheDocument()
    expect(within(tracker).getByRole('region', { name: 'How to play your first Ticket' })).toBeInTheDocument()
    expect(within(tracker).getByRole('button', { name: /T02/ })).toBeDisabled()

    fireEvent.click(within(tracker).getByRole('button', { name: 'Start test' }))
    expect(loadGameState()?.tickets.T01?.status).toBe('TESTING')
    expect(screen.getByRole('complementary', { name: 'First Ticket tutorial' })).toHaveTextContent(
      'Open Shoply in the Browser.',
    )
    expect(windowNamed('Messenger')).toBeInTheDocument()
  })

  it('opens typed addresses, intranet docs, and unknown hosts in the Browser', () => {
    saveGameState(freshState())
    renderAt('/desktop')
    fireEvent.click(desktopIcon('Browser'))
    const browser = windowNamed('Browser')
    const address = within(browser).getByRole('textbox', { name: 'Address' })

    expect(within(browser).getByRole('heading', { name: 'Where to?' })).toBeInTheDocument()
    expect(within(browser).getByRole('button', { name: 'Capture' })).toBeDisabled()

    fireEvent.change(address, { target: { value: 'shoply.com' } })
    fireEvent.submit(address)
    expect(within(browser).getByRole('heading', { name: "This site can't be reached" })).toBeInTheDocument()

    fireEvent.change(address, { target: { value: 'docs.nothingwrong.local/checkout-interaction-specification' } })
    fireEvent.submit(address)
    expect(within(browser).getByText(/Primary action: solid dark fill/)).toBeInTheDocument()

    fireEvent.change(address, { target: { value: 'shoply.local' } })
    fireEvent.submit(address)
    expect(within(browser).getByRole('heading', { name: 'Everyday Carry Pack' })).toBeInTheDocument()
    expect(address).toHaveValue('https://shoply.local/')
    fireEvent.click(within(browser).getByRole('button', { name: 'Go back' }))
    expect(within(browser).getByText(/Primary action: solid dark fill/)).toBeInTheDocument()
  })

  it('plays T01 from briefing link to Review, collects Evidence in QA Notes, and continues the story', () => {
    saveGameState(freshState())
    renderAt('/desktop')
    playT01ToReview(/Confirm order button: Secondary action style/)

    const tracker = windowNamed('QA Tracker')
    expect(within(tracker).getByRole('heading', { name: 'VALID' })).toBeInTheDocument()
    expect(within(tracker).getByText('Level up! You are now Level 2.')).toBeInTheDocument()
    expect(loadWorkspaceState()?.evidence[0]?.context.currentPath).toBe('/shoply/checkout')

    fireEvent.click(desktopIcon('QA Notes'))
    const notes = windowNamed('QA Notes')
    fireEvent.click(within(notes).getByRole('button', { name: /T01\.txt/ }))
    expect(within(notes).getByRole('list', { name: 'Captured values' })).toHaveTextContent(
      'Confirm order button: Secondary action style',
    )
    expect(within(notes).getByRole('region', { name: 'Activity log' })).toHaveTextContent('open checkout')

    fireEvent.click(within(tracker).getByRole('button', { name: 'The team replied · Open Messenger' }))
    const chat = screen.getByRole('list', { name: 'Team chat' })
    expect(chat).toHaveTextContent('release-bot')
    expect(chat).toHaveTextContent('02:14 · release-bot')
    expect(screen.getByRole('complementary', { name: 'Case notes' })).toHaveTextContent(
      'The team is waiting for your answer.',
    )

    const reply = screen.getByRole('group', { name: 'Reply' })
    fireEvent.click(within(reply).getByRole('button', { name: /designer changed the button/ }))
    expect(chat).toHaveTextContent('Look at the author again.')
    expect(within(screen.getByRole('group', { name: 'Reply' })).queryByRole('button', { name: /designer changed/ })).not.toBeInTheDocument()

    fireEvent.click(within(screen.getByRole('group', { name: 'Reply' })).getByRole('button', { name: /automated merge modified it overnight/ }))
    expect(chat).toHaveTextContent('Exactly.')
    expect(chat).toHaveTextContent('charged less than expected')
    expect(screen.getByRole('button', { name: 'Open T02 in QA Tracker' })).toBeInTheDocument()
    expect(loadGameState()).toMatchObject({
      profile: { xp: 100, level: 2, reputation: 102 },
      story: { deductions: { 'DED-T01': { solved: true } } },
    })
  })

  it('lets a failed Report be revised, and shows the Case File in QA Tracker', () => {
    saveGameState(freshState())
    renderAt('/desktop')
    playT01ToReview(/^Total: \$35\.00/)

    const tracker = windowNamed('QA Tracker')
    expect(within(tracker).getByRole('heading', { name: 'INVALID' })).toBeInTheDocument()
    expect(within(tracker).getByText(/does not show the problem/)).toBeInTheDocument()
    fireEvent.click(within(tracker).getByRole('button', { name: 'Back to T01' }))
    fireEvent.click(within(tracker).getByRole('button', { name: 'Create report' }))
    fireEvent.click(within(tracker).getByRole('radio', { name: /final confirmation control/ }))
    fireEvent.click(within(tracker).getByRole('radio', { name: /Confirm order button: Secondary action style/ }))
    fireEvent.click(within(tracker).getByRole('radio', { name: /^LOW/ }))
    fireEvent.click(within(tracker).getByRole('button', { name: 'Submit for QA Review' }))

    expect(within(tracker).getByRole('heading', { name: 'VALID' })).toBeInTheDocument()
    fireEvent.click(within(tracker).getByRole('button', { name: 'Case File' }))
    expect(within(tracker).getByRole('region', { name: 'Chapter 1 · Release Candidate 3' })).toHaveTextContent(
      '02:14 · release-bot',
    )
  })

  it('treats NO ISSUE FOUND on a defective Ticket as a missed bug', () => {
    saveGameState(freshState())
    renderAt('/desktop')
    fireEvent.click(desktopIcon('Messenger'))
    fireEvent.click(screen.getByRole('button', { name: 'Open T01 in QA Tracker' }))
    fireEvent.click(within(windowNamed('QA Tracker')).getByRole('button', { name: 'Start test' }))
    fireEvent.click(desktopIcon('Browser'))
    const browser = windowNamed('Browser')
    fireEvent.change(within(browser).getByRole('textbox', { name: 'Address' }), { target: { value: 'shoply.local' } })
    fireEvent.submit(within(browser).getByRole('textbox', { name: 'Address' }))
    fireEvent.click(within(browser).getByRole('button', { name: 'Capture' }))

    const tracker = windowNamed('QA Tracker')
    fireEvent.click(within(tracker).getByRole('button', { name: 'Create report' }))
    fireEvent.click(within(tracker).getByRole('button', { name: 'Submit NO ISSUE FOUND' }))
    fireEvent.click(within(tracker).getByRole('button', { name: 'Confirm NO ISSUE FOUND' }))

    expect(within(tracker).getByRole('heading', { name: 'INVALID' })).toBeInTheDocument()
    expect(loadGameState()).toMatchObject({
      profile: { reputation: 98 },
      tickets: { T01: { status: 'TESTING' } },
    })
  })

  it('does not replay delivered messages after a reload and redirects old pages to the desktop', () => {
    saveGameState(freshState())
    const first = renderAt('/desktop')
    const delivered = loadGameState()?.story.deliveredCount
    expect(delivered).toBeGreaterThan(0)
    first.unmount()

    renderAt('/dashboard')
    expect(window.location.pathname).toBe('/desktop')
    expect(loadGameState()?.story.deliveredCount).toBe(delivered)
  })

  it('unlocks the Account Switcher in the Browser QA bar after T03', () => {
    const state = freshState()
    for (const id of ['T01', 'T02', 'T03']) {
      state.tickets[id] = { status: 'RESOLVED', reportIds: [], resolvedAt: 1 }
    }
    state.unlockedTools = ['ACCOUNT_SWITCHER']
    state.tickets.T04 = { status: 'TESTING', reportIds: [], acceptedAt: 2 }
    state.currentTicketId = 'T04'
    saveGameState(state)
    renderAt('/desktop')
    fireEvent.click(desktopIcon('Browser'))

    const browser = windowNamed('Browser')
    expect(within(browser).getByRole('group', { name: 'Shoply account' })).toBeInTheDocument()
    expect(within(browser).getByText('QA · T04')).toBeInTheDocument()
  })
})
