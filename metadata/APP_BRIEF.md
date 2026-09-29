<!-- gf-brief source=b5526e586e8d55eba95bf574ab4afbe03e42a82124e33dbb6b6cda33e9844265 written=2026-09-29T18:00:39+03:00 -->
# Cherriva
## What it is
Cherriva is a Courtauld painting quiz for people who keep works on this device. You save a painting, the app writes one word twice on the maker line or the title line, and you tap that twin then Elide to file the work as fair. Misses stay on Saved as botches you can undo.

## Launch and onboarding
On a new install the system launch screen appears, then a blank pause that can last several seconds. Nothing is tappable during that pause; it continues on its own.

The first pages then cover the app (they do not show on later launches unless you choose “Show the first pages”). Each page has illustration, a title, a line of copy, page dots, a full-width bottom button, and “Skip”.

1. Title “Save a painting”. Line “Keep Courtauld works on this device, then sit the quiz.” Button “Next”.
2. Title “Find the twin”. Line “Echo writes one word twice. Tap either neighbor to elide.” Button “Next”.
3. Title “File it fair”. Line “A true elide files the work. Botches stay reviewable on Saved.” Button “Continue”.

“Skip” on any page, or “Continue” on the last page, dismisses the cover and opens Home.

On a later launch the blank pause still happens, then Home. Saved paintings, the live caption, marks, and the first-pages flag come back as they were.

A first session on a device can also show a banner “Started a new echo.” with “Try again” across the top of Home. Tap “Try again” and the banner leaves. It does not appear again on the next launch.

## Screens
There is no tab bar. Home stays underneath. Explore, Saved, Settings, and The twin open as sheets with “Close” in the bar.

### Home
The title at the top is one of: “Echo a work”, “Tap the twin”, “File it fair”, “The line is plain”. Three icon buttons sit to the right. They have no visible captions; VoiceOver names them “Explore”, “Saved”, and “Settings”. They open those sheets.

If there is nothing left to quiz, Home is a full empty page: “The line is plain.”, “Save a work, then elide.”, and a full-width “Explore” that opens Explore.

Otherwise Home shows:

- A large painting tile. VoiceOver uses the work’s title, or “Painting” if there is none. While the picture is still arriving the tile is a blank muted block. After a true elide, a success mark sits on the painting.
- The work title, or “Saved painting” if none is focused.
- A field label: “Maker line”, “Title line”, or “Line”.
- A status word on the same row: “Idle”, “Echoed”, “Fair”, or “Plain”.
- A wrap of word chips from the live caption. The two matching neighbors stay highlighted. A missed word shows a “cooled” tag, looks dim, and cannot be tapped again. VoiceOver on a twin is “{word}, written twice”; on a miss it is “{word}, cooled”.
- The hint “Tap {that twin word}, then Elide.” If there is no live twin it reads “Tap the twin, then Elide.”
- When status is Echoed, a full-width “Elide”. It files the highlighted word if that word is either twin, or records a miss if it is not. It stays disabled until a word is selected (the twin is selected when the line appears).
- When status is not Echoed, a full-width “Write twice”. It writes a doubled caption for another saved work that is not yet fair. After a fair file it does not start the next line by itself; you tap “Write twice”.
- “Undo”. It peels the newest elide or botch. It is dim and disabled when there are no marks.
- A card “How the twin works” with the line “One word sits twice. Elide either twin.” It opens The twin.
- “Fair lately”: up to six recently filed works. Empty copy is “Filed works rest here after an elide.” Tapping a filed row opens Saved.
- Counts “Elides” and “Botches”.

If a restored crate is in use, the banner “Restored the last good echo.” can appear with “Try again”.

### Explore
Navigation title “Explore”. “Close” dismisses the sheet (VoiceOver “Close Explore”). Search field prompt “Maker or title”.

On open, the local Courtauld shelf is already listed (see Starter content). Each row is the painting, title, and maker. Tap a row to save that work into your crate. A “Saved” tag appears on a row that is already in the crate or is the focused work. Tapping a saved row again does not add a second copy; it focuses that work. The sheet stays open until “Close”.

