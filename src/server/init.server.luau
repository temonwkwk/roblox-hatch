--!strict
-- Server Entry Point: Inisialisasi semua Services

local ServerScriptService = game:GetService("ServerScriptService")

local RoundManager = require(ServerScriptService.Server.Services.RoundManager)
local PlayerData   = require(ServerScriptService.Server.Services.PlayerData)
local EggService   = require(ServerScriptService.Server.Services.EggService)

-- Init semua service
PlayerData.Init()
RoundManager.Init(EggService)

print("[HATCH Server] Semua service aktif. Memulai lobby...")

-- Mulai loop ronde
task.spawn(function()
	while true do
		task.wait(20) -- Lobby intermission
		RoundManager.StartRound()
	end
end)
