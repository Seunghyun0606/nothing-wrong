import { useMemo, useState, type FormEvent } from 'react'

import type {
  BugSeverity,
  Evidence,
  PlayerAction,
  ReportStep,
  Requirement,
} from '../../game/domain/schemas'
import { describeObservation, observationsOf } from '../../game/evidence/observations'
import type { CreateBugReportInput } from '../../game/reporting/createBugReport'
import { SEVERITY_GUIDE } from '../../game/reporting/severityGuide'

interface ReportBuilderProps {
  ticketId: string
  initialTitle: string
  requirements: readonly Requirement[]
  evidence: readonly Evidence[]
  interactions: readonly PlayerAction[]
  guideSteps?: readonly string[]
  onSubmit: (input: CreateBugReportInput) => void
}

const SEVERITIES = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'] as const

function describePayload(payload: Record<string, unknown> | undefined): string | undefined {
  if (!payload) return undefined
  const parts = Object.entries(payload)
    .filter(([key, value]) =>
      !key.endsWith('Id') && ['string', 'number', 'boolean'].includes(typeof value),
    )
    .map(([key, value]) => `${key}=${String(value)}`)
  return parts.length > 0 ? parts.join(', ') : undefined
}

function actionLabel(action: PlayerAction): string {
  const details = describePayload(action.payload)
  return [
    action.type.replaceAll('_', ' '),
    action.target,
    details,
  ].filter(Boolean).join(' · ')
}

function observationKey(evidenceId: string, target: string): string {
  return `${evidenceId}::${target}`
}

