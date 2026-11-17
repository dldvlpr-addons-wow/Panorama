# Panorama

Advanced graphics settings for World of Warcraft, in one panel.

Many graphics options are only available through `/console` commands. Panorama puts them in a
window of its own with sliders, checkboxes and buttons. It reapplies your values every time
you log in.

How to use it, and how to set up HDR on Windows: see [GUIDE.md](GUIDE.md), also in German,
Spanish, French, Italian, Portuguese, Russian, Korean and Chinese (`GUIDE.<language>.md`). The
Guide button in the panel opens the same guide in the game.

## Features

- **58 settings and 4 filters** grouped by theme: view distance, vegetation, shadows and lighting,
  environment, image, HDR, camera and interface, nameplates, advanced, floating combat text, filters.
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
- **Default button on every line**: it puts that setting back to its default. Advanced settings,
  nameplate class colors, pets and totems, zoom speed, text size and combat text use the
  game's own default.
- **Vignette, film grain and tint filters**: darkened screen edges, animated film grain, and a
  sepia, warm, cold, night, emerald or dusk tint with its own strength. They change no CVar.

## Settings

| Section | Settings |
|---|---|
| View distance | Scenery distance, volumetric fog and its quality |
| Vegetation and details | Grass density, grass distance |
| Shadows and lighting | Soft shadows, shadow resolution, sun shafts, ambient occlusion |
| Environment | Water detail, sky detail, weather intensity, physics |
| Image | Sharpening filter, sharpening reduction, low latency mode, full-screen glow, grey screen on death, violence level, projected textures, reduce spell effects |
| Camera, mouse and interface | Camera distance, raw mouse input, screenshot quality, zoom speed, text size |
| Nameplates | Nameplate distance, enemy and friendly class colors, enemy pets, enemy totems |
| Advanced | Water reflections, water ripples, terrain detail distance, building detail distance, creature detail distance, object detail scale, particle density, depth-based transparency |
| Floating combat text | Absorb shields, combat state, dodges/parries/misses, absorbed/blocked/resisted damage, healer names, buffs and debuffs, reactive abilities, resource gains, periodic resource gains, combo points, low mana and health, honor gains, reputation changes |
| Filters | Vignette, film grain, color tint, tint strength |

## Commands

| Command | Action |
|---|---|
| `/pano` | Open or close the settings panel |
| `/pano apply` | Write again the settings changed in Panorama |
| `/pano restart` | Restart the graphics engine |
| `/pano low`, `/pano medium`, `/pano high`, `/pano extra` | Apply a preset |
| `/pano undo` | Restore the settings from before the last preset |
| `/pano minimap` | Show or hide the minimap button |

The panel opens in its own window, which you can move and close with Escape. Options > AddOns >
Panorama has a button that opens it.

## Supported clients

WoW Forever 1.60.1 (interface 16001).

## Notes

- The in-game interface is available in English, French, German, Spanish, Italian, Portuguese,
  Russian, Korean, Simplified Chinese and Traditional Chinese. It follows the game client language
  by default; the selector right of the tabs picks another one and reloads the interface.
- A setting marked with a yellow star is also set by a game menu: hover the star to see which one.
  That menu does not read the value back, so it may show a level that no longer matches.
- The Defaults button in the game's Graphics menu resets only the settings that menu manages, and
  Panorama follows it. To reset the others, and the filters, use the Default button on each line
  in `/pano`.

Website: https://muscalab.com/addons/panorama

Discord: https://discord.gg/EyYpyMq2km

## License

GPL-3.0-or-later.
