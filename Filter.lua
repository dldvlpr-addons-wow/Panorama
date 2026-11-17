-- Filtres posés sur le monde : textures sur une frame à soi, enfant de WorldFrame, sous
-- l'interface. Aucune CVar écrite, donc aucun conflit avec les menus du jeu.
-- Réglages dans PanoramaDB.filters, une valeur par clé de NS.filterSettings ; ambiance : Ambiance.lua.
local _, NS = ...

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
-- Lu par les vignettes de la fenêtre (Options.lua) : mêmes couleurs que le filtre.
NS.tints = TINTS
local GRAIN_SIZE = 128   -- côté d'une tuile de grain, en unités d'interface
local GRAIN_FRAME = 1 / 24
local SKY_GROUND = 0.4   -- part de la couleur du ciel gardée en bas de l'écran

-- Même forme que NS.settings, avec `key` à la place de `cvar`. `names` : texte affiché par valeur.
NS.filterSettings = {
    { title = "SECTION_FILTERS", tab = "filters" },
    -- Teinte en tête : la fenêtre l'affiche en vignettes cliquables (Options.lua).
    { key = "tint", min = 0, max = #TINTS, step = 1, default = 0,
      names = { [0] = "TINT_NONE", "TINT_SEPIA", "TINT_WARM", "TINT_COLD",
                "TINT_NIGHT", "TINT_EMERALD", "TINT_DUSK" } },
    { key = "tintStrength", requires = "tint", min = 0, max = 100, step = 5, default = 50 },
    -- Ciel : même palette que la teinte, en dégradé, pleine force en haut de l'écran.
    { key = "sky", min = 0, max = #TINTS, step = 1, default = 0,
      names = { [0] = "TINT_NONE", "TINT_SEPIA", "TINT_WARM", "TINT_COLD",
                "TINT_NIGHT", "TINT_EMERALD", "TINT_DUSK" } },
    { key = "skyStrength", requires = "sky", min = 0, max = 100, step = 5, default = 50 },
    { key = "vignette", min = 0, max = 100, step = 5, default = 0 },
    { key = "grain", min = 0, max = 100, step = 5, default = 0 },
}

-- Faux pour un nombre hors bornes, hors choix ou une valeur d'un autre type.
function NS.IsValidFilter(setting, value)
    return type(value) == "number" and value == value and value >= setting.min and value <= setting.max
        and (not setting.names or setting.names[value] ~= nil)
end

-- Valeurs lues dans PanoramaDB : valeur invalide remplacée par le défaut.
function NS.LoadFilters(db)
    if type(db.filters) ~= "table" then db.filters = {} end
    for _, setting in ipairs(NS.filterSettings) do
        if setting.key and not NS.IsValidFilter(setting, db.filters[setting.key]) then
            db.filters[setting.key] = setting.default
        end
    end
end

local layer, vignette, grain, tint, sky
local grainElapsed = 0
-- Ce qui est à l'écran, en valeurs de rendu : couleurs multipliées (blanc = rien), opacités.
-- Ambiance qui change de contexte : fondu de `fade.from` vers `fade.to` en FADE_SECONDS.
local NEUTRAL = { tintR = 1, tintG = 1, tintB = 1, vignette = 0, grain = 0,
                  skyR = 1, skyG = 1, skyB = 1, skyTopR = 1, skyTopG = 1, skyTopB = 1 }
local FADE_SECONDS = 1.5
local shown = {}
for key, value in pairs(NEUTRAL) do shown[key] = value end
local fade

-- Couleur multipliée à `strength` (0-1) : blanc à 0, couleur pleine à 1.
local function Blend(color, strength)
    return 1 - strength * (1 - color[1]), 1 - strength * (1 - color[2]), 1 - strength * (1 - color[3])
end

-- Tuile de grain décalée au hasard 24 fois par seconde : le grain bouge comme sur une pellicule.
local function AnimateGrain(elapsed)
    grainElapsed = grainElapsed + elapsed
    if grainElapsed < GRAIN_FRAME then return end
    -- Reste gardé : 24 i/s réelles ; modulo pour qu'un gel de l'image ne rattrape pas les tirages.
    grainElapsed = grainElapsed % GRAIN_FRAME
    local u, v = math.random(), math.random()
    grain:SetTexCoord(u, u + layer:GetWidth() / GRAIN_SIZE, v, v + layer:GetHeight() / GRAIN_SIZE)
end

