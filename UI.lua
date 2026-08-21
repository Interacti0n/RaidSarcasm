-- GUI menu

local f = CreateFrame("Frame", "RaidSarcasmMenu", UIParent)
f:SetSize(160, 26)
f:SetPoint("CENTER", 0, 0)
f:SetAlpha(0.70)

-- Allow the frame to be moved

f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")

f:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- Main button to toggle the menu

local mainBtn = CreateFrame("Button", nil, f)
mainBtn:SetSize(160, 26)
mainBtn:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
mainBtn:SetText("Raid Sarcasm [+]")

SkinButton(mainBtn)

-- Redirect dragging from the button to the entire frame

mainBtn:RegisterForDrag("LeftButton")

mainBtn:SetScript("OnDragStart", function()
    f:StartMoving()
end)

mainBtn:SetScript("OnDragStop", function()
    f:StopMovingOrSizing()
end)

-- Submenu

local subMenu = CreateFrame("Frame", nil, f)
subMenu:SetSize(160, 102)
subMenu:SetPoint("TOPLEFT", mainBtn, "BOTTOMLEFT", 0, -2)
subMenu:Hide()

-- Submenu background

if E and E.SetTemplate then
    subMenu:SetTemplate("Transparent")
else
    local bg = subMenu:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(subMenu)
    bg:SetTexture(0, 0, 0, 0.8)
end

-- Toggle menu state

local isExpanded = false

mainBtn:SetScript("OnClick", function()
    if isExpanded then
        subMenu:Hide()
        mainBtn:SetText("Raid Sarcasm [+]")
        f:SetHeight(26)
        f:SetAlpha(0.70)
    else
        subMenu:Show()
        mainBtn:SetText("Raid Sarcasm [-]")
        f:SetHeight(130)
        f:SetAlpha(1.00)
    end

    isExpanded = not isExpanded
end)

-- Button 1: Lost Tank

local btn1 = CreateFrame("Button", nil, subMenu)
btn1:SetSize(150, 24)
btn1:SetPoint("TOP", subMenu, "TOP", 0, -6)
btn1:SetText("Lost Tank")

SkinButton(btn1)

btn1:SetScript("OnClick", function()
    SendRandomEmote(lostTanks)
end)

-- Button 2: Low DPS

local btn2 = CreateFrame("Button", nil, subMenu)
btn2:SetSize(150, 24)
btn2:SetPoint("TOP", btn1, "BOTTOM", 0, -5)
btn2:SetText("Low DPS")

SkinButton(btn2)

btn2:SetScript("OnClick", function()
    SendRandomEmote(lowDps)
end)

-- Button 3: No Threat

local btn3 = CreateFrame("Button", nil, subMenu)
btn3:SetSize(150, 24)
btn3:SetPoint("TOP", btn2, "BOTTOM", 0, -5)
btn3:SetText("No Threat")

SkinButton(btn3)

btn3:SetScript("OnClick", function()
    SendRandomEmote(zeroThreat)
end)

-- ElvUI font settings

if E then
    local font = E.media.normFont

    if font then
        mainBtn:GetFontString():SetFont(font, 12, "OUTLINE")
        btn1:GetFontString():SetFont(font, 12, "OUTLINE")
        btn2:GetFontString():SetFont(font, 12, "OUTLINE")
        btn3:GetFontString():SetFont(font, 12, "OUTLINE")
    end
end

-- Menu slash command

SLASH_RAIDSARCASM1 = "/rsmenu"

SlashCmdList["RAIDSARCASM"] = function()
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
    end
end

-- Hide the menu by default

f:Hide()

print("|cFF1784D1ElvUI|r |cFF00FF00RaidSarcasm loaded successfully!|r")