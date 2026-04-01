local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. Main UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IngoeHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- 2. Title Bar (The handle for dragging)
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleBar.Text = "Ingoe Hub"
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

-- 3. Add a Sample Button
local testButton = Instance.new("TextButton")
testButton.Size = UDim2.new(0.8, 0, 0, 40)
testButton.Position = UDim2.new(0.1, 0, 0.2, 0)
testButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
testButton.Text = "Click Me"
testButton.TextColor3 = Color3.new(1, 1, 1)
testButton.Parent = mainFrame

testButton.MouseButton1Click:Connect(function()
    print("Button clicked by " .. player.Name)
    testButton.Text = "Success!"
    task.wait(1)
    testButton.Text = "Click Me"
end)

-- --- ADVANCED LOGIC ---

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Toggle Logic (L-CTRL)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.LeftControl then
        mainFrame.Visible = not mainFrame.Visible
    end
end)