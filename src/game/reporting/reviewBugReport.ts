import type {
  ActionMatcher,
  BugReport,
  Evidence,
  ExpectedBug,
  ReportStep,
  ReviewResult,
  Scenario,
} from '../domain/schemas'
import { observationsOf } from '../evidence/observations'
import { matchesMutationCondition } from '../mutations/resolveMutation'

/** Selected steps beyond the required actions before Reproduction loses points. */
export const STEP_NOISE_ALLOWANCE = 12
export const NOISE_PENALTY = 5
export const FALSE_REPORT_REPUTATION = -2
export const CORRECT_NO_ISSUE_REPUTATION = 2

function normalize(value: string): string {
  return value.trim().replace(/\s+/g, ' ').toLocaleLowerCase('en-US')
}

function evidenceShowsBug(evidence: Evidence, expectedBug: ExpectedBug): boolean {
  const targets = observationsOf(evidence).map((observation) => observation.target)
  return expectedBug.validEvidenceTargets.some((target) => targets.includes(target))
}

function conditionsMatchEvidence(
  evidence: Evidence,
  expectedBug: ExpectedBug,
): boolean {
  const productState =
    evidence.snapshot.productState !== null &&
    typeof evidence.snapshot.productState === 'object' &&
    !Array.isArray(evidence.snapshot.productState)
      ? (evidence.snapshot.productState as Record<string, unknown>)
      : evidence.snapshot

  return expectedBug.reproductionConditions.every((condition) =>
    matchesMutationCondition(condition, {
      test: evidence.context,
      productState,
    }),
  )
}

function hasOrderedSteps(report: BugReport): boolean {
  return report.reproductionSteps.every((step, index) => step.order === index)
}

function stepMatches(step: ReportStep, matcher: ActionMatcher): boolean {
  if (step.action !== matcher.type) return false
  if (matcher.target !== undefined && step.target !== matcher.target) return false

  return Object.entries(matcher.payload ?? {}).every(([key, value]) =>
    Object.is(step.payload?.[key], value),
  )
}

interface BugEvaluation {
  bug: ExpectedBug
  result: ReviewResult
}

function evaluateBug(
  report: BugReport,
  scenario: Scenario,
  bug: ExpectedBug,
  ticketEvidence: readonly Evidence[],
  attached: readonly Evidence[],
): BugEvaluation {
  const requirementMatches = bug.requirementId
    ? report.requirementId === bug.requirementId
    : normalize(report.expected) === normalize(bug.expected)

  const observation = report.observation
  const observationEvidence = observation
    ? ticketEvidence.find((item) => item.id === observation.evidenceId)
    : undefined
  const observationTargetValid =
    observation !== undefined &&
    observationEvidence !== undefined &&
    bug.validEvidenceTargets.includes(observation.target) &&
    observationsOf(observationEvidence).some((item) => item.target === observation.target)
  const observationInFailingState =
    observationEvidence !== undefined && conditionsMatchEvidence(observationEvidence, bug)
  const observationMatches = observation
    ? observationTargetValid && observationInFailingState
    : normalize(report.actual) === normalize(bug.actual)
  const detectionMatches = requirementMatches && observationMatches

  const requiredActions = bug.reproductionActions ?? []
  const missingActions = requiredActions.filter(
    (matcher) => !report.reproductionSteps.some((step) => stepMatches(step, matcher)),
  )
  const failingStateEvidence = attached.filter(
    (item) => evidenceShowsBug(item, bug) && conditionsMatchEvidence(item, bug),
  )
  const reachedFailingState =
    bug.reproductionConditions.length === 0 ||
    attached.some((item) => conditionsMatchEvidence(item, bug))
  const reproductionMatches =
    report.reproductionSteps.length > 0 &&
    hasOrderedSteps(report) &&
    missingActions.length === 0 &&
    reachedFailingState
  const noisySteps =
    report.reproductionSteps.length > requiredActions.length + STEP_NOISE_ALLOWANCE
  const evidenceMatches = failingStateEvidence.length > 0
  const noisyEvidence =
    attached.length >= 3 && attached.length - failingStateEvidence.length > failingStateEvidence.length
  const severityMatches = report.severity === bug.severity

  const scores = {
    detection: detectionMatches ? scenario.scoring.detection : 0,
    reproduction: reproductionMatches
      ? Math.max(0, scenario.scoring.reproduction - (noisySteps ? NOISE_PENALTY : 0))
      : 0,
    evidence: evidenceMatches
      ? Math.max(0, scenario.scoring.evidence - (noisyEvidence ? NOISE_PENALTY : 0))
      : 0,
    severity: severityMatches ? scenario.scoring.severity : 0,
  }
  const valid = detectionMatches && reproductionMatches && evidenceMatches

  const detectionFeedback = detectionMatches
    ? 'You matched the right requirement to an observation that breaks it.'
    : !requirementMatches && observationMatches
      ? 'Your observation shows a real defect, but the selected requirement is not the one it breaks. Which rule does that value contradict?'
      : requirementMatches && observationTargetValid && !observationInFailingState
        ? 'The selected observation was captured before the failure appeared, so it still meets the requirement. Reproduce the failure, then capture again.'
        : requirementMatches
          ? 'The selected observation does not show the problem. Pick the captured value that contradicts the requirement.'
          : 'Neither the requirement nor the observation identifies a defect yet. Re-read the requirements and compare them with what you captured.'
  const reproductionFeedback = reproductionMatches
    ? noisySteps
      ? `Another tester could repeat this, but ${report.reproductionSteps.length} steps is a lot. Keep only the actions that matter.`
      : 'Another tester could repeat this path.'
    : missingActions.length > 0
      ? `Your steps skip: ${missingActions.map((matcher) => matcher.label).join('; ')}.`
      : !reachedFailingState
        ? 'None of the attached Evidence was captured in the failing state.'
        : 'Add an ordered reproduction path that reaches the failing state.'
  const evidenceFeedback = evidenceMatches
    ? noisyEvidence
      ? 'Attached Evidence shows the defect, but several attachments do not. Leave those out next time.'
      : 'Attached Evidence shows the defect in the failing state.'
    : 'Attach Evidence captured while the defect was on screen.'
  const severityFeedback = severityMatches
    ? 'Severity matches the impact of this issue.'
    : 'Reconsider the severity using the severity guide.'

  return {
    bug,
    result: {
      valid,
      ...(detectionMatches ? { matchedBugId: bug.id } : {}),
      scores,
      totalScore: Object.values(scores).reduce((total, score) => total + score, 0),
      xp: valid ? (scenario.progression?.xp ?? 0) : 0,
      reputationDelta: valid
        ? (scenario.progression?.reputationDelta ?? 0)
        : FALSE_REPORT_REPUTATION,
      feedback: [detectionFeedback, reproductionFeedback, evidenceFeedback, severityFeedback],
    },
  }
}

