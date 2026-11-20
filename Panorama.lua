-- Panorama : liste des réglages, sauvegarde et écriture des CVars.
-- Le panneau d'options est dans Options.lua.
local addonName, NS = ...

-- Langue de Panorama : NS.language, celle du client jusqu'à ADDON_LOADED, qui lit PanoramaDB.locale.
-- enUS pour toute clé non traduite. Les traductions sont dans Locale/.
NS.language = GetLocale()
local L = setmetatable({}, { __index = function(_, key)
    local locale = NS.locales[NS.language]
    return locale and locale[key] or NS.locales.enUS[key]
end })
NS.L = L

-- Une ligne sans `cvar` est un titre de section. Libellé et bulle d'aide : L[cvar] et L[cvar .. "_tip"].
-- `title`, `menu`, `names` et les `label` de NS.presets sont des clés de locale (voir Localize).
-- Les bornes min/max sont celles du curseur du panneau. Une valeur posée hors bornes par
-- /console est gardée et réappliquée telle quelle.
-- Une CVar inconnue du client est ignorée : ni affichée, ni écrite.
-- `levels` : valeurs des préréglages, dans l'ordre de NS.presets. Sans `levels`, un préréglage
-- ne touche pas au réglage (caméra, souris, confort).
-- Bas, Moyen, Élevé : valeurs écrites par les niveaux Bas, Moyen, Élevé du menu Graphismes
-- (relevé en jeu 2026-11-14), pour les CVars présentes sur Forever ; celles absentes du client
-- (horizonfarclip, detailDoodleDensity, shadowLevel, SSFX, gxMultisample) gardent des valeurs
-- estimées. Extra : Élevé, et farclip 7000.
-- `tab` (titre de section) : onglet de la fenêtre, parmi NS.tabs. `requires` : réglage grisé tant que
-- la CVar nommée est coupée (false ou 0).
-- `menu` : option du jeu qui écrit aussi la CVar (relevé dans le source 1.60.1.70862, ticket #12).
-- Le menu natif ne relit pas les CVars : après Panorama, il peut afficher un autre niveau.
NS.settings = {
    { title = "SECTION_VIEW", tab = "quality" },
    { cvar = "farclip", menu = "MENU_VIEW_DISTANCE", min = 185, max = 10000, step = 5, default = 1300, levels = { 400, 800, 2600, 7000 } },
    { cvar = "horizonfarclip", menu = "MENU_VIEW_DISTANCE", min = 1000, max = 5000, step = 8, default = 2112, levels = { 1304, 1704, 2112, 5000 } },
    { cvar = "volumeFog", default = false, levels = { false, false, true, true } },
    -- Défaut 3 relevé en jeu (1.60.1.70790). La CVar accepte 0-4 ; plafond 3 à la demande, imposé
    -- (`hardMax`) : le jeu la repasse parfois à 4, que le curseur ne sait pas afficher.
    { cvar = "volumeFogLevel", requires = "volumeFog", min = 0, max = 3, hardMax = true, step = 1, default = 3, levels = { 0, 1, 3, 3 } },

    { title = "SECTION_VEGETATION", tab = "quality" },
    { cvar = "detailDoodleDensity", menu = "MENU_ENVIRONMENT", min = 0, max = 100, step = 1, default = 100, levels = { 25, 50, 75, 100 } },
    { cvar = "groundEffectDensity", menu = "MENU_GROUND_CLUTTER", min = 16, max = 256, step = 8, default = 256, levels = { 32, 96, 256, 256 } },
    { cvar = "groundEffectDist", menu = "MENU_GROUND_CLUTTER", min = 0, max = 300, step = 5, default = 140, levels = { 40, 80, 300, 300 } },

    { title = "SECTION_SHADOWS", tab = "quality" },
    { cvar = "shadowLevel", menu = "MENU_SHADOWS", min = 0, max = 2, step = 1, default = 2, levels = { 0, 1, 2, 2 } },
    { cvar = "shadowSoft", menu = "MENU_SHADOWS", default = true, levels = { false, false, true, true } },
    { cvar = "shadowTextureSize", menu = "MENU_SHADOWS", choices = { 1024, 2048 }, default = 2048, levels = { 1024, 1024, 2048, 2048 } },
    { cvar = "sunShafts", min = 0, max = 2, step = 1, default = 2, levels = { 0, 1, 2, 2 } },
    { cvar = "SSAO", menu = "MENU_SSAO", min = 0, max = 3, step = 1, default = 3, levels = { 0, 1, 3, 3 } },
    { cvar = "SSFX", default = true, levels = { false, true, true, true } },

    { title = "SECTION_ENVIRONMENT", tab = "quality" },
    -- waterDetail 3 fait planter le client à l'entrée des Ruines de Lordaeron (signalé par un joueur) :
    -- plafond 2, imposé même à une valeur sauvegardée ou posée par /console (`hardMax`).
    { cvar = "waterDetail", menu = "MENU_LIQUID", min = 0, max = 2, hardMax = true, step = 1, default = 2, levels = { 0, 1, 2, 2 } },
    { cvar = "skyCloudLod", min = 0, max = 3, step = 1, default = 3, levels = { 0, 1, 3, 3 } },
    { cvar = "WeatherDensity", min = 0, max = 3, step = 1, default = 3, levels = { 0, 1, 3, 3 } },
    -- Le menu natif demande de relancer le client (ClientRestart, Graphics.lua:1427, 1.60.1.70862).
    { cvar = "physicsLevel", menu = "MENU_PHYSICS", restart = "client", min = 0, max = 2, step = 1, default = 2, levels = { 0, 1, 2, 2 } },

    { title = "SECTION_IMAGE", tab = "quality" },
    { cvar = "gxMultisample", menu = "MENU_MSAA", restart = true, choices = { 1, 2, 4, 8 }, default = 8, levels = { 1, 1, 4, 8 } },
    { cvar = "ResampleAlwaysSharpen", default = true },
    -- Sens inverse du nom : 0 = netteté la plus forte, 2 = la plus faible (menu natif, 1.60.1.70938).
    { cvar = "ResampleSharpness", menu = "MENU_SHARPNESS", min = 0, max = 2, step = 0.1, default = 0.5 },
    -- Valeurs relevées en jeu (1.60.1.70790) : 0 auto, 1 aucun, 2 intégré, 3 Reflex, 4 Reflex + Boost, 5 XeLL.
    { cvar = "LowLatencyMode", menu = "MENU_LOW_LATENCY", min = 0, max = 5, step = 1, default = 0,
      names = { [0] = "LATENCY_AUTO", "OPT_OFF", "LATENCY_BUILTIN", "Reflex", "Reflex + Boost", "XeLL" } },
    { cvar = "ffxGlow", default = true, levels = { false, true, true, true } },
    { cvar = "ffxDeath", default = false },
    { cvar = "violenceLevel", min = 0, max = 5, step = 1, default = 5 },
    { cvar = "ProjectedTextures", menu = "MENU_PROJECTED", default = true, levels = { false, true, true, true } },
    { cvar = "spellClutter", menu = "MENU_SPELL_DENSITY", default = false, levels = { true, false, false, false } },

    -- HDR : absent des menus et de l'interface Blizzard Forever. Défauts relevés en jeu (2026-11-15).
    -- Sans useHDRPeakBrightness ou useHDRBrightness, HDROutput seul assombrit l'image (forum
    -- Blizzard) ; HDRFactor actif seulement sous useHDRPeakBrightness. Bornes des curseurs choisies par
    -- Panorama, celles du moteur non relevées.
    { title = "SECTION_HDR", tab = "advanced" },
    { cvar = "HDROutput", advanced = true, default = false },
    { cvar = "useHDRPeakBrightness", advanced = true, default = false },
    { cvar = "HDRPeakBrightness", requires = "useHDRPeakBrightness", advanced = true, min = 80, max = 2000, step = 10, default = 400 },
    { cvar = "HDRFactor", requires = "useHDRPeakBrightness", advanced = true, min = 0, max = 2, step = 0.1, default = 2 },
    { cvar = "useHDRBrightness", advanced = true, default = false },
    { cvar = "HDRBrightness", requires = "useHDRBrightness", advanced = true, min = 80, max = 1000, step = 1, default = 203 },

    { title = "SECTION_CAMERA", tab = "interface" },
    -- Max du curseur : relevés joueurs (/console accepte 4, et farclip 10000 gardé par le jeu). Le menu Forever
    -- borne la caméra à 2.0 (ControlsOverrides.lua) ; aucune borne Lua pour farclip.
    { cvar = "cameraDistanceMaxZoomFactor", menu = "MENU_CAMERA", min = 1, max = 4, step = 0.1, default = 2.6 },
    { cvar = "rawMouseEnable", default = true },
    { cvar = "screenshotQuality", min = 1, max = 10, step = 1, default = 10 },
    -- Absente du menu Forever. `advanced` : défaut lu dans le jeu (NS.GameDefault).
    -- cameraZoomSpeed : lue par Blizzard_GamepadTargeting/TargetLogic.lua.
    -- cameraZoomSpeed : le moteur accepte 1 à 50 (relevé 1.60.1.70938).
    { cvar = "cameraZoomSpeed", advanced = true, min = 1, max = 50, step = 1, default = 20 },
    -- Barres de vie, taille du texte, texte de combat flottant : retirés. Une CVar touchée est
    -- réécrite à chaque connexion, par-dessus les addons d'interface qui gèrent ces réglages.

    -- Réglables seulement par /console : absentes des menus du jeu (relevé dans Config.wtf et
    -- BlizzardInterfaceCode). `advanced` : défaut lu dans le jeu, comme plus haut.
    -- Bornes relevées en jeu (1.60.1.70938) : le moteur refuse une valeur hors bornes et garde
    -- l'ancienne. reflectionMode accepte 0 à 4, effet de 4 non vu : curseur à 3.
    -- rippleDetail max 2, particleMTDensity max 100. LOD et doodadLodScale : aucune borne moteur,
    -- maximum du curseur choisi par Panorama.
    { title = "SECTION_ADVANCED", tab = "advanced" },
    { cvar = "reflectionMode", menu = "MENU_LIQUID", advanced = true, min = 0, max = 3, step = 1, default = 0 },
    { cvar = "rippleDetail", menu = "MENU_LIQUID", advanced = true, min = 0, max = 2, step = 1, default = 0 },
    { cvar = "terrainLodDist", menu = "MENU_ENVIRONMENT", advanced = true, min = 50, max = 1000, step = 10, default = 200 },
    { cvar = "wmoLodDist", menu = "MENU_ENVIRONMENT", advanced = true, min = 50, max = 1000, step = 10, default = 250 },
    { cvar = "entityLodDist", menu = "MENU_ENVIRONMENT", advanced = true, min = 1, max = 50, step = 1, default = 5 },
    { cvar = "doodadLodScale", menu = "MENU_ENVIRONMENT", advanced = true, min = 0, max = 100, step = 5, default = 50 },
    -- Absentes du source UI ; défauts relevés en jeu (1.60.1.70790) : 15, 100, 800, 70. Bornes et sens
    -- non relevés : curseurs choisis par Panorama.
    { cvar = "lodObjectCullSize", advanced = true, min = 0, max = 100, step = 1, default = 15 },
    { cvar = "lodObjectFadeScale", advanced = true, min = 25, max = 400, step = 5, default = 100 },
    { cvar = "horizonStart", advanced = true, min = 100, max = 5000, step = 50, default = 800 },
    { cvar = "groundEffectFade", advanced = true, min = 0, max = 310, step = 5, default = 70 },
    { cvar = "particleMTDensity", menu = "MENU_PARTICLES", advanced = true, min = 10, max = 100, step = 5, default = 20 },
    { cvar = "DepthBasedOpacity", advanced = true, default = false },
}

