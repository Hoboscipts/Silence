--[[
    ================================================================
    [ SCRIPT INFORMATION ]
    Project: Custom Script
    Author: OYB
    YouTube: https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ
    
    [ TERMS AND CONDITIONS ]
    - You ARE allowed to use and modify this script for your own games.
    - You ARE NOT allowed to re-upload, redistribute, or claim 
      ownership of this script.
    - Removing or altering these credits is strictly prohibited.
    
    Copyright (c) 2026 OYB. All rights reserved.
    ================================================================
]]

-- ⚠️ IMPORTANT: Put this code at the VERY TOP of your Main Script (before obfuscating) ⚠️

local ProtectionConfig = {
    -- 🔴 CRITICAL: This MUST exactly match the 'Secret' value in your Key System's Config!
    -- If your Key System has: Secret = "Test"
    -- Then this must also be: SecretKey = "Test"
    SecretKey = "1234",
    
    -- The name of your Hub (shown in the kick message if they try to bypass)
    HubName = "Silence"
}

-- Anti-Bypass Logic: Checks if the Key System successfully set the global variable
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return -- Stops the rest of the script from loading!
end

-------------------------------------------------------------------------------
-- 👇 YOUR MAIN SCRIPT CODE STARTS HERE 👇
-------------------------------------------------------------------------------

print(ProtectionConfig.HubName .. " Loaded Successfully!")
-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ================= STATE =================
local aimEnabled        = false
local espEnabled        = false
local silentAimEnabled  = false
local noClipEnabled     = false
local infiniteJumpEnabled = false
local guiVisible        = true
local fovCircleVisible  = true
local tracersEnabled    = false
local rgbESPEnabled     = false
local rgbGunEnabled     = false

local FOV_RADIUS     = 120
local SMOOTH         = 0.15
local MIN_SPEED      = 25
local MAX_SPEED      = 250
local currentSpeed   = 25
local currentJumpPower = 17
local humanoid

local aimKeyCode = Enum.KeyCode.E
local guiKeyCode = Enum.KeyCode.RightShift

-- ================= RGB STATE =================
local rgbHue = 0
local currentESPColor = Color3.fromRGB(255, 255, 255)
local tracerLines = {}
local gunGlowHighlights = {}

-- ================= PALETTE =================
local BG_DEEP    = Color3.fromRGB(12,  12,  18)
local BG_MID     = Color3.fromRGB(20,  20,  28)
local BG_PANEL   = Color3.fromRGB(26,  26,  36)
local BG_ITEM    = Color3.fromRGB(32,  32,  44)
local BORDER_CLR = Color3.fromRGB(50,  50,  75)
local ACCENT_BLU = Color3.fromRGB(80,  130, 255)
local ACCENT_PUR = Color3.fromRGB(110, 80,  240)
local TEXT_WHITE = Color3.fromRGB(230, 230, 240)
local TEXT_DIM   = Color3.fromRGB(120, 120, 148)
local GREEN_ON   = Color3.fromRGB(80,  220, 140)
local RED_OFF    = Color3.fromRGB(220, 80,  90)
local YELLOW_CLR = Color3.fromRGB(255, 200, 60)

-- ================= UTIL =================
local function applyCorner(f, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = f
end

local function applyStroke(f, col, th)
	local s = Instance.new("UIStroke")
	s.Color = col or BORDER_CLR
	s.Thickness = th or 1
	s.Transparency = 0.3
	s.Parent = f
end

local function applyGradient(f, c0, c1, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, c0),
		ColorSequenceKeypoint.new(1, c1),
	})
	g.Rotation = rot or 90
	g.Parent = f
end

local function makePadding(f, t, b, l, r)
	local p = Instance.new("UIPadding")
	p.PaddingTop    = UDim.new(0, t or 0)
	p.PaddingBottom = UDim.new(0, b or 0)
	p.PaddingLeft   = UDim.new(0, l or 0)
	p.PaddingRight  = UDim.new(0, r or 0)
	p.Parent = f
end

