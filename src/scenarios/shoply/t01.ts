import { parseScenario } from '../../game/scenarios/parseScenario'

export const T01_SCENARIO = parseScenario({
  id: 'SCENARIO-T01',
  ticket: {
    id: 'T01',
    projectId: 'shoply',
    title: 'Checkout confirmation design review',
    sender: {
      id: 'maya-kim',
      name: 'Maya Kim',
      role: 'QA Lead',
    },
    priority: 'HIGH',
    request:
      'Review the purchase path before release. Confirm the product, cart, and checkout experience matches the approved requirements.',
    scope: ['Product detail', 'Cart', 'Checkout'],
    requirements: [
      {
        id: 'REQ-T01-01',
        description: 'Customers can add a product to the cart and continue to checkout.',
      },
      {
        id: 'REQ-T01-02',
        description: 'The final confirmation control is presented as the primary action.',
        reference: 'Checkout interaction specification',
      },
    ],
    attachments: [
      {
        id: 'ATT-T01-01',
        name: 'Checkout interaction specification',
        reference: 'Design system / checkout actions',
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
        id: 'HINT-T01-01',
        text: 'Follow the complete customer journey before recording a conclusion.',
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
      id: 'BUG-T01-001',
      type: 'VISUAL',
      title: 'Checkout confirmation action uses the wrong style',
      target: 'checkout.confirmButton',
      severity: 'LOW',
      reproductionConditions: [],
      expected: 'Primary action style',
      actual: 'Secondary action style',
      validEvidenceTargets: ['checkout.confirmButton'],
    },
  ],
  mutations: [
    {
      id: 'MUTATION-T01-001',
      type: 'WRONG_STYLE',
      target: 'checkout.confirmButton',
      payload: { value: 'secondary' },
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
