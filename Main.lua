getgenv().FOV = 100
getgenv().Enabled = false

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local localPlayer = players.LocalPlayer
local currentCamera = workspace.CurrentCamera

-- Admin / Owner list
local Admins = {
    ["slbattlesgodd"] = true,
}

local function isAdmin(plr)
    return Admins[plr.Name] or Admins[plr.UserId]
end

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Position = currentCamera.ViewportSize * 0.5
fovCircle.Visible = true
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Radius = getgenv().FOV
fovCircle.Transparency = 1
fovCircle.Filled = false
fovCircle.NumSides = 100

runService.RenderStepped:Connect(function()
    fovCircle.Position = currentCamera.ViewportSize * 0.5
    fovCircle.Radius = getgenv().FOV
    fovCircle.Visible = getgenv().Enabled
end)

-- GUI
local frameHeight = 150

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "SilentAim_ESP_UI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 180, 0, frameHeight)
Frame.Position = UDim2.new(0.8, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 1

local FadeIn = tweenService:Create(Frame, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
FadeIn:Play()

local FrameCorner = Instance.new("UICorner", Frame)
FrameCorner.CornerRadius = UDim.new(0, 12)

-- Silent Aim Toggle
local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(1, -20, 0, 36)
Toggle.Position = UDim2.new(0, 10, 0, 8)
Toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 16
Toggle.Text = "SilentAim: "..tostring(getgenv().Enabled)

local ToggleCorner = Instance.new("UICorner", Toggle)
ToggleCorner.CornerRadius = UDim.new(0, 8)

Toggle.MouseButton1Click:Connect(function()
    getgenv().Enabled = not getgenv().Enabled
    Toggle.Text = "SilentAim: "..tostring(getgenv().Enabled)
end)

-- FOV TextBox
local TextBox = Instance.new("TextBox", Frame)
TextBox.Size = UDim2.new(1, -20, 0, 36)
TextBox.Position = UDim2.new(0, 10, 0, 52)
TextBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TextBox.TextColor3 = Color3.new(1,1,1)
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 16
TextBox.PlaceholderText = "100"
TextBox.Text = ""
TextBox.ClearTextOnFocus = true

local BoxCorner = Instance.new("UICorner", TextBox)
BoxCorner.CornerRadius = UDim.new(0, 8)

TextBox.Focused:Connect(function()
    TextBox.Text = ""
end)

TextBox.FocusLost:Connect(function()
    local newFOV = tonumber(TextBox.Text)
    if newFOV and newFOV > 0 then
        getgenv().FOV = newFOV
        TextBox.PlaceholderText = tostring(getgenv().FOV)
    else
        TextBox.Text = ""
    end
end)

-- ESP Toggle
local espButton = Instance.new("TextButton", Frame)
espButton.Size = UDim2.new(1, -20, 0, 36)
espButton.Position = UDim2.new(0, 10, 0, 96)
espButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
espButton.TextColor3 = Color3.new(1,1,1)
espButton.Font = Enum.Font.GothamBold
espButton.TextSize = 16
espButton.Text = "ESP: false"

local espCorner = Instance.new("UICorner", espButton)
espCorner.CornerRadius = UDim.new(0, 8)

-- Keybinds
local KeybindsLabel = Instance.new("TextLabel", Frame)
KeybindsLabel.Size = UDim2.new(1, -10, 0, 18)
KeybindsLabel.Position = UDim2.new(0, 5, 1, -22)
KeybindsLabel.BackgroundTransparency = 1
KeybindsLabel.Text = "Q – SilentAim | E – ESP"
KeybindsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
KeybindsLabel.Font = Enum.Font.Gotham
KeybindsLabel.TextSize = 12
KeybindsLabel.TextXAlignment = Enum.TextXAlignment.Right

-- ESP System
local espEnabled = false
local espObjects = {}
local espRenderConn = nil

local function applyESP(character, plr)
    if not espEnabled then return end
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    if espObjects[character] then return end

    local isOwner = plr.Name == "borec_1211"
    local teamColor = (plr.Team and plr.TeamColor.Color) or Color3.fromRGB(255, 255, 255)

    local highlight
    if not isOwner then
        highlight = Instance.new("Highlight")
        highlight.Parent = character
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = 0
        highlight.OutlineColor = teamColor
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Parent = character
    billboard.Adornee = character:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextColor3 = teamColor
    textLabel.Text = plr.Name

    espObjects[character] = { highlight, billboard, textLabel }
end

local function clearAllESP()
    for char, data in pairs(espObjects) do
        for _, obj in pairs(data) do
            if obj and obj.Parent then pcall(function() obj:Destroy() end) end
        end
        espObjects[char] = nil
    end
end

local function refreshESP()
    clearAllESP()
    if not espEnabled then return end
    for _, plr in pairs(players:GetPlayers()) do
        if plr.Character then
            applyESP(plr.Character, plr)
            plr.CharacterAdded:Connect(function(newChar)
                task.wait(1)
                if espEnabled then
                    applyESP(newChar, plr)
                end
            end)
        end
    end
end

local function updateESP()
    if not espEnabled then return end
    if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    for _, plr in pairs(players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local char = plr.Character
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChild("Humanoid")
            local espData = espObjects[char]

            if rootPart and humanoid and espData then
                local distance = (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
                local teamName = plr.Team and plr.Team.Name or "No Team"
                local health = math.floor(humanoid.Health)
                local maxHealth = math.floor(humanoid.MaxHealth)
                local teamColor = (plr.Team and plr.TeamColor.Color) or Color3.fromRGB(255, 255, 255)

                espData[3].TextColor3 = teamColor
                espData[3].Text = string.format("%s | %.1fm | %d/%d HP | %s", teamName, distance, health, maxHealth, plr.Name)
            end
        end
    end
end

-- ESP enable/disable
local function enableESP()
    espEnabled = true
    espButton.Text = "ESP: true"
    refreshESP()
    if espRenderConn then espRenderConn:Disconnect() end
    espRenderConn = runService.RenderStepped:Connect(function()
        if espEnabled then updateESP() end
    end)
end

local function disableESP()
    espEnabled = false
    espButton.Text = "ESP: false"
    if espRenderConn then espRenderConn:Disconnect() espRenderConn = nil end
    clearAllESP()
end

espButton.MouseButton1Click:Connect(function()
    if espEnabled then disableESP() else enableESP() end
end)

userInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        getgenv().Enabled = not getgenv().Enabled
        Toggle.Text = "SilentAim: " .. tostring(getgenv().Enabled)
    elseif input.KeyCode == Enum.KeyCode.E then
        if espEnabled then disableESP() else enableESP() end
    end
end)

-- Silent Aim Hook (ignore admins)
local raycastModule = require(replicatedStorage.Events.Modules.RaycastModule)

local function getClosestPlayer()
    local closest, closestDistance = nil, math.huge

    for _, plr in pairs(players:GetPlayers()) do
        if plr == localPlayer or (plr.Team == localPlayer.Team and localPlayer.Team ~= nil) or isAdmin(plr) then
            continue
        end

        local character = plr.Character
        if not character then continue end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then continue end

        local screenPosition, onScreen = currentCamera:WorldToViewportPoint(rootPart.Position)
        if not onScreen then continue end

        local screenDistance = (Vector2.new(screenPosition.X, screenPosition.Y) - currentCamera.ViewportSize * 0.5).Magnitude

        if screenPosition.Z > 0 and screenDistance < getgenv().FOV and screenDistance < closestDistance then
            closest = character
            closestDistance = screenDistance
        end
    end

    return closest
end

for i, func in pairs(raycastModule) do
    if type(func) == "function" then
        raycastModule[i] = function(...)
            if not getgenv().Enabled then return func(...) end

            local closestPlayer = getClosestPlayer()
            if not closestPlayer then return func(...) end

            return closestPlayer.Head, closestPlayer.Head.Position, Vector3.zero
        end
    end
end

-- Auto-refresh ESP on join/leave
players.PlayerAdded:Connect(function()
    task.wait(1)
    refreshESP()
end)

players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    refreshESP()
end)