-- ================= ROOT GUI =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SilenceGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ================= OUTER WINDOW =================
local outerFrame = Instance.new("Frame")
outerFrame.Name = "MainWindow"
outerFrame.Size = UDim2.new(0, 440, 0, 360)
outerFrame.Position = UDim2.new(0.5, -220, 0.5, -180)
outerFrame.BackgroundColor3 = BG_DEEP
outerFrame.BorderSizePixel = 0
outerFrame.Parent = screenGui
applyCorner(outerFrame, 10)
applyStroke(outerFrame, ACCENT_BLU, 1.5)
applyGradient(outerFrame, BG_DEEP, BG_MID, 135)

-- ================= TITLE BAR =================
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 34)
titleBar.BackgroundColor3 = BG_MID
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 5
titleBar.Parent = outerFrame
applyCorner(titleBar, 10)
applyGradient(titleBar, BG_MID, BG_DEEP, 90)
applyStroke(titleBar, BORDER_CLR, 1)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Silence"
titleLabel.TextColor3 = TEXT_WHITE
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 6
titleLabel.Parent = titleBar

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(0, 60, 1, 0)
versionLabel.Position = UDim2.new(1, -70, 0, 0)
versionLabel.BackgroundTransparency = 1
versionLabel.Text = "v1.0"
versionLabel.TextColor3 = TEXT_DIM
versionLabel.Font = Enum.Font.Gotham
versionLabel.TextSize = 10
versionLabel.TextXAlignment = Enum.TextXAlignment.Right
versionLabel.ZIndex = 6
versionLabel.Parent = titleBar

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 1)
accentLine.Position = UDim2.new(0, 0, 1, 0)
accentLine.BackgroundColor3 = ACCENT_BLU
accentLine.BorderSizePixel = 0
accentLine.ZIndex = 6
accentLine.Parent = titleBar
applyGradient(accentLine, ACCENT_BLU, ACCENT_PUR, 0)

-- ================= DRAGGABLE =================
local draggingWindow, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingWindow = true
		dragStart = input.Position
		startPos = outerFrame.Position
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingWindow = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if draggingWindow and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		outerFrame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-- ================= TAB BAR =================
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -20, 0, 28)
tabBar.Position = UDim2.new(0, 10, 0, 42)
tabBar.BackgroundTransparency = 1
tabBar.Parent = outerFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabBar

-- ================= CONTENT AREA =================
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -20, 1, -80)
contentArea.Position = UDim2.new(0, 10, 0, 78)
contentArea.BackgroundColor3 = BG_PANEL
contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true
contentArea.Parent = outerFrame
applyCorner(contentArea, 8)
applyStroke(contentArea, BORDER_CLR, 1)

-- ================= TAB SYSTEM =================
local tabs   = {}
local panels = {}

local tabDefs = {"AIM", "MOVEMENT", "PLAYER", "ESP", "MISC"}

local function switchTab(name)
	for _, t in pairs(tabs) do
		local isActive = t.Name == name
		t.BackgroundTransparency = isActive and 0 or 1
		t.BackgroundColor3 = isActive and BG_MID or Color3.fromRGB(0,0,0)
		t.TextColor3 = isActive and TEXT_WHITE or TEXT_DIM
		for _, v in ipairs(t:GetChildren()) do
			if v:IsA("UIStroke") then v:Destroy() end
		end
		if isActive then applyStroke(t, ACCENT_BLU, 1) end
	end
	for _, p in pairs(panels) do
		p.Visible = p.Name == name.."Panel"
	end
end

