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
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ================= STATE =================
local aimEnabled          = false
local espEnabled          = false
local silentAimEnabled    = false
local noClipEnabled       = false
local infiniteJumpEnabled = false
local guiVisible          = true
local fovCircleVisible    = true  -- starts off; toggled independently
local tracersEnabled      = false
local rgbESPEnabled       = false
local rgbGunEnabled       = false
local headshotOnlyEnabled = false

local bHopEnabled         = false
local bHopKeyCode         = Enum.KeyCode.Space
local nameESPEnabled      = false
local healthESPEnabled    = false
local distanceESPEnabled  = false
local weaponESPEnabled    = false   -- NEW
local autoSprintEnabled   = false
local antiAimEnabled      = false
local spinbotEnabled      = false
local spinbotSpeed        = 10
local crosshairEnabled    = false
local crosshairSize       = 20
local crosshairThickness  = 2
local crosshairGap        = 5
local crosshairColor      = Color3.fromRGB(255,255,255)
local gunColorEnabled     = false
local gunColor            = Color3.fromRGB(255,0,255)
local rgbGunColorEnabled  = false
local clickTpEnabled      = false
local thirdPersonEnabled  = false
local thirdPersonDist     = 15
local fakeLagEnabled      = false
local fakeDeathEnabled    = false
local ghostModeEnabled    = false
local wallhookEnabled     = false
local autoParryEnabled    = false
local autoParryKeyCode    = Enum.KeyCode.F

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

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
local nameLabels = {}
local healthBars   = {}   -- now Drawing "Square" rectangles; key = uid.."_hp_bg" / "_hp_fill"
local distLabels = {}
local weaponLabels = {}   -- NEW  key = uid.."_wpn"
local crosshairLines = {}

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
outerFrame.Size = UDim2.new(0, 440, 0, 420)
outerFrame.Position = UDim2.new(0.5, -220, 0.5, -210)
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
titleLabel.Text = "Silence v1.2"
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
versionLabel.Text = "v1.2"
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

-- ================= MOBILE TOGGLE BUTTON =================
if isMobile then
	local mobileToggleBtn = Instance.new("TextButton")
	mobileToggleBtn.Size = UDim2.new(0, 50, 0, 50)
	mobileToggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
	mobileToggleBtn.BackgroundColor3 = BG_MID
	mobileToggleBtn.Text = "☰"
	mobileToggleBtn.TextColor3 = ACCENT_BLU
	mobileToggleBtn.Font = Enum.Font.GothamBold
	mobileToggleBtn.TextSize = 22
	mobileToggleBtn.BorderSizePixel = 0
	mobileToggleBtn.ZIndex = 100
	mobileToggleBtn.Parent = screenGui
	applyCorner(mobileToggleBtn, 8)
	applyStroke(mobileToggleBtn, ACCENT_BLU, 1.5)
	mobileToggleBtn.MouseButton1Click:Connect(function()
		guiVisible = not guiVisible
		outerFrame.Visible = guiVisible
	end)
	outerFrame.Size = UDim2.new(0.95, 0, 0.7, 0)
	outerFrame.Position = UDim2.new(0.025, 0, 0.15, 0)
end

