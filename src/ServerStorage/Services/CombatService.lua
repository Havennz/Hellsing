local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Utils = require(ReplicatedStorage.Shared.Utils)
local Knit = require(ReplicatedStorage.Packages.Knit)

local CombatService = Knit.CreateService({
	Name = "CombatService",
	Client = {},
})

--[[
	Parâmetros de exemplo que devem ser passados para a função CreateHitBox:

	```lua
		params = {
			["OnlyHumanoids"] = true,
			["Size"] = Vector3,
			["Position"] = Vector3 / CFrame,
			["Damage"] = 0,
			["Effects"] = {
				["Burning"] = false
				["Parryable"] = true
				["Blockable"] = true
				["StunTime"] = 0.5
			},
		}
	```
]]

function CheckHitBox(params)
	local halfSize = params["Size"] / 2
	local lowerBound = params["Position"] - halfSize
	local upperBound = params["Position"] + halfSize

	local Parts = workspace:GetPartBoundsInBox(lowerBound, upperBound)

	local Enemys = {}
	for _, part in pairs(Parts) do
		local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
		if params["OnlyHumanoid"] then
			if humanoid then
				table.insert(Enemys, part.Parent)
			end
		else
			if not Enemys[part.Parent] then
				table.insert(Enemys, part.Parent)
			end
		end
	end

	if RunService:IsServer() then
		CombatService:TagHumanoid(params)
	else
		return Enemys
	end
end

function CombatService.Client:CreateHitBox(player, params)
	return CheckHitBox(params)
end

function CombatService.Client:SanityCheck(player, params)
	local Character = player.Character
	if not Character then
		warn("Sanity Check failed: Player's character not found.")
		return
	end

	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	if not HumanoidRootPart then
		warn("Sanity Check failed: HumanoidRootPart not found.")
		return
	end

	local distance = (HumanoidRootPart.Position - params["Position"]).Magnitude
	if distance > 400 then
		warn(
			("Sanity Check failed for %s: The player is too far from the location that he's trying to attack, distance: %d"):format(
				player.Name,
				distance
			)
		)
	end
end

function CombatService:CreateHitBox(params)
	return CheckHitBox(params)
end

function CombatService:TagHumanoid(params) end

function CombatService:KnitStart() end

function CombatService:KnitInit() end

return CombatService
