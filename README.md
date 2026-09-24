# Panorama

Advanced graphics settings for World of Warcraft, in one panel.

Many graphics options are only available through `/console` commands. Panorama puts them in a
native settings panel with sliders, checkboxes and dropdowns. It reapplies your values every time
you log in.

## Features

- **28 settings** grouped by theme: view distance, vegetation, shadows and lighting, environment,
  image, camera and interface.
- **Safe values**: sliders stay inside the limits the game accepts. An out-of-range value in the
  saved file is brought back into range.
- **Works on every client**: a setting that your client does not support is hidden and never
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
- **Defaults button**: it restores the Panorama preset.

## Settings

| Section | Settings |
|---|---|
| View distance | Scenery distance, horizon distance, volumetric fog |
| Vegetation and details | Ground details, grass density, grass distance |
| Shadows and lighting | Shadow quality, soft shadows, shadow resolution, sun shafts, SSAO, screen space effects |
| Environment | Water detail, sky detail, weather intensity, physics |
| Image | MSAA, sharpening filter, sharpening strength, full-screen glow, death grey screen, violence level, projected textures, spell clutter |
| Camera, mouse and interface | Max camera distance, nameplate distance, raw mouse input, screenshot quality |

## Commands

| Command | Action |
|---|---|
| `/pano` | Open the settings panel |
| `/pano apply` | Reapply all settings |
| `/pano restart` | Restart the graphics engine |
| `/pano low`, `/pano medium`, `/pano high`, `/pano extra` | Apply a preset |

The panel is also available under Options > AddOns > Panorama.

## Supported clients

Classic Era, Anniversary, WoW Forever, TBC Classic, Wrath Classic, Cataclysm Classic,
Mists of Pandaria Classic and retail.

## Notes

- The in-game interface is available in English, French, German, Spanish, Italian, Portuguese,
  Russian, Korean, Simplified Chinese and Traditional Chinese. It follows the game client language.
- To undo every change, use the Defaults button in the game's Graphics menu.

## License

GPL-3.0-or-later.