-- ================= DRAGGABLE =================
local draggingWindow, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		draggingWindow = true
		dragStart = input.Position
		startPos = outerFrame.Position
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		draggingWindow = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if draggingWindow and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
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
tabLayout.Padding = UDim.new(0, 4)
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
local tabDefs = {"AIM", "MOVE", "PLAYER", "ESP", "VISUAL", "MISC"}

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
	btn.Size = UDim2.new(0, 62, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = tabName
	btn.TextColor3 = TEXT_DIM
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 10
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

-- makeToggle now returns BOTH a getter AND a setter so keybind toggles can sync the pill
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

	local function applyVisual(s)
		pill.BackgroundColor3 = s and GREEN_ON or Color3.fromRGB(60, 60, 80)
		knob.Position = s and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
	end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = row
	btn.MouseButton1Click:Connect(function()
		state = not state
		applyVisual(state)
		if callback then callback(state) end
	end)

	-- getter
	local function getState() return state end
	-- setter (for external keybind sync)
	local function setState(s)
		state = s
		applyVisual(state)
		if callback then callback(state) end
	end

	return getState, setState
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

	local function processSlide(inputPos)
		local x = math.clamp(inputPos.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
		local pct = x / track.AbsoluteSize.X
		fill.Size = UDim2.new(pct, 0, 1, 0)
		knob.Position = UDim2.new(pct, -6, 0.5, -6)
		local val = math.floor(min + (max - min) * pct)
		valLabel.Text = tostring(val)
		if callback then callback(val) end
	end

	track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
			or i.UserInputType == Enum.UserInputType.Touch then
			sliding = true
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
			or i.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not sliding then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement
			or i.UserInputType == Enum.UserInputType.Touch then
			processSlide(i.Position)
		end
	end)
end

local function makeSliderFloat(panel, labelText, min, max, default, decimals, callback)
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
	valLabel.Text = string.format("%."..decimals.."f", default)
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

	local function processSlide(inputPos)
		local x = math.clamp(inputPos.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
		local pct = x / track.AbsoluteSize.X
		fill.Size = UDim2.new(pct, 0, 1, 0)
		knob.Position = UDim2.new(pct, -6, 0.5, -6)
		local val = min + (max - min) * pct
		valLabel.Text = string.format("%."..decimals.."f", val)
		if callback then callback(val) end
	end

	track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
			or i.UserInputType == Enum.UserInputType.Touch then
			sliding = true
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
			or i.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not sliding then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement
			or i.UserInputType == Enum.UserInputType.Touch then
			processSlide(i.Position)
		end
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

local function makeColorPickerRow(panel, labelText, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = BG_ITEM
	row.BorderSizePixel = 0
	row.Parent = panel
	applyCorner(row, 6)
	applyStroke(row, BORDER_CLR, 1)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.45, 0, 1, 0)
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
	swatchLayout.Size = UDim2.new(0.52, 0, 0, 18)
	swatchLayout.Position = UDim2.new(0.46, 0, 0.5, -9)
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
			if callback then callback(c) end
		end)
	end
end

-- ================= AIM TAB =================
local aimPanelFrame = panels["AIM"]

makeSectionLabel(aimPanelFrame, "AIMBOT")
local getAimToggle, setAimToggle = makeToggle(aimPanelFrame, "Aimbot", false, function(v) aimEnabled = v end)
makeToggle(aimPanelFrame, "Silent Aim (Broken)", false, function(v) silentAimEnabled = v end)
makeToggle(aimPanelFrame, "Headshot Only", false, function(v) headshotOnlyEnabled = v end)

makeSectionLabel(aimPanelFrame, "SETTINGS")
makeSlider(aimPanelFrame, "FOV Radius", 60, 360, 120, function(v) FOV_RADIUS = v end)
makeSliderFloat(aimPanelFrame, "Smooth", 0.01, 1.0, 0.15, 2, function(v) SMOOTH = v end)

makeSectionLabel(aimPanelFrame, "KEYBINDS")
makeKeybindRow(aimPanelFrame, "Aim Key", "E", function(kc) aimKeyCode = kc end)

-- ================= MOVEMENT TAB =================
local movPanelFrame = panels["MOVE"]

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
	end
end)

makeSectionLabel(movPanelFrame, "TOGGLES")
makeToggle(movPanelFrame, "No Clip", false, function(v)
	noClipEnabled = v
	if not v and player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = true end
		end
	end
end)

makeSectionLabel(movPanelFrame, "Infinite Jump")
makeToggle(movPanelFrame, "Infinite Jump", false, function(v) bHopEnabled = v end)

makeToggle(movPanelFrame, "Anti AFK", false, function(v)
	if v then
		local vu = pcall(function() return game:GetService("VirtualUser") end)
		if vu then
			player.Idled:Connect(function()
				local virtualUser = game:GetService("VirtualUser")
				virtualUser:Button2Down(Vector2.new(0,0), camera.CFrame)
				task.wait(1)
				virtualUser:Button2Up(Vector2.new(0,0), camera.CFrame)
			end)
		end
	end
end)

-- ================= PLAYER TAB =================
local plrPanelFrame = panels["PLAYER"]

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
			if h then h.FillTransparency = v and 0.35 or 1 end
		end
	end
end)

makeSectionLabel(espPanelFrame, "LABELS")
makeToggle(espPanelFrame, "Name ESP", false, function(v)
	nameESPEnabled = v
	if not v then
		for key, lbl in pairs(nameLabels) do
			if lbl then pcall(function() lbl:Remove() end) end
		end
		nameLabels = {}
	end
end)

makeToggle(espPanelFrame, "Distance ESP", false, function(v)
	distanceESPEnabled = v
	if not v then
		for key, lbl in pairs(distLabels) do
			if lbl then pcall(function() lbl:Remove() end) end
		end
		distLabels = {}
	end
end)

