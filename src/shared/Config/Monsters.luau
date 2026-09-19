--!strict
-- Database Konfigurasi Spesies Monster HATCH

export type EvidenceType =
	| "ExtremeHeat"
	| "SubZero"
	| "RapidHeartbeat"
	| "SlowHeartbeat"
	| "SulfurGas"
	| "ToxicAcidGas"
	| "FineSeismic"
	| "HeavySeismic"
	| "UVVeins"
	| "CrystalScrapeAudio"
	| "HissingAudio"
	| "ShockAggressive"
	| "ShockPassive"
	| "ShockAbsorb"

export type MonsterData = {
	Id: string,
	Name: string,
	Alias: string,
	Description: string,
	Evidences: { EvidenceType },
	BreachHazard: string,
	ContainmentProtocol: string,
	BaseAgitationRate: number,
}

local Monsters: { [string]: MonsterData } = {
	SpecimenIgnis = {
		Id = "SpecimenIgnis",
		Name = "Specimen Ignis",
		Alias = "Pyrobis (Molten Hatchling)",
		Description = "Bayi naga berkulit magma dengan panas radiasi ekstrem melebihi 80°C.",
		Evidences = { "ExtremeHeat", "RapidHeartbeat", "SulfurGas" },
		BreachHazard = "Ledakan termal langsung & kobaran api di containment chamber.",
		ContainmentProtocol = "CryogenicCoolant",
		BaseAgitationRate = 1.2,
	},

	CryoWeaver = {
		Id = "CryoWeaver",
		Name = "Cryo-Weaver",
		Alias = "Sub-Zero Crystalline Entity",
		Description = "Makhluk es kristal dengan getaran seismik halus dan urat bercahaya ultraviolet.",
		Evidences = { "SubZero", "FineSeismic", "UVVeins" },
		BreachHazard = "Lantai laboratorium membeku seketika, mengurangi mobilitas pemain.",
		ContainmentProtocol = "ThermalHeater",
		BaseAgitationRate = 0.9,
	},

	AbyssalEcho = {
		Id = "AbyssalEcho",
		Name = "Abyssal Echo",
		Alias = "Oceanic Resonance Predator",
		Description = "Entitas anomali laut dalam yang menghasilkan frekuensi gesekan kristal sonik.",
		Evidences = { "CrystalScrapeAudio", "ShockAggressive", "UVVeins" },
		BreachHazard = "Pulsa akustik frekuensi tinggi yang membutakan dan memekakkan telinga pemain.",
		ContainmentProtocol = "AcousticDampener",
		BaseAgitationRate = 1.5,
	},

	BioGargantua = {
		Id = "BioGargantua",
		Name = "Bio-Gargantua",
		Alias = "Colossal Armored Behemoth",
		Description = "Bayi titan berlapis baja kitin obsidian dengan hentakan langkah seismik berat.",
		Evidences = { "HeavySeismic", "SlowHeartbeat", "ShockPassive" },
		BreachHazard = "Menghancurkan pintu besi baja dan dinding kaca penahan fasilitas.",
		ContainmentProtocol = "MagneticLock",
		BaseAgitationRate = 0.7,
	},

	VaporParasite = {
		Id = "VaporParasite",
		Name = "Vapor Parasite",
		Alias = "Toxic Corrosive Swarm",
		Description = "Larva insektoid asing yang bernapas lewat pori-pori cangkang mengeluarkan kabut asam hijau.",
		Evidences = { "ToxicAcidGas", "HissingAudio", "UVVeins" },
		BreachHazard = "Saturasi gas asam beracun mematikan di seluruh ruangan lab.",
		ContainmentProtocol = "AirtightSeal",
		BaseAgitationRate = 1.0,
	},

	VoltaicHatchling = {
		Id = "VoltaicHatchling",
		Name = "Voltaic Hatchling",
		Alias = "Bio-Electric Capacitor",
		Description = "Bayi drake plasma yang menyerap arus listrik dan memicu medan elektromagnetik.",
		Evidences = { "ShockAbsorb", "ExtremeHeat", "HeavySeismic" },
		BreachHazard = "Ledakan EMP lokal memicu pemadaman listrik fasilitas dan malfungsi pintu.",
		ContainmentProtocol = "FaradayCage",
		BaseAgitationRate = 1.4,
	},
}

return table.freeze(Monsters)
