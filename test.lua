-- Удаляем старое меню при перезапуске
if game:GetService("CoreGui"):FindFirstChild("BrainrotBallHoldGui") then
    game:GetService("CoreGui").BrainrotBallHoldGui:Destroy()
end

-- Настройки
local REACH_DISTANCE = math.huge -- Дистанция захвата (бесконечная, ловит везде)
local scriptEnabled = true

-- Сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera

local targetPart = nil
local isHolding = false

-- Создание скрытых физических объектов для перемещения
local attachmentTarget = Instance.new("Attachment")
attachmentTarget.Parent = workspace:FindFirstChildOfClass("Terrain") -- Помещаем в надежное место

local alignPosition = Instance.new("AlignPosition")
alignPosition.MaxForce = 1e7 -- Огромная сила, чтобы удерживать тяжелые шары
alignPosition.Responsiveness = 25 -- Плавность и скорость следования за курсором
alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
alignPosition.Attachment0 = nil
alignPosition.Parent = attachmentTarget

-- Создание UI в CoreGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotBallHoldGui"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 130)
MainFrame.Position = UDim2.new(0.5, -120, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
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
Title.Text = "Ball Control [Зажми R]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0, 40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус: Готов к захвату"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 200, 0, 35)
ToggleButton.Position = UDim2.new(0.5, -100, 0, 80)
ToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ToggleButton.Text = "Скрипт: ВКЛ"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 15
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

-- Включение/Выключение скрипта через кнопку
ToggleButton.MouseButton1Click:Connect(function()
    scriptEnabled = not scriptEnabled
    if scriptEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        ToggleButton.Text = "Скрипт: ВКЛ"
        StatusLabel.Text = "Статус: Готов к захвату"
        StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        ToggleButton.Text = "Скрипт: ВЫКЛ"
        StatusLabel.Text = "Статус: Отключен"
        StatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        
        -- Принудительно отпускаем шар, если выключили скрипт во время удержания
        isHolding = false
        alignPosition.Attachment0 = nil
        targetPart = nil
    end
end)

-- Фильтр: проверяем, можно ли управлять объектом
local function isMovableBall(part)
    if part and part:IsA("BasePart") and not part.Anchored then
        if not part:IsDescendantOf(Player.Character) and not part:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid") then
            return true
        end
    end
    return false
end

-- Логика нажатия (Захват)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not scriptEnabled then return end
    
    if input.KeyCode == Enum.KeyCode.R then
        local target = Mouse.Target
        if target and isMovableBall(target) then
            targetPart = target
            isHolding = true
            
            StatusLabel.Text = "Статус: Веду шарик!"
            StatusLabel.TextColor3 = Color3.fromRGB(241, 196, 15) -- Желтый
            
            -- Создаем временный Attachment внутри шара для физической привязки
            local ballAttachment = targetPart:FindFirstChild("BallMoveAttachment") or Instance.new("Attachment")
            ballAttachment.Name = "BallMoveAttachment"
            ballAttachment.Parent = targetPart
            
            alignPosition.Attachment0 = ballAttachment
        end
    end
end)

-- Логика отпускания кнопки
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.R then
        isHolding = false
        alignPosition.Attachment0 = nil
        targetPart = nil
        
        if scriptEnabled then
            StatusLabel.Text = "Статус: Шар отпущен"
            StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113) -- Зеленый
            task.delay(1, function()
                if scriptEnabled and not isHolding then
                    StatusLabel.Text = "Статус: Готов к захвату"
                    StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
                end
            end)
        end
    end
end)

-- Обновление позиции цели каждый кадр (Следование за курсором)
RunService.RenderStepped:Connect(function()
    if isHolding and targetPart and targetPart.Parent then
        -- Находим 3D позицию, куда указывает курсор мыши на карте
        local targetPosition = Mouse.Hit.Position
        
        -- Устанавливаем точку назначения для физической силы
        attachmentTarget.Position = targetPosition
        
        -- Гасим лишнее вращение и случайные импульсы шара, чтобы он не вырывался
        targetPart.AssemblyLinearVelocity = targetPart.AssemblyLinearVelocity * 0.1
    elseif isHolding then
        -- Если шар пропал/удалился плейсом во время удержания
        isHolding = false
        alignPosition.Attachment0 = nil
        targetPart = nil
        StatusLabel.Text = "Статус: Шар исчез"
        StatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
    end
end)