makeSectionLabel(espPanelFrame, "TRACERS")
makeToggle(espPanelFrame, "Tracers", false, function(v)
	tracersEnabled = v
	if not v then
		for _, line in pairs(tracerLines) do
			if line then pcall(function() line:Remove() end) end
		end
		tracerLines = {}
	end
end)

makeSectionLabel(espPanelFrame, "ESP COLOR")
makeColorPickerRow(espPanelFrame, "ESP Color", function(col) currentESPColor = col end)

makeSectionLabel(espPanelFrame, "RGB")
makeToggle(espPanelFrame, "RGB Mode (Rainbow)", false, function(v) rgbESPEnabled = v end)

-- ===== FOV CIRCLE TOGGLE (FIXED – independent from aimbot) =====
makeSectionLabel(espPanelFrame, "DISPLAY")
makeToggle(espPanelFrame, "Show FOV Circle", false, function(v)
	fovCircleVisible = v
end)

-- ================= VISUAL TAB =================
local visualPanelFrame = panels["VISUAL"]

makeSectionLabel(visualPanelFrame, "GUN COLOR (Broken)")
makeToggle(visualPanelFrame, "Gun Color Override (Broken)", false, function(v)
	gunColorEnabled = v
	if not v then
		for _, h in pairs(gunGlowHighlights) do
			if h and h.Parent then h:Destroy() end
		end
		gunGlowHighlights = {}
	end
end)
makeColorPickerRow(visualPanelFrame, "Gun Color", function(col) gunColor = col end)

makeToggle(visualPanelFrame, "RGB Gun Glow (Broken)", false, function(v)
	rgbGunColorEnabled = v
	if not v then
		for _, h in pairs(gunGlowHighlights) do
			if h and h.Parent then h:Destroy() end
		end
		gunGlowHighlights = {}
	end
end)

-- ================= MISC TAB =================
local miscPanelFrame = panels["MISC"]

makeSectionLabel(miscPanelFrame, "KEYBINDS")
makeKeybindRow(miscPanelFrame, "Toggle GUI", "RightShift", function(kc) guiKeyCode = kc end)

-- ================= FOV CIRCLE =================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness    = 1.5
fovCircle.Color        = ACCENT_BLU
fovCircle.Filled       = false
fovCircle.Transparency = 0.6
fovCircle.Visible      = false   -- start hidden; toggled by the toggle above

-- ================= CROSSHAIR DRAWING =================
local function buildCrosshairLines()
	for _, l in pairs(crosshairLines) do
		if l then pcall(function() l:Remove() end) end
	end
	crosshairLines = {}
	for i = 1, 4 do
		local line = Drawing.new("Line")
		line.Thickness = crosshairThickness
		line.Color = crosshairColor
		line.Transparency = 0
		line.Visible = false
		table.insert(crosshairLines, line)
	end
end
buildCrosshairLines()

-- ================= TEAM CHECK =================
local function isEnemy(p)
	if not player.Team or not p.Team then return true end
	return player.Team ~= p.Team
end

-- ================= TARGET RESOLUTION =================
local function getAimPart(character)
	if headshotOnlyEnabled then
		return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
	else
		return character:FindFirstChild("HumanoidRootPart")
	end
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

-- ================= HEALTH BAR DRAWING HELPERS (rectangle) =================
-- We use two Drawing.Square objects: a dark background and a colored fill.
local function getOrCreateHealthBarPair(uid)
	local bgKey   = uid .. "_hp_bg"
	local fillKey = uid .. "_hp_fill"
	if not healthBars[bgKey] then
		local bg = Drawing.new("Square")
		bg.Color        = Color3.fromRGB(20, 20, 20)
		bg.Filled       = true
		bg.Thickness    = 1
		bg.Transparency = 0.3
		bg.Visible      = false
		healthBars[bgKey] = bg
	end
	if not healthBars[fillKey] then
		local fill = Drawing.new("Square")
		fill.Color       = Color3.fromRGB(0, 255, 0)
		fill.Filled      = true
		fill.Thickness   = 1
		fill.Transparency = 0
		fill.Visible     = false
		healthBars[fillKey] = fill
	end
	return healthBars[bgKey], healthBars[fillKey]
end

local function hideHealthBar(uid)
	local bg   = healthBars[uid .. "_hp_bg"]
	local fill = healthBars[uid .. "_hp_fill"]
	if bg   then bg.Visible   = false end
	if fill then fill.Visible = false end
end

