import type { Evidence } from '../domain/schemas'
import { createBugReport, InvalidEvidenceClaimError } from './createBugReport'

const evidence: Evidence = {
  id: 'EVIDENCE-T01',
  ticketId: 'T01',
  type: 'SCREENSHOT',
  preview: 'Checkout',
  capturedAt: 1,
  context: {
    account: 'BASIC',
    viewport: 'DESKTOP',
    locale: 'en-US',
    currentPath: '/shoply/checkout',
  },
  snapshot: { visibleTargets: ['checkout.confirmButton'] },
}

const input = {
  id: 'REPORT-T01',
  ticketId: 'T01',
  title: 'Checkout action uses the wrong style',
  reproductionSteps: [{ id: 'STEP-1', order: 0, action: 'OPEN_CHECKOUT' }],
  expected: 'Primary action style',
  actual: 'Secondary action style',
  severity: 'LOW' as const,
  evidenceIds: [evidence.id],
  submittedAt: 2,
}

describe('createBugReport', () => {
  it('creates a Report using Evidence captured for the current Ticket', () => {
    expect(createBugReport(input, [evidence])).toMatchObject({
      id: 'REPORT-T01',
      evidenceIds: ['EVIDENCE-T01'],
    })
  })

  it('rejects an Evidence id that was not captured for the current Ticket', () => {
    expect(() =>
      createBugReport({ ...input, evidenceIds: ['EVIDENCE-OTHER'] }, [evidence]),
    ).toThrow(InvalidEvidenceClaimError)
  })
})
