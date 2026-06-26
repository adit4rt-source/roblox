-- ================================================================
--  DeviceDetector (LocalScript) - DETECT DEVICE TYPE AND SEND TO SERVER
-- ================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SetDeviceEvent = Remotes:WaitForChild("SetDeviceEvent")

-- Determine device type based on user input capabilities
local deviceType = "PC"
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	deviceType = "Mobile"
elseif UserInputService.GamepadEnabled then
	deviceType = "Console"
end

-- Fire to server with a small initial wait to ensure connection is ready
task.spawn(function()
	task.wait(1)
	SetDeviceEvent:FireServer(deviceType)
end)
