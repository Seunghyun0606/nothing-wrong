# CX-09 Old-save compatibility

Status: in progress. Role: Codex verification; explicit CX-09 assignment. No Project OS transition or product fix will be made.

Scope: archived 9131493, ef3a593, adf74eb, e94fde8 and current HEAD. Historical probes use their own sessions; current loader uses a custom main loop and dedicated user://tests/cx09/ paths. Player save files are never read or modified.

## Execution record

- Read PROJECT.md, Project OS manifest/current state, CX-09 brief and RULES.md.
- Confirmed current SaveFile.path routes custom main-loop runs into user://tests/ before autoloads load. Historical copies will use config/name="NW-CX09" and print the effective directory before saving.

## Results

Pending fixture generation and current-loader checks.

### 9131493: fixture generation

Import exit 0; writer exit 0. Logs: `godot/build/cx09/9131493-import.log`, `9131493-writer.log`.
Writer result: `{"failures": [], "tickets": 5, "user_dir": "C:/Users/limse/AppData/Roaming/Godot/app_userdata/NW-CX09"}`.

### 9131493: current HEAD load results

| Version | State | Load outcome | Lost or replayed | Errors |
|---|---|---|---|---|
| 9131493 | furthest | loaded | 12 chat IDs absent; 0 replayed; 4 texts changed | 4 runtime; 3 failed assertions |
| 9131493 | mid-ch2 | loaded | 12 chat IDs absent; 0 replayed; 4 texts changed | 0 runtime; 2 failed assertions |
| 9131493 | t01 | loaded | 0 chat IDs absent; 2 replayed; 1 texts changed | 4 runtime; 4 failed assertions |
| 9131493 | t01-wrong | loaded | 2 chat IDs absent; 0 replayed; 2 texts changed | 0 runtime; 2 failed assertions |

### ef3a593: fixture generation

Import exit 0; writer exit 0. Logs: `godot/build/cx09/ef3a593-import.log`, `ef3a593-writer.log`.
Writer result: `{"failures": [], "tickets": 42, "user_dir": "C:/Users/limse/AppData/Roaming/Godot/app_userdata/NW-CX09"}`.

Probe refinement: initial 9131493 loader results above are superseded by reruns below. The probe now compares JSON numeric values semantically (reconcile intentionally converts count floats to ints), and lets pending UI layout coroutines finish before freeing the scene. Initial teardown errors were caused by probe timing. Historical chat disappearance/replay findings are being rechecked. Initial writer attempt used the bug target for T03; corrected to its valid evidence target and regenerated all 9131493 fixtures with no assertion failures.

### 9131493: current HEAD load results

| Version | State | Load outcome | Lost or replayed | Errors |
|---|---|---|---|---|
| 9131493 | furthest | loaded | 12 chat IDs absent; 0 replayed; 4 texts changed | 0 runtime; 1 failed assertions |
| 9131493 | mid-ch2 | loaded | 12 chat IDs absent; 0 replayed; 4 texts changed | 0 runtime; 1 failed assertions |
| 9131493 | t01 | loaded | 0 chat IDs absent; 2 replayed; 1 texts changed | 0 runtime; 2 failed assertions |
| 9131493 | t01-wrong | loaded | 2 chat IDs absent; 0 replayed; 2 texts changed | 0 runtime; 1 failed assertions |

### ef3a593: current HEAD load results

| Version | State | Load outcome | Lost or replayed | Errors |
|---|---|---|---|---|
| ef3a593 | furthest | loaded | 0 chat IDs absent; 0 replayed; 6 texts changed | 0 runtime; 0 failed assertions |
| ef3a593 | mid-ch2 | loaded | 0 chat IDs absent; 0 replayed; 0 texts changed | 0 runtime; 0 failed assertions |
| ef3a593 | t01 | loaded | 0 chat IDs absent; 0 replayed; 0 texts changed | 0 runtime; 0 failed assertions |

### adf74eb: fixture generation

Import exit 0; writer exit 0. Logs: `godot/build/cx09/adf74eb-import.log`, `adf74eb-writer.log`.
Writer result: `{"failures": [], "tickets": 42, "user_dir": "C:/Users/limse/AppData/Roaming/Godot/app_userdata/NW-CX09"}`.

### adf74eb: current HEAD load results

| Version | State | Load outcome | Lost or replayed | Errors |
|---|---|---|---|---|
| adf74eb | furthest | loaded | 0 chat IDs absent; 0 replayed; 3 texts changed | 0 runtime; 0 failed assertions |
| adf74eb | mid-ch2 | loaded | 0 chat IDs absent; 0 replayed; 0 texts changed | 0 runtime; 0 failed assertions |
| adf74eb | t01 | loaded | 0 chat IDs absent; 0 replayed; 0 texts changed | 0 runtime; 0 failed assertions |

### e94fde8: fixture generation

Import exit 0; writer exit 0. Logs: `godot/build/cx09/e94fde8-import.log`, `e94fde8-writer.log`.
Writer result: `{"failures": [], "tickets": 42, "user_dir": "C:/Users/limse/AppData/Roaming/Godot/app_userdata/NW-CX09"}`.

### e94fde8: current HEAD load results

| Version | State | Load outcome | Lost or replayed | Errors |
|---|---|---|---|---|
| e94fde8 | furthest | loaded | 0 chat IDs absent; 0 replayed; 3 texts changed | 0 runtime; 0 failed assertions |
| e94fde8 | mid-ch2 | loaded | 0 chat IDs absent; 0 replayed; 0 texts changed | 0 runtime; 0 failed assertions |
| e94fde8 | t01 | loaded | 0 chat IDs absent; 0 replayed; 0 texts changed | 0 runtime; 0 failed assertions |

### HEAD: fixture generation

Import exit 0; writer exit 0. Logs: `godot/build/cx09/HEAD-import.log`, `HEAD-writer.log`.
Writer result: `{"failures": [], "tickets": 42, "user_dir": "C:/Users/limse/AppData/Roaming/Godot/app_userdata/NW-CX09"}`.

### HEAD: current HEAD load results

| Version | State | Load outcome | Lost or replayed | Errors |
|---|---|---|---|---|
| HEAD | furthest | loaded | 0 chat IDs absent; 0 replayed; 0 texts changed | 0 runtime; 0 failed assertions |
| HEAD | mid-ch2 | loaded | 0 chat IDs absent; 0 replayed; 0 texts changed | 0 runtime; 0 failed assertions |
| HEAD | t01 | loaded | 0 chat IDs absent; 0 replayed; 0 texts changed | 0 runtime; 0 failed assertions |
