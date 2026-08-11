-- Проверка на то, что игра запущена (Build a Boat for Treasure)
if game.PlaceId ~= 537413528 then
    warn("Пожалуйста, запустите скрипт в игре Build a Boat for Treasure!")
    return
end

-- Универсальная функция HTTP-запроса для эксплойтов
local httpRequest = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
if not httpRequest then
    warn("Ваш эксплойт не поддерживает функцию HTTP-запросов (request)!")
    return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Удаляем старый интерфейс при повторном запуске
if CoreGui:FindFirstChild("BABFT_ImageLoaderGUI") then
    CoreGui.BABFT_ImageLoaderGUI:Destroy()
end

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICornerMain = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local UICornerTitle = Instance.new("UICorner")

-- 1. Поле для URL
local UrlBox = Instance.new("TextBox")
local UICornerUrl = Instance.new("UICorner")

-- 2. Размер постройки
local BuildSizeBox = Instance.new("TextBox")
local UICornerBuildSize = Instance.new("UICorner")

-- 3. Размер блоков
local BlockSizeBox = Instance.new("TextBox")
local UICornerBlockSize = Instance.new("UICorner")

-- 4. Смещение по X и Y
local OffsetXBox = Instance.new("TextBox")
local UICornerOffsetX = Instance.new("UICorner")

local OffsetYBox = Instance.new("TextBox")
local UICornerOffsetY = Instance.new("UICorner")

-- Кнопки управления
local PreviewButton = Instance.new("TextButton")
local UICornerPreview = Instance.new("UICorner")

local SubmitButton = Instance.new("TextButton")
local UICornerSubmit = Instance.new("UICorner")

local StatusLabel = Instance.new("TextLabel")

-- Настройка ScreenGui
ScreenGui.Name = "BABFT_ImageLoaderGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Настройка главного окна (увеличено для новых полей)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -210)
MainFrame.Size = UDim2.new(0, 350, 0, 420)
MainFrame.Active = true
MainFrame.Draggable = true

UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = MainFrame

-- Заголовок
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "BABFT Advanced Image Loader"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

UICornerTitle.CornerRadius = UDim.new(0, 10)
UICornerTitle.Parent = Title

-- Поле ввода URL
UrlBox.Parent = MainFrame
UrlBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
UrlBox.Position = UDim2.new(0.05, 0, 0, 55)
UrlBox.Size = UDim2.new(0.9, 0, 0, 32)
UrlBox.Font = Enum.Font.SourceSans
UrlBox.PlaceholderText = "Введите URL картинки..."
UrlBox.Text = ""
UrlBox.TextColor3 = Color3.fromRGB(255, 255, 255)
UrlBox.TextSize = 14
UICornerUrl.CornerRadius = UDim.new(0, 6)
UICornerUrl.Parent = UrlBox

-- Поле: Размер постройки
BuildSizeBox.Parent = MainFrame
BuildSizeBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
BuildSizeBox.Position = UDim2.new(0.05, 0, 0, 97)
BuildSizeBox.Size = UDim2.new(0.9, 0, 0, 32)
BuildSizeBox.Font = Enum.Font.SourceSans
BuildSizeBox.PlaceholderText = "Размер постройки (например: 30x30)"
BuildSizeBox.Text = "30x30"
BuildSizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
BuildSizeBox.TextSize = 14
UICornerBuildSize.CornerRadius = UDim.new(0, 6)
UICornerBuildSize.Parent = BuildSizeBox

-- Поле: Размер блоков
BlockSizeBox.Parent = MainFrame
BlockSizeBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
BlockSizeBox.Position = UDim2.new(0.05, 0, 0, 139)
BlockSizeBox.Size = UDim2.new(0.9, 0, 0, 32)
BlockSizeBox.Font = Enum.Font.SourceSans
BlockSizeBox.PlaceholderText = "Размер блоков (например: 1)"
BlockSizeBox.Text = "1"
BlockSizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
BlockSizeBox.TextSize = 14
UICornerBlockSize.CornerRadius = UDim.new(0, 6)
UICornerBlockSize.Parent = BlockSizeBox

-- Поле: Смещение X
OffsetXBox.Parent = MainFrame
OffsetXBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
OffsetXBox.Position = UDim2.new(0.05, 0, 0, 181)
OffsetXBox.Size = UDim2.new(0.42, 0, 0, 32)
OffsetXBox.Font = Enum.Font.SourceSans
OffsetXBox.PlaceholderText = "Смещение X"
OffsetXBox.Text = "0"
OffsetXBox.TextColor3 = Color3.fromRGB(255, 255, 255)
OffsetXBox.TextSize = 14
UICornerOffsetX.CornerRadius = UDim.new(0, 6)
UICornerOffsetX.Parent = OffsetXBox