function reviewNoIssue(
  report: BugReport,
  scenario: Scenario,
  attached: readonly Evidence[],
): ReviewResult {
  if (scenario.expectedBugs.length > 0) {
    return {
      valid: false,
      scores: { detection: 0, reproduction: 0, evidence: 0, severity: 0 },
      totalScore: 0,
      xp: 0,
      reputationDelta: FALSE_REPORT_REPUTATION,
      feedback: [
        'A documented defect exists within this Ticket scope, so NO ISSUE FOUND misses it.',
        'Compare every requirement with what Shoply actually shows, including different quantities, accounts, and actions.',
      ],
    }
  }

  const covered = attached.length > 0
  const scores = {
    detection: scenario.scoring.detection,
    reproduction: report.reproductionSteps.length > 0 ? scenario.scoring.reproduction : 0,
    evidence: covered ? scenario.scoring.evidence : 0,
    severity: scenario.scoring.severity,
  }

  return {
    valid: covered,
    scores,
    totalScore: Object.values(scores).reduce((total, score) => total + score, 0),
    xp: covered ? (scenario.progression?.xp ?? 0) : 0,
    reputationDelta: covered
      ? (scenario.progression?.reputationDelta ?? CORRECT_NO_ISSUE_REPUTATION)
      : 0,
    feedback: covered
      ? ['Correct call. Every requirement in scope holds, and your Evidence shows what you checked.']
      : ['Attach Evidence of the screens you checked before closing a Ticket as NO ISSUE FOUND.'],
  }
}

export function reviewBugReport(
  report: BugReport,
  scenario: Scenario,
  availableEvidence: readonly Evidence[],
): ReviewResult {
  const ticketEvidence = availableEvidence.filter((item) => item.ticketId === report.ticketId)
  const claimedIds = new Set(report.evidenceIds)
  const attached = ticketEvidence.filter((item) => claimedIds.has(item.id))

  if (report.kind === 'NO_ISSUE') {
    return reviewNoIssue(report, scenario, attached)
  }

  if (scenario.expectedBugs.length === 0) {
    return {
      valid: false,
      scores: { detection: 0, reproduction: 0, evidence: 0, severity: 0 },
      totalScore: 0,
      xp: 0,
      reputationDelta: FALSE_REPORT_REPUTATION,
      feedback: [
        'Every requirement in this Ticket scope holds. This Report is a false positive.',
        'When the product matches the requirements, close the Ticket as NO ISSUE FOUND.',
      ],
    }
  }

  const evaluations = scenario.expectedBugs.map((bug) =>
    evaluateBug(report, scenario, bug, ticketEvidence, attached),
  )
  const best = evaluations.reduce((leader, candidate) =>
    candidate.result.totalScore > leader.result.totalScore ? candidate : leader,
  )

  return best.result
}
