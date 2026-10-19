-- ================================================================
--                    BLOX FRUITS AIMBOT HUB
--                      Главный загрузчик
-- ================================================================

-- Проверяем, что игра загружена
if not game:IsLoaded() then game.Loaded:Wait() end

-- Защита GUI
if not syn or not protectgui then getgenv().protectgui = function() end end

-- URL репозитория
local REPO_URL = "https://raw.githubusercontent.com/xKaizoReturns/e/refs/heads/main/"

-- Система загрузки модулей с кешированием
local ModuleCache = {}
local function LoadModule(moduleName)
    if ModuleCache[moduleName] then
        print("📦 Модуль из кеша:", moduleName)
        return ModuleCache[moduleName]
    end
    
    local success, result = pcall(function()
        local moduleCode
        if readfile and isfile and isfile("Context/modules/" .. moduleName .. ".lua") then
            moduleCode = readfile("Context/modules/" .. moduleName .. ".lua")
        elseif readfile and isfile and isfile(moduleName .. ".lua") then
            moduleCode = readfile(moduleName .. ".lua")
        else
            moduleCode = game:HttpGet(REPO_URL .. "modules/" .. moduleName .. ".lua")
        end
        return loadstring(moduleCode)()
    end)
    
    if success then
        ModuleCache[moduleName] = result
        print("✅ Модуль загружен:", moduleName)
        return result
    else
        warn("❌ Ошибка загрузки модуля:", moduleName, tostring(result))
        return nil
    end
end

-- Загружаем модули в правильном порядке
print("🚀 Загрузка Blox Fruits AimBot Hub...")

local Core = LoadModule("Core")
local Utils = LoadModule("Utils") 
local GUI = LoadModule("GUI")
local AimBot = LoadModule("AimBot")
local Soru = LoadModule("Soru")
local ESP = LoadModule("ESP")

-- Проверяем успешность загрузки
if not (Core and Utils and GUI and AimBot and Soru and ESP) then
    error("❌ Критическая ошибка: не удалось загрузить один или несколько модулей")
    return
end

-- === ИНИЦИАЛИЗАЦИЯ СИСТЕМЫ ===
local Hub = {}

-- Инициализируем ядро
Hub.Core = Core:Initialize()
Hub.Utils = Utils:Initialize(Hub.Core)

-- Инициализируем GUI
Hub.GUI = GUI:Initialize(Hub.Core, Hub.Utils)

-- Инициализируем функциональные модули
Hub.AimBot = AimBot:Initialize(Hub.Core, Hub.GUI, Hub.Utils)
Hub.Soru = Soru:Initialize(Hub.Core, Hub.GUI, Hub.Utils)
Hub.ESP = ESP:Initialize(Hub.Core, Hub.GUI, Hub.Utils)

-- Запускаем главные циклы
Hub.Core:StartMainLoops()

-- Сохраняем ссылку глобально
getgenv().BloxFruitsHub = Hub

print("🎉 Blox Fruits AimBot Hub успешно загружен!")
print("📋 Доступные модули:", "Core, GUI, AimBot, Soru, ESP")
