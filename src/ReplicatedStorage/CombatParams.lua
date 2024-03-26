local Settings = {}

Settings.params = {
    ["OnlyHumanoids"] = true,
		["ExecutorName"] = "",
		["Size"] = Vector3.one,
		["Position"] = Vector3.zero,
		["Damage"] = 0,
		["Range"] = 100,
		["HitType"] = "normalHit",
		["Effects"] = {
			["Burning"] = false,
			["Parryable"] = true,
			["Blockable"] = true,
			["StunTime"] = 0.5,
		},
}

Settings.Styles = {
	["BasicCombat"] = {
		["Damage"] = 5,
		["Range"] = 3, -- Eixo X da hitbox
		["AttackSpeed"] = 0.35 -- Tempo em segundos de cooldown entre cada hit
	}
}

function Settings:GetDefaultParams()
	return self.params
end

function Settings:GetStyles()
	return self.Styles
end

return Settings