-- Valeurs de rendu des filtres réglés.
local function RenderValues(filters)
    local values = {}
    for key, value in pairs(NEUTRAL) do values[key] = value end
    local color = filters.tintStrength > 0 and TINTS[filters.tint]
    if color then values.tintR, values.tintG, values.tintB = Blend(color, filters.tintStrength / 100) end
    values.vignette = filters.vignette / 100
    values.grain = filters.grain / 100 * 0.35
    local skyColor = filters.skyStrength > 0 and TINTS[filters.sky]
    if skyColor then
        local strength = filters.skyStrength / 100
        values.skyR, values.skyG, values.skyB = Blend(skyColor, strength * SKY_GROUND)
        values.skyTopR, values.skyTopG, values.skyTopB = Blend(skyColor, strength)
    end
    return values
end

local function Same(values, other)
    for key in pairs(NEUTRAL) do
        if values[key] ~= other[key] then return false end
    end
    return true
end

local function Render()
    local hasTint = shown.tintR < 1 or shown.tintG < 1 or shown.tintB < 1
    tint:SetShown(hasTint)
    if hasTint then tint:SetColorTexture(shown.tintR, shown.tintG, shown.tintB, 1) end
    vignette:SetShown(shown.vignette > 0)
    vignette:SetAlpha(shown.vignette)
    grain:SetShown(shown.grain > 0)
    grain:SetAlpha(shown.grain)
    local hasSky = shown.skyTopR < 1 or shown.skyTopG < 1 or shown.skyTopB < 1
    sky:SetShown(hasSky)
    if hasSky then
        -- VERTICAL : première couleur en bas, seconde en haut.
        sky:SetGradient("VERTICAL", CreateColor(shown.skyR, shown.skyG, shown.skyB, 1),
            CreateColor(shown.skyTopR, shown.skyTopG, shown.skyTopB, 1))
    end
end

-- Fondu en cours, puis grain animé. Fin du fondu : cible atteinte, puis filtres reposés (calque
-- caché si plus rien n'est actif, OnUpdate coupé si plus de grain ; nouveau fondu si le contexte a
-- changé sans événement, intérieur ou heure).
local function OnUpdate(_, elapsed)
    if fade then
        fade.elapsed = fade.elapsed + elapsed
        local progress = fade.elapsed / FADE_SECONDS
        if progress >= 1 then
            for key, value in pairs(fade.to) do shown[key] = value end
            fade = nil
            NS.ApplyFilters(true)
            return
        end
        for key, target in pairs(fade.to) do shown[key] = fade.from[key] + (target - fade.from[key]) * progress end
        Render()
    end
    if shown.grain > 0 then AnimateGrain(elapsed) end
end

local function CreateLayer()
    layer = CreateFrame("Frame", nil, WorldFrame)
    layer:SetAllPoints()
    layer:SetFrameStrata("BACKGROUND")
    -- Ordre des calques : teinte et ciel (MOD, ordre indifférent), vignette, puis grain.
    tint = layer:CreateTexture(nil, "BACKGROUND")
    tint:SetAllPoints()
    tint:SetBlendMode("MOD")
    vignette = layer:CreateTexture(nil, "BORDER")
    vignette:SetAllPoints()
    vignette:SetTexture(MEDIA .. "vignette")
    grain = layer:CreateTexture(nil, "ARTWORK")
    grain:SetAllPoints()
    grain:SetTexture(MEDIA .. "grain", "REPEAT", "REPEAT")
    sky = layer:CreateTexture(nil, "BACKGROUND")
    sky:SetAllPoints()
    sky:SetBlendMode("MOD")
    sky:SetColorTexture(1, 1, 1, 1)
end

-- Calque créé au premier filtre actif : rien n'est posé sur le monde tant que tout est à 0.
-- Valeurs : filtres de base, ou ambiance du contexte (Ambiance.lua).
-- `smooth` : changement de contexte de l'ambiance, fondu depuis ce qui est à l'écran ; sinon (réglage
-- du joueur) valeurs posées tout de suite.
function NS.ApplyFilters(smooth)
    local filters = NS.AppliedFilters()
    local target = RenderValues(filters)
    smooth = smooth and not Same(shown, target)
    local active = not Same(target, NEUTRAL) or smooth
    if not layer then
        if not active then return end
        CreateLayer()
    end
    layer:SetShown(active and true or false)
    fade = nil
    if not active then
        for key, value in pairs(target) do shown[key] = value end
        layer:SetScript("OnUpdate", nil)
        return
    end

    if smooth then
        local from = {}
        for key, value in pairs(shown) do from[key] = value end
        fade = { from = from, to = target, elapsed = 0 }
        Render()   -- calque montré à l'instant : textures au point de départ, pas à leur dernier état
    else
        for key, value in pairs(target) do shown[key] = value end
        Render()
    end
    -- Ni fondu ni grain : aucun OnUpdate.
    layer:SetScript("OnUpdate", (fade or target.grain > 0 or shown.grain > 0) and OnUpdate or nil)
end
