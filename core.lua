--[[
    core.lua — AeonoPlates
    Ядро аддона: AceAddon-3.0, события, хуки, OnUpdate-поллинг, UpdateStyle
]] local MAJOR, MINOR = "AeonoPlates", 1

-- Регистрация аддона (глобал для доступа из options.lua и других файлов)
AeonoPlates = LibStub("AceAddon-3.0"):NewAddon("AeonoPlates", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")

-- Дефолтные настройки (строковые ключи для anchor/flags)
local defaults = {
    profile = {
        -- ============================================
        -- NAME SETTINGS
        -- ============================================
        nameFont = "Fonts\\FRIZQT__.TTF",
        nameFlags = "OUTLINE",
        nameWidth = 140,
        nameFriendlyPlayerSize = 20,
        nameEnemyPlayerSize = 16,
        nameFriendlyNpcSize = 18,
        nameEnemyNpcSize = 14,
        nameAnchor = "BOTTOM",
        nameRelAnchor = "TOP",
        nameOffsetX = 0,
        nameOffsetY = 2,
        onlyNameAnchor = "CENTER",
        onlyNameOffsetX = 0,
        onlyNameOffsetY = 0,
        onlyNameWidth = 120,

        -- ============================================
        -- HEALTH SETTINGS
        -- ============================================
        healthTexture = "Interface\\TargetingFrame\\UI-StatusBar",
        showHealthText = true,
        showHealthPercent = true,
        shortenHealth = true,
        healthFont = "Fonts\\FRIZQT__.TTF",
        healthSize = 14,
        healthFlags = "OUTLINE",
        healthAnchor = "CENTER",
        healthRelAnchor = "CENTER",
        healthOffsetX = 0,
        healthOffsetY = 0,
        healthPercentSize = 12,
        healthPercentAnchor = "RIGHT",
        healthPercentRelAnchor = "RIGHT",
        healthPercentOffsetX = -2,
        healthPercentOffsetY = 0,

        -- ============================================
        -- ICON SETTINGS
        -- ============================================
        showEnemyClassIcons = false,
        showFriendlyClassIcons = true,
        showEnemyTotemIcons = true,
        showFriendlyTotemIcons = true,
        iconSize = 40,
        totemIconSize = 30,
        iconAnchor = "BOTTOM",
        iconRelAnchor = "TOP",
        iconOffsetX = 0,
        iconOffsetY = 0,

        -- ============================================
        -- BORDER SETTINGS
        -- ============================================
        borderTexture = "Interface\\Buttons\\WHITE8X8",
        borderPadding = 1,
        borderThickness = 1,
        borderTargetColor = {1, 1, 1, 1},
        borderMouseoverColor = {0, 1, 1, 1},
        borderCombatColor = {1, 0, 0, 1},
        borderDefaultColor = {0, 0, 0, 1},

        -- ============================================
        -- THREAT SETTINGS
        -- ============================================
        threatHighColor = {0, 1, 0, 1},
        threatLowColor = {1, 0, 0, 1},
        threatAggroColor = {1, 1, 0, 1},

        -- ============================================
        -- CLASSIFICATION
        -- ============================================
        showClassification = true,
        classificationSize = 30,
        classificationAnchor = "RIGHT",
        classificationRelAnchor = "LEFT",
        classificationOffsetX = -5,
        classificationOffsetY = 0,

        -- ============================================
        -- RAID TARGET
        -- ============================================
        raidTargetAnchor = "LEFT",
        raidTargetRelAnchor = "RIGHT",
        raidTargetScale = 1.25,
        raidTargetOffsetX = 2,
        raidTargetOffsetY = 0,

        -- ============================================
        -- SCALE SETTINGS
        -- ============================================
        petFrameScale = 0.8,

        -- ============================================
        -- CASTBAR SETTINGS
        -- ============================================
        friendlyPlayerCastBar = true,
        enemyPlayerCastBar = true,
        friendlyNpcCastBar = false,
        enemyNpcCastBar = true,
        castBarTex = "Interface\\TargetingFrame\\UI-StatusBar",
        castBarFadeTime = 0.5,
        castBarHeight = 16,
        castBarWidth = 120,
        castBarShowIcon = true,
        castBarIconSide = "LEFT",
        castBarIconOffsetX = 0,
        castBarIconOffsetY = 0,
        castBarAnchor = "TOP",
        castBarRelativePoint = "BOTTOM",
        castBarOffsetX = 0,
        castBarOffsetY = -3,
        castBarColor = {1, 1, 0, 1},
        castBarSuccessColor = {0, 1, 0, 1},
        castBarFailedColor = {1, 0, 0, 1},
        castBarShieldColor = {0.5, 0.5, 1, 1},
        castBarBgColor = {0, 0, 0, 0.5},
        castNameFont = "Fonts\\FRIZQT__.TTF",
        castNameSize = 10,
        castNameWidth = 100,
        castNameFlags = "OUTLINE",
        castNameColor = {1, 1, 1, 1},
        castNameOffsetX = 0,
        castNameOffsetY = 0,
        castBarSparkWidth = 20,
        castBarSparkHeightMultiplier = 2
    }
}

-- Троттлинг-таблицы
local combatThrottle = {}
local _targetThrottle = 0
local _mouseoverThrottle = 0

-- Состояние mouseover
local _prevMouseoverFrame = nil

-- ============================================
-- ИНИЦИАЛИЗАЦИЯ LSM — конвертация имён в пути
-- ============================================
local function InitLSM()
    local LSM = LibStub("LibSharedMedia-3.0", true)
    if not LSM then
        return
    end

    local db = AeonoPlates.db.profile

    -- Если в db.profile хранится имя (не путь), конвертируем в путь
    if db.nameFont and not db.nameFont:find("\\") and not db.nameFont:find("/") then
        local path = LSM:Fetch("font", db.nameFont)
        if path then
            db.nameFont = path
        end
    end

    if db.healthFont and not db.healthFont:find("\\") and not db.healthFont:find("/") then
        local path = LSM:Fetch("font", db.healthFont)
        if path then
            db.healthFont = path
        end
    end

    if db.healthTexture and not db.healthTexture:find("\\") and not db.healthTexture:find("/") then
        local path = LSM:Fetch("statusbar", db.healthTexture)
        if path then
            db.healthTexture = path
        end
    end

    if db.borderTexture and not db.borderTexture:find("\\") and not db.borderTexture:find("/") then
        local path = LSM:Fetch("border", db.borderTexture)
        if path then
            db.borderTexture = path
        end
    end

    -- Конвертация настроек кастбара
    if db.castBarTex and not db.castBarTex:find("\\") and not db.castBarTex:find("/") then
        local path = LSM:Fetch("statusbar", db.castBarTex)
        if path then
            db.castBarTex = path
        end
    end

    if db.castNameFont and not db.castNameFont:find("\\") and not db.castNameFont:find("/") then
        local path = LSM:Fetch("font", db.castNameFont)
        if path then
            db.castNameFont = path
        end
    end
end

-- ============================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ ХУКОВ
-- ============================================
local function HideCastBar(cb)
    local unit = cb.unit or cb.displayedUnit or (cb.UnitFrame and cb.UnitFrame.unit)
    if unit and unit:find("nameplate") then
        cb:Hide()
    end
end

local function HideName(frame)
    local unit = frame.unit or frame.displayedUnit or (frame.UnitFrame and frame.UnitFrame.unit)
    if unit and unit:find("nameplate") then
        local name = frame.name or (frame.UnitFrame and frame.UnitFrame.name)
        if name then
            name:Hide()
        end
    end
end

local function HideHighlight(frame)
    local unit = frame.unit or frame.displayedUnit or (frame.UnitFrame and frame.UnitFrame.unit)
    if unit and unit:find("nameplate") then
        local hl = frame.selectionHighlight or (frame.healthBar and frame.healthBar.highlight)
        if hl then
            hl:Hide()
        end
    end
end

local function HideBuffs(frame)
    local unit = frame.unit or frame.displayedUnit or (frame.UnitFrame and frame.UnitFrame.unit)
    if unit and unit:find("nameplate") then
        local bf = frame.BuffFrame or (frame.UnitFrame and frame.UnitFrame.BuffFrame)
        if bf then
            bf:Hide()
        end
    end
end

local function HideBorder(frame)
    local unit = frame.unit or frame.displayedUnit or (frame.UnitFrame and frame.UnitFrame.unit)
    if unit and unit:find("nameplate") then
        if frame.healthBar.border then
            frame.healthBar.border:Hide()
        end
    end
end
-- ============================================
-- MOUSEOVER
-- ============================================
local function UpdateMouseoverFrameLevel(frame, data)
    local isMouseover = UnitIsUnit(data.unit, "mouseover")
    local isTarget = UnitIsUnit(data.unit, "target")
    local isMouseoverOnly = isMouseover and not isTarget

    if isMouseoverOnly then
        if not frame._origFrameLevel then
            frame._origFrameLevel = frame:GetFrameLevel()
        end
        frame:SetFrameLevel(frame:GetFrameLevel() + 100)
        _prevMouseoverFrame = frame

        -- Поднимаем frame level кастбара вместе с фреймом
        local cb = frame._pureCB
        if cb and cb.container then
            cb.container:SetFrameLevel(frame:GetFrameLevel())
        end
    else
        if frame._origFrameLevel then
            frame:SetFrameLevel(frame._origFrameLevel)
            frame._origFrameLevel = nil

            -- Восстанавливаем frame level кастбара
            local cb = frame._pureCB
            if cb and cb.container then
                cb.container:SetFrameLevel(frame:GetFrameLevel())
            end
        end
    end
end

local function ResetMouseoverState()
    if _prevMouseoverFrame then
        local prev = _prevMouseoverFrame
        if prev._origFrameLevel then
            prev:SetFrameLevel(prev._origFrameLevel)
            prev._origFrameLevel = nil

            -- Восстанавливаем frame level кастбара
            local cb = prev._pureCB
            if cb and cb.container then
                cb.container:SetFrameLevel(prev:GetFrameLevel())
            end
        end
        -- Сброс цвета границы: получаем полные данные юнита и вызываем UpdateCustomBorder
        if prev then
            local data = GetUnitData(prev)
            if data then
                UpdateCustomBorder(prev, data, AeonoPlates.db.profile)
            end
        end
        _prevMouseoverFrame = nil
    end
end

-- ============================================
-- ОБРАБОТКА PLAYER SELF
-- ============================================
local function UpdatePlayerSelf(frame)
    if not UnitIsUnit(frame.unit, "player") then
        return false
    end

    if frame.customName then
        frame.customName:Hide()
    end
    if frame.healthText then
        frame.healthText:Hide()
    end
    if frame.percText then
        frame.percText:Hide()
    end
    if frame.classIcon then
        frame.classIcon:Hide()
    end
    if frame.healthBar then
        frame.healthBar:SetAlpha(tonumber(GetCVar("nameplateShowSelf")) or 0)
    end
    if frame.BuffFrame then
        frame.BuffFrame:Show()
    end
    if frame.customBorder then
        frame.customBorder:Hide()
    end

    return true
end

-- ============================================
-- UPDATE STYLE — ГЛАВНАЯ ФУНКЦИЯ СТИЛИЗАЦИИ
-- ============================================
function AeonoPlates:UpdateStyle(frame)
    local db = self.db.profile

    local unit = frame.unit or (frame.UnitFrame and frame.UnitFrame.unit)
    if not unit or not UnitExists(unit) then
        return
    end

    -- Player self — особая обработка
    if UpdatePlayerSelf(frame) then
        return
    end

    -- Только неймплейты
    if not unit:find("nameplate") then
        return
    end
    if not (frame.isNamePlate or (frame.UnitFrame and frame.UnitFrame.isNamePlate)) then
        return
    end

    local data = GetUnitData(frame)
    if not data then
        return
    end

    -- Скрытие нативного UI
    local cb = frame.castBar or (frame.UnitFrame and frame.UnitFrame.castBar)
    if cb then
        HideCastBar(cb)
    end
    HideName(frame)
    HideHighlight(frame)
    HideBuffs(frame)
    HideBorder(frame)

    -- Вызов модулей
    UpdateHealthBarTexture(frame, data, db)
    UpdateNameText(frame, data, db)
    UpdateHealthValueText(frame, data, db)
    UpdateHealthPercText(frame, data, db)
    -- Обновляем значения текста здоровья
    if db.showHealthText or db.showHealthPercent then
        self:UpdateHealthValues(frame, data.unit, db)
    end
    UpdateUnitIcon(frame, data, db)
    UpdateClassification(frame, data, db)
    UpdateRaidTarget(frame, data, db)
    UpdateFrameScale(frame, data, db)
    UpdateMouseoverFrameLevel(frame, data)
    UpdateCustomBorder(frame, data, db)
    UpdateThreatIndicator(frame, data, db)

    -- Создаём кастбар (если ещё не создан)
    CreatePureCastBar(frame, db)
end

-- ============================================
-- ОБНОВЛЕНИЕ ЗДОРОВЬЯ (для UNIT_COMBAT)
-- ============================================
function AeonoPlates:UpdateHealthValues(frame, unit)
    local db = self.db.profile
    UpdateHealthValues(frame, unit, db)
end

-- ============================================
-- ПОЛНЫЙ РЕФРЕШ ВСЕХ НЕЙМПЛЕЙТОВ
-- ============================================
function AeonoPlates:RefreshAllPlates()
    local frames = C_NamePlate.GetNamePlates()
    for i = 1, #frames do
        local frame = frames[i]
        local u = frame.unit or (frame.UnitFrame and frame.UnitFrame.unit)
        if u then
            local targetFrame = frame.UnitFrame or frame
            self:UpdateStyle(targetFrame)
            self:UpdateHealthValues(targetFrame, u)
        end
    end
end

-- ============================================
-- ОБРАБОТЧИКИ СОБЫТИЙ
-- ============================================
function AeonoPlates:OnNamePlateAdded(event, unit)
    if unit and unit:find("nameplate") then
        local frame = C_NamePlate.GetNamePlateForUnit(unit)
        if frame then
            local targetFrame = frame.UnitFrame or frame
            self:UpdateStyle(targetFrame)
            self:UpdateHealthValues(targetFrame, unit)
            -- Проверяем, не кастует ли юнит уже сейчас
            if UnitCastingInfo(unit) then
                UpdateCastBarState(unit, true, false, self.db.profile)
            elseif UnitChannelInfo(unit) then
                UpdateCastBarState(unit, true, true, self.db.profile)
            end
        end
    end
end

function AeonoPlates:OnUnitCombat(event, unit, action)
    if unit and unit:find("nameplate") and (action == "WOUND" or action == "HEAL") then
        local guid = UnitGUID(unit)
        if guid then
            local now = GetTime()
            local last = combatThrottle[guid]
            if not last or (now - last) > 0.05 then
                combatThrottle[guid] = now
                local frame = C_NamePlate.GetNamePlateForUnit(unit)
                if frame then
                    local targetFrame = frame.UnitFrame or frame
                    self:UpdateHealthValues(targetFrame, unit)
                end
            end
        end
    end
end

function AeonoPlates:OnUnitFaction(event, unit)
    if unit then
        local frame = C_NamePlate.GetNamePlateForUnit(unit)
        if frame then
            local targetFrame = frame.UnitFrame or frame
            self:UpdateStyle(targetFrame)
            self:UpdateHealthValues(targetFrame, unit)
        end
    end
end

function AeonoPlates:OnThreatUpdate(event, unit)
    if unit and unit:find("nameplate") then
        local frame = C_NamePlate.GetNamePlateForUnit(unit)
        if frame then
            local targetFrame = frame.UnitFrame or frame
            local data = GetUnitData(targetFrame)
            if data then
                UpdateThreatIndicator(targetFrame, data, self.db.profile)
            end
        end
    end
end

function AeonoPlates:OnTargetChanged()
    ResetMouseoverState()

    local now = GetTime()
    if now - _targetThrottle > 0.08 then
        _targetThrottle = now
        local frames = C_NamePlate.GetNamePlates()
        local db = self.db.profile
        for i = 1, #frames do
            local frame = frames[i]
            local u = frame.unit or (frame.UnitFrame and frame.UnitFrame.unit)
            if u then
                local targetFrame = frame.UnitFrame or frame
                local data = GetUnitData(targetFrame)
                if data then
                    UpdateCustomBorder(targetFrame, data, db)
                end
            end
        end
    end
end

function AeonoPlates:OnMouseoverChanged()
    local now = GetTime()
    if now - _mouseoverThrottle > 0.08 then
        _mouseoverThrottle = now
        local frames = C_NamePlate.GetNamePlates()
        local db = self.db.profile
        for i = 1, #frames do
            local frame = frames[i]
            local u = frame.unit or (frame.UnitFrame and frame.UnitFrame.unit)
            if u then
                local targetFrame = frame.UnitFrame or frame
                local data = GetUnitData(targetFrame)
                if data then
                    UpdateMouseoverFrameLevel(targetFrame, data)
                    UpdateCustomBorder(targetFrame, data, db)
                end
            end
        end
    end
end

function AeonoPlates:OnUnitFlags(event, unit)
    if unit and unit:find("nameplate") then
        local frame = C_NamePlate.GetNamePlateForUnit(unit)
        if frame then
            local targetFrame = frame.UnitFrame or frame
            local data = GetUnitData(targetFrame)
            if data then
                UpdateThreatIndicator(targetFrame, data, self.db.profile)
            end
        end
    end
end

function AeonoPlates:OnCVarUpdate()
    self:RefreshAllPlates()
end

function AeonoPlates:OnDuelEvent()
    self:RefreshAllPlates()
end

-- ============================================
-- ОБРАБОТЧИК УДАЛЕНИЯ НЕЙМПЛЕЙТА
-- ============================================
function AeonoPlates:OnNamePlateRemoved(event, unit)
    if unit and unit:find("nameplate") then
        HandleCastBarEvent("NAME_PLATE_UNIT_REMOVED", unit, self.db.profile)
    end
end

-- ============================================
-- ОБРАБОТЧИКИ СОБЫТИЙ КАСТБАРА
-- ============================================
function AeonoPlates:OnUnitSpellcastStart(event, unit)
    HandleCastBarEvent(event, unit, self.db.profile)
end

function AeonoPlates:OnUnitSpellcastChannelStart(event, unit)
    HandleCastBarEvent(event, unit, self.db.profile)
end

function AeonoPlates:OnUnitSpellcastStop(event, unit)
    HandleCastBarEvent(event, unit, self.db.profile)
end

function AeonoPlates:OnUnitSpellcastChannelStop(event, unit)
    HandleCastBarEvent(event, unit, self.db.profile)
end

function AeonoPlates:OnUnitSpellcastInterrupted(event, unit)
    HandleCastBarEvent(event, unit, self.db.profile)
end

function AeonoPlates:OnUnitSpellcastFailed(event, unit)
    HandleCastBarEvent(event, unit, self.db.profile)
end

-- ============================================
-- ЖИЗНЕННЫЙ ЦИКЛ
-- ============================================
function AeonoPlates:OnInitialize()
    -- Инициализация БД
    self.db = LibStub("AceDB-3.0"):New("AeonoPlatesDB", defaults, "Default")

    -- Регистрация слаш-команд
    self:RegisterChatCommand("aep", "OpenOptions")
    self:RegisterChatCommand("aeonoplates", "OpenOptions")

    -- Инициализация LSM
    InitLSM()

    -- Инициализация кэшей цветов
    RefreshBorderColorCache(self.db.profile)
    RefreshCastBarColorCache(self.db.profile)

    -- Регистрация колбэка на смену профиля (для немедленного рефреша)
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
end

function AeonoPlates:OnProfileChanged(event, database, newProfileKey)
    ClearActiveCastBars()
    RefreshBorderColorCache(self.db.profile)
    RefreshCastBarColorCache(self.db.profile)
    self:RefreshAllPlates()
end

-- ... весь код до OnEnable без изменений ...

function AeonoPlates:OnEnable()
    -- Регистрация настроек в AceConfig (здесь options.lua уже загружен)
    local options = self:GetOptionsTable()
    if options then
        LibStub("AceConfig-3.0"):RegisterOptionsTable("AeonoPlates", options)
        LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AeonoPlates", "AeonoPlates")
        LibStub("AceConfigDialog-3.0"):SetDefaultSize("AeonoPlates", 420, 700)

        local AceDBOptions = LibStub("AceDBOptions-3.0", true)
        if AceDBOptions then
            options.args.profile = AceDBOptions:GetOptionsTable(self.db)
        end
    end

    -- Регистрация событий (без изменений)
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED", "OnNamePlateAdded")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", "OnNamePlateRemoved")
    self:RegisterEvent("UNIT_COMBAT", "OnUnitCombat")
    self:RegisterEvent("UNIT_FACTION", "OnUnitFaction")
    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", "OnThreatUpdate")
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "OnTargetChanged")
    self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", "OnMouseoverChanged")
    self:RegisterEvent("UNIT_FLAGS", "OnUnitFlags")
    self:RegisterEvent("CVAR_UPDATE", "OnCVarUpdate")
    self:RegisterEvent("PLAYER_DUEL_START", "OnDuelEvent")
    self:RegisterEvent("PLAYER_DUEL_FINISHED", "OnDuelEvent")

    self:RegisterEvent("UNIT_SPELLCAST_START", "OnUnitSpellcastStart")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", "OnUnitSpellcastChannelStart")
    self:RegisterEvent("UNIT_SPELLCAST_STOP", "OnUnitSpellcastStop")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", "OnUnitSpellcastChannelStop")
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", "OnUnitSpellcastInterrupted")
    self:RegisterEvent("UNIT_SPELLCAST_FAILED", "OnUnitSpellcastFailed")

    self:RegisterMinimapIcon()

    -- Хуки (без изменений)
    if CompactUnitFrame_UpdateName then
        self:SecureHook("CompactUnitFrame_UpdateName", function(frame)
            HideName(frame)
        end)
    end

    if CompactUnitFrame_UpdateSelectionHighlight then
        self:SecureHook("CompactUnitFrame_UpdateSelectionHighlight", function(frame)
            HideHighlight(frame)
        end)
    end

    if CastingBarFrame_OnShow then
        self:SecureHook("CastingBarFrame_OnShow", function(frame)
            HideCastBar(frame)
        end)
    end

    if CastingBarFrame_UpdateShownState then
        self:SecureHook("CastingBarFrame_UpdateShownState", function(frame)
            HideCastBar(frame)
        end)
    end

    -- OnUpdate-поллинг для mouseover (страховка) — без изменений
    if not self._mouseoverPollFrame then
        local pollFrame = CreateFrame("Frame")
        local lastCheck = 0
        pollFrame:SetScript("OnUpdate", function()
            local now = GetTime()
            if now - lastCheck < 0.1 then
                return
            end
            lastCheck = now

            if not UnitExists("mouseover") and _prevMouseoverFrame then
                local prev = _prevMouseoverFrame
                if prev._origFrameLevel then
                    prev:SetFrameLevel(prev._origFrameLevel)
                    prev._origFrameLevel = nil

                    local cb = prev._pureCB
                    if cb and cb.container then
                        cb.container:SetFrameLevel(prev:GetFrameLevel())
                    end
                end
                if prev then
                    local data = GetUnitData(prev)
                    if data then
                        UpdateCustomBorder(prev, data, AeonoPlates.db.profile)
                    end
                end
                _prevMouseoverFrame = nil
            end
        end)
        self._mouseoverPollFrame = pollFrame
    end

    -- ВОТ ЗДЕСЬ ЗАМЕНА: создаём динамический OnUpdate-фрейм для кастбара
    CreateCastBarUpdateFrame()

    -- Полный рефреш при старте
    self:RefreshAllPlates()
