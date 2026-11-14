-- Filtres posés sur le monde : textures sur une frame à soi, enfant de WorldFrame, sous
-- l'interface. Aucune CVar écrite, donc aucun conflit avec les menus du jeu.
-- Réglages dans PanoramaDB.filters, une valeur par clé de NS.filterSettings.
local _, NS = ...
local L = NS.L

local MEDIA = "Interface\\AddOns\\Panorama\\Media\\"
-- Couleur multipliée à l'image (mode MOD) à 100 % d'intensité, index = valeur du réglage `tint`.
local TINTS = {
    { 1, 0.82, 0.58 },   -- sépia
    { 1, 0.88, 0.72 },   -- chaude
    { 0.75, 0.88, 1 },   -- froide
    { 0.55, 0.68, 1 },   -- nuit
    { 0.7, 1, 0.78 },    -- émeraude
    { 1, 0.72, 0.88 },   -- crépuscule
}
local GRAIN_SIZE = 128   -- côté d'une tuile de grain, en unités d'interface
local GRAIN_FRAME = 1 / 24

-- Même forme que NS.settings, avec `key` à la place de `cvar`. `names` : texte affiché par valeur.
NS.filterSettings = {
    { title = L.SECTION_FILTERS },
    -- Hauteur de chaque bande, en pourcentage de la hauteur de l'écran. 0 : pas de bandes.
    { key = "letterbox", min = 0, max = 20, step = 1, default = 0 },
    { key = "vignette", min = 0, max = 100, step = 5, default = 0 },
    { key = "grain", min = 0, max = 100, step = 5, default = 0 },
    { key = "tint", min = 0, max = #TINTS, step = 1, default = 0,
      names = { [0] = L.TINT_NONE, L.TINT_SEPIA, L.TINT_WARM, L.TINT_COLD,
                L.TINT_NIGHT, L.TINT_EMERALD, L.TINT_DUSK } },
    { key = "tintStrength", min = 0, max = 100, step = 5, default = 50 },
}
for _, setting in ipairs(NS.filterSettings) do
    if setting.key then setting.label, setting.tip = L[setting.key], L[setting.key .. "_tip"] end
end

-- Valeurs lues dans PanoramaDB : nombre hors bornes, hors choix ou d'un autre type remplacé par le défaut.
function NS.LoadFilters(db)
    if type(db.filters) ~= "table" then db.filters = {} end
    for _, setting in ipairs(NS.filterSettings) do
        if setting.key then
            local value = db.filters[setting.key]
            if type(value) ~= "number" or value ~= value or value < setting.min or value > setting.max
                    or (setting.names and not setting.names[value]) then
                db.filters[setting.key] = setting.default
            end
        end
    end
end

local layer, topBand, bottomBand, vignette, grain, tint
local grainElapsed = 0

local function LayoutBands()
    local height = layer:GetHeight() * NS.db.filters.letterbox / 100
    topBand:SetHeight(height)
    bottomBand:SetHeight(height)
end

-- Tuile de grain décalée au hasard 24 fois par seconde : le grain bouge comme sur une pellicule.
local function AnimateGrain(_, elapsed)
    grainElapsed = grainElapsed + elapsed
    if grainElapsed < GRAIN_FRAME then return end
    -- Reste gardé : 24 i/s réelles ; modulo pour qu'un gel de l'image ne rattrape pas les tirages.
    grainElapsed = grainElapsed % GRAIN_FRAME
    local u, v = math.random(), math.random()
    grain:SetTexCoord(u, u + layer:GetWidth() / GRAIN_SIZE, v, v + layer:GetHeight() / GRAIN_SIZE)
end

local function CreateBand(point)
    local band = layer:CreateTexture(nil, "OVERLAY")
    band:SetColorTexture(0, 0, 0, 1)
    band:SetPoint(point .. "LEFT")
    band:SetPoint(point .. "RIGHT")
    return band
end

local function CreateLayer()
    layer = CreateFrame("Frame", nil, WorldFrame)
    layer:SetAllPoints()
    layer:SetFrameStrata("BACKGROUND")
    -- Ordre des calques : teinte, vignette, grain, puis bandes par-dessus.
    topBand, bottomBand = CreateBand("TOP"), CreateBand("BOTTOM")
    tint = layer:CreateTexture(nil, "BACKGROUND")
    tint:SetAllPoints()
    tint:SetBlendMode("MOD")
    vignette = layer:CreateTexture(nil, "BORDER")
    vignette:SetAllPoints()
    vignette:SetTexture(MEDIA .. "vignette")
    grain = layer:CreateTexture(nil, "ARTWORK")
    grain:SetAllPoints()
    grain:SetTexture(MEDIA .. "grain", "REPEAT", "REPEAT")
    -- Changement de résolution, letterbox des cinématiques : les bandes gardent leur proportion.
    layer:SetScript("OnSizeChanged", LayoutBands)
end

-- Calque créé au premier filtre actif : rien n'est posé sur le monde tant que tout est à 0.
function NS.ApplyFilters()
    local filters = NS.db.filters
    local color = filters.tintStrength > 0 and TINTS[filters.tint]
    local active = filters.letterbox > 0 or filters.vignette > 0 or filters.grain > 0 or color
    if not layer then
        if not active then return end
        CreateLayer()
    end
    layer:SetShown(active and true or false)
    if not active then return end

    topBand:SetShown(filters.letterbox > 0)
    bottomBand:SetShown(filters.letterbox > 0)
    LayoutBands()

    vignette:SetShown(filters.vignette > 0)
    vignette:SetAlpha(filters.vignette / 100)

    grain:SetShown(filters.grain > 0)
    grain:SetAlpha(filters.grain / 100 * 0.35)
    -- Frame cachée ou grain à 0 : aucun OnUpdate.
    layer:SetScript("OnUpdate", filters.grain > 0 and AnimateGrain or nil)

    tint:SetShown(color and true or false)
    if color then
        local strength = filters.tintStrength / 100
        tint:SetColorTexture(1 - strength * (1 - color[1]), 1 - strength * (1 - color[2]),
            1 - strength * (1 - color[3]), 1)
    end
end
