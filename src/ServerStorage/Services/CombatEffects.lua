local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Utils = require(ReplicatedStorage.Shared.Utils)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages._Index["sleitnick_signal@2.0.1"].signal)
local Observer = require(ReplicatedStorage.Packages.Observers)

local CombatEffectsService = Knit.CreateService({
	Name = "CombatEffectsService",
	Client = {},
})