local function removeHealthBarPair(uid)
	local bgKey   = uid .. "_hp_bg"
	local fillKey = uid .. "_hp_fill"
	for _, k in ipairs({bgKey, fillKey}) do
		if healthBars[k] then
			pcall(function() healthBars[k]:Remove() end)
			healthBars[k] = nil
		end
	end
end

-- ================= WEAPON LABEL HELPERS (NEW) =================
local function getOrCreateWeaponLabel(key)
	if not weaponLabels[key] then
		local lbl = Drawing.new("Text")
		lbl.Size = 12
		lbl.Center = true
		lbl.Outline = true
		lbl.OutlineColor = Color3.fromRGB(0, 0, 0)
		lbl.Color = Color3.fromRGB(255, 200, 60)
		lbl.Font = Drawing.Fonts.UI
		lbl.Visible = false
		weaponLabels[key] = lbl
	end
	return weaponLabels[key]
end

local function getEquippedWeaponName(p)
	-- Check character for equipped Tool
	if p.Character then
		for _, child in ipairs(p.Character:GetChildren()) do
			if child:IsA("Tool") then
				return child.Name
			end
		end
	end
	return nil
end

-- ================= ESP CLEANUP ON PLAYER LEAVE =================
local function cleanupPlayerESP(leavingPlayer)
	local key = tostring(leavingPlayer.UserId)

	-- Tracer line
	local tracerLine = tracerLines[key]
	if tracerLine then
		pcall(function() tracerLine:Remove() end)
		tracerLines[key] = nil
	end

	-- Name label
	local nameLbl = nameLabels[key .. "_name"]
	if nameLbl then
		pcall(function() nameLbl:Remove() end)
		nameLabels[key .. "_name"] = nil
	end

	-- Health bar pair
	removeHealthBarPair(key)

	-- Distance label
	local distLbl = distLabels[key .. "_dist"]
	if distLbl then
		pcall(function() distLbl:Remove() end)
		distLabels[key .. "_dist"] = nil
	end

	-- Weapon label (NEW)
	local wpnLbl = weaponLabels[key .. "_wpn"]
	if wpnLbl then
		pcall(function() wpnLbl:Remove() end)
		weaponLabels[key .. "_wpn"] = nil
	end

	-- Highlight on character
	if leavingPlayer.Character then
		removeHighlight(leavingPlayer.Character)
	end
end

Players.PlayerRemoving:Connect(function(leavingPlayer)
	cleanupPlayerESP(leavingPlayer)
end)

Players.PlayerAdded:Connect(function(p)
	p.CharacterRemoving:Connect(function(char)
		removeHighlight(char)
	end)
	p.CharacterAdded:Connect(function()
		task.wait(0.5)
		if espEnabled and isEnemy(p) and p.Character then
			addHighlight(p.Character)
		end
	end)
end)

for _, p in pairs(Players:GetPlayers()) do
	if p ~= player then
		p.CharacterRemoving:Connect(function(char)
			removeHighlight(char)
		end)
		p.CharacterAdded:Connect(function()
			task.wait(0.5)
			if espEnabled and isEnemy(p) and p.Character then
				addHighlight(p.Character)
			end
		end)
	end
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

-- ================= TARGETING =================
local function getClosestInFOV()
	local closest, closestDist = nil, FOV_RADIUS
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and isEnemy(p) and p.Character then
			local aimPart = getAimPart(p.Character)
			if aimPart then
				local pos, onScreen = camera:WorldToViewportPoint(aimPart.Position)
				if onScreen then
					local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
					if dist < closestDist then
						closest = aimPart
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

local worldRootMT = getrawmetatable and getrawmetatable(workspace)
if worldRootMT then
	local oldNamecall
	pcall(function()
		setreadonly(worldRootMT, false)
		oldNamecall = worldRootMT.__namecall
		worldRootMT.__namecall = newcclosure(function(self, ...)
			local method = getnamecallmethod()
			if silentAimEnabled and silentAimTarget and (
				method == "FindPartOnRay" or
				method == "FindPartOnRayWithIgnoreList" or
				method == "FindPartOnRayWithWhitelist" or
				method == "Raycast"
			) then
				local args = {...}
				if method == "Raycast" then
					local origin = args[1]
					if origin and typeof(origin) == "Vector3" then
						local targetPos = silentAimTarget.Position
						local dir = (targetPos - origin)
						local origLen = args[2] and args[2].Magnitude or dir.Magnitude
						args[2] = dir.Unit * origLen
					end
				else
					local ray = args[1]
					if ray and typeof(ray) == "userdata" then
						local targetPos = silentAimTarget.Position
						local dir = (targetPos - ray.Origin)
						local origLen = ray.Direction.Magnitude
						args[1] = Ray.new(ray.Origin, dir.Unit * origLen)
					end
				end
				return oldNamecall(self, table.unpack(args))
			end
			return oldNamecall(self, ...)
		end)
		setreadonly(worldRootMT, true)
	end)
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

	if ghostModeEnabled then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.LocalTransparencyModifier = 0.7
			end
		end
	end
