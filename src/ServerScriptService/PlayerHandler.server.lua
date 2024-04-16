local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Utils = require(ReplicatedStorage.Shared.Utils)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages._Index["sleitnick_signal@2.0.1"].signal)
local Observers = require(ReplicatedStorage.Packages.Observers)

Observers.observePlayer(function(player)
    Observers.observeCharacter(function(player, character)
        --...

        return function()
			print("Character removed for " .. player.Name)
		end
	end)

    return function()
		print(player.Name .. " left game")
	end
end)
