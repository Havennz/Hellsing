local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Controllers = ReplicatedStorage.Shared.Controllers

for _, module in pairs(Controllers:GetDescendants()) do
	if module:IsA("ModuleScript") and string.match(module.Name, "Controller$") then
		require(module)
	end
end

Knit.Start():catch(warn)

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local CombatController = Knit.GetController("CombatController")
		warn("Clicking")
		CombatController:lightHit()
	end
end)
