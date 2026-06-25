--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║        SERVO HAND CONTROL + LIVE SCREEN MIRROR                               ║
║        Build a Boat for Treasure  •  Delta Executor Compatible               ║
╚══════════════════════════════════════════════════════════════════════════════╝
--]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera    = workspace.CurrentCamera
local mouse     = player:GetMouse()

-- ════════════════════════════════════════════════════════════════════
--  КОНФИГУРАЦИЯ
-- ════════════════════════════════════════════════════════════════════
local CFG = {
    servos = {
        { id = "Servo_1", axis = "horizontal", key = Enum.KeyCode.Q, label = "Servo 1", color = Color3.fromRGB(80, 200, 255) },
        { id = "Servo_2", axis = "vertical",   key = Enum.KeyCode.E, label = "Servo 2", color = Color3.fromRGB(100, 255, 160) },
    },
    zones = {
        Servo_1 = { minX = 0.0, maxX = 0.5, minY = 0.0, maxY = 1.0 },
        Servo_2 = { minX = 0.5, maxX = 1.0, minY = 0.0, maxY = 1.0 },
    },
    maxAngle    = 90,
    smoothSpeed = 6.0,
    deadZone    = 0.05,
    sendRate    = 0.04,
    renderRadius = 150, -- Радиус в блоках вокруг игрока, который будет виден в окошке
}

-- ════════════════════════════════════════════════════════════════════
--  УПРАВЛЕНИЕ СЕРВОПРИВОДАМИ
-- ════════════════════════════════════════════════════════════════════
local remoteEvent = nil
pcall(function()
    local folder = ReplicatedStorage:FindFirstChild("ServoRemotes")
    if folder then remoteEvent = folder:FindFirstChild("ServoControl") end
end)

local function applyAngleDirect(servoId, angle)
    pcall(function()
        local boat = workspace:FindFirstChild("BoatModel") or workspace:FindFirstChild(player.Name .. "_Boat")
        if not boat then return end
        local part = boat:FindFirstChild(servoId, true)
        if not part then return end
        local hinge = part:FindFirstChildWhichIsA("HingeConstraint")
        if not hinge then return end
        if hinge.ActuatorType ~= Enum.ActuatorType.Servo then
            hinge.ActuatorType  = Enum.ActuatorType.Servo
            hinge.LimitsEnabled = true
            hinge.LowerAngle    = -CFG.maxAngle
            hinge.UpperAngle    =  CFG.maxAngle
        end
        hinge.AngularSpeed = 250
        hinge.TargetAngle  = math.clamp(angle, -CFG.maxAngle, CFG.maxAngle)
    end)
end

local function sendCommands(commands)
    if remoteEvent then
        pcall(function() remoteEvent:FireServer(commands) end)
    else
        for _, cmd in ipairs(commands) do applyAngleDirect(cmd.id, cmd.angle) end
    end
end

local held, rawNorm, smooth, angles, sendTimer = {}, {}, {}, {}, 0
for _, s in ipairs(CFG.servos) do
    held[s.id] = false rawNorm[s.id] = Vector2.new(0, 0) smooth[s.id] = Vector2.new(0, 0) angles[s.id] = 0
end

local CAM = { active = false }

-- ════════════════════════════════════════════════════════════════════
--  ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ════════════════════════════════════════════════════════════════════
local function screenToNorm(screenPos, zone)
    local vp = camera.ViewportSize
    if vp.X == 0 or vp.Y == 0 then return Vector2.new(0, 0), false end
    local nx, ny  = screenPos.X / vp.X, screenPos.Y / vp.Y
    local inZone = nx >= zone.minX and nx <= zone.maxX and ny >= zone.minY and ny <= zone.maxY
    local zoneW, zoneH = zone.maxX - zone.minX, zone.maxY - zone.minY
    if zoneW == 0 or zoneH == 0 then return Vector2.new(0, 0), false end
    local lx = ((nx - zone.minX) / zoneW) * 2 - 1
    local ly = ((ny - zone.minY) / zoneH) * 2 - 1
    if math.abs(lx) < CFG.deadZone then lx = 0 end
    if math.abs(ly) < CFG.deadZone then ly = 0 end
    return Vector2.new(math.clamp(lx, -1, 1), math.clamp(ly, -1, 1)), inZone
end

local function smoothV2(current, target, speed, dt)
    local diff = target - current
    local maxStep = speed * dt
    if diff.Magnitude <= maxStep then return target end
    return current + diff.Unit * maxStep
end

local function normToAngle(norm, axis)
    if axis == "horizontal" then return  norm.X * CFG.maxAngle end
    if axis == "vertical"   then return -norm.Y * CFG.maxAngle end
    return 0
end

local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragInput, startPos, startFramePos
    dragHandle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true startPos = inp.Position startFramePos = frame.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    dragHandle.InputChanged:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseMovement then dragInput = inp end end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and dragInput and inp == dragInput then
            local delta = inp.Position - startPos
            frame.Position = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset + delta.X, startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
