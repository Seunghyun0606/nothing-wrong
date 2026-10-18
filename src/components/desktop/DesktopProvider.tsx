import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useRef,
  useState,
  type PropsWithChildren,
} from 'react'

import type { Viewport } from '../../game/domain/schemas'
import { useGameSession } from '../../game/session/GameSessionProvider'
import { useWorkspaceSession } from '../../game/session/WorkspaceSessionProvider'
import { NEW_TAB, parseAddress, type BrowserLocation } from './browserAddress'

export type AppId = 'messenger' | 'browser' | 'notes' | 'tracker'
export type TrackerView = 'detail' | 'report' | 'review' | 'casefile'

export const APP_TITLES: Readonly<Record<AppId, string>> = {
  messenger: 'Messenger',
  browser: 'Browser',
  notes: 'QA Notes',
  tracker: 'QA Tracker',
}

interface WindowState {
  open: boolean
  minimized: boolean
  maximized: boolean
  z: number
}

export interface DesktopToast {
  id: number
  title: string
  text: string
  app?: AppId
}

interface DesktopValue {
  windows: Readonly<Record<AppId, WindowState>>
  focusedApp: AppId | undefined
  openApp: (app: AppId) => void
  closeApp: (app: AppId) => void
  minimizeApp: (app: AppId) => void
  toggleMaximize: (app: AppId) => void
  location: BrowserLocation
  canGoBack: boolean
  canGoForward: boolean
  reloadKey: number
  viewport: Viewport
  openUrl: (address: string) => void
  navigate: (location: BrowserLocation) => void
  goBack: () => void
  goForward: () => void
  reload: () => void
  setViewport: (viewport: Viewport) => void
  trackerTicketId: string | undefined
  trackerView: TrackerView
  showTicket: (ticketId: string, view?: TrackerView) => void
  setTrackerView: (view: TrackerView) => void
  notesTicketId: string | undefined
  showNotes: (ticketId?: string) => void
  toasts: readonly DesktopToast[]
  pushToast: (toast: Omit<DesktopToast, 'id'>) => void
  dismissToast: (id: number) => void
}

const DesktopContext = createContext<DesktopValue | null>(null)

const CLOSED: WindowState = { open: false, minimized: false, maximized: false, z: 0 }

export function actionForPath(path: string): string {
  if (path.includes('/payment')) return 'OPEN_PAYMENT'
  if (path.includes('/orders/')) return 'OPEN_ORDER'
  if (path.endsWith('/orders')) return 'OPEN_ORDERS'
  if (path.includes('/checkout')) return 'OPEN_CHECKOUT'
  if (path.includes('/cart')) return 'OPEN_CART'
  if (path.includes('/product/') || path === '/shoply') return 'OPEN_PRODUCT'
  return 'NAVIGATE'
}

