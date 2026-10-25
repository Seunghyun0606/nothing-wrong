# CX-02 · Game icon, desktop wallpaper, and title art

Read `docs/codex/RULES.md` first and follow it.

## Goal

The Windows build has no icon (`application/icon=""`) and the in-game desktop and title
screen have no artwork. Make these with your image generation tool, in the same world and
mood as the story photos you made earlier (`docs/story/photos/BRIEF.md`, `NOTES.md`, and
the reference sheets there).

## Output folder

`docs/art/2026-10-26/` only. Save PNGs with exactly these names and write `NOTES.md` there.

## The world in one paragraph

The player is a new QA engineer at **Northstar**, a testing company, working on a quiet
Windows-like desktop (Messenger, Browser, QA Notes). The client is a large corporation,
Horizon. Everything looks calm, competent, and corporate. The title says it: *Nothing
Wrong*. The unease is in what is not shown. Palette: calm blue-greys, white, navy, a
little warm light. Never horror, never thriller, never gore.

## Files

1. `icon.png` (1024x1024): the game icon. A simple, bold, flat mark that reads at 32 px:
   a rounded-square tile in navy/blue-grey with a single clean white checkmark whose last
   stroke is very slightly off (a tiny break or misalignment, subtle, not a glitch effect).
   No letters. It must not use the Horizon Foundation sun-in-a-ring emblem (that is a
   story reveal) or anything resembling a real company's logo.
2. `icon_32_preview.png`: the icon scaled down to 32x32 and to 16x16 side by side on a
   light and a dark background, so the small sizes can be judged.
3. `wallpaper.png` (1920x1080): the in-game desktop wallpaper for Northstar's work PCs.
   Calm abstract corporate wallpaper: soft blue-grey gradient with a faint, large north-star
   shape (four long points) low in one corner, very low contrast so windows and text on
   top stay readable. No text, no logos besides the faint star.
4. `title.png` (1920x1080): title screen backdrop. A late-evening open-plan office seen
   from a desk: two monitors glowing with blurred, unreadable interface panels (no legible
   words or numbers), a mug, a sticky note with no writing, the city faintly through the
   window. Quiet, slightly lonely, realistic but softly lit. Leave the left third
   calmer and darker so the game can draw its title and buttons there. No people.
5. `lock.png` (1920x1080): lock-screen backdrop, the same office in early morning light
   (same desk and window as `title.png`), lighter and calmer.

## Check before you finish

Look at every image. Regenerate if: any readable text appears; a real brand or logo
appears; the icon is unreadable at 32 px; the wallpaper is busy enough to fight with
window text; `title.png` and `lock.png` are not recognisably the same place. In `NOTES.md`
list each file, its final prompt, and anything you could not get right. Do not edit any
other file.
