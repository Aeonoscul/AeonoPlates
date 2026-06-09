--[[
    modules/Border.lua — AeonoPlates
    Кастомная граница с цветами: target, mouseover, combat, default.
    Всегда видна (показывается с нейтральным цветом, если ничего не применилось).
    
    Оптимизации:
    - Кэширование backdrop: пересоздаётся только при смене текстуры/размеров
    - Кэширование цветов: распаковываются один раз при смене профиля
    - Разделение обновления геометрии (тяжёлое) и цвета (лёгкое)
]]

-- Кэшированные распакованные цвета границы (обновляются при смене профиля)
local _cachedBorderColors = {}

-- Обновление кэша цветов границы (вызывается при смене профиля)
function RefreshBorderColorCache(db)
    _cachedBorderColors.targetColor    = safeUnpackColor(db.borderTargetColor, 1, 1, 1, 1)
    _cachedBorderColors.mouseoverColor = safeUnpackColor(db.borderMouseoverColor, 1, 1, 1, 1)
    _cachedBorderColors.combatColor    = safeUnpackColor(db.borderCombatColor, 1, 0.5, 0, 1)
    _cachedBorderColors.defaultColor   = safeUnpackColor(db.borderDefaultColor, 0.3, 0.3, 0.3, 1)
end

-- Обновление геометрии border (backdrop + позиция) — только при изменении настроек
local function UpdateBorderGeometry(frame, db)
    local tex = db.borderTexture or "Interface\\Buttons\\WHITE8X8"
    local edge = db.borderPadding or 4
    local size = db.borderThickness or 8

    -- Кэшируем параметры геометрии на фрейме
    if frame._lastBorderTex ~= tex or frame._lastBorderEdge ~= edge or frame._lastBorderSize ~= size then
        frame._lastBorderTex = tex
        frame._lastBorderEdge = edge
        frame._lastBorderSize = size

        frame.customBorder:ClearAllPoints()
        frame.customBorder:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", -size, size)
        frame.customBorder:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", size, -size)

        frame.customBorder:SetBackdrop({
            edgeFile = tex,
            edgeSize = edge,
            bgFile = nil,
            tile = false,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
    end
end

-- Обновление кастомной границы
function UpdateCustomBorder(frame, data, db)
    if not frame.healthBar then return end

    -- Создаём border один раз
    if not frame.customBorder then
        frame.customBorder = CreateFrame("Frame", nil, frame)
        -- Инициализируем кэш геометрии как nil, чтобы принудительно создать backdrop
        frame._lastBorderTex = nil
    end

    -- Обновляем frame level (лёгкая операция)
    local nativeBorder = frame.healthBar.border
    if nativeBorder then
        frame.customBorder:SetFrameLevel(nativeBorder:GetFrameLevel())
    else
        frame.customBorder:SetFrameLevel(frame.healthBar:GetFrameLevel() + 1)
    end

    -- Обновляем геометрию только при изменении настроек
    UpdateBorderGeometry(frame, db)

    -- Скрываем для тотемов и режима только-имя
    if data.isTotemIcon or data.isOnlyNameMode then
        frame.customBorder:Hide()
        return
    end

    -- Обновляем кэш цветов, если ещё не инициализирован
    if not _cachedBorderColors.targetColor then
        RefreshBorderColorCache(db)
    end

    local colors = _cachedBorderColors
    local isTarget = UnitIsUnit(data.unit, "target")
    local isMouseover = UnitIsUnit(data.unit, "mouseover")

    -- Приоритет 1: Цель
    if isTarget then
        frame.customBorder:SetBackdropBorderColor(colors.targetColor[1], colors.targetColor[2], colors.targetColor[3], colors.targetColor[4])
        frame.customBorder:Show()
        return
    end

    -- Приоритет 2: Mouseover (только если не равен цели)
    if isMouseover and not isTarget then
        frame.customBorder:SetBackdropBorderColor(colors.mouseoverColor[1], colors.mouseoverColor[2], colors.mouseoverColor[3], colors.mouseoverColor[4])
        frame.customBorder:Show()
        return
    end

    -- Приоритет 3: Юнит в бою
    if UnitAffectingCombat(data.unit) then
        frame.customBorder:SetBackdropBorderColor(colors.combatColor[1], colors.combatColor[2], colors.combatColor[3], colors.combatColor[4])
        frame.customBorder:Show()
        return
    end

    -- Приоритет 4: Default — всегда показываем с нейтральным цветом
    frame.customBorder:SetBackdropBorderColor(colors.defaultColor[1], colors.defaultColor[2], colors.defaultColor[3], colors.defaultColor[4])
    frame.customBorder:Show()
end