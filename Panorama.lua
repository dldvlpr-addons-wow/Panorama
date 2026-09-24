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
    { cvar = "gxMultisample", choices = { 1, 2, 4, 8 }, default = 8, levels = { 1, 1, 4, 8 } },
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
    if C_CVar and C_CVar.GetCVar then return C_CVar.GetCVar(name) end
    return GetCVar(name)
end

local function SetCVarValue(name, value)
    if C_CVar and C_CVar.SetCVar then return C_CVar.SetCVar(name, value) end
    return SetCVar(name, value)
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

function NS.ApplyAll()
    for _, setting in ipairs(NS.settings) do
        if setting.cvar then NS.Apply(setting) end
    end
end

-- Passe par les réglages du panneau quand ils existent, pour que ses contrôles suivent.
function NS.ApplyPreset(index)
    for _, setting in ipairs(NS.settings) do
        if setting.levels and NS.Exists(setting) then
            local value = NS.Sanitize(setting, setting.levels[index])
            local registered = NS.registered and NS.registered[setting.cvar]
            if registered then
                registered:SetValue(value)
            else
                NS.db.values[setting.cvar] = value
                NS.Apply(setting)
            end
        end
    end
    print(L.PREFIX .. L.MSG_PRESET:format(NS.presets[index].label))
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
        for _, setting in ipairs(NS.settings) do
            if setting.cvar then
                local value = db.values[setting.cvar]
                -- Premier lancement, ou réapplication coupée : on part des valeurs actuelles du jeu.
                if NS.Exists(setting) and (value == nil or not db.applyOnLogin) then
                    value = ReadCVar(setting)
                end
                db.values[setting.cvar] = NS.Sanitize(setting, value)
            end
        end
        NS.db = db
        if NS.BuildOptions then NS.BuildOptions() end
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
    elseif command ~= "" then
        for index, preset in ipairs(NS.presets) do
            if preset.id == command then return NS.ApplyPreset(index) end
        end
        print(L.PREFIX .. L.MSG_UNKNOWN_COMMAND)
    elseif NS.OpenOptions then
        NS.OpenOptions()
    end
end
