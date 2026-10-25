# CX-02 — art delivery

Date: 2026-10-26  
Result: completed art deliverables; no product integration or Project OS transition performed.  
Brief: [CX-02-art.md](../../codex/CX-02-art.md). Rules: [RULES.md](../../codex/RULES.md).

## Delivered files

| File | PNG dimensions | Content |
| --- | --- | --- |
| [icon.png](icon.png) | 1024 × 1024 | Navy blue-grey rounded tile and white check with a slightly displaced, separated upper terminal. |
| [icon_32_preview.png](icon_32_preview.png) | 160 × 96 | Actual 32 × 32 and 16 × 16 resamples, side by side on light and dark backgrounds. |
| [wallpaper.png](wallpaper.png) | 1920 × 1080 | Quiet blue-grey gradient and a faint four-point star low at right. |
| [title.png](title.png) | 1920 × 1080 | Empty evening office with two softly glowing monitors, blank sticky note, mug and city windows; dark quiet left third. |
| [lock.png](lock.png) | 1920 × 1080 | The same desk, window and city composition in soft early morning light. |

## Method and references

All original artwork and all visual corrections used the built-in image generation tool. No API/CLI generation, stock imagery or externally sourced photographs were used. Read the story-photo BRIEF.md and NOTES.md and visually inspected sheet_characters.jpg and sheet_emblem.jpg for palette and the emblem exclusion. The photos' restrained corporate realism, cool navy/grey palette and modest warm lighting informed the office prompts. No reference character or Foundation emblem was included in these deliverables.

The generator returned a 1254 × 1254 icon and 1672 × 941 landscape images despite the requested dimensions. Windows System.Drawing high-quality bicubic resampling produced the exact delivery sizes, with no creative redraw or composition change. The landscape aspect-ratio adjustment is below 0.1%. The final assets are opaque RGB PNGs. The icon has pale grey exterior corners, rather than transparency.

Two transparent-icon attempts were rejected for cloudy tile interiors and transparency defects. The accepted icon was regenerated as opaque artwork. An office correction removed logo-like marks from the monitor bezels and keyboard legends before the morning edit. Only the final five PNGs and this report were written into the repository, all in this output folder.

## Exact final prompt set

### icon.png

Fresh generation; transparent_background=false.

```text
Use case: logo-brand. Asset: a finished flat application icon for a corporate QA game, square 1024x1024.
A perfectly solid flat navy blue-grey #263D53 rounded-square tile, nearly edge-to-edge (94% of canvas), on a perfectly solid pale cool-grey #E9EDF1 background visible only in the tiny outer corners. All pixels fully opaque, no transparency. Single bold pure white checkmark centered, short descending left arm and long ascending right arm, occupying 60% of the width. There is a tiny clean 4-pixel break near the very upper right tip of the long stroke and the small terminal piece is shifted 3 pixels sideways: a subtle almost-correct check. Maintain a strong unambiguous check silhouette at 32 pixels. Uniform thick white strokes, balanced padding. Entire image is two-dimensional flat color: ONE uniform navy fill, white check, pale-grey outer corners. No lighting, no gradients, no texture, no shadows, no bevel, no glass, no mockup. No letters or numbers, no words, no real brand logos, no sun, no ring, no other symbols, no watermark.
```

### icon_32_preview.png

No generative prompt was used: this is a deterministic size proof derived from the delivered icon.png. Canvas 160 × 96, upper half #EEF1F5, lower half #141D29. Each row shows a 32 × 32 icon at x=24, y=8/56 and a 16 × 16 icon at x=104, y=16/64. High-quality bicubic resampling with mirrored edge handling, then unscaled placement; no labels or enlargement. The initial pixel comparison caught background blending at the resample edges; corrected all final resampling to use mirrored edges and confirmed all four preview regions match independently resized icons pixel for pixel. View at 100% to judge native pixel sizes.

### wallpaper.png

Fresh generation; transparent_background=false.

```text
Use case: stylized-concept.
Asset type: finished corporate desktop wallpaper for a fictional QA testing company, 1920x1080, landscape 16:9, opaque PNG.
Primary request: a very quiet smooth soft blue-grey gradient, slightly lighter toward the upper right and muted medium blue-grey toward the lower left. One faint large four-point north star sits low in the bottom right corner, centred roughly at 84% width and 82% height, occupying about 24% of image height. Exactly four long tapered points, vertical points a little longer than horizontal points; simple straight concave star silhouette, no circular ring. The star is only a few shades lighter than its surrounding gradient, approximately 3–5% luminance contrast, barely perceptible like a watermark. No shine.
Composition: edge-to-edge gradient, broad calm empty space over the entire left and centre; no surface details, no banding. Must remain unobtrusive behind desktop windows and text.
Palette: calm desaturated blue-grey, slate, pale cool grey. Professional quiet corporate visual world.
Constraints: no text, letters, numbers, logos, brand marks, sun emblems, circles, windows, UI, people, objects, sparkles, beams, extra stars, decorative lines, texture or watermark text. Single very faint four-point star only.
```

### title.png

Initial generation; transparent_background=false.

