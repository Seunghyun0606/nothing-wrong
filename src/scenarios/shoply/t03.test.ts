import type { BugReport, Evidence } from '../../game/domain/schemas'
import { resolveMutation } from '../../game/mutations/resolveMutation'
import { reviewBugReport } from '../../game/reporting/reviewBugReport'
import { T03_SCENARIO } from './t03'

const orderRuntime = {
  test: {
    account: 'BASIC' as const,
    viewport: 'DESKTOP' as const,
    locale: 'en-US',
    currentPath: '/shoply/orders/order-1042',
  },
  productState: { activeOrderId: 'order-1042', orderStatus: 'PROCESSING' },
}

describe('T03 Scenario', () => {
  it('contains the validated behavior defect contract and reward', () => {
    expect(T03_SCENARIO.ticket.id).toBe('T03')
    expect(T03_SCENARIO.expectedBugs[0]).toMatchObject({
      type: 'BEHAVIOR',
      target: 'orders.cancelAction',
      severity: 'HIGH',
      expected: 'Cancellation flow should open for a processing order',
      actual: 'Payment flow opens after selecting Cancel order',
    })
    expect(T03_SCENARIO.progression).toMatchObject({ xp: 100, reputationDelta: 2 })
  })

  it('changes only the canonical Cancel Order destination', () => {
    const normalDestination = '/shoply/orders/order-1042/cancel'

    expect(
      resolveMutation(
        'orders.cancelAction.destination',
        normalDestination,
        orderRuntime,
        T03_SCENARIO.mutations,
      ),
    ).toBe('/shoply/payment')
    expect(
      resolveMutation(
        'orders.cancelAction.destination',
        normalDestination,
        {
          ...orderRuntime,
          test: { ...orderRuntime.test, currentPath: '/shoply/orders' },
        },
        T03_SCENARIO.mutations,
      ),
    ).toBe(normalDestination)
    expect(
      resolveMutation(
        'orders.cancelAction.destination',
        normalDestination,
        orderRuntime,
        [],
      ),
    ).toBe(normalDestination)
  })

  it('awards a deterministic valid review only with payment-flow Evidence', () => {
    const evidence: Evidence = {
      id: 'EVIDENCE-T03',
      ticketId: 'T03',
      type: 'SCREENSHOT',
      preview: 'Shoply payment flow',
      capturedAt: 2,
      context: {
        ...orderRuntime.test,
        currentPath: '/shoply/payment',
      },
      snapshot: {
        visibleTargets: ['payment.form'],
        productState: orderRuntime.productState,
      },
    }
    const report: BugReport = {
      id: 'REPORT-T03',
      ticketId: 'T03',
      title: 'Cancel Order opens payment',
      reproductionSteps: [
        { id: 'STEP-1', order: 0, action: 'OPEN_ORDERS' },
        { id: 'STEP-2', order: 1, action: 'CANCEL_ORDER' },
        { id: 'STEP-3', order: 2, action: 'OPEN_PAYMENT' },
      ],
      expected: 'Cancellation flow should open for a processing order',
      actual: 'Payment flow opens after selecting Cancel order',
      severity: 'HIGH',
      evidenceIds: [evidence.id],
      submittedAt: 3,
    }

    expect(reviewBugReport(report, T03_SCENARIO, [evidence])).toMatchObject({
      valid: true,
      matchedBugId: 'BUG-T03-001',
      totalScore: 100,
      xp: 100,
      reputationDelta: 2,
    })

    const cancellationEvidence = {
      ...evidence,
      context: {
        ...evidence.context,
        currentPath: '/shoply/orders/order-1042/cancel',
      },
      snapshot: { ...evidence.snapshot, visibleTargets: ['orders.cancelFlow'] },
    }
    expect(
      reviewBugReport(report, T03_SCENARIO, [cancellationEvidence]),
    ).toMatchObject({ valid: false })
  })
})
