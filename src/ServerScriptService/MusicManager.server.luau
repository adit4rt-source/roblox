--[[
	MusicManager.server.luau
	Mengatur always-on music player, antrian lagu (max 2 per user),
	custom ID lookup, transisi lagu, dan sistem vote skip (min 10 orang / 100% server).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local MarketplaceService = game:GetService("MarketplaceService")

local MusicDatabase = require(ReplicatedStorage:WaitForChild("MusicDatabase"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local MusicEvent = Remotes:WaitForChild("MusicEvent")

-- State
local activeSong = nil
local queue = {}
local skipVotes = {} -- Set of player UserIds who voted to skip
local userQueueCounts = {} -- Map of UserId -> number of queued songs
local serverSound = nil -- Silent server sound used to track playback ended
local watchdogThread = nil

-- Helper: Get default playlist song
local function getRandomDefaultSong()
	local tracks = MusicDatabase.Tracks
	if #tracks == 0 then return nil end
	local randomIndex = math.random(1, #tracks)
	local track = tracks[randomIndex]
	return {
		Id = track.Id,
		Title = track.Title,
		Artist = track.Artist,
		Playlist = track.Playlist,
		QueuedBy = "SYSTEM",
		Duration = track.Duration or 180,
		StartTime = Workspace:GetServerTimeNow()
	}
end

-- Broadcast state to all players
local function broadcastState()
	local activeSongData = activeSong
	local queueData = queue
	local voteCount = 0
	for _ in pairs(skipVotes) do
		voteCount += 1
	end
	
	local totalPlayers = #Players:GetPlayers()
	local requiredVotes = math.clamp(math.min(10, totalPlayers), 1, 10)
	
	MusicEvent:FireAllClients({
		Action = "SyncState",
		ActiveSong = activeSongData,
		Queue = queueData,
		VoteCount = voteCount,
		RequiredVotes = requiredVotes
	})
end

-- Stop current watchdog and sound
local function cleanupCurrentPlayback()
	if watchdogThread then
		task.cancel(watchdogThread)
		watchdogThread = nil
	end
	if serverSound then
		serverSound:Stop()
	end
end

-- Play next song in the queue (or default if empty)
local function playNextSong()
	cleanupCurrentPlayback()
	skipVotes = {} -- Clear skip votes
	
	local nextSong = nil
	if #queue > 0 then
		nextSong = table.remove(queue, 1)
		-- Decrement user queue count
		if nextSong.QueuedByUserId and userQueueCounts[nextSong.QueuedByUserId] then
			userQueueCounts[nextSong.QueuedByUserId] = math.max(0, userQueueCounts[nextSong.QueuedByUserId] - 1)
		end
	else
		nextSong = getRandomDefaultSong()
	end
	
	if not nextSong then return end
	
	activeSong = nextSong
	activeSong.StartTime = Workspace:GetServerTimeNow()
	
	-- Setup silent server sound to track playback ended
	if not serverSound then
		serverSound = Instance.new("Sound")
		serverSound.Name = "ServerMusicTimer"
		serverSound.Volume = 0 -- Keep silent on server
		serverSound.Parent = SoundService
	end
	
	serverSound.SoundId = "rbxassetid://" .. activeSong.Id
	serverSound:Play()
	
	-- Broadcast new state
	broadcastState()
	
	-- Watchdog thread to proceed to next song when it ends or times out
	watchdogThread = task.spawn(function()
		-- Wait for sound to load and get TimeLength
		local timeout = 0
		while serverSound.TimeLength == 0 and timeout < 8 do
			task.wait(0.5)
			timeout += 0.5
		end
		
		local duration = serverSound.TimeLength > 0 and serverSound.TimeLength or activeSong.Duration
		activeSong.Duration = duration
		
		-- Wait for song to end naturally or force skip after duration + 5 seconds buffer
		task.wait(duration)
		playNextSong()
	end)
end

-- Handle song skip request
local function skipSong()
	print("[Server] Skiping current song: " .. (activeSong and activeSong.Title or "None"))
	playNextSong()
end

-- Get song details from Database or Roblox Catalog
local function resolveSongInfo(songId: number, requesterName: string, requesterId: number)
	-- Check Database first
	for _, track in ipairs(MusicDatabase.Tracks) do
		if track.Id == songId then
			return {
				Id = track.Id,
				Title = track.Title,
				Artist = track.Artist,
				Playlist = track.Playlist,
				QueuedBy = requesterName,
				QueuedByUserId = requesterId,
				Duration = track.Duration or 180
			}
		end
	end
	
	-- Fetch product info from catalog
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(songId, Enum.InfoType.Asset)
	end)
	
	if success and info and info.AssetTypeId == 3 then -- 3 is Audio
		local cleanTitle = info.Name
		local cleanArtist = "Unknown Artist"
		
		-- Simple split by hyphens (e.g. "Artist - Title")
		local splitStart, splitEnd = string.find(cleanTitle, "%s*-%s*")
		if splitStart then
			cleanArtist = string.sub(cleanTitle, 1, splitStart - 1)
			cleanTitle = string.sub(cleanTitle, splitEnd + 1)
		end
		
		return {
			Id = songId,
			Title = cleanTitle,
			Artist = cleanArtist,
			Playlist = "CUSTOM",
			QueuedBy = requesterName,
			QueuedByUserId = requesterId,
			Duration = 180 -- Fallback duration, will update when played
		}
	end
	
	return nil
end

-- Receive client events
MusicEvent.OnServerEvent:Connect(function(player, data)
	if type(data) ~= "table" then return end
	local action = data.Action
	
	if action == "GetState" then
		-- Sync specific player
		local voteCount = 0
		for _ in pairs(skipVotes) do
			voteCount += 1
		end
		
		local totalPlayers = #Players:GetPlayers()
		local requiredVotes = math.clamp(math.min(10, totalPlayers), 1, 10)
		local hasVoted = skipVotes[player.UserId] == true
		
		MusicEvent:FireClient(player, {
			Action = "SyncState",
			ActiveSong = activeSong,
			Queue = queue,
			VoteCount = voteCount,
			RequiredVotes = requiredVotes,
			HasVoted = hasVoted
		})
		
	elseif action == "QueueSong" then
		local songId = tonumber(data.Id)
		if not songId then return end
		
		-- Enforce queue limit: max 2 songs per player
		local currentCount = userQueueCounts[player.UserId] or 0
		if currentCount >= 2 then
			MusicEvent:FireClient(player, {
				Action = "Notification",
				Title = "Antrean Penuh",
				Text = "Kamu hanya bisa memasukkan maksimal 2 lagu sekaligus!",
				Color = Color3.fromRGB(231, 76, 60)
			})
			return
		end
		
		-- Resolve metadata
		local resolved = resolveSongInfo(songId, player.DisplayName, player.UserId)
		if not resolved then
			MusicEvent:FireClient(player, {
				Action = "Notification",
				Title = "Lagu Gagal",
				Text = "ID audio tidak valid atau tidak dapat diakses!",
				Color = Color3.fromRGB(231, 76, 60)
			})
			return
		end
		
		-- Update counts and add to queue
		userQueueCounts[player.UserId] = currentCount + 1
		table.insert(queue, resolved)
		
		MusicEvent:FireClient(player, {
			Action = "Notification",
			Title = "Sukses Antrean",
			Text = `"{resolved.Title}" berhasil masuk ke antrean!`,
			Color = Color3.fromRGB(46, 204, 113)
		})
		
		-- If currently playing background system music, instantly skip to play user request
		if activeSong and activeSong.QueuedBy == "SYSTEM" then
			print("[Server] User queued a song, skiping system background music...")
			task.spawn(playNextSong)
		else
			broadcastState()
		end
		
	elseif action == "VoteSkip" then
		if not activeSong then return end
		
		if skipVotes[player.UserId] then
			skipVotes[player.UserId] = nil
		else
			skipVotes[player.UserId] = true
		end
		
		-- Check skip logic
		local voteCount = 0
		for _ in pairs(skipVotes) do
			voteCount += 1
		end
		
		local totalPlayers = #Players:GetPlayers()
		local requiredVotes = math.clamp(math.min(10, totalPlayers), 1, 10)
		
		if voteCount >= requiredVotes then
			MusicEvent:FireClient(player, {
				Action = "Notification",
				Title = "Skipped",
				Text = "Lagu berhasil dilewati oleh kesepakatan pemain!",
				Color = Color3.fromRGB(46, 204, 113)
			})
			task.spawn(skipSong)
		else
			broadcastState()
		end
	end
end)

-- Clean up player queue limits when they leave
Players.PlayerRemoving:Connect(function(player)
	userQueueCounts[player.UserId] = nil
	if skipVotes[player.UserId] then
		skipVotes[player.UserId] = nil
		
		-- Check skip logic again since total player count decreased
		local voteCount = 0
		for _ in pairs(skipVotes) do
			voteCount += 1
		end
		
		local totalPlayers = #Players:GetPlayers()
		local requiredVotes = math.clamp(math.min(10, totalPlayers), 1, 10)
		
		if voteCount >= requiredVotes then
			task.spawn(skipSong)
		else
			broadcastState()
		end
	else
		broadcastState()
	end
end)

Players.PlayerAdded:Connect(function()
	task.delay(1, broadcastState)
end)

-- Always-on startup
task.spawn(playNextSong)

print("[Server] MusicManager successfully loaded!")
