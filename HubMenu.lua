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
-- --- THE CREATOR ENGINE ---
local function create(type, text, color, order, callback)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.LayoutOrder = order
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    -- internal state for toggles
    local enabled = false

    btn.MouseButton1Click:Connect(function()
        if type == "toggle" then
            enabled = not enabled
            btn.Text = text:gsub(":.*", "") .. ": " .. (enabled and "ON" or "OFF")
            -- Visual feedback: glows brighter when ON
            btn.BackgroundTransparency = enabled and 0 or 0.2
            if callback then callback(enabled) end

        elseif type == "int" then
            -- This logic assumes you're cycling values (like 16 -> 100)
            if callback then callback() end
            -- Update text after callback finishes
            btn.Text = text:gsub(":.*", "") .. ": " .. settings.Speed

        elseif type == "button" then
            if callback then callback() end
        end
    end)

    return btn
end

-- --- YOUR CLEAN UI DEFINITION ---
-- Note: 'text' here is the base name. The engine handles the ": ON/OFF" part.

local speedBtn = create("int", "Speed: " .. settings.Speed, Color3.fromRGB(40, 40, 60), 1, function()
    settings.Speed = (settings.Speed == 16) and 100 or 16
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = settings.Speed
    end
end)

local aimBtn = create("toggle", "Aimbot: OFF", Color3.fromRGB(60, 40, 40), 2, function(state)
    aimbotEnabled = state
end)

local wallBtn = create("toggle", "Wall Check: OFF", Color3.fromRGB(50, 50, 50), 3, function(state)
    wallCheckEnabled = state
end)

local teamBtn = create("toggle", "Team Check: OFF", Color3.fromRGB(40, 40, 70), 4, function(state)
    teamCheckEnabled = state
end)

local saveBtn = create("button", "SAVE", Color3.fromRGB(30, 60, 30), 5, function()
    saveSettings()
    print("Settings Saved to " .. FileName)
end)

local unloadBtn = create("button", "UNLOAD", Color3.fromRGB(80, 30, 30), 6, function()
    screenGui:Destroy()
end)
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