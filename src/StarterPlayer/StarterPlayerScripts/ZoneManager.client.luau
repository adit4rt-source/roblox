-- ================================================================
--  ZoneManager (LocalScript)
--  Mendeteksi area pemain, mengubah Lighting, dan memunculkan Notifikasi
-- ================================================================

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local zonesFolder = workspace:WaitForChild("AreaZones")

-- ==========================================
-- 1. BUAT UI PENGUMUMAN OTOMATIS
-- ==========================================
local gui = Instance.new("ScreenGui")
gui.Name = "ZoneAnnouncementGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local announceContainer = Instance.new("Frame", gui)
announceContainer.Size = UDim2.new(1, 0, 0, 80)
announceContainer.Position = UDim2.new(0, 0, 0, 60)
announceContainer.BackgroundTransparency = 1

local subLabel = Instance.new("TextLabel", announceContainer)
subLabel.Size = UDim2.new(1, 0, 0, 20)
subLabel.Position = UDim2.new(0, 0, 0, 10)
subLabel.BackgroundTransparency = 1
subLabel.Text = "MEMASUKI AREA"
subLabel.Font = Enum.Font.GothamMedium
subLabel.TextSize = 14
subLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
subLabel.TextTransparency = 1
subLabel.TextStrokeTransparency = 1

local nameLabel = Instance.new("TextLabel", announceContainer)
nameLabel.Size = UDim2.new(1, 0, 0, 40)
nameLabel.Position = UDim2.new(0, 0, 0, 30)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "NAMA AREA"
nameLabel.Font = Enum.Font.GothamBlack
nameLabel.TextSize = 32
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.TextTransparency = 1
nameLabel.TextStrokeTransparency = 1
local uiStroke = Instance.new("UIStroke", nameLabel)
uiStroke.Thickness = 2
uiStroke.Transparency = 1

-- ==========================================
-- 2. SIMPAN PENCAHAYAAN DEFAULT (AWAL)
-- ==========================================
local defaultLighting = {
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime
}

-- ==========================================
-- 3. FUNGSI TRANSISI ANIMASI
-- ==========================================
local currentZonePart = nil
local announceTweenIn1, announceTweenIn2, announceTweenIn3
local announceTweenOut1, announceTweenOut2, announceTweenOut3

local function ShowAnnouncement(zoneName)
	nameLabel.Text = string.upper(zoneName)

	-- Batalkan animasi keluar jika sedang berjalan
	if announceTweenOut1 then announceTweenOut1:Cancel(); announceTweenOut2:Cancel(); announceTweenOut3:Cancel() end

	-- Reset Posisi agak ke bawah untuk efek meluncur naik
	announceContainer.Position = UDim2.new(0, 0, 0, 80)

	-- Animasi Masuk (Fade in & Slide up)
	local tInfoIn = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	TweenService:Create(announceContainer, tInfoIn, {Position = UDim2.new(0, 0, 0, 60)}):Play()
	announceTweenIn1 = TweenService:Create(subLabel, tInfoIn, {TextTransparency = 0, TextStrokeTransparency = 0.5}); announceTweenIn1:Play()
	announceTweenIn2 = TweenService:Create(nameLabel, tInfoIn, {TextTransparency = 0}); announceTweenIn2:Play()
	announceTweenIn3 = TweenService:Create(uiStroke, tInfoIn, {Transparency = 0}); announceTweenIn3:Play()

	-- Hilang otomatis setelah 4 detik
	task.delay(4, function()
		if currentZonePart and (currentZonePart:GetAttribute("ZoneName") or currentZonePart.Name) == zoneName then
			local tInfoOut = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			announceTweenOut1 = TweenService:Create(subLabel, tInfoOut, {TextTransparency = 1, TextStrokeTransparency = 1}); announceTweenOut1:Play()
			announceTweenOut2 = TweenService:Create(nameLabel, tInfoOut, {TextTransparency = 1}); announceTweenOut2:Play()
			announceTweenOut3 = TweenService:Create(uiStroke, tInfoOut, {Transparency = 1}); announceTweenOut3:Play()
		end
	end)
end

local function ApplyZoneLighting(zonePart)
	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) -- Berubah perlahan selama 3 detik
	local targetLighting = {}

	if zonePart then
		-- Baca pengaturan dari Part Zone
		if zonePart:GetAttribute("Ambient") then targetLighting.Ambient = zonePart:GetAttribute("Ambient") end
		if zonePart:GetAttribute("OutdoorAmbient") then targetLighting.OutdoorAmbient = zonePart:GetAttribute("OutdoorAmbient") end
		if zonePart:GetAttribute("Brightness") then targetLighting.Brightness = zonePart:GetAttribute("Brightness") end
		if zonePart:GetAttribute("ClockTime") then targetLighting.ClockTime = zonePart:GetAttribute("ClockTime") end
	else
		-- Jika keluar dari semua area, kembalikan ke default
		targetLighting = defaultLighting
	end

	-- Pastikan ada yang diubah
	local hasChanges = false
	for k, v in pairs(targetLighting) do hasChanges = true break end

	if hasChanges then
		TweenService:Create(Lighting, tweenInfo, targetLighting):Play()
	end
end

-- ==========================================
-- 4. RADAR PENDETEKSI ZONA
-- ==========================================
task.spawn(function()
	while task.wait(0.5) do -- Mengecek setiap 0.5 detik (sangat ringan)
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")

		if hrp then
			local foundZone = nil
			-- Cek bagian/part apa saja yang sedang disentuh tubuh pemain
			local overlappingParts = workspace:GetPartsInPart(hrp)

			for _, part in ipairs(overlappingParts) do
				if part.Parent == zonesFolder then
					foundZone = part
					break -- Ketemu areanya!
				end
			end

			-- Jika berpindah area
			if foundZone ~= currentZonePart then
				currentZonePart = foundZone

				if currentZonePart then
					local zName = currentZonePart:GetAttribute("ZoneName") or "Area Misterius"
					ShowAnnouncement(zName)
					ApplyZoneLighting(currentZonePart)
				else
					-- Keluar zona
					ApplyZoneLighting(nil) 
				end
			end
		end
	end
end)