-- Onglets de la fenêtre, dans l'ordre. Le premier est ouvert au premier lancement.
NS.tabs = { "quality", "filters", "ambiance", "interface", "advanced" }

NS.presets = {
    { id = "low", label = "PRESET_LOW" },
    { id = "medium", label = "PRESET_MEDIUM" },
    { id = "high", label = "PRESET_HIGH" },
    { id = "extra", label = "PRESET_EXTRA" },
}

-- Nom de CVar en minuscules -> réglage, pour l'événement CVAR_UPDATE.
local settingsByCVar = {}
for _, setting in ipairs(NS.settings) do
    if setting.cvar then
        settingsByCVar[setting.cvar:lower()] = setting
    end
end

-- Les tables de réglages portent des clés de locale (titre, menu, noms de valeur, préréglages) :
-- traduites une fois à ADDON_LOADED, quand la langue choisie est connue. `idField` : cvar ou key.
local function Localize(settings, idField)
    for _, setting in ipairs(settings) do
        if setting.title then setting.titleKey, setting.title = setting.title, L[setting.title] end
        if setting.menu then setting.menu = L[setting.menu] end
        -- Nom sans clé de locale ("Reflex") : gardé tel quel.
        for value, key in pairs(setting.names or {}) do setting.names[value] = L[key] or key end
        local id = setting[idField]
        if id then setting.label, setting.tip = L[id], L[id .. "_tip"] end
    end
