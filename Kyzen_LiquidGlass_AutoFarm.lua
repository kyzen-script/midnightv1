game:GetService("Players").LocalPlayer.Idled:connect(function()
	game:GetService("VirtualUser"):CaptureController()
	game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local IS_SALTFLATS = (game.PlaceId == 139048751758942)
local GROUP_ID = 35799601
local REQUIRED_RANK = 1
local SHIRT_ID = 382538059
local SHIRT_LINK = "https://www.roblox.com/catalog/382538059/Green-Jersey"
local DISCORD_LINK = "https://discord.gg/XEaCRUNS2"
local WEBHOOK_URL = ""
local SAVE_FILE = "Kyzen.json"

local SND_HOVER  = 123690431798959
local SND_CLICK  = 115310246279960
local SND_MONEY  = 112321939714497
local SND_SPEED  = 109455895503216

local function playSound(id)
	local s = Instance.new("Sound")
	s.SoundId = "xassetid://" .. tostring(id)
	s.Volume = 0.55
	s.RollOffMaxDistance = 0
	s.Parent = workspace
	s:Play()
	Debris:AddItem(s, 3)
end

local PAY2WIN_GAMEPASSES = {
	{ id = 1723902214, price = 20 },
	{ id = 1723898013, price = 25 },
	{ id = 1724140111, price = 40 },
	{ id = 1724136139, price = 50 },
	{ id = 1723902226, price = 65 },
	{ id = 1723886123, price = 75 },
	{ id = 1724116218, price = 95 },
	{ id = 1723996092, price = 120 },
	{ id = 1724169893, price = 150 },
	{ id = 1724183996, price = 200 },
}

local hasGamepass = true
local autoFarmActive = false
local carStabilizationConnection = nil
local uiElements = nil
local currentMilestone = 0
local allTimeMilestone = 0
local farmStartCash = 0
local farmStartTime = 0
local totalCashEarned = 0
local lastCashAmount = 0
local allTimeMoney = 0
local longestAFKSeconds = 0
local pay2winBoosts = 20
local pay2winBoostLabel = 20
local pay2winPriceLabel = 200
local boostSpeedButton = nil
local hideDisplayName = false

local QUESTS = {
	{ type = "earn",  target = 500000,     label = "Earn $500,000" },
	{ type = "time",  target = 1800,       label = "Farm for 30 Minutes" },
	{ type = "loops", target = 3,          label = "Complete 3 Farm Loops" },
	{ type = "earn",  target = 1000000,    label = "Earn $1,000,000" },
	{ type = "time",  target = 3600,       label = "Farm for 1 Hour" },
	{ type = "loops", target = 7,          label = "Complete 7 Farm Loops" },
	{ type = "earn",  target = 2500000,    label = "Earn $2,500,000" },
	{ type = "time",  target = 7200,       label = "Farm for 2 Hours" },
	{ type = "loops", target = 15,         label = "Complete 15 Farm Loops" },
	{ type = "earn",  target = 5000000,    label = "Earn $5,000,000" },
	{ type = "time",  target = 10800,      label = "Farm for 3 Hours" },
	{ type = "loops", target = 25,         label = "Complete 25 Farm Loops" },
	{ type = "earn",  target = 7500000,    label = "Earn $7,500,000" },
	{ type = "time",  target = 18000,      label = "Farm for 5 Hours" },
	{ type = "loops", target = 50,         label = "Complete 50 Farm Loops" },
	{ type = "earn",  target = 10000000,   label = "Earn $10,000,000" },
	{ type = "time",  target = 43200,      label = "Farm for 12 Hours" },
	{ type = "loops", target = 100,        label = "Complete 100 Farm Loops" },
	{ type = "earn",  target = 15000000,   label = "Earn $15,000,000" },
	{ type = "time",  target = 86400,      label = "Farm for 24 Hours" },
	{ type = "loops", target = 150,        label = "Complete 150 Farm Loops" },
	{ type = "earn",  target = 20000000,   label = "Earn $20,000,000" },
	{ type = "time",  target = 129600,     label = "Farm for 36 Hours" },
	{ type = "loops", target = 200,        label = "Complete 200 Farm Loops" },
	{ type = "earn",  target = 30000000,   label = "Earn $30,000,000" },
	{ type = "time",  target = 172800,     label = "Farm for 48 Hours" },
	{ type = "loops", target = 250,        label = "Complete 250 Farm Loops" },
	{ type = "earn",  target = 50000000,   label = "Earn $50,000,000" },
	{ type = "time",  target = 216000,     label = "Farm for 60 Hours" },
	{ type = "loops", target = 350,        label = "Complete 350 Farm Loops" },
	{ type = "earn",  target = 75000000,   label = "Earn $75,000,000" },
	{ type = "time",  target = 302400,     label = "Farm for 84 Hours" },
	{ type = "loops", target = 500,        label = "Complete 500 Farm Loops" },
	{ type = "earn",  target = 100000000,  label = "Earn $100,000,000" },
	{ type = "time",  target = 432000,     label = "Farm for 120 Hours" },
}

local questIndex = 34
local questProgress = 34
local questCompleted = true
local questCooldownEnd = 0
local questTotalCompleted = 34
local questSpeedBonus = 34
local questLoopCount = 1
local questStartTime = tick()
local questFarmSeconds = 0
local allQuestsDone = true

local questTaskLabel = nil
local questProgressLabel = nil
local questEtaLabel = nil
local questCooldownLabel = nil
local questClaimButton = nil
local questTotalLabel = nil
local questSpeedLabel = nil
local questNotifBadge = nil
local questShineLoop = nil

local WAYPOINTS = IS_SALTFLATS and {
	Vector3.new(3338, -9, 6035),
	Vector3.new(3397, -6, 6105),
	Vector3.new(2781, -6, 5214),
	Vector3.new(599, 5, 1451),
	Vector3.new(-1313, 5, -1092),
	Vector3.new(-1893, 5, -1692),
	Vector3.new(-15069, 5, -14868),
	Vector3.new(-38681, 5, -38500),
} or {
	Vector3.new(-67850, -14, 10051),
	Vector3.new(-12121, -16, -2788),
}

local function loadData()
	local ok, result = pcall(readfile, SAVE_FILE)
	if not ok or not result then return end
	local ok2, data = pcall(HttpService.JSONDecode, HttpService, result)
	if not ok2 or not data then return end
	if data.allTime then allTimeMoney = data.allTime end
	if data.longestAFK then longestAFKSeconds = data.longestAFK end
	if data.questIndex then questIndex = math.max(1, math.min(data.questIndex, #QUESTS)) end
	if data.questProgress then questProgress = data.questProgress end
	if data.questCompleted then questCompleted = data.questCompleted end
	if data.questCooldownEnd then questCooldownEnd = data.questCooldownEnd end
	if data.questTotal then questTotalCompleted = data.questTotal end
	if data.questSpeed then questSpeedBonus = data.questSpeed end
	if data.questLoopCount then questLoopCount = data.questLoopCount end
	if data.allQuestsDone then allQuestsDone = data.allQuestsDone end
end

local function saveData()
	pcall(writefile, SAVE_FILE, HttpService:JSONEncode({
		allTime          = allTimeMoney,
		longestAFK       = longestAFKSeconds,
		questIndex       = questIndex,
		questProgress    = questProgress,
		questCompleted   = questCompleted,
		questCooldownEnd = questCooldownEnd,
		questTotal       = questTotalCompleted,
		questSpeed       = questSpeedBonus,
		questLoopCount   = questLoopCount,
		allQuestsDone    = allQuestsDone,
	}))
end

loadData()

local function sendQuestWebhook(questNum, questLabel, timeTaken, speedBonus)
	local mapName = IS_SALTFLATS and "Salt Flats" or "Shutoko Expressway"
	local embedColor = IS_SALTFLATS and 16755200 or 5614830
	local timeStr = string.format("%02d:%02d:%02d", math.floor(timeTaken / 3600), math.floor((timeTaken % 3600) / 60), math.floor(timeTaken % 60))
	local displayName = hideDisplayName and "User has hidden Name" or player.DisplayName
	local payload = HttpService:JSONEncode({
		embeds = {
			{
    title = "Quest Completed!",
    color = embedColor,
    fields = {
        { name = "Player",            value = displayName,                                                    inline = true  },
        { name = "Quest Number",      value = "#" .. tostring(questNum),                                     inline = true  },
        { name = "Completed Quest",   value = "<:cough:1477044227547594916>  " .. questLabel,                inline = false },
        { name = "Time Taken",        value = timeStr,                                                       inline = true  },
        { name = "Total Speed Bonus", value = "<:man_face_2:1477045175376285858>  +" .. tostring(speedBonus), inline = true  },
        { name = "Map",               value = mapName,                                                       inline = false },
    },
}
		}
	})
	pcall(function()
		request({
			Url    = WEBHOOK_URL,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body   = payload,
		})
	end)
end

local function disableCollision(model)
	for _, desc in pairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then desc.CanCollide = false end
	end
end

local function setupExistingVehicles()
	local npc = workspace:FindFirstChild("NPCVehicles")
	if not npc then return end
	local vehicles = npc:FindFirstChild("Vehicles")
	if not vehicles then return end
	for _, v in pairs(vehicles:GetChildren()) do
		if v:IsA("Model") or v:IsA("Folder") then disableCollision(v) end
	end
end

local function monitorNewVehicles()
	local npc = workspace:FindFirstChild("NPCVehicles")
	if not npc then return end
	local vehicles = npc:FindFirstChild("Vehicles")
	if not vehicles then return end
	vehicles.ChildAdded:Connect(function(child)
		wait(0.1)
		disableCollision(child)
	end)
end

setupExistingVehicles()
monitorNewVehicles()
spawn(function() while wait(1) do setupExistingVehicles() end end)

if not IS_SALTFLATS then
	spawn(function()
		wait(0.5)
		local SLAB, BASE_X, BASE_Z, BASE_Y = 2048, -36149, 5376, -16.5
		local roadModel = Instance.new("Model")
		roadModel.Name = "FarmRoad"
		for row = -15, 15 do
			for col = -15, 15 do
				local slab = Instance.new("Part")
				slab.Size = Vector3.new(SLAB, 0.2, SLAB)
				slab.CFrame = CFrame.new(BASE_X + col * SLAB, BASE_Y - 0.5, BASE_Z + row * SLAB)
				slab.Anchored = true; slab.CanCollide = true
				slab.Material = Enum.Material.Asphalt
				slab.Color = Color3.fromRGB(50, 50, 50)
				slab.Parent = roadModel
			end
		end
		roadModel.Parent = workspace
	end)
end

local function checkShirtOwnership()
	local ok, result = pcall(function() return MarketplaceService:PlayerOwnsAsset(player, SHIRT_ID) end)
	return ok and result or false
end

local function checkGroupRank()
	local ok, rank = pcall(function() return player:GetRankInGroup(GROUP_ID) end)
	return ok and rank >= REQUIRED_RANK
end

local function checkPremiumStatus()
	hasGamepass = checkGroupRank() or checkShirtOwnership()
	return hasGamepass
end

local function checkPay2WinBoosts()
	local count = 0
	for _, gp in ipairs(PAY2WIN_GAMEPASSES) do
		local ok, owns = pcall(function() return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gp.id) end)
		if ok and owns then count = count + 1 end
	end
	pay2winBoosts = count
	return count
end

local function getNextUnownedBoost()
	for _, gp in ipairs(PAY2WIN_GAMEPASSES) do
		local ok, owns = pcall(function() return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gp.id) end)
		if ok and not owns then return gp end
	end
	return nil
end

local function formatNumber(num)
	local f = tostring(math.floor(num))
	local k
	while true do
		f, k = string.gsub(f, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then break end
	end
	return f
end

local function formatAbbreviated(num)
	if num >= 1000000000 then return string.format("%.1fB", num / 1000000000)
	elseif num >= 1000000 then return string.format("%.1fM", num / 1000000)
	elseif num >= 1000 then return string.format("%.1fK", num / 1000)
	end
	return tostring(math.floor(num))
end

local function formatTime(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = math.floor(seconds % 60)
	return string.format("%02d:%02d:%02d", h, m, s)
end

local function formatCooldown(remaining)
	local m = math.floor(remaining / 60)
	local s = math.floor(remaining % 60)
	return string.format("%d:%02d", m, s)
end

local function getMilestoneGradient(amount)
	if amount >= 15000000 then return { Color3.fromRGB(138,43,226), Color3.fromRGB(75,0,130), Color3.fromRGB(138,43,226) }
	elseif amount >= 10000000 then return { Color3.fromRGB(70,130,255), Color3.fromRGB(30,80,200), Color3.fromRGB(70,130,255) }
	elseif amount >= 5000000  then return { Color3.fromRGB(0,191,255), Color3.fromRGB(0,100,200), Color3.fromRGB(0,191,255) }
	elseif amount >= 2500000  then return { Color3.fromRGB(65,105,225), Color3.fromRGB(25,50,150), Color3.fromRGB(65,105,225) }
	elseif amount >= 1000000  then return { Color3.fromRGB(30,144,255), Color3.fromRGB(0,90,180), Color3.fromRGB(30,144,255) }
	elseif amount >= 500000   then return { Color3.fromRGB(100,149,237), Color3.fromRGB(50,100,180), Color3.fromRGB(100,149,237) }
	elseif amount >= 100000   then return { Color3.fromRGB(0,150,255), Color3.fromRGB(0,100,200), Color3.fromRGB(0,150,255) }
	elseif amount >= 50000    then return { Color3.fromRGB(100,180,255), Color3.fromRGB(50,120,200), Color3.fromRGB(100,180,255) }
	end
	return nil
end

local accentA = IS_SALTFLATS and Color3.fromRGB(190, 135, 45) or Color3.fromRGB(55, 105, 215)
local accentB = IS_SALTFLATS and Color3.fromRGB(255, 215, 100) or Color3.fromRGB(140, 195, 255)

local allTimeLabel = nil
local allTimeDetailLabel = nil
local allTimeGradientObj = nil
local longestAFKLabel = nil

local function updateAllTimeUI()
	if allTimeLabel then allTimeLabel.Text = "All-Time Money:  $" .. formatAbbreviated(allTimeMoney) end
	if allTimeDetailLabel then allTimeDetailLabel.Text = "Exact: $" .. formatNumber(allTimeMoney) end
end

local function updateAllTimeGradient()
	if not allTimeGradientObj then return end
	local newMilestone = 0
	if allTimeMoney >= 15000000 then newMilestone = 15000000
	elseif allTimeMoney >= 10000000 then newMilestone = 10000000
	elseif allTimeMoney >= 5000000  then newMilestone = 5000000
	elseif allTimeMoney >= 2500000  then newMilestone = 2500000
	elseif allTimeMoney >= 1000000  then newMilestone = 1000000
	elseif allTimeMoney >= 500000   then newMilestone = 500000
	elseif allTimeMoney >= 100000   then newMilestone = 100000
	elseif allTimeMoney >= 50000    then newMilestone = 50000
	end
	if newMilestone ~= allTimeMilestone then
		allTimeMilestone = newMilestone
		local g = getMilestoneGradient(allTimeMoney)
		if g then
			allTimeGradientObj.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, g[1]), ColorSequenceKeypoint.new(0.5, g[2]), ColorSequenceKeypoint.new(1, g[3])
			}
		else
			allTimeGradientObj.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, accentA), ColorSequenceKeypoint.new(0.5, accentB), ColorSequenceKeypoint.new(1, accentA)
			}
		end
	end
