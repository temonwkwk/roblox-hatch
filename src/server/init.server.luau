--!strict
-- Server Entry Point: Inisialisasi semua Services

local ServerScriptService = game:GetService("ServerScriptService")

-- Panggil builder ruangan lab & kubus spesimen dummy
local ChamberBuilder = require(ServerScriptService.HatchServer.Services.ChamberBuilder)
ChamberBuilder.Build()

local RoundManager = require(ServerScriptService.HatchServer.Services.RoundManager)
local PlayerData   = require(ServerScriptService.HatchServer.Services.PlayerData)
local EggService   = require(ServerScriptService.HatchServer.Services.EggService)

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
