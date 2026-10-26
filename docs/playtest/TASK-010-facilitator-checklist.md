# TASK-010 facilitator checklist

Build: the commit named in the package's `BUILD.txt` (the zip is `NothingWrong-<commit>.zip`).
Use one copy of the [session template](TASK-010-session-template.md) per participant.

## Before the session

- [ ] Unzip `NothingWrong-<commit>.zip`; keep the `NothingWrong` folder intact.
  On the facilitator's Windows account, verify the ZIP and extracted EXE against
  `SHA256SUMS.txt` from the package root using PowerShell:
  `Get-FileHash .\NothingWrong-<commit>.zip -Algorithm SHA256` and
  `Get-FileHash .\NothingWrong\NothingWrong.exe -Algorithm SHA256`.
  Both hashes must match; stop if either differs.
- [ ] Run the exported check from that root:
  `.\NothingWrong\NothingWrong.exe --headless --quit-after 3000 -- --self-check | Out-String`.
  Require **Self-check passed** and `$LASTEXITCODE` equal to **0**.
  Complete both checks described in [godot/README.md, Build](../../godot/README.md#build),
  including the editor check; retain the output. This package's two build-check
  results are in `self-check.txt` beside the ZIP.
- [ ] Copy the session template. Record date/timezone, pseudonym, facilitator, full
  tested commit, exported build, OS/screen size, and language. Ask permission for
  recordings/screenshots before capturing them; leave unknown fields blank.
- [ ] For the human session, launch `NothingWrong.exe`. Follow the template's fresh-save
  setup: **Start work** means fresh; if **Continue work** appears, choose **New game**,
  then **Yes, start a new game**. Use a session account whose progress may be reset.
  Confirm freshness in the record. Choose **한국어** or **English** on the title screen;
  New game keeps language and sound settings. Avoid deleting save files by hand.

## During the session

- [ ] Give the participant only the [participant guide](TASK-010-participant-guide.md).
  Keep the session template with the facilitator. Do not provide repository tests,
  specifications, or story documents; they contain answers.
- [ ] Ask the participant to think aloud. Record their wording, hesitations, actions,
  hints, and unexpected behavior in the template. Let them try QA Notes' hint link
  before coaching. Watch the template's listed moments without prompting about them.
- [ ] Record reproducible defects with Ticket, state, steps, expected/actual results,
  and second-attempt result. Mark unreached steps **not reached**; finishing is optional.

## After the session

- [ ] Ask all six required questions; collect each response and a concrete example.
  Collect the completed session record; keep identifying information private unless
  permission was given.
- [ ] Close the game. Keep `save.json` and `workspace.json` from
  `%APPDATA%\Godot\app_userdata\Nothing Wrong` only with explicit participant consent.
  Record whether consent was given; leave files alone otherwise.
- [ ] Record the full build commit above in the session record. Hand records to the
  human product decision-maker; leave the template's human decision section to them.
  TASK-010 and M4 remain open until their human observations and decision are satisfied.