end

if player.Character then setupCharacter(player.Character) end
player.CharacterAdded:Connect(setupCharacter)

-- ================= NOCLIP LOOP =================
RunService.Stepped:Connect(function()
	if not player.Character then return end
	if noClipEnabled then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)

-- ================= BUNNY HOP =================
local lastBHopTick = 0
local bHopConnection

local function connectBHop()
	if bHopConnection then bHopConnection:Disconnect() end
	bHopConnection = UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if not bHopEnabled or not humanoid then return end
		if input.KeyCode == bHopKeyCode then
			local now = tick()
			if now - lastBHopTick < 0.05 then return end
			lastBHopTick = now
			if humanoid:GetState() == Enum.HumanoidStateType.Freefall
				or humanoid:GetState() == Enum.HumanoidStateType.Running then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end)
end
connectBHop()

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
	local targetSpeed = autoSprintEnabled and math.max(currentSpeed, 24) or currentSpeed
	if humanoid.WalkSpeed ~= targetSpeed then humanoid.WalkSpeed = targetSpeed end
	pcall(function()
		if humanoid.UseJumpPower then
			if humanoid.JumpPower ~= currentJumpPower then humanoid.JumpPower = currentJumpPower end
		else
			local targetHeight = currentJumpPower / 5
			if humanoid.JumpHeight ~= targetHeight then humanoid.JumpHeight = targetHeight end
		end
	end)

	if spinbotEnabled and player.Character then
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinbotSpeed), 0) end
	end

	if antiAimEnabled and player.Character then
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(180), 0) end
	end

	if wallhookEnabled and player.Character then
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local ray = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 4)
			if ray and ray.Instance and not ray.Instance:IsDescendantOf(player.Character) then
				hrp.Velocity = Vector3.new(0, 0, 0)
				hrp.CFrame = CFrame.new(ray.Position + ray.Normal * 2.5, ray.Position)
			end
		end
	end
end)

-- ================= CLICK TELEPORT =================
local clickTpConn
local function connectClickTp()
	if clickTpConn then clickTpConn:Disconnect() end
	clickTpConn = UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if not clickTpEnabled then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			local unitRay = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
			local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, RaycastParams.new())
			if result and player.Character then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0)) end
			end
		end
	end)
end
connectClickTp()

-- ================= THIRD PERSON CAMERA =================
RunService.RenderStepped:Connect(function()
	if thirdPersonEnabled and player.Character then
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			camera.CameraType = Enum.CameraType.Scriptable
			local camOffset = hrp.CFrame * CFrame.new(0, 3, thirdPersonDist)
			camera.CFrame = CFrame.new(camOffset.Position, hrp.Position)
		end
	elseif not thirdPersonEnabled and camera.CameraType == Enum.CameraType.Scriptable then
		camera.CameraType = Enum.CameraType.Custom
	end
end)

-- ================= RGB UTILITY =================
local function hsvToColor3(h, s, v)
	return Color3.fromHSV(h, s, v)
end

-- ================= DRAWING HELPERS =================
local function getOrCreateTracerLine(key)
	if not tracerLines[key] then
		local line = Drawing.new("Line")
		line.Thickness = 3
		line.Color = currentESPColor
		line.Transparency = 0.15
		line.Visible = false
		tracerLines[key] = line
	end
	return tracerLines[key]
end

local function getOrCreateNameLabel(key)
	if not nameLabels[key] then
		local lbl = Drawing.new("Text")
		lbl.Size = 14
		lbl.Center = true
		lbl.Outline = true
		lbl.OutlineColor = Color3.fromRGB(0,0,0)
		lbl.Color = currentESPColor
		lbl.Font = Drawing.Fonts.UI
		lbl.Visible = false
		nameLabels[key] = lbl
	end
	return nameLabels[key]
end

