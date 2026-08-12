-- Загрузка библиотеки Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Slap Battles | Ultimate Menu",
    LoadingTitle = "Загрузка скрипта...",
    LoadingSubtitle = "by Assistant",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Главная", 4483362458)

-- Глобальные переменные для ников
_G.TargetName = ""
_G.BringName = ""

-- Поле ввода никнейма игрока для быстрого телепорта к нему
MainTab:CreateInput({
    Name = "Ник игрока для телепорта к нему",
    PlaceholderText = "Введите ник цели...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        _G.TargetName = Text
    end,
})

-- Переключатель: Быстрый телепорт к игроку (0.0001с, 1 stud впереди спиной к нему)
local FastTpToggle = MainTab:CreateToggle({
    Name = "Быстрый телепорт к игроку (0.0001с)",
    CurrentValue = false,
    Callback = function(Value)
        _G.FastTpEnabled = Value
        task.spawn(function()
            local players = game:GetService("Players")
            local localPlayer = players.LocalPlayer
            
            while _G.FastTpEnabled do
                pcall(function()
                    if _G.TargetName ~= "" then
                        local targetPlayer = nil
                        for _, p in ipairs(players:GetPlayers()) do
                            if p ~= localPlayer then
                                if string.lower(p.Name):find(string.lower(_G.TargetName)) or string.lower(p.DisplayName):find(string.lower(_G.TargetName)) then
                                    targetPlayer = p
                                    break
                                end
                            end
                        end
                        
                        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local localChar = localPlayer.Character
                            if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                                localChar.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1)
                            end
                        end
                    end
                end)
                task.wait(0.01)
            end
        end)
    end,
})

-- Поле ввода никнейма для телепортации другого игрока к себе
MainTab:CreateInput({
    Name = "Ник игрока для телепорта к себе",
    PlaceholderText = "Введите ник кого притянуть...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        _G.BringName = Text
    end,
})

-- Кнопка: Телепортировать игрока к себе
MainTab:CreateButton({
    Name = "Телепортировать игрока к себе",
    Callback = function()
        pcall(function()
            if _G.BringName ~= "" then
                local players = game:GetService("Players")
                local localPlayer = players.LocalPlayer
                local targetPlayer = nil
                
                for _, p in ipairs(players:GetPlayers()) do
                    if p ~= localPlayer then
                        if string.lower(p.Name):find(string.lower(_G.BringName)) or string.lower(p.DisplayName):find(string.lower(_G.BringName)) then
                            targetPlayer = p
                            break
                        end
                    end
                end
                
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local localChar = localPlayer.Character
                    if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                        targetPlayer.Character.HumanoidRootPart.CFrame = localChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                    end
                end
            end
        end)
    end,
})

-- Функция: Максимальная гравитация
MainTab:CreateButton({
    Name = "Максимальная гравитация",
    Callback = function()
        workspace.Gravity = 1000
    end,
})

-- Функция: Режим неподвижности (Anchor Mode)
local AnchorToggle = MainTab:CreateToggle({
    Name = "Режим неподвижности (Нельзя оттолкнуть)",
    CurrentValue = false,
    Callback = function(Value)
        _G.AnchorEnabled = Value
        task.spawn(function()
            local player = game:GetService("Players").LocalPlayer
            while _G.AnchorEnabled do
                pcall(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        player.Character.HumanoidRootPart.Anchored = true
                    end
                end)
                task.wait(0.1)
            end
            pcall(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.Anchored = false
                end
            end)
        end)
    end,
})

-- Функция: Минимальная гравитация
local GravityToggle = MainTab:CreateToggle({
    Name = "Минимальная гравитация",
    CurrentValue = false,
    Callback = function(Value)
        _G.LowGravityEnabled = Value
        task.spawn(function()
            while _G.LowGravityEnabled do
                workspace.Gravity = 25
                task.wait(0.1)
            end
            workspace.Gravity = 196.2
        end)
    end,
})

-- Переключатель: Очень быстрый удар
MainTab:CreateToggle({
    Name = "Очень быстрый удар (Fast Slap)",
    CurrentValue = false,
    Callback = function(Value)
        _G.FastSlapEnabled = Value
        task.spawn(function()
            while _G.FastSlapEnabled do
                pcall(function()
                    local player = game:GetService("Players").LocalPlayer
                    if player.Character then
                        local tool = player.Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end)
                task.wait(0.01)
            end
        end)
    end,
})

-- Переключатель: Атакующий хитбокс
MainTab:CreateToggle({
    Name = "Атакующий хитбокс перчатки (20 studs)",
    CurrentValue = false,
    Callback = function(Value)
        _G.AttackHitboxEnabled = Value
        task.spawn(function()
            local players = game:GetService("Players")
            local localPlayer = players.LocalPlayer
            while _G.AttackHitboxEnabled do
                pcall(function()
                    local char = localPlayer.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        tool.Handle.Size = Vector3.new(20, 20, 20)
                        tool.Handle.CanCollide = false
                    end
                    for _, otherPlayer in ipairs(players:GetPlayers()) do
                        if otherPlayer ~= localPlayer and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (char.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= 20 then
                                if tool then tool:Activate() end
                                for _, remote in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                                    if remote:IsA("RemoteEvent") and (string.find(remote.Name:lower(), "slap") or string.find(remote.Name:lower(), "hit")) then
                                        remote:FireServer(otherPlayer.Character)
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.05)
            end
        end)
    end,
})

-- Переключатель: Полная невидимость
MainTab:CreateToggle({
    Name = "Полная невидимость (Invisibility)",
    CurrentValue = false,
    Callback = function(Value)
        _G.InvisibleEnabled = Value
        pcall(function()
            local char = game:GetService("Players").LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Transparency = _G.InvisibleEnabled and 1 or 0
                    elseif part:IsA("Decal") then
                        part.Transparency = _G.InvisibleEnabled and 1 or 0
                    elseif part:IsA("Accessory") then
                        local handle = part:FindFirstChild("Handle")
                        if handle then
                            handle.Transparency = _G.InvisibleEnabled and 1 or 0
                        end
                    end
                end
            end
        end)
    end,
})

-- Переключатель: Скрыть никнейм
MainTab:CreateToggle({
    Name = "Скрыть никнейм (Hide Name)",
    CurrentValue = false,
    Callback = function(Value)
        _G.HideNameEnabled = Value
        pcall(function()
            local char = game:GetService("Players").LocalPlayer.Character
            if char then
                local head = char:FindFirstChild("Head")
                if head then
                    for _, child in ipairs(head:GetChildren()) do
                        if child:IsA("BillboardGui") then
                            child.Enabled = not _G.HideNameEnabled
                        end
                    end
                end
            end
        end)
    end,
})

-- Кнопка сброса персонажа
MainTab:CreateButton({
    Name = "Сбросить персонажа",
    Callback = function()
        pcall(function()
            local player = game:GetService("Players").LocalPlayer
            if player.Character then
                player.Character:BreakJoints()
            end
        end)
    end,
})

-- Вкладка телепортов
local TeleportTab = Window:CreateTab("Телепорты", 4483362458)
TeleportTab:CreateButton({
    Name = "Телепорт на Арену",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        if player.Character then player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 15, 0) end
    end,
})

TeleportTab:CreateButton({
    Name = "Телепорт в Лобби (Safe Zone)",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        if player.Character then player.Character.HumanoidRootPart.CFrame = CFrame.new(-400, 50, 0) end
    end,
})

Rayfield:Notify({
    Title = "Успешно!",
    Content = "Все модули успешно обновлены.",
    Duration = 4,
})
