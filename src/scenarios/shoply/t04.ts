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
        content: [
          'SAVE10: 10% off the subtotal for every account.',
          'SAVE20: 20% off the subtotal for Gold members only. Basic members see an eligibility message.',
          'Discounts apply to the full subtotal with no quantity limit or cap.',
        ],
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
      cart: [],
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
      requirementId: 'REQ-T04-02',
      reproductionConditions: [
        { field: 'test.currentPath', operator: 'EQ', value: '/shoply/cart' },
        { field: 'test.account', operator: 'EQ', value: 'GOLD' },
        { field: 'product.coupon', operator: 'EQ', value: 'SAVE20' },
        { field: 'product.cart.quantity', operator: 'GTE', value: 3 },
      ],
      reproductionActions: [
        { type: 'CHANGE_ACCOUNT', target: 'GOLD', label: 'switch to the Gold account' },
        { type: 'APPLY_COUPON', payload: { code: 'SAVE20' }, label: 'apply SAVE20' },
        { type: 'OPEN_CART', label: 'open the bag' },
      ],
      expected: 'SAVE20 should apply a 20% discount for Gold members',
      actual: 'SAVE20 applies only a 10% discount with three or more items',
      validEvidenceTargets: ['cart.discount', 'cart.total'],
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
  guide: {
    label: 'Field note',
    ticketIntro: {
      label: 'New tool: Account Switcher',
      heading: 'New tool: Account Switcher',
      body: "Some rules only apply to certain customers. The Account Switcher in the Browser's QA bar lets you test as a Basic or Gold member without leaving the session. This time, you choose what to try.",
      steps: [
        'Read the briefing and the promotion rules.',
        'Combine account, coupon, and quantity until something breaks a rule.',
        'Capture the failing combination and report it.',
      ],
    },
    workspace: [
      {
        id: 'T04-GUIDE-VARY',
        label: 'Vary it',
        title: 'Gold and SAVE20 are active.',
        instruction: 'Now change the quantity and check the discount math at each step against the promotion rules.',
        conditions: [
          { field: 'test.account', operator: 'EQ', value: 'GOLD' },
          { field: 'product.coupon', operator: 'EQ', value: 'SAVE20' },
          { field: 'test.currentPath', operator: 'EQ', value: '/shoply/cart' },
        ],
      },
      {
        id: 'T04-GUIDE-TOOL',
        label: 'New tool',
        title: 'Requirements depend on the account tier.',
        instruction: "Use the Account Switcher in the Browser's QA bar to test as Basic and as Gold.",
        conditions: [],
      },
    ],
    review: {
      valid: 'Conditional defect proven. This is the last piece: read the debrief and close the case.',
      invalid: 'Check the feedback. Was the failing combination of account, coupon, and quantity on screen when you captured?',
    },
  },
  story: {
    chapterId: 'CH1',
    briefing: [
      {
        from: 'Maya Kim',
        role: 'QA Lead',
        text: 'Last one before Friday. The Browser QA bar now has an Account Switcher, so you can test as Basic or Gold. Same staging site: shoply.local.',
      },
      {
        from: 'Daniel Reyes',
        role: 'Shoply Release Manager',
        text: 'Gold members are our best customers and SAVE20 is the headline promo. Please tell me it works.',
      },
      {
        from: 'Sam Ortiz',
        role: 'Shoply Engineer',
        text: 'If it is broken too, check bigger carts. exp/retention-push also had a "margin guard" for large orders.',
      },
    ],
    debrief: [
      {
        from: 'Sam Ortiz',
        role: 'Shoply Engineer',
        text: 'Confirmed. The 10% cap on large Gold carts is the margin guard from exp/retention-push.',
      },
      {
        from: 'Sam Ortiz',
        role: 'Shoply Engineer',
        text: 'And I found out how the archive got in: on Tuesday, release-bot\'s merge rule was widened from "release/*" to "release/*, exp/*, promo/*".',
      },
    ],
    clue: {
      id: 'CLUE-MERGE-RULE',
      title: 'The widened merge rule',
      text: 'On Tuesday the release-bot merge rule was widened to include exp/* and promo/*. Every archived experiment and retired promotion matched it.',
    },
    deduction: {
      id: 'DED-T04',
      askedBy: { from: 'Maya Kim', role: 'QA Lead' },
      prompt: 'Case file: what really happened to RC3?',
      options: [
        {
          id: 'DED-T04-A',
          text: 'Four developers made four unrelated mistakes on the same night.',
          correct: false,
          response: 'Every defect traces back to one 02:14 merge by release-bot. Look at what the clues share.',
        },
        {
          id: 'DED-T04-B',
          text: 'A widened merge rule made release-bot pull archived experiments and retired promotions into RC3.',
          correct: true,
          response: 'That explains every clue: the 02:14 merge, the old promotion, and both pieces of exp/retention-push.',
        },
        {
          id: 'DED-T04-C',
          text: 'Someone shipped the retention experiment on purpose to cut cancellations.',
          correct: false,
          response: "Every change came in through the merge rule. There's no evidence of intent, only of a rule that matched too much.",
        },
      ],
    },
  },
})
