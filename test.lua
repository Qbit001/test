--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║        SERVO HAND CONTROL + CAMERA MENU                                      ║
║        Build a Boat for Treasure  •  Delta Executor Compatible               ║
║                                                                              ║
║   УСТАНОВКА В DELTA:                                                         ║
║   1. Открой Delta Executor                                                   ║
║   2. Вставь весь этот код в поле скрипта                                     ║
║   3. Нажми Execute                                                           ║
║                                                                              ║
║   УПРАВЛЕНИЕ:                                                                ║
║   • Зажми Q + двигай мышь → Servo_1 (горизонталь)                           ║
║   • Зажми E + двигай мышь → Servo_2 (вертикаль)                             ║
║   • Кнопка [📷 Camera] в меню → режим просмотра камеры                      ║
║   • F1 → скрыть/показать меню                                                ║
╚══════════════════════════════════════════════════════════════════════════════╝
--]]

-- ════════════════════════════════════════════════════════════════════
--  СЕРВИСЫ
-- ════════════════════════════════════════════════════════════════════
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
    camFOV      = 70,
    camSensX    = 0.3,
    camSensY    = 0.2,
    camDistance = 20,
}

-- ════════════════════════════════════════════════════════════════════
--  REMOTEEVENT — только ищем существующий (клиент не может создавать)
-- ════════════════════════════════════════════════════════════════════
local remoteEvent = nil
pcall(function()
    local folder = ReplicatedStorage:FindFirstChild("ServoRemotes")
    if folder then
        remoteEvent = folder:FindFirstChild("ServoControl")
    end
end)