for _, tabName in ipairs(tabDefs) do
	local btn = Instance.new("TextButton")
	btn.Name = tabName
	btn.Size = UDim2.new(0, 72, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = tabName
	btn.TextColor3 = TEXT_DIM
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 11
	btn.BorderSizePixel = 0
	btn.Parent = tabBar
	applyCorner(btn, 6)
	btn.MouseButton1Click:Connect(function() switchTab(tabName) end)
	tabs[tabName] = btn

	local panel = Instance.new("ScrollingFrame")
	panel.Name = tabName.."Panel"
	panel.Size = UDim2.new(1, 0, 1, 0)
	panel.BackgroundTransparency = 1
	panel.BorderSizePixel = 0
	panel.ScrollBarThickness = 3
	panel.ScrollBarImageColor3 = ACCENT_BLU
	panel.CanvasSize = UDim2.new(0, 0, 0, 0)
	panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
	panel.Visible = false
	panel.Parent = contentArea
	panels[tabName] = panel

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 6)
	listLayout.Parent = panel
	makePadding(panel, 8, 8, 10, 10)
end

switchTab("AIM")

-- ================= WIDGET HELPERS =================
local function makeSectionLabel(panel, text)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 16)
	lbl.BackgroundTransparency = 1
	lbl.Text = "— "..text
	lbl.TextColor3 = TEXT_DIM
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = panel
end

local function makeToggle(panel, labelText, default, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = BG_ITEM
	row.BorderSizePixel = 0
	row.Parent = panel
	applyCorner(row, 6)
	applyStroke(row, BORDER_CLR, 1)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -60, 1, 0)
	lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = TEXT_WHITE
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row

	local pill = Instance.new("Frame")
	pill.Size = UDim2.new(0, 36, 0, 16)
	pill.Position = UDim2.new(1, -46, 0.5, -8)
	pill.BackgroundColor3 = default and GREEN_ON or Color3.fromRGB(60, 60, 80)
	pill.BorderSizePixel = 0
	pill.Parent = row
	applyCorner(pill, 8)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
	knob.BackgroundColor3 = TEXT_WHITE
	knob.BorderSizePixel = 0
	knob.Parent = pill
	applyCorner(knob, 6)

	local state = default or false

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = row
	btn.MouseButton1Click:Connect(function()
		state = not state
		pill.BackgroundColor3 = state and GREEN_ON or Color3.fromRGB(60, 60, 80)
		knob.Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
		if callback then callback(state) end
	end)

	return function() return state end
end

local function makeSlider(panel, labelText, min, max, default, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 48)
	container.BackgroundColor3 = BG_ITEM
	container.BorderSizePixel = 0
	container.Parent = panel
	applyCorner(container, 6)
	applyStroke(container, BORDER_CLR, 1)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.7, 0, 0, 20)
	lbl.Position = UDim2.new(0, 10, 0, 4)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = TEXT_WHITE
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = container

	local valLabel = Instance.new("TextLabel")
	valLabel.Size = UDim2.new(0.3, -10, 0, 20)
	valLabel.Position = UDim2.new(0.7, 0, 0, 4)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = tostring(default)
	valLabel.TextColor3 = ACCENT_BLU
	valLabel.Font = Enum.Font.GothamBold
	valLabel.TextSize = 11
	valLabel.TextXAlignment = Enum.TextXAlignment.Right
	valLabel.Parent = container

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -20, 0, 4)
	track.Position = UDim2.new(0, 10, 0, 32)
	track.BackgroundColor3 = BG_DEEP
	track.BorderSizePixel = 0
	track.Parent = container
	applyCorner(track, 3)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = ACCENT_BLU
	fill.BorderSizePixel = 0
	fill.Parent = track
	applyCorner(fill, 3)
	applyGradient(fill, ACCENT_BLU, ACCENT_PUR, 0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = UDim2.new(fill.Size.X.Scale, -6, 0.5, -6)
	knob.BackgroundColor3 = TEXT_WHITE
	knob.BorderSizePixel = 0
	knob.ZIndex = 3
	knob.Parent = track
	applyCorner(knob, 6)
	applyStroke(knob, ACCENT_BLU, 1.5)

	local sliding = false
	track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not sliding then return end
		if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		local x = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
		local pct = x / track.AbsoluteSize.X
		fill.Size = UDim2.new(pct, 0, 1, 0)
		knob.Position = UDim2.new(pct, -6, 0.5, -6)
		local val = math.floor(min + (max - min) * pct)
		valLabel.Text = tostring(val)
		if callback then callback(val) end
	end)
