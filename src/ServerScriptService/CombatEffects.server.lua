local CollectionService = game:GetService("CollectionService")
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

		Observers.observeTag("onFire", function(RootPart: BasePart)
			local playerName = RootPart.Parent.Name
			local Humanoid = RootPart.Parent:FindFirstChildOfClass("Humanoid")
			local fireTickThread
			if Humanoid then
				fireTickThread = task.spawn(function()
					while true do
						task.wait(0.4)
						Humanoid:TakeDamage(1)
					end
				end)
			end

			return function()
				task.cancel(fireTickThread)
				print(playerName .. " is no longer on fire")
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
