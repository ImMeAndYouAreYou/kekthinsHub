repeat wait() until game:IsLoaded()

-- ========== SERVICES & SETUP ==========
local cloneref = cloneref or function(o) return o end
local CoreGui = cloneref(game:GetService("CoreGui"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Players = cloneref(game:GetService("Players"))
local TextService = cloneref(game:GetService("TextService"))
local HttpService = cloneref(game:GetService("HttpService"))
local Lighting = cloneref(game:GetService("Lighting"))
local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ========== GAME ID (for reference) ==========
local GameId = tostring(game.GameId)
local SupportedGames = {
    ["286090429"] = true, -- Your game
}
-- No key system – just runs for any game

-- ========== FOLDER MANAGEMENT (for configs) ==========
local Folder_Configs = {
    Directory = "CustomScriptHub",
    Configs = "CustomScriptHub/Configs",
}
for _, Folder in pairs(Folder_Configs) do
    if not isfolder(Folder) then
        makefolder(Folder)
    end
end

-- ========== CUSTOM UI LIBRARY ==========
local Library = {}
do
    local wait = task.wait
    local spawn = task.spawn
    local delay = task.delay

    local FromRGB = Color3.fromRGB
    local UDim2New = UDim2.new
    local UDimNew = UDim.new
    local Vector2New = Vector2.new

    local TableInsert = table.insert
    local StringFormat = string.format
    local InstanceNew = Instance.new

    local function SafeGetUI()
        local Success, Result = pcall(function()
            return game:GetService("CoreGui")
        end)
        return Success and Result or game:GetService("CoreGui")
    end

    Library.Theme = {
        Background = FromRGB(15, 12, 16),
        Inline = FromRGB(22, 20, 24),
        Border = FromRGB(41, 37, 45),
        Text = FromRGB(255, 255, 255),
        InactiveText = FromRGB(185, 185, 185),
        Accent = FromRGB(232, 186, 248),
        Element = FromRGB(36, 32, 39),
    }
    Library.Tween = {
        Time = 0.3,
        Style = Enum.EasingStyle.Quad,
        Direction = Enum.EasingDirection.Out
    }
    Library.Connections = {}
    Library.Threads = {}
    Library.ThemeMap = {}
    Library.ThemeItems = {}
    Library.Holder = nil
    Library.NotifHolder = nil
    Library.Font = nil

    Library.__index = Library

    -- Tween helper
    local Tween = {}
    Tween.__index = Tween
    Tween.Create = function(self, Item, Info, Goal, IsRawItem)
        Item = IsRawItem and Item or Item.Instance
        Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)
        local NewTween = {
            Tween = TweenService:Create(Item, Info, Goal),
            Info = Info,
            Goal = Goal,
            Item = Item
        }
        NewTween.Tween:Play()
        setmetatable(NewTween, Tween)
        return NewTween
    end
    Tween.Pause = function(self) if self.Tween then self.Tween:Pause() end end
    Tween.Play = function(self) if self.Tween then self.Tween:Play() end end
    Tween.Clean = function(self) if self.Tween then self:Pause() end; self = nil end

    -- Instance builder (now global so it can be used outside this block)
    Instances = {}  -- <-- FIX: removed 'local'
    Instances.__index = Instances
    Instances.Create = function(self, Class, Properties)
        local Success, Result = pcall(function()
            local NewItem = {
                Instance = InstanceNew(Class),
                Properties = Properties,
                Class = Class
            }
            setmetatable(NewItem, Instances)
            for Property, Value in pairs(Properties) do
                pcall(function() NewItem.Instance[Property] = Value end)
            end
            return NewItem
        end)
        if Success and Result then return Result end
        return { Instance = nil, Properties = Properties or {}, Class = Class, _Protected = true }
    end
    Instances.AddToTheme = function(self, Properties)
        if not self.Instance then return end
        Library:AddToTheme(self, Properties)
        return self
    end
    Instances.Connect = function(self, Event, Callback)
        if not self.Instance or not self.Instance[Event] then return end
        return Library:Connect(self.Instance[Event], Callback)
    end
    Instances.Tween = function(self, Info, Goal)
        if not self.Instance then return end
        return Tween:Create(self, Info, Goal)
    end
    Instances.Clean = function(self)
        if self.Instance then self.Instance:Destroy() end
        self = nil
    end
    Instances.MakeDraggable = function(self)
        if not self.Instance then return end
        local Gui = self.Instance
        local Dragging = false
        local DragStart, StartPosition, Changed
        self:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = Input.Position
                StartPosition = Gui.Position
                if Changed then return end
                Changed = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                        if Changed then Changed:Disconnect(); Changed = nil end
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(Input)
            if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and Dragging then
                local DragDelta = Input.Position - DragStart
                self:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = UDim2New(StartPosition.X.Scale, StartPosition.X.Offset + DragDelta.X,
                                        StartPosition.Y.Scale, StartPosition.Y.Offset + DragDelta.Y)
                })
            end
        end)
    end

    -- Font loading (optional, fallback to Gotham)
    local function LoadCustomFont()
        local FontPath = Folder_Configs.Configs .. "/InterSemibold.font"
        if not isfile(FontPath) then
            local FontData = {
                name = "InterSemibold",
                faces = { { name = "InterSemibold", weight = 400, style = "Regular", assetId = "rbxassetid://12187365364" } }
            }
            writefile(FontPath, HttpService:JSONEncode(FontData))
        end
        local Success, AssetId = pcall(getcustomasset, FontPath)
        if Success then
            return Font.new(AssetId)
        end
        return Font.fromEnum(Enum.Font.Gotham)
    end
    Library.Font = LoadCustomFont()

    -- UI creation
    Library.Holder = Instances:Create("ScreenGui", {
        Parent = SafeGetUI(),
        Name = "CustomHub",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 2,
        ResetOnSpawn = false
    })

    Library.NotifHolder = Instances:Create("Frame", {
        Parent = Library.Holder.Instance,
        Name = "Notifs",
        Size = UDim2New(0, 0, 1, 0),
        Position = UDim2New(1, 0, 0, 0),
        AnchorPoint = Vector2New(1, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.X
    })
    Instances:Create("UIListLayout", { Parent = Library.NotifHolder.Instance, SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDimNew(0, 20) })
    Instances:Create("UIPadding", { Parent = Library.NotifHolder.Instance, PaddingLeft = UDimNew(0, 12), PaddingRight = UDimNew(0, 12), PaddingTop = UDimNew(0, 12), PaddingBottom = UDimNew(0, 12) })

    Library.Thread = function(self, Func)
        local thread = coroutine.create(Func)
        coroutine.wrap(function() coroutine.resume(thread) end)()
        table.insert(self.Threads, thread)
        return thread
    end

    Library.Connect = function(self, Event, Callback)
        local conn = { Event = Event, Callback = Callback, Connection = nil }
        self:Thread(function() conn.Connection = Event:Connect(Callback) end)
        table.insert(self.Connections, conn)
        return conn
    end

    Library.AddToTheme = function(self, Item, Properties)
        Item = Item.Instance or Item
        local ThemeData = { Item = Item, Properties = Properties }
        for Property, Value in pairs(Properties) do
            if type(Value) == "string" then
                Item[Property] = self.Theme[Value] or Value
            elseif type(Value) == "function" then
                Item[Property] = Value()
            end
        end
        table.insert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

    Library.Notification = function(self, Data)
        -- Simple notification (can be expanded)
        local notif = Instances:Create("TextLabel", {
            Parent = Library.NotifHolder.Instance,
            Text = Data.Title .. "\n" .. (Data.Description or ""),
            TextColor3 = Data.Color or FromRGB(255,255,255),
            BackgroundColor3 = Library.Theme.Background,
            Size = UDim2New(0, 200, 0, 50),
            TextWrapped = true,
            FontFace = Library.Font,
            TextSize = 12,
            LayoutOrder = (Library.NotifHolder.Instance:GetChildren()[#Library.NotifHolder.Instance:GetChildren()] or { LayoutOrder = 0 }).LayoutOrder + 1
        })
        notif:Tween(TweenInfo.new(0.3), { BackgroundTransparency = 0 })
        task.wait(Data.Duration or 3)
        notif:Tween(TweenInfo.new(0.3), { BackgroundTransparency = 1 })
        task.wait(0.3)
        notif:Destroy()
    end
end

-- ========== FEATURE VARIABLES ==========
-- Hitbox
local HitboxEnabled = false
local HitboxSize = 13
local HitboxTransparency = 0.5
local HitboxColor = Color3.fromRGB(255, 0, 0)
local HitboxHeadDot = false

-- ESP
local ESPEnabled = false
local ESPObjects = {}
local ESPSettings = {
    Skeleton = false, HeadBox = false, BodyBox = false,
    Distance = false, Health = false, Name = false,
    Tracer = false, HeadDot = false
}
local ESPColors = {
    Skeleton = Color3.fromRGB(255,255,255), HeadBox = Color3.fromRGB(255,50,50),
    BodyBox = Color3.fromRGB(50,255,50), Tracer = Color3.fromRGB(255,255,255),
    Name = Color3.fromRGB(255,255,255), Health = Color3.fromRGB(255,80,80),
    Distance = Color3.fromRGB(80,200,255), HeadDot = Color3.fromRGB(255,0,0)
}

-- Aimbot
local AimbotEnabled = false
local AimbotKey = Enum.KeyCode.Q
local AimbotFOV = 200
local AimbotShowFOV = true
local AimbotSmoothness = 0.3
local AimbotTarget = nil
local AimbotFOVCircle = nil
local AimbotLockPart = "Head"

-- Local Player
local WalkSpeedValue = 16
local JumpPowerValue = 7.2
local FlyEnabled = false
local FlySpeed = 50
local FlyBodyVelocity = nil
local NoClipEnabled = false

-- ========== FEATURE FUNCTIONS ==========
function ApplyLocalStats()
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = WalkSpeedValue
            humanoid.JumpPower = JumpPowerValue
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    ApplyLocalStats()
    if FlyEnabled then ToggleFly(true) end
    if NoClipEnabled then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false) end
    end
end)

function ToggleFly(state)
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    if state then
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        FlyBodyVelocity.P = 1e5
        FlyBodyVelocity.Parent = rootPart
        humanoid.PlatformStand = true
        local flyConnection
        flyConnection = RunService.RenderStepped:Connect(function()
            if not FlyEnabled or not char or not char.Parent then
                flyConnection:Disconnect()
                if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
                if humanoid then humanoid.PlatformStand = false end
                return
            end
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
            FlyBodyVelocity.Velocity = move.Unit * FlySpeed
        end)
    else
        if FlyBodyVelocity then FlyBodyVelocity:Destroy(); FlyBodyVelocity = nil end
        if humanoid then humanoid.PlatformStand = false end
    end
end

-- Hitbox loop
coroutine.wrap(function()
    while task.wait(0.1) do
        if HitboxEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local char = player.Character
                    for _, partName in pairs({"HumanoidRootPart","Head","Torso","UpperTorso","LowerTorso","RightUpperLeg","LeftUpperLeg"}) do
                        local part = char:FindFirstChild(partName)
                        if part then
                            part.CanCollide = false
                            part.Transparency = HitboxTransparency
                            part.Color = HitboxColor
                            part.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                        end
                    end
                    if HitboxHeadDot then
                        local head = char:FindFirstChild("Head")
                        if head and not head:FindFirstChild("HeadDot") then
                            local dot = Instance.new("BillboardGui")
                            dot.Name = "HeadDot"
                            dot.Size = UDim2.new(0,10,0,10)
                            dot.AlwaysOnTop = true
                            dot.Adornee = head
                            local frame = Instance.new("Frame")
                            frame.Size = UDim2.new(1,0,1,0)
                            frame.BackgroundColor3 = Color3.fromRGB(255,0,0)
                            frame.BorderSizePixel = 0
                            frame.Parent = dot
                            dot.Parent = head
                        end
                    else
                        local head = char:FindFirstChild("Head")
                        if head and head:FindFirstChild("HeadDot") then head.HeadDot:Destroy() end
                    end
                end
            end
        end
    end
end)()

-- ESP Functions
function ClearESP()
    for player, objects in pairs(ESPObjects) do
        for _, obj in pairs(objects) do
            if obj and obj.Parent then obj:Destroy() end
        end
    end
    ESPObjects = {}
end

function CreateESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local char = player.Character
    local rootPart = char.HumanoidRootPart
    local head = char:FindFirstChild("Head")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do if obj and obj.Parent then obj:Destroy() end end
    end
    ESPObjects[player] = {}

    -- Billboard for text
    local espGui = Instance.new("BillboardGui")
    espGui.Name = "ESP_Gui"
    espGui.Size = UDim2.new(0, 250, 0, 120)
    espGui.StudsOffset = Vector3.new(0, 3, 0)
    espGui.AlwaysOnTop = true
    espGui.Adornee = rootPart
    espGui.Parent = rootPart
    table.insert(ESPObjects[player], espGui)

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1,0,1,0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = espGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1,-4,0,20)
    nameLabel.Position = UDim2.new(0,2,0,2)
    nameLabel.BackgroundTransparency = 0.7
    nameLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = ESPColors.Name
    nameLabel.TextSize = 14
    nameLabel.Font = Library.Font
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = mainFrame
    table.insert(ESPObjects[player], nameLabel)

    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "Health"
    healthLabel.Size = UDim2.new(1,-4,0,18)
    healthLabel.Position = UDim2.new(0,2,0,24)
    healthLabel.BackgroundTransparency = 0.7
    healthLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
    healthLabel.TextColor3 = ESPColors.Health
    healthLabel.TextSize = 13
    healthLabel.Font = Library.Font
    healthLabel.TextXAlignment = Enum.TextXAlignment.Left
    healthLabel.Parent = mainFrame
    table.insert(ESPObjects[player], healthLabel)

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "Distance"
    distanceLabel.Size = UDim2.new(1,-4,0,18)
    distanceLabel.Position = UDim2.new(0,2,0,44)
    distanceLabel.BackgroundTransparency = 0.7
    distanceLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
    distanceLabel.TextColor3 = ESPColors.Distance
    distanceLabel.TextSize = 13
    distanceLabel.Font = Library.Font
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    distanceLabel.Parent = mainFrame
    table.insert(ESPObjects[player], distanceLabel)

    -- Head Box
    if head then
        local headBox = Instance.new("BoxHandleAdornment")
        headBox.Name = "ESP_HeadBox"
        headBox.Size = head.Size + Vector3.new(0.2,0.2,0.2)
        headBox.Transparency = 0.6
        headBox.Color3 = ESPColors.HeadBox
        headBox.AlwaysOnTop = true
        headBox.Adornee = head
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
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if torso then
        local bodyBox = Instance.new("BoxHandleAdornment")
        bodyBox.Name = "ESP_BodyBox"
        bodyBox.Size = torso.Size + Vector3.new(0.2,0.2,0.2)
        bodyBox.Transparency = 0.6
        bodyBox.Color3 = ESPColors.BodyBox
        bodyBox.AlwaysOnTop = true
        bodyBox.Adornee = torso
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

    -- Head Dot
    if head then
        local headDot = Instance.new("BillboardGui")
        headDot.Name = "ESP_HeadDot"
        headDot.Size = UDim2.new(0,8,0,8)
        headDot.AlwaysOnTop = true
        headDot.Adornee = head
        local dotFrame = Instance.new("Frame")
        dotFrame.Size = UDim2.new(1,0,1,0)
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
    local leftArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
    local rightArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
    local leftLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
    local rightLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")
    if torso then
        createLine(torso, rootPart)
        if leftArm then createLine(torso, leftArm) end
        if rightArm then createLine(torso, rightArm) end
        if leftLeg then createLine(rootPart, leftLeg) end
        if rightLeg then createLine(rootPart, rightLeg) end
        if head then createLine(torso, head) end
    end

    -- Tracer
    local tracer = Instance.new("LineHandleAdornment")
    tracer.Name = "ESP_Tracer"
    tracer.AlwaysOnTop = true
    tracer.Thickness = 0.1
    tracer.Color3 = ESPColors.Tracer
    tracer.Transparency = 0.5
    tracer.Parent = rootPart
    table.insert(ESPObjects[player], tracer)
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

