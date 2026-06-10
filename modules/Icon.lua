--[[
    modules/Icon.lua — AeonoPlates
    Иконки классов и тотемов
]]

local ADDON_PATH = "Interface\\Addons\\AeonoPlates\\media\\"

-- Обновление иконки юнита (класс/тотем)
function UpdateUnitIcon(frame, data, db)
    local isTotemIcon = data.isTotemIcon
    local isPlayer = data.isPlayer
    local isFriend = data.isFriend
    local alpha = data.alpha
    local totemData = data.totemData
    local curIconSize = isTotemIcon and db.totemIconSize or db.iconSize

    local iconPath = nil
    if isTotemIcon then
        iconPath = ADDON_PATH .. "Totems\\" .. totemData.icon
    elseif isPlayer and ((isFriend and db.showFriendlyClassIcons) or (not isFriend and db.showEnemyClassIcons)) then
        local _, classTag = UnitClass(data.unit)
        if classTag and classIcons[classTag] then
            iconPath = ADDON_PATH .. "ClassIcons\\" .. classIcons[classTag]
        end
    end

    if iconPath then
        local parent = frame

        if not frame.classIcon then
            frame.classIcon = parent:CreateTexture(nil, "BACKGROUND")
        end

        if frame.classIcon:GetParent() ~= parent then
            frame.classIcon:SetParent(parent)
        end

        local anchor = isTotemIcon and "CENTER" or db.iconAnchor
        local relAnchor = isTotemIcon and "CENTER" or db.iconRelAnchor

        local x = isTotemIcon and 0 or db.iconOffsetX
        local y = isTotemIcon and 5 or db.iconOffsetY

        SetIconST(frame.classIcon, iconPath, curIconSize, curIconSize, anchor, parent, relAnchor, x, y, alpha)
    elseif frame.classIcon then
        frame.classIcon:Hide()
    end
end