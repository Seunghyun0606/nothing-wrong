"""Materialize the editorial findings against exact source strings."""
from audit_tools import *

d = data('scenarios')
findings = []

def add(path, suggested, category, severity, reason, meaning=True, file='godot/data/scenarios.json'):
    obj = json.loads(read(file))
    current = dict(leaves(obj))[path]
    assert len(suggested) <= len(current), (path, len(current), len(suggested))
    findings.append(dict(file=file, path=path, current=current, suggested=suggested,
                         category=category, severity=severity,
                         reason=reason + (' New Korean key and revised Korean meaning required.' if meaning else ' New Korean key required; the existing Korean meaning can be retained.')))

add('$.scenarios[7].ticket.request', 'Gold members say their order page shows more than they paid at checkout. Place a test order and compare.', 'clarity', 'P2', 'T08 runs on a staging site. "Real order" can suggest a live purchase; "test order" names the action accurately.')
add('$.scenarios[7].story.briefing[2].text', 'We look anyway. Place a test order as a Gold member with SAVE20, then open it from Orders.', 'clarity', 'P2', 'Same staging-versus-live ambiguity as the T08 request. Keep both instructions consistent.')
add('$.scenarios[13].story.assist[1].text', "Here's the answer: IMG001's thumbnail crops out the young man on the right. Note Target and report it with REQ-T14-01.", 'clarity', 'P3', '"Cuts the young man" lacks "out" and can describe an injury. This is an image crop.', False)
add('$.scenarios[17].ticket.hints[0].text', 'Compare missing Target rows with Source.', 'clarity', 'P3', 'The tautology does not tell a stuck player what to compare. This names the two columns without supplying the answer.')
add('$.scenarios[20].story.assist[1].text', "Here's the answer: each system moved in its own run, and the orchestrator copies as-is. Nothing here is broken: report NO ISSUE FOUND.", 'clarity', 'P2', '"Each system moved in its own year" suggests five distinct years. The view shows five systems across three years, each in a separate run.')
add('$.scenarios[33].ticket.hints[0].text', "Check the screen's arithmetic against the ledger.", 'grammar', 'P3', '"Do the arithmetic ... then the ledger" leaves out the second verb and obscures the comparison.', False)
add('$.scenarios[40].ticket.request', "Check each vendor's legal parent and source of influence, allowing none.", 'clarity', 'P1', '"Controlling interest" commonly means an ownership stake, but the record uses board seats and a partner agreement. Preserve INFLUENCE and allow the explicit none states described in canon C01. The approved Korean already distinguishes influence from equity; add the none qualification.')
add('$.scenarios[40].ticket.requirements[0].description', 'Each vendor states its legal parent and source of influence, or none.', 'clarity', 'P1', 'REQ-T41-01 repeats the ownership-stake ambiguity. Keep parent and influence distinct, and allow none so the wording fits the complete-record answer (canon C01). Add that qualification to the approved Korean meaning.')
add('$.scenarios[40].story.deduction.sentence', 'Daniel opened a case on {topic} on 12 October. It closed the day after he died; {employer} and the firms he questioned answer to {top}.', 'grammar', 'P2', 'The nested "and ... and" hides the two subjects. Two clauses make the conclusion easier to read; all placeholders and the limited control claim remain.', False)
add('$.chapters[6].synopsis', "The dashboard counts no major incidents in scope. The benefits ledger records a death. Check where one employee's records disagree.", 'clarity', 'P1', 'The dashboard reports zero major incidents within its reporting scope, not that nothing happened. The original wording erases that distinction; see the canon report. Its death reference is already gated until T28 and is not an early reveal.')
add('$.chapters[8].synopsis', "Daniel Park's internal-control cases are in the archive. Check what survives the migration, and follow the records as far as they go.", 'exposition', 'P2', 'Alex has only handed over the archive at the end of CH8. This synopsis supplies the T37 closure and T41 Northstar conclusion before those tasks.')

assert all(len(f['suggested']) <= len(f['current']) for f in findings)
(OUT/'english.json').write_text(json.dumps(findings,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
counts = {p:sum(f['severity']==p for f in findings) for p in ['P1','P2','P3']}
lines = ['# CX-07 Part 1: English copy review', '',
    'Status: completed with editorial suggestions; no product changes. Static source review, not a human playtest.', '',
    f"{len(findings)} source locations ({counts['P1']} P1 / {counts['P2']} P2 / {counts['P3']} P3); {len(findings)} distinct English strings.", '',
    'Reviewed all 42 tickets (requests, requirements, attachments, hints), all briefings/debriefs, assists, clues, discovery hints, 19 deduction prompts/templates/options/success lines, 10 chapter synopses, regular/late epilogues, all three endings, and shared report/chat copy in scripts. Read intranet and directory text for context. Storefront and portal UI copy are excluded from editorial suggestions as requested.', '',
    'P1: meaning, reveal, or canon-risk wording. P2: consequential clarity/exposition. P3: minor wording. Suggestions are the same length or shorter by Unicode character count; the JSON stores exact source values and full replacement strings. Changed source strings need replacement Korean keys even when the existing translated meaning can stay. No Korean or game files were changed.', '',
    'The Case File renders each arrived chapter synopsis in `notes_app.gd::_case_file`, gated by `Catalog.is_case_file_open`. CH5–CH7 stay hidden until T28 resolves: their source/death summaries are not early reveals. CH9 becomes visible when T37 arrives and does expose later conclusions. Part 2 checks the corresponding canon conflict. Deliberately explicit second-miss assists and the early prologue tutorials are retained. No blanket redistribution of Mina dialogue is proposed: the earlier review disposition leaves that to TASK-010.', '',
    'Earlier resolved items were checked and excluded: T26 night timing, T27 original-record availability, T38 camera-clock approximation, SAVE10 subtotal eligibility, T21 qualified success line, Korean particle rewrites, and already-applied Korean tone/naturalness changes.', '']
lines += ['The final delivery trace also excluded the Shoply-specific `evaluate_bug` detection-feedback string: the current Messenger renders `reply_hint` or the last fallback feedback item, not that first internal feedback item. It is not reported as an active player-facing copy defect.', '']
for i,f in enumerate(findings,1):
    lines += [f"## E{i:02d} · {f['severity']} · {f['category']}", '',
              f"Location: `{f['file']}` → `{f['path']}`", '',
              '**Current:** '+f['current'], '', '**Suggested:** '+f['suggested'], '', f['reason'], '']
(OUT/'english.md').write_text('\n'.join(lines),encoding='utf-8')
print('Wrote english.md and english.json:',counts)
