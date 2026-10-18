import { createInitialGameState } from '../domain/gameState'
import { GameStateSchema } from '../domain/schemas'
import { SCENARIO_CATALOG } from '../../scenarios/shoply/tickets'
import { T01_SCENARIO } from '../../scenarios/shoply/t01'
import { answerDeduction, FIRST_TRY_DEDUCTION_BONUS } from './answerDeduction'

const deduction = T01_SCENARIO.story!.deduction!
const correct = deduction.options.find((option) => option.correct)!
const wrong = deduction.options.find((option) => !option.correct)!

describe('answerDeduction', () => {
  it('rewards a first-try deduction once', () => {
    const state = createInitialGameState(['T01'])
    const solved = answerDeduction(state, deduction, correct.id)

    expect(solved.story.deductions[deduction.id]).toEqual({ attempts: [correct.id], solved: true })
    expect(solved.profile.reputation).toBe(state.profile.reputation + FIRST_TRY_DEDUCTION_BONUS)
    expect(answerDeduction(solved, deduction, wrong.id)).toBe(solved)
  })

  it('lets the player retry without a penalty', () => {
    const state = createInitialGameState(['T01'])
    const missed = answerDeduction(state, deduction, wrong.id)
    expect(missed.profile.reputation).toBe(state.profile.reputation)
    expect(missed.story.deductions[deduction.id]?.solved).toBe(false)

    const solved = answerDeduction(missed, deduction, correct.id)
    expect(solved.story.deductions[deduction.id]).toEqual({
      attempts: [wrong.id, correct.id],
      solved: true,
    })
    expect(solved.profile.reputation).toBe(state.profile.reputation)
  })

  it('loads saves created before story progress existed', () => {
    const { story: _story, ...legacy } = createInitialGameState(['T01'])
    expect(GameStateSchema.parse(legacy).story).toEqual({ deductions: {}, deliveredCount: 0, readCount: 0 })
  })

  it('gives every catalog story exactly one correct deduction option', () => {
    for (const scenario of SCENARIO_CATALOG) {
      expect(scenario.story?.deduction?.options.filter((option) => option.correct)).toHaveLength(1)
    }
  })
})
