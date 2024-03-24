local ChatService = game:GetService("Chat")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage.Shared.Utils)
local Knit = require(ReplicatedStorage.Packages.Knit)

local DenDenService = Knit.CreateService({
	Name = "DenDenService",
	Client = {},
	Channel = "Interconnection",
	TalkPart = "Head",
	Connections = {},
	Calls = {},
	Cooldowns = {},
	COOLDOWN_TIME = 5,
})

local function connect(src: Instance, dst: Instance)
	local wire = Instance.new("Wire", dst)
	wire.SourceInstance = src
	wire.TargetInstance = dst
end

function DisconnectTable(tbl)
	for _, x in pairs(tbl) do
		if x ~= nil then
			x:Disconnect()
			x = nil
		end
	end
end

function DenDenService:GetParticularChannel(player1, player2)
	return self.Channel -- self.Channel .. player1.UserId .. "-" .. player2.UserId
end

function DenDenService:Talk(part, msg, color)
	msg = msg or "Hello World"
	color = color or "Red"

	local success, errorOrResult = pcall(function()
		ChatService:Chat(part, msg, color)
	end)

	if not success then
		warn("Erro ao enviar mensagem no chat:", errorOrResult)
	end
end

function DenDenService:SetChannel(DenDen: Tool, chanel)
	local AudioListener: AudioListener = DenDen:FindFirstChild("AudioListener", true)
	if AudioListener then
		AudioListener.AudioInteractionGroup = chanel
	end
end

function DenDenService:Conectar(player1: Player, player2: Player, denden1: Tool, denden2: Tool): nil
	local Audio1 = denden1:FindFirstChild("AudioEmitter", true)
	local Audio2 = denden2:FindFirstChild("AudioEmitter", true)
	local Listener1 = denden1:FindFirstChild("AudioListener", true)
	local Listener2 = denden2:FindFirstChild("AudioListener", true)

	if Audio1 and Audio2 and Listener1 and Listener2 then
		self.Calls[player1] = true
		self.Calls[player2] = true

		local privateChannel = self:GetParticularChannel(player1, player2)

		local objects = { Listener1, Listener2 }
		for _, obj in pairs(objects) do
			obj.AudioInteractionGroup = privateChannel
		end
		connect(Listener1, Audio2)
		connect(Listener2, Audio1)
		warn("All Connected")
	else
		warn("No AudioEmitter found in players or tools")
	end
end

function DenDenService:Desconectar(player)
	if self.Connections[player] then
		self.Connections[player]:Disconnect()
		self.Connections[player] = nil
	end
	if self.Calls[player] == true then
		self.Calls[player] = false
	end
	local playerMushi: Tool = Utils:FindItemInPlayerInventory(player.Name, "DenDen")
	if playerMushi then
		self:SetChannel(playerMushi, "")
	end
end

function DenDenService:AttemptConnection(player2, DenDen: Tool, player1)
	local sound = DenDen:FindFirstChild("Ring"):Clone()
	sound.Parent = player2.Character.HumanoidRootPart
	sound:Play()

	local MaxTries = 8
	local Tries = 0
	local Catch = false

	local playerMushi: Tool = Utils:FindItemInPlayerInventory(player2.Name, "DenDen")
	if playerMushi then
		if self.Calls[player2] == true then
			self:Talk(DenDen:FindFirstChild(self.TalkPart), "... [" .. player2.Name .. " Ja se encontra em ligacao]")
			self:Talk(playerMushi:FindFirstChild(self.TalkPart), "... [" .. player1.Name .. "Esta tentando conexao]")
			return
		end
		local localConnections = {}
		localConnections.connection = playerMushi.Equipped:Connect(function()
			Catch = true
		end)

		localConnections.connection2 = playerMushi.Unequipped:Connect(function()
			DisconnectTable(localConnections)

			self:Talk(DenDen:FindFirstChild(self.TalkPart), "[Sinal Perdido]")
			self:Talk(playerMushi:FindFirstChild(self.TalkPart), "[Sinal Perdido]")
			self:Desconectar(player1)
			self:Desconectar(player2)
		end)

		localConnections.connection3 = DenDen.Unequipped:Connect(function()
			DisconnectTable(localConnections)

			self:Talk(DenDen:FindFirstChild(self.TalkPart), "[Sinal Perdido]")
			self:Talk(playerMushi:FindFirstChild(self.TalkPart), "[Sinal Perdido]")
			self:Desconectar(player1)
			self:Desconectar(player2)
		end)

		if playerMushi.Parent:IsA("Model") then
			Catch = true
		end

		for _ = 1, MaxTries do
			Tries = Tries + 1
			warn(Tries)
			if Catch then
				break
			end
			task.wait(1)
		end
	else
		warn("No mushi found for: " .. player2.Name)
	end

	sound:Destroy()

	if Catch then
		sound:Destroy()
		DenDen.Ring:Stop()
		self:Talk(DenDen:FindFirstChild(self.TalkPart), "[Cacha]")
		self:Talk(playerMushi:FindFirstChild(self.TalkPart), "[Cacha]")
		self:Conectar(player1, player2, DenDen, playerMushi)
		self.Cooldowns[player] = true
	else
		self:Talk(DenDen:FindFirstChild(self.TalkPart), player2.Name .. " Não quis atender.")
		DenDen.Ring:Stop()
		local sound = player2.Character.HumanoidRootPart:FindFirstChild("Ring")
		if sound then
			sound:Destroy()
		end
	end
