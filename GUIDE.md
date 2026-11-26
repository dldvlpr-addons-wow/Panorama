# Panorama guide

How to use Panorama on WoW Forever, and how to set up HDR on Windows.

Other languages: [Deutsch](GUIDE.deDE.md) · [Español](GUIDE.esES.md) · [Français](GUIDE.frFR.md) · [Italiano](GUIDE.itIT.md) · [Português](GUIDE.ptBR.md) · [Русский](GUIDE.ruRU.md) · [한국어](GUIDE.koKR.md) · [简体中文](GUIDE.zhCN.md) · [繁體中文](GUIDE.zhTW.md)

**Back up your settings first.** Panorama changes game settings, and removing the addon does not change them back. Before you change anything, quit the game and copy the `WTF` folder of your game install somewhere safe. To go back, quit the game and put that copy back in place.

## 1. Open the window

- Type `/pano`, or left click the Panorama button on the minimap.
- Options > AddOns > Panorama also has a button that opens it.
- Drag the title bar to move the window. Escape or the close button closes it.

The minimap button:

- Left click opens or closes the window.
- Right click shows the presets, undo, redo and graphics restart.
- Drag it to move it around the minimap. `/pano minimap` shows or hides it.

## 2. The window

| Part | What it does |
|---|---|
| **Simple**, **Advanced** (next to the title) | Simple: each tab shows a short list of the main settings, without sections. Advanced: every setting, by section, with the rules per place and the Experts section. On first install it is Simple; if you already used Panorama, it is Advanced. The search always finds every setting. |
| Guide (top right) | Opens this guide in the game. |
| **Options** menu (top right) | **Language** (game language or one of ten languages; changing it reloads the interface), **Apply on every login**, **Minimap button**, **Reset all…**. |
| **Current look:** (bar under the title) | The look on the world now, and who sets it: you, Day and night, or the place. Its button (**Edit**, **Edit this rule**) opens where to change it. Hover the bar to see which one comes first. |
| Tabs | **Image** (graphics quality), **HDR**, **Ambiance** (look of the world), **My filters**. The open tab is remembered. |
| Search box (right of the tabs) | Type a word to list the matching settings of every tab. Clear it to go back. |
| Presets (Image tab) | Low, Medium, High, Extra. The preset that matches your settings is highlighted. |
| Footer | **Undo** cancels your last change: slider, box, preset, filter, ambiance or Reset all. **Redo** puts it back. The last 20 changes are kept until `/reload`. **Restart** restarts the graphics engine. |

In Advanced mode, click a section title to fold or unfold it. The **Experts (console only)** section starts
folded. A section title shows how many of its settings you changed.

### A setting line

- **Slider**: the value is written when you release the mouse button, not while you drag.
- **Value box** next to the slider: type a value, then press Enter or click elsewhere. Escape cancels,
  Tab goes to the next box. A comma works as decimal point. The value is kept within the slider's range.
- **Default button**: puts that setting back to its default value. Hover it to see the value.
- **Gold mark** on the left: you changed this setting.
- **Game menu**: when a game menu also sets this value, the help of the label names it. That menu does not
  read the value back, so it may show another level.
- **Greyed line**: it depends on another setting that is off (for example **Volumetric fog quality**
  without **Volumetric fog**, tint strength without a tint), or a mode sets it. Hover the label to see why.
  A line that depends on another one is shifted to the right, just under it.
- Hover a label to read its full help.

## 3. Presets

| Preset | Result |
|---|---|
| Low | Best performance. Short view distance, no shadows. |
| Medium | Balanced. Good performance with decent shadows. |
| High | The game's High level. Full shadows, all effects. |
| Extra | High, with the longest view distance. |

Presets change only the graphics quality settings of the Image tab. They do not touch camera,
mouse, interface, sharpening, low latency, HDR or filters.

Changed your mind? **Undo** (footer, or `/pano undo`) restores the settings from
before the preset.

## 4. Ambiance

The Ambiance tab sets the look of the world: effects on top of the image. They change no game setting.

- **Mode** (top of the tab): **Fixed** (the same filter everywhere), **Day and night** (a day tint and a
  night tint) or **By place** (see below). Fixed by default.
- **Here**: the place and the time of day detected now. When a dungeon, indoors or the weather comes
  before a zone you set, it says so.
- **Filter** (Fixed and Day and night modes): **Base** uses the lines below. One of your filters
  (My filters tab) replaces the tint, the vignette and the film grain, and brings its contrast,
  brightness and gamma. **Edit filter** opens it in the My filters tab.
