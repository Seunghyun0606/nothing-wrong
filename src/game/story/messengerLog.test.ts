import { createInitialGameState } from '../domain/gameState'
import type { GameState } from '../domain/schemas'
import {
  getStoryChapter,
  isTicketUnlocked,
  SCENARIO_CATALOG,
  TICKET_CATALOG,
} from '../../scenarios/shoply/tickets'
import { answerDeduction } from './answerDeduction'
import { buildMessengerLog } from './messengerLog'

function build(state: GameState) {
  return buildMessengerLog({
    scenarios: SCENARIO_CATALOG,
    state,
    isTicketUnlocked,
    getChapter: getStoryChapter,
  })
}

function resolve(state: GameState, ticketId: string): GameState {
  return {
    ...state,
    tickets: { ...state.tickets, [ticketId]: { status: 'RESOLVED', reportIds: [], resolvedAt: 1 } },
  }
}

describe('buildMessengerLog', () => {
  it('starts with the T01 briefing and its ticket card only', () => {
    const { entries, pendingDeduction } = build(
      createInitialGameState(TICKET_CATALOG.map((ticket) => ticket.id)),
    )

    expect(entries.at(-1)).toMatchObject({ kind: 'ticket', ticketId: 'T01' })
    expect(entries.filter((entry) => entry.kind === 'ticket')).toHaveLength(1)
    expect(entries[0]).toMatchObject({ kind: 'message', from: 'Maya Kim' })
    expect(pendingDeduction).toBeUndefined()
  })

  it('pauses on the deduction after a resolved Ticket, then continues to the next briefing', () => {
    let state = resolve(createInitialGameState(TICKET_CATALOG.map((ticket) => ticket.id)), 'T01')
    const paused = build(state)
    expect(paused.pendingDeduction?.id).toBe('DED-T01')
    expect(paused.entries.some((entry) => entry.kind === 'clue')).toBe(true)
    expect(paused.entries.some((entry) => entry.kind === 'ticket' && entry.ticketId === 'T02')).toBe(false)

    const deduction = paused.pendingDeduction!
    const wrong = deduction.options.find((option) => !option.correct)!
    const right = deduction.options.find((option) => option.correct)!
    state = answerDeduction(state, deduction, wrong.id)
    const retry = build(state)
    expect(retry.pendingDeduction?.id).toBe('DED-T01')
    expect(retry.entries.at(-2)).toEqual(expect.objectContaining({ kind: 'player', text: wrong.text }))
    expect(retry.entries.at(-1)).toEqual(expect.objectContaining({ text: wrong.response }))

    state = answerDeduction(state, deduction, right.id)
    const continued = build(state)
    expect(continued.pendingDeduction).toBeUndefined()
    expect(continued.entries.at(-1)).toMatchObject({ kind: 'ticket', ticketId: 'T02' })
  })

  it('keeps entry ids stable as the story grows', () => {
    const state = createInitialGameState(TICKET_CATALOG.map((ticket) => ticket.id))
    const first = build(state).entries.map((entry) => entry.id)
    const later = build(resolve(state, 'T01')).entries.map((entry) => entry.id)
    expect(later.slice(0, first.length)).toEqual(first)
  })
})
