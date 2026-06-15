--[[
    shared.lua — AeonoPlates
    Общие утилиты: вспомогательные функции, GetUnitData
    Загружается перед модулями и core.lua
]] -- Глобальные таблицы иконок (используются в GetUnitData и модулях)

defaults = {
    profile = {
        -- ============================================
        -- NAME SETTINGS
        -- ============================================
        nameFont = "Fonts\\FRIZQT__.TTF",
        nameFlags = "OUTLINE",
        nameWidth = 140,
        nameFriendlyPlayerSize = 20,
        nameEnemyPlayerSize = 16,
        nameFriendlyNpcSize = 18,
        nameEnemyNpcSize = 14,
        nameAnchor = "BOTTOM",
        nameRelAnchor = "TOP",
        nameOffsetX = 0,
        nameOffsetY = 2,
        onlyNameAnchor = "CENTER",
        onlyNameOffsetX = 0,
        onlyNameOffsetY = 0,
        onlyNameWidth = 120,

        -- ============================================
        -- HEALTH SETTINGS
        -- ============================================
        healthTexture = "Interface\\TargetingFrame\\UI-StatusBar",
        showHealthText = true,
        showHealthPercent = true,
        shortenHealth = true,
        healthFont = "Fonts\\FRIZQT__.TTF",
        healthSize = 14,
        healthFlags = "OUTLINE",
        healthAnchor = "CENTER",
        healthRelAnchor = "CENTER",
        healthOffsetX = 0,
        healthOffsetY = 0,
        healthPercentSize = 12,
        healthPercentAnchor = "RIGHT",
        healthPercentRelAnchor = "RIGHT",
        healthPercentOffsetX = -2,
        healthPercentOffsetY = 0,

        -- ============================================
        -- ICON SETTINGS
        -- ============================================
        showEnemyClassIcons = false,
        showFriendlyClassIcons = true,
        showEnemyTotemIcons = true,
        showFriendlyTotemIcons = true,
        iconSize = 40,
        totemIconSize = 30,
        iconAnchor = "BOTTOM",
        iconRelAnchor = "TOP",
        iconOffsetX = 0,
        iconOffsetY = 0,

        -- ============================================
        -- BORDER SETTINGS
        -- ============================================
        borderTexture = "Interface\\Buttons\\WHITE8X8",
        borderPadding = 1,
        borderThickness = 1,
        borderTargetColor = {1, 1, 1, 1},
        borderMouseoverColor = {0, 1, 1, 1},
        borderCombatColor = {1, 0, 0, 1},
        borderDefaultColor = {0, 0, 0, 1},

        -- ============================================
        -- THREAT SETTINGS
        -- ============================================
        threatHighColor = {0, 1, 0, 1},
        threatLowColor = {1, 0, 0, 1},
        threatAggroColor = {1, 1, 0, 1},

        -- ============================================
        -- CLASSIFICATION
        -- ============================================
        showClassification = true,
        classificationSize = 30,
        classificationAnchor = "RIGHT",
        classificationRelAnchor = "LEFT",
        classificationOffsetX = -5,
        classificationOffsetY = 0,

        -- ============================================
        -- RAID TARGET
        -- ============================================
        raidTargetAnchor = "LEFT",
        raidTargetRelAnchor = "RIGHT",
        raidTargetScale = 1.25,
        raidTargetOffsetX = 2,
        raidTargetOffsetY = 0,

        -- ============================================
        -- SCALE SETTINGS
        -- ============================================
        petFrameScale = 0.8,

        -- ============================================
        -- CASTBAR SETTINGS
        -- ============================================
        friendlyPlayerCastBar = true,
        enemyPlayerCastBar = true,
        friendlyNpcCastBar = false,
        enemyNpcCastBar = true,
        castBarTex = "Interface\\TargetingFrame\\UI-StatusBar",
        castBarFadeTime = 0.5,
        castBarHeight = 16,
        castBarWidth = 120,
        castBarShowIcon = true,
        castBarIconSide = "LEFT",
        castBarIconOffsetX = 0,
        castBarIconOffsetY = 0,
        castBarAnchor = "TOP",
        castBarRelativePoint = "BOTTOM",
        castBarOffsetX = 0,
        castBarOffsetY = -3,
        castBarColor = {1, 1, 0, 1},
        castBarSuccessColor = {0, 1, 0, 1},
        castBarFailedColor = {1, 0, 0, 1},
        castBarShieldColor = {0.5, 0.5, 1, 1},
        castBarBgColor = {0, 0, 0, 0.5},
        castNameFont = "Fonts\\FRIZQT__.TTF",
        castNameSize = 10,
        castNameWidth = 100,
        castNameFlags = "OUTLINE",
        castNameColor = {1, 1, 1, 1},
        castNameOffsetX = 0,
        castNameOffsetY = 0,
        castBarSparkWidth = 20,
        castBarSparkHeightMultiplier = 2
    }
}

