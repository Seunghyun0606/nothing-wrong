import type { BugSeverity } from '../domain/schemas'

export const SEVERITY_GUIDE: Readonly<Record<BugSeverity, string>> = {
  LOW: 'Cosmetic or presentation issue. The customer can still finish the task correctly.',
  MEDIUM: 'Wrong data or money shown, or a rule applied incorrectly. A workaround exists.',
  HIGH: 'A core flow is blocked or sends the customer somewhere harmful, such as an unintended payment.',
  CRITICAL: 'Data loss, a security exposure, or the product is unusable for everyone.',
}
