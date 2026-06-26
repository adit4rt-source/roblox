local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ChatEvent = Remotes:WaitForChild("PrivateChatEvent")

local openChatEvent = Remotes:FindFirstChild("OpenPrivateChatUI") or Instance.new("BindableEvent", Remotes)
openChatEvent.Name = "OpenPrivateChatUI"

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "CustomMessengerGui"; gui.ResetOnSpawn = false

-- ==========================================
-- 1. BANGUN UI MESSENGER
-- ==========================================
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 600, 0, 380); mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(250, 250, 250); mainFrame.Visible = false; mainFrame.ClipsDescendants = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10); Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(220, 220, 220); Instance.new("UIStroke", mainFrame).Thickness = 2

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 28, 0, 28); closeBtn.Position = UDim2.new(1, -38, 0, 10); closeBtn.Text = "X"; closeBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
closeBtn.TextColor3 = Color3.new(1,1,1); closeBtn.Font = Enum.Font.GothamBold; closeBtn.ZIndex = 10; Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

local leftPanel = Instance.new("Frame", mainFrame)
leftPanel.Size = UDim2.new(0, 180, 1, 0); leftPanel.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
local lTitle = Instance.new("TextLabel", leftPanel)
lTitle.Size = UDim2.new(1, 0, 0, 50); lTitle.Text = "?? FRIEND LIST"; lTitle.Font = Enum.Font.GothamBlack; lTitle.BackgroundTransparency = 1; lTitle.TextColor3 = Color3.fromRGB(60,60,60); lTitle.TextSize = 13
Instance.new("UIStroke", lTitle).Color = Color3.fromRGB(220,220,220)
local fScroll = Instance.new("ScrollingFrame", leftPanel)
fScroll.Size = UDim2.new(1, -10, 1, -60); fScroll.Position = UDim2.new(0, 5, 0, 55); fScroll.BackgroundTransparency = 1; fScroll.ScrollBarThickness = 2
local fLayout = Instance.new("UIListLayout", fScroll); fLayout.Padding = UDim.new(0, 5)

local rightPanel = Instance.new("Frame", mainFrame)
rightPanel.Size = UDim2.new(1, -180, 1, 0); rightPanel.Position = UDim2.new(0, 180, 0, 0); rightPanel.BackgroundTransparency = 1
local rHeader = Instance.new("Frame", rightPanel)
rHeader.Size = UDim2.new(1, 0, 0, 50); rHeader.BackgroundColor3 = Color3.new(1,1,1)
Instance.new("UIStroke", rHeader).Color = Color3.fromRGB(220,220,220)

local targetAvatar = Instance.new("ImageLabel", rHeader)
targetAvatar.Size = UDim2.new(0, 34, 0, 34); targetAvatar.Position = UDim2.new(0, 15, 0, 8); targetAvatar.BackgroundColor3 = Color3.fromRGB(220,220,220)
Instance.new("UICorner", targetAvatar).CornerRadius = UDim.new(1, 0)
local targetName = Instance.new("TextLabel", rHeader)
targetName.Size = UDim2.new(1, -70, 1, 0); targetName.Position = UDim2.new(0, 60, 0, 0); targetName.Text = "Pilih Teman..."; targetName.Font = Enum.Font.GothamBold; targetName.TextSize = 14; targetName.BackgroundTransparency = 1; targetName.TextXAlignment = Enum.TextXAlignment.Left; targetName.TextColor3 = Color3.fromRGB(60,60,60)

local msgScroll = Instance.new("ScrollingFrame", rightPanel)
msgScroll.Size = UDim2.new(1, -20, 1, -110); msgScroll.Position = UDim2.new(0, 10, 0, 55); msgScroll.BackgroundTransparency = 1; msgScroll.ScrollBarThickness = 4
local mLayout = Instance.new("UIListLayout", msgScroll); mLayout.Padding = UDim.new(0, 8); mLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

