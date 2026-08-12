--// Slap Battles - Inf Ability & Auto-Slap Farm
--// Fixed remotes, auto loop toggle, and safe automation.

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Cleanup existing UI
if CoreGui:FindFirstChild("SB_InfAbility_UI") then
    CoreGui.SB_InfAbility_UI:Destroy()
end

--// UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SB_InfAbility_UI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.4, -110)
MainFrame.Size = UDim2.new(0, 300, 0, 230)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Color = Color3.fromRGB(120, 40, 255)
UIStroke.Thickness = 2

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 10)
Title.Size = UDim2.new(1, -30, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "Slap Battles | Inf Ability & Farm"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

--// Toggle 1: Inf Ability
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleBtn.Position = UDim2.new(0, 15, 0, 45)
ToggleBtn.Size = UDim2.new(1, -30, 0, 40)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "Auto Ability (Spam): OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
ToggleBtn.TextSize = 13
ToggleBtn.AutoButtonColor = false

local BtnCorner1 = Instance.new("UICorner")
BtnCorner1.CornerRadius = UDim.new(0, 8)
BtnCorner1.Parent = ToggleBtn

--// Toggle 2: Auto Slap Farm
local FarmBtn = Instance.new("TextButton")
FarmBtn.Parent = MainFrame
FarmBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
FarmBtn.Position = UDim2.new(0, 15, 0, 95)
FarmBtn.Size = UDim2.new(1, -30, 0, 40)
FarmBtn.Font = Enum.Font.GothamBold
FarmBtn.Text = "Auto Slap Farm: OFF"
FarmBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
FarmBtn.TextSize = 13
FarmBtn.AutoButtonColor = false

local BtnCorner2 = Instance.new("UICorner")
BtnCorner2.CornerRadius = UDim.new(0, 8)
BtnCorner2.Parent = FarmBtn

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = MainFrame
InfoLabel.BackgroundTransparency = 1
InfoLabel.Position = UDim2.new(0, 15, 0, 145)
InfoLabel.Size = UDim2.new(1, -30, 0, 70)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Text = "• Auto Ability: Spams ability action events.\n• Auto Farm: Automatically targets nearest players to farm slaps safely."
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
InfoLabel.TextSize = 11

--// LOGIC
local AbilityEnabled = false
local FarmEnabled = false

local EventsFolder = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage

local function TriggerAbility()
    local char = LocalPlayer.Character
    if not char then return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        for _, v in pairs(tool:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local nameLower = string.lower(v.Name)
                if string.find(nameLower, "ability") or string.find(nameLower, "use") or string.find(nameLower, "skill") or string.find(nameLower, "action") then
                    pcall(function()
                        v:FireServer()
                    end)
                end
            end
        end
    end
    
    local commonRemotes = {"AbilityButton", "GeneralAbility", "RojoAbility", "Rhythm", "UseAbility"}
    for _, remoteName in ipairs(commonRemotes) do
        local remote = EventsFolder:FindFirstChild(remoteName, true)
        if remote and remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer()
            end)
        end
    end
end

-- Function to find slap remote and hit players
local function GetSlapRemote()
    return EventsFolder:FindFirstChild("slap", true) or ReplicatedStorage:FindFirstChild("Slap", true)
end

-- Main loops
RunService.Stepped:Connect(function()
    -- Auto Ability Loop
    if AbilityEnabled then
        TriggerAbility()
    end
    
    -- Auto Slap Farm Loop
    if FarmEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local myRoot = char.HumanoidRootPart
            local slapRemote = GetSlapRemote()
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = player.Character.HumanoidRootPart
                    local distance = (myRoot.Position - targetRoot.Position).Magnitude
                    
                    -- Check if player is close enough to slap
                    if distance < 15 then
                        if slapRemote and slapRemote:IsA("RemoteEvent") then
                            pcall(function()
                                slapRemote:FireServer(player.Character)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- UI Interactions
ToggleBtn.MouseButton1Click:Connect(function()
    AbilityEnabled = not AbilityEnabled
    if AbilityEnabled then
        ToggleBtn.Text = "Auto Ability (Spam): ON"
        ToggleBtn.TextColor3 = Color3.fromRGB(75, 255, 125)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 45)
    else
        ToggleBtn.Text = "Auto Ability (Spam): OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    end
end)

FarmBtn.MouseButton1Click:Connect(function()
    FarmEnabled = not FarmEnabled
    if FarmEnabled then
        FarmBtn.Text = "Auto Slap Farm: ON"
        FarmBtn.TextColor3 = Color3.fromRGB(75, 255, 125)
        FarmBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 45)
    else
        FarmBtn.Text = "Auto Slap Farm: OFF"
        FarmBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
        FarmBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    end
end)