end

local function GetCVarValue(name)
    return C_CVar.GetCVar(name)
end

local function SetCVarValue(name, value)
    return C_CVar.SetCVar(name, value)
end

function NS.Exists(setting)
    return GetCVarValue(setting.cvar) ~= nil
end

-- Valeur actuelle de la CVar, au type du réglage (booléen ou nombre), non bornée.
local function ReadCVar(setting)
    local raw = GetCVarValue(setting.cvar)
    if type(setting.default) == "boolean" then return raw ~= "0" end
    return tonumber(raw)
end

-- Valide le type d'une valeur lue dans PanoramaDB ou dans le jeu (pas de borne min/max).
function NS.Sanitize(setting, value)
    if type(setting.default) == "boolean" then
        if type(value) ~= "boolean" then return setting.default end
        return value
    end
    if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then return setting.default end
    if setting.choices then
        for _, choice in ipairs(setting.choices) do
            if choice == value then return value end
        end
        -- Valeur du jeu hors liste (/console, Config.wtf) : gardée telle quelle, aucun choix coché.
        if value == ReadCVar(setting) then return value end
        return setting.default
    end
    -- Pas de borne min/max : une valeur posée par /console au-delà du curseur est gardée.
    -- Le moteur borne lui-même ce qu'il accepte. Sauf `hardMax` : valeur au-delà refusée.
    if setting.hardMax then return math.min(value, setting.max) end
    return value
