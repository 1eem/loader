if type(shared.CiderCleanup) == 'function' then
	pcall(shared.CiderCleanup)
	shared.CiderCleanup = nil
end


loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
]])();

local Config = shared.Cider or {}

if Config['Main'] and Config['Main']['Intro'] == true then
	task.spawn(function()
		repeat task.wait() until game:IsLoaded()
		
		local gui = Instance.new("ScreenGui")
		gui.Name = "LogoGui"
		gui.IgnoreGuiInset = true
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		gui.Parent = game.CoreGui

		local logo = Instance.new("ImageLabel")
		logo.Image = "rbxassetid://79667231259857"
		logo.Size = UDim2.fromScale(0.65, 0.65)
		logo.AnchorPoint = Vector2.new(0.5, 0.5)
		logo.Position = UDim2.fromScale(0.5, 0.5)
		logo.BackgroundTransparency = 1
		logo.ImageTransparency = 1
		logo.ScaleType = Enum.ScaleType.Fit
		logo.Parent = gui

		local aspect = Instance.new("UIAspectRatioConstraint")
		aspect.AspectRatio = 3
		aspect.Parent = logo

		pcall(function()
			game:GetService("ContentProvider"):PreloadAsync({logo})
		end)

		for i = 1, 0, -0.04 do
			logo.ImageTransparency = i
			task.wait(0.02)
		end

		task.wait(0.15)

		for i = 0, 1, 0.04 do
			logo.ImageTransparency = i
			task.wait(0.02)
		end

		gui:Destroy()
	end)
end

resolveScriptKey = function(cfg)
	local mainConfig = cfg and cfg['Main'] or nil
	local keyFromShared = shared.script_key
	local keyFromLicense = mainConfig and mainConfig['License Key']
	local keyFromLegacy = mainConfig and mainConfig.script_key
	local resolved = keyFromShared or keyFromLicense or keyFromLegacy or 'Your key here'
	if mainConfig then
		mainConfig['License Key'] = resolved
		mainConfig.script_key = resolved
	end
	shared.script_key = resolved
	return resolved
end
local script_key = resolveScriptKey(Config)
Hook_Adonis = LPH_NO_VIRTUALIZE(function(meta_defs)
	for _, tbl in meta_defs do
		for i, func in tbl do
			if type(func) == "function" and islclosure(func) then
				local dummy_func = function()
					return pcall(coroutine.close, coroutine.running())
				end
				hookfunction(func, dummy_func)
			end
		end
	end
end)
Init_Bypass = LPH_NO_VIRTUALIZE(function()
	for i, v in getgc(true) do
		if typeof(v) == "table" and rawget(v, "indexInstance") and rawget(v, "newindexInstance") and rawget(v, "namecallInstance") and type(rawget(v, "newindexInstance")) == "table" then
			if v["newindexInstance"][1] == "kick" then
				Hook_Adonis(v)
			end
		end
	end
end)
Init_Bypass()

if not Config then
	Config = {}
end
if not Config['Main'] then
	Config['Main'] = {}
end
if not Config['Main']['Keybinds'] then
	Config['Main']['Keybinds'] = {}
end
if not Config['Aim Assist'] then
	Config['Aim Assist'] = {}
end
if not Config['Target Checks'] then
	Config['Target Checks'] = {}
end
if not Config['Self Checks'] then
	Config['Self Checks'] = {}
end
if not Config['Unlock Conditions'] then
	Config['Unlock Conditions'] = {}
end
if not Config['Player Modification'] then
	Config['Player Modification'] = {}
end
if not Config['Player Modification']['Movement'] then
	Config['Player Modification']['Movement'] = {}
end
if not Config['Raid Awareness'] then
	Config['Raid Awareness'] = {}
end
if not Config['Triggerbot'] then
	Config['Triggerbot'] = {}
end
if not Config['Silent Aimbot'] then
	Config['Silent Aimbot'] = {}
end

local TriggerBotConfig = Config and Config['Triggerbot'] or {}
local SilentAimConfig = Config and Config['Silent Aimbot'] or {}
local RaidAwarenessConfig = Config and Config['Raid Awareness'] or {}

local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local vm = game:GetService("VirtualInputManager")
local rep = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local debris = game:GetService("Debris")
local httpService = game:GetService("HttpService")

local plr = players.LocalPlayer
local cam = workspace.CurrentCamera
local mouse = plr:GetMouse()


local mathClamp = math.clamp
local mathDeg = math.deg
local mathRad = math.rad
local mathAcos = math.acos
local mathHuge = math.huge
local mathAbs = math.abs
local mathMax = math.max
local mathMin = math.min
local mathSqrt = math.sqrt
local mathSin = math.sin
local mathCos = math.cos
local mathAtan2 = math.atan2
local mathAsin = math.asin
local mathTan = math.tan
local mathFloor = math.floor
local mathPow = math.pow
local mathExp = math.exp
local mathPi = math.pi
local vector3New = Vector3.new
local vector2New = Vector2.new
local typeof = typeof
local cfNew = CFrame.new
local cfLookAt = CFrame.lookAt
local tableInsert = table.insert
local tableRemove = table.remove
local osTime = os.clock
local vector3Zero = vector3New(0, 0, 0)


local enumKeyCode = Enum.KeyCode
local enumUserInputType = Enum.UserInputType
local enumMaterial = Enum.Material
local enumRaycastFilterType = Enum.RaycastFilterType

getKeyCodeFromString = function(keyName)
	if not keyName or type(keyName) ~= "string" then
		return nil
	end

	local upperKeyName = keyName:upper()

	local success, keyCode = pcall(function()
		return Enum.KeyCode[upperKeyName]
	end)

	if success and keyCode then
		return keyCode
	end

	if upperKeyName:match("^F%d+$") then
		local fKeyNum = tonumber(upperKeyName:sub(2))
		if fKeyNum and fKeyNum >= 1 and fKeyNum <= 12 then
			success, keyCode = pcall(function()
				return Enum.KeyCode["F" .. fKeyNum]
			end)
			if success and keyCode then
				return keyCode
			end
		end
	end

	return nil
end

local bodyParts = {
	"Head",
	"UpperTorso",
	"HumanoidRootPart",
	"LowerTorso",
	"LeftUpperArm",
	"RightUpperArm",
	"LeftLowerArm",
	"RightLowerArm",
	"LeftHand",
	"RightHand",
	"LeftUpperLeg",
	"RightUpperLeg",
	"LeftLowerLeg",
	"RightLowerLeg",
	"LeftFoot",
	"RightFoot"
}

local cameraAimbotLocked = false
local cameraAimbotTarget = nil
local cameraAimbotPaused = false
local cameraAimbotPauseTime = 0
local characterList = {}
local lastUpdate = 0
local fovVisualizer = nil
local aimAssistFovVisual = {
	circle = nil,
	boxLines = {}
}
local antiCurveOverlayText = nil
local antiCurveOverlayExpiry = 0
local antiCurveOverlayData = nil

shouldVisualizeAntiCurve = function()
	local antiCurveConfig = SilentAimConfig and SilentAimConfig['Anti Curve']
	if not antiCurveConfig or not antiCurveConfig['Enabled'] then
		return false
	end
	local anglesConfig = antiCurveConfig['Angles'] or {}
	return anglesConfig['Visualize Anti Curve'] == true
end
local AIM_ASSIST_FOV_COLOR = Color3.fromRGB(50, 50, 50)

ensureAimAssistCircle = function()
	local circle = aimAssistFovVisual.circle
	if circle then
		return circle
	end
	circle = Drawing.new("Circle")
	circle.Visible = false
	circle.Color = AIM_ASSIST_FOV_COLOR
	circle.Transparency = 0.925
	circle.Thickness = 2
	circle.NumSides = 64
	circle.Filled = false
	aimAssistFovVisual.circle = circle
	return circle
end

ensureAimAssistBoxLines = function()
	local existing = aimAssistFovVisual.boxLines or {}
	if #existing == 4 then
		return existing
	end
	for _, line in ipairs(existing) do
		pcall(function()
			line:Remove()
		end)
	end
	local lines = {}
	for i = 1, 4 do
		local line = Drawing.new("Line")
		line.Visible = false
		line.Color = AIM_ASSIST_FOV_COLOR
		line.Transparency = 0.925
		line.Thickness = 2
		lines[i] = line
	end
	aimAssistFovVisual.boxLines = lines
	return lines
end

hideAimAssistVisuals = function()
	if aimAssistFovVisual.circle then
		aimAssistFovVisual.circle.Visible = false
	end
	for _, line in ipairs(aimAssistFovVisual.boxLines) do
		line.Visible = false
	end
end

local triggerBotFovVisual = {
	circle = nil,
	boxLines = {}
}
local TRIGGER_BOT_FOV_COLOR = Color3.fromRGB(255, 255, 255)

ensureTriggerBotCircle = function()
	local circle = triggerBotFovVisual.circle
	if circle then
		return circle
	end
	circle = Drawing.new("Circle")
	circle.Visible = false
	circle.Color = TRIGGER_BOT_FOV_COLOR
	circle.Transparency = 1
	circle.Thickness = 2
	circle.NumSides = 64
	circle.Filled = false
	triggerBotFovVisual.circle = circle
	return circle
end

ensureTriggerBotBoxLines = function()
	local existing = triggerBotFovVisual.boxLines or {}
	if #existing == 4 then
		return existing
	end
	for _, line in ipairs(existing) do
		pcall(function()
			line:Remove()
		end)
	end
	local lines = {}
	for index = 1, 4 do
		local line = Drawing.new("Line")
		line.Visible = false
		line.Color = TRIGGER_BOT_FOV_COLOR
		line.Transparency = 1
		line.Thickness = 2
		lines[index] = line
	end
	triggerBotFovVisual.boxLines = lines
	return lines
end

hideTriggerBotVisuals = function()
	if triggerBotFovVisual.circle then
		triggerBotFovVisual.circle.Visible = false
	end
	for _, line in ipairs(triggerBotFovVisual.boxLines) do
		line.Visible = false
	end
end

local fovDrawings = {
	silent = {
		circle = nil,
		box = nil
	},
	assist = {
		circle = nil,
		box = nil
	},
	trigger = {
		circle = nil,
		box = nil
	}
}

local silentColor = Color3.fromRGB(0, 100, 255)
local assistColor = Color3.fromRGB(255, 255, 0)
local triggerColor = Color3.fromRGB(255, 0, 0)

fovDrawings.silent.circle = Drawing.new('Circle')
fovDrawings.silent.circle.Thickness = 1
fovDrawings.silent.circle.Color = silentColor
fovDrawings.silent.circle.Filled = false
fovDrawings.silent.circle.Transparency = 1
fovDrawings.silent.circle.Visible = false

local silentTargetLine = Drawing.new('Line')
silentTargetLine.Thickness = 1
silentTargetLine.Color = Color3.fromRGB(255, 255, 255)
silentTargetLine.Transparency = 1
silentTargetLine.Visible = false

createfovVisuals = function(fovType, config, color)
	if fovType == 'Circle' then
		local circle = Drawing.new('Circle')
		circle.Thickness = 1
		circle.Color = color
		circle.Filled = false
		circle.Transparency = 1
		circle.Visible = false
		return circle
	end
	return nil
end

updateFovVisual = LPH_NO_VIRTUALIZE(function(visual, fovConfig, circlePos, color, boxCenter)
	if not visual or not fovConfig then
		return
	end
	circlePos = circlePos or uis:GetMouseLocation()
	if not circlePos then
		return
	end
	local boxPos = boxCenter or circlePos
	local dimensions = calculateFovDimensions(fovConfig)
	if not dimensions then
		return
	end
	local fovType = fovConfig['FOV Type'] or 'Box'
	local isVisible = fovConfig['Visualize']
	if fovType == 'Box' then
		if not visual.box then
			visual.box = {
				top = Drawing.new('Line'),
				right = Drawing.new('Line'),
				bottom = Drawing.new('Line'),
				left = Drawing.new('Line')
			}
			for _, line in pairs(visual.box) do
				line.Thickness = 1
				line.Color = color
				line.Transparency = 0.7
				line.Visible = false
			end
		end
		local width = (dimensions.width or 0) * 0.5
		local height = (dimensions.height or 0) * 0.5
		local corners = {
			Vector2.new(boxPos.X - width, boxPos.Y - height),
			Vector2.new(boxPos.X + width, boxPos.Y - height),
			Vector2.new(boxPos.X + width, boxPos.Y + height),
			Vector2.new(boxPos.X - width, boxPos.Y + height)
		}
		if visual.box then
			visual.box.top.From = corners[1]
			visual.box.top.To = corners[2]
			visual.box.right.From = corners[2]
			visual.box.right.To = corners[3]
			visual.box.bottom.From = corners[3]
			visual.box.bottom.To = corners[4]
			visual.box.left.From = corners[4]
			visual.box.left.To = corners[1]
			for _, line in pairs(visual.box) do
				line.Visible = isVisible
			end
		end
		if visual.circle then
			visual.circle.Visible = false
		end
	elseif fovType == 'Circle' then
		if not visual.circle then
			visual.circle = Drawing.new('Circle')
			visual.circle.Thickness = 1
			visual.circle.Color = color
			visual.circle.Filled = false
			visual.circle.Transparency = 0.7
			visual.circle.Visible = false
		end
		visual.circle.Position = circlePos
		visual.circle.Radius = dimensions.radius
		visual.circle.Visible = isVisible
		if visual.box then
			for _, line in pairs(visual.box) do
				line.Visible = false
			end
		end
	end
end)
local speedModActive = false
local jumpPowerActive = false
local defaultWalkSpeed = nil
local defaultJumpPower = nil
local speedModPreviouslyActive = false
local jumpModPreviouslyActive = false
local currentSpreadMultiplier = 1.0
local panicMode = false
local sharedTarget = nil
local espDrawings = {}
local espTargets = {}
local raidFovDrawings = {
	box = nil,
	name = nil
}
local espScreenGui = nil
local cachedAimAssistConfig = nil
local cachedTargetChecksConfig = nil
local cachedSelfChecksConfig = nil
local cacheUpdateTime = 0
local CONFIG_CACHE_DURATION = 0.1
local triggerBotState = false
local activeConnections = {}
local triggerBotTarget = nil
local triggerBotLocked = false
local triggerBotOverrideTarget = nil
local triggerBotFiring = false
local humanizerState = {
	currentOffset = nil,
	targetOffset = nil,
	elapsed = 0,
	lastStep = nil
}
local triggerBotPart = Instance.new("Part")
triggerBotPart.Anchored = true
triggerBotPart.CanCollide = false
triggerBotPart.Transparency = 1
triggerBotPart.Size = Vector3.new(3.3, 7, 3.6)
triggerBotPart.Name = "TriggerBotPart"
local triggerBotRaycastParams = RaycastParams.new()
triggerBotRaycastParams.FilterType = Enum.RaycastFilterType.Whitelist
triggerBotRaycastParams.FilterDescendantsInstances = {triggerBotPart}
local resolveTargetCharacter
local attemptSilentAimShot
local CanShootGun
local silentAimLocked = false
local silentAimTarget = nil
local silentAimFiring = false
local performTrigger
local updateTriggerBotFov
local setupCharacterToolHooks
local cleanupEspDrawings
local cleanupFovVisuals
local updateFovVisuals
local getOrCreateEspScreenGui
local getEspDrawings
local CalculateSpread
local ShootGunEmulation
local GetAimDirection
local GetGunCategory
local GetSpreadMultiplier
local getKeyCodeFromString
local sanitizeNumber
local getKey
local inputMatches
local originalRandom
local getTriggerBotForcedTarget
local shouldTrigger
local isCrouching
local isHoldingRestrictedItem
local getCharacterFromPartTriggerBot
local shouldVisualizeAntiCurve
local ensureAimAssistCircle
local ensureAimAssistBoxLines
local hideAimAssistVisuals
local ensureTriggerBotCircle
local ensureTriggerBotBoxLines
local hideTriggerBotVisuals
local getHumanizerOffset
local getBestTriggerBotTarget
local isTargetInFovTriggerBot
local isCrosshairOnTarget
local findTargetTriggerBot
local destroyTriggerBotFovVisualizer
local getCharacterFromPartTriggerBot
local toggleCameraAimbot
local ProcessSilentAimShot
local addEspTarget
local removeEspTarget
local resolveScriptKey
local createFovVisuals
local resetHumanizerState
local randomizeHumanizerAxis
local resolveHumanizerSample
local chooseHumanizerTarget
local evaluateAntiCurve
local ensureAntiCurveOverlay
local updateAntiCurveOverlay
local stepAntiCurveOverlay
local Hook_Adonis
local Init_Bypass
local updateFovVisual
local updateConfigCache
local hasForcefield
local isKnocked
local isGrabbed
local isSelfKnocked
local isSelfGrabbed
local isSelfForcefield
local canUseFeatures
local isInFirstPerson
local isValidCameraMode
local isFirstPersonOrShiftLock
local calculateFovDimensions
local isWithinFov
local validChar
local wallCheck
local getClosestPointOnPart
local getClosestPointOnPartBasic
local getClosestPoint
local applyPrediction
local getAllPlayers
local getCharacters
local findTarget
local getBestTarget
local clearSilentAimTargetState
local getGunBarrelSilent
local calculate3DAngleSilent
local getClosestPlayerSilent
local destroyFovVisualizer
local isMouseInFov
local updateFovVisualizer
local smoothLerp
local clampScreenPos
local updateCamera
local syncTargetToFeatures
local getClosestBodyPartSilent
local renderConnection
local triggerBotConnection
local movementModConnection
local weaponSpreadConnection
local silentAimRenderConnection

cleanupFovVisuals = function()
	for _, drawing in pairs(fovDrawings) do
		if drawing then
			drawing:Remove()
		end
	end
	fovDrawings = {
		box = nil,
		name = nil,
		health = nil
	}
end


