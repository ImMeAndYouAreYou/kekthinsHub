-- Rayfield UI Framework (included)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Get Players Service
local function getplrsname()
    for i, v in pairs(game:GetChildren()) do
        if v.ClassName == "Players" then
            return v.Name
        end
    end
end

local players = getplrsname()
local plr = game[players].LocalPlayer
local camera = workspace.CurrentCamera

-- Variables
local HitboxEnabled = false
local HitboxSize = 13
local ESPEnabled = false
local ESPObjects = {}
local ESPSettings = {
    Skeleton = true,
    Head = true,
    Body = true,
    Distance = true,
    Health = true,
    Name = true
}
local AimbotEnabled = false
local AimbotKey = Enum.KeyCode.Q
local AimbotTarget = nil
local AimbotFOV = 200

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Roblox Script",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by User",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = nil,
       FileName = "ScriptConfig"
    },
    Discord = {
       Enabled = false,
       Invite = "",
       RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
       Title = "",
       Subtitle = "",
       Note = "",
       FileName = "KeyFile",
       SaveKey = true,
       GrabKeyFromSite = false,
       Key = ""
    }
})

-- Hitbox Extender Tab
local HitboxTab = Window:CreateTab("Hitbox Extender", 4483362458)

local HitboxToggle = HitboxTab:CreateToggle({
    Name = "Enable Hitbox Extender",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(Value)
        HitboxEnabled = Value
    end,
})

local HitboxSlider = HitboxTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {1, 50},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 13,
    Flag = "HitboxSize",
    Callback = function(Value)
        HitboxSize = Value
    end,
})

-- ESP Tab
local ESPTab = Window:CreateTab("ESP", 4483362458)

local ESPMainToggle = ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        ESPEnabled = Value
        if not Value then
            ClearESP()
        else
            UpdateESP()
        end
    end,
})

local ESPSkeletonToggle = ESPTab:CreateToggle({
    Name = "Skeleton",
    CurrentValue = true,
    Flag = "ESPSkeleton",
    Callback = function(Value)
        ESPSettings.Skeleton = Value
        UpdateESP()
    end,
})

local ESPHeadToggle = ESPTab:CreateToggle({
    Name = "Head",
    CurrentValue = true,
    Flag = "ESPHead",
    Callback = function(Value)
        ESPSettings.Head = Value
        UpdateESP()
    end,
})

local ESPBodyToggle = ESPTab:CreateToggle({
    Name = "Body",
    CurrentValue = true,
    Flag = "ESPBody",
    Callback = function(Value)
        ESPSettings.Body = Value
        UpdateESP()
    end,
})

local ESPDistanceToggle = ESPTab:CreateToggle({
    Name = "Distance",
    CurrentValue = true,
    Flag = "ESPDistance",
    Callback = function(Value)
        ESPSettings.Distance = Value
        UpdateESP()
    end,
})

local ESPHealthToggle = ESPTab:CreateToggle({
    Name = "Health",
    CurrentValue = true,
    Flag = "ESPHealth",
    Callback = function(Value)
        ESPSettings.Health = Value
        UpdateESP()
    end,
})

local ESPNameToggle = ESPTab:CreateToggle({
    Name = "Name",
    CurrentValue = true,
    Flag = "ESPName",
    Callback = function(Value)
        ESPSettings.Name = Value
        UpdateESP()
    end,
})

-- Aimbot Tab
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)

local AimbotMainToggle = AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        AimbotEnabled = Value
        if not Value then
            AimbotTarget = nil
        end
    end,
})

local AimbotKeyDropdown = AimbotTab:CreateDropdown({
    Name = "Aimbot Key",
    Options = {"Q", "E", "LeftShift", "Tab", "RightMouseButton"},
    CurrentOption = "Q",
    Flag = "AimbotKey",
    Callback = function(Option)
        if Option == "Q" then
            AimbotKey = Enum.KeyCode.Q
        elseif Option == "E" then
            AimbotKey = Enum.KeyCode.E
        elseif Option == "LeftShift" then
            AimbotKey = Enum.KeyCode.LeftShift
        elseif Option == "Tab" then
            AimbotKey = Enum.KeyCode.Tab
        elseif Option == "RightMouseButton" then
            AimbotKey = Enum.UserInputType.MouseButton2
        end
    end,
})

local AimbotFOVSlider = AimbotTab:CreateSlider({
    Name = "FOV",
    Range = {50, 500},
    Increment = 10,
    Suffix = "",
    CurrentValue = 200,
    Flag = "AimbotFOV",
    Callback = function(Value)
        AimbotFOV = Value
    end,
})

