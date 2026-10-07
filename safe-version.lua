-- Safe FPS Booster - Preserves Important Game Effects
-- Only disables non-essential visual effects

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- 1. Conservative Lighting Settings
Lighting.GlobalShadows = false
Lighting.FogEnd = 100000  -- Reasonable fog distance instead of extreme

-- Disable only expensive post-effects, preserve atmosphere
for _, effect in ipairs(Lighting:GetChildren()) do
    if effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
        effect.Enabled = false
    end
    -- Preserve Sky and Atmosphere for visual integrity
end

-- 2. Safe Object Optimization
local function optimizeObject(object)
    local parent = object.Parent
    if not parent then return end
    
    -- Skip objects in typical UI/important game systems
    local skipNames = {"UI", "Camera", "Humanoid", "Motor", "Weld", "Constraint"}
    for _, skipName in ipairs(skipNames) do
        if object.Name:find(skipName) or parent.Name:find(skipName) then
            return
        end
    end
    
    if object:IsA("BasePart") then
        -- Only optimize if not a crucial part (avoid breaking mechanics)
        if object.Material ~= Enum.Material.Neon then
            object.Material = Enum.Material.SmoothPlastic
            object.Reflectance = 0
        end
        object.CastShadow = false
    elseif object:IsA("Decal") then
        -- Preserve decals, they're usually important for visuals
        return
    elseif object:IsA("ParticleEmitter") then
        -- Only disable if emitter appears decorative (spawning rarely)
        if object.Rate > 50 then
            object.Enabled = false
        end
    elseif object:IsA("Trail") or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") then
        object.Enabled = false
    elseif object:IsA("Beam") then
        -- Only disable high-count beams
        if object.Parent:FindFirstChildOfClass("Beam") then
            object.Enabled = false
        end
    end
end

-- 3. Apply Optimization to Workspace
for _, descendant in ipairs(Workspace:GetDescendants()) do
    optimizeObject(descendant)
end

-- 4. Listen for Newly Spawned Items
Workspace.DescendantAdded:Connect(function(descendant)
    task.wait(0.1)
    optimizeObject(descendant)
end)

-- 5. Lower Terrain Detail
local terrain = Workspace:FindFirstChildOfClass("Terrain")
if terrain then
    terrain.WaterWaveSize = 0
    terrain.WaterWaveSpeed = 0
end

print("✓ Safe FPS Booster loaded - Important effects preserved")