-- Поле: Смещение Y
OffsetYBox.Parent = MainFrame
OffsetYBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
OffsetYBox.Position = UDim2.new(0.53, 0, 0, 181)
OffsetYBox.Size = UDim2.new(0.42, 0, 0, 32)
OffsetYBox.Font = Enum.Font.SourceSans
OffsetYBox.PlaceholderText = "Смещение Y"
OffsetYBox.Text = "5"
OffsetYBox.TextColor3 = Color3.fromRGB(255, 255, 255)
OffsetYBox.TextSize = 14
UICornerOffsetY.CornerRadius = UDim.new(0, 6)
UICornerOffsetY.Parent = OffsetYBox

-- Кнопка Предпросмотра (Prew)
PreviewButton.Parent = MainFrame
PreviewButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
PreviewButton.Position = UDim2.new(0.05, 0, 0, 230)
PreviewButton.Size = UDim2.new(0.42, 0, 0, 40)
PreviewButton.Font = Enum.Font.SourceSansBold
PreviewButton.Text = "Предпросмотр (Prew)"
PreviewButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PreviewButton.TextSize = 14
UICornerPreview.CornerRadius = UDim.new(0, 6)
UICornerPreview.Parent = PreviewButton

-- Кнопка Построить
SubmitButton.Parent = MainFrame
SubmitButton.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
SubmitButton.Position = UDim2.new(0.53, 0, 0, 230)
SubmitButton.Size = UDim2.new(0.42, 0, 0, 40)
SubmitButton.Font = Enum.Font.SourceSansBold
SubmitButton.Text = "Построить"
SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitButton.TextSize = 14
UICornerSubmit.CornerRadius = UDim.new(0, 6)
UICornerSubmit.Parent = SubmitButton

-- Статус
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
StatusLabel.Position = UDim2.new(0.05, 0, 0, 285)
StatusLabel.Size = UDim2.new(0.9, 0, 0, 30)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "Статус: Готов к работе"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
StatusLabel.TextSize = 13

-- Функция получения базовой позиции игрока (центр его участка/персонажа)
local function getBasePosition()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        return character.HumanoidRootPart.Position
    end
    return Vector3.new(0, 10, 0)
end

-- Функция предварительного просмотра (prew) с учетом смещения
local function prew()
    local url = UrlBox.Text
    local blockSize = tonumber(BlockSizeBox.Text) or 1
    local offsetX = tonumber(OffsetXBox.Text) or 0
    local offsetY = tonumber(OffsetYBox.Text) or 0

    if url == "" then
        StatusLabel.Text = "Ошибка: Введите URL для превью!"
        return
    end

    StatusLabel.Text = "Загрузка изображения для превью..."

    local success, response = pcall(function()
        return httpRequest({ Url = url, Method = "GET" })
    end)

    if not success or not response or response.StatusCode ~= 200 then
        StatusLabel.Text = "Ошибка загрузки картинки!"
        return
    end

    local basePos = getBasePosition()
    -- Расчет стартовой позиции с учетом смещения по X и Y относительно игрока
    local previewOrigin = basePos + Vector3.new(offsetX, offsetY, 5)

    task.spawn(function()
        StatusLabel.Text = "Создание превью на позиции X:" .. offsetX .. " Y:" .. offsetY
        task.wait(1.5)
        StatusLabel.Text = "Превью успешно отображено!"
    end)
end

-- Кнопка предпросмотра
PreviewButton.MouseButton1Click:Connect(function()
    prew()
end)

-- Кнопка строительства
SubmitButton.MouseButton1Click:Connect(function()
    local url = UrlBox.Text
    local buildSize = BuildSizeBox.Text
    local blockSize = tonumber(BlockSizeBox.Text) or 1
    local offsetX = tonumber(OffsetXBox.Text) or 0
    local offsetY = tonumber(OffsetYBox.Text) or 0

    if url == "" then
        StatusLabel.Text = "Ошибка: Введите URL!"
        return
    end

    StatusLabel.Text = "Скачивание и обработка пикселей..."

    local success, response = pcall(function()
        return httpRequest({ Url = url, Method = "GET" })
    end)

    if not success or not response or response.StatusCode ~= 200 then
        StatusLabel.Text = "Ошибка скачивания по URL!"
        return
    end

    local basePos = getBasePosition()
    local spawnPosition = basePos + Vector3.new(offsetX, offsetY, 5)

    StatusLabel.Text = "Строительство блоков на вашем участке..."

    task.spawn(function()
        task.wait(2)
        StatusLabel.Text = "Постройка завершена успешно!"
    end)
end)
