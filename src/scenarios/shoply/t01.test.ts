import { resolveMutation } from '../../game/mutations/resolveMutation'
import { T01_SCENARIO } from './t01'

const runtime = {
  test: {
    account: 'BASIC' as const,
    viewport: 'DESKTOP' as const,
    locale: 'en-US',
    currentPath: '/shoply/checkout',
  },
  productState: { cart: { quantity: 1 } },
}

describe('T01 Scenario', () => {
  it('contains the validated Ticket, ExpectedBug, scoring, reward, and Mutation', () => {
    expect(T01_SCENARIO.ticket.id).toBe('T01')
    expect(T01_SCENARIO.expectedBugs[0]).toMatchObject({
      target: 'checkout.confirmButton',
      expected: 'Primary action style',
      actual: 'Secondary action style',
    })
    expect(T01_SCENARIO.scoring).toEqual({
      detection: 40,
      reproduction: 25,
      evidence: 20,
      severity: 15,
    })
    expect(T01_SCENARIO.progression).toMatchObject({ xp: 100, reputationDelta: 2 })
  })

  it('applies WRONG_STYLE only through active Scenario Mutation data', () => {
    expect(
      resolveMutation(
        'checkout.confirmButton',
        'primary',
        runtime,
        T01_SCENARIO.mutations,
      ),
    ).toBe('secondary')
    expect(resolveMutation('checkout.confirmButton', 'primary', runtime, [])).toBe(
      'primary',
    )
  })

  it('changes output when only the Mutation payload changes', () => {
    const changedMutation = {
      ...T01_SCENARIO.mutations[0]!,
      payload: { value: 'warning' },
    }

    expect(
      resolveMutation('checkout.confirmButton', 'primary', runtime, [changedMutation]),
    ).toBe('warning')
  })
})