local function applyAngleDirect(servoId, angle)
    pcall(function()
        local boat = workspace:FindFirstChild("BoatModel")
            or workspace:FindFirstChild(player.Name .. "_Boat")
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
        for _, cmd in ipairs(commands) do
            applyAngleDirect(cmd.id, cmd.angle)
        end
    end
end

-- ════════════════════════════════════════════════════════════════════
--  СОСТОЯНИЕ СЕРВОПРИВОДОВ
-- ════════════════════════════════════════════════════════════════════
local held      = {}
local rawNorm   = {}
local smooth    = {}
local angles    = {}
local sendTimer = 0

for _, s in ipairs(CFG.servos) do
    held[s.id]    = false
    rawNorm[s.id] = Vector2.new(0, 0)
    smooth[s.id]  = Vector2.new(0, 0)
    angles[s.id]  = 0
end

-- ════════════════════════════════════════════════════════════════════
--  СОСТОЯНИЕ КАМЕРЫ
-- ════════════════════════════════════════════════════════════════════
local CAM = {
    active    = false,
    yaw       = 0,
    pitch     = 0,
    distance  = CFG.camDistance,
    fov       = CFG.camFOV,
    target    = nil,
}

-- ════════════════════════════════════════════════════════════════════
--  ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ════════════════════════════════════════════════════════════════════
local function screenToNorm(screenPos, zone)
    local vp = camera.ViewportSize
    if vp.X == 0 or vp.Y == 0 then return Vector2.new(0, 0), false end
    local nx  = screenPos.X / vp.X
    local ny  = screenPos.Y / vp.Y
    local inZone = nx >= zone.minX and nx <= zone.maxX
               and ny >= zone.minY and ny <= zone.maxY
    local zoneW = zone.maxX - zone.minX
    local zoneH = zone.maxY - zone.minY
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

local function lerp(a, b, t) return a + (b - a) * t end

-- ════════════════════════════════════════════════════════════════════
--  РУЧНОЙ DRAG (замена устаревшего .Draggable)
-- ════════════════════════════════════════════════════════════════════
local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragInput, startPos, startFramePos

    dragHandle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = inp.Position
            startFramePos = frame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = inp
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if dragging and dragInput and inp == dragInput then
            local delta = inp.Position - startPos
            frame.Position = UDim2.new(
                startFramePos.X.Scale,
                startFramePos.X.Offset + delta.X,
                startFramePos.Y.Scale,
                startFramePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
--  GUI — ГЛАВНОЕ МЕНЮ
-- ════════════════════════════════════════════════════════════════════
local oldGui = player.PlayerGui:FindFirstChild("ServoControlGUI")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "ServoControlGUI"
screenGui.ResetOnSpawn   = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent         = player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name                   = "MainFrame"
mainFrame.Size                   = UDim2.new(0, 300, 0, 420)
mainFrame.Position               = UDim2.new(0, 20, 0.5, -210)
mainFrame.BackgroundColor3       = Color3.fromRGB(14, 16, 22)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel        = 0
mainFrame.Active                 = true
mainFrame.Parent                 = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color     = Color3.fromRGB(60, 80, 120)
stroke.Thickness = 1.5
stroke.Parent    = mainFrame

-- Заголовок
local header = Instance.new("Frame")
header.Size             = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
header.BorderSizePixel  = 0
header.Parent           = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local headerFix = Instance.new("Frame")
headerFix.Size             = UDim2.new(1, 0, 0, 12)
headerFix.Position         = UDim2.new(0, 0, 1, -12)
headerFix.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
headerFix.BorderSizePixel  = 0
headerFix.Parent           = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size               = UDim2.new(1, -50, 1, 0)
titleLabel.Position           = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text               = "⚙  Servo Hand Control"
titleLabel.TextColor3         = Color3.fromRGB(180, 210, 255)
titleLabel.Font               = Enum.Font.GothamBold
titleLabel.TextSize           = 14
titleLabel.TextXAlignment     = Enum.TextXAlignment.Left
titleLabel.Parent             = header

local hideBtn = Instance.new("TextButton")
hideBtn.Size             = UDim2.new(0, 32, 0, 32)
hideBtn.Position         = UDim2.new(1, -40, 0, 6)
hideBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
hideBtn.BorderSizePixel  = 0
hideBtn.Text             = "—"
hideBtn.TextColor3       = Color3.fromRGB(160, 180, 220)
hideBtn.Font             = Enum.Font.GothamBold
hideBtn.TextSize         = 16
hideBtn.Parent           = header
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 8)

-- Drag на заголовок
makeDraggable(mainFrame, header)

-- Контент-зона
local content = Instance.new("Frame")
content.Name                 = "Content"
content.Size                 = UDim2.new(1, 0, 1, -44)
content.Position             = UDim2.new(0, 0, 0, 44)
content.BackgroundTransparency = 1
content.Parent               = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding             = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent              = content

local padding = Instance.new("UIPadding")
padding.PaddingTop   = UDim.new(0, 10)
padding.PaddingLeft  = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent       = content

local function makeSection(parent, title)
    local sec = Instance.new("Frame")
    sec.Size                 = UDim2.new(1, 0, 0, 20)
    sec.BackgroundTransparency = 1
    sec.Parent               = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size                 = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                 = title
    lbl.TextColor3           = Color3.fromRGB(100, 120, 160)
    lbl.Font                 = Enum.Font.GothamBold
    lbl.TextSize             = 10
    lbl.TextXAlignment       = Enum.TextXAlignment.Left
    lbl.Parent               = sec
    return sec
end

-- ── Карточки сервоприводов ────────────────────────────────────────
local servoCards = {}

local function makeServoCard(parent, servo)
    local card = Instance.new("Frame")
    card.Size             = UDim2.new(1, 0, 0, 72)
    card.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
    card.BorderSizePixel  = 0
    card.Parent           = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local bar = Instance.new("Frame")
    bar.Size             = UDim2.new(0, 3, 0.7, 0)
    bar.Position         = UDim2.new(0, 6, 0.15, 0)
    bar.BackgroundColor3 = servo.color
    bar.BorderSizePixel  = 0
    bar.Parent           = card
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local name = Instance.new("TextLabel")
    name.Size                 = UDim2.new(0.6, 0, 0, 22)
    name.Position             = UDim2.new(0, 18, 0, 8)
    name.BackgroundTransparency = 1
    name.Text                 = servo.label .. "  [" .. servo.key.Name .. "]"
    name.TextColor3           = Color3.fromRGB(200, 210, 230)
    name.Font                 = Enum.Font.GothamBold
    name.TextSize             = 12
    name.TextXAlignment       = Enum.TextXAlignment.Left
    name.Parent               = card

    local axis = Instance.new("TextLabel")
    axis.Size                 = UDim2.new(0.6, 0, 0, 16)
    axis.Position             = UDim2.new(0, 18, 0, 28)
    axis.BackgroundTransparency = 1
    axis.Text                 = "Ось: " .. servo.axis
    axis.TextColor3           = Color3.fromRGB(100, 110, 130)
    axis.Font                 = Enum.Font.Gotham
    axis.TextSize             = 10
    axis.TextXAlignment       = Enum.TextXAlignment.Left
    axis.Parent               = card

    local angleVal = Instance.new("TextLabel")
    angleVal.Size                 = UDim2.new(0.4, -10, 0, 30)
    angleVal.Position             = UDim2.new(0.6, 0, 0, 6)
    angleVal.BackgroundTransparency = 1
    angleVal.Text                 = "0.0°"
    angleVal.TextColor3           = servo.color
    angleVal.Font                 = Enum.Font.GothamBold
    angleVal.TextSize             = 20
    angleVal.TextXAlignment       = Enum.TextXAlignment.Right
    angleVal.Parent               = card

    local barBg = Instance.new("Frame")
    barBg.Size             = UDim2.new(1, -18, 0, 6)
    barBg.Position         = UDim2.new(0, 9, 1, -18)
    barBg.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
    barBg.BorderSizePixel  = 0
    barBg.Parent           = card
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local barFill = Instance.new("Frame")
    barFill.Size             = UDim2.new(0.5, 0, 1, 0)
    barFill.Position         = UDim2.new(0.5, 0, 0, 0)
    barFill.BackgroundColor3 = servo.color
    barFill.BorderSizePixel  = 0
    barFill.Parent           = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

    local center = Instance.new("Frame")
    center.Size             = UDim2.new(0, 1, 1, 2)
    center.Position         = UDim2.new(0.5, 0, 0, -1)
    center.BackgroundColor3 = Color3.fromRGB(80, 90, 110)
    center.BorderSizePixel  = 0
    center.Parent           = barBg

    local dot = Instance.new("Frame")
    dot.Size             = UDim2.new(0, 8, 0, 8)
    dot.Position         = UDim2.new(1, -14, 0, 10)
    dot.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
    dot.BorderSizePixel  = 0
    dot.Parent           = card
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    servoCards[servo.id] = {
        angleVal = angleVal,
        barFill  = barFill,
        dot      = dot,
        color    = servo.color,
    }
    return card
end

makeSection(content, "СЕРВОПРИВОДЫ")
for _, s in ipairs(CFG.servos) do
    makeServoCard(content, s)
end

local divider = Instance.new("Frame")
divider.Size             = UDim2.new(1, 0, 0, 1)
divider.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
divider.BorderSizePixel  = 0
divider.Parent           = content

makeSection(content, "РЕЖИМ КАМЕРЫ")

local camBtn = Instance.new("TextButton")
camBtn.Size             = UDim2.new(1, 0, 0, 42)
camBtn.BackgroundColor3 = Color3.fromRGB(25, 60, 100)
camBtn.BorderSizePixel  = 0
camBtn.Text             = "📷   Включить просмотр камеры"
camBtn.TextColor3       = Color3.fromRGB(120, 190, 255)
camBtn.Font             = Enum.Font.GothamBold
camBtn.TextSize         = 13
camBtn.Parent           = content
Instance.new("UICorner", camBtn).CornerRadius = UDim.new(0, 10)

-- ── Слайдер FOV ───────────────────────────────────────────────────
local fovRow = Instance.new("Frame")
fovRow.Size             = UDim2.new(1, 0, 0, 36)
fovRow.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
fovRow.BorderSizePixel  = 0
fovRow.Parent           = content
Instance.new("UICorner", fovRow).CornerRadius = UDim.new(0, 10)

local fovLbl = Instance.new("TextLabel")
fovLbl.Size                 = UDim2.new(0, 80, 1, 0)
fovLbl.Position             = UDim2.new(0, 10, 0, 0)
fovLbl.BackgroundTransparency = 1
fovLbl.Text                 = "FOV:"
fovLbl.TextColor3           = Color3.fromRGB(150, 160, 180)
fovLbl.Font                 = Enum.Font.Gotham
fovLbl.TextSize             = 12
fovLbl.TextXAlignment       = Enum.TextXAlignment.Left
fovLbl.Parent               = fovRow

local fovVal = Instance.new("TextLabel")
fovVal.Size                 = UDim2.new(0, 40, 1, 0)
fovVal.Position             = UDim2.new(1, -46, 0, 0)
fovVal.BackgroundTransparency = 1
fovVal.Text                 = tostring(CFG.camFOV) .. "°"
fovVal.TextColor3           = Color3.fromRGB(180, 210, 255)
fovVal.Font                 = Enum.Font.GothamBold
fovVal.TextSize             = 12
fovVal.TextXAlignment       = Enum.TextXAlignment.Right
fovVal.Parent               = fovRow

local fovSliderBg = Instance.new("Frame")
fovSliderBg.Size             = UDim2.new(0, 110, 0, 6)
fovSliderBg.Position         = UDim2.new(0, 80, 0.5, -3)
fovSliderBg.BackgroundColor3 = Color3.fromRGB(35, 42, 58)
fovSliderBg.BorderSizePixel  = 0
fovSliderBg.Parent           = fovRow
Instance.new("UICorner", fovSliderBg).CornerRadius = UDim.new(1, 0)

local fovSliderFill = Instance.new("Frame")
fovSliderFill.Size             = UDim2.new(0.5, 0, 1, 0)
fovSliderFill.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
fovSliderFill.BorderSizePixel  = 0
fovSliderFill.Parent           = fovSliderBg
Instance.new("UICorner", fovSliderFill).CornerRadius = UDim.new(1, 0)

local fovHandle = Instance.new("Frame")
fovHandle.Size             = UDim2.new(0, 14, 0, 14)
fovHandle.AnchorPoint      = Vector2.new(0.5, 0.5)
fovHandle.Position         = UDim2.new(0.5, 0, 0.5, 0)
fovHandle.BackgroundColor3 = Color3.fromRGB(200, 225, 255)
fovHandle.BorderSizePixel  = 0
fovHandle.Parent           = fovSliderBg
Instance.new("UICorner", fovHandle).CornerRadius = UDim.new(1, 0)

local fovMin, fovMax = 30, 120

-- vpCamera объявляем до updateFOVSlider чтобы не было nil-ошибки
local vpCamera  -- будет назначен ниже после создания viewport

local function updateFOVSlider(t)
    t = math.clamp(t, 0, 1)
    CFG.camFOV = math.floor(lerp(fovMin, fovMax, t))
    fovVal.Text = tostring(CFG.camFOV) .. "°"
    fovSliderFill.Size = UDim2.new(t, 0, 1, 0)
    fovHandle.Position = UDim2.new(t, 0, 0.5, 0)
    if CAM.active and vpCamera then
        vpCamera.FieldOfView = CFG.camFOV
    end
end

-- ── FOV слайдер через UserInputService (совместимо с Delta) ───────
local fovDragging = false

fovSliderBg.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        fovDragging = true
        -- Сразу применяем позицию клика
        local abs = fovSliderBg.AbsolutePosition
        local sz  = fovSliderBg.AbsoluteSize
        if sz.X > 0 then
            updateFOVSlider((inp.Position.X - abs.X) / sz.X)
        end
    end
end)

