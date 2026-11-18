# Changelog

## 1.8.0

### New
- **Sky filter (Filters tab)**: a color gradient from the top of the screen, with the tint colors
  and its own strength.
- **Automatic ambiance (Ambiance tab)**: off by default. When on, tint, vignette and film grain
  follow the place: dungeon or raid, indoors, rain, snow, sandstorm, then the kind of zone
  (temperate, desert, snowy, jungle and marsh, corrupted, volcanic, arcane forest). The sky follows
  the time of day: day, dawn and dusk, night, outdoors only. The tab shows the place and time
  detected now and lets you edit the values of each context. When the place changes, the filters
  fade to the new values over 1.5 seconds; when the time of day changes, over 60 seconds. Your
  Filters tab values stay saved, and their lines are greyed out while the automatic ambiance is on.
  The black bars are not part of it: they stay as set in the Filters tab.
- **Automatic day and night (Ambiance tab)**: off by default. At night (game's day and night), the night tint
  replaces the tint, with its own strength. It does not work together with the automatic ambiance: turning one
  on turns the other off. The change is gradual from 19:00 to 21:00 and from 5:00 to 7:00.
- **Per-zone ambiance**: "This zone" in the Ambiance tab menu gives the zone you are in its own tint,
  vignette and grain. "Zone type" removes them.
- **Four distance settings (Advanced tab)**: small object culling (`lodObjectCullSize`), object
  fade distance (`lodObjectFadeScale`), horizon start (`horizonStart`) and grass fade distance
  (`groundEffectFade`). Like the other advanced settings, they are written only after you change
  them.
- **`/pano status`** prints in the chat the place and time of day detected and the filter values
  applied right now, to check that the automatic ambiance and the automatic day and night work.
- **Reset all** also turns the automatic ambiance off, puts each context back to its shipped
  values and removes the values of the zones you set.

### Fixed
- **Guide button** moved left of the search box: the Advanced tab no longer covers it.
- **Physics tooltip** now says the setting needs a game restart, like the game's own menu.
- **`/pano apply`** now shows in the window the value the game really applies, when it refuses or
  rounds one.
- **A game value outside the listed choices** (for example a shadow texture size set with
  `/console`) is kept, with no choice checked, instead of being shown as the default.

## 1.7.4

### New
- **Reset all** button, next to Restart at the bottom of the window, and `/pano reset`: every setting
  changed in Panorama and every filter go back to their default, and those settings follow the
  game's menus again. The button
  asks for confirmation; a reset cannot be undone.

### Restored
- **Black bars filter**, removed in 1.7.3, is back in the Filters tab.

## 1.7.3

### Removed
- **Black bars filter.** The top and bottom black bars are gone from the Filters tab. A saved
  value is cleared at login.

## 1.7.2

### Fixed
- **View distance (`farclip`) slider goes up to 10000.** A view distance set above 7000 with
  `/console` showed in Panorama, but the slider and the input box could not go back above 7000.
  The Extra preset stays at 7000.

## 1.7.1

### Fixed
- **Settings changed in Panorama no longer reset at login or `/reload`.** The game could load
  its own values after Panorama had applied yours, and Panorama then saved them over your
  choice. Panorama now waits until loading is done (a few seconds after login), then writes your
  settings again and only then starts following changes made in the game's menu.
- **The window shows what the game really applies.** When the game refuses or rounds a value,
  the slider now moves back to the game's value instead of showing one that is not in effect.

## 1.7.0

### New
- **HDR section (Advanced tab)**: HDR output, peak brightness or reference brightness, and HDR
  intensity. These settings exist only as console commands in the game. Turn on one of the two
  brightness modes, or the image goes dark. HDR intensity works only with peak brightness.
  Your system and monitor must have HDR on. Turn off Auto HDR in Windows.
- **Language selector**: right of the tabs. Pick the game language or any of the ten languages
  of Panorama. Changing it reloads the interface.
- **In-game guide**: the Guide button, left of the language selector, opens the user guide in a
  window of its own, in the language of Panorama.

### Changed
- **New window layout**: four tabs (Quality, Filters, Interface, Advanced). Presets sit on the
  Quality tab, and the preset that matches your current settings is highlighted. Search looks
  through every tab. Sections open unfolded; the open tab is remembered.
- **Type a value**: each slider has a box next to it. Enter or clicking away applies the value,
  Escape cancels, Tab moves to the next box. A comma works as decimal point; values are kept
  within the slider's range.
- **Tint thumbnails**: the tint is picked from seven thumbnails that show its colour. A click
  applies it right away.
- **Each setting has its own Default button**, and a gold mark shows the settings you changed.
- **Settings that depend on another one are greyed out** while it is off: fog density without
  volumetric fog, tint strength without a tint, HDR brightness values without their switch.

## 1.6.0

### New
- **Filters section, black bars**: top and bottom black bars, from 0 to 20 % of the screen each,
  for a cinematic look. They write no CVar.
  They hide part of the world but do not raise the frame rate.
- **Filters section, vignette, film grain and tint**: darkened screen edges, animated film grain,
  and a sepia, warm, cold, night, emerald or dusk tint with its own strength. They write no CVar.
- **Image section, low latency mode**: Auto, Off, Built-in, Reflex, Reflex + Boost or XeLL.
  Presets do not change it.

### Changed
- **Settings also set by a game menu are marked** with a yellow star. Hover it to see which menu:
  that menu does not read the value back and may show another level.
- **Reapply on login writes only the settings you changed in Panorama.** The others follow the
  game's Graphics menu, so a change made there is no longer undone at the next login. A saved value
  that differs from the game's is kept as changed when you update.
- **Presets match the game's Graphics menu.** Low, Medium and High now set the same values as
  the game's Low, Medium and High levels. Extra is High with the view distance at 7000.
- **Sliders write the setting when you release the mouse button**, not at every step. Dragging
  view distance no longer reloads the scenery hundreds of times.
- **Easier to read window**: the line under the mouse is highlighted, and a thin line separates
  each setting and each section.

### Fixed
- **Water detail cap at 2 always applies**: on first install, with reapply on login turned off,
  and when the game's menu or `/console` sets 3.
- **Undo during combat** is now written when combat ends.
- **Floating combat text changed during combat** now shows when combat ends, without a `/reload`.
- **Anti-aliasing mentions removed** from the preset message and the restart tooltip: the setting
  does not exist on WoW Forever.
- **Tint tooltip** lists all six tints.
- **Lighter login**: a setting that already has the right value is no longer written again.
- **Unknown `/pano` command** message now lists `apply` and `restart`.
- **Sharpening reduction**: the ResampleSharpness label said the opposite of what it does.
  0 gives the strongest sharpening, 2 the weakest.
- **Nameplate scale sliders removed**: far, near and target nameplate size are fixed at 1 on
  WoW Forever and ignored any value.

## 1.5.0

### New
- **Search bar** in the Panorama window: type a word to show only the matching settings.
- **Volumetric fog quality** (0 to 3) in the View section. Presets set 0, 1, 3 and 3.

## 1.4.1

### Fixed
- **Water detail is capped at 2.** Level 3 crashes the game when entering the Ruins of Lordaeron.
  The Extra preset now sets 2, and a saved value of 3 is lowered to 2 at login.

## 1.4.0

### New
- **Nameplates section**: enemy and friendly class colors, far, near and target nameplate size,
  enemy pets and enemy totems. Nameplate distance moves here.
- **Camera**: mouse wheel zoom speed and interface text size.
- **Floating combat text**: absorb shields placed on you.
- The new nameplate and camera settings are written only after you change them, like the advanced
  settings.

### Fixed
- **Values set with `/console` are kept.** A value beyond the slider range (for example
  `cameraDistanceMaxZoomFactor 4` or `farclip 7000`) is no longer reset at login or `/reload`.
- **Wider sliders**: max camera distance goes up to 4, view distance (`farclip`) up to 7000.

## 1.3.1

### Changed
- **Minimap button** is now round with the gold ring, like the other minimap buttons.

## 1.3.0

### New
- **Own window**: the panel now opens in its own window instead of the game's Options. Drag it to
  move it, close it with Escape or the close button. `/pano` and a left click on the minimap button
  open or close it. Options > AddOns > Panorama keeps a button that opens the window.
- **Minimap button** with the Panorama logo: left click opens the panel, right click shows
  presets, undo and graphics restart, drag moves it. `/pano minimap` shows or hides it.
- **Advanced section**: 8 graphics settings that only exist as console variables
  (`reflectionMode`, `rippleDetail`, `terrainLodDist`, `wmoLodDist`, `entityLodDist`,
  `doodadLodScale`, `particleMTDensity`, `DepthBasedOpacity`). They are written only after you
  change them.
- **Floating combat text**: 12 options for what the combat text shows.
- **Undo**: `/pano undo` or the panel button restores the settings from before the last preset.
- **Redesigned panel**: preset cards, collapsible sections, default button per setting.

## 1.2.0 (changes since 1.0.0)

### New
- **Translations**: the interface follows the game client language. Available in English, French,
  German, Spanish (EU and Latin America), Italian, Portuguese, Russian, Korean, Simplified Chinese
  and Traditional Chinese. English is the fallback for any other language.
- **Presets**: Low, Medium, High and Extra set every graphics setting at once, from the panel or
  with `/pano low`, `/pano medium`, `/pano high` and `/pano extra`. They do not change camera,
  mouse or comfort settings.
- **Stays in sync**: a change made in the game's Graphics menu or with `/console` now shows in the
  panel.

### Changed
- **Starts from your current values**: on first install, Panorama reads your current game settings
  instead of applying its own maximum values. Nothing changes until you move a control.
- **Reapply on login**: turned off, Panorama now reads the game values at login instead of keeping
  outdated ones.
- `/pano apply` during combat now says the settings will be applied when combat ends.
- An unknown `/pano` command now lists the available presets.
- Horizon distance slider moves in steps of 8 instead of 16.

### Fixed
- Volumetric fog tooltip: checking it replaces the classic distance fog, which hides far scenery
  less. The old tooltip said the opposite.

### Removed
- "Show Lua errors" setting (`scriptErrors`): it is not a graphics setting.

### Package
- The license file is now included in the download.
