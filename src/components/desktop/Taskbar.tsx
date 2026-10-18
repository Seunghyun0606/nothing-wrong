import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'

import { APP_TITLES, useDesktop, type AppId } from './DesktopProvider'
import { useMessengerLog } from './useMessenger'

export const APP_ICONS: Readonly<Record<AppId, string>> = {
  messenger: '💬',
  browser: '🌐',
  notes: '📝',
  tracker: '📋',
}

export const APP_ORDER: readonly AppId[] = ['messenger', 'tracker', 'browser', 'notes']

function useClock(): string {
  const [now, setNow] = useState(() => new Date())
  useEffect(() => {
    const timer = window.setInterval(() => setNow(new Date()), 30_000)
    return () => window.clearInterval(timer)
  }, [])
  return new Intl.DateTimeFormat('en-US', { hour: '2-digit', minute: '2-digit' }).format(now)
}

export function Taskbar() {
  const desktop = useDesktop()
  const navigate = useNavigate()
  const { unread } = useMessengerLog()
  const [menuOpen, setMenuOpen] = useState(false)
  const clock = useClock()

  function toggle(app: AppId) {
    const window = desktop.windows[app]
    if (window.open && !window.minimized && desktop.focusedApp === app) {
      desktop.minimizeApp(app)
    } else {
      desktop.openApp(app)
    }
  }

  return (
    <footer className="taskbar">
      <div className="taskbar-start">
        <button
          aria-expanded={menuOpen}
          aria-label="Start menu"
          className="taskbar-start-button"
          type="button"
          onClick={() => setMenuOpen((current) => !current)}
        >
          NW
        </button>
        {menuOpen && (
          <div className="start-menu" role="menu">
            <p className="card-label">Nothing Wrong · QA workstation</p>
            {APP_ORDER.map((app) => (
              <button
                key={app}
                role="menuitem"
                type="button"
                onClick={() => {
                  desktop.openApp(app)
                  setMenuOpen(false)
                }}
              >
                {APP_ICONS[app]} {APP_TITLES[app]}
              </button>
            ))}
            <button role="menuitem" type="button" onClick={() => navigate('/start')}>
              ⏻ Sign out
            </button>
          </div>
        )}
      </div>
      <nav className="taskbar-apps" aria-label="Taskbar">
        {APP_ORDER.map((app) => {
          const badge = app === 'messenger' && unread > 0 ? unread : 0
          return (
            <button
              aria-label={badge ? `${APP_TITLES[app]}, ${badge} unread` : APP_TITLES[app]}
              aria-pressed={desktop.windows[app].open && !desktop.windows[app].minimized}
              className="taskbar-app"
              key={app}
              type="button"
              onClick={() => toggle(app)}
            >
              <span aria-hidden="true">{APP_ICONS[app]}</span>
              <span className="taskbar-app-label">{APP_TITLES[app]}</span>
              {badge > 0 && <span className="taskbar-badge" aria-hidden="true">{badge}</span>}
            </button>
          )
        })}
      </nav>
      <div className="taskbar-tray">
        <span>Shoply RC3 · Staging</span>
        <time>{clock}</time>
      </div>
    </footer>
  )
}
