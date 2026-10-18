import type { MutationRuntimeContext } from '../../game/mutations/resolveMutation'
import { useGameSession } from '../../game/session/GameSessionProvider'
import { useWorkspaceSession } from '../../game/session/WorkspaceSessionProvider'
import { useShoply } from '../../products/shoply/ShoplyProvider'
import { findNextOpenTicket, getScenario } from '../../scenarios/shoply/tickets'
import { formatAddress } from './browserAddress'
import { useDesktop } from './DesktopProvider'

/** The Ticket under test and the Test Context the Browser currently shows. */
export function useQaContext() {
  const { state } = useGameSession()
  const { evidenceForTicket } = useWorkspaceSession()
  const shoply = useShoply()
  const desktop = useDesktop()

  const currentTicketId = state.currentTicketId
  const activeTicketId =
    currentTicketId && state.tickets[currentTicketId]?.status === 'TESTING'
      ? currentTicketId
      : undefined
  const focusTicketId = activeTicketId ?? findNextOpenTicket(state)?.id
  const activeScenario = activeTicketId ? getScenario(activeTicketId) : undefined
  const focusScenario = focusTicketId ? getScenario(focusTicketId) : undefined
  const location = desktop.location
  const onShoply = location.kind === 'shoply'
  const currentPath = onShoply ? location.path : formatAddress(location) || 'about:blank'
  const evidence = activeTicketId ? evidenceForTicket(activeTicketId) : []

  const mutationContext: MutationRuntimeContext = {
    test: {
      account: shoply.user.tier,
      viewport: desktop.viewport,
      locale: activeScenario?.ticket.startingContext.locale ?? 'en-US',
      currentPath,
    },
    productState: {
      cart: { quantity: shoply.items.reduce((total, item) => total + item.quantity, 0) },
      coupon: shoply.coupon,
    },
    workspace: {
      onShoply,
      browserOpen: desktop.windows.browser.open,
      evidenceCount: evidence.length,
      capturedPaths: evidence.map((item) => item.context.currentPath),
    },
  }

  return {
    activeTicketId,
    activeScenario,
    focusTicketId,
    focusScenario,
    onShoply,
    evidence,
    mutationContext,
  }
}
