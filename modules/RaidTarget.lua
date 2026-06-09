--[[
    modules/RaidTarget.lua — AeonoPlates
    Рейдовая метка: позиционирование и масштаб
]]

function UpdateRaidTarget(frame, data, db)
    if not frame.RaidTargetFrame then
        return
    end

    local parent
    if data.isOnlyNameMode and frame.customName then
        parent = frame.customName
    else
        parent = frame
    end
    local rtf = frame.RaidTargetFrame

    -- Кэшируем позицию
    if rtf.lastAnchor ~= db.raidTargetAnchor or rtf.lastRelAnchor ~= db.raidTargetRelAnchor or rtf.lastParent ~= parent or rtf.lastX ~= db.raidTargetOffsetX or rtf.lastY ~= db.raidTargetOffsetY then
        rtf:ClearAllPoints()
        rtf:SetPoint(db.raidTargetAnchor, parent, db.raidTargetRelAnchor, db.raidTargetOffsetX, db.raidTargetOffsetY)
        rtf.lastAnchor = db.raidTargetAnchor
        rtf.lastRelAnchor = db.raidTargetRelAnchor
        rtf.lastParent = parent
        rtf.lastX = db.raidTargetOffsetX
        rtf.lastY = db.raidTargetOffsetY
    end

    rtf:SetScale(db.raidTargetScale)
    rtf:SetAlpha(data.alpha)
end