local GameConfigs = {

	[1008451066] = {
		Name = "Da Hood",
		Updater = nil,
		RemotePath = function() return rep:WaitForChild("MainEvent") end,
		EventName = "ShootGun"
	},

	[9177263517] = {
		Name = "Der Hood",
		Updater = "D3RHooDMSOUEPoS233^+",
		RemotePath = function() return rep:WaitForChild("MainRemotes"):WaitForChild("MainRemoteEvent") end,
		EventName = "ShootGun",
		FireServer = function(remoteEvent, payload)
			local position = payload.targetPosition or payload.hitPosition or payload.legitimatePosition or payload.forcedOrigin
			remoteEvent:FireServer("D3RHooDMSOUEPoS233^+", position)
		end
	},

	[9177255570] = {
		Name = "Zee Hood",
		Updater = "ZEEHOODMOUSEPOSx3^3",
		RemotePath = function() return rep:WaitForChild("MainRemotes"):WaitForChild("MainRemoteEvent") end,
		FireServer = function(remoteEvent, payload)
			local position = payload.targetPosition or payload.hitPosition or vector3New(0, 0, 0)
			game:GetService("ReplicatedStorage").MainRemotes.MainRemoteEvent:FireServer("ZEEHOODMOUSEPOSx3^3", position)
		end
	},

	[9103711799] = {
		Name = "Pain Hood",
		Updater = "DurrHooDmOussePosition144125+*-",
		RemotePath = function()
			return rep:WaitForChild("MainRemotes"):WaitForChild("MainRemoteEvent")
		end,
		EventName = "ShootGun",
		FireServer = function(remoteEvent, payload)
			local position = payload.targetPosition or payload.hitPosition or payload.legitimatePosition or payload.forcedOrigin or vector3Zero
			remoteEvent:FireServer("DurrHooDmOussePosition144125+*-", position)
		end
	},

	[9196471662] = {
		Name = "Dee Hood",
		Updater = "b55164746",
		RemotePath = function() return rep:WaitForChild("MainEvent") end,
		EventName = "ShootGun",
		FireServer = function(remoteEvent, payload)
			local position = payload.targetPosition or payload.hitPosition or payload.legitimatePosition or payload.forcedOrigin or vector3Zero
			remoteEvent:FireServer(payload.updater, position)
		end
	},

	[9196894486] = {
		Name = "Das Hood",
		RemotePath = function() return rep:WaitForChild("MainEvent") end,
		EventName = "ShootGun",
		FireServer = function(remoteEvent, payload)
			local position = payload.targetPosition or payload.hitPosition or payload.legitimatePosition or payload.forcedOrigin or vector3Zero
			local args = {"UpdateMousePos", position}
			remoteEvent:FireServer(unpack(args))
			
			local toolEvent = payload.tool and payload.tool:FindFirstChild("RemoteEvent")
			if toolEvent then
				task.wait(0.001)
				toolEvent:FireServer("Shoot")
				task.wait(0.001)
				toolEvent:FireServer()
			end
		end
	},

	[9072755042] = {
		Name = "Da Strike",
		RemotePath = function() return rep:WaitForChild("MAINEVENT") end,
		EventName = "ShootGun",
		FireServer = function(remoteEvent, payload)
			local position = payload.targetPosition or payload.hitPosition or payload.legitimatePosition or payload.forcedOrigin or vector3Zero
			local args = {"MOUSE", position}
			remoteEvent:FireServer(unpack(args))
			
			local toolEvent = payload.tool and payload.tool:FindFirstChild("RemoteEvent")
			if toolEvent then
				task.wait(0.001)
				toolEvent:FireServer("Shoot")
				task.wait(0.001)
				toolEvent:FireServer()
			end
		end
	},

}

local CurrentGame = GameConfigs[game.GameId]
if not CurrentGame then
	CurrentGame = {
		Name = "Unknown",
		Updater = nil,
		RemotePath = function() return rep:FindFirstChild("MainEvent") end,
		EventName = "ShootGun"
	}
end


if CurrentGame and CurrentGame.Name == "Dee Hood" then
	task.spawn(LPH_NO_VIRTUALIZE(function()
		task.wait(3)

		pcall(function()
			local foundUpdaters = {}

			for i, v in pairs(getgc(true)) do
				if type(v) == "function" then

					local success, constants = pcall(getconstants, v)
					if success and constants then
						for _, constant in pairs(constants) do
							if type(constant) == "string" and #constant == 9 and constant:sub(1,1) == "b" and constant:match("^[a-z0-9]+$") then
								local letterCount, numberCount = 0, 0
								for j = 1, #constant do
									local char = constant:sub(j,j)
									if char:match("[a-z]") then letterCount = letterCount + 1 end
									if char:match("[0-9]") then numberCount = numberCount + 1 end
								end

								if letterCount > 0 and numberCount > 0 and constant ~= "b55164746" then
									foundUpdaters[constant] = true
								end
							end
						end
					end

					local success2, upvalues = pcall(debug.getupvalues, v)
					if success2 and upvalues then
						for _, upvalue in pairs(upvalues) do
							if type(upvalue) == "string" and #upvalue == 9 and upvalue:sub(1,1) == "b" and upvalue:match("^[a-z0-9]+$") then
								local letterCount, numberCount = 0, 0
								for j = 1, #upvalue do
									local char = upvalue:sub(j,j)
									if char:match("[a-z]") then letterCount = letterCount + 1 end
									if char:match("[0-9]") then numberCount = numberCount + 1 end
								end
								if letterCount > 0 and numberCount > 0 and upvalue ~= "b55164746" then
									foundUpdaters[upvalue] = true
								end
							end
						end
					end
				end
			end

			for updater, _ in pairs(foundUpdaters) do
				CurrentGame.Updater = updater
				return
			end
		end)
	end))
end

local WeaponInfo = {
	Shotguns = {"[Shotgun]", "[Double-Barrel SG]", "[TacticalShotgun]"},
	AutomaticShotgun = {"[Drum-Shotgun]"},
	Pistols = {"[Glock]", "[Silencer]", "[Revolver]"},
	["Assault Rifles"] = {"[AK47]", "[AR]", "[DrumGun]", "[SilencerAR]", "[LMG]"},
	Bursts = {"[AUG]"},
	SMG = {"[P90]", "[SMG]"},
	Rifle = {"[Rifle]"},
	Offsets = {
		["[Shotgun]"] = CFrame.new(0, 0.25, -2.5),
		["[Double-Barrel SG]"] = CFrame.new(0, 0.35, -2.2),
		["[TacticalShotgun]"] = CFrame.new(0, 0.25, -2.5),
		["[Drum-Shotgun]"] = CFrame.new(-0.1, 0.5, -2.5),
		["[Glock]"] = CFrame.new(0.6, 0.25, 0),
		["[Silencer]"] = CFrame.new(0, 0.4, 1.3),
		["[Revolver]"] = CFrame.new(-1, 0.4, 0),
		["[AK47]"] = CFrame.new(-0.1, 0.5, -2.5),
		["[AR]"] = CFrame.new(2, 0.35, 0),
		["[DrumGun]"] = CFrame.new(0, 0.4, 2.4),
		["[SilencerAR]"] = CFrame.new(2.5, 0.35, 0),
		["[LMG]"] = CFrame.new(0, 0.7, -3.8),
		["[AUG]"] = CFrame.new(-0.1, 0.4, 1.8),
		["[P90]"] = CFrame.new(0, 0.2, -1.7),
		["[SMG]"] = CFrame.new(0, 1, 0.5),
		["[Rifle]"] = CFrame.new(0, 0.25, 2.5)
	},
	Delays = {
		["[Shotgun]"] = 1.2,
		["[Double-Barrel SG]"] = 0.0595,
		["[TacticalShotgun]"] = 0.0095,
		["[Drum-Shotgun]"] = 0.415,
		["[Glock]"] = 0.0095,
		["[Silencer]"] = 0.0095,
		["[Revolver]"] = 0.0095,
		["[AK47]"] = 0.15,
		["[AR]"] = 0.15,
		["[DrumGun]"] = 0.15,
		["[SilencerAR]"] = 0.02,
		["[LMG]"] = 0.62,
		["[Rifle]"] = 1.3095,
		["[AUG]"] = 0.0095,
		["[P90]"] = 0.6,
		["[SMG]"] = 0.6
	}
}


local lastShotTicks = {}
local silentAimEmulationEnabled = true

updateConfigCache = LPH_NO_VIRTUALIZE(function()
	local now = osTime()
	if now - cacheUpdateTime > CONFIG_CACHE_DURATION then
		cachedAimAssistConfig = Config['Aim Assist']
		cachedTargetChecksConfig = Config['Target Checks']
		cachedSelfChecksConfig = Config['Self Checks']
		cacheUpdateTime = now
	end
end)

getKey = function(key)
	if not key or type(key) ~= "string" then
		return Enum.KeyCode.Unknown, false
	end
	if key:match("MouseButton") then
		if key == "MouseButton1" then
			return Enum.UserInputType.MouseButton1, true
		elseif key == "MouseButton2" then
			return Enum.UserInputType.MouseButton2, true
		elseif key == "MouseButton3" then
			return Enum.UserInputType.MouseButton3, true
		end
		return Enum.UserInputType.MouseButton1, true
	end

	local keyCode = getKeyCodeFromString and getKeyCodeFromString(key)
	return keyCode or Enum.KeyCode.Unknown, false
end

inputMatches = function(inputObject, keyOrType, isMouseButton)
	if not keyOrType then
		return false
	end
	if isMouseButton then
		return inputObject.UserInputType == keyOrType
	end
	if keyOrType == Enum.KeyCode.Unknown then
		return false
	end
	return inputObject.KeyCode == keyOrType
end

local forcefieldCache = {}
local forcefieldCacheTime = {}
local wallCheckCache = {}
local wallCheckCacheTime = {}
local CACHE_DURATION = 0.1
local WALLCHECK_CACHE_DURATION = 0.1

hasForcefield = LPH_NO_VIRTUALIZE(function(char)
	if not Config['Target Checks']['Forcefield'] then
		return false
	end
	local now = osTime()
	local cached = forcefieldCache[char]
	if cached ~= nil and forcefieldCacheTime[char] and (now - forcefieldCacheTime[char]) < CACHE_DURATION then
		return cached
	end
	local hasFF = char:FindFirstChildOfClass("ForceField") ~= nil
	forcefieldCache[char] = hasFF
	forcefieldCacheTime[char] = now
	return hasFF
end)

isKnocked = LPH_NO_VIRTUALIZE(function(char)
	if not char then
		return false
	end
	local bodyEffects = char:FindFirstChild('BodyEffects')
	if bodyEffects and bodyEffects:FindFirstChild('K.O') then
		return bodyEffects['K.O'].Value == true
	end
	return false
end)

isGrabbed = LPH_NO_VIRTUALIZE(function(char)
	if not char then
		return false
	end
	return char:FindFirstChild('GRABBING_CONSTRAINT') ~= nil
end)

isSelfKnocked = LPH_NO_VIRTUALIZE(function()
	if not Config or not Config['Self Checks'] or not Config['Self Checks']['Knocked'] then
		return false
	end
	if not plr or not plr.Character then
		return false
	end
	return isKnocked(plr.Character)
end)

isSelfGrabbed = LPH_NO_VIRTUALIZE(function()
	if not Config or not Config['Self Checks'] or not Config['Self Checks']['Grabbed'] then
		return false
	end
	if not plr or not plr.Character then
		return false
	end
	return isGrabbed(plr.Character)
end)

isSelfForcefield = LPH_NO_VIRTUALIZE(function()
	if not Config or not Config['Self Checks'] or not Config['Self Checks']['Forcefield'] then
		return false
	end
	if not plr or not plr.Character then
		return false
	end
	return hasForcefield(plr.Character)
end)

canUseFeatures = LPH_NO_VIRTUALIZE(function()
	if not plr or not plr.Character then
		return false
	end
	if isSelfKnocked() then
		return false
	end
	if isSelfGrabbed() then
		return false
	end
	if isSelfForcefield() then
		return false
	end
	return true
end)

isInFirstPerson = LPH_NO_VIRTUALIZE(function()
	if not plr.Character or not plr.Character:FindFirstChild("Head") then
		return false
	end
	local delta = cam.CFrame.Position - plr.Character.Head.Position
	return delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z < 4
end)

isValidCameraMode = LPH_NO_VIRTUALIZE(function()
	local isFP = isInFirstPerson()
	local thirdPersonEnabled = Config['Aim Assist']['Camera Mode']['Third Person']
	local firstPersonEnabled = Config['Aim Assist']['Camera Mode']['First Person']
	if isFP then
		return firstPersonEnabled
	else
		return thirdPersonEnabled
	end
end)

isFirstPersonOrShiftLock = LPH_NO_VIRTUALIZE(function()
	local character = plr.Character
	if not character then
		return false
	end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local delta = cam.CFrame.Position - hrp.Position
		if delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z < 4 then
			return true
		end
	end
	return uis.MouseBehavior == Enum.MouseBehavior.LockCenter
end)

sanitizeNumber = function(value, defaultValue, minValue, maxValue)
	value = tonumber(value)
	if not value or value ~= value or value == mathHuge or value == -mathHuge then
		return defaultValue
	end
	if minValue and value < minValue then
		value = minValue
	end
	if maxValue and value > maxValue then
		value = maxValue
	end
	return value
end

calculateFovDimensions = LPH_NO_VIRTUALIZE(function(fovConfig)
	fovConfig = fovConfig or {}
	local currentCamera = workspace.CurrentCamera or cam
	if currentCamera and currentCamera ~= cam then
		cam = currentCamera
	end
	local viewportHeight = (cam and cam.ViewportSize and cam.ViewportSize.Y) or 720
	if viewportHeight <= 0 then
		viewportHeight = 720
	end

	local fovType = fovConfig['FOV Type'] or 'Box'
	if fovType == 'Circle' then
		local fovValue = sanitizeNumber(fovConfig['Circle Value'], 45, 1, 179)
		local fovRadians = mathRad(fovValue)
		local tanValue = mathTan(fovRadians * 0.5)
		if not tanValue or tanValue ~= tanValue or tanValue == mathHuge or tanValue == -mathHuge then
			tanValue = mathTan(mathRad(45) * 0.5)
		end
		local rawRadius = (viewportHeight * 0.5) * tanValue
		local maxRadius = viewportHeight * 2
		local radius = mathClamp(mathAbs(rawRadius), 4, maxRadius)
		return {
			radius = radius
		}
	else
		local boxConfig = fovConfig['Box'] or {}
		local boxX = sanitizeNumber(boxConfig['X'], 25, 1, 179)
		local boxY = sanitizeNumber(boxConfig['Y'], 25, 1, 179)
		local boxAngle = mathMax(boxX, boxY)
		local boxRadians = mathRad(boxAngle)
		local tanValue = mathTan(boxRadians * 0.5)
		if not tanValue or tanValue ~= tanValue or tanValue == mathHuge or tanValue == -mathHuge then
			tanValue = mathTan(mathRad(25) * 0.5)
		end
		local rawSize = viewportHeight * mathAbs(tanValue)
		local maxSize = viewportHeight * 4
		local clampedSize = mathClamp(mathMax(rawSize, 8), 8, maxSize)
		return {
			width = clampedSize,
			height = clampedSize
		}
	end
end)

isWithinFov = LPH_NO_VIRTUALIZE(function(targetChar, fovConfig, mousePos)
	if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
		return false
	end
	local hrp = targetChar:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return false
	end
	local mousePosition = mousePos or uis:GetMouseLocation()
	local screenPos, visible = cam:WorldToViewportPoint(hrp.Position)
	if not visible or screenPos.Z <= 0 then
		return false
	end
	local fovType = fovConfig['FOV Type'] or 'Box'
	local dimensions = calculateFovDimensions(fovConfig)
	if fovType == 'Circle' then
		local dx = screenPos.X - mousePosition.X
		local dy = screenPos.Y - mousePosition.Y
		return dx * dx + dy * dy <= dimensions.radius * dimensions.radius
	else
		local halfWidth = dimensions.width * 0.5
		local halfHeight = dimensions.height * 0.5
		local deltaX = mathAbs(mousePosition.X - screenPos.X)
		local deltaY = mathAbs(mousePosition.Y - screenPos.Y)
		return deltaX <= halfWidth and deltaY <= halfHeight
	end
end)

validChar = LPH_NO_VIRTUALIZE(function(char)
	if not char or not char.Parent then
		return false
	end
	if Config['Target Checks']['Forcefield'] and hasForcefield(char) then
		return false
	end
	if Config['Target Checks']['Knocked'] and isKnocked(char) then
		return false
	end
	if Config['Target Checks']['Grabbed'] and isGrabbed(char) then
		return false
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return false
	end
	return char:FindFirstChild("HumanoidRootPart") ~= nil
end)

wallCheck = LPH_NO_VIRTUALIZE(function(targetPart)
	if not Config or not Config['Target Checks'] or not Config['Target Checks']['Wall'] then
		return true
	end

	if not targetPart or not targetPart.Parent then
		return false
	end

	if not plr or not plr.Character then
		return false
	end

	local now = osTime()
	local cached = wallCheckCache[targetPart]
	if cached ~= nil and wallCheckCacheTime[targetPart] and (now - wallCheckCacheTime[targetPart]) < WALLCHECK_CACHE_DURATION then
		return cached
	end

	local origin = cam.CFrame.Position
	local targetPos = targetPart.Position
	local direction = (targetPos - origin).Unit
	local distance = (targetPos - origin).Magnitude

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {
		plr.Character
	}
	raycastParams.IgnoreWater = true

	local result = workspace:Raycast(origin, direction * distance, raycastParams)

	local isVisible = true
	if result then
		if result.Instance:IsDescendantOf(targetPart.Parent) then
			isVisible = true
		else
			isVisible = false
		end
	end

	wallCheckCache[targetPart] = isVisible
	wallCheckCacheTime[targetPart] = now
	return isVisible
end)

getClosestPointOnPart = LPH_NO_VIRTUALIZE(function(part, scale)
	if not part then
		return vector3New(0, 0, 0)
	end
	if not part:IsA("BasePart") then
		local success, pos = pcall(function()
			return part.Position
		end)
		if success and pos then
			return pos
		end
		return vector3New(0, 0, 0)
	end
	local partCFrame = part.CFrame
	local partSize = part.Size
	local scaleValue = (scale or 0.5) * 0.5
	local partSizeTransformed = partSize * scaleValue
	local mousePosition = uis:GetMouseLocation()
	local mouseRay = cam:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	local transformed = partCFrame:PointToObjectSpace(mouseRay.Origin + (mouseRay.Direction * mouseRay.Direction:Dot(partCFrame.Position - mouseRay.Origin)))
	if mouse.Target == part then
		return vector3New(mouse.Hit.X, mouse.Hit.Y, mouse.Hit.Z)
	end
	return partCFrame * vector3New(
		mathClamp(transformed.X, - partSizeTransformed.X, partSizeTransformed.X), mathClamp(transformed.Y, - partSizeTransformed.Y, partSizeTransformed.Y), mathClamp(transformed.Z, - partSizeTransformed.Z, partSizeTransformed.Z))
end)

getClosestPointOnPartBasic = LPH_NO_VIRTUALIZE(function(part)
	if not part then
		return Vector3.new(0, 0, 0)
	end
	if not part:IsA("BasePart") then
		local success, pos = pcall(function()
			return part.Position
		end)
		if success and pos then
			return pos
		end
		return Vector3.new(0, 0, 0)
	end
	local mouseRay = mouse.UnitRay
	mouseRay = mouseRay.Origin + (mouseRay.Direction * (part.Position - mouseRay.Origin).Magnitude)
	local point = (mouseRay.Y >= (part.Position - part.Size / 2).Y and mouseRay.Y <= (part.Position + part.Size / 2).Y) and (part.Position + Vector3.new(0, - part.Position.Y + mouseRay.Y, 0)) or part.Position
	local check = RaycastParams.new()
	check.FilterType = Enum.RaycastFilterType.Whitelist
	check.FilterDescendantsInstances = {
		part
	}
	local ray = workspace:Raycast(mouseRay, (point - mouseRay), check)
	if mouse.Target == part then
		return mouse.Hit.Position
	end
	if ray then
		return ray.Position
	else
		return mouse.Hit.Position
	end
end)

