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
  testing. Typing a `docs.northstar.local` address still opens it in the Browser.
- **Three apps (DEC-010):** Messenger (the team and your reports), Browser, and QA Notes.
  QA Notes is the workbook: a page per Ticket (Start test, request, requirements, pinned
  spec, what you noted, your own notes) and the Case File. There is no
  XP, level, or reputation; the job grows as the team assigns Tickets and tools.
- **Deduction first (DEC-009):** testing Shoply is how the player explores; the story
  is the game. A defect leaves a trace in the Browser **Console** (`trace` on a Mutation:
  a log line plus `terms`), mixed in with everyday log lines (`CONSOLE_NOISE` in
  `browser_app.gd`) and with no badge, so the player has to read it. Terms the player has
  seen are remembered quietly: they open a record early (`unlockedByLeads` in
  `data/intranet.json`); the clue connects once the defect is reported.
- **Note, then report:** **📌 Note** in the Browser highlights what can be recorded on the
  page; clicking one saves it to QA Notes with the screen and its console. The report is
  a message to the Ticket's sender in Messenger: pick a note and the requirement it
  breaks, or say nothing is wrong (NO ISSUE FOUND). Steps, Evidence, and severity are
  filled in by `scripts/domain/report_draft.gd`. The sender answers in the chat: the
  debrief when it is right, or a hint about where to look (wrong screen, state, value, or
  rule). After a few misses the team gives a nudge and then the answer (`story.assist` in
  `data/scenarios.json`; T01 helps after one miss).
- **Intranet search (DEC-011):** `search.northstar.local` (also on the Browser's new
  tab). The player types what they read; searches accept English or Korean keywords and
  one typo. Some records are a hop away: a record names the next term to search
  (`unlockedByDocuments`), and decoy records answer broad searches. After two searches
  that miss the record the team is waiting for, Messenger suggests a term
  (`discovery.searchTerms`). Opening that record reveals the clue.
- **Deductions:** a conclusion with blanks (`deduction.sentence`, `blanks`). The player
  fills each blank from a drop-down and sends it; the lead answers with how many parts
  hold up, or `success`. Chapter finales (`mode = "board"`) are answered on the Case File,
  with the clues found so far listed above the sentence.
- **Story clock:** each Ticket starts at a set time (`story.time`, e.g. `Thu 15:30`); chat
  messages are stamped from it (two minutes per message) with a divider for each day,
  and the taskbar clock follows the chat. A wrong report or a wrong conclusion costs 20
  minutes (`PENALTY` in `messenger_log.gd`). Each chapter counts down to its deadline
  (`chapter.deadline`): code freeze, the release, the billing run, the leadership review.
  Nothing blocks play, but a finale answered after the deadline closes the chapter with
  its `lateEpilogue`.
- **Chat delivery** is saved as the last delivered entry's id, so messages added to the
  story later never replay the conversation.
- **Text input:** the window's IME is switched on whenever a text field takes focus
  (`scripts/ui/main.gd`), for Korean input in search and notes.
- **Chapters:** Chapter 1 (T01–T04) finds why RC3 broke; Chapter 2 (T05–T07) finds who
  opened the archive, through device-specific defects and a chain of records; Chapter 3
  (T08–T09, the weekend after release) finds who approved it, through a real order and a
  Gold-only coupon holdout; Chapter 4 (T10–T12, the Monday after) checks the rollback with
  the plan's remaining Ticket types: a cross-screen comparison (T10), a Ticket with two
  defects that both have to be reported (T11), and a regression pass over last week's
  fixes (T12). Chapters 1–4 are a prologue: the master synopsis
  (`docs/NOTHING_WRONG_ALL_IN_ONE.md`) continues from Chapter 5 (ONE HORIZON, ACT 2,
  T13–T16 = NW-006–009). See `docs/story/CANON-MAP.md` and DEC-013.
- **ONE HORIZON QA portal:** `qa.onehorizon.local` shows read-only UAT snapshots of Horizon
  systems as record tables or Source/Target compares (`data/horizon.json`, one generic
  screen in `scripts/ui/horizon/record_view.gd`). Cells can be noted and reported like
  Shoply values. Tickets may offer several outcomes (`ticket.outcomes`: BUG,
  DATA_INTEGRITY, DOC_GAP).
- **Canon gate:** `tests/test_canon.gd` fails if a chapter mentions something the story has
  not reached yet, or states what the canon leaves open (`data/canon.json`).
- **No tutorial overlay:** the team's messages are the guide. Mina's T01 briefing
  explains noting and reporting; each Ticket keeps an optional "Need a hint?" in QA Notes.
- **Notifications** rise from behind the taskbar in the bottom-right corner.
- **Browser tabs:** links and lead searches from other apps open in a new tab (up to six),
  so the page under test stays open; each tab keeps its own Back/Forward history.
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
