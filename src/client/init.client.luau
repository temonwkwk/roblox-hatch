--!strict
-- Client Entry Point: Inisialisasi semua Controllers

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Tunggu map selesai dimuat
local StarterPlayerScripts = player:WaitForChild("PlayerScripts")
local Client = StarterPlayerScripts:WaitForChild("Client")

local ToolController = require(Client.Controllers.ToolController)
local JournalUI      = require(Client.Controllers.JournalUI)
local AmbienceFX     = require(Client.Controllers.AmbienceFX)

-- Init semua controller
ToolController.Init()
JournalUI.Init()
AmbienceFX.Init()

print("[HATCH Client] Semua controller aktif untuk", player.Name)
