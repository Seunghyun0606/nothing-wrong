# CX-11 readability and keyboard accessibility

**Result: complete; accessibility issues found.** Measurement/reporting only. No product fixes, content edits, or Project OS state transitions. This is automated QA, not the TASK-010 human playtest.

Tested on 2026-10-26 with Godot 4.7.2, OpenGL Compatibility, NVIDIA RTX 4070 SUPER. Every Godot run was sequential.

## Coverage and counts

| Matrix | Original tour | Instrumented probe | Stateful keyboard trap check |
|---|---:|---:|---|
| English, 1280x720 | 32 PNGs | 36 measured screens | reproduced |
| English, 1920x1080 | 32 PNGs | 36 measured screens | reproduced |
| Korean, 1280x720 | 32 PNGs | 36 measured screens | reproduced |
| Korean, 1920x1080 | 32 PNGs | 36 measured screens | reproduced |

All final runs exited 0. The original tour produced 128 PNGs; the final probe produced 144 metadata frames and 288 paired text/background PNGs, plus focus evidence. Pixel dimensions were checked against each requested resolution.

The probe visits title, lock, desktop, Messenger, Browser, QA Notes, ticket/test screens, report composer, deduction forms, intranet record/search, five photo record views, photo zoom, tablet gallery, directory, person page, Shoply storefront/product/cart/checkout, Case File, Clock out, and day change. Case File and product screens are explicit additions to the original tour.

| Measurement | Count |
|---|---:|
| Nonempty text-control instances with an on-screen clipped rectangle | 14,870 |
| Attributable rendered text instances measured | 6,874 |
| Symbol/emoji-only instances excluded from text contrast | 3,027 |
| No attributable visible glyph sample: occluded/clipped/etc. | 4,969 |
| Contrast flags under the brief's thresholds | 133 |
| Text under 12 px | 24 |
| Keyboard activation attempts | 100 |
| Successful activations | 92 |
| Failed activations, all evidence markers | 8 |
| Drop-down selections matching requested option | 12 / 12 |

`findings.csv` contains **539 occurrence rows: P1 56, P2 463, P3 20**. These are repeated observations across screens, locales, resolutions, and traversal directions, not 539 distinct defects. Breakdown: 133 contrast; 24 small text; 8 evidence-marker activation failures; 48 editor-trap observations; 298 focus positions outside the clipped viewport; 28 weak/covered focus samples. P1 represents two recurring blocker classes below. Redundant 7 px avatar initials are P3; the 11 px count badge is P2.

## Highest-priority findings

1. **P1 — Evidence selection cannot be operated by keyboard.** Pressing Note works, but `Markcart_subtotal` and `Markcheckout_confirmButton` are absent from both forward and reverse focus traversal in all four combinations. Both instantiated Buttons report `focus_mode=0` (`FOCUS_NONE`); Enter/Space never emits their `pressed` signal. This prevents completing the tested evidence/report gameplay through the specified keys. After recording each failure, the probe emits the marker signal solely to set up later screens; later report success does not establish a complete keyboard-only gameplay path. Evidence: each `probe-*/keyboard.jsonl`, activation labels `Evidence-cart_subtotal` and `Evidence-checkout_confirmButton`; implementation corroboration at `browser_app.gd:774`.

2. **P1 — QA Notes' `MyNotes` editor traps the specified navigation keys.** Forward traversal reaches this TextEdit and stops advancing. A separate stateful test, without resetting focus, confirms Tab, Shift+Tab, and Escape all keep the same focus owner in every combination. Tab edits the in-memory note. Some visits focus the editor below the visible scroll area, making the trap harder to understand. Evidence: `trap-*/keyboard.jsonl` and `notes-trapped.png`. The large number of offscreen focus rows includes other controls in scroll containers; those rows describe clipped focus positions, without claiming that every one independently blocks play.

3. **P2 — Clock/date contrast depends on wallpaper crop and language.** At 720p the date is 2.33:1 English / 2.29:1 Korean against the required 3:1. At 1080p the 96 px clock reaches 2.26:1 in both languages; its 5th-percentile ratios are 2.75 and 2.71. The Korean 720p clock has a local minimum 2.74:1, though its 5th percentile is 4.62:1; this is a localized footprint failure. The English 720p clock passes at 3.33:1 and both 1080p dates pass at 5.42:1. A rectangle-average colour would conceal these variations.

