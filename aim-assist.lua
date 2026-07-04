-- Advanced Aim Assist + Draggable GUI + FOV + Hotkey
local aimAssistEnabled = false
local aimStrength = 0.16
local smoothness = 0.4
local fov = 180
local targetPart = "Head"

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Hotkey (Change this if you want)
local HOTKEY = Enum.KeyCode.k   -- You can change to Enum.KeyCode.F or Enum.KeyCode.Insert etc.

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 160)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Aim Assist"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Status Label
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0, 35)
Status.BackgroundTransparency = 1
Status.Text = "Press Right Ctrl or click button"
Status.TextColor3 = Color3.fromRGB(180, 180, 180)
Status.TextSize = 12
Status.Font = Enum.Font.Gotham
Status.Parent = MainFrame

-- Toggle Button
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0.9, 0, 0, 45)
Toggle.Position = UDim2.new(0.05, 0, 0, 60)
Toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.TextScaled = true
Toggle.Font = Enum.Font.GothamSemibold
Toggle.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = Toggle

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 64
FOVCircle.Radius = fov
FOVCircle.Color = Color3.fromRGB(255, 100, 100)
FOVCircle.Transparency = 0.75
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Draggable
local dragging = false
local dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Update UI
local function updateUI()
    if aimAssistEnabled then
        Toggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        Toggle.Text = "ON"
        FOVCircle.Visible = true
    else
        Toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        Toggle.Text = "OFF"
        FOVCircle.Visible = false
    end
end

-- Toggle Function
local function toggleAimAssist()
    aimAssistEnabled = not aimAssistEnabled
    updateUI()
end

-- Button Click
Toggle.MouseButton1Click:Connect(toggleAimAssist)

-- Hotkey Support
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == HOTKEY then
        toggleAimAssist()
    end
end)

-- Get closest target
local function getClosestTarget()
    local closest = nil
    local shortest = fov
    
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local part = plr.Character:FindFirstChild(targetPart) or plr.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = part
                    end
                end
            end
        end
    end
    return closest
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
    
    if not aimAssistEnabled then return end
    
    local target = getClosestTarget()
    if target then
        local targetPos = camera:WorldToScreenPoint(target.Position)
        local currentPos = Vector2.new(mouse.X, mouse.Y)
        local direction = (Vector2.new(targetPos.X, targetPos.Y) - currentPos) * aimStrength
        
        mousemoverel(direction.X * smoothness, direction.Y * smoothness)
    end
end)

updateUI()
print("✅ Aim Assist fully loaded! Use k or the button to toggle.")