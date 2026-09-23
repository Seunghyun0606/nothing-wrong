import { createScenarioInput } from '../test/fixtures'
import { parseScenario, ScenarioValidationError } from './parseScenario'

describe('parseScenario', () => {
  it('returns validated Scenario data', () => {
    expect(parseScenario(createScenarioInput()).id).toBe('SCENARIO-T01')
  })

  it('throws a visible error with the invalid field path', () => {
    const input = createScenarioInput()
    input.ticket.title = ''

    expect(() => parseScenario(input)).toThrow(ScenarioValidationError)
    expect(() => parseScenario(input)).toThrow('ticket.title')
  })
})