export function DesktopProvider({ children }: PropsWithChildren) {
  const { state: gameState } = useGameSession()
  const { recordInteraction } = useWorkspaceSession()
  const [windows, setWindows] = useState<Record<AppId, WindowState>>({
    messenger: CLOSED,
    browser: CLOSED,
    notes: CLOSED,
    tracker: CLOSED,
  })
  const [focusedApp, setFocusedApp] = useState<AppId>()
  const zCounter = useRef(1)
  const [history, setHistory] = useState<BrowserLocation[]>([NEW_TAB])
  const [historyIndex, setHistoryIndex] = useState(0)
  const [reloadKey, setReloadKey] = useState(0)
  const [viewport, setViewportState] = useState<Viewport>('DESKTOP')
  const [trackerTicketId, setTrackerTicketId] = useState<string>()
  const [trackerView, setTrackerView] = useState<TrackerView>('detail')
  const [notesTicketId, setNotesTicketId] = useState<string>()
  const [toasts, setToasts] = useState<DesktopToast[]>([])
  const toastCounter = useRef(0)

  const currentTicketId = gameState.currentTicketId
  const activeTicketId =
    currentTicketId && gameState.tickets[currentTicketId]?.status === 'TESTING'
      ? currentTicketId
      : undefined

  const openApp = useCallback((app: AppId) => {
    zCounter.current += 1
    const z = zCounter.current
    setWindows((current) => ({
      ...current,
      [app]: { ...current[app], open: true, minimized: false, z },
    }))
    setFocusedApp(app)
    setToasts((current) => current.filter((toast) => toast.app !== app))
  }, [])

  const recordVisit = useCallback(
    (location: BrowserLocation) => {
      if (!activeTicketId || location.kind !== 'shoply') return
      recordInteraction({
        ticketId: activeTicketId,
        type: actionForPath(location.path),
        target: location.path,
      })
    },
    [activeTicketId, recordInteraction],
  )

  const pushToast = useCallback((toast: Omit<DesktopToast, 'id'>) => {
    toastCounter.current += 1
    const id = toastCounter.current
    setToasts((current) => [...current.slice(-2), { ...toast, id }])
  }, [])

  const dismissToast = useCallback((id: number) => {
    setToasts((current) => current.filter((toast) => toast.id !== id))
  }, [])

  const navigate = useCallback(
    (location: BrowserLocation) => {
      setHistory((current) => [...current.slice(0, historyIndex + 1), location])
      setHistoryIndex((current) => current + 1)
      recordVisit(location)
    },
    [historyIndex, recordVisit],
  )

  const value = useMemo<DesktopValue>(
    () => ({
      windows,
      focusedApp,
      openApp,
      closeApp(app) {
        setWindows((current) => ({ ...current, [app]: CLOSED }))
        setFocusedApp((current) => (current === app ? undefined : current))
      },
      minimizeApp(app) {
        setWindows((current) => ({ ...current, [app]: { ...current[app], minimized: true } }))
        setFocusedApp((current) => (current === app ? undefined : current))
      },
      toggleMaximize(app) {
        setWindows((current) => ({
          ...current,
          [app]: { ...current[app], maximized: !current[app].maximized },
        }))
      },
      location: history[historyIndex] ?? NEW_TAB,
      canGoBack: historyIndex > 0,
      canGoForward: historyIndex < history.length - 1,
      reloadKey,
      viewport,
      openUrl(address) {
        openApp('browser')
        navigate(parseAddress(address))
      },
      navigate,
      goBack() {
        const location = history[historyIndex - 1]
        if (!location) return
        setHistoryIndex(historyIndex - 1)
        recordVisit(location)
      },
      goForward() {
        const location = history[historyIndex + 1]
        if (!location) return
        setHistoryIndex(historyIndex + 1)
        recordVisit(location)
      },
      reload() {
        setReloadKey((current) => current + 1)
        const location = history[historyIndex]
        if (activeTicketId && location?.kind === 'shoply') {
          recordInteraction({ ticketId: activeTicketId, type: 'RELOAD_PAGE', target: location.path })
        }
      },
      setViewport(next) {
        setViewportState(next)
        if (activeTicketId) {
          recordInteraction({ ticketId: activeTicketId, type: 'CHANGE_VIEWPORT', target: next })
        }
      },
      trackerTicketId,
      trackerView,
      showTicket(ticketId, view = 'detail') {
        setTrackerTicketId(ticketId)
        setTrackerView(view)
        openApp('tracker')
      },
      setTrackerView,
      notesTicketId,
      showNotes(ticketId) {
        if (ticketId) setNotesTicketId(ticketId)
        openApp('notes')
      },
      toasts,
      pushToast,
      dismissToast,
    }),
    [
      activeTicketId,
      dismissToast,
      focusedApp,
      history,
      historyIndex,
      navigate,
      notesTicketId,
      openApp,
      pushToast,
      recordInteraction,
      recordVisit,
      reloadKey,
      toasts,
      trackerTicketId,
      trackerView,
      viewport,
      windows,
    ],
  )

  return <DesktopContext.Provider value={value}>{children}</DesktopContext.Provider>
}

export function useDesktop(): DesktopValue {
  const value = useContext(DesktopContext)
  if (!value) throw new Error('useDesktop must be used inside DesktopProvider')
  return value
}
