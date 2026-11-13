-- Filtres posés sur le monde : textures sur une frame à soi, enfant de WorldFrame, sous
-- l'interface. Aucune CVar écrite, donc aucun conflit avec les menus du jeu.
-- Réglages dans PanoramaDB.filters, une valeur par clé de NS.filterSettings.
local _, NS = ...
local L = NS.L

-- Même forme que NS.settings, avec `key` à la place de `cvar`.
NS.filterSettings = {
    { title = L.SECTION_FILTERS },
    -- Hauteur de chaque bande, en pourcentage de la hauteur de l'écran. 0 : pas de bandes.
    { key = "letterbox", min = 0, max = 20, step = 1, default = 0 },
}
for _, setting in ipairs(NS.filterSettings) do
    if setting.key then setting.label, setting.tip = L[setting.key], L[setting.key .. "_tip"] end
end

-- Valeurs lues dans PanoramaDB : nombre hors bornes ou d'un autre type remplacé par le défaut.
function NS.LoadFilters(db)
    if type(db.filters) ~= "table" then db.filters = {} end
    for _, setting in ipairs(NS.filterSettings) do
        if setting.key then
            local value = db.filters[setting.key]
            if type(value) ~= "number" or value ~= value or value < setting.min or value > setting.max then
                db.filters[setting.key] = setting.default
            end
        end
    end
end

local layer, topBand, bottomBand

local function LayoutBands()
    local height = layer:GetHeight() * NS.db.filters.letterbox / 100
    topBand:SetHeight(height)
    bottomBand:SetHeight(height)
end

local function CreateBand(point)
    local band = layer:CreateTexture(nil, "BACKGROUND")
    band:SetColorTexture(0, 0, 0, 1)
    band:SetPoint(point .. "LEFT")
    band:SetPoint(point .. "RIGHT")
    return band
end

-- Créée au premier filtre actif : rien n'est posé sur le monde tant que tout est à 0.
function NS.ApplyFilters()
    local active = NS.db.filters.letterbox > 0
    if not layer then
        if not active then return end
        layer = CreateFrame("Frame", nil, WorldFrame)
        layer:SetAllPoints()
        layer:SetFrameStrata("BACKGROUND")
        topBand, bottomBand = CreateBand("TOP"), CreateBand("BOTTOM")
        -- Changement de résolution, letterbox des cinématiques : les bandes gardent leur proportion.
        layer:SetScript("OnSizeChanged", LayoutBands)
    end
    layer:SetShown(active)
    if active then LayoutBands() end
end
