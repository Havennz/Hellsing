local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local combatParams = require(ReplicatedStorage.Shared.CombatParams)
local Utils = {}

function Utils.getApproximatedString(inputName, candidates)
	inputName = string.lower(inputName)

	local bestMatch = nil
	local maxMatchLength = 0

	for _, candidate in pairs(candidates) do
		local candidateLower = string.lower(candidate)

		local inputIndex, candidateIndex = 1, 1
		local currentMatchLength = 0

		while inputIndex <= #inputName and candidateIndex <= #candidateLower do
			if inputName:sub(inputIndex, inputIndex) == candidateLower:sub(candidateIndex, candidateIndex) then
				currentMatchLength = currentMatchLength + 1
				inputIndex = inputIndex + 1
				candidateIndex = candidateIndex + 1
			else
				currentMatchLength = 0
				candidateIndex = candidateIndex + 1
			end

			if currentMatchLength > maxMatchLength then
				maxMatchLength = currentMatchLength
				bestMatch = candidate
			end
		end
	end

	local threshold = 3
	if maxMatchLength >= threshold then
		return bestMatch
	else
		return nil
	end
end

function Utils:GetPlayerNames()
	local names = {}
	for _, player in pairs(Players:GetPlayers()) do
		table.insert(names, player.Name)
	end
	return names
end

function Utils:GetPlayerByName(string)
	local name
	local Names = self:GetPlayerNames()
	name = self.getApproximatedString(string, Names)
	if name then
		return name
	else
		warn("Couldnt find that player.")
		return "Dê um nome Valido"
	end
end

function Utils:FindItemInPlayerInventory(playerName, toolName)
	local plr = Players:FindFirstChild(playerName)

	if plr then
		local backpackItem = plr.Backpack:FindFirstChild(toolName)
		local equippedItem = plr.Character:FindFirstChild(toolName)

		if backpackItem then
			return backpackItem
		end
		if equippedItem then
			return equippedItem
		end
		warn("Cant find any item with the name: " .. toolName)
		return false
	else
		warn("Couldnt find the player with the name: " .. playerName)
	end
end

function Utils.getAdaptedParams(damage, range, executorName, size, position, customEffects, hitType)
	local defaultEffects = {
		["Burning"] = false,
		["Parryable"] = true,
		["Blockable"] = true,
		["StunTime"] = 0.5,
		["Knockback"] = false,
	}

	local Effects = customEffects or defaultEffects

	local newParams = combatParams:GetDefaultParams()
	newParams.Damage = damage or 5
	newParams.Range = range or 20
	newParams.ExecutorName = executorName or ""
	newParams.Size = size or Vector3.new(5, 5, 5)
	newParams.Position = position or Vector3.zero
	newParams.Effects = Effects
	newParams.hitType = hitType or "normalHit"

	return newParams
end

function Utils:GerarSom(idMusica, volume, parent)
	local som = Instance.new("Sound")
	som.SoundId = "rbxassetid://" .. tostring(idMusica)
	som.Volume = volume or 1
	som.PlaybackSpeed = 1
	som.Parent = parent
	som:Play()
	game:GetService("Debris"):AddItem(som, som.TimeLength + 1)
end

return Utils