--  GUI
-- ════════════════════════════════════════════════════════════════════
local oldGui = player.PlayerGui:FindFirstChild("ServoControlGUI")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ServoControlGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 340)
mainFrame.Position = UDim2.new(0, 20, 0.5, -170)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(60, 80, 120)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚙  Servo + Screen Mirror"
titleLabel.TextColor3 = Color3.fromRGB(180, 210, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 32, 0, 32)
hideBtn.Position = UDim2.new(1, -40, 0, 6)
hideBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
hideBtn.Text = "—"
hideBtn.TextColor3 = Color3.fromRGB(160, 180, 220)
hideBtn.Font = Enum.Font.GothamBold
hideBtn.Parent = header
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 8)

makeDraggable(mainFrame, header)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -44)
content.Position = UDim2.new(0, 0, 0, 44)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = content

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent = content

local servoCards = {}
local function makeServoCard(parent, servo)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 64)
    card.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(0.6, 0, 0, 22)
    name.Position = UDim2.new(0, 14, 0, 8)
    name.BackgroundTransparency = 1
    name.Text = servo.label .. "  [" .. servo.key.Name .. "]"
    name.TextColor3 = Color3.fromRGB(200, 210, 230)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 12
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = card

    local angleVal = Instance.new("TextLabel")
    angleVal.Size = UDim2.new(0.4, -10, 0, 30)
    angleVal.Position = UDim2.new(0.6, 0, 0, 4)
    angleVal.BackgroundTransparency = 1
    angleVal.Text = "0.0°"
    angleVal.TextColor3 = servo.color
    angleVal.Font = Enum.Font.GothamBold
    angleVal.TextSize = 18
    angleVal.TextXAlignment = Enum.TextXAlignment.Right
    angleVal.Parent = card

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -28, 0, 6)
    barBg.Position = UDim2.new(0, 14, 1, -16)
    barBg.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
    barBg.Parent = card
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0.5, 0, 1, 0)
    barFill.Position = UDim2.new(0.5, 0, 0, 0)
    barFill.BackgroundColor3 = servo.color
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

    servoCards[servo.id] = { angleVal = angleVal, barFill = barFill, color = servo.color }
end

for _, s in ipairs(CFG.servos) do makeServoCard(content, s) end

local camBtn = Instance.new("TextButton")
camBtn.Size = UDim2.new(1, 0, 0, 42)
camBtn.BackgroundColor3 = Color3.fromRGB(25, 60, 100)
camBtn.Text = "📷   Включить стрим экрана"
camBtn.TextColor3 = Color3.fromRGB(120, 190, 255)
camBtn.Font = Enum.Font.GothamBold
camBtn.TextSize = 13
camBtn.Parent = content
Instance.new("UICorner", camBtn).CornerRadius = UDim.new(0, 10)

-- ════════════════════════════════════════════════════════════════════
--  ОКНО ЗЕРКАЛА ЭКРАНА
-- ════════════════════════════════════════════════════════════════════
local camWindow = Instance.new("Frame")
camWindow.Size = UDim2.new(0, 340, 0, 240)
camWindow.Position = UDim2.new(0.5, -170, 0, 20)
camWindow.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
camWindow.Active = true
camWindow.Visible = false
camWindow.Parent = screenGui
Instance.new("UICorner", camWindow).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", camWindow).Color = Color3.fromRGB(255, 160, 60)

local camHeader = Instance.new("Frame")
camHeader.Size = UDim2.new(1, 0, 0, 36)
camHeader.BackgroundColor3 = Color3.fromRGB(40, 24, 10)
camHeader.Parent = camWindow
Instance.new("UICorner", camHeader).CornerRadius = UDim.new(0, 12)

local camTitle = Instance.new("TextLabel")
camTitle.Size = UDim2.new(1, -50, 1, 0)
camTitle.Position = UDim2.new(0, 12, 0, 0)
camTitle.BackgroundTransparency = 1
camTitle.Text = "📺   Прямая трансляция твоей камеры"
camTitle.TextColor3 = Color3.fromRGB(255, 200, 120)
camTitle.Font = Enum.Font.GothamBold
camTitle.TextSize = 12
camTitle.TextXAlignment = Enum.TextXAlignment.Left
camTitle.Parent = camHeader

makeDraggable(camWindow, camHeader)

local viewport = Instance.new("ViewportFrame")
viewport.Size = UDim2.new(1, -16, 1, -48)
viewport.Position = UDim2.new(0, 8, 0, 40)
viewport.BackgroundColor3 = Color3.fromRGB(5, 7, 12)
viewport.Parent = camWindow
Instance.new("UICorner", viewport).CornerRadius = UDim.new(0, 8)

local vpCamera = Instance.new("Camera")
vpCamera.Parent = viewport
viewport.CurrentCamera = vpCamera

-- ════════════════════════════════════════════════════════════════════
--  МЕНЕДЖЕР РЕНДЕРА КАРТЫ В OKHO
-- ════════════════════════════════════════════════════════════════════
local renderedObjects = {}

