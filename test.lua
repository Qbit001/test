--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║        AUTOMATIC GOLD FARMER (GET ANY BLOCKS)                                ║
║        Build a Boat for Treasure  •  Delta Executor Compatible               ║
╚══════════════════════════════════════════════════════════════════════════════╝
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Включение/Выключение фармера (если захочешь остановить, измени true на false)
shared.AutofarmActive = true 

local function startFarmlogic()
    while shared.AutofarmActive do
        pcall(function()
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            
            if root and humanoid and humanoid.Health > 0 then
                -- Отключаем гравитацию и физику тела, чтобы античит игры не кикал за полет
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
                
                -- Пролетаем сквозь все 10 скрытых ворот локаций (чтобы игра засчитала прохождение)
                for i = 1, 10 do
                    if not shared.AutofarmActive then break end
                    
                    local stage = Workspace.BoatStages:FindFirstChild("NormalStages")
                    local currentStage = stage and stage:FindFirstChild("Stage" .. i)
                    
                    if currentStage then
                        local part = currentStage:FindFirstChild("CaveStage") or currentStage:FindFirstChildOfClass("Part")
                        if part then
                            -- Телепортируемся чуть ниже уровня земли (безопасная зона без кастомных препятствий)
                            root.CFrame = part.CFrame * CFrame.new(0, -15, 0)
                            task.wait(0.4) -- Задержка для прогрузки триггера локации
                        end
                    end
                end
                
                -- Летим прямиком к финальному золотому сундуку
                local endZone = Workspace:FindFirstChild("TheEnd")
                local goldChest = endZone and endZone:FindFirstChild("GoldenChest")
                
                if goldChest and shared.AutofarmActive then
                    -- Касаемся сундука
                    root.CFrame = goldChest.Corpo.CFrame + Vector3.new(0, 2, 0)
                    task.wait(3) -- Ждем анимацию выдачи золота и респавн
                end
            end
        end)
        task.wait(1)
    end
end

-- Запуск скрипта в отдельном потоке
if shared.AutofarmActive then
    print("[ЧИТ]: Авто-фарм успешно запущен! Собираем золото на сундуки...")
    task.spawn(startFarmlogic)
end