end

-- Une écriture, même à valeur égale, peut recharger le décor ou les shaders (gel à la connexion,
-- où tous les réglages touchés sont réécrits) : n'écrire que ce qui change.
local function WriteIfChanged(name, value)
    local current = GetCVarValue(name)
    if current == value or (tonumber(current) ~= nil and tonumber(current) == tonumber(value)) then return end
    SetCVarValue(name, value)
end

-- Réglages à écrire à la sortie du combat, touchés ou non (une annulation rend un réglage au jeu).
local pending = {}
local events = CreateFrame("Frame")

function NS.Apply(setting)
    if not NS.Exists(setting) then return end
    -- Certaines CVars refusent l'écriture en combat : écrites à la sortie du combat.
    if InCombatLockdown() then
        pending[setting] = true
        events:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    local value = NS.db.values[setting.cvar]
    if type(value) == "boolean" then value = value and 1 or 0 end
    WriteIfChanged(setting.cvar, tostring(value))
end

-- Seuls les réglages modifiés dans Panorama sont réécrits : les autres suivent le jeu et son menu
-- Graphismes. Exception : une valeur du jeu au-delà de `hardMax` est toujours ramenée au maximum.
-- `capOnly` : seulement le plafond `hardMax` (premier lancement, réapplication coupée).
function NS.ApplyAll(capOnly)
    for _, setting in ipairs(NS.settings) do
        if setting.cvar and ((not capOnly and NS.db.touched[setting.cvar])
                or (setting.hardMax and NS.Exists(setting) and (ReadCVar(setting) or 0) > setting.max)) then
            NS.Apply(setting)
        end
    end
