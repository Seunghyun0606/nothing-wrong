import type { BugReport, Evidence } from '../../game/domain/schemas'
import { resolveMutation } from '../../game/mutations/resolveMutation'
import { reviewBugReport } from '../../game/reporting/reviewBugReport'
import { T02_SCENARIO } from './t02'

const cartRuntime = {
  test: {
    account: 'BASIC' as const,
    viewport: 'DESKTOP' as const,
    locale: 'en-US',
    currentPath: '/shoply/cart',
  },
  productState: { cart: { quantity: 2 }, coupon: '' },
}

describe('T02 Scenario', () => {
  it('contains the validated data defect contract and reward', () => {
    expect(T02_SCENARIO.ticket.id).toBe('T02')
    expect(T02_SCENARIO.expectedBugs[0]).toMatchObject({
      type: 'DATA',
      target: 'cart.subtotal',
      severity: 'MEDIUM',
      expected: 'Subtotal should be $60.00 for two $30.00 items',
      actual: 'Subtotal is displayed as $50.00',
    })
    expect(T02_SCENARIO.progression).toMatchObject({ xp: 100, reputationDelta: 2 })
  })

  it('changes only the canonical cart quantity-two state', () => {
    expect(
      resolveMutation('cart.subtotal', 60, cartRuntime, T02_SCENARIO.mutations),
    ).toBe(50)
    expect(
      resolveMutation(
        'cart.subtotal',
        30,
        { ...cartRuntime, productState: { cart: { quantity: 1 }, coupon: '' } },
        T02_SCENARIO.mutations,
      ),
    ).toBe(30)
    expect(
      resolveMutation(
        'cart.subtotal',
        60,
        { ...cartRuntime, test: { ...cartRuntime.test, currentPath: '/shoply/checkout' } },
        T02_SCENARIO.mutations,
      ),
    ).toBe(60)
    expect(resolveMutation('cart.subtotal', 60, cartRuntime, [])).toBe(60)
  })

  it('awards a deterministic valid review only with the quantity-two cart evidence', () => {
    const evidence: Evidence = {
      id: 'EVIDENCE-T02',
      ticketId: 'T02',
      type: 'SCREENSHOT',
      preview: 'Shoply cart',
      capturedAt: 2,
      context: cartRuntime.test,
      snapshot: {
        controls: [
          { target: 'cart.lineTotal', label: 'Line total', value: '$60.00' },
          { target: 'cart.subtotal', label: 'Subtotal', value: '$50.00' },
          { target: 'cart.total', label: 'Total', value: '$50.00' },
        ],
        productState: cartRuntime.productState,
      },
    }
    const report: BugReport = {
      id: 'REPORT-T02',
      ticketId: 'T02',
      kind: 'BUG',
      title: 'Subtotal is incorrect',
      reproductionSteps: [
        { id: 'STEP-1', order: 0, action: 'ADD_TO_CART' },
        { id: 'STEP-2', order: 1, action: 'OPEN_CART' },
        { id: 'STEP-3', order: 2, action: 'CHANGE_QUANTITY', payload: { quantity: 2 } },
      ],
      requirementId: 'REQ-T02-01',
      observation: {
        evidenceId: evidence.id,
        target: 'cart.subtotal',
        label: 'Subtotal',
        value: '$50.00',
      },
      expected: 'The cart subtotal equals product price multiplied by quantity.',
      actual: 'Subtotal: $50.00',
      severity: 'MEDIUM',
      evidenceIds: [evidence.id],
      submittedAt: 3,
    }

    expect(reviewBugReport(report, T02_SCENARIO, [evidence])).toMatchObject({
      valid: true,
      matchedBugId: 'BUG-T02-001',
      totalScore: 100,
      xp: 100,
      reputationDelta: 2,
    })

    const wrongQuantityEvidence = {
      ...evidence,
      snapshot: {
        ...evidence.snapshot,
        productState: { cart: { quantity: 1 }, coupon: '' },
      },
    }
    expect(
      reviewBugReport(report, T02_SCENARIO, [wrongQuantityEvidence]),
    ).toMatchObject({ valid: false })
  })

  it('does not reward picking a correct figure or the wrong requirement', () => {
    const evidence: Evidence = {
      id: 'EVIDENCE-T02',
      ticketId: 'T02',
      type: 'SCREENSHOT',
      preview: 'Shoply cart',
      capturedAt: 2,
      context: cartRuntime.test,
      snapshot: {
        controls: [
          { target: 'cart.lineTotal', label: 'Line total', value: '$60.00' },
          { target: 'cart.subtotal', label: 'Subtotal', value: '$50.00' },
        ],
        productState: cartRuntime.productState,
      },
    }
    const base: BugReport = {
      id: 'REPORT-T02',
      ticketId: 'T02',
      kind: 'BUG',
      title: 'Subtotal is incorrect',
      reproductionSteps: [
        { id: 'STEP-1', order: 0, action: 'ADD_TO_CART' },
        { id: 'STEP-2', order: 1, action: 'OPEN_CART' },
      ],
      requirementId: 'REQ-T02-01',
      observation: { evidenceId: evidence.id, target: 'cart.lineTotal', label: 'Line total', value: '$60.00' },
      expected: 'The cart subtotal equals product price multiplied by quantity.',
      actual: 'Line total: $60.00',
      severity: 'MEDIUM',
      evidenceIds: [evidence.id],
      submittedAt: 3,
    }

    const correctFigure = reviewBugReport(base, T02_SCENARIO, [evidence])
    expect(correctFigure).toMatchObject({ valid: false, scores: { detection: 0 } })
    expect(correctFigure.feedback[0]).toMatch(/does not show the problem/)

    const wrongRequirement = reviewBugReport(
      {
        ...base,
        requirementId: 'REQ-T02-02',
        observation: { evidenceId: evidence.id, target: 'cart.subtotal', label: 'Subtotal', value: '$50.00' },
      },
      T02_SCENARIO,
      [evidence],
    )
    expect(wrongRequirement).toMatchObject({ valid: false, scores: { detection: 0 } })
    expect(wrongRequirement.feedback[0]).toMatch(/not the one it breaks/)
  })

  it('names missing reproduction actions and rejects NO ISSUE FOUND', () => {
    const evidence: Evidence = {
      id: 'EVIDENCE-T02',
      ticketId: 'T02',
      type: 'SCREENSHOT',
      preview: 'Shoply cart',
      capturedAt: 2,
      context: cartRuntime.test,
      snapshot: {
        controls: [{ target: 'cart.subtotal', label: 'Subtotal', value: '$50.00' }],
        productState: cartRuntime.productState,
      },
    }
    const report: BugReport = {
      id: 'REPORT-T02',
      ticketId: 'T02',
      kind: 'BUG',
      title: 'Subtotal is incorrect',
      reproductionSteps: [{ id: 'STEP-1', order: 0, action: 'ADD_TO_CART' }],
      requirementId: 'REQ-T02-01',
      observation: { evidenceId: evidence.id, target: 'cart.subtotal', label: 'Subtotal', value: '$50.00' },
      expected: 'The cart subtotal equals product price multiplied by quantity.',
      actual: 'Subtotal: $50.00',
      severity: 'MEDIUM',
      evidenceIds: [evidence.id],
      submittedAt: 3,
    }

    const missingStep = reviewBugReport(report, T02_SCENARIO, [evidence])
    expect(missingStep).toMatchObject({ valid: false, scores: { reproduction: 0 } })
    expect(missingStep.feedback[1]).toBe('Your steps skip: open the bag.')

    expect(
      reviewBugReport(
        { ...report, kind: 'NO_ISSUE', requirementId: undefined, observation: undefined },
        T02_SCENARIO,
        [evidence],
      ),
    ).toMatchObject({ valid: false, totalScore: 0, reputationDelta: -2 })
  })
})
