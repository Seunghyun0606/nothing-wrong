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
        content: [
          'Orders in the processing state can be cancelled until they ship.',
          'Cancel order opens the cancellation flow: choose a reason, confirm, and receive a refund to the original payment method.',
          'A customer is never asked to pay during cancellation.',
        ],
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
      cart: [],
      orderStatuses: { 'order-1042': 'PROCESSING' },
    },
  },
  expectedBugs: [
    {
      id: 'BUG-T03-001',
      type: 'BEHAVIOR',
      title: 'Cancel Order opens the payment flow',
      target: 'orders.cancelAction',
      severity: 'HIGH',
      requirementId: 'REQ-T03-01',
      reproductionConditions: [
        { field: 'test.currentPath', operator: 'EQ', value: '/shoply/payment' },
      ],
      reproductionActions: [
        { type: 'CANCEL_ORDER', label: 'select Cancel order' },
        { type: 'OPEN_PAYMENT', label: 'land on the screen it opens' },
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
    unlockedTools: ['ACCOUNT_SWITCHER'],
  },
  guide: {
    label: 'Field guide',
    ticketIntro: {
      label: 'New skill: action and result',
      heading: 'New skill: action and result',
      body: 'Every label makes a promise. Check that each action takes the customer where its label says it will.',
      steps: [
        'Read the briefing and the order management rules on the intranet.',
        'Act like the customer: try to cancel order #1042.',
        'Capture the screen if the result breaks the rule.',
      ],
    },
    workspace: [
      {
        id: 'T03-GUIDE-CAPTURED',
        label: 'Evidence captured',
        title: 'Which rule does this screen break?',
        instruction: 'Open QA Tracker, select Create report, and match your capture to a requirement.',
        conditions: [{ field: 'workspace.capturedPaths', operator: 'INCLUDES', value: '/shoply/payment' }],
      },
      {
        id: 'T03-GUIDE-RESULT',
        label: 'Look closely',
        title: 'Is this where the action should lead?',
        instruction: 'Compare this screen with REQ-T03-01. If it is wrong, capture it as Evidence.',
        conditions: [{ field: 'test.currentPath', operator: 'EQ', value: '/shoply/payment' }],
      },
      {
        id: 'T03-GUIDE-OPEN-SHOPLY',
        label: 'Find the order',
        title: 'Go to order #1042.',
        instruction: 'Type the order address from the briefing into the Browser. QA Notes has it too.',
        conditions: [{ field: 'workspace.onShoply', operator: 'EQ', value: false }],
      },
      {
        id: 'T03-GUIDE-INVESTIGATE',
        label: 'Investigate',
        title: 'Do what the customer would do.',
        instruction: 'Order #1042 is in Orders. Use its actions and watch where they lead.',
        conditions: [],
      },
    ],
    review: {
      valid: 'Behavior verified. A new tool is now unlocked. Read the debrief first.',
      invalid: 'Check the feedback. Did your Evidence capture the screen the action opened?',
    },
  },
  story: {
    chapterId: 'CH1',
    briefing: [
      {
        from: 'Priya Nair',
        role: 'Shoply Support Lead',
        text: 'This one is urgent. Customers trying to cancel processing orders say they end up on a payment page.',
      },
      {
        from: 'Maya Kim',
        role: 'QA Lead',
        text: 'Order #1042 is still processing, so it should be cancellable. It lives at shoply.local/orders/order-1042. Find out where Cancel order really takes people.',
      },
      {
        from: 'Daniel Reyes',
        role: 'Shoply Release Manager',
        text: "We'd have noticed that. Cancellations actually dropped this week. That's good news, isn't it?",
      },
    ],
    debrief: [
      {
        from: 'Sam Ortiz',
        role: 'Shoply Engineer',
        text: "The cancel link points at payment. I've seen this before: it's from an old experiment branch, exp/retention-push. Marketing wanted fewer cancellations.",
      },
      {
        from: 'Sam Ortiz',
        role: 'Shoply Engineer',
        text: 'That branch was archived in March. It should never ship.',
      },
      {
        from: 'Maya Kim',
        role: 'QA Lead',
        text: "So the drop in cancellations wasn't good news. It was this bug.",
      },
    ],
    clue: {
      id: 'CLUE-RETENTION-PUSH',
      title: 'exp/retention-push',
      text: 'The Cancel → payment routing comes from exp/retention-push, an experiment branch archived in March. Cancellations "dropped" because customers could not cancel.',
    },
    deduction: {
      id: 'DED-T03',
      askedBy: { from: 'Maya Kim', role: 'QA Lead' },
      prompt: 'Old promotion code, an archived experiment, the same 02:14 merge. What is the most likely explanation so far?',
      options: [
        {
          id: 'DED-T03-A',
          text: 'A developer is secretly sabotaging Shoply.',
          correct: false,
          response: "Every change came through release-bot, not a person's account. Don't accuse anyone without evidence.",
        },
        {
          id: 'DED-T03-B',
          text: 'The new Autumn features simply were not tested.',
          correct: false,
          response: 'None of these are new features. They are old code that was retired or archived.',
        },
        {
          id: 'DED-T03-C',
          text: 'release-bot merged old, archived branches into RC3.',
          correct: true,
          response: "That fits every clue so far. One more Ticket: let's see if it holds.",
        },
      ],
    },
  },
})
