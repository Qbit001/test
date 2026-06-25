--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║        FULLY FUNCTIONAL TABBED DISCORD IMAGE PRINTER                         ║
║        Build a Boat for Treasure  •  Delta Executor Compatible               ║
╚══════════════════════════════════════════════════════════════════════════════╝
--]]

local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local player           = Players.LocalPlayer

local IMAGE_API = "https://image-to-pixel-api.vercel.app/api/convert?url="
local isPrinting = false 

-- ════════════════════════════════════════════════════════════════════
--  ФУНКЦИЯ СПАВНА БЛОКОВ
-- ════════════════════════════════════════════════════════════════════
local function spawnBlock(position, color)
    pcall(function()
        local buildEvent = game:GetService("ReplicatedStorage"):FindFirstChild("PlaceBlock", true) 
            or game:GetService("Event"):FindFirstChild("PlaceBlock")
            
        if buildEvent then
            buildEvent:FireServer("PlasticBlock", position, Vector3.new(0,0,0), color)
        else
            -- Бекап для локального отображения (если ремоут не ответил)
            local part = Instance.new("Part")
            part.Size = Vector3.new(2, 2, 2)
            part.Position = position
            part.Color = color
            part.Material = Enum.Material.Plastic
            part.Anchored = true
            part.Parent = workspace
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
--  ИНТЕРФЕЙС (GUI С ФИКСАМИ)
-- ════════════════════════════════════════════════════════════════════
local oldGui = player.PlayerGui:FindFirstChild("TabbedPrinterGUI")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TabbedPrinterGUI"
screenGui.ResetOnSpawn = false -- GUI не пропадет после респавна!
screenGui.Parent = player.PlayerGui

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 270)
mainFrame.Position = UDim2.new(0.5, -180, 0.4, -135)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(55, 60, 85)
mainStroke.Thickness = 1.5

-- Скрипт плавного перетаскивания окна мышкой/пальцем
local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragInput, startPos, startFramePos
    dragHandle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true startPos = inp.Position startFramePos = frame.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    dragHandle.InputChanged:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then dragInput = inp end end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and dragInput and inp == dragInput then
            local delta = inp.Position - startPos
            frame.Position = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset + delta.X, startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y)
        end
    end)
end

-- Панель вкладок (Верхний бар)
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 40)
tabBar.BackgroundColor3 = Color3.fromRGB(28, 30, 43)
tabBar.Parent = mainFrame
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 12)

makeDraggable(mainFrame, tabBar) -- Теперь за верхнюю панель можно таскать окно

-- Кнопка Вкладки 1 (Печать)
local tabBtn1 = Instance.new("TextButton")
tabBtn1.Size = UDim2.new(0.4, 0, 1, 0)
tabBtn1.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
tabBtn1.Text = "🖼️ Печать"
tabBtn1.TextColor3 = Color3.fromRGB(255, 255, 255)
tabBtn1.Font = Enum.Font.GothamBold
tabBtn1.TextSize = 13
tabBtn1.Parent = tabBar
Instance.new("UICorner", tabBtn1).CornerRadius = UDim.new(0, 10)

-- Кнопка Вкладки 2 (Настройки)
local tabBtn2 = Instance.new("TextButton")
tabBtn2.Size = UDim2.new(0.4, 0, 1, 0)
tabBtn2.Position = UDim2.new(0.4, 0, 0, 0)
tabBtn2.BackgroundTransparency = 1
tabBtn2.Text = "⚙️ Настройки"
tabBtn2.TextColor3 = Color3.fromRGB(150, 155, 180)
tabBtn2.Font = Enum.Font.GothamBold
tabBtn2.TextSize = 13
tabBtn2.Parent = tabBar
Instance.new("UICorner", tabBtn2).CornerRadius = UDim.new(0, 10)

-- Кнопка закрытия интерфейса (крестик)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -36, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(45, 30, 35)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = tabBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- ════════════════════════════════════════════════════════════════════
--  ФРЕЙМЫ КОНТЕНТА
-- ════════════════════════════════════════════════════════════════════

-- ВКЛАДКА 1: ПЕЧАТЬ
local printTabFrame = Instance.new("Frame")
printTabFrame.Size = UDim2.new(1, 0, 1, -40)
printTabFrame.Position = UDim2.new(0, 0, 0, 40)
printTabFrame.BackgroundTransparency = 1
printTabFrame.Visible = true
printTabFrame.Parent = mainFrame

