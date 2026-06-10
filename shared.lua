--[[
    shared.lua — AeonoPlates
    Общие утилиты: вспомогательные функции, GetUnitData
    Загружается перед модулями и core.lua
]]

-- Глобальные таблицы иконок (используются в GetUnitData и модулях)
totemIcons = {
    -- Земля
    ["Тотем каменной кожи"]      = { status = true, icon = "Stoneskin Totem" },
    ["Тотем силы Земли"]        = { status = true, icon = "Strength of Earth Totem" },
    ["Тотем каменного когтя"]    = { status = true, icon = "Stoneclaw Totem" },
    ["Тотем оков земли"]        = { status = true, icon = "Earthbind Totem" },
    ["Тотем элементаля земли"]  = { status = true, icon = "Earth Elemental Totem" },
    ["Тотем трепета"]           = { status = true, icon = "Tremor Totem" },

    -- Огонь
    ["Опаляющий тотем"]         = { status = true, icon = "Searing Totem" },
    ["Тотем магмы"]             = { status = true, icon = "Magma Totem" },
    ["Тотем языка пламени"]     = { status = true, icon = "Flametongue Totem" },
    ["Тотем элементаля огня"]   = { status = true, icon = "Fire Elemental Totem" },
    ["Тотем гнева"]             = { status = true, icon = "Totem of Wrath" },
    ["Тотем защиты от магии льда"]    = { status = true, icon = "Frost Resistance Totem" },

    -- Вода
    ["Тотем исцеляющего потока"] = { status = true, icon = "Healing Stream Totem" },
    ["Тотем источника маны"]    = { status = true, icon = "Mana Spring Totem" },
    ["Тотем очищения"]          = { status = true, icon = "Disease Cleansing Totem" },
    ["Тотем защиты от магии огня"]    = { status = true, icon = "Fire Resistance Totem" },
    ["Тотем прилива маны"]      = { status = true, icon = "Mana Tide Totem" },

    -- Воздух
    ["Тотем неистовства ветра"] = { status = true, icon = "Windfury Totem" },
    ["Тотем гнева воздуха"]     = { status = true, icon = "Wrath of Air Totem" },
    ["Тотем заземления"]        = { status = true, icon = "Grounding Totem" },
    ["Тотем защиты от сил природы"] = { status = true, icon = "Nature Resistance Totem" },
    ["Сторожевой тотем"]        = { status = true, icon = "Sentry Totem" },

    -- misc
    ["Восставший союзник"]      = { status = true, icon = "Undead Army" },
    ["Кровавый червь"]          = { status = true, icon = "Bloodworm" },
    ["Войско мертвых"]          = { status = true, icon = "Undead Army" },
    ["Ядовитая змея"]           = { status = true, icon = "Snakes" },
    ["Гадюка"]                  = { status = true, icon = "Snakes" },
    ["Древень"]                 = { status = true, icon = "Treant" },
    ["Страж Ужаса"]             = { status = true, icon = "Doomguard" },
    ["Зловредный бес"]          = { status = true, icon = "Malicious Imp" },
}

classIcons = {
    ["WARRIOR"] = "WARRIOR",
    ["PALADIN"] = "PALADIN",
    ["HUNTER"] = "HUNTER",
    ["ROGUE"] = "ROGUE",
    ["PRIEST"] = "PRIEST",
    ["DEATHKNIGHT"] = "DEATHKNIGHT",
    ["SHAMAN"] = "SHAMAN",
    ["MAGE"] = "MAGE",
    ["WARLOCK"] = "WARLOCK",
    ["DRUID"] = "DRUID",
    ["MONK"] = "MONK",
    ["DEMONHUNTER"] = "DEMONHUNTER",
    ["EVOKER"] = "EVOKER",
}

-- 3. ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ

-- Измерялка ширины текста (один на весь аддон)
local measurer = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")

-- Определение пета по GUID
function UnitIsPetByGUID(guid)
    if not guid then return false end

    local charType = guid:sub(5, 5)
    local byteType = tonumber(charType, 16)
    if not byteType then return false end

    local unitType = byteType % 8
    return unitType == 4
end

