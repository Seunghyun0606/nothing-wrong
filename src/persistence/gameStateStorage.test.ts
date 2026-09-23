import { createInitialGameState } from '../game/domain/gameState'
import {
  GAME_STATE_STORAGE_KEY,
  GameStateStorageError,
  createSaveFile,
  deserializeGameState,
  loadGameState,
  resetGameState,
  saveGameState,
  serializeGameState,
  type StorageLike,
} from './gameStateStorage'

function createMemoryStorage(): StorageLike {
  const values = new Map<string, string>()

  return {
    getItem: (key) => values.get(key) ?? null,
    setItem: (key, value) => values.set(key, value),
    removeItem: (key) => values.delete(key),
  }
}

describe('Game State persistence', () => {
  it('round-trips a versioned SaveFile', () => {
    const state = createInitialGameState(['T01'])
    const serialized = serializeGameState(state)

    expect(JSON.parse(serialized)).toMatchObject({ version: 1 })
    expect(deserializeGameState(serialized)).toEqual(state)
    expect(createSaveFile(state)).toEqual({ version: 1, state })
  })

  it('saves, loads, and resets through the storage boundary', () => {
    const storage = createMemoryStorage()
    const state = createInitialGameState(['T01'])

    expect(loadGameState(storage)).toBeNull()

    saveGameState(state, storage)
    expect(storage.getItem(GAME_STATE_STORAGE_KEY)).not.toBeNull()
    expect(loadGameState(storage)).toEqual(state)

    resetGameState(storage)
    expect(loadGameState(storage)).toBeNull()
  })

  it('rejects corrupt JSON without silently resetting progress', () => {
    expect(() => deserializeGameState('{broken')).toThrow(GameStateStorageError)
    expect(() => deserializeGameState('{broken')).toThrow('not valid JSON')
  })

  it('rejects unsupported SaveFile versions', () => {
    const state = createInitialGameState()

    expect(() =>
      deserializeGameState(JSON.stringify({ version: 2, state })),
    ).toThrow('Saved Game State is invalid')
  })
})
