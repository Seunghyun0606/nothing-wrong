import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useState,
  type PropsWithChildren,
} from 'react'

import type { Evidence, PlayerAction } from '../domain/schemas'
import {
  createInitialWorkspaceState,
  loadWorkspaceState,
  saveWorkspaceState,
  type WorkspaceState,
} from '../../persistence/workspaceStorage'

interface RecordInteractionInput {
  ticketId: string
  type: string
  target?: string
  payload?: Record<string, unknown>
  timestamp?: number
  id?: string
}

interface WorkspaceSessionValue {
  state: WorkspaceState
  setNote: (ticketId: string, content: string) => void
  addEvidence: (evidence: Evidence) => void
  recordInteraction: (input: RecordInteractionInput) => void
  evidenceForTicket: (ticketId: string) => Evidence[]
  interactionsForTicket: (ticketId: string) => PlayerAction[]
}

const WorkspaceSessionContext = createContext<WorkspaceSessionValue | null>(null)

function createActionId(timestamp: number): string {
  const suffix =
    typeof globalThis.crypto?.randomUUID === 'function'
      ? globalThis.crypto.randomUUID()
      : Math.random().toString(36).slice(2)
  return `ACTION-${timestamp}-${suffix}`
}

function loadOrCreateWorkspaceState(): WorkspaceState {
  return loadWorkspaceState() ?? createInitialWorkspaceState()
}

function actionsMatch(left: PlayerAction | undefined, right: PlayerAction): boolean {
  return (
    left?.ticketId === right.ticketId &&
    left.type === right.type &&
    left.target === right.target &&
    JSON.stringify(left.payload) === JSON.stringify(right.payload)
  )
}

export function WorkspaceSessionProvider({ children }: PropsWithChildren) {
  const [state, setState] = useState(loadOrCreateWorkspaceState)

  useEffect(() => {
    saveWorkspaceState(state)
  }, [state])

  const value = useMemo<WorkspaceSessionValue>(
    () => ({
      state,
      setNote(ticketId, content) {
        setState((current) => ({
          ...current,
          notes: { ...current.notes, [ticketId]: content },
        }))
      },
      addEvidence(evidence) {
        setState((current) => ({
          ...current,
          evidence: current.evidence.some((item) => item.id === evidence.id)
            ? current.evidence
            : [...current.evidence, evidence],
        }))
      },
      recordInteraction(input) {
        const timestamp = input.timestamp ?? Date.now()
        const action: PlayerAction = {
          id: input.id ?? createActionId(timestamp),
          ticketId: input.ticketId,
          timestamp,
          type: input.type,
          ...(input.target ? { target: input.target } : {}),
          ...(input.payload ? { payload: input.payload } : {}),
        }

        setState((current) =>
          actionsMatch(current.interactions.at(-1), action)
            ? current
            : { ...current, interactions: [...current.interactions, action] },
        )
      },
      evidenceForTicket(ticketId) {
        return state.evidence.filter((evidence) => evidence.ticketId === ticketId)
      },
      interactionsForTicket(ticketId) {
        return state.interactions.filter((action) => action.ticketId === ticketId)
      },
    }),
    [state],
  )

  return (
    <WorkspaceSessionContext.Provider value={value}>
      {children}
    </WorkspaceSessionContext.Provider>
  )
}

export function useWorkspaceSession(): WorkspaceSessionValue {
  const value = useContext(WorkspaceSessionContext)
  if (!value) {
    throw new Error('useWorkspaceSession must be used inside WorkspaceSessionProvider')
  }
  return value
}
