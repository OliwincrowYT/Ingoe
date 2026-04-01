local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService") -- Fixed: Removed the stray \
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

loadSettings()

-- --- UI SETUP ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Ingoe_Internal"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
-- Update Frame Size to fit new buttons
mainFrame.Size = UDim2.new(0, 300, 0, 500)

-- Add the new toggles to your UI ELEMENTS section

-- Move UNLOAD down to the very bottom

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

-- Fixed Spacing Logic
local speedBtn = createButton("Speed: " .. settings.Speed, UDim2.new(0.1, 0, 0.15, 0), Color3.fromRGB(50, 50, 70))
local jumpBtn = createButton("Inf Jump: " .. (settings.InfJump and "ON" or "OFF"), UDim2.new(0.1, 0, 0.28, 0), Color3.fromRGB(50, 70, 50))
local keybindBtn = createButton("Toggle Key: " .. settings.ToggleKey, UDim2.new(0.1, 0, 0.41, 0), Color3.fromRGB(70, 70, 50))
local saveBtn = createButton("SAVE PREFS", UDim2.new(0.1, 0, 0.54, 0), Color3.fromRGB(40, 40, 40)) -- Adjusted position
local dexBtn = createButton("Open Dex", UDim2.new(0.1, 0, 0.67, 0), Color3.fromRGB(50, 50, 50)) -- Adjusted position
local unloadBtn = createButton("UNLOAD", UDim2.new(0.1, 0, 0.93, 0), Color3.fromRGB(100, 40, 40))
local aimbotEnabled = false
local teamCheckEnabled = false

local aimBtn = createButton("Aimbot: OFF", UDim2.new(0.1, 0, 0.75, 0), Color3.fromRGB(80, 50, 50))
local teamBtn = createButton("Team Check: OFF", UDim2.new(0.1, 0, 0.85, 0), Color3.fromRGB(50, 50, 80))
-- --- LOGIC ---

speedBtn.MouseButton1Click:Connect(function()
    settings.Speed = (settings.Speed == 16) and 100 or 16
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = settings.Speed end
    speedBtn.Text = "Speed: " .. settings.Speed
end)

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

local listeningForKey = false
keybindBtn.MouseButton1Click:Connect(function()
    listeningForKey = true
    keybindBtn.Text = "..."
end)

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local function isVisible(targetPart)
    local char = player.Character
    if not char then return false end

    -- Parameters to ignore yourself and the target's own character
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char, targetPart.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude

    local direction = targetPart.Position - Camera.CFrame.Position
    local result = workspace:Raycast(Camera.CFrame.Position, direction, params)

    -- If result is nil, nothing was in the way
    return result == nil

-- Function to get the closest player
    local function getClosestPlayer()
        local closestPlayer = nil
        local shortestDistance = math.huge

        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
                local head = v.Character.Head
                local health = v.Character:FindFirstChildOfClass("Humanoid") and v.Character:FindFirstChildOfClass("Humanoid").Health or 0

                if health <= 0 then end

                -- 1. Team Check (Arsenal System)
                if teamCheckEnabled and v.Team == player.Team then
                    
                end

                -- 2. On-Screen Check
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    -- 3. Wall Check (Visibility)
                    if isVisible(head) then
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

-- The Heartbeat Loop (Runs every frame)
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character then
            -- Smoothly move camera toward target's head
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- Button Logic
aimBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimBtn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

teamBtn.MouseButton1Click:Connect(function()
    teamCheckEnabled = not teamCheckEnabled
    teamBtn.Text = "Team Check: " .. (teamCheckEnabled and "ON" or "OFF")
end)

dexBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() -- Using a more stable Dex link
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

saveBtn.MouseButton1Click:Connect(function()
    saveSettings()
    saveBtn.Text = "SAVED!"
    task.wait(1)
    saveBtn.Text = "SAVE PREFS"
end)

unloadBtn.MouseButton1Click:Connect(function()
    -- 1. Reset player speed to normal
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = 16 end

    -- 2. Stop the Inf Jump listener (optional but cleaner)
    settings.InfJump = false

    -- 3. Boom, gone.
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
end) end