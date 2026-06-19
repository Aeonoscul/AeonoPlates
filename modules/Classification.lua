function UpdateClassification(frame, data, db)
    local ci = frame.classificationIndicator or (frame.UnitFrame and frame.UnitFrame.classificationIndicator)
    if db.showClassification and data.isElite and not data.isFriend and not data.isTotemIcon and not data.isOnlyNameMode then
        local parent
        if data.isOnlyNameMode and frame.customName then
            parent = frame.customName
        else
            parent = frame
        end
        SetIconST(ci, ci:GetTexture(), db.classificationSize, db.classificationSize, db.classificationAnchor, parent,
            db.classificationRelAnchor, db.classificationOffsetX, db.classificationOffsetY)
        ci:Show()
    else
        ci:Hide()
    end
end
