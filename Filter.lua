-- Filtres posés sur le monde : textures sur une frame à soi, enfant de WorldFrame, sous
-- l'interface. Aucune CVar écrite, donc aucun conflit avec les menus du jeu.
-- Réglages dans PanoramaDB.filters, une valeur par clé de NS.filterSettings ; ambiance : Ambiance.lua.
-- Filtres du joueur (onglet Mes filtres) : PanoramaDB.customFilters, clés de NS.customFilterSettings.
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

-- Valeurs des CVars Contrast, Brightness et Gamma qu'un filtre du joueur peut imposer : index = valeur
-- de ses réglages `contrast`, `brightness`, `gamma` (0 : réglages du joueur).
NS.imageValues = { contrast = {}, brightness = {}, gamma = {} }
for value = 5, 100, 5 do
    NS.imageValues.contrast[#NS.imageValues.contrast + 1] = value
    NS.imageValues.brightness[#NS.imageValues.brightness + 1] = value
end
for tenths = 3, 28 do NS.imageValues.gamma[#NS.imageValues.gamma + 1] = tenths / 10 end

-- Filtres du joueur, réglés dans l'onglet Mes filtres : PanoramaDB.customFilters, liste de 1 à n
-- filtres (le joueur en ajoute et en supprime, il en reste toujours un), une valeur par clé de la liste ci-dessous, plus `name` (nom donné par le joueur ; nil : nom par
-- défaut). Choisi par le réglage `customFilter` (filtres de base, lieu ou zone), un filtre remplace
-- teinte, vignette et grain (RenderValues) et impose son contraste, sa luminosité et son gamma au
-- jeu (NS.PlacePreset). Couleur de la teinte en pourcentage par composante.
local CUSTOM_FILTER_NAME_BYTES = 96   -- 24 caractères saisis, 4 octets au plus chacun
NS.customFilterSettings = {
    { key = "tintRed", min = 0, max = 100, step = 1, default = 85 },
    { key = "tintGreen", min = 0, max = 100, step = 1, default = 80 },
    { key = "tintBlue", min = 0, max = 100, step = 1, default = 100 },
    { key = "tintStrength", min = 0, max = 100, step = 5, default = 50 },
    { key = "vignette", min = 0, max = 100, step = 5, default = 0 },
    { key = "grain", min = 0, max = 100, step = 5, default = 0 },
}
for _, key in ipairs({ "contrast", "brightness", "gamma" }) do
    local names = { [0] = "PRESET_MINE" }
    for index, value in ipairs(NS.imageValues[key]) do
        names[index] = key == "gamma" and ("%.1f"):format(value) or tostring(value)
    end
    NS.customFilterSettings[#NS.customFilterSettings + 1] = { key = key, min = 0, max = #NS.imageValues[key], step = 1,
                                                              default = 0, names = names }
end

-- Nom d'un filtre du joueur : celui qu'il a donné, sinon « Filtre 2 ». nil si `index` n'en désigne aucun.
function NS.CustomFilterName(index)
    local custom = NS.db.customFilters[index]
    return custom and (custom.name or NS.L.CUSTOM_FILTER_NAME:format(index))
end
local GRAIN_SIZE = 128   -- côté d'une tuile de grain, en unités d'interface
local GRAIN_FRAME = 1 / 24
local SKY_GROUND = 0.4   -- part de la couleur du ciel gardée en bas de l'écran

-- Même forme que NS.settings, avec `key` à la place de `cvar`. `names` : texte affiché par valeur.
NS.filterSettings = {
    { title = "SECTION_FILTERS", tab = "filters" },
    -- Filtre du joueur en tête : choisi, il remplace teinte, vignette et grain. `names` : 0, puis le
    -- nom de chaque filtre, relu à chaque affichage (le joueur le renomme).
    -- `max` : nombre de filtres du joueur, relevé à chaque chargement, ajout ou suppression.
    { key = "customFilter", min = 0, max = 1, step = 1, default = 0,
      names = setmetatable({ [0] = "CUSTOM_FILTER_NONE" },
                           { __index = function(_, index) return NS.CustomFilterName(index) end }) },
    -- Teinte : la fenêtre l'affiche en vignettes cliquables (Options.lua).
    -- `strength` : intensité remise à son défaut quand on clique une teinte à intensité 0.
    { key = "tint", basic = true, strength = "tintStrength", min = 0, max = #TINTS, step = 1, default = 0,
      names = { [0] = "TINT_NONE", "TINT_SEPIA", "TINT_WARM", "TINT_COLD",
                "TINT_NIGHT", "TINT_EMERALD", "TINT_DUSK" } },
    { key = "tintStrength", basic = true, requires = "tint", min = 0, max = 100, step = 5, default = 50 },
    -- Ciel : même palette que la teinte, en dégradé, pleine force en haut de l'écran.
    { key = "sky", min = 0, max = #TINTS, step = 1, default = 0,
      names = { [0] = "TINT_NONE", "TINT_SEPIA", "TINT_WARM", "TINT_COLD",
                "TINT_NIGHT", "TINT_EMERALD", "TINT_DUSK" } },
    { key = "skyStrength", requires = "sky", min = 0, max = 100, step = 5, default = 50 },
    { key = "vignette", min = 0, max = 100, step = 5, default = 0 },
    { key = "grain", min = 0, max = 100, step = 5, default = 0 },
    -- Hauteur de chaque bande, en pourcentage de la hauteur de l'écran. 0 : pas de bandes.
    -- Hors ambiance : toujours lue dans les filtres de base.
    { key = "letterbox", min = 0, max = 20, step = 1, default = 0 },
    -- Jour/nuit automatique, dans l'onglet Ambiance avec l'autre automatisme : `tintDay` remplace
    -- `tint` le jour, `tintNight` la nuit (NS.NightFactor). Jamais avec l'ambiance auto : activer
    -- l'un coupe l'autre. Lu dans les filtres de base seulement.
    { title = "SECTION_DAYNIGHT", tab = "ambiance" },
    { key = "autoDayNight", default = false },
    { key = "tintDay", strength = "tintDayStrength", requires = "autoDayNight",
      min = 0, max = #TINTS, step = 1, default = 2,
      names = { [0] = "TINT_NONE", "TINT_SEPIA", "TINT_WARM", "TINT_COLD",
                "TINT_NIGHT", "TINT_EMERALD", "TINT_DUSK" } },
    { key = "tintDayStrength", min = 0, max = 100, step = 5, default = 25,
      requires = function(filters) return filters.autoDayNight and filters.tintDay ~= 0 end },
    { key = "tintNight", strength = "tintNightStrength", requires = "autoDayNight",
      min = 0, max = #TINTS, step = 1, default = 4,
      names = { [0] = "TINT_NONE", "TINT_SEPIA", "TINT_WARM", "TINT_COLD",
                "TINT_NIGHT", "TINT_EMERALD", "TINT_DUSK" } },
    { key = "tintNightStrength", min = 0, max = 100, step = 5, default = 90,
      requires = function(filters) return filters.autoDayNight and filters.tintNight ~= 0 end },
}

-- Faux pour un nombre hors bornes, hors choix ou une valeur d'un autre type.
function NS.IsValidFilter(setting, value)
    if type(setting.default) == "boolean" then return type(value) == "boolean" end
    return type(value) == "number" and value == value and value >= setting.min and value <= setting.max
        and (not setting.names or setting.names[value] ~= nil)
end

-- Ligne du réglage `customFilter`, dont la borne suit le nombre de filtres du joueur.
local function CustomFilterSetting()
    for _, setting in ipairs(NS.filterSettings) do
        if setting.key == "customFilter" then return setting end
    end
end

-- Valeurs lues dans PanoramaDB : valeur invalide remplacée par le défaut. Rend le nombre de valeurs
-- présentes mais invalides (une valeur absente, réglage ajouté depuis, n'est pas comptée).
function NS.LoadFilters(db)
    local reset = 0
    local function Reset(values, key, default)
        if values[key] ~= nil then reset = reset + 1 end
        values[key] = default
    end
    -- Filtres du joueur d'abord : le réglage `customFilter` est validé sur eux.
    if type(db.customFilters) ~= "table" then Reset(db, "customFilters", {}) end
    local customFilters = db.customFilters
    -- Liste suivie depuis 1 : une autre clé (fichier édité à la main) est oubliée, elle n'est pas validée.
    local count = 0
    while customFilters[count + 1] ~= nil do count = count + 1 end
    for key in pairs(customFilters) do
        if type(key) ~= "number" or key < 1 or key > count or key % 1 ~= 0 then Reset(customFilters, key, nil) end
    end
    for index = 1, math.max(count, 1) do
        local custom = db.customFilters[index]
        if type(custom) ~= "table" then
            custom = {}
            Reset(db.customFilters, index, custom)
        end
        for _, setting in ipairs(NS.customFilterSettings) do
            if not NS.IsValidFilter(setting, custom[setting.key]) then Reset(custom, setting.key, setting.default) end
        end
        -- `|` : code d'échappement du jeu, refusé dans un nom affiché.
        local name = custom.name
        if type(name) ~= "string" or not name:find("%S") or #name > CUSTOM_FILTER_NAME_BYTES or name:find("|", 1, true) then
            Reset(custom, "name", nil)
        end
    end
    CustomFilterSetting().max = #customFilters
    if type(db.filters) ~= "table" then Reset(db, "filters", {}) end
    local filters = db.filters
    local keepsDay = filters.autoDayNight == true and filters.tintDay == nil
    for _, setting in ipairs(NS.filterSettings) do
        if setting.key and not NS.IsValidFilter(setting, db.filters[setting.key]) then
            Reset(db.filters, setting.key, setting.default)
        end
    end
    -- Jour/nuit déjà coché avant l'ajout de la teinte de jour : le jour garde la teinte de l'onglet
    -- Filtres (valeurs validées ci-dessus).
    if keepsDay then filters.tintDay, filters.tintDayStrength = filters.tint, filters.tintStrength end
    return reset
end

-- Nouveau filtre du joueur, aux valeurs par défaut : rend son index. Nom par défaut déjà pris par
-- un autre filtre (après une suppression) : le premier « Filtre n » libre lui est donné.
function NS.AddCustomFilter()
    local custom = {}
    for _, setting in ipairs(NS.customFilterSettings) do custom[setting.key] = setting.default end
    local customFilters = NS.db.customFilters
    local taken = {}
    for index in ipairs(customFilters) do taken[NS.CustomFilterName(index)] = true end
    local number = 1
    while taken[NS.L.CUSTOM_FILTER_NAME:format(number)] do number = number + 1 end
    customFilters[#customFilters + 1] = custom
    if number ~= #customFilters then custom.name = NS.L.CUSTOM_FILTER_NAME:format(number) end
    CustomFilterSetting().max = #customFilters
    return #customFilters
end

-- Supprime un filtre du joueur, sauf le dernier qui reste. Ce qui le choisissait (onglet Filtres,
-- lieux, zones) passe à Aucun ; ce qui choisissait un filtre suivant suit son nouvel index.
function NS.DeleteCustomFilter(index)
    local customFilters = NS.db.customFilters
    if #customFilters <= 1 or not customFilters[index] then return end
    -- Filtres suivants sans nom : leur nom par défaut (numéro de place) est figé, ils ne changent pas de nom.
    for following = index + 1, #customFilters do
        customFilters[following].name = NS.CustomFilterName(following)
    end
    table.remove(customFilters, index)
    CustomFilterSetting().max = #customFilters
    local function Follow(values)
        local chosen = values.customFilter
        if chosen == index then
            values.customFilter = 0
        elseif type(chosen) == "number" and chosen > index then
            values.customFilter = chosen - 1
        end
    end
    Follow(NS.db.filters)
    for _, values in pairs(NS.db.ambiance.contexts) do Follow(values) end
    for _, values in pairs(NS.db.ambiance.zones) do Follow(values) end
    NS.ApplyFilters()
end

local layer, vignette, grain, tint, sky, topBand, bottomBand
local grainElapsed = 0
-- Ce qui est à l'écran, en valeurs de rendu : couleurs multipliées (blanc = rien), opacités.
-- Ambiance qui change de contexte : fondu de `fade.from` vers `fade.to` en FADE_SECONDS.
local NEUTRAL = { tintR = 1, tintG = 1, tintB = 1, vignette = 0, grain = 0, letterbox = 0,
                  skyR = 1, skyG = 1, skyB = 1, skyTopR = 1, skyTopG = 1, skyTopB = 1 }
local FADE_SECONDS = 1.5
-- Changement de moment de la journée (jour, aube et crépuscule, nuit) : fondu lent.
local MOMENT_FADE_SECONDS = 60
local shownMoment   -- moment de la dernière application des filtres
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
    local base = NS.db.filters
    -- Filtre du joueur choisi, ou ouvert dans l'onglet Mes filtres (aperçu) : sa couleur, sa vignette
    -- et son grain remplacent ceux des filtres lus, teintes de jour et de nuit comprises.
    local custom = NS.db.customFilters[NS.previewCustomFilter or filters.customFilter]
    if custom then
        values.tintR, values.tintG, values.tintB = Blend(
            { custom.tintRed / 100, custom.tintGreen / 100, custom.tintBlue / 100 }, custom.tintStrength / 100)
    else
        -- Jour/nuit automatique : la teinte de jour remplace celle de l'onglet Filtres.
        local dayTint, dayStrength = filters.tint, filters.tintStrength
        if base.autoDayNight then dayTint, dayStrength = base.tintDay, base.tintDayStrength end
        local color = dayStrength > 0 and TINTS[dayTint]
        if color then values.tintR, values.tintG, values.tintB = Blend(color, dayStrength / 100) end
        -- Nuit (0 le jour, 1 la nuit, entre les deux à l'aube et au crépuscule) : la teinte de nuit
        -- remplace celle de jour. Jamais avec l'ambiance auto : l'une coupe l'autre.
        local night = base.autoDayNight and NS.NightFactor() or 0
        if night > 0 then
            local nightColor = TINTS[base.tintNight]
            local r, g, b = 1, 1, 1
            if nightColor then r, g, b = Blend(nightColor, base.tintNightStrength / 100) end
            values.tintR = values.tintR + (r - values.tintR) * night
            values.tintG = values.tintG + (g - values.tintG) * night
            values.tintB = values.tintB + (b - values.tintB) * night
        end
    end
    values.letterbox = base.letterbox / 100
    local look = custom or filters
    values.vignette = look.vignette / 100
    values.grain = look.grain / 100 * 0.35
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

-- Bandes noires en haut et en bas : part de la hauteur du calque.
local function LayoutBands()
    local height = layer:GetHeight() * shown.letterbox
    topBand:SetHeight(height)
    bottomBand:SetHeight(height)
end

local skyBottomColor, skyTopColor = CreateColor(1, 1, 1, 1), CreateColor(1, 1, 1, 1)

local function Render()
    local hasTint = shown.tintR < 1 or shown.tintG < 1 or shown.tintB < 1
    tint:SetShown(hasTint)
    if hasTint then tint:SetColorTexture(shown.tintR, shown.tintG, shown.tintB, 1) end
    vignette:SetShown(shown.vignette > 0)
    vignette:SetAlpha(shown.vignette)
    grain:SetShown(shown.grain > 0)
    grain:SetAlpha(shown.grain)
    topBand:SetShown(shown.letterbox > 0)
    bottomBand:SetShown(shown.letterbox > 0)
    LayoutBands()
    local hasSky = shown.skyTopR < 1 or shown.skyTopG < 1 or shown.skyTopB < 1
    sky:SetShown(hasSky)
    if hasSky then
        -- VERTICAL : première couleur en bas, seconde en haut.
        -- Couleurs réutilisées : Render tourne à chaque image pendant un fondu de 60 s.
        skyBottomColor:SetRGBA(shown.skyR, shown.skyG, shown.skyB, 1)
        skyTopColor:SetRGBA(shown.skyTopR, shown.skyTopG, shown.skyTopB, 1)
        sky:SetGradient("VERTICAL", skyBottomColor, skyTopColor)
    end
end

-- Fondu en cours, puis grain animé. Fin du fondu : cible atteinte, puis filtres reposés (calque
-- caché si plus rien n'est actif, OnUpdate coupé si plus de grain ; nouveau fondu si le contexte a
-- changé sans événement, intérieur ou heure).
local function OnUpdate(_, elapsed)
    if fade then
        fade.elapsed = fade.elapsed + elapsed
        local progress = fade.elapsed / fade.seconds
        if progress >= 1 then
            for key, value in pairs(fade.to) do shown[key] = value end
            fade = nil
            NS.ApplyFilters(true)
            -- Réglages du lieu reposés en fin de fondu (reprise après refus) : panneau à jour.
            if NS.RefreshOptions then NS.RefreshOptions() end
            return
        end
        for key, target in pairs(fade.to) do shown[key] = fade.from[key] + (target - fade.from[key]) * progress end
        Render()
    end
    if shown.grain > 0 then AnimateGrain(elapsed) end
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
    -- Ordre des calques : teinte et ciel (MOD, ordre indifférent), vignette, grain, puis bandes par-dessus.
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
    topBand, bottomBand = CreateBand("TOP"), CreateBand("BOTTOM")
    -- Changement de résolution, letterbox des cinématiques : les bandes gardent leur proportion.
    layer:SetScript("OnSizeChanged", LayoutBands)
end

-- Calque créé au premier filtre actif : rien n'est posé sur le monde tant que tout est à 0.
-- Valeurs : filtres de base, ou ambiance du contexte (Ambiance.lua) ; filtre du joueur choisi, ou ouvert
-- dans l'onglet Mes filtres (aperçu), par-dessus.
-- `smooth` : changement de contexte de l'ambiance ou d'heure, fondu depuis ce qui est à l'écran (lent si
-- le moment de la journée a changé) ; sinon (réglage du joueur) valeurs posées tout de suite.
function NS.ApplyFilters(smooth)
    -- Même moment que les filtres : lieu, réglage d'un lieu ou ambiance changés.
    -- Isolé : une erreur d'écriture d'un réglage du jeu ne bloque pas les filtres.
    if NS.ApplyPlacePreset then
        local applied, message = pcall(NS.ApplyPlacePreset)
        if not applied then geterrorhandler()(message) end
    end
    local filters = NS.AppliedFilters()
    local target = RenderValues(filters)
    local moment = NS.CurrentMoment()
    -- Fondu lent en cours (moment) : son temps restant gardé, un changement de lieu ne l'abrège pas.
    local remaining = fade and fade.seconds - fade.elapsed or 0
    -- Premier passage (shownMoment nil) : pas de fondu lent, rien n'a encore été montré.
    local fadeSeconds = (shownMoment and moment ~= shownMoment) and MOMENT_FADE_SECONDS
        or math.max(FADE_SECONDS, remaining)
    shownMoment = moment
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
        fade = { from = from, to = target, elapsed = 0, seconds = fadeSeconds }
        Render()   -- calque montré à l'instant : textures au point de départ, pas à leur dernier état
    else
        for key, value in pairs(target) do shown[key] = value end
        Render()
    end
    -- Ni fondu ni grain : aucun OnUpdate.
    layer:SetScript("OnUpdate", (fade or target.grain > 0 or shown.grain > 0) and OnUpdate or nil)
end
