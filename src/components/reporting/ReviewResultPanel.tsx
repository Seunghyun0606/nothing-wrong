import type { ReviewResult } from '../../game/domain/schemas'

const SCORE_LABELS = {
  detection: 'Detection',
  reproduction: 'Reproduction',
  evidence: 'Evidence',
  severity: 'Severity',
} as const

interface ReviewResultPanelProps {
  result: ReviewResult
}

export function ReviewResultPanel({ result }: ReviewResultPanelProps) {
  return (
    <article className="review-result">
      <header className={result.valid ? 'review-valid' : 'review-invalid'}>
        <p>QA REVIEW</p>
        <h1>{result.valid ? 'VALID' : 'INVALID'}</h1>
        <span>{result.totalScore} / 100</span>
      </header>

      <section className="review-scores" aria-label="Review scores">
        {Object.entries(result.scores).map(([category, score]) => (
          <div key={category}>
            <span>{SCORE_LABELS[category as keyof typeof SCORE_LABELS]}</span>
            <strong>{score}</strong>
          </div>
        ))}
      </section>

      <section className="review-reward" aria-label="Progression reward">
        <div><span>XP</span><strong>+{result.xp}</strong></div>
        <div>
          <span>Reputation</span>
          <strong>{result.reputationDelta >= 0 ? '+' : ''}{result.reputationDelta}</strong>
        </div>
      </section>

      <section className="review-feedback">
        <p className="card-label">Lead feedback</p>
        <ul>{result.feedback.map((item) => <li key={item}>{item}</li>)}</ul>
      </section>
    </article>
  )
}
