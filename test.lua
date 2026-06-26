local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "BABFT Multi-Hub | Delta Edition",
    SubTitle = "by AI Assistant",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 340),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:CreateTab({ Title = "Auto Build & Image", Icon = "image" }),
    Exploits = Window:CreateTab({ Title = "AutoFarm & Misc", Icon = "zap" })
}

-- [ ВКЛАДКА 1: AUTO BUILD И ГЕНЕРАТОР КАРТИНОК ]
Tabs.Main:CreateParagraph({
    Title = "Image Generator & Stealer",
    Content = "Загружайте сторонние скрипты для постройки картинок или копирования прямо через этот интерфейс."
})

Tabs.Main:CreateButton({
    Name = "Запустить Image / Pixel Builder (Строитель картинок)",
    Callback = function()
        Window:Destroy() -- Закрываем это меню, чтобы не мешало
        -- Загрузка известного скрипта для генерации картинок из блоков в BABFT
        loadstring(game:HttpGet("https://raw.githubusercontent.com/5Ten987/ImageToMap/main/Source.lua"))()
    end
})

Tabs.Main:CreateButton({
    Name = "Запустить Альтернативный Auto-Build (Vynixius)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixius/Vynixius/main/BuildABoatForTreasure"))()
    end
})

-- [ ВКЛАДКА 2: AUTOFARM & MISC ]
local WalkSpeedSlider = Tabs.Exploits:CreateSlider("WS", {
    Title = "Скорость бега (WalkSpeed)",
    Description = "Стандартная скорость — 16",
    Default = 16,
    Min = 16,
    Max = 150,
    Rounding = 0,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

local JumpPowerSlider = Tabs.Exploits:CreateSlider("JP", {
    Title = "Сила прыжка (JumpPower)",
    Description = "Стандартная сила — 50",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end
})

-- Логика Автофарма золота
local farming = false
Tabs.Exploits:CreateToggle("FarmToggle", {
    Title = "Автофарм золота (Auto Farm)",
    Default = false,
    Callback = function(Value)
        farming = Value
        task.spawn(function()
            while farming do
                pcall(function()
                    local char = game.Players.LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        -- Быстрое перемещение по стадиям к финишу
                        for i = 1, 10 do
                            if not farming then break end
                            local stage = workspace:FindFirstChild("BoatStages"):FindFirstChild("NormalStages"):FindFirstChild("Stage"..i)
                            if stage and stage:FindFirstChild("CaveMustHave") then
                                root.CFrame = stage.CaveMustHave.CFrame
                                task.wait(2.5) -- Безопасный интервал для зачисления золота
                            end
                        end
                        -- Телепорт к сундуку
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

Fluent:Notify({
    Title = "Успешно!",
    Content = "Скрипт полностью готов к использованию в Delta Executor.",
    Duration = 5
})