fovSliderBg.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        fovDragging = false
    end
end)

-- Движение мыши глобально — работает даже если курсор вышел за пределы слайдера
UserInputService.InputChanged:Connect(function(inp)
    if fovDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local abs = fovSliderBg.AbsolutePosition
        local sz  = fovSliderBg.AbsoluteSize
        if sz.X > 0 then
            updateFOVSlider((inp.Position.X - abs.X) / sz.X)
        end
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        fovDragging = false
    end
end)

updateFOVSlider(0.5)

-- ── Инфо-панель камеры ────────────────────────────────────────────
local camInfoCard = Instance.new("Frame")
camInfoCard.Size             = UDim2.new(1, 0, 0, 36)
camInfoCard.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
camInfoCard.BorderSizePixel  = 0
camInfoCard.Parent           = content
Instance.new("UICorner", camInfoCard).CornerRadius = UDim.new(0, 10)

local camYawLbl = Instance.new("TextLabel")
camYawLbl.Size                 = UDim2.new(0.5, 0, 1, 0)
camYawLbl.BackgroundTransparency = 1
camYawLbl.Text                 = "Yaw: 0.0°"
camYawLbl.TextColor3           = Color3.fromRGB(255, 200, 100)
camYawLbl.Font                 = Enum.Font.Gotham
camYawLbl.TextSize             = 11
camYawLbl.Parent               = camInfoCard

