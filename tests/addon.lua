-- Run from the addon directory with Lua 5.1+ or Fengari: lua tests/addon.lua
local checks = 0
local function check(value, message)
    checks = checks + 1
    assert(value, message)
end

local function Boot(saved, skinMode)
    local state = { frames = {}, sent = {}, logs = {}, now = 0, target = "TestTarget", skinned = 0 }
    local env = setmetatable({}, { __index = _G })
    env._G = env
    env.SlashCmdList = {}
    env.RaidSarcasmDB = saved
    env.print = function(message) state.logs[#state.logs + 1] = message end
    env.GetTime = function() return state.now end
    env.UnitName = function(unit) assert(unit == "target"); return state.target end
    env.IsAddOnLoaded = function(name) return name == "ElvUI" and skinMode ~= nil end
    env.SendChatMessage = function(text, channel)
        state.sent[#state.sent + 1] = { text = text, channel = channel }
    end
    local methods = {}
    function methods:SetSize(w, h) self.width, self.height = w, h end
    function methods:SetHeight(h) self.height = h end
    function methods:GetHeight() return self.height end
    function methods:SetPoint(...) self.point = { ... } end
    function methods:ClearAllPoints() self.point = nil end
    function methods:SetAlpha(a) self.alpha = a end
    function methods:SetClampedToScreen(v) self.clamped = v end
    function methods:SetMovable(v) self.movable = v end
    function methods:EnableMouse(v) self.mouse = v end
    function methods:RegisterForDrag(button) self.dragButton = button end
    function methods:SetScript(event, handler) self.scripts[event] = handler end
    function methods:RegisterEvent(event) self.events[event] = true end
    function methods:UnregisterEvent(event) self.events[event] = nil end
    function methods:StartMoving() self.moving = true end
    function methods:StopMovingOrSizing() self.moving = false end
    function methods:GetEffectiveScale() return self.scale or 1 end
    function methods:GetLeft() return self.left or 100 end
    function methods:GetTop() return self.top or 200 end
    function methods:SetNormalFontObject(font) self.normalFont = font end
    function methods:SetHighlightFontObject(font) self.highlightFont = font end
    function methods:SetText(text) assert(self.fontString, "Button needs text object"); self.text = text end
    function methods:GetFontString() return self.fontString end
    function methods:SetBackdrop(backdrop) self.backdrop = backdrop end
    function methods:SetBackdropColor(...) self.color = { ... } end
    function methods:Show() self.shown = true end
    function methods:Hide() self.shown = false end
    function methods:IsShown() return self.shown end
    if skinMode then
        function methods:SetTemplate(template) self.template = template end
        env.ElvUI = {{
            media = { normFont = "TestFont" },
            Skins = { HandleButton = function(_, button)
                if skinMode == "broken" then error("Simulated skin failure") end
                assert(button:GetFontString(), "Skin must receive a complete button")
                state.skinned = state.skinned + 1
            end },
        }}
    end
    env.CreateFrame = function(kind, name, parent, template)
        if name then assert(rawget(env, name) == nil, "Duplicate named frame: " .. name) end
        local f = setmetatable({ kind = kind, name = name, parent = parent,
            scripts = {}, events = {}, shown = true }, { __index = methods })
        if template == "UIPanelButtonTemplate" then
            f.fontString = { SetFont = function(self, font) self.font = font end }
        end
        if name then env[name] = f end
        state.frames[#state.frames + 1] = f
        return f
    end
    env.UIParent = env.CreateFrame("Frame")
    local ns = {}
    local tocText = os.getenv("RAIDSARCASM_TEST_TOC")
    if not tocText then
        local toc = assert(io.open("RaidSarcasm.toc", "r"))
        tocText = toc:read("*a")
        toc:close()
    end
    for line in tocText:gmatch("[^\r\n]+") do
        local file = line:match("^([%w_]+%.lua)%s*$")
        if file then
            local chunk
            if setfenv then chunk = setfenv(assert(loadfile(file)), env)
            else chunk = assert(loadfile(file, "t", env)) end
            chunk("RaidSarcasm", ns)
        end
    end
    check(rawget(env, "RaidSarcasmMenu") == nil, "UI must wait for login")
    for _, f in ipairs(state.frames) do
        if f.events.PLAYER_LOGIN then f.scripts.OnEvent(f, "PLAYER_LOGIN") end
    end
    state.env, state.ns, state.menu = env, ns, env.RaidSarcasmMenu
    state.command = env.SlashCmdList.RAIDSARCASM
    return state
end

local s = Boot()
check(s.menu and s.menu.clamped and s.menu.shown, "Menu must be visible and clamped")
check(s.ns.db.cooldown == 3 and not s.ns.db.expanded, "Default settings")
check(#s.ns.categories == 10, "Expected category count")
local categoryIds, categoryCommands = {}, {}
for _, category in ipairs(s.ns.categories) do
    check(not categoryIds[category.id], "Category IDs must be unique")
    check(not categoryCommands[category.command], "Category commands must be unique")
    check(#category.messages == 10, "Each built-in category has ten messages")
    categoryIds[category.id] = true
    categoryCommands[category.command] = true
end
local frameCount = #s.frames
s.ns.CreateUI()
check(#s.frames == frameCount, "UI creation must be idempotent")
for _, category in ipairs(s.ns.categories) do
    s.now = s.now + 3
    s.env.SlashCmdList["RAIDSARCASM_" .. string.upper(category.id)]()
    local sent = s.sent[#s.sent]
    check(sent.channel == "EMOTE" and sent.text:find("TestTarget", 1, true), "Category slash command")
end
local count = #s.sent
check(not s.ns.SendRandomEmote(s.ns.categories[1]) and #s.sent == count, "Shared cooldown")
s.now = s.now + 3
s.target = nil
check(not s.ns.SendRandomEmote(s.ns.categories[1]) and #s.sent == count, "No target must not send")
s.target = "Percent%1%t"
check(s.ns.SendRandomEmote(s.ns.categories[1]), "Rejected send must not consume cooldown")
check(s.sent[#s.sent].text:find(s.target, 1, true), "Target percent signs remain literal")
s.command("cooldown 0")
check(s.ns.db.cooldown == 0, "Disable cooldown")
for i = 1, 30 do
    local previous = s.sent[#s.sent].text
    check(s.ns.SendRandomEmote(s.ns.categories[1]), "Repeated send")
    check(previous ~= s.sent[#s.sent].text, "No consecutive duplicate text")
end
check(not s.ns.SendRandomEmote({ id = "empty", messages = {} }), "Empty category")
check(not s.ns.SendRandomEmote(nil), "Missing category")
check(not s.ns.SendRandomEmote({ messages = { "waves" } }), "Missing category ID")
check(not s.ns.SendRandomEmote({ id = "bad", messages = { false } }), "Invalid message")
check(not s.ns.SendRandomEmote({ id = "long", messages = { string.rep("x", 256) } }), "Oversize message")
check(s.ns.SendRandomEmote({ id = "single", messages = { "waves to %t" } }), "Single message category")
check(s.ns.SendRandomEmote({ id = "single", messages = { "waves to %t" } }), "Single message can repeat")
for _, value in ipairs({ "-1", "61", "abc", "1e999" }) do
    s.command("cooldown " .. value)
    check(s.ns.db.cooldown == 0, "Invalid cooldown must not overwrite setting")
end
-- Exercise actual button handlers and their category closures.
for _, f in ipairs(s.frames) do
    if f.kind == "Button" and f.parent ~= s.menu then
        local previousCount = #s.sent
        f.scripts.OnClick()
        check(#s.sent == previousCount + 1, "Category button must send")
        local category
        for _, entry in ipairs(s.ns.categories) do if entry.label == f.text then category = entry end end
        local found = false
        for _, message in ipairs(category.messages) do
            if message:gsub("%%t", function() return s.target end) == s.sent[#s.sent].text then found = true end
        end
        check(found, "Button must use its own category")
    elseif f.kind == "Button" and f.parent == s.menu then
        f.scripts.OnClick()
        check(s.ns.db.expanded and s.menu.height > 26, "Expand menu")
        f.scripts.OnDragStart()
        f.scripts.OnDragStop()
        check(s.ns.db.position.x == 100 and s.ns.db.position.y == 200, "Save top-left position")
    end
end
s.command("hide")
check(not s.menu.shown and not s.ns.db.visible, "Hide persists")
local restored = Boot(s.ns.db, "working")
check(not restored.menu.shown and restored.ns.db.expanded, "Restore visibility and expansion")
check(restored.menu.point[4] == 100 and restored.menu.point[5] == 200, "Restore position")
check(restored.skinned == #restored.ns.categories + 1, "Skin title and all category buttons")
restored.command("reset")
check(restored.menu.shown and restored.ns.db.position == nil and not restored.ns.db.expanded, "Reset recovers menu")
restored.command("")
check(not restored.menu.shown, "Toggle menu")
restored.command(" SHOW ")
check(restored.menu.shown, "Case-insensitive command")
local broken = Boot(nil, "broken")
check(broken.menu.shown and broken.command, "Skin errors must not break initialization")
check(broken.ns.SendRandomEmote(broken.ns.categories[1]), "Emotes work after skin error")
local corrupt = Boot({ cooldown = 0/0, position = {point = "INVALID"}, visible = "no", expanded = 3 })
check(corrupt.ns.db.cooldown == 3 and corrupt.ns.db.position == nil and corrupt.menu.shown, "Repair corrupt settings")
local invalid = Boot("invalid")
check(type(invalid.ns.db) == "table", "Repair invalid saved variable")
print("PASS: " .. checks .. " checks (mock WoW API; live client verification still required)")
