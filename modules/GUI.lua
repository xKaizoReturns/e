-- ================================================================
--                      МОДУЛЬ GUI (GUI.lua)
-- ================================================================

local GUI = {}
GUI.__index = GUI

function GUI:Initialize(core, utils)
    local self = setmetatable({}, GUI)
    self.Core = core
    self.Utils = utils
    
    self:LoadLibrary()
    self:CreateInterface()
    self:SetupEventHandlers()
    
    print("✅ GUI инициализирован")
    return self
end

function GUI:LoadLibrary()
    -- Загрузка LinoriaLib
    local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
    self.Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
    self.ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
    self.SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
    
    -- Создание главного окна
    self.Window = self.Library:CreateWindow({
        Title = 'Blox Fruits AimBot Hub',
        Center = true,
        AutoShow = true,
        TabPadding = 8,
        MenuFadeTime = 0.2
    })
    
    self.MainTab = self.Window:AddTab('Main')
end

function GUI:CreateInterface()
    -- === AIM GROUP ===
    local AimGroup = self.MainTab:AddLeftGroupbox('Aim Bot')
    
    AimGroup:AddToggle('AimBotEnabled', {
        Text = 'Enable Aim Bot',
        Default = self.Core.Config.AimBot.Enabled,
        Tooltip = 'Toggle silent aim functionality'
    })
    
    AimGroup:AddDropdown('AimBotMethod', {
        Values = {'Ray', 'FireServer'},
        Default = self.Core.Config.AimBot.Method,
        Multi = false,
        Text = 'Aim Bot Method',
        Tooltip = 'Select the aim bot method'
    })
    
    AimGroup:AddToggle('ShowFOV', {
        Text = 'Show FOV Circle',
        Default = self.Core.Config.AimBot.ShowFOV,
        Tooltip = 'Display FOV circle on screen'
    })
    
    AimGroup:AddToggle('CheckNPC', {
        Text = 'Target NPCs',
        Default = self.Core.Config.AimBot.CheckNPC,
        Tooltip = 'Include NPCs as targets'
    })
    
    AimGroup:AddToggle('Gun', {
        Text = 'Gun Aimbot',
        Default = self.Core.Config.AimBot.Gun,
        Tooltip = 'Enable gun aimbot'
    })
    
    AimGroup:AddSlider('FOVRadius', {
        Text = 'FOV Size',
        Default = self.Core.Config.AimBot.FOVRadius,
        Min = 50,
        Max = 700,
        Rounding = 0,
        Tooltip = 'Adjust FOV circle radius'
    })
    
    -- === SORU GROUP ===
    local SoruGroup = self.MainTab:AddLeftGroupbox('Soru Enhancement')
    
    SoruGroup:AddToggle('SoruEnabled', {
        Text = 'Enhanced Soru',
        Default = self.Core.Config.Soru.Enabled,
        Tooltip = 'Enable aimbot-enhanced Soru teleportation'
    })
    
    -- === ESP GROUP ===
    local ESPGroup = self.MainTab:AddLeftGroupbox('ESP System')
    
    ESPGroup:AddToggle('ESPEnabled', {
        Text = 'Enable ESP',
        Default = self.Core.Config.ESP.Enabled,
        Tooltip = 'Toggle ESP visibility'
    })
    
    ESPGroup:AddToggle('ShowBoxes', {
        Text = 'Show Boxes',
        Default = self.Core.Config.ESP.ShowBoxes,
        Tooltip = 'Show bounding boxes'
    })
    
    ESPGroup:AddToggle('ShowNames', {
        Text = 'Show Names',
        Default = self.Core.Config.ESP.ShowName,
        Tooltip = 'Show player names'
    })
    
    ESPGroup:AddToggle('ShowHealth', {
        Text = 'Show Health',
        Default = self.Core.Config.ESP.ShowHealth,
        Tooltip = 'Show health information'
    })
    
    ESPGroup:AddToggle('ShowDistance', {
        Text = 'Show Distance',
        Default = self.Core.Config.ESP.ShowDistance,
        Tooltip = 'Show distance to targets'
    })
    
    -- === SERVER TOOLS ===
    local ServerGroup = self.MainTab:AddRightGroupbox('Server Tools')
    
    ServerGroup:AddButton({
        Text = 'Copy Job ID',
        Func = function()
            if setclipboard then
                setclipboard(game.JobId)
                self.Library:Notify('Job ID copied to clipboard!', 3)
            else
                self.Library:Notify('Clipboard not supported', 3)
            end
        end,
        Tooltip = 'Copy current server Job ID'
    })
    
    ServerGroup:AddInput('JobIdInput', {
        Default = '',
        Numeric = false,
        Text = 'Job ID',
        Tooltip = 'Enter Job ID to join specific server',
        Placeholder = 'Paste Job ID here...'
    })
    
    ServerGroup:AddButton({
        Text = 'Join by Job ID',
        Func = function()
            local jobId = Options.JobIdInput.Value
            if jobId and jobId ~= '' then
                pcall(function()
                    self.Core.Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, self.Core.LocalPlayer)
                end)
            end
        end,
        Tooltip = 'Join server by Job ID'
    })
    
    ServerGroup:AddButton({
        Text = 'Rejoin Server',
        Func = function()
            pcall(function()
                self.Core.Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, self.Core.LocalPlayer)
            end)
        end,
        Tooltip = 'Rejoin current server'
    })
    
    -- === SETTINGS GROUP ===
    local SettingsGroup = self.MainTab:AddRightGroupbox('Settings')
    
    SettingsGroup:AddToggle('AimAtCursor', {
        Text = 'Aim At Cursor',
        Default = self.Core.Config.AimBot.AimAtCursor,
        Tooltip = 'Target closest to cursor instead of screen center'
    })
    
    SettingsGroup:AddToggle('PredictionEnabled', {
        Text = 'Prediction',
        Default = self.Core.Config.AimBot.Prediction.Enabled,
        Tooltip = 'Predict target movement'
    })
    
    SettingsGroup:AddSlider('PredictionStrength', {
        Text = 'Prediction Strength',
        Default = self.Core.Config.AimBot.Prediction.Strength,
        Min = 0,
        Max = 0.5,
        Rounding = 3,
        Tooltip = 'Higher values = more prediction'
    })
    
    SettingsGroup:AddSlider('MaxDistance', {
        Text = 'Max Distance',
        Default = self.Core.Config.AimBot.Filtering.MaxDistance,
        Min = 500,
        Max = 10000,
        Rounding = 0,
        Suffix = ' studs',
        Tooltip = 'Maximum distance for targets'
    })
    
    SettingsGroup:AddButton({
        Text = 'Destroy GUI',
        Func = function()
            self.Library:Unload()
        end,
        Tooltip = 'Completely remove the GUI'
    })
