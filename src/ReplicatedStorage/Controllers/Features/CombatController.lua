local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CombatController = Knit.CreateController({
	Name = "CombatController",
	Aniationss = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Combat"),
})

function CombatController:KnitStart() end

function CombatController:KnitInit() end

return CombatController
