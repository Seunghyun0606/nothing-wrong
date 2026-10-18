import type { BugReport, Evidence, ReportStep } from '../domain/schemas'
import { T01_SCENARIO } from '../../scenarios/shoply/t01'
import { NOISE_PENALTY, reviewBugReport, STEP_NOISE_ALLOWANCE } from './reviewBugReport'

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
  snapshot: {
    controls: [
      { target: 'cart.total', label: 'Total', value: '$35.00' },
      { target: 'checkout.confirmButton', label: 'Confirm order button', value: 'Secondary action style' },
    ],
  },
}

const report: BugReport = {
  id: 'REPORT-T01',
  ticketId: 'T01',
  kind: 'BUG',
  title: 'Checkout action uses the wrong style',
  reproductionSteps: [
    { id: 'STEP-1', order: 0, action: 'ADD_TO_CART' },
    { id: 'STEP-2', order: 1, action: 'OPEN_CHECKOUT' },
  ],
  requirementId: 'REQ-T01-02',
  observation: {
    evidenceId: 'EVIDENCE-T01',
    target: 'checkout.confirmButton',
    label: 'Confirm order button',
    value: 'Secondary action style',
  },
  expected: 'The final confirmation control is presented as the primary action.',
  actual: 'Confirm order button: Secondary action style',
  severity: 'LOW',
  evidenceIds: ['EVIDENCE-T01'],
  submittedAt: 2,
}

function steps(count: number): ReportStep[] {
  return Array.from({ length: count }, (_, order) => ({
    id: `STEP-${order}`,
    order,
    action: order === 0 ? 'ADD_TO_CART' : order === 1 ? 'OPEN_CHECKOUT' : 'RELOAD_PAGE',
  }))
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

  it('does not award a Report that points at an observation without the defect', () => {
    const result = reviewBugReport(
      {
        ...report,
        observation: { evidenceId: 'EVIDENCE-T01', target: 'cart.total', label: 'Total', value: '$35.00' },
      },
      T01_SCENARIO,
      [evidence],
    )

    expect(result).toMatchObject({ valid: false, xp: 0, reputationDelta: -2 })
    expect(result.scores.detection).toBe(0)
  })

  it('does not award unrelated Evidence', () => {
    const result = reviewBugReport(report, T01_SCENARIO, [
      { ...evidence, snapshot: { visibleTargets: ['cart.quantity'] } },
    ])

    expect(result).toMatchObject({ valid: false, xp: 0, reputationDelta: -2 })
    expect(result.totalScore).toBeLessThan(100)
  })

  it('keeps a noisy Report valid but deducts a few points', () => {
    const noisy = reviewBugReport(
      { ...report, reproductionSteps: steps(2 + STEP_NOISE_ALLOWANCE + 1) },
      T01_SCENARIO,
      [evidence],
    )
    expect(noisy.valid).toBe(true)
    expect(noisy.scores.reproduction).toBe(25 - NOISE_PENALTY)
    expect(noisy.feedback[1]).toMatch(/Keep only the actions that matter/)

    const unrelated = (id: string): Evidence => ({
      ...evidence,
      id,
      context: { ...evidence.context, currentPath: '/shoply/cart' },
      snapshot: { controls: [{ target: 'cart.subtotal', label: 'Subtotal', value: '$30.00' }] },
    })
    const cluttered = reviewBugReport(
      { ...report, evidenceIds: ['EVIDENCE-T01', 'E-2', 'E-3'] },
      T01_SCENARIO,
      [evidence, unrelated('E-2'), unrelated('E-3')],
    )
    expect(cluttered.valid).toBe(true)
    expect(cluttered.scores.evidence).toBe(20 - NOISE_PENALTY)
  })

  it('rejects a missed defect closed as NO ISSUE FOUND and accepts it when nothing is wrong', () => {
    const noIssue: BugReport = {
      ...report,
      kind: 'NO_ISSUE',
      requirementId: undefined,
      observation: undefined,
      severity: undefined,
    }
    expect(reviewBugReport(noIssue, T01_SCENARIO, [evidence])).toMatchObject({
      valid: false,
      reputationDelta: -2,
      xp: 0,
    })

    const cleanScenario = { ...T01_SCENARIO, expectedBugs: [], mutations: [] }
    expect(reviewBugReport(noIssue, cleanScenario, [evidence])).toMatchObject({
      valid: true,
      totalScore: 100,
      reputationDelta: 2,
      xp: 100,
    })
    expect(reviewBugReport(report, cleanScenario, [evidence])).toMatchObject({
      valid: false,
      reputationDelta: -2,
    })
  })
})
