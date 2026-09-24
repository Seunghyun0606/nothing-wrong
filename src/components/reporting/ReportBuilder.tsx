import { useState, type FormEvent } from 'react'

import type {
  BugSeverity,
  Evidence,
  PlayerAction,
  ReportStep,
} from '../../game/domain/schemas'
import type { CreateBugReportInput } from '../../game/reporting/createBugReport'

interface ReportBuilderProps {
  ticketId: string
  initialTitle: string
  evidence: readonly Evidence[]
  interactions: readonly PlayerAction[]
  expectedCandidates: readonly string[]
  actualCandidates: readonly string[]
  onSubmit: (input: CreateBugReportInput) => void
}

function actionLabel(action: PlayerAction): string {
  return `${action.type.replaceAll('_', ' ')}${action.target ? ` · ${action.target}` : ''}`
}

export function ReportBuilder({
  ticketId,
  initialTitle,
  evidence,
  interactions,
  expectedCandidates,
  actualCandidates,
  onSubmit,
}: ReportBuilderProps) {
  const [title, setTitle] = useState(initialTitle)
  const [expected, setExpected] = useState('')
  const [actual, setActual] = useState('')
  const [severity, setSeverity] = useState<BugSeverity>('LOW')
  const [selectedActions, setSelectedActions] = useState(
    () => new Set(interactions.map((action) => action.id)),
  )
  const [selectedEvidence, setSelectedEvidence] = useState(
    () => new Set(evidence.map((item) => item.id)),
  )

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

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const reproductionSteps: ReportStep[] = interactions
      .filter((action) => selectedActions.has(action.id))
      .map((action, order) => ({
        id: `STEP-${action.id}`,
        order,
        action: action.type,
        ...(action.target ? { target: action.target } : {}),
      }))

    onSubmit({
      ticketId,
      title,
      reproductionSteps,
      expected,
      actual,
      severity,
      evidenceIds: evidence
        .filter((item) => selectedEvidence.has(item.id))
        .map((item) => item.id),
    })
  }

  return (
    <form className="report-builder" onSubmit={submit}>
      <header className="report-builder-header">
        <div>
          <p className="kicker">Bug report · {ticketId}</p>
          <h1>Document what you can prove.</h1>
        </div>
        <p>Review uses the structure of your report, not hidden keyword matching.</p>
      </header>

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

        <label className="report-field">
          <span>Expected</span>
          <select
            aria-label="Expected behavior"
            required
            value={expected}
            onChange={(event) => setExpected(event.target.value)}
          >
            <option value="" disabled>Select the required behavior</option>
            {expectedCandidates.map((candidate) => (
              <option key={candidate}>{candidate}</option>
            ))}
          </select>
        </label>

        <label className="report-field">
          <span>Actual</span>
          <select
            aria-label="Actual behavior"
            required
            value={actual}
            onChange={(event) => setActual(event.target.value)}
          >
            <option value="" disabled>Select the observed behavior</option>
            {actualCandidates.map((candidate) => (
              <option key={candidate}>{candidate}</option>
            ))}
          </select>
        </label>

        <label className="report-field">
          <span>Severity</span>
          <select
            aria-label="Severity"
            value={severity}
            onChange={(event) => setSeverity(event.target.value as BugSeverity)}
          >
            {(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'] as const).map((value) => (
              <option key={value}>{value}</option>
            ))}
          </select>
        </label>

        <fieldset className="report-section report-evidence">
          <legend>Evidence</legend>
          <p>Only Evidence captured for this Ticket can be attached.</p>
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
            expected === '' ||
            actual === ''
          }
        >
          Submit for QA Review
        </button>
      </footer>
    </form>
  )
}
