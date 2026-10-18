import type {
  Mutation,
  MutationCondition,
  TestContext,
} from '../domain/schemas'

export interface MutationRuntimeContext {
  test: TestContext
  productState: Readonly<Record<string, unknown>>
  workspace?: Readonly<Record<string, unknown>>
}

const MISSING = Symbol('missing')

function readPath(source: unknown, path: string): unknown | typeof MISSING {
  const segments = path.split('.').filter(Boolean)
  let current: unknown = source

  for (const segment of segments) {
    if (
      current === null ||
      typeof current !== 'object' ||
      !Object.prototype.hasOwnProperty.call(current, segment)
    ) {
      return MISSING
    }

    current = (current as Record<string, unknown>)[segment]
  }

  return current
}

function readConditionValue(
  field: string,
  context: MutationRuntimeContext,
): unknown | typeof MISSING {
  if (field.startsWith('test.')) {
    return readPath(context.test, field.slice('test.'.length))
  }

  if (field.startsWith('product.')) {
    return readPath(context.productState, field.slice('product.'.length))
  }

  if (field.startsWith('workspace.')) {
    return readPath(context.workspace ?? {}, field.slice('workspace.'.length))
  }

  const testValue = readPath(context.test, field)
  return testValue === MISSING ? readPath(context.productState, field) : testValue
}

function compareOrdered(actual: unknown, expected: unknown, operator: string): boolean {
  const sameComparableType =
    (typeof actual === 'number' && typeof expected === 'number') ||
    (typeof actual === 'string' && typeof expected === 'string')

  if (!sameComparableType) {
    return false
  }

  if (operator === 'GT') return actual > expected
  if (operator === 'GTE') return actual >= expected
  if (operator === 'LT') return actual < expected
  return actual <= expected
}

export function matchesMutationCondition(
  condition: MutationCondition,
  context: MutationRuntimeContext,
): boolean {
  const actual = readConditionValue(condition.field, context)

  if (actual === MISSING) {
    return false
  }

  switch (condition.operator) {
    case 'EQ':
      return Object.is(actual, condition.value)
    case 'NEQ':
      return !Object.is(actual, condition.value)
    case 'GT':
    case 'GTE':
    case 'LT':
    case 'LTE':
      return compareOrdered(actual, condition.value, condition.operator)
    case 'IN':
      return (
        Array.isArray(condition.value) &&
        condition.value.some((candidate) => Object.is(candidate, actual))
      )
    case 'INCLUDES':
      return (
        Array.isArray(actual) &&
        actual.some((candidate) => Object.is(candidate, condition.value))
      )
    case 'STARTS_WITH':
      return (
        typeof actual === 'string' &&
        typeof condition.value === 'string' &&
        actual.startsWith(condition.value)
      )
  }
}

export function isMutationActive(
  mutation: Mutation,
  context: MutationRuntimeContext,
): boolean {
  return (mutation.conditions ?? []).every((condition) =>
    matchesMutationCondition(condition, context),
  )
}

export function findActiveMutation(
  target: string,
  context: MutationRuntimeContext,
  mutations: readonly Mutation[],
): Mutation | undefined {
  return mutations.find(
    (mutation) => mutation.target === target && isMutationActive(mutation, context),
  )
}

export function resolveMutation<T>(
  target: string,
  baseValue: T,
  context: MutationRuntimeContext,
  mutations: readonly Mutation[],
): T {
  const mutation = findActiveMutation(target, context, mutations)

  if (!mutation || !Object.prototype.hasOwnProperty.call(mutation.payload, 'value')) {
    return baseValue
  }

  return mutation.payload.value as T
}
