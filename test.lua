local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Функция для обхода кулдауна способности Hallow Jack
local function enableInfiniteHallowJack()
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        -- Поиск перчатки Hallow Jack в руках или в рюкзаке
        local tool = character:FindFirstChild("Hallow Jack") 
            or character:FindFirstChild("HallowJack") 
            or LocalPlayer.Backpack:FindFirstChild("Hallow Jack") 
            or LocalPlayer.Backpack:FindFirstChild("HallowJack")
        
        if tool then
            -- Перебираем все свойства инструмента для сброса таймеров
            for _, v in pairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    local name = v.Name:lower()
                    if name:find("cooldown") or name:find("time") or name:find("debounce") or name:find("delay") then
                        v.Value = 0
                    end
                elseif v:IsA("BoolValue") then
                    local name = v.Name:lower()
                    if name:find("cooldown") or name:find("active") or name:find("debounce") then
                        v.Value = false
                    end
                end
            end
            
            -- Дополнительный сброс локальных скриптов внутри перчатки (если они отслеживают состояние)
            for _, scriptObj in pairs(tool:GetDescendants()) do
                if scriptObj:IsA("LocalScript") then
                    -- Некоторые скрипты используют атрибуты для контроля времени
                    for attrName, _ in pairs(scriptObj:GetAttributes()) do
                        if attrName:lower():find("cooldown") or attrName:lower():find("time") then
                            scriptObj:SetAttribute(attrName, 0)
                        end
                    end
                end
            end
        end
    end)
end

-- Автоматический запуск проверки в фоновом режиме
task.spawn(function()
    while true do
        enableInfiniteHallowJack()
        task.wait(0.05) -- Частота проверки для мгновенного сброса
    end
end)