local function getOrCreateDistLabel(key)
	if not distLabels[key] then
		local lbl = Drawing.new("Text")
		lbl.Size = 12
		lbl.Center = true
		lbl.Outline = true
		lbl.OutlineColor = Color3.fromRGB(0,0,0)
		lbl.Color = Color3.fromRGB(255,200,60)
		lbl.Font = Drawing.Fonts.UI
		lbl.Visible = false
		distLabels[key] = lbl
	end
	return distLabels[key]
end

-- ================= GUN GLOW SYSTEM =================
local currentGunRGBColor = Color3.fromRGB(255, 0, 255)

local function isWeaponModel(obj)
	if obj:IsA("Tool") then return true end
	if obj:IsA("Model") and (
		obj.Name:lower():find("gun") or obj.Name:lower():find("knife") or
		obj.Name:lower():find("blade") or obj.Name:lower():find("sword") or
		obj.Name:lower():find("pistol") or obj.Name:lower():find("rifle") or
		obj.Name:lower():find("shotgun") or obj.Name:lower():find("sniper") or
		obj.Name:lower():find("smg") or obj.Name:lower():find("melee") or
		obj.Name:lower():find("bat") or obj.Name:lower():find("axe")
	) then return true end
	return false
end

local function applyGunGlow(model)
	if not model or not model.Parent then return end
	local existing = model:FindFirstChild("_GunGlowHL")
	if existing then return end
	local h = Instance.new("Highlight")
	h.Name = "_GunGlowHL"
	local useColor = (rgbGunColorEnabled or rgbGunEnabled) and currentGunRGBColor
		or (gunColorEnabled and gunColor)
		or Color3.fromRGB(255, 0, 255)
	h.FillColor = useColor
	h.OutlineColor = useColor
	h.FillTransparency = 0.0
	h.OutlineTransparency = 0
	h.Adornee = model
	h.Parent = model
	table.insert(gunGlowHighlights, h)
end

local function removeGunGlow(model)
	if not model then return end
	local h = model:FindFirstChild("_GunGlowHL")
	if h then h:Destroy() end
end

local function clearAllGunGlow()
	for _, h in pairs(gunGlowHighlights) do
		if h and h.Parent then pcall(function() h:Destroy() end) end
	end
	gunGlowHighlights = {}
end

local function scanAndApplyGunGlow()
	if player.Character then
		for _, obj in ipairs(player.Character:GetChildren()) do
			if isWeaponModel(obj) then applyGunGlow(obj) end
		end
	end
	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		for _, obj in ipairs(backpack:GetChildren()) do
			if isWeaponModel(obj) then applyGunGlow(obj) end
		end
	end
end

player.CharacterAdded:Connect(function(char)
	char.ChildAdded:Connect(function(child)
		if (rgbGunEnabled or rgbGunColorEnabled or gunColorEnabled) and isWeaponModel(child) then
			task.wait(0.1)
			applyGunGlow(child)
		end
	end)
end)

local function watchBackpack()
	local bp = player:WaitForChild("Backpack")
	bp.ChildAdded:Connect(function(child)
		if (rgbGunEnabled or rgbGunColorEnabled or gunColorEnabled) and isWeaponModel(child) then
			task.wait(0.1)
			applyGunGlow(child)
		end
	end)
end
task.spawn(watchBackpack)

-- ================= HEALTH COLOR GRADIENT (green → orange → red) =================
local function healthColor(ratio)
	-- ratio 1.0 = full green, 0.5 = orange, 0.0 = red
	if ratio >= 0.5 then
		local t = (ratio - 0.5) / 0.5
		return Color3.fromRGB(
			math.floor(255 * (1 - t)),   -- red channel
			math.floor(220 * t + 160),   -- green channel
			0
		)
	else
		local t = ratio / 0.5
		return Color3.fromRGB(
			255,
			math.floor(160 * t),
			0
		)
	end
end

