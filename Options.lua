-- Fenêtre Panorama, déplaçable et fermée par Échap. Mise en page : DESIGN.md.
-- En-tête (choix Simple / Avancé, menu Options, Guide), bandeau d'état, 4 onglets (Image, HDR, Ambiance,
-- Mes filtres) et recherche, bloc de l'onglet ouvert, liste défilante de sections repliables, pied
-- (Annuler, Rétablir, Redémarrer). Une ligne par réglage : libellé (aide en infobulle), contrôle
-- (case, boutons radio, menu, curseur et boîte de saisie, vignettes de teinte), bouton Défaut.
-- Options > AddOns > Panorama n'affiche qu'un bouton qui ouvre cette fenêtre.
-- Chaque changement est écrit tout de suite : CVar par NS.Change, filtre par NS.ApplyFilters.
local _, NS = ...
local L = NS.L

local MEDIA = "Interface\\AddOns\\Panorama\\Media\\"
local LIST_WIDTH = 560
local CONTROL_X = 296
local DEFAULT_X = 532
local HEADER_HEIGHT = 28
local SUBTITLE_HEIGHT = 24
local ROW_HEIGHT = 28
local TALL_ROW_HEIGHT = 40   -- libellé sur 2 lignes (allemand, russe)
local TINT_ROW_HEIGHT = 92
local TABS_WIDTH = 394       -- rangée d'onglets : 610 - 2 marges de 14 - recherche (180) - 8 d'écart
local TAB_GAP = 2
local HELP = 0.82            -- gris de l'aide : infobulles, compteur, ligne note, texte d'aide de la recherche
local DISABLED = 0.5         -- gris d'une ligne désactivée, et de rien d'autre

local panel
local items = {}      -- dans l'ordre d'affichage : { frame, height, tab, section | header | subtitle, ... }
local controls = {}   -- table du réglage (ou sa copie) -> { setting, refresh }
local inputs = {}     -- boîtes de saisie dans l'ordre d'affichage, pour Tab
local notes = {}      -- lignes note dont le texte suit l'état : fonctions relues à chaque rafraîchissement
local collapsed       -- NS.db.collapsed : clé de locale du titre de section -> true (false : Experts ouverte)
local filter = ""     -- texte de la barre de recherche, en minuscules
local refreshing = false
-- Onglet Mes filtres : index du filtre du joueur ouvert, pas forcément celui choisi dans l'onglet Ambiance.
local editedFilter = 1
local editedContext = "day"   -- règle ouverte dans l'onglet Ambiance (NS.ambianceContexts), ou "zone"
local editedZone              -- uiMapID édité quand editedContext vaut "zone"
local restartValues = {}      -- valeurs des réglages `restart = true` au dernier redémarrage du moteur

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

local function ContextLabel(id)
    return L[Context(id).label]
end

-- Contexte livré de la règle ouverte ; une zone suit celui de son biome.
local function EditedContext()
    return Context(editedContext == "zone" and NS.ZoneBiome(editedZone) or editedContext)
end

-- Valeur du bouton Défaut d'une ligne de règle : valeur livrée, ou valeur du biome pour une zone.
local function AmbianceDefault(key)
    if editedContext == "zone" then return NS.db.ambiance.contexts[NS.ZoneBiome(editedZone)][key] end
    return Context(editedContext).values[key]
end

-- Valeurs de la règle ouverte. Zone sans réglage propre : lue dans son biome, copiée à la première
-- modification (`write`).
local function RuleValues(write)
    if editedContext == "zone" then
        return NS.db.ambiance.zones[editedZone] or (write and NS.CustomizeZone(editedZone))
            or NS.db.ambiance.contexts[NS.ZoneBiome(editedZone)]
    end
    return NS.db.ambiance.contexts[editedContext]
end

-- Filtre du joueur choisi par le menu Filtre de l'onglet Ambiance (0 : Base) et sa table, nil pour Base.
local function ChosenCustomFilter()
    return NS.db.customFilters[NS.db.filters.customFilter]
end

-- Table lue et écrite par une ligne : CVars, filtres de base, règle ouverte (copie d'un filtre marquée
-- `ambiance`), ou filtre du joueur ouvert dans l'onglet Mes filtres (copie marquée `custom`).
-- `write` : la table va être modifiée.
local function Store(setting, write)
    if setting.cvar then return NS.db.values end
    if setting.custom then return NS.db.customFilters[editedFilter] end
    if setting.ambiance then return RuleValues(write) end
    return NS.db.filters
end

-- Teinte et intensité de base, réglées par le mode Jour et nuit tant qu'il est actif.
local function FollowsDayNight(setting)
    if setting.cvar or setting.ambiance or setting.custom then return false end
    return NS.db.filters.autoDayNight and (setting.key == "tint" or setting.key == "tintStrength")
end

-- Lignes que le filtre du joueur remplace, teintes de jour et de nuit comprises (voir RenderValues).
local REPLACED_BY_CUSTOM_FILTER = { tint = true, tintStrength = true, vignette = true, grain = true,
                                    tintDay = true, tintDayStrength = true, tintNight = true, tintNightStrength = true }
