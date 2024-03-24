local Utils = require(ReplicatedStorage.Shared.Utils)
local Knit = require(ReplicatedStorage.Packages.Knit)

local CurrencyService = Knit.CreateService({
	Name = "CurrencyService",
	Client = {},
})


function CurrencyService:KnitStart()
end
function CurrencyService:KnitInit() end

return CurrencyService
