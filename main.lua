local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local BOOTER = {
    enabled = false,
    mode = "Balanced",
    originalLighting = {},
    originalEffects = {},
    originalParts = {},
    originalVisuals = {}
}

local function safeCall(func)
    local success, result = pcall(func)
    if not success then
        return false, result
    end
    return true, result
end

local function captureOriginals()
    BOOTER.originalLighting = {
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Ambient = Lighting.Ambient,
        ExposureCompensation = Lighting.ExposureCompensation
    }

    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("Atmosphere") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or
           effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect") or
           effect:IsA("Sky") or effect:IsA("PostEffect") then
            BOOTER.originalEffects[effect] = effect.Enabled
        end
    end

    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("BasePart") then
            table.insert(BOOTER.originalParts, {
                obj = descendant,
                material = descendant.Material,
                reflectance = descendant.Reflectance,
                castShadow = descendant.CastShadow,
                transparency = descendant.Transparency,
            })
        elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Smoke") or
               descendant:IsA("Fire") or descendant:IsA("Sparkles") or descendant:IsA("Beam") then
            table.insert(BOOTER.originalVisuals, {
                obj = descendant,
                enabled = descendant.Enabled
            })
        end
    end
end

local function restoreOriginals()
    Lighting.GlobalShadows = BOOTER.originalLighting.GlobalShadows
    Lighting.FogEnd = BOOTER.originalLighting.FogEnd
    Lighting.Brightness = BOOTER.originalLighting.Brightness
    Lighting.ClockTime = BOOTER.originalLighting.ClockTime
    Lighting.OutdoorAmbient = BOOTER.originalLighting.OutdoorAmbient
    Lighting.Ambient = BOOTER.originalLighting.Ambient
    Lighting.ExposureCompensation = BOOTER.originalLighting.ExposureCompensation

    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("Atmosphere") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or
           effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect") or
           effect:IsA("Sky") or effect:IsA("PostEffect") then
            if BOOTER.originalEffects[effect] ~= nil then
                effect.Enabled = BOOTER.originalEffects[effect]
            end
        end
    end

    for _, entry in ipairs(BOOTER.originalParts) do
        if entry.obj and entry.obj.Parent then
            safeCall(function()
                entry.obj.Material = entry.material
                entry.obj.Reflectance = entry.reflectance
                entry.obj.CastShadow = entry.castShadow
                entry.obj.Transparency = entry.transparency
            end)
        end
    end

    for _, entry in ipairs(BOOTER.originalVisuals) do
        if entry.obj and entry.obj.Parent then
            safeCall(function()
                entry.obj.Enabled = entry.enabled
            end)
        end
    end
end

local function isImportantPart(part)
    if not part or not part.Parent then
        return true
    end

    if part:IsA("BasePart") then
        local parent = part.Parent
        if parent and parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then
            return true
        end

        local name = string.lower(part.Name)
        if name:find("collision") or name:find("hitbox") or name:find("trigger") then
            return true
        end
    end

    return false
end

local function optimizeBalanced(descendant)
    if not descendant or not descendant.Parent then
        return
    end

    if descendant:IsA("BasePart") then
        if isImportantPart(descendant) then
            return
        end

        safeCall(function()
            descendant.Material = Enum.Material.SmoothPlastic
            descendant.Reflectance = 0
            descendant.CastShadow = false
        end)
    elseif descendant:IsA("ParticleEmitter") then
        if descendant.Rate > 35 then
            descendant.Enabled = false
        end
    elseif descendant:IsA("Trail") or descendant:IsA("Smoke") or descendant:IsA("Fire") or descendant:IsA("Sparkles") then
        descendant.Enabled = false
    elseif descendant:IsA("Beam") then
        descendant.Enabled = false
    elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
        safeCall(function()
            descendant.Transparency = 1
        end)
    end
end

