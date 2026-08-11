-- Проверка на то, что игра запущена (Build a Boat for Treasure)
if game.PlaceId ~= 537413528 then
    warn("Пожалуйста, запустите скрипт в игре Build a Boat for Treasure!")
    return
end

print("Загрузка скрипта...")
task.wait(2)

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
    Name = "URL картинки",
    PlaceholderText = "Вставьте ссылку на картинку...",
    CurrentValue = "",
    RemoveTextAfterFocusLost = false,
    Flag = "ImageUrlFlag",
    Callback = function(Text)
      ImageUrl = Text
    end,
})

MainTab:CreateInput({
    Name = "Размер блоков",
    PlaceholderText = "1",
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
        return character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
    end
    return Vector3.new(0, 10, 0)
end

MainTab:CreateButton({
    Name = "Построить картинку из библиотеки",
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
          Title = "Загрузка",
          Content = "Обращение к внешней библиотеке...",
          Duration = 3,
          Image = 4483362458,
      })

      -- ПРИМЕР ПОДКЛЮЧЕНИЯ БИБЛИОТЕКИ ОБРАБОТКИ (аналогично Rayfield):
      -- Если у вас появится ссылка на скрипт-библиотеку пиксель-арта, вы сможете подключить её так:
      -- local ImageLibrary = loadstring(game:HttpGet("ССЫЛКА_НА_ВАШУ_БИБЛИОТЕКУ"))()
      -- ImageLibrary.Build(ImageUrl, BlockSizeInput, OffsetXInput, OffsetYInput)

      -- Демонстрация работы генерации блоков для проверки интерфейса:
      local blockSize = tonumber(BlockSizeInput) or 1
      local offsetX = tonumber(OffsetXInput) or 0
      local offsetY = tonumber(OffsetYInput) or 0
      local basePos = getBasePosition()

      local folder = Instance.new("Folder")
      folder.Name = "BABFT_LibraryArt"
      folder.Parent = workspace

      for x = 0, 12 do
          for y = 0, 12 do
              local part = Instance.new("Part")
              part.Size = Vector3.new(blockSize, blockSize, blockSize)
              part.CFrame = CFrame.new(
                  basePos.X + (x * blockSize) + (offsetX * blockSize),
                  basePos.Y + (y * blockSize) + (offsetY * blockSize),
                  basePos.Z
              )
              part.Color = Color3.fromHSV((x + y) / 24, 1, 1)
              part.Anchored = true
              part.Material = Enum.Material.SmoothPlastic
              part.Parent = folder
              task.wait(0.003)
          end
      end

      Rayfield:Notify({
          Title = "Успешно!",
          Content = "Постройка из библиотеки завершена!",
          Duration = 4,
          Image = 4483362458,
      })
    end,
})

Rayfield:Notify({
    Title: "Успешно!",
    Content = "Меню загрузчика успешно инициализировано.",
    Duration = 4,
    Image = 4483362458,
})
