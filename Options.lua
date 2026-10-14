-- Panneau Panorama dans Options > AddOns : cartes de préréglage, sections repliables, une ligne
-- par réglage (libellé, phrase d'aide, contrôle, bouton « Défaut »).
-- Chaque changement est écrit tout de suite dans la CVar (NS.Change).
local _, NS = ...
local L = NS.L

local CONTENT_WIDTH = 560
local ROW_HEIGHT = 52
local HEADER_HEIGHT = 30

local category
local panel
local items = {}      -- dans l'ordre d'affichage : { frame, section, height }
local controls = {}   -- cvar -> { setting, refresh }
local collapsed       -- NS.db.collapsed : section -> true ; « Avancé » replié au départ
local refreshing = false

local function Round(value, step)
    return math.floor(value / step + 0.5) * step
end

local function FormatValue(setting, value)
    if type(value) == "boolean" then return value and L.OPT_ON or L.OPT_OFF end
    if setting.step and setting.step < 1 then return ("%.1f"):format(value) end
    return tostring(value)
end

-- Réaligne les lignes : une section repliée cache ses lignes.
local function Layout()
    local y = 0
    for _, item in ipairs(items) do
        if item.section and collapsed[item.section] then
            item.frame:Hide()
        else
            item.frame:ClearAllPoints()
            item.frame:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -y)
            item.frame:Show()
            y = y + item.height
        end
    end
    panel.content:SetHeight(y + 10)
end

function NS.RefreshOptions()
    if not panel then return end
    refreshing = true
    for cvar, control in pairs(controls) do control.refresh(NS.db.values[cvar]) end
    panel.applyOnLogin:SetChecked(NS.db.applyOnLogin)
    panel.showMinimap:SetChecked(NS.db.minimap.show)
    panel.undo:SetEnabled(NS.CanUndo())
    refreshing = false
end

local function Tooltip(frame, text)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(text, 1, 1, 1, 1, true)
    end)
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function CreateButton(parent, text, width, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 24)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

local function CreateCheckbox(parent, text, tip, onChange)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetSize(26, 26)
    check.text = check:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    check.text:SetPoint("LEFT", check, "RIGHT", 2, 0)
    check.text:SetText(text)
    check:SetScript("OnClick", function(self)
        if not refreshing then onChange(self:GetChecked() and true or false) end
    end)
    Tooltip(check, tip)
    return check
end

-- Curseur sans gabarit (OptionsSliderTemplate est déprécié).
local function CreateSlider(parent, setting, onChange)
    local slider = CreateFrame("Slider", nil, parent)
    slider:SetOrientation("HORIZONTAL")
    slider:SetSize(170, 16)
    slider:SetMinMaxValues(setting.min, setting.max)
    slider:SetValueStep(setting.step)
    if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetPoint("LEFT")
    track:SetPoint("RIGHT")
    track:SetHeight(6)
    track:SetColorTexture(0, 0, 0, 0.6)
    slider:SetScript("OnValueChanged", function(_, value)
        if not refreshing then onChange(Round(value, setting.step)) end
    end)
    return slider
end

local function CreateRow(setting, section)
    local row = CreateFrame("Frame", nil, panel.content)
    row:SetSize(CONTENT_WIDTH, ROW_HEIGHT)

    local label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    label:SetPoint("TOPLEFT", 8, -6)
    label:SetText(setting.label)

    local tip = row:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    tip:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -3)
    tip:SetWidth(230)
    tip:SetJustifyH("LEFT")
    tip:SetMaxLines(2)
    tip:SetText(setting.restart and (setting.tip .. " " .. L.OPT_NEEDS_RESTART) or setting.tip)

    local function change(value)
        NS.db.values[setting.cvar] = value
        NS.Change(setting)
    end

    local valueText = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    valueText:SetPoint("RIGHT", row, "RIGHT", -86, 0)
    valueText:SetWidth(50)
    valueText:SetJustifyH("RIGHT")

    local refresh
    if type(setting.default) == "boolean" then
        local check = CreateCheckbox(row, "", setting.tip, change)
        check:SetPoint("RIGHT", row, "RIGHT", -140, 0)
        refresh = function(value)
            check:SetChecked(value)
            valueText:SetText(FormatValue(setting, value))
        end
    elseif setting.choices then
        local buttons = {}
        local previous
        for index = #setting.choices, 1, -1 do
            local choice = setting.choices[index]
            local button = CreateButton(row, tostring(choice), 36, function() change(choice) end)
            if previous then
                button:SetPoint("RIGHT", previous, "LEFT", -2, 0)
            else
                button:SetPoint("RIGHT", row, "RIGHT", -86, 0)
            end
            buttons[choice], previous = button, button
        end
        refresh = function(value)
            for choice, button in pairs(buttons) do button:SetEnabled(choice ~= value) end
        end
        valueText:Hide()
    else
        local slider = CreateSlider(row, setting, change)
        slider:SetPoint("RIGHT", valueText, "LEFT", -10, 0)
        refresh = function(value)
            slider:SetValue(value)
            valueText:SetText(FormatValue(setting, value))
        end
    end

    local reset = CreateButton(row, L.OPT_DEFAULT, 70, function() change(NS.GameDefault(setting)) end)
    reset:SetPoint("RIGHT", row, "RIGHT", -4, 0)

    controls[setting.cvar] = { setting = setting, refresh = refresh }
    items[#items + 1] = { frame = row, section = section, height = ROW_HEIGHT }
end

local function CreateHeader(title)
    local header = CreateFrame("Button", nil, panel.content)
    header:SetSize(CONTENT_WIDTH, HEADER_HEIGHT)
    local text = header:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    text:SetPoint("LEFT", 8, -4)
    local function update()
        text:SetText((collapsed[title] and "[+] " or "[-] ") .. title)
    end
    header:SetScript("OnClick", function()
        collapsed[title] = not collapsed[title] or nil
        update()
        Layout()
    end)
    update()
    items[#items + 1] = { frame = header, height = HEADER_HEIGHT }
end

local function CreatePresetCards(parent)
    local previous
    for index, preset in ipairs(NS.presets) do
        local card = CreateFrame("Frame", nil, parent)
        card:SetSize(134, 74)
        if previous then
            card:SetPoint("LEFT", previous, "RIGHT", 6, 0)
        else
            card:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -86)
        end
        local button = CreateButton(card, preset.label, 134, function() NS.ApplyPreset(index) end)
        button:SetHeight(28)
        button:SetPoint("TOP")
        local description = card:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
        description:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 2, -4)
        description:SetWidth(130)
        description:SetJustifyH("LEFT")
        description:SetMaxLines(3)
        description:SetText(L["PRESET_" .. preset.id:upper() .. "_DESC"])
        previous = card
    end
