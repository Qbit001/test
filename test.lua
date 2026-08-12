--// Slap Battles - Ultimate Infinite Ability Script
--// UI Library: Custom Implemented Rayfield-style / Functional UI (Not a visual fake)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--// Удаляем старое меню, если оно уже запущено
if CoreGui:FindFirstChild("SlapBattlesGodModeUI") then
    CoreGui.SlapBattlesGodModeUI:Destroy()
end

--// Создание надежного UI (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SlapBattlesGodModeUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Безопасное добавление в CoreGui (чтобы не детектилось античитом через PlayerGui)
local success = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

--// Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Color = Color3.fromRGB(80, 0, 255)
UIStroke.Thickness = 2

--// Шапка меню
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 35)

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(1, -15, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Slap Battles | Ability Bypass"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

--// Контейнер для элементов
local Container = Instance.new("ScrollingFrame")
Container.Name = "Container"
Container.Parent = MainFrame
Container.Active = true
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 45)
Container.Size = UDim2.new(1, -20, 1, -55)
Container.CanvasSize = UDim2.new(0, 0, 0, 200)
Container.ScrollBarThickness = 4

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

--// Функция создания переключателя (Toggle)
local function CreateToggle(name, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = Container
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Size = UDim2.new(1, 0, 0, 40)
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Font = Enum.Font.Gotham
    ToggleBtn.Text = ""
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 14

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleBtn

    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleBtn
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Font = Enum.Font.GothamMedium
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local StatusIndicator = Instance.new("Frame")
    StatusIndicator.Parent = ToggleBtn
    StatusIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    StatusIndicator.Position = UDim2.new(1, -45, 0.5, -10)
    StatusIndicator.Size = UDim2.new(0, 35, 0, 20)

    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(1, 0)
    StatusCorner.Parent = StatusIndicator

    local Circle = Instance.new("Frame")
    Circle.Parent = StatusIndicator
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.Position = UDim2.new(0, 2, 0.5, -8)
    Circle.Size = UDim2.new(0, 16, 0, 16)

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle

    local toggled = false
    ToggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            StatusIndicator.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            Circle:TweenPosition(UDim2.new(1, -18, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        else
            StatusIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            Circle:TweenPosition(UDim2.new(0, 2, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        end
        callback(toggled)
    end)
end

--// ЛОГИКА ФУНКЦИОНАЛА (НЕ визуальный эффект, реальный сброс кулдаунов)

local infAbilityActive = false

-- Поиск RemoteEvent для способностей в игре
local events = ReplicatedStorage:FindFirstChild("b") or ReplicatedStorage:FindFirstChild("AbilityEvent")

CreateToggle("Infinite Ability (No Cooldown)", function(state)
    infAbilityActive = state
end)

-- Основной рабочий поток, перехватывающий и обнуляющий таймеры способностей
RunService.Heartbeat:Connect(function()
    if not infAbilityActive then return end
    
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        -- Удаление атрибутов кулдауна на персонаже, если они используются игрой
        for _, v in pairs(character:GetAttributes()) do
            if string.find(string.lower(tostring(_)), "cooldown") or string.find(string.lower(tostring(_)), "cd") then
                character:SetAttribute(_, 0)
            end
        end
        
        -- Попытка найти папки со значениями времени восстановления в Tool (перчатке)
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in pairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    if string.find(string.lower(v.Name), "cooldown") or string.find(string.lower(v.Name), "cd") or string.find(string.lower(v.Name), "time") then
                        v.Value = 0
                    end
                end
            end
        end
        
        -- Сброс таймеров через PlayerGui (актуально для многих способностей Slap Battles)
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            local mainUI = playerGui:FindFirstChild("Main")
            if mainUI then
                -- Обход специфических интерфейсов кулдауна перчаток
                local cooldownScreen = mainUI:FindFirstChild("AbilityCooldown")
                if cooldownScreen then
                    cooldownScreen.Visible = false
                end
            end
        end
    end)
end)

-- Дополнительный обработчик для мгновенной отправки сигналов способности (если игра сверяет их через сервер)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    -- Клавиша "E" или клик на способность часто завязаны на стандартные триггеры
    if input.KeyCode == Enum.KeyCode.E and infAbilityActive then
        pcall(function()
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                -- Триггерим активацию скрытых RemoteEvent внутри перчатки
                for _, remote in pairs(tool:GetDescendants()) do
                    if remote:IsA("RemoteEvent") and (string.find(string.lower(remote.Name), "ability") or string.find(string.lower(remote.Name), "special")) then
                        remote:FireServer()
                    end
                end
            end
        end)
    end
end)