- **Color tint**: click a thumbnail to apply it right away (sepia, warm, cold, night, emerald, dusk).
  **Tint strength** sets how strong it is.
- **Vignette**: darkens the edges of the screen.
- **Film grain**: animated grain.
- **Day tint** and **Night tint** (Day and night mode): Panorama lays the day tint by day and the night
  tint at night, following the game's day and night. They replace the color tint. The change is gradual
  from 19:00 to 21:00 and from 5:00 to 7:00 (server time). One of your filters chosen on the Filter line
  replaces them.
- **Sky**: the same colors as a gradient, full at the top of the screen and lighter at the bottom.
  **Sky strength** sets how strong it is.
- **Black bars**: top and bottom bars, 0 to 20 % of the screen each, in every mode. The game still renders
  what they hide, so they do not raise the frame rate.

In Simple mode, the tab shows the mode, the place, the filter, the color tint and its strength, and the
day and night tints. Vignette, film grain, sky and black bars are in Advanced mode.

### By place

In **By place** mode, the tint, sky, vignette and grain change on their own, to fit where you are.

- The lines of the Fixed mode are hidden: the rule of the place replaces them. Only the black bars stay.
  Their values stay saved and come back when you change the mode.
  In Simple mode, the shipped rules apply; choose Advanced to edit them.
- **Place**: sets the tint, vignette and grain. Order: dungeon or raid, indoors, weather (rain, snow,
  sandstorm), then the kind of zone: temperate, desert, snowy, jungle and marsh, corrupted, volcanic,
  arcane forest. A zone not known yet counts as temperate. Weather counts only when Weather
  intensity is above 0.
- **Time of day**: sets the sky (day, dawn and dusk, night). Night follows the game's day and
  night; dawn and dusk follow the server time. No sky indoors or in a dungeon.
- **Rule** (Advanced mode): pick a rule, then set it below. The Default button gives back the
  value shipped for that rule. The first time the window opens in a session, the rule of the place you are in is open.
  The menu has five groups: **Zones** (the zone you are in and the zones you set), **Dungeon and indoors**, **Weather**, **Zone type** and **Sky (time of day)**.
  The first four set tint, vignette, grain and a graphics preset: one place applies at a time, in the order given above.
  The last one sets the sky. Nothing to set to get started: every rule already has its values.
- **This zone**: first choice of the same menu, with the name of the zone you are in. Pick it to give
  this zone its own tint, vignette and grain, starting from its kind of zone. It then comes before
  the kind of zone, but after dungeon, indoors and weather. Zones you set stay in the menu.
  **Back to zone type** (next to the menu) removes the values of the zone: it follows its kind of zone again.
- **All zones**: submenu of the same menu, with every known zone. Pick one to set it without being there. Zones are sorted by continent.
- **Graphics preset** and **Scenery distance** (section **Image** of a place or a zone): they apply while you are in that place, over your own settings, whatever the ambiance mode. The scenery distance of the place comes before the one of the preset. Your own settings are kept and come back when you leave. **My settings** changes nothing. Example: Low in dungeons, Extra in a zone you like. In a dungeon or raid, the first choice of the menu sets that dungeon alone. In the Image tab, **Here: …** shows next to the presets while a place applies its own; in Advanced mode, it opens that rule. In combat, the change waits for the end of the fight.
- **Filter** (first line of section **Look** of a place or a zone): this place uses one of your filters from the My filters tab, with its contrast, brightness and gamma. **Settings below**: the tint, vignette and grain of the rule. The Look section applies only in By place mode.

## 5. My filters

The My filters tab lets you create as many filters of your own as you want. The open filter shows on the world only as a preview; the filter that applies is chosen in the Ambiance tab. **New** adds one and opens it, **Delete** removes the open one: the Ambiance tab filter and the rules that used it go back to no filter. One filter always remains.

- **Filter**: picks the filter that the lines below set. **Name**: give it a name (Enter to confirm).
- **Color tint**: click a thumbnail to give the filter that color. **Red**, **Green**, **Blue** (in %): its exact color. **Tint strength**: how strong it is.
- **Vignette** and **Film grain**: those of the filter.
- **Contrast**, **Brightness**, **Gamma**: image settings the filter gives the game while it is applied; your own values come back afterwards. My settings: nothing changes. Depending on the display mode, they may have no effect.
- In Simple mode, the tab shows only the color tint and the tint strength.
- While the tab is open, the filter shown is visible live on the game. The **Current look:** bar says when it is only a preview.
- To use a filter: pick it on the **Filter** line of the Ambiance tab (Fixed and Day and night modes), or of a place or a zone (By place mode). It then replaces the tint, the vignette and the film grain. **Base** or **Settings below**: nothing changes.

