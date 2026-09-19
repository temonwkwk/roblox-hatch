--!strict
-- Database Konfigurasi Peralatan & Sensor Peneliti

export type ItemData = {
	Id: string,
	Name: string,
	Category: "Sensor" | "Containment" | "Utility",
	Description: string,
	Cost: number,
	Tier: number,
}

local Items: { [string]: ItemData } = {
	Thermometer = {
		Id = "Thermometer",
		Name = "Thermal Scanner",
		Category = "Sensor",
		Description = "Mendeteksi suhu cangkang telur (Suhu Ekstrem >80°C atau Sub-Zero <-10°C).",
		Cost = 0,
		Tier = 1,
	},

	Stethoscope = {
		Id = "Stethoscope",
		Name = "Acoustic Biosensor",
		Category = "Sensor",
		Description = "Mendengarkan detak jantung (Cepat / Lambat) dan frekuensi audio (Gesekan Kristal / Desisan).",
		Cost = 0,
		Tier = 1,
	},

	Seismograph = {
		Id = "Seismograph",
		Name = "Seismic Meter",
		Category = "Sensor",
		Description = "Mengukur getaran internal telur (Getaran Halus / Hentakan Berat).",
		Cost = 150,
		Tier = 1,
	},

	UVLight = {
		Id = "UVLight",
		Name = "Ultraviolet Torch",
		Category = "Sensor",
		Description = "Menyinari cangkang untuk mendeteksi vena bioluminesens / spora jamur UV.",
		Cost = 100,
		Tier = 1,
	},

	ShockTester = {
		Id = "ShockTester",
		Name = "Low-Voltage Stimulator",
		Category = "Sensor",
		Description = "Memberikan sengatan kejut mikro untuk mengamati refleks saraf embrio (Agresif / Pasif / Serap Listrik).",
		Cost = 250,
		Tier = 2,
	},

	GasAnalyzer = {
		Id = "GasAnalyzer",
		Name = "Air Quality Spectrometer",
		Category = "Sensor",
		Description = "Menganalisis komposisi emisi gas (Sulfur / Asam Toksik).",
		Cost = 300,
		Tier = 2,
	},
}

return table.freeze(Items)
