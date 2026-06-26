-- Настройки
local REACH_DISTANCE = 100 -- Максимальная дистанция, с которой можно взять предмет

-- Сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local selectedPart = nil
local isSelectingDestination = false

-- Проверка, можно ли двигать объект (не закреплен ли он)
local function canMove(part)
    return part and not part.Anchored and part:IsA("BasePart") and not part:IsDescendantOf(Player.Character)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Активация по клавише R
    if input.KeyCode == Enum.KeyCode.R then
        
        -- ШАГ 1: Если объект еще не выбран, выбираем его
        if not isSelectingDestination then
            local target = Mouse.Target
            if target and canMove(target) then
                -- Проверяем расстояние до предмета
                local distance = (Player.Character.HumanoidRootPart.Position - target.Position).Magnitude
                if distance <= REACH_DISTANCE then
                    selectedPart = target
                    isSelectingDestination = true
                    -- Подсвечиваем деталь, чтобы знать, что она выбрана (опционально)
                    selectedPart.SelectionHighlight = Instance.new("SelectionBox")
                    selectedPart.SelectionHighlight.Color3 = Color3.fromRGB(0, 255, 0)
                    selectedPart.SelectionHighlight.Adornee = selectedPart
                    selectedPart.SelectionHighlight.Parent = selectedPart
                end
            end
            
        -- ШАГ 2: Если объект уже выбран, телепортируем его в точку курсора
        else
            if selectedPart and selectedPart.Parent then
                -- Убираем подсветку
                if selectedPart:FindFirstChild("SelectionHighlight") then
                    selectedPart.SelectionHighlight:Destroy()
                end
                
                -- Получаем координаты клика мыши в пространстве
                local targetPosition = Mouse.Hit.Position
                
                -- Смещаем позицию чуть вверх (на половину высоты детали), чтобы она не застревала в текстурах пола
                local offset = Vector3.new(0, selectedPart.Size.Y / 2, 0)
                
                -- Чтобы сервер засчитал перемещение, на секунду отключаем гравитацию через VectorForce или Velocity
                -- Но самый надежный способ для незакрепленных предметов — это резкий импульс AssemblyLinearVelocity 
                -- совместно с изменением CFrame на близком расстоянии.
                
                -- ВАЖНО: Персонаж должен быть относительно близко к предмету (или к точке назначения), 
                -- чтобы сработал Network Ownership.
                selectedPart.CFrame = CFrame.new(targetPosition + offset)
                selectedPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0) -- Сбрасываем скорость, чтобы он не улетел
            end
            
            -- Сбрасываем состояние для следующего раза
            selectedPart = nil
            isSelectingDestination = false
        end
    end
end)
