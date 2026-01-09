
repeat task.wait() until game:IsLoaded()

--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local CFG = shared.linear

--==================================================
-- FOV DRAWINGS
--==================================================
local SilentFOV = Drawing.new("Circle")
SilentFOV.Thickness = 1
SilentFOV.NumSides = 100
SilentFOV.Filled = false
SilentFOV.Color = Color3.fromRGB(255,255,255)

local TriggerFOV = Drawing.new("Circle")
TriggerFOV.Thickness = 1
TriggerFOV.NumSides = 100
TriggerFOV.Filled = false
TriggerFOV.Color = Color3.fromRGB(255,0,0)

RunService.RenderStepped:Connect(function()
    local center = Camera.ViewportSize / 2

    SilentFOV.Visible = CFG['Silent Aim'].Enabled and CFG['Silent Aim'].FOV.Visible
    SilentFOV.Radius = CFG['Silent Aim'].FOV.Radius
    SilentFOV.Position = center

    TriggerFOV.Visible = CFG['Trigger Bot'].Enabled and CFG['Trigger Bot'].FOV.Visible
    TriggerFOV.Radius = CFG['Trigger Bot'].FOV.Radius
    TriggerFOV.Position = center
end)

--==================================================
-- UTILS
--==================================================
local function Alive(plr)
    local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function ScreenDist(pos)
    local v, on = Camera:WorldToViewportPoint(pos)
    if not on then return math.huge end
    return (Vector2.new(v.X, v.Y) - Camera.ViewportSize / 2).Magnitude
end

local function ClosestPointOnPart(part, worldPos)
    local cf = part.CFrame
    local size = part.Size / 2
    local lp = cf:PointToObjectSpace(worldPos)

    return cf:PointToWorldSpace(Vector3.new(
        math.clamp(lp.X, -size.X, size.X),
        math.clamp(lp.Y, -size.Y, size.Y),
        math.clamp(lp.Z, -size.Z, size.Z)
    ))
end

--==================================================
-- SILENT AIM TARGET
--==================================================
local BodyParts = {
    "Head","UpperTorso","LowerTorso",
    "HumanoidRootPart",
    "LeftUpperArm","RightUpperArm",
    "LeftUpperLeg","RightUpperLeg"
}

local function GetSilentTarget()
    local bestPart, bestPoint, bestDist = nil, nil, CFG['Silent Aim'].FOV.Radius

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and Alive(plr) then
            if CFG['Silent Aim']['Team Check'] and plr.Team == LocalPlayer.Team then continue end
            local char = plr.Character

            local parts
            local mode = CFG['Silent Aim']['Aim Part']

            if type(mode) == "string" then
                parts = (mode == "Closest Part" or mode == "Closest Point") and BodyParts or { mode }
            else
                parts = mode
            end

            for _, name in ipairs(parts) do
                local part = char:FindFirstChild(name)
                if part then
                    local point = (mode == "Closest Point")
                        and ClosestPointOnPart(part, Camera.CFrame.Position + Camera.CFrame.LookVector * 1000)
                        or part.Position

                    local dist = ScreenDist(point)
                    if dist < bestDist then
                        bestDist = dist
                        bestPart = part
                        bestPoint = point
                    end
                end
            end
        end
    end

    return bestPart, bestPoint
end

--==================================================
-- TRIGGERBOT
--==================================================
local Held, Toggled, LastShot = false, false, 0

UIS.InputBegan:Connect(function(i,g)
    if g or i.KeyCode ~= CFG['Trigger Bot'].Activation.Key then return end
    if CFG['Trigger Bot'].Activation.Mode == "Toggle" then
        Toggled = not Toggled
    else
        Held = true
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.KeyCode == CFG['Trigger Bot'].Activation.Key then
        Held = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not CFG['Trigger Bot'].Enabled then return end

    local active = (CFG['Trigger Bot'].Activation.Mode == "Hold" and Held)
        or (CFG['Trigger Bot'].Activation.Mode == "Toggle" and Toggled)

    if not active then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and Alive(plr) then
            if CFG['Trigger Bot']['Team Check'] and plr.Team == LocalPlayer.Team then continue end

            local part = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("UpperTorso")
            if part and ScreenDist(part.Position) <= CFG['Trigger Bot'].FOV.Radius then
                if tick() - LastShot >= CFG['Trigger Bot']['Shoot Delay'] then
                    LastShot = tick()
                    VIM:SendMouseButtonEvent(0,0,0,true,game,0)
                    task.wait()
                    VIM:SendMouseButtonEvent(0,0,0,false,game,0)
                end
                return
            end
        end
    end
end)

--==================================================
-- SILENT AIM METAMETHOD
--==================================================
local mt = getrawmetatable(game)
local old = mt.__index
setreadonly(mt,false)

mt.__index = newcclosure(function(self,key)
    if self == Mouse and CFG['Silent Aim'].Enabled then
        local _, point = GetSilentTarget()
        if point then
            if key == "Hit" then
                return CFrame.new(point)
            elseif key == "UnitRay" then
                local o = Camera.CFrame.Position
                return Ray.new(o, (point - o).Unit * 1000)
            end
        end
    end
    return old(self,key)
end)

setreadonly(mt,true)
