-- Panorama : liste des réglages, sauvegarde et écriture des CVars.
-- Le panneau d'options est dans Options.lua.
local addonName, NS = ...

-- Langue du client, enUS pour toute clé non traduite. Les traductions sont dans Locale/.
local L = NS.locales[GetLocale()] or NS.locales.enUS
if L ~= NS.locales.enUS then setmetatable(L, { __index = NS.locales.enUS }) end
NS.L = L

-- Une ligne sans `cvar` est un titre de section. Libellé et bulle d'aide : L[cvar] et L[cvar .. "_tip"].
-- Les bornes min/max sont celles du curseur du panneau. Une valeur posée hors bornes par
-- /console est gardée et réappliquée telle quelle.
-- Une CVar inconnue du client est ignorée : ni affichée, ni écrite.
-- `levels` : valeurs des préréglages, dans l'ordre de NS.presets. Sans `levels`, un préréglage
-- ne touche pas au réglage (caméra, souris, confort).
-- Bas, Moyen, Élevé : valeurs écrites par les niveaux Bas, Moyen, Élevé du menu Graphismes
-- (relevé en jeu 2026-11-14), pour les CVars présentes sur Forever ; celles absentes du client
-- (horizonfarclip, detailDoodleDensity, shadowLevel, SSFX, gxMultisample) gardent des valeurs
-- estimées. Extra : Élevé, et farclip au maximum du curseur.
-- `menu` : option du jeu qui écrit aussi la CVar (relevé dans le source 1.60.1.70862, ticket #12).
-- Le menu natif ne relit pas les CVars : après Panorama, il peut afficher un autre niveau.
NS.settings = {
    { title = L.SECTION_VIEW },
    { cvar = "farclip", menu = L.MENU_VIEW_DISTANCE, min = 185, max = 7000, step = 5, default = 1300, levels = { 400, 800, 2600, 7000 } },
    { cvar = "horizonfarclip", menu = L.MENU_VIEW_DISTANCE, min = 1000, max = 5000, step = 8, default = 2112, levels = { 1304, 1704, 2112, 5000 } },
    { cvar = "volumeFog", default = false, levels = { false, false, true, true } },
    -- Défaut 3 relevé en jeu (1.60.1.70790). La CVar accepte 0-4 ; curseur plafonné à 3 à la demande.
    { cvar = "volumeFogLevel", min = 0, max = 3, step = 1, default = 3, levels = { 0, 1, 3, 3 } },

    { title = L.SECTION_VEGETATION },
    { cvar = "detailDoodleDensity", menu = L.MENU_ENVIRONMENT, min = 0, max = 100, step = 1, default = 100, levels = { 25, 50, 75, 100 } },
    { cvar = "groundEffectDensity", menu = L.MENU_GROUND_CLUTTER, min = 16, max = 256, step = 8, default = 256, levels = { 32, 96, 256, 256 } },
    { cvar = "groundEffectDist", menu = L.MENU_GROUND_CLUTTER, min = 0, max = 300, step = 5, default = 140, levels = { 40, 80, 300, 300 } },

    { title = L.SECTION_SHADOWS },
    { cvar = "shadowLevel", menu = L.MENU_SHADOWS, min = 0, max = 2, step = 1, default = 2, levels = { 0, 1, 2, 2 } },
    { cvar = "shadowSoft", menu = L.MENU_SHADOWS, default = true, levels = { false, false, true, true } },
    { cvar = "shadowTextureSize", menu = L.MENU_SHADOWS, choices = { 1024, 2048 }, default = 2048, levels = { 1024, 1024, 2048, 2048 } },
    { cvar = "sunShafts", min = 0, max = 2, step = 1, default = 2, levels = { 0, 1, 2, 2 } },
    { cvar = "SSAO", menu = L.MENU_SSAO, min = 0, max = 3, step = 1, default = 3, levels = { 0, 1, 3, 3 } },
    { cvar = "SSFX", default = true, levels = { false, true, true, true } },

    { title = L.SECTION_ENVIRONMENT },
    -- waterDetail 3 fait planter le client à l'entrée des Ruines de Lordaeron (signalé par un joueur) :
    -- plafond 2, imposé même à une valeur sauvegardée ou posée par /console (`hardMax`).
    { cvar = "waterDetail", menu = L.MENU_LIQUID, min = 0, max = 2, hardMax = true, step = 1, default = 2, levels = { 0, 1, 2, 2 } },
    { cvar = "skyCloudLod", min = 0, max = 3, step = 1, default = 3, levels = { 0, 1, 3, 3 } },
    { cvar = "WeatherDensity", min = 0, max = 3, step = 1, default = 3, levels = { 0, 1, 3, 3 } },
    { cvar = "physicsLevel", menu = L.MENU_PHYSICS, min = 0, max = 2, step = 1, default = 2, levels = { 0, 1, 2, 2 } },

    { title = L.SECTION_IMAGE },
    { cvar = "gxMultisample", menu = L.MENU_MSAA, restart = true, choices = { 1, 2, 4, 8 }, default = 8, levels = { 1, 1, 4, 8 } },
    { cvar = "ResampleAlwaysSharpen", default = true },
    -- Sens inverse du nom : 0 = netteté la plus forte, 2 = la plus faible (menu natif, 1.60.1.70938).
    { cvar = "ResampleSharpness", menu = L.MENU_SHARPNESS, min = 0, max = 2, step = 0.1, default = 0.5 },
    -- Valeurs relevées en jeu (1.60.1.70790) : 0 auto, 1 aucun, 2 intégré, 3 Reflex, 4 Reflex + Boost, 5 XeLL.
    { cvar = "LowLatencyMode", menu = L.MENU_LOW_LATENCY, min = 0, max = 5, step = 1, default = 0,
      names = { [0] = L.LATENCY_AUTO, L.OPT_OFF, L.LATENCY_BUILTIN, "Reflex", "Reflex + Boost", "XeLL" } },
    { cvar = "ffxGlow", default = true, levels = { false, true, true, true } },
    { cvar = "ffxDeath", default = false },
    { cvar = "violenceLevel", min = 0, max = 5, step = 1, default = 5 },
    { cvar = "ProjectedTextures", menu = L.MENU_PROJECTED, default = true, levels = { false, true, true, true } },
    { cvar = "spellClutter", menu = L.MENU_SPELL_DENSITY, default = false, levels = { true, false, false, false } },

    { title = L.SECTION_CAMERA },
    -- Max du curseur : relevé joueur (/console accepte 4 et farclip 7000). Le menu Forever
    -- borne la caméra à 2.0 (ControlsOverrides.lua) ; aucune borne Lua pour farclip.
    { cvar = "cameraDistanceMaxZoomFactor", menu = L.MENU_CAMERA, min = 1, max = 4, step = 0.1, default = 2.6 },
    { cvar = "rawMouseEnable", default = true },
    { cvar = "screenshotQuality", min = 1, max = 10, step = 1, default = 10 },
    -- Absentes du menu Forever. `advanced` : défaut lu dans le jeu (NS.GameDefault).
    -- cameraZoomSpeed : lue par Blizzard_GamepadTargeting/TargetLogic.lua.
    -- userFontScale : bornes 0.8 (TextSizeManager.lua) et 2 (menu retail, Mainline/Text.lua).
    -- `also` : écrite en même temps, comme TextSizeManager:SetSettingValue (écran de connexion).
    -- cameraZoomSpeed : le moteur accepte 1 à 50 (relevé 1.60.1.70938).
    { cvar = "cameraZoomSpeed", advanced = true, min = 1, max = 50, step = 1, default = 20 },
    { cvar = "userFontScale", also = "userFontScaleGlue", advanced = true, min = 0.8, max = 2, step = 0.1, default = 1 },

    { title = L.SECTION_NAMEPLATES },
    -- Maximum imposé par le client : 60 sur retail, 41 sur les clients Classic (41 relevé sur Forever).
    { cvar = "nameplateMaxDistance", min = 20,
      max = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) and 60 or 41, step = 1, default = 41 },
    -- Couleurs de classe : aussi dans le menu Nameplates de Forever (Camelot/NameplatesOverrides.lua).
    -- Familiers, totems : écrits seulement par Blizzard_Commentator, absents du menu.
    -- Non vérifiées en jeu : même traitement `advanced`.
    -- nameplateMinScale, nameplateMaxScale, nameplateSelectedScale absentes : figées à 1 sur Forever,
    -- toute écriture ignorée, /console compris (1.60.1.70938).
    { cvar = "nameplateShowClassColor", menu = L.MENU_CLASS_COLORS, advanced = true, default = true },
    { cvar = "nameplateShowFriendlyClassColor", menu = L.MENU_CLASS_COLORS, advanced = true, default = false },
    { cvar = "nameplateShowEnemyPets", advanced = true, default = false },
    { cvar = "nameplateShowEnemyTotems", advanced = true, default = false },

    -- Réglables seulement par /console : absentes des menus du jeu (relevé dans Config.wtf et
    -- BlizzardInterfaceCode). `advanced` : défaut lu dans le jeu, comme plus haut.
    -- Bornes relevées en jeu (1.60.1.70938) : le moteur refuse une valeur hors bornes et garde
    -- l'ancienne. reflectionMode accepte 0 à 4, effet de 4 non vu : curseur à 3.
    -- rippleDetail max 2, particleMTDensity max 100. LOD et doodadLodScale : aucune borne moteur,
    -- maximum du curseur choisi par Panorama.
    { title = L.SECTION_ADVANCED },
    { cvar = "reflectionMode", menu = L.MENU_LIQUID, advanced = true, min = 0, max = 3, step = 1, default = 0 },
    { cvar = "rippleDetail", menu = L.MENU_LIQUID, advanced = true, min = 0, max = 2, step = 1, default = 0 },
    { cvar = "terrainLodDist", menu = L.MENU_ENVIRONMENT, advanced = true, min = 50, max = 1000, step = 10, default = 200 },
    { cvar = "wmoLodDist", menu = L.MENU_ENVIRONMENT, advanced = true, min = 50, max = 1000, step = 10, default = 250 },
    { cvar = "entityLodDist", menu = L.MENU_ENVIRONMENT, advanced = true, min = 1, max = 50, step = 1, default = 5 },
    { cvar = "doodadLodScale", menu = L.MENU_ENVIRONMENT, advanced = true, min = 0, max = 100, step = 5, default = 50 },
    { cvar = "particleMTDensity", menu = L.MENU_PARTICLES, advanced = true, min = 10, max = 100, step = 5, default = 20 },
    { cvar = "DepthBasedOpacity", advanced = true, default = false },

    -- Texte de combat flottant : lu par Blizzard_CombatText. Le menu Combat de Forever n'affiche ces
    -- cases que si classicStyleWorldText vaut "0" (Mainline/CombatOverrides.lua) ; sinon seul
    -- Panorama les règle.
    { title = L.SECTION_COMBAT_TEXT },
    { cvar = "floatingCombatTextCombatHealingAbsorbSelf_v2", menu = L.MENU_COMBAT_TEXT, default = false },
    { cvar = "floatingCombatTextCombatState_v2", menu = L.MENU_COMBAT_TEXT, default = false },
    { cvar = "floatingCombatTextDodgeParryMiss_v2", menu = L.MENU_COMBAT_TEXT, default = false },
    { cvar = "floatingCombatTextDamageReduction_v2", menu = L.MENU_COMBAT_TEXT, default = false },
    { cvar = "floatingCombatTextFriendlyHealers_v2", menu = L.MENU_COMBAT_TEXT, default = false },
    { cvar = "floatingCombatTextAuras_v2", menu = L.MENU_COMBAT_TEXT, default = false },
    { cvar = "floatingCombatTextReactives_v2", menu = L.MENU_COMBAT_TEXT, default = false },
    { cvar = "floatingCombatTextEnergyGains_v2", menu = L.MENU_COMBAT_TEXT, default = false },
    { cvar = "floatingCombatTextPeriodicEnergyGains_v2", menu = L.MENU_COMBAT_TEXT, default = false },
    { cvar = "floatingCombatTextComboPoints_v2", menu = L.MENU_COMBAT_TEXT, default = false },
    { cvar = "floatingCombatTextLowManaHealth_v2", menu = L.MENU_COMBAT_TEXT, default = false },
    { cvar = "floatingCombatTextHonorGains_v2", menu = L.MENU_COMBAT_TEXT, default = false },
    { cvar = "floatingCombatTextRepChanges_v2", menu = L.MENU_COMBAT_TEXT, default = false },
}

