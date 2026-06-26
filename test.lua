<КОД>
-- requirements: Delta Executor, HttpGet support
-- env: Roblox Client Environment
-- файл: babft_final_printer.lua

local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

-- Полная конфигурация скрипта
local CONFIG = {
ImageUrl = "https://cdn.discordapp.com/attachments/1234567890/image.png", -- Ссылка на картинку из Discord
TargetPosition = Vector3.new(0, 25, 0), -- Координаты спавна (X, Y, Z)
MaxWidthBlocks = 60,                   -- Размер (максимальная ширина в блоках)
QualityStep = 1,                       -- Качество: 1 = максимальное, 2 = через один пиксель
MaterialType = "Wood",                 -- Материал: Wood, Stone, Gold, Obsidian, Ice, Plastic
BlockSize = Vector3.new(2, 2, 2)       -- Физический размер одного куба
}

local PARSER_SERVICE = "https://api.roblox-image-parser.workers.dev/parse?url="

-- Получение обработанной матрицы цветов от веб-парсера
local function fetchImageMatrix(url, width, step)
local targetUrl = PARSER_SERVICE .. HttpService:UrlEncode(url) .. "&width=" .. tostring(width) .. "&step=" .. tostring(step)
local success, content = pcall(function()
return game:HttpGet(targetUrl)
end)

if not success or not content then
    warn("[-] Ошибка соединения с парсером изображений.")
    return nil
end

local decodeSuccess, parsedData = pcall(function()
    return HttpService:JSONDecode(content)
end)

return decodeSuccess and parsedData or nil
end

-- Адаптивная функция размещения блока в мире
local function placeBlock(position, rgbColor, materialName)
local itemPlacementRemote = Workspace:FindFirstChild("ItemPlacementRemote") or Workspace:FindFirstChild("BuildingItemPlacement")

if itemPlacementRemote and itemPlacementRemote:IsA("RemoteFunction") then
    -- Строим через сетевые ивенты игры, если они доступны в текущей сессии
    pcall(function()
        itemPlacementRemote:InvokeServer(materialName, position, Color3.fromRGB(rgbColor[1], rgbColor[2], rgbColor[3]))
    end)
else
    -- Локальный фолбек-вариант, если структура игры изменилась
    local block = Instance.new("Part")
    block.Size = CONFIG.BlockSize
    block.Position = position
    block.Color = Color3.fromRGB(rgbColor[1], rgbColor[2], rgbColor[3])
    
    local successMat, enumMat = pcall(function() return Enum.Material[materialName] end)
    block.Material = successMat and enumMat or Enum.Material.Plastic
    
    block.Anchored = true
    block.Parent = Workspace
end
end

-- Основной цикл застройки
local function startPrinting()
print("[*] Запрос данных изображения...")
local data = fetchImageMatrix(CONFIG.ImageUrl, CONFIG.MaxWidthBlocks, CONFIG.QualityStep)

if not data or not data.pixels then
    print("[-] Отмена: данные матрицы отсутствуют.")
    return
end

print("[+] Данные получены. Сетка постройки: " .. tostring(data.width) .. "x" .. tostring(data.height))

local startX = CONFIG.TargetPosition.X
local startY = CONFIG.TargetPosition.Y
local startZ = CONFIG.TargetPosition.Z
local bSize = CONFIG.BlockSize

local pixelIndex = 1
for y = 1, data.height do
    for x = 1, data.width do
        local color = data.pixels[pixelIndex]
        if color then
            -- Вычисление позиции с инверсией оси Y, чтобы картинка не шла вверх ногами
            local currentPos = Vector3.new(
                startX + (x * bSize.X),
                startY + ((data.height - y) * bSize.Y),
                startZ
            )
            placeBlock(currentPos, color, CONFIG.MaterialType)
        end
        pixelIndex = pixelIndex + 1
    end
    -- Оптимизированная задержка после каждого ряда пикселей для стабильности Delta Executor
    task.wait(0.05)
end

print("[+] Печать изображения полностью завершена.")
