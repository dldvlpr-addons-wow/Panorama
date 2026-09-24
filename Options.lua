-- Panneau Panorama dans Options > AddOns, construit avec l'API Settings de Blizzard.
-- Chaque changement est écrit tout de suite dans la CVar. Le bouton « Par défaut »
-- du panneau remet les valeurs de la liste de Panorama.lua.
local _, NS = ...
local L = NS.L

local CreateCheckbox = Settings.CreateCheckbox or Settings.CreateCheckBox
local CreateDropdown = Settings.CreateDropdown or Settings.CreateDropDown

local category
NS.registered = {}

local function Register(setting)
    local isToggle = type(setting.default) == "boolean"
    local variable = "Panorama_" .. setting.cvar
    local registered = Settings.RegisterAddOnSetting(category, variable, setting.cvar, NS.db.values,
        isToggle and Settings.VarType.Boolean or Settings.VarType.Number, setting.label, setting.default)
    Settings.SetOnValueChangedCallback(variable, function() NS.Apply(setting) end)
    NS.registered[setting.cvar] = registered

    if isToggle then
        CreateCheckbox(category, registered, setting.tip)
    elseif setting.choices then
        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            for _, choice in ipairs(setting.choices) do container:Add(choice, tostring(choice)) end
            return container:GetData()
        end
        CreateDropdown(category, registered, GetOptions, setting.tip)
    else
        local options = Settings.CreateSliderOptions(setting.min, setting.max, setting.step)
        local decimals = setting.step < 1 and "%.1f" or "%d"
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
            return decimals:format(value)
        end)
        Settings.CreateSlider(category, registered, options, setting.tip)
    end
end

function NS.BuildOptions()
    local layout
    category, layout = Settings.RegisterVerticalLayoutCategory("Panorama")

    local login = Settings.RegisterAddOnSetting(category, "Panorama_applyOnLogin", "applyOnLogin", NS.db,
        Settings.VarType.Boolean, L.OPT_APPLY_ON_LOGIN, true)
    CreateCheckbox(category, login, L.OPT_APPLY_ON_LOGIN_TIP)

    layout:AddInitializer(CreateSettingsButtonInitializer(L.OPT_ENGINE, L.OPT_RESTART,
        NS.RestartGraphics, L.OPT_RESTART_TIP, true))

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.OPT_PRESETS))
    for index, preset in ipairs(NS.presets) do
        layout:AddInitializer(CreateSettingsButtonInitializer(preset.label, L.OPT_APPLY,
            function() NS.ApplyPreset(index) end,
            L.OPT_PRESET_TIP, true))
    end

    for _, setting in ipairs(NS.settings) do
        if setting.title then
            layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(setting.title))
        elseif NS.Exists(setting) then
            Register(setting)
        end
    end

    Settings.RegisterAddOnCategory(category)
end

function NS.OpenOptions()
    Settings.OpenToCategory(category:GetID())
end
