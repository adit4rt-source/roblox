-- ================================================================
--  DanceClientManager (LocalScript) - FAVORITES & LOCK-ON EDITION
-- ================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local SyncingFolder = ReplicatedStorage:WaitForChild("Syncing")
local SyncEvent = SyncingFolder:WaitForChild("Sync")
local UnSyncEvent = SyncingFolder:WaitForChild("UnSync")

if playerGui:FindFirstChild("IndoVerseDanceGui") then playerGui.IndoVerseDanceGui:Destroy() end

local animationAssets = ReplicatedStorage:WaitForChild("AnimationAssets")
local DanceModule = require(animationAssets:WaitForChild("DanceModule"))

-- SISTEM FAVORIT DANCE
local favoriteDances = {}

local function LoadFavorites()
	local favStr = player:GetAttribute("DanceFavorites") or ""
	favoriteDances = {}
	if favStr ~= "" then
		for id in string.gmatch(favStr, "([^,]+)") do
			favoriteDances[id] = true
		end
	end
end

local function SaveFavorites()
	local favList = {}
	for id, _ in pairs(favoriteDances) do
		table.insert(favList, id)
	end
	local favStr = table.concat(favList, ",")
	player:SetAttribute("DanceFavorites", favStr)
end

-- Load awal
LoadFavorites()
player:GetAttributeChangedSignal("DanceFavorites"):Connect(LoadFavorites)

local COLOR_BG = Color3.fromRGB(20, 20, 28)
local COLOR_STROKE = Color3.fromRGB(44, 44, 60)
local COLOR_TEXT_MAIN = Color3.fromRGB(245, 245, 250)
local COLOR_BTN_BG = Color3.fromRGB(30, 30, 42)
local COLOR_BTN_HOVER = Color3.fromRGB(38, 38, 54)

local gui = Instance.new("ScreenGui")
gui.Name = "IndoVerseDanceGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- ==========================================
-- SISTEM CACHE & PRELOAD 
-- ==========================================
local trackCache = {}

player.CharacterAdded:Connect(function() trackCache = {} end)

task.spawn(function()
	local preloadList = {}
	for _, data in ipairs(DanceModule.Dances) do
		local a = Instance.new("Animation"); a.AnimationId = "rbxassetid://" .. data[2]; table.insert(preloadList, a)
	end
	for _, data in ipairs(DanceModule.Emotes) do
		local a = Instance.new("Animation"); a.AnimationId = "rbxassetid://" .. data[2]; table.insert(preloadList, a)
	end
	ContentProvider:PreloadAsync(preloadList)
end)

-- ==========================================
-- TOMBOL STOP MINIMALIS
-- ==========================================
local floatingStop = Instance.new("TextButton")
floatingStop.Name = "FloatingStop"
floatingStop.Size = UDim2.new(0, 120, 0, 28)
floatingStop.Position = UDim2.new(0.5, -60, 1, 50) 
floatingStop.BackgroundColor3 = COLOR_BG
floatingStop.Text = "Stop Animasi"
floatingStop.Font = Enum.Font.Gotham 
floatingStop.TextColor3 = COLOR_TEXT_MAIN 
floatingStop.TextStrokeTransparency = 1 
floatingStop.TextSize = 11
floatingStop.Parent = gui

Instance.new("UICorner", floatingStop).CornerRadius = UDim.new(0, 8)
local stopStroke = Instance.new("UIStroke", floatingStop)
stopStroke.Color = COLOR_STROKE
stopStroke.Thickness = 1.5

-- ==========================================
-- PANEL MENU DANCE
-- ==========================================
local mainPanel = Instance.new("Frame")
mainPanel.Name = "MainPanel"
mainPanel.Size = UDim2.new(0, 200, 0, 320)
mainPanel.Position = UDim2.new(1, 350, 0, 50) 
mainPanel.AnchorPoint = Vector2.new(1, 0)
mainPanel.BackgroundColor3 = COLOR_BG
mainPanel.Parent = gui
Instance.new("UICorner", mainPanel).CornerRadius = UDim.new(0, 10)
local panelStroke = Instance.new("UIStroke", mainPanel)
panelStroke.Color = COLOR_STROKE
panelStroke.Thickness = 2

local titleLbl = Instance.new("TextLabel", mainPanel)
titleLbl.Size = UDim2.new(1, 0, 0, 35)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "✨ DANCE MENU ✨"
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextColor3 = COLOR_TEXT_MAIN
titleLbl.TextSize = 12

