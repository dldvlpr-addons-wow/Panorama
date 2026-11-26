-- Test temporaire. Valeurs relevées juste après suppression de Config.wtf (détection du matériel).
-- CVar absente du relevé : le jeu ne l'a pas écrite, valeur attendue = défaut moteur.
-- Clés en minuscules : la casse des noms de CVar varie.
local detected = {
    cameradistancemaxzoomfactor = "1",
    depthbasedopacity = "0",
    doodadlodscale = "75",
    entityloddist = "5",
    farclip = "3000",
    lodobjectfadescale = "80",
    projectedtextures = "1",
    rippledetail = "0",
    shadowtexturesize = "512",
    spellclutter = "1",
    volumefoglevel = "1",
    weatherdensity = "0",
}
local names = {
    "bloomUserMult",
    "Brightness",
    "cameraDistanceMaxZoomFactor",
    "cameraZoomSpeed",
    "Contrast",
    "DepthBasedOpacity",
    "detailDoodleDensity",
    "doodadLodScale",
    "entityLodDist",
    "farclip",
    "ffxDeath",
    "Gamma",
    "groundEffectDensity",
    "groundEffectDist",
    "groundEffectFade",
    "gxMultisample",
    "HDRBrightness",
    "HDRFactor",
    "HDROutput",
    "HDRPeakBrightness",
    "horizonfarclip",
    "horizonStart",
    "lodObjectCullSize",
    "lodObjectFadeScale",
    "LowLatencyMode",
    "particleMTDensity",
    "physicsLevel",
    "ProjectedTextures",
    "rawMouseEnable",
    "reflectionMode",
    "ResampleAlwaysSharpen",
    "ResampleSharpness",
    "rippleDetail",
    "screenshotQuality",
    "shadowLevel",
    "shadowSoft",
    "shadowTextureSize",
    "skyCloudLod",
    "spellClutter",
    "SSAO",
    "SSFX",
    "sunShafts",
    "terrainLodDist",
    "useHDRBrightness",
    "useHDRPeakBrightness",
    "violenceLevel",
    "volumeFog",
    "volumeFogLevel",
    "waterDetail",
    "WeatherDensity",
    "wmoLodDist",
}

local function Same(a, b)
    local x, y = tonumber(a), tonumber(b)
    if x and y then return math.abs(x - y) < 0.001 end
    return a == b
end

local function Check()
    local same, checked = 0, 0
    print("|cff33ff99DetectionCheck|r hwDetect = " .. tostring(GetCVar("hwDetect")))
    for _, name in ipairs(names) do
        local value = GetCVar(name)
        if value ~= nil then
            checked = checked + 1
            local expected = detected[name:lower()] or GetCVarDefault(name)
            if Same(value, expected) then
                same = same + 1
            else
                print(("  %s = %s, détection %s%s"):format(name, value, tostring(expected),
                    detected[name:lower()] and "" or " (défaut moteur)"))
            end
        end
    end
    print(("|cff33ff99DetectionCheck|r %d / %d identiques à la détection"):format(same, checked))
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    C_Timer.After(3, Check)
end)
SLASH_DETECTIONCHECK1 = "/detectcheck"
SlashCmdList.DETECTIONCHECK = Check