4. **P2 — Desktop QA Notes caption misses 4.5:1.** English: 4.11:1 at 720p, 4.47:1 at 1080p. Korean: 4.07:1 and 4.47:1. Text is 14 px regular. Foreground is approximately `#1f2328`; the sampled 720p glyph-background median is `#6a85aa`. The 1080p misses are marginal but thresholds are compared before rounding.

5. **P2 — Focus on primary actions is weak; focus can also remain behind another window.** Start work, Sign in, Start test, Send report, Send deduction, and Clock out each change only 76 pixels in their focus/blur crop (>3/255 channel difference). Their blue focus border shares the blue normal fill; the visible difference is concentrated at rounded corners. Desktop icon focus changes 392 pixels and is clearer. This is a measured weak-cue finding, not a claim that no pixels change. `focus-primary.png` shows the enlarged comparison. In all four runs the Messenger product link accepted keyboard activation while fully covered by Browser: zero visible target pixels after occlusion masking. Keyboard focus does not automatically bring that app window forward.

6. **P2/P3 — Repeated small or borderline text.** Shoply uppercase 12 px section labels measure 3.90:1 against 4.5:1. Record-source text measures 4.32:1; warning/status copy often measures 4.46:1. Twenty visible sender-avatar initials (`MS`) are only 7 px (P3, with the sender identified in adjacent text). Four count badges are 11 px (P2). All occurrences and exact elements are in the CSV.

Suggested follow-up for the implementing owner: enable keyboard evidence targeting; provide an escape from note editing and scroll focused content into view; expose the focused app; strengthen the primary-button focus cue; stabilize clock/date and desktop-caption backgrounds; then adjust the repeated low-contrast/small text. These are suggestions only; none were applied.

## Keyboard action results

English uses Enter and Korean uses Space for activation, at both resolutions. Drop-downs additionally use Home, Down, and Enter. Each reachability attempt starts with focus cleared; it tries Tab, then starts again with Shift+Tab if forward traversal stalls. The separate stateful test covers the trap that this reset would otherwise conceal. Focus is briefly released/reacquired only to produce the paired indicator images.

| Action | Final observed behavior |
|---|---|
| Start work | Tab reaches action; activation opens lock screen |
| Sign in | Tab reaches action; activation opens desktop |
| All three desktop app icons | Tab reaches each; activation opens app |
| Start test | Tab reaches action; activation starts T01 test |
| Note | Activation works; later visit needs reverse traversal from cleared focus |
| Select evidence target | Fails both directions; FOCUS_NONE |
| Report observation/requirement and Send report | Shift+Tab reaches controls from cleared focus; activation works with fixture evidence |
| Three deduction drop-downs | Reverse traversal reaches each; popup keyboard selection matches desired indices 1, 3, 2 |
| Send deduction | Reverse traversal reaches enabled action; activation works |
| Clock out | Tab reaches action; activation opens the real day-change screen |

Clock out is tested with an explicitly synthetic end-of-day gate/toast fixture, not by progressing through every game day. Most screen navigation, ticket-unlock setup, photo zoom opening, and record navigation are scripted fixtures. App open flags, final day-screen script, drop-down selection indices, save paths, and persistence flags are recorded in the logs. This does not establish a continuous keyboard-only playthrough.

## Contrast method and limits