```text
Use case: photorealistic-natural.
Asset type: finished title-screen background for Nothing Wrong, a quiet corporate QA game. Landscape 16:9, 1920x1080 opaque PNG. Do not render a title or any buttons.
Primary request: ordinary modern open-plan testing-company office late in the evening, viewed at seated eye level from a work desk. No people. Competent, calm, slightly lonely everyday workplace, no thriller or horror styling. Match ordinary corporate documentary photography: restrained realism, mild 35mm lens softness, muted cool blue-greys, navy, white, a little warm practical light, natural materials.
Composition: reserve the whole LEFT THIRD as dark calm low-detail negative space, a plain navy-grey shadowed partition and uncluttered desktop, no bright objects or hard lines in that region; suitable for white game title and menu drawn later. Desk and objects occupy centre-right. Two plain unbranded black monitors side by side centre-right, both visibly glowing with gently blurred abstract grey-blue interface panels, absolutely no letters, words, numbers, icons or code. One plain ivory ceramic mug to their right. One blank pale-yellow sticky note on the lower right bezel of the left monitor. Plain dark keyboard and mouse below. Desk surface matte grey with subtle use marks.
Behind the desk, a large window with vertical dark mullions across the right side shows a faint generic city skyline at blue hour; subdued distant city lights, no landmarks or signs. A few empty workstation silhouettes recede quietly behind the desk. Soft neutral ceiling light and subtle warm light from the far right, gently exposed shadows; the place is visibly an ordinary safe office.
Constraints: no humans, faces, readable text, numbers, pseudo-writing, signage, posters, branding, real company marks, foundation emblem, sun-in-ring, watermark, captions, dramatic spotlight, dense clutter or supernatural details. Mug and sticky note blank. Monitor content consists only of soft unfocused rectangular areas, no glyph-like rows. Single seamless scene.
```

Final correction, using that initial evening image as Image 1; transparent_background=false.

```text
Use case: precise-object-edit.
Image 1 is the title background edit target. Change only the monitor bezels and keyboard markings. Remove the small raised logo-like badges at the centre of both foreground monitors' bottom black bezels; make each entire lower bezel plain smooth uninterrupted matte black, no label or embossed mark. Also ensure all keyboard keycaps are blank, without any letters or numbers. Preserve absolutely everything else: seated camera, desk, two monitor shapes, blurred abstract panels, blank sticky note, mug, evening city window, partition, lighting, composition and empty dark left third. No readable text, pseudo-writing, brand marks, emblems or watermark anywhere. Output landscape 16:9, 1920x1080.
```

### lock.png

Lighting edit, using the corrected evening title image as Image 1; transparent_background=false.

```text
Use case: lighting-weather.
Asset type: finished lock-screen office backdrop, 1920x1080 landscape 16:9 opaque PNG.
Image 1 is the exact office and desk edit target, the approved evening title backdrop. Change ONLY the time of day and the consequent lighting to early morning. Preserve the identical seated camera, framing, desk geometry, dark left partition, two monitors and plain black bezels, blank sticky note on the lower right of the left monitor, ivory mug at right, blank keyboard, mouse, chairs, plants, window mullions and exact city building silhouettes in exactly the same positions. The morning image must unmistakably be the very same place from the very same viewpoint.
Lighting: soft pale early morning daylight through the windows, cool blue-grey ambience with a slight warm dawn tint at the right, lighter gentler exposure, calm ordinary start-of-workday mood. City windows largely unlit, pale bright morning sky. Screens still softly glowing with the same abstract blurred rectangular panels, no glyphs or text; less dominant in daylight. Turn down artificial lamp glow naturally. Left third stays uncluttered but its plain partition is now a lighter muted slate, no harsh light shaft.
Photorealistic ordinary corporate documentary feel, mildly soft 35mm realism, muted blue-grey, navy, white and a touch of warmth.
Constraints: no people, readable text, numbers, keyboard legends, monitor logos or embossed marks, foundation emblem, ring or sun symbol, watermark, added props, repositioned objects, new architecture, changed city skyline, dramatic weather or thriller treatment. Do not add lock screen clock, buttons, title or UI over the photograph.
```

## Verification

- Opened and visually inspected every final PNG, including the preview at its native size.
- The white check reads clearly at both 32 px and 16 px on both backgrounds. The terminal irregularity becomes a small detail at 32 px and largely merges at 16 px.
- No readable text, real brand marks, people or Foundation emblem observed in the final artwork. Monitor panels are blurred rectangles, keyboard keycaps and sticky note are blank.
- Wallpaper has one faint star at lower right and broad low-detail space. Its suitability behind window text is a visual judgement; no in-game overlay test was run.
- Compared title and lock: foreground desk edge, monitor stands, mug, sticky note, keyboard, mouse, window mullions, chairs and city silhouettes occupy recognisably the same positions. The morning scene is visibly brighter and calmer.
- Checked the title's left third remains dark and low-detail for later title/menu drawing.
- Verified PNG signatures and exact dimensions programmatically, including the four actual preview resamples.
- Did not run Godot or modify game files: CX-02 requests art delivery only. Existing repository changes were left alone.

## Remaining limitations

- The generated icon has extremely subtle raster texture rather than mathematically uniform vector fills. Its terminal gap and displacement are larger than the literal pixel values requested in the prompt, but stay visually restrained at application-icon size.
- Pale outer icon corners are intentionally opaque and appear as a fine light perimeter on a dark background; the preview exposes this. A transparent icon was not retained because its generated tile had interior alpha defects.
- The wallpaper star has gently curved concave edges, rather than perfectly straight polygon edges. It remains a low-contrast four-point silhouette.
- Office continuity is visually convincing, not a claim of pixel-identical reconstruction. Tiny light and material details can vary between the generative evening and morning edit.
- Text/brand absence and image mood were checked visually, not certified by an external logo matcher or OCR system. No blocking visual defect remained after review.

No changes to product code/content, story canon, Project OS state, player saves or git history were made.