NS.presets = {
    { id = "low", label = L.PRESET_LOW },
    { id = "medium", label = L.PRESET_MEDIUM },
    { id = "high", label = L.PRESET_HIGH },
    { id = "extra", label = L.PRESET_EXTRA },
}

-- Nom de CVar en minuscules -> réglage, pour l'événement CVAR_UPDATE.
local settingsByCVar = {}
for _, setting in ipairs(NS.settings) do
    if setting.cvar then
        settingsByCVar[setting.cvar:lower()] = setting
        setting.label, setting.tip = L[setting.cvar], L[setting.cvar .. "_tip"]
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
        return setting.default
    end
    -- Pas de borne min/max : une valeur posée par /console au-delà du curseur est gardée.
    -- Le moteur borne lui-même ce qu'il accepte. Sauf `hardMax` : valeur au-delà dangereuse.
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
    if setting.also and GetCVarValue(setting.also) ~= nil then WriteIfChanged(setting.also, tostring(value)) end
end

-- Blizzard_CombatText ne relit ses CVars qu'à UpdateDisplayedMessages. Appelé seulement sur un
-- changement du joueur, jamais à la connexion : l'appel depuis l'addon peut teinter CombatText.
-- Changé en combat : rafraîchi à la sortie du combat, avec l'écriture différée.
local combatTextAfterCombat = {}
local function RefreshCombatText(setting)
    if not setting.cvar:find("^floatingCombatText") then return end
    if InCombatLockdown() then
        combatTextAfterCombat[setting] = true
    elseif CombatText and CombatText.UpdateDisplayedMessages then
        CombatText:UpdateDisplayedMessages()
    end
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