local closeBtn = Instance.new("TextButton", mainPanel)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 12
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local scrollFrame = Instance.new("ScrollingFrame", mainPanel)
scrollFrame.Size = UDim2.new(1, -15, 1, -80)
scrollFrame.Position = UDim2.new(0, 8, 0, 68)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 3
local listLayout = Instance.new("UIGridLayout", scrollFrame)
listLayout.CellSize = UDim2.new(0.5, -4, 0, 30)
listLayout.CellPadding = UDim2.new(0, 6, 0, 6) 

local activeTab = "DANCE"
local allCells = {}

-- TAB CONTAINER
local tabContainer = Instance.new("Frame", mainPanel)
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, -16, 0, 26)
tabContainer.Position = UDim2.new(0, 8, 0, 35)
tabContainer.BackgroundTransparency = 1

local tabLayout = Instance.new("UIListLayout", tabContainer)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 6)

local tabDance = Instance.new("TextButton", tabContainer)
tabDance.Name = "TabDance"
tabDance.Size = UDim2.new(0.5, -3, 1, 0)
tabDance.BackgroundColor3 = COLOR_BTN_BG
tabDance.Text = "DANCE"
tabDance.Font = Enum.Font.GothamBold
tabDance.TextColor3 = COLOR_TEXT_MAIN
tabDance.TextSize = 10
Instance.new("UICorner", tabDance).CornerRadius = UDim.new(0, 5)
local tabDanceStroke = Instance.new("UIStroke", tabDance)
tabDanceStroke.Color = COLOR_STROKE
tabDanceStroke.Thickness = 1

local tabFav = Instance.new("TextButton", tabContainer)
tabFav.Name = "TabFav"
tabFav.Size = UDim2.new(0.5, -3, 1, 0)
tabFav.BackgroundColor3 = COLOR_BG
tabFav.Text = "FAVORIT"
tabFav.Font = Enum.Font.GothamBold
tabFav.TextColor3 = Color3.fromRGB(150, 150, 165)
tabFav.TextSize = 10
Instance.new("UICorner", tabFav).CornerRadius = UDim.new(0, 5)
local tabFavStroke = Instance.new("UIStroke", tabFav)
tabFavStroke.Color = COLOR_STROKE
tabFavStroke.Thickness = 1

local function UpdateTabVisibility()
	if activeTab == "DANCE" then
		tabDance.BackgroundColor3 = COLOR_BTN_BG
		tabDance.TextColor3 = COLOR_TEXT_MAIN
		
		tabFav.BackgroundColor3 = COLOR_BG
		tabFav.TextColor3 = Color3.fromRGB(150, 150, 165)
	else
		tabDance.BackgroundColor3 = COLOR_BG
		tabDance.TextColor3 = Color3.fromRGB(150, 150, 165)
		
		tabFav.BackgroundColor3 = COLOR_BTN_BG
		tabFav.TextColor3 = COLOR_GOLD
	end

	for _, item in ipairs(allCells) do
		local isFav = favoriteDances[tostring(item.AnimID)]
		if activeTab == "DANCE" then
			item.Cell.Visible = true
			if isFav then
				item.Cell.LayoutOrder = -1000 + item.Index
			else
				item.Cell.LayoutOrder = item.Index
			end
		else
			if isFav then
				item.Cell.Visible = true
				item.Cell.LayoutOrder = item.Index
			else
				item.Cell.Visible = false
			end
		end
	end
end

tabDance.MouseButton1Click:Connect(function()
	activeTab = "DANCE"
	UpdateTabVisibility()
end)

tabFav.MouseButton1Click:Connect(function()
	activeTab = "FAV"
	UpdateTabVisibility()
end) 

-- ==========================================
-- SISTEM ANIMASI & SINKRONISASI 100% AKURAT
-- ==========================================
local currentTrack = nil
local syncConnection = nil
local leaveConnection = nil
local renderSyncConnection = nil
local currentSyncTarget = nil

local function ShowStopButton(show)
	local targetY = show and UDim2.new(0.5, -60, 1, -130) or UDim2.new(0.5, -60, 1, 50)
	TweenService:Create(floatingStop, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetY}):Play()
end