getClosestPoint = LPH_NO_VIRTUALIZE(function(part, useCameraDirection, scale)
	if not part then
		return vector3New(0, 0, 0)
	end
	if not part:IsA("BasePart") then
		local success, pos = pcall(function()
			return part.Position
		end)
		if success and pos then
			return pos
		end
		return vector3New(0, 0, 0)
	end
	if useCameraDirection then
		local mousePos = uis:GetMouseLocation()
		local mouseRay = cam:ScreenPointToRay(mousePos.X, mousePos.Y)
		local rayOrigin = mouseRay.Origin
		local rayDirection = mouseRay.Direction
		local partCFrame = part.CFrame
		local partSize = part.Size
		local scaleValue = (scale or 0.5) * 0.5
		local partSizeTransformed = partSize * scaleValue
		local transformed = partCFrame:PointToObjectSpace(rayOrigin + (rayDirection * rayDirection:Dot(partCFrame.Position - rayOrigin)))
		return partCFrame * vector3New(
            mathClamp(transformed.X, - partSizeTransformed.X, partSizeTransformed.X), mathClamp(transformed.Y, - partSizeTransformed.Y, partSizeTransformed.Y), mathClamp(transformed.Z, - partSizeTransformed.Z, partSizeTransformed.Z))
	else
		return getClosestPointOnPart(part, scale or 0.5)
	end
end)

applyPrediction = LPH_NO_VIRTUALIZE(function(part, position, predictionSettings)
	if not part then
		return position
	end
	if not predictionSettings then
		if Config and Config['Aim Assist'] and Config['Aim Assist']['Hit Target'] and Config['Aim Assist']['Hit Target']['Prediction'] then
			predictionSettings = Config['Aim Assist']['Hit Target']['Prediction']
		else
			return position
		end
	end
	if not predictionSettings then
		return position
	end
	local velocity = part.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
	return position + Vector3.new(
		velocity.X * (predictionSettings.X or 0), velocity.Y * (predictionSettings.Y or 0), velocity.Z * (predictionSettings.Z or 0))
end)

resetHumanizerState = function()
	humanizerState.currentOffset = vector3Zero
	humanizerState.targetOffset = vector3Zero
	humanizerState.elapsed = 0
	humanizerState.lastStep = osTime()
end

randomizeHumanizerAxis = function(range)
	range = mathAbs(range or 0)
	if range <= 0 then
		return 0
	end
	return (math.random() * 2 - 1) * range
end

resolveHumanizerSample = function(entry)
	if type(entry) ~= "table" then
		return vector3Zero
	end
	local xRange = entry['X'] or entry[1] or 0
	local yRange = entry['Y'] or entry[2] or 0
	local zRange = entry['Z'] or entry[3] or 0
	return vector3New(
		randomizeHumanizerAxis(xRange),
		randomizeHumanizerAxis(yRange),
		randomizeHumanizerAxis(zRange)
	)
end

