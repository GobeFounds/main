local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Moon - Hub",
    LoadingTitle = "MOON - X HUB",
    LoadingSubtitle = "by - Lotus",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "MoonConfig"
    },
    Theme = {
        TextColor = Color3.fromRGB(230, 230, 230),
        Background = Color3.fromRGB(20, 20, 22),
        Topbar = Color3.fromRGB(26, 26, 28),
        Shadow = Color3.fromRGB(10, 10, 10),
        NotificationBackground = Color3.fromRGB(25, 25, 28),
        NotificationActionsBackground = Color3.fromRGB(40, 40, 45),
        TabBackground = Color3.fromRGB(35, 35, 38),
        TabStroke = Color3.fromRGB(55, 55, 60),
        TabBackgroundSelected = Color3.fromRGB(45, 45, 48),
        TabTextColor = Color3.fromRGB(200, 200, 200),
        SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(32, 32, 35),
        ElementBackgroundHover = Color3.fromRGB(38, 38, 42),
        SecondaryElementBackground = Color3.fromRGB(26, 26, 28),
        ElementStroke = Color3.fromRGB(50, 50, 55),
        SecondaryElementStroke = Color3.fromRGB(40, 40, 45),
        SliderBackground = Color3.fromRGB(45, 45, 48),
        SliderProgress = Color3.fromRGB(120, 120, 120),
        SliderStroke = Color3.fromRGB(90, 90, 90),
        ToggleBackground = Color3.fromRGB(35, 35, 38),
        ToggleEnabled = Color3.fromRGB(150, 150, 150),
        ToggleDisabled = Color3.fromRGB(90, 90, 90),
        ToggleEnabledStroke = Color3.fromRGB(120, 120, 120),
        ToggleDisabledStroke = Color3.fromRGB(70, 70, 70),
        ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
        ToggleDisabledOuterStroke = Color3.fromRGB(55, 55, 55),
        DropdownSelected = Color3.fromRGB(38, 38, 42),
        DropdownUnselected = Color3.fromRGB(30, 30, 34),
        InputBackground = Color3.fromRGB(28, 28, 30),
        InputStroke = Color3.fromRGB(60, 60, 65),
        PlaceholderColor = Color3.fromRGB(160, 160, 160)
    }
})

local CONFIG = {
    WELCOME_NOTIFICATION = 13492315901,
    LAUNCH_ICON = 16149155528,
    ERROR_ICON = 17829927053,
}

local AntiAFK = {}
AntiAFK.Config = {
    ENABLED = false,
    TEST_MODE = false,
    IDLE_CHECK_MIN = 1,
    IDLE_CHECK_MAX = 2,
    IDLE_CHECK_MIN_PROD = 2,
    IDLE_CHECK_MAX_PROD = 5,
    INPUT_DELAY_MIN = 0.5,
    INPUT_DELAY_MAX = 1.5,
    SHOW_LOGS = false,
    SHOW_UPTIME = true,
    SHOW_NOTIFICATIONS = true
}

AntiAFK.Stats = {
    inputCount = 0,
    lastInputTime = tick(),
    scriptStartTime = tick()
}

AntiAFK.Connections = {
    idleConnection = nil,
    inputConnection = nil,
    backgroundTask = nil
}

local AutoSell = {
    Enabled = false,
    Delay = 60,
    Running = false,
    SellCount = 0
}

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local randomOffsets = {}

for i = 1, 10 do
    table.insert(randomOffsets, Vector2.new(
        math.random(-5, 5),
        math.random(-5, 5)
    ))
end

