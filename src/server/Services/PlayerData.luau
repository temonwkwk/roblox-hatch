--!strict
-- PlayerData: Simpan & muat data pemain via DataStore
-- Menyimpan koin, EXP, level, dan inventaris peralatan

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Network.Remotes)
local Settings = require(ReplicatedStorage.Shared.Config.Settings)

local PlayerData = {}

-- DataStore key prefix
local DS_KEY_PREFIX = "HATCH_v1_"
local store = DataStoreService:GetDataStore("HatchPlayerData")

-- Cache in-memory per sesi
local cache: { [number]: PlayerProfile } = {}

export type PlayerProfile = {
	UserId: number,
	Coins: number,
	EXP: number,
	Level: number,
	Inventory: { string }, -- Daftar Item ID yang dimiliki
	TotalRounds: number,
	SuccessRounds: number,
}

-- ── Default Profile ─────────────────────────────────────────
local function createDefault(userId: number): PlayerProfile
	return {
		UserId = userId,
		Coins = 300,  -- Modal awal
		EXP = 0,
		Level = 1,
		Inventory = { "Thermometer", "Stethoscope" }, -- 2 alat starter gratis
		TotalRounds = 0,
		SuccessRounds = 0,
	}
end

-- ── Load ────────────────────────────────────────────────────
function PlayerData.Load(player: Player)
	local key = DS_KEY_PREFIX .. player.UserId
	local success, data = pcall(function()
		return store:GetAsync(key)
	end)

	local profile: PlayerProfile
	if success and data then
		-- Merge dengan default untuk handle field baru
		profile = data :: PlayerProfile
		profile.UserId = player.UserId
	else
		if not success then
			warn(string.format("[PlayerData] Gagal load data %s: %s", player.Name, tostring(data)))
		end
		profile = createDefault(player.UserId)
	end

	cache[player.UserId] = profile
	print(string.format("[PlayerData] Data %s dimuat. Koin: %d | Level: %d", player.Name, profile.Coins, profile.Level))
end

-- ── Save ────────────────────────────────────────────────────
function PlayerData.Save(player: Player)
	local profile = cache[player.UserId]
	if not profile then return end

	local key = DS_KEY_PREFIX .. player.UserId
	local success, err = pcall(function()
		store:SetAsync(key, profile)
	end)

	if success then
		print(string.format("[PlayerData] Data %s tersimpan.", player.Name))
	else
		warn(string.format("[PlayerData] Gagal simpan data %s: %s", player.Name, tostring(err)))
	end
end

-- ── Getters ──────────────────────────────────────────────────
function PlayerData.Get(player: Player): PlayerProfile?
	return cache[player.UserId]
end

function PlayerData.HasItem(player: Player, itemId: string): boolean
	local profile = cache[player.UserId]
	if not profile then return false end
	for _, id in profile.Inventory do
		if id == itemId then return true end
	end
	return false
end

-- ── Reward Setelah Ronde ────────────────────────────────────
function PlayerData.GrantRoundReward(player: Player, isSuccess: boolean)
	local profile = cache[player.UserId]
	if not profile then return end

	profile.TotalRounds += 1

	if isSuccess then
		profile.SuccessRounds += 1
		profile.Coins += Settings.REWARD_CORRECT_SPECIES + Settings.REWARD_CORRECT_PROTOCOL
		profile.EXP += 250
	else
		profile.Coins = math.max(0, profile.Coins - Settings.PENALTY_FAILED_CONTAINMENT)
		profile.EXP += 50 -- Tetap dapat sedikit EXP dari pengalaman gagal
	end

	-- Level up setiap 1000 EXP
	local newLevel = math.floor(profile.EXP / 1000) + 1
	if newLevel > profile.Level then
		profile.Level = newLevel
		print(string.format("[PlayerData] %s naik ke Level %d!", player.Name, profile.Level))
	end

	print(string.format(
		"[PlayerData] Reward %s → Koin: %d | EXP: %d | Level: %d",
		player.Name, profile.Coins, profile.EXP, profile.Level
	))
end

-- ── Beli Item ───────────────────────────────────────────────
function PlayerData.PurchaseItem(player: Player, itemId: string, cost: number): boolean
	local profile = cache[player.UserId]
	if not profile then return false end
	if PlayerData.HasItem(player, itemId) then return false end -- Sudah punya
	if profile.Coins < cost then return false end -- Koin tidak cukup

	profile.Coins -= cost
	table.insert(profile.Inventory, itemId)
	print(string.format("[PlayerData] %s membeli %s seharga %d koin.", player.Name, itemId, cost))
	return true
end

-- ── Init: Auto load/save saat join/leave ────────────────────
function PlayerData.Init()
	Players.PlayerAdded:Connect(function(player)
		PlayerData.Load(player)

		-- Jawab request GetPlayerData dari client
		Remotes.Functions.GetPlayerData.OnServerInvoke = function(requestingPlayer: Player)
			return cache[requestingPlayer.UserId]
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		PlayerData.Save(player)
		cache[player.UserId] = nil
	end)

	-- Autosave setiap 5 menit
	task.spawn(function()
		while true do
			task.wait(300)
			for _, player in Players:GetPlayers() do
				PlayerData.Save(player)
			end
		end
	end)

	print("[PlayerData] Service diinisialisasi.")
end

return PlayerData
