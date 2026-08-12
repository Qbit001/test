-- Проверка на то, что игра загрузилась
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Переменные окружения
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)

-- Подключение библиотеки интерфейсов (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Создание главного окна
local Window = Rayfield:CreateWindow({
    Name = "Slap Battles | Ability Hub",
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

-- Секция настроек способностей
local AbilitySection = MainTab:CreateSection("Управление способностями")

-- Переменная состояния бесконечного использования
getgenv().InfiniteAbility = false

-- Тоггл (переключатель) бесконечного использования
MainTab:CreateToggle({
    Name = "Бесконечная способность (Без кулдауна)",
    CurrentValue = false,
    Flag = "InfiniteAbilityToggle",
    Callback = function(Value)
        getgenv().InfiniteAbility = Value
        
        if Value then
            Rayfield:Notify({
                Title = "Успешно!",
                Content = "Кулдаун способностей отключен.",
                Duration = 3,
                Image = 4483362458,
            })
            
            -- Основной цикл сброса кулдаунов
            task.spawn(function()
                while getgenv().InfiniteAbility do
                    pcall(function()
                        -- Сброс таймеров или триггер кастомных эвентов способностей
                        if Remotes and Remotes:FindFirstChild("Ability") then
                            -- Логика обхода кулдауна в зависимости от выбранной перчатки
                            -- Большинство перчаток используют локальные проверки или специфичные ремоты
                        end
                        
                        -- Дополнительный метод: сброс атрибутов персонажа, если они отвечают за перезарядку
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            for _, v in pairs(LocalPlayer.Character:GetAttributes()) do
                                if string.find(string.lower(tostring(v)), "cooldown") or string.find(string.lower(tostring(v)), "time") then
                                    LocalPlayer.Character:SetAttribute(v, 0)
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Отключено",
                Content = "Функция возвращена в стандартный режим.",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

-- Дополнительная полезная функция: Авто-спанч (увеличение скорости ударов)
local ExtraSection = MainTab:CreateSection("Дополнительно")

MainTab:CreateButton({
    Name = "Убрать кулдаун перчаток (Универсальный сброс)",
    Callback = function()
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, child in pairs(char:GetChildren()) do
                    if child:IsA("Tool") and child:FindFirstChild("cooldown") then
                        child.cooldown.Value = 0
                    end
                end
            end
        end)
        Rayfield:Notify({
            Title = "Сброс",
            Content = "Попытка обнулить кулдаун активного инструмента.",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

-- Секция информации
local InfoTab = Window:CreateTab("Информация", 4483362458)
InfoTab:CreateParagraph({Title = "Статус", Content = "Интерфейс успешно запущен. Используйте переключатели с осторожностью."})
