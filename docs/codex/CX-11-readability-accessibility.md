# CX-11 · Readability and accessibility

Read `docs/codex/RULES.md` first and follow it.

Scratch: `godot/build/cx11/`. Report: `docs/qa/cx11/report.md` and `findings.csv` (write
as you go).

## Goal

Measure, not judge by eye alone, whether text is readable and the UI is usable with the
keyboard, especially where text now sits over pictures (title card, lock-screen clock and
date, desktop icon labels over the wallpaper, photo captions and badge captions).

## Steps

1. Run the screenshot tour at 1280x720 and 1920x1080, Korean and English (command in
   RULES.md).
2. Write a probe that opens the main screens (title, lock, desktop, each app, a record
   view with photos, the directory, a person page, Shoply product page, Case File, the
   report form, a deduction form) and walks the visible Labels, Buttons, and LineEdits.
   For each, record the font size, font colour, and the background colour behind its
   rectangle, sampled from the rendered frame. Compute the WCAG 2.1 contrast ratio.
   Flag text under 4.5:1 (or under 3:1 if 18 px or larger, or 14 px or larger and bold),
   and any text under 12 px.
3. Keyboard: from the title screen, can the player reach and press the main actions with
   Tab/Shift+Tab and Enter/Space (Start work, Sign in, app icons, Start test, Note, Send
   report, deduction drop-downs and Send, Clock out)? Is focus visible? Record where focus
   gets lost or trapped.
4. `findings.csv`: `screen,element,text,size_px,ratio,required,problem,priority`. Use P1
   for unreadable or unreachable controls that block play, P2 for hard to read, P3 for
   polish. `report.md`: summary counts, top issues, and method limits. Intentionally
   faint decoration, such as the wallpaper star, is not text.

Do not fix code.
