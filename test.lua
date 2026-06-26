-- Удаляем старое меню при перезапуске скрипта
if game:GetService("CoreGui"):FindFirstChild("BrainrotMagnetGui") then
    game:GetService("CoreGui").BrainrotMagnetGui:Destroy()
end

-- Настройки
local scriptEnabled = true
local magnetForce = 50000 -- Сила притяжения (чем больше, тем быстрее летят шары)

-- Сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local isHoldingR = false

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotMagnetGui"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 130)
MainFrame.Position = UDim2.new(0.5, -120, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 30) -- Фиолетовый оттенок под стиль игры
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Ball Magnet [Зажми R]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0, 40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус: Магнит готов"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 200, 0, 35)
ToggleButton.Position = UDim2.new(0.5, -100, 0, 80)
ToggleButton.BackgroundColor3 = Color3.fromRGB(142, 68, 173) -- Фиолетовая кнопка
ToggleButton.Text = "Магнит: ВКЛ"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 15
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

-- Вкл/Выкл через кнопку меню
ToggleButton.MouseButton1Click:Connect(function()
    scriptEnabled = not scriptEnabled
    if scriptEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
        ToggleButton.Text = "Магнит: ВКЛ"
        StatusLabel.Text = "Статус: Магнит готов"
        StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        ToggleButton.Text = "Магнит: ВЫКЛ"
        StatusLabel.Text = "Статус: Отключен"
        StatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        isHoldingR = false
    end
end)

-- Проверка, является ли объект шаром, который можно притянуть
local function isMovableBall(part)
    if part and part:IsA("BasePart") and not part.Anchored then
        -- Проверяем, что это не часть нашего персонажа и не другой игрок
        if not part:IsDescendantOf(Player.Character) and not part:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid") then
            -- Фильтр под шары (обычно они называются Part, MeshPart или Ball в этих плейсах)
            if part.Name == "Part" or part.Name == "MeshPart" or part.Shape == Enum.PartType.Ball then
                return true
            end
        end
    end
    return false
end

-- Отслеживание зажатия R
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not scriptEnabled then return end
    if input.KeyCode == Enum.KeyCode.R then
        isHoldingR = true
        StatusLabel.Text = "СТАТУС: ПРИТЯГИВАЮ ШАРЫ!"
        StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113) -- Зеленый
    end
end)

-- Отслеживание отпускания R
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.R then
        isHoldingR = false
        if scriptEnabled then
            StatusLabel.Text = "Статус: Магнит готов"
            StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    end
end)

-- Цикл притяжения (работает каждый физический кадр, пока зажата R)
RunService.Stepped:Connect(function()
    if not scriptEnabled or not isHoldingR then return end
    
    local character = Player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local myPos = character.HumanoidRootPart.Position
    
    -- Ищем все шары в workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if isMovableBall(obj) then
            -- Считаем направление от шара к нам
            local direction = (myPos - obj.Position)
            local distance = direction.Magnitude
            
            -- Притягиваем только если шар не застрял прямо в нас (на расстоянии больше 3 блоков)
            if distance > 3 then
                -- Вычисляем вектор силы
                local force = direction.Unit * magnetForce
                
                -- Прикладываем скорость напрямую к шару (самый надежный обход для Delta)
                obj.AssemblyLinearVelocity = force * (1 / obj:GetMass())
            else
                -- Если шар уже долетел до нас, гасим скорость, чтобы он плавно упал в лунку рядом
                obj.AssemblyLinearVelocity = Vector3.new(0, -10, 0)
            end
        end
    end
end)
