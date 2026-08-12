--// Slap Battles - Real Working Infinite Ability
--// Bypass Anti-Cooldown Check & Server Sync

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Удаление старого UI
if CoreGui:FindFirstChild("SB_InfAbility_UI") then
    CoreGui.SB_InfAbility_UI:Destroy()
end

--// Создание интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SB_InfAbility_UI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.4, -75)
MainFrame.Size = UDim2.new(0, 300, 0, 160)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Color = Color3.fromRGB(120, 40, 255)
UIStroke.Thickness = 2

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 10)
Title.Size = UDim2.new(1, -30, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "Slap Battles | Inf Ability"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleBtn.Position = UDim2.new(0, 15, 0, 50)
ToggleBtn.Size = UDim2.new(1, -30, 0, 45)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "Enable Inf Ability: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
ToggleBtn.TextSize = 14
ToggleBtn.AutoButtonColor = false

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = MainFrame
InfoLabel.BackgroundTransparency = 1
InfoLabel.Position = UDim2.new(0, 15, 0, 105)
InfoLabel.Size = UDim2.new(1, -30, 0, 40)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Text = "Press 'E' to spam ability instantly.\nBypasses local cooldown timers."
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
InfoLabel.TextSize = 11

--// ЛОГИКА СБРОСА КУЛДАУНА
local Enabled = false

-- Функция очистки ограничений с персонажа
local function ClearCooldowns()
    local char = LocalPlayer.Character
    if not char then return end

    -- 1. Удаление локальных значений Cooldown, если перчатка занесла их в персонажа
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("BoolValue") or v:IsA("StringValue") or v:IsA("NumberValue") then
            if string.find(string.lower(v.Name), "cooldown") or string.find(string.lower(v.Name), "ability") or v.Name == "CD" then
                v:Destroy()
            end
        end
    end

    -- 2. Сброс атрибутов
    for attr, _ in pairs(char:GetAttributes()) do
        if string.find(string.lower(attr), "cooldown") or string.find(string.lower(attr), "cd") or string.find(string.lower(attr), "used") then
            char:SetAttribute(attr, nil)
        end
    end
end

-- Основной цикл снятия блокировок
RunService.Stepped:Connect(function()
    if Enabled then
        ClearCooldowns()
    end
end)

-- Вызов способности без задержки (байпас нажатием клавиши E)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not Enabled then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        local char = LocalPlayer.Character
        if not char then return end
        
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            -- Ищем и вызываем все RemoteEvent, находящиеся внутри перчатки
            for _, v in pairs(tool:GetDescendants()) do
                if v:IsA("RemoteEvent") then
                    v:FireServer()
                end
            end
        end
        
        -- Вызываем глобальные события способностей из ReplicatedStorage
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and (remote.Name == "GeneralAbility" or remote.Name == "RojoAbility" or remote.Name == "Rhythm") then
                remote:FireServer()
            end
        end
    end
end)

-- Переключатель UI
ToggleBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    if Enabled then
        ToggleBtn.Text = "Enable Inf Ability: ON"
        ToggleBtn.TextColor3 = Color3.fromRGB(75, 255, 125)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 45)
    else
        ToggleBtn.Text = "Enable Inf Ability: OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    end
end)
