# CX-06 — badge and product photo delivery

Date: 2026-10-26  
Role/task: Codex art production, CX-06.  
Result: 7 badge portraits and 3 product photographs delivered with the exact requested filenames.

## Method and scope

Read PROJECT.md, the Project OS manifest/current state, CX-06, RULES.md, and the earlier photo BRIEF.md and NOTES.md. Used the built-in image generation tool for every image and every visual correction. No API/CLI image generation, stock photos or external photographs were used.

The supplied `docs/story/photos/sheet_characters.jpg` was viewed and passed directly to every Grace generation as an identity reference; Grace is second from the left. For the other six portraits it was passed only as an exclusion reference, to prevent accidental reuse of recurring faces. Product images used no image references.

Grace required three generations in total: the initial portrait looked too mature; the second requested stronger age regression; the final edited that draft using both the original character sheet and the second draft. Only the final selected images are delivered here. The generator's original outputs and discarded variants remain in its automatic cache.

The generator returned badge images at 1254 × 1254 despite the requested 1024 × 1024. Pillow performed only proportional Lanczos downsampling to 1024 × 1024 and RGB PNG encoding; it did not retouch faces, invent pixels, crop compositions or alter styling. Products were generated at 1536 × 1024 and encoded as RGB PNG at that same size.

Authored repository files only in this output directory. Product code, story canon, Project OS state and Git history were not changed.

## Delivered files and visual review

Viewed all ten generated images and then reopened every final saved PNG with the image viewer after export. The following are visual observations/judgements, not automated identity or age measurements.

| File | Final dimensions | Review |
| --- | --- | --- |
| [grace-yoon.png](grace-yoon.png) | 1024 × 1024 | 2008 / about 29. Reference Grace's eye, nose and mouth relationships retained; longer hair past shoulders, side fringe, dark blazer/light top, no earrings. Final selected after two age corrections. |
| [mina-seo.png](mina-seo.png) | 1024 × 1024 | 2016 / about 25. Straight black hair and blunt full fringe, friendly closed-mouth expression, cardigan over collared shirt. |
| [marcus-reyes.png](marcus-reyes.png) | 1024 × 1024 | 2013 / about 30. Short hair, light stubble and quarter-zip sweater; distinct from the reference's older, stocky security director. |
| [leo-ortiz.png](leo-ortiz.png) | 1024 × 1024 | 2021 / about 24. Curly dark hair, hoodie under casual jacket; slim youthful face distinct from the security director. |
| [priya-nair.png](priya-nair.png) | 1024 × 1024 | 2017 / about 27. Long dark hair tied back in a low ponytail, simple blue blouse. |
| [elena-brooks.png](elena-brooks.png) | 1024 × 1024 | 2011 / about 33. Shoulder-length light brown hair and business jacket; ordinary frontal ID framing. |
| [alex-han.png](alex-han.png) | 1024 × 1024 | 2019 / about 26. Very short buzz cut, no glasses, broad face and plain crew-neck; clearly distinct from Daniel's parted hair, glasses and narrower face. |
| [everyday-pack.png](everyday-pack.png) | 1536 × 1024 | Muted coral-orange structured backpack, upper quick-access zipper pocket, padded straps/back structure; warm off-white seamless background. |
| [travel-sling.png](travel-sling.png) | 1536 × 1024 | Slate-blue compact sling bag, single adjustable strap and front zip pocket; warm off-white seamless background. |
| [laptop-sleeve.png](laptop-sleeve.png) | 1536 × 1024 | Grey felt padded envelope sleeve, closed broad flap with concealed closure; warm off-white seamless background. |

All badge photographs show one person, front-facing at eye level, with a plain light blue-grey backdrop and even, flat lighting. No selfie viewpoints were observed. Compared all six new staff faces with the five-person sheet; no mistaken reuse of Daniel, Samuel, the CEO or the security director was observed. Grace remains recognizable as the sheet's Grace.

No readable text, logos, brand tags, watermarks, card borders or lanyard lettering were observed in any delivered image. The product photographs each show one complete product with a soft shadow and surrounding background space.

## Automated verification

