# Nothing Wrong — Godot build

The game client, built with Godot 4.7 and GDScript. This is the only build that is
developed and shipped (DEC-008); the React/Vite code in the repository root is a frozen
reference and is not updated.

## Run

Open `godot/project.godot` in the Godot 4.7 editor and press **Run**, or from the
repository root:

```powershell
& "<path>\Godot_v4.7.2-stable_win64.exe" --path godot
```

Saves live in Godot's user folder (`user://save.json`, `user://workspace.json`).
**New game** on the title screen resets them.

## Playing

- **Language:** choose 한국어 or English on the title screen (Korean is the default on a
  Korean system). Korean text lives in `i18n/ko.json`, keyed by the English source. The
  Shoply storefront stays in English on purpose: it is an in-world client site.
- **Windows:** drag anywhere on a title bar; drag to the left/right screen edge to fill
  that half, or to the top to maximize; resize from any edge or corner.
- **Spec documents:** links to intranet documents pin the document into the Ticket's
  QA Notes and place QA Notes beside the Browser, so the spec stays readable while
  testing. Typing a `docs.nothingwrong.local` address still opens it in the Browser.
- **Three apps (DEC-010):** Messenger (the team and your reports), Browser, and QA Notes.
  QA Notes is the workbook: a page per Ticket (Start test, request, requirements, pinned
  spec, what you noted, console leads, your own notes) and the Case File. There is no
  XP, level, or reputation; the job grows as the team assigns Tickets and tools.
- **Deduction first (DEC-009):** testing Shoply is how the player explores; the story
  is the game. A defect leaves a trace in the Browser **Console** (`trace` on a Mutation:
  a log line plus lead `terms`). The Console button shows `⚠ n` when the screen logged
  something. Opening it, or noting something on that screen, records the terms as
  **leads** (QA Notes, Case File, Messenger). A lead opens its intranet record early
  (`unlockedByLeads` in `data/intranet.json`); the clue connects once the defect is
  reported.
- **Note, then report:** **📌 Note** in the Browser highlights what can be recorded on the
  page; clicking one saves it to QA Notes with the screen and its console. The report is
  a message to the Ticket's sender in Messenger: pick a note and the requirement it
  breaks, or say nothing is wrong (NO ISSUE FOUND). Steps, Evidence, and severity are
  filled in by `scripts/domain/report_draft.gd`. The sender answers in the chat: the
  debrief when it is right, or a hint about where to look (wrong screen, state, value, or
  rule). After a few misses the team gives a nudge and then the answer (`story.assist` in
  `data/scenarios.json`; T01 helps after one miss).
- **Intranet search:** `search.nothingwrong.local` (also on the Browser's new tab). Leads
  are one-click searches; typed searches accept English or Korean keywords and one typo.
  Opening the record a debrief asks for reveals the clue and lets the story continue.
- **No tutorial overlay:** the team's messages are the guide. Maya's T01 briefing
  explains noting and reporting; each Ticket keeps an optional "Need a hint?" in QA Notes.
- **Notifications** rise from behind the taskbar in the bottom-right corner.
- **Browser tabs:** links and lead searches from other apps open in a new tab (up to six),
  so the page under test stays open; each tab keeps its own Back/Forward history.
- **Case File board:** the T04 finale is answered on the Case File by picking the clues
  that prove a conclusion (`deduction.mode = "board"`, `requiredClues`).
- **Sound:** synthesized effects and office ambience (`scripts/autoload/sfx.gd`); toggle on
  the title screen or the taskbar speaker.

## Content

Edit content directly in `data/`: `scenarios.json` (tickets, story, chapters),
`intranet.json` (searchable records), and `shoply.json` (products and orders). Add the
Korean text for every new string to `i18n/ko.json`; `tests/test_workstation.gd` fails
when a ticket, story, or record string has no Korean.

## Tests

```powershell
& "<path>\Godot_v4.7.2-stable_win64_console.exe" --headless --path godot --script res://tests/run_tests.gd
```

- `tests/test_domain.gd`, `tests/test_review.gd`: pure game logic (conditions, Mutations,
  Review scoring, Game State, messenger log, addresses, pricing).
- `tests/test_ui_flow.gd`: plays the real desktop scene by pressing its buttons,
  including the whole of Chapter 1 (T01→T04).
- `tests/test_workstation.gd`: Korean catalog coverage for every ticket, story, and record
  string, spec pinning beside the Browser, window resizing, and title-bar dragging.
- The full-chapter UI test also searches for every record, answers the clue board, and
  closes T05 as NO ISSUE FOUND.

Visual check (renders each screen to PNG; uses a throwaway session):

```powershell
& "<path>\Godot_v4.7.2-stable_win64_console.exe" --path godot --resolution 1440x900 --script res://tests/screenshot_tour.gd -- <output-dir> [ko|en]
```

## Layout

| Path | Purpose |
| --- | --- |
| `scripts/domain/` | Pure logic ported from `src/game` (no nodes) |
| `scripts/autoload/` | `GameSession`, `WorkspaceSession`, `ShoplyStore`, `DesktopSession` |
| `scripts/ui/` | Title, lock screen, desktop, window frame, theme (`kit.gd`, `palette.gd`) |
| `scripts/ui/apps/` | Messenger (+ report form), Browser (+ Console, Note), QA Notes (+ Case File) |
| `scripts/ui/shoply/` | Shoply storefront pages; reads Mutations only through `mutate()` |
| `data/` | Exported content (generated) |