end

function GUI:SetupEventHandlers()
    local Toggles = getgenv().Toggles or Toggles
    local Options = getgenv().Options or Options

    -- AimBot event handlers
    Toggles.AimBotEnabled:OnChanged(function() 
        self.Core.Config.AimBot.Enabled = Toggles.AimBotEnabled.Value 
    end)
    
    Options.AimBotMethod:OnChanged(function() 
        self.Core.Config.AimBot.Method = Options.AimBotMethod.Value 
    end)
    
    Toggles.ShowFOV:OnChanged(function() 
        self.Core.Config.AimBot.ShowFOV = Toggles.ShowFOV.Value 
    end)
    
    Toggles.CheckNPC:OnChanged(function() 
        self.Core.Config.AimBot.CheckNPC = Toggles.CheckNPC.Value 
    end)
    
    Toggles.Gun:OnChanged(function() 
        self.Core.Config.AimBot.Gun = Toggles.Gun.Value 
    end)
    
    -- Soru event handlers
    Toggles.SoruEnabled:OnChanged(function() 
        self.Core.Config.Soru.Enabled = Toggles.SoruEnabled.Value 
    end)
    
    -- ESP event handlers
    Toggles.ESPEnabled:OnChanged(function() 
        self.Core.Config.ESP.Enabled = Toggles.ESPEnabled.Value 
    end)
    
    Toggles.ShowBoxes:OnChanged(function() 
        self.Core.Config.ESP.ShowBoxes = Toggles.ShowBoxes.Value 
    end)
    
    Toggles.ShowNames:OnChanged(function() 
        self.Core.Config.ESP.ShowName = Toggles.ShowNames.Value 
    end)
    
    Toggles.ShowHealth:OnChanged(function() 
        self.Core.Config.ESP.ShowHealth = Toggles.ShowHealth.Value 
    end)
    
    Toggles.ShowDistance:OnChanged(function() 
        self.Core.Config.ESP.ShowDistance = Toggles.ShowDistance.Value 
    end)
    
    -- Settings event handlers
    Toggles.AimAtCursor:OnChanged(function() 
        self.Core.Config.AimBot.AimAtCursor = Toggles.AimAtCursor.Value 
    end)
    
    Toggles.PredictionEnabled:OnChanged(function() 
        self.Core.Config.AimBot.Prediction.Enabled = Toggles.PredictionEnabled.Value 
    end)
    
    Options.PredictionStrength:OnChanged(function() 
        self.Core.Config.AimBot.Prediction.Strength = Options.PredictionStrength.Value 
    end)
    
    Options.MaxDistance:OnChanged(function() 
        self.Core.Config.AimBot.Filtering.MaxDistance = Options.MaxDistance.Value 
    end)
    
    Options.FOVRadius:OnChanged(function() 
        self.Core.Config.AimBot.FOVRadius = Options.FOVRadius.Value 
    end)
end

function GUI:GetToggleValue(name)
    local Toggles = getgenv().Toggles or Toggles
    return Toggles and Toggles[name] and Toggles[name].Value or false
end

function GUI:GetOptionValue(name)
    local Options = getgenv().Options or Options
    return Options and Options[name] and Options[name].Value or nil
end

return GUI