end

local function makeKeybindRow(panel, labelText, defaultKey, onChanged)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = BG_ITEM
	row.BorderSizePixel = 0
	row.Parent = panel
	applyCorner(row, 6)
	applyStroke(row, BORDER_CLR, 1)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.6, 0, 1, 0)
	lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = TEXT_WHITE
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row

	local keyBtn = Instance.new("TextButton")
	keyBtn.Size = UDim2.new(0, 70, 0, 20)
	keyBtn.Position = UDim2.new(1, -80, 0.5, -10)
	keyBtn.BackgroundColor3 = BG_DEEP
	keyBtn.Text = defaultKey
	keyBtn.TextColor3 = ACCENT_BLU
	keyBtn.Font = Enum.Font.GothamBold
	keyBtn.TextSize = 10
	keyBtn.BorderSizePixel = 0
	keyBtn.Parent = row
	applyCorner(keyBtn, 4)
	applyStroke(keyBtn, ACCENT_BLU, 1)

	local binding = false
	keyBtn.MouseButton1Click:Connect(function()
		binding = true
		keyBtn.Text = "..."
		keyBtn.TextColor3 = YELLOW_CLR
	end)

	UserInputService.InputBegan:Connect(function(i, gp)
		if not binding then return end
		if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
		binding = false
		local name = i.KeyCode.Name
		keyBtn.Text = name:len() > 8 and name:sub(1,7).."." or name
		keyBtn.TextColor3 = ACCENT_BLU
		if onChanged then onChanged(i.KeyCode) end
	end)
end

-- ================= COLOR PICKER HELPER =================
local function makeColorPickerRow(panel, labelText, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = BG_ITEM
	row.BorderSizePixel = 0
	row.Parent = panel
	applyCorner(row, 6)
	applyStroke(row, BORDER_CLR, 1)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.55, 0, 1, 0)
	lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = TEXT_WHITE
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row

	local presetColors = {
		Color3.fromRGB(255,255,255),
		Color3.fromRGB(255,60,60),
		Color3.fromRGB(60,255,100),
		Color3.fromRGB(80,130,255),
		Color3.fromRGB(255,200,60),
		Color3.fromRGB(200,60,255),
	}

	local swatchLayout = Instance.new("Frame")
	swatchLayout.Size = UDim2.new(0.42, 0, 0, 18)
	swatchLayout.Position = UDim2.new(0.56, 0, 0.5, -9)
	swatchLayout.BackgroundTransparency = 1
	swatchLayout.Parent = row

	local swatchList = Instance.new("UIListLayout")
	swatchList.FillDirection = Enum.FillDirection.Horizontal
	swatchList.Padding = UDim.new(0, 3)
	swatchList.VerticalAlignment = Enum.VerticalAlignment.Center
	swatchList.Parent = swatchLayout

	for _, col in ipairs(presetColors) do
		local swatch = Instance.new("TextButton")
		swatch.Size = UDim2.new(0, 18, 0, 18)
		swatch.BackgroundColor3 = col
		swatch.Text = ""
		swatch.BorderSizePixel = 0
		swatch.Parent = swatchLayout
		applyCorner(swatch, 4)
		local c = col
		swatch.MouseButton1Click:Connect(function()
			currentESPColor = c
			if callback then callback(c) end
		end)
	end
end

-- ================= AIM TAB =================
local aimPanelFrame = panels["AIM"]

makeSectionLabel(aimPanelFrame, "AIMBOT")
makeToggle(aimPanelFrame, "Aimbot", false, function(v)
	aimEnabled = v
end)
makeToggle(aimPanelFrame, "Silent Aim", false, function(v)
	silentAimEnabled = v
end)

makeSectionLabel(aimPanelFrame, "SETTINGS")
makeSlider(aimPanelFrame, "FOV Radius", 60, 360, 120, function(v)
	FOV_RADIUS = v
end)
makeSlider(aimPanelFrame, "Smooth", 1, 20, 3, function(v)
	SMOOTH = v / 100
end)

