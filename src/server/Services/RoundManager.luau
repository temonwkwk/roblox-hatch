--!strict
-- Layanan Pengelola Siklus Ronde Permainan (RoundManager)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Settings = require(ReplicatedStorage.Shared.Config.Settings)
local Monsters = require(ReplicatedStorage.Shared.Config.Monsters)
local Remotes = require(ReplicatedStorage.Shared.Network.Remotes)

local RoundManager = {}
RoundManager.CurrentState = "Lobby"
RoundManager.ActiveMonster = nil
RoundManager.AgitationLevel = 0

export type GameState = "Lobby" | "Briefing" | "Investigation" | "Breached" | "Contained"

function RoundManager.SelectRandomMonster(): any
	local keys = {}
	for k in pairs(Monsters) do
		table.insert(keys, k)
	end
	local pickedKey = keys[math.random(1, #keys)]
	return Monsters[pickedKey]
end

function RoundManager.StartRound()
	RoundManager.ActiveMonster = RoundManager.SelectRandomMonster()
	RoundManager.AgitationLevel = 0
	RoundManager.CurrentState = "Briefing"
	
	print(string.format("[HATCH] Ronde dimulai! Target Spesimen (Server-only): %s", RoundManager.ActiveMonster.Name))
	Remotes.Events.GameStateChanged:FireAllClients("Briefing", Settings.BRIEFING_TIME)
	
	task.wait(Settings.BRIEFING_TIME)
	
	RoundManager.CurrentState = "Investigation"
	Remotes.Events.GameStateChanged:FireAllClients("Investigation", Settings.CHAMBER_ROUND_DURATION)
end

function RoundManager.TriggerBreach()
	RoundManager.CurrentState = "Breached"
	print(string.format("[HATCH] CONTAINMENT BREACH! %s telah menetas!", RoundManager.ActiveMonster.Name))
	Remotes.Events.ChamberBreached:FireAllClients(RoundManager.ActiveMonster.Id, RoundManager.ActiveMonster.BreachHazard)
end

function RoundManager.Init()
	print("[HATCH] RoundManager Service diinisialisasi.")
	
	Remotes.Events.SubmitDeduction.OnServerEvent:Connect(function(player: Player, guessedMonsterId: string, protocolId: string)
		if RoundManager.CurrentState ~= "Investigation" then return end
		
		local isMonsterCorrect = (guessedMonsterId == RoundManager.ActiveMonster.Id)
		local isProtocolCorrect = (protocolId == RoundManager.ActiveMonster.ContainmentProtocol)
		
		if isMonsterCorrect and isProtocolCorrect then
			RoundManager.CurrentState = "Contained"
			print(string.format("[HATCH] Sukses! %s berhasil menahan spesimen %s", player.Name, RoundManager.ActiveMonster.Name))
			Remotes.Events.GameStateChanged:FireAllClients("Contained", {
				Winner = player.Name,
				Monster = RoundManager.ActiveMonster.Name,
			})
		else
			print(string.format("[HATCH] Gagal! Tebakan %s salah. Memicu breach!", player.Name))
			RoundManager.TriggerBreach()
		end
	end)
end

return RoundManager
