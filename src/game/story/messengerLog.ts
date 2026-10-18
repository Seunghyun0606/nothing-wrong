import type {
  Deduction,
  GameState,
  Scenario,
  StoryChapter,
  StoryLink,
} from '../domain/schemas'

export type MessengerEntry =
  | {
      id: string
      kind: 'message'
      from: string
      role: string
      text: string
      links?: readonly StoryLink[]
    }
  | { id: string; kind: 'ticket'; ticketId: string; title: string }
  | { id: string; kind: 'clue'; title: string; text: string }
  | { id: string; kind: 'player'; text: string }
  | { id: string; kind: 'system'; text: string }

export interface MessengerLog {
  entries: MessengerEntry[]
  /** A deduction the team is waiting for the player to answer. */
  pendingDeduction?: Deduction
}

interface BuildMessengerLogOptions {
  scenarios: readonly Scenario[]
  state: GameState
  isTicketUnlocked: (ticketId: string, state: GameState) => boolean
  getChapter: (chapterId: string) => StoryChapter | undefined
}

/**
 * Derives the team chat from Game State. Briefings arrive when a Ticket unlocks,
 * the debrief and deduction after it resolves, and the chat pauses on an unanswered
 * deduction so the story is read in order.
 */
export function buildMessengerLog({
  scenarios,
  state,
  isTicketUnlocked,
  getChapter,
}: BuildMessengerLogOptions): MessengerLog {
  const entries: MessengerEntry[] = []

  for (const scenario of scenarios) {
    const ticket = scenario.ticket
    if (!isTicketUnlocked(ticket.id, state)) break

    const story = scenario.story
    story?.briefing.forEach((message, index) => {
      entries.push({ id: `${scenario.id}:briefing:${index}`, kind: 'message', ...message })
    })
    entries.push({
      id: `${scenario.id}:ticket`,
      kind: 'ticket',
      ticketId: ticket.id,
      title: ticket.title,
    })

    if (state.tickets[ticket.id]?.status !== 'RESOLVED') break
    if (!story) continue

    story.debrief.forEach((message, index) => {
      entries.push({ id: `${scenario.id}:debrief:${index}`, kind: 'message', ...message })
    })
    entries.push({
      id: `${scenario.id}:clue`,
      kind: 'clue',
      title: story.clue.title,
      text: story.clue.text,
    })

    const deduction = story.deduction
    if (!deduction) continue

    entries.push({
      id: `${scenario.id}:deduction`,
      kind: 'message',
      ...deduction.askedBy,
      text: deduction.prompt,
    })
    const progress = state.story.deductions[deduction.id]
    for (const [index, optionId] of (progress?.attempts ?? []).entries()) {
      const option = deduction.options.find((candidate) => candidate.id === optionId)
      if (!option) continue
      entries.push({ id: `${scenario.id}:reply:${index}`, kind: 'player', text: option.text })
      entries.push({
        id: `${scenario.id}:response:${index}`,
        kind: 'message',
        ...deduction.askedBy,
        text: option.response,
      })
    }

    if (!progress?.solved) {
      return { entries, pendingDeduction: deduction }
    }

    const chapter = getChapter(story.chapterId)
    if (chapter && chapter.finaleDeductionId === deduction.id) {
      chapter.epilogue.forEach((message, index) => {
        entries.push({ id: `${chapter.id}:epilogue:${index}`, kind: 'message', ...message })
      })
      entries.push({ id: `${chapter.id}:complete`, kind: 'system', text: `${chapter.title} complete.` })
    }
  }

  return { entries }
}
