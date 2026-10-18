import type { BugReport, Evidence } from '../../game/domain/schemas'
import { resolveMutation, type MutationRuntimeContext } from '../../game/mutations/resolveMutation'
import { reviewBugReport } from '../../game/reporting/reviewBugReport'
import { calculateOrderSummary } from '../../products/shoply/domain/rules'
import { SHOPLY_PRODUCTS } from '../../products/shoply/domain/catalog'
import { T04_SCENARIO } from './t04'

const product = SHOPLY_PRODUCTS[0]
if (!product) throw new Error('Shoply test product is missing')

function context(account: 'BASIC' | 'GOLD', quantity: number): MutationRuntimeContext {
  return {
    test: {
      account,
      viewport: 'DESKTOP',
      locale: 'en-US',
      currentPath: '/shoply/cart',
    },
    productState: { cart: { quantity }, coupon: 'SAVE20' },
  }
}

describe('T04 Scenario', () => {
  it('validates the conditional defect and account-switch policy', () => {
    expect(T04_SCENARIO.ticket.id).toBe('T04')
    expect(T04_SCENARIO.expectedBugs[0]).toMatchObject({
      type: 'CONDITIONAL',
      target: 'cart.discount',
      severity: 'MEDIUM',
    })
    expect(T04_SCENARIO.accountSwitchPolicy).toEqual({ resetProductState: false })
    expect(T04_SCENARIO.progression).toMatchObject({ xp: 100, reputationDelta: 2 })
  })

  it('applies ten percent only to Gold SAVE20 carts with at least three items', () => {
    const normalThree = calculateOrderSummary(
      [{ productId: product.id, product, quantity: 3 }],
      'SAVE20',
      'GOLD',
    )
    expect(normalThree.discount).toBe(18)
    expect(resolveMutation('cart.discountRate', 0.2, context('GOLD', 3), T04_SCENARIO.mutations)).toBe(0.1)
    expect(resolveMutation('cart.discountRate', 0.2, context('GOLD', 4), T04_SCENARIO.mutations)).toBe(0.1)

    const normalOne = calculateOrderSummary(
      [{ productId: product.id, product, quantity: 1 }],
      'SAVE20',
      'GOLD',
    )
    expect(normalOne.discount).toBe(6)
    expect(resolveMutation('cart.discountRate', 0.2, context('GOLD', 1), T04_SCENARIO.mutations)).toBe(0.2)

    const basic = calculateOrderSummary(
      [{ productId: product.id, product, quantity: 3 }],
      'SAVE20',
      'BASIC',
    )
    expect(basic.valid).toBe(false)
    expect(basic.discount).toBe(0)
    expect(resolveMutation('cart.discountRate', 0, context('BASIC', 3), T04_SCENARIO.mutations)).toBe(0)
    expect(resolveMutation('cart.discountRate', 0.2, context('GOLD', 3), [])).toBe(0.2)
  })

  it('requires Gold, coupon, quantity, path, and discount Evidence for a valid Review', () => {
    const evidence: Evidence = {
      id: 'EVIDENCE-T04',
      ticketId: 'T04',
      type: 'SCREENSHOT',
      preview: 'Shoply cart discount',
      capturedAt: 2,
      context: context('GOLD', 3).test,
      snapshot: {
        controls: [{ target: 'cart.discount', label: 'Discount', value: '−$9.00' }],
        productState: context('GOLD', 3).productState,
      },
    }
    const report: BugReport = {
      id: 'REPORT-T04',
      ticketId: 'T04',
      kind: 'BUG',
      title: 'Gold SAVE20 discount is halved',
      reproductionSteps: [
        { id: 'STEP-1', order: 0, action: 'OPEN_CART', target: '/shoply/cart' },
        { id: 'STEP-2', order: 1, action: 'CHANGE_ACCOUNT', target: 'GOLD' },
        { id: 'STEP-3', order: 2, action: 'APPLY_COUPON', payload: { code: 'SAVE20' } },
        { id: 'STEP-4', order: 3, action: 'CHANGE_QUANTITY', payload: { quantity: 3 } },
      ],
      requirementId: 'REQ-T04-02',
      observation: {
        evidenceId: evidence.id,
        target: 'cart.discount',
        label: 'Discount',
        value: '−$9.00',
      },
      expected: 'Eligible SAVE20 orders receive a 20% discount at every quantity.',
      actual: 'Discount: −$9.00',
      severity: 'MEDIUM',
      evidenceIds: [evidence.id],
      submittedAt: 3,
    }

    expect(reviewBugReport(report, T04_SCENARIO, [evidence])).toMatchObject({
      valid: true,
      matchedBugId: 'BUG-T04-001',
      totalScore: 100,
      xp: 100,
    })
    for (const changed of [
      { ...evidence, context: { ...evidence.context, account: 'BASIC' as const } },
      { ...evidence, snapshot: { ...evidence.snapshot, productState: context('GOLD', 1).productState } },
      { ...evidence, snapshot: { ...evidence.snapshot, productState: { cart: { quantity: 3 }, coupon: 'SAVE10' } } },
      { ...evidence, context: { ...evidence.context, currentPath: '/shoply/checkout' } },
    ]) {
      expect(reviewBugReport(report, T04_SCENARIO, [changed]).valid).toBe(false)
    }
  })
})
