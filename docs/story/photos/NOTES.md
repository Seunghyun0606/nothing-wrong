# Nothing Wrong — photo delivery

> Codex's delivery notes (2026-10-25). The game uses these photos as JPG in
> `godot/assets/photos/`; the reference sheets are kept here as JPG. The PNG originals were
> not kept. Brief: [BRIEF.md](BRIEF.md). Decision: DEC-017.

All 13 requested PNGs are saved in this directory. Every image and every visual correction was generated with the built-in image generation tool. No external photographs, stock images, or API/CLI image-generation fallback were used. The emblem sheet was mechanically downsampled to 1024 × 1024 after the generator repeatedly returned a larger square; its design was preserved.

The reference sheets were generated first. Every scene received the character sheet as a reference; scenes displaying the Foundation emblem also received the emblem sheet. For scenes without recurring characters, the character reference was explicitly designated as an exclusion reference. The family and terrace scenes additionally received a previous lodge image as an architecture reference.

## Files and final prompt set

Shared scene direction: photorealistic ordinary company CMS event photography, natural skin, slightly flat/over-lit venue light or flash, mild 35 mm softness, muted cool navy/grey palette, fictional people, no glamour or thriller treatment, no watermarks, frames, UI, real brands, or extraneous readable text. Preserve the reference identities and seven-ray sunrise-in-ring design wherever applicable. The following scene-specific prompts were combined with that direction and the corresponding details in BRIEF.md.

| File | Dimensions | Content / scene-specific prompt |
| --- | --- | --- |
| `sheet_characters.png` | 1536 × 1024 | Neutral grey, evenly lit, front-facing head-and-shoulders reference row. Left to right: Daniel, Grace, Samuel, CEO, security director. Grey space above and below keeps the landscape canvas while retaining shoulder-up portraits. |
| `sheet_emblem.png` | 1024 × 1024 | Gold rising half sun, seven rays and horizontal baseline inside a complete ring on navy; matching small physical lapel pin on navy fabric beside it. No text. |
| `IMG001.png` | 1536 × 1024 | Spring 2021 leadership awards stage. Grace, Samuel, CEO, Daniel left to right; Daniel holds a blank glass award at the extreme right. Blue abstract backdrop without words, two visible lapel pins. |
| `IMG002.png` | 1536 × 1024 | Daytime October 2021 lodge retreat. Twelve adults in two rows of six, Grace third from left in the front row. Timber beams, autumn hills through large windows, emblem on wooden lectern. Banner: `HORIZON RIDGE LEADERSHIP RETREAT`. |
| `IMG003.png` | 1536 × 1024 | 2019 ballroom gala. Samuel left in tuxedo with pin, Grace centre in evening dress, Daniel right in dark suit; blank programme booklets. Warm chandeliers and navy/gold step-and-repeat reading `HORIZON FOUNDATION`. |
| `IMG004.png` | 1536 × 1024 | 2020 private dinner. Samuel and CEO sit side by side laughing toward an off-camera guest, both pins visible; white tablecloth, candles, clear water in stemmed glasses, blurred guests at edges. |
| `IMG005.png` | 1536 × 1024 | Summer 2018 lodge lawn. Grace in cream linen with sunglasses pushed up, distinct bald/bearded husband, two children about 8 and 11, picnic tables and other families behind. Banner: `HORIZON RIDGE`. |
| `IMG006.png` | 1536 × 1024 | Orientation-day group of twelve Filipino/Vietnamese-appearing young adults, six per row, six men and six women. Matching light-grey polos with small sunrise crests; modern office entrance, unobscured faces, no signs or text. |
| `IMG007.png` | 1536 × 1024 | Nighttime stone lodge terrace. Exactly four people left to right: Daniel looking toward Grace, Grace, Samuel with pin, security director with green jacket, emblem patch and blank badge. Loose conversation, no touching, flash-lit people and warm lodge windows/dark pines behind. No printed timestamp. |
| `IMG-0390.png` | 1536 × 1024 | Full company auditorium viewed from the back. Small distant presenter and a large abstract blue/teal bar chart without words or numbers. |
| `IMG-0401.png` | 1536 × 1024 | Sunny volunteer tree-planting photo with twelve staff: six kneeling at saplings and six standing with shovels. Plain matching teal shirts, gloves, no recurring cast or lettering. |
| `IMG-0367.png` | 1536 × 1024 | Bright Seattle office opening with about thirty staff, a red ribbon, and large silver ceremonial scissors held by three central staff. Distinct non-cast central man; no signage or text. |
| `IMG-0402.png` | 1536 × 1024 | Holiday product display: plain backpacks, water bottles and ribboned gift boxes. Red/white fabric banner with abstract shapes only, no people or words. |

## Visual review and corrections

- Viewed every delivered image. Verified PNG dimensions for all 13 files.
- Confirmed the critical counts: IMG002 = 12, IMG006 = 12, IMG007 = 4. Volunteer Day also has 12 staff.
- Compared recurring faces with the character reference. Replaced an accidental Daniel-like husband in IMG005 and a CEO-like central participant in IMG-0367 with clearly different fictional people.
- Regenerated Volunteer Day after the first result contained only ten people.
- Corrected the character sheet framing before producing scene photographs.
- In IMG001, Daniel's visible face lies approximately between x = 1360 and 1490, within the rightmost 15% (x ≥ 1306). A centred 4:3 crop at full height retains x ≈ 85–1451, cutting the right side of his face. The precise effect in the game depends on its actual thumbnail crop anchoring.
- Checked the three requested banner phrases and the gala step-and-repeat. No unintended readable text was observed; booklets, badges, chart labels and product labels remain blank.
- Checked the shared timber, stone and multi-pane-window lodge vocabulary across IMG002, IMG005 and IMG007.

## Remaining limitations / interpretation

- Tiny photographic pins and shirt crests are recognizable sunrise-in-ring marks, but their ray spacing and metal details are not pixel-identical to the large emblem master. The large reference emblem has seven rays.
- Daniel's younger appearance in 2019, Grace's younger appearance in 2018, and Daniel's slightly ill-fitting gala suit are subtle. Face recognition was prioritized over stronger ageing or wardrobe distortion.
- Samuel reads as tall, but pose and camera perspective mean the apparent height difference is not exactly a full head in every scene, especially the terrace conversation.
- The lodge is visually consistent across scenes; generated architectural details are not an exact structural reconstruction.
- Followed the specific family-photo request for two children despite the general “Adults only” line in the brief.

Only the requested PNG deliverables and this NOTES.md were authored in the working directory; BRIEF.md was left unchanged.
