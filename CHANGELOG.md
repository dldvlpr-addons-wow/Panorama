# Changelog

## 1.9.1

### Changed
- **Default button and Reset all…**: a setting goes back to the value it had in the game before you
  first changed it in Panorama (the value of the game's hardware detection for the Graphics menu
  settings), no longer to a Panorama value (view distance 1300). A setting you never changed in
  Panorama already has the game's value: Default leaves it as it is. For settings changed before
  1.9.1, Panorama did not keep that value: they go back to the game's own default (view distance
  1000), or to Panorama's when the game gives none.
- **Reset all…**: when a setting was changed before 1.9.1, Reset all also asks the game to detect
  your computer again at the next launch. The chat message says to restart the game: the graphics
  settings then go back to the values the game picks for your computer, those you set in its
  Graphics menu included. The confirmation box says so.

## 1.9.0

Everything new since 1.8.2. The beta sections below give the details.

### New
- **New window**: four tabs, Image, HDR, Ambiance and My filters. Image gathers the former Quality,
  Interface and Advanced tabs; Advanced becomes the Experts section.
- **Simple and Advanced (next to the title)**: Simple shows the main settings of each tab. Advanced
  shows every setting by section, with the rules per place. A new install opens in Simple, an
  existing one in Advanced; your choice is kept.
- **Current look: bar**: the look on the world now, and who sets it: you, Day and night, or the
  place. Its button opens where to change it.
- **Options menu**: Language, Apply on every login, Minimap button and Reset all….
- **Undo and Redo (footer, `/pano undo`, `/pano redo`, minimap menu)**: your last 20 changes,
  presets and Reset all included, until `/reload`.
- **Mode (Ambiance tab)**: Fixed, Day and night or By place. The Filters tab is merged into Ambiance.
- **My filters tab**: build your own filters: color, tint strength, vignette, grain, contrast,
  brightness and gamma, with a live preview. Use one everywhere or for a place.
- **Day tint (Day and night mode)**: by day, a day tint replaces the base tint. Default: Warm at 25.
- **Graphics preset and Scenery distance by place**: they apply while you are there, whatever the
  mode. The **Here:** button next to the presets opens the rule of the place.
- **Rule menu**: a dungeon or raid can have its own rule, and every known zone is listed.
- **Contrast, Brightness, Gamma (Image section)**.
- **Macro commands**: `/pano blackbars 10`, `/pano grain 10`, `/pano vignette 10`, `off` to remove.

### Changed
- **Automatic ambiance** is now **By place**, **Automatic day and night** is now **Day and night**.
  By place replaces the base look (filter, tint, vignette, grain, sky).
- **Weather ambiance** follows your Weather effects setting in Panorama.
- **Defaults** for a new install: night sky strength 70, volcanic tint strength 15.
- **Window**: drop-down menus for named values, greyed lines say why, sections fold in Advanced.
- **Your settings, filters, rules and zones are kept.**

### Removed
- **Full-screen glow** (`ffxGlow`): no visible effect on WoW Forever. Use **Bloom intensity**.
- **Yellow star** next to a setting also set by a game menu: its help names that menu.

### Fixed
- The chat names a setting the game refused, rounded or capped, and reports reset filter settings.
- Unknown zones, missing loading events and logout errors are handled.

## 1.9.0-beta3

### New
- **Filter commands for macros**: `/pano blackbars 10`, `/pano grain 10` and `/pano vignette 10`
  set the filter of the Filters tab; `off` or `0` removes it. Black bars go from 0 to 20, grain
  and vignette from 0 to 100. Undo puts the previous value back. While Automatic ambiance or one
  of your filters sets the grain and vignette, the chat says so and the command changes nothing.

## 1.9.0-beta2

### New
- **Advanced settings (box at the top of the window)**: unticked, the window is one page with no
  tabs: presets, main quality settings, HDR output and peak brightness, contrast, brightness, camera
  zoom, filter, filter strength and ambiance mode. Ticked, every tab and every setting shows. New
  installs start unticked; if you already used Panorama, it starts ticked. The search always finds
  every setting.
- **Undo and Redo (buttons under the tabs, `/pano undo`, `/pano redo`, minimap menu)**: Undo
  cancels your last change: slider, box, preset, filter, ambiance or Reset all. Redo puts it back.
  The last 20 changes are kept until `/reload`.
- **Mode (Ambiance tab)**: one menu picks Off, Automatic day and night, or Automatic ambiance. It
  replaces the Automatic ambiance box and the Automatic day and night line. The day and night
  lines show only in that mode.

### Changed
- **Undo last preset** becomes **Undo**, under the tabs. **Reset all** can now be undone.

### Removed
- **Full-screen glow** (`ffxGlow`): it has no visible effect on WoW Forever, and with it off the
  bloom stayed. Use **Bloom intensity** (Image section) to lower the bloom.

## 1.9.0-beta1

