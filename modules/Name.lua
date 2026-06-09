--[[
    modules/Name.lua — AeonoPlates
    Настройки имени: кастомное имя, скрытие оригинального
]]

-- Скрытие оригинального имени неймплейта
function HideName(frame)
    local unit = frame.unit or frame.displayedUnit or (frame.UnitFrame and frame.UnitFrame.unit)
    if unit and unit:find("nameplate") then
        local name = frame.name or (frame.UnitFrame and frame.UnitFrame.name)
        if name then
            name:Hide()
        end
    end
end

-- Обновление кастомного имени
function UpdateNameText(frame, data, db)
    if data.isTotemIcon then
        if frame.customName then
            frame.customName:Hide()
        end
        return
    end

    local size = data.isPlayer and (data.isFriend and db.nameFriendlyPlayerSize or db.nameEnemyPlayerSize)
                or (data.isFriend and db.nameFriendlyNpcSize or db.nameEnemyNpcSize)
    local maxWidth = data.isOnlyNameMode and db.onlyNameWidth or (db.nameWidth or 100)

    -- Кэшируем результат SmartTruncate для статичных имён
    local nameCacheKey = data.unitName .. "|" .. maxWidth .. "|" .. size .. "|" .. db.nameFlags
    if frame.lastNameCache ~= nameCacheKey then
        frame.lastNameResult = SmartTruncate(data.unitName, maxWidth, db.nameFont, size, db.nameFlags)
        frame.lastNameCache = nameCacheKey
    end
    local finalName = frame.lastNameResult

    local parent = (not data.isOnlyNameMode and frame.healthBar and frame.healthBar:IsShown()) and frame.healthBar.overlay or frame

    if not frame.customName then
        frame.customName = parent:CreateFontString(nil, "BACKGROUND")
    end

    if frame.customName:GetParent() ~= parent then
        frame.customName:SetParent(parent)
    end

    local anchor = data.isOnlyNameMode and db.onlyNameAnchor or db.nameAnchor
    local rel = data.isOnlyNameMode and db.onlyNameAnchor or db.nameRelAnchor
    local x = data.isOnlyNameMode and db.onlyNameOffsetX or db.nameOffsetX
    local y = data.isOnlyNameMode and db.onlyNameOffsetY or db.nameOffsetY
    local alpha = data.alpha or 1

    local r, g, b, a
    if frame.name then
        r, g, b, a = frame.name:GetTextColor()
    else
        r, g, b, a = 1, 1, 1, 1
    end
    if not data.isOnlyNameMode then
        r, g, b = 1, 1, 1
    end

    SetTextST(frame.customName, db.nameFont, size, db.nameFlags, anchor, parent, rel, x, y, alpha, finalName, { r, g, b, a })
    frame.customName:Show()
end