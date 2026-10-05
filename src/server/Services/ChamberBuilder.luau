--!strict
-- Layanan Pembuat Ruang Penahanan Dummy (ChamberBuilder)
-- Otomatis men-generate kubus telur, dudukan, lampu laboratorium, dan dinding penahan

local Workspace = game:GetService("Workspace")

local ChamberBuilder = {}

local function createPart(name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.CanCollide = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

function ChamberBuilder.Build()
	-- Cegah duplikasi jika sudah pernah dibuat
	if Workspace:FindFirstChild("ContainmentChamber") then
		return
	end

	local chamberFolder = Instance.new("Folder")
	chamberFolder.Name = "ContainmentChamber"
	chamberFolder.Parent = Workspace

	-- Naikkan seluruh struktur 10 stud di atas permukaan tanah/Baseplate (Y = 10)
	-- agar tidak terjadi z-fighting / visual clash dengan lantai bawaan Roblox
	local origin = Vector3.new(0, 10, 0)

	-- 1. Ruangan Lab Skala Besar (80 x 80 stud) - Lantai Tebal 3 stud
	local roomSize = 80
	local roomHalf = roomSize / 2
	local wallHeight = 26
	
	local floor = createPart("ChamberFloor", Vector3.new(roomSize, 3, roomSize), origin + Vector3.new(0, 1.5, 0), Color3.fromRGB(40, 44, 52), Enum.Material.Concrete)
	floor.Parent = chamberFolder

	-- Permukaan atas lantai berada di Y = 13
	local floorTopY = origin.Y + 3

	-- 2. Plafon Lab Tinggi (Langit-langit Megah Fasilitas Penahanan)
	local ceiling = createPart("ChamberCeiling", Vector3.new(roomSize, 2, roomSize), Vector3.new(0, floorTopY + wallHeight, 0), Color3.fromRGB(24, 28, 36), Enum.Material.SmoothPlastic)
	ceiling.Parent = chamberFolder

	-- 3. Dinding Lab Luas (4 Sisi Pelat Baja)
	local wallCenterY = floorTopY + (wallHeight / 2)
	local wallNorth = createPart("WallNorth", Vector3.new(roomSize, wallHeight, 2), Vector3.new(0, wallCenterY, -roomHalf), Color3.fromRGB(80, 88, 96), Enum.Material.DiamondPlate)
	local wallSouth = createPart("WallSouth", Vector3.new(roomSize, wallHeight, 2), Vector3.new(0, wallCenterY, roomHalf), Color3.fromRGB(80, 88, 96), Enum.Material.DiamondPlate)
	local wallWest  = createPart("WallWest",  Vector3.new(2, wallHeight, roomSize), Vector3.new(-roomHalf, wallCenterY, 0), Color3.fromRGB(80, 88, 96), Enum.Material.DiamondPlate)
	local wallEast  = createPart("WallEast",  Vector3.new(2, wallHeight, roomSize), Vector3.new(roomHalf, wallCenterY, 0), Color3.fromRGB(80, 88, 96), Enum.Material.DiamondPlate)

	wallNorth.Parent = chamberFolder
	wallSouth.Parent = chamberFolder
	wallWest.Parent = chamberFolder
	wallEast.Parent = chamberFolder

	-- 4. Dudukan Telur Raksasa / Pedestal Penahanan (12 x 3.5 x 12 stud)
	local pedestal = createPart("Pedestal", Vector3.new(12, 3.5, 12), Vector3.new(0, floorTopY + 1.75, 0), Color3.fromRGB(15, 18, 22), Enum.Material.CorrodedMetal)
	pedestal.Parent = chamberFolder

	-- 5. Model Telur Anomali Raksasa (EggModel & EggShell)
	-- Ukuran masif (8 x 12 x 8 stud) - berdiri menjulang di atas pedestal
	local eggModel = Instance.new("Model")
	eggModel.Name = "EggModel"
	eggModel.Parent = Workspace

	local eggHeight = 12
	local eggShell = createPart("EggShell", Vector3.new(8, eggHeight, 8), Vector3.new(0, floorTopY + 3.5 + (eggHeight / 2), 0), Color3.fromRGB(223, 230, 233), Enum.Material.Cobblestone)
	eggShell.Shape = Enum.PartType.Block
	eggShell.Parent = eggModel
	eggModel.PrimaryPart = eggShell

	-- Lampu Lab Reaktif di atas telur raksasa (Jangkauan lebih luas)
	local light = Instance.new("PointLight")
	light.Name = "ChamberLight"
	light.Color = Color3.fromRGB(240, 248, 255)
	light.Brightness = 3.5
	light.Range = 60
	light.Shadows = true
	light.Parent = eggShell

	-- 6. Titik Muncul Pemain (SpawnLocation) - Pasti berada DI DALAM ruangan
	-- Nonaktifkan / hapus SpawnLocation bawaan template Studio yang ada di tanah luar
	for _, obj in Workspace:GetChildren() do
		if obj:IsA("SpawnLocation") and obj.Name ~= "LabSpawnLocation" then
			obj.Enabled = false
			obj.CanCollide = false
			obj.Transparency = 1
		end
	end

	local spawn = chamberFolder:FindFirstChild("LabSpawnLocation") :: SpawnLocation?
	if not spawn then
		spawn = Instance.new("SpawnLocation")
		spawn.Name = "LabSpawnLocation"
		spawn.Parent = chamberFolder
	end

	spawn.Size = Vector3.new(8, 1, 8)
	-- Tempatkan tepat di atas lantai lab (Lantai top = floorTopY, spawn = floorTopY + 0.5)
	spawn.Position = Vector3.new(0, floorTopY + 0.5, 24)
	spawn.Color = Color3.fromRGB(9, 132, 227)
	spawn.Material = Enum.Material.Neon
	spawn.Anchored = true
	spawn.CanCollide = true
	spawn.Duration = 0
	spawn.Enabled = true
	spawn.Neutral = true

	print("[ChamberBuilder] Ruangan laboratorium & kubus dummy spesimen berhasil dibuat!")
end

return ChamberBuilder