end

-- Valeur par défaut du jeu pour les CVars aux bornes ou défauts estimés (avancées) ; repli sur
-- setting.default si le client ne la donne pas.
function NS.GameDefault(setting)
    if setting.advanced then
        local raw = GetCVarDefault(setting.cvar)
        if type(setting.default) == "boolean" then
            if raw ~= nil then return raw == "1" or raw == "true" end
        else
            local number = tonumber(raw)
            if number then return math.max(setting.min, math.min(number, setting.max)) end
        end
    end
    return setting.default
end

-- Vrai pendant un préréglage ou une annulation : le panneau est rafraîchi une fois, à la fin.
local batching = false

-- Le client peut refuser ou arrondir une valeur sans erreur (rendu, matériel, CVar protégée) :
-- un changement du joueur est relu après l'écriture, pour que le panneau montre ce que le jeu
-- applique. Pas à la connexion, où un refus passager effacerait la valeur gardée.
-- Changé en combat : relu à la sortie du combat, après l'écriture différée.
local readBackAfterCombat = {}
-- Intensité météo changée : l'ambiance météo apparaît ou disparaît (Ambiance.lua), filtres reposés.
local function RefreshWeatherAmbiance(setting)
    if setting.cvar == "WeatherDensity" and NS.db.ambiance.enabled then NS.ApplyFilters() end
end
local function ReadBack(setting)
    if NS.Exists(setting) then NS.db.values[setting.cvar] = NS.Sanitize(setting, ReadCVar(setting)) end
end

-- Appelé à chaque changement du joueur (panneau, préréglage, annulation) : NS.db.values est
-- déjà à jour. Le panneau relit les valeurs pour que ses contrôles suivent.
function NS.Change(setting)
    NS.db.touched[setting.cvar] = true
    NS.Apply(setting)
    if InCombatLockdown() then readBackAfterCombat[setting] = true else ReadBack(setting) end
    RefreshWeatherAmbiance(setting)
    if NS.RefreshOptions and not batching then NS.RefreshOptions() end
end

local function SetValue(setting, value)
    NS.db.values[setting.cvar] = value
    NS.Change(setting)
end

-- Valeurs d'avant le dernier préréglage, gardées dans PanoramaDB.undo, et réglages touchés à ce
-- moment dans PanoramaDB.undoTouched : l'annulation rend aussi au jeu ceux qu'il gérait.
function NS.CanUndo()
    return NS.db.undo ~= nil
end

function NS.ApplyPreset(index)
    NS.db.undo = {}
    NS.db.undoTouched = {}
    for cvar, value in pairs(NS.db.values) do NS.db.undo[cvar] = value end
    for cvar, touched in pairs(NS.db.touched) do NS.db.undoTouched[cvar] = touched end
    batching = true
    for _, setting in ipairs(NS.settings) do
        if setting.levels and NS.Exists(setting) then
            SetValue(setting, NS.Sanitize(setting, setting.levels[index]))
        end
    end
    batching = false
    if NS.RefreshOptions then NS.RefreshOptions() end
    print(L.PREFIX .. L.MSG_PRESET:format(NS.presets[index].label))
end

function NS.Undo()
    if not NS.db.undo then
        print(L.PREFIX .. L.MSG_NOTHING_TO_UNDO)
        return
    end
    local values, touched = NS.db.undo, NS.db.undoTouched
    NS.db.undo, NS.db.undoTouched = nil, nil
    batching = true
    for _, setting in ipairs(NS.settings) do
        if setting.cvar and setting.levels and values[setting.cvar] ~= nil and NS.Exists(setting) then
            SetValue(setting, NS.Sanitize(setting, values[setting.cvar]))
            if touched then NS.db.touched[setting.cvar] = touched[setting.cvar] end
        end
    end
    batching = false
    if NS.RefreshOptions then NS.RefreshOptions() end
    print(L.PREFIX .. L.MSG_UNDONE)
