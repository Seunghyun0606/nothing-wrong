import { parseScenario } from '../../game/scenarios/parseScenario'

export const T04_SCENARIO = parseScenario({
  id: 'SCENARIO-T04',
  ticket: {
    id: 'T04',
    projectId: 'shoply',
    title: 'Gold coupon discount verification',
    sender: {
      id: 'maya-kim',
      name: 'Maya Kim',
      role: 'QA Lead',
    },
    priority: 'HIGH',
    request:
      'Verify SAVE20 eligibility and discount amounts as account tier and cart quantity change.',
    scope: ['Account context', 'Cart quantity', 'Coupon discount'],
    requirements: [
      {
        id: 'REQ-T04-01',
        description: 'SAVE20 is available only to Gold members.',
        reference: 'Shoply promotion rules',
      },
      {
        id: 'REQ-T04-02',
        description: 'Eligible SAVE20 orders receive a 20% discount at every quantity.',
        reference: 'Shoply promotion rules',
      },
      {
        id: 'REQ-T04-03',
        description: 'Everyday Carry Pack costs $30.00 per item.',
        reference: 'Product catalog',
      },
    ],
    attachments: [
      {
        id: 'ATT-T04-01',
        name: 'Shoply promotion rules',
        reference: 'Commerce / coupons',
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
        id: 'HINT-T04-01',
        text: 'Compare SAVE20 at different account tiers and quantities.',
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
  accountSwitchPolicy: { resetProductState: false },
  expectedBugs: [
    {
      id: 'BUG-T04-001',
      type: 'CONDITIONAL',
      title: 'SAVE20 applies only ten percent to larger Gold carts',
      target: 'cart.discount',
      severity: 'MEDIUM',
      reproductionConditions: [
        { field: 'test.currentPath', operator: 'EQ', value: '/shoply/cart' },
        { field: 'test.account', operator: 'EQ', value: 'GOLD' },
        { field: 'product.coupon', operator: 'EQ', value: 'SAVE20' },
        { field: 'product.cart.quantity', operator: 'GTE', value: 3 },
      ],
      expected: 'SAVE20 should apply a 20% discount for Gold members',
      actual: 'SAVE20 applies only a 10% discount with three or more items',
      validEvidenceTargets: ['cart.discount'],
    },
  ],
  mutations: [
    {
      id: 'MUTATION-T04-001',
      type: 'WRONG_CALCULATION',
      target: 'cart.discountRate',
      conditions: [
        { field: 'test.currentPath', operator: 'EQ', value: '/shoply/cart' },
        { field: 'test.account', operator: 'EQ', value: 'GOLD' },
        { field: 'product.coupon', operator: 'EQ', value: 'SAVE20' },
        { field: 'product.cart.quantity', operator: 'GTE', value: 3 },
      ],
      payload: { value: 0.1 },
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
