-- ================================================================
--  AdminPanel (LocalScript) - ADMIN TOOL FOR REALTIME NAMETAGS
-- ================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SetNametagEvent = Remotes:WaitForChild("SetNametagEvent")

-- Clean up existing Admin UI if it exists
if playerGui:FindFirstChild("AdminPanelGui") then
	playerGui.AdminPanelGui:Destroy()
end

-- Check if player has admin access
local function checkAdminAccess(): boolean
	return player.UserId == game.CreatorId or player:GetAttribute("IsAdmin") == true or game.CreatorId == 0
end

-- Notification to instruct creator/admins
task.spawn(function()
	task.wait(3)
	if checkAdminAccess() then
		StarterGui:SetCore("SendNotification", {
			Title = "Admin Panel",
			Text = "Tekan tombol 'P' untuk membuka menu Admin Panel.",
			Duration = 6,
			Button1 = "OK"
		})
	end
end)

-- GUI Container
local adminGui = Instance.new("ScreenGui")
adminGui.Name = "AdminPanelGui"
adminGui.ResetOnSpawn = false
adminGui.IgnoreGuiInset = true
adminGui.Enabled = true
adminGui.Parent = playerGui

-- Main Centered Frame
local panel = Instance.new("Frame")
panel.Name = "PanelFrame"
panel.Size = UDim2.new(0, 380, 0, 300)
panel.Position = UDim2.new(0.5, 0, 0.5, 0)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(15, 15, 24) -- Dark nightclub navy
panel.Visible = false
panel.Parent = adminGui

local panelCorner = Instance.new("UICorner", panel)
panelCorner.CornerRadius = UDim.new(0, 12)

local panelStroke = Instance.new("UIStroke", panel)
panelStroke.Color = Color3.fromRGB(85, 0, 127) -- Purple neon border
panelStroke.Thickness = 2

-- Make panel draggable (simple classic dragging support)
local dragging, dragInput, dragStart, startPos
local function update(input)
	local delta = input.Position - dragStart
	panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
panel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = panel.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
panel.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Title Bar
local titleLbl = Instance.new("TextLabel", panel)
titleLbl.Size = UDim2.new(1, 0, 0, 40)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "✨ ADMIN PANEL ✨"
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLbl.TextSize = 14

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),   -- Neon Red
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 170, 0))   -- Gold
})
titleGradient.Parent = titleLbl

-- Close Button
local closeBtn = Instance.new("TextButton", panel)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 11
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
	panel.Visible = false
end)

-- Left Side: Player List Header
local pListHeader = Instance.new("TextLabel", panel)
pListHeader.Size = UDim2.new(0.45, 0, 0, 20)
pListHeader.Position = UDim2.new(0, 12, 0, 40)
pListHeader.BackgroundTransparency = 1
pListHeader.Text = "Pemain Online"
pListHeader.Font = Enum.Font.GothamBold
pListHeader.TextColor3 = Color3.fromRGB(150, 150, 165)
pListHeader.TextSize = 10
pListHeader.TextXAlignment = Enum.TextXAlignment.Left

-- Left Side: Player List Scrolling Frame
local pListScroll = Instance.new("ScrollingFrame", panel)
pListScroll.Size = UDim2.new(0.45, 0, 1, -80)
pListScroll.Position = UDim2.new(0, 12, 0, 65)
pListScroll.BackgroundTransparency = 1
pListScroll.ScrollBarThickness = 3
pListScroll.ScrollBarImageColor3 = Color3.fromRGB(44, 44, 60)
pListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
pListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local pListLayout = Instance.new("UIListLayout", pListScroll)
pListLayout.Padding = UDim.new(0, 5)
pListLayout.SortOrder = Enum.SortOrder.Name

-- Right Side Control Area Container
local controlContainer = Instance.new("Frame", panel)
controlContainer.Size = UDim2.new(0.48, 0, 1, -80)
controlContainer.Position = UDim2.new(0.49, 10, 0, 65)
controlContainer.BackgroundTransparency = 1

local selectedPlayer = nil

-- Target Selection Label
local targetLabel = Instance.new("TextLabel", controlContainer)
targetLabel.Size = UDim2.new(1, 0, 0, 25)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "Target: None"
targetLabel.Font = Enum.Font.GothamBold
targetLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
targetLabel.TextSize = 11
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.TextTruncate = Enum.TextTruncate.AtEnd

-- Custom Tag Input Textbox
local tagTextBox = Instance.new("TextBox", controlContainer)
tagTextBox.Size = UDim2.new(1, 0, 0, 32)
tagTextBox.Position = UDim2.new(0, 0, 0, 35)
tagTextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
tagTextBox.Text = ""
tagTextBox.PlaceholderText = "Ketik custom tag (ex: DJ)"
tagTextBox.Font = Enum.Font.GothamSemibold
tagTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
tagTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 135)
tagTextBox.TextSize = 11

