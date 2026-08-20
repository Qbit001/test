-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Переменные для отслеживания цели
local targetPlayer = nil
local isFollowing = false
local connection = nil

-- Создание графического интерфейса (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SlapBattlesFollowGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 160)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -80)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Меню можно перетаскивать мышкой
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Slap Battles: Follow Player"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Поле ввода ника
local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0.9, 0, 0, 35)
TextBox.Position = UDim2.new(0.05, 0, 0, 45)
TextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TextBox.BorderSizePixel = 0
TextBox.PlaceholderText = "Введите ник игрока..."
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 13
TextBox.Font = Enum.Font.Gotham
TextBox.Parent = MainFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = TextBox

-- Кнопка активации
local TextButton = Instance.new("TextButton")
TextButton.Size = UDim2.new(0.9, 0, 0, 35)
TextButton.Position = UDim2.new(0.05, 0, 0, 95)
TextButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
TextButton.BorderSizePixel = 0
TextButton.Text = "Идти к игроку"
TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton.TextSize = 14
TextButton.Font = Enum.Font.GothamBold
TextButton.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = TextButton

-- Функция поиска игрока по частичному или полному нику
local function findPlayer(name)
	name = name:lower()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if player.Name:lower():sub(1, #name) == name or player.DisplayName:lower():sub(1, #name) == name then
				return player
			end
		end
	end
	return nil
end

-- Логика движения к цели
local function startFollowing()
	if isFollowing then
		-- Если уже идет, отменяем действие (выступаєт в роли переключателя)
		isFollowing = false
		if connection then connection:Disconnect() end
		Humanoid:MoveTo(HumanoidRootPart.Position)
		TextButton.Text = "Идти к игроку"
		TextButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		return
	end
	
	local targetName = TextBox.Text
	targetPlayer = findPlayer(targetName)
	
	if not targetPlayer then
		TextButton.Text = "Игрок не найден!"
		task.wait(1.5)
		TextButton.Text = "Идти к игроку"
		return
	end
	
	isFollowing = true
	TextButton.Text = "Остановить"
	TextButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	
	-- Обновляем персонажа на случай респавна
	LocalPlayer.CharacterAdded:Connect(function(newChar)
		Character = newChar
		HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
		Humanoid = newChar:WaitForChild("Humanoid")
	end)
	
	connection = RunService.RenderStepped:Connect(function()
		if not isFollowing then return end
		
		-- Проверка, живы ли оба игрока
		if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
			isFollowing = false
			connection:Disconnect()
			TextButton.Text = "Цель потеряна"
			task.wait(1.5)
			TextButton.Text = "Идти к игроку"
			TextButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			return
		end
		
		local targetHRP = targetPlayer.Character.HumanoidRootPart
		local distance = (HumanoidRootPart.Position - targetHRP.Position).Magnitude
		
		-- Если подошли впритык (дистанция меньше 3 studs), останавливаемся
		if distance <= 3 then
			Humanoid:MoveTo(HumanoidRootPart.Position)
			isFollowing = false
			connection:Disconnect()
			TextButton.Text = "Дошли!"
			task.wait(1.5)
			TextButton.Text = "Идти к игроку"
			TextButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		else
			-- Идем за игроком
			Humanoid:MoveTo(targetHRP.Position)
		end
	end)
end

-- Обработка нажатия на кнопку
TextButton.MouseButton1Click:Connect(startFollowing)