end

function NS.BuildOptions()
    panel = CreateFrame("Frame")
    panel:Hide()

    local logo = panel:CreateTexture(nil, "ARTWORK")
    logo:SetSize(56, 56)
    logo:SetPoint("TOPLEFT", 16, -12)
    logo:SetTexture("Interface\\AddOns\\Panorama\\Media\\logo")
    local title = panel:CreateFontString(nil, "ARTWORK")
    title:SetFontObject(GameFontNormalHuge or GameFontNormalLarge)
    title:SetPoint("TOPLEFT", logo, "TOPRIGHT", 10, -4)
    title:SetText("Panorama")
    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    subtitle:SetText(L.OPT_SUBTITLE)

    -- Zone fixe sous l'en-tête : préréglages et actions. Le reste défile.
    local top = CreateFrame("Frame", nil, panel)
    top:SetPoint("TOPLEFT", 0, -76)
    top:SetPoint("TOPRIGHT")
    top:SetHeight(230)
    local presetsTitle = top:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    presetsTitle:SetPoint("TOPLEFT", 16, -4)
    presetsTitle:SetText(L.OPT_PRESETS)
    local presetsHelp = top:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    presetsHelp:SetPoint("TOPLEFT", presetsTitle, "BOTTOMLEFT", 0, -4)
    presetsHelp:SetText(L.OPT_PRESET_TIP)
    local cards = CreateFrame("Frame", nil, top)
    cards:SetAllPoints()
    CreatePresetCards(cards)

    panel.undo = CreateButton(top, L.OPT_UNDO, 190, NS.Undo)
    panel.undo:SetPoint("TOPLEFT", 16, -170)
    Tooltip(panel.undo, L.OPT_UNDO_TIP)
    local restart = CreateButton(top, L.OPT_RESTART, 190, NS.RestartGraphics)
    restart:SetPoint("LEFT", panel.undo, "RIGHT", 8, 0)
    Tooltip(restart, L.OPT_RESTART_TIP)

    panel.applyOnLogin = CreateCheckbox(top, L.OPT_APPLY_ON_LOGIN, L.OPT_APPLY_ON_LOGIN_TIP, function(value)
        NS.db.applyOnLogin = value
    end)
    panel.applyOnLogin:SetPoint("TOPLEFT", 12, -200)
    panel.showMinimap = CreateCheckbox(top, L.OPT_MINIMAP_BUTTON, L.OPT_MINIMAP_BUTTON_TIP, function(value)
        NS.db.minimap.show = value
        if NS.UpdateMinimapButton then NS.UpdateMinimapButton() end
    end)
    panel.showMinimap:SetPoint("LEFT", panel.applyOnLogin.text, "RIGHT", 40, 0)

    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 8, -4)
    scroll:SetPoint("BOTTOMRIGHT", -30, 8)
    panel.content = CreateFrame("Frame", nil, scroll)
    panel.content:SetSize(CONTENT_WIDTH, 10)
    scroll:SetScrollChild(panel.content)

    collapsed = NS.db.collapsed
    -- Titre créé à la première ligne visible : pas de section vide sur un client sans ces CVars.
    local section, headerPending
    for _, setting in ipairs(NS.settings) do
        if setting.title then
            section, headerPending = setting.title, true
        elseif NS.Exists(setting) then
            if headerPending then
                CreateHeader(section)
                headerPending = false
            end
            CreateRow(setting, section)
        end
    end
    Layout()

    panel:SetScript("OnShow", NS.RefreshOptions)
    category = Settings.RegisterCanvasLayoutCategory(panel, "Panorama")
    Settings.RegisterAddOnCategory(category)
    NS.RefreshOptions()
end

function NS.OpenOptions()
    Settings.OpenToCategory(category:GetID())
end
