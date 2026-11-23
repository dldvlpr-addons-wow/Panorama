-- Fenêtre Panorama, déplaçable et fermée par Échap. Mise en page : DESIGN.md.
-- En-tête et recherche, 6 onglets, préréglages (onglet Qualité), bloc Ambiance (onglet Ambiance), bloc du
-- filtre ouvert (onglet Mes filtres), liste défilante de sections
-- repliables, pied (cases et redémarrage du moteur). Une ligne par réglage : libellé, aide,
-- contrôle (case, boutons radio, curseur et boîte de saisie, vignettes de teinte), bouton Défaut.
-- Options > AddOns > Panorama n'affiche qu'un bouton qui ouvre cette fenêtre.
-- Chaque changement est écrit tout de suite : CVar par NS.Change, filtre par NS.ApplyFilters.
local _, NS = ...
local L = NS.L

local MEDIA = "Interface\\AddOns\\Panorama\\Media\\"
local LIST_WIDTH = 560
local CONTROL_X = 296
local DEFAULT_X = 532
local HEADER_HEIGHT = 30
local TABS_WIDTH = 444  -- rangée d'onglets : 610 - 2 marges de 14 - menu de langue (130) - 8 d'écart
local TAB_GAP = 2        -- écart entre deux onglets d'un même groupe
local TAB_GROUP_GAP = 14 -- écart avant le premier onglet d'un groupe (NS.tabGroupStart)
local HELP = 0.82       -- gris de l'aide, du sous-titre et du texte d'aide de la recherche
local DISABLED = 0.5    -- gris d'une ligne désactivée, et de rien d'autre
local TAB_LABELS = { quality = "TAB_QUALITY", filters = "TAB_FILTERS", myfilters = "TAB_MYFILTERS",
                     ambiance = "TAB_AMBIANCE",
                     interface = "TAB_INTERFACE", advanced = "TAB_ADVANCED" }
local ADVANCED_TABS = { advanced = true, myfilters = true }   -- cachés en mode simple

