---
name: combat-text-cvar-cache
description: Panorama/WoW — floatingCombatText*_v2 written by SetCVar have no visible effect until /reload (Blizzard_CombatText caches show flags)
metadata:
  type: project
---

Blizzard_CombatText (Forever 1.60.1 / retail family, read in BlizzardInterfaceCode) copies each
`floatingCombatText*_v2` CVar into `CombatTextTypeInfo[*].show` only inside
`CombatTextMixin:UpdateDisplayedMessages()` (frame `CombatText`), called at OnLoad, when
`enableFloatingCombatText` changes through Settings, and on WorldFrame resize. No CVAR_UPDATE
listener. Only FriendlyHealers and DamageReduction are read live.

**Why:** an addon toggle that only calls SetCVar looks broken in-session (seen in Panorama review 2026-10-14).

**How to apply:** when reviewing any Panorama change touching combat text CVars, check that the write
is followed by `CombatText:UpdateDisplayedMessages()` (guarded; legacy global
`CombatText_UpdateDisplayedMessages` on older clients) or that the UI says a /reload is needed.
Blizzard source for Forever: `/Applications/World of Warcraft/_classic_beta_/BlizzardInterfaceCode`.