makeSectionLabel(aimPanelFrame, "KEYBINDS")
makeKeybindRow(aimPanelFrame, "Aim Key", "E", function(kc)
	aimKeyCode = kc
end)

-- ================= MOVEMENT TAB =================
local movPanelFrame = panels["MOVEMENT"]

makeSectionLabel(movPanelFrame, "SPEED")
makeSlider(movPanelFrame, "Walk Speed", 16, 250, 16, function(v)
	currentSpeed = v
	if humanoid then humanoid.WalkSpeed = v end
end)

makeSectionLabel(movPanelFrame, "JUMP")
makeSlider(movPanelFrame, "Jump Power", 17, 300, 17, function(v)
	currentJumpPower = v
	if humanoid then
		pcall(function()
			if humanoid.UseJumpPower then
				humanoid.JumpPower = v
			else
				humanoid.JumpHeight = v / 5
			end
		end)
		pcall(function() humanoid.JumpPower = v end)
		pcall(function() humanoid.JumpHeight = v / 5 end)
	end
end)

makeSectionLabel(movPanelFrame, "TOGGLES")
makeToggle(movPanelFrame, "Infinite Jump", false, function(v)
	infiniteJumpEnabled = v
end)
makeToggle(movPanelFrame, "No Clip", false, function(v)
	noClipEnabled = v
	if not v and player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
	end
end)

-- ================= PLAYER TAB =================
local plrPanelFrame = panels["PLAYER"]

makeSectionLabel(plrPanelFrame, "CHARACTER")
makeToggle(plrPanelFrame, "Anti AFK", false, function(v)
	if v then
		local vu = game:GetService("VirtualUser")
		player.Idled:Connect(function()
			vu:Button2Down(Vector2.new(0,0), camera.CFrame)
			task.wait(1)
			vu:Button2Up(Vector2.new(0,0), camera.CFrame)
		end)
	end
end)

makeSectionLabel(plrPanelFrame, "COSMETICS")
makeToggle(plrPanelFrame, "Fullbright", false, function(v)
	local lighting = game:GetService("Lighting")
	if v then
		lighting.Brightness = 2
		lighting.ClockTime = 14
		lighting.FogEnd = 100000
		lighting.GlobalShadows = false
	else
		lighting.Brightness = 1
		lighting.ClockTime = 14
		lighting.FogEnd = 100000
		lighting.GlobalShadows = true
	end
end)

-- ================= ESP TAB =================
local espPanelFrame = panels["ESP"]

makeSectionLabel(espPanelFrame, "HIGHLIGHTING")
makeToggle(espPanelFrame, "Enemy ESP (Outline)", false, function(v)
	espEnabled = v
	if not v then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character then
				local h = p.Character:FindFirstChild("EnemyHighlight")
				if h then h:Destroy() end
			end
		end
	end
end)

makeToggle(espPanelFrame, "Box ESP (Fill)", false, function(v)
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local h = p.Character:FindFirstChild("EnemyHighlight")
			if h then
				h.FillTransparency = v and 0.35 or 1
			end
		end
	end
end)

makeSectionLabel(espPanelFrame, "TRACERS")
makeToggle(espPanelFrame, "Tracers", false, function(v)
	tracersEnabled = v
	if not v then
		for _, line in pairs(tracerLines) do
			if line then
				pcall(function() line:Remove() end)
			end
		end
		tracerLines = {}
	end
end)

makeSectionLabel(espPanelFrame, "ESP COLOR")
makeColorPickerRow(espPanelFrame, "ESP Color", function(col)
	currentESPColor = col
end)

makeSectionLabel(espPanelFrame, "RGB")
makeToggle(espPanelFrame, "RGB Mode (Rainbow)", false, function(v)
	rgbESPEnabled = v
end)