local function getRandomOffset()
    return randomOffsets[math.random(1, #randomOffsets)]
end

local function getUptime()
    if not AntiAFK.Config.SHOW_UPTIME then return "" end
    local uptime = tick() - AntiAFK.Stats.scriptStartTime
    local hours = math.floor(uptime / 3600)
    local minutes = math.floor((uptime % 3600) / 60)
    local seconds = math.floor(uptime % 60)
    return string.format(" | Uptime: %02d:%02d:%02d", hours, minutes, seconds)
end

function AntiAFK:SimulateInput()
    if not self.Config.ENABLED then return end
    
    local offset = getRandomOffset()
    local randomDelay = math.random(
        self.Config.INPUT_DELAY_MIN * 100, 
        self.Config.INPUT_DELAY_MAX * 100
    ) / 100
    
    VirtualUser:CaptureController()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(randomDelay)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    
    self.Stats.inputCount = self.Stats.inputCount + 1
    self.Stats.lastInputTime = tick()
    
    if self.Config.SHOW_LOGS then
        print(string.format("[Anti-AFK] Input #%d%s", 
            self.Stats.inputCount, getUptime()))
    end
    
    if self.Config.SHOW_NOTIFICATIONS then
        Rayfield:Notify({
            Title = "Anti-AFK",
            Content = "Successfully triggered! Input #" .. self.Stats.inputCount,
            Duration = 3,
            Image = CONFIG.LAUNCH_ICON
        })
    end
    
    return self.Stats.inputCount
end

function AntiAFK:GetStats()
    return {
        inputCount = self.Stats.inputCount,
        uptime = tick() - self.Stats.scriptStartTime,
        lastInput = self.Stats.lastInputTime
    }
end

function AntiAFK:ResetStats()
    self.Stats.inputCount = 0
    self.Stats.scriptStartTime = tick()
    if self.Config.SHOW_LOGS then
        print("[Anti-AFK] Statistics reset")
    end
end

function AntiAFK:GetCurrentInterval()
    if self.Config.TEST_MODE then
        return self.Config.IDLE_CHECK_MIN, self.Config.IDLE_CHECK_MAX
    else
        return self.Config.IDLE_CHECK_MIN_PROD, self.Config.IDLE_CHECK_MAX_PROD
    end
end

function AntiAFK:Start()
    if self.Connections.idleConnection then return end
    
    self.Connections.idleConnection = player.Idled:Connect(function()
        if not self.Config.ENABLED then return end
        if self.Config.SHOW_LOGS then
            print("[Anti-AFK] Idle event detected")
        end
        self:SimulateInput()
    end)
    
    self.Connections.backgroundTask = task.spawn(function()
        while task.wait(1) do
            if not self.Config.ENABLED then 
                task.wait(1)
                continue 
            end
            
            local minInterval, maxInterval = self:GetCurrentInterval()
            local waitTime = math.random(minInterval * 60, maxInterval * 60)
            
            if self.Config.SHOW_LOGS then
                print(string.format("[Anti-AFK] Next check in %.1f minutes", waitTime / 60))
            end
            
            task.wait(waitTime)
            
            if not self.Config.ENABLED then continue end
            
            local timeSinceLastInput = tick() - self.Stats.lastInputTime
            if timeSinceLastInput > 30 then
                if self.Config.SHOW_LOGS then
                    print(string.format("[Anti-AFK] Background check (%.0fm ago)", 
                        timeSinceLastInput / 60))
                end
                self:SimulateInput()
            end
        end
    end)
    
    self.Connections.inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            self.Stats.lastInputTime = tick()
        end
    end)
    
    if self.Config.SHOW_LOGS then
        print("[Anti-AFK] System initialized (Disabled by default)")
    end
end

function AntiAFK:Stop()
    if self.Connections.idleConnection then
        self.Connections.idleConnection:Disconnect()
        self.Connections.idleConnection = nil
    end
    
    if self.Connections.inputConnection then
        self.Connections.inputConnection:Disconnect()
        self.Connections.inputConnection = nil
    end
    
    if self.Config.SHOW_LOGS then
        print("[Anti-AFK] System stopped")
    end
end

local function SellAllItems()
    local success, err = pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("Packages")
            :WaitForChild("_Index")
            :WaitForChild("sleitnick_net@0.2.0")
            :WaitForChild("net")
            :WaitForChild("RF/SellAllItems")
            :InvokeServer()
    end)
    
    if success then
        AutoSell.SellCount = AutoSell.SellCount + 1
        Rayfield:Notify({
            Title = "Auto Sell All",
            Content = "Items sold successfully! Count: " .. AutoSell.SellCount,
            Duration = 3,
            Image = CONFIG.LAUNCH_ICON
        })
        return true
    else
        Rayfield:Notify({
            Title = "Auto Sell All",
            Content = "Failed to sell items: " .. tostring(err),
            Duration = 3,
            Image = CONFIG.ERROR_ICON
        })
        return false
    end