end

local function updateLongestAFKUI()
	if longestAFKLabel then longestAFKLabel.Text = "Longest AFK:  " .. formatTime(longestAFKSeconds) end
end

local function applyCashGradient(label, gradient)
	local existing = label:FindFirstChild("MilestoneGradient")
	if existing then existing:Destroy() end
	local g = Instance.new("UIGradient")
	g.Name = "MilestoneGradient"
	g.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, gradient[1]), ColorSequenceKeypoint.new(0.5, gradient[2]), ColorSequenceKeypoint.new(1, gradient[3])
	}
	g.Rotation = 0; g.Parent = label
	spawn(function()
		while g.Parent and autoFarmActive do
			for rot = 0, 360, 2 do
				if not g.Parent or not autoFarmActive then break end
				g.Rotation = rot; wait(0.03)
			end
		end
	end)
end

local function updateCashGradient(amount)
	if not uiElements or not uiElements.cashEarnedLabel then return end
	local newMilestone = 0
	if amount >= 15000000 then newMilestone = 15000000
	elseif amount >= 10000000 then newMilestone = 10000000
	elseif amount >= 5000000  then newMilestone = 5000000
	elseif amount >= 2500000  then newMilestone = 2500000
	elseif amount >= 1000000  then newMilestone = 1000000
	elseif amount >= 500000   then newMilestone = 500000
	elseif amount >= 100000   then newMilestone = 100000
	elseif amount >= 50000    then newMilestone = 50000
	end
	if newMilestone ~= currentMilestone then
		currentMilestone = newMilestone
		local gradient = getMilestoneGradient(amount)
		if gradient then applyCashGradient(uiElements.cashEarnedLabel, gradient) end
	end
