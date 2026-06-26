--[[
	MusicPlayerClient.client.luau
	Client script untuk memutar musik secara lokal (Volume per user, transisi DJ halus).
	Membangun UI Music Player premium dengan glassmorphism hitam & neon border.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MusicDatabase = require(ReplicatedStorage:WaitForChild("MusicDatabase"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local MusicEvent = Remotes:WaitForChild("MusicEvent")

-- Clean up existing GUI if any
if playerGui:FindFirstChild("MusicPlayerGui") then
	playerGui.MusicPlayerGui:Destroy()
end

-- ScreenGui Setup
local gui = Instance.new("ScreenGui")
gui.Name = "MusicPlayerGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Enabled = false
gui.Parent = playerGui

-- Styling Constants
local COLOR_BG = Color3.fromRGB(15, 15, 22)
local COLOR_CARD_BG = Color3.fromRGB(25, 25, 36)
local COLOR_STROKE = Color3.fromRGB(44, 44, 60)
local COLOR_NEON = Color3.fromRGB(130, 0, 180) -- Purple neon
local COLOR_TEXT = Color3.fromRGB(245, 245, 250)
local COLOR_TEXT_DIM = Color3.fromRGB(150, 150, 165)

-- State Variables
local currentSongData = nil
local activeLocalSound = nil
local clientVolume = 0.5 -- Default local volume (50%)
local isGuiOpen = false
local currentTab = "Home"
local currentSelectedCollection = "All Tracks"
local lastSearchText = ""

-- ================================================================
-- AUDIO SYSTEM (LOCAL PLAYBACK + DJ SMOOTH CROSSFADE)
-- ================================================================
local function playLocalTrack(songId, startTime, duration)
	-- Crossfade duration: 2 seconds
	local fadeTime = 2.0
	
	local newSound = Instance.new("Sound")
	newSound.Name = "ClientMusicTrack_" .. songId
	newSound.SoundId = "rbxassetid://" .. songId
	newSound.Volume = 0
	newSound.Parent = SoundService
	
	-- Calculate elapsed start position
	local elapsed = Workspace:GetServerTimeNow() - startTime
	if elapsed > 0 then
		newSound.TimePosition = math.min(elapsed, duration)
	end
	
	newSound:Play()
	
	-- Transition crossfade
	local oldSound = activeLocalSound
	activeLocalSound = newSound
	
	if oldSound then
		TweenService:Create(oldSound, TweenInfo.new(fadeTime, Enum.EasingStyle.Linear), {Volume = 0}):Play()
		task.delay(fadeTime, function()
			oldSound:Stop()
			oldSound:Destroy()
		end)
	end
	
	TweenService:Create(newSound, TweenInfo.new(fadeTime, Enum.EasingStyle.Linear), {Volume = clientVolume}):Play()
end

local function stopLocalTrack()
	if activeLocalSound then
		local oldSound = activeLocalSound
		activeLocalSound = nil
		TweenService:Create(oldSound, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {Volume = 0}):Play()
		task.delay(1.5, function()
			oldSound:Stop()
			oldSound:Destroy()
		end)
	end
end

-- ================================================================
-- GLASSMORPHISM MAIN FRAME
-- ================================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 780, 0, 480)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = COLOR_BG
mainFrame.BackgroundTransparency = 0.15
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = COLOR_NEON
mainStroke.Thickness = 2

-- Draggable Logic
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		updateDrag(input)
	end
end)

-- ================================================================
-- HEADER & NAVIGATION
-- ================================================================
local header = Instance.new("Frame", mainFrame)
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundTransparency = 1

local titleLbl = Instance.new("TextLabel", header)
titleLbl.Size = UDim2.new(0.3, 0, 1, 0)
titleLbl.Position = UDim2.new(0, 20, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "MUSIC SYSTEM"
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextColor3 = COLOR_TEXT
titleLbl.TextSize = 15
titleLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Navigation Bar in the middle (Sliding Pill style)
local navBar = Instance.new("Frame", header)
navBar.Name = "NavBar"
navBar.Size = UDim2.new(0, 180, 0, 30)
navBar.Position = UDim2.new(0.5, 0, 0.5, 0)
navBar.AnchorPoint = Vector2.new(0.5, 0.5)
navBar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
local navCorner = Instance.new("UICorner", navBar)
navCorner.CornerRadius = UDim.new(0, 8)
local navStroke = Instance.new("UIStroke", navBar)
navStroke.Color = COLOR_STROKE
navStroke.Thickness = 1

-- Sliding Pill Highlight Frame
local navPill = Instance.new("Frame", navBar)
navPill.Name = "NavPill"
navPill.Size = UDim2.new(0.5, -4, 1, -4)
navPill.Position = UDim2.new(0, 2, 0, 2)
navPill.BackgroundColor3 = COLOR_NEON
local pillCorner = Instance.new("UICorner", navPill)
pillCorner.CornerRadius = UDim.new(0, 6)

local btnHome = Instance.new("TextButton", navBar)
btnHome.Size = UDim2.new(0.5, 0, 1, 0)
btnHome.BackgroundTransparency = 1
btnHome.Text = "Home"
btnHome.Font = Enum.Font.GothamBold
btnHome.TextColor3 = COLOR_TEXT
btnHome.TextSize = 11
btnHome.ZIndex = 2

local btnLibrary = Instance.new("TextButton", navBar)
btnLibrary.Size = UDim2.new(0.5, 0, 1, 0)
btnLibrary.Position = UDim2.new(0.5, 0, 0, 0)
btnLibrary.BackgroundTransparency = 1
btnLibrary.Text = "Library"
btnLibrary.Font = Enum.Font.GothamBold
btnLibrary.TextColor3 = COLOR_TEXT_DIM
btnLibrary.TextSize = 11
btnLibrary.ZIndex = 2

-- Close Button
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -45, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = COLOR_TEXT
closeBtn.TextSize = 11
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 6)
local closeStroke = Instance.new("UIStroke", closeBtn)
closeStroke.Color = COLOR_STROKE
closeStroke.Thickness = 1

-- Container for content
local content = Instance.new("Frame", mainFrame)
content.Name = "Content"
content.Size = UDim2.new(1, -20, 1, -70)
content.Position = UDim2.new(0, 10, 0, 55)
content.BackgroundTransparency = 1

-- ================================================================
-- VIEW 1: HOME VIEW (NOW PLAYING & QUEUE LIST)
-- ================================================================
local viewHome = Instance.new("Frame", content)
viewHome.Name = "HomeView"
viewHome.Size = UDim2.new(1, 0, 1, 0)
viewHome.BackgroundTransparency = 1

-- Left Panel: Now Playing (50% Width)
local pNowPlaying = Instance.new("Frame", viewHome)
pNowPlaying.Size = UDim2.new(0.48, 0, 1, 0)
pNowPlaying.BackgroundTransparency = 1

-- Album Art Frame
local artCover = Instance.new("ImageLabel", pNowPlaying)
artCover.Size = UDim2.new(0, 150, 0, 150)
artCover.Position = UDim2.new(0.5, 0, 0, 10)
artCover.AnchorPoint = Vector2.new(0.5, 0)
artCover.Image = "rbxassetid://10850020475" -- Default Disc Vinyl Cover
artCover.BackgroundColor3 = COLOR_CARD_BG
local artCorner = Instance.new("UICorner", artCover)
artCorner.CornerRadius = UDim.new(0, 10)
local artStroke = Instance.new("UIStroke", artCover)
artStroke.Color = COLOR_STROKE
artStroke.Thickness = 1.5

-- Metadata details
local nowPlayingSub = Instance.new("TextLabel", pNowPlaying)
nowPlayingSub.Size = UDim2.new(1, 0, 0, 18)
nowPlayingSub.Position = UDim2.new(0, 0, 0, 170)
nowPlayingSub.BackgroundTransparency = 1
nowPlayingSub.Text = "NOW PLAYING"
nowPlayingSub.Font = Enum.Font.GothamBold
nowPlayingSub.TextColor3 = COLOR_NEON
nowPlayingSub.TextSize = 9

local songTitleLbl = Instance.new("TextLabel", pNowPlaying)
songTitleLbl.Size = UDim2.new(1, 0, 0, 20)
songTitleLbl.Position = UDim2.new(0, 0, 0, 190)
songTitleLbl.BackgroundTransparency = 1
songTitleLbl.Text = "Not Playing Background Music"
songTitleLbl.Font = Enum.Font.GothamBlack
songTitleLbl.TextColor3 = COLOR_TEXT
songTitleLbl.TextSize = 13
songTitleLbl.TextTruncate = Enum.TextTruncate.AtEnd

local playlistNameLbl = Instance.new("TextLabel", pNowPlaying)
playlistNameLbl.Size = UDim2.new(1, 0, 0, 15)
playlistNameLbl.Position = UDim2.new(0, 0, 0, 210)
playlistNameLbl.BackgroundTransparency = 1
playlistNameLbl.Text = "Playlist: None"
playlistNameLbl.Font = Enum.Font.GothamMedium
playlistNameLbl.TextColor3 = COLOR_TEXT_DIM
playlistNameLbl.TextSize = 10

local queuedByLbl = Instance.new("TextLabel", pNowPlaying)
queuedByLbl.Size = UDim2.new(1, 0, 0, 15)
queuedByLbl.Position = UDim2.new(0, 0, 0, 225)
queuedByLbl.BackgroundTransparency = 1
queuedByLbl.Text = "Queued by: SYSTEM"
queuedByLbl.Font = Enum.Font.GothamMedium
queuedByLbl.TextColor3 = COLOR_TEXT_DIM
queuedByLbl.TextSize = 10

-- Progress Bar Section
local progressFrame = Instance.new("Frame", pNowPlaying)
progressFrame.Size = UDim2.new(1, -20, 0, 15)
progressFrame.Position = UDim2.new(0, 10, 0, 255)
progressFrame.BackgroundTransparency = 1

local countStart = Instance.new("TextLabel", progressFrame)
countStart.Size = UDim2.new(0, 35, 1, 0)
countStart.BackgroundTransparency = 1
countStart.Text = "00:00"
countStart.Font = Enum.Font.GothamSemibold
countStart.TextColor3 = COLOR_TEXT_DIM
countStart.TextSize = 9
countStart.TextXAlignment = Enum.TextXAlignment.Left

local countEnd = Instance.new("TextLabel", progressFrame)
countEnd.Size = UDim2.new(0, 35, 1, 0)
countEnd.Position = UDim2.new(1, -35, 0, 0)
countEnd.BackgroundTransparency = 1
countEnd.Text = "00:00"
countEnd.Font = Enum.Font.GothamSemibold
countEnd.TextColor3 = COLOR_TEXT_DIM
countEnd.TextSize = 9
countEnd.TextXAlignment = Enum.TextXAlignment.Right

local progressBarBg = Instance.new("Frame", progressFrame)
progressBarBg.Size = UDim2.new(1, -80, 0, 4)
progressBarBg.Position = UDim2.new(0, 40, 0.5, -2)
progressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
local barBgCorner = Instance.new("UICorner", progressBarBg)
barBgCorner.CornerRadius = UDim.new(0, 2)

local progressBarFill = Instance.new("Frame", progressBarBg)
progressBarFill.Size = UDim2.new(0, 0, 1, 0)
progressBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
local barFillCorner = Instance.new("UICorner", progressBarFill)
barFillCorner.CornerRadius = UDim.new(0, 2)

-- Volume Section
local volumeFrame = Instance.new("Frame", pNowPlaying)
volumeFrame.Size = UDim2.new(1, -20, 0, 35)
volumeFrame.Position = UDim2.new(0, 10, 0, 285)
volumeFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
local volCorner = Instance.new("UICorner", volumeFrame)
volCorner.CornerRadius = UDim.new(0, 6)
local volStroke = Instance.new("UIStroke", volumeFrame)
volStroke.Color = COLOR_STROKE
volStroke.Thickness = 1

local volIcon = Instance.new("TextLabel", volumeFrame)
volIcon.Size = UDim2.new(0, 60, 1, 0)
volIcon.Position = UDim2.new(0, 10, 0, 0)
volIcon.BackgroundTransparency = 1
volIcon.Text = "🔊 Volume"
volIcon.Font = Enum.Font.GothamBold
volIcon.TextColor3 = COLOR_TEXT
volIcon.TextSize = 10
volIcon.TextXAlignment = Enum.TextXAlignment.Left

local volTrack = Instance.new("Frame", volumeFrame)
volTrack.Size = UDim2.new(1, -125, 0, 4)
volTrack.Position = UDim2.new(0, 75, 0.5, -2)
volTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
Instance.new("UICorner", volTrack).CornerRadius = UDim.new(0, 2)

local volFill = Instance.new("Frame", volTrack)
volFill.Size = UDim2.new(0.5, 0, 1, 0) -- 50% start
volFill.BackgroundColor3 = COLOR_NEON
Instance.new("UICorner", volFill).CornerRadius = UDim.new(0, 2)

local volHandle = Instance.new("Frame", volTrack)
volHandle.Size = UDim2.new(0, 10, 0, 10)
volHandle.Position = UDim2.new(0.5, 0, 0.5, 0)
volHandle.AnchorPoint = Vector2.new(0.5, 0.5)
volHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", volHandle).CornerRadius = UDim.new(0, 5)

local volPct = Instance.new("TextLabel", volumeFrame)
volPct.Size = UDim2.new(0, 35, 1, 0)
volPct.Position = UDim2.new(1, -40, 0, 0)
volPct.BackgroundTransparency = 1
volPct.Text = "50%"
volPct.Font = Enum.Font.GothamBold
volPct.TextColor3 = COLOR_TEXT
volPct.TextSize = 10
volPct.TextXAlignment = Enum.TextXAlignment.Right

-- Skip Button
local skipBtn = Instance.new("TextButton", pNowPlaying)
skipBtn.Size = UDim2.new(1, -20, 0, 40)
skipBtn.Position = UDim2.new(0, 10, 0, 335)
skipBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
skipBtn.Text = "Skip (0/10)"
skipBtn.Font = Enum.Font.GothamBold
skipBtn.TextColor3 = COLOR_TEXT
skipBtn.TextSize = 12
local skipBtnCorner = Instance.new("UICorner", skipBtn)
skipBtnCorner.CornerRadius = UDim.new(0, 8)
local skipBtnStroke = Instance.new("UIStroke", skipBtn)
skipBtnStroke.Color = COLOR_STROKE
skipBtnStroke.Thickness = 1.5

-- Right Panel: Queue list (50% Width)
local pQueue = Instance.new("Frame", viewHome)
pQueue.Size = UDim2.new(0.48, 0, 1, 0)
pQueue.Position = UDim2.new(0.52, 0, 0, 0)
pQueue.BackgroundTransparency = 1

local queueHeader = Instance.new("TextLabel", pQueue)
queueHeader.Size = UDim2.new(1, 0, 0, 20)
queueHeader.BackgroundTransparency = 1
queueHeader.Text = "QUEUE"
queueHeader.Font = Enum.Font.GothamBold
queueHeader.TextColor3 = COLOR_TEXT_DIM
queueHeader.TextSize = 11
queueHeader.TextXAlignment = Enum.TextXAlignment.Left

local queueScroll = Instance.new("ScrollingFrame", pQueue)
queueScroll.Size = UDim2.new(1, 0, 1, -30)
queueScroll.Position = UDim2.new(0, 0, 0, 25)
queueScroll.BackgroundTransparency = 1
queueScroll.ScrollBarThickness = 3
queueScroll.ScrollBarImageColor3 = COLOR_STROKE
queueScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
queueScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local queueListLayout = Instance.new("UIListLayout", queueScroll)
queueListLayout.Padding = UDim.new(0, 6)
queueListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Empty Queue Placeholder
local emptyPlaceholder = Instance.new("TextLabel", queueScroll)
emptyPlaceholder.Name = "EmptyPlaceholder"
emptyPlaceholder.Size = UDim2.new(1, -20, 0, 80)
emptyPlaceholder.Position = UDim2.new(0, 10, 0, 20)
emptyPlaceholder.BackgroundTransparency = 1
emptyPlaceholder.Text = "Antrean kosong.\nTambahkan lagu dari Library!"
emptyPlaceholder.Font = Enum.Font.GothamSemibold
emptyPlaceholder.TextColor3 = COLOR_TEXT_DIM
emptyPlaceholder.TextSize = 11
emptyPlaceholder.TextWrapped = true
emptyPlaceholder.Visible = true

-- Vertical Divider Line
local divider = Instance.new("Frame", viewHome)
divider.Name = "Divider"
divider.Size = UDim2.new(0, 1, 1, -20)
divider.Position = UDim2.new(0.5, 0, 0, 10)
divider.BackgroundColor3 = COLOR_STROKE
divider.BorderSizePixel = 0
divider.BackgroundTransparency = 0.5

-- ================================================================
-- VIEW 2: LIBRARY VIEW (COLLECTIONS & ALL TRACKS GRID)
-- ================================================================
local viewLibrary = Instance.new("Frame", content)
viewLibrary.Name = "LibraryView"
viewLibrary.Size = UDim2.new(1, 0, 1, 0)
viewLibrary.BackgroundTransparency = 1
viewLibrary.Visible = false

-- Left Panel: Collections Sidebar (28% Width)
local pCollections = Instance.new("Frame", viewLibrary)
pCollections.Size = UDim2.new(0.28, 0, 1, 0)
pCollections.BackgroundTransparency = 1

local colHeader = Instance.new("TextLabel", pCollections)
colHeader.Size = UDim2.new(1, 0, 0, 20)
colHeader.BackgroundTransparency = 1
colHeader.Text = "COLLECTIONS"
colHeader.Font = Enum.Font.GothamBold
colHeader.TextColor3 = COLOR_TEXT_DIM
colHeader.TextSize = 10
colHeader.TextXAlignment = Enum.TextXAlignment.Left

local colScroll = Instance.new("ScrollingFrame", pCollections)
colScroll.Size = UDim2.new(1, 0, 1, -100) -- Room for Add By ID
colScroll.Position = UDim2.new(0, 0, 0, 25)
colScroll.BackgroundTransparency = 1
colScroll.ScrollBarThickness = 0
colScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
colScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local colListLayout = Instance.new("UIListLayout", colScroll)
colListLayout.Padding = UDim.new(0, 5)
colListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Bottom Panel: ADD BY ID
local addByIdFrame = Instance.new("Frame", pCollections)
addByIdFrame.Size = UDim2.new(1, 0, 0, 65)
addByIdFrame.Position = UDim2.new(0, 0, 1, -65)
addByIdFrame.BackgroundTransparency = 1

local addByIdHeader = Instance.new("TextLabel", addByIdFrame)
addByIdHeader.Size = UDim2.new(1, 0, 0, 18)
addByIdHeader.BackgroundTransparency = 1
addByIdHeader.Text = "ADD BY ID"
addByIdHeader.Font = Enum.Font.GothamBold
addByIdHeader.TextColor3 = COLOR_TEXT_DIM
addByIdHeader.TextSize = 10
addByIdHeader.TextXAlignment = Enum.TextXAlignment.Left

local idTextBox = Instance.new("TextBox", addByIdFrame)
idTextBox.Size = UDim2.new(1, -40, 0, 32)
idTextBox.Position = UDim2.new(0, 0, 0, 20)
idTextBox.BackgroundColor3 = COLOR_CARD_BG
idTextBox.Text = ""
idTextBox.PlaceholderText = "Enter Audio ID..."
idTextBox.Font = Enum.Font.GothamSemibold
idTextBox.TextColor3 = COLOR_TEXT
idTextBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
idTextBox.TextSize = 10
local boxCorner = Instance.new("UICorner", idTextBox)
boxCorner.CornerRadius = UDim.new(0, 6)
local boxStroke = Instance.new("UIStroke", idTextBox)
boxStroke.Color = COLOR_STROKE
boxStroke.Thickness = 1

local addIdBtn = Instance.new("TextButton", addByIdFrame)
addIdBtn.Size = UDim2.new(0, 32, 0, 32)
addIdBtn.Position = UDim2.new(1, -32, 0, 20)
addIdBtn.BackgroundColor3 = COLOR_NEON
addIdBtn.Text = "+"
addIdBtn.Font = Enum.Font.GothamBold
addIdBtn.TextColor3 = COLOR_TEXT
addIdBtn.TextSize = 16
local plusCorner = Instance.new("UICorner", addIdBtn)
plusCorner.CornerRadius = UDim.new(0, 6)

-- Right Panel: Tracks View (70% Width)
local pTracks = Instance.new("Frame", viewLibrary)
pTracks.Size = UDim2.new(0.68, 0, 1, 0)
pTracks.Position = UDim2.new(0.32, 0, 0, 0)
pTracks.BackgroundTransparency = 1

local tracksHeader = Instance.new("TextLabel", pTracks)
tracksHeader.Size = UDim2.new(0.5, 0, 0, 20)
tracksHeader.BackgroundTransparency = 1
tracksHeader.Text = "ALL TRACKS"
tracksHeader.Font = Enum.Font.GothamBold
tracksHeader.TextColor3 = COLOR_TEXT_DIM
tracksHeader.TextSize = 11
tracksHeader.TextXAlignment = Enum.TextXAlignment.Left

-- Search Input
local searchTextBox = Instance.new("TextBox", pTracks)
searchTextBox.Size = UDim2.new(1, 0, 0, 32)
searchTextBox.Position = UDim2.new(0, 0, 0, 25)
searchTextBox.BackgroundColor3 = COLOR_CARD_BG
searchTextBox.Text = ""
searchTextBox.PlaceholderText = "Search tracks..."
searchTextBox.Font = Enum.Font.GothamSemibold
searchTextBox.TextColor3 = COLOR_TEXT
searchTextBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
searchTextBox.TextSize = 10
searchTextBox.TextXAlignment = Enum.TextXAlignment.Left
local searchPadding = Instance.new("UIPadding", searchTextBox)
searchPadding.PaddingLeft = UDim.new(0, 12)
searchPadding.PaddingRight = UDim.new(0, 12)
local searchCorner = Instance.new("UICorner", searchTextBox)
searchCorner.CornerRadius = UDim.new(0, 6)
local searchStroke = Instance.new("UIStroke", searchTextBox)
searchStroke.Color = COLOR_STROKE
searchStroke.Thickness = 1

local tracksScroll = Instance.new("ScrollingFrame", pTracks)
tracksScroll.Size = UDim2.new(1, 0, 1, -65)
tracksScroll.Position = UDim2.new(0, 0, 0, 65)
tracksScroll.BackgroundTransparency = 1
tracksScroll.ScrollBarThickness = 3
tracksScroll.ScrollBarImageColor3 = COLOR_STROKE
tracksScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
tracksScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local tracksGrid = Instance.new("UIGridLayout", tracksScroll)
tracksGrid.CellSize = UDim2.new(0, 120, 0, 155)
tracksGrid.CellPadding = UDim2.new(0, 10, 0, 10)

-- ================================================================
-- CONTROLLER & ACTION INTERACTORS
-- ================================================================

-- Format timer display: (seconds -> "MM:SS")
local function formatTime(seconds)
	if not seconds or seconds < 0 then return "00:00" end
	local m = math.floor(seconds / 60)
	local s = math.floor(seconds % 60)
	return string.format("%02d:%02d", m, s)
end

-- Toggle Home / Library Tab
local function switchTab(tabName)
	currentTab = tabName
	if tabName == "Home" then
		TweenService:Create(navPill, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 2, 0, 2)}):Play()
		btnHome.TextColor3 = COLOR_TEXT
		btnLibrary.TextColor3 = COLOR_TEXT_DIM
		viewHome.Visible = true
		viewLibrary.Visible = false
	else
		TweenService:Create(navPill, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, 2, 0, 2)}):Play()
		btnHome.TextColor3 = COLOR_TEXT_DIM
		btnLibrary.TextColor3 = COLOR_TEXT
		viewHome.Visible = false
		viewLibrary.Visible = true
	end
