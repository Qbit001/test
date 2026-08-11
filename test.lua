-- Внимание: Этот скрипт работает только локально и может потребовать актуального обхода (Byfron bypass)
-- или наличия уязвимости в RemoteEvent конкретного патча игры.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Попытка найти локальный скрипт управления перчаткой или модуль кулдауна
local function removeCooldown()
    -- Большинство перчаток хранят статус в паках игрока или во внутренних модулях
    for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            -- Пробуем найти значения времени последней атаки (debounce / lastslapped)
            local debounce = v:FindFirstChild("Debounce") or v:FindFirstChild("Cooldown")
            if debounce then
                if debounce:IsA("NumberValue") or debounce:IsA("IntValue") then
                    debounce.Value = 0
                elseif debounce:IsA("BoolValue") then
                    debounce.Value = false
                end
            end
        end
    end
end

-- Бесконечный цикл применения для актуального инструмента в руках
task.spawn(function()
    while true do
        pcall(removeCooldown)
        task.wait(0.1)
    end
end)
