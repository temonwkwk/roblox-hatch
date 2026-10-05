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

	local origin = Vector3.new(0, 0, 0)

	-- 1. Lantai Lab Utama (Abu-abu Slate)
	local floor = createPart("ChamberFloor", Vector3.new(40, 2, 40), origin + Vector3.new(0, -1, 0), Color3.fromRGB(45, 52, 54), Enum.Material.Concrete)
	floor.Parent = chamberFolder

	-- 2. Plafon Lab
	local ceiling = createPart("ChamberCeiling", Vector3.new(40, 1, 40), origin + Vector3.new(0, 18, 0), Color3.fromRGB(30, 39, 46), Enum.Material.SmoothPlastic)
	ceiling.Parent = chamberFolder

	-- 3. Dinding Lab (4 Sisi)
	local wallNorth = createPart("WallNorth", Vector3.new(40, 18, 2), origin + Vector3.new(0, 9, -20), Color3.fromRGB(99, 110, 114), Enum.Material.DiamondPlate)
	local wallSouth = createPart("WallSouth", Vector3.new(40, 18, 2), origin + Vector3.new(0, 9, 20), Color3.fromRGB(99, 110, 114), Enum.Material.DiamondPlate)
	local wallWest = createPart("WallWest", Vector3.new(2, 18, 40), origin + Vector3.new(-20, 9, 0), Color3.fromRGB(99, 110, 114), Enum.Material.DiamondPlate)
	local wallEast = createPart("WallEast", Vector3.new(2, 18, 40), origin + Vector3.new(20, 9, 0), Color3.fromRGB(99, 110, 114), Enum.Material.DiamondPlate)

	wallNorth.Parent = chamberFolder
	wallSouth.Parent = chamberFolder
	wallWest.Parent = chamberFolder
	wallEast.Parent = chamberFolder

	-- 4. Dudukan Telur / Pedestal (Kubus Silinder Hitam Obsidian)
	local pedestal = createPart("Pedestal", Vector3.new(6, 3, 6), origin + Vector3.new(0, 1.5, 0), Color3.fromRGB(20, 20, 25), Enum.Material.CorrodedMetal)
	pedestal.Parent = chamberFolder

	-- 5. Model Telur Anomali (EggModel & EggShell)
	local eggModel = Instance.new("Model")
	eggModel.Name = "EggModel"
	eggModel.Parent = Workspace

	-- Kubus spesimen telur utama
	local eggShell = createPart("EggShell", Vector3.new(4, 5.5, 4), origin + Vector3.new(0, 5.75, 0), Color3.fromRGB(223, 230, 233), Enum.Material.Cobblestone)
	eggShell.Shape = Enum.PartType.Block
	eggShell.Parent = eggModel
	eggModel.PrimaryPart = eggShell

	-- Lampu Lab Reaktif di atas telur
	local light = Instance.new("PointLight")
	light.Name = "ChamberLight"
	light.Color = Color3.fromRGB(240, 248, 255)
	light.Brightness = 2
	light.Range = 35
	light.Shadows = true
	light.Parent = eggShell

	-- 6. Titik Muncul Pemain (SpawnLocation)
	local existingSpawn = Workspace:FindFirstChildOfClass("SpawnLocation")
	if not existingSpawn then
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "LabSpawnLocation"
		spawn.Size = Vector3.new(6, 1, 6)
		spawn.Position = origin + Vector3.new(0, 0.5, 14)
		spawn.Color = Color3.fromRGB(9, 132, 227)
		spawn.Material = Enum.Material.Neon
		spawn.Anchored = true
		spawn.CanCollide = true
		spawn.Duration = 0
		spawn.Parent = chamberFolder
	end

	print("[ChamberBuilder] Ruangan laboratorium & kubus dummy spesimen berhasil dibuat!")
end

return ChamberBuilder
