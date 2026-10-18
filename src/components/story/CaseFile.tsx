import type { GameState, Scenario, StoryChapter } from '../../game/domain/schemas'

interface CaseFileProps {
  chapter: StoryChapter
  scenarios: readonly Scenario[]
  state: GameState
}

export function CaseFile({ chapter, scenarios, state }: CaseFileProps) {
  const beats = scenarios.filter((scenario) => scenario.story?.chapterId === chapter.id)
  const closed = state.story.deductions[chapter.finaleDeductionId]?.solved ?? false
  const found = beats.filter((scenario) => state.tickets[scenario.ticket.id]?.status === 'RESOLVED')

  return (
    <section className="case-file" aria-labelledby="case-file-heading">
      <div className="section-heading">
        <div>
          <p className="kicker">Case file</p>
          <h2 id="case-file-heading">{chapter.title}</h2>
        </div>
        <span>{closed ? 'Case closed' : `${found.length} / ${beats.length} clues`}</span>
      </div>
      <p className="case-synopsis">{chapter.synopsis}</p>
      <ol className="clue-list">
        {beats.map((scenario) => {
          const story = scenario.story!
          const resolved = state.tickets[scenario.ticket.id]?.status === 'RESOLVED'
          const connected = story.deduction
            ? (state.story.deductions[story.deduction.id]?.solved ?? false)
            : resolved
          return resolved ? (
            <li className="clue-card" key={story.clue.id}>
              <span className="ticket-id">{scenario.ticket.id}</span>
              <div>
                <strong>{story.clue.title}</strong>
                <p>{story.clue.text}</p>
              </div>
              <span className="clue-status">{connected ? 'Connected' : 'Not yet connected'}</span>
            </li>
          ) : (
            <li className="clue-card clue-locked" key={story.clue.id}>
              <span className="ticket-id">{scenario.ticket.id}</span>
              <div>
                <strong>Unknown clue</strong>
                <p>Resolve {scenario.ticket.id} to uncover it.</p>
              </div>
            </li>
          )
        })}
      </ol>
      {closed && (
        <p className="case-teaser">
          <strong>{chapter.epilogue.at(-1)?.from}:</strong> {chapter.epilogue.at(-1)?.text}
        </p>
      )}
    </section>
  )
}