local camPitchLbl = Instance.new("TextLabel")
camPitchLbl.Size                 = UDim2.new(0.5, 0, 1, 0)
camPitchLbl.Position             = UDim2.new(0.5, 0, 0, 0)
camPitchLbl.BackgroundTransparency = 1
camPitchLbl.Text                 = "Pitch: 0.0°"
camPitchLbl.TextColor3           = Color3.fromRGB(255, 200, 100)
camPitchLbl.Font                 = Enum.Font.Gotham
camPitchLbl.TextSize             = 11
camPitchLbl.Parent               = camInfoCard

local hintLabel = Instance.new("TextLabel")
hintLabel.Size                 = UDim2.new(1, 0, 0, 18)
hintLabel.BackgroundTransparency = 1
hintLabel.Text                 = "F1 = скрыть меню  •  ПКМ = вращать камеру"
hintLabel.TextColor3           = Color3.fromRGB(80, 90, 110)
hintLabel.Font                 = Enum.Font.Gotham
hintLabel.TextSize             = 10
hintLabel.Parent               = content

-- ════════════════════════════════════════════════════════════════════
--  ОКНО КАМЕРЫ
-- ════════════════════════════════════════════════════════════════════
local camWindow = Instance.new("Frame")
camWindow.Name                   = "CameraWindow"
camWindow.Size                   = UDim2.new(0, 340, 0, 240)
camWindow.Position               = UDim2.new(0.5, -170, 0, 20)
camWindow.BackgroundColor3       = Color3.fromRGB(8, 10, 16)
camWindow.BackgroundTransparency = 0.05
camWindow.BorderSizePixel        = 0
camWindow.Active                 = true
camWindow.Visible                = false
camWindow.Parent                 = screenGui
Instance.new("UICorner", camWindow).CornerRadius = UDim.new(0, 12)

