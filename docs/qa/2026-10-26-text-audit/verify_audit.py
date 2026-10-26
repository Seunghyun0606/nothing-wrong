"""Validate deliverables and unchanged sources without launching the game."""
from audit_tools import *
from collections import Counter
from datetime import datetime, timezone
import subprocess
import os

def load_output(name):
    return json.loads((OUT/name).read_text(encoding='utf-8'))

english=load_output('english.json')
canon=load_output('canon.json')
unused=load_output('unused-keys.json')
ko=json.loads(read('godot/i18n/ko.json'))
index=literal_index()
assert len(english)==11
assert len(canon)==7
for f in english:
    assert set(f)=={'file','path','current','suggested','category','severity','reason'}
    assert f['category'] in {'clarity','tone','exposition','grammar'}
    assert f['severity'] in {'P1','P2','P3'}
    assert dict(leaves(json.loads(read(f['file']))))[f['path']]==f['current']
    assert len(f['suggested'])<=len(f['current'])
    assert re.findall(r'\{\w+\}',f['suggested'])==re.findall(r'\{\w+\}',f['current'])
    assert f['current'] in ko
    assert 'Korean' in f['reason']
for f in canon:
    assert set(f)=={'fact','locations','conflict','suggested_fix','severity'}
    assert f['locations'] and f['severity'] in {'P1','P2','P3'}
    for loc in f['locations']:
        assert (ROOT/loc.split('::')[0]).is_file(),loc
assert set(unused)=={'unused','unsure'}
assert len(unused['unused'])==306
assert len(unused['unsure'])==3
assert len(set(unused['unused']))==306
assert not set(unused['unused']) & {x['key'] for x in unused['unsure']}
assert all(k in ko and k not in index for k in unused['unused'])
assert {x['key'] for x in unused['unsure']}=={'Desktop','Tablet','Mobile'}
assert len(index.keys() & ko.keys())+len(unused['unused'])+len(unused['unsure'])==len(ko)
for f in ['english.md','canon.md','unused-keys.md','README.md']:
    assert (OUT/f).stat().st_size>0
hashes=load_output('source-hashes.json')
drift=[p for p,digest in hashes.items() if hashlib.sha256((ROOT/p).read_bytes()).hexdigest()!=digest]
assert not drift,drift
env=dict(os.environ,GIT_OPTIONAL_LOCKS='0')
def git(*args):
    res=subprocess.run(['git','-C',str(ROOT),*args],capture_output=True,text=True,encoding='utf-8',env=env)
    assert res.returncode==0,res.stderr
    return res.stdout.rstrip('\r\n')
head=git('rev-parse','HEAD').strip()
assert head=='e94fde81cae7a7c6fbb68180a2feaac3f03f5141'
status=git('status','--short')
initial_status={
 ' M godot/data/people.json',
 ' M godot/data/scenarios.json',
 ' M godot/i18n/ko.json',
 '?? docs/codex/CX-06-badge-and-product-photos.md',
 '?? docs/codex/CX-07-text-audit.md',
}
audit_output='?? docs/qa/2026-10-26-text-audit/'
assert audit_output in status.splitlines()
additional_status=sorted(set(status.splitlines())-initial_status-{audit_output})
result=dict(task='CX-07',role='read-only text audit',status='completed_with_findings',
    verified_at_utc=datetime.now(timezone.utc).isoformat(),baseline_commit=head,
    checks=dict(json_schema='PASS',current_source_exact_match='PASS',
                replacement_length='PASS',deduction_placeholders='PASS',
                current_english_keys_in_korean_catalog='PASS',
                unused_key_membership_and_disjointness='PASS',
                key_catalog_partition='PASS',source_hashes='PASS',git_inventory='RECORDED'),
    counts=dict(english=len(english),english_priorities=dict(Counter(f['severity'] for f in english)),
                canon=len(canon),canon_priorities=dict(Counter(f['severity'] for f in canon)),
                korean_catalog=len(ko),unused=len(unused['unused']),unsure=len(unused['unsure'])),
    source_files_hashed=len(hashes),source_drift=drift,
    initial_git_status=sorted(initial_status), final_git_status=status.splitlines(),
    additional_non_audit_git_entries=additional_status,
    godot='NOT RUN (brief forbids it)',human_playtest='NOT RUN',
    product_files_changed=False,canonical_state_changed=False,
    notes='Static checks validate reports and evidence, not product fixes. Additional non-audit Git entries surfaced at final verification, including three UI scripts; all 50 original source hashes still match, including those scripts. No audit write targets were outside this output folder. C02/E11 and C03/E10 describe the same issues from two review perspectives; do not add part counts as unique defects.')
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result['counts']))
print('PASS: exact source strings, schemas, lengths, placeholders, key inventory, 50 unchanged source hashes; final Git inventory recorded.')
