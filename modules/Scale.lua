--[[
    modules/Scale.lua — AeonoPlates
    Масштаб фреймов (петы)
]]

function UpdateFrameScale(frame, data, db)
    if not frame.unit or UnitIsUnit(frame.unit, "player") then return end

    if frame.unit ~= data.unit then return end

    if frame.lastScaledGUID and (frame.lastScaledGUID ~= data.guid or not data.isPet) then
        frame:SetScale(1.0)
        frame.lastScaledGUID = nil
    end

    if not data.isOnlyNameMode and data.isPet and (frame.lastScaledGUID ~= data.guid) then
        frame:SetScale(db.petFrameScale)
        frame.lastScaledGUID = data.guid
    end
end