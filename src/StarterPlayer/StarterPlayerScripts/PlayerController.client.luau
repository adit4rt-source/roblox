--[[
	PlayerController.client.luau
	LocalScript yang mengatur input dan UI di sisi klien.
	Lokasi: StarterPlayerScripts
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Module imports
local Utils = require(ReplicatedStorage:WaitForChild("Utils"))

-- References
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- State
local isRunning = false
local DEFAULT_WALK_SPEED = 16
local RUN_SPEED = 32

-- Fungsi untuk toggle sprint
local function toggleSprint(running: boolean)
	isRunning = running
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = if running then RUN_SPEED else DEFAULT_WALK_SPEED
	end
end

-- Input handling - Sprint dengan Left Shift
UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		toggleSprint(true)
	end
end)

UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessed: boolean)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		toggleSprint(false)
	end
end)

-- Reset saat karakter respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	isRunning = false
	Utils.log("Karakter respawn!")
end)

-- Simple HUD update setiap frame (contoh)
RunService.RenderStepped:Connect(function(deltaTime: number)
	-- Tempat untuk update UI real-time jika diperlukan
end)

Utils.log("PlayerController berhasil dimuat!")
print("[Client] PlayerController aktif untuk " .. player.Name)
