--[[
    modules/Threat.lua — AeonoPlates
    Индикация угрозы (триты) через цвет полосы здоровья.
    Использует родной healthBar:SetStatusBarColor().
    Сохраняет оригинальный цвет бара для восстановления.
    Не применяется к игрокам, тотемам и режиму только-имя.
]] function UpdateThreatIndicator(frame, data, db)
    if not frame.healthBar then
        return
    end

    -- Не применяем к игрокам, тотемам и режиму только-имя
    if data.isPlayer or data.isTotemIcon or data.isOnlyNameMode then
        return
    end

    local threat = UnitThreatSituation("player", data.unit)

    if threat then
        -- Сохраняем оригинальный цвет перед первым изменением
        if not frame._origBarColor then
            local r, g, b = frame.healthBar:GetStatusBarColor()
            frame._origBarColor = {r, g, b}
        end

        local color
        if threat == 3 then
            -- Агро на нас (танкуем)
            color = safeUnpackColor(db.threatHighColor, 0, 1, 0)
        elseif threat == 1 or threat == 2 then
            -- Скоро потеряем агро
            color = safeUnpackColor(db.threatAggroColor, 1, 1, 0)
        else
            -- threat == 0, не в агро-листе
            color = safeUnpackColor(db.threatLowColor, 1, 0, 0)
        end
        frame.healthBar:SetStatusBarColor(color[1], color[2], color[3], color[4])
    else
        -- Угрозы нет — восстанавливаем оригинальный цвет, если он был сохранён
        if frame._origBarColor then
            frame.healthBar:SetStatusBarColor(frame._origBarColor[1], frame._origBarColor[2], frame._origBarColor[3])
            frame._origBarColor = nil
        end
    end
end
