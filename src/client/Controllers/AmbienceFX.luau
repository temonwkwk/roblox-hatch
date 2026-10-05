--!strict
-- AmbienceFX: Efek atmosfer client-side — suara ambient, partikel, cahaya, dan visual telur

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Remotes = require(ReplicatedStorage.Shared.Network.Remotes)

local AmbienceFX = {}

-- Referensi ke objek scene (akan diset oleh Init setelah map dimuat)
local eggModel: Model? = nil
local chamberLight: PointLight? = nil
local crackSounds: { [number]: Sound } = {}  -- Fase 1, 2, 3
local alarmSound: Sound? = nil
local ambientLoop: Sound? = nil

-- ── Helpers ───────────────────────────────────────────────────

local function flickerLight(light: PointLight, duration: number)
	local endTime = tick() + duration
	while tick() < endTime do
		light.Enabled = not light.Enabled
		task.wait(math.random(5, 20) / 100)
	end
	light.Enabled = true
end

local function pulsateEgg(eggPart: BasePart)
	-- Efek denyut kecil pada telur sesuai agitasi
	local tween = TweenService:Create(eggPart, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 2, true), {
		Size = eggPart.Size * 1.04,
	})
	tween:Play()
end

-- ── Crack Phase Visuals ────────────────────────────────────────

local crackOverlays: { [number]: string } = {
	[1] = "rbxassetid://0",  -- Ganti dengan ID decal retakan halus
	[2] = "rbxassetid://0",  -- Ganti dengan ID decal retakan lebar
	[3] = "rbxassetid://0",  -- Ganti dengan ID decal retakan bocor
}

local function applyCrackDecal(phase: number)
	if not eggModel then return end

	local egg = eggModel:FindFirstChild("EggShell") :: BasePart?
	if not egg then return end

	-- Hapus decal lama
	for _, d in egg:GetChildren() do
		if d:IsA("Decal") and d.Name == "CrackDecal" then
			d:Destroy()
		end
	end

	-- Pasang decal baru
	if phase > 0 and crackOverlays[phase] then
		local decal = Instance.new("Decal")
		decal.Name = "CrackDecal"
		decal.Texture = crackOverlays[phase]
		decal.Parent = egg
	end
end

-- ── Public API ─────────────────────────────────────────────────

function AmbienceFX.SetEggModel(model: Model)
	eggModel = model
end

-- Update visual saat agitasi berubah
function AmbienceFX.OnAgitationUpdated(agitation: number, crackPhase: number)
	if not eggModel then return end

	local egg = eggModel:FindFirstChild("EggShell") :: BasePart?
	if egg and agitation > 50 then
		pulsateEgg(egg)
	end

	-- Ubah warna cahaya sesuai level stres
	if chamberLight then
		local alpha = agitation / 100
		chamberLight.Color = Color3.new(1, 1 - alpha * 0.8, 1 - alpha * 0.8)
		chamberLight.Brightness = 1 + alpha * 2
	end
end

-- Efek per fase retakan cangkang
function AmbienceFX.OnEggCracked(phase: number)
	applyCrackDecal(phase)

	-- Mainkan suara retakan
	local snd = crackSounds[phase]
	if snd then snd:Play() end

	-- Fase 3: lampu mulai flicker
	if phase == 3 and chamberLight then
		task.spawn(function()
			flickerLight(chamberLight, 3)
		end)
	end

	print(string.format("[AmbienceFX] Cangkang retak fase %d!", phase))
end

-- Efek saat Containment Breach
function AmbienceFX.OnChamberBreached(monsterId: string)
	-- Matikan lampu
	if chamberLight then
		chamberLight.Enabled = false
	end

	-- Hentikan ambient loop
	if ambientLoop then
		ambientLoop:Stop()
	end

	-- Nyalakan alarm
	if alarmSound then
		alarmSound:Play()
	end

	-- Flash merah singkat di layar (UI overlay)
	local player = game:GetService("Players").LocalPlayer
	local gui = player.PlayerGui:FindFirstChild("HatchHUD") :: ScreenGui?
	if gui then
		local flash = gui:FindFirstChild("BreachFlash") :: Frame?
		if flash then
			flash.BackgroundTransparency = 0.3
			TweenService:Create(flash, TweenInfo.new(1.5), { BackgroundTransparency = 1 }):Play()
		end
	end

	print(string.format("[AmbienceFX] BREACH FX aktif! Monster: %s", monsterId))
end

-- Efek saat Containment berhasil
function AmbienceFX.OnContained()
	if chamberLight then
		chamberLight.Color = Color3.new(0.7, 1, 0.7) -- Lampu hijau
		chamberLight.Brightness = 2
	end
	if ambientLoop then
		ambientLoop:Stop()
	end
	print("[AmbienceFX] Containment berhasil! Efek hijau aktif.")
end

-- ── Init ───────────────────────────────────────────────────────
function AmbienceFX.Init()
	-- Dengarkan event server
	Remotes.Events.EggAgitationUpdated.OnClientEvent:Connect(function(agitation: number, crackPhase: number)
		AmbienceFX.OnAgitationUpdated(agitation, crackPhase)
	end)

	Remotes.Events.EggCracked.OnClientEvent:Connect(function(phase: number)
		AmbienceFX.OnEggCracked(phase)
	end)

	Remotes.Events.ChamberBreached.OnClientEvent:Connect(function(monsterId: string)
		AmbienceFX.OnChamberBreached(monsterId)
	end)

	Remotes.Events.GameStateChanged.OnClientEvent:Connect(function(newState: string)
		if newState == "Contained" then
			AmbienceFX.OnContained()
		elseif newState == "Briefing" then
			-- Reset cahaya ke normal
			if chamberLight then
				chamberLight.Color = Color3.new(1, 1, 1)
				chamberLight.Brightness = 1
				chamberLight.Enabled = true
			end
			-- Restart ambient loop
			if ambientLoop then
				ambientLoop:Play()
			end
		end
	end)

	print("[AmbienceFX] Diinisialisasi. Siap render efek atmosfer.")
end

return AmbienceFX
