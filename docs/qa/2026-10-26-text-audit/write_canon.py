from audit_tools import *
from datetime import datetime, timedelta

findings = [
dict(fact='T41 is a complete-record, NO ISSUE FOUND check.', locations=[
 'godot/data/scenarios.json::$.scenarios[40].ticket.requirements[0].description',
 'godot/data/scenarios.json::$.scenarios[40].expectedBugs (empty)',
 'godot/data/scenarios.json::$.scenarios[40].story.assist[1].text',
 'godot/data/horizon.json::$.views[25].rows[2].values.parent (V-2201)',
 'docs/NOTHING_WRONG_ALL_IN_ONE.md::ACT 6 / NW-030 (NO_BUG)'],
 conflict='REQ-T41-01 says every vendor record names its legal parent and controlling interest, and the assist says every record is complete. Bright Future Consulting has legal parent "—". Independent vendors also have "—" for controlling interest. These permitted states are not qualified in the requirement; the declared all-records-complete answer does not satisfy its literal wording.',
 suggested_fix='Keep the canonical NO_BUG outcome. Describe parent status and control type, explicitly allowing no legal parent and no controlling party where applicable. Clarify the dash in the note; do not invent a parent or ownership stake. Update request, requirement, assist and matching Korean keys together.',severity='P1'),
dict(fact='Northstar control is discovered through T41, not the opening of T37.',locations=[
 'godot/data/scenarios.json::$.chapters[8].synopsis',
 'godot/data/scenarios.json::$.scenarios[40].story.debrief[0].text and story.clue',
 'godot/scripts/ui/apps/notes_app.gd::_case_file (arrived first ticket; then chapter synopsis)',
 'godot/scripts/domain/catalog.gd::is_case_file_open',
 'docs/story/CANON-MAP.md::Chapters, NW-030 / Northstar mapping',
 'docs/NOTHING_WRONG_ALL_IN_ONE.md::ACT 6 / NW-030'],
 conflict='The CH9 synopsis states "The chain of control reaches further than anyone wrote down, including to Northstar." It is rendered as soon as T37 arrives because T28 has already opened the Case File. The QA mapping that establishes Northstar INFLUENCE is T41. The same synopsis also gives away T37 case closure before its report.',
 suggested_fix='Use the open archive question in English E11; keep Northstar control and case-closure conclusions in the earned clues/debriefs. Revise the matching Korean key. This is a ticket-level leak within an otherwise correct chapter-level gate.',severity='P1'),
dict(fact='The October dashboard counts zero MAJOR incidents within its site scope.',locations=[
 'godot/data/scenarios.json::$.chapters[6].synopsis',
 'godot/data/horizon.json::$.views[11].note and rows[1].values',
 'godot/data/horizon.json::$.views[13].rows[4].values',
 'godot/data/scenarios.json::$.scenarios[26].story.debrief',
 'docs/NOTHING_WRONG_ALL_IN_ONE.md::Narrative Canon / guardrail 5',
 'docs/story/CANON-MAP.md::How the build follows the canon, Chapter 7'],
 conflict='The synopsis says "The dashboard says nothing happened in October 2021." The dashboard actually excludes partner-run sites and only counts MAJOR incidents; its reference rows include October incidents. The official summary confirms an incident, one fatality and injuries, with authorities involved. The synopsis turns a scoped zero into an absolute absence.',
 suggested_fix='Use the scoped wording in English E10. Preserve the official incident and investigation, the zero count within scope, and the unavailable original reference as distinct facts. Revise the corresponding Korean key. The death reference itself is gated until T28 and is not an early reveal.',severity='P1'),
dict(fact='CH4 begins on the Monday immediately after CH3 Sunday.',locations=[
 'godot/data/scenarios.json::$.chapters[3].synopsis',
 'godot/data/scenarios.json::$.chapters[2].epilogue[4].text and lateEpilogue[4].text',
 'godot/data/scenarios.json::$.scenarios[8].story.time (Sun 15:10)',
 'godot/data/scenarios.json::$.scenarios[9].story.time (next Mon 07:40)',
 'godot/scripts/domain/story_clock.gd::parse'],
 conflict='CH4 says "A week later, Platform rolls everything back." CH3 promises the rollback "tonight" and RC5 "Monday morning"; T09 is Sunday and T10 is the following Monday in the implemented story clock. A week does not elapse between these chapters.',
 suggested_fix='Start the CH4 synopsis "After the weekend, Platform rolls everything back." Keep the existing ticket times and Sunday closing lines. Update the Korean key. Do not move a week of gameplay to justify one sentence.',severity='P2'),
dict(fact='CH3 must describe both on-time and late CH2 releases.',locations=[
 'godot/data/scenarios.json::$.chapters[2].synopsis',
 'godot/data/scenarios.json::$.chapters[1].epilogue[2].text',
 'godot/data/scenarios.json::$.chapters[1].lateEpilogue[2].text',
 'godot/scripts/domain/messenger_log.gd::_stamp',
 'godot/scripts/ui/apps/notes_app.gd::_case_file'],
 conflict='The unconditional CH3 synopsis says "The Autumn Release shipped clean." The supported late CH2 branch says it shipped at 10:00 with release/mobile-fees still present and is being rolled back. A later rollback does not make the release have shipped clean.',
 suggested_fix='Use a branch-neutral opening such as "The Autumn Release is out." Leave the chapter epilogues to describe which release outcome happened, or derive a branch-specific synopsis. Update the Korean key if source wording changes.',severity='P2'),
dict(fact='The T04 configuration record must not record a future Thursday action as completed.',locations=[
 'godot/data/intranet.json::$.documents[3].availableAfter (T04)',
 'godot/data/intranet.json::$.documents[3].lines[4]',
 'godot/data/scenarios.json::$.scenarios[3].story.time (Thu 15:30)',
 'godot/data/scenarios.json::$.scenarios[3].story.discovery',
 'godot/data/scenarios.json::$.chapters[0].deadline (Thu 18:00)',
 'godot/scripts/domain/intranet.gd::is_available',
 'godot/scripts/domain/messenger_log.gd::_stamp'],
 conflict='The configuration history becomes available when T04 resolves and is the required discovery for its deduction. It already records "Thursday 19:05: exp/* and promo/* removed again". An on-time T04 path begins at 15:30 and concludes before the 18:00 freeze, so that required history is showing a completed future edit. Availability filters whole documents, not individual lines or timestamps.',
 suggested_fix='At T04 discovery show only the history that has happened. Record the repair when the chapter closes and stamp it at that actual completion time, consistent with the on-time epilogue saying the rule is fixed; alternatively time-gate the 19:05 repair and adjust that epilogue. Preserve Monday 18:40 and Tuesday 02:14 evidence. Synchronize translated lines.',severity='P2'),
dict(fact='The public organization tree omits two levels above Holdings.',locations=[
 'godot/data/scenarios.json::$.scenarios[39].story.debrief[0].text',
 'godot/data/horizon.json::$.views[24].rows[*].source.chain and target.chain',
 'godot/data/scenarios.json::$.scenarios[39].story.clue.text'],
 conflict='Mina describes Holdings → Community Trust → Foundation, then says the public tree stops "one step short of that". It actually stops at Holdings and omits both Community Trust and Foundation: two links to the stated endpoint.',
 suggested_fix='Replace the last sentence with "The public tree stops at Holdings." Keep the control/influence qualification and update the Korean line, which also says one step.',severity='P3'),
]

