local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local DenDenController = Knit.CreateController({
	Name = "DenDenController",
})

function DenDenController:KnitStart()
end

function DenDenController:KnitInit()
end

return DenDenController
