-- ================================================================
--  Leaderboard (LocalScript) - NIGHTCLUB PREMIUM LEADERBOARD (TAB)
-- ================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local lstats = player:WaitForChild("leaderstats")

-- Premium Dark-Theme Color Palette
local COLOR_BG = Color3.fromRGB(20, 20, 28)
local COLOR_STROKE = Color3.fromRGB(44, 44, 60)
local COLOR_TEXT = Color3.fromRGB(245, 245, 250)
local COLOR_TEXT_DIM = Color3.fromRGB(150, 150, 165)
local COLOR_GOLD = Color3.fromRGB(241, 196, 15)

-- Clean up existing Leaderboard UI if it exists
if playerGui:FindFirstChild("CustomLeaderboardGui") then
	playerGui.CustomLeaderboardGui:Destroy()
end

-- Create UI elements
local lbGui = Instance.new("ScreenGui")
lbGui.Name = "CustomLeaderboardGui"
lbGui.ResetOnSpawn = false
lbGui.IgnoreGuiInset = true
lbGui.Parent = playerGui

local lbContainer = Instance.new("Frame", lbGui)
lbContainer.Name = "LBContainer"
lbContainer.Size = UDim2.new(0, 320, 0, 420)
lbContainer.AnchorPoint = Vector2.new(1, 0.5)
lbContainer.BackgroundColor3 = COLOR_BG

local lbCorner = Instance.new("UICorner", lbContainer)
lbCorner.CornerRadius = UDim.new(0, 12)

local lbStroke = Instance.new("UIStroke", lbContainer)
lbStroke.Color = COLOR_STROKE
lbStroke.Thickness = 2

-- Positions for sliding animation (right side entry)
local posLbBuka = UDim2.new(1, -20, 0.5, 0)
local posLbTutup = UDim2.new(1, 350, 0.5, 0)
lbContainer.Position = posLbTutup
local isLbOpen = false

-- Title
local lbTitle = Instance.new("TextLabel", lbContainer)
lbTitle.Size = UDim2.new(1, 0, 0, 45)
lbTitle.BackgroundTransparency = 1
lbTitle.Text = "✨ CLUB LEADERBOARD ✨"
lbTitle.Font = Enum.Font.GothamBlack
lbTitle.TextColor3 = COLOR_TEXT
lbTitle.TextSize = 16

-- Header Labels (Rank, Name, Level, Coins)
local headerBar = Instance.new("Frame", lbContainer)
headerBar.Size = UDim2.new(1, -20, 0, 20)
headerBar.Position = UDim2.new(0, 10, 0, 45)
headerBar.BackgroundTransparency = 1

local hRank = Instance.new("TextLabel", headerBar)
hRank.Size = UDim2.new(0.15, 0, 1, 0)
hRank.BackgroundTransparency = 1
hRank.Text = "Rank"
hRank.Font = Enum.Font.GothamBold
hRank.TextColor3 = COLOR_TEXT_DIM
hRank.TextSize = 10
hRank.TextXAlignment = Enum.TextXAlignment.Left

local hName = Instance.new("TextLabel", headerBar)
hName.Size = UDim2.new(0.4, 0, 1, 0)
hName.Position = UDim2.new(0.15, 5, 0, 0)
hName.BackgroundTransparency = 1
hName.Text = "Name"
hName.Font = Enum.Font.GothamBold
hName.TextColor3 = COLOR_TEXT_DIM
hName.TextSize = 10
hName.TextXAlignment = Enum.TextXAlignment.Left

local hLvl = Instance.new("TextLabel", headerBar)
hLvl.Size = UDim2.new(0.2, 0, 1, 0)
hLvl.Position = UDim2.new(0.55, 0, 0, 0)
hLvl.BackgroundTransparency = 1
hLvl.Text = "Level"
hLvl.Font = Enum.Font.GothamBold
hLvl.TextColor3 = COLOR_TEXT_DIM
hLvl.TextSize = 10
hLvl.TextXAlignment = Enum.TextXAlignment.Left

local hKoin = Instance.new("TextLabel", headerBar)
hKoin.Size = UDim2.new(0.25, 0, 1, 0)
hKoin.Position = UDim2.new(0.75, 0, 0, 0)
hKoin.BackgroundTransparency = 1
hKoin.Text = "Coins"
hKoin.Font = Enum.Font.GothamBold
hKoin.TextColor3 = COLOR_TEXT_DIM
hKoin.TextSize = 10
hKoin.TextXAlignment = Enum.TextXAlignment.Right

-- Scrolling Area
local lbScrolling = Instance.new("ScrollingFrame", lbContainer)
lbScrolling.Size = UDim2.new(1, -10, 1, -85)
lbScrolling.Position = UDim2.new(0, 5, 0, 75)
lbScrolling.BackgroundTransparency = 1
lbScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
lbScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
lbScrolling.ScrollBarThickness = 3
lbScrolling.ScrollBarImageColor3 = COLOR_STROKE

local lbList = Instance.new("UIListLayout", lbScrolling)
lbList.Padding = UDim.new(0, 6)
lbList.SortOrder = Enum.SortOrder.LayoutOrder