local panel
local items = {}      -- dans l'ordre d'affichage : { frame, tab, section ou header, height, text }
local controls = {}   -- table du réglage (ou sa copie d'ambiance) -> { setting, refresh }
local inputs = {}     -- boîtes de saisie dans l'ordre d'affichage, pour Tab
local collapsed       -- NS.db.collapsed : clé de locale du titre de section -> true
local filter = ""     -- texte de la barre de recherche, en minuscules
local refreshing = false
local editedContext = "day"   -- contexte d'ambiance ouvert dans l'éditeur (NS.ambianceContexts), ou "zone"
local editedZone              -- uiMapID édité quand editedContext vaut "zone"
local editedCustomFilter = 1  -- filtre du joueur ouvert dans l'onglet Mes filtres (NS.db.customFilters)
-- Lu et rendu par l'historique : Annuler une suppression rouvre le filtre rendu.
function NS.GetEditedCustomFilter() return editedCustomFilter end
function NS.SetEditedCustomFilter(index) editedCustomFilter = index end

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

-- Texte tapé dans une boîte de saisie. Rend nil si ce n'est pas un nombre (virgule acceptée),
-- sinon la valeur bornée à min-max et arrondie au pas, et si le texte était dans les bornes.
function NS.ParseInput(setting, text)
    local number = tonumber((strtrim(text):gsub(",", ".")))
    if not number or number ~= number or math.abs(number) == math.huge then return nil end
    local value = Round(math.max(setting.min, math.min(number, setting.max)), setting.step)
    return math.max(setting.min, math.min(value, setting.max)), number >= setting.min and number <= setting.max
end

local function Context(id)
    for _, context in ipairs(NS.ambianceContexts) do
        if context.id == id then return context end
    end
end

-- Contexte livré du contexte édité ; une zone suit celui de son biome.
local function EditedContext()
    return Context(editedContext == "zone" and NS.ZoneBiome(editedZone) or editedContext)
end

-- Valeur du bouton Défaut d'une ligne d'éditeur : valeur livrée, ou valeur du biome pour une zone.
local function AmbianceDefault(key)
    if editedContext == "zone" then return NS.db.ambiance.contexts[NS.ZoneBiome(editedZone)][key] end
    return Context(editedContext).values[key]
end

-- Table lue et écrite par une ligne : CVars, filtres de base, ou ambiance du contexte édité
-- (copie d'un filtre marquée `ambiance`), ou filtre du joueur ouvert (copie marquée `custom`). `write` : la table va être modifiée.
local function Store(setting, write)
    if setting.cvar then return NS.db.values end
    if setting.custom then return NS.db.customFilters[editedCustomFilter] end
    if setting.ambiance then
        if editedContext == "zone" then
            -- Zone sans réglage propre : lue dans son biome, copiée à la première modification.
            return NS.db.ambiance.zones[editedZone] or (write and NS.CustomizeZone(editedZone))
                or NS.db.ambiance.contexts[NS.ZoneBiome(editedZone)]
        end
        return NS.db.ambiance.contexts[editedContext]
    end
    return NS.db.filters
end

-- Filtre de base remplacé par l'ambiance auto, ou teinte remplacée par celles du jour/nuit
-- automatique : sa ligne de l'onglet Filtres est grisée.
local function FollowsAmbiance(setting)
    if setting.cvar or setting.ambiance or setting.custom then return false end
    if NS.db.filters.autoDayNight and (setting.key == "tint" or setting.key == "tintStrength") then return true end
    if not NS.db.ambiance.enabled then return false end
    for _, key in ipairs(NS.ambianceKeys) do
        if key == setting.key then return true end
    end
    return false
end

-- Lignes que le filtre du joueur remplace, teintes de jour et de nuit comprises (voir RenderValues).
local REPLACED_BY_CUSTOM_FILTER = { tint = true, tintStrength = true, vignette = true, grain = true,
                                    tintDay = true, tintDayStrength = true, tintNight = true, tintNightStrength = true }
-- Libellé du réglage nommé `id` (cvar ou key), ou de la teinte dont `id` est l'intensité.
local function LabelOf(id)
    for _, list in ipairs({ NS.settings, NS.filterSettings }) do
        for _, other in ipairs(list) do
            if other.label and ((other.cvar or other.key) == id or other.strength == id) then return other.label end
        end
    end
    return id
end

-- Texte qui dit pourquoi la ligne est grisée, nil si elle est disponible. Grisée tant que le réglage
-- nommé par `requires` est coupé (false ou 0). Réglage requis absent du client (nil) : rien à griser.
-- `requires` peut aussi être une fonction des filtres : la ligne dépend alors de la teinte dont elle est l'intensité.
function NS.UnavailableReason(setting)
    if FollowsAmbiance(setting) then
        local byDayNight = NS.db.filters.autoDayNight and (setting.key == "tint" or setting.key == "tintStrength")
        return L.UNAVAILABLE_SET_BY:format(byDayNight and LabelOf("autoDayNight") or L.AMBIANCE_AUTO)
    end
    -- Filtre du joueur choisi dans la même table (filtres de base, lieu ou zone) : il remplace ces lignes.
    -- Filtres de base sous ambiance auto : leur filtre n'est pas en vigueur, la raison est ailleurs.
    if REPLACED_BY_CUSTOM_FILTER[setting.key] and not setting.custom and (Store(setting).customFilter or 0) ~= 0
        and (setting.ambiance or not NS.db.ambiance.enabled) then
        return L.UNAVAILABLE_REPLACED_BY:format(LabelOf("customFilter"))
    end
    if not setting.requires then return nil end
    if type(setting.requires) == "function" then
        if setting.requires(Store(setting)) then return nil end
        -- Intensité jour ou nuit : Jour et nuit automatiques d'abord, puis sa teinte.
        local missing = Store(setting).autoDayNight == false and "autoDayNight" or setting.key
        return L.UNAVAILABLE_REQUIRES:format(LabelOf(missing))
    end
    local value = Store(setting)[setting.requires]
    if value == false or value == 0 then return L.UNAVAILABLE_REQUIRES:format(LabelOf(setting.requires)) end
end

function NS.IsAvailable(setting)
    return NS.UnavailableReason(setting) == nil
end

local SameValue = NS.SameValue

-- Index du préréglage dont toutes les valeurs égalent les valeurs actuelles, sinon nil.
function NS.CurrentPreset()
    for index in ipairs(NS.presets) do
        local match = true
        for _, setting in ipairs(NS.settings) do
            if match and setting.levels and NS.Exists(setting) then
                match = SameValue(setting, NS.db.values[setting.cvar], NS.Sanitize(setting, setting.levels[index]))
            end
        end
        if match then return index end
    end
end

local function FormatValue(setting, value)
    if type(value) == "boolean" then return value and L.OPT_ON or L.OPT_OFF end
    if setting.names then return setting.names[value] or tostring(value) end
    if setting.step and setting.step < 1 then return ("%.1f"):format(value) end
    return tostring(value)
end

local function DefaultValue(setting)
    if setting.cvar then return NS.GameDefault(setting) end
    if setting.ambiance then return AmbianceDefault(setting.key) end
    return setting.default
end

-- Aperçu : le filtre du joueur ouvert est posé sur le monde (contraste, luminosité et gamma compris) tant que
-- l'onglet Mes filtres est affiché ; une recherche en cours le lève.
local function UpdatePreview()
    -- Filtre ouvert supprimé ou effacé (Tout remettre par défaut) : le dernier de la liste s'ouvre.
    editedCustomFilter = math.min(editedCustomFilter, #NS.db.customFilters)
    local preview = panel:IsShown() and filter == "" and NS.db.tab == "myfilters" and editedCustomFilter or nil
    if preview ~= NS.previewCustomFilter then
        NS.previewCustomFilter = preview
        NS.ApplyFilters()
    end
end

local function Layout()
    local searching = filter ~= ""
    local advanced = NS.db.advancedMode
    -- Mode simple : un onglet avancé encore ouvert (case décochée) laisse place au premier.
    if not advanced and ADVANCED_TABS[NS.db.tab] then NS.db.tab = NS.tabs[1] end
    local matches = {}   -- section -> true si une de ses lignes correspond
    for _, item in ipairs(items) do
        item.match = searching and item.text and item.text:find(filter, 1, true) ~= nil
        if item.match then matches[item.section] = true end
    end
    -- Mode simple : une seule page, lignes `basic` de tous les onglets, sans titres ni repli.
    -- Mode avancé : ligne de l'onglet ouvert, clé présente dans le contexte d'ambiance édité,
    -- section Jour et nuit seulement en mode jour/nuit.
    local function Shown(item)
        if not advanced then return item.basic end
        return item.tab == NS.db.tab
            and (not item.ambianceKey or EditedContext().values[item.ambianceKey] ~= nil)
            and (item.section ~= "SECTION_DAYNIGHT" or NS.db.filters.autoDayNight)
    end
    -- Titre montré seulement si une de ses lignes l'est, section repliée comprise.
    local filled = {}
    for _, item in ipairs(items) do
        if item.section and Shown(item) then filled[item.section] = true end
    end
    -- Recherche : lignes qui correspondent dans tous les onglets et les deux modes, sous leur titre,
    -- sections repliées comprises. Sinon : onglet ouvert, sections repliées cachées.
    local y = 0
    for _, item in ipairs(items) do
        local visible
        if searching then
            visible = item.match or matches[item.header]
        elseif item.header then
            visible = advanced and filled[item.header]
        else
            visible = Shown(item) and not (advanced and item.section and collapsed[item.section])
        end
        if visible then
            item.frame:ClearAllPoints()
            item.frame:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -y)
            item.frame:Show()
            y = y + item.height
        else
            item.frame:Hide()
        end
    end
    panel.content:SetHeight(y + 10)
    panel.noResult:SetShown(searching and y == 0)

    -- Mode avancé : bloc préréglages (Qualité), bloc Ambiance ou bloc Mes filtres, même hauteur, liste en dessous.
    -- Mode simple, onglets cachés : barre d'outils remontée à leur place, préréglages puis Mode
    -- d'ambiance (première ligne du bloc seule) empilés au-dessus de la liste. Rétablir à gauche du
    -- menu de langue (130 de large, TOPRIGHT -14, -73), qui reste sur la rangée.
    local raise = advanced and 0 or 34
    panel.advancedMode:SetPoint("TOPLEFT", 10, -105 + raise)
    panel.redo:SetPoint("TOPRIGHT", advanced and -14 or -14 - 130 - 6, -107 + raise)
    local presets = not searching and (not advanced or NS.db.tab == "quality")
    local ambiance = not searching and (not advanced or NS.db.tab == "ambiance")
    local customFilters = not searching and advanced and NS.db.tab == "myfilters"
    panel.presets:SetShown(presets)
    panel.presets:SetPoint("TOPLEFT", 0, -134 + raise)
    panel.presets:SetPoint("TOPRIGHT", 0, -134 + raise)
    panel.placePreset:SetShown(advanced)
    panel.ambiance:SetShown(ambiance)
    local ambianceTop = advanced and -134 or -134 + raise - 52   -- 4 sous les boutons de préréglage
    panel.ambiance:SetPoint("TOPLEFT", 0, ambianceTop)
    panel.ambiance:SetPoint("TOPRIGHT", 0, ambianceTop)
    panel.ambianceEditor:SetShown(advanced)
    panel.ambianceReset:SetShown(advanced and editedContext == "zone")
    panel.customFilters:SetShown(customFilters)
    local top
    if not advanced then
        top = searching and -134 + raise or ambianceTop - 26
    else
        top = (presets or customFilters or ambiance) and -190 or -134
    end
    panel.scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, top)
    -- Onglets du mode courant, chaînés de gauche à droite.
    local previous
    for index, tab in ipairs(panel.tabs) do
        local id = NS.tabs[index]
        local shown = advanced
        tab:SetShown(shown)
        if shown then
            tab:ClearAllPoints()
            if previous then
                tab:SetPoint("LEFT", previous, "RIGHT", NS.tabGroupStart[id] and panel.tabGroupGap or TAB_GAP, 0)
            else
                tab:SetPoint("TOPLEFT", 14, -70)
            end
            previous = tab
        end
        if not searching and id == NS.db.tab then
            PanelTemplates_SelectTab(tab)
        else
            PanelTemplates_DeselectTab(tab)
        end
    end
    UpdatePreview()
end

-- Panneau caché : rien à rafraîchir, OnShow relit tout à l'ouverture.
function NS.RefreshOptions()
    if not panel or not panel:IsShown() then return end
    -- Annuler peut retirer le filtre ouvert ou changer de mode : borne et lignes visibles relues.
    if not NS.db.customFilters[editedCustomFilter] then editedCustomFilter = #NS.db.customFilters end
    Layout()
    refreshing = true
    for setting, control in pairs(controls) do
        local value = Store(setting)[setting.cvar or setting.key]
        -- Ligne d'éditeur d'une clé que le contexte édité n'a pas (ciel d'un lieu) : cachée, rien à relire.
        if value ~= nil or not setting.ambiance then control.refresh(value) end
    end
    panel.ambianceMode:GenerateMenu()
    panel.ambianceStatus:SetText(L.AMBIANCE_DETECTED:format(NS.DetectedText()))
    panel.ambianceMenu:GenerateMenu()   -- libellé « Cette zone » relu au changement de zone
    panel.customFilterMenu:GenerateMenu()   -- nom relu après un renommage
    -- Nom en cours de frappe : gardé.
    if not panel.customFilterName:HasFocus() then
        panel.customFilterName:SetText(NS.CustomFilterName(editedCustomFilter))
    end
    panel.customFilterDelete:SetEnabled(#NS.db.customFilters > 1)
    panel.applyOnLogin:SetChecked(NS.db.applyOnLogin)
    panel.showMinimap:SetChecked(NS.db.minimap.show)
    panel.advancedMode:SetChecked(NS.db.advancedMode)
    panel.undo:SetEnabled(NS.CanUndo())
    panel.redo:SetEnabled(NS.CanRedo())
    -- Réglages graphiques du lieu en cours : dits sur le bouton, les lignes gardent ceux du joueur.
    local placeGraphics = NS.PlacePresetText(NS.AppliedPlacePreset())
    panel.placePreset:SetText(placeGraphics and L.PLACE_PRESET_ACTIVE:format(placeGraphics) or L.PLACE_PRESET_BUTTON)
    panel.placePreset:SetWidth(math.max(100, panel.placePreset:GetTextWidth() + 24))
    local current = NS.CurrentPreset()
    for index, button in ipairs(panel.presetButtons) do
        if index == current then button:LockHighlight() else button:UnlockHighlight() end
        button.ShowBorder(index == current)
    end
    refreshing = false
end

local function Tooltip(frame, text)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(text, 1, 1, 1, 1, true)
    end)
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-- Largeur = texte + 24 : les libellés allemands et russes sont longs.
local function CreateButton(parent, text, minWidth, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetHeight(22)
    button:SetText(text)
    button:SetWidth(math.max(minWidth, button:GetTextWidth() + 24))
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
    if tip then Tooltip(check, tip) end
    return check
end

-- Contour de `thickness`, posé `outset` à l'extérieur du cadre. Rend la fonction qui l'affiche.
local function CreateBorder(frame, thickness, outset, r, g, b, a)
    local edges = {}
    local function Edge(point1, x1, y1, point2, x2, y2, horizontal)
        local edge = frame:CreateTexture(nil, "OVERLAY")
        edge:SetColorTexture(r, g, b, a)
        edge:SetPoint(point1, x1, y1)
        edge:SetPoint(point2, x2, y2)
        if horizontal then edge:SetHeight(thickness) else edge:SetWidth(thickness) end
        edge:Hide()
        edges[#edges + 1] = edge
    end
    Edge("TOPLEFT", -outset, outset, "TOPRIGHT", outset, outset, true)
    Edge("BOTTOMLEFT", -outset, -outset, "BOTTOMRIGHT", outset, -outset, true)
    Edge("TOPLEFT", -outset, outset, "BOTTOMLEFT", -outset, -outset, false)
    Edge("TOPRIGHT", outset, outset, "BOTTOMRIGHT", outset, -outset, false)
    return function(shown)
        for _, edge in ipairs(edges) do edge:SetShown(shown) end
    end
end

-- Curseur sans gabarit (OptionsSliderTemplate est déprécié). Bouton tenu : seule la valeur affichée
-- suit (`onPreview`), la CVar est écrite au relâchement, pas à chaque pas (farclip : ~1400 pas).
local function CreateSlider(parent, setting, width, onChange, onPreview)
    local slider = CreateFrame("Slider", nil, parent)
    slider:SetOrientation("HORIZONTAL")
    slider:SetSize(width, 16)
    slider:SetMinMaxValues(setting.min, setting.max)
    slider:SetValueStep(setting.step)
    slider:SetObeyStepOnDrag(true)
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    slider:GetThumbTexture():SetSize(32, 32)
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetPoint("LEFT")
    track:SetPoint("RIGHT")
    track:SetHeight(6)
    track:SetColorTexture(0, 0, 0, 0.6)
    -- Repère de la valeur par défaut : la poignée (32) reste dans le curseur, son centre va de 16 à width - 16.
    -- Éditeur d'ambiance : défaut propre à chaque contexte, pas de repère fixe.
    local default = not setting.ambiance and DefaultValue(setting)
    if default and default >= setting.min and default <= setting.max then
        local mark = slider:CreateTexture(nil, "BORDER")
        mark:SetColorTexture(1, 1, 1, 0.35)
        mark:SetSize(1, 10)
        mark:SetPoint("CENTER", slider, "LEFT", 16 + (width - 32) * (default - setting.min) / (setting.max - setting.min), 0)
    end
    local held, moved = false, false
    -- Curseur tenu : un rafraîchissement (zone, minute, /console) ne le ramène pas en arrière.
    slider.IsHeld = function() return held end
    slider:SetScript("OnValueChanged", function(_, value)
        if refreshing then return end
        if held then
            moved = true
            onPreview(Round(value, setting.step))
        else
            onChange(Round(value, setting.step))
        end
    end)
    slider:SetScript("OnMouseDown", function(_, button) held = button == "LeftButton" end)
    -- Clic sans mouvement : rien d'écrit, le réglage n'est pas marqué touché.
    -- Relâché avant d'écrire : le rafraîchissement qui suit montre la valeur relue dans le jeu.
    slider:SetScript("OnMouseUp", function(self)
        local commit = held and moved
        held, moved = false, false
        if commit then onChange(Round(self:GetValue(), setting.step)) end
    end)
    slider:SetScript("OnHide", function() held, moved = false, false end)
    return slider
end

-- Boîte de saisie à côté du curseur. Rien n'est écrit pendant la frappe : Entrée ou perte du focus
-- valide (bornée, arrondie), Échap rend la valeur courante, Tab passe à la boîte suivante.
local function CreateInput(parent, setting, current, change)
    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetSize(48, 20)
    box:SetAutoFocus(false)
    box:SetMaxLetters(6)
    box:SetJustifyH("RIGHT")
    box:SetFontObject(GameFontHighlight)
    -- box.typed : texte tapé depuis la prise du focus. Sans frappe, la perte du focus n'écrit rien :
    -- une valeur /console hors bornes ou hors pas n'est pas ramenée dans le curseur.
    box.typed = false
    box.shade = 1
    function box.Reset()
        box:SetText(FormatValue(setting, current()))
        box:SetTextColor(box.shade, box.shade, box.shade)
        box.typed = false
    end
    local cancelled = false
    local function Commit()
        local value = NS.ParseInput(setting, box:GetText())
        -- Ligne grisée entre-temps : rien d'écrit.
        if box.typed and value and NS.IsAvailable(setting) and not SameValue(setting, value, current()) then
            change(value)
        end
        box.Reset()
    end
    box:HookScript("OnEditFocusGained", function() box.typed = false end)
    box:HookScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        box.typed = true
        local value, inRange = NS.ParseInput(setting, self:GetText())
        if value and inRange then self:SetTextColor(1, 1, 1) else self:SetTextColor(1, 0.125, 0.125) end
    end)
    box:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    box:SetScript("OnEscapePressed", function(self)
        cancelled = true
        self:ClearFocus()
    end)
    box:HookScript("OnEditFocusLost", function()
        if cancelled then box.Reset() else Commit() end
        cancelled = false
    end)
    box:SetScript("OnTabPressed", function(self)
        local index
        for position, other in ipairs(inputs) do
            if other == self then index = position end
        end
        for offset = 1, #inputs - 1 do
            local other = inputs[(index + offset - 1) % #inputs + 1]
            if other:IsVisible() and other:IsEnabled() then
                other:SetFocus()
                return
            end
        end
        self:ClearFocus()
    end)
    Tooltip(box, FormatValue(setting, setting.min) .. " - " .. FormatValue(setting, setting.max))
    return box
end

-- Gabarit propre au moteur retail : repli sur `fallback` s'il manquait au client.
-- Gabarit présent mais en erreur : l'erreur remonte, pas de frame en double.
local function CreateFromTemplate(kind, parent, template, fallback)
    local exists = C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo(template)
    return CreateFrame(kind, nil, parent, exists and template or fallback)
end

-- Haut de ligne, commun à tous les réglages : filet, survol, marqueur « modifié », libellé, aide,
-- bouton Défaut, infobulle complète au survol du texte. Rend la ligne et ses éléments.
local function CreateRowBase(setting, tipWidth)
    local row = CreateFrame("Frame", nil, panel.content)
    row:SetWidth(LIST_WIDTH)
    row.available = true

    local divider = row:CreateTexture(nil, "BACKGROUND")
    divider:SetColorTexture(1, 1, 1, 0.08)
    divider:SetHeight(1)
    divider:SetPoint("BOTTOMLEFT", 8, 0)
    divider:SetPoint("BOTTOMRIGHT", -4, 0)

    -- Surbrillance de la ligne sous le pointeur, contrôles compris : chacun relance le test à l'entrée et à la sortie.
    -- IsMouseOver est géométrique : le test du scroll éteint une ligne à moitié défilée.
    local highlight = row:CreateTexture(nil, "BACKGROUND")
    highlight:SetColorTexture(1, 1, 1, 0.06)
    highlight:SetAllPoints()
    highlight:Hide()
    local function UpdateHover()
        highlight:SetShown(row.available and row:IsVisible() and row:IsMouseOver() and panel.scroll:IsMouseOver())
    end
    function row.HoverWith(frame)
        frame:HookScript("OnEnter", UpdateHover)
        frame:HookScript("OnLeave", UpdateHover)
    end
    row:EnableMouse(true)
    row.HoverWith(row)
    row:HookScript("OnHide", function() highlight:Hide() end)

    row.marker = row:CreateTexture(nil, "ARTWORK")
    row.marker:SetColorTexture(1, 0.82, 0)
    row.marker:SetWidth(2)
    row.marker:SetPoint("TOPLEFT", 2, -6)
    row.marker:SetPoint("BOTTOMLEFT", 2, 6)

    row.label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    row.label:SetPoint("TOPLEFT", 10, -8)
    row.label:SetWidth(tipWidth)
    row.label:SetJustifyH("LEFT")
    row.label:SetMaxLines(2)
    -- Réglage aussi écrit par un menu du jeu : étoile après le nom, menu nommé dans l'infobulle.
    row.label:SetText(setting.menu and (setting.label .. " |cffd1d1d1*|r") or setting.label)

    local tipText = setting.tip
    if setting.restart == "client" then
        tipText = tipText .. " " .. L.OPT_NEEDS_CLIENT_RESTART
    elseif setting.restart then
        tipText = tipText .. " " .. L.OPT_NEEDS_RESTART
    end
    row.tip = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    row.tip:SetPoint("TOPLEFT", row.label, "BOTTOMLEFT", 0, -4)
    row.tip:SetWidth(tipWidth)
    row.tip:SetJustifyH("LEFT")
    row.tip:SetMaxLines(3)
    row.tip:SetText(tipText)
    row.tipText = tipText

    -- Infobulle de ligne : texte entier, même tronqué dans la ligne.
    local hover = CreateFrame("Frame", nil, row)
    hover:SetPoint("TOPLEFT", row.label)
    hover:SetPoint("BOTTOMRIGHT", row.tip)
    hover:EnableMouse(true)
    hover:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(setting.label, 1, 1, 1, 1, true)
        GameTooltip:AddLine(tipText, HELP, HELP, HELP, true)
        if setting.menu then GameTooltip:AddLine(L.ALSO_IN_MENU:format(setting.menu), HELP, HELP, HELP, true) end
        local reason = NS.UnavailableReason(setting)
        if reason then GameTooltip:AddLine(reason, 1, 0.82, 0, true) end
        GameTooltip:Show()
    end)
    hover:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row.HoverWith(hover)

    -- Réglage de CVar (`cvar`) ou filtre (`key`, PanoramaDB.filters ou ambiance, aucune CVar).
    function row.Current()
        return Store(setting)[setting.cvar or setting.key]
    end
    -- `checkpointed` : point d'annulation déjà posé par l'appelant, qui a écrit avant.
    function row.Change(value, checkpointed)
        if not checkpointed then NS.Checkpoint() end
        if setting.cvar then
            NS.db.values[setting.cvar] = value
            NS.Change(setting)
        else
            Store(setting, true)[setting.key] = value
            NS.ApplyFilters()
            NS.RefreshOptions()
        end
    end

    row.reset = CreateFrame("Button", nil, row)
    row.reset:SetSize(22, 22)
    row.reset:SetPoint("LEFT", row, "TOPLEFT", DEFAULT_X, -14)
    row.reset:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton")
    row.reset:SetDisabledTexture("Interface\\Buttons\\UI-RefreshButton")
    row.reset:GetDisabledTexture():SetDesaturated(true)
    row.reset:GetDisabledTexture():SetAlpha(0.5)
    row.reset:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    row.reset:SetMotionScriptsWhileDisabled(true)
    row.reset:SetScript("OnClick", function() row.Change(DefaultValue(setting)) end)
    row.reset:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.OPT_DEFAULT_TIP:format(FormatValue(setting, DefaultValue(setting))), 1, 1, 1)
    end)
    row.reset:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row.HoverWith(row.reset)
    return row