local camStroke = Instance.new("UIStroke")
camStroke.Color     = Color3.fromRGB(255, 160, 60)
camStroke.Thickness = 1.5
camStroke.Parent    = camWindow

local camHeader = Instance.new("Frame")
camHeader.Size             = UDim2.new(1, 0, 0, 36)
camHeader.BackgroundColor3 = Color3.fromRGB(40, 24, 10)
camHeader.BorderSizePixel  = 0
camHeader.Parent           = camWindow
Instance.new("UICorner", camHeader).CornerRadius = UDim.new(0, 12)

local camHeaderFix = Instance.new("Frame")
camHeaderFix.Size             = UDim2.new(1, 0, 0, 12)
camHeaderFix.Position         = UDim2.new(0, 0, 1, -12)
camHeaderFix.BackgroundColor3 = Color3.fromRGB(40, 24, 10)
camHeaderFix.BorderSizePixel  = 0
camHeaderFix.Parent           = camHeader

local camTitle = Instance.new("TextLabel")
camTitle.Size                 = UDim2.new(1, -50, 1, 0)
camTitle.Position             = UDim2.new(0, 12, 0, 0)
camTitle.BackgroundTransparency = 1
camTitle.Text                 = "📷  Просмотр камеры"
camTitle.TextColor3           = Color3.fromRGB(255, 200, 120)
camTitle.Font                 = Enum.Font.GothamBold
camTitle.TextSize             = 13
camTitle.TextXAlignment       = Enum.TextXAlignment.Left
camTitle.Parent               = camHeader

