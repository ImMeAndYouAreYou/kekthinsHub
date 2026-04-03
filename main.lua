-- Load the new UI library
local Library = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ========== VARIABLES ==========
-- Hitbox Extender
local HitboxEnabled = false
local HitboxSize = 13
local HitboxTransparency = 0.5
local HitboxColor = Color3.fromRGB(255, 0, 0)
local HitboxHeadDot = false

-- ESP
local ESPEnabled = false
local ESPObjects = {}
local ESPTrackers = {}
local ESPSettings = {
    Skeleton = false,
    HeadBox = false,
    BodyBox = false,
    Distance = false,
    Health = false,
    Name = false,
    Tracer = false,
    HeadDot = false
}
local ESPColors = {
    Skeleton = Color3.fromRGB(255, 255, 255),
    HeadBox = Color3.fromRGB(255, 50, 50),
    BodyBox = Color3.fromRGB(50, 255, 50),
    Tracer = Color3.fromRGB(255, 255, 255),
    Name = Color3.fromRGB(255, 255, 255),
    Health = Color3.fromRGB(255, 80, 80),
    Distance = Color3.fromRGB(80, 200, 255),
    HeadDot = Color3.fromRGB(255, 0, 0)
}

-- Aimbot
local AimbotEnabled = false
local AimbotKey = Enum.KeyCode.Q
local AimbotFOV = 200
local AimbotShowFOV = true
local AimbotSmoothness = 0.3
local AimbotTarget = nil
local AimbotFOVCircle = nil
local AimbotLockPart = "Head" -- "Head" or "Torso"

-- Local Player
local WalkSpeedValue = 16
local JumpPowerValue = 7.2
local FlyEnabled = false
local FlySpeed = 50
local FlyBodyVelocity = nil
local NoClipEnabled = false

-- ========== UI CREATION ==========
local Window = Library:CreateWindow({
    Name = "Advanced Script Hub",
    LoadingTitle = "Loading Script...",
    LoadingSubtitle = "by Exploiter",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ScriptHub",
        FileName = "Config"
    },
    KeySystem = false
})

-- ========== HITBOX EXTENDER TAB ==========
local HitboxTab = Window:CreateTab("Hitbox Extender", "4483362458")

HitboxTab:CreateToggle({
    Name = "Enable Hitbox Extender",
    CurrentValue = false,
    Callback = function(Value)
        HitboxEnabled = Value
    end
})

HitboxTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {1, 50},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 13,
    Callback = function(Value)
        HitboxSize = Value
    end
})

HitboxTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.5,
    Callback = function(Value)
        HitboxTransparency = Value
    end
})

HitboxTab:CreateColorPicker({
    Name = "Hitbox Color",
    CurrentColor = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
        HitboxColor = Color
    end
})

HitboxTab:CreateToggle({
    Name = "Head Dot (ESP Style)",
    CurrentValue = false,
    Callback = function(Value)
        HitboxHeadDot = Value
    end
})

-- ========== ESP TAB ==========
local ESPTab = Window:CreateTab("ESP", "4483362458")

ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESPEnabled = Value
        if not Value then
            ClearESP()
        else
            UpdateESP()
        end
    end
})

-- ESP Elements
ESPTab:CreateToggle({
    Name = "Skeleton",
    CurrentValue = false,
    Callback = function(Value)
        ESPSettings.Skeleton = Value
        UpdateESP()
    end
})

ESPTab:CreateToggle({
    Name = "Head Box",
    CurrentValue = false,
    Callback = function(Value)
        ESPSettings.HeadBox = Value
        UpdateESP()
    end
})

ESPTab:CreateToggle({
    Name = "Body Box",
    CurrentValue = false,
    Callback = function(Value)
        ESPSettings.BodyBox = Value
        UpdateESP()
    end
})

ESPTab:CreateToggle({
    Name = "Name",
    CurrentValue = false,
    Callback = function(Value)
        ESPSettings.Name = Value
        UpdateESP()
    end
})

