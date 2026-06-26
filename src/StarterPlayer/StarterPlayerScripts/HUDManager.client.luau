-- ================================================================
--  HUDManager (LocalScript) - INDOVERSE PREMIUM DARK HUD
--  Hanya berisi tombol Dance dengan desain premium warna HITAM.
-- ================================================================

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Matikan default player list Roblox agar bersih dan tidak tumpang tindih
pcall(function() 
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) 
end)

-- Hapus HUD lama jika ada
if playerGui:FindFirstChild("IndoVerseHUD") then
	playerGui.IndoVerseHUD:Destroy()
end

-- Premium Dark-Theme Color Palette
local COLOR_BG = Color3.fromRGB(20, 20, 28)
local COLOR_STROKE = Color3.fromRGB(44, 44, 60)
local COLOR_HOVER = Color3.fromRGB(38, 38, 54)
local COLOR_TEXT = Color3.fromRGB(245, 245, 250)

local hudGui = Instance.new("ScreenGui")
hudGui.Name = "IndoVerseHUD"
hudGui.ResetOnSpawn = false
hudGui.IgnoreGuiInset = true
hudGui.Parent = playerGui

-- DANCE TOGGLE BUTTON
local danceBtn = Instance.new("TextButton", hudGui)
danceBtn.Name = "DanceBtn"
danceBtn.Size = UDim2.new(0, 44, 0, 44)
danceBtn.Position = UDim2.new(1, -64, 0, 20) -- Top-right corner
danceBtn.AnchorPoint = Vector2.new(1, 0)
danceBtn.BackgroundColor3 = COLOR_BG
danceBtn.Text = "🕺"
danceBtn.Font = Enum.Font.GothamBold
danceBtn.TextColor3 = COLOR_TEXT
danceBtn.TextSize = 20

Instance.new("UICorner", danceBtn).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", danceBtn)
stroke.Color = COLOR_STROKE
stroke.Thickness = 2

-- Hover & Click animations
danceBtn.MouseEnter:Connect(function()
	TweenService:Create(danceBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_HOVER}):Play()
end)

danceBtn.MouseLeave:Connect(function()
	TweenService:Create(danceBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_BG}):Play()
end)

danceBtn.MouseButton1Click:Connect(function()
	-- Click bounce animation
	local bounceInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local shrink = TweenService:Create(danceBtn, bounceInfo, {Size = UDim2.new(0, 38, 0, 38), Position = UDim2.new(1, -61, 0, 23)})
	local restore = TweenService:Create(danceBtn, bounceInfo, {Size = UDim2.new(0, 44, 0, 44), Position = UDim2.new(1, -64, 0, 20)})
	
	shrink:Play()
	shrink.Completed:Wait()
	restore:Play()

	local toggleEvent = playerGui:FindFirstChild("ToggleDanceUI")
	if not toggleEvent then
		toggleEvent = Instance.new("BindableEvent")
		toggleEvent.Name = "ToggleDanceUI"
		toggleEvent.Parent = playerGui
	end
	toggleEvent:Fire()
end)

-- MUSIC TOGGLE BUTTON
local musicBtn = Instance.new("TextButton", hudGui)
musicBtn.Name = "MusicBtn"
musicBtn.Size = UDim2.new(0, 44, 0, 44)
musicBtn.Position = UDim2.new(1, -118, 0, 20) -- Left of DanceBtn
musicBtn.AnchorPoint = Vector2.new(1, 0)
musicBtn.BackgroundColor3 = COLOR_BG
musicBtn.Text = "🎵"
musicBtn.Font = Enum.Font.GothamBold
musicBtn.TextColor3 = COLOR_TEXT
musicBtn.TextSize = 20

Instance.new("UICorner", musicBtn).CornerRadius = UDim.new(0, 10)
local mStroke = Instance.new("UIStroke", musicBtn)
mStroke.Color = COLOR_STROKE
mStroke.Thickness = 2

-- Hover & Click animations
musicBtn.MouseEnter:Connect(function()
	TweenService:Create(musicBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_HOVER}):Play()
end)

musicBtn.MouseLeave:Connect(function()
	TweenService:Create(musicBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_BG}):Play()
end)

musicBtn.MouseButton1Click:Connect(function()
	-- Click bounce animation
	local bounceInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local shrink = TweenService:Create(musicBtn, bounceInfo, {Size = UDim2.new(0, 38, 0, 38), Position = UDim2.new(1, -115, 0, 23)})
	local restore = TweenService:Create(musicBtn, bounceInfo, {Size = UDim2.new(0, 44, 0, 44), Position = UDim2.new(1, -118, 0, 20)})
	
	shrink:Play()
	shrink.Completed:Wait()
	restore:Play()

	local toggleEvent = playerGui:FindFirstChild("ToggleMusicUI")
	if not toggleEvent then
		toggleEvent = Instance.new("BindableEvent")
		toggleEvent.Name = "ToggleMusicUI"
		toggleEvent.Parent = playerGui
	end
	toggleEvent:Fire()
end)

print("[Client] Premium Dark HUD (Dance & Music buttons) successfully loaded!")