h = data('horizon'); s = data('scenarios')
byid = {v['id']:v for v in h['views']}
timeline=[]
for row in byid['access-timeline']['rows']:
    raw=datetime.strptime(row['source']['time'],'%Y-%m-%d %H:%M UTC')
    local=(raw-timedelta(hours=7)).strftime('%Y-%m-%d %H:%M')
    timeline.append(dict(log=row['key'], raw=row['source']['time'], local=local,
                         displayed=row['target']['time'], expected_defect=row['key']=='VEH-FS01'))
assert [v['local'][-5:] for v in timeline]==['22:48','23:06','23:11','23:18','00:14']
assert all(v['displayed']==v['local'] for v in timeline if not v['expected_defect'])
assert timeline[3]['displayed']=='2021-10-18 06:18'
checks=dict(method='Python static cross-checks; no Godot execution', timeline=timeline,
    inventory=dict(received=1200,patient_use=380,disposed=24,transferred=675,balance=1200-380-24-675),
    payroll=dict(gross=5200,tax=410,pension=190,community=260,net=5200-410-190-260),
    benefit_total=1240+85000,
    historical_orders=len(byid['shoply-orders']['rows']),
    historical_order_targets=sum(row.get('target') is not None for row in byid['shoply-orders']['rows']),
    regular_salary_months=[row['values']['paid'][:7] for row in byid['payflow-after-exit']['rows'] if row['values']['type']=='REGULAR_SALARY'],
    scenarios=len(s['scenarios']), chapters=len(s['chapters']),
    deductions=sum('deduction' in v['story'] for v in s['scenarios']))
