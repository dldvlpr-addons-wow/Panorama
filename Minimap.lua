-- Bouton de minimap : logo Panorama, déplaçable autour de la minimap, sans bibliothèque.
-- Clic gauche : panneau. Clic droit : préréglages, annulation, redémarrage du moteur.
local addonName, NS = ...
local L = NS.L

local LOGO = "Interface\\AddOns\\" .. addonName .. "\\Media\\logo"
local atan2 = math.atan2 or math.atan

local button

-- Place le bouton sur le bord de la minimap. Les minimaps carrées (GetMinimapShape, défini
-- par l'addon qui remplace la minimap) bornent la position au carré.
local function Place()
    local angle = math.rad(NS.db.minimap.angle)
    local half = Minimap:GetWidth() / 2 + 5
    local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
    local x, y = math.cos(angle), math.sin(angle)
    if shape == "ROUND" then
        x, y = x * half, y * half
    else
        local reach = half * 1.4142
        x = math.max(-half, math.min(x * reach, half))
        y = math.max(-half, math.min(y * reach, half))
    end
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function FollowCursor()
    local centerX, centerY = Minimap:GetCenter()
    local scale = Minimap:GetEffectiveScale()
    local cursorX, cursorY = GetCursorPosition()
    NS.db.minimap.angle = math.deg(atan2(cursorY / scale - centerY, cursorX / scale - centerX))
    Place()
end

local function ShowMenu()
    if not (MenuUtil and MenuUtil.CreateContextMenu) then
        if NS.OpenOptions then NS.OpenOptions() end
        return
    end
    MenuUtil.CreateContextMenu(button, function(_, root)
        root:CreateTitle(L.OPT_PRESETS)
        for index, preset in ipairs(NS.presets) do
            root:CreateButton(preset.label, function() NS.ApplyPreset(index) end)
        end
        root:CreateDivider()
        if NS.CanUndo and NS.CanUndo() then
            root:CreateButton(L.OPT_UNDO, NS.Undo)
        end
        root:CreateButton(L.OPT_RESTART, NS.RestartGraphics)
    end)
end

function NS.UpdateMinimapButton()
    if not button then return end
    if NS.db.minimap.show then
        Place()
        button:Show()
    else
        button:Hide()
    end
end

function NS.BuildMinimapButton()
    button = CreateFrame("Button", "PanoramaMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture(LOGO)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")

    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "RightButton" then
            ShowMenu()
        elseif NS.OpenOptions then
            NS.OpenOptions()
        end
    end)
    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", FollowCursor)
        GameTooltip:Hide()
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Panorama")
        GameTooltip:AddLine(L.MINIMAP_TIP_OPEN, 1, 1, 1)
        GameTooltip:AddLine(L.MINIMAP_TIP_MENU, 1, 1, 1)
        GameTooltip:AddLine(L.MINIMAP_TIP_DRAG, 1, 1, 1)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    NS.UpdateMinimapButton()
end
