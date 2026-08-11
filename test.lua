-- Загрузка библиотеки Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Создание главного окна
local Window = Rayfield:CreateWindow({
   Name = "Slap Battles | Internal Menu",
   LoadingTitle = "Загрузка скрипта...",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "SlapBattlesConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvite",
      RememberJoins = true
   },
   KeySystem = false,
})

-- Создание вкладки "Главная" (Main)
local MainTab = Window:CreateTab("Главная", 4483362458)

-- Раздел для функций перчатки
local MainSection = MainTab:CreateSection("Управление перчаткой")

-- Переключатель: No Cooldown
local NoCooldownToggle = MainTab:CreateToggle({
   Name = "Без кулдауна (No Cooldown)",
   CurrentValue = false,
   Flag = "NoCooldownToggle",
   Callback = function(Value)
      _G.NoCooldownEnabled = Value
      
      task.spawn(function()
         while _G.NoCooldownEnabled do
            pcall(function()
               local player = game:GetService("Players").LocalPlayer
               local character = player.Character
               if character then
                  local tool = character:FindFirstChildOfClass("Tool")
                  if tool then
                     local db = tool:FindFirstChild("Debounce") or tool:FindFirstChild("Cooldown")
                     if db then
                        if db:IsA("NumberValue") or db:IsA("IntValue") then
                           db.Value = 0
                        elseif db:IsA("BoolValue") then
                           db.Value = false
                        end
                     end
                  end
               end
            end)
            task.wait(0.05)
         end
      end)
   end,
})

-- Переключатель: Бесконечная способность Hallow Jack
local HallowJackToggle = MainTab:CreateToggle({
   Name = "Бесконечный Hallow Jack",
   CurrentValue = false,
   Flag = "HallowJackToggle",
   Callback = function(Value)
      _G.InfiniteHallowJackEnabled = Value
      
      task.spawn(function()
         while _G.InfiniteHallowJackEnabled do
            pcall(function()
               local player = game:GetService("Players").LocalPlayer
               local character = player.Character
               if not character then return end
               
               -- Ищем Hallow Jack в руках или рюкзаке
               local tool = character:FindFirstChild("Hallow Jack") 
                  or character:FindFirstChild("HallowJack") 
                  or player.Backpack:FindFirstChild("Hallow Jack") 
                  or player.Backpack:FindFirstChild("HallowJack")
               
               if tool then
                  -- Сбрасываем все значения cooldown/debounce внутри инструмента
                  for _, v in pairs(tool:GetDescendants()) do
                     if v:IsA("NumberValue") or v:IsA("IntValue") then
                        local name = v.Name:lower()
                        if name:find("cooldown") or name:find("time") or name:find("debounce") or name:find("delay") then
                           v.Value = 0
                        end
                     elseif v:IsA("BoolValue") then
                        local name = v.Name:lower()
                        if name:find("cooldown") or name:find("active") or name:find("debounce") then
                           v.Value = false
                        end
                     end
                  end
               end
            end)
            task.wait(0.05)
         end
      end)
   end,
})

-- Кнопка: Быстрый сброс персонажа
local ResetButton = MainTab:CreateButton({
   Name = "Сбросить персонажа",
   Callback = function()
      local player = game:GetService("Players").LocalPlayer
      if player.Character and player.Character:FindFirstChild("Humanoid") then
         player.Character.Humanoid.Health = 0
      end
   end,
})

-- Создание вкладки "Телепорты" (Teleports)
local TeleportTab = Window:CreateTab("Телепорты", 4483362458)
local TpSection = TeleportTab:CreateSection("Зоны")

-- Кнопка телепорта на арену
local ArenaTpButton = TeleportTab:CreateButton({
   Name = "Телепорт на Арену",
   Callback = function()
      pcall(function()
         local player = game:GetService("Players").LocalPlayer
         if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 15, 0)
         end
      end)
   end,
})

-- Уведомление при успешной загрузке меню
Rayfield:Notify({
   Title = "Успешно!",
   Content = "Меню Slap Battles (с Hallow Jack) было успешно загружено.",
   Duration = 4,
   Image = 4483362458,
})