local camCloseBtn = Instance.new("TextButton")
camCloseBtn.Size             = UDim2.new(0, 28, 0, 28)
camCloseBtn.Position         = UDim2.new(1, -34, 0, 4)
camCloseBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 30)
camCloseBtn.BorderSizePixel  = 0
camCloseBtn.Text             = "✕"
camCloseBtn.TextColor3       = Color3.fromRGB(255, 200, 200)
camCloseBtn.Font             = Enum.Font.GothamBold
camCloseBtn.TextSize         = 13
camCloseBtn.Parent           = camHeader
Instance.new("UICorner", camCloseBtn).CornerRadius = UDim.new(0, 7)

-- Drag на окно камеры
makeDraggable(camWindow, camHeader)

-- ViewportFrame
local viewport = Instance.new("ViewportFrame")
viewport.Size             = UDim2.new(1, -16, 1, -52)
viewport.Position         = UDim2.new(0, 8, 0, 42)
viewport.BackgroundColor3 = Color3.fromRGB(5, 7, 12)
viewport.BorderSizePixel  = 0
viewport.LightColor       = Color3.fromRGB(255, 240, 220)
viewport.LightDirection   = Vector3.new(-1, -2, -1)
viewport.Parent           = camWindow
Instance.new("UICorner", viewport).CornerRadius = UDim.new(0, 8)

-- Назначаем vpCamera (теперь после объявления переменной выше)
vpCamera = Instance.new("Camera")
vpCamera.FieldOfView   = CFG.camFOV
vpCamera.Parent        = viewport
viewport.CurrentCamera = vpCamera

local vpInfo = Instance.new("TextLabel")
vpInfo.Size                 = UDim2.new(1, -10, 0, 20)
vpInfo.Position             = UDim2.new(0, 5, 1, -24)
vpInfo.BackgroundColor3     = Color3.fromRGB(0, 0, 0)
vpInfo.BackgroundTransparency = 0.5
vpInfo.Text                 = "ПКМ — вращать  •  Scroll — зум"
vpInfo.TextColor3           = Color3.fromRGB(200, 200, 200)
vpInfo.Font                 = Enum.Font.Gotham
vpInfo.TextSize             = 9
vpInfo.ZIndex               = 5
vpInfo.Parent               = viewport
Instance.new("UICorner", vpInfo).CornerRadius = UDim.new(0, 4)

-- ════════════════════════════════════════════════════════════════════
--  ЛОГИКА КАМЕРЫ
-- ════════════════════════════════════════════════════════════════════
local function getCamTarget()
    local ok, result = pcall(function()
        local boat = workspace:FindFirstChild("BoatModel")
            or workspace:FindFirstChild(player.Name .. "_Boat")
        if boat then
            return boat:FindFirstChildWhichIsA("BasePart")
        end
        if character then
            return character:FindFirstChild("HumanoidRootPart")
        end
        return nil
    end)
    return ok and result or nil
end

local clonedParts = {}

local function clearViewport()
    for _, p in ipairs(clonedParts) do
        pcall(function()
            if p and p.Parent then p:Destroy() end
        end)
    end
    clonedParts = {}
