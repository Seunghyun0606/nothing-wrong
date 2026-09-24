import type { BugReport, Evidence } from '../domain/schemas'
import { T01_SCENARIO } from '../../scenarios/shoply/t01'
import { reviewBugReport } from './reviewBugReport'

const report: BugReport = {
  id: 'REPORT-T01',
  ticketId: 'T01',
  title: 'Checkout action uses the wrong style',
  reproductionSteps: [
    { id: 'STEP-1', order: 0, action: 'OPEN_PRODUCT' },
    { id: 'STEP-2', order: 1, action: 'OPEN_CHECKOUT' },
  ],
  expected: 'Primary action style',
  actual: 'Secondary action style',
  severity: 'LOW',
  evidenceIds: ['EVIDENCE-T01'],
  submittedAt: 2,
}

const evidence: Evidence = {
  id: 'EVIDENCE-T01',
  ticketId: 'T01',
  type: 'SCREENSHOT',
  preview: 'Checkout',
  capturedAt: 1,
  context: {
    account: 'BASIC',
    viewport: 'DESKTOP',
    locale: 'en-US',
    currentPath: '/shoply/checkout',
  },
  snapshot: { visibleTargets: ['checkout.confirmButton'] },
}

describe('reviewBugReport', () => {
  it('returns the deterministic T01 score and reward without React', () => {
    expect(reviewBugReport(report, T01_SCENARIO, [evidence])).toEqual({
      valid: true,
      matchedBugId: 'BUG-T01-001',
      scores: { detection: 40, reproduction: 25, evidence: 20, severity: 15 },
      totalScore: 100,
      xp: 100,
      reputationDelta: 2,
      feedback: expect.any(Array),
    })
  })

  it('does not award an invalid Report with unrelated Evidence', () => {
    const result = reviewBugReport(
      { ...report, actual: 'Primary action style' },
      T01_SCENARIO,
      [{ ...evidence, snapshot: { visibleTargets: ['cart.quantity'] } }],
    )

    expect(result).toMatchObject({ valid: false, xp: 0, reputationDelta: -2 })
    expect(result.totalScore).toBeLessThan(100)
  })
})