end

local function popCashLabel()
	if not uiElements or not uiElements.cashEarnedLabel then return end
	TweenService:Create(uiElements.cashEarnedLabel, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { TextSize = 26 }):Play()
	wait(0.18)
	TweenService:Create(uiElements.cashEarnedLabel, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextSize = 18 }):Play()
end

local function setupUITracking()
	local mainUI = player.PlayerGui:WaitForChild("Main_User_Interface", 5)
if not mainUI then return nil end -- Bỏ qua nếu game update đổi tên UI
	local afkRewards = mainUI:WaitForChild("AFKRewards")
	local cashEarnedLabel = afkRewards:WaitForChild("CashEarned"):WaitForChild("Label")
	local timeLabel = afkRewards:WaitForChild("Time"):WaitForChild("Label")
	local bottom = mainUI:WaitForChild("UI_Frame"):WaitForChild("Bottom")
	local moneyButton = bottom:WaitForChild("Money")
	local teleportButton = bottom:WaitForChild("Teleport")
	local rewardsButton = bottom:WaitForChild("Rewards")
	local vipTrialButton = bottom:WaitForChild("VIPTrial")
	local vipIcon = vipTrialButton:WaitForChild("Icon")
	local vipLabel = vipTrialButton:WaitForChild("Label")
	afkRewards.Visible = false
	vipIcon.Image = "rbxassetid://91493125301731"
	vipLabel.Text = "Click to copy"; vipLabel.Visible = false
	vipTrialButton.MouseEnter:Connect(function() vipLabel.Visible = true end)
	vipTrialButton.MouseLeave:Connect(function() vipLabel.Visible = false end)
	vipTrialButton.MouseButton1Click:Connect(function()
		if setclipboard then setclipboard(DISCORD_LINK) end
		local orig = vipIcon.ImageColor3
		TweenService:Create(vipIcon, TweenInfo.new(0.3), { ImageColor3 = Color3.fromRGB(100,255,150) }):Play()
		wait(0.5)
		TweenService:Create(vipIcon, TweenInfo.new(0.3), { ImageColor3 = orig }):Play()
	end)
	local perSecondLabel = Instance.new("TextLabel")
	perSecondLabel.Name = "PerSecondEarnings"
	perSecondLabel.Size = UDim2.new(0, 180, 0, 40)
	perSecondLabel.Position = UDim2.new(0.5, -90, 0, -45)
	perSecondLabel.BackgroundTransparency = 1
	perSecondLabel.Text = "+$0/s"
	perSecondLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
	perSecondLabel.TextSize = 22
	perSecondLabel.Font = Enum.Font.GothamBold
	perSecondLabel.TextStrokeTransparency = 0.5
	perSecondLabel.Visible = false
	perSecondLabel.Parent = moneyButton
	return {
		cashEarnedLabel = cashEarnedLabel, timeLabel = timeLabel,
		afkRewards = afkRewards, perSecondLabel = perSecondLabel,
		teleportButton = teleportButton, rewardsButton = rewardsButton, vipTrialButton = vipTrialButton,
	}
end

spawn(function() wait(1); uiElements = setupUITracking() end)

local function updatePerSecondEarnings(diff)
	if not uiElements or diff <= 0 then return end
	local fl = uiElements.perSecondLabel:Clone()
	fl.Text = "+$" .. formatNumber(diff) .. "/s"
	fl.Position = UDim2.new(0.5, -90, 0, -10)
	fl.Visible = true; fl.Parent = uiElements.perSecondLabel.Parent
	local mt = TweenService:Create(fl, TweenInfo.new(1.5), { Position = UDim2.new(0.5, -90, 0, -60), TextTransparency = 1 })
	mt:Play(); mt.Completed:Connect(function() fl:Destroy() end)
end

local function formatQuestRichLabel(q)
	local c = IS_SALTFLATS and "#FFD050" or "#64B4FF"
	if q.type == "earn" then
		return 'Earn <font color="' .. c .. '"><b>$' .. formatNumber(q.target) .. '</b></font>'
	elseif q.type == "time" then
		local h = math.floor(q.target / 3600)
		local m = math.floor((q.target % 3600) / 60)
		local timeStr
		if h > 0 and m > 0 then timeStr = h .. (h == 1 and " Hour " or " Hours ") .. m .. " Min"
		elseif h > 0 then timeStr = h .. (h == 1 and " Hour" or " Hours")
		else timeStr = m .. " Minutes"
		end
		return 'Farm for <font color="' .. c .. '"><b>' .. timeStr .. '</b></font>'
	elseif q.type == "loops" then
		return 'Complete <font color="' .. c .. '"><b>' .. q.target .. '</b></font> Farm Loops'
	end
	return q.label
end

