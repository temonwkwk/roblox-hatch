--!strict
-- Layanan Pembuat HUD Antarmuka Pemain (UIController)
-- Menampilkan status ronde, bilah stres telur (Agitation Meter), hotbar sensor, dan tablet jurnal deduksi

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Network.Remotes)
local Monsters = require(ReplicatedStorage.Shared.Config.Monsters)
local Items = require(ReplicatedStorage.Shared.Config.Items)

local UIController = {}

local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

local isJournalOpen = false

function UIController.Init(toolController: any, journalUI: any)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HatchHUD"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = pGui

	-- 1. Banner Status Ronde (Atas Tengah)
	local topBanner = Instance.new("Frame")
	topBanner.Name = "TopBanner"
	topBanner.Size = UDim2.new(0, 360, 0, 50)
	topBanner.Position = UDim2.new(0.5, -180, 0, 20)
	topBanner.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
	topBanner.BackgroundTransparency = 0.2
	topBanner.BorderSizePixel = 0
	topBanner.Parent = screenGui

	local cornerTop = Instance.new("UICorner")
	cornerTop.CornerRadius = UDim.new(0, 10)
	cornerTop.Parent = topBanner

	local strokeTop = Instance.new("UIStroke")
	strokeTop.Color = Color3.fromRGB(167, 227, 248)
	strokeTop.Thickness = 1.5
	strokeTop.Parent = topBanner

	local stateLabel = Instance.new("TextLabel")
	stateLabel.Name = "StateLabel"
	stateLabel.Size = UDim2.new(1, -20, 0, 22)
	stateLabel.Position = UDim2.new(0, 10, 0, 4)
	stateLabel.BackgroundTransparency = 1
	stateLabel.Font = Enum.Font.GothamBold
	stateLabel.TextSize = 14
	stateLabel.TextColor3 = Color3.fromRGB(167, 227, 248)
	stateLabel.Text = "FASE: LOBBY"
	stateLabel.Parent = topBanner

	local timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "TimerLabel"
	timerLabel.Size = UDim2.new(1, -20, 0, 18)
	timerLabel.Position = UDim2.new(0, 10, 0, 26)
	timerLabel.BackgroundTransparency = 1
	timerLabel.Font = Enum.Font.Gotham
	timerLabel.TextSize = 12
	timerLabel.TextColor3 = Color3.fromRGB(223, 230, 233)
	timerLabel.Text = "Menunggu ronde baru..."
	timerLabel.Parent = topBanner

	-- 2. Bilah Stres Telur / Agitation Meter (Atas Kanan)
	local agitationFrame = Instance.new("Frame")
	agitationFrame.Name = "AgitationFrame"
	agitationFrame.Size = UDim2.new(0, 220, 0, 45)
	agitationFrame.Position = UDim2.new(1, -240, 0, 20)
	agitationFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
	agitationFrame.BackgroundTransparency = 0.2
	agitationFrame.BorderSizePixel = 0
	agitationFrame.Parent = screenGui

	local cornerAgit = Instance.new("UICorner")
	cornerAgit.CornerRadius = UDim.new(0, 10)
	cornerAgit.Parent = agitationFrame

	local agitTitle = Instance.new("TextLabel")
	agitTitle.Size = UDim2.new(1, -16, 0, 16)
	agitTitle.Position = UDim2.new(0, 8, 0, 4)
	agitTitle.BackgroundTransparency = 1
	agitTitle.Font = Enum.Font.GothamBold
	agitTitle.TextSize = 11
	agitTitle.TextColor3 = Color3.fromRGB(255, 196, 225)
	agitTitle.Text = "EGG AGITATION (STRES)"
	agitTitle.Parent = agitationFrame

	local agitBarBg = Instance.new("Frame")
	agitBarBg.Size = UDim2.new(1, -16, 0, 12)
	agitBarBg.Position = UDim2.new(0, 8, 0, 24)
	agitBarBg.BackgroundColor3 = Color3.fromRGB(40, 44, 52)
	agitBarBg.BorderSizePixel = 0
	agitBarBg.Parent = agitationFrame

	local cornerBarBg = Instance.new("UICorner")
	cornerBarBg.CornerRadius = UDim.new(0, 6)
	cornerBarBg.Parent = agitBarBg

	local agitBarFill = Instance.new("Frame")
	agitBarFill.Name = "BarFill"
	agitBarFill.Size = UDim2.new(0, 0, 1, 0)
	agitBarFill.BackgroundColor3 = Color3.fromRGB(191, 243, 193)
	agitBarFill.BorderSizePixel = 0
	agitBarFill.Parent = agitBarBg

	local cornerBarFill = Instance.new("UICorner")
	cornerBarFill.CornerRadius = UDim.new(0, 6)
	cornerBarFill.Parent = agitBarFill

	-- 3. Notifikasi Temuan Bukti Sensor (Tengah Layar)
	local notifLabel = Instance.new("TextLabel")
	notifLabel.Name = "EvidenceNotif"
	notifLabel.Size = UDim2.new(0, 400, 0, 44)
	notifLabel.Position = UDim2.new(0.5, -200, 0.7, 0)
	notifLabel.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
	notifLabel.BackgroundTransparency = 0.15
	notifLabel.Font = Enum.Font.GothamBold
	notifLabel.TextSize = 15
	notifLabel.TextColor3 = Color3.fromRGB(191, 243, 193)
	notifLabel.Text = "🔬 Bukti Terdeteksi"
	notifLabel.Visible = false
	notifLabel.BorderSizePixel = 0
	notifLabel.Parent = screenGui

	local cornerNotif = Instance.new("UICorner")
	cornerNotif.CornerRadius = UDim.new(0, 8)
	cornerNotif.Parent = notifLabel

	local strokeNotif = Instance.new("UIStroke")
	strokeNotif.Color = Color3.fromRGB(191, 243, 193)
	strokeNotif.Thickness = 1.5
	strokeNotif.Parent = notifLabel

	-- 4. Hotbar Peralatan (Bawah Tengah)
	local hotbar = Instance.new("Frame")
	hotbar.Name = "ToolHotbar"
	hotbar.Size = UDim2.new(0, 480, 0, 56)
	hotbar.Position = UDim2.new(0.5, -240, 1, -75)
	hotbar.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
	hotbar.BackgroundTransparency = 0.2
	hotbar.BorderSizePixel = 0
	hotbar.Parent = screenGui

	local cornerHotbar = Instance.new("UICorner")
	cornerHotbar.CornerRadius = UDim.new(0, 12)
	cornerHotbar.Parent = hotbar

	local toolNames = {
		{ Id = "Thermometer", Key = "1", Label = "Thermal" },
		{ Id = "Stethoscope", Key = "2", Label = "Audio" },
		{ Id = "Seismograph", Key = "3", Label = "Seismik" },
		{ Id = "UVLight",     Key = "4", Label = "UV Light" },
		{ Id = "ShockTester", Key = "5", Label = "Kejut" },
		{ Id = "GasAnalyzer", Key = "6", Label = "Gas" },
	}

	local slotButtons: { [string]: TextButton } = {}

	for i, t in toolNames do
		local btn = Instance.new("TextButton")
		btn.Name = "Slot_" .. t.Id
		btn.Size = UDim2.new(0, 72, 0, 44)
		btn.Position = UDim2.new(0, 8 + (i - 1) * 78, 0, 6)
		btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
		btn.BorderSizePixel = 0
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 11
		btn.TextColor3 = Color3.fromRGB(223, 230, 233)
		btn.Text = string.format("[%s]\n%s", t.Key, t.Label)
		btn.Parent = hotbar

		local cornerBtn = Instance.new("UICorner")
		cornerBtn.CornerRadius = UDim.new(0, 8)
		cornerBtn.Parent = btn

		local strokeBtn = Instance.new("UIStroke")
		strokeBtn.Color = Color3.fromRGB(60, 68, 80)
		strokeBtn.Thickness = 1
		strokeBtn.Parent = btn

		btn.MouseButton1Click:Connect(function()
			toolController.Equip(t.Id)
			for _, b in slotButtons do
				b.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
			end
			btn.BackgroundColor3 = Color3.fromRGB(26, 127, 170)
		end)

		slotButtons[t.Id] = btn
	end

	-- 5. Tombol Petunjuk & Tombol Buka Jurnal
	local hintLabel = Instance.new("TextLabel")
	hintLabel.Size = UDim2.new(0, 480, 0, 16)
	hintLabel.Position = UDim2.new(0.5, -240, 1, -95)
	hintLabel.BackgroundTransparency = 1
	hintLabel.Font = Enum.Font.Gotham
	hintLabel.TextSize = 11
	hintLabel.TextColor3 = Color3.fromRGB(167, 227, 248)
	hintLabel.Text = "Tekan [E] untuk gunakan alat · Tekan [J] untuk buka Jurnal Deduksi"
	hintLabel.Parent = screenGui

	-- Tombol buka jurnal interaktif (bisa diklik mouse selain tekan J)
	local openJournalBtn = Instance.new("TextButton")
	openJournalBtn.Name = "OpenJournalBtn"
	openJournalBtn.Size = UDim2.new(0, 150, 0, 36)
	openJournalBtn.Position = UDim2.new(0, 20, 1, -65)
	openJournalBtn.BackgroundColor3 = Color3.fromRGB(26, 127, 170)
	openJournalBtn.Font = Enum.Font.GothamBold
	openJournalBtn.TextSize = 12
	openJournalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	openJournalBtn.Text = "📋 JURNAL [J]"
	openJournalBtn.Parent = screenGui

	local cornerOpenJ = Instance.new("UICorner")
	cornerOpenJ.CornerRadius = UDim.new(0, 8)
	cornerOpenJ.Parent = openJournalBtn

	-- 6. Jurnal Deduksi / Tablet (Modal Dialog)
	local journalModal = Instance.new("Frame")
	journalModal.Name = "JournalModal"
	journalModal.Size = UDim2.new(0, 500, 0, 360)
	journalModal.Position = UDim2.new(0.5, -250, 0.5, -180)
	journalModal.BackgroundColor3 = Color3.fromRGB(16, 20, 26)
	journalModal.BorderSizePixel = 0
	journalModal.Visible = false
	journalModal.Parent = screenGui

	local cornerJ = Instance.new("UICorner")
	cornerJ.CornerRadius = UDim.new(0, 14)
	cornerJ.Parent = journalModal

	local strokeJ = Instance.new("UIStroke")
	strokeJ.Color = Color3.fromRGB(167, 227, 248)
	strokeJ.Thickness = 2
	strokeJ.Parent = journalModal

	local jTitle = Instance.new("TextLabel")
	jTitle.Size = UDim2.new(1, -30, 0, 32)
	jTitle.Position = UDim2.new(0, 15, 0, 10)
	jTitle.BackgroundTransparency = 1
	jTitle.Font = Enum.Font.GothamBold
	jTitle.TextSize = 16
	jTitle.TextColor3 = Color3.fromRGB(167, 227, 248)
	jTitle.Text = "📋 TABLET DEDUKSI SPESIMEN"
	jTitle.TextXAlignment = Enum.TextXAlignment.Left
	jTitle.Parent = journalModal

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 28, 0, 28)
	closeBtn.Position = UDim2.new(1, -38, 0, 10)
	closeBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextSize = 13
	closeBtn.Parent = journalModal

	local cornerClose = Instance.new("UICorner")
	cornerClose.CornerRadius = UDim.new(0, 6)
	cornerClose.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		journalModal.Visible = false
		isJournalOpen = false
	end)

	local candidateListLabel = Instance.new("TextLabel")
	candidateListLabel.Name = "CandidatesLabel"
	candidateListLabel.Size = UDim2.new(1, -30, 0, 160)
	candidateListLabel.Position = UDim2.new(0, 15, 0, 50)
	candidateListLabel.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
	candidateListLabel.BorderSizePixel = 0
	candidateListLabel.Font = Enum.Font.Gotham
	candidateListLabel.TextSize = 12
	candidateListLabel.TextColor3 = Color3.fromRGB(223, 230, 233)
	candidateListLabel.TextXAlignment = Enum.TextXAlignment.Left
	candidateListLabel.TextYAlignment = Enum.TextYAlignment.Top
	candidateListLabel.Parent = journalModal

	local cornerCand = Instance.new("UICorner")
	cornerCand.CornerRadius = UDim.new(0, 8)
	cornerCand.Parent = candidateListLabel

	local submitBtn = Instance.new("TextButton")
	submitBtn.Name = "SubmitGuessBtn"
	submitBtn.Size = UDim2.new(1, -30, 0, 42)
	submitBtn.Position = UDim2.new(0, 15, 1, -55)
	submitBtn.BackgroundColor3 = Color3.fromRGB(26, 127, 170)
	submitBtn.Font = Enum.Font.GothamBold
	submitBtn.TextSize = 13
	submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	submitBtn.Text = "KUNCI TEBAKAN PROTOKOL"
	submitBtn.Parent = journalModal

	local cornerSubmit = Instance.new("UICorner")
	cornerSubmit.CornerRadius = UDim.new(0, 8)
	cornerSubmit.Parent = submitBtn

	local function refreshJournalContent()
		local confirmed = journalUI.GetConfirmedEvidences()
		local candidates = journalUI.GetCandidates()
		
		local textLines = { "BUKTI TERKONFIRMASI:" }
		local countEv = 0
		for ev in confirmed do
			countEv += 1
			table.insert(textLines, " • " .. ev)
		end
		if countEv == 0 then
			table.insert(textLines, " (Belum ada bukti yang ditemukan)")
		end

		table.insert(textLines, "\nKANDIDAT SPESIES YANG COCOK (" .. #candidates .. "/6):")
		for _, c in candidates do
			local m = Monsters[c]
			table.insert(textLines, string.format(" 🔬 %s (%s) - Protokol: %s", m.Name, m.Alias, m.ContainmentProtocol))
		end

		candidateListLabel.Text = "  " .. table.concat(textLines, "\n  ")

		if #candidates == 1 then
			local targetMonster = Monsters[candidates[1]]
			submitBtn.Text = string.format("KUNCI PROTOKOL [%s] UNTUK %s", targetMonster.ContainmentProtocol, targetMonster.Name)
			submitBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
		else
			submitBtn.Text = "KUMPULKAN LEBIH BANYAK BUKTI"
			submitBtn.BackgroundColor3 = Color3.fromRGB(70, 75, 85)
		end
	end

	submitBtn.MouseButton1Click:Connect(function()
		local candidates = journalUI.GetCandidates()
		if #candidates == 1 then
			local targetMonster = Monsters[candidates[1]]
			journalUI.SelectGuess(targetMonster.Id, targetMonster.ContainmentProtocol)
			journalUI.SubmitDeduction()
			journalModal.Visible = false
			isJournalOpen = false
		end
	end)

	-- Shortcut Toggle Jurnal dengan tombol J
	local function toggleJournal()
		isJournalOpen = not isJournalOpen
		journalModal.Visible = isJournalOpen
		if isJournalOpen then
			refreshJournalContent()
		end
	end

	openJournalBtn.MouseButton1Click:Connect(toggleJournal)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.J then
			toggleJournal()
		end
	end)

	-- ── Sinkronisasi Event Remote ───────────────────────────────
	Remotes.Events.GameStateChanged.OnClientEvent:Connect(function(state: string, duration: number?)
		stateLabel.Text = "FASE: " .. string.upper(state)
		if state == "Investigation" then
			stateLabel.TextColor3 = Color3.fromRGB(191, 243, 193)
			timerLabel.Text = "Investigasi dimulai! Gunakan sensor."
		elseif state == "Briefing" then
			stateLabel.TextColor3 = Color3.fromRGB(167, 227, 248)
			timerLabel.Text = "Briefing spesimen..."
		elseif state == "Contained" then
			stateLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
			timerLabel.Text = "🎉 SPESIMEN BERHASIL DIKUNCI!"
		elseif state == "Breached" then
			stateLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
			timerLabel.Text = "⚠️ CONTAINMENT BREACH! EVAKUASI!"
		end
	end)

	Remotes.Events.EggAgitationUpdated.OnClientEvent:Connect(function(agitation: number, crackPhase: number)
		local pct = math.clamp(agitation / 100, 0, 1)
		agitBarFill.Size = UDim2.new(pct, 0, 1, 0)
		if pct > 0.7 then
			agitBarFill.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
		elseif pct > 0.4 then
			agitBarFill.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
		else
			agitBarFill.BackgroundColor3 = Color3.fromRGB(191, 243, 193)
		end
	end)

	print("[UIController] HUD & Hotbar berhasil diinisialisasi.")
end

return UIController
