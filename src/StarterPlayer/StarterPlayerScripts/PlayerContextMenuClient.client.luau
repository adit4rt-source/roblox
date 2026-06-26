-- ================================================================
--  PlayerContextMenuClient (LocalScript) - NO CHAT EDITION
--  Menu klik pemain: Sync Dance & Tambah Teman
-- ================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local targetPlayer = nil 

local gui = Instance.new("ScreenGui")
gui.Name = "CustomPlayerMenuGui"; gui.ResetOnSpawn = false; gui.Parent = playerGui

local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 180, 0, 0)
menuFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
menuFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
menuFrame.ClipsDescendants = true; menuFrame.Visible = false
menuFrame.Parent = gui

Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", menuFrame).Color = Color3.fromRGB(220,220,220)
Instance.new("UIStroke", menuFrame).Thickness = 2

local listLayout = Instance.new("UIListLayout", menuFrame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

local headerFrame = Instance.new("Frame", menuFrame)
headerFrame.Size = UDim2.new(1, 0, 0, 50); headerFrame.BackgroundColor3 = Color3.new(1,1,1)
headerFrame.LayoutOrder = 1; Instance.new("UIStroke", headerFrame).Color = Color3.fromRGB(220,220,220)

local nameLbl = Instance.new("TextLabel", headerFrame)
nameLbl.Size = UDim2.new(1, -20, 0, 20); nameLbl.Position = UDim2.new(0, 10, 0, 5)
nameLbl.BackgroundTransparency = 1; nameLbl.Font = Enum.Font.GothamBold
nameLbl.TextColor3 = Color3.fromRGB(60,60,60); nameLbl.TextSize = 14; nameLbl.TextXAlignment = Enum.TextXAlignment.Left

local infoLbl = Instance.new("TextLabel", headerFrame)
infoLbl.Size = UDim2.new(1, -20, 0, 15); infoLbl.Position = UDim2.new(0, 10, 0, 25)
infoLbl.BackgroundTransparency = 1; infoLbl.Font = Enum.Font.GothamMedium
infoLbl.TextColor3 = Color3.fromRGB(150, 150, 150); infoLbl.TextSize = 11; infoLbl.TextXAlignment = Enum.TextXAlignment.Left

local function CloseMenu()
	if not menuFrame.Visible then return end
	TweenService:Create(menuFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 180, 0, 0)}):Play()
	task.delay(0.2, function() menuFrame.Visible = false end)
end

local function CreateMenuButton(text, icon, layoutOrder, callback)
	local btn = Instance.new("TextButton", menuFrame)
	btn.Size = UDim2.new(1, 0, 0, 40); btn.BackgroundColor3 = Color3.new(1,1,1)
	btn.BorderSizePixel = 0; btn.Text = ""; btn.LayoutOrder = layoutOrder; btn.AutoButtonColor = false

	local iconLbl = Instance.new("TextLabel", btn)
	iconLbl.Size = UDim2.new(0, 30, 1, 0); iconLbl.Position = UDim2.new(0, 10, 0, 0)
	iconLbl.BackgroundTransparency = 1; iconLbl.Text = icon; iconLbl.TextSize = 16

	local txtLbl = Instance.new("TextLabel", btn)
	txtLbl.Size = UDim2.new(1, -40, 1, 0); txtLbl.Position = UDim2.new(0, 40, 0, 0)
	txtLbl.BackgroundTransparency = 1; txtLbl.Text = text; txtLbl.Font = Enum.Font.GothamSemibold
	txtLbl.TextColor3 = Color3.fromRGB(60,60,60); txtLbl.TextSize = 13; txtLbl.TextXAlignment = Enum.TextXAlignment.Left

	btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(245,245,245)}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(1,1,1)}):Play() end)
	btn.MouseButton1Click:Connect(function() if targetPlayer then callback(targetPlayer); CloseMenu() end end)

	return btn
end

CreateMenuButton("Ikuti Joget", "??", 2, function(tgt)
	local reqSyncEvent = playerGui:FindFirstChild("ReqSyncDance")
	if not reqSyncEvent then 
		reqSyncEvent = Instance.new("BindableEvent")
		reqSyncEvent.Name = "ReqSyncDance"
		reqSyncEvent.Parent = playerGui 
	end
	reqSyncEvent:Fire(tgt)
end)

CreateMenuButton("Berhenti Joget", "??", 3, function(tgt)
	local myHum = player.Character and player.Character:FindFirstChild("Humanoid")
	if myHum then
		local animator = myHum:FindFirstChildWhichIsA("Animator")
		if animator then 
			for _, a in ipairs(animator:GetPlayingAnimationTracks()) do a:Stop() end 
		end
		ReplicatedStorage:WaitForChild("Syncing"):WaitForChild("UnSync"):FireServer()
		player.Character:SetAttribute("CurrentDanceID", nil)
	end
end)

local addFriendBtn = CreateMenuButton("Tambah Teman", "?", 4, function(tgt)
	local ReqFriend = ReplicatedStorage:WaitForChild("Remotes"):FindFirstChild("ReqFriendEvent")
	if ReqFriend then 
		ReqFriend:FireServer(tgt)
		StarterGui:SetCore("SendNotification", {Title = "Terkirim", Text = "Menunggu persetujuan " .. tgt.Name, Duration = 3})
	end
end)

local function OpenMenu(tgtPlayer, clickPos)
	targetPlayer = tgtPlayer
	nameLbl.Text = tgtPlayer.DisplayName
	local ls = tgtPlayer:FindFirstChild("leaderstats")
	infoLbl.Text = "💸 Spent: R$ " .. (ls and ls:FindFirstChild("Spent") and ls.Spent.Value or 0)

	local friendFolder = player:FindFirstChild("FriendList")
	if friendFolder and friendFolder:FindFirstChild(tostring(tgtPlayer.UserId)) then
		addFriendBtn.Visible = false
	else
		addFriendBtn.Visible = true
	end

	menuFrame.Size = UDim2.new(0, 180, 0, 0)
	task.wait()
	local targetHeight = listLayout.AbsoluteContentSize.Y

	local screenSize = camera.ViewportSize
	menuFrame.Position = UDim2.new(0, math.clamp(clickPos.X + 100, 100, screenSize.X - 100), 0, math.clamp(clickPos.Y, 100, screenSize.Y - 150))
	menuFrame.Visible = true
	TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 180, 0, targetHeight)}):Play()
end

UserInputService.InputBegan:Connect(function(input, isProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if isProcessed then return end
		local target = mouse.Target
		if target then
			local model = target:FindFirstAncestorOfClass("Model")
			if model and model:FindFirstChild("Humanoid") then
				local clickedPlayer = Players:GetPlayerFromCharacter(model)
				if clickedPlayer and clickedPlayer ~= player then OpenMenu(clickedPlayer, input.Position); return end
			end
		end
		CloseMenu()
	end
end)