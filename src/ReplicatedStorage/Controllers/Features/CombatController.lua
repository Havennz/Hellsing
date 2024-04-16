local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage.Shared.Utils)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Player = Players.LocalPlayer
local hitCounter = 0
local Animations = ReplicatedStorage.Assets.CombatAnimations
local punchAnimCooldown = 0.4
local lastPunch = tick()
local CombatController = Knit.CreateController({
	Name = "CombatController",
	--Animations = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Combat"),
})

--[[
	Exemplo de como a função getAdaptedParams vai se comportar: 
	```lua
	newParams.Damage = damage or 5
	newParams.Range = range or 20
	newParams.ExecutorName = executorName or ""
	newParams.Size = size or Vector3.new(5,5,5)
	newParams.Position = position or Vector3.zero
	newParams.Effects = Effects
	```

	Header:
	```lua
	getAdaptedParams(damage, range, executorName, size, position, effects)
	```
]]

local function PlayPunchAnimation(humanoid, hitCounter)
	local animator = humanoid:FindFirstChildWhichIsA("Animator") or Instance.new("Animator")
	animator.Parent = humanoid

	local animation = (hitCounter % 2 == 0) and Animations.LeftPunch or Animations.RightPunch

	local animationTrack = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	if animationTrack then
		animationTrack:Play()
	else
		print("Error playing punch animation:", unpack(animationTrack))
	end
end

function CombatController:lightHit()
	local customParams = {
		["Burning"] = false,
		["Parryable"] = true,
		["Blockable"] = true,
		["StunTime"] = 0.5,
		["Knockback"] = false,
	}

	if Player:GetAttribute("LastHit") ~= nil and hitCounter == 4 then
		customParams.Knockback = true
		hitCounter = 0
	end

	if Player:GetAttribute("LastHit") ~= nil and tick() - Player:GetAttribute("LastHit") > 1.5 then
		hitCounter = 0
	end
	Player:SetAttribute("LastHit", tick())
	local CombatService = Knit.GetService("CombatService")
	local char = Player.Character
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local Humanoid = char:FindFirstChild("Humanoid")

	if tick() - lastPunch > punchAnimCooldown then
		local animator = Humanoid:FindFirstChildWhichIsA("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = Humanoid
		end

		if hitCounter % 2 == 0 then
			local animation = Animations.LeftPunch
			local animationTrack = animator:LoadAnimation(animation)
			animationTrack:Play()
		else
			local animation = Animations.RightPunch
			local animationTrack = animator:LoadAnimation(animation)
			animationTrack:Play()
		end
		lastPunch = tick()
	end

	if hrp then
		hitCounter += 1
		local Params =
			Utils.getAdaptedParams(5, 20, Players.LocalPlayer.Name, Vector3.new(10, 10, 10), hrp.CFrame, customParams)
		CombatService:SanityCheck(Params)
	else
		warn("Humanoidrootpart not found")
	end
end

function CombatController:KnitStart() end

function CombatController:KnitInit() end

return CombatController
