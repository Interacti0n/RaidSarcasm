local addonName, ns = ...

ns.locales = {}
ns.localeOrder = {
    "auto", "enUS", "deDE", "frFR", "esES", "esMX", "itIT", "ptBR",
    "ruRU", "koKR", "zhCN", "zhTW", "skSK", "csCZ",
}
ns.localeNames = {
    auto = "Automatic",
    enUS = "English", deDE = "Deutsch", frFR = "Français",
    esES = "Español (España)", esMX = "Español (Latinoamérica)",
    itIT = "Italiano", ptBR = "Português (Brasil)", ruRU = "Русский",
    koKR = "한국어", zhCN = "简体中文", zhTW = "繁體中文",
    skSK = "Slovenčina", csCZ = "Čeština",
}

-- Command words are intentionally never translated, so help always matches
-- the commands registered with WoW.
local commandText = { cooldownUsage = true, languageUsage = true, help = true }
local localizedLoaded = { skSK = true, csCZ = true }

local aliases = { enGB = "enUS", ptPT = "ptBR", czCZ = "csCZ" }

function ns.NormalizeLocale(code)
    if type(code) ~= "string" then return nil end
    return aliases[code] or code
end

function ns.RegisterLocale(code, data)
    ns.locales[code] = data
end

function ns.IsLanguageSupported(code)
    code = ns.NormalizeLocale(code)
    return code == "auto" or ns.locales[code] ~= nil
end

function ns.GetDetectedLocale()
    local code = ns.NormalizeLocale(GetLocale and GetLocale() or "enUS")
    return ns.locales[code] and code or "enUS"
end

function ns.ApplyLanguage(code)
    code = ns.NormalizeLocale(code)
    if not ns.IsLanguageSupported(code) then code = "auto" end
    ns.languageSetting = code
    ns.activeLocale = code == "auto" and ns.GetDetectedLocale() or code
    ns.L = ns.locales[ns.activeLocale] or ns.locales.enUS
    if ns.RefreshUI then ns.RefreshUI() end
    if ns.RefreshOptions then ns.RefreshOptions() end
    return ns.activeLocale
end

function ns.Text(key, ...)
    local value
    if not commandText[key] and (key ~= "loaded" or localizedLoaded[ns.activeLocale]) then
        value = ns.L and ns.L.ui and ns.L.ui[key]
    end
    if value == nil then
        local english = ns.locales.enUS
        value = english and english.ui and english.ui[key] or key
    end
    if select("#", ...) > 0 then return string.format(value, ...) end
    return value
end

function ns.GetCategoryLabel(id)
    local category = ns.L and ns.L.categories and ns.L.categories[id]
    local english = ns.locales.enUS
    local fallback = english and english.categories and english.categories[id]
    return category and category.label or fallback and fallback.label
end

function ns.GetMessages(id)
    local category = ns.L and ns.L.categories and ns.L.categories[id]
    local english = ns.locales.enUS
    local fallback = english and english.categories and english.categories[id]
    if not fallback then return nil end
    local result = {}
    for index = 1, #fallback.messages do
        result[index] = category and category.messages[index] or fallback.messages[index]
    end
    return result
end