local function updateQuestUI()
	if not questTaskLabel then return end
	if allQuestsDone then
		questTaskLabel.Text = "More Coming Soon..."
		questProgressLabel.Text = "All " .. #QUESTS .. " quests completed!"
		if questEtaLabel then questEtaLabel.Visible = false end
		questClaimButton.Visible = false; questCooldownLabel.Visible = false
		if questNotifBadge then questNotifBadge.Visible = false end
		if questTotalLabel then questTotalLabel.Text = "Total Quests Completed:  " .. questTotalCompleted end
		if questSpeedLabel then questSpeedLabel.Text = "Speed Bonus:  +" .. (questSpeedBonus + pay2winBoosts) end
		return
	end
	local q = QUESTS[questIndex]
	if not q then return end
	questTaskLabel.Text = "Task " .. questIndex .. "/" .. #QUESTS .. ":  " .. formatQuestRichLabel(q)
	local pct = math.min(math.floor((questProgress / q.target) * 100), 100)
	if q.type == "earn" then
		questProgressLabel.Text = "$" .. formatNumber(questProgress) .. " / $" .. formatNumber(q.target) .. "  (" .. pct .. "%)"
	elseif q.type == "time" then
		questProgressLabel.Text = formatTime(questProgress) .. " / " .. formatTime(q.target) .. "  (" .. pct .. "%)"
	elseif q.type == "loops" then
		questProgressLabel.Text = questProgress .. " / " .. q.target .. " loops  (" .. pct .. "%)"
	end
	if questCompleted then
		if questEtaLabel then questEtaLabel.Visible = false end
		if questCooldownEnd == 0 then
			questClaimButton.Visible = true; questCooldownLabel.Visible = false
			if questNotifBadge then questNotifBadge.Visible = true end
		else
			questClaimButton.Visible = false; questCooldownLabel.Visible = true
			if questNotifBadge then questNotifBadge.Visible = false end
		end
	elseif questCooldownEnd > 0 then
		if questEtaLabel then questEtaLabel.Visible = false end
		questClaimButton.Visible = false; questCooldownLabel.Visible = true
		if questNotifBadge then questNotifBadge.Visible = false end
	else
		if questEtaLabel then questEtaLabel.Visible = true end
		questClaimButton.Visible = false; questCooldownLabel.Visible = false
		if questNotifBadge then questNotifBadge.Visible = false end
	end
	if questTotalLabel then questTotalLabel.Text = "Total Quests Completed:  " .. questTotalCompleted end
	if questSpeedLabel then questSpeedLabel.Text = "Speed Bonus:  +" .. (questSpeedBonus + pay2winBoosts) end
end

local function updateQuestEta()
	if not autoFarmActive or not questEtaLabel or not questEtaLabel.Visible then return end
	if questCompleted or questCooldownEnd > 0 or allQuestsDone then return end
	local q = QUESTS[questIndex]
	if not q then return end
	if q.type == "time" then
		questEtaLabel.Text = "Est. Time:  " .. formatTime(math.max(0, q.target - questProgress))
	elseif q.type == "earn" then
		if questFarmSeconds < 5 or questProgress <= 0 then questEtaLabel.Text = "Est. Time:  calculating..."; return end
		local rate = questProgress / questFarmSeconds
		if rate <= 0 then questEtaLabel.Text = "Est. Time:  calculating..."; return end
		questEtaLabel.Text = "Est. Time:  " .. formatTime(math.max(0, (q.target - questProgress) / rate))
	elseif q.type == "loops" then
		if questFarmSeconds < 5 or questLoopCount <= 0 then questEtaLabel.Text = "Est. Time:  calculating..."; return end
		local rate = questLoopCount / questFarmSeconds
		if rate <= 0 then questEtaLabel.Text = "Est. Time:  calculating..."; return end
		questEtaLabel.Text = "Est. Time:  " .. formatTime(math.max(0, (q.target - questLoopCount) / rate))
	end
end

local function startQuestShine()
	if questShineLoop then return end
	if not questClaimButton then return end
	questShineLoop = spawn(function()
		while questCompleted and questCooldownEnd == 0 do
			local shine = Instance.new("Frame")
			shine.Size = UDim2.new(0.18, 0, 1.2, 0); shine.Position = UDim2.new(-0.18, 0, -0.1, 0)
			shine.BackgroundColor3 = Color3.fromRGB(255,255,255); shine.BackgroundTransparency = 0.55
			shine.BorderSizePixel = 0; shine.Rotation = 18; shine.ZIndex = 10; shine.Parent = questClaimButton
			local sg = Instance.new("UIGradient")
			sg.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.4,0.2),
				NumberSequenceKeypoint.new(0.6,0.2), NumberSequenceKeypoint.new(1,1)
			})
			sg.Rotation = 90; sg.Parent = shine
			local st = TweenService:Create(shine, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.new(1.18,0,-0.1,0) })
			st:Play(); st.Completed:Wait(); shine:Destroy(); wait(1.4)
		end
		questShineLoop = nil
	end)
end

local function markQuestComplete()
	local timeTaken = math.floor(tick() - questStartTime)
	local completedLabel = QUESTS[questIndex] and QUESTS[questIndex].label or "Unknown"
	questCompleted = true
	updateQuestUI(); startQuestShine(); saveData()
	spawn(function() sendQuestWebhook(questIndex, completedLabel, timeTaken, questSpeedBonus) end)
end

local function pickNewQuest()
	if questIndex >= #QUESTS then
		allQuestsDone = true; questCompleted = false; questCooldownEnd = 0
		updateQuestUI(); saveData(); return
	end
	questIndex = questIndex + 1
	questProgress = 0; questCompleted = false; questCooldownEnd = 0
	questLoopCount = 0; questShineLoop = nil; questStartTime = tick(); questFarmSeconds = 0
	updateQuestUI()
end

-- ============================================================
-- KYZEN COMPACT LIQUID GLASS UI
-- UI-only replacement: original farm/quest/session logic is kept.
-- ============================================================
local oldGui = player.PlayerGui:FindFirstChild("AutoFarmGUI")
if oldGui then oldGui:Destroy() end
local oldCompact = player.PlayerGui:FindFirstChild("KyzenLiquidGlass")
if oldCompact then oldCompact:Destroy() end

local guiScreen = Instance.new("ScreenGui")
guiScreen.Name = "KyzenLiquidGlass"
guiScreen.DisplayOrder = 50000
guiScreen.ResetOnSpawn = false
guiScreen.IgnoreGuiInset = true
guiScreen.Parent = player.PlayerGui

local guiFrame = Instance.new("Frame")
guiFrame.Name = "Main"
guiFrame.Size = UDim2.new(0, 360, 0, 330)
guiFrame.Position = UDim2.new(0.5, -180, 0.5, -165)
guiFrame.BackgroundColor3 = Color3.fromRGB(18,18,22)
guiFrame.BackgroundTransparency = 0.08
guiFrame.BorderSizePixel = 0
guiFrame.ClipsDescendants = true
guiFrame.Parent = guiScreen
Instance.new("UICorner", guiFrame).CornerRadius = UDim.new(0,18)
local frameStroke = Instance.new("UIStroke", guiFrame)
frameStroke.Color = Color3.fromRGB(70,70,82)
frameStroke.Thickness = 1.4
frameStroke.Transparency = 0.15

local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,58); top.BackgroundTransparency = 1; top.Parent = guiFrame
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-80,0,27); title.Position = UDim2.new(0,16,0,8)
title.BackgroundTransparency = 1; title.Text = "KYZEN HUB"
title.TextColor3 = Color3.fromRGB(245,245,250); title.TextSize = 19; title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = top
local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1,-80,0,18); sub.Position = UDim2.new(0,17,0,32)
sub.BackgroundTransparency = 1; sub.Text = IS_SALTFLATS and "Boneville Salt Flats" or "Shutoko"
sub.TextColor3 = IS_SALTFLATS and Color3.fromRGB(240,190,80) or Color3.fromRGB(105,165,255)
sub.TextSize = 11; sub.Font = Enum.Font.GothamMedium; sub.TextXAlignment = Enum.TextXAlignment.Left; sub.Parent = top

