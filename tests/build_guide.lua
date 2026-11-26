-- Convertit GUIDE.md et GUIDE.<code>.md en Guide/<code>.lua, lus par le guide en jeu (Guide.lua) :
-- un addon ne lit pas de fichier .md. Après chaque retouche d'un guide, depuis la racine :
--   lua5.1 tests/build_guide.lua
-- tests/run_tests.lua échoue si un Guide/<code>.lua ne correspond plus à son .md.
-- Blocs produits : { "h1"|"h2"|"h3"|"p", texte }, { "li", texte, repère }, { "row", gauche, droite }.
-- Markdown accepté : celui des guides (titres, paragraphes, listes - et 1., tableaux à 2 colonnes,
-- gras, code, liens). Ligne de tableau d'en-tête et paragraphe de liens vers les autres guides omis.
local CODES = { "enUS", "frFR", "deDE", "esES", "itIT", "ptBR", "ruRU", "koKR", "zhCN", "zhTW" }
local GOLD = "|cffffd100"

local function Source(code)
    return code == "enUS" and "GUIDE.md" or "GUIDE." .. code .. ".md"
end

local function Inline(text)
    text = text:gsub("|", "||")
    text = text:gsub("%[([^%]]+)%]%([^%)]+%)", "%1")
    text = text:gsub("%*%*(.-)%*%*", GOLD .. "%1|r")
    text = text:gsub("`([^`]+)`", GOLD .. "%1|r")
    return text
end

local function Parse(code)
    -- Chinois : pas d'espace à la jointure de deux lignes, sauf entre deux caractères ASCII.
    local noSpace = code == "zhCN" or code == "zhTW"
    local blocks, open, inTable = {}, nil, false
    local function Flush()
        if not open then return end
        local text = open.lines[1]
        for i = 2, #open.lines do
            local nextLine = open.lines[i]
            local joint = (noSpace and (text:byte(-1) >= 128 or nextLine:byte(1) >= 128)) and "" or " "
            text = text .. joint .. nextLine
        end
        if not text:find("%]%(GUIDE%.") then
            blocks[#blocks + 1] = open.kind == "li" and { "li", Inline(text), open.marker } or { open.kind, Inline(text) }
        end
        open = nil
    end
    local file = assert(io.open(Source(code), "rb"))
    for rawLine in file:read("*a"):gmatch("([^\n]*)\n?") do
        local line = rawLine:gsub("\r$", "")
        local hashes, title = line:match("^(#+)%s+(.*)$")
        local marker, item = line:match("^(%-) (.*)$")
        if not marker then marker, item = line:match("^(%d+%.) (.*)$") end
        if not line:find("^|") then inTable = false end
        if line:find("^%s*$") then
            Flush()
        elseif hashes then
            Flush()
            blocks[#blocks + 1] = { "h" .. #hashes, Inline(title) }
        elseif line:find("^|") then
            Flush()
            if not line:find("^|[%s%-:|]+|$") then
                if inTable then
                    local left, right = line:match("^|%s*(.-)%s*|%s*(.-)%s*|$")
                    assert(left, Source(code) .. " : tableau à 2 colonnes attendu : " .. line)
                    blocks[#blocks + 1] = { "row", Inline(left), Inline(right) }
                end
                inTable = true
            end
        elseif marker then
            Flush()
            open = { kind = "li", marker = marker, lines = { item } }
        elseif open and line:find("^%s") then
            open.lines[#open.lines + 1] = line:match("^%s*(.-)%s*$")
        elseif open and open.kind == "p" then
            open.lines[#open.lines + 1] = line:match("^(.-)%s*$")
        else
            Flush()
            open = { kind = "p", lines = { line:match("^(.-)%s*$") } }
        end
    end
    file:close()
    Flush()
    return blocks
end

local function Generate(code)
    local out = {
        "-- Généré par tests/build_guide.lua depuis " .. Source(code) .. " : ne pas éditer à la main.",
        "local _, NS = ...",
        "NS.guides = NS.guides or {}",
        "NS.guides." .. code .. " = {",
    }
    for _, block in ipairs(Parse(code)) do
        local fields = {}
        for i, value in ipairs(block) do fields[i] = string.format("%q", value) end
        out[#out + 1] = "    { " .. table.concat(fields, ", ") .. " },"
    end
    out[#out + 1] = "}"
    if code == "esES" then out[#out + 1] = "NS.guides.esMX = NS.guides.esES" end
    return table.concat(out, "\n") .. "\n"
end

if arg and arg[0] and arg[0]:find("build_guide") then
    for _, code in ipairs(CODES) do
        local file = assert(io.open("Guide/" .. code .. ".lua", "wb"))
        file:write(Generate(code))
        file:close()
    end
    print("Guide/*.lua : " .. #CODES .. " fichiers écrits")
end

return { codes = CODES, Generate = Generate }
