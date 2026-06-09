--[[
    modules/CastBar.lua — AeonoPlates
    Кастомный кастбар для неймплейтов
    Адаптировано из WeakAura-аддона "new/new — копия.lua"
]]

local activeBars = {}

-- Кэшированные распакованные цвета кастбара (избегаем safeUnpackColor в горячем пути)
local _cachedCastBarColors = {}

-- Обновление кэша цветов кастбара (вызывается при смене профиля)
function RefreshCastBarColorCache(db)
    _cachedCastBarColors.castBar    = safeUnpackColor(db.castBarColor, 1, 1, 1, 1)
    _cachedCastBarColors.successBar = safeUnpackColor(db.castBarSuccessColor, 0, 1, 0, 1)
    _cachedCastBarColors.failedBar  = safeUnpackColor(db.castBarFailedColor, 1, 0, 0, 1)
    _cachedCastBarColors.shieldBar  = safeUnpackColor(db.castBarShieldColor, 0.5, 0.5, 1, 1)
    _cachedCastBarColors.bgColor    = safeUnpackColor(db.castBarBgColor, 0, 0, 0, 0.5)
    _cachedCastBarColors.nameColor  = safeUnpackColor(db.castNameColor, 1, 1, 1, 1)
end

-- Применение цвета к статус-бару
local function ApplyColor(cb, colorTable)
    if not cb or not colorTable then return end
    cb:SetStatusBarColor(colorTable[1], colorTable[2], colorTable[3], colorTable[4])
    local tex = cb:GetStatusBarTexture()
    if tex and tex.SetVertexColor then
        tex:SetVertexColor(colorTable[1], colorTable[2], colorTable[3], colorTable[4])
    end
end

-- Обновление позиции кастбара (вызывается при создании и при изменении настроек)
-- Теперь позиционирует контейнер, внутри раскладывает иконку и кастбар
function UpdateCastBarPosition(cb, db)
    if not cb or not db then return end
    local hb = cb._healthBar
    if not hb then return end

    local container = cb.container
    if not container then return end

    -- Синхронизируем frame level контейнера с родителем (кастбар должен быть
    -- в той же иерархии, что и неймплейт, чтобы не перекрывать соседние фреймы)
    local parent = container:GetParent()
    if parent then
        container:SetFrameLevel(parent:GetFrameLevel() + 1)
    end

    local anchor = db.castBarAnchor or "CENTER"
    local relAnchor = db.castBarRelativePoint or "CENTER"
    local width = db.castBarWidth or 100
    local height = db.castBarHeight or 8
    local showIcon = db.castBarShowIcon
    local iconSide = db.castBarIconSide or "LEFT"
    local iconOffX = db.castBarIconOffsetX or 0
    local iconOffY = db.castBarIconOffsetY or 0

    -- Позиционируем контейнер относительно healthBar
    container:ClearAllPoints()
    container:SetPoint(anchor, hb, relAnchor, db.castBarOffsetX, db.castBarOffsetY)

    if showIcon then
        -- Иконка квадратная, размер = высота бара
        local iconSize = height

        if iconSide == "LEFT" then
            -- Иконка слева, кастбар справа
            -- Контейнер: ширина = castBarWidth (включает иконку + кастбар)
            container:SetWidth(width)
            container:SetHeight(height)

            -- Иконка: привязана к левому краю контейнера
            cb.icon:ClearAllPoints()
            cb.icon:SetPoint("LEFT", container, "LEFT", iconOffX, iconOffY)
            cb.icon:SetSize(iconSize, iconSize)
            cb.icon:Show()

            -- Кастбар: справа от иконки, на всю оставшуюся ширину
            local barWidth = width - iconSize - iconOffX
            if barWidth < 1 then barWidth = 1 end
            cb:ClearAllPoints()
            cb:SetPoint("LEFT", cb.icon, "RIGHT", 0, 0)
            cb:SetSize(barWidth, height)
        else
            -- Иконка справа, кастбар слева
            container:SetWidth(width)
            container:SetHeight(height)

            -- Кастбар: привязан к левому краю контейнера
            cb:ClearAllPoints()
            cb:SetPoint("LEFT", container, "LEFT", 0, 0)
            local barWidth = width - iconSize - iconOffX
            if barWidth < 1 then barWidth = 1 end
            cb:SetSize(barWidth, height)

            -- Иконка: справа от кастбара
            cb.icon:ClearAllPoints()
            cb.icon:SetPoint("LEFT", cb, "RIGHT", iconOffX, iconOffY)
            cb.icon:SetSize(iconSize, iconSize)
            cb.icon:Show()
        end
    else
        -- Иконка скрыта, кастбар на весь контейнер
        container:SetWidth(width)
        container:SetHeight(height)

        cb.icon:Hide()

        cb:ClearAllPoints()
        cb:SetPoint("LEFT", container, "LEFT", 0, 0)
        cb:SetSize(width, height)
    end

    -- Фон (bg) всегда следует за кастбаром
    if cb.bg then
        cb.bg:SetAllPoints(cb)
    end

    -- Спарк: размер и позиция обновляются в CastBarOnUpdate
    if cb.spark then
        cb.spark:SetSize(db.castBarSparkWidth, height * db.castBarSparkHeightMultiplier)
    end
