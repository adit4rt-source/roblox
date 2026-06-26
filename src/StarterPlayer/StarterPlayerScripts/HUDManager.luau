-- ================================================================
--  HUDManager (LocalScript) - INDOVERSE ULTIMATE TOP-RIGHT UI
--  NO CHAT EDITION: Bersih dari fitur Private Chat
-- ================================================================

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService") 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) end)

if playerGui:FindFirstChild("IndoVerseHUD") then playerGui.IndoVerseHUD:Destroy() end
if playerGui:FindFirstChild("ConfirmTeleportGui") then playerGui.ConfirmTeleportGui:Destroy() end
if playerGui:FindFirstChild("CustomLeaderboardGui") then playerGui.CustomLeaderboardGui:Destroy() end

local COLOR_BG = Color3.fromRGB(255, 255, 255)
local COLOR_STROKE = Color3.fromRGB(220, 220, 220)
local COLOR_TEXT = Color3.fromRGB(60, 60, 60)
local COLOR_GOLD = Color3.fromRGB(241, 196, 15)

local hudGui = Instance.new("ScreenGui")
hudGui.Name = "IndoVerseHUD"; hudGui.ResetOnSpawn = false; hudGui.IgnoreGuiInset = true; hudGui.Parent = playerGui

-- MAIN CONTAINER
local topContainer = Instance.new("Frame", hudGui)
topContainer.Name = "TopRightContainer"
topContainer.Size = UDim2.new(0, 600, 0, 32)
topContainer.Position = UDim2.new(1, -15, 0, 12)
topContainer.AnchorPoint = Vector2.new(1, 0)
topContainer.BackgroundTransparency = 1

local listLayout = Instance.new("UIListLayout", topContainer)
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)

local function BuatTopStat(nama, icon, width, layoutOrder)
	local pill = Instance.new("Frame", topContainer)
	pill.Name = nama; pill.LayoutOrder = layoutOrder; pill.Size = UDim2.new(0, width, 1, 0); pill.BackgroundColor3 = COLOR_BG
	Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", pill).Color = COLOR_STROKE; Instance.new("UIStroke", pill).Thickness = 2

	local iconLbl = Instance.new("TextLabel", pill)
	iconLbl.Size = UDim2.new(0, 22, 1, 0); iconLbl.Position = UDim2.new(0, 5, 0, 0); iconLbl.BackgroundTransparency = 1; iconLbl.Text = icon
	iconLbl.TextSize = 15

	local txtLbl = Instance.new("TextLabel", pill); txtLbl.Size = UDim2.new(1, -28, 1, 0); txtLbl.Position = UDim2.new(0, 28, 0, 0)
	txtLbl.BackgroundTransparency = 1; txtLbl.Text = "0"; txtLbl.Font = Enum.Font.GothamBold; txtLbl.TextColor3 = COLOR_TEXT; txtLbl.TextSize = 12
	txtLbl.TextXAlignment = Enum.TextXAlignment.Left
	return pill, txtLbl
end

local function BuatTopBtn(nama, icon, layoutOrder, parentFrame)
	local p = parentFrame or topContainer
	local btn = Instance.new("TextButton", p)
	btn.Name = nama; btn.LayoutOrder = layoutOrder; btn.Size = UDim2.new(0, 32, 1, 0); btn.BackgroundColor3 = COLOR_BG
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", btn).Color = COLOR_STROKE; Instance.new("UIStroke", btn).Thickness = 2; btn.Text = icon; btn.TextSize = 16
	btn.TextColor3 = COLOR_TEXT; btn.Font = Enum.Font.GothamBold
	return btn
end

-- 1 & 2: STATUS (LEVEL & KOIN)
local levelPill, levelTxt = BuatTopStat("LevelStat", "?", 90, 1)
local koinPill, koinTxt = BuatTopStat("KoinStat", "??", 100, 2)