-- Ligne du look de base remplacée par la règle du lieu en mode Selon le lieu (NS.ambianceKeys d'Ambiance.lua).
local function SetByPlace(key)
    for _, other in ipairs(NS.ambianceKeys) do
        if other == key then return true end
    end
    return false
end
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
-- `requires` peut aussi être une fonction des valeurs : la ligne dépend alors de la teinte dont elle est l'intensité.
function NS.UnavailableReason(setting)
    if FollowsDayNight(setting) then return L.UNAVAILABLE_SET_BY:format(LabelOf("autoDayNight")) end
    local values = Store(setting)
    if not values then return nil end   -- filtre du joueur effacé : ligne cachée
    -- Look de base en mode Selon le lieu : la règle du lieu le remplace (la recherche montre ces lignes).
    if values == NS.db.filters and NS.db.ambiance.enabled and SetByPlace(setting.key) then
        return L.UNAVAILABLE_BY_PLACE
    end
    -- Filtre du joueur choisi dans la même table (filtres de base, lieu ou zone) : il remplace ces lignes.
    if REPLACED_BY_CUSTOM_FILTER[setting.key] and not setting.custom and (values.customFilter or 0) ~= 0
        and (setting.ambiance or not NS.db.ambiance.enabled) then
        return L.UNAVAILABLE_REPLACED_BY:format(LabelOf("customFilter"))
    end
    if not setting.requires then return nil end
    if type(setting.requires) == "function" then
        if setting.requires(values) then return nil end
        -- Intensité jour ou nuit : mode Jour et nuit d'abord, puis sa teinte.
        local missing = values.autoDayNight == false and "autoDayNight" or setting.key
        return L.UNAVAILABLE_REQUIRES:format(LabelOf(missing))
    end
    local value = values[setting.requires]
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
    if setting.cvar then return (NS.GameDefault(setting)) end
    if setting.ambiance then return AmbianceDefault(setting.key) end
    return setting.default
end

-- Réglage des filtres nommé `key`.
local function FilterSetting(key)
    for _, setting in ipairs(NS.filterSettings) do
        if setting.key == key then return setting end
    end
end

-- Couleur d'une vignette en valeurs de filtre du joueur (0-100) ; « Aucune » : 100, 100, 100.
local function TintColor(value)
    local color = NS.tints[value]
    if not color then return 100, 100, 100 end
    return Round(color[1] * 100, 1), Round(color[2] * 100, 1), Round(color[3] * 100, 1)
end

-- Vignette dont la couleur égale celle du filtre du joueur, nil pour une couleur libre.
local function CustomTint(custom)
    for value = 0, #NS.tints do
        local red, green, blue = TintColor(value)
        if custom.tintRed == red and custom.tintGreen == green and custom.tintBlue == blue then return value end
    end
end

-- Réglages des règles d'ambiance : zone avec son réglage propre, sinon lieu détecté.
-- Même choix à l'ouverture de la fenêtre et au bouton du bandeau.
local function DetectedRule()
    local place, _, zone = NS.DetectAmbiance()
    return zone and NS.db.ambiance.zones[zone] and zone or place
end

local function IsCollapsed(section)
    return collapsed[section] == true or (section == "SECTION_EXPERT" and collapsed[section] == nil)
end

-- Aperçu, onglet Mes filtres ouvert sans recherche : le monde montre le filtre ouvert.
local function UpdatePreview()
    local custom = panel:IsShown() and filter == "" and NS.db.tab == "myfilters" and editedFilter or nil
    if custom ~= NS.previewCustomFilter then
        NS.previewCustomFilter = custom
        NS.ApplyFilters()
    end
end

-- Ligne de l'onglet ouvert, hors recherche : mode d'affichage, clé présente dans la règle ouverte,
-- condition propre (`when`).
local function Shown(item)
    return item.tab == NS.db.tab and (NS.db.advancedMode or item.basic)
        and (not item.ambianceKey or EditedContext().values[item.ambianceKey] ~= nil)
        and (not item.when or item.when())
end

-- Compteur « n modifiés » des titres : lignes candidates (montrées hors repli) marquées modifiées.
local function UpdateCounters()
    local modified = {}
    for _, item in ipairs(items) do
        if item.candidate and item.modified and item.section then
            modified[item.section] = (modified[item.section] or 0) + 1
        end
    end
    for _, item in ipairs(items) do
        if item.header then item.SetCount(modified[item.header] or 0) end
    end
end

local function Layout()
    local searching = filter ~= ""
    local advanced = NS.db.advancedMode
    -- Filtre ouvert supprimé (Supprimer, Annuler d'un Nouveau) : le suivant, ou le dernier s'il était en fin.
    editedFilter = math.min(editedFilter, #NS.db.customFilters)
    UpdatePreview()
    -- Candidates : lignes de l'onglet ouvert, ou lignes qui correspondent à la recherche dans les 4 onglets.
    local filled = {}   -- section ou sous-titre -> true si une de ses lignes est candidate
    for _, item in ipairs(items) do
        if not (item.header or item.subtitle) then
            if searching then
                item.candidate = item.text ~= nil and item.text:find(filter, 1, true) ~= nil
            else
                item.candidate = Shown(item)
            end
            if item.candidate then
                if item.section then filled[item.section] = true end
                if item.subsection then filled[item.subsection] = true end
            end
        end
    end
    -- Titres et sous-titres : mode avancé ou recherche, seulement si une de leurs lignes est candidate.
    -- Repli : mode avancé hors recherche seulement ; le titre d'une section repliée reste.
    local y = 0
    for _, item in ipairs(items) do
        local visible
        if item.header then
            visible = (searching or advanced) and filled[item.header]
            item.UpdateIcon()
        elseif item.subtitle then
            visible = filled[item.subtitle] and (searching or advanced and not IsCollapsed(item.section))
        else
            visible = item.candidate and (searching or not (advanced and item.section and IsCollapsed(item.section)))
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
    UpdateCounters()

    -- Bloc de l'onglet ouvert, caché pendant une recherche ; liste juste en dessous.
    local tab = not searching and NS.db.tab
    panel.imageBlock:SetShown(tab == "image")
    panel.myFiltersBlock:SetShown(tab == "myfilters")
    panel.ambianceBlock:SetShown(tab == "ambiance")
    -- Bloc Ambiance : Mode, Ici, puis Filtre (modes Fixe et Jour et nuit) et Règle (mode avancé), 28 par ligne.
    local filterRow = not NS.db.ambiance.enabled
    panel.filterRow:SetShown(filterRow)
    panel.ruleRow:SetShown(advanced)
    panel.ruleRow:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, filterRow and -28 or 0)
    panel.ambianceReset:SetShown(editedContext == "zone")
    local top = 136
    if tab == "image" then
        top = 192
    elseif tab == "myfilters" then
        top = 196
    elseif tab == "ambiance" then
        top = 196 + (filterRow and 28 or 0) + (advanced and 28 or 0)
    end
    panel.scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -top)
    for index, tabButton in ipairs(panel.tabs) do
        if NS.tabs[index] == tab then
            PanelTemplates_SelectTab(tabButton)
        else
            PanelTemplates_DeselectTab(tabButton)
        end
    end
end

-- Cadre gris des boutons de navigation et d'aide (DESIGN.md § 5) : largeur au texte, `minWidth` au moins.
local function FitButton(button, minWidth)
    button:SetWidth(math.max(minWidth, button:GetTextWidth() + 24))
end

-- Réglage `restart = true` changé depuis le dernier redémarrage du moteur (préréglage et Annuler compris).
local function RestartPending()
    for _, setting in ipairs(NS.settings) do
        if setting.restart == true and NS.Exists(setting)
            and not SameValue(setting, NS.db.values[setting.cvar], restartValues[setting.cvar]) then
            return true
        end
    end
    return false
end

local function TakeRestartValues()
    for _, setting in ipairs(NS.settings) do
        if setting.restart == true then restartValues[setting.cvar] = NS.db.values[setting.cvar] end
    end
end

function NS.OnGraphicsRestarted()
    TakeRestartValues()
    NS.RefreshOptions()
end

-- Bandeau : look posé sur le monde, puis ce qui l'impose, du plus fort au plus faible.
-- Rend le texte, puis le texte et l'action du bouton (nil : pas de bouton).
local function StatusText()
    local applied = NS.AppliedFilters()
    local base = NS.db.filters
    local look = NS.CustomFilterName(applied.customFilter or 0)
    if not look then
        local tint, strength = applied.tint, applied.tintStrength
        -- Jour et nuit : jamais avec Selon le lieu, lu dans les filtres de base.
        if applied == base and base.autoDayNight then
            if NS.NightFactor() >= 0.5 then
                tint, strength = base.tintNight, base.tintNightStrength
            else
                tint, strength = base.tintDay, base.tintDayStrength
            end
        end
        if tint ~= 0 and strength > 0 then
            look = L.STATUS_TINT:format(FilterSetting("tint").names[tint], strength)
        else
            look = L.STATUS_NO_TINT
        end
    end
    local searching = filter ~= ""
    local tab = not searching and NS.db.tab
    local source, button, action
    if tab == "myfilters" and (NS.previewCustomFilter ~= base.customFilter or NS.db.ambiance.enabled) then
        source = L.STATUS_PREVIEW_FILTER
    elseif NS.db.ambiance.enabled then
        local place, moment, zone = NS.DetectAmbiance()
        local where = zone and NS.db.ambiance.zones[zone] and NS.ZoneName(zone) or ContextLabel(place)
        if moment then where = where .. ", " .. ContextLabel(moment) end
        source = L.STATUS_BY_PLACE:format(where)
        local target = DetectedRule()
        local targetShown = tab == "ambiance" and (not NS.db.advancedMode
            or (type(target) == "number" and editedContext == "zone" and editedZone == target)
            or editedContext == target)
        if not targetShown then button, action = L.STATUS_EDIT_RULE, "rule" end
    elseif base.autoDayNight and base.customFilter == 0 then
        source = L.STATUS_SET_BY:format(L.autoDayNight, ContextLabel(NS.CurrentMoment()))
        if tab ~= "ambiance" then button, action = L.STATUS_EDIT, "ambiance" end
    else
        source = L.STATUS_BY_YOU
        if tab ~= "ambiance" then button, action = L.STATUS_EDIT, "ambiance" end
    end
    return look .. " · " .. source, button, action
end

local function UpdateStatus()
    local text, button, action = StatusText()
    local status = panel.status
    status.text = text
    status.value:SetText(text)
    status.action = action
    status.button:SetShown(button ~= nil)
    status.value:ClearAllPoints()
    status.value:SetPoint("LEFT", status.label, "RIGHT", 4, 0)
    if button then
        status.button:SetText(button)
        FitButton(status.button, 80)
        status.value:SetPoint("RIGHT", status.button, "LEFT", -8, 0)
    else
        status.value:SetPoint("RIGHT", status, "RIGHT", -8, 0)
    end
end

-- Panneau caché : rien à rafraîchir, OnShow relit tout à l'ouverture.
local function RefreshControls()
    for setting, control in pairs(controls) do
        local values = Store(setting)
        local value = values and values[setting.cvar or setting.key]
        -- Ligne de règle d'une clé que la règle n'a pas (ciel d'un lieu), filtre du joueur absent :
        -- ligne cachée, rien à relire.
        if values and (value ~= nil or not setting.ambiance) then control.refresh(value) end
    end
    for _, update in ipairs(notes) do update() end
    UpdateCounters()
    UpdateStatus()
    panel.advancedRadio:SetChecked(NS.db.advancedMode)
    panel.simpleRadio:SetChecked(not NS.db.advancedMode)
    panel.ambianceMode:GenerateMenu()
    panel.ambianceMenu:GenerateMenu()   -- libellé « Cette zone » relu au changement de zone
    panel.customFilterMenu:GenerateMenu()   -- nom relu après un renommage
    panel.myFilterMenu:GenerateMenu()
    local here = NS.DetectedText()
    panel.here:SetText(here)
    panel.here.text = here
    -- Nom en cours de frappe : gardé.
    if not panel.customFilterName:HasFocus() then
        panel.customFilterName:SetText(NS.CustomFilterName(editedFilter) or "")
    end
    panel.customFilterDelete:SetEnabled(#NS.db.customFilters > 1)
    panel.undo:SetEnabled(NS.CanUndo())
    panel.redo:SetEnabled(NS.CanRedo())
    -- Réglages graphiques imposés par le lieu en cours : dits à droite des préréglages.
    local placeGraphics = NS.PlacePresetText(NS.AppliedPlacePreset())
    local placeText = placeGraphics and L.PLACE_PRESET_ACTIVE:format(placeGraphics)
    panel.placePreset:SetShown(placeText ~= nil and NS.db.advancedMode)
    panel.placePresetText:SetShown(placeText ~= nil and not NS.db.advancedMode)
    if placeText then
        panel.placePreset:SetText(placeText)
        FitButton(panel.placePreset, 100)
        panel.placePresetText:SetText(placeText)
    end
    local current = NS.CurrentPreset()
    for index, button in ipairs(panel.presetButtons) do
        if index == current then button:LockHighlight() else button:UnlockHighlight() end
        button.ShowBorder(index == current)
    end
    local pending = RestartPending()
    if pending then panel.restart:LockHighlight() else panel.restart:UnlockHighlight() end
    panel.restart.ShowBorder(pending)
    panel.restart.pending = pending
end

function NS.RefreshOptions()
    if not panel or not panel:IsShown() then return end
    -- Avant les contrôles : l'aperçu repose les filtres, qui peuvent rappeler ce rafraîchissement.
    Layout()
    local wasRefreshing = refreshing
    refreshing = true
    -- Erreur pendant la relecture : drapeau rendu quand même, sinon chaque case et curseur ignorerait les clics.
    local ok, err = pcall(RefreshControls)
    refreshing = wasRefreshing
    if not ok then geterrorhandler()(err) end
end

local function Tooltip(frame, text)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(text, 1, 1, 1, 1, true)
    end)
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-- Menu déroulant : HookScript garde le survol du gabarit.
local function DropdownTooltip(dropdown, title, text)
    dropdown:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(title, 1, 1, 1, 1, true)
        if text then GameTooltip:AddLine(text, HELP, HELP, HELP, true) end
        GameTooltip:Show()
    end)
    dropdown:HookScript("OnLeave", function() GameTooltip:Hide() end)
end

-- Gabarit propre au moteur retail : repli sur `fallback` s'il manquait au client.
-- Gabarit présent mais en erreur : l'erreur remonte, pas de frame en double.
local function CreateFromTemplate(kind, parent, template, fallback)
    local exists = C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo(template)
    return CreateFrame(kind, nil, parent, exists and template or fallback)
end

-- Action sur les réglages : bouton natif. Largeur = texte + 24 : les libellés allemands et russes sont longs.
local function CreateButton(parent, text, minWidth, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetHeight(22)
    button:SetText(text)
    FitButton(button, minWidth)
    button:SetScript("OnClick", onClick)
    return button
end

-- Navigation et aide : bouton gris, qui ne change aucun réglage.
local function CreateGreyButton(parent, text, minWidth, onClick)
    local button = CreateFromTemplate("Button", parent, "UIMenuButtonStretchTemplate", "UIPanelButtonTemplate")
    button:SetHeight(22)
    button:SetText(text)
    FitButton(button, minWidth)
    button:SetScript("OnClick", onClick)
    return button
end

local function CreateCheckbox(parent, onChange)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetSize(26, 26)
    check:SetScript("OnClick", function(self)
        if not refreshing then onChange(self:GetChecked() and true or false) end
    end)
    return check
end

-- Bouton radio 16 x 16, texte 4 après, clic sur le texte compris. `width` : radio et texte.
local function CreateRadio(parent, text, onClick)
    local radio = CreateFromTemplate("CheckButton", parent, "UIRadioButtonTemplate", "UICheckButtonTemplate")
    radio:SetSize(16, 16)
    local label = radio.text or radio:CreateFontString(nil, "ARTWORK")
    label:SetFontObject(GameFontHighlightSmall)
    label:ClearAllPoints()
    label:SetPoint("LEFT", radio, "RIGHT", 4, 0)
    label:SetText(text)
    radio:SetHitRectInsets(0, -(label:GetStringWidth() + 4), 0, 0)
    radio:SetScript("OnClick", function(self)
        self:SetChecked(true)
        onClick()
    end)
    radio.width = 16 + 4 + label:GetStringWidth()
    return radio
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
    -- Ligne de règle : défaut propre à chaque règle, pas de repère fixe.
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
        local value = current()
        if value ~= nil then box:SetText(FormatValue(setting, value)) end
        box:SetTextColor(box.shade, box.shade, box.shade)
        box.typed = false
    end
    local cancelled = false
    local function Commit()
        local value = NS.ParseInput(setting, box:GetText())
        -- Ligne grisée ou cachée entre-temps : rien d'écrit.
        if box.typed and value and current() ~= nil and NS.IsAvailable(setting)
            and not SameValue(setting, value, current()) then
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

-- Ligne de liste vide : filet, surbrillance au survol. `HoverWith` : un contrôle relance le test de survol.
local function CreateListRow()
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
    return row
end

-- Haut de ligne, commun à tous les réglages : marqueur « modifié », libellé (aide en infobulle),
-- bouton Défaut. `height` : hauteur imposée (vignettes), sinon 28 ou 40 selon le libellé.
-- Rend la ligne ; `row.middle` : y du centre des contrôles.
local function CreateRowBase(setting, height)
    local row = CreateListRow()

    row.marker = row:CreateTexture(nil, "ARTWORK")
    row.marker:SetColorTexture(1, 0.82, 0)
    row.marker:SetWidth(2)
    row.marker:SetPoint("TOPLEFT", 2, -6)
    row.marker:SetPoint("BOTTOMLEFT", 2, 6)

    -- Ligne dépendante (`requires`) : libellé décalé de 12, sous la ligne dont elle dépend.
    local labelX = setting.requires and 22 or 10
    row.label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    row.label:SetWidth(276 + 10 - labelX)
    row.label:SetJustifyH("LEFT")
    row.label:SetMaxLines(2)
    row.label:SetText(setting.label)
    row.height = height or (row.label:GetStringHeight() > 16 and TALL_ROW_HEIGHT or ROW_HEIGHT)
    row.middle = height and -14 or -row.height / 2
    row.label:SetPoint("LEFT", row, "TOPLEFT", labelX, row.middle)

    local tipText = setting.tip
    if setting.restart == "client" then
        tipText = tipText .. " " .. L.OPT_NEEDS_CLIENT_RESTART
    elseif setting.restart then
        tipText = tipText .. " " .. L.OPT_NEEDS_RESTART
    end
    -- Infobulle du libellé : aide, menu du jeu qui écrit aussi le réglage, raison d'une ligne grisée.
    local hover = CreateFrame("Frame", nil, row)
    hover:SetAllPoints(row.label)
    hover:EnableMouse(true)
    hover:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(setting.label, 1, 1, 1, 1, true)
        if tipText then GameTooltip:AddLine(tipText, HELP, HELP, HELP, true) end
        if setting.menu then GameTooltip:AddLine(L.ALSO_IN_MENU:format(setting.menu), HELP, HELP, HELP, true) end
        local reason = NS.UnavailableReason(setting)
        if reason then GameTooltip:AddLine(reason, 1, 0.82, 0, true) end
        GameTooltip:Show()
    end)
    hover:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row.HoverWith(hover)

    -- Réglage de CVar (`cvar`) ou filtre (`key`, PanoramaDB.filters, règle ou filtre du joueur, aucune CVar).
    function row.Current()
        local values = Store(setting)
        return values and values[setting.cvar or setting.key]
    end
    -- `checkpointed` : point d'annulation déjà posé par l'appelant, qui a écrit avant.
    function row.Change(value, checkpointed)
        if not checkpointed then NS.Checkpoint() end
        if setting.cvar then
            NS.db.values[setting.cvar] = value
            NS.Change(setting)
        else
            local values = Store(setting, true)
            if not values then return end
            values[setting.key] = value
            NS.ApplyFilters()
            NS.RefreshOptions()
        end
    end

    row.reset = CreateFrame("Button", nil, row)
    row.reset:SetSize(22, 22)
    row.reset:SetPoint("LEFT", row, "TOPLEFT", DEFAULT_X, row.middle)
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

-- Fin commune : marqueur et bouton Défaut suivent la valeur, ligne grisée si `requires` est coupé.
-- `item` : section, tab, basic, when, subsection. `noDefault` : ni marqueur ni bouton Défaut (couleur
-- d'un filtre du joueur : ses lignes Rouge, Vert, Bleu les portent).
local function Register(row, setting, item, refreshControl, setEnabled, noDefault)
    row:SetHeight(row.height)
    if noDefault then
        row.marker:Hide()
        row.reset:Hide()
    end
    controls[setting] = { setting = setting, refresh = function(value)
        refreshControl(value)
        item.modified = not noDefault and not SameValue(setting, value, DefaultValue(setting))
        if not noDefault then
            row.marker:SetShown(item.modified)
            row.reset:SetEnabled(item.modified)
        end
        local available = NS.UnavailableReason(setting) == nil
        row.available = available
        local shade = available and 1 or DISABLED
        row.label:SetTextColor(shade, shade, shade)
        setEnabled(available)
    end }
    item.frame = row
    item.height = row.height
    -- `ambianceKey` : ligne de règle, cachée quand la règle ouverte n'a pas cette clé.
    item.ambianceKey = setting.ambiance and setting.key or nil
    -- Copies (règles, filtre du joueur) hors recherche : elles doubleraient les lignes de base.
    if not (setting.ambiance or setting.custom) then
        item.text = Fold(setting.label .. " " .. (setting.tip or "") .. " " .. (setting.cvar or setting.key)
            .. " " .. (setting.menu or ""))
    end
    items[#items + 1] = item
end

local function CreateRow(setting, item)
    local row = CreateRowBase(setting)
    local middle = row.middle
    local refreshControl, setEnabled

    if type(setting.default) == "boolean" then
        local check = CreateCheckbox(row, row.Change)
        check:SetPoint("LEFT", row, "TOPLEFT", CONTROL_X - 4, middle)
        row.HoverWith(check)
        refreshControl = function(value) check:SetChecked(value) end
        setEnabled = function(enabled) check:SetEnabled(enabled) end
    elseif setting.choices then
        local radios = {}
        local x = CONTROL_X
        for _, choice in ipairs(setting.choices) do
            local radio = CreateRadio(row, tostring(choice), function()
                if row.Current() ~= choice then row.Change(choice) end
            end)
            radio:SetPoint("LEFT", row, "TOPLEFT", x, middle)
            row.HoverWith(radio)
            radios[choice] = radio
            x = x + radio.width + 12
        end
        refreshControl = function(value)
            for choice, radio in pairs(radios) do radio:SetChecked(choice == value) end
        end
        setEnabled = function(enabled)
            for _, radio in pairs(radios) do radio:SetEnabled(enabled) end
        end
    elseif setting.names then
        -- Valeur nommée (Faible latence, Filtre d'une règle, Ciel) : menu déroulant de toutes les valeurs.
        -- Menu relu à chaque ouverture : le Filtre suit les filtres ajoutés, supprimés ou renommés.
        local dropdown = CreateFrame("DropdownButton", nil, row, "WowStyle1DropdownTemplate")
        dropdown:SetWidth(220)
        dropdown:SetPoint("LEFT", row, "TOPLEFT", CONTROL_X, middle)
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
        box:SetPoint("LEFT", row, "TOPLEFT", CONTROL_X + 184, middle)
        row.HoverWith(box)
        row.box = box
        -- Saisie tapée en cours : le texte tapé reste. Focus sans frappe : le texte suit la valeur.
        local slider = CreateSlider(row, setting, 172, row.Change, function(value)
            if not box.typed then box:SetText(FormatValue(setting, value)) end
        end)
        slider:SetPoint("LEFT", row, "TOPLEFT", CONTROL_X, middle)
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

    Register(row, setting, item, refreshControl, setEnabled)
end

-- Teinte : 7 vignettes (Aucune + NS.tints), capture du jeu multipliée par la couleur du filtre à 100 %.
-- Un clic applique le filtre ; intensité à 0 : remise à son défaut, pour que la teinte se voie.
-- `setting.customColor` : couleur d'un filtre du joueur, écrite dans Rouge, Vert, Bleu.
local function CreateTintRow(setting, item)
    local row = CreateRowBase(setting, TINT_ROW_HEIGHT)
    local thumbnails = {}
    local strengthKey = setting.strength
    -- Intensité à poser avec une teinte choisie à intensité 0 : défaut de la règle ou du réglage.
    local function StrengthDefault()
        local strength = setting.ambiance and AmbianceDefault(strengthKey) or 0
        return strength > 0 and strength or FilterSetting(strengthKey).default
    end
    local function Choose(value)
        local current = Store(setting)
        if not current then return end
        if setting.customColor then
            -- Vignette déjà choisie, intensité déjà là : rien à écrit.
            if CustomTint(current) == value and (value == 0 or current.tintStrength ~= 0) then return end
            NS.Checkpoint()
            current.tintRed, current.tintGreen, current.tintBlue = TintColor(value)
            if value ~= 0 and current.tintStrength == 0 then current.tintStrength = StrengthDefault() end
            NS.ApplyFilters()
            NS.RefreshOptions()
            return
        end
        -- Vignette déjà choisie, intensité déjà là : rien à écrire (pas de zone réglée pour rien).
        if current[setting.key] == value and (value == 0 or current[strengthKey] ~= 0) then return end
        NS.Checkpoint()   -- avant l'intensité écrite ci-dessous
        local values = Store(setting, true)
        if value ~= 0 and values[strengthKey] == 0 then values[strengthKey] = StrengthDefault() end
        row.Change(value, true)
    end
    for value = 0, #NS.tints do
        local thumbnail = CreateFrame("Button", nil, row)
        thumbnail:SetSize(62, 40)
        if value == 0 then
            thumbnail:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -28)
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
        thumbnail:SetScript("OnClick", function() Choose(value) end)
        row.HoverWith(thumbnail)
        thumbnails[value] = thumbnail
    end
    -- Couleur d'un filtre du joueur : vignette retrouvée par sa couleur, aucune pour une couleur libre.
    if setting.customColor then
        function row.Current()
            local custom = Store(setting)
            return custom and CustomTint(custom)
        end
    end
    Register(row, setting, item, function(stored)
        local current = setting.customColor and row.Current() or stored
        for value, thumbnail in pairs(thumbnails) do
            thumbnail.ShowSelected(value == current)
            thumbnail.caption:SetFontObject(value == current and GameFontNormalSmall or GameFontHighlightSmall)
        end
    end, function(enabled)
        for _, thumbnail in pairs(thumbnails) do
            thumbnail:SetEnabled(enabled)
            thumbnail:SetAlpha(enabled and 1 or DISABLED)
        end
    end, setting.customColor)
end

-- Ligne note : texte d'aide (`Text` relu à chaque rafraîchissement), bouton gris facultatif à droite.
local function CreateNote(Text, item, buttonText, onClick)
    local row = CreateListRow()
    row:SetHeight(ROW_HEIGHT)
    local text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    text:SetTextColor(HELP, HELP, HELP)
    text:SetJustifyH("LEFT")
    text:SetWordWrap(false)
    text:SetPoint("LEFT", row, "TOPLEFT", 10, -ROW_HEIGHT / 2)
    if buttonText then
        local button = CreateGreyButton(row, buttonText, 80, onClick)
        button:SetPoint("RIGHT", row, "TOPRIGHT", -4, -ROW_HEIGHT / 2)
        row.HoverWith(button)
        text:SetPoint("RIGHT", button, "LEFT", -8, 0)
    else
        text:SetPoint("RIGHT", row, "TOPRIGHT", -4, -ROW_HEIGHT / 2)
    end
    notes[#notes + 1] = function()
        if Shown(item) then text:SetText(Text()) end
    end
    item.frame = row
    item.height = ROW_HEIGHT
    items[#items + 1] = item
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
    -- Compteur « n modifiés », visible section repliée comprise.
    local count = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    count:SetTextColor(HELP, HELP, HELP)
    count:SetPoint("RIGHT", -8, 0)
    local item = { frame = header, header = section, tab = tab, height = HEADER_HEIGHT }
    function item.UpdateIcon()
        icon:SetTexture(IsCollapsed(section) and "Interface\\Buttons\\UI-PlusButton-Up" or "Interface\\Buttons\\UI-MinusButton-Up")
        -- Pas de repli en mode simple ni pendant une recherche.
        icon:SetShown(NS.db.advancedMode and filter == "")
    end
    function item.SetCount(modified)
        count:SetText(modified > 0 and L.SECTION_MODIFIED:format(modified) or "")
    end
    header:SetScript("OnClick", function()
        if not NS.db.advancedMode or filter ~= "" then return end
        -- Experts repliée par défaut (clé absente) : ouverte, `false` est enregistré.
        if section == "SECTION_EXPERT" then
            if IsCollapsed(section) then collapsed[section] = false else collapsed[section] = nil end
        else
            collapsed[section] = not collapsed[section] or nil
        end
        Layout()
    end)
    items[#items + 1] = item
end

-- Sous-titre dans une section (Experts), sans repli. `subsection` : identité des lignes qui suivent.
local function CreateSubtitle(subsection, section, tab)
    local frame = CreateFrame("Frame", nil, panel.content)
    frame:SetSize(LIST_WIDTH, SUBTITLE_HEIGHT)
    local text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text:SetPoint("LEFT", 10, 0)
    text:SetText(subsection)
    items[#items + 1] = { frame = frame, subtitle = subsection, section = section, tab = tab, height = SUBTITLE_HEIGHT }
end

-- Saisie en cours validée dans le contexte qu'elle vise, avant de changer ou de vider ce contexte.
local function CommitTyping()
    -- Seulement une saisie de Panorama : le chat en cours de frappe reste ouvert.
    local focus = GetCurrentKeyBoardFocus and GetCurrentKeyBoardFocus()
    if not focus or not panel then return end
    if focus == panel.customFilterName then return focus:ClearFocus() end
    for _, box in ipairs(inputs) do
        if box == focus then return focus:ClearFocus() end
    end
end
-- Menu de la minimap et commandes /pano : même règle que les boutons de la fenêtre.
NS.CommitTyping = CommitTyping

-- Ouvre un onglet : recherche vidée, défilement en haut.
local function OpenTab(tab)
    NS.db.tab = tab
    -- OnTextChanged relance le rafraîchissement.
    if panel.search:GetText() ~= "" then panel.search:SetText("") end
    panel.scroll:SetVerticalScroll(0)
end

-- Libellés de bloc à x 14, centrés sur `y` ; rend le x commun des contrôles : plus long libellé + 12.
local function CreateBlockLabels(block, labels)
    local width = 0
    for _, label in ipairs(labels) do
        local text = (label.parent or block):CreateFontString(nil, "ARTWORK", "GameFontNormal")
        text:SetPoint("LEFT", label.anchor or panel, "TOPLEFT", 14, label.y)
        text:SetText(label.text)
        width = math.max(width, text:GetStringWidth())
    end
    return 14 + math.ceil(width) + 12
end

-- Onglet Image : préréglages, et réglages graphiques imposés par le lieu en cours.
local function CreateImageBlock()
    local block = CreateFrame("Frame", nil, panel)
    block:SetAllPoints()
    panel.imageBlock = block
    CreateBlockLabels(block, { { text = L.OPT_PRESETS, y = -146 } })
    -- Mode avancé : bouton vers la règle en cause, onglet Ambiance.
    panel.placePreset = CreateGreyButton(block, "", 100, function()
        CommitTyping()
        local ambiance = NS.db.ambiance
        local place, _, zone = NS.DetectAmbiance()
        local target = zone and ambiance.zones[zone] and zone or place
        -- Intérieur ou météo sur « Mes réglages » : la zone décide (NS.PlacePreset), elle est ouverte.
        local values = ambiance.zones[target] or ambiance.contexts[target]
        if place ~= "dungeon" and values.preset == 0 and values.viewDistance == 0 then
            local current, biome = NS.CurrentZone()
            target = current and ambiance.zones[current] and current or biome
        end
        OpenTab("ambiance")
        panel.editAmbiance(target)
    end)
    panel.placePreset:SetPoint("RIGHT", panel, "TOPRIGHT", -14, -146)
    Tooltip(panel.placePreset, L.PLACE_PRESET_TIP)
    -- Mode simple : texte seul.
    panel.placePresetText = block:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    panel.placePresetText:SetTextColor(HELP, HELP, HELP)
    panel.placePresetText:SetPoint("RIGHT", panel, "TOPRIGHT", -14, -146)
    local hover = CreateFrame("Frame", nil, block)
    hover:SetAllPoints(panel.placePresetText)
    hover:EnableMouse(true)
    Tooltip(hover, L.PLACE_PRESET_TIP)
    panel.presetButtons = {}
    for index, preset in ipairs(NS.presets) do
        local button = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
        button:SetSize(142, 24)
        button:SetPoint("TOPLEFT", panel, "TOPLEFT", 14 + (index - 1) * (142 + 6), -160)
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

-- Ligne Filtre du bloc Ambiance (modes Fixe et Jour et nuit) : Base ou un filtre du joueur, réglé
-- par les lignes en dessous.
local function CreateFilterMenu(filterRow, x)
    local dropdown = CreateFrame("DropdownButton", nil, filterRow, "WowStyle1DropdownTemplate")
    dropdown:SetWidth(220)
    dropdown:SetPoint("LEFT", panel, "TOPLEFT", x, -206)
    panel.customFilterMenu = dropdown
    local function IsSelected(index) return NS.db.filters.customFilter == index end
    local function Choose(index)
        CommitTyping()
        if IsSelected(index) then return end
        NS.Checkpoint()
        NS.db.filters.customFilter = index
        NS.ApplyFilters()
        NS.RefreshOptions()
    end
    dropdown:SetupMenu(function(_, root)
        root:SetScrollMode(320)   -- autant de filtres que le joueur veut
        root:CreateRadio(L.LOOK_BASE, IsSelected, Choose, 0)
        for index in ipairs(NS.db.customFilters) do
            root:CreateRadio(NS.CustomFilterName(index), IsSelected, Choose, index)
        end
    end)
    DropdownTooltip(dropdown, L.LOOK_FILTER, L.LOOK_FILTER_TIP)
end

-- Onglet Mes filtres : filtre du joueur ouvert, montré en aperçu sans changer le choix de l'onglet
-- Ambiance ; création, nom et suppression. Ses lignes sont en dessous.
local function CreateMyFiltersBlock()
    local block = CreateFrame("Frame", nil, panel)
    block:SetAllPoints()
    panel.myFiltersBlock = block
    local x = CreateBlockLabels(block, { { text = L.LOOK_FILTER, y = -150 },
                                         { text = L.CUSTOM_FILTER_RENAME, y = -178 } })
    local dropdown = CreateFrame("DropdownButton", nil, block, "WowStyle1DropdownTemplate")
    dropdown:SetWidth(220)
    dropdown:SetPoint("LEFT", panel, "TOPLEFT", x, -150)
    panel.myFilterMenu = dropdown
    local function IsOpen(index) return editedFilter == index end
    local function Open(index)
        CommitTyping()
        editedFilter = index
        NS.RefreshOptions()
    end
    dropdown:SetupMenu(function(_, root)
        root:SetScrollMode(320)   -- autant de filtres que le joueur veut
        for index in ipairs(NS.db.customFilters) do
            root:CreateRadio(NS.CustomFilterName(index), IsOpen, Open, index)
        end
    end)
    DropdownTooltip(dropdown, L.LOOK_FILTER, L.MY_FILTER_TIP)
    local add = CreateButton(block, L.CUSTOM_FILTER_ADD, 80, function()
        CommitTyping()
        NS.Checkpoint()
        editedFilter = NS.AddCustomFilter()
        NS.RefreshOptions()
    end)
    add:SetPoint("LEFT", dropdown, "RIGHT", 8, 0)
    Tooltip(add, L.CUSTOM_FILTER_ADD_TIP)

    -- Nom du filtre ouvert : Entrée ou perte du focus enregistre, Échap rend le nom courant.
    -- Vide, ou nom par défaut : aucun nom enregistré, le filtre garde son nom par défaut traduit.
    local name = CreateFrame("EditBox", nil, block, "InputBoxTemplate")
    name:SetSize(190, 20)
    name:SetPoint("LEFT", panel, "TOPLEFT", x + 6, -178)   -- 6 : cadre gauche du gabarit
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
        local index = editedFilter
        local custom = NS.db.customFilters[index]
        if custom and not cancelled then
            -- `|` : code d'échappement du jeu, retiré du nom.
            local text = strtrim((self:GetText():gsub("|", "")))
            local previous = custom.name
            custom.name = nil   -- nom par défaut lu sans le nom enregistré
            local renamed = text ~= "" and text ~= NS.CustomFilterName(index) and text or nil
            custom.name = previous
            if renamed ~= previous then
                NS.Checkpoint()
                custom.name = renamed
            end
        end
        cancelled = false
        self:SetText(NS.CustomFilterName(index) or "")
        NS.RefreshOptions()
    end)
    -- Suppression après confirmation : `data` garde le filtre nommé dans la question, retrouvé à la réponse
    -- (la liste a pu changer entre-temps : /pano reset). Déjà effacé : rien à supprimer.
    StaticPopupDialogs.PANORAMA_DELETE_CUSTOM_FILTER = { text = L.CUSTOM_FILTER_DELETE_CONFIRM, button1 = YES, button2 = NO,
        OnAccept = function(_, custom)
            CommitTyping()
            for index, current in ipairs(NS.db.customFilters) do
                if current == custom then
                    NS.Checkpoint()
                    -- Autre filtre ouvert pendant la question, placé après : il garde sa place.
                    if index < editedFilter then editedFilter = editedFilter - 1 end
                    NS.DeleteCustomFilter(index)
                    break
                end
            end
            NS.RefreshOptions()
        end, timeout = 0, whileDead = true, hideOnEscape = true }
    local delete = CreateButton(block, L.CUSTOM_FILTER_DELETE, 80, function()
        CommitTyping()
        local index = editedFilter
        StaticPopup_Show("PANORAMA_DELETE_CUSTOM_FILTER", NS.CustomFilterName(index), nil, NS.db.customFilters[index])
    end)
    delete:SetPoint("LEFT", name, "RIGHT", 8, 0)
    Tooltip(delete, L.CUSTOM_FILTER_DELETE_TIP)
    delete:SetMotionScriptsWhileDisabled(true)   -- grisé (un seul filtre) : l'infobulle dit pourquoi
    panel.customFilterDelete = delete
end

-- Onglet Ambiance : mode (Fixe, Jour et nuit, Selon le lieu), lieu détecté ; hors Selon le lieu, filtre
-- choisi ; en mode avancé, règle ouverte, réglée par les lignes en dessous. Zone du joueur dans le menu : la choisir
-- lui crée un réglage propre, copié de son biome ; « Revenir au type de zone » le supprime.
local function CreateAmbianceBlock()
    local block = CreateFrame("Frame", nil, panel)
    block:SetAllPoints()
    panel.ambianceBlock = block
    local filterRow = CreateFrame("Frame", nil, block)   -- ligne Filtre : modes Fixe et Jour et nuit
    filterRow:SetAllPoints()
    panel.filterRow = filterRow
    -- Ligne Règle : mode avancé, descendue d'une ligne sous la ligne Filtre (Layout).
    local ruleRow = CreateFrame("Frame", nil, block)
    ruleRow:SetPoint("TOPLEFT")
    ruleRow:SetSize(1, 1)
    panel.ruleRow = ruleRow
    local x = CreateBlockLabels(block, { { text = L.AMBIANCE_MODE, y = -150 }, { text = L.AMBIANCE_HERE, y = -178 },
                                         { text = L.LOOK_FILTER, y = -206, parent = filterRow },
                                         { text = L.AMBIANCE_EDIT, y = -206, parent = ruleRow, anchor = ruleRow } })
    -- Un seul mode : Jour et nuit et Selon le lieu ne vont jamais ensemble.
    local mode = CreateFrame("DropdownButton", nil, block, "WowStyle1DropdownTemplate")
    mode:SetWidth(220)
    mode:SetPoint("LEFT", panel, "TOPLEFT", x, -150)
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
        root:CreateRadio(L.AMBIANCE_FIXED, IsMode, SetMode, "off")
        root:CreateRadio(L.autoDayNight, IsMode, SetMode, "daynight")
        root:CreateRadio(L.AMBIANCE_AUTO, IsMode, SetMode, "auto")
    end)
    DropdownTooltip(mode, L.AMBIANCE_MODE, L.AMBIANCE_MODE_TIP)

    -- Lieu détecté : l'information la plus grosse du bloc, 1 ligne, texte entier en infobulle.
    local here = block:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    here:SetPoint("LEFT", panel, "TOPLEFT", x, -178)
    here:SetPoint("RIGHT", panel, "TOPRIGHT", -14, -178)
    here:SetJustifyH("LEFT")
    here:SetWordWrap(false)
    panel.here = here
    local hover = CreateFrame("Frame", nil, block)
    hover:SetAllPoints(here)
    hover:EnableMouse(true)
    hover:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(here.text or "", 1, 1, 1, 1, true)
    end)
    hover:SetScript("OnLeave", function() GameTooltip:Hide() end)

    CreateFilterMenu(filterRow, x)

    local dropdown = CreateFrame("DropdownButton", nil, ruleRow, "WowStyle1DropdownTemplate")
    dropdown:SetWidth(220)   -- noms de zone longs
    dropdown:SetPoint("LEFT", ruleRow, "TOPLEFT", x, -206)
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
        NS.RefreshOptions()
    end
    panel.editAmbiance = Edit
    panel.ambianceReset = CreateButton(ruleRow, L.AMBIANCE_ZONE_RESET, 100, function()
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
        -- Zone quittée sans réglage propre, encore ouverte.
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

local function CreateTabs()
    panel.tabs = {}
    for index, id in ipairs(NS.tabs) do
        local tab = CreateFromTemplate("Button", panel, "PanelTopTabButtonTemplate", "PanelTabButtonTemplate")
        tab:SetID(index)
        tab:SetText(L["TAB_" .. id:upper()])
        PanelTemplates_TabResize(tab, 12)
        if index == 1 then
            tab:SetPoint("TOPLEFT", 14, -96)
        else
            tab:SetPoint("LEFT", panel.tabs[index - 1], "RIGHT", TAB_GAP, 0)
        end
        tab:SetScript("OnClick", function()
            CommitTyping()
            OpenTab(id)
            NS.RefreshOptions()
        end)
        panel.tabs[index] = tab
    end
    -- Rangée plus large que la place à gauche de la recherche (libellés longs) : onglets resserrés.
    local width = 0
    for _, tab in ipairs(panel.tabs) do width = width + tab:GetWidth() + TAB_GAP end
    if width > TABS_WIDTH then
        panel.tabPadding = 0
        for _, tab in ipairs(panel.tabs) do PanelTemplates_TabResize(tab, 0) end
    end
    local rule = panel:CreateTexture(nil, "BORDER")
    rule:SetColorTexture(1, 1, 1, 0.15)
    rule:SetHeight(1)
    rule:SetPoint("TOPLEFT", 14, -128)
    rule:SetPoint("TOPRIGHT", -14, -128)
end

-- Langues proposées, chacune nommée dans sa propre langue.
local LANGUAGES = {
    { "enUS", "English" }, { "frFR", "Français" }, { "deDE", "Deutsch" }, { "esES", "Español" },
    { "itIT", "Italiano" }, { "ptBR", "Português" }, { "ruRU", "Русский" }, { "koKR", "한국어" },
    { "zhCN", "简体中文" }, { "zhTW", "繁體中文" },
}

-- Infobulle d'un élément de menu.
local function MenuTooltip(description, title, text)
    description:SetTooltip(function(tooltip)
        tooltip:SetText(title, 1, 1, 1, 1, true)
        tooltip:AddLine(text, HELP, HELP, HELP, true)
    end)
end

-- En-tête : logo et titre, choix Simple / Avancé, menu Options (réglages globaux), bouton Guide.
local function CreateHeaderBar()
    local logo = panel:CreateTexture(nil, "ARTWORK")
    logo:SetSize(32, 32)
    logo:SetPoint("TOPLEFT", 14, -28)
    logo:SetTexture(MEDIA .. "logo")
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("LEFT", logo, "RIGHT", 8, 0)
    title:SetText("Panorama")

    -- Choix d'affichage, hors historique.
    local function SetAdvanced(advanced)
        if NS.db.advancedMode == advanced then return end
        CommitTyping()
        NS.db.advancedMode = advanced
        panel.scroll:SetVerticalScroll(0)
        NS.RefreshOptions()
    end
    local simple = CreateRadio(panel, L.OPT_MODE_SIMPLE, function() SetAdvanced(false) end)
    simple:SetPoint("LEFT", panel, "TOPLEFT", 152, -44)
    simple:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.OPT_MODE_SIMPLE_TIP, 1, 1, 1, 1, true)
    end)
    simple:HookScript("OnLeave", function() GameTooltip:Hide() end)
    panel.simpleRadio = simple
    local advanced = CreateRadio(panel, L.OPT_MODE_ADVANCED, function() SetAdvanced(true) end)
    advanced:SetPoint("LEFT", simple, "LEFT", simple.width + 12, 0)
    advanced:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.OPT_MODE_ADVANCED_TIP, 1, 1, 1, 1, true)
    end)
    advanced:HookScript("OnLeave", function() GameTooltip:Hide() end)
    panel.advancedRadio = advanced

    local menu = CreateFrame("DropdownButton", nil, panel, "WowStyle1DropdownTemplate")
    menu:SetWidth(110)
    menu:SetPoint("RIGHT", panel, "TOPRIGHT", -14, -44)
    local function IsLanguage(code) return (NS.db.locale or "auto") == code end
    -- Un choix enregistre PanoramaDB.locale puis recharge l'interface : les libellés des réglages sont
    -- traduits une seule fois, à ADDON_LOADED.
    local function SetLanguage(code)
        if IsLanguage(code) then return end
        CommitTyping()
        NS.db.locale = code ~= "auto" and code or nil
        ReloadUI()
    end
    menu:SetupMenu(function(_, root)
        local language = root:CreateButton(L.OPT_LANGUAGE)
        MenuTooltip(language, L.OPT_LANGUAGE, L.OPT_LANGUAGE_TIP)
        language:CreateRadio(L.OPT_LANGUAGE_AUTO, IsLanguage, SetLanguage, "auto")
        for _, entry in ipairs(LANGUAGES) do
            language:CreateRadio(entry[2], IsLanguage, SetLanguage, entry[1])
        end
        local login = root:CreateCheckbox(L.OPT_APPLY_ON_LOGIN, function() return NS.db.applyOnLogin end,
            function() NS.db.applyOnLogin = not NS.db.applyOnLogin end)
        MenuTooltip(login, L.OPT_APPLY_ON_LOGIN, L.OPT_APPLY_ON_LOGIN_TIP)
        local minimap = root:CreateCheckbox(L.OPT_MINIMAP_BUTTON, function() return NS.db.minimap.show end,
            function()
                NS.db.minimap.show = not NS.db.minimap.show
                if NS.UpdateMinimapButton then NS.UpdateMinimapButton() end
            end)
        MenuTooltip(minimap, L.OPT_MINIMAP_BUTTON, L.OPT_MINIMAP_BUTTON_TIP)
        root:CreateDivider()
        -- Seule action destructive de la fenêtre : texte rouge.
        local reset = root:CreateButton("|cffff1a1a" .. L.OPT_RESET_ALL .. "|r", function()
            StaticPopup_Show("PANORAMA_RESET_ALL")
        end)
        MenuTooltip(reset, L.OPT_RESET_ALL, L.OPT_RESET_ALL_TIP)
    end)
    -- Texte fixe quel que soit l'état des cases.
    if menu.OverrideText then
        menu:OverrideText(L.OPT_OPTIONS)
    else
        menu:SetSelectionText(function() return L.OPT_OPTIONS end)
    end
    -- Tout remettre par défaut, après confirmation ; Annuler le défait.
    StaticPopupDialogs.PANORAMA_RESET_ALL = { text = L.OPT_RESET_ALL_CONFIRM, button1 = YES, button2 = NO,
        OnAccept = function() CommitTyping() NS.ResetAll() end, timeout = 0, whileDead = true, hideOnEscape = true }

    local guide = CreateGreyButton(panel, L.OPT_GUIDE, 70, NS.ToggleGuide)
    guide:SetPoint("RIGHT", menu, "LEFT", -8, 0)
    Tooltip(guide, L.OPT_GUIDE_TIP)
end

-- Bandeau d'état : look posé sur le monde et ce qui l'impose, bouton vers l'endroit où le régler.
local function CreateStatus()
    local status = CreateFrame("Frame", nil, panel)
    status:SetPoint("TOPLEFT", 14, -64)
    status:SetPoint("TOPRIGHT", -14, -64)
    status:SetHeight(28)
    panel.status = status
    local background = status:CreateTexture(nil, "BACKGROUND")
    background:SetColorTexture(1, 1, 1, 0.04)
    background:SetAllPoints()
    local rule = status:CreateTexture(nil, "BORDER")
    rule:SetColorTexture(1, 1, 1, 0.15)
    rule:SetHeight(1)
    rule:SetPoint("BOTTOMLEFT")
    rule:SetPoint("BOTTOMRIGHT")
    status.label = status:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    status.label:SetPoint("LEFT", 8, 0)
    status.label:SetText(L.STATUS_LABEL)
    status.value = status:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    status.value:SetJustifyH("LEFT")
    status.value:SetWordWrap(false)
    status:EnableMouse(true)
    status:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText(self.text or "", 1, 1, 1, 1, true)
        GameTooltip:AddLine(L.STATUS_TIP, HELP, HELP, HELP, true)
        GameTooltip:Show()
    end)
    status:SetScript("OnLeave", function() GameTooltip:Hide() end)
    status.button = CreateGreyButton(status, L.STATUS_EDIT, 80, function()
        CommitTyping()
        local action = status.action
        if action == "rule" then
            OpenTab("ambiance")
            if NS.db.advancedMode then return panel.editAmbiance(DetectedRule()) end
        else
            OpenTab(action)
        end
        NS.RefreshOptions()
    end)
    status.button:SetPoint("RIGHT", -3, 0)
