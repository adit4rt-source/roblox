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

local GROUP_ID = 1014192814

-- Helper to identify game creators / server owners (User or Group owned)
local function isCreator(player: Player): boolean
	if player.Name == "adit4rt" then
		return true
	end
	if game.CreatorId == 0 then
		return true
	end
	
	-- Check place creator
	if game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId then
		return true
	elseif game.CreatorType == Enum.CreatorType.Group and player:GetRankInGroup(game.CreatorId) == 255 then
		return true
	end
	
	-- Check target community group owner
	local success, rank = pcall(function()
		return player:GetRankInGroup(GROUP_ID)
	end)
	return success and rank == 255
end

-- VIP check
local function checkIfVIP(player: Player): boolean
	if isCreator(player) then
		return true
	end
	if player:GetAttribute("IsVIP") == true then
		return true
	end
	
	-- Check VIP Gamepass
	local successPass, hasPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, VIP_GAMEPASS_ID)
	end)
	if successPass and hasPass then
		return true
	end
	
	-- Check community group role rank (role >= 100 or contains VIP)
	local successGroup, rank = pcall(function()
		return player:GetRankInGroup(GROUP_ID)
	end)
	if successGroup and rank >= 100 and rank < 255 then
		return true
	end
	
	local successRole, roleName = pcall(function()
		return player:GetRoleInGroup(GROUP_ID)
	end)
	if successRole and string.find(string.upper(roleName), "VIP") then
		return true
	end
	
	return false
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
		
		-- Determine the single active rank by priority
		local activeRank = nil
		
		if customTag and customTag ~= "" then
			local cleanTag = customTag:match("^%[(.+)%]$") or customTag
			activeRank = {
				Text = cleanTag:upper(),
				TextColor = Color3.fromRGB(255, 255, 255),
				BgColor = Color3.fromRGB(10, 50, 25),      -- Dark green
				BorderColor = Color3.fromRGB(85, 255, 127)  -- Neon green
			}
		elseif isPlrCreator then
			activeRank = {
				Text = "OWNER",
				TextColor = Color3.fromRGB(255, 255, 255),
				BgColor = Color3.fromRGB(150, 0, 20),       -- Red background
				BorderColor = Color3.fromRGB(255, 50, 50)
			}
		elseif isTopSpender then
			activeRank = {
				Text = "DONATUR",
				TextColor = Color3.fromRGB(255, 255, 255),
				BgColor = Color3.fromRGB(10, 50, 25),       -- Green background
				BorderColor = Color3.fromRGB(85, 255, 127)
			}
		elseif isVIP then
			activeRank = {
				Text = "VIP",
				TextColor = Color3.fromRGB(255, 255, 100),   -- Yellow text
				BgColor = Color3.fromRGB(20, 20, 20),       -- Dark grey/black background
				BorderColor = Color3.fromRGB(120, 100, 30)  -- Goldish border
			}
		else
			activeRank = {
				Text = "GUEST",
				TextColor = Color3.fromRGB(180, 180, 180),  -- Grey text
				BgColor = Color3.fromRGB(30, 30, 35),       -- Dark grey background
				BorderColor = Color3.fromRGB(100, 100, 105)
			}
		end
		
		-- Primary rank details for leaderboard / chat tag
		p:SetAttribute("PlayerRank", "[" .. activeRank.Text .. "]")
		p:SetAttribute("PlayerRankColor", activeRank.BorderColor)
		
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
				titleLabel.Text = "[" .. activeRank.Text .. "]"
				titleLabel.TextColor3 = activeRank.BorderColor
				
				-- Clear previous visual frames/labels except TitleLabel and UIListLayout
				for _, child in ipairs(nametag:GetChildren()) do
					if child.Name ~= "TitleLabel" and child.Name ~= "UIListLayout" then
						child:Destroy()
					end
				end
				
				-- Render the single active rank band
				local band = Instance.new("Frame")
				band.Name = "Band_" .. activeRank.Text
				band.Size = UDim2.new(0, 120, 0, 18)
				band.BackgroundColor3 = activeRank.BgColor
				band.BorderSizePixel = 0
				band.LayoutOrder = 1
				
				local uiGradient = Instance.new("UIGradient", band)
				uiGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),       -- Fully transparent at left
					NumberSequenceKeypoint.new(0.2, 0.15),   -- Mostly opaque at 20%
					NumberSequenceKeypoint.new(0.8, 0.15),   -- Mostly opaque at 80%
					NumberSequenceKeypoint.new(1, 1)        -- Fully transparent at right
				})
				
				local label = Instance.new("TextLabel", band)
				label.Size = UDim2.new(1, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.Text = activeRank.Text
				label.Font = Enum.Font.GothamBold
				label.TextColor3 = activeRank.TextColor
				label.TextSize = 10
				label.TextStrokeTransparency = 0.7
				label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				label.Parent = band
				
				band.Parent = nametag
				
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
		task.wait(0.5)
		local head = char:FindFirstChild("Head")
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
