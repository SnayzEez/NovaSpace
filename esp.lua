-- ESPModule.lua
-- Place ce ModuleScript dans ReplicatedStorage
local ESPModule = {}
ESPModule.Enabled = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Vérifie si le RemoteEvent existe sinon le créer
local ESPRemote = ReplicatedStorage:FindFirstChild("ESPRemote")
if not ESPRemote then
    ESPRemote = Instance.new("RemoteEvent")
    ESPRemote.Name = "ESPRemote"
    ESPRemote.Parent = ReplicatedStorage
end

-- Toggle Skeleton ESP
function ESPModule:Toggle(state)
    self.Enabled = state
    ESPRemote:FireServer(state)
end

-- Fonction pour créer l’ESP sur une partie
local function createESP(part)
    local sides = {Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Left, Enum.NormalId.Right, Enum.NormalId.Front, Enum.NormalId.Back}
    for _, side in pairs(sides) do
        local sg = Instance.new("SurfaceGui")
        sg.Name = "ESP"
        sg.Face = side
        sg.Adornee = part
        sg.Parent = part
        sg.AlwaysOnTop = true
        sg.ZOffset = 1

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        frame.BackgroundTransparency = 0.3
        frame.Parent = sg
    end
end

-- Fonction pour retirer l’ESP
local function removeESP(part)
    for _, sg in pairs(part:GetChildren()) do
        if sg:IsA("SurfaceGui") and sg.Name == "ESP" then
            sg:Destroy()
        end
    end
end

-- Appliquer ESP sur le personnage local
ESPRemote.OnClientEvent:Connect(function(state)
    local player = Players.LocalPlayer
    if not player.Character then return end
    for _, part in pairs(player.Character:GetChildren()) do
        if part:IsA("BasePart") then
            if state then
                createESP(part)
            else
                removeESP(part)
            end
        end
    end
end)

-- Surveiller les nouveaux personnages
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if ESPModule.Enabled then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    createESP(part)
                end
            end
        end
    end)
end)

return ESPModule
