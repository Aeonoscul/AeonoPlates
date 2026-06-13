--[[
    modules/Health.lua — AeonoPlates
    Настройки здоровья: текстура бара, текст HP, процент HP
]]

-- Обновление текстуры статус-бара
function UpdateHealthBarTexture(frame, data, db)
    if not frame.healthBar then
        return
    end

    if data.isTotemIcon or data.isOnlyNameMode then
        frame.healthBar:SetAlpha(0)
    else
        frame.healthBar:SetAlpha(1)
        frame.healthBar:Show()

        if frame.healthBar.Background then
            frame.healthBar.Background:SetAlpha(1)
            frame.healthBar.Background:Show()
        end

        -- Кэшируем текстуру
        if frame.lastBarTex ~= db.healthTexture then
            local tex = frame.healthBar:GetStatusBarTexture()
            if tex then
                frame.healthBar:SetStatusBarTexture(db.healthTexture)
                frame.lastBarTex = db.healthTexture
            end
        end
    end
end

-- Обновление текста здоровья
function UpdateHealthValueText(frame, data, db)
    if not frame.healthBar or data.isOnlyNameMode or data.isTotemIcon then
        if frame.healthText then frame.healthText:Hide() end
        return
    end

    local parent = frame.healthBar:IsShown() and frame.healthBar.overlay or frame

    if not frame.healthText then
        frame.healthText = parent:CreateFontString(nil, "BACKGROUND")
        frame.healthText:SetTextColor(1, 1, 1)
        -- Устанавливаем дефолтный шрифт, чтобы избежать "Font not set"
        frame.healthText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    end

    if frame.healthText:GetParent() ~= parent then
        frame.healthText:SetParent(parent)
    end

    SetTextST(frame.healthText, db.healthFont, db.healthSize, db.healthFlags, db.healthAnchor, parent, db.healthRelAnchor, db.healthOffsetX, db.healthOffsetY, data.alpha)
end

-- Обновление процента здоровья
function UpdateHealthPercText(frame, data, db)
    if not frame.healthBar or data.isOnlyNameMode or data.isTotemIcon then
        if frame.percText then frame.percText:Hide() end
        return
    end

    local parent = frame.healthBar:IsShown() and frame.healthBar.overlay or frame.healthBar

    if not frame.percText then
        frame.percText = parent:CreateFontString(nil, "BACKGROUND")
        frame.percText:SetTextColor(1, 1, 1)
        -- Дефолтный шрифт, чтобы избежать "Font not set"
        frame.percText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    end

    if frame.percText:GetParent() ~= parent then
        frame.percText:SetParent(parent)
    end

    SetTextST(frame.percText, db.healthFont, db.healthPercentSize, db.healthFlags, db.healthPercentAnchor, parent, db.healthPercentRelAnchor, db.healthPercentOffsetX, db.healthPercentOffsetY, data.alpha)
end

-- Обновление значений здоровья (вызывается из UNIT_COMBAT и UpdateStyle)
function UpdateHealthValues(frame, unit, db)
    if not frame or not unit or UnitIsUnit(unit, "player") then return end

    if not db.showHealthText and not db.showHealthPercent then return end

    local hp, max = UnitHealth(unit), UnitHealthMax(unit)

    if db.showHealthText then
        local str = FormatHealth(hp, db.shortenHealth)
        if frame.healthText then
            frame.healthText:SetText(str)
        end
    elseif frame.healthText then
        frame.healthText:SetText("")
    end

    if db.showHealthPercent and max > 0 then
        local pct = string.format("%d%%", math.floor((hp / max) * 100))
        if frame.percText then
            frame.percText:SetText(pct)
        end
    elseif frame.percText then
        frame.percText:SetText("")
    end
end