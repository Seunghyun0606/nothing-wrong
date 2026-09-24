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
        visibleTargets: ['cart.subtotal'],
        productState: cartRuntime.productState,
      },
    }
    const report: BugReport = {
      id: 'REPORT-T02',
      ticketId: 'T02',
      title: 'Subtotal is incorrect',
      reproductionSteps: [
        { id: 'STEP-1', order: 0, action: 'ADD_TO_CART' },
        { id: 'STEP-2', order: 1, action: 'CHANGE_QUANTITY' },
      ],
      expected: 'Subtotal should be $60.00 for two $30.00 items',
      actual: 'Subtotal is displayed as $50.00',
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
})
