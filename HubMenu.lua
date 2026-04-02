-- [[ INGOE HUB V1.2 - KEY SYSTEM EDITION ]] --
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- --- CONFIG & STATE ---
local HubName = "Ingoe Hub"
local FileName = "IngoeSettings.json"
local CorrectKey = "Key" -- Change this to your desired key

local settings = {
    ToggleKey = "LeftControl",
    Speed = 16,
    InfJump = false,
    SavedKey = ""
}

local aimbotEnabled = false
local teamCheckEnabled = false
local wallCheckEnabled = false
local listeningForKey = false

-- --- UTILITY FUNCTIONS ---
local function saveSettings()
    local success, json = pcall(function() return HttpService:JSONEncode(settings) end)
    if success then writefile(FileName, json) end
end

local function loadSettings()
    if isfile(FileName) then
        local json = readfile(FileName)
        local decoded = HttpService:JSONDecode(json)
        for k, v in pairs(decoded) do settings[k] = v end
    end
end

loadSettings()

-- --- UI SETUP ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Ingoe_Internal"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- MAIN HUB FRAME (Starts Invisible)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 520)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Visible = false
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- KEY SYSTEM FRAME
local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 300, 0, 180)
keyFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
keyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
keyFrame.BorderSizePixel = 0
keyFrame.Parent = screenGui

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 8)
keyCorner.Parent = keyFrame

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 40)
keyTitle.Text = "INGOE KEY SYSTEM"
keyTitle.TextColor3 = Color3.new(1, 1, 1)
keyTitle.BackgroundTransparency = 1
keyTitle.Parent = keyFrame

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0.8, 0, 0, 40)
keyBox.Position = UDim2.new(0.1, 0, 0.3, 0)
keyBox.PlaceholderText = "Enter Key... ;)"
keyBox.Text = ""
keyBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
keyBox.TextColor3 = Color3.new(1, 1, 1)
keyBox.Parent = keyFrame

local enterBtn = Instance.new("TextButton")
enterBtn.Size = UDim2.new(0.8, 0, 0, 40)
enterBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
enterBtn.Text = "CHECK KEY"
enterBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
enterBtn.TextColor3 = Color3.new(1, 1, 1)
enterBtn.Parent = keyFrame

-- --- KEY LOGIC ---
local function unlockHub()
    keyFrame.Visible = false
    mainFrame.Visible = true
    print("Ingoe Hub: Access Granted")
end

enterBtn.MouseButton1Click:Connect(function()
    if keyBox.Text == CorrectKey then
        settings.SavedKey = keyBox.Text
        saveSettings()
        unlockHub()
    else
        enterBtn.Text = "INVALID KEY"
        enterBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
        task.wait(1)
        enterBtn.Text = "CHECK KEY"
        enterBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    end
end)

keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        if keyBox.Text == CorrectKey then
            settings.SavedKey = keyBox.Text
            saveSettings()
            unlockHub()
        else
            enterBtn.Text = "INVALID KEY"
            enterBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
            task.wait(1)
            enterBtn.Text = "CHECK KEY"
            enterBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
        end
    end
end)

-- Auto-check saved key
if settings.SavedKey == CorrectKey then
    unlockHub()
end

-- [The rest of your Hub UI Elements & Aimbot Logic continues below...]
-- (Paste your existing createButton, speedBtn, getClosestPlayer, etc. here)