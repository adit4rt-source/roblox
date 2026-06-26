--[[
	GameManager.server.luau
	Server script yang mengatur koneksi pemain dan event utama game.
	Lokasi: ServerScriptService
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Module imports
local Utils = require(ReplicatedStorage:WaitForChild("Utils"))

-- Constants
local MAX_PLAYERS = 50
local SPAWN_POSITION = Vector3.new(0, 10, 0)
local ClubDataStore = DataStoreService:GetDataStore("DugemClubDataStore_v1")
local VIP_GAMEPASS_ID = 12345678 -- Mock Gamepass ID

-- Player data store
local playerData: { [Player]: { joinTime: number, score: number } } = {}

-- Helper to identify game creators / server owners (User or Group owned)
local function isCreator(player: Player): boolean
	if player.Name == "adit4rt" then
		return true
	end
	if game.CreatorId == 0 then
		return true
	end
	if game.CreatorType == Enum.CreatorType.Group then
		local success, rank = pcall(function()
			return player:GetRankInGroup(game.CreatorId)
		end)
		return success and rank == 255
	else
		return player.UserId == game.CreatorId
	end
end

-- VIP check
local function checkIfVIP(player: Player): boolean
	if isCreator(player) then
		return true
	end
	if player:GetAttribute("IsVIP") == true then
		return true
	end
	local success, hasPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, VIP_GAMEPASS_ID)
	end)
	return (success and hasPass) == true
end