chooseHumanizerTarget = function(samples)
	if type(samples) ~= "table" or # samples == 0 then
		return vector3Zero
	end
	local totalWeight = 0
	for _, entry in ipairs(samples) do
		local weight = tonumber(entry['Weight'] or entry[4] or 1) or 1
		if weight > 0 then
			totalWeight = totalWeight + weight
		end
	end
	if totalWeight <= 0 then
		return resolveHumanizerSample(samples[math.random(1, # samples)])
	end
	local threshold = math.random() * totalWeight
	local accumulated = 0
	for _, entry in ipairs(samples) do
		local weight = tonumber(entry['Weight'] or entry[4] or 1) or 1
		if weight > 0 then
			accumulated = accumulated + weight
			if threshold <= accumulated then
				return resolveHumanizerSample(entry)
			end
		end
	end
	return resolveHumanizerSample(samples[# samples])
end

getHumanizerOffset = function(isActive)
	local aimAssistConfig = Config and Config['Aim Assist']
	local humanizerConfig = aimAssistConfig and aimAssistConfig['Humanizer']
	if not isActive or not humanizerConfig or not humanizerConfig['Enabled'] then
		resetHumanizerState()
		return vector3Zero
	end

	local now = osTime()
	local delta = mathClamp(now - (humanizerState.lastStep or now), 0, 1)
	humanizerState.lastStep = now
	humanizerState.elapsed = (humanizerState.elapsed or 0) + delta

	local interval = 0.14
	interval = mathClamp(interval, 0.02, 0.6)
	if humanizerState.elapsed >= interval then
		humanizerState.elapsed = humanizerState.elapsed - interval
		humanizerState.targetOffset = chooseHumanizerTarget(humanizerConfig['Samples'])
	end

	local smoothingSpeed = 18
	smoothingSpeed = mathClamp(smoothingSpeed, 1, 60)
	local alpha = 1 - mathExp(- delta * smoothingSpeed)

	local current = humanizerState.currentOffset
	local target = humanizerState.targetOffset
	humanizerState.currentOffset = vector3New(
		current.X + (target.X - current.X) * alpha,
		current.Y + (target.Y - current.Y) * alpha,
		current.Z + (target.Z - current.Z) * alpha
	)
	return humanizerState.currentOffset
end

getAllPlayers = LPH_NO_VIRTUALIZE(function()
	local chars = {}
	local count = 0
	for _, player in ipairs(players:GetPlayers()) do
		if player ~= plr and player.Character and validChar(player.Character) then
			count = count + 1
			chars[count] = player.Character
		end
	end
	local botsFolder = workspace:FindFirstChild('Bots')
	if botsFolder then
		for _, bot in ipairs(botsFolder:GetChildren()) do
			if bot:FindFirstChild('Humanoid') and bot:FindFirstChild('HumanoidRootPart') and validChar(bot) then
				count = count + 1
				chars[count] = bot
			end
		end
	end
	return chars
end)

getCharacters = LPH_NO_VIRTUALIZE(function()
	local now = osTime()
	if now - lastUpdate > 0.5 then
		characterList = getAllPlayers()
		lastUpdate = now
	end
	return characterList
end)

findTarget = LPH_NO_VIRTUALIZE(function(char, useCameraDirection)
	if not char then
		return nil, nil
	end
	local hitTarget = Config['Aim Assist']['Hit Target']['Hit Part']
	local bestPart, bestPos, bestDist = nil, nil, mathHuge
	local rayOrigin, rayDirection
	if useCameraDirection then
		local camCF = cam.CFrame
		rayOrigin = camCF.Position
		rayDirection = camCF.LookVector
	else
		local mousePos = uis:GetMouseLocation()
		local mouseRay = cam:ScreenPointToRay(mousePos.X, mousePos.Y)
		rayOrigin = mouseRay.Origin
		rayDirection = mouseRay.Direction
	end
	if hitTarget ~= "Closest Point" and hitTarget ~= "Closest Part" then
		local part = char:FindFirstChild(hitTarget)
		if part and part:IsA("BasePart") and wallCheck(part) then
			if hitTarget == "Closest Point" then
				bestPos = getClosestPoint(part, useCameraDirection)
			else
				bestPos = part.Position
			end
			return part, bestPos
		end
		return nil, nil
	end
	if hitTarget == "Closest Point" then
		local mousePos = uis:GetMouseLocation()
		local closestScreenDist = mathHuge
		for _, partName in ipairs(bodyParts) do
			local part = char:FindFirstChild(partName)
			if part and part:IsA("BasePart") and wallCheck(part) then
				local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
				if onScreen and screenPos.Z > 0 then
					local dx = screenPos.X - mousePos.X
					local dy = screenPos.Y - mousePos.Y
					local screenDist = dx * dx + dy * dy
					if screenDist < closestScreenDist then
						closestScreenDist = screenDist
						bestPart = part
					end
				end
			end
		end
		if bestPart then
			bestPos = getClosestPoint(bestPart, useCameraDirection)
		end
	else
		for _, partName in ipairs(bodyParts) do
			local part = char:FindFirstChild(partName)
			if part and part:IsA("BasePart") then
				if wallCheck(part) then
					local pos = part.Position
					local pointToRay = pos - rayOrigin
					local projectionLength = pointToRay:Dot(rayDirection)
					local closestPointOnRay = rayOrigin + rayDirection * projectionLength
					local distanceToRay = (pos - closestPointOnRay).Magnitude
					if distanceToRay < bestDist then
						bestDist = distanceToRay
						bestPart = part
						bestPos = pos
					end
				end
			end
		end
	end
	return bestPart, bestPos
end)

getBestTarget = LPH_NO_VIRTUALIZE(function()
	local chars = getCharacters()
	local bestChar, bestPart, bestPos = nil, nil, nil
	local closestDist = mathHuge
	local mousePos = uis:GetMouseLocation()
	for _, char in ipairs(chars) do
		local part, pos = findTarget(char, false)
		if part and pos then
			local screenPos = cam:WorldToViewportPoint(pos)
			if screenPos.Z > 0 then
				local dx = screenPos.X - mousePos.X
				local dy = screenPos.Y - mousePos.Y
				local dist = dx * dx + dy * dy
				if dist < closestDist then
					closestDist = dist
					bestChar = char
					bestPart = part
					bestPos = pos
				end
			end
		end
	end
	return bestChar, bestPart, bestPos
end)

resolveTargetCharacter = function(target)
	if not target then
		return nil
	end
	if type(target) == 'table' and target.Character then
		return target.Character
	end
	if typeof(target) == 'Instance' then
		if target:IsA('Player') then
			return target.Character
		elseif target:IsA('Model') then
			return target
		end
	end
	return nil
end

clearSilentAimTargetState = LPH_NO_VIRTUALIZE(function(forceSharedCleanup)
	local oldTargetChar = resolveTargetCharacter(silentAimTarget)
	silentAimTarget = nil
	silentAimLocked = false
	if silentTargetLine then
		silentTargetLine.Visible = false
	end
	if Config and Config['Main'] and Config['Main']['Sync'] and (forceSharedCleanup or oldTargetChar) then
		if forceSharedCleanup or sharedTarget == oldTargetChar then
			sharedTarget = nil
		end
		if oldTargetChar and Config['Aim Assist']['Enabled'] and cameraAimbotTarget == oldTargetChar and not cameraAimbotLocked then
			cameraAimbotTarget = nil
		end
		if oldTargetChar and TriggerBotConfig['Enabled'] and triggerBotTarget == oldTargetChar and not triggerBotLocked then
			triggerBotTarget = nil
		end
	end
end)

getSilentAimTargetInfo = LPH_NO_VIRTUALIZE(function(targetEntity, options)
	if not targetEntity then
		return nil
	end
	options = options or {}
	local preferHead = options.preferHead
	local targetChar = resolveTargetCharacter(targetEntity)
	if not targetChar or not targetChar.Parent then
		return nil
	end
	local hitTarget = SilentAimConfig['Hit Target'] or {}
	local hitPartOption = preferHead and 'Head' or (hitTarget['Hit Part'] or 'Closest Point')
	local resolverTarget
	if type(targetEntity) == 'table' and targetEntity.Character then
		resolverTarget = targetEntity
	else
		local resolverName
		if type(targetEntity) == 'table' then
			resolverName = targetEntity.Name
		elseif typeof(targetEntity) == 'Instance' then
			resolverName = targetEntity.Name
		end
		resolverTarget = {
			Character = targetChar,
			Name = resolverName or (targetChar and targetChar.Name) or 'Target'
		}
	end
	local selectedPart
	if hitPartOption == 'Closest Point' or hitPartOption == 'Closest Part' then
		selectedPart = resolverTarget and select(1, getClosestBodyPartSilent(resolverTarget)) or nil
	else
		selectedPart = targetChar:FindFirstChild(hitPartOption)
	end
	if (not selectedPart or (preferHead and selectedPart.Name ~= 'Head')) then
		selectedPart = targetChar:FindFirstChild('Head') or targetChar:FindFirstChild('HumanoidRootPart')
	end
	if not selectedPart then
		return nil
	end
	local basePosition
	if hitPartOption == 'Closest Point' then
		basePosition = getClosestPoint(selectedPart, false)
	else
		basePosition = selectedPart.Position
	end
	local hrp = targetChar:FindFirstChild('HumanoidRootPart')
	local velocity = hrp and hrp.AssemblyLinearVelocity or vector3New(0, 0, 0)
	local predConfig = SilentAimConfig['Prediction'] or {}
	local predictedPosition = basePosition + vector3New(
		velocity.X * (predConfig['X'] or 0),
		velocity.Y * (predConfig['Y'] or 0),
		velocity.Z * (predConfig['Z'] or 0)
	)
	return predictedPosition, basePosition, selectedPart
end)

players.PlayerRemoving:Connect(function(player)
	if not silentAimTarget then
		return
	end
	if silentAimTarget == player then
		clearSilentAimTargetState()
		return
	end
	local targetChar = resolveTargetCharacter(silentAimTarget)
	if targetChar and player.Character and targetChar == player.Character then
		clearSilentAimTargetState()
	end
end)

getGunBarrelSilent = LPH_NO_VIRTUALIZE(function()
	local char = plr.Character
	if not char then
		return nil
	end
	for _, tool in pairs(char:GetChildren()) do
		if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
			return tool.Handle
		end
	end
	return nil
end)

calculate3DAngleSilent = LPH_NO_VIRTUALIZE(function(origin, direction, targetPos)
	local toTarget = (targetPos - origin).Unit
	local dotProduct = direction:Dot(toTarget)
	dotProduct = math.clamp(dotProduct, -1, 1)
	local angleRadians = math.acos(dotProduct)
	return math.deg(angleRadians)
end)

evaluateAntiCurve = function(forcedOrigin, predictedPosition, legitDirection)
	local antiCurveConfig = SilentAimConfig and SilentAimConfig['Anti Curve']
	if not antiCurveConfig or not antiCurveConfig['Enabled'] then
		return true, nil
	end
	if not forcedOrigin or not predictedPosition or not legitDirection then
		return true, nil
	end
	local mode = antiCurveConfig['Mode'] or 'Angles'
	if mode ~= 'Angles' then
		return true, nil
	end
	local anglesConfig = antiCurveConfig['Angles'] or {}
	local maxAngle = sanitizeNumber(anglesConfig['Max Angle'], 12, 0, 180)
	local distanceThreshold = sanitizeNumber(anglesConfig['Distance Threshold'], 100, 0, 1000)
	local visualize = shouldVisualizeAntiCurve()
	local currentAngle = calculate3DAngleSilent(forcedOrigin, legitDirection, predictedPosition)
	local currentDistance = (predictedPosition - forcedOrigin).Magnitude
	local redirect = currentAngle <= maxAngle and currentDistance <= distanceThreshold
	local overlayInfo = nil
	if visualize then
		overlayInfo = {
			maxAngle = maxAngle,
			currentAngle = currentAngle,
			distanceThreshold = distanceThreshold,
			currentDistance = currentDistance,
			redirect = redirect
		}
	end
	return redirect, overlayInfo
end

getClosestBodyPartSilent = LPH_NO_VIRTUALIZE(function(player)
	if not player or not player.Character then
		return nil
	end
	if not validChar(player.Character) then
		return nil
	end
	local mousePos = uis:GetMouseLocation()
	local closestPart = nil
	local closestDistance = mathHuge
	for _, partName in pairs(bodyParts) do
		local part = player.Character:FindFirstChild(partName)
		if part and wallCheck(part) then
			local worldPos = part.CFrame.Position
			local screenPos, onScreen = cam:WorldToViewportPoint(worldPos)
			if onScreen and screenPos.Z > 0 then
				local deltaX = mousePos.X - screenPos.X
				local deltaY = mousePos.Y - screenPos.Y
				local distance = deltaX * deltaX + deltaY * deltaY
				if distance < closestDistance then
					closestDistance = distance
					closestPart = part
				end
			end
		end
	end
	if not closestPart then
		for _, part in ipairs(player.Character:GetChildren()) do
			if part:IsA("BasePart") and wallCheck(part) then
				local worldPos = part.Position
				local screenPos, onScreen = cam:WorldToViewportPoint(worldPos)
				if onScreen and screenPos.Z > 0 then
					local deltaX = mousePos.X - screenPos.X
					local deltaY = mousePos.Y - screenPos.Y
					local distance = deltaX * deltaX + deltaY * deltaY
					if distance < closestDistance then
						closestDistance = distance
						closestPart = part
					end
				end
			end
		end
	end
	return closestPart, closestDistance
end)

if type(getClosestBodyPartSilent) ~= "function" then
	getClosestBodyPartSilent = function()
		return nil, nil
	end
end

getClosestPlayerSilent = LPH_NO_VIRTUALIZE(function(fovConfig, enforceFov)
	local bodyPartResolver = getClosestBodyPartSilent
	if type(bodyPartResolver) ~= "function" then
		return nil
	end
	local mousePos = uis:GetMouseLocation()
	local shouldCheckFov = enforceFov and type(fovConfig) == "table"
	local fovSettings = fovConfig or {}
	local function passesFov(targetChar)
		if not shouldCheckFov then
			return true
		end
		return isWithinFov(targetChar, fovSettings, mousePos)
	end
	local closestPlayer = nil
	local closestDistance = mathHuge
	for _, player in pairs(players:GetPlayers()) do
		if player ~= plr and player.Character and validChar(player.Character) then
			if passesFov(player.Character) then
				local part, distance = bodyPartResolver(player)
				if part and distance and distance < closestDistance then
					closestPlayer = player
					closestDistance = distance
				end
			end
		end
	end
	local botsFolder = workspace:FindFirstChild('Bots')
	if botsFolder then
		for _, bot in ipairs(botsFolder:GetChildren()) do
			if bot.Name == 'Dummy' and bot:IsA('Model') and validChar(bot) then
				if passesFov(bot) then
					local part, distance = bodyPartResolver({
						Character = bot
					})
					if part and distance and distance < closestDistance then
						closestPlayer = {
							Character = bot,
							Name = 'Dummy'
						}
						closestDistance = distance
					end
				end
			end
		end
	end
	return closestPlayer
end)

setupCharacterToolHooks = function(character)
	local function hookTool(child)
		if not child:IsA("Tool") or not WeaponInfo.Delays[child.Name] then
			return
		end
		local toolActivated
		toolActivated = child.Activated:Connect(function()
			if triggerBotFiring or silentAimFiring then
				return
			end
			if not SilentAimConfig or not SilentAimConfig['Enabled'] then
				return
			end
			silentAimFiring = true
			local shotTarget = triggerBotOverrideTarget or sharedTarget
			if not shotTarget and triggerBotTarget and validChar(triggerBotTarget) then
				shotTarget = players:GetPlayerFromCharacter(triggerBotTarget) or {
					Character = triggerBotTarget,
					Name = triggerBotTarget.Name or 'Target'
				}
			end
			if not shotTarget and silentAimTarget then
				local targetChar = resolveTargetCharacter(silentAimTarget)
				if targetChar and validChar(targetChar) then
					shotTarget = silentAimTarget
				end
			end
			if not shotTarget and SilentAimConfig['Target Mode'] ~= 'Target' then
				local closestSilent = getClosestPlayerSilent(SilentAimConfig and SilentAimConfig['FOV'], true)
				if closestSilent then
					shotTarget = closestSilent
				end
			end
			attemptSilentAimShot(child, character, shotTarget)
			if triggerBotOverrideTarget then
				triggerBotOverrideTarget = nil
			end
			task.wait(0.05)
			silentAimFiring = false
		end)

		child.AncestryChanged:Connect(function()
			if not child.Parent then
				if toolActivated then
					toolActivated:Disconnect()
				end
			end
		end)
	end

	character.ChildAdded:Connect(hookTool)
	for _, child in ipairs(character:GetChildren()) do
		hookTool(child)
	end
end

destroyFovVisualizer = LPH_NO_VIRTUALIZE(function()
	if aimAssistFovVisual.circle then
		pcall(function()
			aimAssistFovVisual.circle:Remove()
		end)
		aimAssistFovVisual.circle = nil
	end
	for _, line in ipairs(aimAssistFovVisual.boxLines) do
		pcall(function()
			line:Remove()
		end)
	end
	aimAssistFovVisual.boxLines = {}
end)

ensureAntiCurveOverlay = function()
	if antiCurveOverlayText then
		return antiCurveOverlayText
	end
	local textObj = Drawing.new("Text")
	textObj.Visible = false
	textObj.Center = false
	textObj.Size = 16
	textObj.Font = 2
	textObj.Color = Color3.fromRGB(255, 255, 255)
	textObj.Transparency = 1
	textObj.Outline = true
	textObj.OutlineColor = Color3.fromRGB(0, 0, 0)
	antiCurveOverlayText = textObj
	return textObj
end

updateAntiCurveOverlay = function(info)
	if info and not shouldVisualizeAntiCurve() then
		info = nil
	end
	antiCurveOverlayData = info
	if not info then
		if antiCurveOverlayText then
			antiCurveOverlayText.Visible = false
		end
		antiCurveOverlayExpiry = 0
		return
	end
	local overlay = ensureAntiCurveOverlay()
	local redirectText = info.redirect and "Redirect: YES" or "Redirect: NO"
	overlay.Text = string.format(
		"Anti-Curve\nMax Angle: %.1f deg\nCurrent Angle: %.1f deg\nDist Threshold: %.1f\nCurrent Dist: %.1f\n%s",
		info.maxAngle,
		info.currentAngle,
		info.distanceThreshold,
		info.currentDistance,
		redirectText
	)
	overlay.Color = info.redirect and Color3.fromRGB(90, 255, 120) or Color3.fromRGB(255, 120, 120)
	overlay.Visible = true
	antiCurveOverlayExpiry = osTime() + 1.5
	local mousePos = uis:GetMouseLocation()
	overlay.Position = vector2New(mousePos.X + 32, mousePos.Y - 48)
end

stepAntiCurveOverlay = function()
	if not antiCurveOverlayText or not antiCurveOverlayText.Visible then
		if shouldVisualizeAntiCurve and not shouldVisualizeAntiCurve() and antiCurveOverlayText then
			antiCurveOverlayText.Visible = false
			antiCurveOverlayExpiry = 0
			antiCurveOverlayData = nil
		end
		return
	end
	if not shouldVisualizeAntiCurve() then
		antiCurveOverlayText.Visible = false
		antiCurveOverlayData = nil
		antiCurveOverlayExpiry = 0
		return
	end
	if antiCurveOverlayExpiry > 0 and osTime() > antiCurveOverlayExpiry then
		antiCurveOverlayText.Visible = false
		antiCurveOverlayData = nil
		return
	end
	local mousePos = uis:GetMouseLocation()
	antiCurveOverlayText.Position = vector2New(mousePos.X + 32, mousePos.Y - 48)
end

isMouseInFov = LPH_NO_VIRTUALIZE(function(mousePos, targetChar)
	if not targetChar then
		return false
	end
	local fovConfig = Config['Aim Assist'] and Config['Aim Assist']['FOV'] or {}
	return isWithinFov(targetChar, fovConfig, mousePos)
end)

updateFovVisualizer = LPH_NO_VIRTUALIZE(function()
	local aimAssistConfig = Config and Config['Aim Assist']
	local fovConfig = aimAssistConfig and aimAssistConfig['FOV']
	if not aimAssistConfig or not fovConfig or not fovConfig['Visualize'] then
		if hideAimAssistVisuals then hideAimAssistVisuals() end
		return
	end
	local panicConfig = Config and Config['Main'] and Config['Main']['Panic']
	local aimAssistDisabled = panicMode and panicConfig and panicConfig['Disable Aim Assist']
	if not aimAssistConfig['Enabled'] or aimAssistDisabled then
		if hideAimAssistVisuals then hideAimAssistVisuals() end
		return
	end
	local dimensions = calculateFovDimensions(fovConfig)
	if not dimensions then
		hideAimAssistVisuals()
		return
	end
	local fovType = fovConfig['FOV Type'] or 'Circle'
	local color = fovConfig['Color'] or AIM_ASSIST_FOV_COLOR
	if fovType == 'Circle' then
		local circle = ensureAimAssistCircle()
		circle.Color = color
		circle.Position = uis:GetMouseLocation()
		circle.Radius = dimensions.radius or 0
		circle.Visible = true
		for _, line in ipairs(aimAssistFovVisual.boxLines) do
			line.Visible = false
		end
		return
	end
	local lines = ensureAimAssistBoxLines()
	local halfWidth = (dimensions.width or 0) / 2
	local halfHeight = (dimensions.height or 0) / 2
	local bestChar = getBestTarget()
	local targetModel = (bestChar and validChar(bestChar)) and bestChar or nil
	local hrp = targetModel and targetModel:FindFirstChild("HumanoidRootPart") or nil
	if hrp then
		local screenPos, visible = cam:WorldToViewportPoint(hrp.Position)
		if visible and screenPos.Z > 0 then
			local center = Vector2.new(screenPos.X, screenPos.Y)
			local corners = {
				Vector2.new(center.X - halfWidth, center.Y - halfHeight),
				Vector2.new(center.X + halfWidth, center.Y - halfHeight),
				Vector2.new(center.X + halfWidth, center.Y + halfHeight),
				Vector2.new(center.X - halfWidth, center.Y + halfHeight)
			}
			for index, line in ipairs(lines) do
				local nextIndex = (index % 4) + 1
				line.Color = color
				line.From = corners[index]
				line.To = corners[nextIndex]
				line.Visible = true
			end
		else
			for _, line in ipairs(lines) do
				line.Visible = false
			end
		end
	else
		for _, line in ipairs(lines) do
			line.Visible = false
		end
	end
	if aimAssistFovVisual.circle then
		aimAssistFovVisual.circle.Visible = false
	end
end)

smoothLerp = LPH_NO_VIRTUALIZE(function(current, target, speed, easingStyle, easingDirection)
	local alpha = 1 - mathExp(- speed)
	if easingStyle == "Linear" then
		return current + (target - current) * alpha
	elseif easingStyle == "Sine" then
		if easingDirection == "In" then
			alpha = 1 - math.cos(alpha * math.pi / 2)
		elseif easingDirection == "Out" then
			alpha = math.sin(alpha * math.pi / 2)
		else
			alpha = - (math.cos(math.pi * alpha) - 1) / 2
		end
	elseif easingStyle == "Quad" then
		if easingDirection == "In" then
			alpha = alpha * alpha
		elseif easingDirection == "Out" then
			alpha = 1 - (1 - alpha) * (1 - alpha)
		else
			alpha = alpha < 0.5 and 2 * alpha * alpha or 1 - math.pow(-2 * alpha + 2, 2) / 2
		end
	elseif easingStyle == "Cubic" then
		if easingDirection == "In" then
			alpha = alpha * alpha * alpha
		elseif easingDirection == "Out" then
			alpha = 1 - math.pow(1 - alpha, 3)
		else
			alpha = alpha < 0.5 and 4 * alpha * alpha * alpha or 1 - math.pow(-2 * alpha + 2, 3) / 2
		end
	elseif easingStyle == "Exponential" then
		if easingDirection == "In" then
			alpha = alpha == 0 and 0 or math.pow(2, 10 * alpha - 10)
		elseif easingDirection == "Out" then
			alpha = alpha == 1 and 1 or 1 - math.pow(2, -10 * alpha)
		else
			if alpha == 0 then
				alpha = 0
			elseif alpha == 1 then
				alpha = 1
			elseif alpha < 0.5 then
				alpha = math.pow(2, 20 * alpha - 10) / 2
			else
				alpha = (2 - math.pow(2, -20 * alpha + 10)) / 2
			end
		end
	elseif easingStyle == "Elastic" then
		local c4 = (2 * math.pi) / 3
		local c5 = (2 * math.pi) / 4.5
		if easingDirection == "In" then
			if alpha == 0 then
				alpha = 0
			elseif alpha == 1 then
				alpha = 1
			else
				alpha = - math.pow(2, 10 * (alpha - 1)) * math.sin((alpha * 10 - 10.75) * c5)
			end
		elseif easingDirection == "Out" then
			if alpha == 0 then
				alpha = 0
			elseif alpha == 1 then
				alpha = 1
			else
				alpha = math.pow(2, -10 * alpha) * math.sin((alpha * 10 - 0.75) * c5) + 1
			end
		else
			if alpha == 0 then
				alpha = 0
			elseif alpha == 1 then
				alpha = 1
			elseif alpha < 0.5 then
				alpha = - (math.pow(2, 20 * alpha - 10) * math.sin((20 * alpha - 11.125) * c4)) / 2
			else
				alpha = (math.pow(2, -20 * alpha + 10) * math.sin((20 * alpha - 11.125) * c4)) / 2 + 1
			end
		end
	end
 	return current + (target - current) * alpha
end)

clampScreenPos = LPH_NO_VIRTUALIZE(function(pos)
	local viewport = cam.ViewportSize
	local x = mathClamp(pos.X, 0, viewport.X)
	local y = mathClamp(pos.Y, 0, viewport.Y)
	return vector2New(x, y)
end)

updateCamera = LPH_NO_VIRTUALIZE(function()
	if not cameraAimbotLocked or not cameraAimbotTarget then
		return
	end
	local panicConfig = Config and Config['Main'] and Config['Main']['Panic']
	local aimAssistDisabled = panicMode and panicConfig and panicConfig['Disable Aim Assist']
	local selfChecks = Config and Config['Self Checks'] or {}
	local targetChecks = Config and Config['Target Checks'] or {}
	if not canUseFeatures() or aimAssistDisabled then
		cameraAimbotLocked = false
		cameraAimbotTarget = nil
		return
	end
	if selfChecks['Knocked'] and isSelfKnocked() then
		cameraAimbotLocked = false
		cameraAimbotTarget = nil
		return
	end
	if selfChecks['Grabbed'] and isSelfGrabbed() then
		cameraAimbotLocked = false
		cameraAimbotTarget = nil
		return
	end
	if selfChecks['Forcefield'] and isSelfForcefield() then
		cameraAimbotLocked = false
		cameraAimbotTarget = nil
		return
	end
	local mode = Config['Aim Assist']['Mode']
	if mode == "Mouse" then
		if not isValidCameraMode() then
			cameraAimbotLocked = false
			cameraAimbotTarget = nil
			return
		end
	elseif mode == "Camera" then
		if not isValidCameraMode() then
			cameraAimbotLocked = false
			cameraAimbotTarget = nil
			return
		end
	end
	if not validChar(cameraAimbotTarget) then
		cameraAimbotLocked = false
		cameraAimbotTarget = nil
		return
	end
	if targetChecks['Knocked'] and isKnocked(cameraAimbotTarget) then
		cameraAimbotLocked = false
		cameraAimbotTarget = nil
		return
	end
	if targetChecks['Grabbed'] and isGrabbed(cameraAimbotTarget) then
		cameraAimbotLocked = false
		cameraAimbotTarget = nil
		return
	end
	if targetChecks['Forcefield'] and hasForcefield(cameraAimbotTarget) then
		cameraAimbotLocked = false
		cameraAimbotTarget = nil
		cameraAimbotPaused = false
		return
	end

	local part, pos = findTarget(cameraAimbotTarget, mode ~= "Mouse")
	if not part or not pos then
		local hrp = cameraAimbotTarget:FindFirstChild("HumanoidRootPart")
		if hrp then
			pos = hrp.Position
			part = hrp
		else
			cameraAimbotPaused = false
			return
		end
	end

	local isVisible = wallCheck(part)

	if not isVisible then
		if not cameraAimbotPaused then
			cameraAimbotPaused = true
			cameraAimbotPauseTime = osTime()
		end

		local pauseDuration = 5
		if osTime() - cameraAimbotPauseTime > pauseDuration then
			cameraAimbotLocked = false
			cameraAimbotTarget = nil
			cameraAimbotPaused = false
		end
		return
	end

	if cameraAimbotPaused then
		cameraAimbotPaused = false
		cameraAimbotPauseTime = 0
	end

	local predictionSettings = Config['Aim Assist']['Hit Target']['Prediction']
	pos = applyPrediction(part, pos, predictionSettings)
	local camPos = cam.CFrame.Position
	local basePosition = pos
	local inFirstPersonOrShiftLock = isFirstPersonOrShiftLock()
	local screenPos, onScreen, depth = cam:WorldToViewportPoint(basePosition)
	depth = depth or 0
	local distance = (basePosition - camPos).Magnitude
	local useCamera = false
	if mode == "Dynamic" then
		if (not onScreen) or depth < 0 or inFirstPersonOrShiftLock then
			useCamera = true
			predictionSettings = Config['Aim Assist']['Camera Settings']
		end
		local fallbackDistance = 2
		if distance <= fallbackDistance and onScreen and depth > 0 and not inFirstPersonOrShiftLock then
			useCamera = false
			predictionSettings = Config['Aim Assist']['Hit Target']['Prediction']
		end
	elseif mode == "Camera" then
		useCamera = true
		predictionSettings = Config['Aim Assist']['Hit Target']['Prediction']
	else
		useCamera = false
		predictionSettings = Config['Aim Assist']['Hit Target']['Prediction']
	end
	local targetPos3D = applyPrediction(part, basePosition, predictionSettings)
	local humanizerOffset = getHumanizerOffset(true)
	if humanizerOffset.Magnitude > 0 then
		targetPos3D = targetPos3D + humanizerOffset
	end
	screenPos, onScreen, depth = cam:WorldToViewportPoint(targetPos3D)
	depth = depth or 0
	if useCamera then
		local targetCF = cfLookAt(cam.CFrame.Position, targetPos3D)
		local smoothing = Config['Aim Assist']['Smoothing']
		local easingConfig = smoothing['Easing']
		local easingStyleFirst = easingConfig['First']
		local easingStyleSecond = easingConfig['Second']
		local easingDirection = easingConfig['Easing Direction']
		local smoothingValue = smoothing['Smoothing Value']
		local smoothnessX = smoothingValue['X']
		local smoothnessY = smoothingValue['Y']
		local smoothnessZ = smoothingValue['Z']
		local currentLookVector = cam.CFrame.LookVector
		local targetLookVector = targetCF.LookVector
		local yawDiff = mathAtan2(targetLookVector.X, targetLookVector.Z) - mathAtan2(currentLookVector.X, currentLookVector.Z)
		local pitchDiff = mathAsin(targetLookVector.Y) - mathAsin(currentLookVector.Y)
		local smoothness = smoothnessX
		local absYaw = mathAbs(yawDiff)
		local absPitch = mathAbs(pitchDiff)
		if absYaw <= absPitch then
			smoothness = absPitch > 0.5 and smoothnessY or smoothnessZ
		end
		local function applyEasing(t, style, direction)
			if style == "Sine" then
				if direction == "In" then
					return 1 - mathCos(t * mathPi * 0.5)
				elseif direction == "Out" then
					return mathSin(t * mathPi * 0.5)
				elseif direction == "InOut" then
					return - (mathCos(t * mathPi) - 1) * 0.5
				end
			elseif style == "Quad" then
				if direction == "In" then
					return t * t
				elseif direction == "Out" then
					local inv = 1 - t
					return 1 - inv * inv
				elseif direction == "InOut" then
					return t < 0.5 and 2 * t * t or 1 - mathPow(-2 * t + 2, 2) * 0.5
				end
			elseif style == "Cubic" then
				if direction == "In" then
					return t * t * t
				elseif direction == "Out" then
					local inv = 1 - t
					return 1 - inv * inv * inv
				elseif direction == "InOut" then
					return t < 0.5 and 4 * t * t * t or 1 - mathPow(-2 * t + 2, 3) * 0.5
				end
			elseif style == "Quart" then
				if direction == "In" then
					return t * t * t * t
				elseif direction == "Out" then
					local inv = 1 - t
					return 1 - inv * inv * inv * inv
				elseif direction == "InOut" then
					return t < 0.5 and 8 * t * t * t * t or 1 - mathPow(-2 * t + 2, 4) * 0.5
				end
			elseif style == "Quint" then
				if direction == "In" then
					return t * t * t * t * t
				elseif direction == "Out" then
					local inv = 1 - t
					return 1 - inv * inv * inv * inv * inv
				elseif direction == "InOut" then
					return t < 0.5 and 16 * t * t * t * t * t or 1 - mathPow(-2 * t + 2, 5) * 0.5
				end
			elseif style == "Expo" then
				if direction == "In" then
					return t == 0 and 0 or mathPow(2, 10 * (t - 1))
				elseif direction == "Out" then
					return t == 1 and 1 or 1 - mathPow(2, -10 * t)
				elseif direction == "InOut" then
					if t == 0 then
						return 0
					elseif t == 1 then
						return 1
					elseif t < 0.5 then
						return mathPow(2, 20 * t - 10) * 0.5
					else
						return (2 - mathPow(2, -20 * t + 10)) * 0.5
					end
				end
			elseif style == "Circ" then
				if direction == "In" then
					return 1 - mathSqrt(1 - t * t)
				elseif direction == "Out" then
					local inv = t - 1
					return mathSqrt(1 - inv * inv)
				elseif direction == "InOut" then
					local doubled = 2 * t
					local invDoubled = -2 * t + 2
					return t < 0.5 and (1 - mathSqrt(1 - doubled * doubled)) * 0.5 or (mathSqrt(1 - invDoubled * invDoubled) + 1) * 0.5
				end
			elseif style == "Back" then
				local c1 = 1.70158
				local c2 = c1 + 1
				local c3 = c1 * 1.525
				if direction == "In" then
					return c3 * t * t * t - c1 * t * t
				elseif direction == "Out" then
					return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2)
				elseif direction == "InOut" then
					if t < 0.5 then
						return math.pow(2 * t, 2) * ((c2 + 1) * 2 * t - c2) / 2
					else
						return (math.pow(2 * t - 2, 2) * ((c2 + 1) * (2 * t - 2) + c2) + 2) / 2
					end
				end
			elseif style == "Elastic" then
				local c4 = (2 * math.pi) / 3
				local c5 = (2 * math.pi) / 4.5
				if direction == "In" then
					if t == 0 then
						return 0
					elseif t == 1 then
						return 1
					else
						return - math.pow(2, 10 * (t - 1)) * math.sin((t * 10 - 10.75) * c5)
					end
				elseif direction == "Out" then
					if t == 0 then
						return 0
					elseif t == 1 then
						return 1
					else
						return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c5) + 1
					end
				elseif direction == "InOut" then
					if t == 0 then
						return 0
					elseif t == 1 then
						return 1
					elseif t < 0.5 then
						return - (math.pow(2, 20 * t - 10) * math.sin((20 * t - 11.125) * c4)) / 2
					else
						return (math.pow(2, -20 * t + 10) * math.sin((20 * t - 11.125) * c4)) / 2 + 1
					end
				end
			elseif style == "Bounce" then
				local function bounceOut(t)
					local n1 = 7.5625
					local d1 = 2.75
					if t < 1 / d1 then
						return n1 * t * t
					elseif t < 2 / d1 then
						return n1 * (t - 1.5 / d1) * (t - 1.5 / d1) + 0.75
					elseif t < 2.5 / d1 then
						return n1 * (t - 2.25 / d1) * (t - 2.25 / d1) + 0.9375
					else
						return n1 * (t - 2.625 / d1) * (t - 2.625 / d1) + 0.984375
					end
				end
				if direction == "In" then
					return 1 - bounceOut(1 - t)
				elseif direction == "Out" then
					return bounceOut(t)
				elseif direction == "InOut" then
					if t < 0.5 then
						return (1 - bounceOut(1 - 2 * t)) / 2
					else
						return (1 + bounceOut(2 * t - 1)) / 2
					end
				end
			end
			return t
		end
		local eased = smoothness
		local halfPoint = 0.5
		if easingStyleFirst ~= easingStyleSecond then
			if smoothness < halfPoint then
				eased = applyEasing(smoothness * 2, easingStyleFirst, easingDirection)
				eased = eased / 2
			else
				eased = applyEasing((smoothness - halfPoint) * 2, easingStyleSecond, easingDirection)
				eased = (eased + 1) / 2
			end
		else
			eased = applyEasing(smoothness, easingStyleFirst, easingDirection)
		end
		cam.CFrame = cam.CFrame:Lerp(targetCF, eased)
	else
		if onScreen and depth >= 0 then
			local mousePos = uis:GetMouseLocation()
			local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
			local diff = clampScreenPos(targetScreenPos) - mousePos
			if diff.Magnitude > 1 then
				local mouseSpeed = Config['Aim Assist']['Smoothing']['Smoothing Value']['Mouse Smoothing']['X'] or 0.4
				local easingConfig = Config['Aim Assist']['Smoothing']['Easing']
				local easingStyleFirst = easingConfig['First']
				local easingDirection = easingConfig['Easing Direction']
				local smoothedX = smoothLerp(0, diff.X, mouseSpeed, easingStyleFirst, easingDirection)
				local smoothedY = smoothLerp(0, diff.Y, mouseSpeed, easingStyleFirst, easingDirection)
				mousemoverel(smoothedX, smoothedY)
			end
		end
	end
end)
syncTargetToFeatures = LPH_NO_VIRTUALIZE(function(targetChar)
	if not Config or not Config['Main'] or not Config['Main']['Sync'] then
		return
	end
	if Config['Aim Assist'] and Config['Aim Assist']['Enabled'] and not cameraAimbotLocked then
		cameraAimbotTarget = targetChar
	end
	if TriggerBotConfig['Enabled'] and not triggerBotLocked then
		if TriggerBotConfig['Target Mode'] == 'Automatic' then
			triggerBotTarget = targetChar
		end
	end
	if SilentAimConfig['Enabled'] and not silentAimLocked then
		for _, player in pairs(players:GetPlayers()) do
			if player.Character == targetChar then
				silentAimTarget = player
				break
			end
		end
		if not silentAimTarget then
			local botsFolder = workspace:FindFirstChild('Bots')
			if botsFolder then
				for _, bot in ipairs(botsFolder:GetChildren()) do
					if bot == targetChar and bot.Name == 'Dummy' then
						silentAimTarget = {
							Character = bot,
							Name = 'Dummy'
						}
						break
					end
				end
			end
		end
	end
end)

toggleCameraAimbot = function()
	local panicConfig = Config and Config['Main'] and Config['Main']['Panic']
	local aimAssistDisabled = panicMode and panicConfig and panicConfig['Disable Aim Assist']
	if not canUseFeatures() or aimAssistDisabled then
		return
	end
	if cameraAimbotLocked and cameraAimbotTarget then
		cameraAimbotLocked = false
		cameraAimbotTarget = nil
		cameraAimbotPaused = false
		cameraAimbotPauseTime = 0
		if Config and Config['Main'] and Config['Main']['Sync'] then
			sharedTarget = nil
			if TriggerBotConfig['Enabled'] and not triggerBotLocked then
				triggerBotTarget = nil
			end
			if SilentAimConfig['Enabled'] and not silentAimLocked then
				silentAimTarget = nil
			end
		end
	else
		if not canUseFeatures() then
			return
		end
		local mode = Config['Aim Assist']['Mode']
		if mode ~= "Mouse" and not isValidCameraMode() then
			return
		end
		local target, part, pos = getBestTarget()
		if target and validChar(target) then
			local mousePos = uis:GetMouseLocation()
			if isMouseInFov(mousePos, target) then
				cameraAimbotLocked = true
				cameraAimbotTarget = target
					cameraAimbotPaused = false
				cameraAimbotPauseTime = 0
				if Config and Config['Main'] and Config['Main']['Sync'] then
					sharedTarget = target
					syncTargetToFeatures(target)
				end
			end
		end
	end
end


uis.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(input, processed)
	local keybinds = Config and Config['Main'] and Config['Main']['Keybinds'] or {}
	local panicKey, panicIsMouseButton = getKey(keybinds['Panic'])
	local aimAssistKey, aimAssistIsMouseButton = getKey(keybinds['Aim Assist'])
	local speedKey, speedIsMouseButton = getKey(keybinds['Speed'])
	local jumpPowerKey, jumpIsMouseButton = getKey(keybinds['Jump Power'])
	local inventorySorterKey, inventoryIsMouseButton = getKey(keybinds['Inventory Sorter'])

	local panicConfig = Config and Config['Main'] and Config['Main']['Panic']
	local shouldBypassProcessed = inputMatches(input, panicKey, panicIsMouseButton)
		or inputMatches(input, aimAssistKey, aimAssistIsMouseButton)
		or inputMatches(input, speedKey, speedIsMouseButton)
		or inputMatches(input, jumpPowerKey, jumpIsMouseButton)
		or inputMatches(input, inventorySorterKey, inventoryIsMouseButton)

	if processed and not shouldBypassProcessed then
		return
	end

	if inputMatches(input, panicKey, panicIsMouseButton)
		and panicConfig and panicConfig['Enabled'] then
		panicMode = not panicMode
		if panicMode then
			cameraAimbotLocked = false
			cameraAimbotTarget = nil
			cameraAimbotPaused = false
			cameraAimbotPauseTime = 0
			triggerBotState = false
			triggerBotTarget = nil
			triggerBotLocked = false
			silentAimTarget = nil
			sharedTarget = nil
		end
	end

	local aimAssistDisabled = panicMode and panicConfig and panicConfig['Disable Aim Assist']
	if inputMatches(input, aimAssistKey, aimAssistIsMouseButton)
		and Config and Config['Aim Assist']
		and Config['Aim Assist']['Enabled']
		and not aimAssistDisabled then
		toggleCameraAimbot()
	end

	local playerModConfig = Config and Config['Player Modification'] or {}
	local movementConfig = playerModConfig['Movement'] or {}
	local speedConfig = movementConfig['Speed Modifications'] or {}
	local jumpConfig = movementConfig['Jump Modifications'] or {}

	if inputMatches(input, speedKey, speedIsMouseButton) and speedConfig['Enabled'] then
		speedModActive = not speedModActive
	end

	if inputMatches(input, jumpPowerKey, jumpIsMouseButton) and jumpConfig['Enabled'] then
		jumpPowerActive = not jumpPowerActive
	end

	local inventorySorterConfig = playerModConfig['Inventory Sorter'] or {}
	if inventorySorterConfig['Enabled'] and inputMatches(input, inventorySorterKey, inventoryIsMouseButton) then
		local gunOrder = inventorySorterConfig['Order'] or {}
		local backpack = plr:FindFirstChildOfClass("Backpack")
		if not backpack then
			return
		end
		local fakeFolder = Instance.new('Folder')
		fakeFolder.Name = 'FakeFolder'
		fakeFolder.Parent = workspace
		for _, tool in pairs(backpack:GetChildren()) do
			if tool:IsA('Tool') then
				tool.Parent = fakeFolder
			end
		end
		local orderV = 10 - # gunOrder
		for _, gunName in pairs(gunOrder) do
			local gun = fakeFolder:FindFirstChild(gunName)
			if gun then
				gun.Parent = backpack
				task.wait(0.05)
			else
				orderV = orderV + 1
			end
		end
		local foodItems = {}
		for _, tool in pairs(fakeFolder:GetChildren()) do
			if tool:IsA('Tool') and (tool:FindFirstChild('Drink') or tool:FindFirstChild('Eat') or tool.Name == '[Lettuce]') then
				table.insert(foodItems, tool)
			end
		end
		if inventorySorterConfig['Sort Food'] then
			for _, food in pairs(foodItems) do
				if food.Parent == fakeFolder then
					food.Parent = backpack
					orderV = orderV - 1
					task.wait(0.05)
				end
			end
		end
		if orderV > 0 then
			for i = 1, orderV do
				local placeholder = Instance.new('Tool')
				placeholder.Name = ''
				placeholder.ToolTip = 'PlaceHolder'
				placeholder.GripPos = Vector3.new(0, 1, 0)
				placeholder.RequiresHandle = false
				placeholder.Parent = backpack
			end
		end
		for _, tool in pairs(fakeFolder:GetChildren()) do
			if tool:IsA('Tool') then
				local isFood = tool:FindFirstChild('Drink') or tool:FindFirstChild('Eat') or tool.Name == '[Lettuce]'
				if not isFood or inventorySorterConfig['Sort Food'] then
					tool.Parent = backpack
				end
			end
		end
		for _, tool in pairs(backpack:GetChildren()) do
			if tool.Name == '' then
				tool:Destroy()
			end
		end
		if not inventorySorterConfig['Sort Food'] then
			for _, food in pairs(foodItems) do
				if food.Parent == fakeFolder then
					food.Parent = backpack
				end
			end
		end
		fakeFolder:Destroy()
	end
end))

renderConnection = rs.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
	if updateConfigCache then updateConfigCache() end
	if stepAntiCurveOverlay then stepAntiCurveOverlay() end
	local mainConfig = Config and Config['Main']
	local syncEnabled = mainConfig and mainConfig['Sync']
	local panicConfig = mainConfig and mainConfig['Panic']
	local unlockConditions = Config and Config['Unlock Conditions'] or {}
	local selfChecks = cachedSelfChecksConfig or {}
	local targetChecks = cachedTargetChecksConfig or {}
	if unlockConditions['Unlock on Self Knock'] and isSelfKnocked() then
		cameraAimbotLocked = false
		cameraAimbotTarget = nil
		cameraAimbotPaused = false
		cameraAimbotPauseTime = 0
		triggerBotState = false
		triggerBotTarget = nil
		triggerBotLocked = false
		silentAimTarget = nil
		if syncEnabled then
			sharedTarget = nil
		end
	end
	if selfChecks['Knocked'] and isSelfKnocked() then
		if cameraAimbotLocked then
			cameraAimbotLocked = false
			cameraAimbotTarget = nil
			if syncEnabled then
				sharedTarget = nil
			end
		end
	end
	if selfChecks['Grabbed'] and isSelfGrabbed() then
		if cameraAimbotLocked then
			cameraAimbotLocked = false
			cameraAimbotTarget = nil
			if syncEnabled then
				sharedTarget = nil
			end
		end
	end
	if selfChecks['Forcefield'] and isSelfForcefield() then
		if cameraAimbotLocked then
			cameraAimbotLocked = false
			cameraAimbotTarget = nil
			if syncEnabled then
				sharedTarget = nil
			end
		end
	end
	if unlockConditions['Unlock on Target Knock'] then
		if cameraAimbotTarget and isKnocked(cameraAimbotTarget) then
			cameraAimbotLocked = false
			cameraAimbotTarget = nil
			cameraAimbotPaused = false
			cameraAimbotPauseTime = 0
			if syncEnabled then
				sharedTarget = nil
				triggerBotTarget = nil
				silentAimTarget = nil
			end
		end
		if triggerBotTarget and isKnocked(triggerBotTarget) then
			triggerBotState = false
			triggerBotTarget = nil
			triggerBotLocked = false
			if syncEnabled then
				sharedTarget = nil
				cameraAimbotTarget = nil
				silentAimTarget = nil
			end
		end
		if silentAimTarget then
			local targetChar = resolveTargetCharacter(silentAimTarget)
			if targetChar and isKnocked(targetChar) then
				silentAimTarget = nil
				if syncEnabled then
					sharedTarget = nil
					cameraAimbotTarget = nil
					triggerBotTarget = nil
				end
			end
		end
	end
	if targetChecks['Grabbed'] then
		if cameraAimbotTarget and isGrabbed(cameraAimbotTarget) then
			cameraAimbotLocked = false
			cameraAimbotTarget = nil
			if syncEnabled then
				sharedTarget = nil
			end
		end
	end
	if targetChecks['Forcefield'] then
		if cameraAimbotTarget and hasForcefield(cameraAimbotTarget) then
			cameraAimbotLocked = false
			cameraAimbotTarget = nil
			if syncEnabled then
				sharedTarget = nil
			end
		end
	end
	local aimAssistDisabled = panicMode and panicConfig and panicConfig['Disable Aim Assist']
	if aimAssistDisabled or not canUseFeatures() then
		if hideAimAssistVisuals then hideAimAssistVisuals() end
		getHumanizerOffset(false)
		return
	end
	if updateFovVisualizer then updateFovVisualizer() end
	if cameraAimbotLocked and not aimAssistDisabled and canUseFeatures then
		if updateCamera then updateCamera() end
	else
		if getHumanizerOffset then getHumanizerOffset(false) end
	end
end))

