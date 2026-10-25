# Art delivery disposition · 2026-10-26

Source: CX-02 (Codex), brief `docs/codex/CX-02-art.md`, notes `NOTES.md` in this folder.
Reviewed and applied by Claude. All five images accepted.

| File | Used as | In the game |
| --- | --- | --- |
| `icon.png` | Window icon and Windows executable icon | `godot/assets/art/icon.png` (256 px), `icon.ico` (16–256 px); `project.godot` `config/icon`, `config/windows_native_icon`; export preset `application/icon` with `modify_resources=true` |
| `title.png` | Title screen backdrop | `godot/assets/art/title.jpg`; the title card sits over the dark left side |
| `lock.png` | Lock screen backdrop | `godot/assets/art/lock.jpg`, under a light veil so the clock reads |
| `wallpaper.png` | Desktop wallpaper | `godot/assets/art/wallpaper.jpg`; it replaces the "NOTHING WRONG" watermark, which sat on the star |
| `icon_32_preview.png` | Review aid only | not shipped |

Checks: no readable text, brand marks, people, or Foundation emblem in any image; the
icon reads at 32 and 16 px; title and lock show the same desk. The executable's icon
was confirmed after export. A missing picture falls back to the old plain colour
(`Kit.backdrop`), tested in `test_screens_show_their_art`.
