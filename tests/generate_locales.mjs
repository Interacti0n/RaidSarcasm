import fs from "node:fs";
import path from "node:path";

const source = fs.readFileSync("Locales/enUS.lua", "utf8");
const decode = value => JSON.parse(`"${value}"`);
const strings = block => [...block.matchAll(/"((?:[^"\\]|\\.)*)"/g)].map(match => decode(match[1]));
const uiBlock = source.match(/ui\s*=\s*\{([\s\S]*?)\n\s*\},\n\s*categories/)[1];
const ui = {};
for (const match of uiBlock.matchAll(/(\w+)\s*=\s*"((?:[^"\\]|\\.)*)"/g)) ui[match[1]] = decode(match[2]);
const categories = {};
for (const match of source.matchAll(/(\w+)\s*=\s*\{\s*label\s*=\s*"([^"]+)",\s*messages\s*=\s*\{([\s\S]*?)\n\s*\}\},/g)) {
  categories[match[1]] = { label: match[2], messages: strings(match[3]) };
}
if (Object.keys(categories).length !== 10) throw new Error("Could not parse all English categories");

const targets = {
  deDE: "de", frFR: "fr", esES: "es", itIT: "it", ptBR: "pt", ruRU: "ru",
  koKR: "ko", zhCN: "zh-CN", zhTW: "zh-TW", skSK: "sk", csCZ: "cs",
};
const separator = "\n<<<RSSEP>>>\n";
const protect = text => text.replaceAll("%t", "__RSTARGET__").replaceAll("%.1f", "__RSFLOAT__").replaceAll("%s", "__RSVALUE__");
const restore = text => text.replaceAll("__RSTARGET__", "%t").replaceAll("__ RSTARGET __", "%t")
  .replaceAll("__RSFLOAT__", "%.1f").replaceAll("__ RSFLOAT __", "%.1f")
  .replaceAll("__RSVALUE__", "%s").replaceAll("__ RSVALUE __", "%s");

async function translateGroup(values, language) {
  const q = values.map(protect).join(separator);
  const params = new URLSearchParams({ client: "gtx", sl: "en", tl: language, dt: "t", q });
  const response = await fetch(`https://translate.googleapis.com/translate_a/single?${params}`);
  if (!response.ok) throw new Error(`Translation request failed: ${response.status}`);
  const payload = await response.json();
  const translated = payload[0].map(part => part[0]).join("");
  const parts = translated.split(/\s*<<<\s*RSSEP\s*>>>\s*/i).map(restore);
  if (parts.length !== values.length) throw new Error(`Expected ${values.length} translations, got ${parts.length}`);
  return parts;
}

const luaString = value => JSON.stringify(value).replaceAll("\\u2028", "\\n").replaceAll("\\u2029", "\\n");
for (const [locale, language] of Object.entries(targets)) {
  const translatedUiValues = await translateGroup(Object.values(ui), language);
  const translatedUi = Object.fromEntries(Object.keys(ui).map((key, index) => [key, translatedUiValues[index]]));
  translatedUi.title = "Raid Sarcasm";
  const translatedCategories = {};
  for (const [id, category] of Object.entries(categories)) {
    const translated = await translateGroup([category.label, ...category.messages], language);
    translatedCategories[id] = { label: translated[0], messages: translated.slice(1) };
  }
  const lines = ["local addonName, ns = ...", "", `ns.RegisterLocale(${luaString(locale)}, {`, "    ui = {"];
  for (const [key, value] of Object.entries(translatedUi)) lines.push(`        ${key} = ${luaString(value)},`);
  lines.push("    },", "    categories = {");
  for (const [id, category] of Object.entries(translatedCategories)) {
    lines.push(`        ${id} = { label = ${luaString(category.label)}, messages = {`);
    for (const message of category.messages) lines.push(`            ${luaString(message)},`);
    lines.push("        }},");
  }
  lines.push("    },", "})", "");
  fs.writeFileSync(path.join("Locales", `${locale}.lua`), lines.join("\n"), "utf8");
  console.log(`Generated ${locale}`);
}
fs.copyFileSync("Locales/esES.lua", "Locales/esMX.lua");
let esMX = fs.readFileSync("Locales/esMX.lua", "utf8").replace('RegisterLocale("esES"', 'RegisterLocale("esMX"');
fs.writeFileSync("Locales/esMX.lua", esMX, "utf8");
console.log("Generated esMX from esES");
