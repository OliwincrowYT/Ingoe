local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. Create the UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyMenu"
screenGui.ResetOnSpawn = false -- Keeps the menu if you die
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Dark sleek UI
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true -- Starts visible
mainFrame.Parent = screenGui

-- 2. Add a title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Hub Menu [L-CTRL]"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.TextSize = 20
title.Parent = mainFrame

-- 3. The Toggle Logic
local toggleKey = Enum.KeyCode.LeftControl -- Change this to any key (e.g., Enum.KeyCode.RightShift)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- gameProcessed is true if the player is typing in chat
    if gameProcessed then return end

    if input.KeyCode == toggleKey then
        mainFrame.Visible = not mainFrame.Visible
        print("Menu Toggled: " .. tostring(mainFrame.Visible))
    end
end)