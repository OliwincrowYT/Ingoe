local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- --- CONFIG & STATE ---
local HubName = "Ingoe Hub"
local FileName = "IngoeSettings.json"
local CorrectKey = "Key"

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
        local json = pcall(function()
            local data = readfile(FileName)
            local decoded = HttpService:JSONDecode(data)
            for k, v in pairs(decoded) do settings[k] = v end
        end)
    end
end

loadSettings()

-- --- UI SETUP ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Ingoe_Internal"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- MAIN HUB FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 520)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Visible = false
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.Text = "  " .. HubName
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Parent = mainFrame

-- KEY SYSTEM FRAME
-- --- UI SETUP ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Ingoe_Internal"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 520)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Visible = false
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- 1. ADD THE LIST LAYOUT
local layout = Instance.new("UIListLayout")
layout.Parent = mainFrame
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8) -- THIS IS YOUR PADDING VALUE
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 2. ADD A PADDING OBJECT (So buttons don't touch the Title Bar)
local guiPadding = Instance.new("UIPadding")
guiPadding.Parent = mainFrame
guiPadding.PaddingTop = UDim.new(0, 50) -- Keeps buttons below the Title Bar
guiPadding.PaddingBottom = UDim.new(0, 10)

-- --- SIMPLIFIED BUTTON CREATOR ---
-- Now you only need the Text, the Color, and a LayoutOrder
local function createButton(text, color, order)
    local btn = Instance.new("TextButton")
    btn.Name = text -- Easier to find in Explorer
    btn.Size = UDim2.new(0.9, 0, 0, 35) -- 90% width of the frame
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.LayoutOrder = order or 0 -- Determines the vertical position
    btn.Parent = mainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    return btn
end

-- --- BUTTONS (No more UDim2 needed!) ---
local speedBtn    = createButton("Speed: " .. settings.Speed, Color3.fromRGB(50, 50, 70), 1)
local jumpBtn     = createButton("Inf Jump: OFF", Color3.fromRGB(50, 70, 50), 2)
local keybindBtn  = createButton("Toggle Key: " .. settings.ToggleKey, Color3.fromRGB(70, 70, 50), 3)
local aimBtn      = createButton("Aimbot: OFF", Color3.fromRGB(80, 50, 50), 4)
local teamBtn     = createButton("Team Check: OFF", Color3.fromRGB(50, 50, 80), 5)
local wallBtn     = createButton("Wall Check: OFF", Color3.fromRGB(60, 60, 60), 6)
local dexBtn      = createButton("Open Dex", Color3.fromRGB(50, 50, 50), 7)
local saveBtn     = createButton("SAVE PREFS", Color3.fromRGB(40, 40, 40), 8)
local unloadBtn   = createButton("UNLOAD", Color3.fromRGB(100, 40, 40), 9)

-- Create the Buttons inside the mainFrame
local speedBtn = createButton("Speed: " .. settings.Speed, UDim2.new(0.1, 0, 0.12, 0), Color3.fromRGB(50, 50, 70))
local jumpBtn = createButton("Inf Jump: " .. (settings.InfJump and "ON" or "OFF"), UDim2.new(0.1, 0, 0.21, 0), Color3.fromRGB(50, 70, 50))
local keybindBtn = createButton("Toggle Key: " .. settings.ToggleKey, UDim2.new(0.1, 0, 0.30, 0), Color3.fromRGB(70, 70, 50))
local aimBtn = createButton("Aimbot: OFF", UDim2.new(0.1, 0, 0.39, 0), Color3.fromRGB(80, 50, 50))
local teamBtn = createButton("Team Check: OFF", UDim2.new(0.1, 0, 0.48, 0), Color3.fromRGB(50, 50, 80))
local wallBtn = createButton("Wall Check: OFF", UDim2.new(0.1, 0, 0.57, 0), Color3.fromRGB(60, 60, 60))
local dexBtn = createButton("Open Dex", UDim2.new(0.1, 0, 0.66, 0), Color3.fromRGB(50, 50, 50))
local saveBtn = createButton("SAVE PREFS", UDim2.new(0.1, 0, 0.75, 0), Color3.fromRGB(40, 40, 40))
local unloadBtn = createButton("UNLOAD", UDim2.new(0.1, 0, 0.88, 0), Color3.fromRGB(100, 40, 40))

-- --- KEY LOGIC ---
local function unlockHub()
    keyFrame:Destroy() -- Removes key screen entirely
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

if settings.SavedKey == CorrectKey then unlockHub() end

-- --- AIMBOT & GAME LOGIC ---
local function isEnemy(targetPlayer)
    if not teamCheckEnabled then return true end
    return targetPlayer.TeamColor ~= player.TeamColor
end

local function isVisible(targetPart)
    if not wallCheckEnabled then return true end
    local char = player.Character
    if not char then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char, targetPart.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), params)
    return result == nil
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
            local head = v.Character.Head
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and isEnemy(v) then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and isVisible(head) then
                    local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    if distance < shortestDistance then
                        closestPlayer = v
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- --- BUTTON LOGIC ---
aimBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimBtn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

teamBtn.MouseButton1Click:Connect(function()
    teamCheckEnabled = not teamCheckEnabled
    teamBtn.Text = "Team Check: " .. (teamCheckEnabled and "ON" or "OFF")
end)

wallBtn.MouseButton1Click:Connect(function()
    wallCheckEnabled = not wallCheckEnabled
    wallBtn.Text = "Wall Check: " .. (wallCheckEnabled and "ON" or "OFF")
end)

speedBtn.MouseButton1Click:Connect(function()
    settings.Speed = (settings.Speed == 16) and 100 or 16
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = settings.Speed
    end
    speedBtn.Text = "Speed: " .. settings.Speed
end)

jumpBtn.MouseButton1Click:Connect(function()
    settings.InfJump = not settings.InfJump
    jumpBtn.Text = "Inf Jump: " .. (settings.InfJump and "ON" or "OFF")
end)

UserInputService.JumpRequest:Connect(function()
    if settings.InfJump and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

keybindBtn.MouseButton1Click:Connect(function()
    listeningForKey = true
    keybindBtn.Text = "..."
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

dexBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)

saveBtn.MouseButton1Click:Connect(function()
    saveSettings()
    saveBtn.Text = "SAVED!"
    task.wait(1)
    saveBtn.Text = "SAVE PREFS"
end)

unloadBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
    end
    screenGui:Destroy()
end)

-- Draggable Logic
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