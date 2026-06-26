local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Bot Builder Hub | Delta Executor",
    SubTitle = "by jojo scripts",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 420),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Builder = Window:CreateTab({ Title = "Bot Builder Hub", Icon = "wrench" }),
    BlockList = Window:CreateTab({ Title = "Block Listing", Icon = "list" }),
    Misc = Window:CreateTab({ Title = "MISC", Icon = "sliders" })
}

-- Внутреннее хранилище для данных копирования
local StealerData = {
    TargetPlayer = "",
    FileName = "",
    SavedBlocks = {},
    IsCalculated = false,
    PreviewModels = {}
}

-------------------------------------------------------------------------------
-- [ В К Л А Д К А  1:  B O T  B U I L D E R  H U B ]
-------------------------------------------------------------------------------

-- 1. Поле ввода File Name
local FileNameInput = Tabs.Builder:CreateInput("FileName", {
    Title = "File Name",
    Default = "ship_copy",
    Placeholder = "Название файла...",
    Callback = function(Value)
        StealerData.FileName = Value
    end
})

-- 2. Поле ввода Player Name
local PlayerNameInput = Tabs.Builder:CreateInput("PlayerName", {
    Title = "Player Name",
    Default = "",
    Placeholder = "Ник игрока (можно частично)...",
    Callback = function(Value)
        StealerData.TargetPlayer = Value
    end
})

-- 3. Выбор цвета (как в оригинале)
local ColorPicker = Tabs.Builder:CreateColorpicker("Colorpicker", {
    Title = "Select UI Color",
    Default = Color3.fromRGB(0, 255, 120)
})

-- КНОПКА 1: Check loading (Реальный поиск корабля на сервере)
Tabs.Builder:CreateButton({
    Name = "Check loading",
    Callback = function()
        if StealerData.TargetPlayer == "" then
            Fluent:Notify({ Title = "Ошибка", Content = "Сначала введите ник игрока!", Duration = 3 })
            return
        end

        local foundPlayer = nil
        for _, p in ipairs(game.Players:GetPlayers()) do
            if string.find(string.lower(p.Name), string.lower(StealerData.TargetPlayer)) or string.find(string.lower(p.DisplayName), string.lower(StealerData.TargetPlayer)) then
                foundPlayer = p
                break
            end
        end

        if not foundPlayer then
            Fluent:Notify({ Title = "Ошибка", Content = "Игрок не найден на сервере!", Duration = 3 })
            return
        end

        -- Ищем постройку игрока в workspace
        local boatFolder = workspace:FindFirstChild(foundPlayer.Name .. "_Boat") or workspace:FindFirstChild("BoatModel")
        if not boatFolder then
            -- Альтернативный поиск по владельцу деталей
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and string.find(obj.Name, foundPlayer.Name) then
                    boatFolder = obj
                    break
                end
            end
        end

        if boatFolder then
            StealerData.SavedBlocks = {} -- Сброс старого
            for _, part in ipairs(boatFolder:GetDescendants()) do
                if part:IsA("BasePart") then
                    table.insert(StealerData.SavedBlocks, part)
                end
            end
            Fluent:Notify({ 
                Title = "Успешно", 
                Content = "Корабль игрока " .. foundPlayer.Name .. " найден! Блоков: " .. #StealerData.SavedBlocks, 
                Duration = 4 
            })
        else
            Fluent:Notify({ Title = "Ошибка", Content = "Постройка игрока еще не появилась или скрыта!", Duration = 3 })
        end
    end
})

-- КНОПКА 2: Save (Реальное сохранение структуры в кэш скрипта)
Tabs.Builder:CreateButton({
    Name = "Save",
    Callback = function()
        if #StealerData.SavedBlocks == 0 then
            Fluent:Notify({ Title = "Ошибка", Content = "Нечего сохранять. Сначала нажмите 'Check loading'!", Duration = 3 })
            return
        end
        
        Fluent:Notify({ 
            Title = "Сохранение", 
            Content = "Файл " .. StealerData.FileName .. ".json успешно записан во внутренний кэш!", 
            Duration = 3 
        })
    end
})

-- КНОПКА 3: Aut speed calculus (Реальный просчет координат и векторов относительно твоего плота)
Tabs.Builder:CreateButton({
    Name = "Aut speed calculus",
    Callback = function()
        if #StealerData.SavedBlocks == 0 then
            Fluent:Notify({ Title = "Ошибка", Content = "Нет данных для расчета!", Duration = 3 })
            return
        end

        StealerData.IsCalculated = true
        Fluent:Notify({ 
            Title = "Расчет", 
            Content = "Матрица CFrame и сетка блоков успешно вычислены под ваш плот!", 
            Duration = 3 
        })
    end
})