table.insert(activeConnections, renderConnection)

destroyTriggerBotFovVisualizer = LPH_NO_VIRTUALIZE(function()
	if triggerBotFovVisual.circle then
		pcall(function()
			triggerBotFovVisual.circle:Remove()
		end)
		triggerBotFovVisual.circle = nil
	end
	for _, line in ipairs(triggerBotFovVisual.boxLines) do
		pcall(function()
			line:Remove()
		end)
	end
	triggerBotFovVisual.boxLines = {}
end)

getCharacterFromPartTriggerBot = function(part)
	if not part then
		return nil
	end
	if part.Parent then
		local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid then
			return part.Parent
		end
	end
	local current = part
	for i = 1, 5 do
		if not current or not current.Parent then
			break
		end
		current = current.Parent
		local humanoid = current:FindFirstChildOfClass("Humanoid")
		if humanoid then
			return current
		end
	end
	return nil
end

findTargetTriggerBot = LPH_NO_VIRTUALIZE(function(char)
	if not char then
		return nil, nil
	end
	local bestPart, bestPos, bestDist = nil, nil, math.huge
	local mousePos = uis:GetMouseLocation()
	local mouseRay = cam:ScreenPointToRay(mousePos.X, mousePos.Y)
	local rayOrigin = mouseRay.Origin
	local rayDirection = mouseRay.Direction
	for _, partName in ipairs(bodyParts) do
		local part = char:FindFirstChild(partName)
		if part and part.IsA and part:IsA("BasePart") and wallCheck(part) then
			local pos = getClosestPoint(part, false)
			local pointToRay = pos - rayOrigin
			local projectionLength = pointToRay:Dot(rayDirection)
			local closestPointOnRay = rayOrigin + rayDirection * projectionLength
			local distanceToRay = (pos - closestPointOnRay).Magnitude
			if distanceToRay < bestDist then
				bestDist = distanceToRay
				bestPart = part
				bestPos = pos
			end
		end
	end
	return bestPart, bestPos
end)

isCrosshairOnTarget = LPH_NO_VIRTUALIZE(function(targetChar)
	if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
		return false
	end
	local mousePos = uis:GetMouseLocation()
	local mouseRay = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {
		plr.Character
	}
	rayParams.IgnoreWater = true
	local result = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 10000, rayParams)
	if not result or not result.Instance then
		return false
	end
	local hitChar = getCharacterFromPartTriggerBot(result.Instance)
	if not hitChar or hitChar ~= targetChar then
		return false
	end
	local hitPart = result.Instance
	if hitPart and hitPart.Parent == targetChar then
		if Config['Target Checks']['Wall'] then
			return wallCheck(hitPart)
		end
		return true
	end
	return false
end)

isTargetInFovTriggerBot = LPH_NO_VIRTUALIZE(function(targetChar)
	if not targetChar then
		return false
	end

	local mousePos = uis:GetMouseLocation()
	local dimensions = calculateFovDimensions(TriggerBotConfig['FOV'])
	local fovType = TriggerBotConfig['FOV']['FOV Type'] or 'Box'

	if fovType == 'Circle' then
		local radius = dimensions.radius or 0
		local radiusSq = radius * radius
		for _, partName in ipairs(bodyParts) do
			local part = targetChar:FindFirstChild(partName)
			if part and part:IsA("BasePart") then
				local screenPoint = cam:WorldToViewportPoint(part.Position)
				if screenPoint.Z > 0 then
					local dx = mousePos.X - screenPoint.X
					local dy = mousePos.Y - screenPoint.Y
					if dx * dx + dy * dy <= radiusSq then
						if Config['Target Checks']['Wall'] then
							if wallCheck(part) then
								return true
							end
						else
							return true
						end
					end
				end
			end
		end
	else
		local halfWidth = (dimensions.width or 0) * 0.5
		local halfHeight = (dimensions.height or dimensions.radius or 0) * 0.5
		for _, partName in ipairs(bodyParts) do
			local part = targetChar:FindFirstChild(partName)
			if part and part:IsA("BasePart") then
				local screenPoint = cam:WorldToViewportPoint(part.Position)
				if screenPoint.Z > 0 then
					local deltaX = mathAbs(mousePos.X - screenPoint.X)
					local deltaY = mathAbs(mousePos.Y - screenPoint.Y)
					if deltaX <= halfWidth and deltaY <= halfHeight then
						if Config['Target Checks']['Wall'] then
							if wallCheck(part) then
								return true
							end
						else
							return true
						end
					end
				end
			end
		end
	end

	return false
end)

getBestTriggerBotTarget = LPH_NO_VIRTUALIZE(function()
	local chars = getCharacters()
	local mousePos = uis:GetMouseLocation()
	local bestChar, bestPart, bestPos, bestDist = nil, nil, nil, mathHuge
	for _, char in ipairs(chars) do
		local part, pos = findTargetTriggerBot(char)
		if part and pos then
			local screenPos = cam:WorldToViewportPoint(pos)
			if screenPos.Z > 0 then
				local dx = screenPos.X - mousePos.X
				local dy = screenPos.Y - mousePos.Y
				local dist = dx * dx + dy * dy
				if dist < bestDist then
					bestDist = dist
					bestChar = char
					bestPart = part
					bestPos = pos
				end
			end
		end
	end
	return bestChar, bestPart, bestPos
end)

isHoldingRestrictedItem = function()
	if not plr.Character then
		return false
	end
	local restrictedItems = {
		"Knife",
		"knife",
		"katana",
		"Katana",
		"['Katana']",
		"[Knife]",
		"[Chicken]",
		"[Cranberry]",
		"[Pizza]",
		"[Hamburger]",
		"[Donut]",
		"[Lemonade]",
		"[Taco]",
		"[HotDog]",
		"[Lettuce]",
		"[Stim]"
	}
	for _, tool in pairs(plr.Character:GetChildren()) do
		if tool:IsA("Tool") then
			local toolName = tool.Name
			for _, restrictedName in ipairs(restrictedItems) do
				if toolName == restrictedName then
					return true
				end
			end
			if tool:FindFirstChild('Drink') or tool:FindFirstChild('Eat') then
				return true
			end
		end
	end
	return false
