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
- Right click shows the presets, undo and graphics restart.
- Drag it to move it around the minimap. `/pano minimap` shows or hides it.

## 2. The window

| Part | What it does |
|---|---|
| Search box (top right) | Type a word to list the matching settings of every tab. Clear it to go back. |
| Tabs | Quality, Interface, Advanced (game settings), then Filters, My filters, Ambiance (Panorama effects). The open tab is remembered. |
| Language selector (right of the tabs) | Game language or one of ten languages. Changing it reloads the interface. |
| Guide (left of the search box) | Opens this guide in the game. |
| Presets (Quality tab) | Low, Medium, High, Extra. The preset that matches your settings is highlighted. |
| Footer | Apply on every login, minimap button, Reset all, graphics engine restart. |

Click a section title to fold or unfold it.

### A setting line

- **Slider**: the value is written when you release the mouse button, not while you drag.
- **Value box** next to the slider: type a value, then press Enter or click elsewhere. Escape cancels,
  Tab goes to the next box. A comma works as decimal point. The value is kept within the slider's range.
- **Default button**: puts that setting back to its default value. Hover it to see the value.
- **Gold mark** on the left: you changed this setting.
- **Yellow star**: a game menu also sets this value. Hover it to see which one. That menu does not
  read the value back, so it may show another level.
- **Greyed line**: it depends on another setting that is off (for example fog density without
  volumetric fog, tint strength without a tint). The line says which setting to change.
- Hover a label to read its full help.

## 3. Presets

| Preset | Result |
|---|---|
| Low | Best performance. Short view distance, no shadows. |
| Medium | Balanced. Good performance with decent shadows. |
| High | The game's High level. Full shadows, all effects. |
| Extra | High, with the longest view distance. |

Presets change only the graphics quality settings of the Quality tab. They do not touch camera,
mouse, interface, sharpening, low latency, HDR or filters.

Changed your mind? **Undo last preset** (button next to the presets, or `/pano undo`) restores the settings from
before the last preset.

## 4. Filters

The Filters tab adds effects on top of the image. They change no game setting.

- **Tint**: click a thumbnail to apply it right away (sepia, warm, cold, night, emerald, dusk).
  **Tint strength** sets how strong it is.
- **My filter**: uses one of your filters from the My filters tab. It replaces the tint, the vignette and the film grain.
- **Sky**: the same colors as a gradient, full at the top of the screen and lighter at the bottom.
  **Sky strength** sets how strong it is.
- **Vignette**: darkens the edges of the screen.
- **Film grain**: animated grain.
- **Black bars**: top and bottom bars, 0 to 20 % of the screen each. The game still renders what they
  hide, so they do not raise the frame rate.

### Ambiance

The Ambiance tab changes the tint, sky, vignette and grain on its own, to fit where you are.

- **Automatic ambiance**: on, these filters follow the place and the time of day. Off by default.
  The values of the Filters tab stay saved and come back when you turn it off.
- **Place**: sets the tint, vignette and grain. Order: dungeon or raid, indoors, weather (rain, snow,
  sandstorm), then the kind of zone: temperate, desert, snowy, jungle and marsh, corrupted, volcanic,
  arcane forest. A zone not known yet counts as temperate. Weather counts only when Weather
  intensity is above 0.
- **Time of day**: sets the sky (day, dawn and dusk, night). Night follows the game's day and
  night; dawn and dusk follow the server time. No sky indoors or in a dungeon.
- The line on the right shows the place and the time of day detected now. When a dungeon, indoors
  or the weather comes before a zone you set, it says so.
- **Context to edit**: pick a context, then set its filters below. The Default button gives back the
  value shipped for that context.
  The menu has five groups: **Zones** (the zone you are in and the zones you set), **Dungeon and indoors**, **Weather**, **Zone type** and **Sky (time of day)**.
  The first four set tint, vignette, grain and a graphics preset: one place applies at a time, in the order given above.
  The last one sets the sky. Nothing to set to get started: every context already has its values.
