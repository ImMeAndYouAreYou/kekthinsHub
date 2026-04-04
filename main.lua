--[ Rayfield Loader & UI Creation ]--
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Anti-Cheat & Debug Suite",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "AntiCheatDebug"
    },
    KeySystem = false, -- Disabled for internal testing
})

-- Create main tabs
local HitboxTab = Window:CreateTab("Hitbox Expander")
local ESPTab = Window:CreateTab("ESP Debugger")

--[ HITBOX EXPANDER MODULE ]--
local HitboxSection = HitboxTab:CreateSection("Hitbox Configuration")

-- Core Toggle
local HitboxEnabled = false
local HitboxSize = Vector3.new(13,13,13)
local HitboxTransparency = 0.5
local targetLimbs = {"RightUpperLeg", "LeftUpperLeg", "HeadHB", "HumanoidRootPart"}

HitboxTab:CreateToggle({
    Name = "Enable Hitbox Expansion",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(State)
        HitboxEnabled = State
        if not HitboxEnabled then
            for _, v in pairs(game.Players:GetPlayers()) do
                if v.Character then
                    for _, limb in pairs(targetLimbs) do
                        local part = v.Character:FindFirstChild(limb)
                        if part then
                            part.Size = part.Size -- Reset to original
                            part.CanCollide = true
                            part.Transparency = 0
                        end
                    end
                end
            end
        end
    end
})

-- Size Slider
local SizeSlider = HitboxTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {3, 25},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 13,
    Flag = "HitboxSize",
    Callback = function(Value)
        HitboxSize = Vector3.new(Value, Value, Value)
    end
})

-- Transparency Dropdown
local TransparencyDropdown = HitboxTab:CreateDropdown({
    Name = "Hitbox Transparency",
    Options = {"0%", "10%", "20%", "30%", "40%", "50%", "60%", "70%", "80%", "90%", "100%"},
    CurrentOption = "50%",
    Flag = "HitboxTransparency",
    Callback = function(Option)
        local numericValue = tonumber(Option:gsub("%%", "")) / 100
        HitboxTransparency = numericValue
    end
})

--[ ESP DEBUGGING MODULE ]--
local ESPEnabled = false
local TeamCheckEnabled = true
local TraceEnabled = false
local EspColor = Color3.fromRGB(255, 0, 0)
local EspTransparency = 0.5
local MaxDistance = 1000

-- Helper to get team color for ESP
local function getTeamColor(player)
    if not TeamCheckEnabled or not player.Team then return EspColor end
    return player.Team.TeamColor.Color
end

-- Function to create ESP elements
local function createESP(player)
    if not player.Character or player == game.Players.LocalPlayer then return end
    
    -- Create Highlight for Box ESP
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = player.Character
    highlight.FillTransparency = 1
    highlight.OutlineColor = getTeamColor(player)
    highlight.OutlineTransparency = EspTransparency
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = player.Character
    
    -- Create Tracer if enabled
    if TraceEnabled then
        local tracer = Instance.new("LineHandleAdornment")
        tracer.Name = "ESP_Tracer"
        tracer.Color3 = getTeamColor(player)
        tracer.Transparency = EspTransparency
        tracer.AlwaysOnTop = true
        tracer.ZIndex = 5
        tracer.Visible = false
        tracer.Parent = player.Character
    end
end

