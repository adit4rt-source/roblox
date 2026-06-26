--[[
	GameManager.server.luau
	Server script yang mengatur koneksi pemain dan event utama game.
	Lokasi: ServerScriptService
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")

-- Module imports
local Utils = require(ReplicatedStorage:WaitForChild("Utils"))

-- Constants
local MAX_PLAYERS = 50
local SPAWN_POSITION = Vector3.new(0, 10, 0)
local ClubDataStore = DataStoreService:GetDataStore("DugemClubDataStore_v1")

-- Player data store (sederhana, untuk contoh)
local playerData: { [Player]: { joinTime: number, score: number } } = {}

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

	-- Kirim pesan selamat datang
	Utils.log(`Pemain {player.Name} berhasil terhubung!`)
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
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Setup Sync Dance listeners
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

print("[Server] GameManager berhasil dimuat!")