local urlInput = Instance.new("TextBox")
urlInput.Size = UDim2.new(1, -30, 0, 36)
urlInput.Position = UDim2.new(0, 15, 0, 20)
urlInput.PlaceholderText = "Вставьте ссылку на фото из Discord..."
urlInput.Text = ""
urlInput.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
urlInput.TextColor3 = Color3.fromRGB(240, 240, 240)
urlInput.Font = Enum.Font.Gotham
urlInput.TextSize = 12
urlInput.Parent = printTabFrame
Instance.new("UICorner", urlInput).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", urlInput).Color = Color3.fromRGB(50, 55, 80)

local sizeXInput = Instance.new("TextBox")
sizeXInput.Size = UDim2.new(0, 160, 0, 36)
sizeXInput.Position = UDim2.new(0, 15, 0, 70)
sizeXInput.PlaceholderText = "Ширина (X)"
sizeXInput.Text = "32"
sizeXInput.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
sizeXInput.TextColor3 = Color3.fromRGB(240, 240, 240)
sizeXInput.Font = Enum.Font.Gotham
sizeXInput.Parent = printTabFrame
Instance.new("UICorner", sizeXInput).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", sizeXInput).Color = Color3.fromRGB(50, 55, 80)

local sizeYInput = Instance.new("TextBox")
sizeYInput.Size = UDim2.new(0, 160, 0, 36)
sizeYInput.Position = UDim2.new(1, -175, 0, 70)
sizeYInput.PlaceholderText = "Высота (Y)"
sizeYInput.Text = "32"
sizeYInput.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
sizeYInput.TextColor3 = Color3.fromRGB(240, 240, 240)
sizeYInput.Font = Enum.Font.Gotham
sizeYInput.Parent = printTabFrame
Instance.new("UICorner", sizeYInput).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", sizeYInput).Color = Color3.fromRGB(50, 55, 80)

local buildBtn = Instance.new("TextButton")
buildBtn.Size = UDim2.new(1, -30, 0, 44)
buildBtn.Position = UDim2.new(0, 15, 0, 140)
buildBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
buildBtn.Text = "🔨 ПОСТРОИТЬ"
buildBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
buildBtn.Font = Enum.Font.GothamBold
buildBtn.TextSize = 14
buildBtn.Parent = printTabFrame
Instance.new("UICorner", buildBtn).CornerRadius = UDim.new(0, 8)


-- ВКЛАДКА 2: НАСТРОЙКИ
local settingsTabFrame = Instance.new("Frame")
settingsTabFrame.Size = UDim2.new(1, 0, 1, -40)
settingsTabFrame.Position = UDim2.new(0, 0, 0, 40)
settingsTabFrame.BackgroundTransparency = 1
settingsTabFrame.Visible = false
settingsTabFrame.Parent = mainFrame

local maxBlocksLabel = Instance.new("TextLabel")
maxBlocksLabel.Size = UDim2.new(1, -30, 0, 20)
maxBlocksLabel.Position = UDim2.new(0, 15, 0, 20)
maxBlocksLabel.BackgroundTransparency = 1
maxBlocksLabel.Text = "Лимит блоков пластика на 1 рисунок:"
maxBlocksLabel.TextColor3 = Color3.fromRGB(180, 185, 200)
maxBlocksLabel.Font = Enum.Font.GothamBold
maxBlocksLabel.TextSize = 12
maxBlocksLabel.TextXAlignment = Enum.TextXAlignment.Left
maxBlocksLabel.Parent = settingsTabFrame

local maxBlocksInput = Instance.new("TextBox")
maxBlocksInput.Size = UDim2.new(1, -30, 0, 36)
maxBlocksInput.Position = UDim2.new(0, 15, 0, 45)
maxBlocksInput.PlaceholderText = "Без лимита — оставьте пустым"
maxBlocksInput.Text = "1500"
maxBlocksInput.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
maxBlocksInput.TextColor3 = Color3.fromRGB(240, 240, 240)
maxBlocksInput.Font = Enum.Font.Gotham
maxBlocksInput.TextSize = 13
maxBlocksInput.Parent = settingsTabFrame
Instance.new("UICorner", maxBlocksInput).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", maxBlocksInput).Color = Color3.fromRGB(50, 55, 80)


-- ════════════════════════════════════════════════════════════════════
--  РАБОТА КНОПОК И ПЕРЕКЛЮЧАТЕЛЕЙ (ФУНКЦИОНАЛ)
-- ════════════════════════════════════════════════════════════════════

-- Закрытие GUI на крестик
closeBtn.MouseButton1Click:Connect(function()
    isPrinting = false -- На всякий случай останавливаем печать
    screenGui:Destroy()
end)

