import type { Mutation } from '../domain/schemas'
import {
  isMutationActive,
  matchesMutationCondition,
  resolveMutation,
  type MutationRuntimeContext,
} from './resolveMutation'

const goldContext: MutationRuntimeContext = {
  test: {
    account: 'GOLD',
    viewport: 'DESKTOP',
    locale: 'en-US',
    currentPath: '/checkout',
  },
  productState: {
    cart: { quantity: 3 },
    coupon: 'SAVE20',
  },
}

const conditionalMutation: Mutation = {
  id: 'MUTATION-CONDITIONAL',
  type: 'WRONG_CALCULATION',
  target: 'checkout.discountRate',
  conditions: [
    { field: 'account', operator: 'EQ', value: 'GOLD' },
    { field: 'coupon', operator: 'EQ', value: 'SAVE20' },
    { field: 'cart.quantity', operator: 'GTE', value: 3 },
  ],
  payload: { value: 0.1 },
}

describe('Mutation conditions', () => {
  it.each([
    ['EQ', 'GOLD', true],
    ['NEQ', 'BASIC', true],
    ['GT', 2, true],
    ['GTE', 3, true],
    ['LT', 4, true],
    ['LTE', 3, true],
    ['IN', [1, 3, 5], true],
  ] as const)('evaluates %s conditions', (operator, value, expected) => {
    const field = typeof value === 'string' ? 'account' : 'cart.quantity'

    expect(
      matchesMutationCondition({ field, operator, value }, goldContext),
    ).toBe(expected)
  })

  it('activates when every TestContext and Product condition matches', () => {
    expect(isMutationActive(conditionalMutation, goldContext)).toBe(true)
    expect(
      resolveMutation(
        'checkout.discountRate',
        0.2,
        goldContext,
        [conditionalMutation],
      ),
    ).toBe(0.1)
  })

  it('stays inactive for a negative account case', () => {
    const basicContext: MutationRuntimeContext = {
      ...goldContext,
      test: { ...goldContext.test, account: 'BASIC' },
    }

    expect(isMutationActive(conditionalMutation, basicContext)).toBe(false)
    expect(
      resolveMutation(
        'checkout.discountRate',
        0.2,
        basicContext,
        [conditionalMutation],
      ),
    ).toBe(0.2)
  })

  it('stays inactive for a negative Product state case', () => {
    const lowQuantityContext: MutationRuntimeContext = {
      ...goldContext,
      productState: { ...goldContext.productState, cart: { quantity: 1 } },
    }

    expect(isMutationActive(conditionalMutation, lowQuantityContext)).toBe(false)
  })

  it('supports explicit test/product prefixes and IN membership', () => {
    expect(
      matchesMutationCondition(
        { field: 'test.viewport', operator: 'IN', value: ['MOBILE', 'DESKTOP'] },
        goldContext,
      ),
    ).toBe(true)
    expect(
      matchesMutationCondition(
        { field: 'product.cart.quantity', operator: 'LT', value: 4 },
        goldContext,
      ),
    ).toBe(true)
  })

  it('returns false for missing fields and incompatible comparisons', () => {
    expect(
      matchesMutationCondition(
        { field: 'cart.missing', operator: 'EQ', value: true },
        goldContext,
      ),
    ).toBe(false)
    expect(
      matchesMutationCondition(
        { field: 'cart.quantity', operator: 'GT', value: '2' },
        goldContext,
      ),
    ).toBe(false)
  })
})

describe('resolveMutation', () => {
  it('returns the base value when no matching Mutation exists', () => {
    expect(resolveMutation('product.title', 'Normal', goldContext, [])).toBe('Normal')
    expect(
      resolveMutation('product.title', 'Normal', goldContext, [conditionalMutation]),
    ).toBe('Normal')
  })

  it('returns the base value when an active Mutation has no value payload', () => {
    const metadataOnlyMutation: Mutation = {
      id: 'MUTATION-METADATA',
      type: 'WRONG_STYLE',
      target: 'checkout.confirmButton',
      payload: { className: 'secondary' },
    }

    expect(
      resolveMutation(
        'checkout.confirmButton',
        'primary',
        goldContext,
        [metadataOnlyMutation],
      ),
    ).toBe('primary')
  })
})
