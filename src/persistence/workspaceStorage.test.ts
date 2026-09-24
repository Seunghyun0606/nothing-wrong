import { createInitialGameState } from '../game/domain/gameState'
import { serializeGameState, type StorageLike } from './gameStateStorage'
import {
  WORKSPACE_STORAGE_KEY,
  WorkspaceStorageError,
  createInitialWorkspaceState,
  deserializeWorkspaceState,
  loadWorkspaceState,
  saveWorkspaceState,
  serializeWorkspaceState,
} from './workspaceStorage'

function createMemoryStorage(): StorageLike {
  const values = new Map<string, string>()
  return {
    getItem: (key) => values.get(key) ?? null,
    setItem: (key, value) => values.set(key, value),
    removeItem: (key) => values.delete(key),
  }
}

describe('Workspace persistence', () => {
  it('round-trips notes separately from reviewable Game State', () => {
    const state = createInitialWorkspaceState()
    state.notes.T01 = 'Check the final CTA.'

    const restored = deserializeWorkspaceState(serializeWorkspaceState(state))

    expect(restored.notes.T01).toBe('Check the final CTA.')
    expect(serializeGameState(createInitialGameState(['T01']))).not.toContain(
      'Check the final CTA.',
    )
  })

  it('saves evidence and interactions behind a versioned namespaced key', () => {
    const storage = createMemoryStorage()
    const state = createInitialWorkspaceState()
    state.interactions.push({
      id: 'ACTION-1',
      ticketId: 'T01',
      timestamp: 1,
      type: 'OPEN_PRODUCT',
      target: '/shoply/product/everyday-pack',
    })

    saveWorkspaceState(state, storage)

    expect(storage.getItem(WORKSPACE_STORAGE_KEY)).toContain('"version":1')
    expect(loadWorkspaceState(storage)).toEqual(state)
  })

  it('rejects corrupt and unsupported Workspace saves', () => {
    expect(() => deserializeWorkspaceState('{broken')).toThrow(WorkspaceStorageError)
    expect(() =>
      deserializeWorkspaceState(
        JSON.stringify({ version: 2, state: createInitialWorkspaceState() }),
      ),
    ).toThrow('Saved Workspace State is invalid')
  })
})
