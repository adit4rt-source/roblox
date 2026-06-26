-- ================================================================
--  AchievementBookUI (LocalScript)
--  ? Posisi Y disesuaikan ke 50 mengikuti turunnya Bar Atas
-- ================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("AchievementBookGui") then playerGui.AchievementBookGui:Destroy() end

local gui = Instance.new("ScreenGui"); 
gui.Name = "AchievementBookGui"; 
gui.ResetOnSpawn = false; 
gui.IgnoreGuiInset = true; 
gui.Parent = playerGui

local COLOR_BG = Color3.fromRGB(255, 255, 255)
local COLOR_STROKE = Color3.fromRGB(220, 220, 220)
local COLOR_TEXT = Color3.fromRGB(60, 60, 60)

-- [FIX] Posisi Y disesuaikan dengan posisi HUD yang baru (50px dari atas)
local posTutup = UDim2.new(1, 350, 0, 50) 
local posBuka = UDim2.new(1, -15, 0, 50)  

local bookPanel = Instance.new("Frame")
bookPanel.Name = "BookPanel"
bookPanel.Size = UDim2.new(0, 300, 0, 380) 
bookPanel.Position = posTutup
bookPanel.AnchorPoint = Vector2.new(1, 0)
bookPanel.BackgroundColor3 = COLOR_BG
bookPanel.Parent = gui
Instance.new("UICorner", bookPanel).CornerRadius = UDim.new(0, 12)
local panelStroke = Instance.new("UIStroke", bookPanel)
panelStroke.Color = COLOR_STROKE; panelStroke.Thickness = 2

local titleLbl = Instance.new("TextLabel"); titleLbl.Size = UDim2.new(1, 0, 0, 40); titleLbl.BackgroundTransparency = 1; titleLbl.Text = "?? PENCAPAIAN"; titleLbl.Font = Enum.Font.GothamBlack; titleLbl.TextColor3 = COLOR_TEXT; titleLbl.TextSize = 16; titleLbl.Parent = bookPanel
local closeBtn = Instance.new("TextButton"); closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -35, 0, 5); closeBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60); closeBtn.Text = "X"; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); closeBtn.TextSize = 14; closeBtn.Parent = bookPanel; Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
local scrollFrame = Instance.new("ScrollingFrame"); scrollFrame.Size = UDim2.new(1, -20, 1, -50); scrollFrame.Position = UDim2.new(0, 10, 0, 40); scrollFrame.BackgroundTransparency = 1; scrollFrame.ScrollBarThickness = 4; scrollFrame.Parent = bookPanel
local listLayout = Instance.new("UIListLayout"); listLayout.Padding = UDim.new(0, 8); listLayout.Parent = scrollFrame

