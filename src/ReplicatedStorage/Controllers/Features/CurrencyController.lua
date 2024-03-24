local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CurrencyController = Knit.CreateController({
	Name = "CurrencyController",
})

function CurrencyController:KnitStart()
end

function CurrencyController:KnitInit()
end

return CurrencyController
