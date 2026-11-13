# Panorama

Advanced graphics settings for World of Warcraft, in one panel.

Many graphics options are only available through `/console` commands. Panorama puts them in a
window of its own with sliders, checkboxes and dropdowns. It reapplies your values every time
you log in.

## Features

- **58 settings** grouped by theme: view distance, vegetation, shadows and lighting, environment,
  image, camera and interface, nameplates, advanced, floating combat text.
- **Your values are kept**: a value set with `/console` beyond a slider's range is kept and written
  again at login. The game itself limits what it accepts.
- **Safe on your client**: a setting that your client does not support is hidden and never
  written.
- **Starts from your current values**: on first install, the panel reads your current game
  settings. Nothing changes until you move a control.
- **Stays in sync**: a change made in the game's Graphics menu or with `/console` shows in the panel.
- **Reapply on login**: your values from the last session are written again at login, in case the
  game changed them between sessions (Config.wtf, automatic detection). You can turn it off.
- **Combat safe**: changes made during combat are applied when combat ends.
- **Graphics restart button**: it applies settings such as anti-aliasing without leaving the game.
- **Presets**: Low, Medium, High and Extra set every graphics setting at once. They do not change
  camera, mouse or comfort settings.
- **Default button on every line**: it puts that setting back to its default. Advanced settings,
  nameplate class colors, size, pets and totems, zoom speed, text size and combat text use the
  game's own default.
- **Black bars filter**: top and bottom black bars, from 0 to 20 % of the screen each, for a
  cinematic look. They change no CVar.

## Settings

| Section | Settings |
|---|---|
| View distance | Scenery distance, horizon distance, volumetric fog |
| Vegetation and details | Ground details, grass density, grass distance |
| Shadows and lighting | Shadow quality, soft shadows, shadow resolution, sun shafts, SSAO, screen space effects |
| Environment | Water detail, sky detail, weather intensity, physics |
| Image | MSAA, sharpening filter, sharpening strength, full-screen glow, death grey screen, violence level, projected textures, spell clutter |
| Camera, mouse and interface | Max camera distance, raw mouse input, screenshot quality, zoom speed, text size |
| Nameplates | Nameplate distance, enemy and friendly class colors, far, near and target nameplate size, enemy pets, enemy totems |

## Commands

| Command | Action |
|---|---|
| `/pano` | Open the settings panel |
| `/pano apply` | Reapply all settings |
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
  Russian, Korean, Simplified Chinese and Traditional Chinese. It follows the game client language.
- To undo every change, use the Defaults button in the game's Graphics menu. The black bars are
  not a game setting: set them to 0 in `/pano`.
- The black bars hide part of the world. The game still renders it, so they do not raise your
  frame rate.

Website: https://muscalab.com/addons/panorama

Discord: https://discord.gg/EyYpyMq2km

## License

GPL-3.0-or-later.