local function optimizeAggressive(descendant)
    if not descendant or not descendant.Parent then
        return
    end

    if descendant:IsA("BasePart") then
        if isImportantPart(descendant) then
            return
        end

        safeCall(function()
            descendant.Material = Enum.Material.SmoothPlastic
            descendant.Reflectance = 0
            descendant.CastShadow = false
        end)
    elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
        safeCall(function()
            descendant.Transparency = 1
        end)
    elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Smoke") or
           descendant:IsA("Fire") or descendant:IsA("Sparkles") or descendant:IsA("Beam") then
        descendant.Enabled = false
    end
end

local function applyBalancedMode()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    Lighting.Brightness = 1

    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = false
        end
    end

    for _, descendant in ipairs(Workspace:GetDescendants()) do
        optimizeBalanced(descendant)
    end
end

local function applyAggressiveMode()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e9
    Lighting.Brightness = 0.7
    Lighting.ClockTime = 12
    Lighting.OutdoorAmbient = Color3.fromRGB(125, 125, 125)

    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("Atmosphere") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or
           effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect") or
           effect:IsA("Sky") or effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end

    for _, descendant in ipairs(Workspace:GetDescendants()) do
        optimizeAggressive(descendant)
    end
end

local function applyCurrentMode()
    if not BOOTER.enabled then
        restoreOriginals()
        return
    end

    if BOOTER.mode == "Aggressive" then
        applyAggressiveMode()
    else
        applyBalancedMode()
    end
end

-- UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSBooster"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 270, 0, 150)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 34)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.Text = "FPS Booster"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 26)
statusLabel.Position = UDim2.new(0, 10, 0, 42)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: OFF"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 16
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
statusLabel.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 120, 0, 34)
toggleButton.Position = UDim2.new(0, 10, 0, 78)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 90)
toggleButton.Text = "Turn ON"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = frame

local modeButton = Instance.new("TextButton")
modeButton.Size = UDim2.new(0, 120, 0, 34)
modeButton.Position = UDim2.new(0, 140, 0, 78)
modeButton.BackgroundColor3 = Color3.fromRGB(50, 100, 180)
modeButton.Text = "Mode: Balanced"
modeButton.Font = Enum.Font.GothamBold
modeButton.TextSize = 13
modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
modeButton.Parent = frame

local function refreshUI()
    if BOOTER.enabled then
        statusLabel.Text = "Status: ON | Mode: " .. BOOTER.mode
        statusLabel.TextColor3 = Color3.fromRGB(110, 255, 110)
        toggleButton.Text = "Turn OFF"
    else
        statusLabel.Text = "Status: OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
        toggleButton.Text = "Turn ON"
    end

    if BOOTER.mode == "Aggressive" then
        modeButton.Text = "Mode: Aggressive"
    else
        modeButton.Text = "Mode: Balanced"
    end
end

toggleButton.MouseButton1Click:Connect(function()
    BOOTER.enabled = not BOOTER.enabled
    if BOOTER.enabled then
        applyCurrentMode()
    else
        restoreOriginals()
    end
    refreshUI()
end)

modeButton.MouseButton1Click:Connect(function()
    if BOOTER.mode == "Balanced" then
        BOOTER.mode = "Aggressive"
    else
        BOOTER.mode = "Balanced"
    end

    if BOOTER.enabled then
        applyCurrentMode()
    end

    refreshUI()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.F6 then
        BOOTER.enabled = not BOOTER.enabled
        if BOOTER.enabled then
            applyCurrentMode()
        else
            restoreOriginals()
        end
        refreshUI()
    elseif input.KeyCode == Enum.KeyCode.F7 then
        if BOOTER.mode == "Balanced" then
            BOOTER.mode = "Aggressive"
        else
            BOOTER.mode = "Balanced"
        end

        if BOOTER.enabled then
            applyCurrentMode()
        end

        refreshUI()
    end
end)

Workspace.DescendantAdded:Connect(function(descendant)
    task.wait(0.1)
    if not BOOTER.enabled then
        return
    end

    if BOOTER.mode == "Aggressive" then
        optimizeAggressive(descendant)
    else
        optimizeBalanced(descendant)
    end
end)

captureOriginals()
refreshUI()
print("✓ FPS Booster loaded. Press F6 to toggle, F7 to switch modes.")
