-- ==================== LUARMOR KEY SYSTEM (OPTIONAL) ====================
-- Load Luarmor key checker
local luarmor = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
-- Uncomment and configure if you have a Luarmor account:
-- luarmor:SetScriptId("YOUR_SCRIPT_ID")  -- Get from Luarmor dashboard
-- local key = "USER_INPUT_KEY"  -- You'd get this from a TextBox
-- local isValid, message = luarmor:CheckKey(key)
-- if not isValid then return end  -- Key invalid, stop script

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ==================== VARIABLES ====================
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

-- ==================== CUSTOM UI CREATION ====================
local function CreateCustomUI()
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomScriptHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    -- Main Window Frame (draggable)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Corner rounding
    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 8)
    
    -- Title Bar (for dragging)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    titleBar.BackgroundTransparency = 0.05
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    local titleCorner = Instance.new("UICorner", titleBar)
    titleCorner.CornerRadius = UDim.new(0, 8)
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Script Hub (Drag me)"
    titleText.TextColor3 = Color3.fromRGB(255,255,255)
    titleText.TextSize = 16
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 1, 0)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Tab buttons container
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.Position = UDim2.new(0, 0, 0, 30)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    -- Content container (changes based on tab)
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -80)
    contentFrame.Position = UDim2.new(0, 10, 0, 75)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Scrolling frame inside content (for options)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = contentFrame
    
    local uiList = Instance.new("UIListLayout")
    uiList.Padding = UDim.new(0, 8)
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Parent = scrollFrame
    
    -- Tab data
    local tabs = {}
    local currentTab = nil
    
    -- Helper: create a toggle
    local function CreateToggle(parent, name, defaultValue, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 35)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Parent = parent
        local fCorner = Instance.new("UICorner", frame)
        fCorner.CornerRadius = UDim.new(0, 4)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, -10, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(220,220,220)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 60, 0, 25)
        toggleBtn.Position = UDim2.new(1, -70, 0.5, -12.5)
        toggleBtn.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(80,80,80)
        toggleBtn.Text = defaultValue and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
        toggleBtn.TextSize = 12
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.BorderSizePixel = 0
        toggleBtn.Parent = frame
        local btnCorner = Instance.new("UICorner", toggleBtn)
        btnCorner.CornerRadius = UDim.new(0, 4)
        
        local state = defaultValue
        toggleBtn.MouseButton1Click:Connect(function()
            state = not state
            toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0,200,0) or Color3.fromRGB(80,80,80)
            toggleBtn.Text = state and "ON" or "OFF"
            if callback then callback(state) end
        end)
        
        return frame
    end
    
    -- Helper: create slider
    local function CreateSlider(parent, name, min, max, default, suffix, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 55)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Parent = parent
        local fCorner = Instance.new("UICorner", frame)
        fCorner.CornerRadius = UDim.new(0, 4)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. tostring(default) .. suffix
        label.TextColor3 = Color3.fromRGB(220,220,220)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0.9, 0, 0, 4)
        slider.Position = UDim2.new(0.05, 0, 0.7, 0)
        slider.BackgroundColor3 = Color3.fromRGB(70,70,75)
        slider.BorderSizePixel = 0
        slider.Parent = frame
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        fill.BorderSizePixel = 0
        fill.Parent = slider
        
        local value = default
        local dragging = false
        local function updateSlider(x)
            local relative = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * relative
            value = math.floor(value * 100) / 100
            fill.Size = UDim2.new(relative, 0, 1, 0)
            label.Text = name .. ": " .. tostring(value) .. suffix
            if callback then callback(value) end
        end
        
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input.Position.X)
            end
        end)
        
        return frame
    end
    
    -- Helper: create color picker (simplified)
    local function CreateColorPicker(parent, name, defaultColor, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 40)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Parent = parent
        local fCorner = Instance.new("UICorner", frame)
        fCorner.CornerRadius = UDim.new(0, 4)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, -10, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(220,220,220)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local colorDisplay = Instance.new("Frame")
        colorDisplay.Size = UDim2.new(0, 50, 0, 25)
        colorDisplay.Position = UDim2.new(1, -60, 0.5, -12.5)
        colorDisplay.BackgroundColor3 = defaultColor
        colorDisplay.BorderSizePixel = 1
        colorDisplay.BorderColor3 = Color3.fromRGB(255,255,255)
        colorDisplay.Parent = frame
        local dispCorner = Instance.new("UICorner", colorDisplay)
        dispCorner.CornerRadius = UDim.new(0, 4)
        
        -- Simple color cycling for demo (you can expand)
        local colors = {Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255), Color3.fromRGB(255,255,0)}
        local colorIndex = 1
        colorDisplay.MouseButton1Click:Connect(function()
            colorIndex = colorIndex % #colors + 1
            local newColor = colors[colorIndex]
            colorDisplay.BackgroundColor3 = newColor
            if callback then callback(newColor) end
        end)
        
        return frame
    end
    
    -- Helper: create dropdown
    local function CreateDropdown(parent, name, options, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 40)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Parent = parent
        local fCorner = Instance.new("UICorner", frame)
        fCorner.CornerRadius = UDim.new(0, 4)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, -10, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(220,220,220)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local dropdownBtn = Instance.new("TextButton")
        dropdownBtn.Size = UDim2.new(0, 120, 0, 25)
        dropdownBtn.Position = UDim2.new(1, -130, 0.5, -12.5)
        dropdownBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
        dropdownBtn.Text = default
        dropdownBtn.TextColor3 = Color3.fromRGB(255,255,255)
        dropdownBtn.TextSize = 12
        dropdownBtn.Font = Enum.Font.Gotham
        dropdownBtn.BorderSizePixel = 0
        dropdownBtn.Parent = frame
        local btnCorner = Instance.new("UICorner", dropdownBtn)
        btnCorner.CornerRadius = UDim.new(0, 4)
        
        local isOpen = false
        local optionList = nil
        dropdownBtn.MouseButton1Click:Connect(function()
            if isOpen then
                if optionList then optionList:Destroy() end
                isOpen = false
                return
            end
            optionList = Instance.new("Frame")
            optionList.Size = UDim2.new(0, 120, 0, #options * 25)
            optionList.Position = UDim2.new(1, -130, 0, 30)
            optionList.BackgroundColor3 = Color3.fromRGB(50,50,55)
            optionList.BorderSizePixel = 0
            optionList.Parent = frame
            local listCorner = Instance.new("UICorner", optionList)
            listCorner.CornerRadius = UDim.new(0, 4)
            local listLayout = Instance.new("UIListLayout", optionList)
            listLayout.Padding = UDim.new(0, 2)
            
            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 25)
                optBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
                optBtn.Text = opt
                optBtn.TextColor3 = Color3.fromRGB(255,255,255)
                optBtn.TextSize = 12
                optBtn.Font = Enum.Font.Gotham
                optBtn.BorderSizePixel = 0
                optBtn.Parent = optionList
                optBtn.MouseButton1Click:Connect(function()
                    dropdownBtn.Text = opt
                    if callback then callback(opt) end
                    optionList:Destroy()
                    isOpen = false
                end)
            end
            isOpen = true
        end)
        
        return frame
    end
    
    -- Tab creation function
    local function AddTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 1, -5)
        btn.Position = UDim2.new(#tabs * 0.2, 5, 0, 2.5)
        btn.BackgroundColor3 = Color3.fromRGB(60,60,70)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = tabContainer
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 4)
        
        local contentList = Instance.new("Frame")
        contentList.Size = UDim2.new(1, 0, 1, 0)
        contentList.BackgroundTransparency = 1
        contentList.Visible = false
        contentList.Parent = scrollFrame
        local listLayout = Instance.new("UIListLayout", contentList)
        listLayout.Padding = UDim.new(0, 5)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local tab = {button = btn, content = contentList}
        table.insert(tabs, tab)
        
        btn.MouseButton1Click:Connect(function()
            for _, t in ipairs(tabs) do
                t.content.Visible = false
                t.button.BackgroundColor3 = Color3.fromRGB(60,60,70)
            end
            contentList.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
            currentTab = tab
            -- Update canvas size
            local totalHeight = 0
            for _, child in ipairs(contentList:GetChildren()) do
                if child:IsA("Frame") then
                    totalHeight = totalHeight + child.Size.Y.Offset + listLayout.Padding.Offset
                end
            end
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        end)
        
        if #tabs == 1 then btn.MouseButton1Click:Fire() end
        return contentList
    end
    
    -- ========== BUILD TABS ==========
    -- Hitbox Tab
    local hitboxTab = AddTab("Hitbox")
    CreateToggle(hitboxTab, "Enable Hitbox", false, function(v) HitboxEnabled = v end)
    CreateSlider(hitboxTab, "Hitbox Size", 1, 50, 13, " studs", function(v) HitboxSize = v end)
    CreateSlider(hitboxTab, "Hitbox Transparency", 0, 1, 0.5, "", function(v) HitboxTransparency = v end)
    CreateColorPicker(hitboxTab, "Hitbox Color", HitboxColor, function(c) HitboxColor = c end)
    CreateToggle(hitboxTab, "Head Dot (ESP style)", false, function(v) HitboxHeadDot = v end)
    
    -- ESP Tab
    local espTab = AddTab("ESP")
    CreateToggle(espTab, "Enable ESP", false, function(v) ESPEnabled = v; if not v then ClearESP() else UpdateESP() end end)
    CreateToggle(espTab, "Skeleton", false, function(v) ESPSettings.Skeleton = v; UpdateESP() end)
    CreateToggle(espTab, "Head Box", false, function(v) ESPSettings.HeadBox = v; UpdateESP() end)
    CreateToggle(espTab, "Body Box", false, function(v) ESPSettings.BodyBox = v; UpdateESP() end)
    CreateToggle(espTab, "Name", false, function(v) ESPSettings.Name = v; UpdateESP() end)
    CreateToggle(espTab, "Health", false, function(v) ESPSettings.Health = v; UpdateESP() end)
    CreateToggle(espTab, "Distance", false, function(v) ESPSettings.Distance = v; UpdateESP() end)
    CreateToggle(espTab, "Tracer", false, function(v) ESPSettings.Tracer = v; UpdateESP() end)
    CreateToggle(espTab, "Head Dot", false, function(v) ESPSettings.HeadDot = v; UpdateESP() end)
    CreateColorPicker(espTab, "Skeleton Color", ESPColors.Skeleton, function(c) ESPColors.Skeleton = c; UpdateESP() end)
    CreateColorPicker(espTab, "Head Box Color", ESPColors.HeadBox, function(c) ESPColors.HeadBox = c; UpdateESP() end)
    CreateColorPicker(espTab, "Body Box Color", ESPColors.BodyBox, function(c) ESPColors.BodyBox = c; UpdateESP() end)
    CreateColorPicker(espTab, "Tracer Color", ESPColors.Tracer, function(c) ESPColors.Tracer = c; UpdateESP() end)
    
    -- Aimbot Tab
    local aimbotTab = AddTab("Aimbot")
    CreateToggle(aimbotTab, "Enable Aimbot", false, function(v) AimbotEnabled = v; if not v then AimbotTarget = nil end; UpdateAimbotFOVCircle() end)
    CreateDropdown(aimbotTab, "Aimbot Key", {"Q","E","LeftShift","Tab","RightMouseButton","X","C","F"}, "Q", function(opt)
        local map = {Q=Enum.KeyCode.Q, E=Enum.KeyCode.E, LeftShift=Enum.KeyCode.LeftShift, Tab=Enum.KeyCode.Tab,
                     RightMouseButton=Enum.UserInputType.MouseButton2, X=Enum.KeyCode.X, C=Enum.KeyCode.C, F=Enum.KeyCode.F}
        AimbotKey = map[opt]
    end)
    CreateDropdown(aimbotTab, "Lock Part", {"Head","Torso"}, "Head", function(opt) AimbotLockPart = opt end)
    CreateSlider(aimbotTab, "FOV Radius", 50, 500, 200, " px", function(v) AimbotFOV = v; UpdateAimbotFOVCircle() end)
    CreateToggle(aimbotTab, "Show FOV Circle", true, function(v) AimbotShowFOV = v; UpdateAimbotFOVCircle() end)
    CreateSlider(aimbotTab, "Smoothness", 0, 1, 0.3, "", function(v) AimbotSmoothness = v end)
    
    -- Local Player Tab
    local localTab = AddTab("Local Player")
    CreateSlider(localTab, "Walk Speed", 16, 100, 16, " studs/s", function(v) WalkSpeedValue = v; ApplyLocalStats() end)
    CreateSlider(localTab, "Jump Power", 7.2, 100, 7.2, "", function(v) JumpPowerValue = v; ApplyLocalStats() end)
    CreateToggle(localTab, "Fly", false, function(v) FlyEnabled = v; ToggleFly(v) end)
    CreateSlider(localTab, "Fly Speed", 20, 200, 50, " studs/s", function(v) FlySpeed = v; if FlyEnabled then ToggleFly(true) end end)
    CreateToggle(localTab, "No Clip", false, function(v)
        NoClipEnabled = v
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, not v) end
        end
    end)
    
    -- Dragging logic
    local dragging = false
    local dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Create the UI
