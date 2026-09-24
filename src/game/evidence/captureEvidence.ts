import {
  EvidenceSchema,
  type Evidence,
  type TestContext,
} from '../domain/schemas'

interface CaptureEvidenceInput {
  ticketId: string
  context: TestContext
  snapshot: Record<string, unknown>
  preview: string
  capturedAt?: number
  id?: string
}

function createEvidenceId(capturedAt: number): string {
  const suffix =
    typeof globalThis.crypto?.randomUUID === 'function'
      ? globalThis.crypto.randomUUID()
      : Math.random().toString(36).slice(2)

  return `EVIDENCE-${capturedAt}-${suffix}`
}

export function captureEvidence(input: CaptureEvidenceInput): Evidence {
  const capturedAt = input.capturedAt ?? Date.now()

  return EvidenceSchema.parse({
    id: input.id ?? createEvidenceId(capturedAt),
    ticketId: input.ticketId,
    type: 'SCREENSHOT',
    preview: input.preview,
    capturedAt,
    context: input.context,
    snapshot: input.snapshot,
  })
}
