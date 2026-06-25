--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║        DISCORD IMAGE PRINTER  •  OVERHEAD & PREVIEW EDITION                  ║
║        Build a Boat for Treasure  •  Delta Executor Compatible               ║
╚══════════════════════════════════════════════════════════════════════════════╝
--]]

local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local player           = Players.LocalPlayer

local IMAGE_API = "https://image-to-pixel-api.vercel.app/api/convert?url="
local isPrinting = false 
local lastFetchedData = nil
local lastFetchedUrl = ""
local lastFetchedSize = 0

-- Настройки размеров (Пресеты для кнопки выбора размера)
local sizePresets = {16, 32, 48, 64}
local currentSizeIdx = 2 -- По умолчанию 32x32

-- ════════════════════════════════════════════════════════════════════
--  ФУНКЦИЯ СПАВНА БЛОКОВ (ПЛАСТИК)
-- ════════════════════════════════════════════════════════════════════
local function spawnBlock(position, color)
    pcall(function()
        local buildEvent = game:GetService("ReplicatedStorage"):FindFirstChild("PlaceBlock", true) 
            or game:GetService("Event"):FindFirstChild("PlaceBlock")
            
        if buildEvent then
            -- Строго PlasticBlock для идеального цвета
            buildEvent:FireServer("PlasticBlock", position, Vector3.new(0,0,0), color)
        else
            -- Локальный спавн на случай сбоя ремоута
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
--  ИНТЕРФЕЙС (GUI С КНОПКОЙ PREW И ВЫБОРОМ РАЗМЕРА)
-- ════════════════════════════════════════════════════════════════════
local oldGui = player.PlayerGui:FindFirstChild("OverheadPrinterGUI")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OverheadPrinterGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Главное окно (увеличено по высоте для превью)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 390)
mainFrame.Position = UDim2.new(0.5, -180, 0.4, -195)
mainFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(60, 65, 90)

-- Драг-скрипт панели
local function makeDraggable(frame, handle)
    local dragging, dragInput, startPos, startFramePos
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true startPos = inp.Position startFramePos = frame.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    handle.InputChanged:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then dragInput = inp end end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and dragInput and inp == dragInput then
            local delta = inp.Position - startPos
            frame.Position = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset + delta.X, startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y)
        end
    end)
end

-- Верхний бар (Вкладки)
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 40)
tabBar.BackgroundColor3 = Color3.fromRGB(26, 28, 40)
tabBar.Parent = mainFrame
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 12)
makeDraggable(mainFrame, tabBar)

local tabBtn1 = Instance.new("TextButton")
tabBtn1.Size = UDim2.new(0.4, 0, 1, 0)
tabBtn1.BackgroundColor3 = Color3.fromRGB(36, 42, 64)
tabBtn1.Text = "🖼️ Печать"
tabBtn1.TextColor3 = Color3.fromRGB(255, 255, 255)
tabBtn1.Font = Enum.Font.GothamBold
tabBtn1.TextSize = 13
tabBtn1.Parent = tabBar
Instance.new("UICorner", tabBtn1).CornerRadius = UDim.new(0, 10)

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

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -36, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(46, 32, 36)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = tabBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- ════════════════════════════════════════════════════════════════════
--  КОНТЕНТ ВКЛАДОК
-- ════════════════════════════════════════════════════════════════════

-- ВКЛАДКА 1: ПЕЧАТЬ
local printTabFrame = Instance.new("Frame")
printTabFrame.Size = UDim2.new(1, 0, 1, -40)
printTabFrame.Position = UDim2.new(0, 0, 0, 40)
printTabFrame.BackgroundTransparency = 1
printTabFrame.Parent = mainFrame

-- URL инпут
local urlInput = Instance.new("TextBox")
urlInput.Size = UDim2.new(1, -30, 0, 36)
urlInput.Position = UDim2.new(0, 15, 0, 15)
urlInput.PlaceholderText = "Вставьте ссылку на фото из Discord..."
urlInput.Text = ""
urlInput.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
urlInput.TextColor3 = Color3.fromRGB(240, 240, 240)
urlInput.Font = Enum.Font.Gotham
urlInput.TextSize = 12
urlInput.Parent = printTabFrame
Instance.new("UICorner", urlInput).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", urlInput).Color = Color3.fromRGB(50, 55, 80)

-- Кнопка выбора размера картинки
local sizeBtn = Instance.new("TextButton")
sizeBtn.Size = UDim2.new(1, -30, 0, 36)
sizeBtn.Position = UDim2.new(0, 15, 0, 60)
sizeBtn.BackgroundColor3 = Color3.fromRGB(36, 42, 64)
sizeBtn.Text = "📐 Размер: " .. sizePresets[currentSizeIdx] .. "x" .. sizePresets[currentSizeIdx]
sizeBtn.TextColor3 = Color3.fromRGB(230, 240, 255)
sizeBtn.Font = Enum.Font.GothamBold
sizeBtn.TextSize = 12
sizeBtn.Parent = printTabFrame
Instance.new("UICorner", sizeBtn).CornerRadius = UDim.new(0, 6)

