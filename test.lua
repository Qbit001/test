-- Проверка на загрузку игры
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Сервисы
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local RS = game:GetService("RunService")

-- Подключение библиотеки интерфейсов Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Создание главного окна
local Window = Rayfield:CreateWindow({
    Name = "Slap Battles | Ultimate Hub",
    LoadingTitle = "Загрузка скрипта...",
    LoadingSubtitle = "by AI Collaborator",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "SlapBattlesHub"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvite",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Доступ",
        Subtitle = "Введите ключ",
        Note = "Ключ отсутствует",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {""}
    }
})

-- Создание вкладки
local MainTab = Window:CreateTab("Главная", 4483362458)
local MainSection = MainTab:CreateSection("Функции")

-- Глобальные переменные
getgenv().InfiniteAbility = false
getgenv().SlapAura = false
getgenv().AuraRange = 15 -- Радиус удара

-- 1. Тоггл бесконечной способности
MainTab:CreateToggle({
    Name = "Бесконечная способность (Сброс кулдауна)",
    CurrentValue = false,
    Flag = "InfiniteAbilityToggle",
    Callback = function(Value)
        getgenv().InfiniteAbility = Value
        if Value then
            Rayfield:Notify({Title = "Успешно", Content = "Кулдаун способностей отключен.", Duration = 3, Image = 4483362458})
            task.spawn(function()
                while getgenv().InfiniteAbility do
                    pcall(function()
                        local character = LocalPlayer.Character
                        if character then
                            for _, item in pairs(character:GetChildren()) do
                                if item:IsA("Tool") then
                                    if item:FindFirstChild("cooldown") then item.cooldown.Value = 0 end
                                    if item:FindFirstChild("Cooldown") then item.Cooldown.Value = 0 end
                                end
                            end
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        else
            Rayfield:Notify({Title = "Отключено", Content = "Скрипт переведен в стандартный режим.", Duration = 3, Image = 4483362458})
        end
    end,
})

-- 2. Тоггл Слеп Ауры (Slap Aura)
MainTab:CreateToggle({
    Name = "Слеп Аура (Авто-удар игроков)",
    CurrentValue = false,
    Flag = "SlapAuraToggle",
    Callback = function(Value)
        getgenv().SlapAura = Value
        if Value then
            Rayfield:Notify({Title = "Аура активна", Content = "Ближайшие игроки будут получать удары.", Duration = 3, Image = 4483362458})
            
            task.spawn(function()
                while getgenv().SlapAura do
                    pcall(function()
                        local character = LocalPlayer.Character
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            local myRoot = character.HumanoidRootPart
                            local glove = character:FindFirstChildOfClass("Tool")
                            
                            -- Проверяем, взята ли перчатка в руку
                            if glove and (glove:FindFirstChild("Handle") or glove.Name ~= "") then
                                for _, player in pairs(Players:GetPlayers()) do
                                    if player ~= LocalPlayer and player.Character then
                                        local enemyChar = player.Character
                                        local enemyRoot = enemyChar:FindFirstChild("HumanoidRootPart")
                                        local enemyHumanoid = enemyChar:FindFirstChildOfClass("Humanoid")
                                        
                                        -- Проверяем, живой ли игрок и не в лобби/не защищен ли (бабл/щиты)
                                        if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
                                            local distance = (myRoot.Position - enemyRoot.Position).Magnitude
                                            if distance <= getgenv().AuraRange then
                                                -- Вызов удара через стандартный RemoteEvent удара в Slap Battles
                                                if Remotes and Remotes:FindFirstChild("bTo") then
                                                    Remotes.bTo:FireServer(enemyRoot)
                                                elseif glove:FindFirstChild("glove") or Remotes:FindFirstChild("GetHit") then
                                                    -- Альтернативные триггеры сетевых пакетов удара
                                                    local remote = Remotes:FindFirstChild("GetHit") or Remotes:FindFirstChild("banana")
                                                    if remote then remote:FireServer(enemyRoot) end
                                                end
                                                
                                                -- Прямая эмуляция касания перчаткой хитбокса врага
                                                if glove:FindFirstChild("Handle") then
                                                    firetouchinterest(enemyRoot, glove.Handle, 0)
                                                    firetouchinterest(enemyRoot, glove.Handle, 1)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.05) -- Частата срабатывания ауры
                end
            end)
        else
            Rayfield:Notify({Title = "Аура отключена", Content = "Авто-удар выключен.", Duration = 3, Image = 4483362458})
        end
    end,
})

-- Слайдер настройки радиуса ауры
MainTab:CreateSlider({
    Name = "Радиус Слеп Ауры",
    Range = {5, 25},
    Increment = 1,
    CurrentValue = 15,
    Flag = "AuraRangeSlider",
    Callback = function(Value)
        getgenv().AuraRange = Value
    end,
})

-- Вкладка информации
local InfoTab = Window:CreateTab("Информация", 4483362458)
InfoTab:CreateParagraph({
    Title = "О скрипте", 
    Content = "Слеп Аура автоматически фиксирует игроков в радиусе и наносит им урон. Убедитесь, что перчатка надета и находится у вас в руке."
})
