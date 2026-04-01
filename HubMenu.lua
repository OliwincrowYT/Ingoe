local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer

-- --- CONFIG & STATE ---
local HubName = "Ingoe Hub"
local FileName = "IngoeSettings.json"
local settings = {
    ToggleKey = "LeftControl",
    Speed = 16,
    InfJump = false
}

-- --- UTILITY FUNCTIONS ---
local function saveSettings()
    local json = HttpService:JSONEncode(settings)
    writefile(FileName, json)
end

local function loadSettings()
    if isfile(FileName) then
        local json = readfile(FileName)
        local decoded = HttpService:JSONDecode(json)
        for k, v in pairs(decoded) do
            settings[k] = v
        end
    end
end

-- Load settings immediately on execution
loadSettings()

-- --- UI SETUP ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Ingoe_Internal"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 420) -- Made taller for new buttons
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.Text = "  " .. HubName
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Parent = mainFrame

-- --- UI ELEMENTS ---
local function createButton(text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = mainFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

local speedBtn = createButton("Speed: " .. settings.Speed, UDim2.new(0.1, 0, 0.15, 0), Color3.fromRGB(50, 50, 70))
local jumpBtn = createButton("Inf Jump: " .. (settings.InfJump and "ON" or "OFF"), UDim2.new(0.1, 0, 0.3, 0), Color3.fromRGB(50, 70, 50))
local keybindBtn = createButton("Toggle Key: " .. settings.ToggleKey, UDim2.new(0.1, 0, 0.45, 0), Color3.fromRGB(70, 70, 50))
local dexBtn = createButton("Open Dex Explorer", Color3.fromRGB(80, 51, 120))
local saveBtn = createButton("SAVE PREFS", UDim2.new(0.1, 0, 0.65, 0), Color3.fromRGB(40, 40, 40))
local unloadBtn = createButton("UNLOAD", UDim2.new(0.1, 0, 0.85, 0), Color3.fromRGB(100, 40, 40))

-- --- LOGIC ---

-- 1. Speed
speedBtn.MouseButton1Click:Connect(function()
    settings.Speed = (settings.Speed == 16) and 100 or 16
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = settings.Speed end
    speedBtn.Text = "Speed: " .. settings.Speed
end)

-- 2. Infinite Jump
jumpBtn.MouseButton1Click:Connect(function()
    settings.InfJump = not settings.InfJump
    jumpBtn.Text = "Inf Jump: " .. (settings.InfJump and "ON" or "OFF")
end)

UserInputService.JumpRequest:Connect(function()
    if settings.InfJump and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

-- 3. Change Toggle Key
local listeningForKey = false
keybindBtn.MouseButton1Click:Connect(function()
    listeningForKey = true
    keybindBtn.Text = "..."
end)

dexBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://obj.wearedevs.net/2/scripts/Dex%20Explorer.lua"))()
end)

UserInputService.InputBegan:Connect(function(input)
    if listeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
        settings.ToggleKey = input.KeyCode.Name
        keybindBtn.Text = "Toggle Key: " .. settings.ToggleKey
        listeningForKey = false
    elseif not listeningForKey and input.KeyCode == Enum.KeyCode[settings.ToggleKey] then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- 4. Save Button
saveBtn.MouseButton1Click:Connect(function()
    saveSettings()
    saveBtn.Text = "SAVED!"
    task.wait(1)
    saveBtn.Text = "SAVE PREFS"
end)

-- 5. Unload
unloadBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Draggable Logic (Title Bar)
local dragging, dragStart, startPos
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)