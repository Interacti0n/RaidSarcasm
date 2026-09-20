local addonName, ns = ...
local menu, mainButton, subMenu
local buttons = {}
local categoryButtons = {}

local function SavePosition()
    -- A top-left anchor keeps the header stationary when the menu expands.
    ns.db.position = {
        point = "TOPLEFT", relativePoint = "BOTTOMLEFT",
        x = menu:GetLeft(), y = menu:GetTop(),
    }
end
local function RestorePosition()
    menu:ClearAllPoints()
    local p = ns.db.position
    if p then
        menu:SetPoint(p.point, UIParent, p.relativePoint, p.x, p.y)
    else
        menu:SetPoint("TOPLEFT", UIParent, "CENTER", -105, 13)
    end
end
function ns.SetVisible(visible)
    ns.db.visible = visible
    if visible then menu:Show() else menu:Hide() end
end
local function UpdateExpanded()
    local expanded = ns.db.expanded
    mainButton:SetText(ns.Text("title") .. (expanded and " [-]" or " [+]"))
    menu:SetHeight(expanded and (28 + subMenu:GetHeight()) or 26)
    menu:SetAlpha(expanded and 1 or 0.7)
    if expanded then subMenu:Show() else subMenu:Hide() end
end
function ns.ResetPosition()
    ns.db.position = nil
    ns.db.expanded = false
    UpdateExpanded()
    RestorePosition()
    ns.SetVisible(true)
    ns.Print(ns.Text("menuReset"))
end

function ns.RefreshUI()
    if not menu then return end
    UpdateExpanded()
    for id, button in pairs(categoryButtons) do button:SetText(ns.GetCategoryLabel(id)) end
end
local function ApplyElvUI()
    if not IsAddOnLoaded("ElvUI") or type(ElvUI) ~= "table" then return end
    local E = ElvUI[1]
    if not E or not E.Skins or type(E.Skins.HandleButton) ~= "function" then return end
    for _, button in ipairs(buttons) do
        E.Skins:HandleButton(button)
        local text = button:GetFontString()
        if text and E.media and E.media.normFont then
            text:SetFont(E.media.normFont, 12, "OUTLINE")
        end
    end
    if subMenu.SetTemplate then subMenu:SetTemplate("Transparent") end
end
local function AddButton(parent, label)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontHighlight")
    button:SetText(label)
    buttons[#buttons + 1] = button
    return button
end
function ns.CreateUI()
    if menu then return end
    menu = CreateFrame("Frame", "RaidSarcasmMenu", UIParent)
    menu:SetSize(210, 26)
    menu:SetClampedToScreen(true)
    menu:SetMovable(true)
    menu:EnableMouse(true)
    menu:RegisterForDrag("LeftButton")
    local function StartDrag() menu:StartMoving() end
    local function StopDrag()
        menu:StopMovingOrSizing()
        SavePosition()
        RestorePosition()
    end
    menu:SetScript("OnDragStart", StartDrag)
    menu:SetScript("OnDragStop", StopDrag)
    mainButton = AddButton(menu, ns.Text("title") .. " [+]")
    mainButton:SetSize(210, 26)
    mainButton:SetPoint("TOPLEFT", menu, "TOPLEFT", 0, 0)
    mainButton:RegisterForDrag("LeftButton")
    mainButton:SetScript("OnDragStart", StartDrag)
    mainButton:SetScript("OnDragStop", StopDrag)
    mainButton:SetScript("OnClick", function()
        ns.db.expanded = not ns.db.expanded
        UpdateExpanded()
    end)
    subMenu = CreateFrame("Frame", nil, menu)
    subMenu:SetSize(210, math.max(12, 12 + #ns.categories * 29 - 5))
    subMenu:SetPoint("TOPLEFT", mainButton, "BOTTOMLEFT", 0, -2)
    subMenu:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
    subMenu:SetBackdropColor(0, 0, 0, 0.85)
    for index, category in ipairs(ns.categories) do
        local entry = category
        local button = AddButton(subMenu, ns.GetCategoryLabel(entry.id))
        categoryButtons[entry.id] = button
        button:SetSize(200, 24)
        button:SetPoint("TOPLEFT", subMenu, "TOPLEFT", 5, -6 - (index - 1) * 29)
        button:SetScript("OnClick", function() ns.SendRandomEmote(entry) end)
    end
    -- Optional styling must never prevent the base UI or commands from loading.
    local ok = pcall(ApplyElvUI)
    if not ok then ns.Print("ElvUI styling could not be fully applied; the menu remains available.") end
    UpdateExpanded()
    RestorePosition()
    ns.SetVisible(ns.db.visible)
end
