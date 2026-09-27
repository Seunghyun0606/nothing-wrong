import { createInitialGameState } from '../domain/gameState'
import type { BugReport, ReviewResult } from '../domain/schemas'
import { deserializeGameState, serializeGameState } from '../../persistence/gameStateStorage'
import { T01_SCENARIO } from '../../scenarios/shoply/t01'
import { T03_SCENARIO } from '../../scenarios/shoply/t03'
import { applyReview } from './applyReview'

const report: BugReport = {
  id: 'REPORT-T01',
  ticketId: 'T01',
  title: 'Wrong CTA style',
  reproductionSteps: [{ id: 'STEP-1', order: 0, action: 'OPEN_CHECKOUT' }],
  expected: 'Primary action style',
  actual: 'Secondary action style',
  severity: 'LOW',
  evidenceIds: ['EVIDENCE-T01'],
  submittedAt: 2,
}

const review: ReviewResult = {
  valid: true,
  matchedBugId: 'BUG-T01-001',
  scores: { detection: 40, reproduction: 25, evidence: 20, severity: 15 },
  totalScore: 100,
  xp: 100,
  reputationDelta: 2,
  feedback: ['Valid report'],
}

describe('applyReview', () => {
  it('resolves T01 and updates progression and histories exactly once', () => {
    const initial = createInitialGameState(['T01'])
    initial.currentTicketId = 'T01'
    initial.tickets.T01 = {
      status: 'TESTING',
      reportIds: [],
      acceptedAt: 1,
    }

    const completed = applyReview(initial, report, review, T01_SCENARIO.progression, 3)
    const repeated = applyReview(completed, report, review, T01_SCENARIO.progression, 4)

    expect(completed.tickets.T01).toMatchObject({
      status: 'RESOLVED',
      reportIds: ['REPORT-T01'],
      reviewedAt: 3,
      resolvedAt: 3,
    })
    expect(completed.profile).toMatchObject({ xp: 100, level: 2, reputation: 102 })
    expect(completed.reportHistory).toHaveLength(1)
    expect(completed.reviewHistory).toHaveLength(1)
    expect(completed.currentTicketId).toBeUndefined()
    expect(repeated).toBe(completed)
  })

  it('preserves the resolved state through SaveFile serialization', () => {
    const initial = createInitialGameState(['T01'])
    initial.tickets.T01 = { status: 'TESTING', reportIds: [], acceptedAt: 1 }
    const completed = applyReview(initial, report, review, T01_SCENARIO.progression, 3)

    expect(deserializeGameState(serializeGameState(completed))).toEqual(completed)
  })

  it('returns an invalid Report to testing without resolving the Ticket', () => {
    const initial = createInitialGameState(['T01'])
    initial.currentTicketId = 'T01'
    initial.tickets.T01 = { status: 'TESTING', reportIds: [], acceptedAt: 1 }

    const reviewed = applyReview(
      initial,
      report,
      { ...review, valid: false, xp: 0, reputationDelta: -2 },
      T01_SCENARIO.progression,
      3,
    )

    expect(reviewed.tickets.T01).toMatchObject({
      status: 'TESTING',
      reportIds: ['REPORT-T01'],
      reviewedAt: 3,
    })
    expect(reviewed.tickets.T01?.resolvedAt).toBeUndefined()
    expect(reviewed.profile).toMatchObject({ xp: 0, reputation: 98 })
    expect(reviewed.currentTicketId).toBe('T01')
    expect(reviewed.unlockedTools).toEqual([])
  })

  it('unlocks the Account Switcher only after a valid T03 Review', () => {
    const initial = createInitialGameState(['T03'])
    initial.tickets.T03 = { status: 'TESTING', reportIds: [], acceptedAt: 1 }
    const t03Report = { ...report, id: 'REPORT-T03', ticketId: 'T03' }

    const invalid = applyReview(
      initial,
      t03Report,
      { ...review, valid: false, xp: 0, reputationDelta: -2 },
      T03_SCENARIO.progression,
      3,
    )
    expect(invalid.unlockedTools).toEqual([])

    const valid = applyReview(initial, t03Report, review, T03_SCENARIO.progression, 3)
    expect(valid.unlockedTools).toEqual(['ACCOUNT_SWITCHER'])
  })
})