end

local function populateViewport()
    clearViewport()
    local target = getCamTarget()
    if not target then return end
    pcall(function()
        local source = target.Parent
        if source then
            local clone = source:Clone()
            clone.Parent = viewport
            table.insert(clonedParts, clone)
        end
    end)
end

local function updateVPCamera()
    local target = getCamTarget()
    if not target then return end
    pcall(function()
        local targetPos = target.Position
        local yawRad   = math.rad(CAM.yaw)
        local pitchRad = math.rad(math.clamp(CAM.pitch, -80, 80))
        local offset = Vector3.new(
            CAM.distance * math.cos(pitchRad) * math.sin(yawRad),
            CAM.distance * math.sin(pitchRad),
            CAM.distance * math.cos(pitchRad) * math.cos(yawRad)
        )
        vpCamera.CFrame      = CFrame.lookAt(targetPos + offset, targetPos)
        vpCamera.FieldOfView = CFG.camFOV
    end)
end

local function setCameraMode(active)
    CAM.active        = active
    camWindow.Visible = active
    camBtn.BackgroundColor3 = active
        and Color3.fromRGB(20, 80, 30)
        or  Color3.fromRGB(25, 60, 100)
    camBtn.TextColor3 = active
        and Color3.fromRGB(100, 255, 140)
        or  Color3.fromRGB(120, 190, 255)
    camBtn.Text = active
        and "📷   Выключить камеру"
        or  "📷   Включить просмотр камеры"

    if active then
        populateViewport()
    else
        clearViewport()
    end
end

-- Вращение вьюпорт-камеры мышью (ПКМ)
local vpDragging  = false
local vpLastMouse = Vector2.new(0, 0)

viewport.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        vpDragging  = true
        vpLastMouse = Vector2.new(inp.Position.X, inp.Position.Y)
    end
end)

viewport.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        vpDragging = false
    end
end)

viewport.InputChanged:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseMovement and vpDragging then
        local dx = inp.Position.X - vpLastMouse.X
        local dy = inp.Position.Y - vpLastMouse.Y
        vpLastMouse    = Vector2.new(inp.Position.X, inp.Position.Y)
        CAM.yaw        = CAM.yaw   + dx * CFG.camSensX
        CAM.pitch      = math.clamp(CAM.pitch - dy * CFG.camSensY, -80, 80)
    end
    if inp.UserInputType == Enum.UserInputType.MouseWheel then
        CAM.distance = math.clamp(CAM.distance - inp.Position.Z * 2, 5, 80)
    end
end)

-- ════════════════════════════════════════════════════════════════════
--  КНОПКИ GUI
-- ════════════════════════════════════════════════════════════════════
local menuVisible = true

local function toggleMenu()
    menuVisible     = not menuVisible
    content.Visible = menuVisible
    mainFrame.Size  = menuVisible
        and UDim2.new(0, 300, 0, 420)
        or  UDim2.new(0, 300, 0, 44)
    hideBtn.Text    = menuVisible and "—" or "+"
end

hideBtn.MouseButton1Click:Connect(toggleMenu)
camBtn.MouseButton1Click:Connect(function() setCameraMode(not CAM.active) end)
camCloseBtn.MouseButton1Click:Connect(function() setCameraMode(false) end)