ESPTab:CreateToggle({
    Name = "Health",
    CurrentValue = false,
    Callback = function(Value)
        ESPSettings.Health = Value
        UpdateESP()
    end
})

ESPTab:CreateToggle({
    Name = "Distance",
    CurrentValue = false,
    Callback = function(Value)
        ESPSettings.Distance = Value
        UpdateESP()
    end
})

ESPTab:CreateToggle({
    Name = "Tracer (Line to Player)",
    CurrentValue = false,
    Callback = function(Value)
        ESPSettings.Tracer = Value
        UpdateESP()
    end
})

ESPTab:CreateToggle({
    Name = "Head Dot",
    CurrentValue = false,
    Callback = function(Value)
        ESPSettings.HeadDot = Value
        UpdateESP()
    end
})

-- ESP Color Pickers
ESPTab:CreateColorPicker({
    Name = "Skeleton Color",
    CurrentColor = ESPColors.Skeleton,
    Callback = function(Color)
        ESPColors.Skeleton = Color
        UpdateESP()
    end
})

ESPTab:CreateColorPicker({
    Name = "Head Box Color",
    CurrentColor = ESPColors.HeadBox,
    Callback = function(Color)
        ESPColors.HeadBox = Color
        UpdateESP()
    end
})

ESPTab:CreateColorPicker({
    Name = "Body Box Color",
    CurrentColor = ESPColors.BodyBox,
    Callback = function(Color)
        ESPColors.BodyBox = Color
        UpdateESP()
    end
})

ESPTab:CreateColorPicker({
    Name = "Tracer Color",
    CurrentColor = ESPColors.Tracer,
    Callback = function(Color)
        ESPColors.Tracer = Color
        UpdateESP()
    end
})

-- ========== AIMBOT TAB ==========
local AimbotTab = Window:CreateTab("Aimbot", "4483362458")

AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        AimbotEnabled = Value
        if not Value then
            AimbotTarget = nil
        end
    end
})

AimbotTab:CreateDropdown({
    Name = "Aimbot Key",
    Options = {"Q", "E", "LeftShift", "Tab", "RightMouseButton", "X", "C", "F"},
    CurrentOption = "Q",
    Callback = function(Option)
        local keyMap = {
            Q = Enum.KeyCode.Q,
            E = Enum.KeyCode.E,
            LeftShift = Enum.KeyCode.LeftShift,
            Tab = Enum.KeyCode.Tab,
            RightMouseButton = Enum.UserInputType.MouseButton2,
            X = Enum.KeyCode.X,
            C = Enum.KeyCode.C,
            F = Enum.KeyCode.F
        }
        AimbotKey = keyMap[Option]
    end
})

AimbotTab:CreateDropdown({
    Name = "Lock Part",
    Options = {"Head", "Torso"},
    CurrentOption = "Head",
    Callback = function(Option)
        AimbotLockPart = Option
    end
})

AimbotTab:CreateSlider({
    Name = "FOV Radius",
    Range = {50, 500},
    Increment = 10,
    Suffix = " px",
    CurrentValue = 200,
    Callback = function(Value)
        AimbotFOV = Value
        UpdateAimbotFOVCircle()
    end
})

AimbotTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = true,
    Callback = function(Value)
        AimbotShowFOV = Value
        UpdateAimbotFOVCircle()
    end
})

AimbotTab:CreateSlider({
    Name = "Smoothness",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.3,
    Callback = function(Value)
        AimbotSmoothness = Value
    end
})

-- ========== LOCAL PLAYER TAB ==========
local LocalTab = Window:CreateTab("Local Player", "4483362458")

LocalTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    Suffix = " studs/s",
    CurrentValue = 16,
    Callback = function(Value)
        WalkSpeedValue = Value
        ApplyLocalStats()
    end
})

LocalTab:CreateSlider({
    Name = "Jump Power",
    Range = {7.2, 100},
    Increment = 0.5,
    Suffix = "",
    CurrentValue = 7.2,
    Callback = function(Value)
        JumpPowerValue = Value
        ApplyLocalStats()
    end
})

LocalTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(Value)
        FlyEnabled = Value
        ToggleFly(Value)
    end
})

LocalTab:CreateSlider({
    Name = "Fly Speed",
    Range = {20, 200},
    Increment = 5,
    Suffix = " studs/s",
    CurrentValue = 50,
    Callback = function(Value)
        FlySpeed = Value
        if FlyEnabled then
            ToggleFly(true) -- Refresh fly
        end
    end
})

LocalTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Callback = function(Value)
        NoClipEnabled = Value
        if Value then
            LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        else
            LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        end
    end
})

-- ========== FUNCTIONS ==========

-- Apply walk speed and jump power (persistent)
function ApplyLocalStats()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = WalkSpeedValue
            humanoid.JumpPower = JumpPowerValue
        end
    end
end

-- Character added event to re-apply stats
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(0.5)
    ApplyLocalStats()
    if FlyEnabled then
        ToggleFly(true)
    end
    if NoClipEnabled then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        end
    end
end)

-- Fly system
function ToggleFly(state)
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    if state then
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        FlyBodyVelocity.P = 1e5
        FlyBodyVelocity.Parent = rootPart
        
        humanoid.PlatformStand = true
        
        -- Fly control loop
        local flyConnection
        flyConnection = RunService.RenderStepped:Connect(function()
            if not FlyEnabled or not character or not character.Parent then
                if flyConnection then flyConnection:Disconnect() end
                if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
                if humanoid then humanoid.PlatformStand = false end
                return
            end
            
            local moveDirection = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
            
            moveDirection = moveDirection.Unit
            FlyBodyVelocity.Velocity = moveDirection * FlySpeed
        end)
        
        -- Store connection for cleanup
        if not FlyBodyVelocity:FindFirstChild("FlyConnection") then
            local conHolder = Instance.new("BoolValue")
            conHolder.Name = "FlyConnection"
            conHolder.Value = flyConnection
            conHolder.Parent = FlyBodyVelocity
        end
    else
        if FlyBodyVelocity then
            local con = FlyBodyVelocity:FindFirstChild("FlyConnection")
            if con then
                local connection = con.Value
                if typeof(connection) == "RBXScriptConnection" then
                    connection:Disconnect()
                end
                con:Destroy()
            end
            FlyBodyVelocity:Destroy()
            FlyBodyVelocity = nil
        end
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

-- ========== HITBOX EXTENDER LOOP ==========
coroutine.wrap(function()
    while wait(0.1) do
        if HitboxEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local char = player.Character
                    local parts = {"HumanoidRootPart", "Head", "Torso", "UpperTorso", "LowerTorso", "RightUpperLeg", "LeftUpperLeg"}
                    for _, partName in pairs(parts) do
                        local part = char:FindFirstChild(partName)
                        if part then
                            part.CanCollide = false
                            part.Transparency = HitboxTransparency
                            part.Color = HitboxColor
                            part.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                        end
                    end
                    
                    -- Head dot (like ESP)
                    if HitboxHeadDot then
                        local head = char:FindFirstChild("Head")
                        if head then
                            local dot = head:FindFirstChild("HeadDot")
                            if not dot then
                                dot = Instance.new("BillboardGui")
                                dot.Name = "HeadDot"
                                dot.Size = UDim2.new(0, 10, 0, 10)
                                dot.AlwaysOnTop = true
                                dot.Adornee = head
                                local frame = Instance.new("Frame")
                                frame.Size = UDim2.new(1, 0, 1, 0)
                                frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                                frame.BorderSizePixel = 0
                                frame.Parent = dot
                                dot.Parent = head
                            end
                        end
                    else
                        local head = char:FindFirstChild("Head")
                        if head and head:FindFirstChild("HeadDot") then
                            head.HeadDot:Destroy()
                        end
                    end
                end
            end
        end
    end
end)()

-- ========== ESP FUNCTIONS ==========
function ClearESP()
    for player, objects in pairs(ESPObjects) do
        for _, obj in pairs(objects) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
    end
    ESPObjects = {}
    for _, tracker in pairs(ESPTrackers) do
        if tracker and tracker.Parent then
            tracker:Destroy()
        end
    end
    ESPTrackers = {}
