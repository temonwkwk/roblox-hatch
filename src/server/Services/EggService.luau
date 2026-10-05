--!strict
-- EggService: Mengelola siklus hidup telur anomali
-- Agitation meter, fase retakan cangkang, dan logika penetasan

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Settings = require(ReplicatedStorage.Shared.Config.Settings)
local Remotes = require(ReplicatedStorage.Shared.Network.Remotes)

local EggService = {}

-- State internal
local agitation: number = 0
local crackPhase: number = 0 -- 0 = utuh, 1 = retak halus, 2 = retak lebar, 3 = bocor
local isActive: boolean = false
local onBreachCallback: (() -> ())? = nil

-- ── Helpers ────────────────────────────────────────────────
local function broadcastAgitation()
	Remotes.Events.EggAgitationUpdated:FireAllClients(agitation, crackPhase)
end

local function checkCrackPhase()
	local prevPhase = crackPhase
	if agitation >= Settings.PHASE_3_CRACK then
		crackPhase = 3
	elseif agitation >= Settings.PHASE_2_CRACK then
		crackPhase = 2
	elseif agitation >= Settings.PHASE_1_CRACK then
		crackPhase = 1
	end

	if crackPhase ~= prevPhase then
		Remotes.Events.EggCracked:FireAllClients(crackPhase)
		print(string.format("[EggService] Fase retakan berubah ke: %d (Agitasi: %.1f)", crackPhase, agitation))
	end
end

-- ── Public API ─────────────────────────────────────────────

-- Mulai siklus telur baru
function EggService.StartEgg(onBreach: () -> ())
	agitation = 0
	crackPhase = 0
	isActive = true
	onBreachCallback = onBreach
	broadcastAgitation()
	print("[EggService] Telur anomali aktif. Memulai siklus agitasi.")
end

-- Hentikan siklus (setelah contained atau breach)
function EggService.StopEgg()
	isActive = false
	onBreachCallback = nil
	print("[EggService] Siklus telur dihentikan.")
end

-- Tambah agitasi dari aksi tertentu
function EggService.AddAgitation(amount: number, source: string)
	if not isActive then return end
	agitation = math.min(agitation + amount, Settings.MAX_AGITATION)
	print(string.format("[EggService] Agitasi +%.1f dari '%s' → Total: %.1f", amount, source, agitation))
	checkCrackPhase()
	broadcastAgitation()

	-- Cek jika agitasi penuh → forced early hatching
	if agitation >= Settings.MAX_AGITATION then
		isActive = false
		print("[EggService] AGITASI PENUH! Forced Early Hatching dipicu!")
		if onBreachCallback then
			onBreachCallback()
		end
	end
end

-- Getter state saat ini
function EggService.GetAgitation(): number
	return agitation
end

function EggService.GetCrackPhase(): number
	return crackPhase
end

-- ── Tick: Noise dari gerakan pemain di dekat telur ──────────
-- Dipanggil oleh RoundManager setiap detik selama Investigation
function EggService.TickNoise(eggPosition: Vector3)
	if not isActive then return end

	for _, player in Players:GetPlayers() do
		local character = player.Character
		if not character then continue end
		local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not root then continue end

		local dist = (root.Position - eggPosition).Magnitude
		if dist > Settings.PROXIMITY_NOISE_DISTANCE then continue end

		local humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid?
		if not humanoid then continue end

		-- Deteksi lari (kecepatan melebihi WalkSpeed normal 16)
		if humanoid.MoveDirection.Magnitude > 0 and humanoid.WalkSpeed > 16 then
			EggService.AddAgitation(Settings.RUNNING_NOISE_RATE, "PlayerRunning:" .. player.Name)
		end
	end
end

return EggService
