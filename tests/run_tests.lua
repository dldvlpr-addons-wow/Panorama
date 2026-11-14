-- Vérification hors du jeu : lua tests/run_tests.lua (depuis la racine de l'addon).
local cvars, combat, handler, written
C_CVar = {
    GetCVar = function(name) return cvars[name] end,
    SetCVar = function(name, value) cvars[name] = value; written[#written + 1] = name end,
}
InCombatLockdown = function() return combat end
local bands
frame = { RegisterEvent = function() end, UnregisterEvent = function() end,
          SetScript = function(_, script, fn) if script == "OnEvent" then handler = fn end end,
          -- Calque des filtres (Filter.lua) : écran de 1000 de haut.
          SetAllPoints = function() end, SetFrameStrata = function() end, GetHeight = function() return 1000 end,
          GetWidth = function() return 1600 end,
          SetShown = function(self, shown) self.shown = shown end,
          CreateTexture = function()
              local noop = function() end
              local texture = { SetPoint = noop, SetAllPoints = noop, SetTexture = noop, SetBlendMode = noop,
                                SetTexCoord = noop,
                                SetColorTexture = function(self, r, g, b) self.color = { r, g, b } end,
                                SetHeight = function(self, height) self.height = height end,
                                SetShown = function(self, shown) self.shown = shown end,
                                SetAlpha = function(self, alpha) self.alpha = alpha end }
              bands[#bands + 1] = texture
              return texture
          end }
WorldFrame = {}
CreateFrame = function() return frame end
SlashCmdList = {}
strtrim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
GetLocale = function() return "frFR" end
local LOCALES = { "enUS", "frFR", "deDE", "esES", "itIT", "ptBR", "ruRU", "koKR", "zhCN", "zhTW" }

-- .toc : chaque fichier listé existe et compile en Lua 5.1 (loadfile = luac -p), et chaque .lua
-- livré est listé. tests/ et .claude/ ne sont pas livrés (.pkgmeta).
local listed = {}
for line in io.lines("Panorama.toc") do
    line = line:gsub("\r$", "")
    if line ~= "" and not line:find("^#") then
        local path = line:gsub("%s*%[.*$", ""):gsub("\\", "/")
        listed[path] = true
        assert(loadfile(path))
    end
end
local found = io.popen("find . -name '*.lua' -not -path './tests/*' -not -path './.*'")
for path in found:lines() do
    path = path:gsub("^%./", "")
    assert(listed[path], path .. " absent du .toc")
end
found:close()

local function Load(savedVariables, extraCVars)
    cvars = { cameraDistanceMaxZoomFactor = "2.6", farclip = "1000", ffxDeath = "1", gxMultisample = "1", rippleDetail = "2" }
    for name, value in pairs(extraCVars or {}) do cvars[name] = value end
    combat, written = false, {}
    local ns = {}
    for _, code in ipairs(LOCALES) do assert(loadfile("Locale/" .. code .. ".lua"))("Panorama", ns) end
    assert(loadfile("Panorama.lua"))("Panorama", ns)
    assert(loadfile("Filter.lua"))("Panorama", ns)
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
for _, list in ipairs({ ns.settings, ns.filterSettings }) do
    for _, setting in ipairs(list) do
        assert(setting.title or (setting.label and setting.tip),
            "texte manquant " .. tostring(setting.cvar or setting.key))
    end
end
local doubled = 0
for _, setting in ipairs(ns.settings) do
    if setting.menu then doubled = doubled + 1 end
end
assert(doubled == 39 and ns.L.ALSO_IN_MENU:format(ns.L.MENU_SSAO):find("SSAO"), "menus du jeu marqués")
assert(ns.presets[3].label == "Élevé" and ns.L.PREFIX == ns.locales.frFR.PREFIX, "langue du client")
assert(PanoramaDB.values.farclip == 1000 and PanoramaDB.values.ffxDeath == true
    and PanoramaDB.values.gxMultisample == 1, "valeurs du jeu reprises")
handler(frame, "PLAYER_LOGIN")
assert(cvars.farclip == "1000" and cvars.ffxDeath == "1" and cvars.gxMultisample == "1", "rien de changé")

-- Changement hors du panneau (/console) : PanoramaDB suit la CVar, même au-delà du curseur.
cvars.farclip = "9000"
handler(frame, "CVAR_UPDATE", "farClip")
assert(PanoramaDB.values.farclip == 9000, "CVAR_UPDATE suivi sans borne")

-- Valeurs sauvegardées hors limites, de mauvais type ou hors choix.
Load({ values = { farclip = 9000, cameraDistanceMaxZoomFactor = 4, ffxDeath = "oui", gxMultisample = 3 } })
assert(PanoramaDB.values.farclip == 9000, "farclip /console gardé")
assert(PanoramaDB.values.cameraDistanceMaxZoomFactor == 4, "zoom caméra /console gardé")
assert(PanoramaDB.values.ffxDeath == false, "booléen invalide remplacé par défaut")
assert(PanoramaDB.values.gxMultisample == 8, "choix invalide remplacé par défaut")
-- waterDetail 3 fait planter le client : une valeur sauvegardée à 3 redescend à 2.
Load({ values = { waterDetail = 3 } })
assert(PanoramaDB.values.waterDetail == 2, "waterDetail plafonné à 2")
cvars.waterDetail = "3"
handler(frame, "PLAYER_LOGIN")
assert(cvars.waterDetail == "2", "waterDetail réécrit à 2 à la connexion")
-- Plafond aussi au premier lancement, réapplication coupée, et après un CVAR_UPDATE à 3.
Load(nil, { waterDetail = "3" })
handler(frame, "PLAYER_LOGIN")
assert(cvars.waterDetail == "2", "plafond au premier lancement")
Load({ applyOnLogin = false, values = {} }, { waterDetail = "3" })
handler(frame, "PLAYER_LOGIN")
assert(cvars.waterDetail == "2" and #written == 1, "plafond seul, réapplication coupée")
cvars.waterDetail = "3"
handler(frame, "CVAR_UPDATE", "waterDetail")
assert(cvars.waterDetail == "2", "plafond après CVAR_UPDATE")
Load({ values = { farclip = 9000, cameraDistanceMaxZoomFactor = 4, ffxDeath = "oui", gxMultisample = 3 } })
assert(PanoramaDB.applyOnLogin == true)

-- En combat : rien n'est écrit, tout part à la sortie du combat.
combat = true
handler(frame, "PLAYER_LOGIN")
assert(#written == 0, "aucune écriture en combat")
combat = false
handler(frame, "PLAYER_REGEN_ENABLED")
assert(cvars.farclip == "9000" and cvars.ffxDeath == "0" and cvars.gxMultisample == "8")
-- Seules les CVars connues du client sont écrites.
assert(cvars.cameraDistanceMaxZoomFactor == "4", "zoom caméra réécrit à 4")
assert(#written == 4, "CVars inconnues ignorées, écrit " .. #written)

-- Ticket #11 : seul un réglage touché dans Panorama est réécrit ; les autres suivent le jeu.
Load({ schema = 2, values = { farclip = 2000, ffxDeath = false }, touched = { ffxDeath = true } })
assert(PanoramaDB.values.farclip == 1000 and PanoramaDB.values.ffxDeath == false, "non touché : valeur du jeu")
handler(frame, "PLAYER_LOGIN")
assert(cvars.farclip == "1000" and cvars.ffxDeath == "0" and #written == 1, "seul le réglage touché écrit")
-- Valeur déjà égale dans le jeu : aucune écriture (une écriture peut recharger le décor).
written = {}
handler(frame, "PLAYER_LOGIN")
assert(#written == 0, "valeur égale réécrite")
-- Migration depuis une ancienne sauvegarde : valeur égale au jeu non marquée, différente marquée.
Load({ values = { farclip = 1000, gxMultisample = 4 }, touched = {} })
assert(PanoramaDB.schema == 2 and not PanoramaDB.touched.farclip and PanoramaDB.touched.gxMultisample,
    "migration des réglages touchés")
Load({ values = { ResampleSharpness = 0.1 + 0.2 } }, { ResampleSharpness = "0.3" })
assert(PanoramaDB.values.ResampleSharpness == 0.3, "CVar de test présente")
assert(not PanoramaDB.touched.ResampleSharpness, "migration : arrondi du curseur ignoré")
Load({ applyOnLogin = false, values = { gxMultisample = 4 }, touched = {} })
assert(not PanoramaDB.touched.gxMultisample, "migration ignorée si réapplication coupée")

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
assert(PanoramaDB.values.farclip == 7000 and cvars.gxMultisample == "8", "préréglage Extra écrit")

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
-- `also` : userFontScaleGlue suit userFontScale.
cvars.userFontScale, cvars.userFontScaleGlue = "1", "1"
for _, setting in ipairs(ns2.settings) do
    if setting.cvar == "userFontScale" then
        PanoramaDB.values.userFontScale = 1.5
        ns2.Change(setting)
    end
end
assert(cvars.userFontScale == "1.5" and cvars.userFontScaleGlue == "1.5", "userFontScaleGlue écrite aussi")
-- Annulation : le préréglage est défait, rien à annuler ensuite.
ns2 = Load(nil)
assert(not ns2.CanUndo(), "rien à annuler au départ")
SlashCmdList.PANORAMA("low")
assert(cvars.farclip == "400" and ns2.CanUndo())
SlashCmdList.PANORAMA("undo")
assert(cvars.farclip == "1000" and PanoramaDB.values.farclip == 1000, "annulation restaure")
assert(not ns2.CanUndo(), "annulation consommée")
assert(not PanoramaDB.touched.farclip, "annulation : réglage rendu au jeu")
-- Annulation en combat : écrite à la sortie du combat, même pour un réglage rendu au jeu.
SlashCmdList.PANORAMA("low")
combat = true
SlashCmdList.PANORAMA("undo")
assert(cvars.farclip == "400", "rien d'écrit en combat")
combat = false
handler(frame, "PLAYER_REGEN_ENABLED")
assert(cvars.farclip == "1000", "annulation écrite après le combat")

-- Recherche : casse ignorée hors ASCII (latin accentué, cyrillique).
local options = { L = ns.L }
assert(loadfile("Options.lua"))("Panorama", options)
assert(options.Fold("Écran ÀÞ Дальность ЯЁ") == "écran àþ дальность яё", "recherche sans casse")

-- Filtres : rien n'est créé à 0, valeur invalide remplacée par le défaut, bandes à 10 % de l'écran.
-- Textures créées dans l'ordre : bande haute, bande basse, teinte, vignette, grain.
bands = {}
Load(nil)
handler(frame, "PLAYER_LOGIN")
assert(PanoramaDB.filters.letterbox == 0 and PanoramaDB.filters.tintStrength == 50 and #bands == 0,
    "aucun calque sans filtre")
Load({ values = {}, filters = { letterbox = 99, tint = 1.5, vignette = "oui" } })
assert(PanoramaDB.filters.letterbox == 0 and PanoramaDB.filters.tint == 0 and PanoramaDB.filters.vignette == 0,
    "filtres invalides remplacés")
local ns3 = Load({ values = {}, filters = { letterbox = 10 } })
handler(frame, "PLAYER_LOGIN")
assert(#bands == 5 and bands[1].height == 100 and bands[2].height == 100 and bands[1].shown and frame.shown,
    "bandes posées à 10 %")
assert(not bands[3].shown and not bands[4].shown and not bands[5].shown, "seules les bandes visibles")
-- Teinte choisie mais intensité à 0 : rien. Sépia à 100 % : couleur sépia multipliée.
PanoramaDB.filters.letterbox, PanoramaDB.filters.tint, PanoramaDB.filters.tintStrength = 0, 1, 0
ns3.ApplyFilters()
assert(frame.shown == false and #bands == 5, "calque caché à 0, sans recréation")
PanoramaDB.filters.tintStrength = 100
ns3.ApplyFilters()
assert(frame.shown and bands[3].shown and bands[3].color[2] == 0.82 and not bands[1].shown, "teinte sépia")
PanoramaDB.filters.tint, PanoramaDB.filters.vignette, PanoramaDB.filters.grain = 0, 50, 100
ns3.ApplyFilters()
assert(not bands[3].shown and bands[4].shown and bands[4].alpha == 0.5 and bands[5].shown,
    "vignette et grain")
io.write("ok\n")
