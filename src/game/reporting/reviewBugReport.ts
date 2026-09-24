import type {
  BugReport,
  Evidence,
  ExpectedBug,
  ReviewResult,
  Scenario,
} from '../domain/schemas'
import { matchesMutationCondition } from '../mutations/resolveMutation'

function normalize(value: string): string {
  return value.trim().replace(/\s+/g, ' ').toLocaleLowerCase('en-US')
}

function visibleEvidenceTargets(evidence: Evidence): string[] {
  const directTargets = Array.isArray(evidence.snapshot.visibleTargets)
    ? evidence.snapshot.visibleTargets.filter(
        (target): target is string => typeof target === 'string',
      )
    : []
  const controlTargets = Array.isArray(evidence.snapshot.controls)
    ? evidence.snapshot.controls.flatMap((control) => {
        if (
          control !== null &&
          typeof control === 'object' &&
          typeof (control as Record<string, unknown>).target === 'string'
        ) {
          return [(control as Record<string, string>).target]
        }
        return []
      })
    : []

  return [...new Set([...directTargets, ...controlTargets])]
}

function evidenceMatchesBug(evidence: Evidence, expectedBug: ExpectedBug): boolean {
  return expectedBug.validEvidenceTargets.some((target) =>
    visibleEvidenceTargets(evidence).includes(target),
  )
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

function findMatch(
  report: BugReport,
  expectedBugs: readonly ExpectedBug[],
  evidence: readonly Evidence[],
): ExpectedBug | undefined {
  return expectedBugs.find(
    (bug) =>
      normalize(report.expected) === normalize(bug.expected) &&
      normalize(report.actual) === normalize(bug.actual),
  ) ?? expectedBugs.find((bug) => evidence.some((item) => evidenceMatchesBug(item, bug)))
}

export function reviewBugReport(
  report: BugReport,
  scenario: Scenario,
  availableEvidence: readonly Evidence[],
): ReviewResult {
  const claimedIds = new Set(report.evidenceIds)
  const evidence = availableEvidence.filter(
    (item) => item.ticketId === report.ticketId && claimedIds.has(item.id),
  )
  const expectedBug = findMatch(report, scenario.expectedBugs, evidence)
  const detectionMatches =
    expectedBug !== undefined &&
    normalize(report.expected) === normalize(expectedBug.expected) &&
    normalize(report.actual) === normalize(expectedBug.actual)
  const reproductionMatches =
    expectedBug !== undefined &&
    report.reproductionSteps.length > 0 &&
    hasOrderedSteps(report) &&
    (expectedBug.reproductionConditions.length === 0 ||
      evidence.some((item) => conditionsMatchEvidence(item, expectedBug)))
  const evidenceMatches =
    expectedBug !== undefined && evidence.some((item) => evidenceMatchesBug(item, expectedBug))
  const severityMatches = expectedBug !== undefined && report.severity === expectedBug.severity

  const scores = {
    detection: detectionMatches ? scenario.scoring.detection : 0,
    reproduction: reproductionMatches ? scenario.scoring.reproduction : 0,
    evidence: evidenceMatches ? scenario.scoring.evidence : 0,
    severity: severityMatches ? scenario.scoring.severity : 0,
  }
  const totalScore = Object.values(scores).reduce((total, score) => total + score, 0)
  const valid = detectionMatches && reproductionMatches && evidenceMatches
  const feedback = [
    detectionMatches
      ? 'The expected and actual behavior identify the canonical defect.'
      : 'Expected and actual behavior do not identify the documented defect.',
    reproductionMatches
      ? 'The reproduction path is complete and ordered.'
      : 'Add an ordered reproduction path that reaches the failing state.',
    evidenceMatches
      ? 'Captured Evidence shows the affected target in the required context.'
      : 'Attach captured Evidence that shows the affected target.',
    severityMatches
      ? 'Severity matches the impact of this issue.'
      : 'Reconsider the severity based on the issue impact.',
  ]

  return {
    valid,
    ...(expectedBug ? { matchedBugId: expectedBug.id } : {}),
    scores,
    totalScore,
    xp: valid ? (scenario.progression?.xp ?? 0) : 0,
    reputationDelta: valid ? (scenario.progression?.reputationDelta ?? 0) : -2,
    feedback,
  }
}