end

function DenDenService:OnActivated(DenDen)
	local Char = DenDen.Parent
	local player1 = Players:GetPlayerFromCharacter(Char)

	if not player1 then
		return
	end
	if self.Calls[player1] == true then
		self:Talk(DenDen:FindFirstChild(self.TalkPart), "... [Desligando a chamada atual.]")
		self:Desconectar(player1)
		return
	end

	self:Talk(DenDen:FindFirstChild(self.TalkPart), "... [Diga o nome do Player]")
	local waitingTime = tick()
	local function OnPlayerChatted(msg)
		if self.Connections[player1] then
			self.Connections[player1]:Disconnect()
			self.Connections[player1] = nil
		end
		local PlrName = Utils:GetPlayerByName(msg)
		local player2 = Players:FindFirstChild(PlrName)

		if not player2 then
			return
		end
		if (tick() - waitingTime) > 5 then
			self.Cooldowns[player] = true
			self:Talk(DenDen:FindFirstChild(self.TalkPart), "A sua resposta demorou demais")
			return
		end
		if PlrName ~= msg then
			self:Talk(DenDen:FindFirstChild(self.TalkPart), "... [Acho que você quis dizer: " .. player2.Name .. "]")
		elseif PlrName == player1.Name then
			self:Talk(DenDen:FindFirstChild(self.TalkPart), "... [Você está ligando pra você mesmo..?]")
			return
		end

		local playerMushi = Utils:FindItemInPlayerInventory(player2.Name, "DenDen")
		warn(playerMushi)
		if playerMushi then
			local sound = DenDen:FindFirstChild("Ring")
			sound:Play()
			self:AttemptConnection(player2, DenDen, player1)
		end
	end
	self.Connections[player1] = player1.Chatted:Connect(OnPlayerChatted)
end

function DenDenService:OnDeactivated(player1)
	if self.Connections[player1] then
		self.Connections[player1]:Disconnect()
		self.Connections = nil
	end
end

function DenDenService:Setup(DenDen: Tool)
	DenDen.Equipped:Connect(function()
		for _, x in pairs(DenDen:GetChildren()) do
			if x:IsA("BasePart") and x.Anchored then
				x.Anchored = false
				x.CanCollide = false
			end
		end
		self:Talk(DenDen:FindFirstChild(self.TalkPart), "ZzZzzzZ")
	end)

	DenDen.Activated:Connect(function()
		player = DenDen.Parent
		local inCd = self.Cooldowns[player] or false
		if player:IsA("Model") then
			player = Players:GetPlayerFromCharacter(player)
		end
		if not inCd then
			self:OnActivated(DenDen)
		else
			self:Talk(
				DenDen:FindFirstChild(self.TalkPart),
				"...[Espere alguns segundos para que eu possa recuperar o sinal]"
			)
		end
	end)

	DenDen.Unequipped:Connect(function()
		player = DenDen.Parent
		if player:IsA("Model") then
			player = Players:GetPlayerFromCharacter(player)
		end
		self:OnDeactivated(player)
		local inCd = self.Cooldowns[player] or false
		task.delay(self.COOLDOWN_TIME, function()
			if inCd then
				self.Cooldowns[player] = false
			end
		end)
	end)
end

function DenDenService:KnitStart()
	local dendenCollection = CollectionService:GetTagged("DenDen")
	if #dendenCollection > 0 then
		for _, dendenObject in pairs(dendenCollection) do
			self:Setup(dendenObject)
		end
	else
		warn("No Denden found")
	end
end
function DenDenService:KnitInit() end

local function onCharacterSpawned(from: Player, character: Model)
	local emitter = Instance.new("AudioEmitter", character)
	emitter.AudioInteractionGroup = "Interconnection"
	connect(from.AudioDeviceInput, emitter)
end

local function onPlayerAdded(player: Player)
	local input = Instance.new("AudioDeviceInput", player)
	input.Player = player

	if player.Character then
		onCharacterSpawned(player, player.Character)
	end
	player.CharacterAdded:Connect(function()
		onCharacterSpawned(player, player.Character)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
end

return DenDenService
