-- Vérification hors du jeu : lua tests/run_tests.lua (depuis la racine de l'addon).
local cvars, combat, handler, written
C_CVar = {
    GetCVar = function(name) return cvars[name] end,
    SetCVar = function(name, value) cvars[name] = value; written[#written + 1] = name end,
}
InCombatLockdown = function() return combat end
GetCVarDefault = function() return nil end
-- Minuteries gardées sans être lancées : le test les déclenche lui-même.
local timers = {}
C_Timer = { After = function(delay, callback) timers[#timers + 1] = { delay = delay, callback = callback } end }
-- Horloge du jeu, avancée à la main par les tests.
local now = 0
GetTime = function() return now end
-- Midi, jour : remplacés plus bas par les tests de l'ambiance.
GetGameTime = function() return 12, 0 end
C_DateAndTime = { IsDayTime = function() return true end }
local bands
frame = { events = {},
          RegisterEvent = function(self, event) self.events[event] = true end,
          UnregisterEvent = function(self, event) self.events[event] = nil end,
          SetScript = function(self, script, fn)
              if script == "OnEvent" then handler = fn elseif script == "OnUpdate" then self.onUpdate = fn end
          end,
          -- Calque des filtres (Filter.lua) : écran de 1000 de haut.
          SetAllPoints = function() end, SetFrameStrata = function() end, GetHeight = function() return 1000 end,
          GetWidth = function() return 1600 end,
          SetShown = function(self, shown) self.shown = shown end,
          CreateTexture = function()
              local noop = function() end
              local texture = { SetPoint = noop, SetAllPoints = noop, SetTexture = noop, SetBlendMode = noop,
                                SetTexCoord = noop,
                                SetHeight = function(self, height) self.height = height end,
                                SetGradient = function(self, _, bottom, top) self.gradient = { bottom, top } end,
                                SetColorTexture = function(self, r, g, b) self.color = { r, g, b } end,
                                SetShown = function(self, shown) self.shown = shown end,
                                SetAlpha = function(self, alpha) self.alpha = alpha end }
              bands[#bands + 1] = texture
              return texture
          end }
WorldFrame = {}
CreateColor = function(r, g, b, a)
    return { r = r, g = g, b = b, a = a,
             SetRGBA = function(self, nr, ng, nb, na) self.r, self.g, self.b, self.a = nr, ng, nb, na end }
end
CreateFrame = function() return frame end
SlashCmdList = {}
strtrim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
GetLocale = function() return "frFR" end
local LOCALES = { "enUS", "frFR", "deDE", "esES", "itIT", "ptBR", "ruRU", "koKR", "zhCN", "zhTW" }

-- .toc : chaque fichier listé existe et compile en Lua 5.1 (loadfile = luac -p), et chaque .lua
-- livré est listé. tests/ et .claude/ ne sont pas livrés (.pkgmeta).
local listed = {}
for rawLine in io.lines("Panorama.toc") do
    local line = rawLine:gsub("\r$", "")
    if line ~= "" and not line:find("^#") then
        local path = line:gsub("%s*%[.*$", ""):gsub("\\", "/")
        listed[path] = true
        assert(loadfile(path))
    end
end
local found = io.popen("find . -name '*.lua' -not -path './tests/*' -not -path './.*'")
for foundPath in found:lines() do
    local path = foundPath:gsub("^%./", "")
    assert(listed[path], path .. " absent du .toc")
end
found:close()

local function Load(savedVariables, extraCVars)
    cvars = { cameraDistanceMaxZoomFactor = "2.6", farclip = "1000", ffxDeath = "1", gxMultisample = "1", rippleDetail = "2" }
    for name, value in pairs(extraCVars or {}) do cvars[name] = value end
    combat, written = false, {}
    frame.events = {}
    for index = #timers, 1, -1 do timers[index] = nil end
    local ns = {}
    for _, code in ipairs(LOCALES) do assert(loadfile("Locale/" .. code .. ".lua"))("Panorama", ns) end
    assert(loadfile("Panorama.lua"))("Panorama", ns)
    assert(loadfile("Filter.lua"))("Panorama", ns)
    assert(loadfile("Ambiance.lua"))("Panorama", ns)
    PanoramaDB = savedVariables
    handler(frame, "ADDON_LOADED", "Panorama")
    return ns
end

-- Premier lancement : les valeurs actuelles du jeu sont reprises, pas le preset.
-- Ambiance. Contexte du joueur simulé : hors instance, dehors, temps clair, midi, en Elwynn (1429).
-- Cartes : 1426 Dun Morogh -> 1415 Royaumes de l'Est -> 947 Azeroth ; 9999 inconnue sous 1414 Kalimdor.
local instance, indoors, weather, hour, mapID = { false }, false, { type = 0, intensity = 0 }, 12, 1429
local parents = { [1426] = 1415, [1415] = 947, [947] = 0, [9999] = 1414, [1414] = 947, [5555] = 1426 }
IsInInstance = function() return instance[1], instance[2] end
IsIndoors = function() return indoors end
C_Weather = { GetCurrentWeather = function() return weather end }
local minute = 0
GetGameTime = function() return hour, minute end
local isDayTime   -- nil : signal du jeu absent, heure seule
C_DateAndTime = { IsDayTime = function() return isDayTime end }
C_Map = { GetBestMapForUnit = function() return mapID end,
          GetMapInfo = function(id)
              return parents[id] and { mapID = id, parentMapID = parents[id], mapType = id == 1415 and 2 or 3,
                                       name = id == 1415 and "Royaumes de l'Est" or nil }
          end }
Enum = { UIMapType = { Continent = 2 } }
-- Donjon ou raid : nom et instanceID (1er et 8e retours de GetInstanceInfo).
local instanceName, instanceID
GetInstanceInfo = function() return instanceName, instance[2], nil, nil, nil, nil, nil, instanceID end
local ns = Load(nil)

-- Traductions : aucune clé hors de enUS, chaque réglage a son libellé et sa bulle d'aide.
for _, code in ipairs(LOCALES) do
    for key in pairs(ns.locales[code]) do
        assert(ns.locales.enUS[key], code .. " : clé inconnue de enUS " .. key)
    end
end
for _, list in ipairs({ ns.settings, ns.filterSettings, ns.customFilterSettings }) do
    for _, setting in ipairs(list) do
        assert(setting.title or setting.subtitle or (setting.label and setting.tip),
            "texte manquant " .. tostring(setting.cvar or setting.key))
    end
end
local doubled = 0
for _, setting in ipairs(ns.settings) do
    if setting.menu then doubled = doubled + 1 end
end
assert(doubled == 28 and ns.L.ALSO_IN_MENU:format(ns.L.MENU_SSAO):find("SSAO"), "menus du jeu marqués")
assert(ns.presets[3].label == "Élevé" and ns.L.PREFIX == ns.locales.frFR.PREFIX, "langue du client")
assert(PanoramaDB.values.farclip == 1000 and PanoramaDB.values.ffxDeath == true
    and PanoramaDB.values.gxMultisample == 1, "valeurs du jeu reprises")
handler(frame, "PLAYER_LOGIN")
assert(cvars.farclip == "1000" and cvars.ffxDeath == "1" and cvars.gxMultisample == "1", "rien de changé")

-- Changement hors du panneau (/console) : PanoramaDB suit la CVar, même au-delà du curseur.
cvars.farclip = "9000"
handler(frame, "CVAR_UPDATE", "farClip")
assert(PanoramaDB.values.farclip == 9000, "CVAR_UPDATE suivi sans borne")

-- Le client charge ses CVars après PLAYER_LOGIN : réglage touché réécrit par-dessus, réglage du
-- jeu relu, CVAR_UPDATE écouté seulement une fois VARIABLES_LOADED, PLAYER_ENTERING_WORLD et le
-- délai après PLAYER_LOGIN passés, dans n'importe quel ordre.
for _, order in ipairs({ { "VARIABLES_LOADED", "PLAYER_ENTERING_WORLD", "timer" },
                         { "PLAYER_ENTERING_WORLD", "timer", "VARIABLES_LOADED" },
                         { "timer", "VARIABLES_LOADED", "PLAYER_ENTERING_WORLD" } }) do
    Load({ schema = 2, values = { farclip = 3000 }, touched = { farclip = true } })
    handler(frame, "PLAYER_LOGIN")
    assert(cvars.farclip == "3000" and not frame.events.CVAR_UPDATE, "CVAR_UPDATE pas écouté à PLAYER_LOGIN")
    assert(#timers == 1 and timers[1].delay == 4.35, "délai programmé à PLAYER_LOGIN")
    cvars.farclip, cvars.cameraDistanceMaxZoomFactor = "1000", "3.5"
    local function Step(name)
        if name == "timer" then table.remove(timers, 1).callback() else handler(frame, name) end
    end
    Step(order[1])
    Step(order[2])
    assert(cvars.farclip == "1000" and not frame.events.CVAR_UPDATE, "attente de la dernière étape")
    Step(order[3])
    assert(cvars.farclip == "3000" and PanoramaDB.values.farclip == 3000, "réglage touché réécrit après le chargement")
    assert(PanoramaDB.values.cameraDistanceMaxZoomFactor == 3.5, "réglage du jeu relu après le chargement")
    assert(frame.events.CVAR_UPDATE and not frame.events.PLAYER_ENTERING_WORLD, "CVAR_UPDATE écouté, une seule passe")
end

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
-- Brouillard : le jeu le repasse à 4, ramené à 3 (plafond du curseur).
cvars.volumeFogLevel = "4"
handler(frame, "CVAR_UPDATE", "volumeFogLevel")
assert(cvars.volumeFogLevel == "3" and PanoramaDB.values.volumeFogLevel == 3, "volumeFogLevel plafonné à 3")
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
-- Écriture refusée sans erreur par le client : le panneau reprend la valeur du jeu.
local setCVar = C_CVar.SetCVar
C_CVar.SetCVar = function() return false end
for _, setting in ipairs(ns2.settings) do
    if setting.cvar == "farclip" then
        PanoramaDB.values.farclip = 3000
        ns2.Change(setting)
    end
end
assert(PanoramaDB.values.farclip == 1000, "valeur refusée remplacée par celle du jeu")
-- Même refus pour un changement fait en combat : relu après l'écriture de sortie de combat.
combat = true
for _, setting in ipairs(ns2.settings) do
    if setting.cvar == "farclip" then
        PanoramaDB.values.farclip = 3000
        ns2.Change(setting)
    end
end
assert(PanoramaDB.values.farclip == 3000, "en combat : valeur gardée jusqu'à l'écriture")
combat = false
handler(frame, "PLAYER_REGEN_ENABLED")
C_CVar.SetCVar = setCVar
assert(PanoramaDB.values.farclip == 1000, "refus après le combat : valeur du jeu reprise")
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

-- Remise à zéro complète : CVars à la valeur du jeu d'avant le premier changement (détection du
-- matériel : 3000) et rendues au jeu, filtres au défaut, annulable.
local nsReset = Load({ values = {}, filters = { grain = 50, letterbox = 10 } }, { farclip = "3000", hwDetect = "0" })
SlashCmdList.PANORAMA("low")
assert(PanoramaDB.origin.farclip == 3000, "origine gardée au premier changement")
SlashCmdList.PANORAMA("medium")
assert(PanoramaDB.origin.farclip == 3000, "origine gardée une seule fois")
cvars.cameraZoomSpeed = "35"   -- réglé par le jeu, jamais touché dans Panorama
SlashCmdList.PANORAMA("reset")
assert(cvars.cameraZoomSpeed == "35", "réglage non touché laissé au jeu")
assert(cvars.farclip == "3000" and not PanoramaDB.touched.farclip and nsReset.CanUndo(), "CVars remises au jeu")
assert(PanoramaDB.origin.farclip == nil, "origine oubliée avec le réglage rendu au jeu")
assert(cvars.hwDetect == "0", "toutes les origines gardées : pas de nouvelle détection du matériel")
assert(PanoramaDB.filters.grain == 0 and PanoramaDB.filters.letterbox == 0, "filtres remis au défaut")
bands = {}   -- calque de filtres créé par l'annulation (grain rendu)
SlashCmdList.PANORAMA("undo")
assert(cvars.farclip == "800" and PanoramaDB.touched.farclip and PanoramaDB.filters.grain == 50, "reset annulé")
assert(PanoramaDB.origin.farclip == 3000, "annulation : origine rendue")
-- Réglages touchés sans origine gardée (versions d'avant) : défaut du jeu pour tous les réglages : nombre, booléen "4" lu vrai, défaut vide ou hors `choices`
-- remplacé par celui de Panorama.
GetCVarDefault = function(name)
    return ({ farclip = "1000", spellClutter = "4", sunShafts = "", shadowTextureSize = "512" })[name]
end
cvars.spellClutter, cvars.sunShafts, cvars.shadowTextureSize = "0", "0", "1024"
PanoramaDB.values.spellClutter, PanoramaDB.values.sunShafts, PanoramaDB.values.shadowTextureSize = false, 0, 1024
PanoramaDB.touched.spellClutter, PanoramaDB.touched.sunShafts, PanoramaDB.touched.shadowTextureSize = true, true, true
SlashCmdList.PANORAMA("reset")
assert(cvars.hwDetect == "1", "réglage sans origine : détection du matériel au prochain lancement")
assert(cvars.farclip == "3000" and cvars.spellClutter == "1" and cvars.sunShafts == "2"
    and cvars.shadowTextureSize == "2048", "reset : défaut du jeu, repli sur le défaut de Panorama")
GetCVarDefault = function() return nil end
SlashCmdList.PANORAMA("undo")
assert(cvars.hwDetect == "0", "reset annulé : détection du matériel retirée")

-- Historique : plusieurs pas, Rétablir, file Rétablir vidée par une modification, 20 pas au plus.
local nsHistory = Load(nil)
SlashCmdList.PANORAMA("low")
nsHistory.Checkpoint()
PanoramaDB.filters.vignette = 40
SlashCmdList.PANORAMA("undo")
assert(PanoramaDB.filters.vignette == 0 and cvars.farclip == "400" and nsHistory.CanRedo(), "un pas annulé")
SlashCmdList.PANORAMA("undo")
assert(cvars.farclip == "1000" and not nsHistory.CanUndo(), "deux pas annulés")
SlashCmdList.PANORAMA("redo")
SlashCmdList.PANORAMA("redo")
assert(cvars.farclip == "400" and PanoramaDB.filters.vignette == 40 and not nsHistory.CanRedo(), "deux pas rétablis")
SlashCmdList.PANORAMA("undo")
nsHistory.Checkpoint()   -- modification sans effet : Rétablir gardé
assert(nsHistory.CanRedo(), "point sans effet : Rétablir gardé")
nsHistory.Checkpoint()
PanoramaDB.filters.vignette = 10
assert(not nsHistory.CanRedo(), "modification : Rétablir vidé")
for step = 1, 25 do
    nsHistory.Checkpoint()
    PanoramaDB.filters.grain = step
end
for _ = 1, 25 do SlashCmdList.PANORAMA("undo") end
assert(PanoramaDB.filters.grain == 5, "20 pas gardés")
-- Nouvelle modification après une annulation, même suivie d'un point sans effet : Rétablir vidé.
nsHistory = Load(nil)
for _, command in ipairs({ "low", "undo", "high", "high" }) do SlashCmdList.PANORAMA(command) end
assert(not nsHistory.CanRedo(), "point sans effet après une modification : Rétablir vidé")
-- Points sans effet : ne prennent pas de pas.
nsHistory = Load(nil)
for _ = 1, 22 do SlashCmdList.PANORAMA("low") end
SlashCmdList.PANORAMA("medium")
for _ = 1, 25 do SlashCmdList.PANORAMA("undo") end
assert(cvars.farclip == "1000", "points sans effet hors des 20 pas")
-- Changement fait dans le menu du jeu entre deux pas : Annuler ne le défait pas.
nsHistory = Load(nil)
SlashCmdList.PANORAMA("low")
cvars.cameraDistanceMaxZoomFactor = "1.5"
handler(frame, "CVAR_UPDATE", "cameraDistanceMaxZoomFactor")
SlashCmdList.PANORAMA("undo")
assert(cvars.farclip == "1000" and cvars.cameraDistanceMaxZoomFactor == "1.5", "changement du jeu gardé par Annuler")
-- Annuler en combat : le message dit que l'écriture attend la fin du combat.
nsHistory = Load(nil)
SlashCmdList.PANORAMA("low")
local historyPrinted, historyPrint = {}, print
print = function(text) historyPrinted[#historyPrinted + 1] = text end
combat = true
SlashCmdList.PANORAMA("undo")
combat = false
print = historyPrint
assert(historyPrinted[#historyPrinted]:find(nsHistory.L.MSG_APPLIED_AFTER_COMBAT, 1, true) and cvars.farclip == "400",
    "Annuler en combat : écriture annoncée pour la fin du combat")
handler(frame, "PLAYER_REGEN_ENABLED")
assert(cvars.farclip == "1000", "Annuler en combat : écrit à la sortie du combat")
-- Annuler : le filtre choisi dans l'onglet Look au moment du pas est rechoisi.
nsHistory = Load(nil)
PanoramaDB.filters.customFilter = 1
nsHistory.Checkpoint()
PanoramaDB.filters.customFilter = 0
SlashCmdList.PANORAMA("undo")
assert(PanoramaDB.filters.customFilter == 1, "Annuler rechoisit le filtre choisi au moment du pas")
-- Erreur pendant un préréglage : signalée, et le panneau se rafraîchit encore ensuite.
nsHistory = Load(nil)
local refreshed, reported = 0, nil
nsHistory.RefreshOptions = function() refreshed = refreshed + 1 end
geterrorhandler = function() return function(message) reported = message end end
local setCVar = C_CVar.SetCVar
C_CVar.SetCVar = function() error("refusé") end
SlashCmdList.PANORAMA("low")
C_CVar.SetCVar = setCVar
refreshed = 0
for _, setting in ipairs(nsHistory.settings) do
    if setting.cvar == "farclip" then
        nsHistory.db.values.farclip = 600
        nsHistory.Change(setting)
    end
end
assert(reported and reported:find("refusé") and refreshed == 1, "erreur de préréglage : panneau encore rafraîchi")
geterrorhandler = nil
-- Mode simple au premier lancement, mode avancé pour un joueur qui avait déjà Panorama.
Load(nil)
assert(PanoramaDB.advancedMode == false, "nouveau joueur : mode simple")
Load({ values = {} })
assert(PanoramaDB.advancedMode == true, "joueur existant : mode avancé")

-- Recherche : casse ignorée hors ASCII (latin accentué, cyrillique).
local options = { L = ns.L }
assert(loadfile("Options.lua"))("Panorama", options)
assert(options.Fold("Écran ÀÞ Дальность ЯЁ") == "écran àþ дальность яё", "recherche sans casse")

-- Filtres : rien n'est créé à 0, valeur invalide remplacée par le défaut.
-- Textures créées dans l'ordre : teinte, vignette, grain, ciel, bande du haut, bande du bas.
bands = {}
Load(nil)
handler(frame, "PLAYER_LOGIN")
assert(PanoramaDB.filters.tint == 0 and PanoramaDB.filters.tintStrength == 50 and #bands == 0,
    "aucun calque sans filtre")
Load({ values = {}, filters = { grain = 101, tint = 1.5, vignette = "oui" } })
assert(PanoramaDB.filters.grain == 0 and PanoramaDB.filters.tint == 0 and PanoramaDB.filters.vignette == 0,
    "filtres invalides remplacés")
-- Filtres du joueur : liste suivie depuis 1 (le 6, après un trou, oublié), valeurs invalides remplacées, nom invalide oublié.
local nsCustom = Load({ values = {}, filters = { tint = 7, customFilter = 6 },
                        customFilters = { { tintRed = 40, grain = "x", contrast = 99, name = "Désert" },
                                          "x", { name = "a|cffff0000b" }, { name = "  " }, nil, {} } })
local customFilters = PanoramaDB.customFilters
assert(#customFilters == 4 and customFilters[6] == nil and nsCustom.filterSettings[8].max == 4
    and customFilters[1].tintRed == 40 and customFilters[1].grain == 0
    and customFilters[1].contrast == 0 and customFilters[2].tintBlue == 100 and customFilters[4].tintStrength == 50,
    "filtres du joueur chargés")
assert(PanoramaDB.filters.tint == 0 and PanoramaDB.filters.customFilter == 0
    and PanoramaDB.ambiance.contexts.temperate.customFilter == 0, "teinte 7 et filtre 6 inconnus remplacés")
assert(customFilters[3].name == nil and customFilters[4].name == nil and nsCustom.CustomFilterName(1) == "Désert"
    and nsCustom.CustomFilterName(3) == "Filtre 3" and nsCustom.CustomFilterName(6) == nil
    and nsCustom.filterSettings[8].names[1] == "Désert" and nsCustom.filterSettings[8].names[0] == "Réglages ci-dessous",
    "noms des filtres du joueur")
-- Bandes noires à 10 % d'un écran de 1000 de haut : 100 chacune.
local ns3 = Load({ values = {}, filters = { letterbox = 10, vignette = 50 } })
handler(frame, "PLAYER_LOGIN")
assert(#bands == 6 and frame.shown and bands[2].shown and not bands[1].shown and not bands[3].shown
    and not bands[4].shown, "vignette visible, ni teinte, ni grain, ni ciel")
assert(bands[5].shown and bands[6].shown and bands[5].height == 100 and bands[6].height == 100,
    "bandes noires à 10 %")
PanoramaDB.filters.letterbox = 0
-- Teinte choisie mais intensité à 0 : rien. Sépia à 100 % : couleur sépia multipliée.
PanoramaDB.filters.vignette, PanoramaDB.filters.tint, PanoramaDB.filters.tintStrength = 0, 1, 0
ns3.ApplyFilters()
assert(frame.shown == false and #bands == 6, "calque caché à 0, sans recréation")
PanoramaDB.filters.tintStrength = 100
ns3.ApplyFilters()
assert(frame.shown and bands[1].shown and bands[1].color[2] == 0.82, "teinte sépia")
-- Aucun filtre enregistré : un filtre ; deux ajoutés, aux valeurs par défaut.
assert(#PanoramaDB.customFilters == 1 and ns3.AddCustomFilter() == 2 and ns3.AddCustomFilter() == 3
    and PanoramaDB.customFilters[3].tintStrength == 50 and ns3.filterSettings[8].max == 3, "filtres ajoutés")
-- Filtre du joueur choisi : sa couleur, sa vignette et son grain remplacent ceux de l'onglet Filtres.
local custom = PanoramaDB.customFilters[2]
custom.tintRed, custom.tintGreen, custom.tintStrength, custom.vignette = 50, 25, 100, 40
PanoramaDB.filters.customFilter = 2
ns3.ApplyFilters()
assert(bands[1].color[1] == 0.5 and bands[1].color[2] == 0.25 and bands[2].shown and bands[2].alpha == 0.4,
    "filtre du joueur posé")
-- Mode Selon le lieu : le look vient de la règle du lieu, pas du look de base.
PanoramaDB.ambiance.enabled = true
assert(ns3.AppliedFilters() ~= PanoramaDB.filters, "selon le lieu : look de la règle")
PanoramaDB.ambiance.enabled, PanoramaDB.filters.customFilter = false, 0
-- Suppression : ce qui choisissait le filtre passe à Aucun, ce qui choisissait un suivant le suit.
PanoramaDB.filters.customFilter, PanoramaDB.ambiance.contexts.desert.customFilter = 3, 2
PanoramaDB.ambiance.zones[1] = { customFilter = 3 }
ns3.DeleteCustomFilter(2)
assert(#PanoramaDB.customFilters == 2 and PanoramaDB.filters.customFilter == 2
    and PanoramaDB.ambiance.contexts.desert.customFilter == 0 and PanoramaDB.ambiance.zones[1].customFilter == 2
    and ns3.filterSettings[8].max == 2 and ns3.CustomFilterName(2) == "Filtre 3", "filtre supprimé, choix suivis")
ns3.DeleteCustomFilter(1)
ns3.DeleteCustomFilter(1)
assert(#PanoramaDB.customFilters == 1 and PanoramaDB.filters.customFilter == 1, "un filtre reste toujours")
-- Ajout : premier nom par défaut libre (« Filtre 3 » est pris par le filtre restant).
assert(ns3.AddCustomFilter() == 2 and ns3.CustomFilterName(2) == "Filtre 1" and ns3.AddCustomFilter() == 3
    and ns3.CustomFilterName(3) == "Filtre 2", "nom du filtre ajouté")
ns3.DeleteCustomFilter(3)
ns3.DeleteCustomFilter(2)
PanoramaDB.filters.customFilter, PanoramaDB.ambiance.zones[1] = 0, nil
PanoramaDB.filters.tint, PanoramaDB.filters.vignette, PanoramaDB.filters.grain = 0, 50, 100
ns3.ApplyFilters()
assert(not bands[1].shown and bands[2].shown and bands[2].alpha == 0.5 and bands[3].shown,
    "vignette et grain")
-- Ciel nuit à 100 % : couleur pleine en haut, 40 % de sa force en bas.
PanoramaDB.filters.vignette, PanoramaDB.filters.grain, PanoramaDB.filters.sky, PanoramaDB.filters.skyStrength = 0, 0, 4, 100
ns3.ApplyFilters()
local bottom, top = bands[4].gradient[1], bands[4].gradient[2]
assert(frame.shown and bands[4].shown and top.r == 0.55 and top.b == 1 and math.abs(bottom.r - 0.82) < 1e-9,
    "ciel en dégradé")
PanoramaDB.filters.skyStrength = 0
ns3.ApplyFilters()
assert(frame.shown == false, "ciel à 0 : calque caché")

-- Ambiance : coupée par défaut, valeurs livrées par contexte, valeur invalide remplacée.
local ns5 = Load({ values = {}, filters = { tint = 5, tintStrength = 80 },
                   ambiance = { enabled = true, contexts = { night = { sky = 99, skyStrength = 60 }, rain = "x" } } })
assert(ns5.AppliedFilters() ~= PanoramaDB.filters, "ambiance enregistrée active")
assert(PanoramaDB.ambiance.contexts.night.sky == 4 and PanoramaDB.ambiance.contexts.night.skyStrength == 60
    and PanoramaDB.ambiance.contexts.rain.tint == 3, "ambiance invalide remplacée, valeur choisie gardée")
assert(PanoramaDB.ambiance.contexts.night.tint == nil and PanoramaDB.ambiance.contexts.desert.sky == nil,
    "un contexte ne garde que ses clés")
assert(Load(nil) and PanoramaDB.ambiance.enabled == false and PanoramaDB.ambiance.contexts.temperate.tint == 2,
    "ambiance coupée par défaut")
-- Lieu : biome de la zone, de sa carte parente, sinon tempéré. Moment : heure du serveur.
local function Detect()
    local place, moment = ns5.DetectAmbiance()
    return place .. (moment and " " .. moment or "")
end
assert(Detect() == "temperate day", "Elwynn de jour")
hour = 20
assert(Detect() == "temperate dusk", "crépuscule")
hour = 2
assert(Detect() == "temperate night", "nuit")
-- Signal jour/nuit du jeu prioritaire sur l'heure ; aube et crépuscule à l'heure, dans son jour.
hour, isDayTime = 12, false
assert(Detect() == "temperate night", "jeu dit nuit à midi : nuit")
hour, isDayTime = 22, true
assert(Detect() == "temperate dusk", "jeu dit jour à 22 h : crépuscule")
hour, isDayTime = 2, nil
mapID = 1426
assert(Detect() == "frozen night", "Dun Morogh enneigé")
mapID = 5555
assert(Detect() == "frozen night" and select(3, ns5.DetectAmbiance()) == 1426, "sous-zone : biome et zone parents")
mapID = 9999
assert(Detect() == "temperate night" and select(3, ns5.DetectAmbiance()) == 9999, "zone inconnue : tempéré")
mapID = 1426
Detect()
mapID = nil
assert(Detect() == "frozen night" and select(3, ns5.DetectAmbiance()) == 1426, "carte illisible : dernière zone gardée")
-- Carte illisible plus de 5 minutes : zone d'avant oubliée, tempéré.
now = now + 301
assert(Detect() == "temperate night" and select(3, ns5.DetectAmbiance()) == nil, "carte perdue : zone oubliée")
mapID = 1426
Detect()
mapID = nil
assert(Detect() == "frozen night", "carte relue : délai repris de zéro")
mapID = 1427
weather.type = 2
assert(Detect() == "snow night", "météo avant le biome")
-- Réglage du joueur, pas la CVar : un préréglage de lieu peut couper la météo sans quitter le lieu.
cvars.WeatherDensity = "0"
assert(Detect() == "snow night", "météo coupée dans le jeu seulement : ambiance météo gardée")
cvars.WeatherDensity = nil
ns5.db.values.WeatherDensity = 0
assert(Detect() == "volcanic night", "effets météo coupés : pas d'ambiance météo")
ns5.db.values.WeatherDensity = nil
indoors = true
assert(Detect() == "indoor", "intérieur : pas de ciel")
instance = { true, "pvp" }
assert(Detect() == "indoor", "champ de bataille : pas un donjon")
instance = { true, "raid" }
assert(Detect() == "dungeon", "raid")
-- Ambiance active : lieu et ciel du moment, filtres de base intacts.
ns5 = Load({ values = {}, filters = { tint = 5, tintStrength = 80 }, ambiance = { enabled = true } })
local applied = ns5.AppliedFilters()
assert(applied.tint == 4 and applied.vignette == 40 and applied.sky == 0 and applied.skyStrength == 0,
    "ambiance donjon appliquée, sans ciel")
instance, indoors, weather.type, hour, mapID = { false }, false, 0, 2, 1427
applied = ns5.AppliedFilters()
assert(applied.tint == 0 and applied.tintStrength == 15 and applied.sky == 4 and applied.skyStrength == 70,
    "Gorge des Vents brûlants de nuit")
assert(PanoramaDB.filters.tint == 5 and PanoramaDB.filters.tintStrength == 80 and PanoramaDB.filters.vignette == 0,
    "filtres de base intacts")
-- Zone réglée : copie de son biome, puis ses propres valeurs ; sous la pluie, la météo passe avant.
local volcano = ns5.CustomizeZone(1427)
assert(volcano.tint == 0 and volcano.vignette == 30 and volcano.sky == nil and ns5.CustomizeZone(1427) == volcano,
    "zone copiée de son biome")
volcano.vignette = 70
assert(ns5.AppliedFilters().vignette == 70 and PanoramaDB.ambiance.contexts.volcanic.vignette == 30, "zone réglée appliquée")
weather.type = 1
assert(ns5.AppliedFilters().vignette == 25, "pluie avant la zone")
weather.type = 0
PanoramaDB.ambiance.enabled = false
assert(ns5.AppliedFilters() == PanoramaDB.filters, "ambiance coupée : filtres de base")
-- Fondu : changement de contexte de l'ambiance, de l'écran vers les valeurs du nouveau contexte ;
-- réglage du joueur posé tout de suite. bands[2] = vignette, bands[1] = teinte.
bands = {}
local ns6 = Load({ values = {}, ambiance = { enabled = true } })
hour, mapID = 12, 1429
ns6.ApplyFilters()
assert(bands[2].alpha == 0.15 and not frame.onUpdate, "Elwynn posé sans fondu")
mapID = 1427
ns6.UpdateAmbiance()
assert(bands[2].alpha == 0.15 and frame.onUpdate, "fondu lancé vers le volcan")
frame.onUpdate(frame, 0.75)
assert(math.abs(bands[2].alpha - 0.225) < 1e-9 and bands[1].shown, "mi-fondu")
frame.onUpdate(frame, 1)
assert(bands[2].alpha == 0.3 and not bands[1].shown and not frame.onUpdate, "fondu fini, sans grain livré")
PanoramaDB.ambiance.enabled = false
ns6.UpdateAmbiance()
ns6.ApplyFilters()
assert(frame.shown == false and not frame.onUpdate, "ambiance coupée : calque caché sans fondu")
-- Préréglage du lieu : écrit dans le jeu par-dessus les réglages du joueur, qui restent intacts
-- dans PanoramaDB ; réglages du joueur réécrits en sortant du lieu et à la déconnexion.
instance, indoors, weather.type, hour, mapID = { false }, false, 0, 12, 1429
local nsPlace = Load({ schema = 2, values = { farclip = 3000 }, touched = { farclip = true },
                       ambiance = { contexts = { volcanic = { preset = 1 }, indoor = { viewDistance = 2 } },
                                    zones = { [1426] = { preset = 4 } } } })
assert(PanoramaDB.ambiance.enabled == false, "réglages du lieu : sans l'ambiance auto")
assert(PanoramaDB.ambiance.contexts.temperate.preset == 0 and PanoramaDB.ambiance.contexts.day.preset == nil
    and PanoramaDB.ambiance.zones[1426].preset == 4, "préréglage de lieu relu, absent des moments")
assert(nsPlace.placeSettings[1].names[0] == "Mes réglages" and nsPlace.placeSettings[1].label == "Préréglage"
    and nsPlace.placeSettings[2].label == "Distance des décors" and nsPlace.placeSettings[2].names[2] == "800",
    "réglages de lieu traduits")
assert(PanoramaDB.ambiance.contexts.temperate.viewDistance == 0 and PanoramaDB.ambiance.zones[1426].viewDistance == 0
    and PanoramaDB.ambiance.contexts.day.viewDistance == nil, "distance de lieu complétée, absente des moments")
assert(#nsPlace.zoneMaps > 40, "zones connues listées pour le menu")
mapID = 1427
nsPlace.ApplyFilters()
assert(cvars.farclip == "1000", "préréglage de lieu attendu jusqu'à la fin du chargement")
handler(frame, "PLAYER_LOGIN")
handler(frame, "VARIABLES_LOADED")
handler(frame, "PLAYER_ENTERING_WORLD")
table.remove(timers, 1).callback()
assert(cvars.farclip == "400" and PanoramaDB.values.farclip == 3000 and PanoramaDB.undo == nil,
    "préréglage du volcan posé, réglages du joueur intacts")
assert(nsPlace.DetectedText():find(nsPlace.presets[1].label, 1, true), "préréglage du lieu dans l'état")
handler(frame, "CVAR_UPDATE", "farclip")
assert(PanoramaDB.values.farclip == 3000, "valeur du préréglage de lieu : pas un réglage du joueur")
cvars.farclip = "5000"
handler(frame, "CVAR_UPDATE", "farclip")
assert(PanoramaDB.values.farclip == 5000, "changement du joueur dans le lieu : suivi")
-- Revenu à la valeur du lieu dans le menu du jeu : c'est son dernier choix, il est gardé.
cvars.farclip = "400"
handler(frame, "CVAR_UPDATE", "farclip")
assert(PanoramaDB.values.farclip == 400, "retour du joueur à la valeur du lieu : suivi")
combat, mapID = true, 1426
nsPlace.UpdateAmbiance()
assert(cvars.farclip == "400", "préréglage de lieu différé en combat")
combat = false
handler(frame, "PLAYER_REGEN_ENABLED")
assert(cvars.farclip == "7000" and PanoramaDB.values.farclip == 400, "préréglage de la zone posé après le combat")
handler(frame, "CVAR_UPDATE", "farclip")
assert(PanoramaDB.values.farclip == 400, "nouveau lieu : sa valeur n'est plus un choix du joueur")
PanoramaDB.values.farclip = 5000
assert(cvars.gxMultisample == "1", "préréglage du lieu : réglage à redémarrage laissé au joueur")
mapID = 1429
nsPlace.UpdateAmbiance()
assert(cvars.farclip == "5000", "lieu sans préréglage : réglages du joueur rendus")
mapID = 1427
nsPlace.UpdateAmbiance()
handler(frame, "PLAYER_LOGOUT")
assert(cvars.farclip == "5000", "déconnexion : réglages du joueur rendus")
mapID = 1426
nsPlace.UpdateAmbiance()
assert(cvars.farclip == "7000", "réglages du lieu reposés après la déconnexion annulée")
-- Distance du lieu : passe avant le préréglage ; intérieur sans préréglage : celui de la zone reste.
indoors = true
nsPlace.UpdateAmbiance()
assert(cvars.farclip == "800" and cvars.gxMultisample == "1", "distance de l'intérieur avant celle du préréglage")
for _, setting in ipairs(nsPlace.settings) do
    if setting.cvar == "farclip" then nsPlace.farclipSetting = setting end
end
local placeIndex, placeDistance = nsPlace.PlacePreset()
assert(placeIndex == 4 and placeDistance == 800, "intérieur sur Mes réglages : préréglage de la zone gardé")
assert(nsPlace.DetectedText():find("800", 1, true), "distance du lieu dans l'état")
-- Réglage changé dans Panorama pendant que le lieu le tient : gardé, écrit en sortant du lieu.
PanoramaDB.touched.farclip, PanoramaDB.origin.farclip = nil, nil
local playerFarclip = PanoramaDB.values.farclip
PanoramaDB.values.farclip = 6000
nsPlace.Change(nsPlace.farclipSetting, playerFarclip)
assert(cvars.farclip == "800" and PanoramaDB.values.farclip == 6000, "réglage tenu par le lieu : choix du joueur gardé")
assert(playerFarclip ~= 800 and PanoramaDB.origin.farclip == playerFarclip,
    "réglage tenu par le lieu : origine = valeur du joueur, pas celle du lieu")
nsPlace.ApplyAll()
assert(cvars.farclip == "800", "tout réappliquer : réglage du lieu gardé")
-- Donjon : réglage propre, rangé sous l'opposé de son instanceID, nom gardé.
indoors, instance, instanceName, instanceID = false, { true, "party" }, "Mortemines", 36
nsPlace.UpdateAmbiance()
assert(cvars.farclip == "6000", "donjon sans réglage : réglages du joueur")
assert(nsPlace.CurrentZone() == -36 and nsPlace.ZoneName(-36) == "Mortemines" and nsPlace.ZoneBiome(-36) == "dungeon",
    "donjon : zone propre nommée")
nsPlace.CustomizeZone(-36).viewDistance = 1
nsPlace.UpdateAmbiance()
assert(cvars.farclip == "400" and PanoramaDB.placePreset == 0, "distance propre au donjon posée, repère gardé")
instanceID = 48
nsPlace.UpdateAmbiance()
assert(cvars.farclip == "6000", "autre donjon : réglages du joueur")
instance, instanceName, instanceID, mapID = { false }, nil, nil, 1429
nsPlace.UpdateAmbiance()
assert(cvars.farclip == "6000", "lieu sans réglage : réglages du joueur rendus")
assert(PanoramaDB.placePreset == nil, "repère du préréglage de lieu effacé une fois les réglages rendus")

mapID = 1429
-- Session finie en combat avec un préréglage de lieu : il reste dans le jeu. Il n'est pas relu
-- comme réglage du joueur, et les réglages enregistrés sont réécrits.
Load({ schema = 2, values = { farclip = 3000 }, placePreset = 1 }, { farclip = "400" })
assert(PanoramaDB.values.farclip == 3000, "préréglage resté dans le jeu : pas relu au chargement")
handler(frame, "PLAYER_LOGIN")
handler(frame, "VARIABLES_LOADED")
handler(frame, "PLAYER_ENTERING_WORLD")
table.remove(timers, 1).callback()
assert(cvars.farclip == "3000" and PanoramaDB.values.farclip == 3000 and PanoramaDB.placePreset == nil,
    "préréglage resté dans le jeu : réglages du joueur réécrits")
Load({ schema = 2, values = { farclip = 3000 } }, { farclip = "400" })
assert(PanoramaDB.values.farclip == 400, "sans repère : réglage qui suit le jeu relu")
-- Rechargé en combat : rien n'est écrit, le repère reste jusqu'à l'écriture de sortie de combat.
local nsCombat = Load({ schema = 2, values = { farclip = 3000 }, placePreset = 1 }, { farclip = "400" })
combat = true
handler(frame, "PLAYER_LOGIN")
handler(frame, "VARIABLES_LOADED")
handler(frame, "PLAYER_ENTERING_WORLD")
table.remove(timers, 1).callback()
assert(cvars.farclip == "400" and PanoramaDB.placePreset == 1, "rechargé en combat : repère gardé")
combat = false
handler(frame, "PLAYER_REGEN_ENABLED")
assert(cvars.farclip == "3000" and PanoramaDB.values.farclip == 3000 and PanoramaDB.placePreset == nil,
    "sortie de combat : réglages du joueur réécrits, repère effacé")
-- Repère resté et réglage sans valeur enregistrée : valeur par défaut, pas celle du lieu.
local nsNew = Load({ schema = 2, values = {}, placePreset = 1 }, { farclip = "400" })
for _, setting in ipairs(nsNew.settings) do
    if setting.cvar == "farclip" then
        assert(PanoramaDB.values.farclip == nsNew.GameDefault(setting) and PanoramaDB.values.farclip ~= 400,
            "repère resté, réglage neuf à la valeur du lieu : valeur par défaut")
    end
end
Load({ schema = 2, values = {}, placePreset = 1 }, { farclip = "1234" })
assert(PanoramaDB.values.farclip == 1234, "repère resté, réglage neuf : valeur du jeu, celle du joueur")
-- Écriture du lieu refusée hors combat : reprise à la passe suivante.
mapID = 1426
local nsRefused = Load({ schema = 2, values = { farclip = 3000 },
                         ambiance = { zones = { [1426] = { viewDistance = 1 } } } }, { farclip = "3000" })
local acceptCVar = C_CVar.SetCVar
C_CVar.SetCVar = function() return false end
handler(frame, "PLAYER_LOGIN")
handler(frame, "VARIABLES_LOADED")
handler(frame, "PLAYER_ENTERING_WORLD")
table.remove(timers, 1).callback()
assert(cvars.farclip == "3000", "écriture du lieu refusée")
C_CVar.SetCVar = acceptCVar
nsRefused.UpdateAmbiance()
assert(cvars.farclip == "400" and PanoramaDB.values.farclip == 3000, "écriture du lieu reprise à la passe suivante")
-- Sortie du lieu refusée : repère gardé, à la déconnexion aussi ; la valeur du lieu n'est pas relue.
C_CVar.SetCVar = function() return false end
mapID = 1429
nsRefused.UpdateAmbiance()
assert(cvars.farclip == "400" and PanoramaDB.placePreset ~= nil, "réglages du joueur non rendus : repère gardé")
-- Essais épuisés : un seul message, qui nomme le réglage par son libellé.
local refusedMessages, silentPrint = {}, print
print = function(text) refusedMessages[#refusedMessages + 1] = text end
for _ = 1, 5 do nsRefused.UpdateAmbiance() end
print = silentPrint
assert(#refusedMessages == 1 and refusedMessages[1]:find(nsRefused.L.farclip, 1, true),
    "essais épuisés : réglage nommé une fois")
handler(frame, "PLAYER_LOGOUT")
assert(PanoramaDB.placePreset ~= nil, "déconnexion refusée : repère gardé")
C_CVar.SetCVar = acceptCVar
Load(PanoramaDB, { farclip = "400" })
assert(PanoramaDB.values.farclip == 3000, "session suivante : valeur du lieu pas prise pour celle du joueur")
handler(frame, "PLAYER_LOGIN")
handler(frame, "VARIABLES_LOADED")
handler(frame, "PLAYER_ENTERING_WORLD")
table.remove(timers, 1).callback()
assert(cvars.farclip == "3000" and PanoramaDB.placePreset == nil, "session suivante : réglages du joueur rendus")
-- Écriture du lieu refusée, puis le joueur choisit la valeur du lieu dans le menu du jeu : suivi.
mapID = 1426
local nsChosen = Load({ schema = 2, values = { farclip = 3000 },
                        ambiance = { zones = { [1426] = { viewDistance = 1 } } } }, { farclip = "3000" })
C_CVar.SetCVar = function() return false end
handler(frame, "PLAYER_LOGIN")
handler(frame, "VARIABLES_LOADED")
handler(frame, "PLAYER_ENTERING_WORLD")
table.remove(timers, 1).callback()
C_CVar.SetCVar = acceptCVar
cvars.farclip = "400"
handler(frame, "CVAR_UPDATE", "farclip")
assert(PanoramaDB.values.farclip == 400, "lieu refusé : choix du joueur égal à la valeur du lieu suivi")
-- Reprise : le réglage changé par le joueur entre-temps n'est pas réécrit.
cvars.farclip = "2000"
handler(frame, "CVAR_UPDATE", "farclip")
nsChosen.UpdateAmbiance()
assert(cvars.farclip == "2000" and PanoramaDB.values.farclip == 2000, "reprise : choix du joueur laissé dans le jeu")
mapID = 1429
-- Continent d'une zone, pour ranger « Toutes les zones ».
assert(nsCombat.ZoneContinent(1426) == "Royaumes de l'Est" and nsCombat.ZoneContinent(5555) == "Royaumes de l'Est"
    and nsCombat.ZoneContinent(1429) == nil, "continent d'une zone, nil si le jeu ne le dit pas")
-- Zone illisible supprimée, valeur invalide remplacée par celle du biome enregistré.
Load({ ambiance = { contexts = { frozen = { vignette = 55 } },
                    zones = { [1426] = { tint = 3, tintStrength = 40, vignette = "x" }, abc = {}, [1429] = 5 } } })
local zones = PanoramaDB.ambiance.zones
assert(zones[1426].tintStrength == 40 and zones[1426].vignette == 55 and zones[1426].grain == 0
    and zones.abc == nil and zones[1429] == nil, "zones relues")

-- Jour/nuit automatique : teinte de jour Aucune le jour, fondu de 60 s vers la teinte de nuit au
-- changement de moment. bands[1] = teinte.
Load({ values = {}, filters = { autoDayNight = "oui" } })
assert(PanoramaDB.filters.autoDayNight == false, "booléen de filtre invalide remplacé")
-- Ambiance auto et jour/nuit automatiques enregistrés ensemble : l'ambiance garde la main.
Load({ values = {}, filters = { autoDayNight = true }, ambiance = { enabled = true } })
assert(PanoramaDB.ambiance.enabled and PanoramaDB.filters.autoDayNight == false, "ambiance et jour/nuit exclusifs")
bands, hour, isDayTime, mapID = {}, 12, true, 1429
local nsDay = Load({ values = {}, filters = { tint = 0, tintNight = 4, tintNightStrength = 100, autoDayNight = true } })
nsDay.ApplyFilters()
assert(frame.shown == false, "jour sans teinte de jour : calque caché")
isDayTime = false
nsDay.UpdateAmbiance()
assert(frame.shown and not bands[1].shown and frame.onUpdate, "fondu lancé depuis l'écran sans teinte")
frame.onUpdate(frame, 30)
assert(math.abs(bands[1].color[1] - 0.775) < 1e-9, "fondu lent à mi-chemin")
frame.onUpdate(frame, 30)
assert(math.abs(bands[1].color[1] - 0.55) < 1e-9 and not frame.onUpdate, "nuit atteinte, plus d'OnUpdate")
nsDay.UpdateAmbiance()
assert(not frame.onUpdate, "même moment : aucun fondu")
-- Changement de lieu pendant le fondu lent : temps restant gardé.
isDayTime = true
nsDay.UpdateAmbiance()
frame.onUpdate(frame, 10)
nsDay.UpdateAmbiance()
frame.onUpdate(frame, 1.5)
assert(frame.onUpdate and bands[1].shown, "fondu lent non abrégé")
frame.onUpdate(frame, 50)
assert(not frame.onUpdate, "jour atteint")
-- Crépuscule (jeu dit jour, 20 h) : teinte de nuit à moitié ; 22 h : pleine.
hour = 20
nsDay.ApplyFilters()
assert(math.abs(bands[1].color[1] - 0.775) < 1e-9, "crépuscule : mi-nuit")
hour = 6
nsDay.ApplyFilters()
assert(math.abs(bands[1].color[1] - 0.775) < 1e-9, "aube : mi-nuit")
hour = 22
nsDay.ApplyFilters()
assert(math.abs(bands[1].color[1] - 0.55) < 1e-9, "jeu dit jour à 22 h : pleine nuit")
hour, minute = 19, 30
nsDay.ApplyFilters()
assert(math.abs(bands[1].color[1] - 0.8875) < 1e-9, "19 h 30 : quart de nuit")
hour, minute = 12, 0
-- Teinte de jour (chaude, bleu 0.72) : remplace celle de l'onglet Filtres (nuit, bleu 1) tant que
-- jour/nuit est coché.
PanoramaDB.filters.tint, PanoramaDB.filters.tintStrength = 4, 100
PanoramaDB.filters.tintDay, PanoramaDB.filters.tintDayStrength = 2, 100
nsDay.ApplyFilters()
assert(math.abs(bands[1].color[3] - 0.72) < 1e-9, "jour : teinte de jour, pas celle des filtres")
PanoramaDB.filters.autoDayNight = false
nsDay.ApplyFilters()
assert(bands[1].color[3] == 1, "auto coupé : teinte de l'onglet Filtres")
PanoramaDB.filters.tint = 0
nsDay.ApplyFilters()
assert(frame.shown == false, "auto coupé : teinte de jour Aucune, calque caché")
isDayTime = nil
-- Teinte de jour livrée : chaude à 25 %. Jour/nuit déjà coché sans teinte de jour enregistrée
-- (version d'avant) : la teinte de l'onglet Filtres est gardée le jour.
Load(nil)
assert(PanoramaDB.filters.tintDay == 2 and PanoramaDB.filters.tintDayStrength == 25, "teinte de jour livrée")
Load({ values = {}, filters = { autoDayNight = true, tint = 3, tintStrength = 40 } })
assert(PanoramaDB.filters.tintDay == 3 and PanoramaDB.filters.tintDayStrength == 40, "jour/nuit déjà coché : jour inchangé")
Load({ values = {}, filters = { autoDayNight = true, tint = 99 } })
assert(PanoramaDB.filters.tintDay == 0 and PanoramaDB.filters.tintDayStrength == 50, "reprise après validation")

-- Fenêtre : onglet invalide remis au premier, sections dépliées par défaut.
local ns4 = Load({ tab = "inconnu" })
assert(PanoramaDB.tab == "image" and next(PanoramaDB.collapsed) == nil, "onglet et sections par défaut")
Load({ tab = "filters" })
assert(PanoramaDB.tab == "ambiance", "ancien onglet Filtres (avant 1.9) : Ambiance")
Load({ tab = "look" })
assert(PanoramaDB.tab == "ambiance", "onglet Filtres (look) fondu dans Ambiance")
Load({ tab = "myfilters" })
assert(PanoramaDB.tab == "myfilters", "onglet Mes filtres gardé")
Load({ collapsed = { ["Advanced"] = true } })
assert(next(PanoramaDB.collapsed) == nil and PanoramaDB.layout == 2, "ancien repli de la 1.6.0 purgé")
Load({ collapsed = { ["Advanced"] = true }, layout = 2 })
assert(PanoramaDB.collapsed.Advanced, "repli choisi gardé")
ns4 = Load(nil)
assert(loadfile("Options.lua"))("Panorama", ns4)
-- Saisie : virgule acceptée, bornée, arrondie au pas ; texte non numérique refusé.
local fov = { min = 0, max = 2, step = 0.1 }
local value, inRange = ns4.ParseInput(fov, " 0,5 ")
assert(math.abs(value - 0.5) < 1e-9 and inRange, "virgule décimale")
value, inRange = ns4.ParseInput(fov, "7")
assert(value == 2 and not inRange, "borne haute")
value = ns4.ParseInput({ min = 0, max = 100, step = 5 }, "42")
assert(value == 40, "arrondi au pas")
assert(ns4.ParseInput(fov, "abc") == nil and ns4.ParseInput(fov, "") == nil and ns4.ParseInput(fov, "inf") == nil,
    "saisie refusée")
-- Ligne grisée tant que le réglage requis est coupé.
PanoramaDB.values.volumeFog = false
assert(not ns4.IsAvailable({ cvar = "volumeFogLevel", requires = "volumeFog" }), "brouillard coupé")
PanoramaDB.values.volumeFog = true
assert(ns4.IsAvailable({ cvar = "volumeFogLevel", requires = "volumeFog" }), "brouillard actif")
PanoramaDB.filters.tint = 0
assert(not ns4.IsAvailable({ key = "tintStrength", requires = "tint" }), "teinte aucune")
assert(ns4.IsAvailable({ cvar = "farclip" }), "sans dépendance")
local strengthSetting
for _, setting in ipairs(ns4.filterSettings) do
    if setting.key == "tintStrength" then strengthSetting = setting end
end
assert(not ns4.IsAvailable(strengthSetting), "intensité grisée sans teinte")
for _, setting in ipairs(ns4.filterSettings) do
    if setting.key == "tintNightStrength" then strengthSetting = setting end
end
PanoramaDB.filters.autoDayNight, PanoramaDB.filters.tintNight = true, 4
assert(ns4.IsAvailable(strengthSetting), "intensité de nuit active")
assert(not ns4.IsAvailable({ key = "tint" }) and ns4.IsAvailable({ key = "vignette" }),
    "jour/nuit coché : teinte de base grisée, pas le reste")
PanoramaDB.filters.autoDayNight = false
assert(not ns4.IsAvailable(strengthSetting), "intensité de nuit grisée sans jour/nuit")
local dayNightLabel
for _, setting in ipairs(ns4.filterSettings) do
    if setting.key == "autoDayNight" then dayNightLabel = setting.label end
end
assert(dayNightLabel and ns4.UnavailableReason(strengthSetting):find(dayNightLabel, 1, true),
    "raison : jour/nuit auto, pas la teinte")
-- Mode Selon le lieu : look de base grisé (la règle le remplace), bandes noires et éditeur de règle réglables.
ns4.db.ambiance.enabled = true
assert(ns4.UnavailableReason({ key = "vignette" }) == ns4.L.UNAVAILABLE_BY_PLACE, "selon le lieu : vignette de base grisée")
assert(ns4.IsAvailable({ key = "letterbox" }), "selon le lieu : bandes noires réglables")
assert(ns4.IsAvailable({ key = "autoDayNight", default = false }), "jour/nuit actif sous l'ambiance")
assert(ns4.IsAvailable({ key = "vignette", ambiance = true }), "éditeur actif")
ns4.db.ambiance.enabled = false
-- Chaque `requires` nomme un réglage de la même liste : une faute de frappe ne grise jamais rien.
for _, list in ipairs({ ns4.settings, ns4.filterSettings }) do
    local names = {}
    for _, setting in ipairs(list) do
        if setting.cvar or setting.key then names[setting.cvar or setting.key] = true end
    end
    for _, setting in ipairs(list) do
        assert(not setting.requires or type(setting.requires) == "function" or names[setting.requires],
            "requires inconnu " .. tostring(setting.requires))
    end
end
for _, id in ipairs(ns4.tabs) do
    assert(ns4.L["TAB_" .. id:upper()], "onglet sans libellé " .. id)
end
-- Préréglage reconnu après application.
SlashCmdList.PANORAMA("low")
assert(ns4.CurrentPreset() == 1, "préréglage Faible reconnu")
SlashCmdList.PANORAMA("extra")
assert(ns4.CurrentPreset() == 4, "préréglage Extra reconnu")

-- Langue choisie : remplace celle du client (frFR) partout, langue inconnue retombe sur le client.
local de = Load({ locale = "deDE" })
local tint
for _, setting in ipairs(de.filterSettings) do if setting.key == "tint" then tint = setting end end
assert(de.presets[3].label == de.locales.deDE.PRESET_HIGH and de.L.OPT_UNDO == de.locales.deDE.OPT_UNDO and de.L.PREFIX == de.locales.enUS.PREFIX
    and de.settings[1].title == de.locales.deDE.SECTION_VIEW and de.settings[2].menu == de.locales.deDE.MENU_VIEW_DISTANCE
    and de.filterSettings[7].title == de.L.SECTION_LOOK_FILTER and tint.names[1] == de.locales.deDE.TINT_SEPIA
    and tint.label == de.locales.deDE.tint, "langue choisie appliquée")
local lowLatency
for _, setting in ipairs(de.settings) do if setting.cvar == "LowLatencyMode" then lowLatency = setting end end
assert(lowLatency.names[0] == de.locales.deDE.LATENCY_AUTO and lowLatency.names[3] == "Reflex", "noms de valeur traduits")
local unknown = Load({ locale = "xxXX" })
assert(PanoramaDB.locale == nil and unknown.presets[3].label == "Élevé", "langue inconnue : langue du client")
-- Menu des contextes : chaque contexte a un groupe au titre traduit.
for _, context in ipairs(unknown.ambianceContexts) do
    assert(unknown.locales.enUS[context.group], "groupe de menu sans titre : " .. context.id)
end

-- Guide en jeu : Guide/<code>.lua à jour de son .md (sinon : lua5.1 tests/build_guide.lua),
-- blocs connus, plus de markdown brut, une ligne de tableau a ses deux colonnes.
local build = dofile("tests/build_guide.lua")
local guides = {}
for _, code in ipairs(build.codes) do
    local file = assert(io.open("Guide/" .. code .. ".lua", "rb"))
    assert(file:read("*a") == build.Generate(code), "Guide/" .. code .. ".lua périmé : lua5.1 tests/build_guide.lua")
    file:close()
    assert(loadfile("Guide/" .. code .. ".lua"))("Panorama", guides)
    local blocks = guides.guides[code]
    assert(blocks[1][1] == "h1" and #blocks > 40, "guide " .. code .. " incomplet")
    for _, block in ipairs(blocks) do
        assert(({ h1 = 1, h2 = 1, h3 = 1, p = 1, li = 1, row = 1 })[block[1]], "bloc inconnu " .. block[1])
        assert(block[1] ~= "row" or block[3] ~= "", "colonne vide dans " .. code)
        for _, text in ipairs(block) do
            assert(not text:find("%*%*") and not text:find("`") and not text:find("%]%("), "markdown brut dans " .. code)
        end
    end
end
assert(guides.guides.esMX == guides.guides.esES, "esMX lit le guide espagnol")
-- Contraste et gamma du filtre du joueur d'une zone : écrits dans la zone, réglages du joueur rendus à la sortie.
mapID = 1426
local nsImage = Load({ schema = 2, values = { Contrast = 50, Brightness = 50, Gamma = 1 },
                       customFilters = { { contrast = 12, gamma = 3 } },
                       ambiance = { enabled = true, zones = { [1426] = { customFilter = 1 } } } },
                     { Contrast = "50", Brightness = "50", Gamma = "1" })
handler(frame, "PLAYER_LOGIN")
handler(frame, "VARIABLES_LOADED")
handler(frame, "PLAYER_ENTERING_WORLD")
table.remove(timers, 1).callback()
assert(cvars.Contrast == "60" and cvars.Gamma == "0.5" and cvars.Brightness == "50", "image de la zone écrite")
assert(PanoramaDB.values.Contrast == 50 and PanoramaDB.values.Gamma == 1 and PanoramaDB.placePreset == 0,
    "image de la zone : réglages du joueur gardés, repère posé")
assert(nsImage.PlacePresetText(nsImage.AppliedPlacePreset()) == nil, "image du filtre : pas un réglage graphique du lieu")
mapID = 1429
nsImage.UpdateAmbiance()
assert(cvars.Contrast == "50" and cvars.Gamma == "1" and PanoramaDB.placePreset == nil, "image rendue à la sortie")
-- Tout réinitialiser : réglages rendus au jeu, filtres et ambiance par défaut, annulable.
local nsReset = Load(nil)
SlashCmdList.PANORAMA("low")
PanoramaDB.filters.vignette, PanoramaDB.ambiance.enabled, PanoramaDB.ambiance.zones[1] = 50, true, {}
PanoramaDB.customFilters[1].tintRed, PanoramaDB.customFilters[1].name, PanoramaDB.filters.customFilter = 0, "Nuit", 1
SlashCmdList.PANORAMA("reset")
assert(#PanoramaDB.customFilters == 1 and PanoramaDB.customFilters[1].tintRed == 85 and PanoramaDB.customFilters[1].name == nil
    and PanoramaDB.filters.customFilter == 0, "reset : filtres du joueur remis à neuf")
assert(next(PanoramaDB.touched) == nil and nsReset.CanUndo(), "reset : réglages rendus au jeu")
assert(PanoramaDB.filters.vignette == 0, "reset : filtres par défaut")
assert(not PanoramaDB.ambiance.enabled and next(PanoramaDB.ambiance.zones) == nil, "reset : ambiance par défaut")
-- /pano status : contexte détecté et valeurs posées, ambiance active.
YES, NO = "Yes", "No"   -- chaînes globales du jeu
local nsStatus, printed = Load(nil), {}
handler(frame, "PLAYER_LOGIN")
PanoramaDB.ambiance.enabled, PanoramaDB.filters.letterbox = true, 10
local realPrint = print
print = function(text) printed[#printed + 1] = text end
SlashCmdList.PANORAMA("status")
print = realPrint
local place = nsStatus.DetectAmbiance()
assert(#printed == 3 and printed[1]:find(nsStatus.DetectedText(), 1, true), "status : contexte détecté")
assert(printed[2]:find(": " .. PanoramaDB.ambiance.contexts[place].vignette .. ",", 1, true)
    and printed[2]:find(": 10", 1, true), "status : valeurs du contexte et bandes de base")

-- Ambiance coupée, pleine nuit : la teinte de nuit remplace la teinte, dont l'intensité tombe à 0.
PanoramaDB.ambiance.enabled, PanoramaDB.filters.autoDayNight = false, true
PanoramaDB.filters.tint, PanoramaDB.filters.tintStrength, PanoramaDB.filters.tintNightStrength = 1, 50, 40
PanoramaDB.filters.skyStrength = 30   -- seule la teinte vaut 50
isDayTime, printed = false, {}
print = function(text) printed[#printed + 1] = text end
SlashCmdList.PANORAMA("status")
print = realPrint
isDayTime = true
assert(printed[2]:find(": 0,", 1, true) and not printed[2]:find(": 50", 1, true), "status : teinte effacée la nuit")
assert(printed[3]:find(": 40,", 1, true) and printed[3]:find(": 100 %", 1, true), "status : teinte de nuit pleine")

-- Échecs auparavant muets : chacun dit quelque chose au joueur.
local captured
local function Capture(fn)
    captured = {}
    local silent = print
    print = function(text) captured[#captured + 1] = text end
    fn()
    print = silent
end
mapID = 1429
local nsQuiet = Load({ schema = 2, values = { farclip = 3000 }, touched = { farclip = true },
                       filters = { tint = "violet" } })
local quietL = nsQuiet.L
Capture(function() handler(frame, "PLAYER_LOGIN") end)
assert(#captured == 1 and captured[1] == quietL.PREFIX .. quietL.MSG_FILTERS_RESET:format(1),
    "filtre enregistré invalide : remis à zéro et dit à la connexion")
-- Table illisible remise à zéro : comptée ; table absente : non comptée.
assert(nsQuiet.LoadFilters({ filters = 5 }) == 1 and nsQuiet.LoadFilters({}) == 0, "table de filtres illisible comptée")
assert(nsQuiet.LoadAmbiance({ ambiance = { enabled = "oui", contexts = 5 } }) == 2
    and nsQuiet.LoadAmbiance({}) == 0, "tables d'ambiance illisibles comptées")
-- VARIABLES_LOADED et PLAYER_ENTERING_WORLD jamais reçus : passe finale faite après le repli.
cvars.farclip = "1000"
table.remove(timers, 1).callback()
local fallback
for index, timer in ipairs(timers) do if timer.delay == 30 then fallback = table.remove(timers, index) break end end
assert(fallback and not frame.events.CVAR_UPDATE, "repli programmé, passe finale pas encore faite")
fallback.callback()
assert(frame.events.CVAR_UPDATE and cvars.farclip == "3000", "passe finale faite sans les événements de chargement")
-- Valeur gardée par le jeu différente de celle choisie : réglage nommé, valeur du jeu affichée.
local farclipSetting
for _, setting in ipairs(nsQuiet.settings) do if setting.cvar == "farclip" then farclipSetting = setting end end
local storeCVar = C_CVar.SetCVar
-- CVAR_UPDATE envoyé pendant SetCVar, comme en jeu : la valeur du jeu est recopiée avant la relecture.
C_CVar.SetCVar = function(name) cvars[name] = "1500" handler(frame, "CVAR_UPDATE", name) return true end
Capture(function()
    nsQuiet.db.values.farclip = 2000
    nsQuiet.Change(farclipSetting)
end)
assert(nsQuiet.db.values.farclip == 1500 and #captured == 1
    and captured[1] == quietL.PREFIX .. quietL.MSG_VALUE_ADJUSTED:format(farclipSetting.label),
    "valeur ajustée par le jeu : dite")
C_CVar.SetCVar = storeCVar
Capture(function()
    nsQuiet.db.values.farclip = 2000
    nsQuiet.Change(farclipSetting)
end)
assert(#captured == 0, "valeur acceptée : aucun message")
-- CVar illisible : la valeur choisie reste, pas le défaut de Panorama.
C_CVar.SetCVar = function(name) cvars[name] = "" handler(frame, "CVAR_UPDATE", name) return true end
nsQuiet.db.values.farclip = 2500
nsQuiet.Change(farclipSetting)
assert(nsQuiet.db.values.farclip == 2500, "CVar illisible : valeur choisie gardée")
-- /pano apply : un seul réglage ajusté, nommé plutôt que compté.
C_CVar.SetCVar = function(name, value)
    cvars[name] = name == "farclip" and "1500" or value
    handler(frame, "CVAR_UPDATE", name)
    return true
end
nsQuiet.db.values.farclip = 2000
Capture(function() SlashCmdList.PANORAMA("apply") end)
assert(captured[#captured] == quietL.PREFIX .. quietL.MSG_VALUE_ADJUSTED:format(farclipSetting.label),
    "un seul réglage ajusté : nommé")
C_CVar.SetCVar = storeCVar
-- /pano minimap : l'état est dit.
Capture(function() SlashCmdList.PANORAMA("minimap") end)
assert(captured[1] == quietL.PREFIX .. quietL.MSG_MINIMAP_HIDDEN, "bouton de minicarte masqué : dit")
Capture(function() SlashCmdList.PANORAMA("minimap") end)
assert(captured[1] == quietL.PREFIX .. quietL.MSG_MINIMAP_SHOWN, "bouton de minicarte affiché : dit")
-- /pano blackbars|grain|vignette : filtre de base réglé, off = 0, hors bornes refusé, annulable.
assert(loadfile("Options.lua"))("Panorama", nsQuiet)
SlashCmdList.PANORAMA("blackbars 10")
SlashCmdList.PANORAMA("GRAIN 15")
assert(nsQuiet.db.filters.letterbox == 10 and nsQuiet.db.filters.grain == 15, "filtres réglés par commande")
SlashCmdList.PANORAMA("grain off")
assert(nsQuiet.db.filters.grain == 0, "grain off : 0")
nsQuiet.Undo()
assert(nsQuiet.db.filters.grain == 15, "commande de filtre annulable")
Capture(function() SlashCmdList.PANORAMA("blackbars 50") end)
assert(captured[1] == quietL.PREFIX .. quietL.MSG_FILTER_RANGE:format("blackbars", 20, "blackbars")
    and nsQuiet.db.filters.letterbox == 10, "valeur hors bornes refusée")
Capture(function() SlashCmdList.PANORAMA("vignette") end)
assert(captured[1] == quietL.PREFIX .. quietL.MSG_FILTER_RANGE:format("vignette", 100, "vignette"), "valeur absente")
SlashCmdList.PANORAMA("blackbars 0")
assert(nsQuiet.db.filters.letterbox == 0, "bandes retirées")
SlashCmdList.PANORAMA("grain 12")
assert(nsQuiet.db.filters.grain == 10, "valeur arrondie au pas du curseur")
-- Look de base en mode Selon le lieu : refusé (rien ne changerait à l'écran), sauf les bandes noires.
nsQuiet.db.ambiance.enabled = true
SlashCmdList.PANORAMA("grain 30")
assert(nsQuiet.db.filters.grain == 10, "grain en mode Selon le lieu : refusé")
SlashCmdList.PANORAMA("blackbars 5")
assert(nsQuiet.db.filters.letterbox == 5, "bandes sous ambiance auto")
nsQuiet.db.ambiance.enabled = false
nsQuiet.db.customFilters[1] = nsQuiet.db.customFilters[1] or {}
nsQuiet.db.filters.customFilter = 1
Capture(function() SlashCmdList.PANORAMA("vignette 30") end)
assert(captured[1] and nsQuiet.db.filters.vignette == 0, "vignette sous filtre du joueur : refusée")
nsQuiet.db.filters.customFilter = 0
-- Carte sans nom connu du jeu : libellé, pas le numéro seul.
assert(nsQuiet.ZoneName(9999) == quietL.AMBIANCE_ZONE_UNKNOWN:format(9999), "zone inconnue : nommée")
-- Erreur d'écriture à la déconnexion : rattrapée, repère gardé pour la session suivante.
mapID = 1426
local nsLogout = Load({ schema = 2, values = { farclip = 3000 },
                        ambiance = { zones = { [1426] = { viewDistance = 1 } } } }, { farclip = "3000" })
handler(frame, "PLAYER_LOGIN")
handler(frame, "VARIABLES_LOADED")
handler(frame, "PLAYER_ENTERING_WORLD")
table.remove(timers, 1).callback()
assert(cvars.farclip == "400" and PanoramaDB.placePreset ~= nil, "lieu posé avant la déconnexion")
C_CVar.SetCVar = function() error("écriture impossible") end
local loggedOut = pcall(handler, frame, "PLAYER_LOGOUT")
C_CVar.SetCVar = storeCVar
assert(loggedOut and PanoramaDB.placePreset ~= nil, "erreur à la déconnexion rattrapée, repère gardé")
assert(nsLogout.db == PanoramaDB)

io.write("ok\n")
