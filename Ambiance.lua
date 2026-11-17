-- Ambiance automatique : les filtres suivent le contexte détecté, sur deux axes.
-- Lieu (donjon, intérieur, météo, zone réglée par le joueur, biome de la zone) : teinte, son
-- intensité, vignette, grain.
-- Moment de la journée (jour, aube et crépuscule, nuit) : dégradé du ciel, dehors seulement.
-- Rien n'est écrit dans PanoramaDB.filters :
-- l'ambiance vit dans PanoramaDB.ambiance (contexts : par contexte ; zones : uiMapID -> valeurs
-- propres à une zone, mêmes clés que son biome).
local _, NS = ...

-- Clés de NS.filterSettings que l'ambiance remplace.
NS.ambianceKeys = { "tint", "tintStrength", "vignette", "grain", "sky", "skyStrength" }

-- Ordre du menu de l'éditeur. `values` : valeurs livrées, et clés éditées pour ce contexte.
-- Teinte et ciel = index de NS.tints (1 sépia, 2 chaude, 3 froide, 4 nuit, 5 émeraude, 6 crépuscule).
-- Biomes réglés sur des captures des zones (wikis, captures Forever, nov. 2026) : le filtre ne fait
-- qu'assombrir (mode MOD), teinte nulle ou légère là où la zone est déjà saturée (volcan, désert).
NS.ambianceContexts = {
    { id = "day", label = "AMBIANCE_DAY", values = { sky = 3, skyStrength = 20 } },
    { id = "dusk", label = "AMBIANCE_DUSK", values = { sky = 1, skyStrength = 35 } },
    { id = "night", label = "AMBIANCE_NIGHT", values = { sky = 4, skyStrength = 45 } },
    { id = "temperate", label = "AMBIANCE_TEMPERATE", values = { tint = 2, tintStrength = 15, vignette = 15, grain = 0 } },
    { id = "desert", label = "AMBIANCE_DESERT", values = { tint = 2, tintStrength = 10, vignette = 20, grain = 0 } },
    { id = "frozen", label = "AMBIANCE_FROZEN", values = { tint = 3, tintStrength = 15, vignette = 20, grain = 0 } },
    { id = "jungle", label = "AMBIANCE_JUNGLE", values = { tint = 5, tintStrength = 15, vignette = 25, grain = 0 } },
    { id = "corrupted", label = "AMBIANCE_CORRUPTED", values = { tint = 4, tintStrength = 15, vignette = 30, grain = 10 } },
    { id = "volcanic", label = "AMBIANCE_VOLCANIC", values = { tint = 0, tintStrength = 30, vignette = 30, grain = 10 } },
    { id = "arcane", label = "AMBIANCE_ARCANE", values = { tint = 6, tintStrength = 15, vignette = 20, grain = 0 } },
    { id = "rain", label = "AMBIANCE_RAIN", values = { tint = 3, tintStrength = 30, vignette = 25, grain = 10 } },
    { id = "snow", label = "AMBIANCE_SNOW", values = { tint = 3, tintStrength = 20, vignette = 15, grain = 0 } },
    { id = "sandstorm", label = "AMBIANCE_SANDSTORM", values = { tint = 1, tintStrength = 35, vignette = 25, grain = 20 } },
    { id = "indoor", label = "AMBIANCE_INDOOR", values = { tint = 2, tintStrength = 20, vignette = 30, grain = 0 } },
    { id = "dungeon", label = "AMBIANCE_DUNGEON", values = { tint = 4, tintStrength = 25, vignette = 40, grain = 10 } },
}

-- uiMapID des zones de Forever 1.60.1 (table UiMap du build 70938) -> biome. Zone absente :
-- carte parente cherchée, puis tempéré.
local BIOMES = {
    temperate = { 1412, 1417, 1424, 1425, 1429, 1432, 1433, 1436, 1439, 1440, 1442, 1453, 1456, 2521, 2665 },
    desert = { 1411, 1413, 1418, 1441, 1446, 1451, 1454 },
    frozen = { 1416, 1426, 1452, 1455 },
    jungle = { 1434, 1435, 1437, 1444, 1445, 1449, 2548, 2652 },
    corrupted = { 1419, 1420, 1421, 1422, 1423, 1430, 1431, 1443, 1448, 1458 },
    volcanic = { 1427, 1428 },
    arcane = { 1438, 1447, 1450, 1457, 2482 },
}
local ZONE_BIOMES = {}
for biome, maps in pairs(BIOMES) do
    for _, mapID in ipairs(maps) do ZONE_BIOMES[mapID] = biome end
end

-- Enum.WeatherType de Forever 1.60.1 : 0 clair, 1 pluie, 2 neige, 3 tempête de sable, 4 autre.
local WEATHER_CONTEXTS = { [1] = "rain", [2] = "snow", [3] = "sandstorm" }
local TICK_SECONDS = 60   -- l'heure du jeu n'a pas d'événement : relue chaque minute
local MAX_MAP_DEPTH = 10  -- garde contre une boucle de cartes parentes

local function FilterSetting(key)
    for _, setting in ipairs(NS.filterSettings) do
        if setting.key == key then return setting end
    end
end

local function ShippedValues(id)
    for _, context in ipairs(NS.ambianceContexts) do
        if context.id == id then return context.values end
    end
end

-- Carte de la zone (première carte connue en remontant les parentes, sinon la carte de départ) et
-- son biome, tempéré si aucune carte n'est connue.
local function FindZone(mapID)
    local start = mapID
    for _ = 1, MAX_MAP_DEPTH do
        if not mapID or mapID == 0 then break end
        if ZONE_BIOMES[mapID] then return mapID, ZONE_BIOMES[mapID] end
        local info = C_Map.GetMapInfo(mapID)
        mapID = info and info.parentMapID
    end
    return start ~= 0 and start or nil, "temperate"
