--[[
    core.lua — AeonoPlates
    Ядро аддона: AceAddon-3.0, события, хуки, OnUpdate-поллинг, UpdateStyle
]] local MAJOR, MINOR = "AeonoPlates", 1

-- Регистрация аддона (глобал для доступа из options.lua и других файлов)
AeonoPlates = LibStub("AceAddon-3.0"):NewAddon("AeonoPlates", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")

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
-- FRAME LEVEL
-- ============================================
local _prevMouseoverFrame = nil
local _prevTargetFrame = nil

local function UpdateFrameLevel(frame, data)
    if not frame then
        return
    end

    local isTarget = UnitIsUnit(data.unit, "target")
    local isMouseover = UnitIsUnit(data.unit, "mouseover")

    local newOffset = 0
    if isTarget and isMouseover then
        newOffset = 300
        _prevTargetFrame = frame
        _prevMouseoverFrame = frame
    elseif isTarget then
        newOffset = 200
        _prevTargetFrame = frame
    elseif isMouseover then
        newOffset = 100
        _prevMouseoverFrame = frame
    end

    local oldOffset = frame._currentOffset or 0
    if newOffset == oldOffset then
        return -- ничего не меняется
    end

    local currentLevel = frame:GetFrameLevel()
    local newLevel = currentLevel - oldOffset + newOffset
    frame:SetFrameLevel(newLevel)

    frame._currentOffset = newOffset

    local cb = frame._pureCB
    if cb and cb.container then
        cb.container:SetFrameLevel(newLevel)
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
    if db.showHealthText or db.showHealthPercent then
        self:UpdateHealthValues(frame, data.unit, db)
    end
    UpdateUnitIcon(frame, data, db)
    UpdateClassification(frame, data, db)
    UpdateRaidTarget(frame, data, db)
    UpdateFrameScale(frame, data, db)
    UpdateFrameLevel(frame, data)
    UpdateCustomBorder(frame, data, db)
    UpdateThreatIndicator(frame, data, db)
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
    if _prevTargetFrame then
        local data = GetUnitData(_prevTargetFrame)
        if data then
            UpdateFrameLevel(_prevTargetFrame, data)
            UpdateCustomBorder(_prevTargetFrame, data, self.db.profile)
        end
        _prevTargetFrame = nil
    end

    local newTargetFrame = C_NamePlate.GetNamePlateForUnit("target")
    if newTargetFrame then
        local targetFrame = newTargetFrame.UnitFrame or newTargetFrame
        local unit = targetFrame.unit
        if unit and unit:find("nameplate") then
            local data = GetUnitData(targetFrame)
            if data then
                UpdateFrameLevel(targetFrame, data)
                UpdateCustomBorder(targetFrame, data, self.db.profile)
            end
        end
    end
end

function AeonoPlates:OnMouseoverChanged()
    if _prevMouseoverFrame then
        local data = GetUnitData(_prevMouseoverFrame)
        if data then
            UpdateFrameLevel(_prevMouseoverFrame, data)
            UpdateCustomBorder(_prevMouseoverFrame, data, self.db.profile)
        end
        _prevMouseoverFrame = nil
    end

    local newMouseoverFrame = C_NamePlate.GetNamePlateForUnit("mouseover")
    if newMouseoverFrame then
        local targetFrame = newMouseoverFrame.UnitFrame or newMouseoverFrame
        local unit = targetFrame.unit
        if unit and unit:find("nameplate") then
            local data = GetUnitData(targetFrame)
            if data then
                UpdateFrameLevel(targetFrame, data)
                UpdateCustomBorder(targetFrame, data, self.db.profile)
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

    if not self._PollFrame then
        local pollFrame = CreateFrame("Frame")
        local lastCheck = 0
        pollFrame:SetScript("OnUpdate", function()
            local now = GetTime()
            if now - lastCheck < 0.2 then -- ~10 FPS проверок
                return
            end
            lastCheck = now

            -- 1. Обработка снятия маусовера/цели (было)
            if _prevMouseoverFrame then
                local unit = _prevMouseoverFrame.unit or
                                 (_prevMouseoverFrame.UnitFrame and _prevMouseoverFrame.UnitFrame.unit)
                if not unit or not UnitIsUnit(unit, "mouseover") then
                    local data = GetUnitData(_prevMouseoverFrame)
                    if data then
                        UpdateFrameLevel(_prevMouseoverFrame, data)
                        UpdateCustomBorder(_prevMouseoverFrame, data, AeonoPlates.db.profile)
                    end
                    _prevMouseoverFrame = nil
                end
            end

            if _prevTargetFrame then
                local unit = _prevTargetFrame.unit or (_prevTargetFrame.UnitFrame and _prevTargetFrame.UnitFrame.unit)
                if not unit or not UnitIsUnit(unit, "target") then
                    local data = GetUnitData(_prevTargetFrame)
                    if data then
                        UpdateFrameLevel(_prevTargetFrame, data)
                        UpdateCustomBorder(_prevTargetFrame, data, AeonoPlates.db.profile)
                    end
                    _prevTargetFrame = nil
                end
            end

            local allPlates = C_NamePlate.GetNamePlates()
            for i = 1, #allPlates do
                local plate = allPlates[i]
                local targetFrame = plate.UnitFrame or plate
                local unit = targetFrame.unit
                if unit and unit:find("nameplate") and UnitExists(unit) then
                    local data = GetUnitData(targetFrame)
                    if data then
                        UpdateCustomBorder(targetFrame, data, AeonoPlates.db.profile)
                    end
                    _prevTargetFrame = nil
                end
            end
        end)
        self._PollFrame = pollFrame
    end

    -- ВОТ ЗДЕСЬ ЗАМЕНА: создаём динамический OnUpdate-фрейм для кастбара
    CreateCastBarUpdateFrame()

    -- Полный рефреш при старте
    self:RefreshAllPlates()
end

function AeonoPlates:OnDisable()
    self:UnhookAll()
    self:UnregisterAllEvents()

    if self._pollFrame then
        self._pollFrame:SetScript("OnUpdate", nil)
        self._pollFrame = nil
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
        end
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