end

btnHome.MouseButton1Click:Connect(function() switchTab("Home") end)
btnLibrary.MouseButton1Click:Connect(function() switchTab("Library") end)

-- Setup Volume Slider
local function setupVolumeSlider()
	local UIS = game:GetService("UserInputService")
	local dragging = false
	
	local function updateVolume(input)
		local pct = math.clamp((input.Position.X - volTrack.AbsolutePosition.X) / volTrack.AbsoluteSize.X, 0, 1)
		volFill.Size = UDim2.new(pct, 0, 1, 0)
		volHandle.Position = UDim2.new(pct, 0, 0.5, 0)
		volPct.Text = math.floor(pct * 100) .. "%"
		
		clientVolume = pct
		if activeLocalSound then
			activeLocalSound.Volume = clientVolume
		end
	end
	
	volHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateVolume(input)
		end
	end)
	
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	
	volTrack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			updateVolume(input)
			dragging = true
		end
	end)
end

setupVolumeSlider()

-- Close Dialog Event
local function toggleGui()
	isGuiOpen = not isGuiOpen
	gui.Enabled = isGuiOpen
end

closeBtn.MouseButton1Click:Connect(toggleGui)

-- Connect HUD toggle bindable event
local reqToggleMusic = playerGui:FindFirstChild("ToggleMusicUI")
if not reqToggleMusic then
	reqToggleMusic = Instance.new("BindableEvent")
	reqToggleMusic.Name = "ToggleMusicUI"
	reqToggleMusic.Parent = playerGui
