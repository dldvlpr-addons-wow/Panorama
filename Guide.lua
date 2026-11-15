-- Guide en jeu : fenêtre défilante, ouverte par le bouton Guide de la fenêtre Panorama.
-- Texte : NS.guides[langue], généré depuis les GUIDE*.md par tests/build_guide.lua (repli enUS).
-- Construite au premier affichage, dans la langue de Panorama (un changement de langue recharge l'interface).
local _, NS = ...

local WIDTH = 530
local ROW_LEFT = 170    -- colonne gauche d'une ligne de tableau
local INDENT = 20       -- texte d'un élément de liste, après son repère
local FONTS = { h2 = "GameFontNormalLarge", h3 = "GameFontNormal", p = "GameFontHighlight",
                li = "GameFontHighlight", row = "GameFontHighlight" }
local GAP = { h2 = 20, h3 = 12, p = 8, li = 4, row = 8 }   -- espace au-dessus du bloc

local guide

local function Text(parent, font, x, y, width, text)
    local label = parent:CreateFontString(nil, "ARTWORK", font)
    label:SetPoint("TOPLEFT", x, y)
    label:SetWidth(width)
    label:SetJustifyH("LEFT")
    label:SetSpacing(2)
    label:SetText(text)
    return label:GetStringHeight()
end

local function Build()
    guide = CreateFrame("Frame", "PanoramaGuideFrame", UIParent, "BasicFrameTemplate")
    guide:SetSize(590, 640)
    if PanoramaFrame then
        guide:SetPoint("TOPLEFT", PanoramaFrame, "TOPRIGHT", 4, 0)
    else
        guide:SetPoint("CENTER")
    end
    guide:SetFrameStrata("DIALOG")
    guide:SetToplevel(true)
    guide:SetClampedToScreen(true)
    guide:SetMovable(true)
    guide:EnableMouse(true)
    guide:RegisterForDrag("LeftButton")
    guide:SetScript("OnDragStart", guide.StartMoving)
    guide:SetScript("OnDragStop", guide.StopMovingOrSizing)
    tinsert(UISpecialFrames, "PanoramaGuideFrame")

    local scroll = CreateFrame("ScrollFrame", nil, guide, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 14, -32)
    scroll:SetPoint("BOTTOMRIGHT", -36, 12)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(WIDTH, 10)
    scroll:SetScrollChild(content)

    local y = 0
    for index, block in ipairs(NS.guides[NS.language] or NS.guides.enUS) do
        local kind = block[1]
        if kind == "h1" then
            guide.TitleText:SetText(block[2])
        else
            if index > 2 then y = y - GAP[kind] end
            local height
            if kind == "li" then
                Text(content, FONTS.li, 0, y, INDENT, block[3])
                height = Text(content, FONTS.li, INDENT, y, WIDTH - INDENT, block[2])
            elseif kind == "row" then
                height = math.max(Text(content, FONTS.row, 0, y, ROW_LEFT - 12, block[2]),
                                  Text(content, FONTS.row, ROW_LEFT, y, WIDTH - ROW_LEFT, block[3]))
            else
                height = Text(content, FONTS[kind], 0, y, WIDTH, block[2])
            end
            y = y - math.ceil(height)
        end
    end
    content:SetHeight(-y + 12)
end

function NS.ToggleGuide()
    if not guide then Build() return guide:Show() end
    guide:SetShown(not guide:IsShown())
end