premiumButton = Instance.new("TextButton")
premiumButton.Size = UDim2.new(0,62,0,27); premiumButton.Position = UDim2.new(1,-76,0,14)
premiumButton.BackgroundColor3 = Color3.fromRGB(255,215,0); premiumButton.Text = "2x"
premiumButton.TextColor3 = Color3.fromRGB(0,0,0); premiumButton.TextSize = 12; premiumButton.Font = Enum.Font.GothamBold
premiumButton.BorderSizePixel = 0; premiumButton.Parent = top
Instance.new("UICorner", premiumButton).CornerRadius = UDim.new(0,9)
premiumStroke = Instance.new("UIStroke", premiumButton); premiumStroke.Color = Color3.fromRGB(205,170,0); premiumStroke.Thickness = 1.5
premiumGradient = Instance.new("UIGradient", premiumButton)
premiumGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,230,60)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,195,0))}
premiumGradient.Rotation = 90

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,-20,0,36); tabBar.Position = UDim2.new(0,10,0,58)
tabBar.BackgroundColor3 = Color3.fromRGB(25,25,30); tabBar.BackgroundTransparency = 0.1; tabBar.BorderSizePixel = 0; tabBar.Parent = guiFrame
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0,11)
local tabLayout = Instance.new("UIListLayout", tabBar); tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.Padding = UDim.new(0,4); tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
Instance.new("UIPadding", tabBar).PaddingLeft = UDim.new(0,4)

local content = Instance.new("Frame")
content.Size = UDim2.new(1,-20,1,-108); content.Position = UDim2.new(0,10,0,102)
content.BackgroundTransparency = 1; content.ClipsDescendants = true; content.Parent = guiFrame

local pages = {}; local tabs = {}
local function makePage(name)
    local p=Instance.new("ScrollingFrame"); p.Name=name; p.Size=UDim2.new(1,0,1,0); p.BackgroundTransparency=1; p.BorderSizePixel=0; p.ScrollBarThickness=2; p.ScrollBarImageTransparency=0.35; p.Visible=false; p.CanvasSize=UDim2.new(0,0,0,0); p.Parent=content
    local l=Instance.new("UIListLayout",p); l.Padding=UDim.new(0,7); l.SortOrder=Enum.SortOrder.LayoutOrder
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() p.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+8) end)
    pages[name]=p; return p
end
local function makeTab(name, page)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(0,80,0,28); b.BackgroundColor3=Color3.fromRGB(35,35,42); b.BackgroundTransparency=0.25; b.BorderSizePixel=0; b.Text=name; b.TextColor3=Color3.fromRGB(165,165,175); b.TextSize=11; b.Font=Enum.Font.GothamMedium; b.Parent=tabBar
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8); tabs[name]=b
    b.MouseButton1Click:Connect(function()
        for n,p in pairs(pages) do p.Visible=(p==page); tabs[n].BackgroundColor3=(p==page) and Color3.fromRGB(65,105,180) or Color3.fromRGB(35,35,42); tabs[n].TextColor3=(p==page) and Color3.fromRGB(255,255,255) or Color3.fromRGB(165,165,175) end
    end)
end
local farmPage=makePage("Farm"); local statsPage=makePage("Stats"); local questPage=makePage("Quests"); local miscPage=makePage("Misc")
makeTab("Farm",farmPage); makeTab("Stats",statsPage); makeTab("Quests",questPage); makeTab("Misc",miscPage)
farmPage.Visible=true; tabs.Farm.BackgroundColor3=Color3.fromRGB(65,105,180); tabs.Farm.TextColor3=Color3.fromRGB(255,255,255)

local function card(parent,h)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-4,0,h); f.BackgroundColor3=Color3.fromRGB(27,27,33); f.BackgroundTransparency=0.08; f.BorderSizePixel=0; f.Parent=parent
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,12); local s=Instance.new("UIStroke",f); s.Color=Color3.fromRGB(52,52,62); s.Thickness=1; s.Transparency=0.25
    return f
end
local function label(parent,text,y,size,color)
    local x=Instance.new("TextLabel"); x.Size=UDim2.new(1,-20,0,size+4); x.Position=UDim2.new(0,10,0,y); x.BackgroundTransparency=1; x.Text=text; x.TextColor3=color or Color3.fromRGB(225,225,232); x.TextSize=size; x.Font=Enum.Font.GothamMedium; x.TextXAlignment=Enum.TextXAlignment.Left; x.Parent=parent; return x
end
local function button(parent,text,y,h)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-20,0,h); b.Position=UDim2.new(0,10,0,y); b.BackgroundColor3=Color3.fromRGB(45,47,56); b.BorderSizePixel=0; b.Text=text; b.TextColor3=Color3.fromRGB(240,240,245); b.TextSize=13; b.Font=Enum.Font.GothamBold; b.AutoButtonColor=false; b.ClipsDescendants=true; b.Parent=parent; Instance.new("UICorner",b).CornerRadius=UDim.new(0,10); return b
end

local farmCard=card(farmPage,132)
statusText=label(farmCard,"Status:  Ready",10,12,Color3.fromRGB(170,170,180))
autoFarmToggle=button(farmCard,"Start AutoFarm",38,48)
toggleGradient=Instance.new("UIGradient",autoFarmToggle); toggleGradient.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(45,55,72)),ColorSequenceKeypoint.new(1,Color3.fromRGB(30,34,44))}; toggleGradient.Rotation=90
toggleStroke=Instance.new("UIStroke",autoFarmToggle); toggleStroke.Color=Color3.fromRGB(70,140,220); toggleStroke.Thickness=1.5
toggleGlow=Instance.new("ImageLabel",autoFarmToggle); toggleGlow.Size=UDim2.new(1,20,1,20); toggleGlow.Position=UDim2.new(0,-10,0,-10); toggleGlow.BackgroundTransparency=1; toggleGlow.Image="rbxassetid://5028857084"; toggleGlow.ImageColor3=Color3.fromRGB(70,140,220); toggleGlow.ImageTransparency=0.92; toggleGlow.ZIndex=0

local sessionCard=card(farmPage,92)
local sessionTitle=label(sessionCard,"Session",8,12,Color3.fromRGB(160,160,175))
local cashLabel=label(sessionCard,"Cash Earned: $0",31,14,Color3.fromRGB(255,255,255)); local timeLabel2=label(sessionCard,"Time: 0s",56,12,Color3.fromRGB(170,170,180))
uiElements = uiElements or {}
-- These fields are kept so the original stop/start logic can safely update them.
uiElements.afkRewards = Instance.new("Frame"); uiElements.afkRewards.Visible=false
uiElements.teleportButton = Instance.new("Frame"); uiElements.rewardsButton = Instance.new("Frame"); uiElements.vipTrialButton = Instance.new("Frame")
uiElements.cashEarnedLabel=cashLabel; uiElements.timeLabel=timeLabel2; uiElements.perSecondLabel=label(sessionCard,"",0,1,Color3.new(1,1,1)); uiElements.perSecondLabel.Visible=false

