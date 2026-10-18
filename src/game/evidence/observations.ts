import type { Evidence } from '../domain/schemas'

export interface EvidenceObservation {
  target: string
  label: string
  value: string
}

function readControl(control: unknown): EvidenceObservation | undefined {
  if (control === null || typeof control !== 'object') return undefined

  const record = control as Record<string, unknown>
  if (typeof record.target !== 'string' || record.target === '') return undefined

  return {
    target: record.target,
    label: typeof record.label === 'string' && record.label !== '' ? record.label : record.target,
    value: typeof record.value === 'string'
      ? record.value
      : typeof record.text === 'string'
        ? record.text
        : '',
  }
}

/** Lists what a capture recorded, one entry per observed product target. */
export function observationsOf(evidence: Evidence): EvidenceObservation[] {
  const controls = Array.isArray(evidence.snapshot.controls)
    ? evidence.snapshot.controls.flatMap((control) => readControl(control) ?? [])
    : []
  const listedTargets = new Set(controls.map((observation) => observation.target))
  const bareTargets = Array.isArray(evidence.snapshot.visibleTargets)
    ? evidence.snapshot.visibleTargets.filter(
        (target): target is string =>
          typeof target === 'string' && target !== '' && !listedTargets.has(target),
      )
    : []

  const observations = [
    ...controls,
    ...bareTargets.map((target) => ({ target, label: target, value: '' })),
  ]
  const seen = new Set<string>()
  return observations.filter((observation) => {
    if (seen.has(observation.target)) return false
    seen.add(observation.target)
    return true
  })
}

export function describeObservation(observation: EvidenceObservation): string {
  return observation.value ? `${observation.label}: ${observation.value}` : observation.label
}