end

-- Pied : Annuler et Rétablir à gauche, Redémarrer à droite.
local function CreateFooter()
    local rule = panel:CreateTexture(nil, "BORDER")
    rule:SetColorTexture(1, 1, 1, 0.15)
    rule:SetHeight(1)
    rule:SetPoint("BOTTOMLEFT", 14, 44)
    rule:SetPoint("BOTTOMRIGHT", -14, 44)
    -- Saisie en cours validée avant : sinon sa perte de focus écraserait le résultat du bouton.
    panel.undo = CreateButton(panel, L.OPT_UNDO, 90, function() CommitTyping() NS.Undo() end)
    panel.undo:SetPoint("BOTTOMLEFT", 14, 13)
    panel.undo:SetMotionScriptsWhileDisabled(true)
    Tooltip(panel.undo, L.OPT_UNDO_TIP)
    panel.redo = CreateButton(panel, L.OPT_REDO, 90, function() CommitTyping() NS.Redo() end)
    panel.redo:SetPoint("LEFT", panel.undo, "RIGHT", 6, 0)
    panel.redo:SetMotionScriptsWhileDisabled(true)
    Tooltip(panel.redo, L.OPT_REDO_TIP)
    local restart = CreateButton(panel, L.OPT_RESTART, 100, function()
        CommitTyping()
        NS.RestartGraphics()
    end)
    restart:SetPoint("BOTTOMRIGHT", -14, 13)
    restart.ShowBorder = CreateBorder(restart, 2, 2, 1, 0.82, 0, 1)
    restart:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.OPT_RESTART_TIP, 1, 1, 1, 1, true)
        if self.pending then GameTooltip:AddLine(L.OPT_RESTART_PENDING, 1, 0.82, 0, true) end
        GameTooltip:Show()
    end)
    restart:SetScript("OnLeave", function() GameTooltip:Hide() end)
    panel.restart = restart