makeSectionLabel(espPanelFrame, "DISPLAY")
makeToggle(espPanelFrame, "Show FOV Circle", true, function(v)
	fovCircleVisible = v
	fovCircle.Visible = v
end)

-- ================= MISC TAB =================
local miscPanelFrame = panels["MISC"]

makeSectionLabel(miscPanelFrame, "KEYBINDS")
makeKeybindRow(miscPanelFrame, "Toggle GUI", "RightShift", function(kc)
	guiKeyCode = kc
end)

makeSectionLabel(miscPanelFrame, "GUN COSMETICS")
makeToggle(miscPanelFrame, "RGB Gun Glow (Arsenal)", false, function(v)
	rgbGunEnabled = v
	if not v then
		for _, h in pairs(gunGlowHighlights) do
			if h and h.Parent then h:Destroy() end
		end
		gunGlowHighlights = {}
	end
end)

makeSectionLabel(miscPanelFrame, "INFO")
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 20)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Default toggle: RightShift"
infoLabel.TextColor3 = TEXT_DIM
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 10
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = miscPanelFrame

-- ================= FOV CIRCLE =================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness    = 1.5
fovCircle.Color        = ACCENT_BLU
fovCircle.Filled       = false
fovCircle.Transparency = 0.6
fovCircle.Visible      = true

-- ================= TEAM CHECK =================
local function isEnemy(p)
	if not player.Team or not p.Team then return true end
	return player.Team ~= p.Team
end

-- ================= ESP SYSTEM =================
local function addHighlight(char)
	if not char or char:FindFirstChild("EnemyHighlight") then return end
	local h = Instance.new("Highlight")
	h.Name = "EnemyHighlight"
	h.FillTransparency = 1
	h.OutlineTransparency = 0
	h.FillColor    = Color3.fromRGB(255, 60, 60)
	h.OutlineColor = currentESPColor
	h.Parent = char
end

local function removeHighlight(char)
	if not char then return end
	local h = char:FindFirstChild("EnemyHighlight")
	if h then h:Destroy() end
end

task.spawn(function()
	while true do
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character then
				if espEnabled and isEnemy(p) then
					addHighlight(p.Character)
				else
					removeHighlight(p.Character)
				end
			end
		end
		task.wait(0.5)
	end
end)

for _, p in pairs(Players:GetPlayers()) do
	if p ~= player then
		p.CharacterAdded:Connect(function()
			task.wait(0.5)
			if espEnabled and isEnemy(p) and p.Character then
				addHighlight(p.Character)
			end
		end)
	end
end

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function()
		task.wait(0.5)
		if espEnabled and isEnemy(p) and p.Character then
			addHighlight(p.Character)
		end
	end)
end)

-- ================= TARGETING =================
local function getClosestInFOV()
	local closest, closestDist = nil, FOV_RADIUS
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and isEnemy(p) and p.Character then
			local root = p.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local pos, onScreen = camera:WorldToViewportPoint(root.Position)
				if onScreen then
					local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
					if dist < closestDist then
						closest = root
						closestDist = dist
					end
				end
			end
		end
	end
	return closest
end

-- ================= SILENT AIM =================
local silentAimTarget = nil

RunService.RenderStepped:Connect(function()
	silentAimTarget = nil
	if silentAimEnabled then
		silentAimTarget = getClosestInFOV()
	end
end)

local mt = getrawmetatable and getrawmetatable(camera)
if mt then
	local oldIndex = mt.__index
	setreadonly(mt, false)
	mt.__index = function(self, key)
		if key == "ViewportPointToRay" and silentAimEnabled and silentAimTarget then
			return function(_, x, y, depth)
				local origin = camera.CFrame.Position
				local direction = (silentAimTarget.Position - origin).Unit * (depth or 1000)
				return Ray.new(origin, direction)
			end
		end
		return oldIndex(self, key)
	end
	setreadonly(mt, true)
end

