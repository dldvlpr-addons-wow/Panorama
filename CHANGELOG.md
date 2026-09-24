# Changelog

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