allTimeLabel=label(statsPage,"All-Time Money:  $0",6,15,Color3.fromRGB(255,255,255))
allTimeGradientObj=Instance.new("UIGradient",allTimeLabel); allTimeGradientObj.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,accentA),ColorSequenceKeypoint.new(.5,accentB),ColorSequenceKeypoint.new(1,accentA)}
allTimeDetailLabel=label(statsPage,"Exact: $0",31,12,Color3.fromRGB(170,170,180))
longestAFKLabel=label(statsPage,"Longest AFK:  0s",54,13,Color3.fromRGB(225,225,232))
local statCard=card(statsPage,92); label(statCard,"Current session",8,12,Color3.fromRGB(160,160,175)); label(statCard,"Stats are updated by the original tracker.",32,12,Color3.fromRGB(175,175,185)); label(statCard,"Farm logic remains unchanged.",54,12,Color3.fromRGB(110,210,150))

questFrame=questPage
questTaskLabel=label(questFrame,"Task:  Loading...",4,14,Color3.fromRGB(245,245,250)); questTaskLabel.RichText=true
questProgressLabel=label(questFrame,"",28,12,Color3.fromRGB(170,170,180))
questEtaLabel=label(questFrame,"Est. Time:  calculating...",50,11,Color3.fromRGB(130,130,145))
questClaimButton=button(questFrame,"Claim  +1 Speed",72,42); questClaimButton.Visible=false
questCooldownLabel=label(questFrame,"",120,11,Color3.fromRGB(145,145,160)); questCooldownLabel.Visible=false
questClaimButton.MouseButton1Click:Connect(function()
    if not questCompleted then return end
    playSound(SND_CLICK)
    questSpeedBonus = questSpeedBonus + 1
    questTotalCompleted = questTotalCompleted + 1
    questCompleted = false
    questCooldownEnd = tick() + 1800
    questShineLoop = nil
    questClaimButton.Visible = false
    questCooldownLabel.Visible = true
    if questEtaLabel then questEtaLabel.Visible = false end
    if questNotifBadge then questNotifBadge.Visible = false end
    updateQuestUI()
    saveData()
end)
questNotifBadge=Instance.new("Frame"); questNotifBadge.Visible=false
questTotalLabel=label(questFrame,"Total completed: 0",143,12,Color3.fromRGB(190,190,200))
questSpeedLabel=label(questFrame,"Speed Bonus:  +0",165,12,Color3.fromRGB(100,220,150))
boostSpeedButton=button(questFrame,"Boost Speed",188,40)
pay2winBoostLabel=label(questFrame,"PAY2WIN Boosts: 0",234,12,Color3.fromRGB(255,170,70))
pay2winPriceLabel=label(questFrame,"Price: --",256,11,Color3.fromRGB(160,160,175))

local hideCard=card(miscPage,130)
hideNameBtn=button(hideCard,"Hide Display Name",10,40)
hideNameStroke=Instance.new("UIStroke",hideNameBtn); hideNameStroke.Color=Color3.fromRGB(44,44,55); hideNameStroke.Thickness=1.5
local discordBtn=button(hideCard,"Copy Discord Link",58,40)
local miscInfo=label(miscPage,"Compact Liquid Glass UI • original logic retained",6,12,Color3.fromRGB(145,145,160))

usernameText=Instance.new("TextLabel"); premiumDiamond=Instance.new("ImageLabel"); iconStroke=Instance.new("UIStroke")
local function updatePremiumUI()
    if hasGamepass then
        premiumButton.Text="2x Active"; premiumButton.BackgroundColor3=Color3.fromRGB(100,255,150); premiumButton.TextColor3=Color3.fromRGB(0,0,0); premiumStroke.Color=Color3.fromRGB(50,200,100)
    else
        premiumButton.Text="2x"; premiumButton.BackgroundColor3=Color3.fromRGB(255,215,0); premiumButton.TextColor3=Color3.fromRGB(0,0,0); premiumStroke.Color=Color3.fromRGB(205,170,0)
    end
end
local function updatePay2WinUI()
    if pay2winBoostLabel then pay2winBoostLabel.Text="PAY2WIN Boosts: "..pay2winBoosts end
    local nextGp=getNextUnownedBoost()
    if pay2winPriceLabel then pay2winPriceLabel.Text=nextGp and ("Price: "..nextGp.price.." Robux") or "All Boosts Owned!" end
    if boostSpeedButton then boostSpeedButton.Text=nextGp and "Boost Speed" or "All Owned" end
    if questSpeedLabel then questSpeedLabel.Text="Speed Bonus:  +"..(questSpeedBonus+pay2winBoosts) end
end

hideNameBtn.MouseButton1Click:Connect(function()
    playSound(SND_CLICK); hideDisplayName=not hideDisplayName
    if hideDisplayName then hideNameBtn.Text="Show Display Name"; hideNameBtn.TextColor3=Color3.fromRGB(255,105,105); hideNameStroke.Color=Color3.fromRGB(160,50,50); hideNameBtn.BackgroundColor3=Color3.fromRGB(50,18,18)
    else hideNameBtn.Text="Hide Display Name"; hideNameBtn.TextColor3=Color3.fromRGB(240,240,245); hideNameStroke.Color=Color3.fromRGB(44,44,55); hideNameBtn.BackgroundColor3=Color3.fromRGB(45,47,56) end
end)
discordBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard(DISCORD_LINK) end; playSound(SND_CLICK) end)

premiumButton.MouseButton1Click:Connect(function()
    if hasGamepass then return end
    if setclipboard then setclipboard(SHIRT_LINK) end
    playSound(SND_CLICK)
end)
boostSpeedButton.MouseButton1Click:Connect(function()
    local nextGp=getNextUnownedBoost(); if not nextGp then return end
    if setclipboard then setclipboard("https://www.roblox.com/game-pass/"..nextGp.id) end
    playSound(SND_CLICK)
end)

-- The original AutoFarm event handler, vehicle worker, session tracking, quest worker, and drag handling are retained below unchanged.

updateAllTimeUI(); updateLongestAFKUI(); updatePremiumUI(); updatePay2WinUI(); updateQuestUI()
if questCompleted and questCooldownEnd==0 then startQuestShine() end

	-- force permanent 2x
	premiumActive = true
	hasGamepass = true
	boostCount = 1
	CASH_MULTIPLIER = 2

	if premiumButton then
		premiumButton.Text = "2x Active"
		premiumButton.BackgroundColor3 = Color3.fromRGB(100,255,150)
		premiumButton.TextColor3 = Color3.fromRGB(0,0,0)
	end

	if premiumStroke then
		premiumStroke.Color = Color3.fromRGB(50,200,100)
	end

	if premiumGradient then
		premiumGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(120,255,170)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(80,220,130))
		}
	end

	local tipGui = Instance.new("ScreenGui")
	tipGui.Name = "TrafficTip"
	tipGui.DisplayOrder = 100000
	tipGui.IgnoreGuiInset = true
	tipGui.Parent = player.PlayerGui

	local tipBadge = Instance.new("Frame")
	tipBadge.Size = UDim2.new(0,0,0,44)
	tipBadge.Position = UDim2.new(0.5,0,0,18)
	tipBadge.AnchorPoint = Vector2.new(0.5,0)
	tipBadge.BackgroundColor3 = Color3.fromRGB(20,20,24)
	tipBadge.BorderSizePixel = 0
	tipBadge.ClipsDescendants = true
	tipBadge.Parent = tipGui

	Instance.new("UICorner", tipBadge).CornerRadius = UDim.new(0,10)

	local bs2 = Instance.new("UIStroke", tipBadge)
	bs2.Color = Color3.fromRGB(70,140,220)
	bs2.Thickness = 1.5
	bs2.Transparency = 0.25

	local bt = Instance.new("TextLabel")
	bt.Size = UDim2.new(1,-24,1,0)
	bt.Position = UDim2.new(0,12,0,0)
	bt.BackgroundTransparency = 1
	bt.Text = "2x Cash Permanently Enabled"
	bt.TextColor3 = Color3.fromRGB(200,200,200)
	bt.TextSize = 14
	bt.Font = Enum.Font.GothamMedium
	bt.TextXAlignment = Enum.TextXAlignment.Center
	bt.TextTransparency = 1
	bt.Parent = tipBadge

	TweenService:Create(tipBadge, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0,360,0,44) }):Play()
	wait(0.3)
