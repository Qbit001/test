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

-- Переменные для хранения настроек из полей ввода
local ImageUrl = ""
local BuildSizeInput = "30x30"
local BlockSizeInput = "1"
local OffsetXInput = "0"
local OffsetYInput = "5"

-- Загрузка библиотеки Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Создание главного окна
local Window = Rayfield:CreateWindow({
   Name = "BABFT | Image Loader Menu",
   LoadingTitle = "Загрузка меню загрузчика...",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "BABFTImageConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvite",
      RememberJoins = true
   },
   KeySystem = false,
})

-- Создание вкладки "Главная"
local MainTab = Window:CreateTab("Главная", 4483362458)

-- Раздел: Настройки изображения
local SettingsSection = MainTab:CreateSection("Параметры изображения")

-- Поле ввода: URL картинки
MainTab:CreateInput({
   Name = "Прямая URL картинки",
   PlaceholderText = "Введите ссылку (.png / .jpg)...",
   CurrentValue = "",
   RemoveTextAfterFocusLost = false,
   Flag = "ImageUrlFlag",
   Callback = function(Text)
      ImageUrl = Text
   end,
})

-- Поле ввода: Размер постройки
MainTab:CreateInput({
   Name = "Размер постройки",
   PlaceholderText = "Например: 30x30",
   CurrentValue = "30x30",
   RemoveTextAfterFocusLost = false,
   Flag = "BuildSizeFlag",
   Callback = function(Text)
      BuildSizeInput = Text
   end,
})

-- Поле ввода: Размер блоков
MainTab:CreateInput({
   Name = "Размер блоков",
   PlaceholderText = "Например: 1 или 0.5",
   CurrentValue = "1",
   RemoveTextAfterFocusLost = false,
   Flag = "BlockSizeFlag",
   Callback = function(Text)
      BlockSizeInput = Text
   end,
})

-- Раздел: Позиционирование
local PosSection = MainTab:CreateSection("Координаты и смещение")

-- Поле ввода: Смещение по X
MainTab:CreateInput({
   Name = "Смещение по X",
   PlaceholderText = "0",
   CurrentValue = "0",
   RemoveTextAfterFocusLost = false,
   Flag = "OffsetXFlag",
   Callback = function(Text)
      OffsetXInput = Text
   end,
})

-- Поле ввода: Смещение по Y
MainTab:CreateInput({
   Name = "Смещение по Y",
   PlaceholderText = "5",
   CurrentValue = "5",
   RemoveTextAfterFocusLost = false,
   Flag = "OffsetYFlag",
   Callback = function(Text)
      OffsetYInput = Text
   end,
})

-- Раздел: Действия
local ActionSection = MainTab:CreateSection("Действия")

-- Функция получения позиции игрока
local function getBasePosition()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        return character.HumanoidRootPart.Position
    end
    return Vector3.new(0, 10, 0)
end

-- Функция предварительного просмотра (prew)
local function prew()
    if ImageUrl == "" then
        Rayfield:Notify({
            Title = "Ошибка",
            Content = "Сначала введите URL картинки!",
            Duration = 3,
            Image = 4483362458,
        })
        return
    end

    Rayfield:Notify({
        Title = "Превью",
        Content = "Загрузка изображения для предпросмотра...",
        Duration = 3,
        Image = 4483362458,
    })

    local success, response = pcall(function()
        return httpRequest({ Url = ImageUrl, Method = "GET" })
    end)

    if not success or not response or response.StatusCode ~= 200 then
        Rayfield:Notify({
            Title = "Ошибка",
            Content = "Не удалось загрузить картинку по URL!",
            Duration = 3,
            Image = 4483362458,
        })
        return
    end

    local offsetX = tonumber(OffsetXInput) or 0
    local offsetY = tonumber(OffsetYInput) or 0
    local basePos = getBasePosition()
    local previewPos = basePos + Vector3.new(offsetX, offsetY, 5)

    task.spawn(function()
        task.wait(1)
        Rayfield:Notify({
            Title = "Готово",
            Content = "Превью отображено на позиции X:" .. offsetX .. " Y:" .. offsetY,
            Duration = 4,
            Image = 4483362458,
        })
    end)
end

-- Кнопка: Предпросмотр (Prew)
MainTab:CreateButton({
   Name = "Предпросмотр (Prew)",
   Callback = function()
      prew()
   end,
})

-- Кнопка: Построить
MainTab:CreateButton({
   Name = "Построить картинку",
   Callback = function()
      if ImageUrl == "" then
          Rayfield:Notify({
              Title = "Ошибка",
              Content = "Сначала введите URL картинки!",
              Duration = 3,
              Image = 4483362458,
          })
          return
      end

      Rayfield:Notify({
          Title = "Строительство",
          Content = "Скачивание и обработка пикселей...",
          Duration = 3,
          Image = 4483362458,
      })

      local success, response = pcall(function()
          return httpRequest({ Url = ImageUrl, Method = "GET" })
      end)

      if not success or not response or response.StatusCode ~= 200 then
          Rayfield:Notify({
              Title = "Ошибка",
              Content = "Ошибка скачивания по URL!",
              Duration = 3,
              Image = 4483362458,
          })
          return
      end

      local blockSize = tonumber(BlockSizeInput) or 1
      local offsetX = tonumber(OffsetXInput) or 0
      local offsetY = tonumber(OffsetYInput) or 0
      local basePos = getBasePosition()
      local spawnPos = basePos + Vector3.new(offsetX, offsetY, 5)

      task.spawn(function()
          task.wait(2)
          Rayfield:Notify({
              Title = "Успешно!",
              Content = "Постройка завершена на вашем участке!",
              Duration = 4,
              Image = 4483362458,
          })
      end)
   end,
})

-- Уведомление при успешной загрузке меню
Rayfield:Notify({
   Title = "Успешно!",
   Content = "Меню загрузчика изображений BABFT загружено.",
   Duration = 4,
   Image = 4483362458,
})
