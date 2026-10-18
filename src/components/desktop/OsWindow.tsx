import { useRef, useState, type PointerEvent, type PropsWithChildren } from 'react'

import { APP_TITLES, useDesktop, type AppId } from './DesktopProvider'

export interface WindowRect {
  x: number
  y: number
  width: number
  height: number
}

interface OsWindowProps extends PropsWithChildren {
  app: AppId
  icon: string
  rect: WindowRect
  subtitle?: string
}

export function OsWindow({ app, icon, rect, subtitle, children }: OsWindowProps) {
  const desktop = useDesktop()
  const state = desktop.windows[app]
  const [position, setPosition] = useState({ x: rect.x, y: rect.y })
  const drag = useRef<{ pointerX: number; pointerY: number; x: number; y: number } | null>(null)

  if (!state.open) return null

  function startDrag(event: PointerEvent<HTMLElement>) {
    if (state.maximized || event.button !== 0) return
    if ((event.target as HTMLElement).closest('button')) return
    drag.current = { pointerX: event.clientX, pointerY: event.clientY, ...position }
    event.currentTarget.setPointerCapture?.(event.pointerId)
  }

  function moveDrag(event: PointerEvent<HTMLElement>) {
    if (!drag.current) return
    setPosition({
      x: Math.max(-rect.width + 120, drag.current.x + event.clientX - drag.current.pointerX),
      y: Math.max(0, drag.current.y + event.clientY - drag.current.pointerY),
    })
  }

  function endDrag() {
    drag.current = null
  }

  const title = APP_TITLES[app]

  return (
    <section
      aria-label={title}
      className={[
        'os-window',
        `os-window-${app}`,
        state.maximized ? 'os-window-maximized' : '',
        desktop.focusedApp === app ? 'os-window-focused' : '',
      ].join(' ')}
      hidden={state.minimized}
      style={{
        zIndex: state.z,
        left: position.x,
        top: position.y,
        width: rect.width,
        height: rect.height,
      }}
      onPointerDownCapture={() => {
        if (desktop.focusedApp !== app) desktop.openApp(app)
      }}
    >
      <header
        className="os-window-titlebar"
        onDoubleClick={() => desktop.toggleMaximize(app)}
        onPointerDown={startDrag}
        onPointerMove={moveDrag}
        onPointerUp={endDrag}
        onPointerCancel={endDrag}
      >
        <span className="os-window-icon" aria-hidden="true">{icon}</span>
        <strong>{title}</strong>
        {subtitle && <span className="os-window-subtitle">{subtitle}</span>}
        <div className="os-window-controls">
          <button type="button" aria-label={`Minimize ${title}`} onClick={() => desktop.minimizeApp(app)}>–</button>
          <button type="button" aria-label={`Maximize ${title}`} onClick={() => desktop.toggleMaximize(app)}>□</button>
          <button type="button" aria-label={`Close ${title}`} onClick={() => desktop.closeApp(app)}>×</button>
        </div>
      </header>
      <div className="os-window-body">{children}</div>
    </section>
  )
}