local function updateViewportWorld()
    if not CAM.active then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Очищаем старые/далекие объекты
    for obj, clone in pairs(renderedObjects) do
        if not obj.Parent or (obj:IsA("BasePart") and (obj.Position - root.Position).Magnitude > CFG.renderRadius) then
            if clone then clone:Destroy() end
            renderedObjects[obj] = nil
        end
    end
    
    -- Ищем постройки вокруг игрока
    local items = workspace:GetPartBoundsInRadius(root.Position, CFG.renderRadius)
    for _, part in ipairs(items) do
        -- Игнорируем инструменты, спец-эффекты и сам GUI
        if part.CanCollide and not part:IsDescendantOf(character) and not part:IsDescendantOf(screenGui) then
            if not renderedObjects[part] then
                pcall(function()
                    local c = part:Clone()
                    c.Anchored = true -- Замораживаем физику в окне
                    c.Parent = viewport
                    renderedObjects[part] = c
                end)
            else
                -- Синхронизируем положение на случай, если постройка движется
                pcall(function()
                    renderedObjects[part].CFrame = part.CFrame
                end)
            end
        end
    end
end

local function setCameraMode(active)
    CAM.active = active
    camWindow.Visible = active
    camBtn.BackgroundColor3 = active and Color3.fromRGB(20, 80, 30) or Color3.fromRGB(25, 60, 100)
    camBtn.TextColor3 = active and Color3.fromRGB(100, 255, 140) or Color3.fromRGB(120, 190, 255)
    camBtn.Text = active and "📷   Выключить стрим" or "📷   Включить стрим экрана"
    
    if not active then
        for _, c in pairs(renderedObjects) do if c then c:Destroy() end end
        renderedObjects = {}
    end
end

-- ════════════════════════════════════════════════════════════════════
--  ИНПУТЫ И КНОПКИ
-- ════════════════════════════════════════════════════════════════════
local menuVisible = true
local function toggleMenu()
    menuVisible = not menuVisible
    content.Visible = menuVisible
    mainFrame.Size = menuVisible and UDim2.new(0, 300, 0, 240) or UDim2.new(0, 300, 0, 44)
    hideBtn.Text = menuVisible and "—" or "+"
end

hideBtn.MouseButton1Click:Connect(toggleMenu)
camBtn.MouseButton1Click:Connect(function() setCameraMode(not CAM.active) end)

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.F1 then toggleMenu() return end
    for _, s in ipairs(CFG.servos) do if inp.KeyCode == s.key then held[s.id] = true end end
end)

UserInputService.InputEnded:Connect(function(inp, gp)
    if gp then return end
    for _, s in ipairs(CFG.servos) do if inp.KeyCode == s.key then held[s.id] = false end end
end)

-- ════════════════════════════════════════════════════════════════════
--  ГЛАВНЫЙ ЦИКЛ
-- ════════════════════════════════════════════════════════════════════
local mapUpdateTimer = 0

RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        local mousePos = Vector2.new(mouse.X, mouse.Y)
        local commands = {}

        -- Обработка сервоприводов
        for _, s in ipairs(CFG.servos) do
            local zone = CFG.zones[s.id]
            local norm, inZone = screenToNorm(mousePos, zone)

            if held[s.id] and inZone then rawNorm[s.id] = norm
            elseif not held[s.id] then rawNorm[s.id] = Vector2.new(0, 0) end

            smooth[s.id] = smoothV2(smooth[s.id], rawNorm[s.id], CFG.smoothSpeed, dt)
            angles[s.id] = normToAngle(smooth[s.id], s.axis)

            table.insert(commands, { id = s.id, angle = angles[s.id] })

            local card = servoCards[s.id]
            if card then
                local a = angles[s.id]
                card.angleVal.Text = string.format("%+.1f°", a)
                local t = a / CFG.maxAngle
                if t >= 0 then
                    card.barFill.Position = UDim2.new(0.5, 0, 0, 0)
                    card.barFill.Size = UDim2.new(t * 0.5, 0, 1, 0)
                else
                    card.barFill.Position = UDim2.new(0.5 + t * 0.5, 0, 0, 0)
                    card.barFill.Size = UDim2.new(-t * 0.5, 0, 1, 0)
                end
            end
        end

        sendTimer = sendTimer + dt
        if sendTimer >= CFG.sendRate then
            sendTimer = 0
            sendCommands(commands)
        end

        -- Стриминг и синхронизация камеры
        if CAM.active then
            -- Идеальная копия ракурса твоих глаз
            vpCamera.CFrame = camera.CFrame
            vpCamera.FieldOfView = camera.FieldOfView
            
            -- Обновляем блоки на карте раз в несколько кадров (для оптимизации FPS)
            mapUpdateTimer = mapUpdateTimer + dt
            if mapUpdateTimer >= 0.1 then 
                mapUpdateTimer = 0
                updateViewportWorld()
            end
        end
    end)
end)
