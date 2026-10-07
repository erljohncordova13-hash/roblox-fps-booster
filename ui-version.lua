-- FPS Booster with UI Toggle
-- Click the button to toggle between Safe/Aggressive/Off modes

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- State variables
local boosterMode = "OFF" -- OFF, SAFE, AGGRESSIVE
local originalSettings = {}

-- Store original settings for restoration
local function storeOriginalSettings()
    originalSettings.globalShadows = Lighting.GlobalShadows
    originalSettings.fogEnd = Lighting.FogEnd
    originalSettings.brightness = Lighting.Brightness
    originalSettings.clockTime = Lighting.ClockTime
    originalSettings.outdoorAmbient = Lighting.OutdoorAmbient
    originalSettings.parts = {}
    
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("BasePart") then
            table.insert(originalSettings.parts, {
                part = descendant,
                material = descendant.Material,
                reflectance = descendant.Reflectance,
                castShadow = descendant.CastShadow,
                transparency = descendant.Transparency
            })
        end
    end
end

-- Restore original settings
local function restoreSettings()
    Lighting.GlobalShadows = originalSettings.globalShadows
    Lighting.FogEnd = originalSettings.fogEnd
    Lighting.Brightness = originalSettings.brightness
    Lighting.ClockTime = originalSettings.clockTime
    Lighting.OutdoorAmbient = originalSettings.outdoorAmbient
    
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or effect:IsA("Sky") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") then
            effect.Enabled = true
        end
    end
    
    for _, entry in ipairs(originalSettings.parts) do
        if entry.part and entry.part.Parent then
            entry.part.Material = entry.material
            entry.part.Reflectance = entry.reflectance
            entry.part.CastShadow = entry.castShadow
            entry.part.Transparency = entry.transparency
        end
    end
end

-- Safe mode optimization
local function applySafeMode()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = false
        end
    end
    
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Material ~= Enum.Material.Neon then
            descendant.Material = Enum.Material.SmoothPlastic
            descendant.Reflectance = 0
            descendant.CastShadow = false
        elseif descendant:IsA("ParticleEmitter") and descendant.Rate > 50 then
            descendant.Enabled = false
        elseif descendant:IsA("Trail") or descendant:IsA("Smoke") or descendant:IsA("Fire") or descendant:IsA("Sparkles") then
            descendant.Enabled = false
        end
    end
end

-- Aggressive mode optimization
local function applyAggressiveMode()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e9
    Lighting.Brightness = 0.8
    Lighting.ClockTime = 12
    Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 120)
    
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("Atmosphere") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("Sky") or effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end
    
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.Material = Enum.Material.SmoothPlastic
            descendant.Reflectance = 0
            descendant.CastShadow = false
        elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
            descendant.Transparency = 1
        elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Smoke") or descendant:IsA("Fire") or descendant:IsA("Sparkles") or descendant:IsA("Beam") then
            descendant.Enabled = false
        end
    end
end

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSBoosterUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 180)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Text = "FPS Booster"
title.Parent = mainFrame

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 45)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Status: OFF"
statusLabel.Parent = mainFrame

-- Safe mode button
local safeButton = Instance.new("TextButton")
safeButton.Name = "SafeButton"
safeButton.Size = UDim2.new(0, 130, 0, 35)
safeButton.Position = UDim2.new(0, 10, 0, 80)
safeButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
safeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
safeButton.TextSize = 12
safeButton.Font = Enum.Font.GothamBold
safeButton.Text = "Safe Mode"
safeButton.BorderSizePixel = 0
safeButton.Parent = mainFrame

-- Aggressive mode button
local aggressiveButton = Instance.new("TextButton")
aggressiveButton.Name = "AggressiveButton"
aggressiveButton.Size = UDim2.new(0, 130, 0, 35)
aggressiveButton.Position = UDim2.new(0, 160, 0, 80)
aggressiveButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
aggressiveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
aggressiveButton.TextSize = 12
aggressiveButton.Font = Enum.Font.GothamBold
aggressiveButton.Text = "Aggressive"
aggressiveButton.BorderSizePixel = 0
aggressiveButton.Parent = mainFrame

-- Off button
local offButton = Instance.new("TextButton")
offButton.Name = "OffButton"
offButton.Size = UDim2.new(0, 280, 0, 30)
offButton.Position = UDim2.new(0, 10, 0, 125)
offButton.BackgroundColor3 = Color3.fromRGB(158, 158, 158)
offButton.TextColor3 = Color3.fromRGB(255, 255, 255)
offButton.TextSize = 12
offButton.Font = Enum.Font.GothamBold
offButton.Text = "Turn Off"
offButton.BorderSizePixel = 0
offButton.Parent = mainFrame

-- Button interactions
local function updateStatus()
    statusLabel.Text = "Status: " .. boosterMode
    if boosterMode == "OFF" then
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    elseif boosterMode == "SAFE" then
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    end
end

safeButton.MouseButton1Click:Connect(function()
    if boosterMode == "OFF" then
        storeOriginalSettings()
    end
    if boosterMode == "AGGRESSIVE" then
        restoreSettings()
    end
    applySafeMode()
    boosterMode = "SAFE"
    updateStatus()
    print("✓ Safe Mode activated")
end)

aggressiveButton.MouseButton1Click:Connect(function()
    if boosterMode == "OFF" then
        storeOriginalSettings()
    end
    if boosterMode == "SAFE" then
        restoreSettings()
    end
    applyAggressiveMode()
    boosterMode = "AGGRESSIVE"
    updateStatus()
    print("✓ Aggressive Mode activated")
end)

offButton.MouseButton1Click:Connect(function()
    if boosterMode ~= "OFF" then
        restoreSettings()
    end
    boosterMode = "OFF"
    updateStatus()
    print("✓ FPS Booster deactivated")
end)

-- Keyboard toggle (Press F6 to cycle modes)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        if boosterMode == "OFF" then
            safeButton:FireAllChildren()
            safeButton.MouseButton1Click:Fire()
        elseif boosterMode == "SAFE" then
            aggressiveButton.MouseButton1Click:Fire()
        else
            offButton.MouseButton1Click:Fire()
        end
    end
end)

-- Handle newly spawned objects
Workspace.DescendantAdded:Connect(function(descendant)
    task.wait(0.05)
    if boosterMode == "SAFE" then
        if descendant:IsA("BasePart") and descendant.Material ~= Enum.Material.Neon then
            descendant.Material = Enum.Material.SmoothPlastic
            descendant.Reflectance = 0
            descendant.CastShadow = false
        elseif descendant:IsA("ParticleEmitter") and descendant.Rate > 50 then
            descendant.Enabled = false
        end
    elseif boosterMode == "AGGRESSIVE" then
        if descendant:IsA("BasePart") then
            descendant.Material = Enum.Material.SmoothPlastic
            descendant.Reflectance = 0
            descendant.CastShadow = false
        elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Smoke") or descendant:IsA("Fire") or descendant:IsA("Sparkles") or descendant:IsA("Beam") then
            descendant.Enabled = false
        end
    end
end)

updateStatus()
print("✓ FPS Booster UI loaded - Press F6 to cycle modes or use buttons")
