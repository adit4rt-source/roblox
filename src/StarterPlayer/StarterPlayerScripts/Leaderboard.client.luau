-- ================================================================
--  Leaderboard (LocalScript) - NIGHTCLUB PREMIUM LEADERBOARD (TAB)
-- ================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Premium Dark-Theme Color Palette (Nightclub vibes)
local COLOR_BG = Color3.fromRGB(15, 15, 24) -- Deeper dark navy
local COLOR_STROKE = Color3.fromRGB(85, 0, 127) -- Neon purple stroke
local COLOR_TEXT = Color3.fromRGB(245, 245, 250)
local COLOR_TEXT_DIM = Color3.fromRGB(150, 150, 165)
local COLOR_GOLD = Color3.fromRGB(255, 215, 0)

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

-- Title with Neon Gradient
local lbTitle = Instance.new("TextLabel", lbContainer)
lbTitle.Size = UDim2.new(1, 0, 0, 45)
lbTitle.BackgroundTransparency = 1
lbTitle.Text = "✨ TOP SPENDER ✨"
lbTitle.Font = Enum.Font.GothamBlack
lbTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
lbTitle.TextSize = 16

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 85, 255)), -- Neon Purple
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))   -- Neon Cyan
})
titleGradient.Parent = lbTitle

-- Header Labels (Rank, Name, Spent)
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
hName.Size = UDim2.new(0.55, -5, 1, 0)
hName.Position = UDim2.new(0.15, 5, 0, 0)
hName.BackgroundTransparency = 1
hName.Text = "Name"
hName.Font = Enum.Font.GothamBold
hName.TextColor3 = COLOR_TEXT_DIM
hName.TextSize = 10
hName.TextXAlignment = Enum.TextXAlignment.Left

local hSpent = Instance.new("TextLabel", headerBar)
hSpent.Size = UDim2.new(0.3, -5, 1, 0)
hSpent.Position = UDim2.new(0.7, 0, 0, 0)
hSpent.BackgroundTransparency = 1
hSpent.Text = "Spent"
hSpent.Font = Enum.Font.GothamBold
hSpent.TextColor3 = COLOR_TEXT_DIM
hSpent.TextSize = 10
hSpent.TextXAlignment = Enum.TextXAlignment.Right

-- Scrolling Area
local lbScrolling = Instance.new("ScrollingFrame", lbContainer)
lbScrolling.Size = UDim2.new(1, -10, 1, -85)
lbScrolling.Position = UDim2.new(0, 5, 0, 75)
lbScrolling.BackgroundTransparency = 1
lbScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
lbScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
lbScrolling.ScrollBarThickness = 3
lbScrolling.ScrollBarImageColor3 = Color3.fromRGB(44, 44, 60)

local lbList = Instance.new("UIListLayout", lbScrolling)
lbList.Padding = UDim.new(0, 6)
lbList.SortOrder = Enum.SortOrder.LayoutOrder

-- Format Helper
local function FormatNumber(n)
	local formatted = tostring(n)
	for i = 1, 20 do
		local k
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then break end
	end
	return formatted
end

local function BuatPlayerBar(p, spent, rank)
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
	stroke.Color = Color3.fromRGB(44, 44, 60)
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

	-- Horizontal Container for Rank Badge + Name
	local nameContainer = Instance.new("Frame", bar)
	nameContainer.Name = "NameContainer"
	nameContainer.Size = UDim2.new(0.55, -5, 1, 0)
	nameContainer.Position = UDim2.new(0.15, 5, 0, 0)
	nameContainer.BackgroundTransparency = 1
	
	local listLayout = Instance.new("UIListLayout", nameContainer)
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 4)
	
	-- Rank Badge
	local badge = Instance.new("TextLabel", nameContainer)
	badge.Name = "Badge"
	badge.Size = UDim2.new(0, 0, 1, 0)
	badge.AutomaticSize = Enum.AutomaticSize.X
	badge.BackgroundTransparency = 1
	badge.Font = Enum.Font.GothamBold
	badge.TextSize = 10
	badge.LayoutOrder = 1
	
	local rankBadgeText = p:GetAttribute("PlayerRank") or "[GUEST]"
	local rankBadgeColor = p:GetAttribute("PlayerRankColor") or Color3.fromRGB(180, 180, 180)
	badge.Text = rankBadgeText
	badge.TextColor3 = rankBadgeColor
	
	-- Player Name Label
	local nameLbl = Instance.new("TextLabel", nameContainer)
	nameLbl.Name = "NameLabel"
	nameLbl.Size = UDim2.new(0, 100, 1, 0)
	nameLbl.AutomaticSize = Enum.AutomaticSize.X
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = p.DisplayName
	nameLbl.Font = Enum.Font.GothamSemibold
	nameLbl.TextColor3 = COLOR_TEXT
	nameLbl.TextSize = 11
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
	nameLbl.LayoutOrder = 2
	
	local sizeConstraint = Instance.new("UISizeConstraint", nameLbl)
	sizeConstraint.MaxSize = Vector2.new(115, 9000)

	-- Spent Info
	local spentLbl = Instance.new("TextLabel", bar)
	spentLbl.Size = UDim2.new(0.3, -5, 1, 0)
	spentLbl.Position = UDim2.new(0.7, 0, 0, 0)
	spentLbl.BackgroundTransparency = 1
	spentLbl.Text = "R$ " .. FormatNumber(spent)
	spentLbl.Font = Enum.Font.GothamBold
	spentLbl.TextColor3 = COLOR_GOLD
	spentLbl.TextSize = 11
	spentLbl.TextXAlignment = Enum.TextXAlignment.Right

	return bar
end

local leaderboardUpdatePending = false
local function RealUpdateLeaderboard()
	for _, child in pairs(lbScrolling:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	local playerList = {}
	for _, p in pairs(Players:GetPlayers()) do
		local ls = p:FindFirstChild("leaderstats")
		local spent = ls and ls:FindFirstChild("Spent") and ls.Spent.Value or 0
		table.insert(playerList, {Player = p, Spent = spent})
	end
	
	table.sort(playerList, function(a, b)
		return a.Spent > b.Spent
	end)
	
	for i = 1, math.min(#playerList, 15) do
		local bar = BuatPlayerBar(playerList[i].Player, playerList[i].Spent, i)
		bar.Parent = lbScrolling
	end
end

local function UpdateLeaderboard()
	if leaderboardUpdatePending then return end
	leaderboardUpdatePending = true
	task.defer(function()
		leaderboardUpdatePending = false
		RealUpdateLeaderboard()
	end)
end

local function ConnectPlayerStats(p)
	task.spawn(function()
		p.AttributeChanged:Connect(function(attr)
			if attr == "PlayerRank" or attr == "PlayerRankColor" then
				UpdateLeaderboard()
			end
		end)
		
		local ls = p:WaitForChild("leaderstats", 10)
		if ls then
			local spent = ls:WaitForChild("Spent", 10)
			if spent then
				spent.Changed:Connect(UpdateLeaderboard)
				UpdateLeaderboard()
			end
		end
	end)
end

-- Hook existing players
UpdateLeaderboard()
Players.PlayerAdded:Connect(ConnectPlayerStats)
Players.PlayerRemoving:Connect(UpdateLeaderboard)

for _, p in ipairs(Players:GetPlayers()) do
	ConnectPlayerStats(p)
end

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
