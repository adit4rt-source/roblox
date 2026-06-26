-- ================================================================
--  NotificationManager (LocalScript)
--  Taruh di: StarterPlayer > StarterPlayerScripts
--  ? Sistem Notifikasi Toast Modern (Muncul dari kanan bawah)
-- ================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Membuat Event Bindable Global untuk Notifikasi
local notifEvent = ReplicatedStorage:FindFirstChild("CustomNotification")
if not notifEvent then
	notifEvent = Instance.new("BindableEvent")
	notifEvent.Name = "CustomNotification"
	notifEvent.Parent = ReplicatedStorage
end

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "ModernNotificationGui"
gui.ResetOnSpawn = false

-- Kontainer di kanan bawah layar
local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0, 300, 1, -40)
container.Position = UDim2.new(1, -20, 0, 20)
container.AnchorPoint = Vector2.new(1, 0)
container.BackgroundTransparency = 1

local listLayout = Instance.new("UIListLayout", container)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
listLayout.Padding = UDim.new(0, 10)

notifEvent.Event:Connect(function(config)
	local title = config.Title or "Notifikasi"
	local text = config.Text or ""
	local duration = config.Duration or 3
	local color = config.Color or Color3.fromRGB(241, 196, 15)

	-- CanvasGroup agar efek transparansinya memudar dengan sempurna
	local toast = Instance.new("CanvasGroup")
	toast.Size = UDim2.new(1, 0, 0, 65)
	toast.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	toast.GroupTransparency = 1 -- Awalnya transparan
	Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke", toast)
	stroke.Color = Color3.fromRGB(220, 220, 220)
	stroke.Thickness = 2

	local accent = Instance.new("Frame", toast)
	accent.Size = UDim2.new(0, 6, 1, 0)
	accent.BackgroundColor3 = color
	accent.BorderSizePixel = 0

	local titleLbl = Instance.new("TextLabel", toast)
	titleLbl.Size = UDim2.new(1, -20, 0, 20)
	titleLbl.Position = UDim2.new(0, 15, 0, 10)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = title
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextColor3 = color
	titleLbl.TextSize = 14
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left

	local descLbl = Instance.new("TextLabel", toast)
	descLbl.Size = UDim2.new(1, -20, 0, 25)
	descLbl.Position = UDim2.new(0, 15, 0, 30)
	descLbl.BackgroundTransparency = 1
	descLbl.Text = text
	descLbl.Font = Enum.Font.GothamMedium
	descLbl.TextColor3 = Color3.fromRGB(100, 100, 100)
	descLbl.TextSize = 12
	descLbl.TextXAlignment = Enum.TextXAlignment.Left
	descLbl.TextWrapped = true

	toast.Parent = container

	-- Animasi MUNCUL (Fade In)
	TweenService:Create(toast, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()

	-- Tunggu sesuai durasi, lalu MENGHILANG (Fade Out)
	task.delay(duration, function()
		local fadeOut = TweenService:Create(toast, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1})
		fadeOut:Play()
		fadeOut.Completed:Wait()
		toast:Destroy()
	end)
end)