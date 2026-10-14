-- Panorama : liste des réglages, sauvegarde et écriture des CVars.
-- Le panneau d'options est dans Options.lua.
local addonName, NS = ...

-- Langue du client, enUS pour toute clé non traduite. Les traductions sont dans Locale/.
local L = NS.locales[GetLocale()] or NS.locales.enUS
if L ~= NS.locales.enUS then setmetatable(L, { __index = NS.locales.enUS }) end
NS.L = L

-- Une ligne sans `cvar` est un titre de section. Libellé et bulle d'aide : L[cvar] et L[cvar .. "_tip"].
-- Les bornes min/max sont celles des menus du jeu : le panneau ne permet pas d'en sortir,
-- et une valeur hors bornes dans PanoramaDB (fichier édité à la main) est ramenée dedans.
-- Une CVar inconnue du client est ignorée : ni affichée, ni écrite.
-- `levels` : valeurs des préréglages, dans l'ordre de NS.presets. Sans `levels`, un préréglage
-- ne touche pas au réglage (caméra, souris, confort).
NS.settings = {
    { title = L.SECTION_VIEW },
    { cvar = "farclip", min = 185, max = 2600, step = 5, default = 1300, levels = { 400, 800, 1300, 2600 } },
    { cvar = "horizonfarclip", min = 1000, max = 5000, step = 8, default = 2112, levels = { 1304, 1704, 2112, 5000 } },
    { cvar = "volumeFog", default = false, levels = { false, false, true, true } },

    { title = L.SECTION_VEGETATION },
    { cvar = "detailDoodleDensity", min = 0, max = 100, step = 1, default = 100, levels = { 25, 50, 75, 100 } },
    { cvar = "groundEffectDensity", min = 16, max = 256, step = 8, default = 256, levels = { 32, 96, 160, 256 } },
    { cvar = "groundEffectDist", min = 0, max = 300, step = 5, default = 140, levels = { 40, 80, 140, 300 } },

    { title = L.SECTION_SHADOWS },
    { cvar = "shadowLevel", min = 0, max = 2, step = 1, default = 2, levels = { 0, 1, 2, 2 } },
    { cvar = "shadowSoft", default = true, levels = { false, false, true, true } },
    { cvar = "shadowTextureSize", choices = { 1024, 2048 }, default = 2048, levels = { 1024, 1024, 2048, 2048 } },
    { cvar = "sunShafts", min = 0, max = 2, step = 1, default = 2, levels = { 0, 1, 2, 2 } },
    { cvar = "SSAO", min = 0, max = 3, step = 1, default = 3, levels = { 0, 1, 2, 3 } },
    { cvar = "SSFX", default = true, levels = { false, true, true, true } },

    { title = L.SECTION_ENVIRONMENT },
    { cvar = "waterDetail", min = 0, max = 3, step = 1, default = 3, levels = { 0, 1, 2, 3 } },
    { cvar = "skyCloudLod", min = 0, max = 3, step = 1, default = 3, levels = { 0, 1, 2, 3 } },
    { cvar = "WeatherDensity", min = 0, max = 3, step = 1, default = 3, levels = { 0, 1, 2, 3 } },
    { cvar = "physicsLevel", min = 0, max = 2, step = 1, default = 2, levels = { 0, 1, 2, 2 } },

    { title = L.SECTION_IMAGE },
    { cvar = "gxMultisample", restart = true, choices = { 1, 2, 4, 8 }, default = 8, levels = { 1, 1, 4, 8 } },
    { cvar = "ResampleAlwaysSharpen", default = true },
    { cvar = "ResampleSharpness", min = 0, max = 2, step = 0.1, default = 0.5 },
    { cvar = "ffxGlow", default = true, levels = { false, true, true, true } },
    { cvar = "ffxDeath", default = false },
    { cvar = "violenceLevel", min = 0, max = 5, step = 1, default = 5 },
    { cvar = "ProjectedTextures", default = true, levels = { false, true, true, true } },
    { cvar = "spellClutter", default = false, levels = { true, false, false, false } },

    { title = L.SECTION_CAMERA },
    { cvar = "cameraDistanceMaxZoomFactor", min = 1, max = 2.6, step = 0.1, default = 2.6 },
    -- Maximum imposé par le client : 60 sur retail, 41 sur les clients Classic.
    { cvar = "nameplateMaxDistance", min = 20,
      max = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) and 60 or 41, step = 1, default = 41 },
    { cvar = "rawMouseEnable", default = true },
    { cvar = "screenshotQuality", min = 1, max = 10, step = 1, default = 10 },

    -- Réglables seulement par /console : absentes des menus du jeu (relevé dans Config.wtf et
    -- BlizzardInterfaceCode). `advanced` : jamais écrites tant que le joueur n'a pas touché au réglage.
    -- ponytail: bornes estimées, non lues dans le source Blizzard. À confirmer en jeu par
    -- /run SetCVar("<nom>", "<valeur>"), puis resserrer.
    { title = L.SECTION_ADVANCED },
    { cvar = "reflectionMode", advanced = true, min = 0, max = 3, step = 1, default = 0 },
    { cvar = "rippleDetail", advanced = true, min = 0, max = 2, step = 1, default = 0 },
    { cvar = "terrainLodDist", advanced = true, min = 50, max = 1000, step = 10, default = 200 },
    { cvar = "wmoLodDist", advanced = true, min = 50, max = 1000, step = 10, default = 250 },
    { cvar = "entityLodDist", advanced = true, min = 1, max = 50, step = 1, default = 5 },
    { cvar = "doodadLodScale", advanced = true, min = 0, max = 100, step = 5, default = 50 },
    { cvar = "particleMTDensity", advanced = true, min = 10, max = 100, step = 5, default = 20 },
    { cvar = "DepthBasedOpacity", advanced = true, default = false },

    -- Texte de combat flottant : lu par Blizzard_CombatText, aucun contrôle dans les menus.
    { title = L.SECTION_COMBAT_TEXT },
    { cvar = "floatingCombatTextCombatState_v2", default = false },
    { cvar = "floatingCombatTextDodgeParryMiss_v2", default = false },
    { cvar = "floatingCombatTextDamageReduction_v2", default = false },
    { cvar = "floatingCombatTextFriendlyHealers_v2", default = false },
    { cvar = "floatingCombatTextAuras_v2", default = false },
    { cvar = "floatingCombatTextReactives_v2", default = false },
    { cvar = "floatingCombatTextEnergyGains_v2", default = false },
    { cvar = "floatingCombatTextPeriodicEnergyGains_v2", default = false },
    { cvar = "floatingCombatTextComboPoints_v2", default = false },
    { cvar = "floatingCombatTextLowManaHealth_v2", default = false },
    { cvar = "floatingCombatTextHonorGains_v2", default = false },
    { cvar = "floatingCombatTextRepChanges_v2", default = false },
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