-- ESP Functions
function ClearESP()
    for player, objects in pairs(ESPObjects) do
        for _, obj in pairs(objects) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
    end
    ESPObjects = {}
end

function CreateESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
    end
    ESPObjects[player] = {}
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    
    if not rootPart then return end
    
    -- Create ESP Billboard
    local espGui = Instance.new("BillboardGui")
    espGui.Name = "ESP_Gui"
    espGui.Size = UDim2.new(0, 200, 0, 100)
    espGui.StudsOffset = Vector3.new(0, 3, 0)
    espGui.AlwaysOnTop = true
    espGui.Adornee = rootPart
    espGui.Parent = rootPart
    
    local espFrame = Instance.new("Frame")
    espFrame.Size = UDim2.new(1, 0, 1, 0)
    espFrame.BackgroundTransparency = 1
    espFrame.Parent = espGui
    
    table.insert(ESPObjects[player], espGui)
    
    -- Name Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = espFrame
    table.insert(ESPObjects[player], nameLabel)
    
    -- Health Label
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "Health"
    healthLabel.Size = UDim2.new(1, 0, 0, 20)
    healthLabel.Position = UDim2.new(0, 0, 0, 20)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = ""
    healthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    healthLabel.TextSize = 12
    healthLabel.TextStrokeTransparency = 0
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.Parent = espFrame
    table.insert(ESPObjects[player], healthLabel)
    
    -- Distance Label
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "Distance"
    distanceLabel.Size = UDim2.new(1, 0, 0, 20)
    distanceLabel.Position = UDim2.new(0, 0, 0, 40)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = ""
    distanceLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    distanceLabel.TextSize = 12
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.Parent = espFrame
    table.insert(ESPObjects[player], distanceLabel)
    
    -- Head Box
    if head then
        local headBox = Instance.new("BoxHandleAdornment")
        headBox.Name = "ESP_Head"
        headBox.Size = head.Size
        headBox.Transparency = 0.5
        headBox.Color3 = Color3.fromRGB(255, 0, 0)
        headBox.AlwaysOnTop = true
        headBox.Adornee = head
        headBox.ZIndex = 1
        headBox.Parent = head
        table.insert(ESPObjects[player], headBox)
    end
    
    -- Body Box (Torso)
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if torso then
        local bodyBox = Instance.new("BoxHandleAdornment")
        bodyBox.Name = "ESP_Body"
        bodyBox.Size = torso.Size
        bodyBox.Transparency = 0.5
        bodyBox.Color3 = Color3.fromRGB(0, 255, 0)
        bodyBox.AlwaysOnTop = true
        bodyBox.Adornee = torso
        bodyBox.ZIndex = 1
        bodyBox.Parent = torso
        table.insert(ESPObjects[player], bodyBox)
    end
    
    -- Skeleton Lines
    local function createLine(part1, part2)
        local attachment1 = Instance.new("Attachment")
        attachment1.Parent = part1
        
        local attachment2 = Instance.new("Attachment")
        attachment2.Parent = part2
        
        local line = Instance.new("Beam")
        line.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        line.Transparency = NumberSequence.new(0.3)
        line.Width0 = 0.2
        line.Width1 = 0.2
        line.Attachment0 = attachment1
        line.Attachment1 = attachment2
        line.Parent = part1
        
        table.insert(ESPObjects[player], attachment1)
        table.insert(ESPObjects[player], attachment2)
        table.insert(ESPObjects[player], line)
    end
    
    -- Create skeleton connections
    if rootPart and head then
        createLine(rootPart, head)
    end
    
    local leftArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm")
    local rightArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
    local leftLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg")
    local rightLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg")
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    
    if torso then
        if rootPart then createLine(torso, rootPart) end
        if leftArm then createLine(torso, leftArm) end
        if rightArm then createLine(torso, rightArm) end
        if leftLeg and rootPart then createLine(rootPart, leftLeg) end
        if rightLeg and rootPart then createLine(rootPart, rightLeg) end
    end
end

function UpdateESP()
    ClearESP()
    if not ESPEnabled then return end
    
    for _, player in pairs(game[players]:GetPlayers()) do
        if player ~= plr and player.Character then
            CreateESP(player)
        end
    end
end