end

isCrouching = function()
	return uis:IsKeyDown(Enum.KeyCode.LeftControl)
end

getTriggerBotForcedTarget = function()
	if not triggerBotTarget or not validChar(triggerBotTarget) then
		return nil
	end
	local owningPlayer = players:GetPlayerFromCharacter(triggerBotTarget)
	if owningPlayer then
		return owningPlayer
	end
	return {
		Character = triggerBotTarget,
		Name = triggerBotTarget.Name or 'Target'
	}
end

shouldTrigger = LPH_NO_VIRTUALIZE(function()
	local panicConfig = Config and Config['Main'] and Config['Main']['Panic']
	local triggerBotDisabled = panicMode and panicConfig and panicConfig['Disable Trigger Bot']
	if not TriggerBotConfig['Enabled'] or triggerBotDisabled or not canUseFeatures() then
		return false
	end
	if not triggerBotState or not triggerBotTarget then
		return false
	end
	if not getTriggerBotForcedTarget() then
		return false
	end
	local character = plr.Character
	local equippedTool = character and character:FindFirstChildWhichIsA("Tool") or nil
	if not equippedTool or equippedTool.Name == '[Knife]' then
		return false
	end
	if not validChar(triggerBotTarget) then
		triggerBotTarget = nil
		triggerBotLocked = false
		return false
	end
	if isCrouching() then
		return false
	end
	if TriggerBotConfig['Shoot Mode'] == "Hitbox" then
		if not isCrosshairOnTarget(triggerBotTarget) then
			return false
		end
	elseif TriggerBotConfig['Shoot Mode'] == "FOV" then
		if not isTargetInFovTriggerBot(triggerBotTarget) then
			return false
		end
	end
	if Config['Target Checks']['Wall'] then
		local hasVisiblePart = false
		for _, partName in ipairs(bodyParts) do
			local part = triggerBotTarget:FindFirstChild(partName)
			if part and part:IsA("BasePart") and wallCheck(part) then
				hasVisiblePart = true
				break
			end
		end
		if not hasVisiblePart then
			return false
		end
	end
	return true
end)

performTrigger = LPH_NO_VIRTUALIZE(function()
	if not shouldTrigger() then
		triggerBotPart.Position = vector3Zero
		triggerBotPart.Parent = nil
		return
	end
	local character = plr.Character
	local tool = character and character:FindFirstChildWhichIsA("Tool") or nil
	if not tool or tool.Name == '[Knife]' then
		triggerBotPart.Position = vector3Zero
		triggerBotPart.Parent = nil
		return
	end
	local forcedTarget = getTriggerBotForcedTarget()
	if not forcedTarget then
		triggerBotPart.Position = vector3Zero
		triggerBotPart.Parent = nil
		return
	end
	local targetChar = resolveTargetCharacter(forcedTarget)
	if not targetChar or not validChar(targetChar) then
		triggerBotPart.Position = vector3Zero
		triggerBotPart.Parent = nil
		return
	end
	local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
	if not targetHrp then
		triggerBotPart.Position = vector3Zero
		triggerBotPart.Parent = nil
		return
	end
	local fovConfig = TriggerBotConfig and TriggerBotConfig['FOV']
	if fovConfig then
		local xSize = sanitizeNumber(fovConfig['Box'] and fovConfig['Box']['X'], 3.3, 0.1, 50) or 3.3
		local ySize = sanitizeNumber(fovConfig['Box'] and fovConfig['Box']['Y'], 7, 0.1, 50) or 7
		local zSize = sanitizeNumber(fovConfig['Box'] and fovConfig['Box']['X'], 3.6, 0.1, 50) or 3.6
		triggerBotPart.Size = Vector3.new(xSize, ySize, zSize)
	end
	local predictionConfig = TriggerBotConfig and TriggerBotConfig['Prediction']
	local targetPos = targetHrp.Position
	if predictionConfig and predictionConfig['Enabled'] then
		local velocity = targetHrp.AssemblyLinearVelocity
		local predScale = sanitizeNumber(predictionConfig['X'], 0, -10, 10) or 0
		targetPos = targetPos + Vector3.new(velocity.X * predScale, 0, velocity.Z * predScale)
	end
	triggerBotPart.Position = targetPos
	triggerBotPart.Parent = workspace
	local visualize = fovConfig and fovConfig['Visualize']
	triggerBotPart.Transparency = (visualize and 0.7) or 1
	triggerBotPart.Color = Color3.new(1, 0, 0)
	local mouseLocation = uis:GetMouseLocation()
	local ray = cam:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, triggerBotRaycastParams)
	if result and result.Instance == triggerBotPart then
		local timingConfig = TriggerBotConfig and TriggerBotConfig['Timing']
		local configuredCooldown = timingConfig and sanitizeNumber(timingConfig['Cooldown'], 0, 0, 5) or 0
		local fallbackCooldown = 0
		if configuredCooldown <= 0 and CurrentGame and CurrentGame.Name == "Da Hood" then
			fallbackCooldown = 0.18
		end
		local cooldown = mathMax(configuredCooldown, fallbackCooldown)
		local now = osTime()
		if cooldown > 0 and (now - lastTriggerTime) < cooldown then
			return
		end
		triggerBotFiring = true
		silentAimFiring = true
		triggerBotPart.Color = Color3.new(0, 1, 0)
		tool:Activate()
		lastTriggerTime = now
		task.delay(0.05, function()
			triggerBotFiring = false
			silentAimFiring = false
		end)
	else
		triggerBotPart.Color = Color3.new(1, 0, 0)
	end
end)

updateTriggerBotFov = LPH_NO_VIRTUALIZE(function()
	local fovConfig = TriggerBotConfig and TriggerBotConfig['FOV']
	if not fovConfig then
		if hideTriggerBotVisuals then hideTriggerBotVisuals() end
		return
	end
	local panicConfig = Config and Config['Main'] and Config['Main']['Panic']
	local triggerBotDisabled = panicMode and panicConfig and panicConfig['Disable Trigger Bot']
	if triggerBotDisabled or not TriggerBotConfig or not TriggerBotConfig['Enabled'] or not fovConfig or not fovConfig['Visualize'] then
		if hideTriggerBotVisuals then hideTriggerBotVisuals() end
		return
	end
	local dimensions = calculateFovDimensions and calculateFovDimensions(fovConfig)
	if not dimensions then
		if hideTriggerBotVisuals then hideTriggerBotVisuals() end
		return
	end
	local color = fovConfig['Color'] or TRIGGER_BOT_FOV_COLOR
	local fovType = fovConfig['FOV Type'] or 'Box'
	if fovType == 'Circle' then
		local circle = ensureTriggerBotCircle()
		circle.Color = color
		circle.Position = uis:GetMouseLocation()
		circle.Radius = dimensions.radius or 0
		circle.Visible = true
		for _, line in ipairs(triggerBotFovVisual.boxLines) do
			line.Visible = false
		end
		return
	end
	local lines = ensureTriggerBotBoxLines()
	local forcedEntity = getTriggerBotForcedTarget()
	local targetChar = resolveTargetCharacter(forcedEntity)
	if not targetChar then
		targetChar = select(1, getBestTriggerBotTarget())
	end
	local hrp = targetChar and validChar(targetChar) and targetChar:FindFirstChild("HumanoidRootPart") or nil
	if not hrp then
		for _, line in ipairs(lines) do
			line.Visible = false
		end
		if triggerBotFovVisual.circle then
			triggerBotFovVisual.circle.Visible = false
		end
		return
	end
	local screenPos, visible = cam:WorldToViewportPoint(hrp.Position)
	if not visible or screenPos.Z <= 0 then
		for _, line in ipairs(lines) do
			line.Visible = false
		end
		if triggerBotFovVisual.circle then
			triggerBotFovVisual.circle.Visible = false
		end
		return
	end
	local halfWidth = (dimensions.width or 0) * 0.5
	local halfHeight = (dimensions.height or 0) * 0.5
	local center = Vector2.new(screenPos.X, screenPos.Y)
	local corners = {
		Vector2.new(center.X - halfWidth, center.Y - halfHeight),
		Vector2.new(center.X + halfWidth, center.Y - halfHeight),
		Vector2.new(center.X + halfWidth, center.Y + halfHeight),
		Vector2.new(center.X - halfWidth, center.Y + halfHeight)
	}
	for index, line in ipairs(lines) do
		local nextIndex = (index % 4) + 1
		line.Color = color
		line.From = corners[index]
		line.To = corners[nextIndex]
		line.Visible = true
	end
	if triggerBotFovVisual.circle then
		triggerBotFovVisual.circle.Visible = false
	end
end)

uis.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(input, processed)
	local panicConfig = Config and Config['Main'] and Config['Main']['Panic']
	local triggerBotDisabled = panicMode and panicConfig and panicConfig['Disable Trigger Bot']
	if processed or triggerBotDisabled or not canUseFeatures() then
		return
	end
	local keybinds = Config and Config['Main'] and Config['Main']['Keybinds'] or {}
	local triggerTargetKey, isTargetKeyMouse = getKey(keybinds['Trigger Bot Target'])
	local toggleKey = keybinds['Trigger Bot Activate'] or 'MouseButton1'
	local toggleKeyCode, isToggleKeyMouse = getKey(toggleKey)

	local isTargetKey = false
	if isTargetKeyMouse and input.UserInputType == triggerTargetKey then
		isTargetKey = true
	elseif not isTargetKeyMouse and input.KeyCode == triggerTargetKey then
		isTargetKey = true
	end
	local isActivateKey = false
	if TriggerBotConfig['Enabled'] then
		if isToggleKeyMouse and input.UserInputType == toggleKeyCode then
			isActivateKey = true
		elseif not isToggleKeyMouse and input.KeyCode == toggleKeyCode then
			isActivateKey = true
		end
	end

	local sameKey = (keybinds['Trigger Bot Target'] == toggleKey) and (isTargetKey or isActivateKey)

	if isTargetKey and not sameKey then
		if triggerBotTarget then
			triggerBotTarget = nil
			triggerBotLocked = false
			triggerBotState = false
			if Config and Config['Main'] and Config['Main']['Sync'] then
				sharedTarget = nil
				if not cameraAimbotLocked then
					cameraAimbotTarget = nil
				end
				silentAimTarget = nil
			end
		else
			if TriggerBotConfig and TriggerBotConfig['Target Mode'] == 'Target' then
				local targetChar, targetPart, targetPos = getBestTriggerBotTarget()
				if targetChar then
					triggerBotTarget = targetChar
					triggerBotLocked = true
					if Config and Config['Main'] and Config['Main']['Sync'] then
						sharedTarget = targetChar
						if not cameraAimbotLocked then
							cameraAimbotTarget = targetChar
						end
						for _, player in pairs(players:GetPlayers()) do
							if player.Character == targetChar then
								silentAimTarget = player
								break
							end
						end
					end
				end
			end
		end
	end
	if sameKey then
		if triggerBotTarget and triggerBotLocked then
			triggerBotState = false
			triggerBotTarget = nil
			triggerBotLocked = false
			if Config and Config['Main'] and Config['Main']['Sync'] then
				sharedTarget = nil
				if Config['Aim Assist']['Enabled'] and not cameraAimbotLocked then
					cameraAimbotTarget = nil
				end
				if SilentAimConfig['Enabled'] and not silentAimLocked then
					silentAimTarget = nil
				end
			end
		else
			local targetChar, targetPart, targetPos = getBestTriggerBotTarget()
			if targetChar then
				triggerBotTarget = targetChar
				triggerBotLocked = true
				triggerBotState = true
				if Config and Config['Main'] and Config['Main']['Sync'] then
					sharedTarget = targetChar
					syncTargetToFeatures(targetChar)
				end
			end
		end
	elseif isActivateKey and not sameKey then
		if TriggerBotConfig['Mode'] == "Toggle" then
			triggerBotState = not triggerBotState
		elseif TriggerBotConfig['Mode'] == "Hold" then
			triggerBotState = true
		end
		if TriggerBotConfig['Target Mode'] == 'Automatic' and triggerBotState then
			local targetChar, targetPart, targetPos = getBestTriggerBotTarget()
			if targetChar then
				triggerBotTarget = targetChar
				if Config and Config['Main'] and Config['Main']['Sync'] then
					sharedTarget = targetChar
					syncTargetToFeatures(targetChar)
				end
			end
		end
	end
end))

uis.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(input, processed)
	local panicConfig = Config and Config['Main'] and Config['Main']['Panic']
	local triggerBotDisabled = panicMode and panicConfig and panicConfig['Disable Trigger Bot']
	if triggerBotDisabled or not canUseFeatures() then
		return
	end
	if TriggerBotConfig['Enabled'] and TriggerBotConfig['Mode'] == "Hold" then
		local keybinds = Config and Config['Main'] and Config['Main']['Keybinds'] or {}
		local triggerTargetKey = keybinds['Trigger Bot Target'] or 'C'
		local toggleKey = keybinds['Trigger Bot Activate'] or 'MouseButton1'
		local sameKey = (triggerTargetKey == toggleKey)
		if not sameKey then
			local keyInput, isMouseButton = getKey(toggleKey)
			if isMouseButton and input.UserInputType == keyInput then
				triggerBotState = true
			elseif not isMouseButton and input.KeyCode == keyInput then
				triggerBotState = true
			end
		end
	end
end))

uis.InputEnded:Connect(LPH_NO_VIRTUALIZE(function(input, processed)
	local panicConfig = Config and Config['Main'] and Config['Main']['Panic']
	local triggerBotDisabled = panicMode and panicConfig and panicConfig['Disable Trigger Bot']
	if triggerBotDisabled or not canUseFeatures() then
		return
	end
	if TriggerBotConfig['Enabled'] and TriggerBotConfig['Mode'] == "Hold" then
		local keybinds = Config and Config['Main'] and Config['Main']['Keybinds'] or {}
		local triggerTargetKey = keybinds['Trigger Bot Target'] or 'C'
		local toggleKey = keybinds['Trigger Bot Activate'] or 'MouseButton1'
		local sameKey = (triggerTargetKey == toggleKey)
		if not sameKey then
			local keyInput, isMouseButton = getKey(toggleKey)
			if isMouseButton and input.UserInputType == keyInput then
				triggerBotState = false
			elseif not isMouseButton and input.KeyCode == keyInput then
				triggerBotState = false
			end
		end
	end
end))

triggerBotConnection = rs.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
	local mainConfig = Config and Config['Main']
	local panicConfig = mainConfig and mainConfig['Panic']
	local triggerBotDisabled = panicMode and panicConfig and panicConfig['Disable Trigger Bot']
	if not TriggerBotConfig or not TriggerBotConfig['Enabled'] or triggerBotDisabled or not canUseFeatures() then
		updateTriggerBotFov()
		return
	end
	if TriggerBotConfig['Target Mode'] == 'Automatic' then
		local targetChar, targetPart, targetPos = getBestTriggerBotTarget()
		if targetChar then
			triggerBotTarget = targetChar
			if Config and Config['Main'] and Config['Main']['Sync'] then
				sharedTarget = targetChar
				syncTargetToFeatures(targetChar)
			end
		else
			if not triggerBotLocked then
				triggerBotTarget = nil
				if Config and Config['Main'] and Config['Main']['Sync'] then
					sharedTarget = nil
					if Config['Aim Assist']['Enabled'] and not cameraAimbotLocked then
						cameraAimbotTarget = nil
					end
					if SilentAimConfig['Enabled'] and not silentAimLocked then
						silentAimTarget = nil
					end
				end
			end
		end
	elseif TriggerBotConfig['Target Mode'] == 'Target' then
		if Config and Config['Main'] and Config['Main']['Sync'] and sharedTarget and triggerBotLocked then
			triggerBotTarget = sharedTarget
		end
		if triggerBotTarget and not validChar(triggerBotTarget) then
			triggerBotTarget = nil
			triggerBotLocked = false
			if Config and Config['Main'] and Config['Main']['Sync'] then
				sharedTarget = nil
				if Config['Aim Assist']['Enabled'] and not cameraAimbotLocked then
					cameraAimbotTarget = nil
				end
				if SilentAimConfig['Enabled'] and not silentAimLocked then
					silentAimTarget = nil
				end
			end
		end
	end
	if updateTriggerBotFov then updateTriggerBotFov() end
	if triggerBotState and triggerBotTarget and performTrigger then
		performTrigger()
	end
end))
table.insert(activeConnections, triggerBotConnection)

players.PlayerRemoving:Connect(function(player)
	if triggerBotTarget == player.Character then
		triggerBotState = false
		triggerBotTarget = nil
		triggerBotLocked = false
		if Config and Config['Main'] and Config['Main']['Sync'] then
			sharedTarget = nil
		end
	end
end)

resolveTargetCharacter = function(target)
	if not target then
		return nil
	end
	if type(target) == 'table' and target.Character then
		return target.Character
	end
	if typeof(target) == 'Instance' then
		if target:IsA('Player') then
			return target.Character
		elseif target:IsA('Model') then
			return target
		end
	end
	return nil
end

movementModConnection = rs.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
	local character = plr.Character
	if not character then
		defaultWalkSpeed = nil
		defaultJumpPower = nil
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then
		return
	end

	if not defaultWalkSpeed then
		defaultWalkSpeed = humanoid.WalkSpeed
	end
	if not defaultJumpPower then
		defaultJumpPower = humanoid.JumpPower
	end

	local movementConfig = Config['Player Modification'] and Config['Player Modification']['Movement']
	if not movementConfig then
		return
	end

	local speedConfig = movementConfig['Speed Modifications']
	local jumpConfig = movementConfig['Jump Modifications']
	local speedActiveNow = speedModActive and speedConfig and speedConfig['Enabled']
	local jumpActiveNow = jumpPowerActive and jumpConfig and jumpConfig['Enabled']

	if speedActiveNow then
		if not speedModPreviouslyActive or not defaultWalkSpeed then
			defaultWalkSpeed = humanoid.WalkSpeed
		end
		local speedValue = speedConfig['Value'] or 5
		humanoid.WalkSpeed = speedValue * 100
	else
		if speedModPreviouslyActive and defaultWalkSpeed then
			humanoid.WalkSpeed = defaultWalkSpeed
		end
		defaultWalkSpeed = humanoid.WalkSpeed
	end
	speedModPreviouslyActive = speedActiveNow

	if jumpActiveNow then
		if not jumpModPreviouslyActive or not defaultJumpPower then
			defaultJumpPower = humanoid.JumpPower
		end
		local jumpValue = jumpConfig['Value'] or 2
		humanoid.JumpPower = jumpValue * 100
	else
		if jumpModPreviouslyActive and defaultJumpPower then
			humanoid.JumpPower = defaultJumpPower
		end
		defaultJumpPower = humanoid.JumpPower
	end
	jumpModPreviouslyActive = jumpActiveNow
end))
table.insert(activeConnections, movementModConnection)

