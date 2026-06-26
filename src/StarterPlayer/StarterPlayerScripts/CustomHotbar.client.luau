-- ================================================================
--  Custom Hotbar & Full Backpack System (LocalScript)
--  ? ULTIMATE VERSION: Slot Utama (1-9) + Kapasitas Maksimal (54 Slot)
-- ================================================================

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) end)

local MAX_HOTBAR = 9
local MAX_INV = 54 -- ?? KAPASITAS DITAMBAH AGAR FULL TANPA RUANG KOSONG!
local IGNORED_TOOLS = { ["SapuTerbang"] = true }

-- Palet Warna Modern Dark
local COLOR_BG_TAS = Color3.fromRGB(35, 38, 45)       
local COLOR_BG_BOTTOM = Color3.fromRGB(20, 22, 28) 
local COLOR_SLOT_IDLE = Color3.fromRGB(65, 70, 80)    
local COLOR_SLOT_HOVER = Color3.fromRGB(85, 90, 105)  
local COLOR_SLOT_EQUIP = Color3.fromRGB(100, 110, 125) 
local COLOR_STROKE = Color3.fromRGB(120, 125, 135)    
local COLOR_EQUIP_STROKE = Color3.fromRGB(241, 196, 15) 

local gui = Instance.new("ScreenGui")
gui.Name = "CustomInventoryGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- === 1. HOTBAR BAWAH (HUD LAYAR UTAMA) ===
local hotbarFrame = Instance.new("Frame")
hotbarFrame.Name = "HotbarFrame"
hotbarFrame.Size = UDim2.new(0, 560, 0, 60) 
hotbarFrame.Position = UDim2.new(0.5, -280, 1, -80)
hotbarFrame.BackgroundTransparency = 1
hotbarFrame.Parent = gui

local hotbarLayout = Instance.new("UIListLayout")
hotbarLayout.FillDirection = Enum.FillDirection.Horizontal
hotbarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
hotbarLayout.SortOrder = Enum.SortOrder.LayoutOrder
hotbarLayout.Padding = UDim.new(0, 8)
hotbarLayout.Parent = hotbarFrame

-- === 2. TAS FULL INVENTORY ===
local invFrame = Instance.new("Frame")
invFrame.Name = "FullInventoryFrame"
-- ?? Frame dipertinggi sedikit agar 5 baris pas sempurna
invFrame.Size = UDim2.new(0, 580, 0, 460) 
invFrame.Position = UDim2.new(0.5, -290, 0.5, -230)
invFrame.BackgroundColor3 = COLOR_BG_TAS
invFrame.BackgroundTransparency = 0.05
invFrame.Visible = false
invFrame.Parent = gui

