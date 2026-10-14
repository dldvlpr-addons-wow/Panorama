-- Vérification hors du jeu : lua tests/run_tests.lua (depuis la racine de l'addon).
local cvars, combat, handler, written
C_CVar = {
    GetCVar = function(name) return cvars[name] end,
    SetCVar = function(name, value) cvars[name] = value; written[#written + 1] = name end,
}
InCombatLockdown = function() return combat end
frame = { RegisterEvent = function() end, UnregisterEvent = function() end,
          SetScript = function(_, _, fn) handler = fn end }
CreateFrame = function() return frame end
SlashCmdList = {}
strtrim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
GetLocale = function() return "frFR" end
local LOCALES = { "enUS", "frFR", "deDE", "esES", "itIT", "ptBR", "ruRU", "koKR", "zhCN", "zhTW" }

local function Load(savedVariables)
    cvars = { farclip = "1000", ffxDeath = "1", gxMultisample = "1", rippleDetail = "2" }
    combat, written = false, {}
    local ns = {}
    for _, code in ipairs(LOCALES) do assert(loadfile("Locale/" .. code .. ".lua"))("Panorama", ns) end
    assert(loadfile("Panorama.lua"))("Panorama", ns)
    PanoramaDB = savedVariables
    handler(frame, "ADDON_LOADED", "Panorama")
    return ns
end

-- Premier lancement : les valeurs actuelles du jeu sont reprises, pas le preset.
local ns = Load(nil)

-- Traductions : aucune clé hors de enUS, chaque réglage a son libellé et sa bulle d'aide.
for _, code in ipairs(LOCALES) do
    for key in pairs(ns.locales[code]) do
        assert(ns.locales.enUS[key], code .. " : clé inconnue de enUS " .. key)
    end
end
for _, setting in ipairs(ns.settings) do
    assert(setting.title or (setting.label and setting.tip), "texte manquant " .. tostring(setting.cvar))
end
assert(ns.presets[3].label == "Élevé" and ns.L.PREFIX == ns.locales.frFR.PREFIX, "langue du client")
assert(PanoramaDB.values.farclip == 1000 and PanoramaDB.values.ffxDeath == true
    and PanoramaDB.values.gxMultisample == 1, "valeurs du jeu reprises")
handler(frame, "PLAYER_LOGIN")
assert(cvars.farclip == "1000" and cvars.ffxDeath == "1" and cvars.gxMultisample == "1", "rien de changé")

-- Changement hors du panneau : PanoramaDB suit la CVar, bornée.
cvars.farclip = "99999"
handler(frame, "CVAR_UPDATE", "farClip")
assert(PanoramaDB.values.farclip == 2600, "CVAR_UPDATE suivi et borné")

-- Valeurs sauvegardées hors limites, de mauvais type ou hors choix.
Load({ values = { farclip = 99999, ffxDeath = "oui", gxMultisample = 3 } })
assert(PanoramaDB.values.farclip == 2600, "farclip ramené au max")
assert(PanoramaDB.values.ffxDeath == false, "booléen invalide remplacé par défaut")
assert(PanoramaDB.values.gxMultisample == 8, "choix invalide remplacé par défaut")
assert(PanoramaDB.applyOnLogin == true)

-- En combat : rien n'est écrit, tout part à la sortie du combat.
combat = true
handler(frame, "PLAYER_LOGIN")
assert(#written == 0, "aucune écriture en combat")
combat = false
handler(frame, "PLAYER_REGEN_ENABLED")
assert(cvars.farclip == "2600" and cvars.ffxDeath == "0" and cvars.gxMultisample == "8")
-- Seules les CVars connues du client sont écrites.
assert(#written == 3, "CVars inconnues ignorées, écrit " .. #written)

-- Réapplication coupée : PanoramaDB reprend les valeurs du jeu au chargement.
Load({ applyOnLogin = false, values = { farclip = 2000 } })
assert(PanoramaDB.values.farclip == 1000, "valeur du jeu reprise")
-- Préréglage : seules les CVars avec `levels` changent, les autres restent intactes.
print = function() end
Load(nil)
SlashCmdList.PANORAMA("low")
assert(cvars.farclip == "400" and cvars.gxMultisample == "1", "préréglage Bas écrit")
assert(cvars.ffxDeath == "1", "ffxDeath hors préréglage")
SlashCmdList.PANORAMA("extra")
assert(PanoramaDB.values.farclip == 2600 and cvars.gxMultisample == "8", "préréglage Extra écrit")

-- Avancé : jamais écrit à la connexion tant que non touché, écrit après NS.Change.
local ns2 = Load({ values = { rippleDetail = 0 } })
written = {}
handler(frame, "PLAYER_LOGIN")
for _, name in ipairs(written) do assert(name ~= "rippleDetail", "avancé non touché écrit") end
for _, setting in ipairs(ns2.settings) do
    if setting.cvar == "rippleDetail" then
        PanoramaDB.values.rippleDetail = 1
        ns2.Change(setting)
    end
end
assert(PanoramaDB.touched.rippleDetail and cvars.rippleDetail == "1", "NS.Change écrit et marque touché")
-- Annulation : le préréglage est défait, rien à annuler ensuite.
ns2 = Load(nil)
assert(not ns2.CanUndo(), "rien à annuler au départ")
SlashCmdList.PANORAMA("low")
assert(cvars.farclip == "400" and ns2.CanUndo())
SlashCmdList.PANORAMA("undo")
assert(cvars.farclip == "1000" and PanoramaDB.values.farclip == 1000, "annulation restaure")
assert(not ns2.CanUndo(), "annulation consommée")
io.write("ok\n")