-- 3: WADAH TOMBOL MENU (SLIDING CONTAINER)
local actionContainer = Instance.new("Frame", topContainer)
actionContainer.Name = "ActionContainer"
actionContainer.LayoutOrder = 3
actionContainer.Size = UDim2.new(0, 260, 1, 0)
actionContainer.BackgroundTransparency = 1
actionContainer.ClipsDescendants = true 
local actionLayout = Instance.new("UIListLayout", actionContainer)
actionLayout.FillDirection = Enum.FillDirection.Horizontal
actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
actionLayout.SortOrder = Enum.SortOrder.LayoutOrder
actionLayout.Padding = UDim.new(0, 6)

-- TOMBOL-TOMBOL DI DALAM WADAH MENU
local friendBtn = BuatTopBtn("FriendBtn", "??", 1, actionContainer) 
local menuBtn = BuatTopBtn("MenuBtn", "??", 2, actionContainer) 
local achieveBtn = BuatTopBtn("AchieveBtn", "??", 3, actionContainer) 
local invBtn = BuatTopBtn("InvBtn", "??", 4, actionContainer) 
local danceBtn = BuatTopBtn("DanceBtn", "??", 5, actionContainer) 
local settingBtn = BuatTopBtn("SettingBtn", "??", 6, actionContainer) 
local tpBtn = BuatTopBtn("TpBtn", "??", 7, actionContainer) 

-- 4: TOMBOL TOGGLE (HAMBURGER / CLOSE)
local toggleMenuBtn = BuatTopBtn("ToggleMenuBtn", "X", 4, topContainer) 
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

levelTxt.Position = UDim2.new(0, 28, 0, -4) 
local lvlBarBg = Instance.new("Frame", levelPill); lvlBarBg.Size = UDim2.new(1, -33, 0, 4); lvlBarBg.Position = UDim2.new(0, 28, 1, -8)
lvlBarBg.BackgroundColor3 = Color3.fromRGB(230, 230, 230); Instance.new("UICorner", lvlBarBg).CornerRadius = UDim.new(1, 0)
local lvlFill = Instance.new("Frame", lvlBarBg); lvlFill.Size = UDim2.new(0, 0, 1, 0)
lvlFill.BackgroundColor3 = COLOR_GOLD; Instance.new("UICorner", lvlFill).CornerRadius = UDim.new(1, 0)

-- EFEK GLOW EXP
local expGlow = Instance.new("Frame", lvlFill)
expGlow.Size = UDim2.new(1, 0, 1, 0)
expGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255); expGlow.BackgroundTransparency = 1; Instance.new("UICorner", expGlow).CornerRadius = UDim.new(1, 0)