Instance.new("UICorner", invFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", invFrame).Color = COLOR_STROKE
Instance.new("UIStroke", invFrame).Thickness = 2

local invScale = Instance.new("UIScale", invFrame)
invScale.Scale = 0 

local invTitle = Instance.new("TextLabel")
invTitle.Size = UDim2.new(1, 0, 0, 45)
invTitle.BackgroundTransparency = 1
invTitle.Text = "?? BACKPACK"
invTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
invTitle.Font = Enum.Font.GothamBlack
invTitle.TextSize = 18
invTitle.Parent = invFrame

local closeBtn = Instance.new("TextButton", invFrame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- CONTAINER ATAS (GRID SISA BARANG)
local invContainer = Instance.new("ScrollingFrame")
invContainer.Size = UDim2.new(1, -20, 1, -135) 
invContainer.Position = UDim2.new(0, 10, 0, 45)
invContainer.BackgroundTransparency = 1
invContainer.ScrollBarThickness = 5
invContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
invContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
invContainer.Parent = invFrame

local invLayout = Instance.new("UIGridLayout")
invLayout.CellSize = UDim2.new(0, 55, 0, 55)
invLayout.CellPadding = UDim2.new(0, 8, 0, 8)
invLayout.SortOrder = Enum.SortOrder.LayoutOrder
invLayout.Parent = invContainer

-- ?? KOTAK BAWAH (SLOT UTAMA 1-9 DI DALAM TAS) ??
local invHotbarFrame = Instance.new("Frame")
invHotbarFrame.Name = "InvHotbarFrame"
invHotbarFrame.Size = UDim2.new(1, -20, 0, 75)
invHotbarFrame.Position = UDim2.new(0, 10, 1, -85)
invHotbarFrame.BackgroundColor3 = COLOR_BG_BOTTOM
invHotbarFrame.Parent = invFrame
Instance.new("UICorner", invHotbarFrame).CornerRadius = UDim.new(0, 8)
local bottomStroke = Instance.new("UIStroke", invHotbarFrame)
bottomStroke.Color = Color3.fromRGB(15, 15, 15) 
bottomStroke.Thickness = 3

local invHotbarLayout = Instance.new("UIListLayout")
invHotbarLayout.FillDirection = Enum.FillDirection.Horizontal
invHotbarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
invHotbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
invHotbarLayout.SortOrder = Enum.SortOrder.LayoutOrder
invHotbarLayout.Padding = UDim.new(0, 7)
invHotbarLayout.Parent = invHotbarFrame

-- ==========================================
-- SISTEM SLOT & DRAG DROP
-- ==========================================
local dragGhost = Instance.new("ImageLabel")
dragGhost.Size = UDim2.new(0, 45, 0, 45)
dragGhost.BackgroundTransparency = 1
dragGhost.ScaleType = Enum.ScaleType.Fit
dragGhost.Visible = false
dragGhost.ZIndex = 100
dragGhost.Parent = gui

local hotbarSlotsUI = {}; local invSlotsUI = {}; local itemData = {}
local draggingSlot = nil; local hoveredSlot = nil; local dragStartPos = nil
local toggleEquip

local function createSlotUI(index, parent, showNumber)
	local slot = Instance.new("TextButton")
	slot.Name = "Slot" .. index
	slot.LayoutOrder = index
	slot.BackgroundColor3 = COLOR_SLOT_IDLE
	slot.BackgroundTransparency = 0.1
	slot.Text = ""
	slot.AutoButtonColor = false
	slot.Parent = parent

	local scale = Instance.new("UIScale", slot)
	scale.Scale = 1

	Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", slot)
	stroke.Color = COLOR_STROKE
	stroke.Thickness = 2

	if showNumber then
		local numLabel = Instance.new("TextLabel")
		numLabel.Size = UDim2.new(0, 15, 0, 15)
		numLabel.Position = UDim2.new(0, 4, 0, 4)
		numLabel.BackgroundTransparency = 1
		numLabel.Text = tostring(index)
		numLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		numLabel.Font = Enum.Font.GothamBold
		numLabel.TextSize = 11
		numLabel.ZIndex = 2
		numLabel.Parent = slot
	end

	local iconImage = Instance.new("ImageLabel")
	iconImage.Size = UDim2.new(0.65, 0, 0.65, 0)
	iconImage.Position = UDim2.new(0.175, 0, 0.05, 0)
	iconImage.BackgroundTransparency = 1
	iconImage.ScaleType = Enum.ScaleType.Fit
	iconImage.Visible = false
	iconImage.Parent = slot

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -4, 0.35, 0)
	nameLabel.Position = UDim2.new(0, 2, 0.65, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = ""
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.GothamSemibold
	nameLabel.TextSize = 10
	nameLabel.TextWrapped = true
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.ZIndex = 2
	nameLabel.Parent = slot

	slot.MouseEnter:Connect(function() 
		hoveredSlot = index 
		if itemData[index] and itemData[index].Parent == char then return end 
		TweenService:Create(slot, TweenInfo.new(0.15), {BackgroundColor3 = COLOR_SLOT_HOVER}):Play()
	end)

	slot.MouseLeave:Connect(function() 
		if hoveredSlot == index then hoveredSlot = nil end 
		if itemData[index] and itemData[index].Parent == char then return end 
		TweenService:Create(slot, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_SLOT_IDLE}):Play()
	end)

	slot.InputBegan:Connect(function(input) 
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and itemData[index] then 
			draggingSlot = index; dragStartPos = input.Position 
		end 
	end)

	slot.InputEnded:Connect(function(input) 
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and draggingSlot == index then 
			if (input.Position - dragStartPos).Magnitude < 10 then 
				toggleEquip(index) 
			end 
		end 
	end)

	return { Button = slot, NameLabel = nameLabel, Icon = iconImage, Stroke = stroke, Scale = scale }
end

-- GENERATE SLOTS
for i = 1, MAX_INV do
	itemData[i] = nil
	if i <= MAX_HOTBAR then
		hotbarSlotsUI[i] = createSlotUI(i, hotbarFrame, true)
		hotbarSlotsUI[i].Button.Size = UDim2.new(0, 55, 0, 55)

		invSlotsUI[i] = createSlotUI(i, invHotbarFrame, true)
		invSlotsUI[i].Button.Size = UDim2.new(0, 55, 0, 55)
	else
		invSlotsUI[i] = createSlotUI(i, invContainer, false)
	end
end

UserInputService.InputChanged:Connect(function(input)
	if draggingSlot and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		if (input.Position - dragStartPos).Magnitude >= 10 then
			if not dragGhost.Visible then
				local tool = itemData[draggingSlot]
				dragGhost.Image = (tool and tool.TextureId and tool.TextureId ~= "") and tool.TextureId or ""
				dragGhost.Visible = true
			end
			dragGhost.Position = UDim2.new(0, input.Position.X - 22, 0, input.Position.Y - 22)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if draggingSlot and dragGhost.Visible and hoveredSlot and hoveredSlot ~= draggingSlot then
			local temp = itemData[draggingSlot]
			itemData[draggingSlot] = itemData[hoveredSlot]
			itemData[hoveredSlot] = temp
			refreshUI()
		end
		draggingSlot = nil
		dragGhost.Visible = false
	end
end)

local function updateSlotVisual(uiElement, tool)
	if tool and tool.Parent then
		uiElement.NameLabel.Text = tool.Name
		if tool.TextureId and tool.TextureId ~= "" then 
			uiElement.Icon.Image = tool.TextureId
			uiElement.Icon.Visible = true 
		else 
			uiElement.Icon.Visible = false 
		end

		if tool.Parent == char then 
			uiElement.Stroke.Color = COLOR_EQUIP_STROKE
			uiElement.Stroke.Thickness = 2.5
			uiElement.Button.BackgroundColor3 = COLOR_SLOT_EQUIP 
		else 
			uiElement.Stroke.Color = COLOR_STROKE
			uiElement.Stroke.Thickness = 2
			if hoveredSlot == uiElement.Button.LayoutOrder then
				uiElement.Button.BackgroundColor3 = COLOR_SLOT_HOVER
			else
				uiElement.Button.BackgroundColor3 = COLOR_SLOT_IDLE 
			end
		end
	else
		uiElement.NameLabel.Text = ""
		uiElement.Icon.Visible = false
		uiElement.Stroke.Color = COLOR_STROKE
		uiElement.Stroke.Thickness = 2
		uiElement.Button.BackgroundColor3 = COLOR_SLOT_IDLE
	end
end

function refreshUI()
	for i = 1, MAX_INV do 
		updateSlotVisual(invSlotsUI[i], itemData[i]) 
		if i <= MAX_HOTBAR then updateSlotVisual(hotbarSlotsUI[i], itemData[i]) end 
	end
end

local function toolAdded(tool)
	if not tool:IsA("Tool") or IGNORED_TOOLS[tool.Name] then return end
	for i = 1, MAX_INV do if itemData[i] == tool then refreshUI() return end end
	for i = 1, MAX_INV do if itemData[i] == nil then itemData[i] = tool; refreshUI() return end end
end

local function toolRemoved(tool)
	if not tool:IsA("Tool") or IGNORED_TOOLS[tool.Name] then return end
	task.wait() 
	if tool.Parent == player.Backpack or tool.Parent == char then 
		refreshUI() 
	else 
		for i = 1, MAX_INV do 
			if itemData[i] == tool then itemData[i] = nil; refreshUI() return end 
		end 
	end
end

toggleEquip = function(slotIndex)
	local tool = itemData[slotIndex]
	if not tool then return end
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	if tool.Parent == char then hum:UnequipTools() else hum:EquipTool(tool) end

	local function playBounce(scaleObj)
		if scaleObj then
			TweenService:Create(scaleObj, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Scale = 0.85}):Play()
			task.delay(0.1, function() TweenService:Create(scaleObj, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play() end)
		end
	end

	playBounce(invSlotsUI[slotIndex].Scale)
	if slotIndex <= MAX_HOTBAR then playBounce(hotbarSlotsUI[slotIndex].Scale) end
end

local bpAddConn, bpRemConn, charAddConn, charRemConn
local function setupListeners()
	if bpAddConn then bpAddConn:Disconnect() end
	if bpRemConn then bpRemConn:Disconnect() end
	if charAddConn then charAddConn:Disconnect() end
	if charRemConn then charRemConn:Disconnect() end

	local backpack = player:WaitForChild("Backpack")
	for _, tool in pairs(backpack:GetChildren()) do toolAdded(tool) end
	if char then for _, tool in pairs(char:GetChildren()) do toolAdded(tool) end end

	bpAddConn = backpack.ChildAdded:Connect(toolAdded)
	bpRemConn = backpack.ChildRemoved:Connect(toolRemoved)
	if char then 
		charAddConn = char.ChildAdded:Connect(toolAdded)
		charRemConn = char.ChildRemoved:Connect(toolRemoved) 
	end
end

player.CharacterAdded:Connect(function(newChar)
	char = newChar; for i = 1, MAX_INV do itemData[i] = nil end; refreshUI(); setupListeners()
end)
setupListeners()

-- ================================================================
--  ANIMASI BUKA/TUTUP INVENTORY (BOUNCY POP-UP)
-- ================================================================
local isInvOpen = false
local function ToggleInventory()
	isInvOpen = not isInvOpen
	if isInvOpen then
		invFrame.Visible = true
		TweenService:Create(invScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	else
		TweenService:Create(invScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0}):Play()
		task.delay(0.25, function() if not isInvOpen then invFrame.Visible = false end end)
	end
end

closeBtn.MouseButton1Click:Connect(ToggleInventory)

local toggleInvEvent = playerGui:FindFirstChild("ToggleInventoryUI")
if not toggleInvEvent then
	toggleInvEvent = Instance.new("BindableEvent")
	toggleInvEvent.Name = "ToggleInventoryUI"
	toggleInvEvent.Parent = playerGui
end
toggleInvEvent.Event:Connect(ToggleInventory)

UserInputService.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end
	if input.KeyCode == Enum.KeyCode.Backquote then ToggleInventory() end
	if input.KeyCode.Value >= Enum.KeyCode.One.Value and input.KeyCode.Value <= Enum.KeyCode.Nine.Value then 
		toggleEquip(input.KeyCode.Value - Enum.KeyCode.One.Value + 1) 
	end
end)