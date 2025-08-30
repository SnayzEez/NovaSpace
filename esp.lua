-- Toggle ESP
function ESPModule:Toggle(state)
    self.Enabled = state
    ESPRemote:FireServer(state)
end

-- Client Side: Surveiller les personnages pour appliquer l’ESP localement
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

-- Client reçoit les updates de toggle du serveur (optionnel si tu veux l’affichage local direct)
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

-- Surveiller les parties qui apparaissent après le toggle
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