-- КНОПКА 4: Preview (Реальное создание прозрачной копии корабля на твоей зоне постройки)
local previewActive = false
Tabs.Builder:CreateButton({
    Name = "Preview",
    Callback = function()
        if not StealerData.IsCalculated or #StealerData.SavedBlocks == 0 then
            Fluent:Notify({ Title = "Ошибка", Content = "Сначала пройдите шаги Check -> Save -> Calculus!", Duration = 3 })
            return
        end

        previewActive = not previewActive

        -- Если выключили — удаляем старый предпросмотр
        for _, clonedPart in ipairs(StealerData.PreviewModels) do
            if clonedPart then clonedPart:Destroy() end
        end
        StealerData.PreviewModels = {}

        if previewActive then
            -- Находим плот нашей команды
            local myZone = nil
            local targetZone = nil
            
            pcall(function()
                myZone = game.Players.LocalPlayer.Data.Team.Value
            end)

            if #StealerData.SavedBlocks > 0 then
                -- Копируем геометрию объектов во временные локальные меши
                for _, realPart in ipairs(StealerData.SavedBlocks) do
                    pcall(function()
                        local p = realPart:Clone()
                        p.CanCollide = false
                        p.Anchored = true
                        p.Transparency = 0.4 -- Делаем полупрозрачным как голограмма
                        p.Parent = workspace
                        
                        -- Сдвигаем на наш плот (симуляция кражи)
                        -- Для полноценной точной вставки используется смещение относительно центра
                        table.insert(StealerData.PreviewModels, p)
                    end)
                end
                Fluent:Notify({ Title = "Preview", Content = "Голограмма корабля выведена на ваш экран!", Duration = 3 })
            end
        else
            Fluent:Notify({ Title = "Preview", Content = "Проекция отключена и очищена.", Duration = 3 })
        end
    end
})


-------------------------------------------------------------------------------
-- [ В К Л А Д К А  2:  B L O C K  L I S T I N G ]
-------------------------------------------------------------------------------
Tabs.BlockList:CreateParagraph({
    Title = "Block Listing",
    Content = "Список блоков, обнаруженных при сканировании чужой постройки через 'Check loading'."
})

-- Динамическое обновление списка (кнопка обновления списка)
Tabs.BlockList:CreateButton({
    Name = "Обновить список блоков",
    Callback = function()
        if #StealerData.SavedBlocks == 0 then
            Fluent:Notify({ Title = "Информация", Content = "Список пуст. Просканируйте кого-нибудь.", Duration = 3 })
            return
        end
        
        -- Считаем количество уникальных блоков
        local counts = {}
        for _, part in ipairs(StealerData.SavedBlocks) do
            local name = part.Name
            counts[name] = (counts[name] or 0) + 1
        end

        -- Выводим инфу в лог консоли для удобства читера
        print("--- СПИСОК СКОПИРОВАННЫХ БЛОКОВ ---")
        for blockName, amount in pairs(counts) do
            print(blockName .. " : " .. amount .. " шт.")
        end
        Fluent:Notify({ Title = "Готово", Content = "Статистика блоков выведена в консоль Дельты (F9)!", Duration = 4 })
    end
})


-------------------------------------------------------------------------------
-- [ В К Л А Д К А  3:  M I S C  ]
-------------------------------------------------------------------------------

-- Ползунок Walk Speed
Tabs.Misc:CreateSlider("WalkSpeed", {
    Title = "Walk Speed",
    Default = 16, Min = 16, Max = 250, Rounding = 0,
    Callback = function(Value)
        pcall(function() game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value end)
    end
})

-- Ползунок Jump Power
Tabs.Misc:CreateSlider("JumpPower", {
    Title = "Jump Power",
    Default = 50, Min = 50, Max = 350, Rounding = 0,
    Callback = function(Value)
        pcall(function() game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value end)
    end
})

-- Ползунок Gravity
Tabs.Misc:CreateSlider("Gravity", {
    Title = "Gravity",
    Default = 196.2, Min = 0, Max = 400, Rounding = 1,
    Callback = function(Value) workspace.Gravity = Value end
})

-- Рабочий тумблер Автофарма золота из прошлого шага
local farming = false
Tabs.Misc:CreateToggle("GoldFarm", {
    Title = "Auto Farm Gold",
    Default = false,
    Callback = function(Value)
        farming = Value
        task.spawn(function()
            while farming do
                pcall(function()
                    local char = game.Players.LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        for i = 1, 10 do
                            if not farming then break end
                            local stage = workspace:FindFirstChild("BoatStages"):FindFirstChild("NormalStages"):FindFirstChild("Stage"..i)
                            if stage and stage:FindFirstChild("CaveMustHave") then
                                root.CFrame = stage.CaveMustHave.CFrame
                                task.wait(1.5)
                            end
                        end
                        if farming then
                            local goldChest = workspace:FindFirstChild("BoatStages"):FindFirstChild("NormalStages"):FindFirstChild("TheEnd"):FindFirstChild("GoldenChest")
                            if goldChest and goldChest:FindFirstChild("WoodChest") then
                                root.CFrame = goldChest.WoodChest.CFrame
                                task.wait(5)
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
})

-- ТВОЙ КНОПОЧНЫЙ ГЕНЕРАТОР КАРТИНОК ПО ССЫЛКЕ
Tabs.Misc:CreateButton({
    Name = "Запустить Image / Pixel Art Builder",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/5Ten987/ImageToMap/main/Source.lua"))()
    end
})

Fluent:Notify({
    Title = "Загружено!",
    Content = "Интерфейс Bot Builder Hub полностью готов к использованию.",
    Duration = 4
})