-- Format Helper
local function FormatNumber(n)
	local formatted = tostring(n)
	while true do
		local k
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then break end
	end
	return formatted
end

local function BuatPlayerBar(p, koin, level, rank)
	local bar = Instance.new("Frame")
	bar.Name = p.Name
	bar.Size = UDim2.new(1, -6, 0, 35)
	bar.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
	
	if p == player then
		bar.BackgroundColor3 = Color3.fromRGB(44, 44, 62)
		bar.LayoutOrder = -100
	else
		bar.LayoutOrder = rank
	end
	
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 6)
	local stroke = Instance.new("UIStroke", bar)
	stroke.Color = COLOR_STROKE
	stroke.Thickness = 1

	bar.MouseEnter:Connect(function()
		if p ~= player then
			TweenService:Create(bar, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(38, 38, 54)}):Play()
		end
	end)
	bar.MouseLeave:Connect(function()
		if p ~= player then
			TweenService:Create(bar, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 42)}):Play()
		end
	end)

	local rankStr = "#" .. rank
	local rankColor = COLOR_TEXT
	if rank == 1 then
		rankStr = "👑 1"
		rankColor = COLOR_GOLD
	elseif rank == 2 then
		rankStr = "🥈 2"
		rankColor = Color3.fromRGB(189, 195, 199)
	elseif rank == 3 then
		rankStr = "🥉 3"
		rankColor = Color3.fromRGB(205, 127, 50)
	end

	local rankLbl = Instance.new("TextLabel", bar)
	rankLbl.Size = UDim2.new(0.15, 0, 1, 0)
	rankLbl.Position = UDim2.new(0, 5, 0, 0)
	rankLbl.BackgroundTransparency = 1
	rankLbl.Text = rankStr
	rankLbl.Font = Enum.Font.GothamBlack
	rankLbl.TextColor3 = rankColor
	rankLbl.TextSize = 12
	rankLbl.TextXAlignment = Enum.TextXAlignment.Left

	local nameLbl = Instance.new("TextLabel", bar)
	nameLbl.Size = UDim2.new(0.4, -5, 1, 0)
	nameLbl.Position = UDim2.new(0.15, 5, 0, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = p.DisplayName
	nameLbl.Font = Enum.Font.GothamSemibold
	nameLbl.TextColor3 = COLOR_TEXT
	nameLbl.TextSize = 11
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

	local lvlLbl = Instance.new("TextLabel", bar)
	lvlLbl.Size = UDim2.new(0.2, 0, 1, 0)
	lvlLbl.Position = UDim2.new(0.55, 0, 0, 0)
	lvlLbl.BackgroundTransparency = 1
	lvlLbl.Text = "Lv. " .. level
	lvlLbl.Font = Enum.Font.GothamBold
	lvlLbl.TextColor3 = COLOR_GOLD
	lvlLbl.TextSize = 10
	lvlLbl.TextXAlignment = Enum.TextXAlignment.Left

	local koinLbl = Instance.new("TextLabel", bar)
	koinLbl.Size = UDim2.new(0.25, -5, 1, 0)
	koinLbl.Position = UDim2.new(0.75, 0, 0, 0)
	koinLbl.BackgroundTransparency = 1
	koinLbl.Text = FormatNumber(koin)
	koinLbl.Font = Enum.Font.GothamBold
	koinLbl.TextColor3 = Color3.fromRGB(46, 204, 113)
	koinLbl.TextSize = 11
	koinLbl.TextXAlignment = Enum.TextXAlignment.Right

	return bar
end

local function UpdateLeaderboard()
	for _, child in pairs(lbScrolling:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	local playerList = {}
	for _, p in pairs(Players:GetPlayers()) do
		local ls = p:FindFirstChild("leaderstats")
		local koin = ls and ls:FindFirstChild("Koin") and ls.Koin.Value or 0
		local level = ls and ls:FindFirstChild("Level") and ls.Level.Value or 1
		table.insert(playerList, {Player = p, Koin = koin, Level = level})
	end
	
	table.sort(playerList, function(a, b)
		return a.Koin > b.Koin
	end)
	
	for i = 1, math.min(#playerList, 15) do
		local bar = BuatPlayerBar(playerList[i].Player, playerList[i].Koin, playerList[i].Level, i)
		bar.Parent = lbScrolling
	end
end

local koinVal = lstats:WaitForChild("Koin")
local levelVal = lstats:WaitForChild("Level")

UpdateLeaderboard()
Players.PlayerAdded:Connect(UpdateLeaderboard)
Players.PlayerRemoving:Connect(UpdateLeaderboard)
koinVal.Changed:Connect(UpdateLeaderboard)
levelVal.Changed:Connect(UpdateLeaderboard)


-- Automatic periodic refresh
task.spawn(function()
	while task.wait(3) do
		UpdateLeaderboard()
	end
end)

-- Toggle leaderboard with Tab key
UserInputService.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end
	if input.KeyCode == Enum.KeyCode.Tab then
		isLbOpen = not isLbOpen
		local targetPosition = isLbOpen and posLbBuka or posLbTutup
		TweenService:Create(lbContainer, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = targetPosition
		}):Play()
	end
end)

print("[Client] Premium Leaderboard active. Toggle with TAB key.")
