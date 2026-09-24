import { parseScenario } from '../../game/scenarios/parseScenario'

export const T02_SCENARIO = parseScenario({
  id: 'SCENARIO-T02',
  ticket: {
    id: 'T02',
    projectId: 'shoply',
    title: 'Cart subtotal verification',
    sender: {
      id: 'maya-kim',
      name: 'Maya Kim',
      role: 'QA Lead',
    },
    priority: 'HIGH',
    request:
      'Verify that cart totals remain accurate when customers change item quantities before checkout.',
    scope: ['Product detail', 'Cart totals'],
    requirements: [
      {
        id: 'REQ-T02-01',
        description: 'The cart subtotal equals product price multiplied by quantity.',
        reference: 'Shoply pricing rules',
      },
      {
        id: 'REQ-T02-02',
        description: 'Everyday Carry Pack costs $30.00 per item.',
        reference: 'Product catalog',
      },
    ],
    attachments: [
      {
        id: 'ATT-T02-01',
        name: 'Shoply pricing rules',
        reference: 'Commerce / cart calculations',
      },
    ],
    startingContext: {
      account: 'BASIC',
      viewport: 'DESKTOP',
      locale: 'en-US',
      currentPath: '/shoply/product/everyday-pack',
    },
    hints: [
      {
        id: 'HINT-T02-01',
        text: 'Check displayed totals after changing the quantity in the cart.',
      },
    ],
    status: 'NEW',
  },
  seed: {
    productState: {
      cart: { quantity: 0 },
      coupon: '',
    },
  },
  expectedBugs: [
    {
      id: 'BUG-T02-001',
      type: 'DATA',
      title: 'Cart subtotal is incorrect for two items',
      target: 'cart.subtotal',
      severity: 'MEDIUM',
      reproductionConditions: [
        { field: 'test.currentPath', operator: 'EQ', value: '/shoply/cart' },
        { field: 'product.cart.quantity', operator: 'EQ', value: 2 },
      ],
      expected: 'Subtotal should be $60.00 for two $30.00 items',
      actual: 'Subtotal is displayed as $50.00',
      validEvidenceTargets: ['cart.subtotal'],
    },
  ],
  mutations: [
    {
      id: 'MUTATION-T02-001',
      type: 'WRONG_CALCULATION',
      target: 'cart.subtotal',
      conditions: [
        { field: 'test.currentPath', operator: 'EQ', value: '/shoply/cart' },
        { field: 'product.cart.quantity', operator: 'EQ', value: 2 },
      ],
      payload: { value: 50 },
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