local inputArea = Instance.new("Frame", rightPanel)
inputArea.Size = UDim2.new(1, -20, 0, 40); inputArea.Position = UDim2.new(0, 10, 1, -50); inputArea.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
Instance.new("UICorner", inputArea).CornerRadius = UDim.new(0, 8)
local txtBox = Instance.new("TextBox", inputArea)
txtBox.Size = UDim2.new(1, -60, 1, 0); txtBox.Position = UDim2.new(0, 10, 0, 0); txtBox.BackgroundTransparency = 1; txtBox.PlaceholderText = "Ketik pesan..."; txtBox.Text = ""; txtBox.Font = Enum.Font.GothamMedium; txtBox.TextSize = 12; txtBox.TextXAlignment = Enum.TextXAlignment.Left; txtBox.ClearTextOnFocus = false
local sendBtn = Instance.new("TextButton", inputArea)
sendBtn.Size = UDim2.new(0, 40, 0, 30); sendBtn.Position = UDim2.new(1, -45, 0, 5); sendBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219); sendBtn.Text = "?"; sendBtn.TextColor3 = Color3.new(1,1,1); sendBtn.Font = Enum.Font.GothamBold; sendBtn.TextSize = 14
Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 2. NOTIFIKASI KECIL & RAPI
-- ==========================================
local notifBtn = Instance.new("TextButton", gui)
notifBtn.Size = UDim2.new(0, 200, 0, 45); notifBtn.Position = UDim2.new(1, 250, 1, -150)
notifBtn.AnchorPoint = Vector2.new(1, 1); notifBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
notifBtn.AutoButtonColor = false; notifBtn.Text = ""
Instance.new("UICorner", notifBtn).CornerRadius = UDim.new(0, 8)
local notifStroke = Instance.new("UIStroke", notifBtn); notifStroke.Color = Color3.fromRGB(220, 220, 220); notifStroke.Thickness = 2

local notifAva = Instance.new("ImageLabel", notifBtn)
notifAva.Size = UDim2.new(0, 28, 0, 28); notifAva.Position = UDim2.new(0, 8, 0, 8)
notifAva.BackgroundColor3 = Color3.fromRGB(230, 230, 230); Instance.new("UICorner", notifAva).CornerRadius = UDim.new(1, 0)

local notifTitle = Instance.new("TextLabel", notifBtn)
notifTitle.Size = UDim2.new(1, -50, 0, 16); notifTitle.Position = UDim2.new(0, 45, 0, 6)
notifTitle.BackgroundTransparency = 1; notifTitle.Font = Enum.Font.GothamBold; notifTitle.TextColor3 = Color3.fromRGB(52, 152, 219); notifTitle.TextSize = 12; notifTitle.TextXAlignment = Enum.TextXAlignment.Left

local notifDesc = Instance.new("TextLabel", notifBtn)
notifDesc.Size = UDim2.new(1, -50, 0, 14); notifDesc.Position = UDim2.new(0, 45, 0, 22)
notifDesc.BackgroundTransparency = 1; notifDesc.Font = Enum.Font.GothamMedium; notifDesc.TextColor3 = Color3.fromRGB(120, 120, 120); notifDesc.TextSize = 10; notifDesc.TextXAlignment = Enum.TextXAlignment.Left; notifDesc.TextTruncate = Enum.TextTruncate.AtEnd

local currentNotifSender = nil

notifBtn.MouseButton1Click:Connect(function()
	if currentNotifSender then
		openChatEvent:Fire(currentNotifSender)
		TweenService:Create(notifBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 250, 1, -150)}):Play()
	end
end)

local function ShowChatNotif(sender, text)
	currentNotifSender = sender
	notifTitle.Text = "?? " .. sender.Name
	notifDesc.Text = text

	-- Ambil foto avatar
	local content = Players:GetUserThumbnailAsync(sender.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	notifAva.Image = content

	TweenService:Create(notifBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 1, -150)}):Play()

	task.delay(5, function()
		if currentNotifSender == sender then
			TweenService:Create(notifBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 250, 1, -150)}):Play()
		end
	end)
end

-- ==========================================
-- 3. LOGIKA CHAT & RENDER
-- ==========================================
local chatHistory = {} 
local activeChatUserId = nil

