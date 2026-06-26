-- Удаляем старое меню, если скрипт запускается повторно
if game:GetService("CoreGui"):FindFirstChild("TeleportPartGui") then
    game:GetService("CoreGui").TeleportPartGui:Destroy()
end

-- Настройки
local REACH_DISTANCE = 100
local scriptEnabled = true

-- Сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local selectedPart = nil
local isSelectingDestination = false

-- Создание UI (Интерфейса) в CoreGui (чтобы не пропадал при смерти)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportPartGui"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Главный фрейм (Меню)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 140)
MainFrame.Position = UDim2.new(0.5, -110, 0.2, 0) -- По центру сверху
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Меню можно перетаскивать мышкой/пальцем
MainFrame.Parent = ScreenGui

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "TP Parts (Click 'R')"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Индикатор Статуса
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус: Ожидание выбора"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Parent = MainFrame

-- Кнопка Вкл/Выкл
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 180, 0, 40)
ToggleButton.Position = UDim2.new(0.5, -90, 0, 80)
ToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Зеленый
ToggleButton.Text = "Скрипт: ВКЛ"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

-- Логика переключения кнопки
ToggleButton.MouseButton1Click:Connect(function()
    scriptEnabled = not scriptEnabled
    if scriptEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        ToggleButton.Text = "Скрипт: ВКЛ"
        StatusLabel.Text = "Статус: Ожидание выбора"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Красный
        ToggleButton.Text = "Скрипт: ВЫКЛ"
        StatusLabel.Text = "Статус: Отключен"
        StatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        
        -- Сброс если было что-то выбрано
        if selectedPart then
            if selectedPart:FindFirstChild("SelectionHighlight") then
                selectedPart.SelectionHighlight:Destroy()
            end
            selectedPart = nil
            isSelectingDestination = false
        end
    end
end)

-- Функция проверки физики объекта
local function canMove(part)
    return part and not part.Anchored and part:IsA("BasePart") and not part:IsDescendantOf(Player.Character)
end

-- Логика перемещения
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not scriptEnabled then return end
    
    if input.KeyCode == Enum.KeyCode.R then
        -- ШАГ 1: Выбор детали
        if not isSelectingDestination then
            local target = Mouse.Target
            if target and canMove(target) then
                local distance = (Player.Character.HumanoidRootPart.Position - target.Position).Magnitude
                if distance <= REACH_DISTANCE then
                    selectedPart = target
                    isSelectingDestination = true
                    
                    StatusLabel.Text = "Статус: Объект ВЫБРАН"
                    StatusLabel.TextColor3 = Color3.fromRGB(241, 196, 15) -- Желтый
                    
                    -- Подсветка
                    local highlight = Instance.new("SelectionBox")
                    highlight.Name = "SelectionHighlight"
                    highlight.Color3 = Color3.fromRGB(46, 204, 113)
                    highlight.Adornee = selectedPart
                    highlight.Parent = selectedPart
                end
            end
            
        -- ШАГ 2: Перемещение в точку клика
        else
            if selectedPart and selectedPart.Parent then
                if selectedPart:FindFirstChild("SelectionHighlight") then
                    selectedPart.SelectionHighlight:Destroy()
                end
                
                local targetPosition = Mouse.Hit.Position
                local offset = Vector3.new(0, selectedPart.Size.Y / 2, 0)
                
                -- Перенос предмета
                selectedPart.CFrame = CFrame.new(targetPosition + offset)
                selectedPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                
                StatusLabel.Text = "Статус: Перемещено!"
                StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113) -- Зеленый
                task.delay(1, function()
                    if scriptEnabled and not isSelectingDestination then
                        StatusLabel.Text = "Статус: Ожидание выбора"
                        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                    end
                end)
            end
            
            selectedPart = nil
            isSelectingDestination = false
        end
    end
end)