end
reqToggleMusic.Event:Connect(toggleGui)

-- Skip Request
skipBtn.MouseButton1Click:Connect(function()
	MusicEvent:FireServer({Action = "VoteSkip"})
end)

-- Custom ID submission
addIdBtn.MouseButton1Click:Connect(function()
	local text = idTextBox.Text
	local number = tonumber(text)
	if number then
		MusicEvent:FireServer({Action = "QueueSong", Id = number})
		idTextBox.Text = ""
	else
		-- Trigger toast alert
		local notifEvent = ReplicatedStorage:FindFirstChild("CustomNotification")
		if notifEvent then
			notifEvent:Fire({
				Title = "Input Gagal",
				Text = "Masukkan ID audio angka yang valid!",
				Color = Color3.fromRGB(231, 76, 60),
				Duration = 3
			})
		end
	end
end)

-- Setup grid cards
local function buildTrackCard(track)
	local card = Instance.new("Frame", tracksScroll)
	card.Name = "Track_" .. track.Title
	card.BackgroundColor3 = COLOR_CARD_BG
	local cardCorner = Instance.new("UICorner", card)
	cardCorner.CornerRadius = UDim.new(0, 8)
	local cardStroke = Instance.new("UIStroke", card)
	cardStroke.Color = COLOR_STROKE
	cardStroke.Thickness = 1
	
	local cardImage = Instance.new("ImageLabel", card)
	cardImage.Size = UDim2.new(1, -12, 0, 95)
	cardImage.Position = UDim2.new(0, 6, 0, 6)
	cardImage.Image = track.CoverArt or "rbxassetid://10850020475"
	cardImage.BackgroundColor3 = COLOR_BG
	local imgCorner = Instance.new("UICorner", cardImage)
	imgCorner.CornerRadius = UDim.new(0, 6)
	
	local cardTitle = Instance.new("TextLabel", card)
	cardTitle.Size = UDim2.new(1, -12, 0, 16)
	cardTitle.Position = UDim2.new(0, 6, 0, 105)
	cardTitle.BackgroundTransparency = 1
	cardTitle.Text = track.Title
	cardTitle.Font = Enum.Font.GothamBold
	cardTitle.TextColor3 = COLOR_TEXT
	cardTitle.TextSize = 9
	cardTitle.TextTruncate = Enum.TextTruncate.AtEnd
	
	local cardArtist = Instance.new("TextLabel", card)
	cardArtist.Size = UDim2.new(1, -12, 0, 12)
	cardArtist.Position = UDim2.new(0, 6, 0, 121)
	cardArtist.BackgroundTransparency = 1
	cardArtist.Text = track.Artist
	cardArtist.Font = Enum.Font.GothamMedium
	cardArtist.TextColor3 = COLOR_TEXT_DIM
	cardArtist.TextSize = 8
	cardArtist.TextTruncate = Enum.TextTruncate.AtEnd
	
	local cardPlaylist = Instance.new("TextLabel", card)
	cardPlaylist.Size = UDim2.new(1, -12, 0, 12)
	cardPlaylist.Position = UDim2.new(0, 6, 0, 133)
	cardPlaylist.BackgroundTransparency = 1
	cardPlaylist.Text = track.Playlist
	cardPlaylist.Font = Enum.Font.GothamBold
	cardPlaylist.TextColor3 = COLOR_TEXT_DIM
	cardPlaylist.TextSize = 7
	cardPlaylist.TextTruncate = Enum.TextTruncate.AtEnd
	
	-- Button to Queue
	local triggerBtn = Instance.new("TextButton", card)
	triggerBtn.Size = UDim2.new(1, 0, 1, 0)
	triggerBtn.BackgroundTransparency = 1
	triggerBtn.Text = ""
	
	triggerBtn.MouseEnter:Connect(function()
		TweenService:Create(cardStroke, TweenInfo.new(0.2), {Color = COLOR_NEON}):Play()
	end)
	
	triggerBtn.MouseLeave:Connect(function()
		TweenService:Create(cardStroke, TweenInfo.new(0.2), {Color = COLOR_STROKE}):Play()
	end)
	
	triggerBtn.MouseButton1Click:Connect(function()
		MusicEvent:FireServer({Action = "QueueSong", Id = track.Id})
	end)
	
	return card
