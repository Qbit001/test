--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║        AUTOMATIC SHOP BUYER (BULK CHEST PURCHASER)                           ║
║        Build a Boat for Treasure  •  Delta Executor Compatible               ║
╚══════════════════════════════════════════════════════════════════════════════╝
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Ищем официальный ремоут-ивент покупки предметов в игре
local buyItemRemote = ReplicatedStorage:FindFirstChild("BuyItem", true) 
    or ReplicatedStorage:FindFirstChild("PurchaseItem", true)

-- ════════════════════════════════════════════════════════════════════
--  ИНТЕРФЕЙС МАГАЗИНА
-- ════════════════════════════════════════════════════════════════════
local oldGui = player.PlayerGui:FindFirstChild("FastShopGUI")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FastShopGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 300)
mainFrame.Position = UDim2.new(0.5, -160, 0.4, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 24, 35)
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(65, 70, 100)

-- Перетаскивание окна
local function makeDraggable(frame)
    local dragging, dragInput, startPos, startFramePos
    frame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true startPos = inp.Position startFramePos = frame.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    frame.InputChanged:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then dragInput = inp end end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and dragInput and inp == dragInput then
            local delta = inp.Position - startPos
            frame.Position = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset + delta.X, startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(mainFrame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🛍️ Fast Shop Automator"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(32, 35, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- Закрытие
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.BackgroundTransparency = 1
close.Text = "✕"
close.TextColor3 = Color3.fromRGB(255, 100, 100)
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.Parent = mainFrame
close.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Шаблон для создания кнопок покупки
local function createBuyButton(name, displayName, cost, positionY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 40)
    btn.Position = UDim2.new(0, 15, 0, positionY)
    btn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
    btn.Text = "Купить " .. displayName .. " (" .. cost .. " Gold)"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        btn.Text = "⏳ Покупка..."
        btn.BackgroundColor3 = Color3.fromRGB(100, 100, 110)
        
        -- Посылаем запрос на сервер игры
        if buyItemRemote then
            pcall(function()
                -- Аргументы: Название предмета/сундука, Количество (1)
                buyItemRemote:FireServer(name, 1)
            end)
            task.wait(0.3)
            btn.Text = "✅ Успешно отправлено!"
            btn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        else
            btn.Text = "❌ Ремоут не найден"
            btn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        end
        
        task.wait(1)
        btn.Text = "Купить " .. displayName .. " (" .. cost .. " Gold)"
        btn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
    end)
end

-- Создаем кнопки для моментальной скупки основных сундуков (внутри которых лежит хлеб, пластик и т.д.)
createBuyButton("Common Chest", "Обычный сундук", "5", 60)
createBuyButton("Uncommon Chest", "Необычный сундук", "15", 110)
createBuyButton("Rare Chest", "Редкий сундук", "45", 160)
createBuyButton("Epic Chest", "Эпический сундук", "135", 210)

-- Информационная плашка снизу
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 25)
footer.Position = UDim2.new(0, 0, 1, -25)
footer.BackgroundTransparency = 1
footer.Text = "⚠️ Недоступные ивентовые предметы защищены сервером"
footer.TextColor3 = Color3.fromRGB(130, 135, 150)
footer.Font = Enum.Font.Helvetica
footer.TextSize = 10
footer.Parent = mainFrame