-- ════════════════════════════════════════════════════════════════════
--  ВВОД ДЛЯ СЕРВОПРИВОДОВ
-- ════════════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.F1 then
        toggleMenu()
        return
    end
    for _, s in ipairs(CFG.servos) do
        if inp.KeyCode == s.key then
            held[s.id] = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(inp, gp)
    if gp then return end
    for _, s in ipairs(CFG.servos) do
        if inp.KeyCode == s.key then
            held[s.id] = false
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════
--  ГЛАВНЫЙ ЦИКЛ
-- ════════════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        local mousePos = Vector2.new(mouse.X, mouse.Y)
        local commands = {}

        -- Сервоприводы
        for _, s in ipairs(CFG.servos) do
            local zone          = CFG.zones[s.id]
            local norm, inZone  = screenToNorm(mousePos, zone)

            if held[s.id] and inZone then
                rawNorm[s.id] = norm
            elseif not held[s.id] then
                rawNorm[s.id] = Vector2.new(0, 0)
            end

            smooth[s.id]  = smoothV2(smooth[s.id], rawNorm[s.id], CFG.smoothSpeed, dt)
            angles[s.id]  = normToAngle(smooth[s.id], s.axis)

            table.insert(commands, { id = s.id, angle = angles[s.id] })

            -- Обновление карточки GUI
            local card = servoCards[s.id]
            if card then
                local a = angles[s.id]
                card.angleVal.Text = string.format("%+.1f°", a)

                local t = a / CFG.maxAngle
                if t >= 0 then
                    card.barFill.Position = UDim2.new(0.5, 0, 0, 0)
                    card.barFill.Size     = UDim2.new(t * 0.5, 0, 1, 0)
                else
                    card.barFill.Position = UDim2.new(0.5 + t * 0.5, 0, 0, 0)
                    card.barFill.Size     = UDim2.new(-t * 0.5, 0, 1, 0)
                end
                card.barFill.BackgroundColor3 = math.abs(a) > 5
                    and card.color
                    or  Color3.fromRGB(50, 60, 80)
                card.dot.BackgroundColor3 = held[s.id]
                    and card.color
                    or  Color3.fromRGB(50, 55, 70)
            end
        end

        -- Отправка на сервер
        sendTimer = sendTimer + dt
        if sendTimer >= CFG.sendRate then
            sendTimer = 0
            sendCommands(commands)
        end

        -- Камера
        if CAM.active then
            if not vpDragging then
                CAM.yaw = CAM.yaw + 6 * dt
            end
            updateVPCamera()
            camYawLbl.Text   = string.format("  Yaw:  %+.1f°", CAM.yaw % 360)
            camPitchLbl.Text = string.format("Pitch: %+.1f°", CAM.pitch)
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════════
--  Уведомление о запуске
-- ════════════════════════════════════════════════════════════════════
local notify = Instance.new("Frame")
notify.Size             = UDim2.new(0, 260, 0, 48)
notify.Position         = UDim2.new(0.5, -130, 0, -60)
notify.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
notify.BorderSizePixel  = 0
notify.ZIndex           = 10
notify.Parent           = screenGui
Instance.new("UICorner", notify).CornerRadius = UDim.new(0, 10)

local notifyStroke = Instance.new("UIStroke")
notifyStroke.Color     = Color3.fromRGB(80, 220, 120)
notifyStroke.Thickness = 1
notifyStroke.Parent    = notify

local notifyLbl = Instance.new("TextLabel")
notifyLbl.Size                 = UDim2.new(1, 0, 1, 0)
notifyLbl.BackgroundTransparency = 1
notifyLbl.Text                 = "✅  Servo Hand Control запущен!"
notifyLbl.TextColor3           = Color3.fromRGB(120, 255, 160)
notifyLbl.Font                 = Enum.Font.GothamBold
notifyLbl.TextSize             = 13
notifyLbl.ZIndex               = 11
notifyLbl.Parent               = notify

local tweenIn = TweenService:Create(notify,
    TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Position = UDim2.new(0.5, -130, 0, 20) }
)
tweenIn:Play()
tweenIn.Completed:Connect(function()
    task.wait(2.5)
    local tweenOut = TweenService:Create(notify,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Position = UDim2.new(0.5, -130, 0, -60) }
    )
    tweenOut:Play()
    tweenOut.Completed:Connect(function() notify:Destroy() end)
end)

print("[ServoHandControl] Скрипт успешно запущен в Delta Executor!")
print("Управление: Q = Servo_1 (горизонталь)  |  E = Servo_2 (вертикаль)")
print("F1 = скрыть/показать меню  |  Кнопка Camera = режим камеры")