end

-- Setup collection filters
local activeCollectionBtn = nil

local function filterGrid()
	for _, card in ipairs(tracksScroll:GetChildren()) do
		if card:IsA("Frame") then
			local trackName = string.sub(card.Name, 7) -- Strip "Track_"
			local matchesSearch = string.find(string.lower(trackName), string.lower(lastSearchText)) ~= nil
			
			-- Get playlist category
			local isMatchCategory = false
			for _, track in ipairs(MusicDatabase.Tracks) do
				if track.Title == trackName then
					isMatchCategory = (currentSelectedCollection == "All Tracks" or track.Playlist == currentSelectedCollection)
					-- Check artist match as well
					if not matchesSearch then
						matchesSearch = string.find(string.lower(track.Artist), string.lower(lastSearchText)) ~= nil
					end
					break
				end
			end
			
			card.Visible = matchesSearch and isMatchCategory
		end
	end
end

local function selectCollection(btn, colName)
	currentSelectedCollection = colName
	tracksHeader.Text = string.upper(colName)
	
	if activeCollectionBtn then
		activeCollectionBtn.BackgroundColor3 = COLOR_BG
		activeCollectionBtn.UIStroke.Color = COLOR_STROKE
	end
	
	activeCollectionBtn = btn
	activeCollectionBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
	activeCollectionBtn.UIStroke.Color = COLOR_NEON
	
	filterGrid()
