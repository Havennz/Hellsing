local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage.Shared.Utils)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Player = Players.LocalPlayer
local hitCounter = 0

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

	Player:SetAttribute("LastHit", tick())
	local CombatService = Knit.GetService("CombatService")
	local char = Player.Character
	local hrp = char:FindFirstChild("HumanoidRootPart")
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