An empty search box keeps the local shelf and does not look up the catalog. Typing a query waits a moment, may show a spinner, then lists matches. No matches: “No Courtauld match. The local shelf stays.” plus “Try again”, and the local shelf remains. A failed lookup: “Search missed the catalog. The shelf is still here.” plus “Try again”.

If Explore had nothing at all to show, the empty page is “The crate is open.”, “Search The Courtauld, then save a work.”, and “Show shelf”, which fills the local shelf.

### Saved
Navigation title “Saved”. “Close” dismisses (VoiceOver “Close Saved”). Toolbar “Undo” peels the newest mark and is disabled when there are none.

If there are no fair works and no botches, the empty page is “Nothing filed yet.”, “Elide a twin to file a work as fair.”, and “Back to the line”, which closes the sheet.

Otherwise a list shows counts “Elides” and “Botches”. Section “Fair” lists each filed work by title, maker, and an eight-digit day number from the device calendar. Section “Botches” lists the missed word, the work title, and that day number. Rows are not tappable. If there are botches but no fair works yet, extra copy reads “Fair works land here after a true elide.”

### Settings
Navigation title “Settings”. “Close” dismisses (VoiceOver “Close Settings”).

Section “The Courtauld”:

- “The Courtauld” opens The Courtauld site.
- “Collection” opens the gallery collection page.
- “Wikidata Q1138087” opens that Wikidata item.

Section “Marks”:

- “Undo newest mark” peels the newest elide or botch. Disabled when there are no marks.
- When there are none: “No filed tap or miss to peel.”

Section “Help”:

- “Contact us” opens the support page.
- “How the twin works” opens The twin.
- “Show the first pages” closes Settings and shows the three first pages again.

Then “Reset all data” and the line “Clears saved paintings, the live caption, and every mark on this device.” That button opens a confirmation titled “Reset all data” with message “Paintings, marks, and the live quiz leave this device. This cannot be undone.”, destructive “Reset all data”, and “Keep my crate”. Confirming empties the crate on this device. Showing the first pages again after a reset needs “Show the first pages”, or a quit and relaunch.

### The twin
Navigation title “The twin”. “Close” dismisses (VoiceOver “Close the twin”).

Headline “Tap the twin”. Body “A saved painting that is not yet fair gets one word written twice. Maker or title, never both.” Then “Tap either matching neighbor to file it fair. A miss cools that word and keeps the doubled caption.” Decorative twin and caption art follow. There is no other control.

## Features
- Save Courtauld works from Explore into a crate on this device.
- Sit the quiz on Home: “Write twice” / echo a work that is not yet fair.
- A doubled caption that is maker or title, never both, with one word written twice beside itself.
- Tap a word, then “Elide”, to file a true twin as fair or to mark a miss as a botch.
- Status “Idle”, “Echoed”, “Fair”, and “Plain”.
- “Fair lately” on Home, and a Fair list on Saved.
- Reviewable botches on Saved, with “cooled” words on the live caption.
- Counts of Elides and Botches.
- “Undo” / “Undo newest mark” to peel the newest elide or botch.
- “How the twin works” / The twin.
- First pages, with “Show the first pages” to see them again.
- The Courtauld, Collection, and Wikidata Q1138087 credits.
- “Contact us”.
- “Reset all data”.
- Shortcuts named “Open Quiz”, “Open Explore”, “Open Saved”, “Open Settings”, “Echo a line”, and “Elide the twin”. Spoken phrases include “Echo a line in Cherriva” (short title “Echo”) and “Elide the twin in Cherriva” (short title “Elide”).

