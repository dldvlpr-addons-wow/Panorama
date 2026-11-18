-- Vérification hors du jeu : lua tests/run_tests.lua (depuis la racine de l'addon).
local cvars, combat, handler, written
C_CVar = {
    GetCVar = function(name) return cvars[name] end,
    SetCVar = function(name, value) cvars[name] = value; written[#written + 1] = name end,
}
InCombatLockdown = function() return combat end
-- Minuteries gardées sans être lancées : le test les déclenche lui-même.
local timers = {}
C_Timer = { After = function(delay, callback) timers[#timers + 1] = { delay = delay, callback = callback } end }
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
CreateColor = function(r, g, b, a) return { r = r, g = g, b = b, a = a } end
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
-- `also` : userFontScaleGlue suit userFontScale.
cvars.userFontScale, cvars.userFontScaleGlue = "1", "1"
for _, setting in ipairs(ns2.settings) do
    if setting.cvar == "userFontScale" then
        PanoramaDB.values.userFontScale = 1.5
        ns2.Change(setting)
    end
end
assert(cvars.userFontScale == "1.5" and cvars.userFontScaleGlue == "1.5", "userFontScaleGlue écrite aussi")
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
          GetMapInfo = function(id) return parents[id] and { mapID = id, parentMapID = parents[id] } end }
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
mapID = 1427
weather.type = 2
assert(Detect() == "snow night", "météo avant le biome")
cvars.WeatherDensity = "0"
assert(Detect() == "volcanic night", "effets météo coupés : pas d'ambiance météo")
cvars.WeatherDensity = nil
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
assert(applied.tint == 0 and applied.tintStrength == 30 and applied.sky == 4 and applied.skyStrength == 45,
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
PanoramaDB.filters.autoDayNight = false
nsDay.ApplyFilters()
assert(frame.shown == false, "auto coupé : teinte de jour Aucune, calque caché")
isDayTime = nil

-- Fenêtre : onglet invalide remis au premier, sections dépliées par défaut.
local ns4 = Load({ tab = "inconnu" })
assert(PanoramaDB.tab == "quality" and next(PanoramaDB.collapsed) == nil, "onglet et sections par défaut")
Load({ tab = "filters" })
assert(PanoramaDB.tab == "filters", "onglet retenu")
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
PanoramaDB.filters.autoDayNight = false
assert(not ns4.IsAvailable(strengthSetting), "intensité de nuit grisée sans jour/nuit")
-- Ambiance auto : ses filtres de base grisés dans l'onglet Filtres, pas dans l'éditeur.
ns4.db.ambiance.enabled = true
assert(not ns4.IsAvailable({ key = "vignette" }), "vignette suit l'ambiance")
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
    and de.filterSettings[1].title == de.locales.deDE.SECTION_FILTERS and tint.names[1] == de.locales.deDE.TINT_SEPIA
    and tint.label == de.locales.deDE.tint, "langue choisie appliquée")
local lowLatency
for _, setting in ipairs(de.settings) do if setting.cvar == "LowLatencyMode" then lowLatency = setting end end
assert(lowLatency.names[0] == de.locales.deDE.LATENCY_AUTO and lowLatency.names[3] == "Reflex", "noms de valeur traduits")
local unknown = Load({ locale = "xxXX" })
assert(PanoramaDB.locale == nil and unknown.presets[3].label == "Élevé", "langue inconnue : langue du client")

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
-- Tout réinitialiser : réglages rendus au jeu, filtres et ambiance par défaut, plus rien à annuler.
local nsReset = Load(nil)
SlashCmdList.PANORAMA("low")
PanoramaDB.filters.vignette, PanoramaDB.ambiance.enabled, PanoramaDB.ambiance.zones[1] = 50, true, {}
SlashCmdList.PANORAMA("reset")
assert(next(PanoramaDB.touched) == nil and not nsReset.CanUndo(), "reset : réglages rendus au jeu")
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

io.write("ok\n")