end

-- Build Collections List
for idx, colName in ipairs(MusicDatabase.Collections) do
	local btn = Instance.new("TextButton", colScroll)
	btn.Name = "ColBtn_" .. colName
	btn.Size = UDim2.new(1, -6, 0, 30)
	btn.BackgroundColor3 = COLOR_BG
	btn.Text = "  " .. colName
	btn.Font = Enum.Font.GothamMedium
	btn.TextColor3 = COLOR_TEXT
	btn.TextSize = 9
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.LayoutOrder = idx
	
	local colCorner = Instance.new("UICorner", btn)
	colCorner.CornerRadius = UDim.new(0, 6)
	local colStroke = Instance.new("UIStroke", btn)
	colStroke.Color = COLOR_STROKE
	colStroke.Thickness = 1
	
	btn.MouseButton1Click:Connect(function()
		selectCollection(btn, colName)
	end)
	
	-- Select first default category
	if colName == "All Tracks" then
		selectCollection(btn, colName)
	end
end

-- Build all track cards
for _, track in ipairs(MusicDatabase.Tracks) do
	buildTrackCard(track)
end

-- Hook Search Box
searchTextBox:GetPropertyChangedSignal("Text"):Connect(function()
	lastSearchText = searchTextBox.Text
	filterGrid()
end)

