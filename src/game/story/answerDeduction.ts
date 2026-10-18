import { GameStateSchema, type Deduction, type GameState } from '../domain/schemas'

/** Reputation for connecting the clues on the first attempt. Wrong guesses cost nothing. */
export const FIRST_TRY_DEDUCTION_BONUS = 1

export function answerDeduction(
  state: GameState,
  deduction: Deduction,
  optionId: string,
): GameState {
  const option = deduction.options.find((candidate) => candidate.id === optionId)
  if (!option) {
    throw new Error(`Unknown option ${optionId} for Deduction ${deduction.id}`)
  }

  const progress = state.story.deductions[deduction.id] ?? { attempts: [], solved: false }
  if (progress.solved) return state

  const attempts = [...progress.attempts, option.id]
  const firstTry = option.correct && attempts.length === 1

  return GameStateSchema.parse({
    ...state,
    profile: {
      ...state.profile,
      reputation: state.profile.reputation + (firstTry ? FIRST_TRY_DEDUCTION_BONUS : 0),
    },
    story: {
      ...state.story,
      deductions: {
        ...state.story.deductions,
        [deduction.id]: { attempts, solved: option.correct },
      },
    },
  })
}
