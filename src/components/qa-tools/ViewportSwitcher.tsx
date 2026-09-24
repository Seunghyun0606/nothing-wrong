import type { Viewport } from '../../game/domain/schemas'

const VIEWPORTS: Viewport[] = ['DESKTOP', 'TABLET', 'MOBILE']

interface ViewportSwitcherProps {
  value: Viewport
  onChange: (viewport: Viewport) => void
}

export function ViewportSwitcher({ value, onChange }: ViewportSwitcherProps) {
  return (
    <div className="viewport-switcher" role="group" aria-label="Product viewport">
      {VIEWPORTS.map((viewport) => (
        <button
          key={viewport}
          type="button"
          aria-pressed={value === viewport}
          onClick={() => onChange(viewport)}
        >
          {viewport[0]}{viewport.slice(1).toLowerCase()}
        </button>
      ))}
    </div>
  )
}
