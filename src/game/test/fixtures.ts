export function createScenarioInput() {
  return {
    id: 'SCENARIO-T01',
    ticket: {
      id: 'T01',
      projectId: 'shoply',
      title: 'Checkout CTA verification',
      sender: {
        id: 'lead-qa',
        name: 'M. Kim',
        role: 'QA Lead',
      },
      priority: 'NORMAL',
      request: 'Verify the checkout confirmation action.',
      scope: ['checkout'],
      requirements: [
        {
          id: 'REQ-CHECKOUT-001',
          description: 'The confirmation action uses the primary style.',
        },
      ],
      startingContext: {
        account: 'BASIC',
        viewport: 'DESKTOP',
        locale: 'en-US',
        currentPath: '/product/1',
      },
      status: 'NEW',
    },
    seed: {
      productState: {
        cart: { quantity: 1 },
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
    },
    narrative: {
      tags: [],
      clueIds: [],
      entityIds: [],
      persistentChanges: [],
    },
  }
}
