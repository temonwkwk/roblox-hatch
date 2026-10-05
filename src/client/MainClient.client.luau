--!strict
-- Client Entry Point: Inisialisasi semua Controllers

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Tunggu map selesai dimuat
local StarterPlayerScripts = player:WaitForChild("PlayerScripts")
local HatchClient = StarterPlayerScripts:WaitForChild("HatchClient")

local ToolController = require(HatchClient.Controllers.ToolController)
local JournalUI      = require(HatchClient.Controllers.JournalUI)
local AmbienceFX     = require(HatchClient.Controllers.AmbienceFX)
local UIController   = require(HatchClient.Controllers.UIController)

-- Init semua controller
ToolController.Init()
JournalUI.Init()
AmbienceFX.Init()
UIController.Init(ToolController, JournalUI)

print("[HATCH Client] Semua controller aktif untuk", player.Name)
