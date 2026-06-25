--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║        TABBED DISCORD IMAGE PRINTER                                          ║
║        Build a Boat for Treasure  •  Delta Executor Compatible               ║
╚══════════════════════════════════════════════════════════════════════════════╝
--]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local IMAGE_API = "https://image-to-pixel-api.vercel.app/api/convert?url="

-- Переменная для остановки печати, если нужно
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
            -- Локальный бекап для тестов в студии
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
--  ИНТЕРФЕЙС (GUI С ВКЛАДКАМИ)
-- ════════════════════════════════════════════════════════════════════
local oldGui = player.PlayerGui:FindFirstChild("TabbedPrinterGUI")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TabbedPrinterGUI"
screenGui.Parent = player.PlayerGui

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 260)
mainFrame.Position = UDim2.new(0.5, -180, 0.4, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(45, 50, 70)
mainStroke.Thickness = 1.5

-- Панель вкладок (Верхний бар)
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 40)
tabBar.BackgroundColor3 = Color3.fromRGB(28, 30, 43)
tabBar.Parent = mainFrame
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 12)

-- Кнопка Вкладки 1 (Печать)
local tabBtn1 = Instance.new("TextButton")
tabBtn1.Size = UDim2.new(0.5, 0, 1, 0)
tabBtn1.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
tabBtn1.Text = "🖼️ Печать"
tabBtn1.TextColor3 = Color3.fromRGB(255, 255, 255)
tabBtn1.Font = Enum.Font.GothamBold
tabBtn1.TextSize = 13
tabBtn1.Parent = tabBar
Instance.new("UICorner", tabBtn1).CornerRadius = UDim.new(0, 10)

-- Кнопка Вкладки 2 (Настройки)
local tabBtn2 = Instance.new("TextButton")
tabBtn2.Size = UDim2.new(0.5, 0, 1, 0)
tabBtn2.Position = UDim2.new(0.5, 0, 0, 0)
tabBtn2.BackgroundTransparency = 1
tabBtn2.Text = "⚙️ Настройки"
tabBtn2.TextColor3 = Color3.fromRGB(150, 155, 180)
tabBtn2.Font = Enum.Font.GothamBold
tabBtn2.TextSize = 13
tabBtn2.Parent = tabBar
Instance.new("UICorner", tabBtn2).CornerRadius = UDim.new(0, 10)


-- ════════════════════════════════════════════════════════════════════
--  КОНТЕНТ ВКЛАДОК
-- ════════════════════════════════════════════════════════════════════

-- ВКЛАДКА 1: ПЕЧАТЬ
local printTabFrame = Instance.new("Frame")
printTabFrame.Size = UDim2.new(1, 0, 1, -40)
printTabFrame.Position = UDim2.new(0, 0, 0, 40)
printTabFrame.BackgroundTransparency = 1
printTabFrame.Visible = true
printTabFrame.Parent = mainFrame

-- Поле ввода ссылки URL
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

-- Размеры (Ширина и Высота в один ряд)
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

-- Кнопка ПОСТРОИТЬ
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

-- Текст-подпись для лимита блоков
local maxBlocksLabel = Instance.new("TextLabel")
maxBlocksLabel.Size = UDim2.new(1, -30, 0, 20)
maxBlocksLabel.Position = UDim2.new(0, 15, 0, 20)
maxBlocksLabel.BackgroundTransparency = 1
maxBlocksLabel.Text = "Максимальное количество блоков пластика:"
maxBlocksLabel.TextColor3 = Color3.fromRGB(180, 185, 200)
maxBlocksLabel.Font = Enum.Font.GothamBold
maxBlocksLabel.TextSize = 12
maxBlocksLabel.TextXAlignment = Enum.TextXAlignment.Left
maxBlocksLabel.Parent = settingsTabFrame