local function FlashEXPGlow()
	expGlow.BackgroundTransparency = 0.2
	TweenService:Create(expGlow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
end

-- ==========================================
-- 2. PANEL FRIENDLIST & DROPDOWN LAINNYA
-- ==========================================
local friendFrame = Instance.new("Frame", hudGui)
friendFrame.Size = UDim2.new(0, 200, 0, 200); friendFrame.Position = UDim2.new(1, -210, 0, -250); friendFrame.AnchorPoint = Vector2.new(1, 0); friendFrame.BackgroundColor3 = COLOR_BG
Instance.new("UICorner", friendFrame).CornerRadius = UDim.new(0, 10); Instance.new("UIStroke", friendFrame).Color = COLOR_STROKE; Instance.new("UIStroke", friendFrame).Thickness = 2
local frTitle = Instance.new("TextLabel", friendFrame)
frTitle.Size = UDim2.new(1, 0, 0, 30); frTitle.BackgroundTransparency = 1; frTitle.Text = "?? DAFTAR TEMAN"; frTitle.Font = Enum.Font.GothamBlack; frTitle.TextColor3 = COLOR_TEXT
frTitle.TextSize = 12
local frScroll = Instance.new("ScrollingFrame", friendFrame); frScroll.Size = UDim2.new(1, -10, 1, -40); frScroll.Position = UDim2.new(0, 5, 0, 35)
frScroll.BackgroundTransparency = 1; frScroll.ScrollBarThickness = 3
local frLayout = Instance.new("UIListLayout", frScroll)
frLayout.Padding = UDim.new(0, 4)

local function UpdateFriendList(friendUserIds)
	for _, child in pairs(frScroll:GetChildren()) do if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end end
	local onlineCount = 0
	if friendUserIds then
		for _, uid in ipairs(friendUserIds) do
			local fPlayer = Players:GetPlayerByUserId(uid)
			if fPlayer then 
				onlineCount += 1
				local bar = Instance.new("TextButton", frScroll)
				bar.Size = UDim2.new(1, -6, 0, 25); bar.BackgroundColor3 = Color3.fromRGB(245, 245, 245); bar.Text = ""; bar.AutoButtonColor = false
				Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 6)

				local statDot = Instance.new("Frame", bar); statDot.Size = UDim2.new(0, 8, 0, 8)
				statDot.Position = UDim2.new(0, 8, 0.5, -4); statDot.BackgroundColor3 = Color3.fromRGB(46, 204, 113); Instance.new("UICorner", statDot).CornerRadius = UDim.new(1,0)

				local nameL = Instance.new("TextLabel", bar)
				nameL.Size = UDim2.new(1, -25, 1, 0); nameL.Position = UDim2.new(0, 22, 0, 0); nameL.BackgroundTransparency = 1; nameL.Text = fPlayer.Name
				nameL.Font = Enum.Font.GothamSemibold; nameL.TextColor3 = COLOR_TEXT; nameL.TextSize = 11; nameL.TextXAlignment = Enum.TextXAlignment.Left
			end
		end
	end
	if onlineCount == 0 then 
		local none = Instance.new("TextLabel", frScroll)
		none.Size = UDim2.new(1,0,0,30); none.BackgroundTransparency = 1; none.Text = "Tidak ada teman online."; none.Font = Enum.Font.Gotham; none.TextColor3 = Color3.fromRGB(150,150,150)
		none.TextSize = 10 
	end
end

Remotes:WaitForChild("UpdateFriendUIEvent").OnClientEvent:Connect(UpdateFriendList)

local isFriendOpen = false
friendBtn.MouseButton1Click:Connect(function()
	isFriendOpen = not isFriendOpen
	TweenService:Create(friendBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 28, 1, -4)}):Play(); task.delay(0.1, function() TweenService:Create(friendBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 32, 1, 0)}):Play() end)
	TweenService:Create(friendFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = isFriendOpen and UDim2.new(1, -210, 0, 50) or UDim2.new(1, -210, 0, -250)}):Play()
end)

-- JOB FRAME
local jobFrame = Instance.new("Frame", hudGui)
jobFrame.Size = UDim2.new(0, 170, 0, 150); jobFrame.Position = UDim2.new(1, -180, 0, -250); jobFrame.AnchorPoint = Vector2.new(1, 0); jobFrame.BackgroundColor3 = COLOR_BG
Instance.new("UICorner", jobFrame).CornerRadius = UDim.new(0, 10); Instance.new("UIStroke", jobFrame).Color = COLOR_STROKE; Instance.new("UIStroke", jobFrame).Thickness = 2
local function BuatJobBar(nama, posisiY, icon, warnaFill, parent)
	local container = Instance.new("Frame", parent)
	container.Size = UDim2.new(1, -20, 0, 38); container.Position = UDim2.new(0, 10, 0, posisiY); container.BackgroundTransparency = 1
	local lbl = Instance.new("TextLabel", container)
	lbl.Size = UDim2.new(1, 0, 0, 16); lbl.BackgroundTransparency = 1; lbl.Text = icon .. " " .. nama .. ": Lv.1"
	lbl.Font = Enum.Font.GothamBold; lbl.TextColor3 = COLOR_TEXT; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left
	local bg = Instance.new("Frame", container)
	bg.Size = UDim2.new(1, 0, 0, 8); bg.Position = UDim2.new(0, 0, 0, 20); bg.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
	Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
	local fill = Instance.new("Frame", bg); fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = warnaFill
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	local txt = Instance.new("TextLabel", bg); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
	txt.Text = "0/0"; txt.Font = Enum.Font.GothamBold; txt.TextColor3 = Color3.fromRGB(255, 255, 255); txt.TextSize = 8; local txtStroke = Instance.new("UIStroke", txt)
	txtStroke.Thickness = 1; txtStroke.Transparency = 0.5
	return lbl, fill, txt 
