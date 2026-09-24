import type { Viewport } from '../../game/domain/schemas'
import { ViewportSwitcher } from './ViewportSwitcher'

export type InspectorTab = 'ticket' | 'notes' | 'evidence'

interface QAToolbarProps {
  ticketId: string
  activeTab: InspectorTab
  viewport: Viewport
  evidenceCount: number
  onSelectTab: (tab: InspectorTab) => void
  onViewportChange: (viewport: Viewport) => void
  onCapture: () => void
  onCreateReport: () => void
}

export function QAToolbar({
  ticketId,
  activeTab,
  viewport,
  evidenceCount,
  onSelectTab,
  onViewportChange,
  onCapture,
  onCreateReport,
}: QAToolbarProps) {
  return (
    <header className="qa-toolbar">
      <div className="qa-toolbar-brand">
        <span>NW / QA LAB</span>
        <strong>{ticketId}</strong>
      </div>
      <nav aria-label="QA workspace panels">
        {(['ticket', 'notes', 'evidence'] as const).map((tab) => (
          <button
            key={tab}
            type="button"
            aria-pressed={activeTab === tab}
            onClick={() => onSelectTab(tab)}
          >
            {tab}
            {tab === 'evidence' && evidenceCount > 0 ? ` ${evidenceCount}` : ''}
          </button>
        ))}
      </nav>
      <ViewportSwitcher value={viewport} onChange={onViewportChange} />
      <div className="qa-toolbar-actions">
        <button className="qa-capture" type="button" onClick={onCapture}>Capture evidence</button>
        <button className="qa-report" type="button" onClick={onCreateReport}>Create report</button>
      </div>
    </header>
  )
}
