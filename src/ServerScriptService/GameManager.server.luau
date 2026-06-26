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
		
		local rankText = "[GUEST]"
		local rankColor = Color3.fromRGB(180, 180, 180)
		
		if customTag and customTag ~= "" then
			local cleanTag = customTag:match("^%[(.+)%]$") or customTag
			rankText = "[" .. cleanTag:upper() .. "]"
			rankColor = Color3.fromRGB(85, 255, 127)
		elseif p == topSpender then
			rankText = "[TOP SPENDER]"
			rankColor = Color3.fromRGB(255, 215, 0)
		elseif isVIP then
			rankText = "[VIP]"
			rankColor = Color3.fromRGB(170, 85, 255)
		end
		
		p:SetAttribute("PlayerRank", rankText)
		p:SetAttribute("PlayerRankColor", rankColor)
		
		local char = p.Character
		if char then
			local head = char:FindFirstChild("Head")
			if head then
				local nametag = head:FindFirstChild("PlayerNametag")
				if not nametag then
					nametag = Instance.new("BillboardGui")
					nametag.Name = "PlayerNametag"
					nametag.Size = UDim2.new(4, 0, 1.5, 0)
					nametag.StudsOffset = Vector3.new(0, 2.5, 0)
					nametag.AlwaysOnTop = true
					nametag.LightInfluence = 0
					
					local uiListLayout = Instance.new("UIListLayout")
					uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
					uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
					uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
					uiListLayout.Padding = UDim.new(0, 2)
					uiListLayout.Parent = nametag
					
					local titleLabel = Instance.new("TextLabel")
					titleLabel.Name = "TitleLabel"
					titleLabel.Size = UDim2.new(1, 0, 0.45, 0)
					titleLabel.BackgroundTransparency = 1
					titleLabel.Font = Enum.Font.GothamBold
					titleLabel.TextSize = 14
					titleLabel.TextStrokeTransparency = 0.5
					titleLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
					titleLabel.LayoutOrder = 1
					titleLabel.Parent = nametag
					
					local nameLabel = Instance.new("TextLabel")
					nameLabel.Name = "NameLabel"
					nameLabel.Size = UDim2.new(1, 0, 0.45, 0)
					nameLabel.BackgroundTransparency = 1
					nameLabel.Font = Enum.Font.GothamBold
					nameLabel.TextSize = 16
					nameLabel.TextColor3 = Color3.new(1, 1, 1)
					nameLabel.TextStrokeTransparency = 0.5
					nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
					nameLabel.Text = p.Name
					nameLabel.LayoutOrder = 2
					nameLabel.Parent = nametag
					
					nametag.Parent = head
				end
				
				local titleLabel = nametag:FindFirstChild("TitleLabel")
				if titleLabel then
					titleLabel.Text = rankText
					titleLabel.TextColor3 = rankColor
				end
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
