export function FoundationPage() {
  return (
    <main className="foundation-shell">
      <section className="foundation-panel" aria-labelledby="foundation-title">
        <p className="foundation-eyebrow">Nothing Wrong</p>
        <h1 id="foundation-title">Project foundation ready</h1>
        <p className="foundation-summary">
          The application shell, router, and automated test entry points are in place.
        </p>
        <dl className="foundation-status" aria-label="Foundation status">
          <div>
            <dt>Milestone</dt>
            <dd>M1 · First Playable</dd>
          </div>
          <div>
            <dt>Current scope</dt>
            <dd>Platform bootstrap</dd>
          </div>
        </dl>
      </section>
    </main>
  )
}
