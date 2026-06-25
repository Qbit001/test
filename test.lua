--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║        CLICK TELEPORT TO CURSOR (KEY: R)                                     ║
║        Build a Boat for Treasure  •  Delta Executor Compatible               ║
╚══════════════════════════════════════════════════════════════════════════════╝
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Функция отправки красивого уведомления в игре
local function sendNotification(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = 3;
        })
    end)
end

-- Основная логика отслеживания нажатия кнопки
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Если ты пишешь в чат или открыл меню, телепорт не сработает
    if gameProcessed then return end
    
    -- Проверяем нажатие клавиши R
    if input.KeyCode == Enum.KeyCode.R then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Проверяем, указывает ли мышка на какую-то точку в пространстве
            if mouse.Hit then
                -- Конечная позиция + 3 блока вверх, чтобы не провалиться под землю
                local targetCFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                
                -- Безопасный перенос персонажа со всеми его частями
                character:PivotTo(targetCFrame)
            end
        end
    end
end)

-- Сигнал об успешном запуске
sendNotification("Click TP Активирован", "Наведи мышку и нажми [R] для телепортации!")