A Python/Pillow export check successfully loaded each generated source, checked its aspect ratio, saved and verified each PNG, then reopened it to assert the exact required dimensions, RGB mode and PNG format. The set of PNG filenames was asserted to equal the ten names from CX-06. All ten passed. SHA-256 hashes were computed in the verification output to identify the selected files.

## Limitations and interpretation

- Exact perceived ages remain subjective. Grace's final face is younger than the master, but the change remains restrained and may read somewhat older than 29; recognizable identity was preserved through two corrective generations.
- Year-specific camera differences are subtle. The older portraits use restrained softness and flat lighting rather than obvious fading or damage; the set retains a consistent directory appearance.
- The backpack's laptop compartment is hinted by its rear structure rather than shown open. The sleeve's magnets are concealed under its closed flap. Capacity, maximum laptop fit and recycled fabric composition are intended product specifications, not properties a photograph can verify.

## Final prompts

These are the exact final prompts sent to the built-in image generation tool. All calls used `transparent_background: false`. A prompt's requested pixel size is recorded faithfully; the mechanical export normalization described above produced the final dimensions.

### grace-yoon.png

References: original `docs/story/photos/sheet_characters.jpg` (identity master) and the second Grace draft `exec-16d607d6-e848-465c-8c45-a1322f620de6.png` (correction target/layout), both passed as local image paths. The draft is retained only in the tool's automatic cache.

```text
Use case: identity-preserve. Create final grace-yoon.png, square corporate ID photo 1024x1024.
Input 1 sheet_characters.jpg: identity master, Grace is the woman SECOND FROM LEFT. Input 2 is the draft portrait to correct. Keep the same recognizable woman and same framing, clothes, blue-grey background, long hair past shoulders and side fringe, no earrings. Main correction: AGE REGRESSION from the mature draft to her genuinely YOUNG AGE 29, taken in 2008. The draft mistakenly looks about 42. Reconstruct how this same woman looked thirteen years earlier, NOT simply remove a few wrinkles. Younger fuller cheek contour, firmer cheek and jaw tissue, smooth natural eyelid and lower-eye transitions, youthful upper face and lips; remove mature crow's feet, deep cheek creases and under-eye age changes. Preserve specific eye shape and spacing, distinctive nose shape, mouth shape and overall face identity. Still natural photographic skin, not glossy beauty retouching. Her face must plausibly read late twenties. The second image supplies layout only; the reference master supplies identity, not target age.
Simple dark blazer over light top, no pearl earrings or any jewelry. Centered head and shoulders, facing straight at camera with neutral mild closed-mouth smile. First-week corporate badge photo in 2008, slightly flat on-camera flash, plain light blue-grey backdrop, distinctly gentle early-digital softness and low contrast, ordinary office camera rather than a beauty session. No text, logo, watermark, lanyard, emblem, frame or border. One fictional woman only.
```

### mina-seo.png

Reference: `docs/story/photos/sheet_characters.jpg`, exclusion reference only.

```text
Use case: photorealistic-natural. Asset: a fictional staff directory ID photograph, square 1024x1024. One adult, head and shoulders, exactly front-facing at eye-level, centered with space above complete hair and visible shoulders. Plain light blue-grey backdrop. Even frontal light, slightly flat on-camera flash, ordinary first-week corporate badge camera capture with natural unretouched skin. Neutral mild closed-mouth smile. No glamour, selfie angle, dramatic shadows or cinematic treatment.
Input reference sheet is an EXCLUSION reference only: create a completely NEW fictional person who does NOT resemble any of the five people in it. Especially avoid Daniel (first from left, slim oval face and parted hair with rectangular glasses), Samuel (third), CEO (fourth), or security director (fifth). No resemblance to real public figures.
No readable text, letters, numbers, logos, emblems, branding, name tags, lanyards, badge card, watermark, border or frame. Image is just the portrait photograph.
Subject: Mina Seo, Korean woman about 25, photographed in 2016. Straight jet-black hair with an unmistakably BLUNT FULL FRINGE across the forehead, friendly youthful round face distinct from Grace, a soft muted cardigan over a neat collared shirt. Plausible simple 2016 office styling and modest digital-camera clarity.
```

### marcus-reyes.png

