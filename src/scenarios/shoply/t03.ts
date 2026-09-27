import { parseScenario } from '../../game/scenarios/parseScenario'

export const T03_SCENARIO = parseScenario({
  id: 'SCENARIO-T03',
  ticket: {
    id: 'T03',
    projectId: 'shoply',
    title: 'Order cancellation routing',
    sender: {
      id: 'maya-kim',
      name: 'Maya Kim',
      role: 'QA Lead',
    },
    priority: 'HIGH',
    request:
      'Verify that customers can enter the cancellation flow for an order that is still processing.',
    scope: ['Order details', 'Order cancellation'],
    requirements: [
      {
        id: 'REQ-T03-01',
        description: 'Cancel Order opens the return or cancellation flow for a processing order.',
        reference: 'Shoply order management rules',
      },
      {
        id: 'REQ-T03-02',
        description: 'Order #1042 is eligible for cancellation before shipment.',
        reference: 'Order #1042',
      },
    ],
    attachments: [
      {
        id: 'ATT-T03-01',
        name: 'Order management rules',
        reference: 'Commerce / order lifecycle',
      },
    ],
    startingContext: {
      account: 'BASIC',
      viewport: 'DESKTOP',
      locale: 'en-US',
      currentPath: '/shoply/orders/order-1042',
    },
    hints: [
      {
        id: 'HINT-T03-01',
        text: 'Compare the action label with the screen that opens after selecting it.',
      },
    ],
    status: 'NEW',
  },
  seed: {
    productState: {
      activeOrderId: 'order-1042',
      orderStatus: 'PROCESSING',
    },
  },
  expectedBugs: [
    {
      id: 'BUG-T03-001',
      type: 'BEHAVIOR',
      title: 'Cancel Order opens the payment flow',
      target: 'orders.cancelAction',
      severity: 'HIGH',
      reproductionConditions: [
        { field: 'test.currentPath', operator: 'EQ', value: '/shoply/payment' },
      ],
      expected: 'Cancellation flow should open for a processing order',
      actual: 'Payment flow opens after selecting Cancel order',
      validEvidenceTargets: ['payment.form'],
    },
  ],
  mutations: [
    {
      id: 'MUTATION-T03-001',
      type: 'WRONG_ACTION',
      target: 'orders.cancelAction.destination',
      conditions: [
        {
          field: 'test.currentPath',
          operator: 'EQ',
          value: '/shoply/orders/order-1042',
        },
      ],
      payload: { value: '/shoply/payment' },
    },
  ],
  scoring: {
    detection: 40,
    reproduction: 25,
    evidence: 20,
    severity: 15,
  },
  progression: {
    xp: 100,
    reputationDelta: 2,
    unlockedTools: [],
  },
})
