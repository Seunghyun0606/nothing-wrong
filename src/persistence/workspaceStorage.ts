import { z } from 'zod'

import {
  EvidenceSchema,
  PlayerActionSchema,
  type Evidence,
  type PlayerAction,
} from '../game/domain/schemas'
import type { RecoverableLoad, StorageLike } from './gameStateStorage'

export const WORKSPACE_STORAGE_KEY = 'nothingwrong.workspace'
export const WORKSPACE_SAVE_VERSION = 1 as const

const WorkspaceStateSchema = z.object({
  notes: z.record(z.string(), z.string()),
  evidence: z.array(EvidenceSchema),
  interactions: z.array(PlayerActionSchema),
})

const WorkspaceSaveFileSchema = z.object({
  version: z.literal(WORKSPACE_SAVE_VERSION),
  state: WorkspaceStateSchema,
})

export interface WorkspaceState {
  notes: Record<string, string>
  evidence: Evidence[]
  interactions: PlayerAction[]
}

export class WorkspaceStorageError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'WorkspaceStorageError'
  }
}

function browserStorage(): StorageLike {
  if (typeof window === 'undefined' || window.localStorage === undefined) {
    throw new WorkspaceStorageError('localStorage is not available in this runtime')
  }

  return window.localStorage
}

export function createInitialWorkspaceState(): WorkspaceState {
  return { notes: {}, evidence: [], interactions: [] }
}

export function serializeWorkspaceState(state: WorkspaceState): string {
  return JSON.stringify(
    WorkspaceSaveFileSchema.parse({ version: WORKSPACE_SAVE_VERSION, state }),
  )
}

export function deserializeWorkspaceState(serialized: string): WorkspaceState {
  let candidate: unknown

  try {
    candidate = JSON.parse(serialized)
  } catch {
    throw new WorkspaceStorageError('Saved Workspace State is not valid JSON')
  }

  const parsed = WorkspaceSaveFileSchema.safeParse(candidate)
  if (!parsed.success) {
    throw new WorkspaceStorageError(
      `Saved Workspace State is invalid: ${parsed.error.message}`,
    )
  }

  return parsed.data.state
}

export function loadWorkspaceState(
  storage: StorageLike = browserStorage(),
): WorkspaceState | null {
  const serialized = storage.getItem(WORKSPACE_STORAGE_KEY)
  return serialized === null ? null : deserializeWorkspaceState(serialized)
}

export const WORKSPACE_BACKUP_KEY = 'nothingwrong.workspace.unreadable'

export function loadWorkspaceStateWithRecovery(
  storage: StorageLike = browserStorage(),
): RecoverableLoad<WorkspaceState> {
  try {
    return { state: loadWorkspaceState(storage), recovered: false }
  } catch (error) {
    if (!(error instanceof WorkspaceStorageError)) throw error
    const serialized = storage.getItem(WORKSPACE_STORAGE_KEY)
    if (serialized !== null) storage.setItem(WORKSPACE_BACKUP_KEY, serialized)
    storage.removeItem(WORKSPACE_STORAGE_KEY)
    return { state: null, recovered: true }
  }
}

export function saveWorkspaceState(
  state: WorkspaceState,
  storage: StorageLike = browserStorage(),
): void {
  storage.setItem(WORKSPACE_STORAGE_KEY, serializeWorkspaceState(state))
}

export function resetWorkspaceState(storage: StorageLike = browserStorage()): void {
  storage.removeItem(WORKSPACE_STORAGE_KEY)
}