Reference: `docs/story/photos/sheet_characters.jpg`, exclusion reference only.

```text
Use case: photorealistic-natural. Asset: a fictional staff directory ID photograph, square 1024x1024. One adult, head and shoulders, exactly front-facing at eye-level, centered with space above complete hair and visible shoulders. Plain light blue-grey backdrop. Even frontal light, slightly flat on-camera flash, ordinary first-week corporate badge camera capture with natural unretouched skin. Neutral mild closed-mouth smile. No glamour, selfie angle, dramatic shadows or cinematic treatment.
Input reference sheet is an EXCLUSION reference only: create a completely NEW fictional person who does NOT resemble any of the five people in it. Especially avoid Daniel (first from left, slim oval face and parted hair with rectangular glasses), Samuel (third), CEO (fourth), or security director (fifth). No resemblance to real public figures.
No readable text, letters, numbers, logos, emblems, branding, name tags, lanyards, badge card, watermark, border or frame. Image is just the portrait photograph.
Subject: Marcus Reyes, Filipino-American man about 30, photographed in 2013. Short neat black hair, LIGHT STUBBLE rather than full beard, an approachable rounded youthful face with broad cheekbones, dark brown eyes. Plain charcoal quarter-zip sweater with the zipper visible at collar. Typical 2013 office ID styling, a little softer and flatter than a 2021 digital photo. He must look clearly Filipino, NOT like the stocky bearded security director or the older Korean men in the reference.
```

### leo-ortiz.png

Reference: `docs/story/photos/sheet_characters.jpg`, exclusion reference only.

```text
Use case: photorealistic-natural. Asset: a fictional staff directory ID photograph, square 1024x1024. One adult, head and shoulders, exactly front-facing at eye-level, centered with space above complete hair and visible shoulders. Plain light blue-grey backdrop. Even frontal light, slightly flat on-camera flash, ordinary first-week corporate badge camera capture with natural unretouched skin. Neutral mild closed-mouth smile. No glamour, selfie angle, dramatic shadows or cinematic treatment.
Input reference sheet is an EXCLUSION reference only: create a completely NEW fictional person who does NOT resemble any of the five people in it. Especially avoid Daniel (first from left, slim oval face and parted hair with rectangular glasses), Samuel (third), CEO (fourth), or security director (fifth). No resemblance to real public figures.
No readable text, letters, numbers, logos, emblems, branding, name tags, lanyards, badge card, watermark, border or frame. Image is just the portrait photograph.
Subject: Leo Ortiz, Latino man about 24, photographed in 2021. Clearly curly dark hair with natural ringlets, clean-shaven youthful slim angular face, medium warm brown skin, friendly neutral expression. Plain hoodie under a casual jacket, no marks or graphics anywhere. Straight-on 2021 corporate ID photo with modest clear digital-camera detail. He is NOT the older stocky bearded security director from the reference; different narrow face, clean-shaven and much younger.
```

### priya-nair.png

Reference: `docs/story/photos/sheet_characters.jpg`, exclusion reference only.

```text
Use case: photorealistic-natural. Asset: a fictional staff directory ID photograph, square 1024x1024. One adult, head and shoulders, exactly front-facing at eye-level, centered with space above complete hair and visible shoulders. Plain light blue-grey backdrop. Even frontal light, slightly flat on-camera flash, ordinary first-week corporate badge camera capture with natural unretouched skin. Neutral mild closed-mouth smile. No glamour, selfie angle, dramatic shadows or cinematic treatment.
Input reference sheet is an EXCLUSION reference only: create a completely NEW fictional person who does NOT resemble any of the five people in it. Especially avoid Daniel (first from left, slim oval face and parted hair with rectangular glasses), Samuel (third), CEO (fourth), or security director (fifth). No resemblance to real public figures.
No readable text, letters, numbers, logos, emblems, branding, name tags, lanyards, badge card, watermark, border or frame. Image is just the portrait photograph.
Subject: Priya Nair, Indian-American woman about 27, photographed in 2017. Long dark hair neatly tied back in a low ponytail, visible pulled-back hair at sides, warm medium-brown skin, distinct youthful oval face, brown eyes and modest friendly closed-mouth smile. Simple solid muted blue blouse, small simple stud earrings permitted, no elaborate jewelry. Ordinary 2017 office styling, modest digital-camera clarity.
```