end
local fLabel, fBarFill, fBarTxt = BuatJobBar("Mancing", 10, "??", Color3.fromRGB(52, 152, 219), jobFrame)
local mLabel, mBarFill, mBarTxt = BuatJobBar("Nambang", 58, "??", Color3.fromRGB(149, 165, 166), jobFrame)
local cLabel, cBarFill, cBarTxt = BuatJobBar("Hunting", 106, "??", Color3.fromRGB(231, 76, 60), jobFrame)

-- SETTINGS FRAME
local setFrame = Instance.new("Frame", hudGui)
setFrame.Size = UDim2.new(0, 190, 0, 150); setFrame.Position = UDim2.new(1, -55, 0, -250); setFrame.AnchorPoint = Vector2.new(1, 0); setFrame.BackgroundColor3 = COLOR_BG
Instance.new("UICorner", setFrame).CornerRadius = UDim.new(0, 10); Instance.new("UIStroke", setFrame).Color = COLOR_STROKE; Instance.new("UIStroke", setFrame).Thickness = 2
local setTitle = Instance.new("TextLabel", setFrame)
setTitle.Size = UDim2.new(1, 0, 0, 30); setTitle.BackgroundTransparency = 1; setTitle.Text = "?? PENGATURAN"; setTitle.Font = Enum.Font.GothamBlack; setTitle.TextColor3 = COLOR_TEXT
setTitle.TextSize = 12
local function BuatToggle(nama, labelTxt, posY, defaultState, callback)
	local container = Instance.new("Frame", setFrame); container.Size = UDim2.new(1, -20, 0, 30)
	container.Position = UDim2.new(0, 10, 0, posY); container.BackgroundTransparency = 1
	local lbl = Instance.new("TextLabel", container); lbl.Size = UDim2.new(0.7, 0, 1, 0)
	lbl.BackgroundTransparency = 1; lbl.Text = labelTxt; lbl.Font = Enum.Font.GothamSemibold; lbl.TextColor3 = COLOR_TEXT; lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	local toggleBtn = Instance.new("TextButton", container); toggleBtn.Size = UDim2.new(0, 40, 0, 20); toggleBtn.Position = UDim2.new(1, -40, 0.5, -10)
	toggleBtn.Text = ""; toggleBtn.BackgroundColor3 = defaultState and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(200, 200, 200)
	Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
	local circle = Instance.new("Frame", toggleBtn); circle.Size = UDim2.new(0, 16, 0, 16)
	circle.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8); circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
	local isON = defaultState
	toggleBtn.MouseButton1Click:Connect(function()
		isON = not isON
		TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = isON and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(200, 200, 200)}):Play()
		TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = isON and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
		callback(isON)
	end)
end
BuatToggle("ShadowToggle", "Bayangan (Shadows)", 35, true, function(state) game.Lighting.GlobalShadows = state end)
BuatToggle("NametagToggle", "Tampilkan Nametag", 75, true, function(state) _G.HideNametags = not state for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("Head") then local tag = p.Character.Head:FindFirstChild("PlayerNametag") if tag then tag.Enabled = state end end end end)
BuatToggle("HotbarToggle", "Tampilkan Hotbar", 115, true, function(state) local hotbar = playerGui:FindFirstChild("CustomInventoryGui") if hotbar and hotbar:FindFirstChild("HotbarFrame") then hotbar.HotbarFrame.Visible = state end end)

