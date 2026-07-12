--[[
    modules/CastBar.lua — AeonoPlates
    Кастомный кастбар с динамическим OnUpdate и обновлением настроек на лету
]] local activeBars = {}
local updateFrame = nil
local updateFrameActive = false

local _cachedCastBarColors = {}

function RefreshCastBarColorCache(db)
    _cachedCastBarColors.castBar = safeUnpackColor(db.castBarColor, 1, 1, 1, 1)
    _cachedCastBarColors.successBar = safeUnpackColor(db.castBarSuccessColor, 0, 1, 0, 1)
    _cachedCastBarColors.failedBar = safeUnpackColor(db.castBarFailedColor, 1, 0, 0, 1)
    _cachedCastBarColors.shieldBar = safeUnpackColor(db.castBarShieldColor, 0.5, 0.5, 1, 1)
    _cachedCastBarColors.bgColor = safeUnpackColor(db.castBarBgColor, 0, 0, 0, 0.5)
    _cachedCastBarColors.nameColor = safeUnpackColor(db.castNameColor, 1, 1, 1, 1)
end

local function ApplyColor(cb, colorTable)
    if not cb or not colorTable then
        return
    end
    cb:SetStatusBarColor(colorTable[1], colorTable[2], colorTable[3], colorTable[4])
    local tex = cb:GetStatusBarTexture()
    if tex and tex.SetVertexColor then
        tex:SetVertexColor(colorTable[1], colorTable[2], colorTable[3], colorTable[4])
    end
end

-- Обновление всех настроек кастбара (позиция, текстура, шрифты, цвета)
function UpdateCastBarSettings(cb, db)
    if not cb or not db then
        return
    end
    local hb = cb._healthBar
    if not hb then
        return
    end

    local parent = cb:GetParent()
    if not parent then
        return
    end

    local anchor = db.castBarAnchor or "CENTER"
    local relAnchor = db.castBarRelativePoint or "CENTER"
    local width = db.castBarWidth or 100
    local height = db.castBarHeight or 8
    local showIcon = db.castBarShowIcon

    cb:SetStatusBarTexture(db.castBarTex)

    -- Привязка cb напрямую к родительскому фрейму
    cb:ClearAllPoints()
    cb:SetPoint(anchor, parent, relAnchor, db.castBarOffsetX, db.castBarOffsetY)
    cb:SetSize(width, height)

    -- Иконка с независимыми настройками
    if showIcon and cb.icon then
        local iconSize = db.castBarIconSize or height
        local iconAnchor = db.castBarIconAnchor or "LEFT"
        local iconRelAnchor = db.castBarIconRelAnchor or "LEFT"
        local iconOffsetX = db.castBarIconOffsetX or 0
        local iconOffsetY = db.castBarIconOffsetY or 0

        SetIconST(cb.icon, cb.castIcon, iconSize, iconSize, iconAnchor, cb, iconRelAnchor, iconOffsetX, iconOffsetY)
        cb.icon:Show()
    elseif cb.icon then
        cb.icon:Hide()
    end

    if cb.bg then
        cb.bg:SetAllPoints(cb)
        if _cachedCastBarColors.bgColor then
            cb.bg:SetVertexColor(_cachedCastBarColors.bgColor[1], _cachedCastBarColors.bgColor[2],
                _cachedCastBarColors.bgColor[3], _cachedCastBarColors.bgColor[4])
        end
    end

    if cb.text then
        SetTextST(cb.text, db.castNameFont, db.castNameSize, db.castNameFlags, "CENTER", cb, "CENTER",
            db.castNameOffsetX, db.castNameOffsetY, cb.text:GetText(), _cachedCastBarColors.nameColor)
    end

    if cb.spark then
        cb.spark:SetSize(db.castBarSparkWidth, height * db.castBarSparkHeightMultiplier)
    end
end

function CreatePureCastBar(plate, db)
    if not plate then
        return nil
    end

    if plate._pureCB then
        UpdateCastBarSettings(plate._pureCB, db)
        return plate._pureCB
    end

    local parent = plate.UnitFrame or plate

    local cb = CreateFrame("StatusBar", nil, parent)
    cb:SetFrameLevel(parent:GetFrameLevel())
    cb:SetStatusBarTexture(db.castBarTex)
    cb:SetMinMaxValues(0, 100)
    cb:SetValue(0)
    cb:SetAlpha(0)
    cb:Hide()

    cb._healthBar = plate.healthBar or (plate.UnitFrame and plate.UnitFrame.healthBar) or plate.HealthBar or plate

    cb.bg = cb:CreateTexture(nil, "BACKGROUND")
    cb.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
    cb.bg:SetAllPoints(cb)

    cb.text = cb:CreateFontString(nil, "OVERLAY")

    cb.icon = cb:CreateTexture(nil, "TOOLTIP")

    cb.spark = cb:CreateTexture(nil, "TOOLTIP")
    cb.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    cb.spark:SetBlendMode("ADD")

    plate._pureCB = cb

    UpdateCastBarSettings(cb, db)
    return cb
end

-- ========== ДИНАМИЧЕСКИЙ ONUPDATE ==========
local function SetUpdateFrameActive(active)
    if not updateFrame then
        return
    end
    if active and not updateFrameActive then
        updateFrame:Show()
        updateFrameActive = true
    elseif not active and updateFrameActive then
        updateFrame:Hide()
        updateFrameActive = false
    end
end

