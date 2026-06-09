--[[
    modules/Classification.lua — AeonoPlates
    Индикатор классификации (элита, рар и т.д.)
]]

function UpdateClassification(frame, data, db)
    local ci = frame.classificationIndicator or (frame.UnitFrame and frame.UnitFrame.classificationIndicator)
    if not ci then
        return
    end

    local isElite = (UnitClassification(data.unit) ~= "normal")
    if db.showClassification and isElite and not data.isTotemIcon and not data.isOnlyNameMode then
        local parent
        if data.isOnlyNameMode and frame.customName then
            parent = frame.customName
        else
            parent = frame.healthBar and frame.healthBar.overlay or frame
        end

        SetIconST(ci, ci:GetTexture(), db.classificationSize, db.classificationSize, db.classificationAnchor, parent, db.classificationRelAnchor, db.classificationOffsetX, db.classificationOffsetY, data.alpha)
    else
        ci:Hide()
    end
end