-- ==========================================
-- 3. UPDATE DATA UI (ANGKA BERJALAN)
-- ==========================================
local lstats = player:WaitForChild("leaderstats")
local jstats = player:WaitForChild("JobStats")
local function FormatNumber(n) local formatted = tostring(n) while true do formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then break end end return formatted end

local currentDisplayKoin = Instance.new("IntValue")
currentDisplayKoin.Value = lstats.Koin.Value
koinTxt.Text = FormatNumber(currentDisplayKoin.Value)

currentDisplayKoin.Changed:Connect(function(val) koinTxt.Text = FormatNumber(val) end)
lstats.Koin.Changed:Connect(function(newVal) TweenService:Create(currentDisplayKoin, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Value = newVal}):Play() end)

local function UpdateBar(expAttribute, currentLevel, fillObj, txtObj, multiplier)
	local totalExp = player:GetAttribute(expAttribute) or 0
	multiplier = multiplier or 100
	local expForCurrent = ((currentLevel - 1) ^ 2) * multiplier
	local expForNext = (currentLevel ^ 2) * multiplier
	local progress = totalExp - expForCurrent
	local needed = expForNext - expForCurrent
	if txtObj then txtObj.Text = math.floor(progress) .. " / " .. needed .. " EXP" end
	TweenService:Create(fillObj, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(math.clamp(progress / needed, 0, 1), 0, 1, 0)}):Play()
end

local lastGlobalExp = player:GetAttribute("GlobalEXP") or 0
local function UpdateUI()
	levelTxt.Text = "Lv. " .. lstats.Level.Value
	fLabel.Text = "?? Mancing: Lv." .. jstats.Fishing.Value; mLabel.Text = "?? Nambang: Lv." .. jstats.Mining.Value; cLabel.Text = "?? Hunting: Lv." .. jstats.Combat.Value

	local currentExp = player:GetAttribute("GlobalEXP") or 0
	if currentExp > lastGlobalExp then FlashEXPGlow() end
	lastGlobalExp = currentExp

	UpdateBar("GlobalEXP", lstats.Level.Value, lvlFill, nil, 250)
	UpdateBar("FishingEXP", jstats.Fishing.Value, fBarFill, fBarTxt, 100); UpdateBar("MiningEXP", jstats.Mining.Value, mBarFill, mBarTxt, 100); UpdateBar("CombatEXP", jstats.Combat.Value, cBarFill, cBarTxt, 100)
end
UpdateUI(); lstats.Level.Changed:Connect(UpdateUI); jstats.Fishing.Changed:Connect(UpdateUI); jstats.Mining.Changed:Connect(UpdateUI); jstats.Combat.Changed:Connect(UpdateUI)
player:GetAttributeChangedSignal("GlobalEXP"):Connect(UpdateUI); player:GetAttributeChangedSignal("FishingEXP"):Connect(UpdateUI)
player:GetAttributeChangedSignal("MiningEXP"):Connect(UpdateUI); player:GetAttributeChangedSignal("CombatEXP"):Connect(UpdateUI)

-- ==========================================
-- 4. LOGIKA SLIDE MENU & KLIK
-- ==========================================
local isMenuExpanded = true
local isMenuOpen = false
local isSetOpen = false

toggleMenuBtn.MouseButton1Click:Connect(function()
	isMenuExpanded = not isMenuExpanded
	toggleMenuBtn.Text = isMenuExpanded and "X" or "?"

	local targetWidth = isMenuExpanded and 260 or 0
	TweenService:Create(actionContainer, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, targetWidth, 1, 0)}):Play()

	-- Tutup otomatis dropdown jika menu dilipat
	if not isMenuExpanded then
		if isFriendOpen then isFriendOpen = false; TweenService:Create(friendFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, -210, 0, -250)}):Play() end
		if isMenuOpen then isMenuOpen = false; TweenService:Create(jobFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, -180, 0, -250)}):Play() end
		if isSetOpen then isSetOpen = false; TweenService:Create(setFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, -55, 0, -250)}):Play() end
	end

	TweenService:Create(toggleMenuBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 28, 1, -4)}):Play()
	task.delay(0.1, function() TweenService:Create(toggleMenuBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 32, 1, 0)}):Play() end)