totemIcons = {
    -- Земля
    ["Тотем каменной кожи"] = {
        status = true,
        icon = "Stoneskin Totem"
    },
    ["Тотем силы Земли"] = {
        status = true,
        icon = "Strength of Earth Totem"
    },
    ["Тотем каменного когтя"] = {
        status = true,
        icon = "Stoneclaw Totem"
    },
    ["Тотем оков земли"] = {
        status = true,
        icon = "Earthbind Totem"
    },
    ["Тотем элементаля земли"] = {
        status = true,
        icon = "Earth Elemental Totem"
    },
    ["Тотем трепета"] = {
        status = true,
        icon = "Tremor Totem"
    },

    -- Огонь
    ["Опаляющий тотем"] = {
        status = true,
        icon = "Searing Totem"
    },
    ["Тотем магмы"] = {
        status = true,
        icon = "Magma Totem"
    },
    ["Тотем языка пламени"] = {
        status = true,
        icon = "Flametongue Totem"
    },
    ["Тотем элементаля огня"] = {
        status = true,
        icon = "Fire Elemental Totem"
    },
    ["Тотем гнева"] = {
        status = true,
        icon = "Totem of Wrath"
    },
    ["Тотем защиты от магии льда"] = {
        status = true,
        icon = "Frost Resistance Totem"
    },

    -- Вода
    ["Тотем исцеляющего потока"] = {
        status = true,
        icon = "Healing Stream Totem"
    },
    ["Тотем источника маны"] = {
        status = true,
        icon = "Mana Spring Totem"
    },
    ["Тотем очищения"] = {
        status = true,
        icon = "Disease Cleansing Totem"
    },
    ["Тотем защиты от магии огня"] = {
        status = true,
        icon = "Fire Resistance Totem"
    },
    ["Тотем прилива маны"] = {
        status = true,
        icon = "Mana Tide Totem"
    },

    -- Воздух
    ["Тотем неистовства ветра"] = {
        status = true,
        icon = "Windfury Totem"
    },
    ["Тотем гнева воздуха"] = {
        status = true,
        icon = "Wrath of Air Totem"
    },
    ["Тотем заземления"] = {
        status = true,
        icon = "Grounding Totem"
    },
    ["Тотем защиты от сил природы"] = {
        status = true,
        icon = "Nature Resistance Totem"
    },
    ["Сторожевой тотем"] = {
        status = true,
        icon = "Sentry Totem"
    },

    -- misc
    ["Восставший союзник"] = {
        status = true,
        icon = "Undead Army"
    },
    ["Кровавый червь"] = {
        status = true,
        icon = "Bloodworm"
    },
    ["Войско мертвых"] = {
        status = true,
        icon = "Undead Army"
    },
    ["Ядовитая змея"] = {
        status = true,
        icon = "Snakes"
    },
    ["Гадюка"] = {
        status = true,
        icon = "Snakes"
    },
    ["Древень"] = {
        status = true,
        icon = "Treant"
    },
    ["Страж Ужаса"] = {
        status = true,
        icon = "Doomguard"
    },
    ["Зловредный бес"] = {
        status = true,
        icon = "Malicious Imp"
    }
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
    ["EVOKER"] = "EVOKER"
}

-- 3. ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ

-- ИНИЦИАЛИЗАЦИЯ LSM — конвертация имён в пути
function InitLSM()
    local LSM = LibStub("LibSharedMedia-3.0", true)
    if not LSM then
        return
    end

    local db = AeonoPlates.db.profile

    -- Если в db.profile хранится имя (не путь), конвертируем в путь
    if db.nameFont and not db.nameFont:find("\\") and not db.nameFont:find("/") then
        local path = LSM:Fetch("font", db.nameFont)
        if path then
            db.nameFont = path
        end
    end

    if db.healthFont and not db.healthFont:find("\\") and not db.healthFont:find("/") then
        local path = LSM:Fetch("font", db.healthFont)
        if path then
            db.healthFont = path
        end
    end

    if db.healthTexture and not db.healthTexture:find("\\") and not db.healthTexture:find("/") then
        local path = LSM:Fetch("statusbar", db.healthTexture)
        if path then
            db.healthTexture = path
        end
    end

    if db.borderTexture and not db.borderTexture:find("\\") and not db.borderTexture:find("/") then
        local path = LSM:Fetch("border", db.borderTexture)
        if path then
            db.borderTexture = path
        end
    end

    -- Конвертация настроек кастбара
    if db.castBarTex and not db.castBarTex:find("\\") and not db.castBarTex:find("/") then
        local path = LSM:Fetch("statusbar", db.castBarTex)
        if path then
            db.castBarTex = path
        end
    end

    if db.castNameFont and not db.castNameFont:find("\\") and not db.castNameFont:find("/") then
        local path = LSM:Fetch("font", db.castNameFont)
        if path then
            db.castNameFont = path
        end
    end
end

-- Измерялка ширины текста (один на весь аддон)
local measurer = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")

-- Определение пета по GUID
function UnitIsPetByGUID(guid)
    if not guid then
        return false
    end

    local charType = guid:sub(5, 5)
    local byteType = tonumber(charType, 16)
    if not byteType then
        return false
    end

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
    if not v then
        return ""
    end
    if not shorten then
        return tostring(v)
    end

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
    if not obj then
        return
    end

    -- Конвертация "NONE" в "" для совместимости с WoW API
    if flags == "NONE" then
        flags = ""
    end

    obj:SetFont(font, size, flags)
    if text then
        obj:SetText(text)
    end
    if color then
        obj:SetTextColor(unpack(color))
    end

    if obj.lastAnchor ~= anchor or obj.lastRelAnchor ~= relAnchor or obj.lastX ~= x or obj.lastY ~= y or obj.lastParent ~=
        anchorFrame then
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
    if not obj then
        return
    end

    obj:SetTexture(path)
    obj:SetSize(w, h)

    if obj.lastAnchor ~= anchor or obj.lastRelAnchor ~= relAnchor or obj.lastX ~= x or obj.lastY ~= y or obj.lastParent ~=
        anchorFrame then
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
    if not unit or not UnitExists(unit) then
        return nil
    end

    local guid = UnitGUID(unit)
    local reaction = UnitReaction("player", unit)
    local isFriend = reaction and reaction > 4
    if UnitIsUnit("player", unit) then
        isFriend = true
    end
    local unitName = frame and UnitName(unit) or ""
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
        return {color[1], color[2], color[3], color[4] or 1}
    end
    return {defaultR or 1, defaultG or 1, defaultB or 1, defaultA or 1}
end