-- Ramène une valeur lue dans PanoramaDB dans les limites du réglage.
function NS.Sanitize(setting, value)
    if type(setting.default) == "boolean" then
        if type(value) ~= "boolean" then return setting.default end
        return value
    end
    if type(value) ~= "number" or value ~= value then return setting.default end
    if setting.choices then
        for _, choice in ipairs(setting.choices) do
            if choice == value then return value end
        end
        return setting.default
    end
    return math.min(setting.max, math.max(setting.min, value))
end

local pending = false
local events = CreateFrame("Frame")

function NS.Apply(setting)
    if not NS.Exists(setting) then return end
    -- Certaines CVars refusent l'écriture en combat : tout est réappliqué à la sortie du combat.
    if InCombatLockdown() then
        pending = true
        events:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    local value = NS.db.values[setting.cvar]
    if type(value) == "boolean" then value = value and 1 or 0 end
    SetCVarValue(setting.cvar, tostring(value))
end

-- Un réglage avancé n'est écrit que s'il a été modifié par le joueur : sa valeur vient du jeu sinon.
function NS.ApplyAll()
    for _, setting in ipairs(NS.settings) do
        if setting.cvar and (not setting.advanced or NS.db.touched[setting.cvar]) then
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

-- Appelé à chaque changement du joueur (panneau, préréglage, annulation) : NS.db.values est
-- déjà à jour. Le panneau relit les valeurs pour que ses contrôles suivent.
function NS.Change(setting)
    if setting.advanced then NS.db.touched[setting.cvar] = true end
    NS.Apply(setting)
    -- Blizzard_CombatText ne relit ses CVars qu'à UpdateDisplayedMessages.
    if setting.cvar:find("^floatingCombatText") then
        if CombatText and CombatText.UpdateDisplayedMessages then
            CombatText:UpdateDisplayedMessages()
        end
    end
    if NS.RefreshOptions then NS.RefreshOptions() end