-- ESP update loop (visibility & dynamic info)
coroutine.wrap(function()
    while task.wait(0.1) do
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
                                    if ESPSettings.Distance then obj.Text = string.format("Distance: %.1f", distance) end
                                elseif obj.Name == "Health" then
                                    obj.Visible = ESPSettings.Health
                                    if ESPSettings.Health and humanoid then obj.Text = string.format("Health: %d/%d", humanoid.Health, humanoid.MaxHealth) end
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
                                        obj.PointA = Camera.CFrame.Position
                                        obj.PointB = rootPart.Position
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

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() task.wait(1); if ESPEnabled then CreateESP(player) end end)
    if ESPEnabled then task.wait(1); CreateESP(player) end
end)
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do if obj and obj.Parent then obj:Destroy() end end
        ESPObjects[player] = nil
    end
end)

-- Aimbot FOV circle
function UpdateAimbotFOVCircle()
    if AimbotShowFOV and AimbotEnabled then
        if not AimbotFOVCircle then
            local circle = Instance.new("Frame")
            circle.Name = "AimbotFOV"
            circle.Size = UDim2.new(0, AimbotFOV*2, 0, AimbotFOV*2)
            circle.Position = UDim2.new(0.5, -AimbotFOV, 0.5, -AimbotFOV)
            circle.BackgroundTransparency = 0.9
            circle.BackgroundColor3 = Color3.fromRGB(255,0,0)
            circle.BorderSizePixel = 2
            circle.BorderColor3 = Color3.fromRGB(255,255,255)
            local corner = Instance.new("UICorner", circle)
            corner.CornerRadius = UDim.new(1,0)
            circle.Parent = CoreGui
            AimbotFOVCircle = circle
        else
            AimbotFOVCircle.Size = UDim2.new(0, AimbotFOV*2, 0, AimbotFOV*2)
            AimbotFOVCircle.Position = UDim2.new(0.5, -AimbotFOV, 0.5, -AimbotFOV)
            AimbotFOVCircle.Visible = true
        end
    elseif AimbotFOVCircle then
        AimbotFOVCircle.Visible = false
    end
