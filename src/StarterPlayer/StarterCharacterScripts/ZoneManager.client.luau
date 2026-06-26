local player = game.Players.LocalPlayer
local char = script.Parent
local HRP = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local RS = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sapuTemplate = ReplicatedStorage:WaitForChild("SapuTerbang")

local noFlyFolder = workspace:FindFirstChild("NoFlyZones")
if not noFlyFolder then
	noFlyFolder = Instance.new("Folder")
	noFlyFolder.Name = "NoFlyZones"
	noFlyFolder.Parent = workspace
end

local function isInNoFlyZone()
	if not HRP then return false end
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = {noFlyFolder}

	local parts = workspace:GetPartsInPart(HRP, overlapParams)
	return #parts > 0
end

-- [PERBAIKAN]: Kita set nil agar saat baru masuk server, skrip langsung bekerja!
local wasInZone = nil 

RS.Heartbeat:Connect(function()
	if not char or not humanoid or humanoid.Health <= 0 then return end

	local inZone = isInNoFlyZone()

	-- DETEKSI SAAT BARU MASUK, BARU KELUAR, ATAU BARU SPAWN
	if inZone ~= wasInZone then
		wasInZone = inZone

		if inZone then
			-- [MASUK ZONA TERLARANG]
			local sapuInHand = char:FindFirstChild("SapuTerbang")
			if sapuInHand then
				humanoid:UnequipTools() 
			end

			task.delay(0.1, function()
				if wasInZone then 
					local sapuInBag = player.Backpack:FindFirstChild("SapuTerbang")
					local sapuEquipped = char:FindFirstChild("SapuTerbang")
					if sapuInBag then sapuInBag:Destroy() end
					if sapuEquipped then sapuEquipped:Destroy() end

					if HRP then
						for _, v in pairs(HRP:GetChildren()) do
							if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
								v:Destroy()
							end
						end
					end
					humanoid.PlatformStand = false
				end
			end)
		else
			-- [KELUAR ZONA TERLARANG ATAU BARU SPAWN DI LUAR ZONA]
			local sapuInBag = player.Backpack:FindFirstChild("SapuTerbang")
			local sapuInHand = char:FindFirstChild("SapuTerbang")

			-- Kalau belum punya sapu sama sekali (misal baru login)
			if not sapuInBag and not sapuInHand then
				local newSapu = sapuTemplate:Clone()
				newSapu.Parent = player.Backpack
				humanoid:EquipTool(newSapu)
			elseif sapuInBag then
				-- Kalau ada di tas tapi belum dipegang
				humanoid:EquipTool(sapuInBag)
			end
		end
	end

	-- FAIL-SAFE: MEMASTIKAN PEMAIN TIDAK ISENG MELEPAS MANUAL SAAT DI LUAR
	if not inZone then
		local sapuInBag = player.Backpack:FindFirstChild("SapuTerbang")
		local sapuInHand = char:FindFirstChild("SapuTerbang")

		if sapuInBag and not sapuInHand then
			humanoid:EquipTool(sapuInBag)
		end
	end
end)