-- Окно цифрового PREW-превью
local previewCanvas = Instance.new("Frame")
previewCanvas.Size = UDim2.new(0, 130, 0, 130)
previewCanvas.Position = UDim2.new(0.5, -65, 0, 110)
previewCanvas.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
previewCanvas.ClipsDescendants = true
previewCanvas.Parent = printTabFrame
Instance.new("UICorner", previewCanvas).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", previewCanvas).Color = Color3.fromRGB(40, 45, 60)

local previewLabel = Instance.new("TextLabel")
previewLabel.Size = UDim2.new(1, 0, 1, 0)
previewLabel.BackgroundTransparency = 1
previewLabel.Text = "Нет превью"
previewLabel.TextColor3 = Color3.fromRGB(100, 105, 120)
previewLabel.Font = Enum.Font.Gotham
previewLabel.TextSize = 11
previewLabel.Parent = previewCanvas

-- Кнопка PREW
local prewBtn = Instance.new("TextButton")
prewBtn.Size = UDim2.new(0.45, -5, 0, 40)
prewBtn.Position = UDim2.new(0, 15, 0, 255)
prewBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
prewBtn.Text = "🔍 PREW"
prewBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
prewBtn.Font = Enum.Font.GothamBold
prewBtn.TextSize = 13
prewBtn.Parent = printTabFrame
Instance.new("UICorner", prewBtn).CornerRadius = UDim.new(0, 8)

-- Кнопка ПОСТРОИТЬ
local buildBtn = Instance.new("TextButton")
buildBtn.Size = UDim2.new(0.45, -5, 0, 40)
buildBtn.Position = UDim2.new(0.55, 0, 0, 255)
buildBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
buildBtn.Text = "🔨 ПОСТРОИТЬ"
buildBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
buildBtn.Font = Enum.Font.GothamBold
buildBtn.TextSize = 13
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
maxBlocksLabel.Text = "Лимит блоков пластика на рисунок:"
maxBlocksLabel.TextColor3 = Color3.fromRGB(180, 185, 200)
maxBlocksLabel.Font = Enum.Font.GothamBold
maxBlocksLabel.TextSize = 12
maxBlocksLabel.TextXAlignment = Enum.TextXAlignment.Left
maxBlocksLabel.Parent = settingsTabFrame

local maxBlocksInput = Instance.new("TextBox")
maxBlocksInput.Size = UDim2.new(1, -30, 0, 36)
maxBlocksInput.Position = UDim2.new(0, 15, 0, 45)
maxBlocksInput.PlaceholderText = "Без лимита — пусто"
maxBlocksInput.Text = "2500"
maxBlocksInput.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
maxBlocksInput.TextColor3 = Color3.fromRGB(240, 240, 240)
maxBlocksInput.Font = Enum.Font.Gotham
maxBlocksInput.Parent = settingsTabFrame
Instance.new("UICorner", maxBlocksInput).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", maxBlocksInput).Color = Color3.fromRGB(50, 55, 80)


-- ════════════════════════════════════════════════════════════════════
--  ЛОГИКА ФУНКЦИОНАЛА GUI
-- ════════════════════════════════════════════════════════════════════

closeBtn.MouseButton1Click:Connect(function() isPrinting = false screenGui:Destroy() end)

tabBtn1.MouseButton1Click:Connect(function()
    printTabFrame.Visible = true settingsTabFrame.Visible = false
    tabBtn1.BackgroundColor3 = Color3.fromRGB(36, 42, 64) tabBtn1.BackgroundTransparency = 0 tabBtn1.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn2.BackgroundTransparency = 1 tabBtn2.TextColor3 = Color3.fromRGB(150, 155, 180)
end)

tabBtn2.MouseButton1Click:Connect(function()
    printTabFrame.Visible = false settingsTabFrame.Visible = true
    tabBtn2.BackgroundColor3 = Color3.fromRGB(36, 42, 64) tabBtn2.BackgroundTransparency = 0 tabBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn1.BackgroundTransparency = 1 tabBtn1.TextColor3 = Color3.fromRGB(150, 155, 180)
end)

