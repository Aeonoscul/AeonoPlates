--[[
    modules/Border.lua — AeonoPlates
    Кастомная граница с цветами: target, mouseover, combat, default.
    Всегда видна (показывается с нейтральным цветом, если ничего не применилось).
    
    Оптимизации:
    - Кэширование backdrop: пересоздаётся только при смене текстуры/размеров
    - Кэширование цветов: распаковываются один раз при смене профиля
    - Разделение обновления геометрии (тяжёлое) и цвета (лёгкое)
]]

local _cachedBorderColors = {}

function RefreshBorderColorCache(db)
    _cachedBorderColors.targetColor    = safeUnpackColor(db.borderTargetColor, 1, 1, 1, 1)
    _cachedBorderColors.mouseoverColor = safeUnpackColor(db.borderMouseoverColor, 1, 1, 1, 1)
    _cachedBorderColors.combatColor    = safeUnpackColor(db.borderCombatColor, 1, 0.5, 0, 1)
    _cachedBorderColors.defaultColor   = safeUnpackColor(db.borderDefaultColor, 0.3, 0.3, 0.3, 1)
end

function UpdateBorderGeometry(frame, db)
    local tex = db.borderTexture or "Interface\\Buttons\\WHITE8X8"
    local edge = db.borderPadding or 4
    local size = db.borderThickness or 8

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

function UpdateCustomBorder(frame, data, db)
    if not frame.healthBar then return end

    if not frame.customBorder then
        frame.customBorder = CreateFrame("Frame", nil, frame)
        frame._lastBorderTex = nil
    end

    local nativeBorder = frame.healthBar.border
    if nativeBorder then
        frame.customBorder:SetFrameLevel(nativeBorder:GetFrameLevel())
    else
        frame.customBorder:SetFrameLevel(frame.healthBar:GetFrameLevel() + 1)
    end

    UpdateBorderGeometry(frame, db)

    if data.isTotemIcon or data.isOnlyNameMode then
        frame.customBorder:Hide()
        return
    end

    if not _cachedBorderColors.targetColor then
        RefreshBorderColorCache(db)
    end

    local colors = _cachedBorderColors
    local isTarget = UnitIsUnit(data.unit, "target")
    local isMouseover = UnitIsUnit(data.unit, "mouseover")
    local inCombat = UnitAffectingCombat(data.unit)

    -- Приоритет 1: Цель
    if isTarget then
        frame.customBorder:SetBackdropBorderColor(colors.targetColor[1], colors.targetColor[2], colors.targetColor[3], colors.targetColor[4])
        frame.customBorder:Show()
    -- Приоритет 2: Mouseover (только если не равен цели)
    elseif isMouseover and not isTarget then
        frame.customBorder:SetBackdropBorderColor(colors.mouseoverColor[1], colors.mouseoverColor[2], colors.mouseoverColor[3], colors.mouseoverColor[4])
        frame.customBorder:Show()
    -- Приоритет 3: Юнит в бою
    elseif inCombat then
        frame.customBorder:SetBackdropBorderColor(colors.combatColor[1], colors.combatColor[2], colors.combatColor[3], colors.combatColor[4])
        frame.customBorder:Show()
    -- Приоритет 4: Default — всегда показываем с нейтральным цветом
    else
        frame.customBorder:SetBackdropBorderColor(colors.defaultColor[1], colors.defaultColor[2], colors.defaultColor[3], colors.defaultColor[4])
        frame.customBorder:Show()
    end
end