end

function AeonoPlates:OnDisable()
    self:UnhookAll()
    self:UnregisterAllEvents()

    if self._mouseoverPollFrame then
        self._mouseoverPollFrame:SetScript("OnUpdate", nil)
        self._mouseoverPollFrame = nil
    end

    -- Очищаем активные бары (OnUpdate-фрейм сам скроется)
    ClearActiveCastBars()
end

-- ============================================
-- РЕГИСТРАЦИЯ ИКОНКИ МИНИКАРТЫ
-- ============================================
function AeonoPlates:RegisterMinimapIcon()
    local icon = LibStub("LibDBIcon-1.0", true)
    if not icon then
        return
    end

    local ldb = LibStub("LibDataBroker-1.1", true)
    if not ldb then
        return
    end

    local dataobj = ldb:NewDataObject("AeonoPlates", {
        type = "data source",
        text = "AeonoPlates",
        icon = "Interface\\Icons\\INV_Misc_QuestionMark",
        OnClick = function()
            self:OpenOptions()
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("AeonoPlates")
            tooltip:AddLine("Нажмите для открытия настроек")
        end,
    })
    icon:Register("AeonoPlates", dataobj, self.db.profile)
end

-- ============================================
-- ПОЛУЧЕНИЕ ТАБЛИЦЫ НАСТРОЕК
-- ============================================
function AeonoPlates:GetOptionsTable()
    return self.optionsTable
end

-- ============================================
-- ОТКРЫТИЕ НАСТРОЕК
-- ============================================
function AeonoPlates:OpenOptions(input)
    LibStub("AceConfigDialog-3.0"):Open("AeonoPlates")
end
