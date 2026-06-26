local char = script.Parent
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local UpdateStatEvent = Remotes:WaitForChild("UpdateSensorStatEvent")

local totalDistance = 0
local lastPosition = rootPart.Position

-- ==========================================
-- 1. SENSOR MELOMPAT
-- ==========================================
humanoid.StateChanged:Connect(function(oldState, newState)
	if newState == Enum.HumanoidStateType.Jumping then
		UpdateStatEvent:FireServer("TotalJumps", 1)
	end
end)

-- ==========================================
-- 2. SENSOR BERJALAN (Kirim ke server setiap 10 stud)
-- ==========================================
RunService.Heartbeat:Connect(function()
	local currentPos = rootPart.Position
	local dist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(lastPosition.X, 0, lastPosition.Z)).Magnitude

	if dist > 0.05 then
		totalDistance += dist
		lastPosition = currentPos

		if totalDistance >= 10 then
			UpdateStatEvent:FireServer("TotalDistance", 10)
			totalDistance = 0 
		end
	end
end)

-- ==========================================
-- 3. SENSOR CHAT PERTAMA KALI (FIXED ?)
-- ==========================================
local chatConnection
chatConnection = player.Chatted:Connect(function(message)
	-- Kirim laporan ke server bahwa pemain sudah chat
	UpdateStatEvent:FireServer("ChatCount", 1)

	-- Langsung putuskan sensornya agar tidak mengirim data berkali-kali 
	-- setiap kali pemain nge-chat lagi setelah yang pertama
	if chatConnection then
		chatConnection:Disconnect() 
	end
end)