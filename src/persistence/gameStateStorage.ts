import {
  SAVE_VERSION,
  SaveFileSchema,
  type GameState,
  type SaveFile,
} from '../game/domain/schemas'

export const GAME_STATE_STORAGE_KEY = 'nothingwrong.gameState'

export interface StorageLike {
  getItem(key: string): string | null
  setItem(key: string, value: string): void
  removeItem(key: string): void
}

export class GameStateStorageError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'GameStateStorageError'
  }
}

function browserStorage(): StorageLike {
  if (typeof window === 'undefined' || window.localStorage === undefined) {
    throw new GameStateStorageError('localStorage is not available in this runtime')
  }

  return window.localStorage
}

export function serializeGameState(state: GameState): string {
  const saveFile = SaveFileSchema.parse({
    version: SAVE_VERSION,
    state,
  })

  return JSON.stringify(saveFile)
}

export function deserializeGameState(serialized: string): GameState {
  let candidate: unknown

  try {
    candidate = JSON.parse(serialized)
  } catch {
    throw new GameStateStorageError('Saved Game State is not valid JSON')
  }

  const parsed = SaveFileSchema.safeParse(candidate)
  if (!parsed.success) {
    throw new GameStateStorageError(`Saved Game State is invalid: ${parsed.error.message}`)
  }

  return parsed.data.state
}

export function createSaveFile(state: GameState): SaveFile {
  return SaveFileSchema.parse({ version: SAVE_VERSION, state })
}

export function loadGameState(storage: StorageLike = browserStorage()): GameState | null {
  const serialized = storage.getItem(GAME_STATE_STORAGE_KEY)
  return serialized === null ? null : deserializeGameState(serialized)
}

export function saveGameState(
  state: GameState,
  storage: StorageLike = browserStorage(),
): void {
  storage.setItem(GAME_STATE_STORAGE_KEY, serializeGameState(state))
}

export function resetGameState(storage: StorageLike = browserStorage()): void {
  storage.removeItem(GAME_STATE_STORAGE_KEY)
}
