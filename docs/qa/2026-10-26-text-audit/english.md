# CX-07 Part 1: English copy review

Status: completed with editorial suggestions; no product changes. Static source review, not a human playtest.

11 source locations (3 P1 / 5 P2 / 3 P3); 11 distinct English strings.

Reviewed all 42 tickets (requests, requirements, attachments, hints), all briefings/debriefs, assists, clues, discovery hints, 19 deduction prompts/templates/options/success lines, 10 chapter synopses, regular/late epilogues, all three endings, and shared report/chat copy in scripts. Read intranet and directory text for context. Storefront and portal UI copy are excluded from editorial suggestions as requested.

P1: meaning, reveal, or canon-risk wording. P2: consequential clarity/exposition. P3: minor wording. Suggestions are the same length or shorter by Unicode character count; the JSON stores exact source values and full replacement strings. Changed source strings need replacement Korean keys even when the existing translated meaning can stay. No Korean or game files were changed.

The Case File renders each arrived chapter synopsis in `notes_app.gd::_case_file`, gated by `Catalog.is_case_file_open`. CH5–CH7 stay hidden until T28 resolves: their source/death summaries are not early reveals. CH9 becomes visible when T37 arrives and does expose later conclusions. Part 2 checks the corresponding canon conflict. Deliberately explicit second-miss assists and the early prologue tutorials are retained. No blanket redistribution of Mina dialogue is proposed: the earlier review disposition leaves that to TASK-010.

Earlier resolved items were checked and excluded: T26 night timing, T27 original-record availability, T38 camera-clock approximation, SAVE10 subtotal eligibility, T21 qualified success line, Korean particle rewrites, and already-applied Korean tone/naturalness changes.

The final delivery trace also excluded the Shoply-specific `evaluate_bug` detection-feedback string: the current Messenger renders `reply_hint` or the last fallback feedback item, not that first internal feedback item. It is not reported as an active player-facing copy defect.

## E01 · P2 · clarity

Location: `godot/data/scenarios.json` → `$.scenarios[7].ticket.request`

**Current:** Gold members say their order page shows more than they paid at checkout. Place a real order and compare.

**Suggested:** Gold members say their order page shows more than they paid at checkout. Place a test order and compare.

T08 runs on a staging site. "Real order" can suggest a live purchase; "test order" names the action accurately. New Korean key and revised Korean meaning required.

## E02 · P2 · clarity

Location: `godot/data/scenarios.json` → `$.scenarios[7].story.briefing[2].text`

**Current:** We look anyway. Place a real order as a Gold member with SAVE20, then open it from Orders.

**Suggested:** We look anyway. Place a test order as a Gold member with SAVE20, then open it from Orders.

Same staging-versus-live ambiguity as the T08 request. Keep both instructions consistent. New Korean key and revised Korean meaning required.

## E03 · P3 · clarity

Location: `godot/data/scenarios.json` → `$.scenarios[13].story.assist[1].text`

**Current:** Here's the answer: IMG001's thumbnail cuts the young man on the right. Note the Target description and report it with REQ-T14-01.

**Suggested:** Here's the answer: IMG001's thumbnail crops out the young man on the right. Note Target and report it with REQ-T14-01.

"Cuts the young man" lacks "out" and can describe an injury. This is an image crop. New Korean key required; the existing Korean meaning can be retained.

## E04 · P3 · clarity

Location: `godot/data/scenarios.json` → `$.scenarios[17].ticket.hints[0].text`

**Current:** A record missing from Target is still a record.

**Suggested:** Compare missing Target rows with Source.

The tautology does not tell a stuck player what to compare. This names the two columns without supplying the answer. New Korean key and revised Korean meaning required.

## E05 · P2 · clarity

Location: `godot/data/scenarios.json` → `$.scenarios[20].story.assist[1].text`

**Current:** Here's the answer: each system moved in its own year, and the orchestrator copies as-is. Nothing here is broken: report NO ISSUE FOUND.

**Suggested:** Here's the answer: each system moved in its own run, and the orchestrator copies as-is. Nothing here is broken: report NO ISSUE FOUND.

"Each system moved in its own year" suggests five distinct years. The view shows five systems across three years, each in a separate run. New Korean key and revised Korean meaning required.

## E06 · P3 · grammar

Location: `godot/data/scenarios.json` → `$.scenarios[33].ticket.hints[0].text`

**Current:** Do the arithmetic the screen shows, then the ledger.

**Suggested:** Check the screen's arithmetic against the ledger.

"Do the arithmetic ... then the ledger" leaves out the second verb and obscures the comparison. New Korean key required; the existing Korean meaning can be retained.

## E07 · P1 · clarity

Location: `godot/data/scenarios.json` → `$.scenarios[40].ticket.request`

**Current:** Check that every vendor record names its legal parent and its controlling interest.

**Suggested:** Check each vendor's legal parent and source of influence, allowing none.

"Controlling interest" commonly means an ownership stake, but the record uses board seats and a partner agreement. Preserve INFLUENCE and allow the explicit none states described in canon C01. The approved Korean already distinguishes influence from equity; add the none qualification. New Korean key and revised Korean meaning required.

## E08 · P1 · clarity

Location: `godot/data/scenarios.json` → `$.scenarios[40].ticket.requirements[0].description`

**Current:** Every vendor record names its legal parent and its controlling interest.

**Suggested:** Each vendor states its legal parent and source of influence, or none.

REQ-T41-01 repeats the ownership-stake ambiguity. Keep parent and influence distinct, and allow none so the wording fits the complete-record answer (canon C01). Add that qualification to the approved Korean meaning. New Korean key and revised Korean meaning required.

## E09 · P2 · grammar

Location: `godot/data/scenarios.json` → `$.scenarios[40].story.deduction.sentence`

**Current:** Daniel opened a case on {topic} on 12 October; it was closed the day after he died, and the companies he questioned, and {employer}, answer to {top}.

**Suggested:** Daniel opened a case on {topic} on 12 October. It closed the day after he died; {employer} and the firms he questioned answer to {top}.

The nested "and ... and" hides the two subjects. Two clauses make the conclusion easier to read; all placeholders and the limited control claim remain. New Korean key required; the existing Korean meaning can be retained.

## E10 · P1 · clarity

Location: `godot/data/scenarios.json` → `$.chapters[6].synopsis`

**Current:** The dashboard says nothing happened in October 2021. The benefits ledger says someone died. The records of one employee cannot all be true at once.

**Suggested:** The dashboard counts no major incidents in scope. The benefits ledger records a death. Check where one employee's records disagree.

The dashboard reports zero major incidents within its reporting scope, not that nothing happened. The original wording erases that distinction; see the canon report. Its death reference is already gated until T28 and is not an early reveal. New Korean key and revised Korean meaning required.

## E11 · P2 · exposition

Location: `godot/data/scenarios.json` → `$.chapters[8].synopsis`

**Current:** Daniel Park was investigating the Foundation's vendors when he died. His case was closed the next day. The chain of control reaches further than anyone wrote down, including to Northstar.

**Suggested:** Daniel Park's internal-control cases are in the archive. Check what survives the migration, and follow the records as far as they go.

Alex has only handed over the archive at the end of CH8. This synopsis supplies the T37 closure and T41 Northstar conclusion before those tasks. New Korean key and revised Korean meaning required.
