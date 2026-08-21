-- 1. ZOZNAMY HLÁŠOK
local lostTanks = {
    "fires a flare gun at %t so they can finally find their way back to the boss.",
    "asks %t if the wall they are currently staring at said something offensive.",
    "opens a map of Azeroth and tries to point out to %t where the raid is.",
    "hands %t a GPS navigation system because their tanking style looks like orienteering.",
    "drops a trail of gold coins to lure %t back into the active combat zone."
}

local lowDps = {
    "applauds %t for a flawless dance in the mechanics, though it's a shame they are only tickling the boss.",
    "checks to see if %t accidentally equipped a foam sword from the Darkmoon Faire.",
    "gently reminds %t that the boss is not immune to damage, so they are free to start hitting it.",
    "notes that %t's damage meter looks like a heart monitor of someone who is legally dead.",
    "hands %t a small bell to shake, since it would contribute more to the fight than their current rotation."
}

local zeroThreat = {
    "admires %t's absolute invincibility, even if their DPS looks like an aggressive pillow fight.",
    "suggests %t try hitting the boss next time, rather than just glaring at it judgmentally from behind a shield.",
    "asks %t if they are saving their threat-generating abilities for the next expansion.",
    "hands %t a calculator to show them that 0 damage equals 0 threat.",
    "whispers to %t: 'The boss isn't afraid of your shield, they are just confused by your lack of threat.'"
}

-- Spoločná funkcia pre odoslanie správy
local function SendRandomEmote(emotesList)
    local target = UnitName("target")
    if not target then
        print("|cFFFF0000RaidSarcasm: Musíš mať označený cieľ!|r")
        return
    end
    local randomIndex = math.random(1, #emotesList)
    local formattedMessage = string.gsub(emotesList[randomIndex], "%%t", target)
    SendChatMessage(formattedMessage, "EMOTE")
end

-- Detekcia ElvUI
local E
if IsAddOnLoaded("ElvUI") then
    E = unpack(ElvUI)
end

-- Funkcia na skinovanie tlačidiel
local function SkinButton(btn)
    if E and E.Skins then
        E.Skins:HandleButton(btn)
    else
        btn:SetNormalTexture("")
        btn:SetHighlightTexture("")
        btn:SetPushedTexture("")
    end
end

-- 2. VYTVORENIE GRAFICKÉHO MENU
local f = CreateFrame("Frame", "RaidSarcasmMenu", UIParent)
f:SetSize(160, 26)
f:SetPoint("CENTER", 0, 0)

-- Povolenie hýbania
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", function(self) self:StartMoving() end)
f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

-- Hlavné prepínacie tlačidlo
local mainBtn = CreateFrame("Button", nil, f)
mainBtn:SetSize(160, 26)
mainBtn:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
mainBtn:SetText("Raid Sarcasm [+]")
SkinButton(mainBtn)

-- Nastavenie základnej priehľadnosti celého okna na 0.7
f:SetAlpha(0.70)

-- Presmerovanie ťahania z tlačidla na celý Frame
mainBtn:RegisterForDrag("LeftButton")
mainBtn:SetScript("OnDragStart", function() f:StartMoving() end)
mainBtn:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)

-- Priečinok pre skryté pod-menu tlačidlá
local subMenu = CreateFrame("Frame", nil, f)
subMenu:SetSize(160, 102)
subMenu:SetPoint("TOPLEFT", mainBtn, "BOTTOMLEFT", 0, -2)
subMenu:Hide()

-- Pozadie pre pod-menu
if E then
    subMenu:SetTemplate("Transparent")
else
    local bg = subMenu:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(subMenu)
    bg:SetTexture(0, 0, 0, 0.8)
end

-- Funkcia na prepínanie stavu (Collapse / Expand) s úpravou priehľadnosti
local isExpanded = false
mainBtn:SetScript("OnClick", function()
    if isExpanded then
        subMenu:Hide()
        mainBtn:SetText("Raid Sarcasm [+]")
        f:SetHeight(26)
        f:SetAlpha(0.70) -- Keď sa zbalí (Collapse), vráti sa na 0.70 priehľadnosť
    else
        subMenu:Show()
        mainBtn:SetText("Raid Sarcasm [-]")
        f:SetHeight(130)
        f:SetAlpha(1.00) -- Keď sa rozbalí (Expand), svieti naplno na 1.00
    end
    isExpanded = not isExpanded
end)

-- Tlačidlo 1: Lost Tank
local btn1 = CreateFrame("Button", nil, subMenu)
btn1:SetSize(150, 24)
btn1:SetPoint("TOP", subMenu, "TOP", 0, -6)
btn1:SetText("Lost Tank")
SkinButton(btn1)
btn1:SetScript("OnClick", function() SendRandomEmote(lostTanks) end)

-- Tlačidlo 2: Low DPS
local btn2 = CreateFrame("Button", nil, subMenu)
btn2:SetSize(150, 24)
btn2:SetPoint("TOP", btn1, "BOTTOM", 0, -5)
btn2:SetText("Low DPS")
SkinButton(btn2)
btn2:SetScript("OnClick", function() SendRandomEmote(lowDps) end)

-- Tlačidlo 3: No Threat
local btn3 = CreateFrame("Button", nil, subMenu)
btn3:SetSize(150, 24)
btn3:SetPoint("TOP", btn2, "BOTTOM", 0, -5)
btn3:SetText("No Threat")
SkinButton(btn3)
btn3:SetScript("OnClick", function() SendRandomEmote(zeroThreat) end)

-- Nastavenie ElvUI fontov
if E then
    local font = E.media.normFont
    if font then
        mainBtn:GetFontString():SetFont(font, 12, "OUTLINE")
        btn1:GetFontString():SetFont(font, 12, "OUTLINE")
        btn2:GetFontString():SetFont(font, 12, "OUTLINE")
        btn3:GetFontString():SetFont(font, 12, "OUTLINE")
    end
end

-- 3. REGISTRÁCIA TEXTOVÝCH PRÍKAZOV (/slash)
SLASH_LOSTTANK1 = "/losttank"
SlashCmdList["LOSTTANK"] = function() SendRandomEmote(lostTanks) end

SLASH_BADPLAY1 = "/badplay"
SlashCmdList["BADPLAY"] = function() SendRandomEmote(lowDps) end

SLASH_NOTHREAT1 = "/nothreat"
SlashCmdList["NOTHREAT"] = function() SendRandomEmote(zeroThreat) end

SLASH_RAIDSARCASM1 = "/rsmenu"
SlashCmdList["RAIDSARCASM"] = function()
    if f:IsShown() then f:Hide() else f:Show() end
end

print("|cFF1784D1ElvUI|r |cFF00FF00RaidSarcasm úspešne načítaný!|r")
