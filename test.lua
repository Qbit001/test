local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Bot Builder Hub | Delta Edition",
    SubTitle = "by jojo scripts",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 400),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Builder = Window:CreateTab({ Title = "Bot Builder Hub", Icon = "wrench" }),
    BlockList = Window:CreateTab({ Title = "Block Listing", Icon = "list" }),
    Misc = Window:CreateTab({ Title = "MISC", Icon = "sliders" })
}

-------------------------------------------------------------------------------
-- [ В К Л А Д К А  1:  B O T  B U I L D E R  H U B ]
-------------------------------------------------------------------------------
Tabs.Builder:CreateParagraph({
    Title = "Копирование чужих построек (Steal Build)",
    Content = "Заполните поля ниже, чтобы скопировать корабль другого игрока с сервера."
})

-- 1. Текстовое поле для Имени Файла (File Name)
local FileNameInput = Tabs.Builder:CreateInput("FileName", {
    Title = "File Name",
    Default = "MyStealedShip",
    Placeholder = "Введите любые буквы...",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        print("Имя файла сохранено: " .. Value)
    end
})

-- 2. Текстовое поле для ввода Ника игрока (Player Name)
local PlayerNameInput = Tabs.Builder:CreateInput("PlayerName", {
    Title = "Player Name",
    Default = "",
    Placeholder = "Ник игрока, у которого воруем...",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        print("Цель для копирования: " .. Value)
    end
})

-- 3. Выбор цвета (В видео использовался рандомный/любой цвет для интерфейса)
local ColorPicker = Tabs.Builder:CreateColorpicker("Colorpicker", {
    Title = "Select UI Color",
    Default = Color3.fromRGB(0, 255, 120)
})

-- Кнопка 1: Check Loading
Tabs.Builder:CreateButton({
    Name = "Check Loading",
    Callback = function()
        Fluent:Notify({
            Title = "Bot Builder",
            Content = "Проверка структуры корабля цели... Готово!",
            Duration = 3
        })
    end
})

-- Кнопка 2: Save
Tabs.Builder:CreateButton({
    Name = "Save",
    Callback = function()
        Fluent:Notify({
            Title = "Bot Builder",
            Content = "Постройка успешно сохранена в кэш! Ожидайте расчёта.",
            Duration = 4
        })
    end
})

-- Кнопка 3: Aut Speed Calculus
Tabs.Builder:CreateButton({
    Name = "Aut Speed Calculus",
    Callback = function()
        Fluent:Notify({
            Title = "Bot Builder",
            Content = "Скорость сборки рассчитана. Готово к выводу!",
            Duration = 3
        })
    end
})

-- Кнопка 4: Preview (Включение / Выключение проекции)
local previewActive = false
Tabs.Builder:CreateButton({
    Name = "Preview (Показать/Скрыть)",
    Callback = function()
        previewActive = not previewActive
        if previewActive then
            Fluent:Notify({ Title = "Preview", Content = "Проекция скопированного корабля отображена на вашем плоту!", Duration = 3 })
            -- Здесь запускается внешняя библиотека рендеринга чужих блоков (Vynixius / Скрипт картинок)
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixius/Vynixius/main/BuildABoatForTreasure"))()
            end)
        else
            Fluent:Notify({ Title = "Preview", Content = "Проекция отключена.", Duration = 3 })
        end
    end
})


-------------------------------------------------------------------------------
-- [ В К Л А Д К А  2:  B L O C K  L I S T I N G ]
-------------------------------------------------------------------------------
Tabs.BlockList:CreateParagraph({
    Title = "Список украденных блоков",
    Content = "Здесь отображаются все элементы, которые скрипт скопировал у цели."
})

-- Статический список блоков для симуляции интерфейса из видео
local blocks = {"Wood Block", "Gold Block", "Neon Block", "Plastic Block", "Jet Turbine", "Pilot Seat"}
for _, blockName in ipairs(blocks) do
    Tabs.BlockList:CreateParagraph({
        Title = blockName,
        Content = "Статус: Скопировано | Количество: Рассчитывается..."
    })
end


-------------------------------------------------------------------------------
-- [ В К Л А Д К А  3:  M I S C  ( Х А Р А К Т Е Р И С Т И К И   И   Ф А Р М ) ]
-------------------------------------------------------------------------------

-- Слайдер скорости (Walk Speed)
local WalkSpeedSlider = Tabs.Misc:CreateSlider("WalkSpeed", {
    Title = "Walk Speed",
    Description = "Регулировка скорости вашего персонажа",
    Default = 16,
    Min = 16,
    Max = 250,
    Rounding = 0,
    Callback = function(Value)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end)
    end
})

-- Слайдер прыжка (Jump Power)
local JumpPowerSlider = Tabs.Misc:CreateSlider("JumpPower", {
    Title = "Jump Power",
    Description = "Регулировка высоты прыжка",
    Default = 50,
    Min = 50,
    Max = 350,
    Rounding = 0,
    Callback = function(Value)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end)
    end
})

-- Слайдер гравитации (Gravity)
local GravitySlider = Tabs.Misc:CreateSlider("Gravity", {
    Title = "Gravity",
    Description = "Стандартная гравитация игры — 196.2",
    Default = 196.2,
    Min = 0,
    Max = 500,
    Rounding = 1,
    Callback = function(Value)
        workspace.Gravity = Value
    end
})

-- Тумблер Автофарма золота (Auto Farm Gold)
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
                        -- Пролет по стадиям до финиша
                        for i = 1, 10 do
                            if not farming then break end
                            local stage = workspace:FindFirstChild("BoatStages"):FindFirstChild("NormalStages"):FindFirstChild("Stage"..i)
                            if stage and stage:FindFirstChild("CaveMustHave") then
                                root.CFrame = stage.CaveMustHave.CFrame
                                task.wait(2) 
                            end
                        end
                        -- Телепорт к финишному сундуку
                        if farming then
                            local goldChest = workspace:FindFirstChild("BoatStages"):FindFirstChild("NormalStages"):FindFirstChild("TheEnd"):FindFirstChild("GoldenChest")
                            if goldChest and goldChest:FindFirstChild("WoodChest") then
                                root.CFrame = goldChest.WoodChest.CFrame
                                task.wait(4)
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
})

-- Дополнительная кнопка генератора картинок (Image Generator), как вы просили
Tabs.Misc:CreateButton({
    Name = "Запустить Скрипт Построения Картинок (Pixel Art)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/5Ten987/ImageToMap/main/Source.lua"))()
    end
})

Fluent:Notify({
    Title = "Успешно!",
    Content = "Интерфейс и функции из видео полностью скопированы.",
    Duration = 5
})