originalRandom = hookfunction(math.random, function(...)
	local args = {...}

	if checkcaller() then
		return originalRandom(...)
	end

	if (#args == 0)
		or (args[1] == -0.05 and args[2] == 0.05)
		or (args[1] == -0.1)
		or (args[1] == -0.05) then
		return originalRandom(...) * currentSpreadMultiplier
	end

	return originalRandom(...)
end)

weaponSpreadConnection = rs.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
	local character = plr.Character
	if not character then
		currentSpreadMultiplier = 1.0
		return
	end

	local weaponModConfig = Config['Player Modification'] and Config['Player Modification']['Weapon Modifications']
	if not weaponModConfig or not weaponModConfig['Enabled'] then
		currentSpreadMultiplier = 1.0
		return
	end

	local currentTool = character:FindFirstChildWhichIsA("Tool")
	if not currentTool then
		currentSpreadMultiplier = 1.0
		return
	end

	local toolName = currentTool.Name
	local spreadValue = nil

	if toolName == "[Double-Barrel SG]" then
		spreadValue = weaponModConfig['Double-Barrel SG'] and weaponModConfig['Double-Barrel SG']['Value']
	elseif toolName == "[TacticalShotgun]" then
		spreadValue = weaponModConfig['TacticalShotgun'] and weaponModConfig['TacticalShotgun']['Value']
	elseif toolName == "[Shotgun]" or toolName == "[DrumGun]" then
		spreadValue = weaponModConfig['Other Shotguns'] and weaponModConfig['Other Shotguns']['Value']
	end

	if spreadValue then
		currentSpreadMultiplier = spreadValue
	else
		currentSpreadMultiplier = 1.0
	end
end))
table.insert(activeConnections, weaponSpreadConnection)

silentAimRenderConnection = rs.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
	local mainConfig = Config and Config['Main']
	local panicConfig = mainConfig and mainConfig['Panic']
	local syncEnabled = mainConfig and mainConfig['Sync']
	local silentAimDisabled = panicMode and panicConfig and panicConfig['Disable Silent Aim']
	local silentFovConfig = SilentAimConfig and SilentAimConfig['FOV']
	if silentAimLocked and not silentAimTarget then
		clearSilentAimTargetState(true)
	end
	if silentAimTarget then
		local targetCharCheck = resolveTargetCharacter(silentAimTarget)
		if not targetCharCheck or not validChar(targetCharCheck) then
			clearSilentAimTargetState()
		end
	end
	if silentAimDisabled or not canUseFeatures() then
		if fovDrawings.silent.circle then
			fovDrawings.silent.circle.Visible = false
		end
		if silentTargetLine then
			silentTargetLine.Visible = false
		end
		return
	end
	if SilentAimConfig['Target Mode'] == 'Automatic' then
		local closestPlayer = getClosestPlayerSilent(silentFovConfig, true)
		silentAimTarget = closestPlayer
		if silentAimTarget and syncEnabled then
			local targetChar = resolveTargetCharacter(silentAimTarget)
			sharedTarget = targetChar
			syncTargetToFeatures(targetChar)
		end
		if not silentAimTarget then
			local botsFolder = workspace:FindFirstChild('Bots')
			if botsFolder then
				for _, bot in ipairs(botsFolder:GetChildren()) do
					if bot == sharedTarget and bot.Name == 'Dummy' then
						silentAimTarget = {
							Character = bot,
							Name = 'Dummy'
						}
						break
					end
				end
			end
		end
	end
	local fovConfig = silentFovConfig or {}
	local shouldVisualizeFov = SilentAimConfig['Enabled'] and fovConfig['Visualize'] and not silentAimDisabled
	if shouldVisualizeFov and silentAimTarget then
		local targetChar = resolveTargetCharacter(silentAimTarget)
		local hrpPart = targetChar and targetChar:FindFirstChild('HumanoidRootPart')
		if hrpPart then
			local hrpWorldPos = hrpPart.CFrame.Position
			local hrpScreenPos, onScreen = cam:WorldToViewportPoint(hrpWorldPos)
			if onScreen and hrpScreenPos.Z > 0 then
				local targetScreenPos = Vector2.new(hrpScreenPos.X, hrpScreenPos.Y)
				local visualizationConfig = {
					['FOV Type'] = fovConfig['FOV Type'],
					['Circle Value'] = fovConfig['Circle Value'],
					['Box'] = fovConfig['Box'],
					['Visualize'] = true
				}
				local mouseLocation = uis:GetMouseLocation()
				updateFovVisual(fovDrawings.silent, visualizationConfig, mouseLocation, silentColor, targetScreenPos)
			else
				if fovDrawings.silent.box then
					for _, line in pairs(fovDrawings.silent.box) do
						line.Visible = false
					end
				end
				if fovDrawings.silent.circle then
					fovDrawings.silent.circle.Visible = false
				end
				silentTargetLine.Visible = false
			end
		else
			if fovDrawings.silent.box then
				for _, line in pairs(fovDrawings.silent.box) do
					line.Visible = false
				end
			end
			if fovDrawings.silent.circle then
				fovDrawings.silent.circle.Visible = false
			end
			silentTargetLine.Visible = false
		end
	else
		if fovDrawings.silent.box then
			for _, line in pairs(fovDrawings.silent.box) do
				line.Visible = false
			end
		end
		if fovDrawings.silent.circle then
			fovDrawings.silent.circle.Visible = false
		end
	end
    local shouldDrawTargetLine = SilentAimConfig['Target Line'] and SilentAimConfig['Enabled'] and not silentAimDisabled and silentAimTarget
    if silentTargetLine then
    	if shouldDrawTargetLine then
    		local tracerPredicted, tracerBase = getSilentAimTargetInfo(silentAimTarget, {
    			preferHead = true
    		})
    		local tracerWorldPosition = tracerBase or tracerPredicted
    		if tracerWorldPosition then
    			local targetScreenPos3D, onScreen3D = cam:WorldToViewportPoint(tracerWorldPosition)
    			if onScreen3D and targetScreenPos3D.Z > 0 then
    				local mouseLocation = uis:GetMouseLocation()
    				silentTargetLine.From = vector2New(mouseLocation.X, mouseLocation.Y)
    				silentTargetLine.To = vector2New(targetScreenPos3D.X, targetScreenPos3D.Y)
    				silentTargetLine.Visible = true
    			else
    				silentTargetLine.Visible = false
    			end
    		else
    			silentTargetLine.Visible = false
    		end
    	else
    		silentTargetLine.Visible = false
    	end
    end
end))
table.insert(activeConnections, silentAimRenderConnection)

GetGunCategory = function(toolName)
	if not toolName then return nil end
	if table.find(WeaponInfo.Shotguns, toolName) then return "Shotgun" end
	if table.find(WeaponInfo.Pistols, toolName) then return "Pistol" end
	if table.find(WeaponInfo["Assault Rifles"], toolName) then return "Rifle" end
	if table.find(WeaponInfo.Bursts, toolName) then return "Burst" end
	if table.find(WeaponInfo.SMG, toolName) then return "SMG" end
	if table.find(WeaponInfo.Rifle, toolName) then return "Rifle" end
	if table.find(WeaponInfo.AutomaticShotgun, toolName) then return "Auto" end
	return nil
end

GetAimDirection = function(originPos)
	local mouseTarget = mouse.Target
	if mouseTarget then
		return (mouse.Hit.p - originPos).Unit
	end
	local cameraCFrame = cam.CFrame
	local targetPoint = cameraCFrame.p + cameraCFrame.LookVector * 60
	local lookVector = cameraCFrame.LookVector
	local mouseRay = cam:ScreenPointToRay(mouse.X, mouse.Y)
	local rayDirection = mouseRay.Direction
	local rayOrigin = mouseRay.Origin
	local mouseHitPos = rayOrigin + rayDirection * ((targetPoint - rayOrigin):Dot(lookVector) / rayDirection:Dot(lookVector))
	return (mouseHitPos - originPos).Unit
end

CanShootGun = function(character)
	if not character then return false end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then
		return false
	end
	local bodyEffects = character:FindFirstChild("BodyEffects")
	if bodyEffects then
		if bodyEffects:FindFirstChild("K.O") and bodyEffects["K.O"].Value then return false end
		if bodyEffects:FindFirstChild("Cuff") and bodyEffects.Cuff.Value then return false end
		if bodyEffects:FindFirstChild("Grabbed") and bodyEffects.Grabbed.Value then return false end
		if bodyEffects:FindFirstChild("Reload") and bodyEffects.Reload.Value then return false end
		if bodyEffects:FindFirstChild("Dead") and bodyEffects.Dead.Value then return false end
	end
	if character:FindFirstChild("GRABBING_CONSTRAINT") then return false end
	if character:FindFirstChild("FORCEFIELD") then return false end
	local tool = character:FindFirstChildWhichIsA("Tool")
	if not tool or not tool:FindFirstChild("Handle") or not tool:FindFirstChild("Ammo") then
		return false
	end
	return true
end

GetSpreadMultiplier = function(toolName)
	local weaponModConfig = Config['Player Modification'] and Config['Player Modification']['Weapon Modifications']
	if not weaponModConfig or not weaponModConfig['Enabled'] then
		return nil
	end

	local isShotgun = false
	for _, shotgunName in ipairs(WeaponInfo.Shotguns) do
		if toolName == shotgunName then
			isShotgun = true
			break
		end
	end
	for _, autoShotgunName in ipairs(WeaponInfo.AutomaticShotgun) do
		if toolName == autoShotgunName then
			isShotgun = true
			break
		end
	end

	if not isShotgun then
		return nil
	end

	if toolName == "[Double-Barrel SG]" then
		return weaponModConfig['Double-Barrel SG'] and weaponModConfig['Double-Barrel SG']['Value'] or 1.0
	elseif toolName == "[TacticalShotgun]" then
		return weaponModConfig['TacticalShotgun'] and weaponModConfig['TacticalShotgun']['Value'] or 1.0
	elseif toolName == "[Shotgun]" or toolName == "[Drum-Shotgun]" then
		return weaponModConfig['Other Shotguns'] and weaponModConfig['Other Shotguns']['Value'] or 1.0
	end

	return 1.0
end

CalculateSpread = function(spreadMultiplier)
	local SpreadX = math.random() > 0.5 and math.random() * 0.05 or -math.random() * 0.05
	local SpreadY = math.random() > 0.5 and math.random() * 0.1 or -math.random() * 0.1
	local SpreadZ = math.random() > 0.5 and math.random() * 0.05 or -math.random() * 0.05
	return Vector3.new(SpreadX * spreadMultiplier, SpreadY * spreadMultiplier, SpreadZ * spreadMultiplier)
end

ShootGunEmulation = function(tool, targetPosition, legitimatePosition)
	if not tool or not tool:FindFirstChild("Handle") then return end

	local handle = tool.Handle
	local weaponOffset = WeaponInfo.Offsets[tool.Name] or CFrame.new(0, 0, 0)
	local toolEvent = tool:FindFirstChild("RemoteEvent")
	if not toolEvent then return end

	if type(CurrentGame.BeforeShoot) == "function" then
		local success, err = pcall(CurrentGame.BeforeShoot, {
			tool = tool,
			handle = handle,
			targetPosition = targetPosition,
			legitimatePosition = legitimatePosition,
			player = plr
		})
		if not success then

		end
	end

	local forcedOrigin = (tool:FindFirstChild("Default") and
		tool.Default:FindFirstChild("Mesh") and
		tool.Default.Mesh:FindFirstChild("Muzzle") and
		tool.Default.Mesh.Muzzle.WorldPosition) or
		(handle.CFrame * weaponOffset).Position

	local range = tool:FindFirstChild("Range") and tool.Range.Value or 200
	local spreadMultiplier = GetSpreadMultiplier(tool.Name)
	local direction

	if spreadMultiplier then
		local spread = CalculateSpread(spreadMultiplier)
		direction = (targetPosition - forcedOrigin).Unit + spread
	else
		direction = (targetPosition - forcedOrigin).Unit
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {plr.Character, workspace:FindFirstChild("Ignored")}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.IgnoreWater = true

	local rayResult = workspace:Raycast(forcedOrigin, direction * range, raycastParams)
	local hitPosition = rayResult and rayResult.Position or (forcedOrigin + direction * range)
	local hitInstance = rayResult and rayResult.Instance
	local hitNormal = rayResult and rayResult.Normal

	local remoteEvent = CurrentGame.RemotePath()
	if remoteEvent then
		local payload = {
			eventName = CurrentGame.EventName,
			updater = CurrentGame.Updater,
			handle = handle,
			forcedOrigin = forcedOrigin,
			hitPosition = hitPosition,
			hitInstance = hitInstance,
			hitNormal = hitNormal,
			targetPosition = targetPosition,
			legitimatePosition = legitimatePosition,
			tool = tool
		}
		local customFire = CurrentGame.FireServer
		if type(customFire) == "function" then
			customFire(remoteEvent, payload)
		elseif payload.updater then
			remoteEvent:FireServer(payload.updater, payload.eventName, payload.handle, payload.forcedOrigin, payload.hitPosition, payload.hitInstance, payload.hitNormal)
		else
			remoteEvent:FireServer(payload.eventName, payload.handle, payload.forcedOrigin, payload.hitPosition, payload.hitInstance, payload.hitNormal)
		end
	end

	local requiresToolShoot = (type(CurrentGame.FireServer) ~= "function") or (CurrentGame and CurrentGame.RequiresToolEventShoot)
	if requiresToolShoot then
		toolEvent:FireServer("Shoot")
		task.wait(0.001)
		toolEvent:FireServer()
	end
end

ProcessSilentAimShot = function(tool, overrideTarget)
	if not silentAimEmulationEnabled then return false end
	if not SilentAimConfig['Enabled'] then return false end
	local targetEntity = overrideTarget or silentAimTarget
	if not targetEntity then return false end
	local targetChar = resolveTargetCharacter(targetEntity)
	if not targetChar then return false end

	local panicConfig = Config and Config['Main'] and Config['Main']['Panic']
	local silentAimDisabled = panicMode and panicConfig and panicConfig['Disable Silent Aim']
	if silentAimDisabled or not canUseFeatures() then return false end


	if not validChar(targetChar) then return false end

	local predictedPosition, basePosition, targetPart = getSilentAimTargetInfo(targetEntity)
	if not predictedPosition or not targetPart then return false end

	if Config['Target Checks']['Wall'] then
		if not wallCheck(targetPart) then
			return false
		end
	end

	local requireFovCheck = overrideTarget == nil
	if requireFovCheck then
		local mousePos = uis:GetMouseLocation()
		local fovConfig = SilentAimConfig['FOV'] or {}
		if not isWithinFov(targetChar, fovConfig, mousePos) then return false end
	end


	local handle = tool.Handle
	local weaponOffset = WeaponInfo.Offsets[tool.Name] or CFrame.new(0, 0, 0)
	local forcedOrigin = (handle.CFrame * weaponOffset).Position
	local legitDirection = GetAimDirection(forcedOrigin)
	local range = tool:FindFirstChild("Range") and tool.Range.Value or 200
	local legitPosition = forcedOrigin + legitDirection * range

	local shouldRedirect, antiCurveInfo = evaluateAntiCurve(forcedOrigin, predictedPosition, legitDirection)
	updateAntiCurveOverlay(antiCurveInfo)
	if not shouldRedirect then
		return false
	end


	ShootGunEmulation(tool, predictedPosition, legitPosition)
	return true
end

attemptSilentAimShot = function(tool, shooter, forcedTarget)
	if not tool or not shooter then
		return "idle"
	end
	if not CanShootGun(shooter) then
		return "blocked"
	end
	local timingConfig = TriggerBotConfig and TriggerBotConfig['Timing'] or {}
	local configDelay = timingConfig['Cooldown'] or 0
	local weaponDelay = WeaponInfo.Delays and WeaponInfo.Delays[tool.Name] or 0
	local requiredDelay = mathMax(configDelay, weaponDelay or 0, 0)
	local bypassCooldown = forcedTarget ~= nil
	if requiredDelay > 0 and not bypassCooldown then
		lastShotTicks[tool.Name] = lastShotTicks[tool.Name] or 0
		local now = osTime()
		if now - lastShotTicks[tool.Name] < requiredDelay then
			return "cooldown"
		end
		if ProcessSilentAimShot(tool, forcedTarget) then
			lastShotTicks[tool.Name] = now
			return "fired"
		end
		return "idle"
	end
	if ProcessSilentAimShot(tool, forcedTarget) then
		lastShotTicks[tool.Name] = osTime()
		return "fired"
	end
	return "idle"
end

