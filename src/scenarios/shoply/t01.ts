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
        content: [
          'Primary action: solid dark fill with a white label. Use it for the one action that completes the step.',
          'Secondary action: outlined, transparent fill, dark label. Use it for optional or alternative actions.',
          'Every checkout step has exactly one primary action. On the Delivery details step it is "Confirm order".',
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
        id: 'HINT-T01-01',
        text: 'Follow the complete customer journey before recording a conclusion.',
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
      id: 'BUG-T01-001',
      type: 'VISUAL',
      title: 'Checkout confirmation action uses the wrong style',
      target: 'checkout.confirmButton',
      severity: 'LOW',
      requirementId: 'REQ-T01-02',
      reproductionConditions: [],
      reproductionActions: [
        { type: 'ADD_TO_CART', label: 'add the product to the bag' },
        { type: 'OPEN_CHECKOUT', label: 'open checkout' },
      ],
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
  guide: {
    label: 'First Ticket tutorial',
    ticketIntro: {
      label: 'How to play your first Ticket',
      heading: 'What am I supposed to do?',
      body: 'Use the Ticket requirements as your checklist. Explore Shoply like a customer, compare what happens with what should happen, then report only what you can prove.',
      steps: [
        'Read the briefing in Messenger and the requirements below.',
        'Select Start test, then open Shoply in the Browser and follow product → bag → checkout.',
        'If something differs, select Capture in the Browser while it is on screen. Captures land in QA Notes.',
        'Back in QA Tracker, create a Report, attach Evidence, and read the QA Review.',
      ],
    },
    workspace: [
      {
        id: 'T01-GUIDE-CAPTURED',
        label: 'Evidence captured',
        title: 'Turn your observation into a Report.',
        instruction: 'Your capture is in QA Notes. Keep exploring, or open QA Tracker and select Create report when your capture shows the difference.',
        conditions: [{ field: 'workspace.capturedPaths', operator: 'INCLUDES', value: '/shoply/checkout' }],
      },
      {
        id: 'T01-GUIDE-CHECKOUT',
        label: 'Compare',
        title: 'Check this screen against the Ticket.',
        instruction: 'Compare this screen with the requirements in QA Tracker and the specification on the intranet. If the visible result differs, select Capture in the Browser before confirming the order.',
        conditions: [{ field: 'test.currentPath', operator: 'EQ', value: '/shoply/checkout' }],
      },
      {
        id: 'T01-GUIDE-CART',
        label: 'Continue the journey',
        title: 'Inspect the bag, then continue to checkout.',
        instruction: 'Compare each screen with the requirements in QA Tracker as you go.',
        conditions: [{ field: 'test.currentPath', operator: 'EQ', value: '/shoply/cart' }],
      },
      {
        id: 'T01-GUIDE-PRODUCT',
        label: 'Explore',
        title: 'Try Shoply as a customer.',
        instruction: 'Use Add to bag on the product page, then open Bag. The requirements are in QA Tracker.',
        conditions: [{ field: 'test.currentPath', operator: 'STARTS_WITH', value: '/shoply/product/' }],
      },
      {
        id: 'T01-GUIDE-OPEN-SHOPLY',
        label: 'Open the site',
        title: 'Open Shoply in the Browser.',
        instruction: "Select the shoply.local link in Maya's message, or open Browser and type shoply.local into the address bar.",
        conditions: [{ field: 'workspace.onShoply', operator: 'EQ', value: false }],
      },
      {
        id: 'T01-GUIDE-DETOUR',
        label: 'Explore freely',
        title: 'Return to the purchase journey when you are ready.',
        instruction: 'Select the Shoply logo to return to the product page, then explore the product, bag, and checkout against the Ticket requirements.',
        conditions: [],
      },
    ],
    report: [
      'Keep the recorded actions another tester needs to repeat what you saw.',
      'Pick the requirement that is not met, then the captured observation that shows it.',
      'Choose a severity with the guide, attach the Evidence, and submit for QA Review.',
    ],
    review: {
      valid: 'First case complete. Read the debrief below and connect the clue to the story.',
      invalid: 'Read the feedback, return to the Test Workspace, and revise your Report. Check the steps, the requirement, and the observation you picked, and capture new Evidence if needed.',
    },
  },
  story: {
    chapterId: 'CH1',
    briefing: [
      {
        from: 'Maya Kim',
        role: 'QA Lead',
        text: 'Welcome aboard. Shoply is our client, and their Autumn Release ships Friday. Build RC3 landed overnight.',
      },
      {
        from: 'Daniel Reyes',
        role: 'Shoply Release Manager',
        text: "Honestly, this is a formality. Nothing changed in checkout. Nothing wrong with this build.",
      },
      {
        from: 'Maya Kim',
        role: 'QA Lead',
        text: "Then it should be a quick review. Follow the purchase path and check it against the spec. Trust what you can prove, not what you're told.",
      },
      {
        from: 'Maya Kim',
        role: 'QA Lead',
        text: 'Accept T01 in QA Tracker first. Then open the staging site and start from the product page. The spec is on the intranet.',
        links: [
          { label: 'shoply.local/product/everyday-pack', url: 'https://shoply.local/product/everyday-pack' },
          { label: 'Checkout interaction specification', url: 'https://docs.nothingwrong.local/checkout-interaction-specification' },
        ],
      },
    ],
    debrief: [
      {
        from: 'Maya Kim',
        role: 'QA Lead',
        text: 'Good catch. Design confirms Confirm order should be primary, and they say they never touched it.',
      },
      {
        from: 'Sam Ortiz',
        role: 'Shoply Engineer',
        text: 'Weird. Version history says the checkout styles changed at 02:14 last night. The author is release-bot, our merge automation.',
      },
    ],
    clue: {
      id: 'CLUE-0214',
      title: '02:14 · release-bot',
      text: 'Checkout styles changed at 02:14 in RC3, committed by release-bot. The design team made no change.',
    },
    deduction: {
      id: 'DED-T01',
      askedBy: { from: 'Maya Kim', role: 'QA Lead' },
      prompt: 'Daniel said nothing changed in checkout. What does the evidence say?',
      options: [
        {
          id: 'DED-T01-A',
          text: 'Checkout did change: an automated merge modified it overnight.',
          correct: true,
          response: 'Exactly. Something changed, even if no person meant to change it.',
        },
        {
          id: 'DED-T01-B',
          text: 'A designer changed the button and forgot to mention it.',
          correct: false,
          response: 'Design says they made no change, and the commit came from release-bot, not a person. Look at the author again.',
        },
        {
          id: 'DED-T01-C',
          text: 'Nothing changed. The button was always secondary.',
          correct: false,
          response: 'The specification says primary, and the history shows an edit at 02:14. Something did change.',
        },
      ],
    },
  },
})