- Walk instantiated visible Labels, Buttons (including OptionButtons), and LineEdits. RichTextLabels are also sampled for story/caption coverage. Record translated text, resolved theme font size, bold flag, state-specific foreground RGBA, clipped/global rectangles, focus mode, and window/toast occluders.
- Let animations settle for 0.45 seconds. Capture a normal GPU frame, make text theme colours transparent without changing layout or panel/photo backgrounds, capture the background frame, then restore overrides in that throwaway process. Source files are never changed.
- Store a 16x16-ish background grid's median/range behind each rectangle. For contrast, identify changed pixels consistent with the declared font colour (difference >3/255, glyph coverage >0.08, RGB residual <0.035), mask higher app windows/toasts, and sample the corresponding text-free background. Require at least four attributable pixels. This avoids treating another window's text or a control border as the tested text.
- Convert sRGB channels to linear values, compute relative luminance `0.2126 R + 0.7152 G + 0.0722 B`, and use `(lighter + 0.05)/(darker + 0.05)`. Alpha-composite declared text over each background sample. Report minimum, 5th percentile, median, and failed-footprint fraction. CSV `ratio` is the minimum, formatted to four decimals; threshold comparisons use unrounded values. Background medians are descriptive and are not used instead of local samples.
- Follow the brief's 4.5:1 requirement, relaxed to 3:1 at >=18 **px**, or >=14 **px** bold. WCAG's actual large-text definition uses 18 **pt**, or 14 **pt** bold (approximately 24 px / 18.7 px). Raw records retain both required values; applying the stricter point-derived size rule produces no additional contrast failures in the measured set. This is a project audit, not WCAG certification. [W3C contrast minimum](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html).
- Disabled controls are retained in measurements but exempted from contrast findings. Symbol/emoji-only controls, including decorative stars, are excluded. The tool cannot certify coloured emoji glyphs, font fallback, or text embedded in bitmap photographs. Mixed rich text uses its declared default colour and base size; inline styling is a limitation. No attempt is made to infer a pass for samples without attributable glyphs.
- Across the 44 `p-*` photo/directory/person/storefront frames, 1,796 text-control instances yielded samples and no contrast failure was found. This is limited to visible caption/badge text in those frames, not all scrolled content, all photos, or image-embedded lettering. The title card's measured text passes; its headline is >=13.86:1 and subtitle >=5.36:1.
- Focus comparison counts are an operational measurement, not a standardized perceptual threshold. Covered focus is masked geometrically; offscreen focus uses ancestor clip rectangles. These findings were also inspected in screenshots. [W3C focus visible](https://www.w3.org/WAI/WCAG21/Understanding/focus-visible.html).
- Only these locales, resolutions, fixtures, renderer and font environment were tested. No screen reader, high-DPI scaling, colour-vision simulation, exhaustive hover/pressed states, or human reading-speed test was performed. Transient/dynamic UI and a glyph-footprint sampling tolerance can affect marginal results; raw minimum and percentile values are retained for review.

## Evidence and reproducibility

- Deliverable: [findings.csv](findings.csv), with the exact requested eight columns. Blank size/ratio cells denote keyboard findings.
- [Execution journal](execution-journal.md) records progress, preliminary runs and the correction from forward-only to bidirectional activation checks. Final probe results supersede preliminary counts.
- Scratch: `godot/build/cx11/`. `probe-<language>-<resolution>/` holds frame pairs, control metadata, focus pairs and keyboard JSONL; `tour-*/` holds the original tour. `trap-*/` holds stateful trap evidence.
- `measurements.jsonl` holds all per-control font/foreground/background/ratio/exclusion records. `summary.json`, `keyboard-summary.json`, and `focus-summary.json` contain aggregate evidence. `runs.jsonl` records matrix commands, exit codes, and timestamps. Repeated probe runs are retained in that command journal; files in each probe directory are the final refined run.
- Rebuild the scratch probe with `python godot/build/cx11/make_probe.py`, then `python godot/build/cx11/upgrade_probe.py`. Run `python godot/build/cx11/run_matrix.py tour probe`, then `python godot/build/cx11/run_traps.py`, then `python -X utf8 godot/build/cx11/analyze.py`. Final artifact assertions are in `finalize_report.py`.
- The runner invokes the exact tour script from RULES.md, with absolute output/log paths and the requested locale/resolution. The first exploratory invocation used a `res://` log path and reported a directory-creation error; the matrix reran with absolute paths and produced all expected screenshots.
- The engine reports a certificate-store read error and known RID/ObjectDB/texture leaks at exit. No missing button/marker, GDScript parse error, or runtime script error appears in the final tour/probe/trap logs. A scratch-only trap script type-inference parse error was corrected before the four successful trap runs. Engine exit 0 alone is not used as proof that the accessibility audit passed.

## Scope and save handling

Read Project OS bootstrap files and the two requested briefs. CX-11 is the explicit assigned QA task; no `projectctl` claim/submit/review/state operation was performed.

All authored files are under `godot/build/cx11/` or `docs/qa/cx11/`. Godot's import cache/log exceptions are permitted by the brief. Custom SceneTree scripts cause `SaveFile.path()` to resolve to `user://tests/` before autoload save handling; all final completion records confirm the three test paths and `persist=false`. No player save was read, written, moved, deleted, or enumerated. The probes write no save fixtures, so there are no probe-owned test saves to remove. Product files and existing unrelated changes are untouched; no Git history operations were performed.

Structured task result: **QA execution complete; issues reported; no fixes applied; human playtest and canonical project state unchanged.**
