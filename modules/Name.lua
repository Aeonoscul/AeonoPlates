function UpdateNameText(frame, data, db)
    if (data.isTotemIcon and not data.isFriend and db.showEnemyTotemIcons) or
        (data.isTotemIcon and data.isFriend and db.showFriendlyTotemIcons) then
        if frame.customName then
            frame.customName:Hide()
        end
        return
    end

    local size = data.isPlayer and (data.isFriend and db.nameFriendlyPlayerSize or db.nameEnemyPlayerSize) or
                     (data.isFriend and db.nameFriendlyNpcSize or db.nameEnemyNpcSize)
    local maxWidth = data.isOnlyNameMode and db.onlyNameWidth or (db.nameWidth or 100)

    -- Кэшируем результат SmartTruncate для статичных имён
    local nameCacheKey = data.unitName .. "|" .. maxWidth .. "|" .. size .. "|" .. db.nameFlags
    if frame.lastNameCache ~= nameCacheKey then
        frame.lastNameResult = SmartTruncate(data.unitName, maxWidth, db.nameFont, size, db.nameFlags)
        frame.lastNameCache = nameCacheKey
    end
    local finalName = frame.lastNameResult

    local parent = (not data.isOnlyNameMode and frame.healthBar and frame.healthBar:IsShown()) and
                       frame.healthBar.overlay or frame

    if not frame.customName then
        frame.customName = parent:CreateFontString(nil, "BACKGROUND")
        frame.customName:SetDrawLayer("BACKGROUND", 7)
    end

    if frame.customName:GetParent() ~= parent then
        frame.customName:SetParent(parent)
    end

    local anchor = data.isOnlyNameMode and db.onlyNameAnchor or db.nameAnchor
    local rel = data.isOnlyNameMode and db.onlyNameAnchor or db.nameRelAnchor
    local x = data.isOnlyNameMode and db.onlyNameOffsetX or db.nameOffsetX
    local y = data.isOnlyNameMode and db.onlyNameOffsetY or db.nameOffsetY

    local r, g, b, a
    if not data.isOnlyNameMode then
        r, g, b, a = 1, 1, 1, 1
    elseif db.classColorEnemyNames and data.isPlayer and not data.isFriend and data.class then
        local color = RAID_CLASS_COLORS[data.class]
        if color then
            r, g, b, a = color.r, color.g, color.b, 1
        end
        if frame.name then
            r, g, b, a = frame.name:GetTextColor()
        end
    else
        if frame.name then
            r, g, b, a = frame.name:GetTextColor()
        end
    end

    SetTextST(frame.customName, db.nameFont, size, db.nameFlags, anchor, parent, rel, x, y, finalName, {r, g, b, a})
    frame.customName:Show()
end