local function StopDance()
	if currentTrack then currentTrack:Stop(0.2); currentTrack = nil end

	local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
	if humanoid then
		local animator = humanoid:FindFirstChild("Animator")
		if animator then 
			for _, t in ipairs(animator:GetPlayingAnimationTracks()) do 
				if t.Priority.Value >= Enum.AnimationPriority.Action.Value then t:Stop(0.2) end 
			end 
		end
	end

	ShowStopButton(false)
	floatingStop.Text = "Stop Animasi"
	currentSyncTarget = nil

	if syncConnection then syncConnection:Disconnect(); syncConnection = nil end
	if leaveConnection then leaveConnection:Disconnect(); leaveConnection = nil end
	if renderSyncConnection then renderSyncConnection:Disconnect(); renderSyncConnection = nil end

	UnSyncEvent:FireServer()
	if player.Character then player.Character:SetAttribute("CurrentDanceID", nil) end
end

floatingStop.MouseButton1Click:Connect(StopDance)

-- FUNGSI CERDAS MENYAMAKAN GERAKAN & MENCEGAH DELAY (FRAME-BY-FRAME)
local function ApplySync(targetChar)
	local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
	if not humanoid then return end
	local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)

	local danceId = targetChar:GetAttribute("CurrentDanceID")

	if currentTrack then currentTrack:Stop(0.2) end
	if renderSyncConnection then renderSyncConnection:Disconnect(); renderSyncConnection = nil end

	if danceId and danceId ~= "" then
		if not trackCache[danceId] then
			local a = Instance.new("Animation")
			a.AnimationId = "rbxassetid://" .. danceId
			a.Parent = humanoid
			trackCache[danceId] = animator:LoadAnimation(a)
		end

		currentTrack = trackCache[danceId]
		currentTrack.Looped = true
		currentTrack:Play(0.2)

		SyncEvent:FireServer(danceId)

		-- LOOP SINKRONISASI BRUTAL (AKURAT 1 MILIDETIK)
		renderSyncConnection = RunService.Heartbeat:Connect(function()
			if not currentTrack or not currentTrack.IsPlaying then return end

			local tgtHum = targetChar:FindFirstChild("Humanoid")
			local tgtAnimator = tgtHum and tgtHum:FindFirstChild("Animator")
			if tgtAnimator then
				for _, track in ipairs(tgtAnimator:GetPlayingAnimationTracks()) do
					-- Cari tarian yang sama di tubuh target
					if track.Animation and track.Animation.AnimationId == currentTrack.Animation.AnimationId then
						-- Paksa sama posisinya jika beda lebih dari 0.05 detik
						if math.abs(currentTrack.TimePosition - track.TimePosition) > 0.05 then
							currentTrack.TimePosition = track.TimePosition
						end
						break
					end
				end
			end
		end)

	else
		-- Tetap lock-on ke target, stop tari lokal saja
		if currentTrack then currentTrack:Stop(0.2); currentTrack = nil end
		UnSyncEvent:FireServer()
		if player.Character then player.Character:SetAttribute("CurrentDanceID", nil) end

		floatingStop.Text = "Stop Mengikuti"
		ShowStopButton(true)
		StarterGui:SetCore("SendNotification", {Title = "Menunggu", Text = "Menunggu " .. targetChar.Name .. " mulai berjoget kembali...", Duration = 3})
	end
end

-- JEMBATAN DARI CONTEXT MENU KE MANAGER INI
local reqSyncEvent = playerGui:FindFirstChild("ReqSyncDance")
if not reqSyncEvent then 
	reqSyncEvent = Instance.new("BindableEvent")
	reqSyncEvent.Name = "ReqSyncDance"
	reqSyncEvent.Parent = playerGui 
end

reqSyncEvent.Event:Connect(function(targetPlayer)
	local tgtChar = targetPlayer.Character
	if not tgtChar then return end

	local initialDanceId = tgtChar:GetAttribute("CurrentDanceID")
	if not initialDanceId or initialDanceId == "" then
		StarterGui:SetCore("SendNotification", {Title = "Gagal", Text = targetPlayer.Name .. " tidak sedang berjoget!", Duration = 3})
		return
	end

	currentSyncTarget = targetPlayer
	floatingStop.Text = "Stop Mengikuti"
	ShowStopButton(true)

	ApplySync(tgtChar)

	if syncConnection then syncConnection:Disconnect() end
	syncConnection = tgtChar:GetAttributeChangedSignal("CurrentDanceID"):Connect(function()
		if currentSyncTarget == targetPlayer then ApplySync(tgtChar) end
	end)

	if leaveConnection then leaveConnection:Disconnect() end
	leaveConnection = Players.PlayerRemoving:Connect(function(removedPlayer)
		if removedPlayer == targetPlayer then
			StopDance()
		end
	end)
end)