end

local function SetValue(setting, value)
    NS.db.values[setting.cvar] = value
    NS.Change(setting)
end

-- Valeurs d'avant le dernier préréglage, gardées dans PanoramaDB.undo.
function NS.CanUndo()
    return NS.db.undo ~= nil
end

function NS.ApplyPreset(index)
    NS.db.undo = {}
    for cvar, value in pairs(NS.db.values) do NS.db.undo[cvar] = value end
    for _, setting in ipairs(NS.settings) do
        if setting.levels and NS.Exists(setting) then
            SetValue(setting, NS.Sanitize(setting, setting.levels[index]))
        end
    end
    print(L.PREFIX .. L.MSG_PRESET:format(NS.presets[index].label))
end

function NS.Undo()
    if not NS.db.undo then
        print(L.PREFIX .. L.MSG_NOTHING_TO_UNDO)
        return
    end
    local values = NS.db.undo
    NS.db.undo = nil
    for _, setting in ipairs(NS.settings) do
        if setting.cvar and setting.levels and values[setting.cvar] ~= nil and NS.Exists(setting) then
            SetValue(setting, values[setting.cvar])
        end
    end
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
        if type(db.undo) ~= "table" then db.undo = nil end
        if type(db.collapsed) ~= "table" then db.collapsed = { [L.SECTION_ADVANCED] = true } end
        if type(db.minimap) ~= "table" then db.minimap = {} end
        if type(db.minimap.angle) ~= "number" then db.minimap.angle = 200 end
        if type(db.minimap.show) ~= "boolean" then db.minimap.show = true end
        for _, setting in ipairs(NS.settings) do
            if setting.cvar then
                local value = db.values[setting.cvar]
                -- Premier lancement, réapplication coupée, ou réglage avancé jamais touché :
                -- on part des valeurs actuelles du jeu.
                if NS.Exists(setting) and (value == nil or not db.applyOnLogin
                        or (setting.advanced and not db.touched[setting.cvar])) then
                    value = ReadCVar(setting)
                end
                db.values[setting.cvar] = NS.Sanitize(setting, value)
            end
        end
        NS.db = db
        if NS.BuildOptions then NS.BuildOptions() end
        if NS.BuildMinimapButton then NS.BuildMinimapButton() end
    elseif event == "PLAYER_LOGIN" then
        -- Réécrit les valeurs de la dernière session, au cas où le jeu les aurait changées entre-temps
        -- (Config.wtf, détection automatique). Premier lancement : les valeurs viennent du jeu, rien à écrire.
        if NS.db.applyOnLogin and not firstRun then NS.ApplyAll() end
        -- Écouté après la réécriture, pour qu'un CVAR_UPDATE du chargement n'écrase pas PanoramaDB.
        self:RegisterEvent("CVAR_UPDATE")
    elseif event == "CVAR_UPDATE" then
        -- Changement venu du menu Graphismes ou de /console : le panneau suit la vraie valeur.
        local setting = NS.db and type(arg1) == "string" and settingsByCVar[arg1:lower()]
        if setting then
            NS.db.values[setting.cvar] = NS.Sanitize(setting, ReadCVar(setting))
            if NS.RefreshOptions then NS.RefreshOptions() end
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        if pending then
            pending = false
            NS.ApplyAll()
        end
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