end)

menuBtn.MouseButton1Click:Connect(function()
	isMenuOpen = not isMenuOpen
	TweenService:Create(menuBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 28, 1, -4)}):Play(); task.delay(0.1, function() TweenService:Create(menuBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 32, 1, 0)}):Play() end)
	TweenService:Create(jobFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = isMenuOpen and UDim2.new(1, -180, 0, 50) or UDim2.new(1, -180, 0, -250)}):Play()
end)

settingBtn.MouseButton1Click:Connect(function()
	isSetOpen = not isSetOpen
	TweenService:Create(settingBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 28, 1, -4)}):Play()
	task.delay(0.1, function() TweenService:Create(settingBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 32, 1, 0)}):Play() end)
	TweenService:Create(setFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = isSetOpen and UDim2.new(1, -55, 0, 50) or UDim2.new(1, -55, 0, -250)}):Play()
end)

local function playClickAnim(btn, eventName)
	btn.MouseButton1Click:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 28, 1, -4)}):Play(); task.delay(0.1, function() TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 32, 1, 0)}):Play() end)
		local toggleEvent = playerGui:FindFirstChild(eventName)
		if not toggleEvent then toggleEvent = Instance.new("BindableEvent"); toggleEvent.Name = eventName; toggleEvent.Parent = playerGui end
		toggleEvent:Fire()
	end)
end
playClickAnim(achieveBtn, "ToggleAchievementUI")
playClickAnim(invBtn, "ToggleInventoryUI")
playClickAnim(danceBtn, "ToggleDanceUI")

-- ==========================================
-- 5. CUSTOM LEADERBOARD PREMIUM (TAB)
-- ==========================================
local lbGui = Instance.new("ScreenGui")
lbGui.Name = "CustomLeaderboardGui"; lbGui.ResetOnSpawn = false; lbGui.IgnoreGuiInset = true; lbGui.Parent = playerGui
local lbContainer = Instance.new("Frame", lbGui); lbContainer.Name = "LBContainer"
lbContainer.Size = UDim2.new(0, 300, 0, 350); lbContainer.AnchorPoint = Vector2.new(1, 0); lbContainer.BackgroundColor3 = COLOR_BG; Instance.new("UICorner", lbContainer).CornerRadius = UDim.new(0, 10)
local lbStroke = Instance.new("UIStroke", lbContainer); lbStroke.Color = COLOR_STROKE; lbStroke.Thickness = 2
local posLbBuka = UDim2.new(1, -15, 0, 50)
local posLbTutup = UDim2.new(1, 350, 0, 50); lbContainer.Position = posLbTutup; local isLbOpen = false
local lbTitle = Instance.new("TextLabel", lbContainer)
lbTitle.Size = UDim2.new(1, 0, 0, 40); lbTitle.BackgroundTransparency = 1; lbTitle.Text = "?? LEADERBOARD"; lbTitle.Font = Enum.Font.GothamBlack; lbTitle.TextColor3 = COLOR_TEXT
lbTitle.TextSize = 16
local lbScrolling = Instance.new("ScrollingFrame", lbContainer); lbScrolling.Size = UDim2.new(1, -10, 1, -50); lbScrolling.Position = UDim2.new(0, 5, 0, 45)
lbScrolling.BackgroundTransparency = 1; lbScrolling.CanvasSize = UDim2.new(0, 0, 0, 0); lbScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y; lbScrolling.ScrollBarThickness = 3
local lbList = Instance.new("UIListLayout", lbScrolling)
lbList.Padding = UDim.new(0, 6); lbList.SortOrder = Enum.SortOrder.LayoutOrder