local function CreateDanceButton(nama, animID, index)
	local cell = Instance.new("Frame", scrollFrame)
	cell.BackgroundColor3 = COLOR_BTN_BG
	cell.Size = UDim2.new(0.5, -4, 0, 30)
	Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 5)
	
	local stroke = Instance.new("UIStroke", cell)
	stroke.Color = COLOR_STROKE
	stroke.Thickness = 1

	local btn = Instance.new("TextButton", cell)
	btn.Size = UDim2.new(1, -26, 1, 0)
	btn.Position = UDim2.new(0, 4, 0, 0)
	btn.BackgroundTransparency = 1
	btn.Text = nama
	btn.Font = Enum.Font.GothamMedium
	btn.TextColor3 = COLOR_TEXT_MAIN
	btn.TextSize = 9
	btn.TextWrapped = true

	local star = Instance.new("TextButton", cell)
	star.Size = UDim2.new(0, 20, 0, 20)
	star.Position = UDim2.new(1, -22, 0.5, -10)
	star.BackgroundTransparency = 1
	star.Font = Enum.Font.GothamBold
	star.TextSize = 12

	local function UpdateFavoriteUI()
		local isFav = favoriteDances[tostring(animID)]
		if isFav then
			star.Text = "★"
			star.TextColor3 = Color3.fromRGB(241, 196, 15) -- Gold
			cell.LayoutOrder = -1000 + index -- Float to top
		else
			star.Text = "☆"
			star.TextColor3 = Color3.fromRGB(150, 150, 165)
			cell.LayoutOrder = index
		end
	end

	UpdateFavoriteUI()
	table.insert(allCells, {Cell = cell, AnimID = animID, Index = index})

	star.MouseButton1Click:Connect(function()
		local id = tostring(animID)
		favoriteDances[id] = not favoriteDances[id]
		SaveFavorites()
		UpdateFavoriteUI()
		UpdateTabVisibility()
	end)

	btn.MouseEnter:Connect(function()
		TweenService:Create(cell, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_BTN_HOVER}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(cell, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_BTN_BG}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		local char = player.Character
		if not char then return end
		local humanoid = char:FindFirstChild("Humanoid")
		if not humanoid then return end
		local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)

		if currentTrack then currentTrack:Stop(0.2) end
		if syncConnection then syncConnection:Disconnect(); syncConnection = nil end
		if leaveConnection then leaveConnection:Disconnect(); leaveConnection = nil end
		if renderSyncConnection then renderSyncConnection:Disconnect(); renderSyncConnection = nil end

		currentSyncTarget = nil
		floatingStop.Text = "Stop Animasi"

		if not trackCache[animID] then
			local anim = Instance.new("Animation")
			anim.AnimationId = "rbxassetid://" .. animID
			anim.Parent = humanoid
			trackCache[animID] = animator:LoadAnimation(anim)
		end

		currentTrack = trackCache[animID]
		currentTrack.Looped = true
		currentTrack:Play(0.2) 

		ShowStopButton(true)
		char:SetAttribute("CurrentDanceID", tostring(animID))
		SyncEvent:FireServer(animID)
	end)
end

-- Render Item
local itemIndex = 1
for _, data in ipairs(DanceModule.Dances) do 
	CreateDanceButton(data[1], data[2], itemIndex) 
	itemIndex += 1
end
for _, data in ipairs(DanceModule.Emotes) do 
	CreateDanceButton(data[1], data[2], itemIndex) 
	itemIndex += 1
end
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.ceil((#DanceModule.Dances + #DanceModule.Emotes) / 2) * 36)

-- ==========================================
-- JEMBATAN BUKA/TUTUP UI
-- ==========================================
local isBuka = false
local function TogglePanel()
	isBuka = not isBuka
	local targetPos = isBuka and UDim2.new(1, -95, 0, 50) or UDim2.new(1, 350, 0, 50)
	TweenService:Create(mainPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
end
closeBtn.MouseButton1Click:Connect(TogglePanel)

local toggleEvent = playerGui:FindFirstChild("ToggleDanceUI")
if not toggleEvent then 
	toggleEvent = Instance.new("BindableEvent")
	toggleEvent.Name = "ToggleDanceUI"
	toggleEvent.Parent = playerGui 
end
toggleEvent.Event:Connect(TogglePanel)