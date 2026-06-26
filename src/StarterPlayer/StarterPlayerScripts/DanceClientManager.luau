-- ================================================================
--  DanceClientManager (LocalScript) - ULTIMATE VERSION
--  Sistem Sync Cerdas: Anti-Delay, Auto-Update, & Stop Sync UI
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

local COLOR_BG = Color3.fromRGB(255, 255, 255)
local COLOR_STROKE = Color3.fromRGB(220, 220, 220)
local COLOR_TEXT_MAIN = Color3.fromRGB(60, 60, 60)
local COLOR_BLACK = Color3.fromRGB(0, 0, 0) 

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
floatingStop.TextColor3 = COLOR_BLACK 
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
titleLbl.Text = "?? DANCE & EMOTE"
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
scrollFrame.Size = UDim2.new(1, -15, 1, -50)
scrollFrame.Position = UDim2.new(0, 8, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 3
local listLayout = Instance.new("UIGridLayout", scrollFrame)
listLayout.CellSize = UDim2.new(0.5, -4, 0, 30)
listLayout.CellPadding = UDim2.new(0, 6, 0, 6) 

-- ==========================================
-- SISTEM ANIMASI & SINKRONISASI 100% AKURAT
-- ==========================================
local currentTrack = nil
local syncConnection = nil
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
		StopDance()
		StarterGui:SetCore("SendNotification", {Title = "Selesai", Text = targetChar.Name .. " berhenti berjoget.", Duration = 3})
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
	floatingStop.Text = "Stop Mengikuti" -- UBAH TEKS TOMBOL
	ShowStopButton(true)

	ApplySync(tgtChar)

	-- MONITORING OTOMATIS: Jika teman ganti gaya, kita ikuti seketika!
	if syncConnection then syncConnection:Disconnect() end
	syncConnection = tgtChar:GetAttributeChangedSignal("CurrentDanceID"):Connect(function()
		if currentSyncTarget == targetPlayer then ApplySync(tgtChar) end
	end)
end)

local function CreateDanceButton(nama, animID)
	local btn = Instance.new("TextButton", scrollFrame)
	btn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	btn.Text = nama
	btn.Font = Enum.Font.GothamMedium
	btn.TextColor3 = COLOR_TEXT_MAIN
	btn.TextSize = 9
	btn.TextWrapped = true
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

	btn.MouseButton1Click:Connect(function()
		local char = player.Character
		if not char then return end
		local humanoid = char:FindFirstChild("Humanoid")
		if not humanoid then return end
		local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)

		if currentTrack then currentTrack:Stop(0.2) end
		if syncConnection then syncConnection:Disconnect(); syncConnection = nil end
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
for _, data in ipairs(DanceModule.Dances) do CreateDanceButton(data[1], data[2]) end
for _, data in ipairs(DanceModule.Emotes) do CreateDanceButton(data[1], data[2]) end
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