end

-- Zone du joueur et son biome. Carte illisible (écran de chargement) : dernière zone lue gardée,
-- pour ne pas retomber sur le tempéré le temps du chargement.
local lastZone, lastBiome = nil, "temperate"
function NS.CurrentZone()
    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID and mapID ~= 0 then lastZone, lastBiome = FindZone(mapID) end
    return lastZone, lastBiome
end

-- Biome d'une zone rendue par NS.CurrentZone : carte connue, ou carte inconnue comptée tempérée.
function NS.ZoneBiome(mapID)
    return ZONE_BIOMES[mapID] or "temperate"
end

function NS.ZoneName(mapID)
    local info = C_Map.GetMapInfo(mapID)
    return info and info.name or tostring(mapID)
end

-- Réglage propre à une zone, copié de son biome : la zone garde ensuite ses valeurs.
function NS.CustomizeZone(mapID)
    local zones = NS.db.ambiance.zones
    if zones[mapID] then return zones[mapID] end
    local biome = NS.ZoneBiome(mapID)
    local values = {}
    for key in pairs(ShippedValues(biome)) do values[key] = NS.db.ambiance.contexts[biome][key] end
    zones[mapID] = values
    return values
end

-- Valeurs lues dans PanoramaDB : contexte absent ou valeur invalide remplacé par la valeur livrée ;
-- zone illisible supprimée, valeur invalide d'une zone remplacée par celle de son biome.
function NS.LoadAmbiance(db)
    if type(db.ambiance) ~= "table" then db.ambiance = {} end
    local ambiance = db.ambiance
    if type(ambiance.enabled) ~= "boolean" then ambiance.enabled = false end
    if type(ambiance.contexts) ~= "table" then ambiance.contexts = {} end
    for _, context in ipairs(NS.ambianceContexts) do
        local values = ambiance.contexts[context.id]
        if type(values) ~= "table" then
            values = {}
            ambiance.contexts[context.id] = values
        end
        for key, shipped in pairs(context.values) do
            if not NS.IsValidFilter(FilterSetting(key), values[key]) then values[key] = shipped end
        end
    end
    if type(ambiance.zones) ~= "table" then ambiance.zones = {} end
    for mapID, values in pairs(ambiance.zones) do
        if type(mapID) ~= "number" or type(values) ~= "table" then
            ambiance.zones[mapID] = nil
        else
            local biome = NS.ZoneBiome(mapID)
            for key in pairs(ShippedValues(biome)) do
                if not NS.IsValidFilter(FilterSetting(key), values[key]) then
                    values[key] = ambiance.contexts[biome][key]
                end
            end
        end
    end
end

-- Lieu, du plus précis au plus général : donjon ou raid, intérieur, météo, biome. Puis moment de la
-- journée (signal jour/nuit du jeu, heure du serveur pour l'aube et le crépuscule) ;
-- nil sous un toit (donjon, intérieur) : pas de ciel. Avec le biome,
-- uiMapID de la zone, dont le réglage propre passe avant le biome.
function NS.DetectAmbiance()
    local inInstance, instanceType = IsInInstance()
    if inInstance and (instanceType == "party" or instanceType == "raid") then return "dungeon" end
    if IsIndoors() then return "indoor" end
    -- Nuit : signal jour/nuit du jeu (celui de l'indicateur de la minicarte), heure en repli.
    -- Aube et crépuscule n'ont pas de signal : heure du serveur, dans la part « jour » du jeu.
    local hour = GetGameTime()
    local isDay = C_DateAndTime and C_DateAndTime.IsDayTime and C_DateAndTime.IsDayTime()
    if isDay == nil then isDay = hour >= 5 and hour < 21 end
    local moment = "night"
    if isDay then moment = (hour < 7 or hour >= 19) and "dusk" or "day" end
    -- Effets météo coupés dans le jeu (WeatherDensity 0) : rien à l'écran, pas d'ambiance météo.
    local weather = C_CVar.GetCVar("WeatherDensity") ~= "0" and C_Weather.GetCurrentWeather()
    if weather and WEATHER_CONTEXTS[weather.type] then return WEATHER_CONTEXTS[weather.type], moment end
    local zone, biome = NS.CurrentZone()
    return biome, moment, zone
end

local applied = {}
-- Valeurs posées sur le monde : filtres de base, ou ambiance du lieu et du moment quand elle est active.
function NS.AppliedFilters()
    local base = NS.db.filters
    if not NS.db.ambiance.enabled then return base end
    local contexts = NS.db.ambiance.contexts
    local place, moment, zone = NS.DetectAmbiance()
    for key, value in pairs(zone and NS.db.ambiance.zones[zone] or contexts[place]) do applied[key] = value end
    if moment then
        applied.sky, applied.skyStrength = contexts[moment].sky, contexts[moment].skyStrength
    else
        applied.sky, applied.skyStrength = 0, 0
    end
    return applied
end

-- Zone, intérieur, météo ou heure changés : filtres reposés en fondu si l'ambiance est active,
-- ligne d'état relue.
function NS.UpdateAmbiance()
    if NS.db.ambiance.enabled then NS.ApplyFilters(true) end
    if NS.RefreshOptions then NS.RefreshOptions() end
end

local function Tick()
    C_Timer.After(TICK_SECONDS, Tick)   -- réarmé d'abord : une erreur ne coupe pas le minuteur
    NS.UpdateAmbiance()
end

function NS.StartAmbiance()
    C_Timer.After(TICK_SECONDS, Tick)
end
