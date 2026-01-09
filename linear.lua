shared.Linear = {
    ['General'] = {
        ['Team Check'] = false,
        ['Aim Part'] = 'HumanoidRootPart', -- Options: HumanoidRootPart, Head, UpperTorso
    },
    
    ['Silent Aim'] = {
        ['Enabled'] = true,
        ['Transparency'] = 0.5,
        ['FOV'] = {
            ['Visible'] = true,
            ['X'] = 106, -- Replaced Vector2
            ['Y'] = 106,
            ['Color'] = Color3.fromRGB(255, 255, 255)
        }
    },
    
    ['Trigger Bot'] = {
        ['Enabled'] = true,
        ['Transparency'] = 0.5,
        ['Delay'] = 0.05,
        ['Activation'] = {
            ['Mode'] = 'Hold', -- Options: Hold, Toggle
            ['Keybind'] = 'Z'  -- Replaced Enum.KeyCode.Z
        },
        ['FOV'] = {
            ['Visible'] = true,
            ['X'] = 106, -- Replaced Vector2
            ['Y'] = 106,
            ['Color'] = Color3.fromRGB(255, 0, 0)
        }
    }
}

repeat task.wait() until game:IsLoaded()

local Config = shared.Linear
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Convert the "Z" string to a real Roblox KeyCode
local function GetKeyCode(key)
    return Enum.KeyCode[key]
end

local SilentCfg = Config['Silent Aim']
local TriggerCfg = Config['Trigger Bot']
local TriggerKey = GetKeyCode(TriggerCfg.Activation.Keybind)


local function CreateBox(color, transparency)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = color
    box.Transparency = transparency
    box.Visible = false
    return box
end

local SilentBox = CreateBox(SilentCfg.FOV.Color, SilentCfg.Transparency)
local TriggerBox = CreateBox(TriggerCfg.FOV.Color, TriggerCfg.Transparency)


local function Alive(plr)
    local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function GetBoxData(targetPart, sizeX, sizeY)
    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if not onScreen then return nil end

    local distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
    local factor = 1 / (distance * math.tan(math.rad(Camera.FieldOfView / 2))) * (Camera.ViewportSize.Y / 2)
    local boxWidth = sizeX * factor
    local boxHeight = sizeY * factor

    return {
        Position = Vector2.new(pos.X - boxWidth / 2, pos.Y - boxHeight / 2),
        Size = Vector2.new(boxWidth, boxHeight),
        Center = Vector2.new(pos.X, pos.Y)
    }
end

local function IsMouseInBox(boxData)
    local center = Camera.ViewportSize / 2
    return center.X >= boxData.Position.X and center.X <= (boxData.Position.X + boxData.Size.X) and
           center.Y >= boxData.Position.Y and center.Y <= (boxData.Position.Y + boxData.Size.Y)
end

local function GetTargetInFOV(fovX, fovY, teamCheck)
    local target = nil
    local shortestDist = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and Alive(plr) then
            if teamCheck and plr.Team == LocalPlayer.Team then continue end
            local char = plr.Character
            local part = char:FindFirstChild(Config.General['Aim Part'])
            if part then
                local boxData = GetBoxData(part, fovX, fovY)
                if boxData and IsMouseInBox(boxData) then
                    local mag = (boxData.Center - (Camera.ViewportSize / 2)).Magnitude
                    if mag < shortestDist then
                        shortestDist = mag
                        target = plr
                    end
                end
            end
        end
    end
    return target
end

--==================================================
-- MAIN LOOP
--==================================================
local TriggerHeld, TriggerToggle, LastShot = false, false, 0

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == TriggerKey then
        if TriggerCfg.Activation.Mode == "Toggle" then 
            TriggerToggle = not TriggerToggle 
        else 
            TriggerHeld = true 
        end
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.KeyCode == TriggerKey then TriggerHeld = false end
end)

RunService.RenderStepped:Connect(function()
    SilentBox.Color = SilentCfg.FOV.Color
    SilentBox.Transparency = SilentCfg.Transparency
    TriggerBox.Color = TriggerCfg.FOV.Color
    TriggerBox.Transparency = TriggerCfg.Transparency

    -- SILENT AIM
    local silentTarget = GetTargetInFOV(SilentCfg.FOV.X, SilentCfg.FOV.Y, Config.General['Team Check'])
    if silentTarget and SilentCfg.Enabled then
        local boxData = GetBoxData(silentTarget.Character[Config.General['Aim Part']], SilentCfg.FOV.X, SilentCfg.FOV.Y)
        if boxData and SilentCfg.FOV.Visible then
            SilentBox.Visible = true
            SilentBox.Size = boxData.Size
            SilentBox.Position = boxData.Position
        end
    else
        SilentBox.Visible = false
    end

    -- TRIGGERBOT
    local triggerTarget = GetTargetInFOV(TriggerCfg.FOV.X, TriggerCfg.FOV.Y, Config.General['Team Check'])
    local isTriggerActive = (TriggerCfg.Activation.Mode == "Hold" and TriggerHeld) or (TriggerCfg.Activation.Mode == "Toggle" and TriggerToggle)

    if triggerTarget and TriggerCfg.Enabled then
        local boxData = GetBoxData(triggerTarget.Character[Config.General['Aim Part']], TriggerCfg.FOV.X, TriggerCfg.FOV.Y)
        if boxData and TriggerCfg.FOV.Visible then
            TriggerBox.Visible = true
            TriggerBox.Size = boxData.Size
            TriggerBox.Position = boxData.Position
        end

        if isTriggerActive and tick() - LastShot >= TriggerCfg.Delay then
            LastShot = tick()
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait()
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    else
        TriggerBox.Visible = false
    end
end)

--==================================================
-- SILENT AIM HOOK
--==================================================
local mt = getrawmetatable(game)
local old = mt.__index
setreadonly(mt, false)

mt.__index = newcclosure(function(self, key)
    if self == Mouse and SilentCfg.Enabled and not checkcaller() then
        local targetPlr = GetTargetInFOV(SilentCfg.FOV.X, SilentCfg.FOV.Y, Config.General['Team Check'])
        if targetPlr and targetPlr.Character then
            local part = targetPlr.Character:FindFirstChild(Config.General['Aim Part'])
            if part then
                if key == "Hit" then return part.CFrame end
                if key == "UnitRay" then 
                    return Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit) 
                end
            end
        end
    end
    return old(self, key)
end)

setreadonly(mt, true)