-- Переключение на вкладку "Печать"
tabBtn1.MouseButton1Click:Connect(function()
    printTabFrame.Visible = true
    settingsTabFrame.Visible = false
    
    tabBtn1.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
    tabBtn1.BackgroundTransparency = 0
    tabBtn1.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    tabBtn2.BackgroundTransparency = 1
    tabBtn2.TextColor3 = Color3.fromRGB(150, 155, 180)
end)

-- Переключение на вкладку "Настройки"
tabBtn2.MouseButton1Click:Connect(function()
    printTabFrame.Visible = false
    settingsTabFrame.Visible = true
    
    tabBtn2.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
    tabBtn2.BackgroundTransparency = 0
    tabBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    tabBtn1.BackgroundTransparency = 1
    tabBtn1.TextColor3 = Color3.fromRGB(150, 155, 180)
end)


-- ════════════════════════════════════════════════════════════════════
--  ГЛАВНАЯ ЛОГИКА СБОРКИ КАРТИНКИ
-- ════════════════════════════════════════════════════════════════════
local function drawImage(pixelData, sizeX, sizeY)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local startPos = character.HumanoidRootPart.Position + character.HumanoidRootPart.CFrame.LookVector * 15
    local blockSize = 2
    local blocksSpawned = 0
    
    -- Считываем лимит из настроек (если там пусто или текст — ставим бесконечность)
    local maxAllowedBlocks = tonumber(maxBlocksInput.Text) or 999999
    
    isPrinting = true
    
    for y = 1, sizeY do
        for x = 1, sizeX do
            if not isPrinting then break end
            
            -- Проверка лимита блоков
            if blocksSpawned >= maxAllowedBlocks then
                buildBtn.Text = "🛑 Достигнут лимит!"
                buildBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
                task.wait(2)
                isPrinting = false
                return
            end
            
            local pixelIndex = ((y - 1) * sizeX) + x
            local hexColor = pixelData[pixelIndex]
            
            if hexColor and hexColor ~= "TRANSPARENT" then
                local r = tonumber(string.sub(hexColor, 1, 2), 16) / 255
                local g = tonumber(string.sub(hexColor, 3, 4), 16) / 255
                local b = tonumber(string.sub(hexColor, 5, 6), 16) / 255
                local color = Color3.new(r, g, b)
                
                local blockPos = startPos + Vector3.new((x - sizeX/2) * blockSize, (sizeY/2 - y) * blockSize, 0)
                
                spawnBlock(blockPos, color)
                blocksSpawned = blocksSpawned + 1
                
                task.wait(0.015) -- Стабильная задержка против краша дельты
            end
        end
        if not isPrinting then break end
    end
    isPrinting = false
end

-- Кнопка "ПОСТРОИТЬ / ОСТАНОВИТЬ"
buildBtn.MouseButton1Click:Connect(function()
    -- Если печать уже идет — кнопка работает как СТОП
    if isPrinting then
        isPrinting = false
        buildBtn.Text = "🔨 ПОСТРОИТЬ"
        buildBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        return
    end

    local url = urlInput.Text
    local sizeX = tonumber(sizeXInput.Text) or 32
    -- ИСПРАВЛЕНО: Теперь корректно берется текст из sizeYInput
    local sizeY = tonumber(sizeYInput.Text) or 32 
    
    -- Проверка корректности ссылки
    if url == "" or not string.match(url, "^https?://") then
        buildBtn.Text = "❌ Неверный URL ссылки!"
        buildBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        task.wait(1.5)
        buildBtn.Text = "🔨 ПОСТРОИТЬ"
        buildBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        return
    end
    
    buildBtn.Text = "⏳ Обработка фото..."
    buildBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 130)
    
    -- Запрос к API конвертера
    local encodedUrl = HttpService:UrlEncode(url)
    local requestUrl = IMAGE_API .. encodedUrl .. "&width=" .. sizeX .. "&height=" .. sizeY
    
    local success, response = pcall(function()
        return game:HttpGet(requestUrl)
    end)
    
    if success and response then
        local decodeSuccess, pixelTable = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        
        if decodeSuccess and type(pixelTable) == "table" then
            buildBtn.Text = "🛑 ОСТАНОВИТЬ"
            buildBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Красная кнопка стопа во время генерации
            
            drawImage(pixelTable, sizeX, sizeY)
            
            buildBtn.Text = "✅ Готово!"
            buildBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            task.wait(2)
        else
            buildBtn.Text = "❌ Ошибка чтения JSON"
            buildBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
            task.wait(2)
        end
    else
        buildBtn.Text = "❌ Ошибка загрузки"
        buildBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        task.wait(2)
    end
    
    buildBtn.Text = "🔨 ПОСТРОИТЬ"
    buildBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
end)