local function CastBarOnUpdateInternal(elapsed)
    if not activeBars or next(activeBars) == nil then
        SetUpdateFrameActive(false)
        return
    end

    local now = GetTime()
    local db = AeonoPlates.db.profile
    if not db then
        return
    end

    local toRemove = {}
    for cb in pairs(activeBars) do
        if cb.isFading then
            cb.fadeTimer = cb.fadeTimer - elapsed
            if cb.fadeTimer <= 0 then
                cb:Hide()
                cb:SetAlpha(0)
                toRemove[#toRemove + 1] = cb
            else
                local fadeAlpha = cb.fadeTimer / db.castBarFadeTime
                cb:SetAlpha(fadeAlpha)
            end
        else
            local timeLeft = cb.endTime - now
            if timeLeft < 0 then
                timeLeft = 0
            end

            local progress = 0
            if cb.duration > 0 then
                if cb.isChannel then
                    progress = timeLeft / cb.duration
                else
                    progress = (cb.duration - timeLeft) / cb.duration
                end
            end
            if progress < 0 then
                progress = 0
            elseif progress > 1 then
                progress = 1
            end

            cb:SetValue(progress * 100)

            if cb.spark then
                local sparkPosition = progress * cb:GetWidth()
                cb.spark:SetPoint("CENTER", cb, "LEFT", sparkPosition - 0.5, 0)
            end

            if (not cb.isChannel and now >= cb.endTime) or (cb.isChannel and now <= cb.startTime) then
                cb.isFading = true
                if not cb.fadeTimer then
                    cb.fadeTimer = db.castBarFadeTime
                end
            end
        end
    end

    for i = 1, #toRemove do
        activeBars[toRemove[i]] = nil
    end

    if next(activeBars) == nil then
        SetUpdateFrameActive(false)
    end
end

function CreateCastBarUpdateFrame()
    if not updateFrame then
        updateFrame = CreateFrame("Frame", "AeonoPlatesCastBarUpdateFrame", UIParent)
        updateFrame:Hide()
        updateFrame:SetScript("OnUpdate", function(_, elapsed)
            CastBarOnUpdateInternal(elapsed)
        end)
        updateFrameActive = false
    end
    return updateFrame
end
-- ============================================

function UpdateCastBarState(unit, isStart, isChannel, db)
    if not C_NamePlate or not C_NamePlate.GetNamePlateForUnit then
        return
    end
    local plate = C_NamePlate.GetNamePlateForUnit(unit)
    if not plate then
        return
    end
    if UnitIsUnit(unit, "player") then
        return
    end

    local cb = CreatePureCastBar(plate, db)
    if not cb then
        return
    end

    if not isStart then
        if cb:IsShown() and not cb.isFading then
            cb.isFading = true
            cb.fadeTimer = db.castBarFadeTime
            if not updateFrameActive then
                SetUpdateFrameActive(true)
            end
        end
        return
    end

    local isPlayer = UnitIsPlayer(unit)
    local isFriend = UnitIsFriend("player", unit)
    local show = false

    if isPlayer then
        if isFriend then
            show = db.friendlyPlayerCastBar
        else
            show = db.enemyPlayerCastBar
        end
    else
        if isFriend then
            show = db.friendlyNpcCastBar
        else
            show = db.enemyNpcCastBar
        end
    end

    if not show then
        cb:Hide()
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

    if cb.text then
        local maxWidth = db.castNameWidth
        local truncatedName = SmartTruncate(name, maxWidth, db.castNameFont, db.castNameSize, db.castNameFlags)
        cb.text:SetText(truncatedName)
    end

    if cb.icon and texture then
        cb.icon:SetTexture(texture)
        if db.castBarShowIcon then
            cb.icon:Show()
        else
            cb.icon:Hide()
        end
    end

    cb:SetAlpha(1)
    cb:Show()

    if cb.notInterruptible then
        ApplyColor(cb, _cachedCastBarColors.shieldBar)
    else
        ApplyColor(cb, _cachedCastBarColors.castBar)
    end

    activeBars[cb] = true
    if not updateFrame then
        CreateCastBarUpdateFrame()
    end
    SetUpdateFrameActive(true)
end

function HandleCastBarEvent(event, unit, db)
    if not unit or not unit:find("nameplate") then
        return
    end

    if event == "UNIT_SPELLCAST_START" then
        UpdateCastBarState(unit, true, false, db)
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        UpdateCastBarState(unit, true, true, db)
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
        local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit(unit)
        local cb = plate and plate._pureCB
        if cb and cb:IsShown() and not cb.isFading then
            ApplyColor(cb, _cachedCastBarColors.failedBar)
            if cb.text then
                cb.text:SetText("Прервано")
            end
            cb.isFading = true
            cb.fadeTimer = db and db.castBarFadeTime or 0.3
            if not updateFrameActive then
                SetUpdateFrameActive(true)
            end
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit(unit)
        local cb = plate and plate._pureCB
        if cb and cb:IsShown() then
            ApplyColor(cb, _cachedCastBarColors.successBar)
            cb.isFading = true
            cb.fadeTimer = db and db.castBarFadeTime or 0.3
            if not updateFrameActive then
                SetUpdateFrameActive(true)
            end
        end
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        UpdateCastBarState(unit, false, nil, db)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit(unit)
        if plate and plate._pureCB then
            plate._pureCB:Hide()
            activeBars[plate._pureCB] = nil
        end
    end
end

function ClearActiveCastBars()
    for cb in pairs(activeBars) do
        cb:Hide()
        cb:SetAlpha(0)
    end
    activeBars = {}
    SetUpdateFrameActive(false)
end