-- ================= CHARACTER SETUP =================
local function setupCharacter(character)
	humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = currentSpeed
	pcall(function()
		if humanoid.UseJumpPower then
			humanoid.JumpPower = currentJumpPower
		else
			humanoid.JumpHeight = currentJumpPower / 5
		end
	end)
	pcall(function() humanoid.JumpPower = currentJumpPower end)
	pcall(function() humanoid.JumpHeight = currentJumpPower / 5 end)
end

if player.Character then setupCharacter(player.Character) end
player.CharacterAdded:Connect(setupCharacter)

-- ================= NOCLIP LOOP =================
RunService.Stepped:Connect(function()
	if not player.Character then return end
	if noClipEnabled then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- ================= INFINITE JUMP =================
local lastJumpTick = 0
UserInputService.JumpRequest:Connect(function()
	if not infiniteJumpEnabled or not humanoid then return end
	local now = tick()
	if now - lastJumpTick < 0.1 then return end
	lastJumpTick = now
	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end)

-- ================= HEARTBEAT ENFORCEMENT =================
RunService.Heartbeat:Connect(function()
	if not humanoid or not humanoid.Parent then return end
	if humanoid.WalkSpeed ~= currentSpeed then
		humanoid.WalkSpeed = currentSpeed
	end
	pcall(function()
		if humanoid.UseJumpPower then
			if humanoid.JumpPower ~= currentJumpPower then
				humanoid.JumpPower = currentJumpPower
			end
		else
			local targetHeight = currentJumpPower / 5
			if humanoid.JumpHeight ~= targetHeight then
				humanoid.JumpHeight = targetHeight
			end
		end
	end)
end)

-- ================= RGB CYCLE UTILITY =================
local function hsvToColor3(h, s, v)
	return Color3.fromHSV(h, s, v)
end

-- ================= TRACER SYSTEM =================
-- Pool of Drawing lines, one per enemy player slot
local function getOrCreateTracerLine(key)
	if not tracerLines[key] then
		local line = Drawing.new("Line")
		line.Thickness = 1.5
		line.Color = currentESPColor
		line.Transparency = 0.15
		line.Visible = false
		tracerLines[key] = line
	end
	return tracerLines[key]
end

local function clearTracerForKey(key)
	if tracerLines[key] then
		pcall(function() tracerLines[key]:Remove() end)
		tracerLines[key] = nil
	end
end

-- ================= GUN GLOW SYSTEM =================
local GUN_GLOW_COLOR = Color3.fromRGB(255, 60, 255)

local function isWeaponModel(obj)
	-- Arsenal stores guns/knives as Tool descendants in the character or workspace
	-- We try to match common Arsenal model naming patterns
	if obj:IsA("Tool") then return true end
	if obj:IsA("Model") and (
		obj.Name:lower():find("gun") or
		obj.Name:lower():find("knife") or
		obj.Name:lower():find("blade") or
		obj.Name:lower():find("sword") or
		obj.Name:lower():find("pistol") or
		obj.Name:lower():find("rifle") or
		obj.Name:lower():find("shotgun") or
		obj.Name:lower():find("sniper") or
		obj.Name:lower():find("smg") or
		obj.Name:lower():find("melee") or
		obj.Name:lower():find("bat") or
		obj.Name:lower():find("axe")
	) then return true end
	return false
end

local function applyGunGlow(model, color)
	-- Tag it so we don't double-apply
	if model:FindFirstChild("_GunGlowHL") then return end
	local h = Instance.new("Highlight")
	h.Name = "_GunGlowHL"
	h.FillColor = color
	h.OutlineColor = color
	h.FillTransparency = 0.4
	h.OutlineTransparency = 0
	h.Parent = model
	table.insert(gunGlowHighlights, h)
end

local function removeGunGlow(model)
	local h = model:FindFirstChild("_GunGlowHL")
	if h then h:Destroy() end
end

local function scanAndApplyGunGlow(color)
	-- Scan local character backpack and equipped tools
	if player.Character then
		for _, obj in ipairs(player.Character:GetChildren()) do
			if isWeaponModel(obj) then
				applyGunGlow(obj, color)
			end
		end
	end
	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		for _, obj in ipairs(backpack:GetChildren()) do
			if isWeaponModel(obj) then
				applyGunGlow(obj, color)
			end
		end
	end
end

local function clearAllGunGlow()
	for _, h in pairs(gunGlowHighlights) do
		if h and h.Parent then
			pcall(function() h:Destroy() end)
		end
	end
	gunGlowHighlights = {}
end

-- Watch for new tools being equipped/added
player.CharacterAdded:Connect(function(char)
	char.ChildAdded:Connect(function(child)
		if rgbGunEnabled and isWeaponModel(child) then
			task.wait(0.1)
			applyGunGlow(child, GUN_GLOW_COLOR)
		end
	end)
end)

-- Also watch backpack
local function watchBackpack()
	local bp = player:WaitForChild("Backpack")
	bp.ChildAdded:Connect(function(child)
		if rgbGunEnabled and isWeaponModel(child) then
			task.wait(0.1)
			applyGunGlow(child, GUN_GLOW_COLOR)
		end
	end)
end
task.spawn(watchBackpack)

-- ================= RENDER LOOP =================
RunService.RenderStepped:Connect(function(dt)
	-- ---- RGB HUE CYCLE ----
	rgbHue = (rgbHue + dt * 0.12) % 1
	local rgbColor = hsvToColor3(rgbHue, 1, 1)

	-- ---- RESOLVE ACTIVE ESP COLOR ----
	local activeColor = rgbESPEnabled and rgbColor or currentESPColor

	-- ---- FOV CIRCLE ----
	fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	fovCircle.Radius   = FOV_RADIUS
	fovCircle.Color    = activeColor
	fovCircle.Visible  = fovCircleVisible

	-- ---- SCREEN BOTTOM CENTER (tracer origin) ----
	local screenW = camera.ViewportSize.X
	local screenH = camera.ViewportSize.Y
	local tracerOrigin = Vector2.new(screenW / 2, screenH)

	-- ---- PER-PLAYER LOOP ----
	for _, p in pairs(Players:GetPlayers()) do
		if p == player then continue end

		local char = p.Character
		local tracerKey = tostring(p.UserId)

		-- Update highlight color if ESP is on
		if espEnabled and isEnemy(p) and char then
			local h = char:FindFirstChild("EnemyHighlight")
			if h then
				h.OutlineColor = activeColor
			end
		end

		-- Tracer logic
		if tracersEnabled and isEnemy(p) and char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
				local line = getOrCreateTracerLine(tracerKey)
				if onScreen then
					line.From = tracerOrigin
					line.To   = Vector2.new(screenPos.X, screenPos.Y)
					line.Color = activeColor
					line.Visible = true
				else
					line.Visible = false
				end
			else
				local line = tracerLines[tracerKey]
				if line then line.Visible = false end
			end
		else
			local line = tracerLines[tracerKey]
			if line then line.Visible = false end
		end
	end

	-- ---- GUN GLOW RGB UPDATE ----
	if rgbGunEnabled then
		GUN_GLOW_COLOR = rgbColor
		-- Refresh existing highlights with current color
		for _, h in pairs(gunGlowHighlights) do
			if h and h.Parent then
				h.FillColor = rgbColor
				h.OutlineColor = rgbColor
			end
		end
		-- Keep scanning in case new tools appeared
		scanAndApplyGunGlow(rgbColor)
	else
		-- If gun glow toggled off, handled in toggle callback; just skip
	end

	-- ---- AIMBOT ----
	if not aimEnabled then return end
	local target = getClosestInFOV()
	if not target then return end
	local desired = CFrame.new(camera.CFrame.Position, target.Position)
	camera.CFrame = camera.CFrame:Lerp(desired, SMOOTH)
end)

-- ================= GLOBAL KEYBINDS =================
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == guiKeyCode then
		guiVisible = not guiVisible
		outerFrame.Visible = guiVisible
	end
	if input.KeyCode == aimKeyCode then
		aimEnabled = not aimEnabled
	end
end)
