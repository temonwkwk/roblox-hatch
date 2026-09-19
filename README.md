# roblox-hatch: Containment Breach

Game Co-op Social & Psychological Deduction Sci-Fi Horror untuk platform Roblox yang dikembangkan menggunakan arsitektur modern **Rojo** dan bahasa **Luau**.

Terinspirasi dari mekanisme deduksi bukti *Phasmophobia*, atmosfer ketegangan penahanan anomali *CRACK*, dan intensitas bahaya *Lethal Company*.

---

## 🎯 Konsep Permainan
Pemain bertindak sebagai tim ilmuwan penahanan fasilitas rahasia. Tugas tim:
1. Menyelidiki telur anomali berukuran besar menggunakan peralatan sensor ilmiah sebelum cangkang telur menetas.
2. Mengumpulkan **3 kombinasi bukti biologis** (Suhu, Detak Jantung, Getaran Seismik, Emisi Gas, atau Respon Kejut Listrik).
3. Mengidentifikasi spesies monster yang ada di dalam telur via **Tablet Deduksi**.
4. Menyiapkan **Protokol Penahanan Khusus** yang tepat untuk menyegel spesimen sebelum terjadi *Containment Breach*.

---

## 🧬 Daftar 6 Spesies Monster Utama
1. **Specimen Ignis (*Pyrobis*)**: Bayi naga magma berpijar (Suhu $>80^\circ\text{C}$ + Detak Jantung Ganda Cepat + Emisi Gas Sulfur).
2. **Cryo-Weaver**: Makhluk kristal es sub-zero (Suhu $<-10^\circ\text{C}$ + Getaran Seismik Halus + Vena UV Menyala).
3. **Abyssal Echo**: Entitas anomali laut dalam (Suhu Netral + Gesekan Kristal Sonik + Refleks Kejut Agresif).
4. **Bio-Gargantua**: Bayi titan lapis baja kitin obsidian (Hentakan Seismik Berat + Detak Lambat Berat + Refleks Pasif).
5. **Vapor Parasite**: Larva insektoid uap asam (Emisi Gas Toksik Hijau + Desisan Pori Telur + Vena UV Menyala).
6. **Voltaic Hatchling**: Bayi drake plasma listrik (Serap Arus Listrik + Suhu Panas + Hentakan Seismik Berat).

---

## 🛠️ Struktur Proyek (Rojo)
```text
roblox-hatch/
├── default.project.json      # Konfigurasi sync Rojo ke Roblox Studio DataModel
├── README.md                 # Dokumentasi & petunjuk setup
├── src/
│   ├── shared/               # Modul Client & Server (ReplicatedStorage)
│   │   ├── Config/
│   │   │   ├── Monsters.luau # Database 6 spesies, 3-evidence, dan bahaya breach
│   │   │   ├── Items.luau    # Konfigurasi peralatan scanner & sensor
│   │   │   └── Settings.luau # Durasi ronde, parameter stres telur & hadiah
│   │   └── Network/
│   │       └── Remotes.luau  # Deklarasi RemoteEvent & RemoteFunction
│   ├── server/               # Script Server (ServerScriptService)
│   │   └── Services/
│   │       └── RoundManager.luau # State Machine siklus ronde & verifikasi deduksi
│   └── client/               # Script Client (StarterPlayerScripts)
│       └── Controllers/
│           └── (ToolController, JournalUI, AmbienceFX)
```

---

## 🚀 Panduan Menjalankan dengan Rojo ke Roblox Studio

### 1. Prasyarat
- Pasang [Rojo CLI](https://rojo.space/) atau ekstensi Visual Studio Code Rojo.
- Buka baseplate kosong di **Roblox Studio** pada PC Anda.
- Pasang plugin **Rojo** di Roblox Studio.

### 2. Sinkronisasi Kode ke Roblox Studio
Jalankan perintah berikut di terminal:
```bash
rojo serve
```
Buka Roblox Studio $\rightarrow$ klik tab **Plugins** $\rightarrow$ klik tombol **Connect** pada plugin Rojo. Seluruh struktur script akan otomatis tersinkronisasi ke dalam game secara *real-time*.