end

-- Создание кастбара для неймплейта (вызывается из UpdateStyle)
function CreatePureCastBar(plate, db)
    if not plate or plate._pureCB then return plate._pureCB end

    local parent = plate.UnitFrame or plate

    -- Создаём контейнер — именно он позиционируется относительно healthBar
    -- FrameLevel = parent + 1, чтобы кастбар был выше родителя, но не перекрывал
    -- соседние неймплейты (наследует иерархию уровней фреймов)
    local container = CreateFrame("Frame", nil, parent)
    container:SetFrameLevel(parent:GetFrameLevel() + 1)

    -- Создаём кастбар как дочерний элемент контейнера
    local cb = CreateFrame("StatusBar", nil, container)
    cb:SetStatusBarTexture(db.castBarTex)
    cb:SetMinMaxValues(0, 100)
    cb:SetValue(0)
    cb:SetAlpha(0)
    cb:Hide()

    -- Кешируем healthBar на cb
    cb._healthBar = plate.healthBar or (plate.UnitFrame and plate.UnitFrame.healthBar) or plate.HealthBar or plate

    -- Фон (дочерний контейнера, но будет перепаренчен через SetAllPoints к cb)
    cb.bg = cb:CreateTexture(nil, "BACKGROUND")
    cb.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
    -- Инициализируем кэш цветов, если ещё не
    if not _cachedCastBarColors.bgColor then
        RefreshCastBarColorCache(db)
    end
    cb.bg:SetVertexColor(_cachedCastBarColors.bgColor[1], _cachedCastBarColors.bgColor[2], _cachedCastBarColors.bgColor[3], _cachedCastBarColors.bgColor[4])

    -- Текст имени заклинания (дочерний контейнера)
    cb.text = cb:CreateFontString(nil, "OVERLAY")

    -- Иконка заклинания (дочерний контейнера)
    cb.icon = container:CreateTexture(nil, "TOOLTIP")

    -- Спарк (дочерний контейнера)
    cb.spark = container:CreateTexture(nil, "TOOLTIP")
    cb.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    cb.spark:SetBlendMode("ADD")

    -- Сохраняем контейнер
    cb.container = container
    plate._pureCB = cb

    -- Первичная настройка позиции
    UpdateCastBarPosition(cb, db)

    return cb
end

-- Обновление состояния кастбара по событию
function UpdateCastBarState(unit, isStart, isChannel, db)
    if not C_NamePlate or not C_NamePlate.GetNamePlateForUnit then return end
    local plate = C_NamePlate.GetNamePlateForUnit(unit)
    if not plate then return end
    if UnitIsUnit(unit, "player") then return end

    local cb = CreatePureCastBar(plate, db)
    if not cb then return end

    -- Обновляем позицию при каждом старте каста (на случай смены настроек)
    UpdateCastBarPosition(cb, db)

    if not isStart then
        if cb:IsShown() and not cb.isFading then
            cb.isFading = true
            cb.fadeTimer = db.castBarFadeTime
        end
        return
    end

    local isPlayer = UnitIsPlayer(unit)
    local isFriend = UnitIsFriend("player", unit)
    local show = false

    if isPlayer then
        show = isFriend and db.friendlyPlayerCastBar or db.enemyPlayerCastBar
    else
        show = isFriend and db.friendlyNpcCastBar or db.enemyNpcCastBar
    end

    if not show then
        cb:Hide()
        if cb.container then cb.container:Hide() end
        activeBars[cb] = nil
        return
    end

    local name, _, _, texture, startTime, endTime, _, _, notInterruptible
    if isChannel then
        name, _, _, texture, startTime, endTime, _, _, notInterruptible = UnitChannelInfo(unit)
    else
        name, _, _, texture, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(unit)
    end

    if not name or not startTime or not endTime then
        cb:Hide()
        if cb.container then cb.container:Hide() end
        activeBars[cb] = nil
        return
    end

    cb.castName = name
    cb.castIcon = texture
    cb.startTime = startTime / 1000
    cb.endTime = endTime / 1000
    cb.duration = (endTime - startTime) / 1000
    cb.isChannel = isChannel
    cb.notInterruptible = notInterruptible and true or false
    cb.isFading = false
    cb.fadeTimer = nil

    -- Размеры больше не устанавливаем здесь — всё в UpdateCastBarPosition

    -- Текст через SetTextST (кэширование позиции, шрифт, цвет)
    if cb.text then
        local maxWidth = db.castNameWidth
        local truncatedName = SmartTruncate(name, maxWidth, db.castNameFont, db.castNameSize, db.castNameFlags)
        SetTextST(cb.text, db.castNameFont, db.castNameSize, db.castNameFlags,
                  "CENTER", cb, "CENTER", db.castNameOffsetX, db.castNameOffsetY,
                  1, truncatedName, _cachedCastBarColors.nameColor)
    end

    -- Иконка: только текстура, позиция уже установлена в UpdateCastBarPosition
    if cb.icon and texture then
        cb.icon:SetTexture(texture)
    end

    cb:SetAlpha(1)
    if cb.container then cb.container:SetAlpha(1) end
    cb:Show()
    if cb.container then cb.container:Show() end

    if cb.notInterruptible then
        ApplyColor(cb, _cachedCastBarColors.shieldBar)
    else
        ApplyColor(cb, _cachedCastBarColors.castBar)
    end

    activeBars[cb] = true
