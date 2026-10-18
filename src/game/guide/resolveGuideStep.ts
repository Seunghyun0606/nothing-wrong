import type { GuideStep } from '../domain/schemas'
import {
  matchesMutationCondition,
  type MutationRuntimeContext,
} from '../mutations/resolveMutation'

/** Returns the first guide step whose conditions all hold; list the fallback step last. */
export function resolveGuideStep(
  steps: readonly GuideStep[],
  context: MutationRuntimeContext,
): GuideStep | undefined {
  return steps.find((step) =>
    step.conditions.every((condition) => matchesMutationCondition(condition, context)),
  )
}