## 6. Your values and the game

- On first install, Panorama reads your current game settings. Nothing changes until you move a control.
- A change made in the game's Graphics menu or with `/console` shows in the window.
- **Apply on every login** (Options menu, on by default): the settings you changed in Panorama are written again
  at each login. The others follow the game's Graphics menu.
- A change made during combat is applied when combat ends.
- Some settings, such as MSAA, need a graphics restart. Click **Restart** in the footer, or type
  `/pano restart`. The screen flickers for a second.

## 7. HDR on Windows

HDR settings exist only as console commands in the game. Panorama shows them in the **HDR** tab.
You need a monitor that supports HDR.

### Step 1: turn on HDR in Windows

Windows 11:

1. Open **Settings > System > Display**.
2. Select the HDR monitor if you have more than one.
3. Turn on **Use HDR**. The shortcut **Win + Alt + B** also turns it on or off.

Windows 10: **Settings > System > Display > Windows HD Color settings**, then turn on
**Play HDR games and apps**.

Also check that HDR is on in the monitor's own menu, if it has such an option.

Turn off **Auto HDR** in Windows 11: **Settings > System > Display > HDR**. Auto HDR is meant for games without HDR. WoW makes its own HDR image.

### Step 2: find the peak brightness of your monitor

Install the free **Windows HDR Calibration** app from the Microsoft Store and run it. The maximum
luminance it finds is the peak brightness of your monitor, in nits.

Without the app, use the monitor's HDR rating: DisplayHDR 400 means about 400 nits, DisplayHDR 600
about 600, DisplayHDR 1000 about 1000.

### Step 3: set HDR in Panorama

Open `/pano`, tab **HDR**. In Simple mode, the tab shows only the first three lines below: choose
**Advanced** to see **HDR intensity** and the reference brightness.

1. Check **HDR output**.
2. Check **Use peak brightness** or **Use reference brightness**: one of the two, never both. Without one, the image goes dark.

**Peak brightness mode (recommended)**

- Check **Use peak brightness**.
- Set **Peak brightness (nits)** to the value found in step 2.
- **HDR intensity** works only in this mode. The game's default is 2. Change it in small steps and
  compare: Blizzard does not document its exact effect.

**Reference brightness mode**

- Check **Use reference brightness**.
- **Reference brightness (nits)** is the brightness of white in the scene. 203 is the standard value.
  Raise it if the image looks too dark in a bright room. HDR intensity has no effect in this mode.

If the image does not change, click **Restart** in the footer.

### HDR troubleshooting

| Problem | Fix |
|---|---|
| Image very dark | Check one of the two brightness modes. |
| Image grey or washed out | Turn on HDR in Windows (step 1) and in the monitor's menu. |
| Auto HDR on in Windows | Turn it off (step 1). |
| Highlights too bright or flat | Set the peak brightness to the real value of your monitor (step 2). |
| You want HDR off | Uncheck **HDR output**. |

Each HDR line has a Default button that puts back the game's value.

## 8. Commands

| Command | Action |
|---|---|
| `/pano` | Open or close the window |
| `/pano low`, `/pano medium`, `/pano high`, `/pano extra` | Apply a preset |
| `/pano undo` | Cancel the last change |
| `/pano redo` | Put back the change you just undid |
| `/pano reset` | Put every setting and filter back to its default |
| `/pano status` | Show in the chat the place and time of day detected and the filters applied now (during a fade, the values it goes to) |
| `/pano apply` | Write again the settings changed in Panorama |
| `/pano restart` | Restart the graphics engine |
| `/pano minimap` | Show or hide the minimap button |
| `/pano blackbars 10` | Black bars at 10% of the screen height (0 to 20). `off` removes them |
| `/pano grain 10` | Film grain at 10 (0 to 100). `off` removes it |
| `/pano vignette 10` | Vignette at 10 (0 to 100). `off` removes it |

## 9. Reset

- The **Default** button on each line resets that setting.
- The **Defaults** button of the game's Graphics menu resets only the settings that menu manages,
  and Panorama follows it. Use the Default buttons in `/pano` for the others and for the filters.
- **Reset all…** (Options menu, with confirmation) or `/pano reset`: puts every setting in the window,
  changed in Panorama or not, and every filter back to its default. **Undo** cancels it until `/reload`.
  The Ambiance tab and the zones you set are reset too. Your filters in the My filters tab are erased too.
