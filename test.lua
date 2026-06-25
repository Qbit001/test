--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║        DISCORD IMAGE PRINTER (PIXEL ART GENERATOR)                           ║
║        Build a Boat for Treasure  •  Delta Executor Compatible               ║
╚══════════════════════════════════════════════════════════════════════════════╝
--]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- Универсальный API для десериализации картинок в JSON (Pixel Data)
local IMAGE_API = "https://image-to-pixel-api.vercel.app/api/convert?url="

-- ════════════════════════════════════════════════════════════════════
--  ФУНКЦИЯ СБОРКИ (ПЛЕЙСИНГ БЛОКОВ)
-- ════════════════════════════════════════════════════════════════════
local function spawnBlock(position, color)
    pcall(function()
        -- Вызов оригинального ремоута игры для постройки блока
        -- В Build a Boat используется золотой молот / инструмент постройки
        local workspacePlayer = workspace:FindFirstChild(player.Name)
        if not workspacePlayer then return end
        
        -- Ищем строительный ивент игры
        local buildEvent = game:GetService("ReplicatedStorage"):FindFirstChild("PlaceBlock", true) 
            or game:GetService("Event"):FindFirstChild("PlaceBlock")
            
        if buildEvent then
            -- Передаем параметры: Имя блока (Plastic), Позиция, Поворот, Цвет
            buildEvent:FireServer("PlasticBlock", position, Vector3.new(0,0,0), color)
        else
            -- Альтернативный метод, если ремоут скрыт (локальный спавн для тестов)
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

local function drawImage(pixelData, sizeX, sizeY)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        print("Ошибка: Персонаж не найден!") 
        return 
    end
    
    -- Точка отсчета — чуть впереди игрока
    local startPos = character.HumanoidRootPart.Position + character.HumanoidRootPart.CFrame.LookVector * 15
    local blockSize = 2 -- Размер одного пикселя-блока в игре
    
    print("Начало печати картинки...")
    
    -- Проходим по сетке пикселей
    for y = 1, sizeY do
        for x = 1, sizeX do
            local pixelIndex = ((y - 1) * sizeX) + x
            local hexColor = pixelData[pixelIndex]
            
            if hexColor and hexColor ~= "TRANSPARENT" then
                -- Конвертируем HEX-строку в Color3
                local r = tonumber(string.sub(hexColor, 1, 2), 16) / 255
                local g = tonumber(string.sub(hexColor, 3, 4), 16) / 255
                local b = tonumber(string.sub(hexColor, 5, 6), 16) / 255
                local color = Color3.new(r, g, b)
                
                -- Вычисляем позицию блока в пространстве (вертикальная стена)
                local blockPos = startPos + Vector3.new((x - sizeX/2) * blockSize, (sizeY/2 - y) * blockSize, 0)
                
                spawnBlock(blockPos, color)
                
                -- Микро-задержка, чтобы Delta Executor не вылетел, и античит не кикнул
                task.wait(0.02)
            end
        end
    end
    print("Печать успешно завершена!")
end

-- ════════════════════════════════════════════════════════════════════
--  ИНТЕРФЕЙС (GUI)
-- ════════════════════════════════════════════════════════════════════
local oldGui = player.PlayerGui:FindFirstChild("ImagePrinterGUI")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImagePrinterGUI"
screenGui.Parent = player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 220)
mainFrame.Position = UDim2.new(0.5, -175, 0.4, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🖼️ Discord Image Printer"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- Поле ввода ссылки URL
local urlInput = Instance.new("TextBox")
urlInput.Size = UDim2.new(1, -30, 0, 35)
urlInput.Position = UDim2.new(0, 15, 0, 55)
urlInput.PlaceholderText = "Вставьте ссылку на фото из Discord..."
urlInput.Text = ""
urlInput.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
urlInput.TextColor3 = Color3.fromRGB(230, 230, 230)
urlInput.Font = Enum.Font.Gotham
urlInput.TextSize = 12
urlInput.Parent = mainFrame
Instance.new("UICorner", urlInput).CornerRadius = UDim.new(0, 6)

-- Поле ввода размера (Ширина)
local sizeInputX = Instance.new("TextBox")
sizeInputX.Size = UDim2.new(0, 150, 0, 35)
sizeInputX.Position = UDim2.new(0, 15, 0, 105)
sizeInputX.PlaceholderText = "Ширина (напр. 32)"
sizeInputX.Text = "32"
sizeInputX.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
sizeInputX.TextColor3 = Color3.fromRGB(230, 230, 230)
sizeInputX.Font = Enum.Font.Gotham
sizeInputX.TextSize = 12
sizeInputX.Parent = mainFrame
Instance.new("UICorner", sizeInputX).CornerRadius = UDim.new(0, 6)

-- Поле ввода размера (Высота)
local sizeInputY = Instance.new("TextBox")
sizeInputY.Size = UDim2.new(0, 150, 0, 35)
sizeInputY.Position = UDim2.new(1, -165, 0, 105)
sizeInputY.PlaceholderText = "Высота (напр. 32)"
sizeInputY.Text = "32"
sizeInputY.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
sizeInputY.TextColor3 = Color3.fromRGB(230, 230, 230)
sizeInputY.Font = Enum.Font.Gotham
sizeInputY.TextSize = 12
sizeInputY.Parent = mainFrame
Instance.new("UICorner", sizeInputY).CornerRadius = UDim.new(0, 6)

-- Кнопка Сборки
local buildBtn = Instance.new("TextButton")
buildBtn.Size = UDim2.new(1, -30, 0, 45)
buildBtn.Position = UDim2.new(0, 15, 0, 155)
buildBtn.BackgroundColor3 = Color3.fromRGB(114, 137, 218) -- Цвет Дискорда
buildBtn.Text = "🔨 Начать генерацию блоков"
buildBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
buildBtn.Font = Enum.Font.GothamBold
buildBtn.TextSize = 14
buildBtn.Parent = mainFrame
Instance.new("UICorner", buildBtn).CornerRadius = UDim.new(0, 8)

-- ════════════════════════════════════════════════════════════════════
--  ОБРАБОТКА НАЖАТИЯ
-- ════════════════════════════════════════════════════════════════════
buildBtn.MouseButton1Click:Connect(function()
    local url = urlInput.Text
    local sizeX = tonumber(sizeInputX.Text) or 32
    local sizeY = tonumber(sizeInputY.Text) or 32
    
    if url == "" or not string.match(url, "^https?://") then
        buildBtn.Text = "❌ Неверная ссылка!"
        task.wait(2)
        buildBtn.Text = "🔨 Начать генерацию блоков"
        return
    end
    
    buildBtn.Text = "⏳ Скачивание и обработка..."
    buildBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    
    -- Кодируем URL, чтобы передать его внешнему API сервера
    local encodedUrl = HttpService:UrlEncode(url)
    local requestUrl = IMAGE_API .. encodedUrl .. "&width=" .. sizeX .. "&height=" .. sizeY
    
    -- Используем стандартный функционал Delta Executor для GET запросов
    local success, response = pcall(function()
        return game:HttpGet(requestUrl)
    end)
    
    if success and response then
        local decodeSuccess, pixelTable = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        
        if decodeSuccess and type(pixelTable) == "table" then
            buildBtn.Text = "🧱 Строю... Пожалуйста, ждите"
            buildBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            
            -- Запуск постройки
            drawImage(pixelTable, sizeX, sizeY)
            
            buildBtn.Text = "✅ Готово!"
            task.wait(2)
        else
            buildBtn.Text = "❌ Ошибка парсинга картинки"
        end
    else
        buildBtn.Text = "❌ Ошибка загрузки сервера"
    end
    
    buildBtn.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
    buildBtn.Text = "🔨 Начать генерацию блоков"
end)