### elena-brooks.png

Reference: `docs/story/photos/sheet_characters.jpg`, exclusion reference only.

```text
Use case: photorealistic-natural. Asset: a fictional staff directory ID photograph, square 1024x1024. One adult, head and shoulders, exactly front-facing at eye-level, centered with space above complete hair and visible shoulders. Plain light blue-grey backdrop. Even frontal light, slightly flat on-camera flash, ordinary first-week corporate badge camera capture with natural unretouched skin. Neutral mild closed-mouth smile. No glamour, selfie angle, dramatic shadows or cinematic treatment.
Input reference sheet is an EXCLUSION reference only: create a completely NEW fictional person who does NOT resemble any of the five people in it. Especially avoid Daniel (first from left, slim oval face and parted hair with rectangular glasses), Samuel (third), CEO (fourth), or security director (fifth). No resemblance to real public figures.
No readable text, letters, numbers, logos, emblems, branding, name tags, lanyards, badge card, watermark, border or frame. Image is just the portrait photograph.
Subject: Elena Brooks, white American woman about 33, photographed in 2011. Shoulder-length LIGHT BROWN hair, simple 2011 side-parted smooth styling, subtle natural makeup, blue-grey eyes, composed neutral mild smile. Business jacket over a simple pale blouse. Ordinary business ID photograph, not an executive glamour headshot. Slightly soft, modest low-contrast early-2010s office-camera rendering, flatter and less crisp than a 2021 photograph, no fake scratches or sepia tint. New distinct face.
```

### alex-han.png

Reference: `docs/story/photos/sheet_characters.jpg`, exclusion reference only.

```text
Use case: photorealistic-natural. Asset: a fictional staff directory ID photograph, square 1024x1024. One adult, head and shoulders, exactly front-facing at eye-level, centered with space above complete hair and visible shoulders. Plain light blue-grey backdrop. Even frontal light, slightly flat on-camera flash, ordinary first-week corporate badge camera capture with natural unretouched skin. Neutral mild closed-mouth smile. No glamour, selfie angle, dramatic shadows or cinematic treatment.
Input reference sheet is an EXCLUSION reference only: create a completely NEW fictional person who does NOT resemble any of the five people in it. Especially avoid Daniel (first from left, slim oval face and parted hair with rectangular glasses), Samuel (third), CEO (fourth), or security director (fifth). No resemblance to real public figures.
No readable text, letters, numbers, logos, emblems, branding, name tags, lanyards, badge card, watermark, border or frame. Image is just the portrait photograph.
Subject: Alex Han, Korean-American man age 26, photographed in 2019. VERY SHORT ALL-OVER BUZZ CUT, approximately 3mm hair, no part and no fringe, absolutely NO GLASSES. Clean-shaven, broad sturdy rounded-square face with strong wide jaw, slightly wide-set eyes, neutral closed-mouth expression. Plain dark crew-neck shirt. Youthful natural unlined skin appropriate to 26. He MUST NOT look like Daniel Park, the bespectacled slim oval-faced first man at left in reference; use distinctly different facial geometry. He must also not look like elderly Samuel or the bearded security director. Ordinary 2019 employee ID photograph, modern modest camera clarity.
```

### everyday-pack.png

References: none.

```text
Use case: product-mockup. Asset: clean e-commerce studio product photograph for the fictional online shop Shoply. Exact LANDSCAPE 3:2 composition, requested 1536x1024 pixels. ONE product alone, fully visible, centered with generous clear space all around. Warm off-white seamless background and matching surface, soft contact shadow, diffuse studio softbox light. Real photographic fabric and construction detail, restrained natural color, ordinary credible retail catalog shot.
No text, logos, brand tags, lettering, watermark, border, props, people, hands, mannequin or second item. No brand-identifiable design. No extra promotional graphics.
Product: Everyday Carry Pack, a structured compact 18-litre BACKPACK in MUTED CORAL-ORANGE recycled woven fabric with subtle matte textile grain. Upright three-quarter view showing its front, one side, and a hint of the padded back panel/laptop compartment seam at the rear. A practical quick-access TOP ZIP POCKET is clearly visible, main zipped compartment, padded shoulder straps arranged neatly behind. All zipper pulls and hardware plain and unbranded. Backpack occupies roughly the central half of frame width with comfortable top and bottom margins. Make one coherent functional bag; laptop sleeve only hinted by rear structure, no separate laptop or loose sleeve.
```

