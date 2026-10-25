# CX-04 · Korean copy review

Read `docs/codex/RULES.md` first and follow it.

## Goal

Review the Korean text of the game and list what should change. Do not edit `ko.json`;
Claude applies the accepted suggestions.

## Sources (read only)

- `godot/i18n/ko.json`: every Korean string, keyed by its English source.
- `godot/data/scenarios.json`: who says each line (`from`, `role`), in which Ticket and
  chapter. Use it to judge each character's voice.
- `godot/data/intranet.json`, `godot/data/people.json`, `godot/data/horizon.json`:
  record and directory text.
- `docs/story/CANON-MAP.md` and `docs/NOTHING_WRONG_ALL_IN_ONE.md`: what each line may and
  may not claim.
- `godot/tests/test_workstation.gd`: the term rules the tests already enforce (티켓, 보고,
  QA 노트, 사건 파일, 조직도, 추리, 📌 메모; 기록 means records). Keep them.
- `docs/qa/2026-10-25-review-disposition.md`: what was already fixed (F04, F09).

## What to look for, in this order

1. Meaning errors: the Korean says something different from the English, or claims more
   than the canon allows (e.g. treats a photo as proof, confirms a cause of death).
2. Continuity: dates, times, IDs, names, and numbers that differ from the English or from
   the records.
3. Voice: each character speaks the same way throughout (Mina Seo, the QA lead, uses polite
   colleague speech; Grace Yoon is formal and guarded; Alex Han is technical; Marcus,
   Priya, Leo, Elena in the prologue). Flag lines where a character's speech level or
   personality slips.
4. 번역투 and unnatural phrasing in dialogue, especially briefings, debriefs, hints, and
   chapter epilogues. Suggest natural Korean that keeps the meaning and length.
5. UI strings: consistent, short, and clear; placeholders (`%s`, `%d`, `{blank}`) kept.
6. Deduction sentences (`deduction.sentence`) and their options: they must read correctly
   with every option (no particle right after a blank that depends on the word before it).

Skip the Shoply storefront and ONE HORIZON portal text that stays English on purpose.

## Output folder

`docs/qa/2026-10-26-korean-copy/` only:

- `review.md`: a short summary (how many lines checked, main patterns), then a table per
  category with: English key (shortened if long, but unique), current Korean, suggested
  Korean, reason, severity (P1 meaning/continuity, P2 voice/naturalness, P3 polish).
- `suggestions.json`: the same suggestions as a JSON list of objects
  `{ "key": <exact English key>, "current": <exact current Korean>, "suggested": <Korean>,
  "category": <meaning|continuity|voice|naturalness|ui|deduction>, "severity": <P1|P2|P3>,
  "reason": <short> }`. Keys and current values must match `ko.json` exactly so the
  suggestions can be applied mechanically.

Keep suggestions to real improvements, not rewrites for taste. Suggested text must keep
placeholders and the term rules. Do not edit any other file.