local function BuatPlayerBar(p, koin, level, rank)
	local bar = Instance.new("Frame"); bar.Name = p.Name
	bar.Size = UDim2.new(1, -6, 0, 35); bar.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	if p == player then bar.BackgroundColor3 = Color3.fromRGB(255, 250, 230)
		bar.LayoutOrder = -100 else bar.LayoutOrder = rank end; Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 6)

	bar.MouseEnter:Connect(function() if p ~= player then TweenService:Create(bar, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(235, 235, 235)}):Play() end end)
	bar.MouseLeave:Connect(function() if p ~= player then TweenService:Create(bar, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(245, 245, 245)}):Play() end end)

	local rankStr = "#" .. rank
	local rankColor = COLOR_TEXT
	if rank == 1 then rankStr = "?? 1"
		rankColor = Color3.fromRGB(241, 196, 15)
	elseif rank == 2 then rankStr = "?? 2"
		rankColor = Color3.fromRGB(189, 195, 199)
	elseif rank == 3 then rankStr = "?? 3"
		rankColor = Color3.fromRGB(205, 127, 50) end

	local rankLbl = Instance.new("TextLabel", bar); rankLbl.Size = UDim2.new(0.15, 0, 1, 0)
	rankLbl.Position = UDim2.new(0, 5, 0, 0); rankLbl.BackgroundTransparency = 1; rankLbl.Text = rankStr; rankLbl.Font = Enum.Font.GothamBlack; rankLbl.TextColor3 = rankColor
	rankLbl.TextSize = 13; rankLbl.TextXAlignment = Enum.TextXAlignment.Left
	local nameLbl = Instance.new("TextLabel", bar); nameLbl.Size = UDim2.new(0.4, -5, 1, 0)
	nameLbl.Position = UDim2.new(0.15, 5, 0, 0); nameLbl.BackgroundTransparency = 1; nameLbl.Text = p.DisplayName; nameLbl.Font = Enum.Font.GothamSemibold; nameLbl.TextColor3 = COLOR_TEXT
	nameLbl.TextSize = 12; nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
	local lvlLbl = Instance.new("TextLabel", bar); lvlLbl.Size = UDim2.new(0.2, 0, 1, 0)
	lvlLbl.Position = UDim2.new(0.55, 0, 0, 0); lvlLbl.BackgroundTransparency = 1; lvlLbl.Text = "? " .. level; lvlLbl.Font = Enum.Font.GothamBold
	lvlLbl.TextColor3 = COLOR_GOLD; lvlLbl.TextSize = 11; lvlLbl.TextXAlignment = Enum.TextXAlignment.Left
	local koinLbl = Instance.new("TextLabel", bar); koinLbl.Size = UDim2.new(0.25, -5, 1, 0)
	koinLbl.Position = UDim2.new(0.75, 0, 0, 0); koinLbl.BackgroundTransparency = 1; koinLbl.Text = FormatNumber(koin); koinLbl.Font = Enum.Font.GothamBold; koinLbl.TextColor3 = Color3.fromRGB(39, 174, 96)
	koinLbl.TextSize = 11; koinLbl.TextXAlignment = Enum.TextXAlignment.Right
	return bar
end

local function UpdateLeaderboard()
	for _, child in pairs(lbScrolling:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
	local playerList = {}
	for _, p in pairs(Players:GetPlayers()) do
		local ls = p:FindFirstChild("leaderstats")
		local koin = ls and ls:FindFirstChild("Koin") and ls.Koin.Value or 0
		local level = ls and ls:FindFirstChild("Level") and ls.Level.Value or 1
		table.insert(playerList, {Player = p, Koin = koin, Level = level})
	end
	table.sort(playerList, function(a, b) return a.Koin > b.Koin end)
	for i = 1, math.min(#playerList, 15) do BuatPlayerBar(playerList[i].Player, playerList[i].Koin, playerList[i].Level, i).Parent = lbScrolling end
end

UpdateLeaderboard()
Players.PlayerAdded:Connect(UpdateLeaderboard); Players.PlayerRemoving:Connect(UpdateLeaderboard); lstats.Koin.Changed:Connect(UpdateLeaderboard); lstats.Level.Changed:Connect(UpdateLeaderboard)
task.spawn(function() while task.wait(3) do UpdateLeaderboard() end end)

UserInputService.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end
	if input.KeyCode == Enum.KeyCode.Tab then
		isLbOpen = not isLbOpen
		TweenService:Create(lbContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = isLbOpen and posLbBuka or posLbTutup}):Play()
	end
end)