end

-- Remise à zéro complète : chaque CVar modifiée dans Panorama à son défaut (NS.GameDefault), puis
-- rendue au jeu (plus réécrite à la connexion) ; les autres suivent déjà le jeu et restent telles
-- quelles. Chaque filtre à son défaut, ambiance coupée et remise aux valeurs livrées, zones
-- oubliées. Efface aussi l'annulation de préréglage.
function NS.ResetAll()
    NS.db.undo, NS.db.undoTouched = nil, nil
    local restartNote = ""
    batching = true
    for _, setting in ipairs(NS.settings) do
        if setting.cvar and NS.db.touched[setting.cvar] and NS.Exists(setting) then
            local default = NS.GameDefault(setting)
            if setting.restart and NS.db.values[setting.cvar] ~= default then
                if setting.restart == "client" then
                    restartNote = " " .. L.OPT_NEEDS_CLIENT_RESTART
                elseif restartNote == "" then
                    restartNote = " " .. L.OPT_NEEDS_RESTART
                end
            end
            SetValue(setting, default)
            NS.db.touched[setting.cvar] = nil
        end
    end
    batching = false
    for _, setting in ipairs(NS.filterSettings) do
        if setting.key then NS.db.filters[setting.key] = setting.default end
    end
    NS.db.ambiance = nil
    NS.LoadAmbiance(NS.db)
    NS.ApplyFilters()
    if NS.RefreshOptions then NS.RefreshOptions() end
    print(L.PREFIX .. L.MSG_RESET_ALL .. restartNote)
end

function NS.RestartGraphics()
    ConsoleExec("gxRestart")
end

-- Réglage qui suit le jeu : jamais touché dans Panorama, ou réapplication coupée.
local function FollowsGame(db, setting)
    return not db.applyOnLogin or not db.touched[setting.cvar]
end

