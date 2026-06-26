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

	local donated = Instance.new("IntValue")
	donated.Name = "Donated"
	donated.Value = 0 -- initial Robux donation amount
	donated.Parent = leaderstats

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

print("[Server] GameManager berhasil dimuat!")