-- Function to update ESP elements
local function updateESP()
    if not ESPEnabled then return end
    
    local localPlayer = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    local localChar = localPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Distance check
            local distance = (player.Character.HumanoidRootPart.Position - localChar.HumanoidRootPart.Position).Magnitude
            if distance <= MaxDistance then
                if not player.Character:FindFirstChild("ESP_Highlight") then
                    createESP(player)
                else
                    local highlight = player.Character:FindFirstChild("ESP_Highlight")
                    highlight.OutlineColor = getTeamColor(player)
                    highlight.OutlineTransparency = EspTransparency
                end
                
                -- Update tracer if enabled
                if TraceEnabled then
                    local tracer = player.Character:FindFirstChild("ESP_Tracer")
                    if tracer then
                        tracer.Visible = true
                        local startPoint = camera.CFrame.Position
                        local endPoint = player.Character.HumanoidRootPart.Position
                        tracer.From = startPoint
                        tracer.To = endPoint
                        tracer.Color3 = getTeamColor(player)
                        tracer.Transparency = EspTransparency
                    end
                end
            else
                -- Remove if out of range
                if player.Character:FindFirstChild("ESP_Highlight") then
                    player.Character:FindFirstChild("ESP_Highlight"):Destroy()
                end
                if player.Character:FindFirstChild("ESP_Tracer") then
                    player.Character:FindFirstChild("ESP_Tracer"):Destroy()
                end
            end
        end
    end
end

-- ESP Toggle
ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(State)
        ESPEnabled = State
        if not ESPEnabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character then
                    if player.Character:FindFirstChild("ESP_Highlight") then
                        player.Character:FindFirstChild("ESP_Highlight"):Destroy()
                    end
                    if player.Character:FindFirstChild("ESP_Tracer") then
                        player.Character:FindFirstChild("ESP_Tracer"):Destroy()
                    end
                end
            end
        end
    end
})

-- Team Check Toggle
ESPTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "TeamCheckToggle",
    Callback = function(State)
        TeamCheckEnabled = State
    end
})

-- Trace Toggle
ESPTab:CreateToggle({
    Name = "Enable Tracers",
    CurrentValue = false,
    Flag = "TraceToggle",
    Callback = function(State)
        TraceEnabled = State
        if not TraceEnabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("ESP_Tracer") then
                    player.Character:FindFirstChild("ESP_Tracer"):Destroy()
                end
            end
        end
    end
})

-- ESP Color Picker
ESPTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255,0,0),
    Flag = "ESPColor",
    Callback = function(Color)
        EspColor = Color
    end
})

-- ESP Transparency Slider
ESPTab:CreateSlider({
    Name = "ESP Transparency",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.5,
    Flag = "ESPTransparency",
    Callback = function(Value)
        EspTransparency = Value
    end
})

-- Max Distance Slider
ESPTab:CreateSlider({
    Name = "Max ESP Distance",
    Range = {50, 2000},
    Increment = 50,
    Suffix = "Studs",
    CurrentValue = 1000,
    Flag = "ESPDistance",
    Callback = function(Value)
        MaxDistance = Value
    end
})

--[ MAIN LOOP EXECUTION ]--
local hitboxLoop
local espLoop

-- Hitbox modification loop
local function startHitboxLoop()
    if hitboxLoop then
        game:GetService("RunService").Heartbeat:Disconnect(hitboxLoop)
    end
    hitboxLoop = game:GetService("RunService").Heartbeat:Connect(function()
        if HitboxEnabled then
            for _, v in pairs(game.Players:GetPlayers()) do
                if v.Character then
                    for _, limb in pairs(targetLimbs) do
                        local part = v.Character:FindFirstChild(limb)
                        if part then
                            part.CanCollide = false
                            part.Transparency = HitboxTransparency
                            part.Size = HitboxSize
                        end
                    end
                end
            end
        end
    end)
end

-- ESP update loop
local function startESPLoop()
    if espLoop then
        game:GetService("RunService").RenderStepped:Disconnect(espLoop)
    end
    espLoop = game:GetService("RunService").RenderStepped:Connect(function()
        updateESP()
    end)
end

-- Start loops
startHitboxLoop()
startESPLoop()

-- Cleanup on player leave
game.Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        if player.Character:FindFirstChild("ESP_Highlight") then
            player.Character:FindFirstChild("ESP_Highlight"):Destroy()
        end
        if player.Character:FindFirstChild("ESP_Tracer") then
            player.Character:FindFirstChild("ESP_Tracer"):Destroy()
        end
    end
end)

-- Notify success
Rayfield:Notify({
    Title = "Debug Suite Loaded",
    Content = "Anti-cheat analysis tools ready.",
    Duration = 5
})
