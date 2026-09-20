local addonName, ns = ...
local panel, title, description, languageLabel, dropdown

local function DisplayName(code)
    if code == "auto" then return ns.Text("automatic", ns.localeNames[ns.GetDetectedLocale()]) end
    return ns.localeNames[code] or code
end

local function InitializeDropdown(self, level)
    for _, code in ipairs(ns.localeOrder) do
        local localeCode = code
        local info = UIDropDownMenu_CreateInfo()
        info.text = DisplayName(localeCode)
        info.value = localeCode
        info.checked = ns.db.language == localeCode
        info.func = function()
            ns.SetLanguage(localeCode)
            UIDropDownMenu_SetSelectedValue(dropdown, localeCode)
            UIDropDownMenu_SetText(dropdown, DisplayName(localeCode))
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

function ns.RefreshOptions()
    if not panel then return end
    title:SetText(ns.Text("title"))
    description:SetText(ns.Text("description"))
    languageLabel:SetText(ns.Text("language"))
    UIDropDownMenu_SetSelectedValue(dropdown, ns.db.language)
    UIDropDownMenu_SetText(dropdown, DisplayName(ns.db.language))
end

function ns.OpenOptions()
    if not panel then return end
    InterfaceOptionsFrame_OpenToCategory(panel)
    InterfaceOptionsFrame_OpenToCategory(panel)
end

function ns.CreateOptions()
    if panel then return end
    panel = CreateFrame("Frame", "RaidSarcasmOptionsPanel", InterfaceOptionsFramePanelContainer)
    panel.name = "RaidSarcasm"
    title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    description = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    description:SetWidth(560)
    description:SetJustifyH("LEFT")
    languageLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    languageLabel:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -24)
    dropdown = CreateFrame("Frame", "RaidSarcasmLanguageDropdown", panel, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", languageLabel, "BOTTOMLEFT", -16, -4)
    UIDropDownMenu_SetWidth(dropdown, 200)
    UIDropDownMenu_Initialize(dropdown, InitializeDropdown)
    InterfaceOptions_AddCategory(panel)
    ns.RefreshOptions()
end
