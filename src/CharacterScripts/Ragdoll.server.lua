--> Perfect R6 Ragdoll by CompletedLoop
--> June 6, 2023

--> Make sure this script is located in StarterPlayer.StarterCharacterScripts
local Character: Model = script.Parent.Parent
local Torso: BasePart = Character:WaitForChild("Torso")
local Humanoid: Humanoid = Character:FindFirstChildOfClass("Humanoid")

--> Necessary for Ragdolling to function properly
Character.Humanoid.BreakJointsOnDeath = false
Character.Humanoid.RequiresNeck = false

--> Specific CFrame's I made for the best looking Ragdoll
local attachmentCFrames = {
	["Neck"] = { CFrame.new(0, 1, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1), CFrame.new(0, -0.5, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1) },
	["Left Shoulder"] = {
		CFrame.new(-1.3, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1),
		CFrame.new(0.2, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1),
	},
	["Right Shoulder"] = {
		CFrame.new(1.3, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		CFrame.new(-0.2, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	},
	["Left Hip"] = {
		CFrame.new(-0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
		CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
	},
	["Right Hip"] = {
		CFrame.new(0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
		CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
	},
}

local ragdollInstanceNames = {
	["RagdollAttachment"] = true,
	["RagdollConstraint"] = true,
	["ColliderPart"] = true,
}

--> Used to trigger Ragdoll
local RagdollValue = Instance.new("BoolValue")
RagdollValue.Name = "IsRagdoll"
RagdollValue.Parent = Character

--> Used for anticheats to prevent flying Ragdolls from getting flagged, might be useful for you.
Character:SetAttribute("LastRag")
-------------------------------------------------------------------------------------------------

--> Allows for proper limb collisions
local function createColliderPart(part: BasePart)
	if not part then
		return
	end
	local rp = Instance.new("Part")
	rp.Name = "ColliderPart"
	rp.Size = part.Size / 1.7
	rp.Massless = true
	rp.CFrame = part.CFrame
	rp.Transparency = 1

	local wc = Instance.new("WeldConstraint")
	wc.Part0 = rp
	wc.Part1 = part

	wc.Parent = rp
	rp.Parent = part
end

--> Converts Motor6D's into BallSocketConstraints
function replaceJoints()
	for _, motor: Motor6D in pairs(Character:GetDescendants()) do
		if motor:IsA("Motor6D") then
			if not attachmentCFrames[motor.Name] then
				return
			end
			motor.Enabled = false
			local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
			a0.CFrame = attachmentCFrames[motor.Name][1]
			a1.CFrame = attachmentCFrames[motor.Name][2]

			a0.Name = "RagdollAttachment"
			a1.Name = "RagdollAttachment"

			createColliderPart(motor.Part1)

			local b = Instance.new("BallSocketConstraint")
			b.Attachment0 = a0
			b.Attachment1 = a1
			b.Name = "RagdollConstraint"

			b.Radius = 0.15
			b.LimitsEnabled = true
			b.TwistLimitsEnabled = false
			b.MaxFrictionTorque = 20
			b.Restitution = 0
			b.UpperAngle = 90
			b.TwistLowerAngle = -45
			b.TwistUpperAngle = 45

			if motor.Name == "Neck" then
				b.TwistLimitsEnabled = true
				b.UpperAngle = 45
				b.TwistLowerAngle = -70
				b.TwistUpperAngle = 70
			end

			a0.Parent = motor.Part0
			a1.Parent = motor.Part1
			b.Parent = motor.Parent
		end
	end

	Humanoid.AutoRotate = false --> Disabling AutoRotate prevents the Character rotating in first person or Shift-Lock
	Character:SetAttribute("LastRag", tick())
end

--> Destroys all Ragdoll made instances and re-enables the Motor6D's
function resetJoints()
	if Humanoid.Health < 1 then
		return
	end
	for _, instance in pairs(Character:GetDescendants()) do
		if ragdollInstanceNames[instance.Name] then
			instance:Destroy()
		end

		if instance:IsA("Motor6D") then
			instance.Enabled = true
		end
	end

	Humanoid.AutoRotate = true
end

function Ragdoll(value: boolean)
	if value then
		replaceJoints()
	else
		resetJoints()
	end
end

-------------------------------------------------------------------------------------------------
--> Connect the Events
RagdollValue.Changed:Connect(Ragdoll)
Humanoid.Died:Once(function()
	RagdollValue.Value = true
end)
