getgenv().boolNames = true -- activer/désactiver les pseudos

local Players = game.Players
local Camera = workspace.CurrentCamera
local lp = Players.LocalPlayer
local Names = {}

-- Supprimer texte quand un joueur quitte
local PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
    if Names[player.Name] then
        Names[player.Name]:Remove()
        Names[player.Name] = nil
    end
end)

local function mean(t)
    local sum = 0
    for _,v in pairs(t) do sum = sum + v end
    return sum / #t
end

while getgenv().boolNames do
    task.wait()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") then
            if not Names[player.Name] then
                local txt = Drawing.new("Text")
                txt.Visible = false
                txt.Size = 14 -- texte un peu plus petit
                txt.Color = Color3.fromRGB(255,255,255) -- blanc
                txt.Transparency = 1
                txt.ZIndex = 1
                txt.Center = true
                txt.Font = 3
                txt.Outline = true
                txt.OutlineColor = Color3.fromRGB(0,0,0) -- contour noir
                txt.Text = player.Name
                Names[player.Name] = txt
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

                Names[player.Name].Visible = true
                Names[player.Name].Position = Vector2.new(headScreenPos.x, centerScreenPos.y - distScreen)
            else
                Names[player.Name].Visible = false
            end
        end
    end
end

-- Cleanup
PlayerRemovingConnection:Disconnect()
for _, v in pairs(Names) do
    v:Remove()
end
Names = {}
script:Destroy()