end

function CreateESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character.HumanoidRootPart
    local head = character:FindFirstChild("Head")
    
    if not rootPart then return end
    
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj and obj.Parent then obj:Destroy() end
        end
    end
    ESPObjects[player] = {}
    
    -- Billboard GUI for text info
    local espGui = Instance.new("BillboardGui")
    espGui.Name = "ESP_Gui"
    espGui.Size = UDim2.new(0, 250, 0, 120)
    espGui.StudsOffset = Vector3.new(0, 3, 0)
    espGui.AlwaysOnTop = true
    espGui.Adornee = rootPart
    espGui.Parent = rootPart
    table.insert(ESPObjects[player], espGui)
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = espGui
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, -4, 0, 20)
    nameLabel.Position = UDim2.new(0, 2, 0, 2)
    nameLabel.BackgroundTransparency = 0.7
    nameLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = ESPColors.Name
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = mainFrame
    table.insert(ESPObjects[player], nameLabel)
    
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "Health"
    healthLabel.Size = UDim2.new(1, -4, 0, 18)
    healthLabel.Position = UDim2.new(0, 2, 0, 24)
    healthLabel.BackgroundTransparency = 0.7
    healthLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    healthLabel.TextColor3 = ESPColors.Health
    healthLabel.TextSize = 13
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.TextXAlignment = Enum.TextXAlignment.Left
    healthLabel.Parent = mainFrame
    table.insert(ESPObjects[player], healthLabel)
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "Distance"
    distanceLabel.Size = UDim2.new(1, -4, 0, 18)
    distanceLabel.Position = UDim2.new(0, 2, 0, 44)
    distanceLabel.BackgroundTransparency = 0.7
    distanceLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.TextColor3 = ESPColors.Distance
    distanceLabel.TextSize = 13
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    distanceLabel.Parent = mainFrame
    table.insert(ESPObjects[player], distanceLabel)
    
    -- Head Box
    if head then
        local headBox = Instance.new("BoxHandleAdornment")
        headBox.Name = "ESP_HeadBox"
        headBox.Size = head.Size + Vector3.new(0.2, 0.2, 0.2)
        headBox.Transparency = 0.6
        headBox.Color3 = ESPColors.HeadBox
        headBox.AlwaysOnTop = true
        headBox.Adornee = head
        headBox.ZIndex = 2
        headBox.Parent = head
        table.insert(ESPObjects[player], headBox)
        
        local headOutline = Instance.new("SelectionBox")
        headOutline.Name = "ESP_HeadOutline"
        headOutline.Adornee = head
        headOutline.Transparency = 0.7
        headOutline.Color3 = ESPColors.HeadBox
        headOutline.Thickness = 0.15
        headOutline.Parent = head
        table.insert(ESPObjects[player], headOutline)
    end
    
    -- Body Box
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if torso then
        local bodyBox = Instance.new("BoxHandleAdornment")
        bodyBox.Name = "ESP_BodyBox"
        bodyBox.Size = torso.Size + Vector3.new(0.2, 0.2, 0.2)
        bodyBox.Transparency = 0.6
        bodyBox.Color3 = ESPColors.BodyBox
        bodyBox.AlwaysOnTop = true
        bodyBox.Adornee = torso
        bodyBox.ZIndex = 2
        bodyBox.Parent = torso
        table.insert(ESPObjects[player], bodyBox)
        
        local bodyOutline = Instance.new("SelectionBox")
        bodyOutline.Name = "ESP_BodyOutline"
        bodyOutline.Adornee = torso
        bodyOutline.Transparency = 0.7
        bodyOutline.Color3 = ESPColors.BodyBox
        bodyOutline.Thickness = 0.15
        bodyOutline.Parent = torso
        table.insert(ESPObjects[player], bodyOutline)
    end
    
    -- Head Dot (separate from hitbox)
    if head then
        local headDot = Instance.new("BillboardGui")
        headDot.Name = "ESP_HeadDot"
        headDot.Size = UDim2.new(0, 8, 0, 8)
        headDot.AlwaysOnTop = true
        headDot.Adornee = head
        local dotFrame = Instance.new("Frame")
        dotFrame.Size = UDim2.new(1, 0, 1, 0)
        dotFrame.BackgroundColor3 = ESPColors.HeadDot
        dotFrame.BorderSizePixel = 0
        dotFrame.Parent = headDot
        headDot.Parent = head
        table.insert(ESPObjects[player], headDot)
    end
    
    -- Skeleton lines
    local function createLine(partA, partB)
        if not partA or not partB then return end
        local attA = Instance.new("Attachment", partA)
        local attB = Instance.new("Attachment", partB)
        local beam = Instance.new("Beam")
        beam.Color = ColorSequence.new(ESPColors.Skeleton)
        beam.Transparency = NumberSequence.new(0.3)
        beam.Width0 = 0.1
        beam.Width1 = 0.1
        beam.Attachment0 = attA
        beam.Attachment1 = attB
        beam.Parent = partA
        table.insert(ESPObjects[player], attA)
        table.insert(ESPObjects[player], attB)
        table.insert(ESPObjects[player], beam)
    end
    
    local leftArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm")
    local rightArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
    local leftLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg")
    local rightLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg")
    
    if torso then
        createLine(torso, rootPart)
        if leftArm then createLine(torso, leftArm) end
        if rightArm then createLine(torso, rightArm) end
        if leftLeg then createLine(rootPart, leftLeg) end
        if rightLeg then createLine(rootPart, rightLeg) end
        if head then createLine(torso, head) end
    end
    
    -- Tracer (line from camera to player)
    local tracer = Instance.new("LineHandleAdornment")
    tracer.Name = "ESP_Tracer"
    tracer.AlwaysOnTop = true
    tracer.ZIndex = 1
    tracer.Thickness = 0.1
    tracer.Color3 = ESPColors.Tracer
    tracer.Transparency = 0.5
    tracer.Parent = rootPart
    table.insert(ESPObjects[player], tracer)
    ESPTrackers[player] = tracer
