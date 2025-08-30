- ModuleScript ESP (à placer dans ReplicatedStorage ou à utiliser via require)

local Players = game:GetService("Players")

local ESPModule = {}
ESPModule.Enabled = false

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

local function removeESP(part)
    for _, sg in pairs(part:GetChildren()) do
        if sg:IsA("SurfaceGui") and sg.Name == "ESP" then
            sg:Destroy()
        end
    end
end

function ESPModule:Toggle(state)
    self.Enabled = state
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            for _, part in ipairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    if state then
                        createESP(part)
                    else
                        removeESP(part)
                    end
                end
            end
        end
    end
end

-- Met à jour l'ESP pour les nouveaux joueurs/personnages
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if ESPModule.Enabled then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    createESP(part)
                end
            end
        end
    end)
end)
