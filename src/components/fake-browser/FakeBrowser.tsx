import type { Viewport } from '../../game/domain/schemas'
import { ProductNavigationProvider } from '../../products/shoply/ProductNavigation'
import { ProductRouter } from './ProductRouter'

const VIEWPORT_WIDTHS: Record<Viewport, string> = {
  DESKTOP: '100%',
  TABLET: '768px',
  MOBILE: '390px',
}

interface FakeBrowserProps {
  path: string
  viewport: Viewport
  canGoBack: boolean
  canGoForward: boolean
  reloadKey: number
  onNavigate: (path: string) => void
  onBack: () => void
  onForward: () => void
  onReload: () => void
}

export function FakeBrowser({
  path,
  viewport,
  canGoBack,
  canGoForward,
  reloadKey,
  onNavigate,
  onBack,
  onForward,
  onReload,
}: FakeBrowserProps) {
  const viewportWidth = VIEWPORT_WIDTHS[viewport]
  const fakeUrl = `https://shoply.local${path.replace(/^\/shoply/, '') || '/'}`

  return (
    <section className="fake-browser" aria-label="Shoply test browser">
      <header className="fake-browser-bar">
        <div className="window-controls" aria-hidden="true"><i /><i /><i /></div>
        <div className="browser-navigation">
          <button type="button" aria-label="Go back" disabled={!canGoBack} onClick={onBack}>←</button>
          <button type="button" aria-label="Go forward" disabled={!canGoForward} onClick={onForward}>→</button>
          <button type="button" aria-label="Reload Shoply" onClick={onReload}>↻</button>
        </div>
        <div className="fake-url" aria-label="Fake URL">{fakeUrl}</div>
        <span className="secure-indicator">LOCAL</span>
      </header>
      <div className="fake-browser-stage">
        <div
          className="fake-browser-viewport"
          data-testid="product-viewport"
          data-viewport={viewport}
          data-viewport-width={viewportWidth}
          style={{ width: viewportWidth }}
        >
          <ProductNavigationProvider currentPath={path} onNavigate={onNavigate}>
            <div key={reloadKey} data-testid="product-router">
              <ProductRouter path={path} />
            </div>
          </ProductNavigationProvider>
        </div>
      </div>
    </section>
  )
}
