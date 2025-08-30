getgenv().boolBoxes = true -- activer/désactiver les boxes

local Players = game.Players
local Camera = workspace.CurrentCamera
local lp = Players.LocalPlayer
local Boxes = {}

-- Supprimer box quand un joueur quitte
local PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
    if Boxes[player.Name] then
        Boxes[player.Name]:Remove()
        Boxes[player.Name] = nil
    end
end)

local function mean(t)
    local sum = 0
    for _,v in pairs(t) do sum = sum + v end
    return sum / #t
end

while getgenv().boolBoxes do
    task.wait()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") then
            if not Boxes[player.Name] then
                local sq = Drawing.new("Square")
                sq.Visible = false
                sq.Thickness = 1
                sq.Size = Vector2.new(10,10)
                sq.Filled = false
                sq.Color = Color3.fromRGB(255,0,255) -- rose
                Boxes[player.Name] = sq
            end

            local head = player.Character.Head
            local hrp = player.Character.HumanoidRootPart
            local headScreenPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
            local hrpScreenPos, hrpOnScreen = Camera:WorldToViewportPoint(hrp.Position)

            if headOnScreen and hrpOnScreen then
                local distScreen = (headScreenPos - hrpScreenPos).Magnitude
                local centerPos = Vector3.new(mean({head.Position.x, hrp.Position.x}),
                                              mean({head.Position.y, hrp.Position.y}),
                                              mean({head.Position.z, hrp.Position.z}))
                local centerScreenPos = Camera:WorldToViewportPoint(centerPos)

                Boxes[player.Name].Visible = true
                Boxes[player.Name].Position = Vector2.new(centerScreenPos.x - distScreen, centerScreenPos.y - distScreen)
                Boxes[player.Name].Size = Vector2.new(distScreen*2, distScreen*3)
            else
                Boxes[player.Name].Visible = false
            end
        end
    end
end

-- Cleanup
PlayerRemovingConnection:Disconnect()
for _, v in pairs(Boxes) do
    v:Remove()
end
Boxes = {}
script:Destroy()
