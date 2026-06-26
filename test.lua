-- Удаляем старое меню при перезапуске
if game:GetService("CoreGui"):FindFirstChild("BrainrotBallGui") then
    game:GetService("CoreGui").BrainrotBallGui:Destroy()
end

-- Настройки
local REACH_DISTANCE = math.huge -- Бесконечная дистанция, чтобы ловить шары везде
local scriptEnabled = true

-- Сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local selectedPart = nil
local isSelectingDestination = false

-- Создание UI в CoreGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotBallGui"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Главная панель
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 140)
MainFrame.Position = UDim2.new(0.5, -120, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Drop Balls TP [R]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0, 40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус: Наведи на шар и нажми R"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Parent = MainFrame

-- Кнопка Вкл/Выкл
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 200, 0, 40)
ToggleButton.Position = UDim2.new(0.5, -100, 0, 80)
ToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ToggleButton.Text = "Скрипт: АКТИВЕН"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 15
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    scriptEnabled = not scriptEnabled
    if scriptEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        ToggleButton.Text = "Скрипт: АКТИВЕН"
        StatusLabel.Text = "Статус: Наведи на шар и нажми R"
        StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        ToggleButton.Text = "Скрипт: ВЫКЛЮЧЕН"
        StatusLabel.Text = "Статус: Спит"
        StatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        
        if selectedPart then
            if selectedPart:FindFirstChild("SelectionHighlight") then
                selectedPart.SelectionHighlight:Destroy()
            end
            selectedPart = nil
            isSelectingDestination = false
        end
    end
end)

-- Проверка, физический ли это шар/предмет
local function isMovableBall(part)
    if part and part:IsA("BasePart") and not part.Anchored then
        -- Не даем случайно выбрать своего персонажа или чужих игроков
        if not part:IsDescendantOf(Player.Character) and not part:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid") then
            return true
        end
    end
    return false
end

-- Основная логика работы
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not scriptEnabled then return end
    
    if input.KeyCode == Enum.KeyCode.R then
        -- 1 НАЖАТИЕ: Выбираем падающий шар
        if not isSelectingDestination then
            local target = Mouse.Target
            if target and isMovableBall(target) then
                selectedPart = target
                isSelectingDestination = true
                
                StatusLabel.Text = "Шар пойман! Укажи цель и нажми R"
                StatusLabel.TextColor3 = Color3.fromRGB(241, 196, 15) -- Желтый
                
                -- Подсвечиваем шар
                local highlight = Instance.new("SelectionBox")
                highlight.Name = "SelectionHighlight"
                highlight.Color3 = Color3.fromRGB(241, 196, 15)
                highlight.LineWidth = 0.05
                highlight.Adornee = selectedPart
                highlight.Parent = selectedPart
            end
            
        -- 2 НАЖАТИЕ: Телепортируем шар туда, куда смотрит мышь
        else
            if selectedPart and selectedPart.Parent then
                if selectedPart:FindFirstChild("SelectionHighlight") then
                    selectedPart.SelectionHighlight:Destroy()
                end
                
                local targetPosition = Mouse.Hit.Position
                -- Немного приподнимаем над точкой клика, чтобы шар не провалился под текстуры
                local offset = Vector3.new(0, selectedPart.Size.Y / 2 + 1, 0)
                
                -- Перемещение физического тела
                selectedPart.CFrame = CFrame.new(targetPosition + offset)
                -- Полностью обнуляем скорость (чтобы шар не улетел по старой инерции)
                selectedPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                selectedPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                
                StatusLabel.Text = "Бум! Шарик перемещен!"
                StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
                
                task.delay(1, function()
                    if scriptEnabled and not isSelectingDestination then
                        StatusLabel.Text = "Статус: Наведи на шар и нажми R"
                        StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
                    end
                end)
            else
                -- Если шар успел исчезнуть/удалиться игрой до 2-го клика
                StatusLabel.Text = "Упс! Шар исчез, выбери другой"
                StatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
            end
            
            selectedPart = nil
            isSelectingDestination = false
        end
    end
end)
