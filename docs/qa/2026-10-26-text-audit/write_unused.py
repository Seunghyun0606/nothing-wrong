"""Conservative source-literal inventory plus manually reviewed dynamic producers."""
from audit_tools import *
from collections import Counter

ko = json.loads(read('godot/i18n/ko.json'))
index = literal_index()
unmatched = [key for key in ko if key not in index]
dynamic = {
    key: f'godot/scripts/ui/apps/browser_app.gd:103-106 iterates DESKTOP/TABLET/MOBILE and passes mode.capitalize() to Kit.button. It produces "{key}"; buttons inherit automatic translation from Settings. No exact title-case literal is required. Retain this key (generation is statically confirmed; not safe to delete).'
    for key in ['Desktop','Tablet','Mobile']
}
assert set(dynamic) <= set(unmatched)
unused = [key for key in unmatched if key not in dynamic]
unsure = [dict(key=key,why=why) for key,why in dynamic.items()]
assert len(unused) == 306, len(unused)
result = dict(unused=unused,unsure=unsure)
(OUT/'unused-keys.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

evidence = dict(
    method='Static source inventory plus manual review of translation, formatting, concatenation and capitalization producers. No runtime execution or player-save access.',
    counts=dict(korean_keys=len(ko), source_files=len(source_files()),
                extensions=dict(Counter(p.suffix for p in source_files())),
                exact_literal_or_data_references=len(ko)-len(unmatched),
                unmatched=len(unmatched),unused=len(unused),unsure=len(unsure)),
    scanned_files=[str(p.relative_to(ROOT)).replace('\\','/') for p in source_files()],
    retained_source_references={key:index[key] for key in ko if key in index},
    dynamic_retentions=unsure,
    deletion_evidence={key:'No exact decoded source literal or JSON scalar/key. Reviewed dynamic producers cannot form this full message key from the current authored content.' for key in unused})
(OUT/'key-usage-evidence.json').write_text(json.dumps(evidence,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

lines = ['# CX-07 Part 3: Unused Korean keys','',
    f'Status: static audit complete. {len(ko)} Korean keys inspected; **306 unused**, **3 unsure/retain**, and **1275 retained by exact source/data reference**. No keys were deleted.','',
    '`unused-keys.json` is the requested machine-readable list. The three `unsure` entries are conservative exclusions from the deletion list because they are produced dynamically; their production is actually established by source inspection. They must be retained. `key-usage-evidence.json` records every scanned file, retained reference and deletion candidate.','',
    '## Method and scope','',
    '- Scanned all 38 runtime GDScript files, all 7 `godot/data/*.json` files, the one `.tscn` scene, and `godot/project.godot`: 47 files. Read `ko.json` separately as the catalog. Decode escaped strings, ignore code comments, and include JSON field names as well as values. The scanner skips generated `.godot/`, ignored `build/`, and test fixtures. Frozen root React/Vite text and QA documents are not current game producers.',
    '- Followed `Kit.t`, `Kit.tf`, direct `TranslationServer.translate`, and the automatic translation of labels/buttons documented in `settings.gd`. A missing explicit `Kit.t` call is not evidence of disuse. Kept titles, labels, request/requirement text, attachment content, dialogue, clues, options, notes and directory fields that flow through those paths.',
    '- Traced `mode.capitalize()` and `tier.capitalize()`, status-label dictionary lookup, joined channel members, chapter-complete messages, formatted reply templates, translated deduction templates/options, portal/Shoply evidence labels, and browser tab titles. Template keys are looked up before substitution by `Kit.tf`; a longer sentence containing a phrase does not translate that phrase as a separate key.',
    '- Deduction word labels disable automatic translation after the full sentence is translated. They do not make every individual word in a sentence a live key. The old bare `NO ISSUE FOUND` entry is not needed by the current full-message and button keys. The old channel-member entry has a different order from the current first-speaker join.',
    '- Literal presence is treated conservatively: a reference can be a data value, template, fallback, or internal label even if this review did not prove its display in every branch. Such keys are retained, so this is a safe deletion list rather than a claim that every remaining reference is rendered.',
    '- "Safe to delete" is scoped to the current Godot authored game and supported producers. It does not promise compatibility with a future content version or externally altered saves. Player saves were never inspected. No Godot, export, or playtest was run.','',
    'The earlier Korean review covered the whole catalog, including legacy keys; editing a translation there did not establish that it was used. This audit distinguishes reachability from copy quality. Most unused entries belong to earlier tutorial panels, Capture/Flag flows, manual severity/report screens, career counters and old dialogue choices.','',
    '## Unsure / retain','']
for item in unsure:
    lines += ['- **'+item['key']+'** — '+item['why']]
lines += ['','## Unused: 306 keys','',
    'Every key below has no exact decoded runtime/content/scene/config reference, and no reviewed builder produces the full key. Listed in catalog order; these are exact source keys, not the Korean values.','']
for i,key in enumerate(unused,1):
    lines += [f'{i}. '+json.dumps(key,ensure_ascii=False)]
(OUT/'unused-keys.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print(json.dumps(evidence['counts']))
