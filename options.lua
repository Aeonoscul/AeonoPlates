AeonoPlates = LibStub("AceAddon-3.0"):GetAddon("AeonoPlates")

-- ============================================
-- СТРУКТУРА НАСТРОЕК
-- ============================================
local options = {
    name = "AeonoPlates",
    handler = AeonoPlates,
    type = "group",
    childGroups = "tab",
    args = {
        -- ============================================
        -- NAME SETTINGS
        -- ============================================
        nameSettings = {
            type = "group",
            name = "Настройки имени",
            order = 10,
            args = {
                nameFont = {
                    type = "select",
                    name = "Шрифт имени",
                    desc = "Шрифт для имени",
                    order = 10,
                    values = function()
                        return GetFontList()
                    end,
                    set = function(info, val)
                        AeonoPlates.db.profile.nameFont = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.nameFont
                    end
                },
                nameFlags = {
                    type = "select",
                    name = "Флаги шрифта",
                    desc = "Флаги шрифта имени",
                    order = 20,
                    values = flagOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.nameFlags = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.nameFlags
                    end
                },
                classColorEnemyNames = {
                    type = "toggle",
                    name = "Цвет враж.игрока в цвет класса",
                    desc = "Окршивать имена вражеских игроков в цвета их классов",
                    order = 24,
                    set = function(info, val)
                        AeonoPlates.db.profile.classColorEnemyNames = val
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.classColorEnemyNames
                    end
                },
                classColorFriendlyNames = {
                    type = "toggle",
                    name = "Цвет союз.игрока в цвет класса",
                    desc = "Окршивать имена союзнык игроков в цвета их классов",
                    order = 25,
                    set = function(info, val)
                        AeonoPlates.db.profile.classColorFriendlyNames = val
                        AeonoPlates:ApplyCVars() -- применяем все CVar'ы
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.classColorFriendlyNames
                    end
                },
                nameWidth = {
                    type = "range",
                    name = "Ширина имени",
                    desc = "Максимальная ширина имени (пиксели)",
                    order = 30,
                    min = 20,
                    max = 500,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.nameWidth = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.nameWidth
                    end
                },
                onlyNameWidth = {
                    type = "range",
                    name = "Ширина (только имя)",
                    desc = "Максимальная ширина имени в режиме только-имя",
                    order = 31,
                    min = 20,
                    max = 500,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.onlyNameWidth = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.onlyNameWidth
                    end
                },
                nameFriendlyPlayerSize = {
                    type = "range",
                    name = "Размер (союзный игрок)",
                    desc = "Размер шрифта имени для дружественных игроков",
                    order = 35,
                    min = 6,
                    max = 48,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.nameFriendlyPlayerSize = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.nameFriendlyPlayerSize
                    end
                },
                nameEnemyPlayerSize = {
                    type = "range",
                    name = "Размер (вражеский игрок)",
                    desc = "Размер шрифта имени для вражеских игроков",
                    order = 40,
                    min = 6,
                    max = 48,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.nameEnemyPlayerSize = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.nameEnemyPlayerSize
                    end
                },
                nameFriendlyNpcSize = {
                    type = "range",
                    name = "Размер (союзный NPC)",
                    desc = "Размер шрифта имени для дружественных NPC",
                    order = 50,
                    min = 6,
                    max = 48,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.nameFriendlyNpcSize = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.nameFriendlyNpcSize
                    end
                },
                nameEnemyNpcSize = {
                    type = "range",
                    name = "Размер (вражеский NPC)",
                    desc = "Размер шрифта имени для вражеских NPC",
                    order = 60,
                    min = 6,
                    max = 48,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.nameEnemyNpcSize = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.nameEnemyNpcSize
                    end
                },
                nameAnchor = {
                    type = "select",
                    name = "Привязка имени",
                    desc = "Точка привязки имени",
                    order = 70,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.nameAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.nameAnchor
                    end
                },
                nameRelAnchor = {
                    type = "select",
                    name = "Отн. привязка имени",
                    desc = "Относительная точка привязки имени",
                    order = 80,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.nameRelAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.nameRelAnchor
                    end
                },
                nameOffsetX = {
                    type = "range",
                    name = "Смещение X",
                    desc = "Смещение имени по X",
                    order = 90,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.nameOffsetX = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.nameOffsetX
                    end
                },
                nameOffsetY = {
                    type = "range",
                    name = "Смещение Y",
                    desc = "Смещение имени по Y",
                    order = 100,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.nameOffsetY = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.nameOffsetY
                    end
                },
                onlyNameMode = {
                    type = "select",
                    name = "Только имя",
                    desc = "Включить отображение только имени для выбранных фреймов",
                    order = 110,
                    values = onlyNameOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.onlyNameMode = val;
                        AeonoPlates:ApplyCVars()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.onlyNameMode
                    end
                },
                onlyNameAnchor = {
                    type = "select",
                    name = "Привязка (только имя)",
                    desc = "Точка привязки в режиме только-имя",
                    order = 120,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.onlyNameAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.onlyNameAnchor
                    end
                },
                onlyNameOffsetX = {
                    type = "range",
                    name = "Смещение X (только имя)",
                    desc = "Смещение по X в режиме только-имя",
                    order = 130,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.onlyNameOffsetX = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.onlyNameOffsetX
                    end
                },
                onlyNameOffsetY = {
                    type = "range",
                    name = "Смещение Y (только имя)",
                    desc = "Смещение по Y в режиме только-имя",
                    order = 140,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.onlyNameOffsetY = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.onlyNameOffsetY
                    end
                }
            }
        },

        -- ============================================
        -- HEALTH SETTINGS
        -- ============================================
        healthSettings = {
            type = "group",
            name = "Настройки здоровья",
            order = 20,
            args = {
                healthBarWidth = {
                    type = "range",
                    name = "Ширина",
                    desc = "Ширина полос",
                    order = 1,
                    min = 0,
                    max = 2,
                    step = 0.05,
                    set = function(info, val)
                        AeonoPlates.db.profile.healthBarWidth = val
                        AeonoPlates:ApplyCVars() -- применяем все CVar'ы
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.healthBarWidth
                    end
                },
                healthBarHeight = {
                    type = "range",
                    name = "Высота",
                    desc = "Высота полос",
                    order = 2,
                    min = 0,
                    max = 2,
                    step = 0.05,
                    set = function(info, val)
                        AeonoPlates.db.profile.healthBarHeight = val
                        AeonoPlates:ApplyCVars() -- применяем все CVar'ы
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.healthBarHeight
                    end
                },
                classColorEnemyPlates = {
                    type = "toggle",
                    name = "Полосы враж.игроков в цвета классов",
                    desc = "Включает стандартную опцию игры для окраски полос вражеских игроков в цвет их класса",
                    order = 3,
                    set = function(info, val)
                        AeonoPlates.db.profile.classColorEnemyPlates = val
                        AeonoPlates:ApplyCVars() -- применяем все CVar'ы
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.classColorEnemyPlates
                    end
                },
                classColorFriendlyPlates = {
                    type = "toggle",
                    name = "Полосы союз.игроков в цвета классов",
                    desc = "Включает стандартную опцию игры для окраски полос союзных игроков в цвет их класса",
                    order = 4,
                    set = function(info, val)
                        AeonoPlates.db.profile.classColorFriendlyPlates = val
                        AeonoPlates:ApplyCVars() -- применяем все CVar'ы
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.classColorFriendlyPlates
                    end
                },
                healthTexture = {
                    type = "select",
                    name = "Текстура полосы",
                    desc = "Текстура полосы здоровья",
                    order = 10,
                    values = function()
                        return GetStatusBarList()
                    end,
                    set = function(info, val)
                        AeonoPlates.db.profile.healthTexture = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.healthTexture
                    end
                },
                healthFont = {
                    type = "select",
                    name = "Шрифт HP",
                    desc = "Шрифт для текста здоровья",
                    order = 11,
                    values = function()
                        return GetFontList()
                    end,
                    set = function(info, val)
                        AeonoPlates.db.profile.healthFont = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.healthFont
                    end
                },
                shortenHealth = {
                    type = "toggle",
                    name = "Сокращать здоровье",
                    desc = "Сокращать здоровье (1.2k, 3.5M)",
                    order = 20,
                    set = function(info, val)
                        AeonoPlates.db.profile.shortenHealth = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.shortenHealth
                    end
                },
                showHealthText = {
                    type = "toggle",
                    name = "Показывать текст здоровья",
                    desc = "Показывать текст здоровья",
                    order = 30,
                    set = function(info, val)
                        AeonoPlates.db.profile.showHealthText = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.showHealthText
                    end
                },
                showHealthPercent = {
                    type = "toggle",
                    name = "Показывать процент здоровья",
                    desc = "Показывать процент здоровья",
                    order = 40,
                    set = function(info, val)
                        AeonoPlates.db.profile.showHealthPercent = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.showHealthPercent
                    end
                },
                healthSize = {
                    type = "range",
                    name = "Размер шрифта HP",
                    desc = "Размер шрифта текста здоровья",
                    order = 50,
                    min = 6,
                    max = 48,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.healthSize = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.healthSize
                    end
                },
                healthFlags = {
                    type = "select",
                    name = "Флаги шрифта HP",
                    desc = "Флаги шрифта здоровья",
                    order = 60,
                    values = flagOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.healthFlags = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.healthFlags
                    end
                },
                healthAnchor = {
                    type = "select",
                    name = "Привязка HP",
                    desc = "Точка привязки текста здоровья",
                    order = 70,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.healthAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.healthAnchor
                    end
                },
                healthRelAnchor = {
                    type = "select",
                    name = "Отн. привязка HP",
                    desc = "Относительная точка привязки текста здоровья",
                    order = 80,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.healthRelAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.healthRelAnchor
                    end
                },
                healthOffsetX = {
                    type = "range",
                    name = "Смещение HP X",
                    desc = "Смещение текста здоровья по X",
                    order = 90,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.healthOffsetX = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.healthOffsetX
                    end
                },
                healthOffsetY = {
                    type = "range",
                    name = "Смещение HP Y",
                    desc = "Смещение текста здоровья по Y",
                    order = 100,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.healthOffsetY = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.healthOffsetY
                    end
                },
                healthPercentSize = {
                    type = "range",
                    name = "Размер шрифта %",
                    desc = "Размер шрифта процента здоровья",
                    order = 110,
                    min = 6,
                    max = 48,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.healthPercentSize = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.healthPercentSize
                    end
                },
                healthPercentAnchor = {
                    type = "select",
                    name = "Привязка %",
                    desc = "Точка привязки процента здоровья",
                    order = 120,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.healthPercentAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.healthPercentAnchor
                    end
                },
                healthPercentRelAnchor = {
                    type = "select",
                    name = "Отн. привязка %",
                    desc = "Относительная точка привязки процента здоровья",
                    order = 130,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.healthPercentRelAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.healthPercentRelAnchor
                    end
                },
                healthPercentOffsetX = {
                    type = "range",
                    name = "Смещение % X",
                    desc = "Смещение процента здоровья по X",
                    order = 140,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.healthPercentOffsetX = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.healthPercentOffsetX
                    end
                },
                healthPercentOffsetY = {
                    type = "range",
                    name = "Смещение % Y",
                    desc = "Смещение процента здоровья по Y",
                    order = 150,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.healthPercentOffsetY = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.healthPercentOffsetY
                    end
                }
            }
        },

        -- ============================================
        -- ICON SETTINGS
        -- ============================================
        iconSettings = {
            type = "group",
            name = "Настройки иконок",
            order = 30,
            args = {
                showEnemyClassIcons = {
                    type = "toggle",
                    name = "Иконки классов (враги)",
                    desc = "Показывать иконки классов у врагов",
                    order = 10,
                    set = function(info, val)
                        AeonoPlates.db.profile.showEnemyClassIcons = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.showEnemyClassIcons
                    end
                },
                showFriendlyClassIcons = {
                    type = "toggle",
                    name = "Иконки классов (союзники)",
                    desc = "Показывать иконки классов у союзников",
                    order = 20,
                    set = function(info, val)
                        AeonoPlates.db.profile.showFriendlyClassIcons = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.showFriendlyClassIcons
                    end
                },
                showEnemyTotemIcons = {
                    type = "toggle",
                    name = "Иконки тотемов (враги)",
                    desc = "Показывать иконки тотемов у врагов",
                    order = 30,
                    set = function(info, val)
                        AeonoPlates.db.profile.showEnemyTotemIcons = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.showEnemyTotemIcons
                    end
                },
                showFriendlyTotemIcons = {
                    type = "toggle",
                    name = "Иконки тотемов (союзники)",
                    desc = "Показывать иконки тотемов у союзников",
                    order = 40,
                    set = function(info, val)
                        AeonoPlates.db.profile.showFriendlyTotemIcons = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.showFriendlyTotemIcons
                    end
                },
                iconSize = {
                    type = "range",
                    name = "Размер иконки класса",
                    desc = "Размер иконки класса (ширина = высота)",
                    order = 50,
                    min = 8,
                    max = 64,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.iconSize = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.iconSize
                    end
                },
                totemIconSize = {
                    type = "range",
                    name = "Размер иконки тотема",
                    desc = "Размер иконки тотема (ширина = высота)",
                    order = 60,
                    min = 8,
                    max = 64,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.totemIconSize = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.totemIconSize
                    end
                },
                iconAnchor = {
                    type = "select",
                    name = "Привязка иконки",
                    desc = "Точка привязки иконки",
                    order = 90,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.iconAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.iconAnchor
                    end
                },
                iconRelAnchor = {
                    type = "select",
                    name = "Отн. привязка иконки",
                    desc = "Относительная точка привязки иконки",
                    order = 100,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.iconRelAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.iconRelAnchor
                    end
                },
                iconOffsetX = {
                    type = "range",
                    name = "Смещение иконки X",
                    desc = "Смещение иконки по X",
                    order = 110,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.iconOffsetX = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.iconOffsetX
                    end
                },
                iconOffsetY = {
                    type = "range",
                    name = "Смещение иконки Y",
                    desc = "Смещение иконки по Y",
                    order = 120,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.iconOffsetY = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.iconOffsetY
                    end
                }
            }
        },

        -- ============================================
        -- BORDER SETTINGS
        -- ============================================
        borderSettings = {
            type = "group",
            name = "Настройки границы",
            order = 40,
            args = {
                borderTexture = {
                    type = "select",
                    name = "Текстура границы",
                    desc = "Текстура границы",
                    order = 10,
                    values = function()
                        return GetBorderList()
                    end,
                    set = function(info, val)
                        AeonoPlates.db.profile.borderTexture = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.borderTexture
                    end
                },
                borderPadding = {
                    type = "range",
                    name = "Размер границы",
                    desc = "Отступ границы от края полосы здоровья",
                    order = 20,
                    min = 1,
                    max = 20,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.borderPadding = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.borderPadding
                    end
                },
                borderThickness = {
                    type = "range",
                    name = "Толщина границы",
                    desc = "Толщина границы",
                    order = 30,
                    min = 1,
                    max = 32,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.borderThickness = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.borderThickness
                    end
                },
                borderTargetColor = {
                    type = "color",
                    name = "Цвет (цель)",
                    desc = "Цвет границы для цели",
                    order = 40,
                    hasAlpha = true,
                    set = function(info, r, g, b, a)
                        local c = AeonoPlates.db.profile.borderTargetColor
                        c[1], c[2], c[3], c[4] = r, g, b, a or 1
                        RefreshBorderColorCache(AeonoPlates.db.profile)
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        local c = AeonoPlates.db.profile.borderTargetColor
                        return c[1], c[2], c[3], c[4]
                    end
                },
                borderMouseoverColor = {
                    type = "color",
                    name = "Цвет (наведение)",
                    desc = "Цвет границы при наведении",
                    order = 50,
                    hasAlpha = true,
                    set = function(info, r, g, b, a)
                        local c = AeonoPlates.db.profile.borderMouseoverColor
                        c[1], c[2], c[3], c[4] = r, g, b, a or 1
                        RefreshBorderColorCache(AeonoPlates.db.profile)
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        local c = AeonoPlates.db.profile.borderMouseoverColor
                        return c[1], c[2], c[3], c[4]
                    end
                },
                borderCombatColor = {
                    type = "color",
                    name = "Цвет (бой)",
                    desc = "Цвет границы когда юнит в бою",
                    order = 60,
                    hasAlpha = true,
                    set = function(info, r, g, b, a)
                        local c = AeonoPlates.db.profile.borderCombatColor
                        c[1], c[2], c[3], c[4] = r, g, b, a or 1
                        RefreshBorderColorCache(AeonoPlates.db.profile)
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        local c = AeonoPlates.db.profile.borderCombatColor
                        return c[1], c[2], c[3], c[4]
                    end
                },
                borderDefaultColor = {
                    type = "color",
                    name = "Цвет (по умолчанию)",
                    desc = "Цвет границы по умолчанию (когда не цель, не наведение, не бой)",
                    order = 70,
                    hasAlpha = true,
                    set = function(info, r, g, b, a)
                        local c = AeonoPlates.db.profile.borderDefaultColor
                        c[1], c[2], c[3], c[4] = r, g, b, a or 1
                        RefreshBorderColorCache(AeonoPlates.db.profile)
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        local c = AeonoPlates.db.profile.borderDefaultColor
                        return c[1], c[2], c[3], c[4]
                    end
                }
            }
        },

        -- ============================================
        -- THREAT SETTINGS
        -- ============================================
        threatSettings = {
            type = "group",
            name = "Настройки цвета",
            order = 45,
            args = {
                threatHighColor = {
                    type = "color",
                    name = "Цвет здоровья (высокая угроза)",
                    desc = "Цвет полосы здоровья при высоком уровне угрозы (танкуем)",
                    order = 10,
                    hasAlpha = true,
                    set = function(info, r, g, b, a)
                        local c = AeonoPlates.db.profile.threatHighColor
                        c[1], c[2], c[3], c[4] = r, g, b, a or 1
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        local c = AeonoPlates.db.profile.threatHighColor
                        return c[1], c[2], c[3], c[4]
                    end
                },
                threatLowColor = {
                    type = "color",
                    name = "Цвет здоровья (низкая угроза)",
                    desc = "Цвет полосы здоровья при низком уровне угрозы (не в агро-листе)",
                    order = 20,
                    hasAlpha = true,
                    set = function(info, r, g, b, a)
                        local c = AeonoPlates.db.profile.threatLowColor
                        c[1], c[2], c[3], c[4] = r, g, b, a or 1
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        local c = AeonoPlates.db.profile.threatLowColor
                        return c[1], c[2], c[3], c[4]
                    end
                },
                threatAggroColor = {
                    type = "color",
                    name = "Цвет здоровья (потеря агро)",
                    desc = "Цвет полосы здоровья при потере агро (threat 1-2)",
                    order = 30,
                    hasAlpha = true,
                    set = function(info, r, g, b, a)
                        local c = AeonoPlates.db.profile.threatAggroColor
                        c[1], c[2], c[3], c[4] = r, g, b, a or 1
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        local c = AeonoPlates.db.profile.threatAggroColor
                        return c[1], c[2], c[3], c[4]
                    end
                }
            }
        },

        -- ============================================
        -- CLASSIFICATION
        -- ============================================
        classificationSettings = {
            type = "group",
            name = "Классификация",
            order = 50,
            args = {
                showClassification = {
                    type = "toggle",
                    name = "Показывать классификацию",
                    desc = "Показывать индикатор элиты/рарности",
                    order = 10,
                    set = function(info, val)
                        AeonoPlates.db.profile.showClassification = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.showClassification
                    end
                },
                classificationSize = {
                    type = "range",
                    name = "Размер иконки",
                    desc = "Размер иконки классификации",
                    order = 20,
                    min = 8,
                    max = 64,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.classificationSize = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.classificationSize
                    end
                },
                classificationAnchor = {
                    type = "select",
                    name = "Привязка иконки",
                    desc = "Точка привязки иконки классификации",
                    order = 30,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.classificationAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.classificationAnchor
                    end
                },
                classificationRelAnchor = {
                    type = "select",
                    name = "Отн. привязка иконки",
                    desc = "Относительная точка привязки иконки классификации",
                    order = 40,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.classificationRelAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.classificationRelAnchor
                    end
                },
                classificationOffsetX = {
                    type = "range",
                    name = "Смещение X",
                    desc = "Смещение иконки классификации по X",
                    order = 50,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.classificationOffsetX = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.classificationOffsetX
                    end
                },
                classificationOffsetY = {
                    type = "range",
                    name = "Смещение Y",
                    desc = "Смещение иконки классификации по Y",
                    order = 60,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.classificationOffsetY = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.classificationOffsetY
                    end
                }
            }
        },

        -- ============================================
        -- RAID TARGET
        -- ============================================
        raidTargetSettings = {
            type = "group",
            name = "Рейдовая метка",
            order = 60,
            args = {
                raidTargetAnchor = {
                    type = "select",
                    name = "Привязка метки",
                    desc = "Точка привязки рейдовой метки",
                    order = 10,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.raidTargetAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.raidTargetAnchor
                    end
                },
                raidTargetRelAnchor = {
                    type = "select",
                    name = "Отн. привязка метки",
                    desc = "Относительная точка привязки рейдовой метки",
                    order = 20,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.raidTargetRelAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.raidTargetRelAnchor
                    end
                },
                raidTargetScale = {
                    type = "range",
                    name = "Масштаб метки",
                    desc = "Масштаб рейдовой метки",
                    order = 30,
                    min = 0.1,
                    max = 3.0,
                    step = 0.05,
                    set = function(info, val)
                        AeonoPlates.db.profile.raidTargetScale = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.raidTargetScale
                    end
                },
                raidTargetOffsetX = {
                    type = "range",
                    name = "Смещение метки X",
                    desc = "Смещение рейдовой метки по X",
                    order = 40,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.raidTargetOffsetX = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.raidTargetOffsetX
                    end
                },
                raidTargetOffsetY = {
                    type = "range",
                    name = "Смещение метки Y",
                    desc = "Смещение рейдовой метки по Y",
                    order = 50,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.raidTargetOffsetY = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.raidTargetOffsetY
                    end
                }
            }
        },

        -- ============================================
        -- SCALE SETTINGS
        -- ============================================
        scaleSettings = {
            type = "group",
            name = "Настройки масштаба",
            order = 70,
            args = {
                globalFrameScale = {
                    type = "range",
                    name = "Общий масштаб",
                    desc = "Общий масштаб фреймов",
                    order = 10,
                    min = 0.5,
                    max = 1.5,
                    step = 0.05,
                    set = function(info, val)
                        AeonoPlates.db.profile.globalFrameScale = val;
                        AeonoPlates:ApplyCVars()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.globalFrameScale
                    end
                },
                targetFrameScale = {
                    type = "range",
                    name = "Масштаб цели",
                    desc = "Масштаб выбранного фрейма",
                    order = 10,
                    min = 1,
                    max = 2,
                    step = 0.05,
                    set = function(info, val)
                        AeonoPlates.db.profile.targetFrameScale = val;
                        AeonoPlates:ApplyCVars()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.targetFrameScale
                    end
                },
                petFrameScale = {
                    type = "range",
                    name = "Масштаб петов",
                    desc = "Масштаб фрейма для петов",
                    order = 20,
                    min = 0.1,
                    max = 2.0,
                    step = 0.05,
                    set = function(info, val)
                        AeonoPlates.db.profile.petFrameScale = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.petFrameScale
                    end
                }
            }
        },

        -- ============================================
        -- CASTBAR SETTINGS
        -- ============================================
        castBarSettings = {
            type = "group",
            name = "Настройки кастбара",
            order = 80,
            args = {
                -- Visibility
                friendlyPlayerCastBar = {
                    type = "toggle",
                    name = "Кастбар (союзный игрок)",
                    desc = "Показывать кастбар у дружественных игроков",
                    order = 10,
                    set = function(info, val)
                        AeonoPlates.db.profile.friendlyPlayerCastBar = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.friendlyPlayerCastBar
                    end
                },
                enemyPlayerCastBar = {
                    type = "toggle",
                    name = "Кастбар (вражеский игрок)",
                    desc = "Показывать кастбар у вражеских игроков",
                    order = 20,
                    set = function(info, val)
                        AeonoPlates.db.profile.enemyPlayerCastBar = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.enemyPlayerCastBar
                    end
                },
                friendlyNpcCastBar = {
                    type = "toggle",
                    name = "Кастбар (союзный NPC)",
                    desc = "Показывать кастбар у дружественных NPC",
                    order = 30,
                    set = function(info, val)
                        AeonoPlates.db.profile.friendlyNpcCastBar = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.friendlyNpcCastBar
                    end
                },
                enemyNpcCastBar = {
                    type = "toggle",
                    name = "Кастбар (вражеский NPC)",
                    desc = "Показывать кастбар у вражеских NPC",
                    order = 40,
                    set = function(info, val)
                        AeonoPlates.db.profile.enemyNpcCastBar = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.enemyNpcCastBar
                    end
                },
                -- Appearance
                castBarTex = {
                    type = "select",
                    name = "Текстура кастбара",
                    desc = "Текстура полосы каста",
                    order = 50,
                    values = function()
                        return GetStatusBarList()
                    end,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarTex = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarTex
                    end
                },
                castBarFadeTime = {
                    type = "range",
                    name = "Время затухания",
                    desc = "Время затухания кастбара после завершения",
                    order = 60,
                    min = 0,
                    max = 2,
                    step = 0.05,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarFadeTime = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarFadeTime
                    end
                },
                castBarHeight = {
                    type = "range",
                    name = "Высота полосы",
                    desc = "Высота полосы каста",
                    order = 70,
                    min = 2,
                    max = 40,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarHeight = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarHeight
                    end
                },
                castBarWidth = {
                    type = "range",
                    name = "Ширина контейнера",
                    desc = "Ширина контейнера кастбара (включая иконку, если она слева/справа)",
                    order = 75,
                    min = 20,
                    max = 500,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarWidth = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarWidth
                    end
                },
                castBarShowIcon = {
                    type = "toggle",
                    name = "Показывать иконку",
                    desc = "Показывать иконку заклинания рядом с кастбаром",
                    order = 76,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarShowIcon = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarShowIcon
                    end
                },
                castBarIconSize = {
                    type = "range",
                    name = "Размер иконки",
                    desc = "Размер иконки заклинания (ширина = высота)",
                    order = 77,
                    min = 4,
                    max = 64,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarIconSize = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarIconSize
                    end
                },
                castBarIconAnchor = {
                    type = "select",
                    name = "Привязка иконки",
                    desc = "Точка привязки иконки относительно кастбара",
                    order = 78,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarIconAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarIconAnchor
                    end
                },
                castBarIconRelAnchor = {
                    type = "select",
                    name = "Отн. привязка иконки",
                    desc = "Относительная точка привязки иконки на кастбаре",
                    order = 79,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarIconRelAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarIconRelAnchor
                    end
                },
                castBarIconOffsetX = {
                    type = "range",
                    name = "Смещение иконки X",
                    desc = "Смещение иконки по X",
                    order = 80,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarIconOffsetX = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarIconOffsetX
                    end
                },
                castBarIconOffsetY = {
                    type = "range",
                    name = "Смещение иконки Y",
                    desc = "Смещение иконки по Y",
                    order = 81,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarIconOffsetY = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarIconOffsetY
                    end
                },
                castBarAnchor = {
                    type = "select",
                    name = "Привязка кастбара",
                    desc = "Точка привязки кастбара к полосе здоровья",
                    order = 82,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarAnchor = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarAnchor
                    end
                },
                castBarRelativePoint = {
                    type = "select",
                    name = "Отн. точка привязки",
                    desc = "Относительная точка привязки на полосе здоровья",
                    order = 90,
                    values = anchorOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarRelativePoint = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarRelativePoint
                    end
                },
                castBarOffsetX = {
                    type = "range",
                    name = "Смещение кастбара X",
                    desc = "Смещение кастбара по X",
                    order = 100,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarOffsetX = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarOffsetX
                    end
                },
                castBarOffsetY = {
                    type = "range",
                    name = "Смещение кастбара Y",
                    desc = "Смещение кастбара по Y",
                    order = 110,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarOffsetY = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarOffsetY
                    end
                },
                castBarColor = {
                    type = "color",
                    name = "Цвет каста",
                    desc = "Цвет полосы каста",
                    order = 120,
                    hasAlpha = true,
                    set = function(info, r, g, b, a)
                        local c = AeonoPlates.db.profile.castBarColor
                        c[1], c[2], c[3], c[4] = r, g, b, a or 1
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        local c = AeonoPlates.db.profile.castBarColor
                        return c[1], c[2], c[3], c[4]
                    end
                },
                castBarSuccessColor = {
                    type = "color",
                    name = "Цвет (успех)",
                    desc = "Цвет при успешном завершении",
                    order = 130,
                    hasAlpha = true,
                    set = function(info, r, g, b, a)
                        local c = AeonoPlates.db.profile.castBarSuccessColor
                        c[1], c[2], c[3], c[4] = r, g, b, a or 1
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        local c = AeonoPlates.db.profile.castBarSuccessColor
                        return c[1], c[2], c[3], c[4]
                    end
                },
                castBarFailedColor = {
                    type = "color",
                    name = "Цвет (провал)",
                    desc = "Цвет при прерывании/провале каста",
                    order = 140,
                    hasAlpha = true,
                    set = function(info, r, g, b, a)
                        local c = AeonoPlates.db.profile.castBarFailedColor
                        c[1], c[2], c[3], c[4] = r, g, b, a or 1
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        local c = AeonoPlates.db.profile.castBarFailedColor
                        return c[1], c[2], c[3], c[4]
                    end
                },
                castBarShieldColor = {
                    type = "color",
                    name = "Цвет (непрерываемый)",
                    desc = "Цвет для не-прерываемых заклинаний",
                    order = 150,
                    hasAlpha = true,
                    set = function(info, r, g, b, a)
                        local c = AeonoPlates.db.profile.castBarShieldColor
                        c[1], c[2], c[3], c[4] = r, g, b, a or 1
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        local c = AeonoPlates.db.profile.castBarShieldColor
                        return c[1], c[2], c[3], c[4]
                    end
                },
                castBarBgColor = {
                    type = "color",
                    name = "Цвет фона",
                    desc = "Цвет фона кастбара",
                    order = 160,
                    hasAlpha = true,
                    set = function(info, r, g, b, a)
                        local c = AeonoPlates.db.profile.castBarBgColor
                        c[1], c[2], c[3], c[4] = r, g, b, a or 1
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        local c = AeonoPlates.db.profile.castBarBgColor
                        return c[1], c[2], c[3], c[4]
                    end
                },
                castNameFont = {
                    type = "select",
                    name = "Шрифт названия",
                    desc = "Шрифт имени заклинания",
                    order = 170,
                    values = function()
                        return GetFontList()
                    end,
                    set = function(info, val)
                        AeonoPlates.db.profile.castNameFont = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castNameFont
                    end
                },
                castNameSize = {
                    type = "range",
                    name = "Размер шрифта",
                    desc = "Размер шрифта имени заклинания",
                    order = 180,
                    min = 6,
                    max = 48,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.castNameSize = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castNameSize
                    end
                },
                castNameWidth = {
                    type = "range",
                    name = "Ширина текста",
                    desc = "Максимальная ширина имени заклинания",
                    order = 190,
                    min = 20,
                    max = 500,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.castNameWidth = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castNameWidth
                    end
                },
                castNameFlags = {
                    type = "select",
                    name = "Флаги шрифта",
                    desc = "Флаги шрифта имени заклинания",
                    order = 200,
                    values = flagOptions,
                    set = function(info, val)
                        AeonoPlates.db.profile.castNameFlags = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castNameFlags
                    end
                },
                castNameColor = {
                    type = "color",
                    name = "Цвет названия",
                    desc = "Цвет имени заклинания",
                    order = 210,
                    hasAlpha = true,
                    set = function(info, r, g, b, a)
                        local c = AeonoPlates.db.profile.castNameColor
                        c[1], c[2], c[3], c[4] = r, g, b, a or 1
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        local c = AeonoPlates.db.profile.castNameColor
                        return c[1], c[2], c[3], c[4]
                    end
                },
                castNameOffsetX = {
                    type = "range",
                    name = "Смещение названия X",
                    desc = "Смещение имени заклинания по X",
                    order = 220,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.castNameOffsetX = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castNameOffsetX
                    end
                },
                castNameOffsetY = {
                    type = "range",
                    name = "Смещение названия Y",
                    desc = "Смещение имени заклинания по Y",
                    order = 230,
                    min = -200,
                    max = 200,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.castNameOffsetY = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castNameOffsetY
                    end
                },
                castBarSparkWidth = {
                    type = "range",
                    name = "Ширина спарка",
                    desc = "Ширина спарка",
                    order = 240,
                    min = 4,
                    max = 64,
                    step = 1,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarSparkWidth = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarSparkWidth
                    end
                },
                castBarSparkHeightMultiplier = {
                    type = "range",
                    name = "Множитель высоты спарка",
                    desc = "Множитель высоты спарка относительно высоты бара",
                    order = 250,
                    min = 0.5,
                    max = 3.0,
                    step = 0.1,
                    set = function(info, val)
                        AeonoPlates.db.profile.castBarSparkHeightMultiplier = val;
                        AeonoPlates:RefreshAllPlates()
                    end,
                    get = function(info)
                        return AeonoPlates.db.profile.castBarSparkHeightMultiplier
                    end
                }
            }
        }
    }
}

-- Сохраняем таблицу настроек в аддон (регистрация происходит в core.lua:OnInitialize)
AeonoPlates.optionsTable = options
