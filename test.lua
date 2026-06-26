local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local holding = false
local magnetRange = 150 -- Радиус работы магнита

-- Отслеживаем нажатие клавиши R
UserInputService.InputBegan:Connect(function(input, gameProcessed)
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

task.spawn(function()
    while task.wait(0.05) do
        if holding then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart

                for _, item in ipairs(workspace:GetDescendants()) do
                    -- Проверяем: это деталь, она НЕ зафиксирована (без Anchored) и это не наш персонаж
                    if item:IsA("BasePart") and not item.Anchored and not item:IsDescendantOf(char) then
                        local distance = (item.Position - root.Position).Magnitude
                        
                        if distance <= magnetRange then
                            -- ДОПОЛНИТЕЛЬНО: Ломаем соединения, если предмет приварен к чему-то
                            for _, joint in ipairs(item:GetChildren()) do
                                if joint:IsA("Weld") or joint:IsA("ManualWeld") or joint:IsA("WeldConstraint") then
                                    joint:Destroy() -- Уничтожаем сварку, освобождая деталь
                                end
                            end
                            
                            -- Притягиваем деталь к персонажу
                            item.CFrame = root.CFrame
                        end
                    end
                end
            end
        end
    end
end)