end

-- OnUpdate для анимации кастбаров (вызывается из core.lua)
function CastBarOnUpdate(elapsed, db)
    -- Ранний выход: если нет активных баров, не делаем ничего
    if not next(activeBars) then return end

    local now = GetTime()
    local toRemove = {}

    for cb in pairs(activeBars) do
        if cb.isFading then
            cb.fadeTimer = cb.fadeTimer - elapsed
            if cb.fadeTimer <= 0 then
                cb:Hide()
                if cb.container then cb.container:Hide() end
                cb:SetAlpha(0)
                toRemove[#toRemove + 1] = cb
            else
                -- Линейное затухание: альфа = остаток / исходное время затухания
                local fadeAlpha = cb.fadeTimer / db.castBarFadeTime
                cb:SetAlpha(fadeAlpha)
                if cb.container then
                    cb.container:SetAlpha(fadeAlpha)
                end
            end
        else
            local timeLeft = cb.endTime - now
            if timeLeft < 0 then timeLeft = 0 end

            local progress = 0
            if cb.duration > 0 then
                if cb.isChannel then
                    progress = timeLeft / cb.duration
                else
                    progress = (cb.duration - timeLeft) / cb.duration
                end
            end
            if progress < 0 then progress = 0 elseif progress > 1 then progress = 1 end

            cb:SetValue(progress * 100)

            if cb.spark then
                local sparkPosition = progress * cb:GetWidth()
                cb.spark:SetPoint("CENTER", cb, "LEFT", sparkPosition - 0.5, 0)
            end

            if (not cb.isChannel and now >= cb.endTime) or (cb.isChannel and now <= cb.startTime) then
                ApplyColor(cb, _cachedCastBarColors.successBar)
                cb.isFading = true
                if not cb.fadeTimer then
                    cb.fadeTimer = db and db.castBarFadeTime or 0.3
                end
            end
        end
    end

    for i = 1, #toRemove do
        activeBars[toRemove[i]] = nil
    end
end

-- Обработка событий кастбара (вызывается из core.lua)
function HandleCastBarEvent(event, unit, db)
    if not unit or not unit:find("nameplate") then return end

    if event == "UNIT_SPELLCAST_START" then
        UpdateCastBarState(unit, true, false, db)
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        UpdateCastBarState(unit, true, true, db)
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
        if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
            local plate = C_NamePlate.GetNamePlateForUnit(unit)
            local cb = plate and plate._pureCB
            if cb and cb:IsShown() and not cb.isFading then
                ApplyColor(cb, _cachedCastBarColors.failedBar)
                cb.isFading = true
                cb.fadeTimer = db and db.castBarFadeTime or 0.3
            end
        end
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        UpdateCastBarState(unit, false, nil, db)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
            local plate = C_NamePlate.GetNamePlateForUnit(unit)
            if plate and plate._pureCB then
                plate._pureCB:Hide()
                if plate._pureCB.container then plate._pureCB.container:Hide() end
                activeBars[plate._pureCB] = nil
            end
        end
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        if UnitCastingInfo(unit) then
            UpdateCastBarState(unit, true, false, db)
        elseif UnitChannelInfo(unit) then
            UpdateCastBarState(unit, true, true, db)
        end
    end
end

-- Очистка активных баров (вызывается при смене профиля)
function ClearActiveCastBars()
    for cb in pairs(activeBars) do
        cb:Hide()
        if cb.container then cb.container:Hide() end
        cb:SetAlpha(0)
    end
    activeBars = {}
end