end

-- Lignes de la liste, dans l'ordre des onglets : Image (NS.settings), Ambiance (Jour et nuit, filtre de base,
-- ciel et bandes noires) et Mes filtres (NS.filterSettings), puis règles d'ambiance.
local function CreateList()
    -- Titre créé à la première ligne visible : pas de section vide sur un client sans ces CVars.
    local section, title, tab, headerPending, subsection
    local function Item(fields)
        if headerPending then
            CreateHeader(section, title, tab)
            headerPending = false
        end
        fields.section, fields.tab, fields.subsection = section, tab, subsection
        return fields
    end
    -- Filtre de base : modes Fixe et Jour et nuit (Selon le lieu le remplace par la règle).
    local function Fixed() return not NS.db.ambiance.enabled end
    local function Base() return Fixed() and NS.db.filters.customFilter == 0 end
    local function Custom() return Fixed() and ChosenCustomFilter() ~= nil end
    -- Lignes du filtre du joueur ouvert : onglet Mes filtres, hors section (ni titre, ni repli).
    local function MyFilterItem(fields)
        fields.tab = "myfilters"
        return fields
    end
    local function DayNight() return NS.db.filters.autoDayNight end
    for _, list in ipairs({ NS.settings, NS.filterSettings }) do
        for _, setting in ipairs(list) do
            if setting.title then
                section, title, tab, headerPending, subsection = setting.titleKey, setting.title, setting.tab, true, nil
            elseif setting.subtitle then
                if headerPending then
                    CreateHeader(section, title, tab)
                    headerPending = false
                end
                subsection = setting.subtitle
                CreateSubtitle(subsection, section, tab)
            elseif setting.key == "customFilter" then
                -- Choisi par le menu Filtre de l'onglet Ambiance, où une note ouvre l'onglet Mes filtres sur lui.
                -- Lignes du filtre ouvert dans Mes filtres, couleur en vignettes (DESIGN.md § Onglet Mes
                -- filtres). Ciel et bandes noires restent ceux de Base.
                CreateNote(function()
                    return L.LOOK_FROM_FILTER:format(NS.CustomFilterName(NS.db.filters.customFilter) or "")
                end, Item({ basic = true, when = Custom }), L.RULE_EDIT_FILTER, function()
                    CommitTyping()
                    editedFilter = NS.db.filters.customFilter
                    OpenTab("myfilters")
                    NS.RefreshOptions()
                end)
                local tint = FilterSetting("tint")
                CreateTintRow(setmetatable({ custom = true, customColor = true }, { __index = tint }),
                    MyFilterItem({ basic = true }))
                for _, custom in ipairs(NS.customFilterSettings) do
                    local copy = setmetatable({ custom = true }, { __index = custom })
                    local basic
                    if custom.key == "tintStrength" then
                        basic = true
                        copy.requires = function(values)
                            return not (values.tintRed == 100 and values.tintGreen == 100 and values.tintBlue == 100)
                        end
                    end
                    CreateRow(copy, MyFilterItem({ basic = basic }))
                end
            elseif setting.key == "autoDayNight" then
                -- Mode Jour et nuit : réglé par le menu Mode du bloc Ambiance, sans ligne.
            elseif setting.key or NS.Exists(setting) then
                local item
                if section == "SECTION_DAYNIGHT" then
                    item = Item({ basic = true, when = DayNight })
                elseif setting.key == "tint" or setting.key == "tintStrength" then
                    -- Remplacées par le filtre choisi, ou par les teintes de jour et de nuit.
                    item = Item({ basic = setting.basic, when = function() return Base() and not DayNight() end })
                elseif REPLACED_BY_CUSTOM_FILTER[setting.key] then
                    item = Item({ basic = setting.basic, when = Base })   -- remplacées par le filtre choisi
                elseif setting.key == "sky" or setting.key == "skyStrength" then
                    item = Item({ basic = setting.basic, when = Fixed })   -- Selon le lieu : ciel du moment
                else
                    item = Item({ basic = setting.basic })
                end
                if setting.key == "tint" or setting.key == "tintDay" or setting.key == "tintNight" then
                    CreateTintRow(setting, item)
                else
                    CreateRow(setting, item)
                end
            end
        end
    end

    -- Règle ouverte dans l'onglet Ambiance : réglages graphiques du lieu (agissent dans tous les modes),
    -- puis look du lieu ou du moment (Selon le lieu seulement). Mode avancé.
    local function Enabled() return NS.db.ambiance.enabled end
    local function RuleFilter() return RuleValues().customFilter or 0 end
    local function RuleCopy(setting) return setmetatable({ ambiance = true }, { __index = setting }) end
    section, title, tab, headerPending, subsection = "SECTION_RULE_IMAGE", L.SECTION_RULE_IMAGE, "ambiance", true, nil
    for _, setting in ipairs(NS.placeSettings) do CreateRow(RuleCopy(setting), Item({})) end
    section, title, headerPending = "SECTION_RULE_LOOK", L.SECTION_RULE_LOOK, true
    local ambianceKeys = {}
    for _, key in ipairs(NS.ambianceKeys) do ambianceKeys[key] = true end
    for _, setting in ipairs(NS.filterSettings) do
        if ambianceKeys[setting.key] then
            if REPLACED_BY_CUSTOM_FILTER[setting.key] then
                -- Filtre du joueur choisi par la règle : ses lignes le remplacent, cachées.
                local item = Item({ when = function() return Enabled() and RuleFilter() == 0 end })
                if setting.key == "tint" then
                    CreateTintRow(RuleCopy(setting), item)
                else
                    CreateRow(RuleCopy(setting), item)
                end
            else
                CreateRow(RuleCopy(setting), Item({ when = Enabled }))
            end
            if setting.key == "customFilter" then
                CreateNote(function() return L.RULE_LOOK_FROM_FILTER:format(NS.CustomFilterName(RuleFilter()) or "") end,
                    Item({ ambianceKey = "customFilter",
                           when = function() return Enabled() and NS.CustomFilterName(RuleFilter()) ~= nil end }),
                    L.RULE_EDIT_FILTER, function()
                        CommitTyping()
                        local index = RuleFilter()
                        if not NS.db.customFilters[index] then return end
                        editedFilter = index
                        OpenTab("myfilters")
                        NS.RefreshOptions()
                    end)
            end
        end
    end
    CreateNote(function() return L.RULE_LOOK_OFF end, Item({ when = function() return not Enabled() end }))
    -- Mode simple, Selon le lieu : les règles livrées s'appliquent, elles se règlent en mode avancé.
    section, headerPending, subsection = nil, false, nil
    CreateNote(function() return L.AMBIANCE_RULES_ADVANCED end,
        Item({ basic = true, when = function() return not NS.db.advancedMode and Enabled() end }))

    -- Tab suit l'ordre d'affichage, recherche multi-onglets comprise.
    for _, item in ipairs(items) do
        if item.frame.box then inputs[#inputs + 1] = item.frame.box end
    end
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

    local search = CreateFrame("EditBox", nil, panel, "SearchBoxTemplate")
    panel.search = search
    search:SetSize(180, 20)
    search:SetPoint("TOPRIGHT", -14, -102)
    search.Instructions:SetText(L.OPT_SEARCH)
    search.Instructions:SetTextColor(HELP, HELP, HELP)
    -- HookScript : garde le script du gabarit (texte d'aide, bouton d'effacement).
    search:HookScript("OnTextChanged", function(self)
        filter = Fold(strtrim(self:GetText()))
        panel.scroll:SetVerticalScroll(0)
        NS.RefreshOptions()
    end)

    -- Lu par PanelTabButtonMixin:OnShow, qui redimensionne les onglets à chaque affichage.
    panel.tabPadding = 12
    CreateHeaderBar()
    CreateStatus()
    CreateTabs()
    CreateImageBlock()
    CreateMyFiltersBlock()
    CreateAmbianceBlock()
    CreateFooter()

    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    panel.scroll = scroll
    scroll.scrollBarHideable = true
    scroll:SetPoint("TOPLEFT", 14, -192)
    scroll:SetPoint("BOTTOMRIGHT", -36, 48)
    panel.content = CreateFrame("Frame", nil, scroll)
    panel.content:SetSize(LIST_WIDTH, 10)
    scroll:SetScrollChild(panel.content)
    panel.noResult = scroll:CreateFontString(nil, "ARTWORK", "GameFontDisable")
    panel.noResult:SetPoint("TOPLEFT", 10, -16)
    panel.noResult:SetText(L.OPT_NO_RESULT)

    collapsed = NS.db.collapsed
    CreateList()
    TakeRestartValues()

    -- Première ouverture : la règle ouverte est celle du lieu du joueur, pas un moment (ciel seul),
    -- pour que le filtre, la teinte et les réglages graphiques du lieu soient visibles d'emblée.
    local rulePlaced = false
    panel:SetScript("OnShow", function()
        if not rulePlaced then
            rulePlaced = true
            panel.editAmbiance(DetectedRule())   -- rafraîchit déjà le panneau, aperçu compris
        else
            NS.RefreshOptions()
        end
    end)
    panel:SetScript("OnHide", UpdatePreview)

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