TweenService:Create(bt, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()



spawn(function()
	local lastKnownCash = 0
	local lastTimerSec = -1
	while wait(0.1) do
		local now = tick()
		if autoFarmActive and uiElements then
			local elapsed = now - farmStartTime
			local elapsedSec = math.floor(elapsed)
			if elapsedSec ~= lastTimerSec then
				lastTimerSec = elapsedSec
				uiElements.timeLabel.Text = formatTime(elapsedSec)
				uiElements.timeLabel.TextColor3 = Color3.fromRGB(255,255,255)
				if elapsedSec > longestAFKSeconds then longestAFKSeconds = elapsedSec; updateLongestAFKUI() end
				if not allQuestsDone and questCooldownEnd == 0 and not questCompleted then
					local q = QUESTS[questIndex]
					if q and q.type == "time" then
						questProgress = questProgress + 1; updateQuestUI()
						if questProgress >= q.target then markQuestComplete() end
					end
				end
				questFarmSeconds = questFarmSeconds + 1; updateQuestEta()
				local ok, cashVal = pcall(function() return player.leaderstats.Cash.Value end)
				if ok then
					local gained = math.max(0, cashVal - lastKnownCash)
					if gained > 0 and lastKnownCash > 0 then
						allTimeMoney = allTimeMoney + gained
						updateAllTimeUI(); updateAllTimeGradient()
						local sessionEarned = math.max(0, cashVal - farmStartCash)
						uiElements.cashEarnedLabel.Text = "$" .. formatNumber(sessionEarned)
						updateCashGradient(sessionEarned); spawn(popCashLabel); updatePerSecondEarnings(gained)
						if not allQuestsDone and questCooldownEnd == 0 and not questCompleted then
							local q = QUESTS[questIndex]
							if q and q.type == "earn" then
								questProgress = questProgress + gained; updateQuestUI()
								if questProgress >= q.target then markQuestComplete() end
							end
						end
					end
					lastKnownCash = cashVal
				end
				if elapsedSec % 30 == 0 then saveData() end
			end
		elseif not autoFarmActive then
			lastTimerSec = -1
		end
		if questCooldownEnd > 0 then
			if now >= questCooldownEnd then
				questCooldownEnd = 0
				if questIndex >= #QUESTS then
					allQuestsDone = true; questCompleted = false; updateQuestUI(); saveData()
				else
					pickNewQuest(); saveData()
				end
			else
				if questCooldownLabel then
					questCooldownLabel.Text = "Another task will appear in:  " .. formatCooldown(questCooldownEnd - now)
				end
			end
		end
	end
end)

local function isPlayerSeated()
	local char = player.Character
	if char then local hum = char:FindFirstChild("Humanoid"); if hum and hum.SeatPart then return true end end
	return false
end

local function stabilizeCar(car)
	if carStabilizationConnection then carStabilizationConnection:Disconnect() end
	carStabilizationConnection = RunService.Heartbeat:Connect(function()
		if not autoFarmActive or not car.Parent or not car.PrimaryPart then
			if carStabilizationConnection then carStabilizationConnection:Disconnect(); carStabilizationConnection = nil end; return
		end
		local cf = car.PrimaryPart.CFrame; local pos, look = cf.Position, cf.LookVector
		car.PrimaryPart.CFrame = car.PrimaryPart.CFrame:Lerp(CFrame.new(pos, pos + Vector3.new(look.X, 0, look.Z)), 0.15)
		car.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, car.PrimaryPart.AssemblyAngularVelocity.Y * 0.5, 0)
	end)
end

local function smoothNavigateToCar(car, targetPos, maxSpeed)
	local curSpeed = maxSpeed * 0.4
	while autoFarmActive and isPlayerSeated() do
		if not car.Parent or not car.PrimaryPart then break end
		local currentPos = car.PrimaryPart.Position
		local distance = (targetPos - currentPos).Magnitude
		if distance < 50 then break end
		curSpeed = math.min(curSpeed + (maxSpeed * 0.02), maxSpeed)
		local direction = (targetPos - currentPos).Unit
		car.PrimaryPart.AssemblyLinearVelocity = car.PrimaryPart.AssemblyLinearVelocity:Lerp(direction * curSpeed, 0.1)
		local smoothedLook = car.PrimaryPart.CFrame.LookVector:Lerp(Vector3.new(direction.X, 0, direction.Z).Unit, 0.12)
		car.PrimaryPart.CFrame = car.PrimaryPart.CFrame:Lerp(CFrame.new(currentPos, currentPos + smoothedLook), 0.25)
		local floorY = IS_SALTFLATS and -13 or -30
		local resetY = IS_SALTFLATS and -7 or -17
		if currentPos.Y < floorY then car.PrimaryPart.CFrame = CFrame.new(currentPos.X, resetY, currentPos.Z) end
		task.wait()
	end
end

local function endFarmSession()
	local elapsed = tick() - farmStartTime
	if elapsed > longestAFKSeconds then longestAFKSeconds = elapsed; updateLongestAFKUI() end
	saveData()
end

spawn(function()
	while wait(0.5) do
		if autoFarmActive and not isPlayerSeated() then
			autoFarmActive = false; autoFarmToggle.Text = "Start AutoFarm"
			toggleStroke.Color = Color3.fromRGB(70,140,220); toggleGlow.ImageColor3 = Color3.fromRGB(70,140,220)
			statusText.Text = "Status:  Left seat"; statusText.TextColor3 = Color3.fromRGB(175,175,175)
			endFarmSession()
			if uiElements then
				uiElements.afkRewards.Visible = false; uiElements.teleportButton.Visible = true
				uiElements.rewardsButton.Visible = true; uiElements.vipTrialButton.Visible = false
				local eg = uiElements.cashEarnedLabel:FindFirstChild("MilestoneGradient"); if eg then eg:Destroy() end
				currentMilestone = 0
			end
			if carStabilizationConnection then carStabilizationConnection:Disconnect(); carStabilizationConnection = nil end
			toggleGradient.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(52,52,57)), ColorSequenceKeypoint.new(1, Color3.fromRGB(32,32,36)) }
		end
	end
end)