### travel-sling.png

References: none.

```text
Use case: product-mockup. Asset: clean e-commerce studio product photograph for the fictional online shop Shoply. Exact LANDSCAPE 3:2 composition, requested 1536x1024 pixels. ONE product alone, fully visible, centered with generous clear space all around. Warm off-white seamless background and matching surface, soft contact shadow, diffuse studio softbox light. Real photographic fabric and construction detail, restrained natural color, ordinary credible retail catalog shot.
No text, logos, brand tags, lettering, watermark, border, props, people, hands, mannequin or second item. No brand-identifiable design. No extra promotional graphics.
Product: Travel Sling, a COMPACT CROSSBODY SLING BAG made from matte SLATE BLUE woven fabric. Slim adjustable webbing shoulder strap, a functional front ZIP POCKET, plain unmarked hardware and zip pull. Small practical streamlined body, not a backpack or handbag. Three-quarter view with the front pocket clearly visible; strap neatly looped behind and beside the bag, fully inside frame with generous margins. One coherent functional bag, no separate accessories. Bag and strap together occupy about the central two-thirds of landscape width and two-thirds height.
```

### laptop-sleeve.png

References: none.

```text
Use case: product-mockup. Asset: clean e-commerce studio product photograph for the fictional online shop Shoply. Exact LANDSCAPE 3:2 composition, requested 1536x1024 pixels. ONE product alone, fully visible, centered with generous clear space all around. Warm off-white seamless background and matching surface, soft contact shadow, diffuse studio softbox light. Real photographic fabric and construction detail, restrained natural color, ordinary credible retail catalog shot.
No text, logos, brand tags, lettering, watermark, border, props, people, hands, mannequin or second item. No brand-identifiable design. No extra promotional graphics.
Product: Laptop Sleeve, a slim PADDED GREY FELT laptop sleeve sized for laptops UP TO 14 INCHES. Broad rectangular envelope shape in landscape orientation, substantial soft grey felt texture, neat reinforced stitched edges, simple broad MAGNETIC FLAP, shown CLOSED with discreet concealed magnetic closure and no visible button or buckle. Slight elevated three-quarter front angle on seamless surface so the flap edge and padded thickness read clearly. Nothing inside or beside it; no laptop, cable, strap, handle, pockets, labels or extra products. Sleeve occupies roughly central two-thirds of image width with generous clear space around all edges.
```

## Selected generation provenance

Original built-in outputs were copied from the tool's automatic cache; the originals were left in place.

| Delivered file | Selected generated filename |
| --- | --- |
| `grace-yoon.png` | `exec-83fa2d64-fb4b-4e64-b117-ecc9e5bb7eb0.png` |
| `mina-seo.png` | `exec-a64abeb0-256e-4b82-85ce-fb8c5e5c2cac.png` |
| `marcus-reyes.png` | `exec-7a10112f-83c9-4e59-8a10-90210dc30d7d.png` |
| `leo-ortiz.png` | `exec-cfba5f5d-ec2d-4d84-a847-b77f222e6073.png` |
| `priya-nair.png` | `exec-9f9ecfed-727f-4c0c-9d9c-b7422867761b.png` |
| `elena-brooks.png` | `exec-5d1518db-f70c-4753-8fd6-55c71200436e.png` |
| `alex-han.png` | `exec-00ada07b-53da-438b-b394-610272a14690.png` |
| `everyday-pack.png` | `exec-8c2e2631-8665-4086-adea-2c32faff34f9.png` |
| `travel-sling.png` | `exec-9331eeda-8b2a-455d-ad1f-41e01707cb20.png` |
| `laptop-sleeve.png` | `exec-d53bc461-54aa-4f36-b85f-86b18b24addc.png` |

