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

Saves live in Godot's user folder (`user://save.json`, `user://workspace.json`,
`user://settings.json`). Each is written to a temporary file that then replaces the old
one, so a save cut short leaves the previous one whole; an unreadable save is kept as
`user://save.unreadable.json` and a new game starts. **New game** on the title screen
(shown once there is progress, with a confirmation) resets progress, Evidence, and notes;
the language and sound settings stay. Saves from builds since `ef3a593` (2026-10-21) load
in full; saves from the first Godot build (`9131493`) keep their progress and notes, but
some of their old chat can repeat or be missing (`docs/qa/cx09/report.md`).

## Build

```powershell
& "<path>\Godot_v4.7.2-stable_win64_console.exe" --headless --path godot --export-release "Windows Desktop" build/windows/NothingWrong.exe
& godot\build\windows\NothingWrong.exe --headless --quit-after 3000 -- --self-check | Out-String
& "<path>\Godot_v4.7.2-stable_win64_console.exe" --headless --path godot --quit-after 3000 -- --self-check
```

Run both. The exported build shows that the content was packed. Release templates do
not report GDScript runtime errors, so the editor run is the one that catches those.
`| Out-String` makes PowerShell wait for the game and set `$LASTEXITCODE`.

The preset (`export_presets.cfg`) includes `data/*.json` and `i18n/*.json` and leaves
out `tests/` and `build/` (QA scratch, which once added 221 MiB). The game draws at most 60
frames a second (`application/run/max_fps`), so an idle desktop does not keep a CPU core
busy. `--self-check` (`scripts/autoload/self_check.gd`) parses every content
file, opens each screen once on a session that saves nothing, and prints `Self-check
passed` with exit 0 only when nothing is missing and no error was logged. A build that
prints anything else, or nothing (a script that does not parse), has failed;
`--quit-after` keeps such a run from waiting forever. Export
templates for 4.7.2 must be installed; the build goes to `godot/build/`, which is ignored.

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
- **Conversations (DEC-014, DEC-015):** each chapter talks in its own channel (`channel`
  on a chapter, story, message, or deduction in `data/scenarios.json`). Direct messages
  are for what someone keeps from the channel and for help: "Stuck? Ask Mina for a hint"
  in QA Notes, and the team's nudges after missed reports. Messenger lists the
  conversations the story has opened with unread badges, follows the newest message until
  the player picks another one, and points the composer to the conversation where the
  team is waiting. A narrow window folds the list into a picker above the chat.
- **Workday (DEC-015):** each Ticket's chat waits at its first message: the taskbar clock
  runs forward ("2 hours later"), the message comes up as a notification, and the chat goes
  on when the player opens it. A Ticket on another story day ends the day first: the
  afternoon runs to 18:00, **Clock out**, a night screen, and the lock screen the next
  morning. A Ticket appears in QA Notes once its first message arrives.
- **Arrange:** the taskbar button puts the Browser on the left three quarters and QA Notes
  on the right, both full height (spec links use the same split). A narrow QA Notes picks
  Tickets from a drop-down.
- **Directory:** `people.northstar.local` (linked from the new tab page and from names in
  Messenger) lists our team and the client contacts: title, team, manager, address, and
  what each person looks after (`data/people.json`). Each entry shows from the Ticket that
  introduces it (`since`), so it never runs ahead of the story. Photos are badge photos
  from each person's first week (`photo.taken`, DEC-018), so they may not look like the
  person now; Mina says so at T13 and T24. Images live in `assets/people/`, and Shoply's
  product photos in `assets/products/` (`Kit.picture`, with initials or a colour block as
  the fallback).
- **Key terms:** chat messages and clue cards show record IDs, codes, dates, times, and
  the names in `data/key_terms.json` in bold (`scripts/domain/key_terms.gd`).
- **Text input:** the window's IME is switched on whenever a text field takes focus
  (`scripts/ui/main.gd`), for Korean input in search and notes.
- **Chapters:** Chapter 1 (T01–T04) finds why RC3 broke; Chapter 2 (T05–T07) finds who
  opened the archive, through device-specific defects and a chain of records; Chapter 3
  (T08–T09, the weekend after release) finds who approved it, through a test order and a
  Gold-only coupon holdout; Chapter 4 (T10–T12, the Monday after) checks the rollback with
  the plan's remaining Ticket types: a cross-screen comparison (T10), a Ticket with two
  defects that both have to be reported (T11), and a regression pass over last week's
  fixes (T12). Chapters 1–4 are a prologue: the master synopsis
  (`docs/NOTHING_WRONG_ALL_IN_ONE.md`) continues from Chapter 5 (ONE HORIZON, ACT 2,
  T13–T15 = NW-003–005, T16–T19 = NW-006–009) and Chapter 6 (ACT 3, T20–T24 = NW-010–014) and Chapter 7 (ACT 4, T25–T29 = NW-015–019,
  where the Case File opens), Chapter 8 (ACT 5, T30–T36 = NW-020–026), Chapter 9 (ACT 6,
  T37–T41), and the Final (T42, NW-FINAL): a release check with a three-inspection coverage
  budget (`view.inspect`), then a choice on the Case File that decides the ending
  (`deduction.mode = "choice"`, `chapter.endings`, `optionRequires`). See
  `docs/story/CANON-MAP.md` and DEC-013.
