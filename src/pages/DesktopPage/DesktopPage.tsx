import { useEffect } from 'react'

import { BrowserApp } from '../../components/desktop/apps/BrowserApp'
import { MessengerApp } from '../../components/desktop/apps/MessengerApp'
import { NotesApp } from '../../components/desktop/apps/NotesApp'
import { TrackerApp } from '../../components/desktop/apps/TrackerApp'
import {
  APP_TITLES,
  DesktopProvider,
  useDesktop,
  type DesktopToast,
} from '../../components/desktop/DesktopProvider'
import { GuideNote } from '../../components/desktop/GuideNote'
import { OsWindow } from '../../components/desktop/OsWindow'
import { APP_ICONS, APP_ORDER, Taskbar } from '../../components/desktop/Taskbar'
import { useMessengerDelivery, useMessengerLog } from '../../components/desktop/useMessenger'
import { useQaContext } from '../../components/desktop/useQaContext'

function Toast({ toast }: { toast: DesktopToast }) {
  const desktop = useDesktop()
  const { dismissToast } = desktop

  useEffect(() => {
    const timer = window.setTimeout(() => dismissToast(toast.id), 7000)
    return () => window.clearTimeout(timer)
  }, [dismissToast, toast.id])

  return (
    <div className="os-toast" role="status">
      <button
        className="os-toast-body"
        type="button"
        onClick={() => {
          if (toast.app) desktop.openApp(toast.app)
          dismissToast(toast.id)
        }}
      >
        <strong>{toast.title}</strong>
        <span>{toast.text}</span>
      </button>
      <button aria-label="Dismiss notification" type="button" onClick={() => dismissToast(toast.id)}>×</button>
    </div>
  )
}

function Desktop() {
  useMessengerDelivery()
  const desktop = useDesktop()
  const { unread } = useMessengerLog()
  const qa = useQaContext()

  return (
    <main className="os-desktop">
      <div className="os-wallpaper" aria-hidden="true">
        <span>NOTHING WRONG</span>
      </div>
      <nav className="os-icons" aria-label="Desktop">
        {APP_ORDER.map((app) => (
          <button className="os-icon" key={app} type="button" onClick={() => desktop.openApp(app)}>
            <span className="os-icon-glyph" aria-hidden="true">{APP_ICONS[app]}</span>
            <span>{APP_TITLES[app]}</span>
            {app === 'messenger' && unread > 0 && <span className="taskbar-badge" aria-hidden="true">{unread}</span>}
          </button>
        ))}
      </nav>

      <OsWindow app="messenger" icon={APP_ICONS.messenger} rect={{ x: 132, y: 28, width: 440, height: 600 }}>
        <MessengerApp />
      </OsWindow>
      <OsWindow
        app="tracker"
        icon={APP_ICONS.tracker}
        rect={{ x: 220, y: 18, width: 980, height: 680 }}
        subtitle={qa.activeTicketId ? `${qa.activeTicketId} in testing` : undefined}
      >
        <TrackerApp />
      </OsWindow>
      <OsWindow app="browser" icon={APP_ICONS.browser} rect={{ x: 160, y: 12, width: 1120, height: 720 }}>
        <BrowserApp />
      </OsWindow>
      <OsWindow app="notes" icon={APP_ICONS.notes} rect={{ x: 760, y: 60, width: 520, height: 620 }}>
        <NotesApp />
      </OsWindow>

      <GuideNote />
      <div className="os-toasts" aria-live="polite">
        {desktop.toasts.map((toast) => <Toast key={toast.id} toast={toast} />)}
      </div>
      <Taskbar />
    </main>
  )
}

export function DesktopPage() {
  return (
    <DesktopProvider>
      <Desktop />
    </DesktopProvider>
  )
}
