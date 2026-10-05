--!strict
-- ToolController: Mengelola equip, penggunaan alat sensor, dan feedback animasi di sisi client

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Network.Remotes)
local Settings = require(ReplicatedStorage.Shared.Config.Settings)

local ToolController = {}

local player = Players.LocalPlayer
local equippedTool: string? = nil

-- Cooldown per alat (detik)
local toolCooldowns: { [string]: number } = {
	Thermometer     = 3,
	Stethoscope     = 4,
	Seismograph     = 5,
	UVLight         = 2,
	ShockTester     = 6,
	GasAnalyzer     = 5,
}

local lastUsed: { [string]: number } = {}

-- ── Feedback Visual/Audio (placeholder, ganti dengan aset nyata) ──
local function playToolFeedback(toolId: string, resultEvidence: string)
	-- Di game nyata: trigger animasi tangan, sound effect, dan particle
	print(string.format("[ToolController] %s digunakan → Bukti terdeteksi: %s", toolId, resultEvidence))

	-- Contoh: tampilkan notif singkat di layar
	local screenGui = player.PlayerGui:FindFirstChild("HatchHUD") :: ScreenGui?
	if not screenGui then return end

	local notif = screenGui:FindFirstChild("EvidenceNotif") :: TextLabel?
	if notif then
		notif.Text = "🔬 " .. resultEvidence
		notif.Visible = true
		task.delay(2.5, function()
			notif.Visible = false
		end)
	end
end

-- ── Gunakan Alat ke Server ────────────────────────────────────
function ToolController.UseTool(toolId: string)
	if not equippedTool or equippedTool ~= toolId then
		warn("[ToolController] Alat tidak ter-equip:", toolId)
		return
	end

	-- Cek cooldown
	local now = tick()
	local cd = toolCooldowns[toolId] or 3
	local last = lastUsed[toolId] or 0
	if now - last < cd then
		local remaining = math.ceil(cd - (now - last))
		print(string.format("[ToolController] %s masih cooldown %ds.", toolId, remaining))
		return
	end

	lastUsed[toolId] = now

	-- Kirim ke server
	Remotes.Events.UseToolAction:FireServer(toolId)
	print(string.format("[ToolController] Menggunakan alat: %s", toolId))
end

-- ── Equip / Unequip ───────────────────────────────────────────
function ToolController.Equip(toolId: string)
	equippedTool = toolId
	print(string.format("[ToolController] Equip: %s", toolId))
end

function ToolController.Unequip()
	equippedTool = nil
	print("[ToolController] Unequip semua alat.")
end

function ToolController.GetEquipped(): string?
	return equippedTool
end

-- ── Handle Event dari Server (hasil penggunaan alat) ──────────
local function onToolResult(toolId: string, evidence: string)
	playToolFeedback(toolId, evidence)
end

-- ── Shortcut keyboard 1–6 untuk equip alat ───────────────────
local toolSlots: { string } = {
	"Thermometer",
	"Stethoscope",
	"Seismograph",
	"UVLight",
	"ShockTester",
	"GasAnalyzer",
}

local keyMap: { [Enum.KeyCode]: number } = {
	[Enum.KeyCode.One]   = 1,
	[Enum.KeyCode.Two]   = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four]  = 4,
	[Enum.KeyCode.Five]  = 5,
	[Enum.KeyCode.Six]   = 6,
}

-- ── Init ──────────────────────────────────────────────────────
function ToolController.Init()
	-- Input shortcut keyboard
	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then return end

		-- Equip via angka 1-6
		local slot = keyMap[input.KeyCode]
		if slot and toolSlots[slot] then
			ToolController.Equip(toolSlots[slot])
			return
		end

		-- E = gunakan alat yang sedang di-equip
		if input.KeyCode == Enum.KeyCode.E then
			if equippedTool then
				ToolController.UseTool(equippedTool)
			end
		end
	end)

	-- Dengar balasan server soal hasil penggunaan alat
	Remotes.Events.UseToolAction.OnClientEvent:Connect(function(toolId: string, evidence: string)
		onToolResult(toolId, evidence)
		-- Otomatis masukkan bukti valid ke Journal tablet
		local JournalUI = require(script.Parent.JournalUI)
		JournalUI.AddEvidence(evidence)
	end)

	print("[ToolController] Diinisialisasi. Tekan 1-6 untuk equip, E untuk gunakan.")
end

return ToolController
