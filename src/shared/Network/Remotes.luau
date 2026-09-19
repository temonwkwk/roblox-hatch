--!strict
-- Deklarasi Jaringan Komunikasi Remote Event & Functions

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local function getOrCreateRemoteEvent(name: string): RemoteEvent
	local folder = ReplicatedStorage:FindFirstChild("HatchRemotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "HatchRemotes"
		folder.Parent = ReplicatedStorage
	end

	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	return remote :: RemoteEvent
end

local function getOrCreateRemoteFunction(name: string): RemoteFunction
	local folder = ReplicatedStorage:FindFirstChild("HatchRemotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "HatchRemotes"
		folder.Parent = ReplicatedStorage
	end

	local rf = folder:FindFirstChild(name)
	if not rf then
		rf = Instance.new("RemoteFunction")
		rf.Name = name
		rf.Parent = folder
	end
	return rf :: RemoteFunction
end

Remotes.Events = {
	-- Server -> Client
	GameStateChanged = getOrCreateRemoteEvent("GameStateChanged"),
	EggAgitationUpdated = getOrCreateRemoteEvent("EggAgitationUpdated"),
	EggCracked = getOrCreateRemoteEvent("EggCracked"),
	ChamberBreached = getOrCreateRemoteEvent("ChamberBreached"),
	
	-- Client -> Server
	UseToolAction = getOrCreateRemoteEvent("UseToolAction"),
	SubmitDeduction = getOrCreateRemoteEvent("SubmitDeduction"),
}

Remotes.Functions = {
	GetPlayerData = getOrCreateRemoteFunction("GetPlayerData"),
}

return Remotes
