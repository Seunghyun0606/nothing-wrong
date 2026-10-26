# Badge and product photos disposition · 2026-10-26

Source: CX-06 (Codex), brief `docs/codex/CX-06-badge-and-product-photos.md`, notes
`NOTES.md` in this folder. Reviewed and applied by Claude; decision DEC-018. All ten
images accepted.

| Files | In the game |
| --- | --- |
| `grace-yoon`, `mina-seo`, `marcus-reyes`, `leo-ortiz`, `priya-nair`, `elena-brooks`, `alex-han` | `godot/assets/people/<id>.jpg` (384 px). The directory card and person page show the badge photo with "Badge photo · <year>"; the player's own entry says the photo is pending. |
| `everyday-pack`, `travel-sling`, `laptop-sleeve` | `godot/assets/products/<id>.jpg` (1200 px). Shoply's product grid and product page. |

Checks:
- Grace at 29 (2008) is the same woman as on `docs/story/photos/sheet_characters.jpg`, with longer hair and different styling. She is recognisable but not identical.
- Mina has the fringe she mentions at T13.
- Alex has no glasses and does not resemble Daniel Park.
- No one else resembles a recurring character.
- No readable text, logos, or brands appear.

A missing photo falls back to initials, or to the product's colour block.

The PNG originals were converted to JPG (quality 90) before commit to keep the repository small; file names in `NOTES.md` refer to the same images as `.png`.