events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
-- Le client charge encore des CVars après PLAYER_LOGIN (stockées serveur, posées par l'interface
-- par défaut) : VARIABLES_LOADED n'a pas d'ordre garanti, parfois après PLAYER_ENTERING_WORLD
-- (warcraft.wiki.gg). Deuxième passe une fois les deux reçus, avant d'écouter CVAR_UPDATE.
-- VARIABLES_LOADED part bien sur Forever : le panneau Settings de Blizzard l'attend aussi
-- (Blizzard_SettingsRegistrar.lua, source 1.60.1.70862).
events:RegisterEvent("VARIABLES_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
-- Ambiance (Ambiance.lua) : contexte relu à chaque changement de zone, d'intérieur ou de météo.
local AMBIANCE_EVENTS = { ZONE_CHANGED = true, ZONE_CHANGED_INDOORS = true, ZONE_CHANGED_NEW_AREA = true,
                          WEATHER_CHANGED = true, DIEL_CYCLE_CHANGED = true }
-- pcall : DIEL_CYCLE_CHANGED (bascule jour/nuit du jeu) absent d'un build = minuteur de 60 s seul.
for event in pairs(AMBIANCE_EVENTS) do pcall(events.RegisterEvent, events, event) end
local firstRun = false
local variablesLoaded, enteredWorld, loginSettled = false, false, false
-- Délai après PLAYER_LOGIN avant la passe finale : le client peut encore changer des CVars après
-- l'entrée dans le monde. KelaGraphics attend 4 s avant de comparer ses valeurs, puis 0,35 s avant
-- de les réécrire.
local LOGIN_SETTLE_SECONDS = 4.35

-- Fin du chargement : les réglages qui suivent le jeu relisent sa valeur définitive, les réglages
-- touchés sont réécrits par-dessus ce que le client a chargé, puis CVAR_UPDATE est écouté.
-- Écouté plus tôt, il enregistrerait dans PanoramaDB les valeurs chargées par le client.
local function FinishLoading()
    events:UnregisterEvent("VARIABLES_LOADED")
    events:UnregisterEvent("PLAYER_ENTERING_WORLD")
    for _, setting in ipairs(NS.settings) do
        if setting.cvar and NS.Exists(setting) and FollowsGame(NS.db, setting) then
            NS.db.values[setting.cvar] = NS.Sanitize(setting, ReadCVar(setting))
        end
    end
    NS.ApplyAll(not NS.db.applyOnLogin or firstRun)
    events:RegisterEvent("CVAR_UPDATE")
    if NS.RefreshOptions then NS.RefreshOptions() end
end
events:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        firstRun = type(PanoramaDB) ~= "table" or type(PanoramaDB.values) ~= "table"
        PanoramaDB = type(PanoramaDB) == "table" and PanoramaDB or {}
        local db = PanoramaDB
        -- Langue choisie dans la fenêtre ; absente ou inconnue : langue du client.
        if db.locale ~= nil and not NS.locales[db.locale] then db.locale = nil end
        NS.language = db.locale or GetLocale()
        Localize(NS.settings, "cvar")
        if NS.filterSettings then Localize(NS.filterSettings, "key") end
        for _, preset in ipairs(NS.presets) do preset.label = L[preset.label] end
        if type(db.values) ~= "table" then db.values = {} end
        if db.applyOnLogin == nil then db.applyOnLogin = true end
        if type(db.touched) ~= "table" then db.touched = {} end
        -- Avant le schéma 2, tout réglage non avancé était réécrit à la connexion. Migration : un
        -- réglage dont la valeur sauvegardée diffère du jeu est marqué touché, pour la garder.
        -- Réapplication coupée : rien n'était réécrit, rien à garder.
        local migrate = not firstRun and db.schema ~= 2 and db.applyOnLogin
        db.schema = 2
        if type(db.undo) ~= "table" then db.undo = nil end
        if type(db.undoTouched) ~= "table" then db.undoTouched = nil end
        -- Fenêtre à onglets (layout 2) : sections toutes dépliées, l'ancien « Avancé replié » tombe une fois.
        if type(db.collapsed) ~= "table" or db.layout ~= 2 then db.collapsed = {} end
        db.layout = 2
        local knownTab = false
        for _, tab in ipairs(NS.tabs) do knownTab = knownTab or db.tab == tab end
        if not knownTab then db.tab = NS.tabs[1] end
        if type(db.minimap) ~= "table" then db.minimap = {} end
        if type(db.minimap.angle) ~= "number" then db.minimap.angle = 200 end
        if type(db.minimap.show) ~= "boolean" then db.minimap.show = true end
        for _, setting in ipairs(NS.settings) do
            if setting.cvar then
                local value = db.values[setting.cvar]
                if migrate and not setting.advanced and value ~= nil and NS.Exists(setting) then
                    local saved, game = NS.Sanitize(setting, value), NS.Sanitize(setting, ReadCVar(setting))
                    -- Curseur arrondi (0.30000000000000004) contre CVar relue ("0.3") : écart sous le pas.
                    if type(saved) == "number" and math.abs(saved - game) >= (setting.step or 1) / 2
                            or type(saved) == "boolean" and saved ~= game then
                        db.touched[setting.cvar] = true
                    end
                end
                -- Premier lancement, réapplication coupée, ou réglage jamais touché dans Panorama :
                -- on part des valeurs actuelles du jeu.
                if NS.Exists(setting) and (value == nil or FollowsGame(db, setting)) then
                    value = ReadCVar(setting)
                end
                db.values[setting.cvar] = NS.Sanitize(setting, value)
            end
        end
        -- Posé avant les modules : une erreur de chargement des filtres ne laisse pas NS.db vide.
        NS.db = db
        if NS.LoadFilters then NS.LoadFilters(db) end
        if NS.LoadAmbiance then NS.LoadAmbiance(db) end
        if NS.BuildOptions then NS.BuildOptions() end
        if NS.BuildMinimapButton then NS.BuildMinimapButton() end
    elseif event == "PLAYER_LOGIN" then
        -- Réécrit les réglages modifiés dans Panorama, au cas où le jeu les aurait changés entre-temps
        -- (Config.wtf, détection automatique). Premier lancement : les valeurs viennent du jeu, rien à écrire.
        -- Le plafond `hardMax` est écrit dans tous les cas.
        NS.ApplyAll(not NS.db.applyOnLogin or firstRun)
        C_Timer.After(LOGIN_SETTLE_SECONDS, function()
            loginSettled = true
            -- Passe finale d'abord : une erreur de détection d'ambiance ne la bloque pas.
            if variablesLoaded and enteredWorld and NS.db then FinishLoading() end
            -- Carte parfois inconnue au PLAYER_LOGIN : biome relu une fois le monde chargé.
            if NS.StartAmbiance then NS.StartAmbiance(); NS.UpdateAmbiance() end
        end)
        -- Les filtres ne sont pas des CVars : toujours reposés, réapplication coupée ou non.
        if NS.ApplyFilters then NS.ApplyFilters() end
    elseif AMBIANCE_EVENTS[event] then
        if NS.db and NS.UpdateAmbiance then NS.UpdateAmbiance() end
    elseif event == "VARIABLES_LOADED" or event == "PLAYER_ENTERING_WORLD" then
        if event == "VARIABLES_LOADED" then variablesLoaded = true else enteredWorld = true end
        if variablesLoaded and enteredWorld and loginSettled and NS.db then FinishLoading() end
    elseif event == "CVAR_UPDATE" then
        -- Changement venu du menu Graphismes ou de /console : le panneau suit la vraie valeur.
        local setting = NS.db and type(arg1) == "string" and settingsByCVar[arg1:lower()]
        if setting then
            NS.db.values[setting.cvar] = NS.Sanitize(setting, ReadCVar(setting))
            -- Au-delà du plafond `hardMax` (menu du jeu, /console) : ramenée au maximum.
            if setting.hardMax and (ReadCVar(setting) or 0) > setting.max then NS.Apply(setting) end
            RefreshWeatherAmbiance(setting)
            if NS.RefreshOptions and not batching then NS.RefreshOptions() end
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        local settings = pending
        pending = {}
        for setting in pairs(settings) do NS.Apply(setting) end
        local readBack = readBackAfterCombat
        readBackAfterCombat = {}
        for setting in pairs(readBack) do ReadBack(setting) end
        if next(readBack) and NS.RefreshOptions then NS.RefreshOptions() end
    end
end)

