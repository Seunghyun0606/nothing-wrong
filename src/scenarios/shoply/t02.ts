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
        content: [
          'Subtotal = unit price × quantity, summed over every item in the bag.',
          'Shipping is free when the subtotal is $50.00 or more; otherwise it is $5.00.',
          'Total = subtotal − discount + shipping.',
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
        id: 'HINT-T02-01',
        text: 'Check displayed totals after changing the quantity in the cart.',
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
  expectedBugs: [
    {
      id: 'BUG-T02-001',
      type: 'DATA',
      title: 'Cart subtotal is incorrect for two items',
      target: 'cart.subtotal',
      severity: 'MEDIUM',
      requirementId: 'REQ-T02-01',
      reproductionConditions: [
        { field: 'test.currentPath', operator: 'EQ', value: '/shoply/cart' },
        { field: 'product.cart.quantity', operator: 'EQ', value: 2 },
      ],
      reproductionActions: [
        { type: 'ADD_TO_CART', label: 'add the product to the bag' },
        { type: 'OPEN_CART', label: 'open the bag' },
      ],
      expected: 'Subtotal should be $60.00 for two $30.00 items',
      actual: 'Subtotal is displayed as $50.00',
      validEvidenceTargets: ['cart.subtotal', 'cart.total'],
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
  guide: {
    label: 'Guided Ticket',
    ticketIntro: {
      label: 'New skill: verify the numbers',
      heading: 'New skill: verify the numbers',
      body: 'A screen can look perfect and still show the wrong figures. This time, work out what each figure should be and compare it with what Shoply shows.',
      steps: [
        'Read the briefing in Messenger and open the pricing rules on the intranet.',
        'Put the pack in your bag and change the quantity.',
        'Do the math for every figure in the Order summary.',
        'Capture the screen while a figure is wrong, then report it.',
      ],
    },
    workspace: [
      {
        id: 'T02-GUIDE-CAPTURED',
        label: 'Evidence captured',
        title: 'Do your captured numbers disagree?',
        instruction: 'Read the captured values in QA Notes. If one breaks the pricing rule, create a report in QA Tracker. If they all agree, try another quantity and capture again.',
        conditions: [{ field: 'workspace.capturedPaths', operator: 'INCLUDES', value: '/shoply/cart' }],
      },
      {
        id: 'T02-GUIDE-MATH',
        label: 'Do the math',
        title: 'Price × quantity: does every figure agree?',
        instruction: 'Compare the line total, Subtotal, and Total with REQ-T02-01. If one is wrong, select Capture while it is on screen.',
        conditions: [
          { field: 'test.currentPath', operator: 'EQ', value: '/shoply/cart' },
          { field: 'product.cart.quantity', operator: 'GTE', value: 2 },
        ],
      },
      {
        id: 'T02-GUIDE-QUANTITY',
        label: 'Change the quantity',
        title: 'One item is easy. Try more than one.',
        instruction: 'Use the Qty selector and watch the Order summary as it updates.',
        conditions: [{ field: 'test.currentPath', operator: 'EQ', value: '/shoply/cart' }],
      },
      {
        id: 'T02-GUIDE-PRODUCT',
        label: 'Start',
        title: 'Put the pack in your bag.',
        instruction: 'Select Add to bag, then open Bag.',
        conditions: [{ field: 'test.currentPath', operator: 'STARTS_WITH', value: '/shoply/product/' }],
      },
      {
        id: 'T02-GUIDE-OPEN-SHOPLY',
        label: 'Open the site',
        title: 'Head back to Shoply.',
        instruction: 'Use the link in the briefing or QA Notes, or type shoply.local in the Browser.',
        conditions: [{ field: 'workspace.onShoply', operator: 'EQ', value: false }],
      },
      {
        id: 'T02-GUIDE-DETOUR',
        label: 'Head to the bag',
        title: 'The figures to check are in the bag.',
        instruction: 'Select Bag in the Shoply header, or the Shoply logo to return to the product.',
        conditions: [],
      },
    ],
    report: [
      'The requirement to pick is the rule your captured figure breaks.',
      'Pick the figure that is wrong, not one that is correct.',
    ],
    review: {
      valid: 'Numbers verified. Read the debrief: the pattern is starting to show.',
      invalid: 'Check the feedback. Did you capture while the wrong figure was on screen, and pick the figure that breaks the rule?',
    },
  },
  story: {
    chapterId: 'CH1',
    briefing: [
      {
        from: 'Maya Kim',
        role: 'QA Lead',
        text: 'Second job. Shoply Support got a strange email: a customer bought two packs and was charged less than expected.',
      },
      {
        from: 'Priya Nair',
        role: 'Shoply Support Lead',
        text: 'He was happy. Our finance team was not. Can you check whether the cart math is right?',
      },
      {
        from: 'Daniel Reyes',
        role: 'Shoply Release Manager',
        text: "Probably a coupon. The pricing code hasn't changed since spring.",
      },
      {
        from: 'Maya Kim',
        role: 'QA Lead',
        text: 'Pricing rules are on the intranet. Start from the product page again.',
        links: [
          { label: 'shoply.local/product/everyday-pack', url: 'https://shoply.local/product/everyday-pack' },
          { label: 'Shoply pricing rules', url: 'https://docs.nothingwrong.local/shoply-pricing-rules' },
        ],
      },
    ],
    debrief: [
      {
        from: 'Sam Ortiz',
        role: 'Shoply Engineer',
        text: 'Found it. The subtotal code in RC3 is a copy from last spring\'s "TWO FOR $50" promotion. That promo was retired in June.',
      },
      {
        from: 'Sam Ortiz',
        role: 'Shoply Engineer',
        text: 'And the author is the same as the button change: release-bot, 02:14.',
      },
    ],
    clue: {
      id: 'CLUE-TWO-FOR-50',
      title: 'A retired promotion came back',
      text: 'RC3 calculates two-item subtotals with the "TWO FOR $50" code from a spring promotion retired in June. Merged by release-bot at 02:14.',
    },
    deduction: {
      id: 'DED-T02',
      askedBy: { from: 'Maya Kim', role: 'QA Lead' },
      prompt: 'Two unrelated screens broke on the same night. What links them?',
      options: [
        {
          id: 'DED-T02-A',
          text: 'The customer\'s coupon caused both problems.',
          correct: false,
          response: 'No coupon was applied in your test, and coupons do not change button styles. Look at who changed both files.',
        },
        {
          id: 'DED-T02-B',
          text: 'Both changes came from the same overnight merge by release-bot.',
          correct: true,
          response: "Right. One merge, two broken screens. That's a pattern, not a coincidence.",
        },
        {
          id: 'DED-T02-C',
          text: 'Shoply\'s servers were overloaded that night.',
          correct: false,
          response: 'An overload would not rewrite a button style or bring back old promotion code. Check the timestamps.',
        },
      ],
    },
  },
})