-- TELEPORT KE LOBBY
local confirmGui = Instance.new("ScreenGui")
confirmGui.Name = "ConfirmTeleportGui"; confirmGui.Parent = playerGui
local countdownLabel = Instance.new("TextLabel"); countdownLabel.Size = UDim2.new(0, 200, 0, 200)
countdownLabel.Position = UDim2.new(0.5, -100, 0.5, -100); countdownLabel.BackgroundTransparency = 1; countdownLabel.Text = ""; countdownLabel.Font = Enum.Font.GothamBlack; countdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
countdownLabel.TextSize = 100; countdownLabel.Visible = false; countdownLabel.Parent = confirmGui
local confirmFrame = Instance.new("Frame"); confirmFrame.Size = UDim2.new(0, 320, 0, 150)
confirmFrame.Position = UDim2.new(0.5, -160, 0.5, -75); confirmFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255); confirmFrame.Visible = false; confirmFrame.Parent = confirmGui
Instance.new("UICorner", confirmFrame).CornerRadius = UDim.new(0, 15); local cStroke = Instance.new("UIStroke", confirmFrame); cStroke.Color = Color3.fromRGB(200, 200, 200)
cStroke.Thickness = 3
local confirmText = Instance.new("TextLabel"); confirmText.Size = UDim2.new(1, 0, 0.5, 0); confirmText.BackgroundTransparency = 1
confirmText.Text = "Kembali ke Lobby Utama?"; confirmText.Font = Enum.Font.GothamBold; confirmText.TextColor3 = Color3.fromRGB(60, 60, 60); confirmText.TextSize = 18
confirmText.Parent = confirmFrame
local yesBtn = Instance.new("TextButton"); yesBtn.Size = UDim2.new(0, 110, 0, 40); yesBtn.Position = UDim2.new(0, 30, 0.6, 0)
yesBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113); yesBtn.Text = "YES"; yesBtn.Font = Enum.Font.GothamBold; yesBtn.TextColor3 = COLOR_BG; yesBtn.Parent = confirmFrame
Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 8)
local noBtn = Instance.new("TextButton"); noBtn.Size = UDim2.new(0, 110, 0, 40); noBtn.Position = UDim2.new(1, -140, 0.6, 0)
noBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60); noBtn.Text = "NO"; noBtn.Font = Enum.Font.GothamBold; noBtn.TextColor3 = COLOR_BG; noBtn.Parent = confirmFrame
Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 8)

tpBtn.MouseButton1Click:Connect(function() 
	confirmFrame.Visible = true 
	TweenService:Create(tpBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 28, 1, -4)}):Play(); task.delay(0.1, function() TweenService:Create(tpBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 32, 1, 0)}):Play() end)
end)
noBtn.MouseButton1Click:Connect(function() confirmFrame.Visible = false end)
yesBtn.MouseButton1Click:Connect(function()
	confirmFrame.Visible = false; countdownLabel.Visible = true
	for i = 3, 1, -1 do countdownLabel.Text = i; task.wait(1) end
	countdownLabel.Visible = false; local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then local spawnLoc = workspace:FindFirstChild("SpawnLocation") if spawnLoc then char:PivotTo(spawnLoc.CFrame + Vector3.new(0, 5, 0)) else char:PivotTo(CFrame.new(0, 10, 0)) end end
end)