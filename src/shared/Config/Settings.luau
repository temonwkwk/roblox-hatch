--!strict
-- Konfigurasi Parameter Permainan

local Settings = {
	-- Pengaturan Durasi Ronde (Detik)
	LOBBY_INTERMISSION_TIME = 20,
	BRIEFING_TIME = 15,
	CHAMBER_ROUND_DURATION = 360, -- 6 Menit per ronde
	POST_ROUND_TIME = 15,

	-- Nilai Batas Stres Telur (Egg Agitation Meter)
	MAX_AGITATION = 100,
	RUNNING_NOISE_RATE = 1.5, -- Tambahan stres per detik saat pemain lari di chamber
	SHOCK_STIMULATION_PENALTY = 8.0, -- Tambahan stres saat sengatan kejut dipakai
	PROXIMITY_NOISE_DISTANCE = 12.0, -- Jarak deteksi suara lari (Studs)

	-- Fase Retakan Cangkang (Egg Shell Fracture Thresholds)
	PHASE_1_CRACK = 30, -- Retakan halus pertama
	PHASE_2_CRACK = 65, -- Retakan melebar & suara getaran makin keras
	PHASE_3_CRACK = 90, -- Gas/cairan anomali mulai bocor keluar

	-- Hadiah Koin & EXP
	REWARD_CORRECT_SPECIES = 200,
	REWARD_CORRECT_PROTOCOL = 150,
	PENALTY_FAILED_CONTAINMENT = 50,
}

return table.freeze(Settings)
