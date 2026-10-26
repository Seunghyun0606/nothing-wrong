"""Read-only CX-07 source inventory and reproducible static checks (no Godot)."""
import hashlib
import json
import pathlib
import re
import sys

ROOT = pathlib.Path('C:/Users/limse/Desktop/\ud68c\uc0ac/AI_PJT/nothing-wrong')
OUT = ROOT / 'docs/qa/2026-10-26-text-audit'

def read(rel):
    return (ROOT / rel).read_text(encoding='utf-8-sig')

def data(name):
    return json.loads(read('godot/data/' + name + '.json'))

def leaves(obj, path='$'):
    if isinstance(obj, dict):
        for k, v in obj.items():
            yield from leaves(v, path + '.' + k)
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            yield from leaves(v, path + '[' + str(i) + ']')
    elif isinstance(obj, str):
        yield path, obj

def source_files():
    godot = ROOT / 'godot'
    return sorted(p for p in godot.rglob('*') if p.is_file()
                  and p.suffix in {'.gd', '.json', '.tscn', '.godot'}
                  and not any(x in p.relative_to(godot).parts for x in ['build', '.godot'])
                  and 'tests' not in p.relative_to(godot).parts
                  and 'i18n' not in p.relative_to(godot).parts)

def string_literals(text, semicolon_comments=False):
    """GDScript/TSCN strings, skipping comments so apostrophes cannot eat code."""
    i = 0
    line = 1
    while i < len(text):
        if text[i] == '#' or (semicolon_comments and text[i] == ';'):
            end = text.find('\n', i)
            i = len(text) if end < 0 else end
        elif text[i] in ['"', "'"]:
            quote = text[i]
            size = 3 if text[i:i+3] == quote*3 else 1
            start_line = line
            i += size
            value = ''
            while i < len(text):
                if text[i:i+size] == quote*size:
                    i += size
                    break
                if text[i] == '\\' and i+1 < len(text):
                    escaped = text[i+1]
                    if escaped in ['n', 'r', 't', 'b', 'f']:
                        value += dict(n='\n',r='\r',t='\t',b='\b',f='\f')[escaped]
                        i += 2
                    elif escaped in ['u','U'] and re.fullmatch('[0-9a-fA-F]{'+('4' if escaped=='u' else '8')+'}', text[i+2:i+(6 if escaped=='u' else 10)]):
                        length = 4 if escaped == 'u' else 8
                        value += chr(int(text[i+2:i+2+length],16))
                        i += 2+length
                    else:
                        value += escaped
                        i += 2
                else:
                    value += text[i]
                    line += text[i]=='\n'
                    i += 1
            yield start_line, value
        else:
            line += text[i]=='\n'
            i += 1

def literal_index():
    found = {}
    for p in source_files():
        rel = str(p.relative_to(ROOT)).replace('\\','/')
        txt = p.read_text(encoding='utf-8-sig')
        if p.suffix == '.json':
            obj = json.loads(txt)
            entries = list(leaves(obj))
            def dict_keys(v, path='$'):
                if isinstance(v, dict):
                    for k, value in v.items():
                        yield path + '.' + k + ' (key)', k
                        yield from dict_keys(value,path+'.'+k)
                elif isinstance(v,list):
                    for i,value in enumerate(v):
                        yield from dict_keys(value,path+'['+str(i)+']')
            entries += list(dict_keys(obj))
        else:
            entries = [(str(line),v) for line,v in string_literals(txt, p.suffix in {'.godot', '.tscn'})]
        for loc,value in entries:
            found.setdefault(value,[]).append(rel+'::'+loc)
    return found

if __name__ == '__main__':
    mode = sys.argv[1]
    if mode == 'dialogue':
        start, end = map(int, sys.argv[2:4])
        for i, s in enumerate(data('scenarios')['scenarios']):
            if not start <= i + 1 <= end:
                continue
            print('\n###', s['ticket']['id'])
            for path, value in leaves(s):
                if path.startswith('$.ticket') or path.startswith('$.story'):
                    if any(x in path for x in ['.seed', '.startingContext', '.searchTerms', '.links', '.answer', '.requires', '.terms']):
                        continue
                    if path.endswith(('.id', '.role', '.projectId', '.status', '.priority', '.chapterId', '.documentId', '.channel')):
                        continue
                    print(path, '=', value)
    elif mode == 'snapshot':
        files = source_files() + [ROOT / p for p in ['godot/i18n/ko.json', 'docs/story/CANON-MAP.md', 'docs/NOTHING_WRONG_ALL_IN_ONE.md']]
        result = {str(p.relative_to(ROOT)).replace('\\','/'): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
        (OUT / 'source-hashes.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
        print('Snapshotted', len(files), 'source files')