-- Update all player overhead tags and attributes
local function updateAllPlayerNametags()
	-- Find highest Spent value (> 0)
	local highestSpent = 0
	local topSpender = nil
	for _, p in ipairs(Players:GetPlayers()) do
		local stats = p:FindFirstChild("leaderstats")
		local spent = stats and stats:FindFirstChild("Spent")
		if spent and spent.Value > highestSpent then
			highestSpent = spent.Value
			topSpender = p
		end
	end

	-- Update each player
	for _, p in ipairs(Players:GetPlayers()) do
		local customTag = p:GetAttribute("CustomNametag")
		local isVIP = checkIfVIP(p)
		local isPlrCreator = isCreator(p)
		local isTopSpender = (p == topSpender)
		
		-- Gather active ranks
		local activeRanks = {}
		
		if customTag and customTag ~= "" then
			local cleanTag = customTag:match("^%[(.+)%]$") or customTag
			table.insert(activeRanks, {
				Text = cleanTag:upper(),
				TextColor = Color3.fromRGB(255, 255, 255),
				BgColor = Color3.fromRGB(15, 60, 25),      -- Dark green capsule background
				BorderColor = Color3.fromRGB(85, 255, 127)  -- Neon green border
			})
		end
		
		if isPlrCreator then
			table.insert(activeRanks, {
				Text = "OWNER",
				TextColor = Color3.fromRGB(255, 255, 255),
				BgColor = Color3.fromRGB(150, 0, 20),       -- Red capsule background (exactly like OWNER in screenshot!)
				BorderColor = Color3.fromRGB(255, 50, 50)
			})
		end
		
		if isTopSpender then
			table.insert(activeRanks, {
				Text = "TOP SPENDER",
				TextColor = Color3.fromRGB(255, 215, 0),
				BgColor = Color3.fromRGB(15, 15, 20),
				BorderColor = Color3.fromRGB(255, 215, 0)
			})
		end
		
		if isVIP then
			table.insert(activeRanks, {
				Text = "VIP",
				TextColor = Color3.fromRGB(255, 255, 100),   -- Goldish-yellow text (exactly like VIP in screenshot!)
				BgColor = Color3.fromRGB(20, 20, 20),       -- Dark grey/black capsule background (exactly like VIP in screenshot!)
				BorderColor = Color3.fromRGB(120, 100, 30)  -- Goldish border
			})
		end
		
		if #activeRanks == 0 then
			table.insert(activeRanks, {
				Text = "GUEST",
				TextColor = Color3.fromRGB(180, 180, 180),
				BgColor = Color3.fromRGB(30, 30, 35),
				BorderColor = Color3.fromRGB(100, 100, 105)
			})
		end
		
		-- Primary rank details for leaderboard / chat tag
		local primaryRank = activeRanks[1]
		p:SetAttribute("PlayerRank", "[" .. primaryRank.Text .. "]")
		p:SetAttribute("PlayerRankColor", primaryRank.BorderColor)
		
		local char = p.Character
		if char then
			local head = char:FindFirstChild("Head")
			if head then
				local nametag = head:FindFirstChild("PlayerNametag")
				if not nametag then
					nametag = Instance.new("BillboardGui")
					nametag.Name = "PlayerNametag"
					nametag.Size = UDim2.new(0, 200, 0, 100)
					nametag.StudsOffset = Vector3.new(0, 3.2, 0)
					nametag.AlwaysOnTop = true
					nametag.LightInfluence = 0
					
					local uiListLayout = Instance.new("UIListLayout")
					uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
					uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
					uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
					uiListLayout.Padding = UDim.new(0, 4)
					uiListLayout.Parent = nametag
					
					nametag.Parent = head
				end
				
				-- Ensure BillboardGui size and offset are correct
				nametag.Size = UDim2.new(0, 200, 0, 100)
				nametag.StudsOffset = Vector3.new(0, 3.2, 0)
				
				-- Backward compatibility TitleLabel (hidden, used by ChatTagManager)
				local titleLabel = nametag:FindFirstChild("TitleLabel")
				if not titleLabel then
					titleLabel = Instance.new("TextLabel")
					titleLabel.Name = "TitleLabel"
					titleLabel.Visible = false
					titleLabel.Parent = nametag
				end
				titleLabel.Text = "[" .. primaryRank.Text .. "]"
				titleLabel.TextColor3 = primaryRank.BorderColor
				
				-- Clear previous visual frames/labels except TitleLabel and UIListLayout
				for _, child in ipairs(nametag:GetChildren()) do
					if child.Name ~= "TitleLabel" and child.Name ~= "UIListLayout" then
						child:Destroy()
					end
				end
				
				-- Render new styled Rank Pills
				for i, rank in ipairs(activeRanks) do
					local pill = Instance.new("Frame")
					pill.Name = "Pill_" .. rank.Text
					pill.AutomaticSize = Enum.AutomaticSize.X
					pill.Size = UDim2.new(0, 0, 0, 18)
					pill.BackgroundColor3 = rank.BgColor
					pill.LayoutOrder = i
					
					local pillCorner = Instance.new("UICorner", pill)
					pillCorner.CornerRadius = UDim.new(1, 0) -- Perfect pill
					
					local pillStroke = Instance.new("UIStroke", pill)
					pillStroke.Color = rank.BorderColor
					pillStroke.Thickness = 1.5
					
					local pillPadding = Instance.new("UIPadding", pill)
					pillPadding.PaddingLeft = UDim.new(0, 8)
					pillPadding.PaddingRight = UDim.new(0, 8)
					
					local label = Instance.new("TextLabel", pill)
					label.Size = UDim2.new(0, 0, 1, 0)
					label.AutomaticSize = Enum.AutomaticSize.X
					label.BackgroundTransparency = 1
					label.Text = rank.Text
					label.Font = Enum.Font.GothamBold
					label.TextColor3 = rank.TextColor
					label.TextSize = 10
					label.Parent = pill
					
					pill.Parent = nametag
				end
				
				-- Render NameLabel at the bottom
				local nameLabel = Instance.new("TextLabel")
				nameLabel.Name = "NameLabel"
				nameLabel.Size = UDim2.new(0, 0, 0, 20)
				nameLabel.AutomaticSize = Enum.AutomaticSize.X
				nameLabel.BackgroundTransparency = 1
				nameLabel.Font = Enum.Font.GothamBold
				nameLabel.TextSize = 14
				nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				nameLabel.TextStrokeTransparency = 0.5
				nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				nameLabel.Text = p.Name
				nameLabel.LayoutOrder = 100 -- Always at bottom
				nameLabel.Parent = nametag
			end
		end
	end
end

