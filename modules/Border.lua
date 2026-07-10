local _cachedBorderColors = {}

function RefreshBorderColorCache(db)
    _cachedBorderColors.targetColor = safeUnpackColor(db.borderTargetColor, 1, 1, 1, 1)
    _cachedBorderColors.mouseoverColor = safeUnpackColor(db.borderMouseoverColor, 1, 1, 1, 1)
    _cachedBorderColors.combatColor = safeUnpackColor(db.borderCombatColor, 1, 0.5, 0, 1)
    _cachedBorderColors.defaultColor = safeUnpackColor(db.borderDefaultColor, 0.3, 0.3, 0.3, 1)
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
            insets = {
                left = 0,
                right = 0,
                top = 0,
                bottom = 0
            }
        })
    end
end

function UpdateCustomBorder(frame, data, db)
    if not frame.healthBar then
        return
    end

    if not frame.customBorder then
        frame.customBorder = CreateFrame("Frame", nil, frame)
        frame._lastBorderTex = nil
        -- Граница не должна перекрывать другие фреймы → уровень 0
        frame.customBorder:SetFrameLevel(frame.healthBar:GetFrameLevel() + 1)
    else
        -- На случай, если уровень был изменён ранее (например, сменой профиля)
        frame.customBorder:SetFrameLevel(frame.healthBar:GetFrameLevel() + 1)
    end

    UpdateBorderGeometry(frame, db)

    if data.isOnlyNameMode or (data.isTotemIcon and not data.isFriend and db.showEnemyTotemIcons) or
        (data.isTotemIcon and data.isFriend and db.showFriendlyTotemIcons) then
        frame.customBorder:Hide()
        return
    end

    RefreshBorderColorCache(db)

    local colors = _cachedBorderColors
    local isTarget = UnitIsUnit(data.unit, "target")
    local isMouseover = UnitIsUnit(data.unit, "mouseover")
    local inCombat = UnitAffectingCombat(data.unit)

    -- Приоритет 1: Цель
    if isTarget then
        frame.customBorder:SetBackdropBorderColor(colors.targetColor[1], colors.targetColor[2], colors.targetColor[3],
            colors.targetColor[4])
        frame.customBorder:Show()
        -- Приоритет 2: Mouseover (только если не равен цели)

    elseif isMouseover and not isTarget then
        frame.customBorder:SetBackdropBorderColor(colors.mouseoverColor[1], colors.mouseoverColor[2],
            colors.mouseoverColor[3], colors.mouseoverColor[4])
        frame.customBorder:Show()
        -- Приоритет 3: Юнит в бою

    elseif inCombat then
        frame.customBorder:SetBackdropBorderColor(colors.combatColor[1], colors.combatColor[2], colors.combatColor[3],
            colors.combatColor[4])
        frame.customBorder:Show()
        -- Приоритет 4: Default — всегда показываем с нейтральным цветом
    else
        frame.customBorder:SetBackdropBorderColor(colors.defaultColor[1], colors.defaultColor[2],
            colors.defaultColor[3], colors.defaultColor[4])
        frame.customBorder:Show()
    end
end