CreateCustomUI()

-- ==================== FEATURE FUNCTIONS (same as before, but with corrected variable names) ====================
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
    wait(0.5)
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

-- Hitbox Loop
coroutine.wrap(function()
    while wait(0.1) do
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

-- ESP Functions (keep original, but ensure they reference ESPSettings)
function ClearESP()
    for player, objects in pairs(ESPObjects) do
        for _, obj in pairs(objects) do
            if obj and obj.Parent then obj:Destroy() end
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
    espGui.Size = UDim2.new(0, 250, 0, 120)
    espGui.StudsOffset = Vector3.new(0, 3.5, 0)
    espGui.AlwaysOnTop = true
    espGui.Adornee = rootPart
    espGui.Parent = rootPart
    
    local espFrame = Instance.new("Frame")
    espFrame.Size = UDim2.new(1, 0, 1, 0)
    espFrame.BackgroundTransparency = 1
    espFrame.Parent = espGui
    
    table.insert(ESPObjects[player], espGui)
    
    -- Name Label (Improved styling)
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, -4, 0, 22)
    nameLabel.Position = UDim2.new(0, 2, 0, 2)
    nameLabel.BackgroundTransparency = 0.8
    nameLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.BorderSizePixel = 0
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 16
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = espFrame
    table.insert(ESPObjects[player], nameLabel)
    
    -- Health Label (Improved styling)
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "Health"
    healthLabel.Size = UDim2.new(1, -4, 0, 18)
    healthLabel.Position = UDim2.new(0, 2, 0, 26)
    healthLabel.BackgroundTransparency = 0.8
    healthLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    healthLabel.BorderSizePixel = 0
    healthLabel.Text = ""
    healthLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    healthLabel.TextSize = 14
    healthLabel.TextStrokeTransparency = 0.5
    healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.TextXAlignment = Enum.TextXAlignment.Left
    healthLabel.Parent = espFrame
    table.insert(ESPObjects[player], healthLabel)
    
    -- Distance Label (Improved styling)
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "Distance"
    distanceLabel.Size = UDim2.new(1, -4, 0, 18)
    distanceLabel.Position = UDim2.new(0, 2, 0, 46)
    distanceLabel.BackgroundTransparency = 0.8
    distanceLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.BorderSizePixel = 0
    distanceLabel.Text = ""
    distanceLabel.TextColor3 = Color3.fromRGB(80, 200, 255)
    distanceLabel.TextSize = 14
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    distanceLabel.Parent = espFrame
    table.insert(ESPObjects[player], distanceLabel)
    
    -- Head Box (Improved styling)
    if head then
        local headBox = Instance.new("BoxHandleAdornment")
        headBox.Name = "ESP_Head"
        headBox.Size = head.Size + Vector3.new(0.1, 0.1, 0.1)
        headBox.Transparency = 0.7
        headBox.Color3 = Color3.fromRGB(255, 50, 50)
        headBox.AlwaysOnTop = true
        headBox.Adornee = head
        headBox.ZIndex = 2
        headBox.Parent = head
        table.insert(ESPObjects[player], headBox)
        
        -- Head outline
        local headOutline = Instance.new("SelectionBox")
        headOutline.Name = "ESP_Head_Outline"
        headOutline.Adornee = head
        headOutline.Transparency = 0.8
        headOutline.Color3 = Color3.fromRGB(255, 0, 0)
        headOutline.Thickness = 0.15
        headOutline.Parent = head
        table.insert(ESPObjects[player], headOutline)
    end
    
    -- Body Box (Torso) (Improved styling)
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if torso then
        local bodyBox = Instance.new("BoxHandleAdornment")
        bodyBox.Name = "ESP_Body"
        bodyBox.Size = torso.Size + Vector3.new(0.1, 0.1, 0.1)
        bodyBox.Transparency = 0.7
        bodyBox.Color3 = Color3.fromRGB(50, 255, 50)
        bodyBox.AlwaysOnTop = true
        bodyBox.Adornee = torso
        bodyBox.ZIndex = 2
        bodyBox.Parent = torso
        table.insert(ESPObjects[player], bodyBox)
        
        -- Body outline
        local bodyOutline = Instance.new("SelectionBox")
        bodyOutline.Name = "ESP_Body_Outline"
        bodyOutline.Adornee = torso
        bodyOutline.Transparency = 0.8
        bodyOutline.Color3 = Color3.fromRGB(0, 255, 0)
        bodyOutline.Thickness = 0.15
        bodyOutline.Parent = torso
        table.insert(ESPObjects[player], bodyOutline)
    end
    
    -- Skeleton Lines
    local function createLine(part1, part2)
        local attachment1 = Instance.new("Attachment")
        attachment1.Parent = part1
        
        local attachment2 = Instance.new("Attachment")
        attachment2.Parent = part2
        
        local line = Instance.new("Beam")
        line.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        line.Transparency = NumberSequence.new(0.4)
        line.Width0 = 0.15
        line.Width1 = 0.15
        line.LightEmission = 0.3
        line.LightInfluence = 0.5
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

function UpdateESP()
    ClearESP()
    if not ESPEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then CreateESP(player) end
    end
end

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
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)
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
                    if dist < closestDist then closest, closestDist = player, dist end
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

-- Initialization
wait(1)
ApplyLocalStats()
UpdateESP()
UpdateAimbotFOVCircle()