SLASH_PANORAMA1 = "/pano"
SLASH_PANORAMA2 = "/panorama"
SlashCmdList.PANORAMA = function(message)
    local command = strtrim(message or ""):lower()
    if command == "apply" then
        NS.ApplyAll()
        if InCombatLockdown() then
            print(L.PREFIX .. L.MSG_APPLIED_AFTER_COMBAT)
        else
            -- Valeur refusée ou arrondie par le jeu : le panneau montre ce qui est appliqué.
            for _, setting in ipairs(NS.settings) do
                if setting.cvar and NS.db.touched[setting.cvar] then ReadBack(setting) end
            end
            if NS.RefreshOptions then NS.RefreshOptions() end
            print(L.PREFIX .. L.MSG_APPLIED)
        end
    elseif command == "restart" then
        NS.RestartGraphics()
    elseif command == "undo" then
        NS.Undo()
    elseif command == "reset" then
        NS.ResetAll()
    elseif command == "status" then
        NS.PrintStatus()
    elseif command == "minimap" then
        NS.db.minimap.show = not NS.db.minimap.show
        if NS.UpdateMinimapButton then NS.UpdateMinimapButton() end
    elseif command ~= "" then
        for index, preset in ipairs(NS.presets) do
            if preset.id == command then return NS.ApplyPreset(index) end
        end
        print(L.PREFIX .. L.MSG_UNKNOWN_COMMAND)
    elseif NS.OpenOptions then
        NS.OpenOptions()
    end
end