-- Функционал кнопки выбора размера (кликер)
sizeBtn.MouseButton1Click:Connect(function()
    currentSizeIdx = (currentSizeIdx % #sizePresets) + 1
    local newSize = sizePresets[currentSizeIdx]
    sizeBtn.Text = "📐 Размер: " .. newSize .. "x" .. newSize
end)

-- Функция отрисовки GUI Превью (внутри окна чита)
local function renderGuiPreview(pixelData, size)
    previewCanvas:ClearAllChildren()
    Instance.new("UIStroke", previewCanvas).Color = Color3.fromRGB(40, 45, 60)
    
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(1/size, 0, 1/size, 0)
    grid.CellPadding = UDim2.new(0, 0, 0, 0)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = previewCanvas

    for i = 1, size * size do
        local hexColor = pixelData[i]
        local p = Instance.new("Frame")
        p.BorderSizePixel = 0
        p.LayoutOrder = i
        
        if hexColor and hexColor ~= "TRANSPARENT" then
            local r = tonumber(string.sub(hexColor, 1, 2), 16) / 255
            local g = tonumber(string.sub(hexColor, 3, 4), 16) / 255
            local b = tonumber(string.sub(hexColor, 5, 6), 16) / 255
            p.BackgroundColor3 = Color3.new(r, g, b)
        else
            p.BackgroundTransparency = 1
        end
        p.Parent = previewCanvas
    end
end

-- Общая функция загрузки данных изображения с сервера API
local function fetchImageData(url, size)
    if lastFetchedUrl == url and lastFetchedSize == size and lastFetchedData then
        return lastFetchedData
    end
    
    local encodedUrl = HttpService:UrlEncode(url)
    local requestUrl = IMAGE_API .. encodedUrl .. "&width=" .. size .. "&height=" .. size
    
    local success, response = pcall(function() return game:HttpGet(requestUrl) end)
    if success and response then
        local decodeSuccess, tableData = pcall(function() return HttpService:JSONDecode(response) end)
        if decodeSuccess and type(tableData) == "table" then
            lastFetchedData = tableData
            lastFetchedUrl = url
            lastFetchedSize = size
            return tableData
        end
    end
    return nil
end


-- ════════════════════════════════════════════════════════════════════
--  РАБОТА КНОПКИ PREW И ГЕНЕРАЦИИ НАД ИГРОКОМ
-- ════════════════════════════════════════════════════════════════════

-- Функционал кнопки PREW
prewBtn.MouseButton1Click:Connect(function()
    local url = urlInput.Text
    local size = sizePresets[currentSizeIdx]
    
    if url == "" or not string.match(url, "^https?://") then
        prewBtn.Text = "❌ Плохой URL"
        task.wait(1.5)
        prewBtn.Text = "🔍 PREW"
        return
    end
    
    prewBtn.Text = "⏳ Загрузка..."
    local data = fetchImageData(url, size)
    
    if data then
        renderGuiPreview(data, size)
        prewBtn.Text = "🔍 PREW"
    else
        prewBtn.Text = "❌ Ошибка"
        task.wait(1.5)
        prewBtn.Text = "🔍 PREW"
    end
end)

-- Функция постройки блоков над игроком
local function drawImageOverhead(pixelData, size)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    -- НОВАЯ ПОЗИЦИЯ: Ровно над головой игрока, поднятая на 25 блоков вверх
    local startPos = character.HumanoidRootPart.Position + Vector3.new(0, 25, 0)
    local blockSize = 2
    local blocksSpawned = 0
    local maxAllowedBlocks = tonumber(maxBlocksInput.Text) or 999999
    
    isPrinting = true
    
    for y = 1, size do
        for x = 1, size do
            if not isPrinting then break end
            
            if blocksSpawned >= maxAllowedBlocks then
                buildBtn.Text = "🛑 Лимит!"
                task.wait(2)
                isPrinting = false
                return
            end
            
            local pixelIndex = ((y - 1) * size) + x
            local hexColor = pixelData[pixelIndex]
            
            if hexColor and hexColor ~= "TRANSPARENT" then
                local r = tonumber(string.sub(hexColor, 1, 2), 16) / 255
                local g = tonumber(string.sub(hexColor, 3, 4), 16) / 255
                local b = tonumber(string.sub(hexColor, 5, 6), 16) / 255
                local color = Color3.new(r, g, b)
                
                -- Генерация вертикального полотна над головой
                local blockPos = startPos + Vector3.new((x - size/2) * blockSize, (size/2 - y) * blockSize, 0)
                
                spawnBlock(blockPos, color)
                blocksSpawned = blocksSpawned + 1
                
                task.wait(0.015) -- Безопасный тайминг для Delta Executor
            end
        end
        if not isPrinting then break end
    end
    isPrinting = false
end

-- Функционал кнопки ПОСТРОИТЬ
buildBtn.MouseButton1Click:Connect(function()
    if isPrinting then
        isPrinting = false
        buildBtn.Text = "🔨 ПОСТРОИТЬ"
        buildBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        return
    end

    local url = urlInput.Text
    local size = sizePresets[currentSizeIdx]
    
    if url == "" or not string.match(url, "^https?://") then
        buildBtn.Text = "❌ Нет ссылки"
        buildBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        task.wait(1.5)
        buildBtn.Text = "🔨 ПОСТРОИТЬ"
        buildBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        return
    end
    
    buildBtn.Text = "⏳ Подготовка..."
    buildBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 130)
    
    local data = fetchImageData(url, size)
    
    if data then
        buildBtn.Text = "🛑 СТОП"
        buildBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        
        drawImageOverhead(data, size)
        
        buildBtn.Text = "✅ Готово!"
        buildBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
        task.wait(2)
    else
        buildBtn.Text = "❌ Ошибка загрузки"
        buildBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        task.wait(2)
    end
    
    buildBtn.Text = "🔨 ПОСТРОИТЬ"
    buildBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
end)
