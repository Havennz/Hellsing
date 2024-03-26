local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Utils = require(ReplicatedStorage.Shared.Utils)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages._Index["sleitnick_signal@2.0.1"].signal)

local CombatService = Knit.CreateService({
	Name = "CombatService",
	Client = {},
	defaultParams = require(ReplicatedStorage.Shared:FindFirstChild("CombatParams")),
})

--[[
	Parâmetros de exemplo que devem ser passados para a função CreateHitBox:

	```lua
		params = {
			["OnlyHumanoids"] = true,
			["ExecutorName"] = "danilozoom", -- Exemplo de valor
			["Size"] = Vector3,
			["Position"] = Vector3 / CFrame,
			["Damage"] = 0,
			["Range"] = 100,
			["HitType"] = "normalHit",
			["Effects"] = {
				["Burning"] = false,
				["Parryable"] = true,
				["Blockable"] = true,
				["StunTime"] = 0.5,
			},
		}
	```
]]

function adaptParamsWithDefault(params, default)
	local adaptedParams = {}
	for key, value in pairs(default) do
		adaptedParams[key] = value
	end

	for key, value in pairs(params) do
		adaptedParams[key] = value
	end

	return adaptedParams
end

function makePlayerInCooldown(cooldownType, playerName, time)
	local Player = Players:FindFirstChild(playerName)
	local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
	CollectionService:AddTag(HumanoidRootPart, cooldownType)
	task.delay(time, function()
		local Tags = CollectionService:GetAllTags(HumanoidRootPart)
		warn(Tags)
		CollectionService:RemoveTag(HumanoidRootPart, cooldownType)
	end)
end

function checkIfInCooldown(playerName, specific)
	local Player = Players:FindFirstChild(playerName)
	local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
	local Tags = CollectionService:GetAllTags(HumanoidRootPart)
	for _, x in pairs(Tags) do
		if x == specific then
			return true
		end
	end
	return false
end

function CheckHitBox(params)
	local Parts = workspace:GetPartBoundsInBox(params["Position"], params["Size"], OverlapParams.new())

	local Enemys = {}
	local EnemySet = {}

	for _, part in pairs(Parts) do
		local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid then
			if not EnemySet[part.Parent] and part.Parent.Name ~= params["ExecutorName"] then
				table.insert(Enemys, part.Parent)
				EnemySet[part.Parent] = true
			end
		else
			if not EnemySet[part] then
				table.insert(Enemys, part)
				EnemySet[part] = true
			end
		end
	end

	if RunService:IsServer() then
		CombatService:TagHumanoid(params, Enemys)
	else
		return Enemys
	end
end

function CombatService.Client:CreateHitBox(player, params)
	return CheckHitBox(params)
end

function CombatService:CreateHitBox(params)
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
	if not checkIfInCooldown(player.Name, params["HitType"]) then
		self.Server:CreateHitBox(params)
	end
end

function CombatService:TagHumanoid(params: table, Enemys: table)
	local AdaptedParams = adaptParamsWithDefault(params, self.defaultParams:GetDefaultParams())
	local Player = Players:FindFirstChild(params["ExecutorName"])
	for _, x in pairs(Enemys) do
		if x:IsA("Model") then
			local hum = x:FindFirstChildOfClass("Humanoid")
			if hum then
				hum:TakeDamage(AdaptedParams["Damage"])
			end
		end
	end

	makePlayerInCooldown(AdaptedParams["HitType"], Player.Name, 0.4)
end

function CombatService:KnitStart() end

function CombatService:KnitInit() end

return CombatService
