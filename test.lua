--[[
    AUTO BUILDER: IMAGE TO BLOCKS
    Для использования требуется внешний API, возвращающий JSON с пикселями.
--]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ВНИМАНИЕ: Сюда нужно вставлять ссылку на API/JSON, а НЕ прямую ссылку на картинку в Discord!
-- Формат JSON должен быть примерно таким: [{"x":1, "y":1, "r":255, "g":0, "b":0}, ...]
local DATA_URL = "https://твой-сайт.com/get_pixels_json"

-- Настройки
local START_POS = Vector3.new(-50, 5, 50) -- Координаты начала постройки
local BLOCK_SIZE = 2 -- Размер блока (в стадах)
local BUILD_DELAY = 0.05 -- Задержка между установкой блоков (чтобы не кикнуло за спам)

-- Функция получения данных
local function getPixelData()
    local success, result = pcall(function()
        return game:HttpGet(DATA_URL)
    end)
    
    if success and result then
        return HttpService:JSONDecode(result)
    else
        warn("Ошибка: Не удалось получить JSON с пикселями!")
        return nil
    end
end

-- Функция установки одного пикселя (блока)
local function placeAndPaintBlock(x, y, r, g, b)
    local targetPosition = START_POS + Vector3.new(x * BLOCK_SIZE, y * BLOCK_SIZE, 0)
    local targetColor = Color3.fromRGB(r, g, b)
    
    --[[ 
        ВАЖНО ДЛЯ BUILD A BOAT:
        Разработчики игры часто меняют RemoteEvents для защиты от читеров.
        Вам потребуется найти актуальные аргументы для установки пластикового блока и его покраски.
        Обычно это делается через перехват RemoteSpy.
    ]]
    
    pcall(function()
        -- ПРИМЕР ВЫЗОВА (Названия и аргументы могут отличаться в текущей версии игры)
        
        -- 1. Установка блока
        -- local placeArgs = { "PlasticBlock", targetPosition, ... }
        -- workspace.Events.PlaceBlock:FireServer(unpack(placeArgs))
        
        -- 2. Покраска блока
        -- local paintArgs = { workspace.Map.Blocks.LastPlacedBlock, targetColor }
        -- workspace.Events.PaintBlock:FireServer(unpack(paintArgs))
    end)
    
    task.wait(BUILD_DELAY)
end

-- Главный цикл постройки
local function buildImage()
    print("Запрашиваем данные картинки...")
    local pixels = getPixelData()
    
    if not pixels then return end
    print("Найдено " .. #pixels .. " пикселей. Начинаем постройку...")
    
    for i, pixel in ipairs(pixels) do
        placeAndPaintBlock(pixel.x, pixel.y, pixel.r, pixel.g, pixel.b)
        
        -- Отчет о прогрессе
        if i % 50 == 0 then
            print("Построено: " .. i .. " / " .. #pixels)
        end
    end
    
    print("✅ Постройка завершена!")
end

-- Запуск
buildImage()
