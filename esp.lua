-- SkeletonESP.lua (ModuleScript dans ReplicatedStorage)

local Players = game:GetService("Players")

local SkeletonESP = {}
SkeletonESP.Enabled = false

-- Par personnage: instances créées (attachments + beams) et connexions (died/ancestry)
local perCharInstances = {}   -- [Character] = {Instance|RBXScriptConnection, ...}
local perCharConnections = {} -- [Character] = {RBXScriptConnection, ...}

local function destroyList(list)
    for _, v in ipairs(list) do
        if typeof(v) == "RBXScriptConnection" then
            v:Disconnect()
        elseif typeof(v) == "Instance" and v and v.Parent then
            v:Destroy()
        end
    end
end

local function clearForCharacter(char)
    if perCharInstances[char] then
        destroyList(perCharInstances[char])
        perCharInstances[char] = nil
    end
    if perCharConnections[char] then
        destroyList(perCharConnections[char])
        perCharConnections[char] = nil
    end
end

local function clearAll()
    for char in pairs(perCharInstances) do
        clearForCharacter(char)
    end
end

local function addBeamBetween(part0, part1, bucket, color)
    if not (part0 and part1) then return end

    local att0 = part0:FindFirstChild("NovaSkelAtt") or Instance.new("Attachment")
    att0.Name = "NovaSkelAtt"
    att0.Parent = part0

    local att1 = part1:FindFirstChild("NovaSkelAtt") or Instance.new("Attachment")
    att1.Name = "NovaSkelAtt"
    att1.Parent = part1

    local beam = Instance.new("Beam")
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Color = ColorSequence.new(color or Color3.fromRGB(0,255,0))
    beam.Transparency = NumberSequence.new(0)
    beam.Width0 = 0.05
    beam.Width1 = 0.05
    beam.FaceCamera = true
    beam.LightInfluence = 0
    beam.Parent = att0

    table.insert(bucket, att0)
    table.insert(bucket, att1)
    table.insert(bucket, beam)
end

local function buildR15(char, bucket, color)
    local function gp(name) return char:FindFirstChild(name) end
    -- Tronc
    addBeamBetween(gp("Head"), gp("UpperTorso"), bucket, color)
    addBeamBetween(gp("UpperTorso"), gp("LowerTorso"), bucket, color)

    -- Bras
    addBeamBetween(gp("UpperTorso"), gp("LeftUpperArm"), bucket, color)
    addBeamBetween(gp("LeftUpperArm"), gp("LeftLowerArm"), bucket, color)
    addBeamBetween(gp("LeftLowerArm"), gp("LeftHand"), bucket, color)

    addBeamBetween(gp("UpperTorso"), gp("RightUpperArm"), bucket, color)
    addBeamBetween(gp("RightUpperArm"), gp("RightLowerArm"), bucket, color)
    addBeamBetween(gp("RightLowerArm"), gp("RightHand"), bucket, color)

    -- Jambes
    addBeamBetween(gp("LowerTorso"), gp("LeftUpperLeg"), bucket, color)
    addBeamBetween(gp("LeftUpperLeg"), gp("LeftLowerLeg"), bucket, color)
    addBeamBetween(gp("LeftLowerLeg"), gp("LeftFoot"), bucket, color)

    addBeamBetween(gp("LowerTorso"), gp("RightUpperLeg"), bucket, color)
    addBeamBetween(gp("RightUpperLeg"), gp("RightLowerLeg"), bucket, color)
    addBeamBetween(gp("RightLowerLeg"), gp("RightFoot"), bucket, color)
end

local function buildR6(char, bucket, color)
    local function gp(name) return char:FindFirstChild(name) end
    addBeamBetween(gp("Head"), gp("Torso"), bucket, color)
    addBeamBetween(gp("Torso"), gp("Left Arm"), bucket, color)
    addBeamBetween(gp("Torso"), gp("Right Arm"), bucket, color)
    addBeamBetween(gp("Torso"), gp("Left Leg"), bucket, color)
    addBeamBetween(gp("Torso"), gp("Right Leg"), bucket, color)
end

local function ensureSkeleton(char, color)
    if perCharInstances[char] then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local bucket = {}
    local lineColor = color or Color3.fromRGB(0,255,0)

    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        buildR15(char, bucket, lineColor)
    else
        buildR6(char, bucket, lineColor)
    end

    local conns = {}
    conns[#conns+1] = char.AncestryChanged:Connect(function(_, parent)
        if not parent then clearForCharacter(char) end
    end)
    conns[#conns+1] = humanoid.Died:Connect(function()
        clearForCharacter(char)
    end)

    perCharInstances[char] = bucket
    perCharConnections[char] = conns
end

function SkeletonESP:Toggle(state)
    self.Enabled = state
    if not state then
        clearAll()
        return
    end

    local localPlayer = Players.LocalPlayer
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            ensureSkeleton(p.Character)
        end
    end
end

-- Gestion nouveaux joueurs / respawns
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        if SkeletonESP.Enabled then
            ensureSkeleton(char)
        end
    end)
end)

-- Pour les joueurs déjà présents au moment du require
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= Players.LocalPlayer then
        p.CharacterAdded:Connect(function(char)
            if SkeletonESP.Enabled then
                ensureSkeleton(char)
            end
        end)
    end
end

return SkeletonESP
