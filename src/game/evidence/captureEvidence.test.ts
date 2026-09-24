import { captureEvidence } from './captureEvidence'

describe('captureEvidence', () => {
  it('captures the complete test context and semantic snapshot', () => {
    const evidence = captureEvidence({
      id: 'EVIDENCE-1',
      ticketId: 'T01',
      capturedAt: 42,
      context: {
        account: 'BASIC',
        viewport: 'TABLET',
        locale: 'en-US',
        currentPath: '/shoply/checkout',
      },
      preview: 'Shoply checkout preview',
      snapshot: {
        heading: 'Delivery details',
        targets: ['checkout.confirmButton'],
      },
    })

    expect(evidence).toMatchObject({
      id: 'EVIDENCE-1',
      ticketId: 'T01',
      capturedAt: 42,
      context: {
        account: 'BASIC',
        viewport: 'TABLET',
        currentPath: '/shoply/checkout',
      },
      snapshot: { heading: 'Delivery details' },
    })
  })
})