- **ONE HORIZON QA portal:** `qa.onehorizon.local` shows read-only UAT snapshots of Horizon
  systems as record tables or Source/Target compares (`data/horizon.json`, one generic
  screen in `scripts/ui/horizon/record_view.gd`). Cells can be noted and reported like
  Shoply values. Tickets may offer several outcomes (`ticket.outcomes`: BUG,
  DATA_INTEGRITY, DOC_GAP).
- **Photos (DEC-017):** a row's `photo` names an image in `assets/photos/` (`IMG001.jpg`)
  and how the view draws it: `crop` (fractions of the image), `rotate`, and per-side or
  per-device overrides (`source`, `target`, `byViewport`), so a thumbnail cut, a tablet
  layout, or an unrotated preview is drawn from the one source image. Clicking a photo
  shows it large; a Note on it records the column named by `notes`. The alt text and
  metadata stay in the row, so a missing image never blocks play. The images were made
  from one face and emblem reference sheet (`docs/story/photos/`).
- **Canon gate:** `tests/test_canon.gd` fails if a chapter mentions something the story has
  not reached yet, or states what the canon leaves open (`data/canon.json`).
- **No tutorial overlay:** the team's messages are the guide. Mina's T01 briefing
  explains noting and reporting; each Ticket offers "Stuck? Ask Mina for a hint" in QA
  Notes, answered in a direct message.
- **Notifications** rise from behind the taskbar in the bottom-right corner.
- **Art:** the title, lock screen, and desktop draw `assets/art/title.jpg`, `lock.jpg`, and
  `wallpaper.jpg` (`Kit.backdrop`, which falls back to a plain colour), and the window and
  executable use `assets/art/icon.png` / `icon.ico` (`modify_resources=true` in the export
  preset embeds the icon). Sources and notes: `docs/art/2026-10-26/`.
- **Browser tabs:** links and lead searches from other apps open in a new tab (up to six),
  so the page under test stays open; each tab keeps its own Back/Forward history.
- **Sound:** synthesized effects and office ambience (`scripts/autoload/sfx.gd`); toggle on
  the title screen or the taskbar speaker.

## Content

Edit content directly in `data/`: `scenarios.json` (tickets, story, chapters),
`intranet.json` (searchable records), `horizon.json` (ONE HORIZON record views),
`people.json` (the directory), and `shoply.json` (products and orders). Add the Korean
text for every new string to `i18n/ko.json`; `tests/test_workstation.gd` fails when a
ticket, story, or record string has no Korean, or when a key term (티켓, 보고, QA 노트,
사건 파일, 조직도, 추리, 📌 메모) is worded another way. The 📌 Note action is 메모 in Korean;
기록 means the records the story turns up.

## Tests

```powershell
& "<path>\Godot_v4.7.2-stable_win64_console.exe" --headless --path godot --script res://tests/run_tests.gd
```

- `tests/test_domain.gd`, `tests/test_review.gd`: pure game logic (conditions, every
  Mutation active only under its conditions, Review scoring, Game State, messenger log,
  addresses, pricing, the directory), and that Shoply never names a Ticket.
- `tests/test_canon.gd`: no chapter reveals what the story has not reached.
- `tests/test_ui_flow.gd`: plays the real desktop scene by pressing its buttons:
  `test_full_story` plays T01–T42 and the Final; others cover notifications, the
  workday, hints, Arrange, and the directory.
- `tests/test_saves.gd`: saves cut short, unreadable saves, saves in the wrong shape, a
  long session that keeps its screen visits, and a reload mid-chapter.
- `tests/test_workstation.gd`: Korean coverage, terminology, and conclusions that read
  with every option; photos and their drawn defects; spec pinning; window resizing and
  dragging; and windows that fit 1280x720 and 1024x640.

Tests (and the screenshot tour) save under `user://tests/`, never over the player's saves.

Visual check (renders each screen to PNG; uses a throwaway session):

```powershell
& "<path>\Godot_v4.7.2-stable_win64_console.exe" --path godot --resolution 1280x720 --script res://tests/screenshot_tour.gd -- <output-dir> ko 1280x720
```

The third argument sets the screen size (default 1440x900).

## Layout

| Path | Purpose |
| --- | --- |
| `scripts/domain/` | Pure logic ported from `src/game` (no nodes) |
| `scripts/autoload/` | `GameSession`, `WorkspaceSession`, `ShoplyStore`, `DesktopSession` |
| `scripts/ui/` | Title, lock screen, desktop, window frame, theme (`kit.gd`, `palette.gd`) |
| `scripts/ui/apps/` | Messenger (+ report form), Browser (+ Console, Note), QA Notes (+ Case File) |
| `scripts/ui/shoply/` | Shoply storefront pages; reads Mutations only through `mutate()` |
| `data/` | Content: scenarios, records, record views, directory, Shoply catalog |
| `assets/photos/` | Story and event photos shown on record views |
| `assets/art/` | Title, lock screen, and desktop pictures, and the game icon |
| `assets/people/`, `assets/products/` | Directory badge photos and Shoply product photos |
