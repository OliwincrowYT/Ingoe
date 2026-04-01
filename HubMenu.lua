-- Define the Player and their UI container
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create the ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HelloGui"
screenGui.Parent = playerGui

-- Create the TextLabel
local textLabel = Instance.new("TextLabel")
textLabel.Name = "GreetingLabel"
textLabel.Text = "Hello"
textLabel.Size = UDim2.new(0, 200, 0, 50) -- Width: 200px, Height: 50px
textLabel.TextColor3 = Color3.new(1, 1, 1) -- White text
textLabel.BackgroundTransparency = 1 -- Transparent background
textLabel.Font = Enum.Font.SourceSansBold
textLabel.TextSize = 40

-- Center the label
-- AnchorPoint (0.5, 0.5) puts the "handle" in the middle of the label
textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
-- Position (0.5, 0, 0.5, 0) puts that handle in the middle of the screen
textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)

textLabel.Parent = screenGui