-- Valeur par défaut du jeu pour les CVars aux bornes ou défauts estimés (avancées, texte de
-- combat) ; repli sur setting.default si le client ne la donne pas.
function NS.GameDefault(setting)
    if (setting.advanced or setting.cvar:find("^floatingCombatText")) then
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

-- Appelé à chaque changement du joueur (panneau, préréglage, annulation) : NS.db.values est
-- déjà à jour. Le panneau relit les valeurs pour que ses contrôles suivent.
function NS.Change(setting)
    NS.db.touched[setting.cvar] = true
    NS.Apply(setting)
    RefreshCombatText(setting)
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

function NS.RestartGraphics()
    ConsoleExec("gxRestart")
end

events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
local firstRun = false
events:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        firstRun = type(PanoramaDB) ~= "table" or type(PanoramaDB.values) ~= "table"
        PanoramaDB = type(PanoramaDB) == "table" and PanoramaDB or {}
        local db = PanoramaDB
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
        if type(db.collapsed) ~= "table" then db.collapsed = { [L.SECTION_ADVANCED] = true } end
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
                if NS.Exists(setting) and (value == nil or not db.applyOnLogin
                        or not db.touched[setting.cvar]) then
                    value = ReadCVar(setting)
                end
                db.values[setting.cvar] = NS.Sanitize(setting, value)
            end
        end
        if NS.LoadFilters then NS.LoadFilters(db) end
        NS.db = db
        if NS.BuildOptions then NS.BuildOptions() end
        if NS.BuildMinimapButton then NS.BuildMinimapButton() end
    elseif event == "PLAYER_LOGIN" then
        -- Réécrit les réglages modifiés dans Panorama, au cas où le jeu les aurait changés entre-temps
        -- (Config.wtf, détection automatique). Premier lancement : les valeurs viennent du jeu, rien à écrire.
        -- Le plafond `hardMax` est écrit dans tous les cas.
        NS.ApplyAll(not NS.db.applyOnLogin or firstRun)
        -- Les filtres ne sont pas des CVars : toujours reposés, réapplication coupée ou non.
        if NS.ApplyFilters then NS.ApplyFilters() end
        -- Écouté après la réécriture, pour qu'un CVAR_UPDATE du chargement n'écrase pas PanoramaDB.
        self:RegisterEvent("CVAR_UPDATE")
    elseif event == "CVAR_UPDATE" then
        -- Changement venu du menu Graphismes ou de /console : le panneau suit la vraie valeur.
        local setting = NS.db and type(arg1) == "string" and settingsByCVar[arg1:lower()]
        if setting then
            NS.db.values[setting.cvar] = NS.Sanitize(setting, ReadCVar(setting))
            -- Au-delà du plafond `hardMax` (menu du jeu, /console) : ramenée au maximum.
            if setting.hardMax and (ReadCVar(setting) or 0) > setting.max then NS.Apply(setting) end
            if NS.RefreshOptions and not batching then NS.RefreshOptions() end
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        local settings = pending
        pending = {}
        for setting in pairs(settings) do NS.Apply(setting) end
        local combatText = combatTextAfterCombat
        combatTextAfterCombat = {}
        for setting in pairs(combatText) do RefreshCombatText(setting) end
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
            print(L.PREFIX .. L.MSG_APPLIED)
        end
    elseif command == "restart" then
        NS.RestartGraphics()
    elseif command == "undo" then
        NS.Undo()
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
