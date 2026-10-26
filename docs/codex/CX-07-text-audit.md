# CX-07 · English copy review, canon consistency audit, unused Korean keys

Read `docs/codex/RULES.md` first and follow it. Three read-only reviews of the game text.
Do not edit game files; Claude decides and applies. Do not run Godot.

## Output folder

`docs/qa/2026-10-26-text-audit/` only. Write each part's file as soon as that part is
done, so a stop part-way still leaves results.

## Sources (read only)

`godot/data/scenarios.json`, `intranet.json`, `horizon.json`, `people.json`,
`shoply.json`, `godot/i18n/ko.json`, `godot/scripts/` (for strings in code),
`docs/story/CANON-MAP.md`, `docs/NOTHING_WRONG_ALL_IN_ONE.md`, and the earlier reviews in
`docs/qa/` (do not repeat findings already fixed there).

## Part 1 · English copy review → `english.md`, `english.json`

English is the source text; only the Korean has been reviewed. Review the dialogue
(briefings, debriefs, hints, assists, deduction prompts and success lines, chapter
synopses and epilogues, endings) and Ticket text.

Look for: unclear or ambiguous sentences; words a player could misread; tone that slips
for a character (Mina: warm, direct QA lead; Grace: formal, guarded; Alex: technical,
dry; Marcus, Priya, Leo, Elena in the prologue); exposition that tells the player what
they should have found themselves; typos and grammar. Keep suggestions short and the
same length or shorter. Skip the Shoply storefront and ONE HORIZON portal UI.

`english.json`: a list of `{ "file", "path" (JSON path or ticket/field), "current",
"suggested", "category" (clarity|tone|exposition|grammar), "severity" (P1|P2|P3),
"reason" }`. `current` must match the source exactly. A changed English string needs a
new Korean line too; say so in `reason` when the Korean must change in meaning.

## Part 2 · Canon consistency audit → `canon.md`, `canon.json`

Check that facts agree everywhere they appear: dates and times (17 October 2021 and the
timeline 22:48 / 23:06 / 23:11 / 23:18 / 00:14), employee and record IDs (E-18419,
P-004217, INC-1017, CASE-2021-1012, IMG001–IMG007, …), names and titles, counts (38
people at Horizon Ridge, 12 in IMG002, …), money and percentages, which Ticket reveals
what (a later fact must not be stated earlier), and the guardrails in RULES.md.

`canon.json`: `{ "fact", "locations": [ ... ], "conflict", "suggested_fix",
"severity" }`. Only real conflicts.

## Part 3 · Unused Korean keys → `unused-keys.md`, `unused-keys.json`

List `ko.json` keys that no code, scene, or content file can produce. Be careful: code
builds keys with `Kit.t(...)`, `Kit.tf(template, ...)`, and from data fields (titles,
labels, options, notes). Also check `.tscn` files and `project.godot`. Classify each as
`unused` (safe to delete) or `unsure` (could be built dynamically; say how).
`unused-keys.json`: `{ "unused": [keys], "unsure": [{ "key", "why" }] }`.

## Finish

A short `README.md` in the folder: counts per part and the top five items overall.