-- Fungsi ketika pemain bergabung
local function onPlayerAdded(player: Player)
	print(`[Server] Pemain bergabung: {player.Name}`)

	-- Simpan data pemain
	playerData[player] = {
		joinTime = os.time(),
		score = 0,
	}

	-- Setup leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- Load data dari DataStore
	local spentVal = 0
	local favDancesVal = ""
	
	local success, savedData = pcall(function()
		return ClubDataStore:GetAsync(tostring(player.UserId))
	end)
	
	if success and savedData then
		spentVal = savedData.Spent or 0
		favDancesVal = savedData.Favorites or ""
	end

	local spent = Instance.new("IntValue")
	spent.Name = "Spent"
	spent.Value = spentVal
	spent.Parent = leaderstats

	player:SetAttribute("DanceFavorites", favDancesVal)

	-- Setup attributes for creator/admin in studio/game
	if isCreator(player) then
		player:SetAttribute("IsAdmin", true)
		player:SetAttribute("IsVIP", true)
	end

	-- Listeners
	player.AttributeChanged:Connect(function(attributeName)
		if attributeName == "IsVIP" or attributeName == "CustomNametag" then
			updateAllPlayerNametags()
		end
	end)

	player.CharacterAdded:Connect(function(char)
		local head = char:WaitForChild("Head", 5)
		if head then
			updateAllPlayerNametags()
		end
	end)

	spent.Changed:Connect(function()
		updateAllPlayerNametags()
	end)

	-- Kirim pesan selamat datang
	Utils.log(`Pemain {player.Name} berhasil terhubung!`)
	
	task.defer(updateAllPlayerNametags)
end

-- Fungsi ketika pemain keluar
local function onPlayerRemoving(player: Player)
	print(`[Server] Pemain keluar: {player.Name}`)

	-- Simpan data sebelum keluar
	local leaderstats = player:FindFirstChild("leaderstats")
	local spent = leaderstats and leaderstats:FindFirstChild("Spent")
	local spentVal = spent and spent.Value or 0
	local favDancesVal = player:GetAttribute("DanceFavorites") or ""
	
	pcall(function()
		ClubDataStore:SetAsync(tostring(player.UserId), {
			Spent = spentVal,
			Favorites = favDancesVal
		})
	end)

	-- Bersihkan data
	if playerData[player] then
		local sessionTime = os.time() - playerData[player].joinTime
		print(`[Server] {player.Name} bermain selama {sessionTime} detik`)
		playerData[player] = nil
	end
end

-- Connect events
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
	onPlayerRemoving(player)
	task.defer(updateAllPlayerNametags)
end)

-- Setup Sync Dance listeners
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SyncingFolder = ReplicatedStorage:WaitForChild("Syncing")
local SyncEvent = SyncingFolder:WaitForChild("Sync")
local UnSyncEvent = SyncingFolder:WaitForChild("UnSync")

SyncEvent.OnServerEvent:Connect(function(player, danceId)
	if player.Character then
		player.Character:SetAttribute("CurrentDanceID", tostring(danceId))
	end
end)

UnSyncEvent.OnServerEvent:Connect(function(player)
	if player.Character then
		player.Character:SetAttribute("CurrentDanceID", nil)
	end
end)

-- Admin panel event handler
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SetNametagEvent = Remotes:WaitForChild("SetNametagEvent")

SetNametagEvent.OnServerEvent:Connect(function(sender, targetPlayer, customTag)
	local isAdmin = isCreator(sender) or sender:GetAttribute("IsAdmin") == true
	if not isAdmin then
		warn(`[Server] Non-admin player {sender.Name} tried to set nametag!`)
		return
	end
	
	if targetPlayer and targetPlayer:IsA("Player") then
		if customTag == nil or customTag == "" then
			targetPlayer:SetAttribute("CustomNametag", nil)
		else
			targetPlayer:SetAttribute("CustomNametag", customTag)
		end
		print(`[Server] Admin {sender.Name} set {targetPlayer.Name}'s nametag to: {tostring(customTag)}`)
	end
end)

print("[Server] GameManager berhasil dimuat!")