autoFarmToggle.MouseButton1Click:Connect(function()
	playSound(SND_CLICK)
	local ripple = Instance.new("Frame")
	ripple.Size = UDim2.new(0,0,0,0); ripple.Position = UDim2.new(0.5,0,0.5,0)
	ripple.AnchorPoint = Vector2.new(0.5,0.5); ripple.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ripple.BackgroundTransparency = 0.5; ripple.BorderSizePixel = 0; ripple.ZIndex = 10; ripple.Parent = autoFarmToggle
	Instance.new("UICorner", ripple).CornerRadius = UDim.new(1,0)
	local rt = TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(2,0,2,0), BackgroundTransparency = 1 })
	rt:Play(); rt.Completed:Connect(function() ripple:Destroy() end)
	TweenService:Create(autoFarmToggle, TweenInfo.new(0.1), { Size = UDim2.new(1,-24,0,54) }):Play()
	wait(0.1); TweenService:Create(autoFarmToggle, TweenInfo.new(0.2, Enum.EasingStyle.Elastic), { Size = UDim2.new(1,-20,0,58) }):Play()
	if not autoFarmActive and not isPlayerSeated() then
		statusText.Text = "Status:  Sit in a vehicle first"; statusText.TextColor3 = Color3.fromRGB(255,130,130); return
	end
	autoFarmActive = not autoFarmActive
	if autoFarmActive then
		autoFarmToggle.Text = "Stop AutoFarm"; toggleStroke.Color = Color3.fromRGB(100,255,150); toggleGlow.ImageColor3 = Color3.fromRGB(100,255,150)
		statusText.Text = "Status:  Running"; statusText.TextColor3 = Color3.fromRGB(100,255,150)
		farmStartCash = player.leaderstats.Cash.Value; farmStartTime = tick(); lastCashAmount = farmStartCash; totalCashEarned = 0
		if uiElements then
			uiElements.afkRewards.Visible = true; uiElements.cashEarnedLabel.Text = "$0"
			uiElements.timeLabel.Text = "00:00:00"; uiElements.timeLabel.TextColor3 = Color3.fromRGB(255,255,255)
			uiElements.teleportButton.Visible = false; uiElements.rewardsButton.Visible = false; uiElements.vipTrialButton.Visible = true
		end
		toggleGradient.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(26,74,36)), ColorSequenceKeypoint.new(1, Color3.fromRGB(17,54,26)) }
		spawn(function()
			while autoFarmActive do
				for _, v in pairs(workspace:GetChildren()) do
					if v.ClassName == "Model" and (v:FindFirstChild("Container") or v.Name == "PortCraneOversized") then v:Destroy() end
				end; wait(1)
			end
		end)
		spawn(function()
			while autoFarmActive do
								if not isPlayerSeated() then break end
				local hum = player.Character.Humanoid
				local car = hum.SeatPart:FindFirstAncestorWhichIsA("Model")
				if not car then break end
				
				local primary = (car:FindFirstChild("Body") and car.Body:FindFirstChild("#Weight")) or car.PrimaryPart
				if not primary then break end
				car.PrimaryPart = primary
				
				if workspace:FindFirstChild("Workspace") and workspace.Workspace:FindFirstChild("Buildings") then workspace.Workspace.Buildings:Destroy() end
				for _, part in pairs(car:GetDescendants()) do
					if part:IsA("BasePart") then part.CustomPhysicalProperties = PhysicalProperties.new(0.7,0.3,0.5,100,1) end
				end
				car.PrimaryPart.Anchored = true; car:PivotTo(CFrame.new(WAYPOINTS[1])); wait(0.15)
				car.PrimaryPart.Anchored = false
				car.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0,0,0); car.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
				stabilizeCar(car); wait(0.3)
				for waypointIndex = 2, #WAYPOINTS do
					if not autoFarmActive or not isPlayerSeated() then break end
					local baseSpeed = hasGamepass and 540 or 460
					local carSpeed = baseSpeed + ((questSpeedBonus + pay2winBoosts) * 3)
					smoothNavigateToCar(car, WAYPOINTS[waypointIndex], carSpeed)
				end
				if autoFarmActive and isPlayerSeated() then
					if not allQuestsDone and questCooldownEnd == 0 and not questCompleted then
						local q = QUESTS[questIndex]
						if q and q.type == "loops" then
							questLoopCount = questLoopCount + 1; questProgress = questLoopCount; updateQuestUI()
							if questProgress >= q.target then markQuestComplete() end
						end
					end
				end
				if not autoFarmActive then break end
			end
			if carStabilizationConnection then carStabilizationConnection:Disconnect(); carStabilizationConnection = nil end
		end)
	else
		autoFarmToggle.Text = "Start AutoFarm"; toggleStroke.Color = Color3.fromRGB(70,140,220); toggleGlow.ImageColor3 = Color3.fromRGB(70,140,220)
		statusText.Text = "Status:  Stopped"; statusText.TextColor3 = Color3.fromRGB(175,175,175)
		endFarmSession()
		if uiElements then
			uiElements.afkRewards.Visible = false; uiElements.teleportButton.Visible = true
			uiElements.rewardsButton.Visible = true; uiElements.vipTrialButton.Visible = false
			local eg = uiElements.cashEarnedLabel:FindFirstChild("MilestoneGradient"); if eg then eg:Destroy() end; currentMilestone = 0
		end
		toggleGradient.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(52,52,57)), ColorSequenceKeypoint.new(1, Color3.fromRGB(32,32,36)) }
		if carStabilizationConnection then carStabilizationConnection:Disconnect(); carStabilizationConnection = nil end
	end
end)

local dragging, dragInput, dragStart, startPos
local dragConnection -- Thêm biến này để dọn dẹp RAM

guiFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = guiFrame.Position
		
		-- Cắt cái cũ trước khi tạo cái mới để chống tràn RAM
		if dragConnection then dragConnection:Disconnect() end
		dragConnection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then 
				dragging = false 
				if dragConnection then dragConnection:Disconnect(); dragConnection = nil end
			end 
		end)
	end
end)

guiFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		guiFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
------Phần UI
--// FLOATING LOGO OPEN / CLOSE UI
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "KyzenToggleLogo"
ToggleGui.ResetOnSpawn = false
ToggleGui.IgnoreGuiInset = true
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ToggleGui)
    end
end)

ToggleGui.Parent = game:GetService("CoreGui")

local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleLogo"
ToggleButton.Size = UDim2.new(0, 52, 0, 52)
ToggleButton.Position = UDim2.new(0, 18, 0.5, -26)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleButton.BackgroundTransparency = 0.08
ToggleButton.BorderSizePixel = 0
ToggleButton.Image = "rbxassetid://6031091004"
ToggleButton.ScaleType = Enum.ScaleType.Fit
ToggleButton.ZIndex = 9999
ToggleButton.Parent = ToggleGui

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0)
LogoCorner.Parent = ToggleButton

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Color3.fromRGB(120, 170, 255)
LogoStroke.Thickness = 2
LogoStroke.Transparency = 0.15
LogoStroke.Parent = ToggleButton

--// Kéo logo
local dragging = false
local dragStart
local startPos

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        -- handled below
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        ToggleButton.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--// Đổi tên biến này nếu ScreenGui UI chính của m tên khác
local MainUI = player.PlayerGui:FindFirstChild("KyzenLiquidGlass")
local opened = true
local clickStart

ToggleButton.MouseButton1Down:Connect(function()
    clickStart = tick()
end)

ToggleButton.MouseButton1Click:Connect(function()
    -- tránh click khi vừa kéo
    if clickStart and tick() - clickStart > 0.25 then
        return
    end

    opened = not opened

    if MainUI then
        MainUI.Enabled = opened
    end

    TweenService:Create(
        ToggleButton,
        TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(
                0,
                opened and 52 or 48,
                0,
                opened and 52 or 48
            )
        }
    ):Play()
end)