end

function GetClosestPlayerInFOV()
    local closest, closestDist = nil, AimbotFOV
    local center = Vector2.new(Mouse.X, Mouse.Y)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = player.Character:FindFirstChild(AimbotLockPart)
            if part then
                local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not AimbotEnabled then return end
    local pressed = (AimbotKey.EnumType == Enum.KeyCode and input.KeyCode == AimbotKey) or
                    (AimbotKey.EnumType == Enum.UserInputType and input.UserInputType == AimbotKey)
    if pressed then AimbotTarget = GetClosestPlayerInFOV() end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed or not AimbotEnabled then return end
    local released = (AimbotKey.EnumType == Enum.KeyCode and input.KeyCode == AimbotKey) or
                     (AimbotKey.EnumType == Enum.UserInputType and input.UserInputType == AimbotKey)
    if released then AimbotTarget = nil end
end)

RunService.RenderStepped:Connect(function()
    if AimbotEnabled and AimbotTarget and AimbotTarget.Character then
        local targetPart = AimbotTarget.Character:FindFirstChild(AimbotLockPart)
        if targetPart and LocalPlayer.Character then
            local newCF = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
            if AimbotSmoothness > 0 then
                Camera.CFrame = Camera.CFrame:Lerp(newCF, AimbotSmoothness)
            else
                Camera.CFrame = newCF
            end
        end
    end
end)