(OUT/'canon-checks.json').write_text(json.dumps(checks,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(OUT/'canon.json').write_text(json.dumps(findings,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
lines=['# CX-07 Part 2: Canon consistency audit','',
 'Status: completed with seven conflicts (P1 3 / P2 3 / P3 1). No canon, code, content, or Project OS state changes. Findings are static content/branch analysis; no engine or playtest was run. `canon.json` is the conflict list; `canon-checks.json` contains the arithmetic and timezone checks.','',
 'Compared all 42 scenarios, 30 portal views, 25 intranet documents, 8 directory people and 3 organizations, Shoply fixtures, Korean equivalents, the full canon map, the narrative/ticket/image/continuity sections and examples of the master synopsis, and the scripts that gate content and stamp story time. The master handoff is interpreted with the canon map: the prologue, mandatory timeline, completed photo work and three confirmed endings are accepted extensions. Older statements that endings are undecided are superseded by D-18/DEC-017, not fresh conflicts.','']
for i,f in enumerate(findings,1):
    lines += [f"## C{i:02d} · {f['severity']} · {f['fact']}",'',f['conflict'],'','Locations:']
    lines += ['- `'+x+'`' for x in f['locations']]
    lines += ['','Suggested fix: '+f['suggested_fix'],'']
lines += ['## Facts checked without a new conflict','',
 '- Timeline: raw UTC minus seven hours yields 17 October 22:48, 23:06, 23:11, 23:18, then 18 October 00:14. VEH-FS01 deliberately displays unconverted UTC; that is the T39 defect, not a canon inconsistency. The transfer is not a time of death.',
 '- Daniel: E-18419 / T-55291 / P-88114 / B-44210 → P-004217 agree. CASE-2021-1012 opens 12 October and closes 18 October. The canon fixes the death to 17 October without a precise death time. Photo clocks and CMS tags remain unverified.',
 '- Counts: 15 source orders, 14 target orders; 38 travelers, Source linked returns 9 versus Target 0; leave counts 38/36 with 12 exits the next day; IMG002 has G. Yoon plus 11 untagged people. Twelve people in a photo need not equal the full 38-person cohort. Samples are explicitly distinguished from totals.',
 '- Money/rules: 5200 − 410 − 190 − 260 = 4340; regular salary appears in November, December and January (three months); 1240 + 85000 = 86240; 1200 − 380 − 24 − 675 = 121. T34 deliberately omits the transfer from the displayed formula. SAVE10 has no minimum; SAVE20 is Gold-only 20%, with the deliberate 10% cap defect at quantity ≥3. Vendor rates 5%/18% within the approved 20% override and CA-70 ≥70 agree.',
 '- Images: IMG001 awards; IMG002 retreat; IMG003 2019 gala; IMG004 leadership dinner; IMG005 2018 family retreat; IMG006 opportunity cohort; IMG007 terrace. FS-01 is used for a security badge and a vehicle in different namespaces, which does not itself establish a conflict or identify the driver.',
 '- Guardrails: player-facing records do not assert an intentional cause of death, photo-based guilt, a trafficking finding or Northstar ownership by the Trust. DB-01 is in Benefit Settlement. Forbidden-word matches in `data/canon.json` are validator deny-list metadata, not displayed story text. English E07–E08 address the softer ownership implication of "controlling interest"; that wording is not treated as an actual ownership fact here.',
 '- Reveal gates: the portal uses each view\'s ticket unlock, directory facts use `since`, intranet documents use completion/leads/document chains, and quiet Case File chapters require T28. CH6 source-data and CH7 death summaries therefore do not leak before T28. CH9 does leak T41 as described in C02.',
 '- Previously fixed T26 timing, T27 original availability, T38 ninety-minute approximation, SAVE10 minimum, and T21 qualified success are not repeated. No unsupported conflict was added for normal names/abbreviations, separate ID namespaces, deliberate source/target mutations, or accepted canon-map extensions.','',
 'Remaining work: Claude decides and applies the seven fixes, then verifies the affected branches and localization. TASK-010 remains open; this audit is not a human-gate result.']
(OUT/'canon.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('Wrote canon.md, canon.json and canon-checks.json:',len(findings),'conflicts; deductions',checks['deductions'])