-- Умная обрезка текста бинарным поиском
function SmartTruncate(text, maxWidth, font, size, flags)
    if not text or maxWidth <= 0 then
        return text
    end

    measurer:SetFont(font, size, flags)
    measurer:SetText(text)

    if measurer:GetStringWidth() <= maxWidth then
        return text
    end

    local low = 1
    local high = #text
    local best = 0

    while low <= high do
        local mid = math.floor((low + high) / 2)
        local truncated = text:sub(1, mid)
        measurer:SetText(truncated .. "..")

        if measurer:GetStringWidth() <= maxWidth then
            best = mid
            low = mid + 1
        else
            high = mid - 1
        end
    end

    if best > 0 then
        -- Корректировка для UTF-8 (не режем многобайтовые символы)
        while best > 0 and text:byte(best) >= 128 and text:byte(best) < 192 do
            best = best - 1
        end
        if best > 0 then
            local b = text:byte(best)
            if b >= 194 and b <= 244 then
                best = best - 1
            end
        end
        return text:sub(1, best) .. ".."
    end

    return ".."
end

-- Форматирование здоровья (K/M)
function FormatHealth(v, shorten)
    if not v then return "" end
    if not shorten then return tostring(v) end

    if v >= 1e6 then
        return string.format("%.1fM", v / 1e6)
    elseif v >= 1e3 then
        return string.format("%.1fk", v / 1e3)
    else
        return tostring(v)
    end
end

-- Установка текста с кэшированием позиции
function SetTextST(obj, font, size, flags, anchor, anchorFrame, relAnchor, x, y, alpha, text, color)
    if not obj then return end

    -- Конвертация "NONE" в "" для совместимости с WoW API
    if flags == "NONE" then flags = "" end

    obj:SetFont(font, size, flags)
    if text then obj:SetText(text) end
    if color then obj:SetTextColor(unpack(color)) end

    if obj.lastAnchor ~= anchor or obj.lastRelAnchor ~= relAnchor or obj.lastX ~= x or obj.lastY ~= y or obj.lastParent ~= anchorFrame then
        obj:ClearAllPoints()
        obj:SetPoint(anchor, anchorFrame, relAnchor, x, y)
        obj.lastAnchor = anchor
        obj.lastRelAnchor = relAnchor
        obj.lastX = x
        obj.lastY = y
        obj.lastParent = anchorFrame
    end

    obj:SetAlpha(alpha)
    obj:Show()
end

-- Установка иконки с кэшированием позиции
function SetIconST(obj, path, w, h, anchor, anchorFrame, relAnchor, x, y, alpha)
    if not obj then return end

    obj:SetTexture(path)
    obj:SetSize(w, h)

    if obj.lastAnchor ~= anchor or obj.lastRelAnchor ~= relAnchor or obj.lastX ~= x or obj.lastY ~= y or obj.lastParent ~= anchorFrame then
        obj:ClearAllPoints()
        obj:SetPoint(anchor, anchorFrame, relAnchor, x, y)
        obj.lastAnchor = anchor
        obj.lastRelAnchor = relAnchor
        obj.lastX = x
        obj.lastY = y
        obj.lastParent = anchorFrame
    end

    obj:SetAlpha(alpha)
    obj:Show()
end

-- Переиспользуемая таблица для данных юнита
local dataCache = {}

-- Сбор данных о юните
function GetUnitData(frame)
    local unit = frame.unit or (frame.UnitFrame and frame.UnitFrame.unit)
    if not unit or not UnitExists(unit) then return nil end

    local guid = UnitGUID(unit)
    local reaction = UnitReaction("player", unit)
    local isFriend = reaction and reaction > 4
    if UnitIsUnit("player", unit) then isFriend = true end
    local unitName = GetUnitName(unit, false) or ""
    local cvar = tonumber(GetCVar("nameplateShowOnlyNames")) or 0
    local isPlayer = UnitIsPlayer(unit)
    local cleanName = unitName:gsub("%s+[IVXLCDM]+%s*$", "")
    local isPet = UnitIsPetByGUID(guid)
    local alpha = frame:GetAlpha()

    local totemData = not isPlayer and totemIcons[cleanName]
    local isTotemIcon = totemData and totemData.status

    -- Переиспользуем таблицу
    local data = dataCache
    data.unit = unit
    data.guid = guid
    data.alpha = alpha
    data.isPlayer = isPlayer
    data.isFriend = isFriend
    data.unitName = unitName
    data.isOnlyNameMode = (cvar == 3) or (cvar == 1 and isFriend) or (cvar == 2 and not isFriend)
    data.cleanName = cleanName
    data.totemData = totemData
    data.isTotemIcon = isTotemIcon
    data.isPet = isPet
    return data
end

-- Безопасное распаковывание цвета с fallback (используется в Border.lua, CastBar.lua и др.)
function safeUnpackColor(color, defaultR, defaultG, defaultB, defaultA)
    if color and #color >= 3 then
        return { color[1], color[2], color[3], color[4] or 1 }
    end
    return { defaultR or 1, defaultG or 1, defaultB or 1, defaultA or 1 }
end