local daftarMisi = {
	{Nama = "Warga Baru", Desc = "Login untuk pertama kali.", Hadiah = "100 Koin", Selesai = false, Max = 1, StatKey = "LoginCount"},
	{Nama = "Pemanasan", Desc = "Bermain selama 5 menit.", Hadiah = "200 Koin", Selesai = false, Max = 5, StatKey = "MenitMain"},
	{Nama = "Mulai Betah", Desc = "Bermain selama 10 menit.", Hadiah = "300 Koin", Selesai = false, Max = 10, StatKey = "MenitMain"},
	{Nama = "Setengah Jam", Desc = "Bermain selama 30 menit.", Hadiah = "500 Koin", Selesai = false, Max = 30, StatKey = "MenitMain"},
	{Nama = "Satu Jam Penuh", Desc = "Bermain selama 1 Jam.", Hadiah = "1000 Koin", Selesai = false, Max = 60, StatKey = "MenitMain"},
	{Nama = "Pemain Setia", Desc = "Bermain selama 6 Jam.", Hadiah = "5000 Koin", Selesai = false, Max = 360, StatKey = "MenitMain"},
	{Nama = "Setengah Hari", Desc = "Bermain selama 12 Jam.", Hadiah = "10000 Koin", Selesai = false, Max = 720, StatKey = "MenitMain"},
	{Nama = "Sehari Semalam", Desc = "Bermain selama 24 Jam.", Hadiah = "25000 Koin", Selesai = false, Max = 1440, StatKey = "MenitMain"},
	{Nama = "Suka Ngobrol", Desc = "Tulis chat world perdana.", Hadiah = "100 Koin", Selesai = false, Max = 1, StatKey = "ChatCount"},
	{Nama = "Katak Melompat", Desc = "Loncat sebanyak 100 kali.", Hadiah = "200 Koin", Selesai = false, Max = 100, StatKey = "TotalJumps"},
	{Nama = "Kelinci Melompat", Desc = "Loncat sebanyak 1.000 kali.", Hadiah = "1000 Koin", Selesai = false, Max = 1000, StatKey = "TotalJumps"},
	{Nama = "Kangguru", Desc = "Loncat sebanyak 5.000 kali.", Hadiah = "5000 Koin", Selesai = false, Max = 5000, StatKey = "TotalJumps"},
	{Nama = "Penerbang", Desc = "Loncat sebanyak 10.000 kali.", Hadiah = "10000 Koin", Selesai = false, Max = 10000, StatKey = "TotalJumps"},
	{Nama = "Langkah Pertama", Desc = "Berjalan sejauh 10 stud.", Hadiah = "100 Koin", Selesai = false, Max = 10, StatKey = "TotalDistance"},
	{Nama = "Jalan Santai", Desc = "Berjalan sejauh 100 stud.", Hadiah = "500 Koin", Selesai = false, Max = 100, StatKey = "TotalDistance"},
	{Nama = "Pelari Marathon", Desc = "Berjalan sejauh 1.000 stud.", Hadiah = "2000 Koin", Selesai = false, Max = 1000, StatKey = "TotalDistance"},
	{Nama = "Pengembara", Desc = "Berjalan sejauh 10.000 stud.", Hadiah = "10000 Koin", Selesai = false, Max = 10000, StatKey = "TotalDistance"},
	{Nama = "Pemilik Tanah", Desc = "Pergi ke lahanmu pertama kali.", Hadiah = "500 Koin", Selesai = false, Max = 1, StatKey = "PlotVisits"},
	{Nama = "Pemancing Pemula", Desc = "Melakukan mancing pertama kali.", Hadiah = "100 Koin", Selesai = false, Max = 1, StatKey = "FishingCasts"},
	{Nama = "Pemancing Rajin", Desc = "Melakukan mancing 10x.", Hadiah = "500 Koin", Selesai = false, Max = 10, StatKey = "FishingCasts"},
	{Nama = "Pemancing Ahli", Desc = "Melakukan mancing 100x.", Hadiah = "2000 Koin", Selesai = false, Max = 100, StatKey = "FishingCasts"},
	{Nama = "Dewa Kail", Desc = "Melakukan mancing 1.000x.", Hadiah = "10000 Koin", Selesai = false, Max = 1000, StatKey = "FishingCasts"},
	{Nama = "Tangkapan Pertama", Desc = "Mendapatkan ikan 10x.", Hadiah = "500 Koin", Selesai = false, Max = 10, StatKey = "FishCaught"},
	{Nama = "Nelayan", Desc = "Mendapatkan ikan 100x.", Hadiah = "2000 Koin", Selesai = false, Max = 100, StatKey = "FishCaught"},
	{Nama = "Raja Lautan", Desc = "Mendapatkan ikan 1.000x.", Hadiah = "10000 Koin", Selesai = false, Max = 1000, StatKey = "FishCaught"},
	{Nama = "Cuan Mengalir", Desc = "Mendapatkan total 10.000 koin.", Hadiah = "1000 Koin", Selesai = false, Max = 10000, StatKey = "TotalKoinEarned"},
	{Nama = "Mulai Kaya", Desc = "Mendapatkan total 50.000 koin.", Hadiah = "5000 Koin", Selesai = false, Max = 50000, StatKey = "TotalKoinEarned"},
	{Nama = "Sultan IndoVerse", Desc = "Mendapatkan total 100.000 koin.", Hadiah = "10000 Koin", Selesai = false, Max = 100000, StatKey = "TotalKoinEarned"},
	{Nama = "Naik Pangkat I", Desc = "Mencapai level 5.", Hadiah = "1000 Koin", Selesai = false, Max = 5, StatKey = "Level"},
	{Nama = "Naik Pangkat II", Desc = "Mencapai level 10.", Hadiah = "2000 Koin", Selesai = false, Max = 10, StatKey = "Level"},
	{Nama = "Naik Pangkat III", Desc = "Mencapai level 15.", Hadiah = "3000 Koin", Selesai = false, Max = 15, StatKey = "Level"},
	{Nama = "Naik Pangkat IV", Desc = "Mencapai level 20.", Hadiah = "4000 Koin", Selesai = false, Max = 20, StatKey = "Level"},
	{Nama = "Naik Pangkat V", Desc = "Mencapai level 25.", Hadiah = "5000 Koin", Selesai = false, Max = 25, StatKey = "Level"},
	{Nama = "Naik Pangkat VI", Desc = "Mencapai level 30.", Hadiah = "6000 Koin", Selesai = false, Max = 30, StatKey = "Level"},
	{Nama = "Naik Pangkat VII", Desc = "Mencapai level 35.", Hadiah = "7000 Koin", Selesai = false, Max = 35, StatKey = "Level"},
	{Nama = "Naik Pangkat VIII", Desc = "Mencapai level 40.", Hadiah = "8000 Koin", Selesai = false, Max = 40, StatKey = "Level"},
	{Nama = "Naik Pangkat IX", Desc = "Mencapai level 45.", Hadiah = "9000 Koin", Selesai = false, Max = 45, StatKey = "Level"},
	{Nama = "Legenda", Desc = "Mencapai level 50.", Hadiah = "10000 Koin", Selesai = false, Max = 50, StatKey = "Level"},
	{Nama = "Pemancing Level 5", Desc = "Mencapai level 5 mancing.", Hadiah = "1000 Koin", Selesai = false, Max = 5, StatKey = "FishingLevel"},
	{Nama = "Pemancing Level 10", Desc = "Mencapai level 10 mancing.", Hadiah = "2000 Koin", Selesai = false, Max = 10, StatKey = "FishingLevel"},
	{Nama = "Pemancing Level 20", Desc = "Mencapai level 20 mancing.", Hadiah = "4000 Koin", Selesai = false, Max = 20, StatKey = "FishingLevel"},
	{Nama = "Pemancing Level 30", Desc = "Mencapai level 30 mancing.", Hadiah = "6000 Koin", Selesai = false, Max = 30, StatKey = "FishingLevel"},
	{Nama = "Master Mancing", Desc = "Mencapai level 50 mancing.", Hadiah = "10000 Koin", Selesai = false, Max = 50, StatKey = "FishingLevel"},
	{Nama = "Penggali Batu I", Desc = "Menambang sebanyak 10 batu.", Hadiah = "100 Koin", Selesai = false, Max = 10, StatKey = "TotalMined"},
	{Nama = "Penggali Batu II", Desc = "Menambang sebanyak 100 batu.", Hadiah = "1000 Koin", Selesai = false, Max = 100, StatKey = "TotalMined"},
	{Nama = "Penggali Batu III", Desc = "Menambang sebanyak 500 batu.", Hadiah = "5000 Koin", Selesai = false, Max = 500, StatKey = "TotalMined"},
	{Nama = "Pencari Arang I", Desc = "Menambang Coal sebanyak 10.", Hadiah = "100 Koin", Selesai = false, Max = 10, StatKey = "MinedCoal"},
	{Nama = "Pencari Arang II", Desc = "Menambang Coal sebanyak 100.", Hadiah = "1000 Koin", Selesai = false, Max = 100, StatKey = "MinedCoal"},
	{Nama = "Pencari Arang III", Desc = "Menambang Coal sebanyak 1000.", Hadiah = "5000 Koin", Selesai = false, Max = 1000, StatKey = "MinedCoal"},
	{Nama = "Pencari Besi I", Desc = "Menambang Iron sebanyak 10.", Hadiah = "200 Koin", Selesai = false, Max = 10, StatKey = "MinedIron"},
	{Nama = "Pencari Besi II", Desc = "Menambang Iron sebanyak 100.", Hadiah = "2000 Koin", Selesai = false, Max = 100, StatKey = "MinedIron"},
	{Nama = "Pencari Besi III", Desc = "Menambang Iron sebanyak 1000.", Hadiah = "10000 Koin", Selesai = false, Max = 1000, StatKey = "MinedIron"},
	{Nama = "Pencari Emas I", Desc = "Menambang Gold sebanyak 10.", Hadiah = "500 Koin", Selesai = false, Max = 10, StatKey = "MinedGold"},
	{Nama = "Pencari Emas II", Desc = "Menambang Gold sebanyak 100.", Hadiah = "5000 Koin", Selesai = false, Max = 100, StatKey = "MinedGold"},
	{Nama = "Pencari Emas III", Desc = "Menambang Gold sebanyak 1000.", Hadiah = "25000 Koin", Selesai = false, Max = 1000, StatKey = "MinedGold"},
	{Nama = "Pencari Zamrud I", Desc = "Menambang Emerald sebanyak 10.", Hadiah = "1000 Koin", Selesai = false, Max = 10, StatKey = "MinedEmerald"},
	{Nama = "Pencari Zamrud II", Desc = "Menambang Emerald sebanyak 100.", Hadiah = "10000 Koin", Selesai = false, Max = 100, StatKey = "MinedEmerald"},
	{Nama = "Pencari Zamrud III", Desc = "Menambang Emerald sebanyak 1000.", Hadiah = "50000 Koin", Selesai = false, Max = 1000, StatKey = "MinedEmerald"},
	{Nama = "Pencari Berlian I", Desc = "Menambang Diamond sebanyak 10.", Hadiah = "2000 Koin", Selesai = false, Max = 10, StatKey = "MinedDiamond"},
	{Nama = "Pencari Berlian II", Desc = "Menambang Diamond sebanyak 100.", Hadiah = "20000 Koin", Selesai = false, Max = 100, StatKey = "MinedDiamond"},
	{Nama = "Pencari Berlian III", Desc = "Menambang Diamond sebanyak 1000.", Hadiah = "100000 Koin", Selesai = false, Max = 1000, StatKey = "MinedDiamond"},
	{Nama = "Saudagar Tambang I", Desc = "Jual batu sebanyak 100.", Hadiah = "1000 Koin", Selesai = false, Max = 100, StatKey = "TotalRocksSold"},
	{Nama = "Saudagar Tambang II", Desc = "Jual batu sebanyak 1000.", Hadiah = "10000 Koin", Selesai = false, Max = 1000, StatKey = "TotalRocksSold"},
	{Nama = "Pemburu Slime I", Desc = "Membunuh monster slime sebanyak 10.", Hadiah = "500 Koin", Selesai = false, Max = 10, StatKey = "MonstersKilled"},
	{Nama = "Pemburu Slime II", Desc = "Membunuh monster slime sebanyak 100.", Hadiah = "5000 Koin", Selesai = false, Max = 100, StatKey = "MonstersKilled"},
	{Nama = "Pemburu Slime III", Desc = "Membunuh monster slime sebanyak 1000.", Hadiah = "50000 Koin", Selesai = false, Max = 1000, StatKey = "MonstersKilled"},
	{Nama = "Pengepul Gel I", Desc = "Menjual SlimeGel sebanyak 10.", Hadiah = "200 Koin", Selesai = false, Max = 10, StatKey = "SlimeGelSold"},
	{Nama = "Pengepul Gel II", Desc = "Menjual SlimeGel sebanyak 100.", Hadiah = "2000 Koin", Selesai = false, Max = 100, StatKey = "SlimeGelSold"},
	{Nama = "Pengepul Gel III", Desc = "Menjual SlimeGel sebanyak 1000.", Hadiah = "20000 Koin", Selesai = false, Max = 1000, StatKey = "SlimeGelSold"},
}