end

local function StartAutoSell()
    if AutoSell.Running then return end
    AutoSell.Running = true
    
    task.spawn(function()
        while AutoSell.Enabled and AutoSell.Running do
            SellAllItems()
            task.wait(AutoSell.Delay)
        end
        AutoSell.Running = false
    end)
end

local function StopAutoSell()
    AutoSell.Running = false
end

AntiAFK:Start()

local MainTab = Window:CreateTab("Fish It", 515816713)
local MainSection = MainTab:CreateSection("Fish It - Features")

local AntiAFKToggle = MainTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFKToggle",
    Callback = function(Value)
        AntiAFK.Config.ENABLED = Value
        
        if Value then
            Rayfield:Notify({
                Title = "Anti-AFK",
                Content = "Enabled! Running in " .. (AntiAFK.Config.TEST_MODE and "TEST MODE (1-2 min)" or "PRODUCTION MODE (2-5 min)"),
                Duration = 4,
                Image = CONFIG.LAUNCH_ICON
            })
            
            if AntiAFK.Config.SHOW_LOGS then
                local minInterval, maxInterval = AntiAFK:GetCurrentInterval()
                print(string.format("[Anti-AFK] ENABLED | Mode: %s | Interval: %d-%d min",
                    AntiAFK.Config.TEST_MODE and "TEST" or "PRODUCTION",
                    minInterval, maxInterval))
            end
        else
            Rayfield:Notify({
                Title = "Anti-AFK",
                Content = "Disabled",
                Duration = 3,
                Image = CONFIG.ERROR_ICON
            })
            
            if AntiAFK.Config.SHOW_LOGS then
                print("[Anti-AFK] DISABLED")
            end
        end
    end,
})

MainTab:CreateButton({
    Name = "Auto Sell All",
    Callback = function()
        SellAllItems()
    end
})

local AutoSellToggle = MainTab:CreateToggle({
    Name = "Auto Sell Loop",
    CurrentValue = false,
    Flag = "AutoSellToggle",
    Callback = function(Value)
        AutoSell.Enabled = Value
        
        if Value then
            StartAutoSell()
            Rayfield:Notify({
                Title = "Auto Sell Loop",
                Content = "Enabled! Selling every " .. AutoSell.Delay .. " seconds",
                Duration = 4,
                Image = CONFIG.LAUNCH_ICON
            })
        else
            StopAutoSell()
            Rayfield:Notify({
                Title = "Auto Sell Loop",
                Content = "Disabled",
                Duration = 3,
                Image = CONFIG.ERROR_ICON
            })
        end
    end,
})

local AutoSellDelayInput = MainTab:CreateInput({
    Name = "Auto Sell Delay (seconds)",
    PlaceholderText = "60",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local delay = tonumber(Text)
        if delay and delay >= 1 then
            AutoSell.Delay = delay
            Rayfield:Notify({
                Title = "Auto Sell Delay",
                Content = "Set to " .. delay .. " seconds",
                Duration = 3,
                Image = CONFIG.LAUNCH_ICON
            })
        else
            Rayfield:Notify({
                Title = "Auto Sell Delay",
                Content = "Invalid delay! Must be >= 1 second",
                Duration = 3,
                Image = CONFIG.ERROR_ICON
            })
        end
    end,
})

Rayfield:Notify({
    Title = "Welcome To Moon HUB!",
    Content = "Fish It Features, Loaded Successfully!",
    Image = CONFIG.WELCOME_NOTIFICATION,
    Duration = 5
})
