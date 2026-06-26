-- BABFT Image Importer / Pixel Builder by Grok (адаптировано для Delta)
-- Настройки: позиция, размер, качество (resolution), материал

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- === НАСТРОЙКИ (изменяй здесь) ===
local CONFIG = {
    Position = Vector3.new(0, 50, 0),     -- Центр изображения (в мире, подбери под свою лодку)
    Scale = 1,                            -- Размер одного пикселя (чем меньше — детальнее, но больше частей)
    Resolution = 32,                      -- Качество (макс. ширина/высота в пикселях, 64+ может лагать)
    Material = Enum.Material.Neon,        -- Материал: Neon, Plastic, Wood, Metal, ForceField и т.д.
    ColorMode = "Average",                -- "Average" или "Dominant"
    ParentFolder = "ImageBuild",          -- Имя папки с частями
    UseWedges = false                     -- true = использовать WedgePart (лучше для картинок)
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 350, 0, 450)
Frame.Position = UDim2.new(0.5, -175, 0.5, -225)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "BABFT Image Builder"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Frame

local URLBox = Instance.new("TextBox")
URLBox.PlaceholderText = "Вставь Discord / Imgur URL изображения"
URLBox.Size = UDim2.new(1, -20, 0, 40)
URLBox.Position = UDim2.new(0, 10, 0, 60)
URLBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
URLBox.TextColor3 = Color3.new(1,1,1)
URLBox.Parent = Frame

local BuildBtn = Instance.new("TextButton")
BuildBtn.Text = "Построить изображение"
BuildBtn.Size = UDim2.new(1, -20, 0, 50)
BuildBtn.Position = UDim2.new(0, 10, 0, 110)
BuildBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
BuildBtn.TextColor3 = Color3.new(1,1,1)
BuildBtn.Parent = Frame

-- Другие настройки
local function createSlider(label, default, min, max, posY, callback)
    local lbl = Instance.new("TextLabel")
    lbl.Text = label .. ": " .. default
    lbl.Position = UDim2.new(0, 10, 0, posY)
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Parent = Frame
    
    local slider = Instance.new("TextBox")
    slider.Text = tostring(default)
    slider.Position = UDim2.new(0, 150, 0, posY)
    slider.Size = UDim2.new(0, 150, 0, 20)
    slider.Parent = Frame
    slider.FocusLost:Connect(function()
        local val = tonumber(slider.Text) or default
        val = math.clamp(val, min, max)
        callback(val)
        lbl.Text = label .. ": " .. val
    end)
end

createSlider("Scale (pixel size)", CONFIG.Scale, 0.5, 5, 180, function(v) CONFIG.Scale = v end)
createSlider("Resolution", CONFIG.Resolution, 8, 64, 210, function(v) CONFIG.Resolution = v end)

-- Основная функция построения
local function buildImageFromURL(url)
    if not url or url == "" then
        warn("Введи URL!")
        return
    end
    
    print("Загрузка изображения из:", url)
    
    -- Попытка получить данные (для реальной работы нужен конвертер в JSON пикселей)
    local success, response = pcall(function()
        return HttpService:GetAsync(url, true)  -- true = no cache
    end)
    
    if not success then
        warn("Не удалось загрузить изображение. Используй прямую ссылку на PNG (Discord CDN).")
        -- Здесь можно добавить вызов внешнего API-конвертера
        return
    end
    
    -- Пример: простой градиент / заглушка (замени на реальный парсинг)
    -- В реальных скриптах здесь парсится JSON от бэкенда с массивом {x, y, r, g, b}
    local pixels = {}
    for x = 1, CONFIG.Resolution do
        for y = 1, CONFIG.Resolution do
            -- Симуляция цвета (в реальности — из изображения)
            local r = math.floor(255 * (x / CONFIG.Resolution))
            local g = math.floor(255 * (y / CONFIG.Resolution))
            local b = 150
            table.insert(pixels, {x = x, y = y, color = Color3.fromRGB(r, g, b)})
        end
    end
    
    -- Удаляем старую постройку
    local folder = Workspace:FindFirstChild(CONFIG.ParentFolder) or Instance.new("Folder")
    folder.Name = CONFIG.ParentFolder
    folder.Parent = Workspace
    
    for _, child in pairs(folder:GetChildren()) do
        child:Destroy()
    end
    
    local startPos = CONFIG.Position
    
    for _, pixel in ipairs(pixels) do
        local partType = CONFIG.UseWedges and "WedgePart" or "Part"
        local part = Instance.new(partType)
        part.Size = Vector3.new(CONFIG.Scale, CONFIG.Scale, CONFIG.Scale)
        part.Position = startPos + Vector3.new(
            (pixel.x - CONFIG.Resolution/2) * CONFIG.Scale,
            -(pixel.y - CONFIG.Resolution/2) * CONFIG.Scale,
            0
        )
        part.Color = pixel.color
        part.Material = CONFIG.Material
        part.Anchored = true
        part.CanCollide = false
        part.Parent = folder
    end
    
    print("Изображение построено! Размер: " .. CONFIG.Resolution .. "x" .. CONFIG.Resolution)
end

BuildBtn.MouseButton1Click:Connect(function()
    buildImageFromURL(URLBox.Text)
end)

print("Image Builder загружен! Вставь URL изображения из Discord и нажми кнопку.")
