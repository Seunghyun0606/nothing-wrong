# Working journal (historical)

Early counts and pending labels below were superseded by report.md.

# CX-11 readability and keyboard accessibility

Status: running. Scope: measurement and reporting only; no product fixes or Project OS transitions.

## Execution journal

- 2026-10-26: Read PROJECT.md, Project OS manifest/current state, CX-11, and RULES.md. Role: Codex QA; the explicit CX-11 brief is the assigned task.
- Inspected the screenshot tour and startup save handling. `SaveFile.path()` sends custom SceneTree scripts to `user://tests/`; no player save is read, inspected, or changed. Probes additionally disable session/settings persistence.
- Planned matrix: Korean and English at 1280x720 and 1920x1080, sequential Godot processes. Original screenshot tour plus an instrumented scratch probe, rendered text/background pairs, font metadata, and injected keyboard events.
- Thresholds follow the brief: 4.5:1, relaxed to 3:1 at >=18 px or >=14 px bold; flag <12 px. These size thresholds are project-specific: WCAG uses 18 pt / 14 pt bold (approximately 24 px / 18.7 px). Both threshold interpretations will be retained in raw measurements.

## Results

Pending execution. Findings are appended to findings.csv as each probe frame is measured.

## Method and limits

This is automated QA, not TASK-010 or a human playtest. Text metadata comes from instantiated controls; backgrounds will be sampled from rendered frames with text temporarily made transparent in the scratch process. No source/UI changes are saved.

References: [W3C contrast minimum](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html), [W3C focus visible](https://www.w3.org/WAI/WCAG21/Understanding/focus-visible.html).

- Run `tour-en-1280x720`: exit 0, 32 PNGs, 0 metadata frames; logs in `godot/build/cx11/`.

- Run `tour-en-1920x1080`: exit 0, 32 PNGs, 0 metadata frames; logs in `godot/build/cx11/`.

- Run `tour-ko-1280x720`: exit 0, 32 PNGs, 0 metadata frames; logs in `godot/build/cx11/`.

- Run `tour-ko-1920x1080`: exit 0, 32 PNGs, 0 metadata frames; logs in `godot/build/cx11/`.

- Run `probe-en-1280x720`: exit 0, 107 PNGs, 36 metadata frames; logs in `godot/build/cx11/`.

- Run `probe-en-1920x1080`: exit 0, 107 PNGs, 36 metadata frames; logs in `godot/build/cx11/`.

- Run `probe-ko-1280x720`: exit 0, 107 PNGs, 36 metadata frames; logs in `godot/build/cx11/`.

- Run `probe-ko-1920x1080`: exit 0, 107 PNGs, 36 metadata frames; logs in `godot/build/cx11/`.

- Run `probe-en-1280x720`: exit 0, 136 PNGs, 36 metadata frames; logs in `godot/build/cx11/`.

- Follow-up: forward-only activation failures were retested using Shift+Tab. Send report and deduction controls respond from a fresh focus state through reverse traversal; do not classify them as inherently unreachable. Evidence marker Buttons have FOCUS_NONE and fail both traversal directions. Probe refined to mask occluding app windows/toasts and let animation settle before contrast sampling.

- Run `probe-en-1920x1080`: exit 0, 136 PNGs, 36 metadata frames; logs in `godot/build/cx11/`.

- Run `probe-ko-1280x720`: exit 0, 136 PNGs, 36 metadata frames; logs in `godot/build/cx11/`.

- Run `probe-ko-1920x1080`: exit 0, 136 PNGs, 36 metadata frames; logs in `godot/build/cx11/`.

- `trap-en-1280x720`: stateful Tab, Shift+Tab, and Escape all leave focus in MyNotes; forward Tab inserts a tab in the unsaved in-memory note. Exit 0.

- `trap-en-1920x1080`: stateful Tab, Shift+Tab, and Escape all leave focus in MyNotes; forward Tab inserts a tab in the unsaved in-memory note. Exit 0.

- `trap-ko-1280x720`: stateful Tab, Shift+Tab, and Escape all leave focus in MyNotes; forward Tab inserts a tab in the unsaved in-memory note. Exit 0.

- `trap-ko-1920x1080`: stateful Tab, Shift+Tab, and Escape all leave focus in MyNotes; forward Tab inserts a tab in the unsaved in-memory note. Exit 0.
