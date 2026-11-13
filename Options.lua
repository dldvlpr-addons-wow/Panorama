-- Fenêtre Panorama, déplaçable et fermée par Échap : cartes de préréglage, sections repliables,
-- une ligne par réglage (libellé, phrase d'aide, contrôle, bouton « Défaut »).
-- Options > AddOns > Panorama n'affiche qu'un bouton qui ouvre cette fenêtre.
-- Chaque changement est écrit tout de suite : CVar par NS.Change, filtre par NS.ApplyFilters.
local _, NS = ...
local L = NS.L

local CONTENT_WIDTH = 560
local ROW_HEIGHT = 52
local HEADER_HEIGHT = 30

local panel
local items = {}      -- dans l'ordre d'affichage : { frame, section, height }
local controls = {}   -- cvar ou clé de filtre -> { setting, refresh }
local collapsed       -- NS.db.collapsed : section -> true ; « Avancé » replié au départ
local filter = ""     -- texte de la barre de recherche, en minuscules
local refreshing = false

local function Round(value, step)
    return math.floor(value / step + 0.5) * step
end

-- Minuscules UTF-8 pour la recherche : strlower ne plie que l'ASCII.
-- Couvre le latin accentué (À-Þ) et le cyrillique ; le coréen et le chinois n'ont pas de casse.
local function Fold(text)
    return (text:lower()
        :gsub("\195([\128-\158])", function(c) return "\195" .. string.char(c:byte() + 32) end)
        :gsub("\208\129", "\209\145")
        :gsub("\208([\144-\175])", function(c)
            local byte = c:byte()
            if byte < 160 then return "\208" .. string.char(byte + 32) end
            return "\209" .. string.char(byte - 32)
        end))
end
NS.Fold = Fold

local function FormatValue(setting, value)
    if type(value) == "boolean" then return value and L.OPT_ON or L.OPT_OFF end
    if setting.step and setting.step < 1 then return ("%.1f"):format(value) end
    return tostring(value)
end

-- Réaligne les lignes : une section repliée cache ses lignes.
-- Pendant une recherche, seules les lignes qui correspondent et leurs titres restent, sections repliées comprises.
local function Layout()
    local matches = {}   -- section -> true si une de ses lignes correspond
    for _, item in ipairs(items) do
        item.match = filter ~= "" and item.text and item.text:find(filter, 1, true) ~= nil
        if item.match then matches[item.section] = true end
    end
    local y = 0
    for _, item in ipairs(items) do
        local hidden
        if filter ~= "" then
            hidden = not (item.match or matches[item.header])
        else
            hidden = item.section and collapsed[item.section]
        end
        if hidden then
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
    for key, control in pairs(controls) do
        control.refresh((control.setting.cvar and NS.db.values or NS.db.filters)[key])
    end
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
    slider:SetObeyStepOnDrag(true)
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

    -- Réglage de CVar (`cvar`) ou filtre (`key`, PanoramaDB.filters, aucune CVar).
    local function change(value)
        if setting.cvar then
            NS.db.values[setting.cvar] = value
            NS.Change(setting)
        else
            NS.db.filters[setting.key] = value
            NS.ApplyFilters()
            NS.RefreshOptions()
        end
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

    local reset = CreateButton(row, L.OPT_DEFAULT, 70, function()
        if setting.cvar then change(NS.GameDefault(setting)) else change(setting.default) end
    end)
    reset:SetPoint("RIGHT", row, "RIGHT", -4, 0)

    controls[setting.cvar or setting.key] = { setting = setting, refresh = refresh }
    items[#items + 1] = { frame = row, section = section, height = ROW_HEIGHT,
        text = Fold(setting.label .. " " .. setting.tip .. " " .. (setting.cvar or setting.key)) }
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
    items[#items + 1] = { frame = header, header = title, height = HEADER_HEIGHT }
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
    panel = CreateFrame("Frame", "PanoramaFrame", UIParent, "BasicFrameTemplate")
    panel:Hide()
    panel:SetSize(CONTENT_WIDTH + 50, 640)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:SetToplevel(true)
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    tinsert(UISpecialFrames, "PanoramaFrame")

    local logo = panel:CreateTexture(nil, "ARTWORK")
    logo:SetSize(56, 56)
    logo:SetPoint("TOPLEFT", 16, -30)
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
    top:SetPoint("TOPLEFT", 0, -94)
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
    local search = CreateFrame("EditBox", nil, top, "SearchBoxTemplate")
    search:SetSize(170, 20)
    search:SetPoint("LEFT", restart, "RIGHT", 16, 0)
    search.Instructions:SetText(L.OPT_SEARCH)
    -- HookScript : garde le script du gabarit (texte d'aide, bouton d'effacement).
    search:HookScript("OnTextChanged", function(self)
        filter = Fold(strtrim(self:GetText()))
        panel.scroll:SetVerticalScroll(0)
        Layout()
    end)

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
    panel.scroll = scroll
    scroll:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 8, -4)
    scroll:SetPoint("BOTTOMRIGHT", -30, 8)
    panel.content = CreateFrame("Frame", nil, scroll)
    panel.content:SetSize(CONTENT_WIDTH, 10)
    scroll:SetScrollChild(panel.content)

    collapsed = NS.db.collapsed
    -- Titre créé à la première ligne visible : pas de section vide sur un client sans ces CVars.
    local section, headerPending
    for _, list in ipairs({ NS.settings, NS.filterSettings }) do
        for _, setting in ipairs(list) do
            if setting.title then
                section, headerPending = setting.title, true
            elseif setting.key or NS.Exists(setting) then
                if headerPending then
                    CreateHeader(section)
                    headerPending = false
                end
                CreateRow(setting, section)
            end
        end
    end
    Layout()

    panel:SetScript("OnShow", NS.RefreshOptions)
    NS.RefreshOptions()

    local launcher = CreateFrame("Frame")
    local open = CreateButton(launcher, L.OPT_OPEN_WINDOW, 220, function()
        if not InCombatLockdown() then HideUIPanel(SettingsPanel) end
        panel:Show()
    end)
    open:SetPoint("TOPLEFT", 16, -16)
    local category = Settings.RegisterCanvasLayoutCategory(launcher, "Panorama")
    Settings.RegisterAddOnCategory(category)
end

function NS.OpenOptions()
    panel:SetShown(not panel:IsShown())
end