-- ================= RENDER LOOP =================
RunService.RenderStepped:Connect(function(dt)
	rgbHue = (rgbHue + dt * 0.12) % 1
	local rgbColor = hsvToColor3(rgbHue, 1, 1)
	local activeColor = rgbESPEnabled and rgbColor or currentESPColor

	-- FOV circle: visible whenever fovCircleVisible is true, regardless of aimbot state
	fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	fovCircle.Radius   = FOV_RADIUS
	fovCircle.Color    = activeColor
	fovCircle.Visible  = fovCircleVisible

	local screenW = camera.ViewportSize.X
	local screenH = camera.ViewportSize.Y
	local tracerOrigin = Vector2.new(screenW / 2, screenH)

	if crosshairEnabled and #crosshairLines >= 4 then
		local cx = screenW / 2
		local cy = screenH / 2
		crosshairLines[1].From = Vector2.new(cx - crosshairSize - crosshairGap, cy)
		crosshairLines[1].To   = Vector2.new(cx - crosshairGap, cy)
		crosshairLines[1].Color = crosshairColor
		crosshairLines[1].Thickness = crosshairThickness
		crosshairLines[1].Visible = true
		crosshairLines[2].From = Vector2.new(cx + crosshairGap, cy)
		crosshairLines[2].To   = Vector2.new(cx + crosshairSize + crosshairGap, cy)
		crosshairLines[2].Color = crosshairColor
		crosshairLines[2].Thickness = crosshairThickness
		crosshairLines[2].Visible = true
		crosshairLines[3].From = Vector2.new(cx, cy - crosshairSize - crosshairGap)
		crosshairLines[3].To   = Vector2.new(cx, cy - crosshairGap)
		crosshairLines[3].Color = crosshairColor
		crosshairLines[3].Thickness = crosshairThickness
		crosshairLines[3].Visible = true
		crosshairLines[4].From = Vector2.new(cx, cy + crosshairGap)
		crosshairLines[4].To   = Vector2.new(cx, cy + crosshairSize + crosshairGap)
		crosshairLines[4].Color = crosshairColor
		crosshairLines[4].Thickness = crosshairThickness
		crosshairLines[4].Visible = true
	else
		for _, line in pairs(crosshairLines) do
			if line then line.Visible = false end
		end
	end

	-- Active player set for stale-cleanup
	local activePlayers = {}
	for _, p in pairs(Players:GetPlayers()) do
		activePlayers[tostring(p.UserId)] = true
	end

	-- Stale tracer cleanup
	for key, line in pairs(tracerLines) do
		if not activePlayers[key] then
			pcall(function() line:Remove() end)
			tracerLines[key] = nil
		end
	end
	-- Stale name label cleanup
	for key, lbl in pairs(nameLabels) do
		local uid = key:match("^(%d+)_name$")
		if uid and not activePlayers[uid] then
			pcall(function() lbl:Remove() end)
			nameLabels[key] = nil
		end
	end
	-- Stale health bar cleanup
	for key, obj in pairs(healthBars) do
		local uid = key:match("^(%d+)_hp_")
		if uid and not activePlayers[uid] then
			pcall(function() obj:Remove() end)
			healthBars[key] = nil
		end
	end
	-- Stale dist label cleanup
	for key, lbl in pairs(distLabels) do
		local uid = key:match("^(%d+)_dist$")
		if uid and not activePlayers[uid] then
			pcall(function() lbl:Remove() end)
			distLabels[key] = nil
		end
	end
	-- Stale weapon label cleanup
	for key, lbl in pairs(weaponLabels) do
		local uid = key:match("^(%d+)_wpn$")
		if uid and not activePlayers[uid] then
			pcall(function() lbl:Remove() end)
			weaponLabels[key] = nil
		end
	end

	-- ===== PER-PLAYER ESP =====
	for _, p in pairs(Players:GetPlayers()) do
		if p == player then continue end

		local char      = p.Character
		local uid       = tostring(p.UserId)

		-- Update ESP highlight colour
		if espEnabled and isEnemy(p) and char then
			local h = char:FindFirstChild("EnemyHighlight")
			if h then h.OutlineColor = activeColor end
		end

		if isEnemy(p) and char then
			local aimPart = getAimPart(char)
			local head    = char:FindFirstChild("Head")
			local hum     = char:FindFirstChildOfClass("Humanoid")

			-- --- TRACERS ---
			if tracersEnabled and aimPart then
				local screenPos, onScreen = camera:WorldToViewportPoint(aimPart.Position)
				local line = getOrCreateTracerLine(uid)
				if onScreen then
					line.From = tracerOrigin
					line.To   = Vector2.new(screenPos.X, screenPos.Y)
					line.Color = activeColor
					line.Visible = true
				else
					line.Visible = false
				end
			else
				local line = tracerLines[uid]
				if line then line.Visible = false end
			end

			-- --- NAME ESP ---
			if nameESPEnabled and head then
				local nameScreenPos, nameOnScreen = camera:WorldToViewportPoint(
					head.Position + Vector3.new(0, 2.5, 0)
				)
				local nameLbl = getOrCreateNameLabel(uid .. "_name")
				if nameOnScreen then
					nameLbl.Text = p.Name
					nameLbl.Position = Vector2.new(nameScreenPos.X, nameScreenPos.Y)
					nameLbl.Color = activeColor
					nameLbl.Visible = true
				else
					nameLbl.Visible = false
				end
			else
				local lbl = nameLabels[uid .. "_name"]
				if lbl then lbl.Visible = false end
			end

			-- --- HEALTH ESP (rectangle bar, fixed) ---
			if healthESPEnabled and head and hum then
				local hpScreenPos, hpOnScreen = camera:WorldToViewportPoint(head.Position)
				local bgRect, fillRect = getOrCreateHealthBarPair(uid)

				if hpOnScreen then
					local hpRatio   = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
					local barW      = 4     -- width of the vertical bar in pixels
					local barH      = 40    -- total height of the bar
					local barX      = hpScreenPos.X - 22   -- left of the bar
					local barTopY   = hpScreenPos.Y - barH / 2

					-- Background (dark, full height)
					bgRect.Size     = Vector2.new(barW, barH)
					bgRect.Position = Vector2.new(barX, barTopY)
					bgRect.Visible  = true

					-- Fill (grows from bottom upward based on HP ratio)
					local fillH      = math.max(1, barH * hpRatio)
					local fillY      = barTopY + (barH - fillH)   -- bottom-aligned
					fillRect.Size     = Vector2.new(barW, fillH)
					fillRect.Position = Vector2.new(barX, fillY)
					fillRect.Color    = healthColor(hpRatio)
					fillRect.Visible  = true
				else
					hideHealthBar(uid)
				end
			else
				hideHealthBar(uid)
			end

			-- --- DISTANCE ESP ---
			if distanceESPEnabled and aimPart and player.Character then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local dist = math.floor((hrp.Position - aimPart.Position).Magnitude)
					local distScreenPos, distOnScreen = camera:WorldToViewportPoint(
						aimPart.Position + Vector3.new(0, -2, 0)
					)
					local distLbl = getOrCreateDistLabel(uid .. "_dist")
					if distOnScreen then
						distLbl.Text = tostring(dist) .. "m"
						distLbl.Position = Vector2.new(distScreenPos.X, distScreenPos.Y)
						distLbl.Visible = true
					else
						distLbl.Visible = false
					end
				end
			else
				local lbl = distLabels[uid .. "_dist"]
				if lbl then lbl.Visible = false end
			end

			-- --- WEAPON ESP (NEW) ---
			if weaponESPEnabled and head then
				local wpnName = getEquippedWeaponName(p)
				local wpnLbl  = getOrCreateWeaponLabel(uid .. "_wpn")
				local wpnScreenPos, wpnOnScreen = camera:WorldToViewportPoint(
					head.Position + Vector3.new(0, -2.8, 0)
				)
				if wpnOnScreen and wpnName then
					wpnLbl.Text     = "🔫 " .. wpnName
					wpnLbl.Position = Vector2.new(wpnScreenPos.X, wpnScreenPos.Y)
					wpnLbl.Color    = Color3.fromRGB(255, 180, 50)
					wpnLbl.Visible  = true
				else
					wpnLbl.Visible = false
				end
			else
				local lbl = weaponLabels[uid .. "_wpn"]
				if lbl then lbl.Visible = false end
			end
		end
	end

	-- Gun glow per-frame update
	local gunGlowActive = rgbGunEnabled or rgbGunColorEnabled or gunColorEnabled
	if gunGlowActive then
		local resolvedGunColor = (rgbGunEnabled or rgbGunColorEnabled) and rgbColor or gunColor
		currentGunRGBColor = resolvedGunColor

		local validHighlights = {}
		for _, h in pairs(gunGlowHighlights) do
			if h and h.Parent then
				h.FillColor    = resolvedGunColor
				h.OutlineColor = resolvedGunColor
				table.insert(validHighlights, h)
			end
		end
		gunGlowHighlights = validHighlights
		scanAndApplyGunGlow()
	end

	-- Aimbot
	if not aimEnabled then return end
	local target = getClosestInFOV()
	if not target then return end
	local desired = CFrame.new(camera.CFrame.Position, target.Position)
	camera.CFrame = camera.CFrame:Lerp(desired, SMOOTH)
end)

-- ================= GLOBAL KEYBINDS =================
-- Aim key syncs the GUI toggle pill so they stay in agreement
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == guiKeyCode then
		guiVisible = not guiVisible
		outerFrame.Visible = guiVisible
	end
	if input.KeyCode == aimKeyCode then
		aimEnabled = not aimEnabled
		setAimToggle(aimEnabled)   -- sync pill to match keybind state
	end
end)