## Behaviours that can look like bugs
- A blank screen can sit for several seconds after launch. Wait; the first pages or Home follow without a tap.
- First install can show “Started a new echo.” with “Try again”. Tap “Try again”. It is not an error you must fix to use the app.
- Home stays on “The line is plain.” with “Explore” until at least one echoable work is in the crate. Save a work on Explore, close the sheet, then tap “Write twice” if the doubled line has not appeared yet.
- “Write twice” only uses a saved work that is not yet fair and whose chosen maker or title has at least two different words. A one-word maker and a one-word title together will not quiz; the title becomes “The line is plain.” Save another work, or undo a fair file so that work can sit the line again.
- After “File it fair”, the next work does not start by itself. Tap “Write twice”.
- While the line is Echoed, “Write twice” is gone and a second echo is refused. You stay on that caption until you Elide a twin (or Undo / Reset).
- “Elide” does nothing useful on a non-twin: the word gains “cooled”, Botches goes up, and the doubled caption stays. That is a miss. Highlight either matching neighbor, then tap “Elide”. The twin pair is already highlighted when the line appears, so you can tap “Elide” immediately.
- The first pages and The twin say to tap a neighbor to elide. Home also needs the “Elide” button after the word is selected.
- Cooled chips refuse taps. Undo the newest botch to reheat that word, or Elide a still-live twin.
- “Undo” and “Undo newest mark” stay disabled, and Home “Undo” looks faded, until there is at least one elide or botch. “No filed tap or miss to peel.” is the Settings empty line.
- “Elide” is disabled if no word is selected. Tap a live word first.
- Word chips are disabled when status is not Echoed.
- Explore does not search until you type in “Maker or title”. An empty box is the local shelf, not a failure.
- Search can show a Q-number as the artist line. That is catalog data, not a freeze. The local shelf uses written names. “Try again” after “No Courtauld match. The local shelf stays.” or “Search missed the catalog. The shelf is still here.”
- Tapping an Explore row that already shows “Saved” does not add another copy.
- Fair works leave the quiz. They appear under “Fair lately” and Saved. Undo the newest elide to put that work back on the line.
- “Fair lately” only keeps the six most recent filed works; Saved keeps the full Fair list.
- Saved Fair and Botches rows do not open a further screen.
- After “Reset all data”, the first pages may not cover Home again until you tap “Show the first pages” or quit and relaunch.
- Paintings can sit as a blank muted tile until the picture arrives.

## Starter content and resume
Explore’s local shelf, with no search typed, lists these six works (title then maker):

- “A Bar at the Folies Bergere” — “Edouard Manet”
- “Self Portrait with Bandaged Ear” — “Vincent van Gogh”
- “The Card Players” — “Paul Cezanne”
- “La Loge” — “Pierre Auguste Renoir”
- “Nevermore” — “Paul Gauguin”
- “Young Woman Powdering Herself” — “Georges Seurat”

They are not pre-saved into the quiz crate on a device. You save a row to sit the line. On Simulator only, a demo crate can already hold several of those works, a live doubled line, fair files, botches, and skipped first pages.

Unfinished work resumes: the crate, the live caption including cooled words, focused work, elides, botches, and whether the first pages were finished return after quit.

## Permissions
None. The app never asks for camera, photos, microphone, location, tracking, or notifications.

## Absent
Genuinely absent: login or accounts, in-app purchase, ads, analytics, user-generated content (you save catalog works and marks; you do not post or create public content), account deletion flow, App Tracking Transparency prompt.

## Data and support
Saved paintings, the live caption, and every mark stay on this device. Reset copy states that clearly. Typing in Explore looks up The Courtauld catalog; a miss still leaves the local shelf.

Support control: “Contact us” under Help in Settings. It opens the support page.

## Scanning and health
None. The app does not scan barcodes or QR codes. It does not show health, medical, or product-health information.

## Platform
English UI only; no in-app language or region switch. Elide and botch counts follow the device’s number grouping. Day numbers on Saved are eight-digit calendar dates for the device time zone. Search is by maker or title against English catalog titles.

Portrait only on iPhone and iPad, full screen, Light appearance. iPhone and iPad. Minimum iOS 17.0. On iPad with iOS 18, Settings uses a large page sheet so the reset sentence stays on screen.

## Category
Education
