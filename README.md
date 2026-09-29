# Epizeuxis

Tap the word that appears twice so a saved Courtauld painting files as fair.

This app is for people who already keep museum paintings on device and want to drop a scribal double. It is not a museum site, not a shop, and not a grade book.

## Architecture

Epizeuxis is a closed Dittography fold: Idle, Echoed, and Fair. A fourth work case is a defect. Plain is a write when the crate cannot echo.

The echo is a fold over Works. `EchoStore` pattern-matches that fold. Views call `echoLine`, `elideToken`, `botchToken` (via a miss on `elideToken`), and `undoNewestMark`. They do not keep a second echo enum.

The fold fits this product because the job is one native token written twice. Echo writes a Line that is artist XOR title with one adjacent duplicate and folds Idle to Echoed. Elide writes an ElideMark when the tap is either identical neighbor and folds Echoed to Fair. A miss writes a BotchMark and keeps the Line. Elide on Idle is refused. A second Echo while Echoed is refused.

## Echo then elide

Echo samples one saved Work that is not Fair whose chosen field has at least two pairwise-distinct tokens. Every token is tappable. Fair works leave the echo pool and rest on Saved. Undo peels the newest ElideMark or BotchMark. Explore stores a Work as Idle. A repeated object id focuses that row. Empty echo writes Plain.

Home is the quiz, not a list of records. Explore, Saved, and Settings arrive as sheets over the locked line.

## Look

3D glass render, glassmorphism. Soft card daylight. Warm hospitable type on SF Pro. Photography-first quiz tile, caption under the tile, pill Elide, soft shadow only on the hero.

Base prompt used for every asset:

```
3D glass render, glassmorphism, studio-lit copyist board, frosted doubled word line beside one painting tile, refraction and soft bloom, isolated subjects, quiet uncluttered ground, hospitable daylight not a museum grid, no text, no letters, no logo, no photoreal stock, no specified colours, one echoed line not a gloss rail, not a mixed folio, not a composing stick, and not a glued roll
```

Exact per-asset prompts (images are generated in a later assets step; empty imagesets are named from the spec):

**epz_AppIcon** — A single 3D glass copyist board with one frosted doubled word line, glassmorphism, subject centred filling the canvas edge to edge, no text, no letters, no words, no alpha, no transparency, no rounded corners, no drop shadow outside the canvas

**epz_Splash** — A tall vertical 3D glass copyist board receding, quiet uncluttered centre band for a wordmark, glassmorphism, no readable text

**epz_Onboarding1** — Solid wooden copyist board with a painting tile and a doubled caption line, the product in one glance, isolated cutout, opaque wood and paper in the center, transparent corners, no glass box, no text

**epz_Onboarding2** — A hand tapping one of two identical solid word tablets sitting side by side, elide the echo, isolated cutout, opaque subject in the center, no hollow frame, no text

**epz_Onboarding3** — A small stack of fair filed painting boards beside a copyist quill, meaning accumulated, isolated cutout, opaque subjects, no text

**epz_EmptyHome** — A solid unused copyist board still blank, waiting, calm and inviting, never sad, isolated cutout, opaque wood and paper in the center, no hollow glass, no text

**epz_EmptyList** — A solid empty wooden picture crate with no boards, calm, isolated cutout, opaque wood, no text

**epz_CardBackdrop** — Abstract low-contrast 3D frosted glass copyist bloom, quiet enough for text on top, filling the canvas, no letters

**epz_ControlFace** — The face of a small solid bone stylus used to mark a doubled word, isolated cutout, opaque bone, no text

**epz_TwistHero** — Solid caption tablets with one word written twice beside itself, echo-then-elide emblem, isolated cutout, opaque paper, no hollow glass, no text

**epz_SuccessMark** — A small solid painting board filed after the twin was dropped, confirmation not fireworks, isolated cutout, no letters

**epz_HeaderDecor** — A wide low solid copyist rail with one overlapping doubled tablet, isolated cutout, opaque wood and paper in the center, transparent corners, no glass pane, no readable text

**epz_CopyistBoard** — Isolated solid wooden copyist board, cutout, transparent corners, opaque wood filling the center, no plate, no hollow frame, no text

**epz_TwinToken** — Two identical solid word tablets sitting side by side, cutout, opaque paper, transparent corners, no plate, no readable letter, no text

**epz_EchoedLine** — Isolated solid row of caption tablets with one pair doubled, cutout, opaque paper, transparent corners, no plate, no text

## How this is not a repeat

Home verb is elide-the-echo: one native token of artist XOR title is written twice, and tapping either twin files the work as fair. That is not strike-the-gloss, not keep-the-undertext, not right-the-sort, not patch-the-shard, not seat-the-role, and not split-the-kollesis. One Courtauld voice. Sheets only. No shop and no grade.

## Build

```bash
cd apps/Epizeuxis
xcodegen generate
xcodebuild -scheme Epizeuxis -destination 'generic/platform=iOS' build
```

Contact: https://epizeuxis-echo.pro/contact-us
