local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create the UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FadeGui"
screenGui.Parent = playerGui

local textLabel = Instance.new("TextLabel")
textLabel.Text = "Hello"
textLabel.Size = UDim2.new(0, 200, 0, 50)
textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.TextSize = 40
textLabel.Parent = screenGui

-- --- THE FADE LOGIC ---

-- 1. Setup the Tween settings (2 seconds long, smooth easing)
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear)

-- 2. Define what property we want to change (TextTransparency to 1)
local targetProperties = {TextTransparency = 1}

-- 3. Create and Play the animation
local fadeTween = TweenService:Create(textLabel, tweenInfo, targetProperties)

task.wait(2) -- Let the player read "Hello" for 2 seconds
fadeTween:Play() -- Start the fade

-- Optional: Cleanup once the fade is done
fadeTween.Completed:Connect(function()
    screenGui:Destroy()
end)