local function RenderMessages(userId)
	for _, child in pairs(msgScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
	if not chatHistory[userId] then return end

	for _, msg in ipairs(chatHistory[userId]) do
		local isMe = (msg.senderId == player.UserId)
		local b = Instance.new("Frame", msgScroll)
		b.Size = UDim2.new(1, 0, 0, 30); b.BackgroundTransparency = 1

		local bubble = Instance.new("TextLabel", b)
		bubble.Size = UDim2.new(0.7, 0, 1, 0); bubble.Text = msg.txt; bubble.Font = Enum.Font.GothamMedium; bubble.TextSize = 12; bubble.TextWrapped = true; bubble.BackgroundColor3 = isMe and Color3.fromRGB(52, 152, 219) or Color3.fromRGB(220, 220, 220)
		bubble.TextColor3 = isMe and Color3.new(1,1,1) or Color3.fromRGB(60,60,60)
		Instance.new("UICorner", bubble).CornerRadius = UDim.new(0, 8)

		local textBounds = game.TextService:GetTextSize(msg.txt, 12, Enum.Font.GothamMedium, Vector2.new(msgScroll.AbsoluteSize.X * 0.7, 1000))
		b.Size = UDim2.new(1, 0, 0, textBounds.Y + 16)
		bubble.Size = UDim2.new(0, textBounds.X + 20, 1, 0)

		if isMe then bubble.AnchorPoint = Vector2.new(1, 0); bubble.Position = UDim2.new(1, -5, 0, 0) else bubble.Position = UDim2.new(0, 5, 0, 0) end
	end
	task.wait(0.05); msgScroll.CanvasPosition = Vector2.new(0, msgScroll.AbsoluteWindowSize.Y + 1000)
end

local function SendMsg()
	if not activeChatUserId or txtBox.Text == "" then return end
	local text = txtBox.Text; txtBox.Text = ""

	if not chatHistory[activeChatUserId] then chatHistory[activeChatUserId] = {} end
	table.insert(chatHistory[activeChatUserId], {senderId = player.UserId, txt = text})
	RenderMessages(activeChatUserId)
	ChatEvent:FireServer(activeChatUserId, text)
end
sendBtn.MouseButton1Click:Connect(SendMsg)
txtBox.FocusLost:Connect(function(enterPressed) if enterPressed then SendMsg() end end)

ChatEvent.OnClientEvent:Connect(function(sender, text)
	if not chatHistory[sender.UserId] then chatHistory[sender.UserId] = {} end
	table.insert(chatHistory[sender.UserId], {senderId = sender.UserId, txt = text})

	if activeChatUserId == sender.UserId and mainFrame.Visible then
		RenderMessages(sender.UserId)
	else
		ShowChatNotif(sender, text)
	end
end)

openChatEvent.Event:Connect(function(tgtPlayer)
	mainFrame.Visible = true
	activeChatUserId = tgtPlayer.UserId
	targetName.Text = tgtPlayer.DisplayName

	-- Ambil foto avatar utama
	local content = Players:GetUserThumbnailAsync(tgtPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	targetAvatar.Image = content

	for _, child in pairs(fScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
	local friendFolder = player:FindFirstChild("FriendList")
	if friendFolder then
		for _, fVal in ipairs(friendFolder:GetChildren()) do
			local uid = fVal.Value
			local pInfo = Players:GetPlayerByUserId(uid)
			if pInfo then
				local fBtn = Instance.new("TextButton", fScroll)
				fBtn.Size = UDim2.new(1, 0, 0, 45); fBtn.BackgroundColor3 = Color3.new(1,1,1); fBtn.Text = ""
				Instance.new("UICorner", fBtn).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", fBtn).Color = Color3.fromRGB(220,220,220)

				-- Ambil foto avatar List
				local avaContent = Players:GetUserThumbnailAsync(uid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)

				local ava = Instance.new("ImageLabel", fBtn)
				ava.Size = UDim2.new(0, 30, 0, 30); ava.Position = UDim2.new(0, 5, 0, 7); ava.BackgroundColor3 = Color3.fromRGB(200,200,200); ava.Image = avaContent
				Instance.new("UICorner", ava).CornerRadius = UDim.new(1,0)

				local nL = Instance.new("TextLabel", fBtn)
				nL.Size = UDim2.new(1, -45, 1, 0); nL.Position = UDim2.new(0, 40, 0, 0); nL.Text = pInfo.DisplayName; nL.Font = Enum.Font.GothamSemibold; nL.TextSize = 11; nL.BackgroundTransparency = 1; nL.TextXAlignment = Enum.TextXAlignment.Left; nL.TextColor3 = Color3.fromRGB(60,60,60)

				fBtn.MouseButton1Click:Connect(function()
					activeChatUserId = pInfo.UserId; targetName.Text = pInfo.DisplayName; targetAvatar.Image = avaContent; RenderMessages(pInfo.UserId)
				end)
			end
		end
	end
	RenderMessages(activeChatUserId)
end)