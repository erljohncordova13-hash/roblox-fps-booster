-- Aggressive FPS Booster
-- Higher performance impact, lower visual fidelity

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- 1. Aggressive lighting cleanup
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

-- 2. Aggressive object optimization
local function optimizeObject(object)
    if object:IsA("BasePart") then
        object.Material = Enum.Material.SmoothPlastic
        object.Reflectance = 0
        object.CastShadow = false
        if object.Transparency < 1 then
            object.Transparency = math.clamp(object.Transparency + 0.05, 0, 1)
        end
    elseif object:IsA("Decal") or object:IsA("Texture") then
        object.Transparency = 1
    elseif object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") or object:IsA("Beam") then
        object.Enabled = false
    end
end

-- 3. Apply to current workspace
for _, descendant in ipairs(Workspace:GetDescendants()) do
    optimizeObject(descendant)
end

-- 4. Optimize newly added objects
Workspace.DescendantAdded:Connect(function(descendant)
    task.wait(0.05)
    optimizeObject(descendant)
end)

-- 5. Terrain cleanup
local terrain = Workspace:FindFirstChildOfClass("Terrain")
if terrain then
    terrain.WaterWaveSize = 0
    terrain.WaterWaveSpeed = 0
    terrain.WaterReflectance = 0
    terrain.WaterTransparency = 1
end

print("✓ Aggressive FPS Booster loaded")
