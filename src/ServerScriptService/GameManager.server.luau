--[[
	GameManager.server.luau
	Server script yang mengatur koneksi pemain dan event utama game.
	Lokasi: ServerScriptService
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Module imports
local Utils = require(ReplicatedStorage:WaitForChild("Utils"))

-- Constants
local MAX_PLAYERS = 50
local SPAWN_POSITION = Vector3.new(0, 10, 0)

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

	local score = Instance.new("IntValue")
	score.Name = "Score"
	score.Value = 0
	score.Parent = leaderstats

	local playtime = Instance.new("IntValue")
	playtime.Name = "Playtime"
	playtime.Value = 0
	playtime.Parent = leaderstats

	local koin = Instance.new("IntValue")
	koin.Name = "Koin"
	koin.Value = 100 -- starting coins
	koin.Parent = leaderstats

	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = 1 -- starting level
	level.Parent = leaderstats



	-- Kirim pesan selamat datang
	Utils.log(`Pemain {player.Name} berhasil terhubung!`)
end

-- Fungsi ketika pemain keluar
local function onPlayerRemoving(player: Player)
	print(`[Server] Pemain keluar: {player.Name}`)

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

-- Update playtime setiap 60 detik
task.spawn(function()
	while true do
		task.wait(60)
		for player, data in pairs(playerData) do
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local playtime = leaderstats:FindFirstChild("Playtime")
				if playtime then
					playtime.Value += 1
				end
			end
		end
	end
end)

print("[Server] GameManager berhasil dimuat!")
