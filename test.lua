local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local holding = false
local magnetRange = 150 -- Радиус работы магнита (в стадах). Можно изменить.

-- Отслеживаем нажатие клавиши R
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- gameProcessed проверяет, не печатает ли игрок в чат
    if not gameProcessed and input.KeyCode == Enum.KeyCode.R then
        holding = true
    end
end)

-- Отслеживаем отпускание клавиши R
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.R then
        holding = false
    end
end)

-- Создаем отдельный поток для цикла магнита
task.spawn(function()
    while task.wait(0.05) do -- Обновляем каждые 0.05 секунд, чтобы не вызывать сильных лагов
        if holding then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart

                -- Перебираем все объекты в игровом мире
                for _, item in ipairs(workspace:GetDescendants()) do
                    -- Фильтруем объекты: это должна быть деталь, она не должна быть закреплена
                    -- и она не должна быть частью вашего персонажа
                    if item:IsA("BasePart") and not item.Anchored and not item:IsDescendantOf(char) then
                        local distance = (item.Position - root.Position).Magnitude
                        
                        -- Если предмет в радиусе действия
                        if distance <= magnetRange then
                            -- Телепортируем предмет к центру персонажа
                            item.CFrame = root.CFrame
                        end
                    end
                end
            end
        end
    end
end)
