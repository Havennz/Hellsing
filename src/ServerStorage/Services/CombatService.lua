local Utils = require(ReplicatedStorage.Shared.Utils)
local Knit = require(ReplicatedStorage.Packages.Knit)

local CombatService = Knit.CreateService({
	Name = "CombatService",
	Client = {},
})

function CombatService:KnitStart() end

function CombatService:KnitInit() end

return CombatService