-- ESP Update Loop
coroutine.resume(coroutine.create(function()
    while wait(0.1) do
        if ESPEnabled then
            for _, player in pairs(game[players]:GetPlayers()) do
                if player ~= plr and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local objects = ESPObjects[player]
                    if objects then
                        local rootPart = player.Character.HumanoidRootPart
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        local distance = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and 
                                       (rootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude or 0
                        
                        for _, obj in pairs(objects) do
                            if obj and obj.Parent then
                                if obj.Name == "Distance" and ESPSettings.Distance then
                                    obj.Text = string.format("Distance: %.1f", distance)
                                    obj.Visible = true
                                elseif obj.Name == "Distance" then
                                    obj.Visible = false
                                elseif obj.Name == "Health" and ESPSettings.Health and humanoid then
                                    obj.Text = string.format("Health: %d/%d", humanoid.Health, humanoid.MaxHealth)
                                    obj.Visible = true
                                elseif obj.Name == "Health" then
                                    obj.Visible = false
                                elseif obj.Name == "Name" then
                                    obj.Visible = ESPSettings.Name
                                elseif obj.Name == "ESP_Head" then
                                    obj.Visible = ESPSettings.Head
                                elseif obj.Name == "ESP_Body" then
                                    obj.Visible = ESPSettings.Body
                                elseif obj.ClassName == "Beam" then
                                    obj.Visible = ESPSettings.Skeleton
                                end
                            end
                        end
                    else
                        CreateESP(player)
                    end
                end
            end
        end
    end
end))

-- Hitbox Extender Loop
coroutine.resume(coroutine.create(function()
    while wait(0.1) do
        if HitboxEnabled then
            for _, v in pairs(game[players]:GetPlayers()) do
                if v.Name ~= plr.Name and v.Character then
                    local char = v.Character
                    
                    if char:FindFirstChild("RightUpperLeg") then
                        char.RightUpperLeg.CanCollide = false
                        char.RightUpperLeg.Transparency = 0.5
                        char.RightUpperLeg.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    end
                    
                    if char:FindFirstChild("LeftUpperLeg") then
                        char.LeftUpperLeg.CanCollide = false
                        char.LeftUpperLeg.Transparency = 0.5
                        char.LeftUpperLeg.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    end
                    
                    if char:FindFirstChild("HeadHB") then
                        char.HeadHB.CanCollide = false
                        char.HeadHB.Transparency = 0.5
                        char.HeadHB.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    end
                    
                    if char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CanCollide = false
                        char.HumanoidRootPart.Transparency = 0.5
                        char.HumanoidRootPart.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    end
                end
            end
        end
    end
end))

-- Player Added/Removed Events
game[players].PlayerAdded:Connect(function(player)
    if ESPEnabled then
        wait(1) -- Wait for character to load
        CreateESP(player)
    end
end)

game[players].PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        ESPObjects[player] = nil
    end
end)

-- Aimbot Functions
function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = AimbotFOV
    
    for _, player in pairs(game[players]:GetPlayers()) do
        if player ~= plr and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and 
           player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local character = player.Character
            local rootPart = character.HumanoidRootPart
            local head = character:FindFirstChild("Head")
            
            if rootPart and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local screenPoint, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                local distance = (rootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                
                if onScreen then
                    local screenDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude
                    
                    if screenDistance < shortestDistance then
                        shortestDistance = screenDistance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Aimbot Input Handler
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if AimbotEnabled then
        local keyPressed = false
        if typeof(AimbotKey) == "EnumItem" then
            if AimbotKey.EnumType == Enum.KeyCode then
                keyPressed = input.KeyCode == AimbotKey
            elseif AimbotKey.EnumType == Enum.UserInputType then
                keyPressed = input.UserInputType == AimbotKey
            end
        end
        
        if keyPressed then
            AimbotTarget = GetClosestPlayer()
        end
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if AimbotEnabled then
        local keyReleased = false
        if typeof(AimbotKey) == "EnumItem" then
            if AimbotKey.EnumType == Enum.KeyCode then
                keyReleased = input.KeyCode == AimbotKey
            elseif AimbotKey.EnumType == Enum.UserInputType then
                keyReleased = input.UserInputType == AimbotKey
            end
        end
        
        if keyReleased then
            AimbotTarget = nil
        end
    end
end)

-- Aimbot Camera Lock Loop
game:GetService("RunService").RenderStepped:Connect(function()
    if AimbotEnabled and AimbotTarget and AimbotTarget.Character and AimbotTarget.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = AimbotTarget.Character.HumanoidRootPart
        local targetHead = AimbotTarget.Character:FindFirstChild("Head")
        
        if targetRoot and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = targetHead and targetHead.Position or targetRoot.Position
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPosition)
        end
    end
end)

-- Initialize ESP on script start
wait(2)
UpdateESP()
