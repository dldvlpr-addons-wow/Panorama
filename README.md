# Panorama

Advanced graphics settings for World of Warcraft, in one panel.

Many graphics options are only available through `/console` commands. Panorama puts them in a
window of its own with sliders, checkboxes and buttons. It reapplies your values every time
you log in.

**Back up your settings first.** Panorama changes game settings, and removing the addon does not
change them back. Before you install it, quit the game and copy the `WTF` folder of your game
install somewhere safe. To go back, quit the game and put that copy back in place.

How to use it, and how to set up HDR on Windows: see [GUIDE.md](GUIDE.md), also in German,
Spanish, French, Italian, Portuguese, Russian, Korean and Chinese (`GUIDE.<language>.md`). The
Guide button in the panel opens the same guide in the game.

## Features

- **46 settings and 13 filters** in four tabs: Image (view distance, vegetation, shadows and
  lighting, environment, image, camera, mouse and interface, experts), HDR, Ambiance (filters and ambiance
  modes) and My filters.
- **Your values are kept**: a value set with `/console` beyond a slider's range is kept. The game
  itself limits what it accepts.
- **Safe on your client**: a setting that your client does not support is hidden and never
  written.
- **Starts from your current values**: on first install, the panel reads your current game
  settings. Nothing changes until you move a control, except water detail above 2, lowered to 2
  (level 3 crashes the game).
- **Stays in sync**: a change made in the game's Graphics menu or with `/console` shows in the panel.
- **Reapply on login**: the settings you changed in Panorama are written again at login, in case the
  game changed them between sessions (Config.wtf, automatic detection). The others follow the game's
  Graphics menu. You can turn it off.
- **Combat safe**: changes made during combat are applied when combat ends.
- **Graphics restart button**: it restarts the graphics engine without leaving the game.
- **Presets**: Low, Medium, High and Extra set the main graphics settings at once. They do not change
  camera, mouse, comfort, sharpening or low latency settings.
- **Default button on every line**: it puts that setting back to the value it had in the game
  before you first changed it in Panorama. Settings changed before version 1.9.1 go back to the
  game's own default. For those, Reset all… in the Options menu asks the game to detect your
  computer again: restart the game and it sets the graphics settings for your computer.
- **Black bars filter**: top and bottom black bars, from 0 to 20 % of the screen each, for a
  cinematic look. They change no CVar.
- **Vignette, film grain and tint filters**: darkened screen edges, animated film grain, and a
  sepia, warm, cold, night, emerald or dusk tint, with its
  own strength. They change no CVar.
- **My filters** (its own tab): build as many filters of your own as you want, each with a name, a color set
  with Red, Green and Blue sliders, a tint strength, a vignette, a film grain, a contrast, a
  brightness and a gamma. You see the filter on the game while you set it. Use it everywhere from
  the Filter line of the Ambiance tab, or for a place or a zone in By place mode.
- **Ambiance modes** (Mode menu of the Ambiance tab): **Fixed** (default) applies the same filter
  everywhere: Base (the tint, vignette and grain of the tab) or one of your filters. **Day and
  night** lays a day tint by day and a night tint at night (game's day and night), each with its
  own strength, in place of the tint. The change is gradual from 19:00 to 21:00 and from 5:00 to
  7:00 (server time). **By place**: see below.
- **Sky filter**: a color gradient from the top of the screen, with the tint colors.
- **By place** mode: tint, vignette and grain follow the place (dungeon,
  indoors, rain, snow, sandstorm, then the kind of zone: temperate, desert, snowy, jungle, corrupted,
  volcanic, arcane); the sky follows the time of day (day, dawn and dusk, night). Each context has
  its own values, editable in the Ambiance tab in Advanced mode, and any zone can get its own values,
  picked from the list of all zones. A place or a zone can also apply a graphics preset (Low, Medium,
  High, Extra) or a scenery distance while you are there, whatever the ambiance mode; your own
  settings come back when you leave. The values of the Fixed mode stay saved.

## Settings

| Tab | Section | Settings |
|---|---|---|
| Image | View distance | Scenery distance, volumetric fog and its quality |
| Image | Vegetation and details | Grass density, grass distance |
| Image | Shadows and lighting | Soft shadows, shadow resolution, sun shafts, ambient occlusion |
| Image | Environment | Water detail, sky detail, weather intensity, physics |
| Image | Image | Sharpening filter, sharpening reduction, low latency mode, bloom intensity, grey screen on death, violence level, projected textures, reduce spell effects, contrast, brightness, gamma |
| Image | Camera, mouse and interface | Camera distance, raw mouse input, screenshot quality, zoom speed |
| Image | Experts (console only) | Water reflections, water ripples, terrain detail distance, building detail distance, creature detail distance, object detail scale, small object culling, object fade distance, horizon start, grass fade distance, particle density, depth-based transparency |
| HDR | HDR output | HDR output, use peak brightness, peak brightness, HDR intensity, use reference brightness, reference brightness |
| Ambiance | Top of the tab | Mode (Fixed, Day and night, By place); filter (Base or one of your filters) |
| Ambiance | Day and night | Day tint, day tint strength, night tint, night tint strength |
| Ambiance | Filter settings | Color tint, tint strength, vignette, film grain |
| Ambiance | Sky and black bars | Sky, sky strength, black bars |
| Ambiance | Image (rules, Advanced mode) | Graphics preset and scenery distance for each place or zone, whatever the mode |
| Ambiance | Look (rules, Advanced mode, By place) | Filter, tint, tint strength, vignette, film grain for each place or zone; sky and sky strength for each time of day |
| My filters | | For each of your filters: name, red, green, blue, tint strength, vignette, film grain, contrast, brightness, gamma |

## Commands

| Command | Action |
|---|---|
| `/pano` | Open or close the settings panel |
| `/pano apply` | Write again the settings changed in Panorama |
| `/pano restart` | Restart the graphics engine |
| `/pano low`, `/pano medium`, `/pano high`, `/pano extra` | Apply a preset |
| `/pano undo` | Cancel the last change |
| `/pano redo` | Put back the change you just undid |
| `/pano reset` | Put every setting and filter back to its default |
| `/pano status` | Show in the chat the place and time of day detected and the filters applied now (during a fade, the values it goes to) |
| `/pano minimap` | Show or hide the minimap button |
| `/pano blackbars 10` | Black bars at 10% of the screen height (0 to 20). `off` removes them |
| `/pano grain 10` | Film grain at 10 (0 to 100). `off` removes it |
| `/pano vignette 10` | Vignette at 10 (0 to 100). `off` removes it |

The panel opens in its own window, which you can move and close with Escape. Options > AddOns >
Panorama has a button that opens it.

## Supported clients

WoW Forever 1.60.1 (interface 16001).

## Notes

- The in-game interface is available in English, French, German, Spanish, Italian, Portuguese,
  Russian, Korean, Simplified Chinese and Traditional Chinese. It follows the game client language
  by default; Language, in the Options menu, picks another one and reloads the interface.
- When a game menu also sets a setting, the help of its label names that menu. That menu does not
  read the value back, so it may show a level that no longer matches.
- The Defaults button in the game's Graphics menu resets only the settings that menu manages, and
  Panorama follows it. To reset the others, and the filters, use the Default button on each line
  in `/pano`, or Reset all… in the Options menu for everything at once, the Ambiance tab and the
  zones you set included.
- The black bars hide part of the world. The game still renders it, so they do not raise your
  frame rate.

Website: https://muscalab.com/addons/panorama

Discord: https://discord.gg/EyYpyMq2km

## License

GPL-3.0-or-later.