end

function UpdateESP()
    ClearESP()
    if not ESPEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            CreateESP(player)
        end
    end
end

-- ESP update loop (visibility and dynamic info)
coroutine.wrap(function()
    while wait(0.1) do
        if ESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local objects = ESPObjects[player]
                    if objects then
                        local rootPart = player.Character.HumanoidRootPart
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
                                       (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or 0
                        
                        for _, obj in pairs(objects) do
                            if obj and obj.Parent then
                                if obj.Name == "Distance" then
                                    obj.Visible = ESPSettings.Distance
                                    if ESPSettings.Distance then
                                        obj.Text = string.format("Distance: %.1f", distance)
                                    end
                                elseif obj.Name == "Health" then
                                    obj.Visible = ESPSettings.Health
                                    if ESPSettings.Health and humanoid then
                                        obj.Text = string.format("Health: %d/%d", humanoid.Health, humanoid.MaxHealth)
                                    end
                                elseif obj.Name == "Name" then
                                    obj.Visible = ESPSettings.Name
                                elseif obj.Name == "ESP_HeadBox" or obj.Name == "ESP_HeadOutline" then
                                    obj.Visible = ESPSettings.HeadBox
                                elseif obj.Name == "ESP_BodyBox" or obj.Name == "ESP_BodyOutline" then
                                    obj.Visible = ESPSettings.BodyBox
                                elseif obj.Name == "ESP_HeadDot" then
                                    obj.Visible = ESPSettings.HeadDot
                                elseif obj.ClassName == "Beam" then
                                    obj.Visible = ESPSettings.Skeleton
                                elseif obj.Name == "ESP_Tracer" then
                                    obj.Visible = ESPSettings.Tracer
                                    if ESPSettings.Tracer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                        local cameraPos = Camera.CFrame.Position
                                        local targetPos = rootPart.Position
                                        obj.PointA = cameraPos
                                        obj.PointB = targetPos
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)()

-- Player added/removed events
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        if ESPEnabled then
            CreateESP(player)
        end
    end)
    if ESPEnabled then
        wait(1)
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj and obj.Parent then obj:Destroy() end
        end
        ESPObjects[player] = nil
    end