export function ReportBuilder({
  ticketId,
  initialTitle,
  requirements,
  evidence,
  interactions,
  guideSteps,
  onSubmit,
}: ReportBuilderProps) {
  const [title, setTitle] = useState(initialTitle)
  const [requirementId, setRequirementId] = useState('')
  const [selectedObservation, setSelectedObservation] = useState('')
  const [severity, setSeverity] = useState<BugSeverity | ''>('')
  const [confirmingNoIssue, setConfirmingNoIssue] = useState(false)
  const [selectedActions, setSelectedActions] = useState(
    () => new Set(interactions.map((action) => action.id)),
  )
  const [selectedEvidence, setSelectedEvidence] = useState(
    () => new Set(evidence.slice(-1).map((item) => item.id)),
  )

  const captures = useMemo(
    () =>
      [...evidence].reverse().map((item) => ({
        evidence: item,
        observations: observationsOf(item),
      })),
    [evidence],
  )
  const requirement = requirements.find((candidate) => candidate.id === requirementId)
  const observation = captures
    .flatMap(({ evidence: item, observations }) =>
      observations.map((entry) => ({ evidenceId: item.id, ...entry })),
    )
    .find((entry) => observationKey(entry.evidenceId, entry.target) === selectedObservation)

  function toggleSelection(
    id: string,
    selected: Set<string>,
    update: (value: Set<string>) => void,
  ) {
    const next = new Set(selected)
    if (next.has(id)) next.delete(id)
    else next.add(id)
    update(next)
  }

  function selectObservation(evidenceId: string, target: string) {
    setSelectedObservation(observationKey(evidenceId, target))
    setSelectedEvidence((current) => new Set(current).add(evidenceId))
  }

  function reproductionSteps(): ReportStep[] {
    return interactions
      .filter((action) => selectedActions.has(action.id))
      .map((action, order) => {
        const details = describePayload(action.payload)
        return {
          id: `STEP-${action.id}`,
          order,
          action: action.type,
          ...(action.target ? { target: action.target } : {}),
          ...(details ? { details } : {}),
          ...(action.payload ? { payload: action.payload } : {}),
        }
      })
  }

  function attachedEvidenceIds(): string[] {
    return evidence.filter((item) => selectedEvidence.has(item.id)).map((item) => item.id)
  }

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (!requirement || !observation || severity === '') return

    onSubmit({
      ticketId,
      kind: 'BUG',
      title,
      reproductionSteps: reproductionSteps(),
      requirementId: requirement.id,
      observation: {
        evidenceId: observation.evidenceId,
        target: observation.target,
        label: observation.label,
        value: observation.value,
      },
      expected: requirement.description,
      actual: describeObservation(observation),
      severity,
      evidenceIds: attachedEvidenceIds(),
    })
  }

  function submitNoIssue() {
    onSubmit({
      ticketId,
      kind: 'NO_ISSUE',
      title: `${ticketId}: NO ISSUE FOUND`,
      reproductionSteps: reproductionSteps(),
      expected: 'Every requirement in scope is met',
      actual: 'No defect observed',
      evidenceIds: attachedEvidenceIds(),
    })
  }

  return (
    <form className="report-builder" onSubmit={submit}>
      <header className="report-builder-header">
        <div>
          <p className="kicker">Bug report · {ticketId}</p>
          <h1>Document what you can prove.</h1>
        </div>
        <p>Match a requirement to something you actually captured. Review checks the structure, not keywords.</p>
      </header>

      {guideSteps && guideSteps.length > 0 && (
        <section className="first-ticket-report-guide" aria-label="Report guide">
          <p className="card-label">Report guide</p>
          <ol>
            {guideSteps.map((step) => <li key={step}>{step}</li>)}
          </ol>
        </section>
      )}

      <div className="report-form-grid">
        <label className="report-field report-field-wide">
          <span>Title</span>
          <input
            aria-label="Report title"
            required
            value={title}
            onChange={(event) => setTitle(event.target.value)}
          />
        </label>

        <fieldset className="report-section report-field-wide">
          <legend>Reproduction steps</legend>
          <p>Select the recorded actions that make the issue reproducible.</p>
          <div className="report-choice-list">
            {interactions.map((action, index) => (
              <label key={action.id}>
                <input
                  type="checkbox"
                  checked={selectedActions.has(action.id)}
                  onChange={() =>
                    toggleSelection(action.id, selectedActions, setSelectedActions)
                  }
                />
                <strong>{index + 1}</strong>
                <span>{actionLabel(action)}</span>
              </label>
            ))}
          </div>
        </fieldset>

        <fieldset className="report-section requirement-choices">
          <legend>Expected · Which requirement is not met?</legend>
          <div className="report-choice-list">
            {requirements.map((candidate) => (
              <label key={candidate.id}>
                <input
                  type="radio"
                  name="requirement"
                  checked={requirementId === candidate.id}
                  onChange={() => setRequirementId(candidate.id)}
                />
                <strong>{candidate.id.replace(/^REQ-/, '')}</strong>
                <span>{candidate.description}</span>
              </label>
            ))}
          </div>
        </fieldset>

        <fieldset className="report-section">
          <legend>Actual · Which captured observation shows it?</legend>
          <div className="observation-groups">
            {captures.map(({ evidence: item, observations }) => (
              <div className="observation-group" key={item.id}>
                <p>{item.preview}</p>
                {observations.length === 0 ? (
                  <small>No observable values on this capture.</small>
                ) : (
                  <div className="report-choice-list">
                    {observations.map((entry) => (
                      <label key={entry.target}>
                        <input
                          type="radio"
                          name="observation"
                          checked={selectedObservation === observationKey(item.id, entry.target)}
                          onChange={() => selectObservation(item.id, entry.target)}
                        />
                        <span>{describeObservation(entry)}</span>
                      </label>
                    ))}
                  </div>
                )}
              </div>
            ))}
          </div>
        </fieldset>

        <fieldset className="report-section report-field-wide severity-guide">
          <legend>Severity</legend>
          <div className="severity-options">
            {SEVERITIES.map((value) => (
              <label key={value}>
                <input
                  type="radio"
                  name="severity"
                  checked={severity === value}
                  onChange={() => setSeverity(value)}
                />
                <strong>{value}</strong>
                <span>{SEVERITY_GUIDE[value]}</span>
              </label>
            ))}
          </div>
        </fieldset>

        <fieldset className="report-section report-evidence report-field-wide">
          <legend>Evidence</legend>
          <p>Attach the captures that show the problem. Unrelated captures weaken the Report.</p>
          <div className="report-choice-list">
            {evidence.map((item) => (
              <label key={item.id}>
                <input
                  type="checkbox"
                  checked={selectedEvidence.has(item.id)}
                  onChange={() =>
                    toggleSelection(item.id, selectedEvidence, setSelectedEvidence)
                  }
                />
                <span>{item.preview}</span>
              </label>
            ))}
          </div>
        </fieldset>
      </div>

      <footer className="report-builder-footer">
        <span>{selectedActions.size} steps · {selectedEvidence.size} Evidence attached</span>
        <button
          className="button button-primary"
          type="submit"
          disabled={
            selectedActions.size === 0 ||
            selectedEvidence.size === 0 ||
            !requirement ||
            !observation ||
            severity === ''
          }
        >
          Submit for QA Review
        </button>
      </footer>

      <section className="no-issue-panel" aria-label="No issue found">
        <div>
          <p className="card-label">Nothing wrong?</p>
          <p>
            If every requirement in scope holds, close the Ticket as <strong>NO ISSUE FOUND</strong>.
            Attach Evidence of what you checked. Missing a real defect costs Reputation.
          </p>
        </div>
        {confirmingNoIssue ? (
          <div className="no-issue-confirm">
            <button
              className="button button-secondary"
              type="button"
              disabled={selectedEvidence.size === 0}
              onClick={submitNoIssue}
            >
              Confirm NO ISSUE FOUND
            </button>
            <button className="text-link" type="button" onClick={() => setConfirmingNoIssue(false)}>
              Keep investigating
            </button>
          </div>
        ) : (
          <button className="button button-secondary" type="button" onClick={() => setConfirmingNoIssue(true)}>
            Submit NO ISSUE FOUND
          </button>
        )}
      </section>
    </form>
  )
}