-- ================================================================
-- SYNC LOGIC & UI POPULATION
-- ================================================================
local function syncQueueList(queueList)
	-- Clean existing queue items
	for _, child in ipairs(queueScroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	if #queueList == 0 then
		emptyPlaceholder.Visible = true
		return
	end
	emptyPlaceholder.Visible = false
	
	for idx, qItem in ipairs(queueList) do
		local card = Instance.new("Frame", queueScroll)
		card.Name = "QueueItem_" .. idx
		card.Size = UDim2.new(1, -6, 0, 45)
		card.BackgroundColor3 = COLOR_CARD_BG
		card.LayoutOrder = idx
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
		local qStroke = Instance.new("UIStroke", card)
		qStroke.Color = COLOR_STROKE
		qStroke.Thickness = 1
		
		-- Index Bubble
		local indexFrame = Instance.new("Frame", card)
		indexFrame.Size = UDim2.new(0, 18, 0, 18)
		indexFrame.Position = UDim2.new(0, 8, 0.5, -9)
		indexFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
		Instance.new("UICorner", indexFrame).CornerRadius = UDim.new(0, 9)
		
		local indexLbl = Instance.new("TextLabel", indexFrame)
		indexLbl.Size = UDim2.new(1, 0, 1, 0)
		indexLbl.BackgroundTransparency = 1
		indexLbl.Text = tostring(idx)
		indexLbl.Font = Enum.Font.GothamBold
		indexLbl.TextColor3 = COLOR_TEXT
		indexLbl.TextSize = 8
		
		-- Cover Art Icon
		local art = Instance.new("ImageLabel", card)
		art.Size = UDim2.new(0, 30, 0, 30)
		art.Position = UDim2.new(0, 32, 0.5, -15)
		art.Image = qItem.CoverArt or "rbxassetid://10850020475"
		art.BackgroundColor3 = COLOR_BG
		Instance.new("UICorner", art).CornerRadius = UDim.new(0, 4)
		
		-- Details Text layout
		local detailFrame = Instance.new("Frame", card)
		detailFrame.Size = UDim2.new(1, -75, 1, 0)
		detailFrame.Position = UDim2.new(0, 70, 0, 0)
		detailFrame.BackgroundTransparency = 1
		
		local title = Instance.new("TextLabel", detailFrame)
		title.Size = UDim2.new(1, 0, 0.5, 0)
		title.Position = UDim2.new(0, 0, 0, 4)
		title.BackgroundTransparency = 1
		title.Text = qItem.Artist .. " - " .. qItem.Title
		title.Font = Enum.Font.GothamBold
		title.TextColor3 = COLOR_TEXT
		title.TextSize = 9
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextTruncate = Enum.TextTruncate.AtEnd
		
		local subInfo = Instance.new("TextLabel", detailFrame)
		subInfo.Size = UDim2.new(1, 0, 0.5, 0)
		subInfo.Position = UDim2.new(0, 0, 0.5, -2)
		subInfo.BackgroundTransparency = 1
		subInfo.Text = `Playlist: {qItem.Playlist} | Queued by: {qItem.QueuedBy}`
		subInfo.Font = Enum.Font.GothamMedium
		subInfo.TextColor3 = COLOR_TEXT_DIM
		subInfo.TextSize = 7.5
		subInfo.TextXAlignment = Enum.TextXAlignment.Left
		subInfo.TextTruncate = Enum.TextTruncate.AtEnd
	end
end

-- Heartbeat loop to update Now Playing progress bar
RunService.Heartbeat:Connect(function()
	if not currentSongData then return end
	
	local elapsed = Workspace:GetServerTimeNow() - currentSongData.StartTime
	elapsed = math.max(0, math.min(elapsed, currentSongData.Duration))
	
	countStart.Text = formatTime(elapsed)
	countEnd.Text = formatTime(currentSongData.Duration)
	
	local pct = currentSongData.Duration > 0 and (elapsed / currentSongData.Duration) or 0
	progressBarFill.Size = UDim2.new(pct, 0, 1, 0)
end)

-- Setup Remote Event Sync
MusicEvent.OnClientEvent:Connect(function(data)
	if type(data) ~= "table" then return end
	local action = data.Action
	
	if action == "SyncState" then
		-- Update Active Song
		local song = data.ActiveSong
		if song then
			if not currentSongData or currentSongData.Id ~= song.Id or math.abs(currentSongData.StartTime - song.StartTime) > 2 then
				currentSongData = song
				
				-- Trigger dynamic cover art image if database matches
				local resolvedArt = "rbxassetid://10850020475"
				for _, track in ipairs(MusicDatabase.Tracks) do
					if track.Id == song.Id then
						resolvedArt = track.CoverArt
						break
					end
				end
				artCover.Image = resolvedArt
				
				-- Update Text labels
				songTitleLbl.Text = song.Artist .. " - " .. song.Title
				playlistNameLbl.Text = "Playlist: " .. song.Playlist
				queuedByLbl.Text = "Queued by: " .. song.QueuedBy
				
				-- Play Local Sound
				playLocalTrack(song.Id, song.StartTime, song.Duration)
			end
		else
			currentSongData = nil
			songTitleLbl.Text = "Not Playing"
			playlistNameLbl.Text = "Playlist: None"
			queuedByLbl.Text = "Queued by: SYSTEM"
			countStart.Text = "00:00"
			countEnd.Text = "00:00"
			progressBarFill.Size = UDim2.new(0, 0, 1, 0)
			stopLocalTrack()
		end
		
		-- Update Queue
		syncQueueList(data.Queue or {})
		
		-- Update Skip progress
		local votes = data.VoteCount or 0
		local required = data.RequiredVotes or 10
		skipBtn.Text = `Skip ({votes}/{required})`
		
		if data.HasVoted then
			skipBtn.BackgroundColor3 = COLOR_NEON
			skipBtn.UIStroke.Color = Color3.fromRGB(255, 255, 255)
		else
			skipBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
			skipBtn.UIStroke.Color = COLOR_STROKE
		end
		
	elseif action == "Notification" then
		-- Trigger notification in Toast system
		local notifEvent = ReplicatedStorage:FindFirstChild("CustomNotification")
		if notifEvent then
			notifEvent:Fire({
				Title = data.Title or "Notifikasi",
				Text = data.Text or "",
				Color = data.Color or Color3.fromRGB(241, 196, 15),
				Duration = 4
			})
		end
	end
end)

-- Retrieve initial state
task.spawn(function()
	task.wait(1.5)
	MusicEvent:FireServer({Action = "GetState"})
end)

print("[Client] MusicPlayerClient successfully loaded!")