end)

-- ========== AIMBOT FUNCTIONS ==========
function UpdateAimbotFOVCircle()
    if AimbotShowFOV and AimbotEnabled then
        if not AimbotFOVCircle then
            local circle = Instance.new("Frame")
            circle.Name = "AimbotFOV"
            circle.Size = UDim2.new(0, AimbotFOV * 2, 0, AimbotFOV * 2)
            circle.Position = UDim2.new(0.5, -AimbotFOV, 0.5, -AimbotFOV)
            circle.BackgroundTransparency = 0.9
            circle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            circle.BorderSizePixel = 2
            circle.BorderColor3 = Color3.fromRGB(255, 255, 255)
            circle.Visible = true
            
            local corner = Instance.new("UICorner", circle)
            corner.CornerRadius = UDim.new(1, 0)
            
            circle.Parent = game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer.PlayerGui
            AimbotFOVCircle = circle
        else
            AimbotFOVCircle.Size = UDim2.new(0, AimbotFOV * 2, 0, AimbotFOV * 2)
            AimbotFOVCircle.Position = UDim2.new(0.5, -AimbotFOV, 0.5, -AimbotFOV)
            AimbotFOVCircle.Visible = AimbotShowFOV and AimbotEnabled
        end
    else
        if AimbotFOVCircle then
            AimbotFOVCircle.Visible = false
        end
    end
end

function GetClosestPlayerInFOV()
    local closest = nil
    local closestDist = AimbotFOV
    local center = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimbotLockPart) then
            local part = player.Character[AimbotLockPart]
            local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
            if onScreen then
                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                local dist = (screenVec - center).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

-- Aimbot input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not AimbotEnabled then return end
    
    local isKey = false
    if AimbotKey.EnumType == Enum.KeyCode then
        isKey = input.KeyCode == AimbotKey
    elseif AimbotKey.EnumType == Enum.UserInputType then
        isKey = input.UserInputType == AimbotKey
    end
    
    if isKey then
        AimbotTarget = GetClosestPlayerInFOV()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed or not AimbotEnabled then return end
    
    local isKey = false
    if AimbotKey.EnumType == Enum.KeyCode then
        isKey = input.KeyCode == AimbotKey
    elseif AimbotKey.EnumType == Enum.UserInputType then
        isKey = input.UserInputType == AimbotKey
    end
    
    if isKey then
        AimbotTarget = nil
    end
end)

-- Aimbot camera smoothing
RunService.RenderStepped:Connect(function()
    if AimbotEnabled and AimbotTarget and AimbotTarget.Character and AimbotTarget.Character:FindFirstChild(AimbotLockPart) then
        local targetPart = AimbotTarget.Character[AimbotLockPart]
        if targetPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = targetPart.Position
            local currentCF = Camera.CFrame
            local newCF = CFrame.lookAt(currentCF.Position, targetPos)
            if AimbotSmoothness > 0 then
                Camera.CFrame = currentCF:Lerp(newCF, AimbotSmoothness)
            else
                Camera.CFrame = newCF
            end
        end
    end
end)

-- Update FOV circle when toggled
AimbotTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = true,
    Callback = function(Value)
        AimbotShowFOV = Value
        UpdateAimbotFOVCircle()
    end
})

-- Initial setup
wait(1)
UpdateESP()
UpdateAimbotFOVCircle()
ApplyLocalStats()

-- Keep FOV circle updated
coroutine.wrap(function()
    while wait(0.2) do
        if AimbotEnabled and AimbotShowFOV then
            if not AimbotFOVCircle then
                UpdateAimbotFOVCircle()
            else
                AimbotFOVCircle.Visible = true
            end
        elseif AimbotFOVCircle then
            AimbotFOVCircle.Visible = false
        end
    end
end)()