end

-- Hauteur = 8 + libellé + 4 + aide + 8 (+ `extra`), au multiple de 4 supérieur.
local function RowHeight(row, extra, minimum, maximum)
    local height = 8 + row.label:GetStringHeight() + 4 + row.tip:GetStringHeight() + 8 + extra
    return math.max(minimum, math.min(math.ceil(height / 4) * 4, maximum))
end

-- Fin commune : marqueur et bouton Défaut suivent la valeur, ligne grisée si `requires` est coupé.
local function Register(row, setting, section, tab, height, refreshControl, setEnabled)
    row:SetHeight(height)
    controls[setting] = { setting = setting, refresh = function(value)
        refreshControl(value)
        local modified = not SameValue(setting, value, DefaultValue(setting))
        row.marker:SetShown(modified)
        row.reset:SetEnabled(modified)
        -- Ligne grisée : la raison remplace l'aide, qui reste entière dans l'infobulle.
        local reason = NS.UnavailableReason(setting)
        local available = reason == nil
        row.available = available
        row.tip:SetText(reason or row.tipText)
        local shade = available and 1 or DISABLED
        row.label:SetTextColor(shade, shade, shade)
        local tipShade = available and HELP or DISABLED
        row.tip:SetTextColor(tipShade, tipShade, tipShade)
        setEnabled(available)
    end }
    -- Éditeur d'ambiance et onglet Mes filtres hors recherche : leurs lignes doubleraient celles de l'onglet Filtres.
    -- `ambianceKey` : ligne d'éditeur, cachée quand le contexte édité n'a pas cette clé.
    items[#items + 1] = { frame = row, section = section, tab = tab, height = height,
        ambianceKey = setting.ambiance and setting.key or nil,
        -- Copies (éditeur d'ambiance, Mes filtres) : `basic` hérité du filtre, ignoré.
        basic = setting.basic and not (setting.ambiance or setting.custom),
        text = not (setting.ambiance or setting.custom) and Fold(setting.label .. " " .. setting.tip .. " " .. (setting.cvar or setting.key)
            .. " " .. (setting.menu or "")) or nil }
end

local function CreateRow(setting, section, tab)
    local row = CreateRowBase(setting, 276)
    local refreshControl, setEnabled

    if type(setting.default) == "boolean" then
        local check = CreateCheckbox(row, "", nil, row.Change)
        check:SetPoint("LEFT", row, "TOPLEFT", CONTROL_X - 4, -14)
        row.HoverWith(check)
        refreshControl = function(value) check:SetChecked(value) end
        setEnabled = function(enabled) check:SetEnabled(enabled) end
    elseif setting.choices then
        local radios = {}
        local x = CONTROL_X
        for _, choice in ipairs(setting.choices) do
            local radio = CreateFromTemplate("CheckButton", row, "UIRadioButtonTemplate", "UICheckButtonTemplate")
            radio:SetSize(16, 16)
            radio:SetPoint("LEFT", row, "TOPLEFT", x, -14)
            local text = radio.text or radio:CreateFontString(nil, "ARTWORK")
            text:SetFontObject(GameFontHighlightSmall)
            text:ClearAllPoints()
            text:SetPoint("LEFT", radio, "RIGHT", 4, 0)
            text:SetText(tostring(choice))
            -- Clic sur le texte aussi.
            radio:SetHitRectInsets(0, -(text:GetStringWidth() + 4), 0, 0)
            radio:SetScript("OnClick", function(self)
                self:SetChecked(true)
                if row.Current() ~= choice then row.Change(choice) end
            end)
            row.HoverWith(radio)
            radios[choice] = radio
            x = x + 16 + 4 + text:GetStringWidth() + 12
        end
        refreshControl = function(value)
            for choice, radio in pairs(radios) do radio:SetChecked(choice == value) end
        end
        setEnabled = function(enabled)
            for _, radio in pairs(radios) do radio:SetEnabled(enabled) end
        end
    elseif setting.names then
        -- Valeur nommée (Faible latence, Mon filtre, Ciel) : menu déroulant de toutes les valeurs.
        -- Menu relu à chaque ouverture : Mon filtre suit les filtres ajoutés, supprimés ou renommés.
        local dropdown = CreateFrame("DropdownButton", nil, row, "WowStyle1DropdownTemplate")
        dropdown:SetWidth(220)
        dropdown:SetPoint("LEFT", row, "TOPLEFT", CONTROL_X, -14)
        local function IsSelected(value) return SameValue(setting, row.Current(), value) end
        local function Select(value)
            if not IsSelected(value) then row.Change(value) end
        end
        dropdown:SetupMenu(function(_, root)
            root:SetScrollMode(320)   -- autant de filtres que le joueur veut
            local listed = false
            for value = setting.min, setting.max, setting.step do
                root:CreateRadio(FormatValue(setting, value), IsSelected, Select, value)
                listed = listed or IsSelected(value)
            end
            -- Valeur du jeu hors liste (/console, Config.wtf) : affichée et cochée, pas un menu vide.
            local current = row.Current()
            if not listed and current ~= nil then
                root:CreateRadio(FormatValue(setting, current), IsSelected, Select, current)
            end
        end)
        row.HoverWith(dropdown)
        refreshControl = function() dropdown:GenerateMenu() end
        setEnabled = function(enabled) dropdown:SetEnabled(enabled) end
    else
        local box = CreateInput(row, setting, row.Current, row.Change)
        box:SetPoint("LEFT", row, "TOPLEFT", CONTROL_X + 184, -14)
        row.HoverWith(box)
        row.box = box
        -- Saisie tapée en cours : le texte tapé reste. Focus sans frappe : le texte suit la valeur.
        local slider = CreateSlider(row, setting, 172, row.Change, function(value)
            if not box.typed then box:SetText(FormatValue(setting, value)) end
        end)
        slider:SetPoint("LEFT", row, "TOPLEFT", CONTROL_X, -14)
        row.HoverWith(slider)
        refreshControl = function(value)
            if slider.IsHeld() then return end
            slider:SetValue(value)
            if not box.typed then box.Reset() end
        end
        setEnabled = function(enabled)
            slider:SetEnabled(enabled)
            box:SetEnabled(enabled)
            local shade = enabled and 1 or DISABLED
            slider:GetThumbTexture():SetVertexColor(shade, shade, shade)
            box.shade = shade
            if not box.typed then box:SetTextColor(shade, shade, shade) end
        end
    end

    Register(row, setting, section, tab, RowHeight(row, 0, 44, 80), refreshControl, setEnabled)
end

-- Teinte (de jour ou de nuit) : 7 vignettes (Aucune + NS.tints), capture du jeu multipliée par la couleur du filtre à 100 %.
-- Un clic applique le filtre ; intensité à 0 : remise à son défaut, pour que la teinte se voie.
local function CreateTintRow(setting, section, tab)
    local row = CreateRowBase(setting, 500)
    local thumbnails = {}
    for value = 0, setting.max do
        local thumbnail = CreateFrame("Button", nil, row)
        thumbnail:SetSize(62, 40)
        if value == 0 then
            thumbnail:SetPoint("TOPLEFT", row.tip, "BOTTOMLEFT", 0, -8)
        else
            thumbnail:SetPoint("LEFT", thumbnails[value - 1], "RIGHT", 6, 0)
        end
        local image = thumbnail:CreateTexture(nil, "ARTWORK")
        image:SetAllPoints()
        image:SetTexture(MEDIA .. "tint-preview")
        image:SetTexCoord(0.1125, 0.8875, 0, 1)
        local color = NS.tints[value]
        if color then image:SetVertexColor(color[1], color[2], color[3]) end
        thumbnail.caption = thumbnail:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        thumbnail.caption:SetPoint("TOP", thumbnail, "BOTTOM", 0, -3)
        thumbnail.caption:SetWidth(68)
        thumbnail.caption:SetWordWrap(false)
        thumbnail.caption:SetText(setting.names[value])
        thumbnail.ShowSelected = CreateBorder(thumbnail, 2, 2, 1, 0.82, 0, 1)
        local showHover = CreateBorder(thumbnail, 1, 0, 1, 1, 1, 0.6)
        thumbnail:SetScript("OnEnter", function(self)
            showHover(true)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(setting.names[value], 1, 1, 1)
        end)
        thumbnail:SetScript("OnLeave", function()
            showHover(false)
            GameTooltip:Hide()
        end)
        thumbnail:SetScript("OnClick", function()
            local current = Store(setting)
            -- Vignette déjà choisie, intensité déjà là : rien à écrire (pas de zone réglée pour rien).
            local strengthKey = setting.strength
            if current[setting.key] == value and (value == 0 or current[strengthKey] ~= 0) then return end
            NS.Checkpoint()   -- avant l'intensité écrite ci-dessous
            local values = Store(setting, true)
            if value ~= 0 and values[strengthKey] == 0 then
                for _, other in ipairs(NS.filterSettings) do
                    if other.key == strengthKey then
                        local strength = setting.ambiance and AmbianceDefault(strengthKey) or 0
                        values[strengthKey] = strength > 0 and strength or other.default
                    end
                end
            end
            row.Change(value, true)
        end)
        row.HoverWith(thumbnail)
        thumbnails[value] = thumbnail
    end
    Register(row, setting, section, tab, RowHeight(row, 40 + 3 + 12 + 8, 108, 132), function(current)
        for value, thumbnail in pairs(thumbnails) do
            thumbnail.ShowSelected(value == current)
            thumbnail.caption:SetFontObject(value == current and GameFontNormalSmall or GameFontHighlightSmall)
        end
    end, function(enabled)
        for _, thumbnail in pairs(thumbnails) do
            thumbnail:SetEnabled(enabled)
            thumbnail:SetAlpha(enabled and 1 or DISABLED)
        end
    end)
end

-- `section` : clé de locale du titre, identité stable quelle que soit la langue.
local function CreateHeader(section, title, tab)
    local header = CreateFrame("Button", nil, panel.content)
    header:SetSize(LIST_WIDTH, HEADER_HEIGHT)
    local background = header:CreateTexture(nil, "BACKGROUND")
    background:SetColorTexture(1, 1, 1, 0.04)
    background:SetAllPoints()
    local rule = header:CreateTexture(nil, "BORDER")
    rule:SetColorTexture(1, 1, 1, 0.15)
    rule:SetHeight(1)
    rule:SetPoint("BOTTOMLEFT", 4, 0)
    rule:SetPoint("BOTTOMRIGHT", -4, 0)
    local hover = header:CreateTexture(nil, "HIGHLIGHT")
    hover:SetColorTexture(1, 1, 1, 0.06)
    hover:SetAllPoints()
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(14, 14)
    icon:SetPoint("LEFT", 8, 0)
    local text = header:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    text:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    text:SetText(title)
    local function Update()
        icon:SetTexture(collapsed[section] and "Interface\\Buttons\\UI-PlusButton-Up" or "Interface\\Buttons\\UI-MinusButton-Up")
    end
    header:SetScript("OnClick", function()
        collapsed[section] = not collapsed[section] or nil
        Update()
        Layout()
    end)
    Update()
    items[#items + 1] = { frame = header, header = section, tab = tab, height = HEADER_HEIGHT }
end

-- Saisie en cours validée dans le contexte qu'elle vise, avant de changer ou de vider ce contexte.
local function CommitTyping()
    -- Seulement une saisie de Panorama : le chat en cours de frappe reste ouvert.
    local focus = GetCurrentKeyBoardFocus and GetCurrentKeyBoardFocus()
    if focus and focus == panel.customFilterName then return focus:ClearFocus() end
    for _, box in ipairs(inputs) do
        if box == focus then return focus:ClearFocus() end
    end
end
-- Menu de la minimap et commandes /pano : même règle que les boutons de la fenêtre.
NS.CommitTyping = CommitTyping

local function CreatePresets()
    local block = CreateFrame("Frame", nil, panel)
    block:SetPoint("TOPLEFT", 0, -134)
    block:SetPoint("TOPRIGHT", 0, -134)
    block:SetHeight(48)
    panel.presets = block
    local title = block:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("LEFT", block, "TOPLEFT", 14, -10)
    title:SetText(L.OPT_PRESETS)
    -- Renvoi vers l'éditeur de l'onglet Ambiance, ouvert sur la zone réglée ou le lieu du joueur.
    panel.placePreset = CreateButton(block, L.PLACE_PRESET_BUTTON, 100, function()
        local ambiance = NS.db.ambiance
        local place, _, zone = NS.DetectAmbiance()
        local target = zone and ambiance.zones[zone] and zone or place
        -- Intérieur ou météo sur « Mes réglages » : la zone décide (NS.PlacePreset), elle est ouverte.
        local values = ambiance.zones[target] or ambiance.contexts[target]
        if place ~= "dungeon" and values.preset == 0 and values.viewDistance == 0 then
            local current, biome = NS.CurrentZone()
            target = current and ambiance.zones[current] and current or biome
        end
        NS.db.tab = "ambiance"
        if panel.search:GetText() ~= "" then panel.search:SetText("") end
        panel.scroll:SetVerticalScroll(0)
        panel.editAmbiance(target)
    end)
    panel.placePreset:SetPoint("RIGHT", block, "TOPRIGHT", -14, -10)
    Tooltip(panel.placePreset, L.PLACE_PRESET_TIP)
    panel.presetButtons = {}
    for index, preset in ipairs(NS.presets) do
        local button = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
        button:SetSize(142, 24)
        button:SetPoint("TOPLEFT", 14 + (index - 1) * (142 + 6), -24)
        button:SetText(preset.label)
        button:SetScript("OnClick", function() CommitTyping() NS.ApplyPreset(index) end)
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:SetText(preset.label, 1, 1, 1)
            GameTooltip:AddLine(L["PRESET_" .. preset.id:upper() .. "_DESC"], HELP, HELP, HELP, true)
            GameTooltip:AddLine(L.OPT_PRESET_TIP, HELP, HELP, HELP, true)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        button.ShowBorder = CreateBorder(button, 2, 2, 1, 0.82, 0, 1)
        panel.presetButtons[index] = button
    end
end

-- Bloc de l'onglet Ambiance, à la place des préréglages : menu Mode, contexte détecté ; en mode
-- avancé, menu du contexte édité par les lignes de filtres en dessous (ciel pour un moment ; préréglage
-- graphique, distance de vue, filtre du joueur, teinte, vignette et grain pour un lieu). Zone du joueur dans le menu : la choisir lui crée un réglage
-- propre, copié de son biome ; « Type de zone » le supprime.
local function CreateAmbiance()
    local block = CreateFrame("Frame", nil, panel)
    block:SetPoint("TOPLEFT", 0, -134)
    block:SetPoint("TOPRIGHT", 0, -134)
    block:SetHeight(48)
    panel.ambiance = block
    -- Mode : aucun automatisme (filtres de l'onglet Filtres), jour et nuit, ou ambiance auto.
    -- Un seul choix : jour/nuit et ambiance auto ne vont jamais ensemble.
    local modeLabel = block:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    modeLabel:SetPoint("LEFT", block, "TOPLEFT", 14, -10)
    modeLabel:SetText(L.AMBIANCE_MODE)
    local mode = CreateFrame("DropdownButton", nil, block, "WowStyle1DropdownTemplate")
    mode:SetWidth(200)
    mode:SetPoint("LEFT", modeLabel, "RIGHT", 8, 0)
    panel.ambianceMode = mode
    local function IsMode(id)
        local current = NS.db.ambiance.enabled and "auto" or NS.db.filters.autoDayNight and "daynight" or "off"
        return current == id
    end
    local function SetMode(id)
        CommitTyping()
        if IsMode(id) then return end
        NS.Checkpoint()
        NS.db.ambiance.enabled = id == "auto"
        NS.db.filters.autoDayNight = id == "daynight"
        NS.ApplyFilters()
        NS.RefreshOptions()
    end
    mode:SetupMenu(function(_, root)
        root:CreateRadio(L.OPT_OFF, IsMode, SetMode, "off")
        root:CreateRadio(L.autoDayNight, IsMode, SetMode, "daynight")
        root:CreateRadio(L.AMBIANCE_AUTO, IsMode, SetMode, "auto")
    end)
    -- HookScript : garde le survol du gabarit.
    mode:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.AMBIANCE_MODE, 1, 1, 1)
        GameTooltip:AddLine(L.AMBIANCE_MODE_TIP, HELP, HELP, HELP, true)
        GameTooltip:Show()
    end)
    mode:HookScript("OnLeave", function() GameTooltip:Hide() end)
    panel.ambianceStatus = block:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    panel.ambianceStatus:SetTextColor(HELP, HELP, HELP)
    panel.ambianceStatus:SetPoint("RIGHT", block, "TOPRIGHT", -14, -10)
    -- Seconde ligne, mode avancé seulement : contexte édité (lieu, moment, zone).
    local editor = CreateFrame("Frame", nil, block)
    editor:SetAllPoints()
    panel.ambianceEditor = editor
    local label = editor:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("LEFT", block, "TOPLEFT", 14, -36)
    label:SetText(L.AMBIANCE_EDIT)
    local dropdown = CreateFrame("DropdownButton", nil, editor, "WowStyle1DropdownTemplate")
    dropdown:SetWidth(200)   -- noms de zone longs
    dropdown:SetPoint("LEFT", label, "RIGHT", 8, 0)
    panel.ambianceMenu = dropdown
    -- `id` : uiMapID (nombre) pour une zone, id de NS.ambianceContexts sinon.
    local function IsSelected(id)
        if type(id) == "number" then return editedContext == "zone" and editedZone == id end
        return editedContext == id
    end
    local function Edit(id)
        CommitTyping()
        if type(id) == "number" then
            editedContext, editedZone = "zone", id
        else
            editedContext = id
        end
        Layout()
        NS.RefreshOptions()
    end
    panel.editAmbiance = Edit
    panel.ambianceReset = CreateButton(editor, L.AMBIANCE_ZONE_RESET, 100, function()
        CommitTyping()
        NS.Checkpoint()
        NS.db.ambiance.zones[editedZone] = nil
        -- Filtres et réglages du lieu reposés avant le rafraîchissement d'Edit.
        NS.ApplyFilters()
        Edit(NS.ZoneBiome(editedZone))
    end)
    panel.ambianceReset:SetPoint("LEFT", dropdown, "RIGHT", 8, 0)
    Tooltip(panel.ambianceReset, L.AMBIANCE_ZONE_RESET_TIP)
    -- Zones connues, rangées par continent et triées par nom une fois : le menu est reconstruit à
    -- chaque rafraîchissement. `continents` : noms triés ; `allZones[nom]` : ses zones ;
    -- `allZones[1..n]` : zones sans continent connu.
    local allZones, continents
    dropdown:SetupMenu(function(_, root)
        local current = NS.CurrentZone()
        root:CreateTitle(L.AMBIANCE_GROUP_ZONES)
        if current then
            root:CreateRadio(L.AMBIANCE_ZONE:format(NS.ZoneName(current)), IsSelected, Edit, current)
        end
        local saved = {}
        for mapID in pairs(NS.db.ambiance.zones) do
            if mapID ~= current then saved[#saved + 1] = mapID end
        end
        -- Zone quittée sans réglage propre, encore ouverte dans l'éditeur.
        if editedContext == "zone" and editedZone ~= current and not NS.db.ambiance.zones[editedZone] then
            saved[#saved + 1] = editedZone
        end
        table.sort(saved)
        for _, mapID in ipairs(saved) do root:CreateRadio(NS.ZoneName(mapID), IsSelected, Edit, mapID) end
        -- Sous-menu défilant : toute zone se règle sans y être.
        local function ByName(a, b) return NS.ZoneName(a) < NS.ZoneName(b) end
        -- Carte pas encore connue du jeu : rangement refait à la prochaine ouverture.
        local incomplete = false
        if not allZones then
            allZones, continents = {}, {}
            for _, mapID in ipairs(NS.zoneMaps) do
                if not C_Map.GetMapInfo(mapID) then incomplete = true end
                local continent = NS.ZoneContinent(mapID)
                local list = allZones
                if continent then
                    list = allZones[continent]
                    if not list then
                        list = {}
                        allZones[continent] = list
                        continents[#continents + 1] = continent
                    end
                end
                list[#list + 1] = mapID
            end
            table.sort(continents)
            table.sort(allZones, ByName)
            for _, continent in ipairs(continents) do table.sort(allZones[continent], ByName) end
        end
        local others = root:CreateButton(L.AMBIANCE_ALL_ZONES)
        others:SetScrollMode(320)
        for _, continent in ipairs(continents) do
            local submenu = others:CreateButton(continent)
            submenu:SetScrollMode(320)
            for _, mapID in ipairs(allZones[continent]) do
                submenu:CreateRadio(NS.ZoneName(mapID), IsSelected, Edit, mapID)
            end
        end
        for _, mapID in ipairs(allZones) do others:CreateRadio(NS.ZoneName(mapID), IsSelected, Edit, mapID) end
        if incomplete then allZones = nil end
        local group
        for _, context in ipairs(NS.ambianceContexts) do
            if context.group ~= group then
                group = context.group
                root:CreateTitle(L[group])
            end
            root:CreateRadio(L[context.label], IsSelected, Edit, context.id)
        end
    end)
end

-- Bloc de l'onglet Mes filtres : filtre ouvert (les lignes en dessous le règlent), son nom, ajout et suppression.
-- Pour s'en servir, le joueur le choisit à la ligne `customFilter` de l'onglet Filtres ou d'un lieu.
local function CreateCustomFilters()
    local block = CreateFrame("Frame", nil, panel)
    block:SetPoint("TOPLEFT", 0, -134)
    block:SetPoint("TOPRIGHT", 0, -134)
    block:SetHeight(48)
    panel.customFilters = block
    local label = block:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("LEFT", block, "TOPLEFT", 14, -10)
    label:SetText(L.CUSTOM_FILTER_EDIT)
    local dropdown = CreateFrame("DropdownButton", nil, block, "WowStyle1DropdownTemplate")
    dropdown:SetWidth(200)
    dropdown:SetPoint("LEFT", label, "RIGHT", 8, 0)
    panel.customFilterMenu = dropdown
    local function IsSelected(index) return editedCustomFilter == index end
    local function Edit(index)
        CommitTyping()
        editedCustomFilter = index
        Layout()
        NS.RefreshOptions()
    end
    dropdown:SetupMenu(function(_, root)
        root:SetScrollMode(320)   -- autant de filtres que le joueur veut
        for index in ipairs(NS.db.customFilters) do
            root:CreateRadio(NS.CustomFilterName(index), IsSelected, Edit, index)
        end
    end)
    -- HookScript : garde le survol du gabarit.
    dropdown:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.CUSTOM_FILTER_TIP, 1, 1, 1, 1, true)
    end)
    dropdown:HookScript("OnLeave", function() GameTooltip:Hide() end)
    local add = CreateButton(block, L.CUSTOM_FILTER_ADD, 80, function()
        CommitTyping()
        NS.Checkpoint()
        Edit(NS.AddCustomFilter())
    end)
    add:SetPoint("LEFT", dropdown, "RIGHT", 8, 0)
    Tooltip(add, L.CUSTOM_FILTER_ADD_TIP)

    local nameLabel = block:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    nameLabel:SetPoint("LEFT", block, "TOPLEFT", 14, -36)
    nameLabel:SetText(L.CUSTOM_FILTER_RENAME)
    -- Nom du filtre ouvert : Entrée ou perte du focus enregistre, Échap rend le nom courant.
    -- Vide, ou nom par défaut : aucun nom enregistré, le filtre garde son nom par défaut traduit.
    local name = CreateFrame("EditBox", nil, block, "InputBoxTemplate")
    name:SetSize(190, 20)
    name:SetPoint("LEFT", nameLabel, "RIGHT", 14, 0)
    name:SetAutoFocus(false)
    name:SetMaxLetters(24)
    name:SetFontObject(GameFontHighlight)
    panel.customFilterName = name
    local cancelled = false
    name:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    name:SetScript("OnEscapePressed", function(self)
        cancelled = true
        self:ClearFocus()
    end)
    name:HookScript("OnEditFocusLost", function(self)
        local custom = NS.db.customFilters[editedCustomFilter]
        if custom and not cancelled then
            -- `|` : code d'échappement du jeu, retiré du nom.
            local text = strtrim((self:GetText():gsub("|", "")))
            local previous = custom.name
            custom.name = nil   -- nom par défaut lu sans le nom enregistré
            local renamed = text ~= "" and text ~= NS.CustomFilterName(editedCustomFilter) and text or nil
            custom.name = previous
            if renamed ~= previous then
                NS.Checkpoint()
                custom.name = renamed
            end
        end
        cancelled = false
        self:SetText(NS.CustomFilterName(editedCustomFilter))
        NS.RefreshOptions()
    end)
    -- Suppression après confirmation : `data` garde le filtre nommé dans la question, retrouvé à la réponse
    -- (la liste a pu changer entre-temps : /pano reset). Déjà effacé : rien à supprimer.
    StaticPopupDialogs.PANORAMA_DELETE_CUSTOM_FILTER = { text = L.CUSTOM_FILTER_DELETE_CONFIRM, button1 = YES, button2 = NO,
        OnAccept = function(_, custom)
            CommitTyping()
            for index, current in ipairs(NS.db.customFilters) do
                if current == custom then
                    NS.Checkpoint()   -- avant le décalage : Annuler rouvre le filtre ouvert à la suppression
                    -- Filtre ouvert placé après le supprimé : il garde sa place dans la liste.
                    if editedCustomFilter > index then editedCustomFilter = editedCustomFilter - 1 end
                    NS.DeleteCustomFilter(index)
                    break
                end
            end
            Layout()
            NS.RefreshOptions()
        end, timeout = 0, whileDead = true, hideOnEscape = true }
    local delete = CreateButton(block, L.CUSTOM_FILTER_DELETE, 80, function()
        CommitTyping()
        StaticPopup_Show("PANORAMA_DELETE_CUSTOM_FILTER", NS.CustomFilterName(editedCustomFilter), nil, NS.db.customFilters[editedCustomFilter])
    end)
    delete:SetPoint("LEFT", name, "RIGHT", 8, 0)
    Tooltip(delete, L.CUSTOM_FILTER_DELETE_TIP)
    delete:SetMotionScriptsWhileDisabled(true)   -- grisé (un seul filtre) : l'infobulle dit pourquoi
    panel.customFilterDelete = delete
end

local function CreateTabs(search)
    panel.tabs = {}
    panel.tabGroupGap = TAB_GROUP_GAP   -- lu par Layout, qui chaîne les onglets du mode courant
    for index, id in ipairs(NS.tabs) do
        local tab = CreateFromTemplate("Button", panel, "PanelTopTabButtonTemplate", "PanelTabButtonTemplate")
        tab:SetID(index)
        tab:SetText(L[TAB_LABELS[id]])
        PanelTemplates_TabResize(tab, 12)
        if index == 1 then
            tab:SetPoint("TOPLEFT", 14, -70)
        else
            tab:SetPoint("LEFT", panel.tabs[index - 1], "RIGHT", NS.tabGroupStart[id] and TAB_GROUP_GAP or TAB_GAP, 0)
        end
        tab:SetScript("OnClick", function()
            NS.db.tab = id
            -- Clic sur un onglet pendant une recherche : la recherche est vidée (OnTextChanged relance Layout).
            if search:GetText() ~= "" then search:SetText("") end
            panel.scroll:SetVerticalScroll(0)
            Layout()
        end)
        panel.tabs[index] = tab
    end
    -- Rangée plus large que la place à gauche du menu de langue (libellés longs) : onglets resserrés,
    -- puis, si ça ne suffit pas, écart de groupe ramené à l'écart normal.
    local function RowWidth()
        local width = 0
        for index, tab in ipairs(panel.tabs) do
            width = width + tab:GetWidth() + (NS.tabGroupStart[NS.tabs[index]] and TAB_GROUP_GAP or TAB_GAP)
        end
        return width
    end
    if RowWidth() > TABS_WIDTH then
        panel.tabPadding = 0
        for _, tab in ipairs(panel.tabs) do PanelTemplates_TabResize(tab, 0) end
        if RowWidth() > TABS_WIDTH then panel.tabGroupGap = TAB_GAP end
    end
    local rule = panel:CreateTexture(nil, "BORDER")
    rule:SetColorTexture(1, 1, 1, 0.15)
    rule:SetHeight(1)
    rule:SetPoint("TOPLEFT", 14, -102)
    rule:SetPoint("TOPRIGHT", -14, -102)
end

-- Langues proposées, chacune nommée dans sa propre langue.
local LANGUAGES = {
    { "enUS", "English" }, { "frFR", "Français" }, { "deDE", "Deutsch" }, { "esES", "Español" },
    { "itIT", "Italiano" }, { "ptBR", "Português" }, { "ruRU", "Русский" }, { "koKR", "한국어" },
    { "zhCN", "简体中文" }, { "zhTW", "繁體中文" },
}

-- Sélecteur de langue, à droite de la rangée d'onglets. Un choix enregistre PanoramaDB.locale puis
-- recharge l'interface : les libellés des réglages sont traduits une seule fois, à ADDON_LOADED.
local function CreateLanguage(search)
    local dropdown = CreateFrame("DropdownButton", nil, panel, "WowStyle1DropdownTemplate")
    dropdown:SetWidth(130)
    dropdown:SetPoint("TOPRIGHT", -14, -73)
    local function IsSelected(code) return (NS.db.locale or "auto") == code end
    local function SetSelected(code)
        if IsSelected(code) then return end
        NS.db.locale = code ~= "auto" and code or nil
        ReloadUI()
    end
    dropdown:SetupMenu(function(_, root)
        root:CreateRadio(L.OPT_LANGUAGE_AUTO, IsSelected, SetSelected, "auto")
        for _, language in ipairs(LANGUAGES) do
            root:CreateRadio(language[2], IsSelected, SetSelected, language[1])
        end
    end)
    -- HookScript : garde le survol du gabarit.
    dropdown:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.OPT_LANGUAGE_TIP, 1, 1, 1, 1, true)
    end)
    dropdown:HookScript("OnLeave", function() GameTooltip:Hide() end)

    -- Bouton Guide à gauche de la recherche : ouvre le guide en jeu (Guide.lua). Hors de la rangée des
    -- onglets, que les onglets longs (Дополнительно) remplissent.
    local guide = CreateButton(panel, L.OPT_GUIDE, 70, NS.ToggleGuide)
    guide:SetPoint("RIGHT", search, "LEFT", -10, 0)
    Tooltip(guide, L.OPT_GUIDE_TIP)
end

-- Barre sous les onglets, sur tous les onglets : case du mode avancé à gauche, Annuler et Rétablir à droite.
local function CreateToolbar()
    panel.advancedMode = CreateCheckbox(panel, L.OPT_ADVANCED_MODE, L.OPT_ADVANCED_MODE_TIP, function(value)
        NS.db.advancedMode = value
        panel.scroll:SetVerticalScroll(0)
        Layout()
    end)
    panel.advancedMode:SetPoint("TOPLEFT", 10, -105)
    -- Saisie en cours validée avant : sinon sa perte de focus écraserait le résultat du bouton.
    panel.redo = CreateButton(panel, L.OPT_REDO, 90, function() CommitTyping() NS.Redo() end)
    panel.redo:SetPoint("TOPRIGHT", -14, -107)
    panel.redo:SetMotionScriptsWhileDisabled(true)
    Tooltip(panel.redo, L.OPT_REDO_TIP)
    panel.undo = CreateButton(panel, L.OPT_UNDO, 90, function() CommitTyping() NS.Undo() end)
    panel.undo:SetPoint("RIGHT", panel.redo, "LEFT", -6, 0)
    panel.undo:SetMotionScriptsWhileDisabled(true)
    Tooltip(panel.undo, L.OPT_UNDO_TIP)
end

local function CreateFooter()
    local rule = panel:CreateTexture(nil, "BORDER")
    rule:SetColorTexture(1, 1, 1, 0.15)
    rule:SetHeight(1)
    rule:SetPoint("BOTTOMLEFT", 14, 44)
    rule:SetPoint("BOTTOMRIGHT", -14, 44)
    panel.applyOnLogin = CreateCheckbox(panel, L.OPT_APPLY_ON_LOGIN, L.OPT_APPLY_ON_LOGIN_TIP, function(value)
        NS.db.applyOnLogin = value
    end)
    panel.applyOnLogin:SetPoint("BOTTOMLEFT", 10, 11)
    panel.showMinimap = CreateCheckbox(panel, L.OPT_MINIMAP_BUTTON, L.OPT_MINIMAP_BUTTON_TIP, function(value)
        NS.db.minimap.show = value
        if NS.UpdateMinimapButton then NS.UpdateMinimapButton() end
    end)
    panel.showMinimap:SetPoint("LEFT", panel.applyOnLogin.text, "RIGHT", 16, 0)
    local restart = CreateButton(panel, L.OPT_RESTART, 100, NS.RestartGraphics)
    restart:SetPoint("BOTTOMRIGHT", -14, 13)
    Tooltip(restart, L.OPT_RESTART_TIP)
    -- Tout remettre par défaut, après confirmation ; Annuler le défait.
    StaticPopupDialogs.PANORAMA_RESET_ALL = { text = L.OPT_RESET_ALL_CONFIRM, button1 = YES, button2 = NO,
        OnAccept = function() CommitTyping() NS.ResetAll() end, timeout = 0, whileDead = true, hideOnEscape = true }
    -- Action destructive : texte rouge sans fond de bouton, à 16 du bouton Redémarrer.
    local resetAll = CreateFrame("Button", nil, panel)
    resetAll:SetNormalFontObject(GameFontRed)
    resetAll:SetHighlightFontObject(GameFontHighlight)
    resetAll:SetText(L.OPT_RESET_ALL)
    resetAll:SetSize(resetAll:GetTextWidth() + 8, 22)
    resetAll:SetScript("OnClick", function() StaticPopup_Show("PANORAMA_RESET_ALL") end)
    resetAll:SetPoint("RIGHT", restart, "LEFT", -16, 0)
    Tooltip(resetAll, L.OPT_RESET_ALL_TIP)
end

function NS.BuildOptions()
    panel = CreateFrame("Frame", "PanoramaFrame", UIParent, "BasicFrameTemplate")
    panel:Hide()
    panel:SetSize(610, 664)
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
    logo:SetSize(32, 32)
    logo:SetPoint("TOPLEFT", 14, -30)
    logo:SetTexture(MEDIA .. "logo")
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", logo, "TOPRIGHT", 8, -1)
    title:SetText("Panorama")
    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetTextColor(HELP, HELP, HELP)
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)
    subtitle:SetWidth(250)   -- s'arrête avant le bouton Guide
    subtitle:SetJustifyH("LEFT")
    subtitle:SetMaxLines(2)
    subtitle:SetText(L.OPT_SUBTITLE)

    local search = CreateFrame("EditBox", nil, panel, "SearchBoxTemplate")
    panel.search = search
    search:SetSize(180, 20)
    search:SetPoint("TOPRIGHT", -14, -36)
    search.Instructions:SetText(L.OPT_SEARCH)
    search.Instructions:SetTextColor(HELP, HELP, HELP)
    -- HookScript : garde le script du gabarit (texte d'aide, bouton d'effacement).
    search:HookScript("OnTextChanged", function(self)
        filter = Fold(strtrim(self:GetText()))
        panel.scroll:SetVerticalScroll(0)
        Layout()
    end)

    -- Lu par PanelTabButtonMixin:OnShow, qui redimensionne les onglets à chaque affichage.
    panel.tabPadding = 12
    CreateTabs(search)
    CreateLanguage(search)
    CreateToolbar()
    CreatePresets()
    CreateAmbiance()
    CreateCustomFilters()
    CreateFooter()

    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    panel.scroll = scroll
    scroll.scrollBarHideable = true
    scroll:SetPoint("TOPLEFT", 14, -134)
    scroll:SetPoint("BOTTOMRIGHT", -36, 48)
    panel.content = CreateFrame("Frame", nil, scroll)
    panel.content:SetSize(LIST_WIDTH, 10)
    scroll:SetScrollChild(panel.content)
    panel.noResult = scroll:CreateFontString(nil, "ARTWORK", "GameFontDisable")
    panel.noResult:SetPoint("TOPLEFT", 10, -16)
    panel.noResult:SetText(L.OPT_NO_RESULT)

    collapsed = NS.db.collapsed
    -- Éditeur d'ambiance : les lignes de filtres reprises, liées au contexte édité.
    -- Créé avant les sections : la section Jour et nuit de l'onglet Ambiance vient en dessous.
    -- Réglages graphiques du lieu en tête : ils marchent sans l'ambiance auto. Absents pour un moment (ciel).
    -- Titre repliable comme les autres sections ; clé de locale = identité du repli.
    CreateHeader("AMBIANCE_AUTO", L.AMBIANCE_AUTO, "ambiance")
    for _, setting in ipairs(NS.placeSettings) do
        CreateRow(setmetatable({ ambiance = true }, { __index = setting }), "AMBIANCE_AUTO", "ambiance")
    end
    local ambianceKeys = {}
    for _, key in ipairs(NS.ambianceKeys) do ambianceKeys[key] = true end
    for _, setting in ipairs(NS.filterSettings) do
        if ambianceKeys[setting.key] then
            local copy = setmetatable({ ambiance = true }, { __index = setting })
            if setting.key == "tint" then
                CreateTintRow(copy, "AMBIANCE_AUTO", "ambiance")
            else
                CreateRow(copy, "AMBIANCE_AUTO", "ambiance")
            end
        end
    end
    -- Onglet Mes filtres : les réglages d'un filtre du joueur, liés au filtre ouvert.
    for _, setting in ipairs(NS.customFilterSettings) do
        CreateRow(setmetatable({ custom = true }, { __index = setting }), nil, "myfilters")
    end
    -- Titre créé à la première ligne visible : pas de section vide sur un client sans ces CVars.
    local section, title, tab, headerPending
    for _, list in ipairs({ NS.settings, NS.filterSettings }) do
        for _, setting in ipairs(list) do
            if setting.title then
                section, title, tab, headerPending = setting.titleKey, setting.title, setting.tab, true
            -- Jour et nuit automatiques : réglés par le menu Mode du bloc Ambiance, sans ligne.
            elseif setting.key == "autoDayNight" then
            elseif setting.key or NS.Exists(setting) then
                if headerPending then
                    CreateHeader(section, title, tab)
                    headerPending = false
                end
                if setting.key == "tint" or setting.key == "tintDay" or setting.key == "tintNight" then
                    CreateTintRow(setting, section, tab)
                else
                    CreateRow(setting, section, tab)
                end
            end
        end
    end
    -- Lignes dans l'ordre des onglets : la liste de recherche suit le même ordre.
    local order = {}
    for index, id in ipairs(NS.tabs) do order[id] = index end
    for index, item in ipairs(items) do item.position = index end
    table.sort(items, function(a, b)
        if a.tab ~= b.tab then return order[a.tab] < order[b.tab] end
        return a.position < b.position
    end)
    -- Tab suit l'ordre d'affichage, recherche multi-onglets comprise.
    for _, item in ipairs(items) do
        if item.frame.box then inputs[#inputs + 1] = item.frame.box end
    end
    Layout()

    -- Première ouverture : l'éditeur d'ambiance montre le lieu du joueur, pas un moment (ciel seul),
    -- pour que Mon filtre, la teinte et les réglages graphiques du lieu soient visibles d'emblée.
    local editorPlaced = false
    panel:SetScript("OnShow", function()
        if not editorPlaced then
            editorPlaced = true
            local place, _, zone = NS.DetectAmbiance()
            -- Comme le bouton Par lieu : la zone si elle a son réglage propre, sinon son lieu (biome).
            -- editAmbiance rafraîchit déjà le panneau (aperçu compris).
            panel.editAmbiance(zone and NS.db.ambiance.zones[zone] and zone or place)
        else
            NS.RefreshOptions()
        end
    end)
    panel:SetScript("OnHide", UpdatePreview)
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