- **This zone**: first choice of the same menu, with the name of the zone you are in. Pick it to give
  this zone its own tint, vignette and grain, starting from its kind of zone. It then comes before
  the kind of zone, but after dungeon, indoors and weather. Zones you set stay in the menu.
  **Zone type** removes the values of the zone: it follows its kind of zone again.
- **All zones**: submenu of the same menu, with every known zone. Pick one to set it without being there. Zones are sorted by continent.
- **Graphics preset** and **Scenery distance** (first lines of a place or a zone): they apply while you are in that place, over your own settings, with the automatic ambiance on or off. The scenery distance of the place comes before the one of the preset. Your own settings are kept and come back when you leave. **My settings** changes nothing. Example: Low in dungeons, Extra in a zone you like. In a dungeon or raid, the first choice of the menu sets that dungeon alone. In the Quality tab, the **By place** button opens these lines for the place you are in; it reads **Here: …** while a place applies its own. In combat, the change waits for the end of the fight.
- **My filter** (first line of the filters of a place or a zone): this place uses one of your filters from the My filters tab, with its contrast, brightness and gamma, while the automatic ambiance is on.
- **Day and night** (bottom of the tab): **Automatic day and night** lays the **Day tint** by day and the **Night tint** at night,
  following the game's day and night. They replace the Filters tab tint. The change is gradual from 19:00 to 21:00 and from 5:00 to 7:00
  (server time). **Day tint strength** and **Night tint strength** set how strong they are.
  It does not work together with the automatic ambiance: turning one on turns the other off.

## 5. My filters

The My filters tab lets you create as many filters of your own as you want. **New** adds one, **Delete** removes the open one: the Filters tab, places and zones that used it go back to None.

- **Filter to edit**: picks the filter that the lines below set. **Name**: give it a name (Enter to confirm).
- **Red**, **Green**, **Blue** (in %): the tint color of the filter. **Tint strength**: how strong it is.
- **Vignette** and **Film grain**: those of the filter.
- **Contrast**, **Brightness**, **Gamma**: image settings the filter gives the game while it is applied; your own values come back afterwards. My settings: nothing changes. Depending on the display mode, they may have no effect.
- While the tab is open, the filter shown is visible live on the game.
- To use a filter: pick it on the **My filter** line of the Filters tab (everywhere), or for a place or a zone in the Ambiance tab (automatic ambiance on). It then replaces the tint, the vignette and the film grain, whose lines are greyed out. None: nothing changes.

## 6. Your values and the game

- On first install, Panorama reads your current game settings. Nothing changes until you move a control.
- A change made in the game's Graphics menu or with `/console` shows in the window.
- **Apply on every login** (footer, on by default): the settings you changed in Panorama are written again
  at each login. The others follow the game's Graphics menu.
- A change made during combat is applied when combat ends.
- Some settings, such as MSAA, need a graphics restart. Click **Restart** in the footer, or type
  `/pano restart`. The screen flickers for a second.

## 7. HDR on Windows

HDR settings exist only as console commands in the game. Panorama shows them in the **Advanced** tab,
section **HDR (console only)**. You need a monitor that supports HDR.

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

Open `/pano`, tab **Advanced**, section **HDR (console only)**.

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
| `/pano undo` | Restore the settings from before the last preset |
| `/pano reset` | Put every setting and filter back to its default |
| `/pano status` | Show in the chat the place and time of day detected and the filters applied now (during a fade, the values it goes to) |
| `/pano apply` | Write again the settings changed in Panorama |
| `/pano restart` | Restart the graphics engine |
| `/pano minimap` | Show or hide the minimap button |

## 9. Reset

- The **Default** button on each line resets that setting.
- The **Defaults** button of the game's Graphics menu resets only the settings that menu manages,
  and Panorama follows it. Use the Default buttons in `/pano` for the others and for the filters.
- **Reset all** (footer, with confirmation) or `/pano reset`: puts every setting changed in Panorama
  and every filter back to its default. It cannot be undone.
  The Ambiance tab and the zones you set are reset too. Your filters in the My filters tab are erased too.
