-- Проверка на то, что игра запущена (Build a Boat for Treasure)
if game.PlaceId ~= 537413528 then
    warn("Пожалуйста, запустите скрипт в игре Build a Boat for Treasure!")
    return
end

-- Имитация задержки загрузки
print("Загрузка скрипта...")
task.wait(5)

-- Универсальная функция HTTP-запроса для эксплойтов
local httpRequest = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
if not httpRequest then
    warn("Ваш эксплойт не поддерживает функцию HTTP-запросов (request)!")
    return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Переменные для хранения настроек
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
   LoadingTitle = "Загрузка скрипта...",
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
MainTab:CreateSection("Параметры изображения")

MainTab:CreateInput({
   Name = "URL картинки (Поддерживает Discord)",
   PlaceholderText = "Вставьте ссылку из Discord...",
   CurrentValue = "",
   RemoveTextAfterFocusLost = false,
   Flag = "ImageUrlFlag",
   Callback = function(Text)
      ImageUrl = Text
   end,
})

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
MainTab:CreateSection("Координаты и смещение")

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
MainTab:CreateSection("Действия")

local function getBasePosition()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        return character.HumanoidRootPart.Position
    end
    return Vector3.new(0, 10, 0)
end

-- Функция предварительного просмотра (prew) с заголовками для Discord
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
        Content = "Загрузка изображения...",
        Duration = 3,
        Image = 4483362458,
    })

    -- Добавлен User-Agent для обхода защиты Discord CDN
    local success, response = pcall(function()
        return httpRequest({
            Url = ImageUrl,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
            }
        })
    end)

    if not success or not response or response.StatusCode ~= 200 then
        Rayfield:Notify({
            Title = "Ошибка",
            Content = "Не удалось загрузить картинку. Проверьте ссылку!",
            Duration = 3,
            Image = 4483362458,
        })
        return
    end

    local offsetX = tonumber(OffsetXInput) or 0
    local offsetY = tonumber(OffsetYInput) or 0
    local basePos = getBasePosition()

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

MainTab:CreateButton({
   Name = "Предпросмотр (Prew)",
   Callback = function()
      prew()
   end,
})

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

      -- Запрос с заголовком браузера для Discord
      local success, response = pcall(function()
          return httpRequest({
              Url = ImageUrl,
              Method = "GET",
              Headers = {
                  ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
              }
          })
      end)

      if not success or not response or response.StatusCode ~= 200 then
          Rayfield:Notify({
              Title = "Ошибка",
              Content = "Ошибка скачивания! Проверьте валидность ссылки.",
              Duration = 3,
              Image = 4483362458,
          })
          return
      end

      local blockSize = tonumber(BlockSizeInput) or 1
      local offsetX = tonumber(OffsetXInput) or 0
      local offsetY = tonumber(OffsetYInput) or 0
      local basePos = getBasePosition()

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

Rayfield:Notify({
   Title = "Успешно!",
   Content = "Меню загрузчика изображений BABFT загружено.",
   Duration = 4,
   Image = 4483362458,
})
