local addonName, ns = ...
local lastSent
local lastMessage = {}

function ns.Print(message)
    print("|cFF1784D1RaidSarcasm:|r " .. message)
end

function ns.SendRandomEmote(category)
    if type(category) ~= "table" or type(category.id) ~= "string" or category.id == "" then
        ns.Print(ns.Text("invalidCategory"))
        return false
    end
    local messages = ns.GetMessages(category.id)
    if type(messages) ~= "table" or #messages == 0 then
        ns.Print(ns.Text("emptyCategory"))
        return false
    end
    for i = 1, #messages do
        if type(messages[i]) ~= "string" or messages[i] == "" then
            ns.Print(ns.Text("invalidMessage"))
            return false
        end
    end
    local target = UnitName("target")
    if not target then
        ns.Print(ns.Text("noTarget"))
        return false
    end
    local now = GetTime()
    local cooldown = ns.db.cooldown
    if lastSent and now - lastSent < cooldown then
        ns.Print(ns.Text("wait", cooldown - (now - lastSent)))
        return false
    end
    local candidates = {}
    for i = 1, #messages do
        if messages[i] ~= lastMessage[category.id] then candidates[#candidates + 1] = messages[i] end
    end
    local message = #candidates > 0 and candidates[math.random(#candidates)] or messages[1]
    local formatted = string.gsub(message, "%%t", function() return target end)
    if #formatted > 255 then
        ns.Print(ns.Text("tooLong"))
        return false
    end
    SendChatMessage(formatted, "EMOTE")
    lastSent = now
    lastMessage[category.id] = message
    return true
end

local anchorPoints = {
    TOPLEFT = true, TOP = true, TOPRIGHT = true, LEFT = true, CENTER = true,
    RIGHT = true, BOTTOMLEFT = true, BOTTOM = true, BOTTOMRIGHT = true,
}
local function FiniteNumber(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end
local function InitializeSettings()
    if type(RaidSarcasmDB) ~= "table" then RaidSarcasmDB = {} end
    ns.db = RaidSarcasmDB
    if type(ns.db.visible) ~= "boolean" then ns.db.visible = true end
    if type(ns.db.expanded) ~= "boolean" then ns.db.expanded = false end
    if not FiniteNumber(ns.db.cooldown) or ns.db.cooldown < 0 or ns.db.cooldown > 60 then ns.db.cooldown = 3 end
    local language = ns.NormalizeLocale(ns.db.language)
    if not ns.IsLanguageSupported(language) then language = "auto" end
    ns.db.language = language
    ns.ApplyLanguage(language)
    local p = ns.db.position
    if type(p) ~= "table" or not anchorPoints[p.point] or not anchorPoints[p.relativePoint]
        or not FiniteNumber(p.x) or not FiniteNumber(p.y) then ns.db.position = nil end
end

function ns.SetLanguage(code, silent)
    code = ns.NormalizeLocale(code)
    if not ns.IsLanguageSupported(code) then
        if not silent then ns.Print(ns.Text("languageUsage")) end
        return false
    end
    ns.db.language = code
    local active = ns.ApplyLanguage(code)
    if not silent then ns.Print(ns.Text("languageSet", ns.localeNames[active])) end
    return true
end

local function RegisterCommands()
    for _, category in ipairs(ns.categories) do
        local entry = category
        local key = "RAIDSARCASM_" .. string.upper(entry.id)
        _G["SLASH_" .. key .. "1"] = entry.command
        SlashCmdList[key] = function() ns.SendRandomEmote(entry) end
    end
    SLASH_RAIDSARCASM1 = "/rsmenu"
    SlashCmdList.RAIDSARCASM = function(input)
        local command, argument = string.match(input or "", "^%s*(%S*)%s*(.-)%s*$")
        command = string.lower(command)
        if command == "" then ns.SetVisible(not ns.db.visible)
        elseif command == "show" then ns.SetVisible(true)
        elseif command == "hide" then ns.SetVisible(false)
        elseif command == "reset" then ns.ResetPosition()
        elseif command == "settings" then ns.OpenOptions()
        elseif command == "language" or command == "lang" then ns.SetLanguage(argument)
        elseif command == "cooldown" then
            local seconds = tonumber(argument)
            if FiniteNumber(seconds) and seconds >= 0 and seconds <= 60 then
                ns.db.cooldown = seconds
                ns.Print(ns.Text("cooldownSet", seconds))
            else ns.Print(ns.Text("cooldownUsage")) end
        else
            ns.Print(ns.Text("help"))
            for _, category in ipairs(ns.categories) do
                ns.Print(category.command .. " - " .. ns.GetCategoryLabel(category.id))
            end
        end
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    InitializeSettings()
    ns.CreateUI()
    ns.CreateOptions()
    RegisterCommands()
    self:UnregisterEvent("PLAYER_LOGIN")
    ns.Print(ns.Text("loaded"))
end)