### New
- **My filters tab**: build as many filters of your own as you want (New, Delete). Each has a name, a color set with Red,
  Green and Blue sliders, a tint strength, a vignette, a film grain, a contrast, a brightness and
  a gamma. You see the filter on the game while the tab is open.
- **My filter (Filters tab, and each place or zone of the Ambiance tab)**: uses one of your
  filters. It replaces the tint, the vignette and the grain, and applies its contrast, brightness
  and gamma while it is on; your own values come back after.
- **Contrast, Brightness, Gamma**: new settings in the Quality tab. Depending on the display mode,
  they may have no effect.
- **Day tint and Day tint strength (automatic day and night)**: by day, a day tint replaces the
  Filters tab tint, as the night tint does at night. Default: Warm at 25. If automatic day and
  night was already on, your day keeps the Filters tab tint and its strength.
- **Color tint and Tint strength (Filters tab)**: greyed while automatic day and night is on, as
  the day tint and the night tint replace them.
- **Graphics preset and Scenery distance by place (Ambiance tab)**: each place and each zone gets a
  Graphics preset line and a Scenery distance line, at the top of its settings. They apply while
  you are there, over your own settings, which come back when you leave. They work with the
  automatic ambiance on or off. Default: My settings (nothing changes).
- **By place button (Quality tab)**: it opens these lines for the place you are in. It reads
  "Here: …" while a place applies its own. The Quality lines keep showing your own settings.
- **Dungeons and raids (Ambiance tab)**: inside one, the first choice of the context menu sets
  that dungeon alone.
- **All zones (Ambiance tab)**: the context menu lists every known zone, sorted by continent. A
  zone can be set without being there.

### Changed
- **Weather ambiance**: it now follows your Weather effects setting in Panorama, not the game value a
  place preset may lower.
- **Night sky strength (automatic ambiance)**: the default goes from 45 to 70.
- **Volcanic tint strength (automatic ambiance)**: the default goes from 30 to 15. The volcanic
  tint stays None.
- **Options window**: a setting with named values (My filter, Sky, Low latency, Contrast…) is now
  a drop-down menu. A greyed line says why it is greyed. Help text gets 3 lines and is brighter.
  The active preset has a gold border, Reset all is red text, and the scroll bar hides when
  nothing scrolls.
- **Tabs**: they come in two groups, with a gap between them: game settings first (Quality,
  Interface, Advanced), then Panorama effects (Filters, My filters, Ambiance).
- **Ambiance tab**: the editor now opens on the place you are in (first opening of the session), not on Day, so My filter and
  the tint of that place are shown at once.

For both default changes above, the new default is for a new install, the Default button and Reset all. If Panorama is
already installed, your current values are kept.

### Fixed
- **Ambiance tab**: the context editor rows now sit under a collapsible "Automatic ambiance" title,
  like the Day and night section.
- **Settings kept by the game**: when the game keeps another value than the one you chose
  (refused, rounded or capped), the chat names the setting. A preset or Reset all gives one line.
- **Invalid saved filter settings**: they are reset, and the chat says how many at login.
- **/pano minimap**: the chat says whether the button is now shown or hidden.
- **Unknown zone**: its name reads "Unknown zone (number)", not the number alone. `/pano status`
  shows "?" for a setting it cannot read, not "nil", and names the events this client does not send.
- **Zone kept forever**: if the game gives no map for more than 5 minutes, Panorama forgets the
  last zone and uses Temperate.
- **Settings not loaded**: if the game never sends its loading events, Panorama finishes loading
  after 30 seconds.
- **Settings window**: it refreshes once, not twice, when it opens or a place applies.
- **Logout**: an error while writing your settings back is reported, and they are written back at
  the next login.

## 1.8.2

### New
- **Bloom intensity (Image section)**: the strength of the glow around lights and bright areas
  (`bloomUserMult`), from 0 to 1. It is the setting behind the game's own bloom slider. The
  "Full-screen glow" checkbox does not change this bloom.

### Changed
- **Night tint strength (automatic day and night)**: the default goes from 50 to 90, for a new
  install, the Default button of the line and Reset all. If Panorama is already installed, your
  current value is kept.

## 1.8.1

### Removed
- **Nameplates section**: class colors (enemy and friendly), nameplate distance, enemy pets and
  enemy totems.
- **Text size** (Interface tab).
- **Floating combat text section**: its 13 options.

Panorama rewrote these settings at every login once changed, over the addons that manage nameplates,
text or combat text. The value you had stays in the game; Panorama no longer writes it. Class colors
are in the game's Options > Nameplates > Class Colors.

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
- **Anti-aliasing mentions removed** from the preset message and the restart tooltip: the setting
  does not exist on WoW Forever.
- **Tint tooltip** lists all six tints.
- **Lighter login**: a setting that already has the right value is no longer written again.
- **Unknown `/pano` command** message now lists `apply` and `restart`.
- **Sharpening reduction**: the ResampleSharpness label said the opposite of what it does.
  0 gives the strongest sharpening, 2 the weakest.

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
- **Camera**: mouse wheel zoom speed. It is written only after you change it, like the advanced
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
