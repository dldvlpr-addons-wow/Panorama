---
name: strlower-utf8-locales
description: Panorama/WoW — string.lower (strlower) only lowers ASCII; case-insensitive text matching breaks on frFR/deDE/ruRU labels starting with an accented or Cyrillic capital
metadata:
  type: project
---

Panorama ships 10 locales (frFR, deDE, esES, itIT, ptBR, ruRU, koKR, zhCN, zhTW, enUS). WoW Lua 5.1
`string.lower` works byte by byte in the C locale: `"Écran"`, `"Дальность"`, `"Über"` keep their capital.
Seen in the options search bar review (2026-11-12): frFR "écran" missed `ffxDeath` ("Écran gris à la mort");
ruRU "мягкие тени" missed "Мягкие тени".

**Why:** any `:lower()` + `find` comparison over localized text silently fails for non-ASCII capitals,
and the headless tests only run with ASCII queries.

**How to apply:** when reviewing a Panorama change that compares or searches localized strings, check
for a UTF-8 aware fold (`CaseAccentInsensitiveParse` if confirmed on Forever, or a gsub on
`\195[\128-\158]` / `\208[\144-\175]` / `\208\129`), not a bare `:lower()`.
