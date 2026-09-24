import {
  BugReportSchema,
  type BugReport,
  type BugSeverity,
  type Evidence,
  type ReportStep,
} from '../domain/schemas'

export interface CreateBugReportInput {
  id?: string
  ticketId: string
  title: string
  reproductionSteps: ReportStep[]
  expected: string
  actual: string
  severity: BugSeverity
  evidenceIds: string[]
  submittedAt?: number
}

export class InvalidEvidenceClaimError extends Error {
  constructor(evidenceId: string) {
    super(`Evidence ${evidenceId} was not captured for this Ticket`)
    this.name = 'InvalidEvidenceClaimError'
  }
}

function createReportId(submittedAt: number): string {
  const suffix =
    typeof globalThis.crypto?.randomUUID === 'function'
      ? globalThis.crypto.randomUUID()
      : Math.random().toString(36).slice(2)
  return `REPORT-${submittedAt}-${suffix}`
}

export function createBugReport(
  input: CreateBugReportInput,
  capturedEvidence: readonly Evidence[],
): BugReport {
  const evidenceById = new Map(
    capturedEvidence
      .filter((evidence) => evidence.ticketId === input.ticketId)
      .map((evidence) => [evidence.id, evidence]),
  )

  for (const evidenceId of input.evidenceIds) {
    if (!evidenceById.has(evidenceId)) {
      throw new InvalidEvidenceClaimError(evidenceId)
    }
  }

  const submittedAt = input.submittedAt ?? Date.now()
  return BugReportSchema.parse({
    ...input,
    id: input.id ?? createReportId(submittedAt),
    evidenceIds: [...new Set(input.evidenceIds)],
    submittedAt,
  })
}
