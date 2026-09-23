import {
  BugReportSchema,
  EvidenceSchema,
  GameStateSchema,
  ReviewResultSchema,
  ScenarioSchema,
  TicketSchema,
} from './schemas'
import { createInitialGameState } from './gameState'
import { createScenarioInput } from '../test/fixtures'

describe('domain schemas', () => {
  it('validates the complete Scenario content aggregate', () => {
    const input = createScenarioInput()

    const scenario = ScenarioSchema.parse(input)

    expect(scenario.id).toBe('SCENARIO-T01')
    expect(TicketSchema.parse(input.ticket).id).toBe('T01')
    expect(scenario.mutations[0]?.target).toBe('checkout.confirmButton')
  })

  it('validates Evidence, BugReport, ReviewResult, and GameState contracts', () => {
    const context = {
      account: 'BASIC',
      viewport: 'DESKTOP',
      locale: 'en-US',
      currentPath: '/checkout',
    }

    expect(
      EvidenceSchema.parse({
        id: 'EVIDENCE-1',
        ticketId: 'T01',
        type: 'SCREENSHOT',
        preview: 'data:image/mock',
        capturedAt: 1,
        context,
        snapshot: { buttonStyle: 'secondary' },
      }).ticketId,
    ).toBe('T01')

    expect(
      BugReportSchema.parse({
        id: 'REPORT-1',
        ticketId: 'T01',
        title: 'Checkout action has the wrong style',
        reproductionSteps: [
          { id: 'STEP-1', order: 0, action: 'OPEN_CHECKOUT' },
        ],
        expected: 'Primary action style',
        actual: 'Secondary action style',
        severity: 'LOW',
        evidenceIds: ['EVIDENCE-1'],
        submittedAt: 2,
      }).id,
    ).toBe('REPORT-1')

    expect(
      ReviewResultSchema.parse({
        valid: true,
        matchedBugId: 'BUG-T01-001',
        scores: { detection: 40, reproduction: 25, evidence: 20, severity: 15 },
        totalScore: 100,
        xp: 100,
        reputationDelta: 2,
        feedback: ['Valid report'],
      }).valid,
    ).toBe(true)

    expect(GameStateSchema.parse(createInitialGameState(['T01'])).tickets.T01?.status).toBe(
      'NEW',
    )
  })

  it('rejects scoring weights that do not total 100', () => {
    const input = createScenarioInput()
    input.scoring.severity = 10

    const result = ScenarioSchema.safeParse(input)

    expect(result.success).toBe(false)
  })
})