local textCorner = Instance.new("UICorner", tagTextBox)
textCorner.CornerRadius = UDim.new(0, 6)
local textStroke = Instance.new("UIStroke", tagTextBox)
textStroke.Color = Color3.fromRGB(44, 44, 60)
textStroke.Thickness = 1

-- Set Nametag Button
local setBtn = Instance.new("TextButton", controlContainer)
setBtn.Size = UDim2.new(1, 0, 0, 35)
setBtn.Position = UDim2.new(0, 0, 0, 80)
setBtn.BackgroundColor3 = Color3.fromRGB(85, 0, 127) -- Purple neon
setBtn.Text = "SET NAMETAG"
setBtn.Font = Enum.Font.GothamBold
setBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setBtn.TextSize = 11

local setCorner = Instance.new("UICorner", setBtn)
setCorner.CornerRadius = UDim.new(0, 6)

-- Clear Nametag Button
local clearBtn = Instance.new("TextButton", controlContainer)
clearBtn.Size = UDim2.new(1, 0, 0, 35)
clearBtn.Position = UDim2.new(0, 0, 0, 125)
clearBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40) -- Dark Red
clearBtn.Text = "CLEAR NAMETAG"
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.TextSize = 11

local clearCorner = Instance.new("UICorner", clearBtn)
clearCorner.CornerRadius = UDim.new(0, 6)

-- Populate Player List
local function updatePlayerList()
	for _, child in ipairs(pListScroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	for _, p in ipairs(Players:GetPlayers()) do
		local btn = Instance.new("TextButton")
		btn.Name = p.Name
		btn.Size = UDim2.new(1, -6, 0, 30)
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
		btn.Text = p.DisplayName
		btn.Font = Enum.Font.GothamSemibold
		btn.TextColor3 = Color3.fromRGB(245, 245, 250)
		btn.TextSize = 11
		
		local btnCorner = Instance.new("UICorner", btn)
		btnCorner.CornerRadius = UDim.new(0, 6)
		
		local btnStroke = Instance.new("UIStroke", btn)
		btnStroke.Color = Color3.fromRGB(44, 44, 60)
		btnStroke.Thickness = 1
		
		btn.MouseButton1Click:Connect(function()
			selectedPlayer = p
			targetLabel.Text = "Target: " .. p.DisplayName
			
			for _, otherBtn in ipairs(pListScroll:GetChildren()) do
				if otherBtn:IsA("TextButton") then
					otherBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
					otherBtn.UIStroke.Color = Color3.fromRGB(44, 44, 60)
				end
			end
			btn.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
			btn.UIStroke.Color = Color3.fromRGB(255, 255, 255)
		end)
		
		btn.Parent = pListScroll
	end
end

-- Button events
setBtn.MouseButton1Click:Connect(function()
	if not selectedPlayer then
		StarterGui:SetCore("SendNotification", {
			Title = "Gagal",
			Text = "Pilih pemain terlebih dahulu!",
			Duration = 3
		})
		return
	end
	
	local tagText = tagTextBox.Text
	if tagText == "" then
		StarterGui:SetCore("SendNotification", {
			Title = "Gagal",
			Text = "Ketik teks tag terlebih dahulu!",
			Duration = 3
		})
		return
	end
	
	SetNametagEvent:FireServer(selectedPlayer, tagText)
	tagTextBox.Text = ""
	
	StarterGui:SetCore("SendNotification", {
		Title = "Sukses",
		Text = "Nametag target berhasil diupdate!",
		Duration = 3
	})
end)

clearBtn.MouseButton1Click:Connect(function()
	if not selectedPlayer then
		StarterGui:SetCore("SendNotification", {
			Title = "Gagal",
			Text = "Pilih pemain terlebih dahulu!",
			Duration = 3
		})
		return
	end
	
	SetNametagEvent:FireServer(selectedPlayer, nil)
	StarterGui:SetCore("SendNotification", {
		Title = "Sukses",
		Text = "Nametag target berhasil dihapus!",
		Duration = 3
	})
end)

-- Handle player additions/removals
Players.PlayerAdded:Connect(function()
	if panel.Visible then
		updatePlayerList()
	end
end)

Players.PlayerRemoving:Connect(function(p)
	if selectedPlayer == p then
		selectedPlayer = nil
		targetLabel.Text = "Target: None"
	end
	if panel.Visible then
		updatePlayerList()
	end
end)

-- Toggle Menu visibility on P key
UserInputService.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end
	if input.KeyCode == Enum.KeyCode.P then
		if checkAdminAccess() then
			panel.Visible = not panel.Visible
			if panel.Visible then
				updatePlayerList()
			end
		end
	end
end)

print("[Client] Admin Panel active. Press P to open if Admin.")
