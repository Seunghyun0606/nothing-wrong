import { ScenarioSchema, type Scenario } from '../domain/schemas'

export interface ScenarioValidationIssue {
  path: string
  message: string
}

export class ScenarioValidationError extends Error {
  readonly issues: readonly ScenarioValidationIssue[]

  constructor(issues: readonly ScenarioValidationIssue[]) {
    const detail = issues
      .map((issue) => `${issue.path || '<root>'}: ${issue.message}`)
      .join('; ')
    super(`Invalid Scenario: ${detail}`)
    this.name = 'ScenarioValidationError'
    this.issues = issues
  }
}

export function parseScenario(input: unknown): Scenario {
  const result = ScenarioSchema.safeParse(input)

  if (!result.success) {
    throw new ScenarioValidationError(
      result.error.issues.map((issue) => ({
        path: issue.path.join('.'),
        message: issue.message,
      })),
    )
  }

  return result.data
}
