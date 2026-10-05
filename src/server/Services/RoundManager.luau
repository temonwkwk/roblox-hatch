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
RoundManager.EggService = nil

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
	RoundManager.CurrentState = "Briefing"
	
	print(string.format("[HATCH] Ronde dimulai! Target Spesimen (Server-only): %s", RoundManager.ActiveMonster.Name))
	Remotes.Events.GameStateChanged:FireAllClients("Briefing", Settings.BRIEFING_TIME)
	
	task.wait(Settings.BRIEFING_TIME)
	
	RoundManager.CurrentState = "Investigation"
	Remotes.Events.GameStateChanged:FireAllClients("Investigation", Settings.CHAMBER_ROUND_DURATION)

	-- Aktifkan siklus hidup telur
	if RoundManager.EggService then
		RoundManager.EggService.StartEgg(function()
			RoundManager.TriggerBreach()
		end)
	end
end

function RoundManager.TriggerBreach()
	if RoundManager.CurrentState == "Breached" then return end
	RoundManager.CurrentState = "Breached"
	if RoundManager.EggService then
		RoundManager.EggService.StopEgg()
	end
	print(string.format("[HATCH] CONTAINMENT BREACH! %s telah menetas!", RoundManager.ActiveMonster.Name))
	Remotes.Events.ChamberBreached:FireAllClients(RoundManager.ActiveMonster.Id, RoundManager.ActiveMonster.BreachHazard)
end

function RoundManager.Init(EggService: any)
	RoundManager.EggService = EggService
	print("[HATCH] RoundManager Service diinisialisasi.")
	
	-- Menangani penggunaan alat sensor oleh pemain
	Remotes.Events.UseToolAction.OnServerEvent:Connect(function(player: Player, toolId: string)
		if RoundManager.CurrentState ~= "Investigation" or not RoundManager.ActiveMonster then return end

		-- Tambahkan stres pada telur jika menggunakan alat kejut listrik
		if toolId == "ShockTester" and RoundManager.EggService then
			RoundManager.EggService.AddAgitation(Settings.SHOCK_STIMULATION_PENALTY, "ShockTester:" .. player.Name)
		end

		-- Evaluasi hasil bukti berdasarkan monster yang aktif
		local matchedEvidence = nil
		local monsterEvidences = RoundManager.ActiveMonster.Evidences

		if toolId == "Thermometer" then
			if table.find(monsterEvidences, "ExtremeHeat") then
				matchedEvidence = "ExtremeHeat"
			elseif table.find(monsterEvidences, "SubZero") then
				matchedEvidence = "SubZero"
			else
				matchedEvidence = "NormalTemperature"
			end
		elseif toolId == "Stethoscope" then
			if table.find(monsterEvidences, "RapidHeartbeat") then
				matchedEvidence = "RapidHeartbeat"
			elseif table.find(monsterEvidences, "SlowHeartbeat") then
				matchedEvidence = "SlowHeartbeat"
			elseif table.find(monsterEvidences, "CrystalScrapeAudio") then
				matchedEvidence = "CrystalScrapeAudio"
			elseif table.find(monsterEvidences, "HissingAudio") then
				matchedEvidence = "HissingAudio"
			else
				matchedEvidence = "FaintHeartbeat"
			end
		elseif toolId == "Seismograph" then
			if table.find(monsterEvidences, "FineSeismic") then
				matchedEvidence = "FineSeismic"
			elseif table.find(monsterEvidences, "HeavySeismic") then
				matchedEvidence = "HeavySeismic"
			else
				matchedEvidence = "NoSeismicActivity"
			end
		elseif toolId == "UVLight" then
			if table.find(monsterEvidences, "UVVeins") then
				matchedEvidence = "UVVeins"
			else
				matchedEvidence = "NoUVReaction"
			end
		elseif toolId == "ShockTester" then
			if table.find(monsterEvidences, "ShockAggressive") then
				matchedEvidence = "ShockAggressive"
			elseif table.find(monsterEvidences, "ShockPassive") then
				matchedEvidence = "ShockPassive"
			elseif table.find(monsterEvidences, "ShockAbsorb") then
				matchedEvidence = "ShockAbsorb"
			else
				matchedEvidence = "StandardReflex"
			end
		elseif toolId == "GasAnalyzer" then
			if table.find(monsterEvidences, "SulfurGas") then
				matchedEvidence = "SulfurGas"
			elseif table.find(monsterEvidences, "ToxicAcidGas") then
				matchedEvidence = "ToxicAcidGas"
			else
				matchedEvidence = "CleanAir"
			end
		end

		print(string.format("[HATCH] %s menggunakan %s -> Bukti: %s", player.Name, toolId, tostring(matchedEvidence)))
		
		-- Kirim bukti kembali ke pemain yang memakai alat
		if matchedEvidence then
			Remotes.Events.UseToolAction:FireClient(player, toolId, matchedEvidence)
		end
	end)

	Remotes.Events.SubmitDeduction.OnServerEvent:Connect(function(player: Player, guessedMonsterId: string, protocolId: string)
		if RoundManager.CurrentState ~= "Investigation" then return end
		
		local isMonsterCorrect = (guessedMonsterId == RoundManager.ActiveMonster.Id)
		local isProtocolCorrect = (protocolId == RoundManager.ActiveMonster.ContainmentProtocol)
		
		if isMonsterCorrect and isProtocolCorrect then
			RoundManager.CurrentState = "Contained"
			if RoundManager.EggService then
				RoundManager.EggService.StopEgg()
			end
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
