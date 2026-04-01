local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local player = game.Players.LocalPlayer

-- --- CONFIG & STATE ---
local HubName = "Ingoe Hub"
local Version = "1.1.0"
local isUnloaded = false
local speedEnabled = false
local infJumpEnabled = false
local ToggleKey = Enum.KeyCode.LeftControl

-- Store connections here so we can disconnect them on Unload
local connections = {}

-- --- UI CONSTRUCTION ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Ingoe_Internal"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 350)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.Text = "  " .. HubName .. " v" .. Version
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Font = Enum.Font.SourceSansBold
titleBar.TextSize = 18
titleBar.Parent = mainFrame

-- --- BUTTON FACTORY ---
local function createButton(text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = mainFrame

    -- Round the corners slightly
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    return btn
end

local speedBtn = createButton("Speed: Normal", UDim2.new(0.1, 0, 0.2, 0), Color3.fromRGB(50, 50, 70))
local jumpBtn = createButton("Inf Jump: OFF", UDim2.new(0.1, 0, 0.4, 0), Color3.fromRGB(50, 70, 50))
local unloadBtn = createButton("UNLOAD HUB", UDim2.new(0.1, 0, 0.8, 0), Color3.fromRGB(100, 40, 40))

-- --- FEATURES ---

-- 1. Speed
speedBtn.MouseButton1Click:Connect(function()
    if isUnloaded then return end
    speedEnabled = not speedEnabled
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = speedEnabled and 100 or 16
    end
    speedBtn.Text = speedEnabled and "Speed: FAST" or "Speed: Normal"
end)

-- 2. Inf Jump
jumpBtn.MouseButton1Click:Connect(function()
    if isUnloaded then return end
    infJumpEnabled = not infJumpEnabled
    jumpBtn.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump: OFF"
end)

local jumpConn = UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)
table.insert(connections, jumpConn)

-- --- UNLOAD LOGIC ---
unloadBtn.MouseButton1Click:Connect(function()
    isUnloaded = true

    -- Reset Character
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = 16 end

    -- Disconnect all events
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end

    -- Destroy UI
    screenGui:Destroy()

    print("Hub Unloaded Successfully.")
    StarterGui:SetCore("SendNotification", {
        Title = HubName,
        Text = "Hub has been unloaded.",
        Duration = 3
    })
end)

-- --- DRAGGING & TOGGLE ---
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

local dragConn = UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
table.insert(connections, dragConn)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local toggleConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == ToggleKey then
        mainFrame.Visible = not mainFrame.Visible
    end
end)
table.insert(connections, toggleConn)

-- --- LOAD NOTIFICATION ---
StarterGui:SetCore("SendNotification", {
    Title = HubName,
    Text = "Ready! " + ToggleKey + " to Toggle.",
    Duration = 5
})