for _, misi in ipairs(daftarMisi) do
	local card = Instance.new("Frame"); card.Size = UDim2.new(1, -6, 0, 80); card.Parent = scrollFrame; Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
	local namaLbl = Instance.new("TextLabel"); namaLbl.Size = UDim2.new(1, -10, 0, 20); namaLbl.Position = UDim2.new(0, 10, 0, 5); namaLbl.BackgroundTransparency = 1; namaLbl.Text = misi.Nama; namaLbl.Font = Enum.Font.GothamBold; namaLbl.TextColor3 = COLOR_TEXT; namaLbl.TextSize = 14; namaLbl.TextXAlignment = Enum.TextXAlignment.Left; namaLbl.Parent = card
	local descLbl = Instance.new("TextLabel"); descLbl.Size = UDim2.new(1, -10, 0, 15); descLbl.Position = UDim2.new(0, 10, 0, 25); descLbl.BackgroundTransparency = 1; descLbl.Text = misi.Desc .. " (Hadiah: " .. misi.Hadiah .. ")"; descLbl.Font = Enum.Font.GothamMedium; descLbl.TextColor3 = Color3.fromRGB(130, 130, 130); descLbl.TextSize = 11; descLbl.TextXAlignment = Enum.TextXAlignment.Left; descLbl.Parent = card
	local barBg = Instance.new("Frame"); barBg.Size = UDim2.new(1, -20, 0, 14); barBg.Position = UDim2.new(0, 10, 0, 50); barBg.BackgroundColor3 = Color3.fromRGB(230, 230, 230); barBg.BorderSizePixel = 0; barBg.Parent = card; Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
	local fill = Instance.new("Frame"); fill.Size = UDim2.new(0, 0, 1, 0); fill.BorderSizePixel = 0; fill.Parent = barBg; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	local progTxt = Instance.new("TextLabel"); progTxt.Size = UDim2.new(1, 0, 1, 0); progTxt.BackgroundTransparency = 1; progTxt.Font = Enum.Font.GothamBold; progTxt.TextColor3 = Color3.fromRGB(100, 100, 100); progTxt.TextSize = 10; progTxt.Parent = barBg
	local statusLbl = Instance.new("TextLabel"); statusLbl.Size = UDim2.new(0, 80, 0, 20); statusLbl.Position = UDim2.new(1, -90, 0, 5); statusLbl.BackgroundTransparency = 1; statusLbl.Font = Enum.Font.GothamBold; statusLbl.TextSize = 11; statusLbl.TextXAlignment = Enum.TextXAlignment.Right; statusLbl.Parent = card
	local claimBtn = Instance.new("TextButton"); claimBtn.Size = UDim2.new(0, 70, 0, 22); claimBtn.Position = UDim2.new(1, -80, 0, 5); claimBtn.BackgroundColor3 = Color3.fromRGB(241, 196, 15); claimBtn.Text = "?? CLAIM"; claimBtn.Font = Enum.Font.GothamBold; claimBtn.TextColor3 = Color3.fromRGB(255, 255, 255); claimBtn.TextSize = 10; claimBtn.Parent = card; claimBtn.Visible = false; Instance.new("UICorner", claimBtn).CornerRadius = UDim.new(0, 6)

	local safeName = string.gsub(misi.Nama, " ", "")
	local function UpdateCardUI()
		if player:GetAttribute("Ach_" .. safeName) then misi.Selesai = true end
		local currentProgress = misi.StatKey and (player:GetAttribute(misi.StatKey) or 0) or 0
		if misi.Selesai then currentProgress = misi.Max end
		if currentProgress > misi.Max then currentProgress = misi.Max end
		local isFull = currentProgress >= misi.Max
		progTxt.Text = math.floor(currentProgress) .. " / " .. misi.Max
		TweenService:Create(fill, TweenInfo.new(0.3), {Size = UDim2.new(math.clamp(currentProgress / misi.Max, 0, 1), 0, 1, 0)}):Play()

		if not isFull then
			statusLbl.Text = "?? TERKUNCI"; statusLbl.TextColor3 = Color3.fromRGB(180, 180, 180); card.BackgroundColor3 = Color3.fromRGB(245, 245, 245); fill.BackgroundColor3 = Color3.fromRGB(241, 196, 15); claimBtn.Visible = false; statusLbl.Visible = true
		elseif isFull and not misi.Selesai then
			claimBtn.Visible = true; statusLbl.Visible = false; card.BackgroundColor3 = Color3.fromRGB(255, 250, 230); fill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
		elseif isFull and misi.Selesai then
			claimBtn.Visible = false; statusLbl.Visible = true; statusLbl.Text = "? SELESAI"; statusLbl.TextColor3 = Color3.fromRGB(46, 204, 113); card.BackgroundColor3 = Color3.fromRGB(235, 255, 235); fill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
		end
	end

	if misi.StatKey then player:GetAttributeChangedSignal(misi.StatKey):Connect(UpdateCardUI) end
	player:GetAttributeChangedSignal("Ach_" .. safeName):Connect(UpdateCardUI); UpdateCardUI()

	claimBtn.MouseButton1Click:Connect(function()
		misi.Selesai = true; UpdateCardUI()
		game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClaimAchievementEvent"):FireServer(misi.Nama, misi.Hadiah)
		local notifEvent = ReplicatedStorage:FindFirstChild("CustomNotification")
		if notifEvent then notifEvent:Fire({Title = "?? CLAIM BERHASIL!", Text = "Kamu mendapatkan " .. misi.Hadiah, Color = Color3.fromRGB(241, 196, 15)}) end
	end)
end

scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #daftarMisi * 88)

local isBuka = false; local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function ToggleBook()
	isBuka = not isBuka
	local targetPos = isBuka and posBuka or posTutup
	TweenService:Create(bookPanel, tweenInfo, {Position = targetPos}):Play()
end
closeBtn.MouseButton1Click:Connect(ToggleBook)

local toggleEvent = playerGui:FindFirstChild("ToggleAchievementUI")
if not toggleEvent then toggleEvent = Instance.new("BindableEvent"); toggleEvent.Name = "ToggleAchievementUI"; toggleEvent.Parent = playerGui end
toggleEvent.Event:Connect(ToggleBook)