-- ========== UI CREATION ==========
local MainWindow = Instances:Create("Frame", {
    Parent = Library.Holder.Instance,
    Name = "MainWindow",
    Size = UDim2.new(0, 520, 0, 420),
    Position = UDim2.new(0.5, -260, 0.5, -210),
    BackgroundColor3 = Library.Theme.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ClipsDescendants = true
}):AddToTheme({ BackgroundColor3 = "Background" })
Instances:Create("UICorner", { Parent = MainWindow.Instance, CornerRadius = UDim.new(0, 8) })
Instances:Create("UIStroke", { Parent = MainWindow.Instance, Color = Library.Theme.Border, Thickness = 1, Transparency = 0.8 }):AddToTheme({ Color = "Border" })

-- Title bar
local TitleBar = Instances:Create("Frame", {
    Parent = MainWindow.Instance,
    Size = UDim2.new(1, 0, 0, 35),
    BackgroundColor3 = Library.Theme.Inline,
    BackgroundTransparency = 0.1
}):AddToTheme({ BackgroundColor3 = "Inline" })
Instances:Create("UICorner", { Parent = TitleBar.Instance, CornerRadius = UDim.new(0, 8) })
local TitleText = Instances:Create("TextLabel", {
    Parent = TitleBar.Instance,
    Size = UDim2.new(1, -40, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "Custom Script Hub",
    TextColor3 = Library.Theme.Text,
    TextSize = 16,
    FontFace = Library.Font,
    TextXAlignment = Enum.TextXAlignment.Left
}):AddToTheme({ TextColor3 = "Text" })
local CloseBtn = Instances:Create("TextButton", {
    Parent = TitleBar.Instance,
    Size = UDim2.new(0, 30, 1, 0),
    Position = UDim2.new(1, -30, 0, 0),
    BackgroundColor3 = Library.Theme.Element,
    Text = "X",
    TextColor3 = Library.Theme.Text,
    TextSize = 14,
    FontFace = Library.Font
}):AddToTheme({ BackgroundColor3 = "Element", TextColor3 = "Text" })
CloseBtn:Connect("MouseButton1Click", function() Library.Holder:Clean() end)

-- Tab container
local TabContainer = Instances:Create("Frame", {
    Parent = MainWindow.Instance,
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 35),
    BackgroundTransparency = 1
})
local ContentFrame = Instances:Create("Frame", {
    Parent = MainWindow.Instance,
    Size = UDim2.new(1, -20, 1, -85),
    Position = UDim2.new(0, 10, 0, 80),
    BackgroundTransparency = 1
})
local ScrollFrame = Instances:Create("ScrollingFrame", {
    Parent = ContentFrame.Instance,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 6
})
local UIList = Instances:Create("UIListLayout", { Parent = ScrollFrame.Instance, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })

local Tabs = {}
local function AddTab(name)
    local btn = Instances:Create("TextButton", {
        Parent = TabContainer.Instance,
        Size = UDim2.new(0, 100, 1, -6),
        Position = UDim2.new(#Tabs * 0.19 + 0.02, 0, 0, 3),
        BackgroundColor3 = Library.Theme.Element,
        Text = name,
        TextColor3 = Library.Theme.Text,
        TextSize = 14,
        FontFace = Library.Font
    }):AddToTheme({ BackgroundColor3 = "Element", TextColor3 = "Text" })
    Instances:Create("UICorner", { Parent = btn.Instance, CornerRadius = UDim.new(0, 4) })
    local content = Instances:Create("Frame", {
        Parent = ScrollFrame.Instance,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false
    })
    local list = Instances:Create("UIListLayout", { Parent = content.Instance, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
    table.insert(Tabs, { btn = btn, content = content })
    btn:Connect("MouseButton1Click", function()
        for _, t in pairs(Tabs) do
            t.content.Instance.Visible = false
            t.btn.Instance.BackgroundColor3 = Library.Theme.Element
        end
        content.Instance.Visible = true
        btn.Instance.BackgroundColor3 = Library.Theme.Accent
        -- Update canvas height
        local total = 0
        for _, child in pairs(content.Instance:GetChildren()) do
            if child:IsA("Frame") then
                total = total + child.Size.Y.Offset + list.Padding.Offset
            end
        end
        ScrollFrame.Instance.CanvasSize = UDim2.new(0, 0, 0, total)
    end)
    if #Tabs == 1 then btn:Connect("MouseButton1Click")() end
    return content
end

-- Helper functions to add UI elements
local function AddToggle(parent, name, default, callback)
    local frame = Instances:Create("Frame", { Parent = parent.Instance, Size = UDim2.new(1, -10, 0, 36), BackgroundColor3 = Library.Theme.Element, BackgroundTransparency = 0.2 }):AddToTheme({ BackgroundColor3 = "Element" })
    Instances:Create("UICorner", { Parent = frame.Instance, CornerRadius = UDim.new(0, 4) })
    local label = Instances:Create("TextLabel", { Parent = frame.Instance, Size = UDim2.new(0.7, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.Text, TextSize = 14, FontFace = Library.Font, TextXAlignment = Enum.TextXAlignment.Left }):AddToTheme({ TextColor3 = "Text" })
    local btn = Instances:Create("TextButton", { Parent = frame.Instance, Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(1, -70, 0.5, -13), BackgroundColor3 = default and Color3.fromRGB(0,200,0) or Color3.fromRGB(80,80,80), Text = default and "ON" or "OFF", TextColor3 = Color3.fromRGB(255,255,255), TextSize = 12, FontFace = Library.Font })
    Instances:Create("UICorner", { Parent = btn.Instance, CornerRadius = UDim.new(0, 4) })
    local state = default
    btn:Connect("MouseButton1Click", function()
        state = not state
        btn.Instance.BackgroundColor3 = state and Color3.fromRGB(0,200,0) or Color3.fromRGB(80,80,80)
        btn.Instance.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end)
    return frame
end

local function AddSlider(parent, name, min, max, default, suffix, callback)
    local frame = Instances:Create("Frame", { Parent = parent.Instance, Size = UDim2.new(1, -10, 0, 55), BackgroundColor3 = Library.Theme.Element, BackgroundTransparency = 0.2 }):AddToTheme({ BackgroundColor3 = "Element" })
    Instances:Create("UICorner", { Parent = frame.Instance, CornerRadius = UDim.new(0, 4) })
    local label = Instances:Create("TextLabel", { Parent = frame.Instance, Size = UDim2.new(1, -10, 0, 22), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = name .. ": " .. tostring(default) .. suffix, TextColor3 = Library.Theme.Text, TextSize = 13, FontFace = Library.Font, TextXAlignment = Enum.TextXAlignment.Left }):AddToTheme({ TextColor3 = "Text" })
    local slider = Instances:Create("Frame", { Parent = frame.Instance, Size = UDim2.new(0.9, 0, 0, 4), Position = UDim2.new(0.05, 0, 0.7, 0), BackgroundColor3 = Color3.fromRGB(70,70,75), BorderSizePixel = 0 })
    local fill = Instances:Create("Frame", { Parent = slider.Instance, Size = UDim2.new((default-min)/(max-min), 0, 1, 0), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0 }):AddToTheme({ BackgroundColor3 = "Accent" })
    local value = default
    local dragging = false
    local function update(x)
        local rel = math.clamp((x - slider.Instance.AbsolutePosition.X) / slider.Instance.AbsoluteSize.X, 0, 1)
        value = min + (max-min)*rel
        value = math.floor(value * 100) / 100
        fill.Instance.Size = UDim2.new(rel, 0, 1, 0)
        label.Instance.Text = name .. ": " .. tostring(value) .. suffix
        if callback then callback(value) end
    end
    slider:Connect("InputBegan", function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input.Position.X) end
    end)
    return frame
end

local function AddColorPicker(parent, name, defaultColor, callback)
    local frame = Instances:Create("Frame", { Parent = parent.Instance, Size = UDim2.new(1, -10, 0, 42), BackgroundColor3 = Library.Theme.Element, BackgroundTransparency = 0.2 }):AddToTheme({ BackgroundColor3 = "Element" })
    Instances:Create("UICorner", { Parent = frame.Instance, CornerRadius = UDim.new(0, 4) })
    local label = Instances:Create("TextLabel", { Parent = frame.Instance, Size = UDim2.new(0.6, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.Text, TextSize = 13, FontFace = Library.Font, TextXAlignment = Enum.TextXAlignment.Left }):AddToTheme({ TextColor3 = "Text" })
    local colorDisplay = Instances:Create("Frame", { Parent = frame.Instance, Size = UDim2.new(0, 50, 0, 26), Position = UDim2.new(1, -60, 0.5, -13), BackgroundColor3 = defaultColor, BorderSizePixel = 1, BorderColor3 = Color3.fromRGB(255,255,255) })
    Instances:Create("UICorner", { Parent = colorDisplay.Instance, CornerRadius = UDim.new(0, 4) })
    local colors = {Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255), Color3.fromRGB(255,255,0), Color3.fromRGB(255,0,255), Color3.fromRGB(0,255,255)}
    local idx = 1
    colorDisplay:Connect("MouseButton1Click", function()
        idx = idx % #colors + 1
        local newColor = colors[idx]
        colorDisplay.Instance.BackgroundColor3 = newColor
        if callback then callback(newColor) end
    end)
    return frame
end

local function AddDropdown(parent, name, options, default, callback)
    local frame = Instances:Create("Frame", { Parent = parent.Instance, Size = UDim2.new(1, -10, 0, 42), BackgroundColor3 = Library.Theme.Element, BackgroundTransparency = 0.2 }):AddToTheme({ BackgroundColor3 = "Element" })
    Instances:Create("UICorner", { Parent = frame.Instance, CornerRadius = UDim.new(0, 4) })
    local label = Instances:Create("TextLabel", { Parent = frame.Instance, Size = UDim2.new(0.4, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.Text, TextSize = 13, FontFace = Library.Font, TextXAlignment = Enum.TextXAlignment.Left }):AddToTheme({ TextColor3 = "Text" })
    local btn = Instances:Create("TextButton", { Parent = frame.Instance, Size = UDim2.new(0, 120, 0, 28), Position = UDim2.new(1, -130, 0.5, -14), BackgroundColor3 = Library.Theme.Inline, Text = default, TextColor3 = Library.Theme.Text, TextSize = 12, FontFace = Library.Font }):AddToTheme({ BackgroundColor3 = "Inline", TextColor3 = "Text" })
    Instances:Create("UICorner", { Parent = btn.Instance, CornerRadius = UDim.new(0, 4) })
    local isOpen = false
    local optionList = nil
    btn:Connect("MouseButton1Click", function()
        if isOpen then if optionList then optionList:Destroy() end isOpen = false return end
        optionList = Instances:Create("Frame", { Parent = frame.Instance, Size = UDim2.new(0, 120, 0, #options * 28), Position = UDim2.new(1, -130, 0, 30), BackgroundColor3 = Library.Theme.Element, BorderSizePixel = 0 }):AddToTheme({ BackgroundColor3 = "Element" })
        Instances:Create("UICorner", { Parent = optionList.Instance, CornerRadius = UDim.new(0, 4) })
        local layout = Instances:Create("UIListLayout", { Parent = optionList.Instance, Padding = UDim.new(0, 2) })
        for _, opt in ipairs(options) do
            local optBtn = Instances:Create("TextButton", { Parent = optionList.Instance, Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = Library.Theme.Inline, Text = opt, TextColor3 = Library.Theme.Text, TextSize = 12, FontFace = Library.Font }):AddToTheme({ BackgroundColor3 = "Inline", TextColor3 = "Text" })
            optBtn:Connect("MouseButton1Click", function()
                btn.Instance.Text = opt
                if callback then callback(opt) end
                optionList:Destroy()
                isOpen = false
            end)
        end
        isOpen = true
    end)
    return frame
end

-- Build Tabs
local hitboxTab = AddTab("Hitbox Extender")
AddToggle(hitboxTab, "Enable Hitbox", false, function(v) HitboxEnabled = v end)
AddSlider(hitboxTab, "Hitbox Size", 1, 50, 13, " studs", function(v) HitboxSize = v end)
AddSlider(hitboxTab, "Hitbox Transparency", 0, 1, 0.5, "", function(v) HitboxTransparency = v end)
AddColorPicker(hitboxTab, "Hitbox Color", HitboxColor, function(c) HitboxColor = c end)
AddToggle(hitboxTab, "Head Dot (ESP style)", false, function(v) HitboxHeadDot = v end)

local espTab = AddTab("ESP")
AddToggle(espTab, "Enable ESP", false, function(v) ESPEnabled = v; if not v then ClearESP() else UpdateESP() end end)
AddToggle(espTab, "Skeleton", false, function(v) ESPSettings.Skeleton = v; UpdateESP() end)
AddToggle(espTab, "Head Box", false, function(v) ESPSettings.HeadBox = v; UpdateESP() end)
AddToggle(espTab, "Body Box", false, function(v) ESPSettings.BodyBox = v; UpdateESP() end)
AddToggle(espTab, "Name", false, function(v) ESPSettings.Name = v; UpdateESP() end)
AddToggle(espTab, "Health", false, function(v) ESPSettings.Health = v; UpdateESP() end)
AddToggle(espTab, "Distance", false, function(v) ESPSettings.Distance = v; UpdateESP() end)
AddToggle(espTab, "Tracer", false, function(v) ESPSettings.Tracer = v; UpdateESP() end)
AddToggle(espTab, "Head Dot", false, function(v) ESPSettings.HeadDot = v; UpdateESP() end)
AddColorPicker(espTab, "Skeleton Color", ESPColors.Skeleton, function(c) ESPColors.Skeleton = c; UpdateESP() end)
AddColorPicker(espTab, "Head Box Color", ESPColors.HeadBox, function(c) ESPColors.HeadBox = c; UpdateESP() end)
AddColorPicker(espTab, "Body Box Color", ESPColors.BodyBox, function(c) ESPColors.BodyBox = c; UpdateESP() end)
AddColorPicker(espTab, "Tracer Color", ESPColors.Tracer, function(c) ESPColors.Tracer = c; UpdateESP() end)

local aimbotTab = AddTab("Aimbot")
AddToggle(aimbotTab, "Enable Aimbot", false, function(v) AimbotEnabled = v; if not v then AimbotTarget = nil end; UpdateAimbotFOVCircle() end)
AddDropdown(aimbotTab, "Aimbot Key", {"Q","E","LeftShift","Tab","RightMouseButton","X","C","F"}, "Q", function(opt)
    local map = {Q=Enum.KeyCode.Q, E=Enum.KeyCode.E, LeftShift=Enum.KeyCode.LeftShift, Tab=Enum.KeyCode.Tab,
                 RightMouseButton=Enum.UserInputType.MouseButton2, X=Enum.KeyCode.X, C=Enum.KeyCode.C, F=Enum.KeyCode.F}
    AimbotKey = map[opt]
end)
AddDropdown(aimbotTab, "Lock Part", {"Head","Torso"}, "Head", function(opt) AimbotLockPart = opt end)
AddSlider(aimbotTab, "FOV Radius", 50, 500, 200, " px", function(v) AimbotFOV = v; UpdateAimbotFOVCircle() end)
AddToggle(aimbotTab, "Show FOV Circle", true, function(v) AimbotShowFOV = v; UpdateAimbotFOVCircle() end)
AddSlider(aimbotTab, "Smoothness", 0, 1, 0.3, "", function(v) AimbotSmoothness = v end)

local localTab = AddTab("Local Player")
AddSlider(localTab, "Walk Speed", 16, 100, 16, " studs/s", function(v) WalkSpeedValue = v; ApplyLocalStats() end)
AddSlider(localTab, "Jump Power", 7.2, 100, 7.2, "", function(v) JumpPowerValue = v; ApplyLocalStats() end)
AddToggle(localTab, "Fly", false, function(v) FlyEnabled = v; ToggleFly(v) end)
AddSlider(localTab, "Fly Speed", 20, 200, 50, " studs/s", function(v) FlySpeed = v; if FlyEnabled then ToggleFly(true) end end)
AddToggle(localTab, "No Clip", false, function(v)
    NoClipEnabled = v
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, not v) end
    end
end)

-- Make window draggable
MainWindow:MakeDraggable()

-- Initialize
task.wait(1)
ApplyLocalStats()
UpdateESP()
UpdateAimbotFOVCircle()
