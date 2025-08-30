-- LocalScript dans StarterPlayerScripts

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local menuOpen = true
local menuColor = Color3.fromHex("000000")
local borderColor = Color3.fromHex("FF26A3")

-- Créer ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "NovaSpaceMenu"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- Frame principale
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 500)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -250)
mainFrame.BackgroundColor3 = menuColor
mainFrame.BorderSizePixel = 0
mainFrame.Visible = menuOpen
mainFrame.Parent = gui

-- Coins arrondis
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

-- Contour
local outline = Instance.new("UIStroke")
outline.Thickness = 3
outline.Color = borderColor
outline.Parent = mainFrame

-- Titre
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "Nova Space"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 28
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = mainFrame

-- Frame onglets
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 40)
tabFrame.Position = UDim2.new(0, 0, 0, 50)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local tabs = {"Visual", "Aim", "Settings", "Credit"}
local tabButtons = {}
local contentFrames = {}
local spacing = (360 - (#tabs * 80)) / (#tabs + 1)

for i, tabName in pairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.Position = UDim2.new(0, spacing*i + 80*(i-1), 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = tabName
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = tabFrame
    tabButtons[tabName] = btn

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -100)
    content.Position = UDim2.new(0, 10, 0, 100)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = mainFrame
    contentFrames[tabName] = content
end

-- Compteur de toggles par onglet pour l'affichage vertical
local toggleCounts = {
    Visual = 0,
    Aim = 0,
    Settings = 0,
    Credit = 0
}

-- Fonction création toggle
local function createToggle(parent, text, callback, ignoreColor)
    local state = false
    -- Trouve le nom de l'onglet correspondant au parent
    local tabName = nil
    for name, frame in pairs(contentFrames) do
        if frame == parent then
            tabName = name
            break
        end
    end
    if tabName then
        toggleCounts[tabName] = toggleCounts[tabName] + 1
    end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, ((toggleCounts[tabName] or 1)-1)*45)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = text.." : Off"
    btn.Parent = parent
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." : "..(state and "On" or "Off")
        if not ignoreColor then
            btn.BackgroundColor3 = state and Color3.fromRGB(0,255,0) or Color3.fromRGB(40,40,40)
        end
        callback(state)
    end)
    return btn
end

-- ESP Toggle logic
local espActive = false
local espObjects = {}

local function ToggleESP(state)
    espActive = state
    if not espActive then
        -- Supprime tous les ESP existants
        for _, obj in pairs(espObjects) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        espObjects = {}
    end
end

-- Fonction ESP
local function UpdateESP()
    if not espActive then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") and not espObjects[part] then
                    local surface = Instance.new("SurfaceGui", part)
                    surface.AlwaysOnTop = true
                    surface.Name = "ESP"
                    local frame = Instance.new("Frame", surface)
                    frame.Size = UDim2.new(1,0,1,0)
                    frame.BackgroundColor3 = Color3.fromRGB(0,255,0)
                    frame.BorderSizePixel = 0
                    espObjects[part] = surface
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- Visual Toggles
createToggle(contentFrames["Visual"], "ESP 1", ToggleESP)

-- Aim Toggles
local aimToggles = {"Aimbot", "Aim Fov", "Aim Smooth", "Silent Aim"}
for _, name in pairs(aimToggles) do
    createToggle(contentFrames["Aim"], name, function(state)
        -- Code Aim
    end)
end

-- Settings Toggles
local function addSettingButton(text, callback, ignoreColor)
    createToggle(contentFrames["Settings"], text, callback, ignoreColor)
end

addSettingButton("White Countering", function(state)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    outline.Color = Color3.fromRGB(255,255,255)
end, true)

addSettingButton("Pink Countering", function(state)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    outline.Color = Color3.fromHex("FF26A3")
end, true)

-- Show FPS
local fpsGui = Instance.new("ScreenGui")
fpsGui.Name = "FPSGui"
fpsGui.ResetOnSpawn = false
fpsGui.Parent = PlayerGui
fpsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 100, 0, 30)
fpsLabel.Position = UDim2.new(1, -110, 0, 10)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(0,255,0)
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.TextSize = 18
fpsLabel.Text = "FPS: 0"
fpsLabel.Parent = fpsGui
fpsLabel.Visible = false

addSettingButton("Show FPS", function(state)
    fpsLabel.Visible = state
end)

local lastTime = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    if fpsLabel.Visible then
        frameCount = frameCount + 1
        local currentTime = tick()
        if currentTime - lastTime >= 1 then
            fpsLabel.Text = "FPS: "..frameCount
            frameCount = 0
            lastTime = currentTime
        end
    end
end)

-- Credit
local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(1, 0, 0, 40)
creditLabel.Position = UDim2.new(0,0,0,0)
creditLabel.BackgroundTransparency = 1
creditLabel.TextColor3 = Color3.fromRGB(255,255,255)
creditLabel.Font = Enum.Font.SourceSansBold
creditLabel.TextSize = 18
creditLabel.Text = "Dev: SnayzEez"
creditLabel.Parent = contentFrames["Credit"]

-- Onglet clic
for tabName, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        for _, frame in pairs(contentFrames) do
            frame.Visible = false
        end
        contentFrames[tabName].Visible = true
    end)
end

-- Onglet Visual par défaut
contentFrames["Visual"].Visible = true

-- Info raccourci en bas
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 20)
infoLabel.Position = UDim2.new(0, 0, 1, -25)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextSize = 14
infoLabel.Text = "RightShift for close/open"
infoLabel.TextXAlignment = Enum.TextXAlignment.Center
infoLabel.Parent = mainFrame

-- Toggle menu RightShift
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        menuOpen = not menuOpen
        mainFrame.Visible = menuOpen
    end
end)