-- Поле ввода максимального количества блоков
local maxBlocksInput = Instance.new("TextBox")
maxBlocksInput.Size = UDim2.new(1, -30, 0, 36)
maxBlocksInput.Position = UDim2.new(0, 15, 0, 45)
maxBlocksInput.PlaceholderText = "Например: 1000"
maxBlocksInput.Text = "2000" -- Значение по умолчанию
maxBlocksInput.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
maxBlocksInput.TextColor3 = Color3.fromRGB(240, 240, 240)
maxBlocksInput.Font = Enum.Font.Gotham
maxBlocksInput.TextSize = 13
maxBlocksInput.Parent = settingsTabFrame
Instance.new("UICorner", maxBlocksInput).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", maxBlocksInput).Color = Color3.fromRGB(50, 55, 80)


-- ════════════════════════════════════════════════════════════════════
--  ЛОГИКА ПЕРЕКЛЮЧЕНИЯ ВКЛАДОК
-- ════════════════════════════════════════════════════════════════════
tabBtn1.MouseButton1Click:Connect(function()
    -- Включаем вкладку 1
    printTabFrame.Visible = true
    settingsTabFrame.Visible = false
    -- Меняем стили кнопок
    tabBtn1.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
    tabBtn1.BackgroundTransparency = 0
    tabBtn1.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    tabBtn2.BackgroundTransparency = 1
    tabBtn2.TextColor3 = Color3.fromRGB(150, 155, 180)
end)

tabBtn2.MouseButton1Click:Connect(function()
    -- Включаем вкладку 2
    printTabFrame.Visible = false
    settingsTabFrame.Visible = true
    -- Меняем стили кнопок
    tabBtn2.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
    tabBtn2.BackgroundTransparency = 0
    tabBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    tabBtn1.BackgroundTransparency = 1
    tabBtn1.TextColor3 = Color3.fromRGB(150, 155, 180)
end)


-- ════════════════════════════════════════════════════════════════════
--  ЛОГИКА ГЕНЕРАЦИИ И ВЫЧИСЛЕНИЙ
-- ════════════════════════════════════════════════════════════════════
local function drawImage(pixelData, sizeX, sizeY)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local startPos = character.HumanoidRootPart.Position + character.HumanoidRootPart.CFrame.LookVector * 15
    local blockSize = 2
    local blocksSpawned = 0
    
    -- Получаем лимит блоков из второй вкладки
    local maxAllowedBlocks = tonumber(maxBlocksInput.Text) or 999999
    
    isPrinting = true
    
    for y = 1, sizeY do
        for x = 1, sizeX do
            if not isPrinting then break end
            
            -- Проверка на превышение лимита блоков
            if blocksSpawned >= maxAllowedBlocks then
                print("Предупреждение: Достигнут лимит пластика! Печать остановлена.")
                buildBtn.Text = "🛑 Лимит блоков!"
                task.wait(2)
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
                
                task.wait(0.02) -- Защита от вылета Делты
            end
        end
        if not isPrinting then break end
    end
    isPrinting = false
end

buildBtn.MouseButton1Click:Connect(function()
    if isPrinting then
        isPrinting = false
        buildBtn.Text = "🔨 ПОСТРОИТЬ"
        return
    end

    local url = urlInput.Text
    local sizeX = tonumber(sizeXInput.Text) or 32
    local sizeY = tonumber(sizeYInputInput and sizeYInput.Text) or 32
    
    if url == "" or not string.match(url, "^https?://") then
        buildBtn.Text = "❌ Неверный URL!"
        task.wait(1.5)
        buildBtn.Text = "🔨 ПОСТРОИТЬ"
        return
    end
    
    buildBtn.Text = "⏳ Загрузка..."
    
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
            drawImage(pixelTable, sizeX, sizeY)
            buildBtn.Text = "✅ Готово!"
            task.wait(2)
        else
            buildBtn.Text = "❌ Ошибка данных"
        end
    else
        buildBtn.Text = "❌ Ошибка HTTP запроса"
    end
    
    buildBtn.Text = "🔨 ПОСТРОИТЬ"
end)
