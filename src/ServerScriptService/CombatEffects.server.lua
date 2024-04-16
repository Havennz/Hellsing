local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Utils = require(ReplicatedStorage.Shared.Utils)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages._Index["sleitnick_signal@2.0.1"].signal)
local Observers = require(ReplicatedStorage.Packages.Observers)

--[[
    https://sleitnick.github.io/RbxObservers/docs/Observers/players
]]

Observers.observePlayer(function(player)
	Observers.observeCharacter(function(player, character)
		print("Character spawned for " .. player.Name)
		-- Wait for humanoid:
		local humanoid = character:WaitForChild("Humanoid", 60) -- waits at least 60 seconds before giving up

		-- Handle with the humanoid death
		local onDiedConn: RBXScriptConnection? = nil
		if humanoid then
			onDiedConn = humanoid.Died:Connect(function()
				print("Character died for " .. player.Name)
			end)
		end

		-- Effects handler with observe tag

		Observers.observeTag("Stun", function(RootPart)
			local playerName = RootPart.Parent.Name
			local Humanoid: Humanoid = RootPart.Parent:FindFirstChildOfClass("Humanoid")

			local normalMoveSpeed = humanoid.WalkSpeed
			local nerfedWalkSpeed = normalMoveSpeed * 0.2

			Humanoid.WalkSpeed = nerfedWalkSpeed
			return function()
				Humanoid.WalkSpeed = normalMoveSpeed
			end
		end)

		Observers.observeTag("Ragdoll", function(RootPart: Part)
			local char = RootPart.Parent
			local Torso = char:FindFirstChild("Torso")
			local isRag = char:FindFirstChild("IsRagdoll")
			isRag.Value = true
			return function()
				isRag.Value = false
			end
		end)

		Observers.observeTag("onFire", function(RootPart: BasePart)
			local fireEffect = ReplicatedStorage.Effects.Particles.Fire.FireParticle:Clone()
			local playerName = RootPart.Parent.Name
			local Humanoid = RootPart.Parent:FindFirstChildOfClass("Humanoid")
			local fireTickThread
			if Humanoid then
				fireEffect.Parent = RootPart
				fireTickThread = task.spawn(function()
					while true do
						task.wait(0.4)
						Humanoid:TakeDamage(1)
					end
				end)
			end

			return function()
				fireEffect.Fire1.Enabled = false
				Debris:AddItem(fireEffect, 1)
				task.cancel(fireTickThread)
			end
		end)

		return function()
			-- Character was removed
			print("Character removed for " .. player.Name)
			if onDiedConn then
				onDiedConn:Disconnect()
				onDiedConn = nil
			end
		end
	end)

	return function()
		print(player.Name .. " left game")
	end
end)
