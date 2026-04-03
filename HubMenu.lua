local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- --- CONFIG ---
local HubName = "Ingoe Hub V1.4"
local FileName = "IngoeSettings.json"
local CorrectKey = "Key"

local settings = {
    ToggleKey = "LeftControl",
    Speed = 16,
    InfJump = false,
    SavedKey = ""
}

local aimbotEnabled, teamCheckEnabled, wallCheckEnabled = false, false, false

-- --- LOAD SETTINGS ---
if isfile(FileName) then
    pcall(function()
        settings = HttpService:JSONDecode(readfile(FileName))
    end)
end

-- --- UI SETUP ---
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

-- MAIN FRAME
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 240, 0, 380)
mainFrame.Position = UDim2.new(0.5, -120, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.Visible = false

-- THE AUTO-LAYOUT (Your Padding Fix)
local layout = Instance.new("UIListLayout", mainFrame)
layout.Padding = UDim.new(0, 7) -- The spacing between buttons
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder

Instance.new("UIPadding", mainFrame).PaddingTop = UDim.new(0, 45)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0,0,0,-45) -- Offset from the padding
title.Text = HubName
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.new(1, 1, 1)

-- --- BUTTON CREATOR ---
local function createButton(text, color, order)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    return btn
end

-- BUTTON LIST
local speedBtn  = createButton("Speed: " .. settings.Speed, Color3.fromRGB(40, 40, 60), 1)
local aimBtn    = createButton("Aimbot: OFF", Color3.fromRGB(60, 40, 40), 2)
local wallBtn   = createButton("Wall Check: OFF", Color3.fromRGB(50, 50, 50), 3)
local saveBtn   = createButton("SAVE", Color3.fromRGB(30, 60, 30), 4)
local unloadBtn = createButton("UNLOAD", Color3.fromRGB(80, 30, 30), 5)

-- --- KEY SYSTEM ---
local keyFrame = Instance.new("Frame", screenGui)
keyFrame.Size = UDim2.new(0, 200, 0, 120)
keyFrame.Position = UDim2.new(0.5, -100, 0.5, -60)
keyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local keyBox = Instance.new("TextBox", keyFrame)
keyBox.Size = UDim2.new(0.8, 0, 0, 30)
keyBox.Position = UDim2.new(0.1, 0, 0.2, 0)
keyBox.PlaceholderText = "Key..."

local checkBtn = Instance.new("TextButton", keyFrame)
checkBtn.Size = UDim2.new(0.8, 0, 0, 30)
checkBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
checkBtn.Text = "Verify"

-- --- HANDLERS ---
local function unlock()
    keyFrame:Destroy()
    mainFrame.Visible = true
end

checkBtn.MouseButton1Click:Connect(function()
    if keyBox.Text == CorrectKey then
        settings.SavedKey = keyBox.Text
        writefile(FileName, HttpService:JSONEncode(settings))
        unlock()
    end
end)

if settings.SavedKey == CorrectKey then unlock() end

unloadBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Toggle Menu
UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode[settings.ToggleKey] then
        mainFrame.Visible = not mainFrame.Visible
    end
end)