local Character: Model = script.Parent.Parent
local Torso: BasePart = Character:WaitForChild("Torso")
local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
local RagdollValue: BoolValue = Character:WaitForChild("IsRagdoll")

local function push()
	Torso:ApplyImpulse(Torso.CFrame.LookVector * 100)
end

RagdollValue:GetPropertyChangedSignal("Value"):Connect(function()
	if Humanoid.Health == 0 then --> Prevents OOF sound from playing twice thanks to @robloxdestroyer1035
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		push()
		return
	end

	if RagdollValue.Value then
		Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		push()
	elseif not RagdollValue.Value then
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)

Humanoid.Died:Connect(push)
