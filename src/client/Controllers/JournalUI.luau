--!strict
-- JournalUI: Tablet deduksi untuk mencoret bukti & mengunci tebakan spesies + protokol

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Network.Remotes)
local Monsters = require(ReplicatedStorage.Shared.Config.Monsters)

local JournalUI = {}

local player = Players.LocalPlayer

-- State deduksi lokal pemain ini
local confirmedEvidences: { [string]: boolean } = {}  -- Evidence ID → sudah dikonfirmasi?
local eliminatedMonsters: { [string]: boolean } = {}   -- Monster ID → sudah dicoret?
local selectedMonster: string? = nil
local selectedProtocol: string? = nil

-- ── Helpers ───────────────────────────────────────────────────

-- Hitung monster yang masih bisa jadi kandidat berdasarkan bukti yang terkonfirmasi
local function getValidCandidates(): { string }
	local candidates: { string } = {}
	for mId, mData in Monsters do
		if eliminatedMonsters[mId] then continue end

		-- Cek apakah semua confirmed evidence cocok dengan monster ini
		local match = true
		for evidenceId in confirmedEvidences do
			local found = false
			for _, ev in mData.Evidences do
				if ev == evidenceId then
					found = true
					break
				end
			end
			if not found then
				match = false
				break
			end
		end

		if match then
			table.insert(candidates, mId)
		end
	end
	return candidates
end

local function refreshUI()
	local gui = player.PlayerGui:FindFirstChild("HatchHUD") :: ScreenGui?
	if not gui then return end

	-- Update kandidat yang tersisa di UI
	local candidates = getValidCandidates()
	print(string.format("[JournalUI] Kandidat tersisa: %d spesies", #candidates))
	for _, c in candidates do
		print("  →", Monsters[c].Name)
	end
end

-- ── Public API ────────────────────────────────────────────────

-- Catat bukti yang berhasil dideteksi alat sensor
function JournalUI.AddEvidence(evidenceId: string)
	if confirmedEvidences[evidenceId] then return end -- Sudah ada
	confirmedEvidences[evidenceId] = true
	print(string.format("[JournalUI] Bukti terkonfirmasi: %s", evidenceId))
	refreshUI()
end

-- Coret monster secara manual (tombol X di jurnal)
function JournalUI.EliminateMonster(monsterId: string)
	eliminatedMonsters[monsterId] = true
	if selectedMonster == monsterId then
		selectedMonster = nil
	end
	print(string.format("[JournalUI] Spesies dicoret: %s", monsterId))
	refreshUI()
end

-- Pilih spesies & protokol untuk dikunci
function JournalUI.SelectGuess(monsterId: string, protocolId: string)
	selectedMonster = monsterId
	selectedProtocol = protocolId
	print(string.format("[JournalUI] Tebakan dikunci: %s | Protokol: %s", monsterId, protocolId))
end

-- Kirim tebakan final ke server
function JournalUI.SubmitDeduction()
	if not selectedMonster or not selectedProtocol then
		warn("[JournalUI] Pilih spesies dan protokol terlebih dahulu!")
		return
	end
	Remotes.Events.SubmitDeduction:FireServer(selectedMonster, selectedProtocol)
	print(string.format("[JournalUI] Deduksi dikirim → %s / %s", selectedMonster, selectedProtocol))
end

-- Reset state saat ronde baru
function JournalUI.Reset()
	confirmedEvidences = {}
	eliminatedMonsters = {}
	selectedMonster = nil
	selectedProtocol = nil
	print("[JournalUI] Jurnal direset untuk ronde baru.")
	refreshUI()
end

-- Getter untuk UI binding
function JournalUI.GetConfirmedEvidences(): { [string]: boolean }
	return confirmedEvidences
end

function JournalUI.GetCandidates(): { string }
	return getValidCandidates()
end

-- ── Init ──────────────────────────────────────────────────────
function JournalUI.Init()
	-- Reset jurnal setiap ronde baru dimulai
	Remotes.Events.GameStateChanged.OnClientEvent:Connect(function(newState: string)
		if newState == "Briefing" then
			JournalUI.Reset()
		end
	end)

	print("[JournalUI] Diinisialisasi. Siap mencatat bukti.")
end

return JournalUI
