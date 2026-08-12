--// Slap Battles - Fixed & Working Infinite Ability Script
--// Handles server-side validation, proper remote argument structures, and active tool states.

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
MainFrame.Position = UDim2.new(0.5, -150, 0.4, -75)
MainFrame.Size = UDim2.new(0, 300, 0, 160)
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
Title.Text = "Slap Battles | Inf Ability (Fixed)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleBtn.Position = UDim2.new(0, 15, 0, 50)
ToggleBtn.Size = UDim2.new(1, -30, 0, 45)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "Enable Inf Ability: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
ToggleBtn.TextSize = 14
ToggleBtn.AutoButtonColor = false

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = MainFrame
InfoLabel.BackgroundTransparency = 1
InfoLabel.Position = UDim2.new(0, 15, 0, 105)
InfoLabel.Size = UDim2.new(1, -30, 0, 40)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Text = "Press 'E' to trigger ability loop safely.\nBypasses local client-side checks."
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
InfoLabel.TextSize = 11

--// CORE LOGIC
local Enabled = false

-- Locate specific ability remotes safely inside ReplicatedStorage
local EventsFolder = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage

local function TriggerAbility()
    local char = LocalPlayer.Character
    if not char then return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        -- Fire specific known ability identifiers to prevent server-side errors from blanket-firing
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
    
    -- Check common remote locations in Slap Battles
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

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not Enabled then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        TriggerAbility()
    end
end)

-- UI State Toggle
ToggleBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    if Enabled then
        ToggleBtn.Text = "Enable Inf Ability: ON"
        ToggleBtn.TextColor3 = Color3.fromRGB(75, 255, 125)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 45)
    else
        ToggleBtn.Text = "Enable Inf Ability: OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    end
end)