addEspTarget = function(target)
	if not target then
		return
	end
	for i = 1, # espTargets do
		if espTargets[i] == target then
			return
		end
	end
	espTargets[# espTargets + 1] = target
end

removeEspTarget = function(target)
	if not target then
		return
	end
	for i = 1, # espTargets do
		if espTargets[i] == target then
			tableRemove(espTargets, i)
			return
		end
	end
end

cleanupEspDrawings = function(target)
	local drawings = espDrawings[target]
	if drawings then
		if drawings.holder then
			pcall(function()
				drawings.holder:Destroy()
			end)
		end
		if drawings.line then
			pcall(function()
				drawings.line:Remove()
			end)
		end
		if drawings.lineOutline then
			pcall(function()
				drawings.lineOutline:Remove()
			end)
		end
		espDrawings[target] = nil
	end
end

getOrCreateEspScreenGui = function()
	if not espScreenGui or not espScreenGui.Parent then
		espScreenGui = Instance.new("ScreenGui")
		espScreenGui.Name = "RaidAwarenessESP"
		espScreenGui.ResetOnSpawn = false
		espScreenGui.IgnoreGuiInset = true
		espScreenGui.Parent = game:GetService("CoreGui")
	end
	return espScreenGui
end

getEspDrawings = function(target)
	if not espDrawings[target] then
		local gui = getOrCreateEspScreenGui()
		local holder = Instance.new("Frame")
		holder.Name = "ESPHolder"
		holder.BackgroundTransparency = 1
		holder.Size = UDim2.new(0, 100, 0, 100)
		holder.Position = UDim2.new(0, 0, 0, 0)
		holder.Parent = gui
		local boxFrame = Instance.new("Frame")
		boxFrame.Name = "Box"
		boxFrame.BackgroundTransparency = 1
		boxFrame.Size = UDim2.new(1, -2, 1, -2)
		boxFrame.Position = UDim2.new(0, 1, 0, 1)
		boxFrame.Parent = holder
		local boxStroke = Instance.new("UIStroke")
		boxStroke.Color = Color3.fromRGB(0, 0, 0)
		boxStroke.Thickness = 1
		boxStroke.LineJoinMode = Enum.LineJoinMode.Miter
		boxStroke.Parent = boxFrame
		local boxInner = Instance.new("Frame")
		boxInner.Name = "Inner"
		boxInner.BackgroundTransparency = 1
		boxInner.Size = UDim2.new(1, -2, 1, -2)
		boxInner.Position = UDim2.new(0, 1, 0, 1)
		boxInner.Parent = boxFrame
		local innerStroke = Instance.new("UIStroke")
		innerStroke.Color = Color3.fromRGB(255, 255, 255)
		innerStroke.Thickness = 1
		innerStroke.LineJoinMode = Enum.LineJoinMode.Miter
		innerStroke.Parent = boxInner
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "Name"
		nameLabel.BackgroundTransparency = 1
		nameLabel.Size = UDim2.new(0, 0, 0, 0)
		nameLabel.AutomaticSize = Enum.AutomaticSize.XY
		nameLabel.Font = Enum.Font.Code
		nameLabel.TextSize = 13
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextStrokeTransparency = 1
		nameLabel.Parent = holder
		local nameStroke = Instance.new("UIStroke")
		nameStroke.Color = Color3.fromRGB(0, 0, 0)
		nameStroke.Thickness = 1
		nameStroke.LineJoinMode = Enum.LineJoinMode.Miter
		nameStroke.Parent = nameLabel
		local healthBarBg = Instance.new("Frame")
		healthBarBg.Name = "HealthBarBg"
		healthBarBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		healthBarBg.BorderSizePixel = 0
		healthBarBg.Size = UDim2.new(0, 5, 0, 100)
		healthBarBg.Parent = holder
		local healthBarEmpty = Instance.new("Frame")
		healthBarEmpty.Name = "HealthBarEmpty"
		healthBarEmpty.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		healthBarEmpty.BorderSizePixel = 0
		healthBarEmpty.Size = UDim2.new(1, -2, 1, -2)
		healthBarEmpty.Position = UDim2.new(0, 1, 0, 1)
		healthBarEmpty.ZIndex = 1
		healthBarEmpty.Parent = healthBarBg
		local healthBarFill = Instance.new("Frame")
		healthBarFill.Name = "HealthBarFill"
		healthBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		healthBarFill.BorderSizePixel = 0
		healthBarFill.Size = UDim2.new(1, -2, 1, -2)
		healthBarFill.Position = UDim2.new(0, 1, 0, 1)
		healthBarFill.ZIndex = 2
		healthBarFill.Parent = healthBarBg
		espDrawings[target] = {
			holder = holder,
			box = boxFrame,
			boxStroke = innerStroke,
			name = nameLabel,
			healthBarBg = healthBarBg,
			healthBarEmpty = healthBarEmpty,
			healthBarFill = healthBarFill,
			line = nil,
			lineOutline = nil
		}
	end
	return espDrawings[target]
end

updateFovVisuals = LPH_NO_VIRTUALIZE(function()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local viewportSize = camera.ViewportSize
	local centerX = viewportSize.X * 0.5
	local centerY = viewportSize.Y * 0.5
	local center = vector2New(centerX, centerY)
	if RaidAwarenessConfig['Box'] and RaidAwarenessConfig['Box']['Visualize'] then
		if RaidAwarenessConfig['Box']['FOV Method'] ~= (raidFovDrawings.box and raidFovDrawings.box.MethodUsed) then
			if raidFovDrawings.box and raidFovDrawings.box.Drawing then
				raidFovDrawings.box.Drawing:Remove()
			end
			if raidFovDrawings.box and raidFovDrawings.box.Corners then
				for _, corner in ipairs(raidFovDrawings.box.Corners) do
					corner:Remove()
				end
			end
			raidFovDrawings.box = nil
		end
		local boxFov = RaidAwarenessConfig['Box']['FOV'] or 90
		local boxColor = RaidAwarenessConfig['Box']['Box Color'] or Color3.fromRGB(255, 255, 255)
		if RaidAwarenessConfig['Box']['FOV Method'] == 'Circle' then
			if not raidFovDrawings.box or not raidFovDrawings.box.Drawing then
				raidFovDrawings.box = {
					Drawing = Drawing.new("Circle"),
					MethodUsed = 'Circle'
				}
				raidFovDrawings.box.Drawing.Thickness = 1
				raidFovDrawings.box.Drawing.Filled = false
			end
			raidFovDrawings.box.Drawing.Position = center
			raidFovDrawings.box.Drawing.Radius = (viewportSize.Y / 2) * (boxFov / 90)
			raidFovDrawings.box.Drawing.Color = boxColor
			raidFovDrawings.box.Drawing.Visible = true
		elseif RaidAwarenessConfig['Box']['FOV Method'] == 'Box' then
			if not raidFovDrawings.box or not raidFovDrawings.box.Corners then
				raidFovDrawings.box = {
					Corners = {},
					MethodUsed = 'Box'
				}
				for i = 1, 4 do
					table.insert(raidFovDrawings.box.Corners, Drawing.new("Line"))
				end
			end
			local halfFov = (boxFov * 0.5) * (mathPi / 180)
			local distance = (viewportSize.Y * 0.5) / mathTan(halfFov)
			local width = distance * mathTan(halfFov)
			local height = width
			local corners = {
				Vector2.new(center.X - width, center.Y - height),
				Vector2.new(center.X + width, center.Y - height),
				Vector2.new(center.X + width, center.Y + height),
				Vector2.new(center.X - width, center.Y + height)
			}
			for i, corner in ipairs(raidFovDrawings.box.Corners) do
				local nextI = (i % 4) + 1
				corner.From = corners[i]
				corner.To = corners[nextI]
				corner.Color = boxColor
				corner.Thickness = 1
				corner.Visible = true
			end
		end
	elseif raidFovDrawings.box then
		if raidFovDrawings.box.Drawing then
			raidFovDrawings.box.Drawing.Visible = false
		end
		if raidFovDrawings.box.Corners then
			for _, corner in ipairs(raidFovDrawings.box.Corners) do
				corner.Visible = false
			end
		end
	end
	if RaidAwarenessConfig['Name'] and RaidAwarenessConfig['Name']['Show FOV'] then
		if not raidFovDrawings.name then
			raidFovDrawings.name = Drawing.new("Circle")
			raidFovDrawings.name.Thickness = 1
			raidFovDrawings.name.Filled = false
		end
		local nameFov = RaidAwarenessConfig['Name']['FOV'] or 90
		raidFovDrawings.name.Position = center
		raidFovDrawings.name.Radius = (viewportSize.Y * 0.5) * (nameFov / 90)
		raidFovDrawings.name.Color = RaidAwarenessConfig['Name']['Color'] or Color3.fromRGB(255, 255, 255)
		raidFovDrawings.name.Visible = true
	elseif raidFovDrawings.name then
		raidFovDrawings.name.Visible = false
	end
	if RaidAwarenessConfig['Health'] and RaidAwarenessConfig['Health']['Show FOV'] then
		if not raidFovDrawings.health then
			raidFovDrawings.health = Drawing.new("Circle")
			raidFovDrawings.health.Thickness = 1
			raidFovDrawings.health.Filled = false
		end
		local healthFov = RaidAwarenessConfig['Health']['FOV'] or 90
		raidFovDrawings.health.Position = center
		raidFovDrawings.health.Radius = (viewportSize.Y * 0.5) * (healthFov / 90)
		raidFovDrawings.health.Color = RaidAwarenessConfig['Health']['Color'] or Color3.fromRGB(0, 255, 0)
		raidFovDrawings.health.Visible = true
	elseif raidFovDrawings.health then
		raidFovDrawings.health.Visible = false
	end
end)

uis.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(input, processed)
	local panicConfig = Config and Config['Main'] and Config['Main']['Panic']
	local visualsDisabled = panicMode and panicConfig and panicConfig['Disable Visuals']
	if processed or visualsDisabled then
		return
	end
	if RaidAwarenessConfig['Enabled'] then
		local binds = RaidAwarenessConfig['Binds'] or {}
		local addKey = getKey(binds['Add Target'])
		local removeKey = getKey(binds['Remove Target'])
		if input.KeyCode == addKey then
			local mouseTarget = mouse.Target
			if mouseTarget then
				local character = mouseTarget.Parent
				if character and not character:FindFirstChild("Humanoid") then
					character = character.Parent
				end
				if character and character:FindFirstChild("Humanoid") then
					for _, player in pairs(players:GetPlayers()) do
						if player.Character == character then
							addEspTarget(player)
							return
						end
					end
				end
			end
		elseif input.KeyCode == removeKey then
			local mouseTarget = mouse.Target
			if mouseTarget then
				local character = mouseTarget.Parent
				if character and not character:FindFirstChild("Humanoid") then
					character = character.Parent
				end
				if character and character:FindFirstChild("Humanoid") then
					for _, player in pairs(players:GetPlayers()) do
						if player.Character == character then
							removeEspTarget(player)
							cleanupEspDrawings(player)
							return
						end
					end
				end
			end
		end
	end
end))

table.insert(activeConnections, rs.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
	local mainConfig = Config and Config['Main']
	local panicConfig = mainConfig and mainConfig['Panic']
	local visualsDisabled = panicMode and panicConfig and panicConfig['Disable Visuals']
	if not RaidAwarenessConfig or not RaidAwarenessConfig['Enabled'] or visualsDisabled then
		for target, _ in pairs(espDrawings) do
			cleanupEspDrawings(target)
		end
		cleanupFovVisuals()
		return
	end
	updateFovVisuals()
	local maxRenderDistance = RaidAwarenessConfig['Max Render Distance'] or 1000
	local maxRenderDistSq = maxRenderDistance * maxRenderDistance
	for i = # espTargets, 1, -1 do
		local target = espTargets[i]
		if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
			table.remove(espTargets, i)
			cleanupEspDrawings(target)
		end
	end
	for _, target in ipairs(espTargets) do
		if target and target.Character then
			local character = target.Character
			local hrp = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if hrp and humanoid then
				local distance = (hrp.Position - cam.CFrame.Position).Magnitude
				local maxRenderDistance = RaidAwarenessConfig['Max Render Distance'] or 1000
				if distance > maxRenderDistance then
					local drawings = getEspDrawings(target)
					if drawings then
						if drawings.box then
							drawings.box.Visible = false
						end
						if drawings.name then
							drawings.name.Visible = false
						end
						if drawings.healthBar then
							drawings.healthBar.Visible = false
						end
						if drawings.healthBarBg then
							drawings.healthBarBg.Visible = false
						end
					end
				end
				local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
				if onScreen and screenPos.Z > 0 then
					local screenPosition = Vector2.new(screenPos.X, screenPos.Y)
					local drawings = getEspDrawings(target)
					local mainPart = hrp
					if not mainPart then
						return
					end
					local ViewportTop = mainPart.Position + (mainPart.CFrame.UpVector * 1.8) + cam.CFrame.UpVector
					local ViewportBottom = mainPart.Position - (mainPart.CFrame.UpVector * 2.5) - cam.CFrame.UpVector
					local topPoint, topOnScreen = cam:WorldToViewportPoint(ViewportTop)
					local bottomPoint, bottomOnScreen = cam:WorldToViewportPoint(ViewportBottom)
					if not (topOnScreen and bottomOnScreen) then
						return
					end
					local top = vector2New(topPoint.X, topPoint.Y)
					local bottom = vector2New(bottomPoint.X, bottomPoint.Y)
					local width = mathMax(mathFloor(mathAbs(top.X - bottom.X)), 8)
					local height = mathMax(mathFloor(mathMax(mathAbs(bottom.Y - top.Y), width * 0.5)), 12)
					local boxWidth = mathFloor(mathMax(height / 1.5, width))
					local boxSize = vector2New(boxWidth, height)
					local boxPos = vector2New(
                        mathFloor(top.X * 0.5 + bottom.X * 0.5 - boxWidth * 0.5), mathFloor(mathMin(top.Y, bottom.Y)))
					if RaidAwarenessConfig['Box'] and RaidAwarenessConfig['Box']['Enabled'] then
						local boxColor = RaidAwarenessConfig['Box']['Box Color'] or Color3.fromRGB(255, 255, 255)
						drawings.holder.Size = UDim2.new(0, boxWidth, 0, height)
						drawings.holder.Position = UDim2.new(0, boxPos.X, 0, boxPos.Y)
						drawings.holder.Visible = true
						drawings.box.Visible = true
						drawings.boxStroke.Color = boxColor
					else
						if drawings.box then
							drawings.box.Visible = false
						end
					end
					if RaidAwarenessConfig['Name'] and RaidAwarenessConfig['Name']['Enabled'] then
						local nameType = RaidAwarenessConfig['Name']['Type'] or 'Display'
						local displayName = nameType == 'Display' and target.DisplayName or target.Name
						local nameColor = RaidAwarenessConfig['Name']['Color'] or Color3.fromRGB(255, 255, 255)
						local nameSize = RaidAwarenessConfig['Name']['Size'] or 13
						drawings.name.Text = displayName
						drawings.name.TextColor3 = nameColor
						drawings.name.TextSize = nameSize
						drawings.name.Position = UDim2.new(0.5, 0, 0, -20)
						drawings.name.AnchorPoint = Vector2.new(0.5, 1)
						drawings.name.Visible = true
					else
						if drawings.name then
							drawings.name.Visible = false
						end
					end
					if RaidAwarenessConfig['Health'] and RaidAwarenessConfig['Health']['Enabled'] then
						local healthType = RaidAwarenessConfig['Health']['Type'] or 'Bar'
						local currentHealth = humanoid.Health
						local maxHealth = humanoid.MaxHealth
						local healthPercent = math.clamp(currentHealth / maxHealth, 0, 1)
						if healthType == 'Bar' then
							local barWidth = 3
							local barHeight = height
							drawings.healthBarBg.Size = UDim2.new(0, barWidth + 2, 0, barHeight + 2)
							drawings.healthBarBg.Position = UDim2.new(1, 4, 0, -1)
							drawings.healthBarBg.Visible = true
							local fillHeight = barHeight * healthPercent
							drawings.healthBarEmpty.Visible = true
							drawings.healthBarFill.Size = UDim2.new(1, -2, healthPercent, -2)
							drawings.healthBarFill.Position = UDim2.new(0, 1, 1 - healthPercent, 1)
							drawings.healthBarFill.Visible = true
							local lowColor = RaidAwarenessConfig['Health']['Missing Health Color'] or Color3.fromRGB(255, 0, 0)
							local highColor = RaidAwarenessConfig['Health']['High Health Color'] or Color3.fromRGB(0, 255, 0)
							drawings.healthBarEmpty.BackgroundColor3 = lowColor
							drawings.healthBarFill.BackgroundColor3 = highColor
						end
					else
						if drawings.healthBarBg then
							drawings.healthBarBg.Visible = false
						end
					end
					if RaidAwarenessConfig['Lines'] and RaidAwarenessConfig['Lines']['Enabled'] then
						if not drawings.line then
							drawings.line = Drawing.new("Line")
							drawings.lineOutline = Drawing.new("Line")
						end
						local lineType = RaidAwarenessConfig['Lines']['Type'] or 'Top'
						local lineColor = RaidAwarenessConfig['Lines']['Color'] or Color3.fromRGB(255, 255, 255)
						local lineFrom = Vector2.new(0, 0)
						if lineType == 'Top' then
							lineFrom = Vector2.new(cam.ViewportSize.X / 2, 0)
						elseif lineType == 'Bottom' then
							lineFrom = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
						elseif lineType == 'Mouse' then
							lineFrom = uis:GetMouseLocation()
						elseif lineType == 'Middle' then
							lineFrom = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
						end
						drawings.lineOutline.From = lineFrom
						drawings.lineOutline.To = screenPosition
						drawings.lineOutline.Color = Color3.fromRGB(0, 0, 0)
						drawings.lineOutline.Thickness = 2.8
						drawings.lineOutline.Visible = true
						drawings.line.From = lineFrom
						drawings.line.To = screenPosition
						drawings.line.Color = lineColor
						drawings.line.Thickness = 2
						drawings.line.Visible = true
					else
						if drawings.line then
							drawings.line.Visible = false
						end
						if drawings.lineOutline then
							drawings.lineOutline.Visible = false
						end
					end
				else
					cleanupEspDrawings(target)
				end
			else
				cleanupEspDrawings(target)
			end
		else
			cleanupEspDrawings(target)
		end
	end
end)))

players.PlayerRemoving:Connect(function(player)
	if silentAimTarget == player then
		silentAimTarget = nil
		if Config and Config['Main'] and Config['Main']['Sync'] then
			sharedTarget = nil
		end
	end
	if cameraAimbotTarget == player.Character then
		cameraAimbotLocked = false
		cameraAimbotTarget = nil
		if Config and Config['Main'] and Config['Main']['Sync'] then
			sharedTarget = nil
		end
	end
	removeEspTarget(player)
	cleanupEspDrawings(player)
end)

plr.CharacterAdded:Connect(function(character)
	pcall(function()
		character:WaitForChild('BodyEffects', 10)
	end)
	setupCharacterToolHooks(character)
end)

if plr.Character then
	setupCharacterToolHooks(plr.Character)
end

uis.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(input, processed)
	local panicConfig = Config and Config['Main'] and Config['Main']['Panic']
	local silentAimDisabled = panicMode and panicConfig and panicConfig['Disable Silent Aim']
	if processed or silentAimDisabled or not canUseFeatures() then
		return
	end
	local keybinds = Config and Config['Main'] and Config['Main']['Keybinds'] or {}
	local silentAimKey = getKey and getKey(keybinds['Silent Aim'])
	if input.KeyCode == silentAimKey then
		if SilentAimConfig['Target Mode'] == 'Target' then
			if silentAimLocked then
				clearSilentAimTargetState(true)
			else
				silentAimTarget = getClosestPlayerSilent(SilentAimConfig and SilentAimConfig['FOV'], true)
				if silentAimTarget then
					silentAimLocked = true
					if Config and Config['Main'] and Config['Main']['Sync'] then
						local targetChar = resolveTargetCharacter(silentAimTarget)
						sharedTarget = targetChar
						syncTargetToFeatures(targetChar)
					end
				end
			end
		end
	end
end))

shared.CiderCleanup = function()
	pcall(function()
		for _, connection in ipairs(activeConnections) do
			if connection and connection.Disconnect then
				connection:Disconnect()
			end
		end
		activeConnections = {}
	end)
	pcall(function()
		hideAimAssistVisuals()
	end)
	pcall(function()
		hideTriggerBotVisuals()
	end)
	task.wait(0.05)
	pcall(function()
		destroyFovVisualizer()
	end)
	pcall(function()
		destroyTriggerBotFovVisualizer()
	end)
	pcall(function()
		if fovDrawings.silent then
			if fovDrawings.silent.circle then
				pcall(function()
					fovDrawings.silent.circle.Visible = false
				end)
				pcall(function()
					fovDrawings.silent.circle:Remove()
				end)
			end
			if fovDrawings.silent.box and # fovDrawings.silent.box > 0 then
				for _, line in ipairs(fovDrawings.silent.box) do
					if line then
						pcall(function()
							line.Visible = false
						end)
						pcall(function()
							line:Remove()
						end)
					end
				end
			end
			if fovDrawings.silent.line then
				pcall(function()
					fovDrawings.silent.line.Visible = false
				end)
				pcall(function()
					fovDrawings.silent.line:Remove()
				end)
			end
			fovDrawings.silent = nil
		end
	end)
	pcall(function()
		cleanupFovVisuals()
	end)
	pcall(function()
		for target, _ in pairs(espDrawings) do
			cleanupEspDrawings(target)
		end
	end)
end

pcall(function()
	plr:GetPropertyChangedSignal("Parent"):Connect(function()
		if not plr.Parent then
			pcall(shared.CiderCleanup)
		end
	end)
end)

pcall(function()
	plr.AncestryChanged:Connect(function(child, parent)
		if not parent then
			pcall(shared.CiderCleanup)
		end
	end)
end)
