local v0rtexdIsTheBestDev = cloneref or function(service) return service end

local oMgThisTweenServiceIsSoCool = v0rtexdIsTheBestDev(game:GetService("TweenService"))
local thisInputServiceGoesHard = v0rtexdIsTheBestDev(game:GetService("UserInputService"))
local runServiceMoreLikeWalkService = v0rtexdIsTheBestDev(game:GetService("RunService"))
local playersAreNoobs = v0rtexdIsTheBestDev(game:GetService("Players"))
local textServiceBeLikeText = v0rtexdIsTheBestDev(game:GetService("TextService"))
local coreGuiMoreLikeBoreGui = v0rtexdIsTheBestDev(game:GetService("CoreGui"))
local guiServiceIsCool = v0rtexdIsTheBestDev(game:GetService("GuiService"))

local superMegaAwesomeLibrary = {}
superMegaAwesomeLibrary.__index = superMegaAwesomeLibrary

local theOneAndOnlyPlayer = playersAreNoobs.LocalPlayer
local mouseGoClickClick = theOneAndOnlyPlayer:GetMouse()

local isMobileUserSadly = thisInputServiceGoesHard.TouchEnabled and not thisInputServiceGoesHard.KeyboardEnabled
local mobileScaleFactor = isMobileUserSadly and 0.75 or 1

local brandLogoUrl = "https://raw.githubusercontent.com/CodeE4X-dev/Assets/main/logo.png"
local brandLogoFallback = "rbxassetid://10723375250"
local brandLogoAsset
local function resolveBrandIcon()
    if brandLogoAsset then
        return brandLogoAsset
    end
    brandLogoAsset = brandLogoFallback
    pcall(function()
        local getAsset = getcustomasset or getsynasset
        if not (getAsset and writefile) then
            return
        end
        local path = "codee4x_logo.png"
        if not (isfile and isfile(path)) then
            local data = game:HttpGet(brandLogoUrl)
            if type(data) ~= "string" or #data == 0 then
                return
            end
            writefile(path, data)
        end
        local id = getAsset(path)
        if type(id) == "string" and #id > 0 then
            brandLogoAsset = id
        end
    end)
    return brandLogoAsset
end

local function makeThingExist(className, properties)
    local whatWeJustMade = Instance.new(className)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            pcall(function()
                whatWeJustMade[property] = value
            end)
        end
    end
    if properties.Parent then
        whatWeJustMade.Parent = properties.Parent
    end
    return whatWeJustMade
end

local function smoothMoveGoWoosh(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfoYay = TweenInfo.new(duration or 0.2, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out)
    local tweenGoVroom = oMgThisTweenServiceIsSoCool:Create(instance, tweenInfoYay, properties)
    tweenGoVroom:Play()
    return tweenGoVroom
end

local function makeDraggableCuzWeCan(frame, handle)
    handle = handle or frame
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    handle.Active = true
    
    local function updatePosition(input)
        if not dragging or not dragStart or not startPos then return end
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    handle.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    dragStart = nil
                    startPos = nil
                    if connection then
                        connection:Disconnect()
                    end
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                updatePosition(input)
            end
        end
    end)
    
    thisInputServiceGoesHard.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updatePosition(input)
        end
    end)
    
    thisInputServiceGoesHard.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            dragStart = nil
            startPos = nil
        end
    end)
end

local function getPlayerAvatarCuzTheyreBeautiful(userId)
    local didItWork, whatWeGot = pcall(function()
        return playersAreNoobs:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    if didItWork then
        return whatWeGot
    end
    return "rbxassetid://135756197673563"
end

local function howWideIsThisText(text, textSize, font)
    local textBoundsYay = textServiceBeLikeText:GetTextSize(text, textSize, font or Enum.Font.GothamSemibold, Vector2.new(math.huge, math.huge))
    return textBoundsYay.X
end

local function truncateTextLikeABoss(text, maxWidth, textSize, font)
    local fullWidth = howWideIsThisText(text, textSize, font)
    if fullWidth <= maxWidth then
        return text
    end
    
    local truncated = text
    while howWideIsThisText(truncated .. "...", textSize, font) > maxWidth and #truncated > 0 do
        truncated = truncated:sub(1, -2)
    end
    return truncated .. "..."
end

function superMegaAwesomeLibrary.new(config)
    local self = setmetatable({}, superMegaAwesomeLibrary)
    
    self.config = config or {}
    self.config.Name = self.config.Name or "o11 vision"
    self.config.AccentColor = self.config.AccentColor or Color3.fromRGB(2, 133, 255)
    self.config.BackgroundColor = self.config.BackgroundColor or Color3.fromRGB(16, 16, 16)
    self.config.SecondaryColor = self.config.SecondaryColor or Color3.fromRGB(18, 18, 18)
    self.config.TextColor = self.config.TextColor or Color3.fromRGB(255, 255, 255)
    self.config.SubTextColor = self.config.SubTextColor or Color3.fromRGB(124, 124, 124)
    
    self.sectionsAreAwesome = {}
    self.tabsGoWoosh = {}
    self.currentTabYay = nil
    self.notificationsAreCool = {}
    self.isToggledOn = true
    self.dropdownHolderRef = nil
    
    self:CreateUIBecauseWeNeedIt()
    
    return self
end

function superMegaAwesomeLibrary:CreateUIBecauseWeNeedIt()
    self.screenGuiYay = makeThingExist("ScreenGui", {
        Name = "v0rtexdBestUIEver",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    if syn then
        syn.protect_gui(self.screenGuiYay)
        self.screenGuiYay.Parent = coreGuiMoreLikeBoreGui
    elseif gethui then
        self.screenGuiYay.Parent = gethui()
    else
        self.screenGuiYay.Parent = theOneAndOnlyPlayer:WaitForChild("PlayerGui")
    end
    
    self.dropdownHolderRef = makeThingExist("Frame", {
        Name = "DropdownHolderBecauseDropdownsNeedHomes",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 9999,
        Parent = self.screenGuiYay
    })
    
    self.__ddOpen = {}
    self.searchIndex = {}

    self:CreateWatermarkBecauseWeCool()
    self:CreateMainFrameYay()
    self:CreateNotificationHolderForCoolNotifs()
    self:CreateReshowPill()
    
    thisInputServiceGoesHard.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == (self.config.ToggleKey or Enum.KeyCode.RightControl) then
            self:ToggleUI()
        end
    end)
end

function superMegaAwesomeLibrary:CloseDropdowns()
    if self.__ddOpen then
        for _, closer in pairs(self.__ddOpen) do
            pcall(closer)
        end
        table.clear(self.__ddOpen)
    end
end

function superMegaAwesomeLibrary:ToggleUI()
    self.isToggledOn = not self.isToggledOn
    self:CloseDropdowns()
    if self.searchResultsFrame then
        self.searchResultsFrame.Visible = false
    end

    local mf = self.mainFrameYay

    if self.isToggledOn then
        pcall(function()
            mf.GroupTransparency = 1
        end)
        mf.Visible = true
        smoothMoveGoWoosh(mf, {GroupTransparency = 0}, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    else
        smoothMoveGoWoosh(mf, {GroupTransparency = 1}, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        task.delay(0.26, function()
            if not self.isToggledOn and mf and mf.Parent then
                mf.Visible = false
            end
        end)
    end

    if self.reshowPill then
        if self.isToggledOn then
            self.reshowPill.Visible = false
        else
            task.delay(0.1, function()
                if not self.isToggledOn and self.reshowPill then
                    self.reshowPill.Visible = true
                    local sc = self.reshowPill:FindFirstChildOfClass("UIScale")
                    if sc then
                        sc.Scale = 0.6
                        smoothMoveGoWoosh(sc, {Scale = 1}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    end
                end
            end)
        end
    end
end

function superMegaAwesomeLibrary:CreateReshowPill()
    local pill = makeThingExist("Frame", {
        Name = "ReshowPill",
        BackgroundColor3 = Color3.fromRGB(16, 16, 20),
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 14),
        Size = UDim2.new(0, 118 * mobileScaleFactor, 0, 34 * mobileScaleFactor),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 17000,
        Active = true,
        Parent = self.screenGuiYay
    })

    makeThingExist("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = pill
    })

    makeThingExist("UIScale", {
        Scale = 1,
        Parent = pill
    })

    local pillStroke = makeThingExist("UIStroke", {
        Color = self.config.AccentColor,
        Thickness = 1.4,
        Transparency = 0.25,
        Parent = pill
    })

    local pillGrad = makeThingExist("UIGradient", {
        Rotation = 25,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.config.AccentColor),
            ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, self.config.AccentColor),
        }),
        Parent = pillStroke
    })

    makeThingExist("ImageLabel", {
        Name = "PillIcon",
        BackgroundTransparency = 1,
        Image = resolveBrandIcon(),
        ImageColor3 = self.config.AccentColor,
        Position = UDim2.new(0, 10, 0.5, -8 * mobileScaleFactor),
        Size = UDim2.new(0, 16 * mobileScaleFactor, 0, 16 * mobileScaleFactor),
        ZIndex = 17001,
        Parent = pill
    })

    makeThingExist("TextLabel", {
        Name = "PillText",
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        TextColor3 = Color3.new(1, 1, 1),
        Text = "open menu",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        TextSize = 12.5 * mobileScaleFactor,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 17001,
        Parent = pill
    })

    local pillBtn = makeThingExist("TextButton", {
        Name = "PillButton",
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 17002,
        Parent = pill
    })

    task.spawn(function()
        while pill.Parent do
            if pill.Visible then
                pillGrad.Rotation = (os.clock() * 80) % 360
            end
            task.wait(0.05)
        end
    end)

    pillBtn.MouseEnter:Connect(function()
        smoothMoveGoWoosh(pill, {BackgroundColor3 = Color3.fromRGB(24, 24, 30)}, 0.15)
        smoothMoveGoWoosh(pillStroke, {Transparency = 0}, 0.15)
    end)
    pillBtn.MouseLeave:Connect(function()
        smoothMoveGoWoosh(pill, {BackgroundColor3 = Color3.fromRGB(16, 16, 20)}, 0.15)
        smoothMoveGoWoosh(pillStroke, {Transparency = 0.25}, 0.15)
    end)

    local dragging, hasMoved, dragStart, startPos = false, false, nil, nil

    pillBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            hasMoved = false
            dragStart = input.Position
            startPos = pill.Position
        end
    end)
    pillBtn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 8 then
                hasMoved = true
            end
            pill.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    thisInputServiceGoesHard.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not hasMoved then
                if not self.isToggledOn then
                    self:ToggleUI()
                end
            end
            dragging = false
        end
    end)

    self.reshowPill = pill
end

function superMegaAwesomeLibrary:CreateWatermarkBecauseWeCool()
    local hubNameWidth = howWideIsThisText(self.config.Name, 14, Enum.Font.GothamSemibold)
    local initialText = self.config.Name .. " | 00:00:00 | 60 FPS"
    local initialWidth = howWideIsThisText(initialText, 14, Enum.Font.GothamSemibold) + 45
    
    self.watermarkFrame = makeThingExist("Frame", {
        Name = "WatermarkCuzWeNeedFlexing",
        BackgroundColor3 = Color3.fromRGB(16, 16, 16),
        Position = UDim2.new(0.01, 0, 0.02, 0),
        BorderColor3 = Color3.new(),
        BorderSizePixel = 0,
        Size = UDim2.new(0, initialWidth * mobileScaleFactor, 0, 36 * mobileScaleFactor),
        Active = true,
        Parent = self.screenGuiYay
    })
    
    makeThingExist("UICorner", {
        Name = "RoundedCornersAreSexy",
        CornerRadius = UDim.new(0, 7),
        Parent = self.watermarkFrame
    })
    
    local watermarkIconYay = makeThingExist("ImageLabel", {
        Name = "IconGoesHere",
        BorderColor3 = Color3.new(),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Image = resolveBrandIcon(),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 11, 0.5, -7.5 * mobileScaleFactor),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 15 * mobileScaleFactor, 0, 15 * mobileScaleFactor),
        Parent = self.watermarkFrame
    })
    
    makeThingExist("UIAspectRatioConstraint", {
        Name = "KeepItSquare",
        Parent = watermarkIconYay
    })
    
    self.watermarkTextLabel = makeThingExist("TextLabel", {
        Name = "TextGoesHereToo",
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextColor3 = Color3.new(1, 1, 1),
        Text = initialText,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 0),
        BorderSizePixel = 0,
        BorderColor3 = Color3.new(),
        TextSize = 14 * mobileScaleFactor,
        Size = UDim2.new(1, -40, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.watermarkFrame
    })
    
    makeThingExist("UIPadding", {
        Name = "PaddingForDays",
        PaddingTop = UDim.new(0, 2),
        Parent = self.watermarkTextLabel
    })
    
    makeDraggableCuzWeCan(self.watermarkFrame)
    
    local lastWatermarkWidth = 0
    task.spawn(function()
        while task.wait(1) do
            if self.watermarkFrame and self.watermarkFrame.Parent and self.watermarkTextLabel and self.watermarkTextLabel.Parent and self.watermarkFrame.Visible then
                local timeNow = os.date("%H:%M:%S")
                local fpsCount = math.floor(1 / runServiceMoreLikeWalkService.RenderStepped:Wait())
                local newText = self.config.Name .. " | " .. timeNow .. " | " .. fpsCount .. " FPS"
                self.watermarkTextLabel.Text = newText

                local newWidth = howWideIsThisText(newText, 14 * mobileScaleFactor, Enum.Font.GothamSemibold) + 45
                if math.abs(newWidth - lastWatermarkWidth) > 2 then
                    lastWatermarkWidth = newWidth
                    smoothMoveGoWoosh(self.watermarkFrame, {Size = UDim2.new(0, newWidth, 0, 36 * mobileScaleFactor)}, 0.2)
                end
            end
        end
    end)
end

function superMegaAwesomeLibrary:CreateMainFrameYay()
    local frameWidth = 753 * mobileScaleFactor
    local frameHeight = 493 * mobileScaleFactor

    self.mainFrameYay = makeThingExist("CanvasGroup", {
        Name = "MainFrameIsAwesome",
        BackgroundColor3 = Color3.fromRGB(16, 16, 16),
        GroupTransparency = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BorderColor3 = Color3.new(),
        BorderSizePixel = 0,
        Size = UDim2.new(0, frameWidth, 0, frameHeight),
        Active = true,
        Parent = self.screenGuiYay
    })

    self.mainScale = makeThingExist("UIScale", {
        Name = "AutoFitScale",
        Scale = 1,
        Parent = self.mainFrameYay
    })

    local function fitToScreen()
        local cam = workspace.CurrentCamera
        local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
        local s = math.min((vp.X - 30) / frameWidth, (vp.Y - 50) / frameHeight, 1)
        self.mainScale.Scale = math.clamp(s, 0.45, 1)
    end

    fitToScreen()

    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then
            cam:GetPropertyChangedSignal("ViewportSize"):Connect(fitToScreen)
        end
    end)
    
    makeThingExist("UICorner", {
        Name = "UICorner",
        CornerRadius = UDim.new(0, 10),
        Parent = self.mainFrameYay
    })

    makeThingExist("UIStroke", {
        Name = "MainFrameStroke",
        Color = Color3.fromRGB(44, 44, 52),
        Thickness = 1,
        Parent = self.mainFrameYay
    })
    
    self.dragBarThing = makeThingExist("Frame", {
        Name = "DragBarForDragging",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 65 * mobileScaleFactor),
        Active = true,
        Parent = self.mainFrameYay
    })
    
    makeDraggableCuzWeCan(self.mainFrameYay, self.dragBarThing)
    
    local fullHubName = tostring(self.config.Name or "menu")
    local hubTitleText, hubSubText = fullHubName, ""
    local barAt = fullHubName:find("|", 1, true)
    if barAt then
        hubTitleText = fullHubName:sub(1, barAt - 1):gsub("^%s+", ""):gsub("%s+$", "")
        hubSubText = fullHubName:sub(barAt + 1):gsub("^%s+", ""):gsub("%s+$", "")
    end

    self.hubIconFrame = makeThingExist("Frame", {
        Name = "HubIcon",
        BackgroundColor3 = Color3.new(1, 1, 1),
        Position = UDim2.new(0, 17, 0, 14 * mobileScaleFactor),
        Size = UDim2.new(0, 32 * mobileScaleFactor, 0, 32 * mobileScaleFactor),
        BorderSizePixel = 0,
        Parent = self.mainFrameYay
    })

    makeThingExist("UICorner", {
        CornerRadius = UDim.new(0, 9),
        Parent = self.hubIconFrame
    })

    makeThingExist("UIGradient", {
        Name = "HubIconGradient",
        Rotation = 65,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.config.AccentColor),
            ColorSequenceKeypoint.new(1, self.config.AccentColor:Lerp(Color3.new(0, 0, 0), 0.45)),
        }),
        Parent = self.hubIconFrame
    })

    makeThingExist("UIStroke", {
        Color = self.config.AccentColor,
        Transparency = 0.55,
        Thickness = 1.2,
        Parent = self.hubIconFrame
    })

    makeThingExist("TextLabel", {
        Name = "HubIconV",
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
        Text = "V",
        TextColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        TextSize = 19 * mobileScaleFactor,
        Parent = self.hubIconFrame
    })

    self.hubNameLabel = makeThingExist("TextLabel", {
        Name = "HubNameGoesHere",
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        TextColor3 = Color3.new(1, 1, 1),
        Text = hubTitleText,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 57, 0, 12 * mobileScaleFactor),
        BorderSizePixel = 0,
        TextSize = 17 * mobileScaleFactor,
        Size = UDim2.new(0, 118 * mobileScaleFactor, 0, 19 * mobileScaleFactor),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = self.mainFrameYay
    })

    self.hubNameGradient = makeThingExist("UIGradient", {
        Name = "HubNameGradient",
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.5, self.config.AccentColor),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
        }),
        Parent = self.hubNameLabel
    })

    self.hubSubLabel = makeThingExist("TextLabel", {
        Name = "HubSubName",
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        TextColor3 = Color3.fromRGB(120, 120, 130),
        Text = hubSubText,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 57, 0, 31 * mobileScaleFactor),
        BorderSizePixel = 0,
        TextSize = 11.5 * mobileScaleFactor,
        Size = UDim2.new(0, 118 * mobileScaleFactor, 0, 14 * mobileScaleFactor),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Visible = hubSubText ~= "",
        Parent = self.mainFrameYay
    })

    self.__titleAnimConn = runServiceMoreLikeWalkService.RenderStepped:Connect(function()
        if self.hubNameGradient and self.hubNameGradient.Parent then
            local t = (os.clock() * 0.4) % 1
            self.hubNameGradient.Offset = Vector2.new(t * 2 - 1, 0)
        end
    end)

    self.minimizeBtn = makeThingExist("TextButton", {
        Name = "MinimizeBtn",
        BackgroundColor3 = Color3.fromRGB(28, 28, 32),
        Position = UDim2.new(1, -44, 0, 12),
        Size = UDim2.new(0, 32, 0, 32),
        Text = "—",
        TextColor3 = Color3.fromRGB(210, 210, 215),
        TextSize = 15,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        AutoButtonColor = false,
        ZIndex = 50,
        Parent = self.mainFrameYay
    })

    makeThingExist("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = self.minimizeBtn
    })

    local minStroke = makeThingExist("UIStroke", {
        Color = Color3.fromRGB(45, 45, 50),
        Parent = self.minimizeBtn
    })

    self.minimizeBtn.MouseEnter:Connect(function()
        smoothMoveGoWoosh(self.minimizeBtn, {BackgroundColor3 = Color3.fromRGB(40, 40, 46)}, 0.15)
        smoothMoveGoWoosh(minStroke, {Color = self.config.AccentColor}, 0.15)
    end)
    self.minimizeBtn.MouseLeave:Connect(function()
        smoothMoveGoWoosh(self.minimizeBtn, {BackgroundColor3 = Color3.fromRGB(28, 28, 32)}, 0.15)
        smoothMoveGoWoosh(minStroke, {Color = Color3.fromRGB(45, 45, 50)}, 0.15)
    end)
    self.minimizeBtn.MouseButton1Click:Connect(function()
        if self.isToggledOn then
            self:ToggleUI()
        end
    end)
    
    self.lineSeperator = makeThingExist("Frame", {
        Name = "LineThatSeperates",
        BackgroundColor3 = self.config.AccentColor,
        Position = UDim2.new(0, 17, 0, 57 * mobileScaleFactor),
        BorderColor3 = Color3.new(),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 158 * mobileScaleFactor, 0, 1),
        Parent = self.mainFrameYay
    })

    makeThingExist("UIGradient", {
        Name = "UIGradient",
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.35),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = self.lineSeperator
    })
    
    self.tabNameLabel = makeThingExist("TextLabel", {
        Name = "TabNameGoesHere",
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextColor3 = Color3.new(1, 1, 1),
        Text = "tab name",
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 201 * mobileScaleFactor, 0, 14 * mobileScaleFactor),
        BorderSizePixel = 0,
        BorderColor3 = Color3.new(),
        TextSize = 17 * mobileScaleFactor,
        Size = UDim2.new(0, 78, 0, 20 * mobileScaleFactor),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.mainFrameYay
    })
    
    self.tabDescriptionLabel = makeThingExist("TextLabel", {
        Name = "TabDescriptionGoesHere",
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextColor3 = Color3.fromRGB(46, 46, 46),
        Text = "tab description",
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 201 * mobileScaleFactor, 0, 34 * mobileScaleFactor),
        BorderSizePixel = 0,
        BorderColor3 = Color3.new(),
        TextSize = 14 * mobileScaleFactor,
        Size = UDim2.new(0, 200, 0, 18 * mobileScaleFactor),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.mainFrameYay
    })
    
    self.searchFrame = makeThingExist("Frame", {
        Name = "SearchFrame",
        BackgroundColor3 = Color3.fromRGB(24, 24, 28),
        Position = UDim2.new(0, 17, 0, 66 * mobileScaleFactor),
        Size = UDim2.new(0, 158 * mobileScaleFactor, 0, 26 * mobileScaleFactor),
        BorderSizePixel = 0,
        Parent = self.mainFrameYay
    })

    makeThingExist("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.searchFrame
    })

    self.searchStroke = makeThingExist("UIStroke", {
        Color = Color3.fromRGB(38, 38, 44),
        Parent = self.searchFrame
    })

    makeThingExist("ImageLabel", {
        Name = "SearchIcon",
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734943674",
        ImageColor3 = Color3.fromRGB(110, 110, 120),
        Position = UDim2.new(0, 7, 0.5, -6 * mobileScaleFactor),
        Size = UDim2.new(0, 12 * mobileScaleFactor, 0, 12 * mobileScaleFactor),
        Parent = self.searchFrame
    })

    self.searchBox = makeThingExist("TextBox", {
        Name = "SearchBox",
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextColor3 = Color3.new(1, 1, 1),
        PlaceholderText = "Search features...",
        PlaceholderColor3 = Color3.fromRGB(95, 95, 105),
        Text = "",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 25, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
        TextSize = 12 * mobileScaleFactor,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = self.searchFrame
    })

    self.searchBox.Focused:Connect(function()
        smoothMoveGoWoosh(self.searchStroke, {Color = self.config.AccentColor}, 0.15)
    end)
    self.searchBox.FocusLost:Connect(function()
        smoothMoveGoWoosh(self.searchStroke, {Color = Color3.fromRGB(38, 38, 44)}, 0.15)
    end)
    self.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:UpdateSearchResults(self.searchBox.Text)
    end)

    self.searchResultsFrame = makeThingExist("Frame", {
        Name = "SearchResults",
        BackgroundColor3 = Color3.fromRGB(18, 18, 22),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 190 * mobileScaleFactor, 0, 0),
        Visible = false,
        ZIndex = 16000,
        Parent = self.screenGuiYay
    })

    makeThingExist("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.searchResultsFrame
    })

    makeThingExist("UIStroke", {
        Color = Color3.fromRGB(45, 45, 52),
        Parent = self.searchResultsFrame
    })

    self.sectionHolderScroll = makeThingExist("ScrollingFrame", {
        Name = "SectionHolderForSections",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 17, 0, 100 * mobileScaleFactor),
        Size = UDim2.new(0, 162 * mobileScaleFactor, 0, 330 * mobileScaleFactor),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Active = true,
        Parent = self.mainFrameYay
    })

    self.profileCard = makeThingExist("Frame", {
        Name = "ProfileCard",
        BackgroundColor3 = Color3.fromRGB(21, 21, 25),
        Position = UDim2.new(0, 12, 1, -56 * mobileScaleFactor),
        Size = UDim2.new(0, 168 * mobileScaleFactor, 0, 46 * mobileScaleFactor),
        BorderSizePixel = 0,
        Parent = self.mainFrameYay
    })

    makeThingExist("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = self.profileCard
    })

    makeThingExist("UIStroke", {
        Color = Color3.fromRGB(36, 36, 42),
        Parent = self.profileCard
    })

    self.playerAvatarImg = makeThingExist("ImageLabel", {
        Name = "PlayerAvatarIs4K",
        BackgroundColor3 = Color3.fromRGB(30, 30, 36),
        Image = getPlayerAvatarCuzTheyreBeautiful(theOneAndOnlyPlayer.UserId),
        BackgroundTransparency = 0,
        Position = UDim2.new(0, 7, 0.5, -16 * mobileScaleFactor),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 32 * mobileScaleFactor, 0, 32 * mobileScaleFactor),
        Parent = self.profileCard
    })

    makeThingExist("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = self.playerAvatarImg
    })

    self.displayNameLabel = makeThingExist("TextLabel", {
        Name = "DisplayNameLabel",
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        TextColor3 = Color3.new(1, 1, 1),
        Text = theOneAndOnlyPlayer.DisplayName,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 46, 0, 7 * mobileScaleFactor),
        Size = UDim2.new(1, -52, 0, 16 * mobileScaleFactor),
        TextSize = 13 * mobileScaleFactor,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = self.profileCard
    })

    self.userNameLabel = makeThingExist("TextLabel", {
        Name = "UserNameOfTheCoolPlayer",
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        TextColor3 = Color3.fromRGB(110, 110, 120),
        Text = "@" .. theOneAndOnlyPlayer.Name,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 46, 0, 23 * mobileScaleFactor),
        Size = UDim2.new(1, -52, 0, 14 * mobileScaleFactor),
        TextSize = 11 * mobileScaleFactor,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = self.profileCard
    })
    
    makeThingExist("UIPadding", {
        Name = "UIPadding",
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 2),
        Parent = self.sectionHolderScroll
    })
    
    self.sectionLayoutThing = makeThingExist("UIListLayout", {
        Name = "UIListLayout",
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.sectionHolderScroll
    })
    
    self.contentHolderFrame = makeThingExist("Frame", {
        Name = "ContentHolderForContent",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 198 * mobileScaleFactor, 0, 62 * mobileScaleFactor),
        Size = UDim2.new(0, 548 * mobileScaleFactor, 0, 424 * mobileScaleFactor),
        ClipsDescendants = true,
        Active = true,
        Parent = self.mainFrameYay
    })
end

function superMegaAwesomeLibrary:UpdateSearchResults(text)
    local frame = self.searchResultsFrame
    if not frame then
        return
    end
    for _, ch in ipairs(frame:GetChildren()) do
        if ch:IsA("TextButton") then
            ch:Destroy()
        end
    end
    text = tostring(text or ""):lower()
    if #text < 2 then
        frame.Visible = false
        return
    end

    local matches = {}
    for _, entry in ipairs(self.searchIndex) do
        if entry.label:lower():find(text, 1, true) then
            matches[#matches + 1] = entry
            if #matches >= 8 then
                break
            end
        end
    end
    if #matches == 0 then
        frame.Visible = false
        return
    end

    local rowH = 26 * mobileScaleFactor
    for i, entry in ipairs(matches) do
        local row = makeThingExist("TextButton", {
            Name = "SearchRow",
            BackgroundColor3 = Color3.fromRGB(18, 18, 22),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 4, 0, (i - 1) * rowH + 4),
            Size = UDim2.new(1, -8, 0, rowH),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 16001,
            Parent = frame
        })
        makeThingExist("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = row
        })
        makeThingExist("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            TextColor3 = Color3.new(1, 1, 1),
            Text = entry.label,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 2),
            Size = UDim2.new(1, -70, 1, -4),
            TextSize = 12 * mobileScaleFactor,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 16002,
            Parent = row
        })
        makeThingExist("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            TextColor3 = self.config.AccentColor,
            Text = entry.tab,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -62, 0, 2),
            Size = UDim2.new(0, 56, 1, -4),
            TextSize = 10.5 * mobileScaleFactor,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 16002,
            Parent = row
        })
        row.MouseEnter:Connect(function()
            smoothMoveGoWoosh(row, {BackgroundTransparency = 0.55, BackgroundColor3 = self.config.AccentColor}, 0.12)
        end)
        row.MouseLeave:Connect(function()
            smoothMoveGoWoosh(row, {BackgroundTransparency = 1}, 0.12)
        end)
        row.MouseButton1Click:Connect(function()
            frame.Visible = false
            self.searchBox.Text = ""
            pcall(entry.go)
            if entry.inst and entry.inst:IsA("TextLabel") then
                local orig = Color3.fromRGB(124, 124, 124)
                entry.inst.TextColor3 = self.config.AccentColor
                task.delay(1.4, function()
                    pcall(function()
                        smoothMoveGoWoosh(entry.inst, {TextColor3 = orig}, 0.5)
                    end)
                end)
            end
        end)
    end

    local sfPos = self.searchFrame.AbsolutePosition
    local sfSize = self.searchFrame.AbsoluteSize
    frame.Position = UDim2.new(0, sfPos.X, 0, sfPos.Y + sfSize.Y + 8)
    frame.Size = UDim2.new(0, 190 * mobileScaleFactor, 0, #matches * rowH + 8)
    frame.Visible = true
end

function superMegaAwesomeLibrary:CreateNotificationHolderForCoolNotifs()
    self.notificationHolderFrame = makeThingExist("Frame", {
        Name = "NotificationHolderForNotifs",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -18, 1, -18),
        Size = UDim2.new(0, 310 * mobileScaleFactor, 1, -120),
        Parent = self.screenGuiYay
    })

    makeThingExist("UIListLayout", {
        Name = "UIListLayout",
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Parent = self.notificationHolderFrame
    })
end

function superMegaAwesomeLibrary:Notify(config)
    config = config or {}
    local title = tostring(config.Title or "Notification")
    local desc = type(config.Description) == "string" and config.Description or (type(config.Content) == "string" and config.Content or "")
    local duration = tonumber(config.Duration or config.Time) or 4
    local accent = self.config.AccentColor
    local holder = self.notificationHolderFrame

    if not holder or not holder.Parent then
        return
    end

    local hasDesc = #desc > 0
    local cardW = 300 * mobileScaleFactor
    local textW = cardW - 74 * mobileScaleFactor
    local descCalc = hasDesc and textServiceBeLikeText:GetTextSize(desc, 12.5 * mobileScaleFactor, Enum.Font.Gotham, Vector2.new(textW, math.huge)) or Vector2.new(0, 0)
    local cardH = hasDesc and math.max(54 * mobileScaleFactor, 30 * mobileScaleFactor + descCalc.Y + 16) or 48 * mobileScaleFactor

    local cell = makeThingExist("Frame", {
        Name = "NotifCell",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, cardW, 0, 0),
        ClipsDescendants = false,
        Parent = holder
    })

    local card = makeThingExist("TextButton", {
        Name = "NotifCard",
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(17, 17, 22),
        Position = UDim2.new(0, cardW + 40, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = cell
    })

    makeThingExist("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = card
    })

    local cardStroke = makeThingExist("UIStroke", {
        Color = Color3.fromRGB(48, 48, 56),
        Thickness = 1,
        Parent = card
    })

    local accentStrip = makeThingExist("Frame", {
        Name = "AccentStrip",
        BackgroundColor3 = accent,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 8, 0.5, 0),
        Size = UDim2.new(0, 3, 1, -18),
        BorderSizePixel = 0,
        Parent = card
    })

    makeThingExist("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = accentStrip
    })

    local iconChip = makeThingExist("Frame", {
        Name = "IconChip",
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.86,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 19, 0.5, 0),
        Size = UDim2.new(0, 26 * mobileScaleFactor, 0, 26 * mobileScaleFactor),
        BorderSizePixel = 0,
        Parent = card
    })

    makeThingExist("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = iconChip
    })

    makeThingExist("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Image = config.Icon or "rbxassetid://10747361219",
        ImageColor3 = accent,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 15 * mobileScaleFactor, 0, 15 * mobileScaleFactor),
        Parent = iconChip
    })

    makeThingExist("TextLabel", {
        Name = "NotifTitle",
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        TextColor3 = Color3.new(1, 1, 1),
        Text = title,
        BackgroundTransparency = 1,
        Position = hasDesc and UDim2.new(0, 55, 0, 9 * mobileScaleFactor) or UDim2.new(0, 55, 0.5, -8 * mobileScaleFactor),
        Size = UDim2.new(1, -80, 0, 16 * mobileScaleFactor),
        TextSize = 13.5 * mobileScaleFactor,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card
    })

    if hasDesc then
        makeThingExist("TextLabel", {
            Name = "NotifDesc",
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(158, 158, 168),
            Text = desc,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 55, 0, 27 * mobileScaleFactor),
            Size = UDim2.new(0, textW, 0, descCalc.Y + 4),
            TextSize = 12.5 * mobileScaleFactor,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Parent = card
        })
    end

    local closeBtn = makeThingExist("TextButton", {
        Name = "NotifClose",
        Text = "\u{00D7}",
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        TextColor3 = Color3.fromRGB(120, 120, 130),
        TextSize = 15,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -22, 0, 4),
        Size = UDim2.new(0, 18, 0, 18),
        ZIndex = 2,
        Parent = card
    })

    local barFill = makeThingExist("Frame", {
        Name = "NotifCountdown",
        BackgroundColor3 = accent,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 2),
        BorderSizePixel = 0,
        Parent = card
    })

    makeThingExist("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, accent),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
        }),
        Parent = barFill
    })

    local closed = false
    local function dismiss()
        if closed then
            return
        end
        closed = true
        pcall(function()
            smoothMoveGoWoosh(card, {Position = UDim2.new(0, cardW + 40, 0, 0)}, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            smoothMoveGoWoosh(cardStroke, {Transparency = 1}, 0.28)
        end)
        task.delay(0.24, function()
            pcall(function()
                smoothMoveGoWoosh(cell, {Size = UDim2.new(0, cardW, 0, 0)}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            end)
            task.delay(0.2, function()
                pcall(function()
                    cell:Destroy()
                end)
            end)
        end)
    end

    card.MouseButton1Click:Connect(dismiss)
    closeBtn.MouseButton1Click:Connect(dismiss)
    closeBtn.MouseEnter:Connect(function()
        smoothMoveGoWoosh(closeBtn, {TextColor3 = Color3.new(1, 1, 1)}, 0.12)
    end)
    closeBtn.MouseLeave:Connect(function()
        smoothMoveGoWoosh(closeBtn, {TextColor3 = Color3.fromRGB(120, 120, 130)}, 0.12)
    end)
    card.MouseEnter:Connect(function()
        smoothMoveGoWoosh(cardStroke, {Color = accent}, 0.15)
    end)
    card.MouseLeave:Connect(function()
        smoothMoveGoWoosh(cardStroke, {Color = Color3.fromRGB(48, 48, 56)}, 0.15)
    end)

    task.defer(function()
        smoothMoveGoWoosh(cell, {Size = UDim2.new(0, cardW, 0, cardH)}, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        smoothMoveGoWoosh(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        smoothMoveGoWoosh(barFill, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    end)

    task.delay(duration, dismiss)

    return card
end

function superMegaAwesomeLibrary:CreateSection(config)
    config = config or {}
    config.Name = config.Name or "Section"
    config.Icon = config.Icon or "rbxassetid://98092584632154"
    
    local sectionObj = {}
    sectionObj.tabsInSection = {}
    sectionObj.isExpanded = true
    sectionObj.Library = self
    
    sectionObj.containerFrame = makeThingExist("Frame", {
        Name = "SectionContainerYay",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 154 * mobileScaleFactor, 0, 32 * mobileScaleFactor),
        ClipsDescendants = true,
        Parent = self.sectionHolderScroll
    })
    
    sectionObj.mainFrame = makeThingExist("Frame", {
        Name = "SectionMainFrame",
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        Position = UDim2.new(0, 0, 0, 0),
        BorderColor3 = Color3.new(),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 28 * mobileScaleFactor),
        Parent = sectionObj.containerFrame
    })

    local strokeThing = makeThingExist("UIStroke", {
        Name = "UIStroke",
        Color = Color3.fromRGB(33, 33, 33),
        Parent = sectionObj.mainFrame
    })
    
    makeThingExist("UIGradient", {
        Name = "UIGradient",
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.493, Color3.fromRGB(150, 150, 150)),
            ColorSequenceKeypoint.new(0.509, Color3.fromRGB(150, 150, 150)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }),
        Rotation = 260,
        Parent = strokeThing
    })
    
    makeThingExist("UICorner", {
        Name = "UICorner",
        CornerRadius = UDim.new(0, 7),
        Parent = sectionObj.mainFrame
    })
    
    makeThingExist("ImageLabel", {
        Name = "SectionIcon",
        BorderColor3 = Color3.new(),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Image = config.Icon,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -7 * mobileScaleFactor),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 14 * mobileScaleFactor, 0, 14 * mobileScaleFactor),
        Parent = sectionObj.mainFrame
    })
    
    makeThingExist("TextLabel", {
        Name = "SectionName",
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextColor3 = Color3.new(1, 1, 1),
        Text = config.Name,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0.5, -8.5 * mobileScaleFactor),
        BorderSizePixel = 0,
        BorderColor3 = Color3.new(),
        TextSize = 15 * mobileScaleFactor,
        Size = UDim2.new(0, 80, 0, 17 * mobileScaleFactor),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sectionObj.mainFrame
    })
    
    local expandButtonImg = makeThingExist("ImageButton", {
        Name = "ExpandCollapseButton",
        BackgroundColor3 = Color3.new(1, 1, 1),
        Image = "rbxassetid://111626678408582",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -24, 0.5, -8 * mobileScaleFactor),
        BorderColor3 = Color3.new(),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 16 * mobileScaleFactor, 0, 16 * mobileScaleFactor),
        Parent = sectionObj.mainFrame
    })
    
    sectionObj.tabHolderFrame = makeThingExist("Frame", {
        Name = "TabHolderFrame",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 36 * mobileScaleFactor),
        Size = UDim2.new(1, -16, 0, 0),
        Parent = sectionObj.containerFrame
    })
    
    sectionObj.tabLayoutThing = makeThingExist("UIListLayout", {
        Name = "UIListLayout",
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sectionObj.tabHolderFrame
    })
    
    local function updateContainerSizeYay()
        local tabsHeight = sectionObj.tabLayoutThing.AbsoluteContentSize.Y
        sectionObj.tabHolderFrame.Size = UDim2.new(1, -16, 0, tabsHeight)
        if sectionObj.isExpanded then
            smoothMoveGoWoosh(sectionObj.containerFrame, {Size = UDim2.new(0, 154 * mobileScaleFactor, 0, 32 * mobileScaleFactor + tabsHeight + 12)}, 0.25)
        end
    end
    
    sectionObj.tabLayoutThing:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContainerSizeYay)
    
    expandButtonImg.MouseButton1Click:Connect(function()
        sectionObj.isExpanded = not sectionObj.isExpanded
        smoothMoveGoWoosh(expandButtonImg, {Rotation = sectionObj.isExpanded and 0 or -90}, 0.25)
        if sectionObj.isExpanded then
            local tabsHeight = sectionObj.tabLayoutThing.AbsoluteContentSize.Y
            smoothMoveGoWoosh(sectionObj.containerFrame, {Size = UDim2.new(0, 154 * mobileScaleFactor, 0, 32 * mobileScaleFactor + tabsHeight + 12)}, 0.25)
        else
            smoothMoveGoWoosh(sectionObj.containerFrame, {Size = UDim2.new(0, 154 * mobileScaleFactor, 0, 32 * mobileScaleFactor)}, 0.25)
        end
    end)
    
    function sectionObj:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        tabConfig.Name = tabConfig.Name or "Tab"
        tabConfig.Description = tabConfig.Description or "Tab description"
        tabConfig.Icon = tabConfig.Icon or "rbxassetid://94219370057308"
        
        local tabObj = {}
        tabObj.groupsInTab = {}
        tabObj.groupPositions = {Left = 0, Right = 0}
        tabObj.isActive = false
        tabObj.Library = sectionObj.Library
        
        tabObj.buttonFrame = makeThingExist("Frame", {
            Name = "TabButton",
            BackgroundColor3 = sectionObj.Library.config.AccentColor,
            BackgroundTransparency = 1,
            BorderColor3 = Color3.new(),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 28 * mobileScaleFactor),
            Parent = sectionObj.tabHolderFrame
        })
        
        makeThingExist("UICorner", {
            Name = "UICorner",
            CornerRadius = UDim.new(0, 7),
            Parent = tabObj.buttonFrame
        })

        tabObj.iconImg = makeThingExist("ImageLabel", {
            Name = "TabIcon",
            ImageColor3 = Color3.fromRGB(89, 89, 89),
            BackgroundColor3 = Color3.new(1, 1, 1),
            Image = tabConfig.Icon,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 9, 0.5, -7 * mobileScaleFactor),
            BorderColor3 = Color3.new(),
            BorderSizePixel = 0,
            Size = UDim2.new(0, 14 * mobileScaleFactor, 0, 14 * mobileScaleFactor),
            Parent = tabObj.buttonFrame
        })
        
        tabObj.nameLabel = makeThingExist("TextLabel", {
            Name = "TabName",
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(89, 89, 89),
            Text = tabConfig.Name,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 30, 0.5, -8 * mobileScaleFactor),
            BorderSizePixel = 4,
            BorderColor3 = Color3.new(),
            TextSize = 15 * mobileScaleFactor,
            Size = UDim2.new(1, -40, 0, 16 * mobileScaleFactor),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = tabObj.buttonFrame
        })
        
        local tabClickButton = makeThingExist("TextButton", {
            Name = "TabClickButton",
            Text = "",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = tabObj.buttonFrame
        })
        
        tabObj.contentScroll = makeThingExist("ScrollingFrame", {
            Name = "TabContentScroll",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 4, 0, 4),
            Size = UDim2.new(1, -8, 1, -8),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60),
            CanvasSize = UDim2.new(0, 540 * mobileScaleFactor, 0, 0),
            Visible = false,
            Active = true,
            Parent = sectionObj.Library.contentHolderFrame
        })
        
        tabObj.leftColumnFrame = makeThingExist("Frame", {
            Name = "LeftColumn",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 262 * mobileScaleFactor, 0, 1000),
            Parent = tabObj.contentScroll
        })
        
        tabObj.rightColumnFrame = makeThingExist("Frame", {
            Name = "RightColumn",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 270 * mobileScaleFactor, 0, 0),
            Size = UDim2.new(0, 262 * mobileScaleFactor, 0, 1000),
            Parent = tabObj.contentScroll
        })
        
        function tabObj:Activate()
            sectionObj.Library:CloseDropdowns()
            if sectionObj.Library.searchResultsFrame then
                sectionObj.Library.searchResultsFrame.Visible = false
            end
            if sectionObj.Library.currentTabYay then
                sectionObj.Library.currentTabYay:Deactivate()
            end
            
            sectionObj.Library.currentTabYay = tabObj
            tabObj.isActive = true
            tabObj.contentScroll.Visible = true
            tabObj.contentScroll.Position = UDim2.new(0, 4, 0, 18)
            smoothMoveGoWoosh(tabObj.contentScroll, {Position = UDim2.new(0, 4, 0, 4)}, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            smoothMoveGoWoosh(tabObj.buttonFrame, {BackgroundTransparency = 0}, 0.2)
            smoothMoveGoWoosh(tabObj.iconImg, {ImageColor3 = Color3.new(1, 1, 1)}, 0.2)
            smoothMoveGoWoosh(tabObj.nameLabel, {TextColor3 = Color3.new(1, 1, 1)}, 0.2)
            
            sectionObj.Library.tabNameLabel.Text = tabConfig.Name
            sectionObj.Library.tabDescriptionLabel.Text = tabConfig.Description
        end
        
        function tabObj:Deactivate()
            tabObj.isActive = false
            tabObj.contentScroll.Visible = false
            
            smoothMoveGoWoosh(tabObj.buttonFrame, {BackgroundTransparency = 1}, 0.2)
            smoothMoveGoWoosh(tabObj.iconImg, {ImageColor3 = Color3.fromRGB(89, 89, 89)}, 0.2)
            smoothMoveGoWoosh(tabObj.nameLabel, {TextColor3 = Color3.fromRGB(89, 89, 89)}, 0.2)
        end
        
        tabClickButton.MouseButton1Click:Connect(function()
            if not tabObj.isActive then
                tabObj:Activate()
            end
        end)
        
        tabClickButton.MouseEnter:Connect(function()
            if not tabObj.isActive then
                smoothMoveGoWoosh(tabObj.buttonFrame, {BackgroundTransparency = 0.9}, 0.15)
                smoothMoveGoWoosh(tabObj.nameLabel, {TextColor3 = Color3.fromRGB(190, 190, 195)}, 0.15)
                smoothMoveGoWoosh(tabObj.iconImg, {ImageColor3 = Color3.fromRGB(190, 190, 195)}, 0.15)
            end
        end)

        tabClickButton.MouseLeave:Connect(function()
            if not tabObj.isActive then
                smoothMoveGoWoosh(tabObj.buttonFrame, {BackgroundTransparency = 1}, 0.15)
                smoothMoveGoWoosh(tabObj.nameLabel, {TextColor3 = Color3.fromRGB(89, 89, 89)}, 0.2)
                smoothMoveGoWoosh(tabObj.iconImg, {ImageColor3 = Color3.fromRGB(89, 89, 89)}, 0.2)
            end
        end)
        
        function tabObj:AddGroup(groupConfig)
            groupConfig = groupConfig or {}
            groupConfig.Name = groupConfig.Name or "Group"
            groupConfig.Side = groupConfig.Side or "Left"
            groupConfig.Icon = groupConfig.Icon or "rbxassetid://10723427199"
            
            local groupObj = {}
            groupObj.elementsInGroup = {}
            groupObj.Library = tabObj.Library
            groupObj.elementYPos = 35 * mobileScaleFactor
            
            local parentColumn = groupConfig.Side == "Left" and tabObj.leftColumnFrame or tabObj.rightColumnFrame
            local groupWidth = 260 * mobileScaleFactor
            local yPosStart = tabObj.groupPositions[groupConfig.Side]
            
            groupObj.mainFrame = makeThingExist("Frame", {
                Name = "GroupModule",
                BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                Position = UDim2.new(0, 1, 0, yPosStart + 1),
                BorderColor3 = Color3.new(),
                BorderSizePixel = 0,
                Size = UDim2.new(0, groupWidth, 0, 50 * mobileScaleFactor),
                Active = true,
                Parent = parentColumn
            })

            local groupStrokeThing = makeThingExist("UIStroke", {
                Name = "UIStroke",
                Color = Color3.fromRGB(33, 33, 33),
                Parent = groupObj.mainFrame
            })
            
            makeThingExist("UIGradient", {
                Name = "UIGradient",
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(0.493, Color3.fromRGB(150, 150, 150)),
                    ColorSequenceKeypoint.new(0.509, Color3.fromRGB(150, 150, 150)),
                    ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                }),
                Rotation = 260,
                Parent = groupStrokeThing
            })
            
            makeThingExist("UICorner", {
                Name = "UICorner",
                CornerRadius = UDim.new(0, 11),
                Parent = groupObj.mainFrame
            })
            
            local groupIconImg = makeThingExist("ImageLabel", {
                Name = "GroupIcon",
                BorderColor3 = Color3.new(),
                BackgroundColor3 = Color3.new(1, 1, 1),
                Image = groupConfig.Icon,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 10 * mobileScaleFactor),
                BorderSizePixel = 0,
                Size = UDim2.new(0, 16 * mobileScaleFactor, 0, 16 * mobileScaleFactor),
                Parent = groupObj.mainFrame
            })
            
            makeThingExist("UIAspectRatioConstraint", {
                Name = "UIAspectRatioConstraint",
                Parent = groupIconImg
            })
            
            makeThingExist("TextLabel", {
                Name = "GroupName",
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextColor3 = Color3.new(1, 1, 1),
                Text = groupConfig.Name,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 32, 0, 8 * mobileScaleFactor),
                BorderSizePixel = 0,
                BorderColor3 = Color3.new(),
                TextSize = 15 * mobileScaleFactor,
                Size = UDim2.new(0, 100, 0, 16 * mobileScaleFactor),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = groupObj.mainFrame
            })

            local function updateGroupSizeYay()
                local newHeight = groupObj.elementYPos + 10 * mobileScaleFactor
                groupObj.mainFrame.Size = UDim2.new(0, groupWidth, 0, newHeight)
                tabObj.groupPositions[groupConfig.Side] = yPosStart + newHeight + 15 * mobileScaleFactor

                local maxHeight = math.max(tabObj.groupPositions.Left, tabObj.groupPositions.Right)
                tabObj.contentScroll.CanvasSize = UDim2.new(0, 540 * mobileScaleFactor, 0, maxHeight)
            end
            groupObj.refresh = updateGroupSizeYay
            
            function groupObj:AddToggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                toggleConfig.Name = toggleConfig.Name or "Toggle"
                toggleConfig.Default = toggleConfig.Default or false
                toggleConfig.Callback = toggleConfig.Callback or function() end
                
                local toggleObj = {}
                toggleObj.value = toggleConfig.Default
                
                local yPosition = groupObj.elementYPos
                local switchWidth = 38 * mobileScaleFactor
                local switchHeight = 20 * mobileScaleFactor
                local circleSize = 14 * mobileScaleFactor
                local circlePadding = 3 * mobileScaleFactor
                
                toggleObj.labelText = makeThingExist("TextLabel", {
                    Name = "ToggleLabel",
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(124, 124, 124),
                    Text = toggleConfig.Name,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.new(),
                    TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(0, 150 * mobileScaleFactor, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = groupObj.mainFrame
                })
                
                toggleObj.switchFrame = makeThingExist("Frame", {
                    Name = "ToggleSwitch",
                    BackgroundColor3 = toggleObj.value and groupObj.Library.config.AccentColor or Color3.fromRGB(32, 32, 32),
                    Position = UDim2.new(1, -(switchWidth + 10), 0, yPosition),
                    BorderColor3 = Color3.new(),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, switchWidth, 0, switchHeight),
                    Parent = groupObj.mainFrame
                })
                
                makeThingExist("UICorner", {
                    Name = "UICorner",
                    CornerRadius = UDim.new(1, 0),
                    Parent = toggleObj.switchFrame
                })
                
                local offPosX = circlePadding
                local onPosX = switchWidth - circleSize - circlePadding
                local circlePosY = (switchHeight - circleSize) / 2
                
                toggleObj.circleFrame = makeThingExist("Frame", {
                    Name = "ToggleCircle",
                    BackgroundColor3 = toggleObj.value and Color3.new(1, 1, 1) or Color3.fromRGB(75, 75, 75),
                    Position = toggleObj.value and UDim2.new(0, onPosX, 0, circlePosY) or UDim2.new(0, offPosX, 0, circlePosY),
                    BorderColor3 = Color3.new(),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, circleSize, 0, circleSize),
                    Parent = toggleObj.switchFrame
                })
                
                makeThingExist("UICorner", {
                    Name = "UICorner",
                    CornerRadius = UDim.new(1, 0),
                    Parent = toggleObj.circleFrame
                })
                
                local toggleClickButton = makeThingExist("TextButton", {
                    Name = "ToggleClickButton",
                    Text = "",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = toggleObj.switchFrame
                })
                
                function toggleObj:Set(value)
                    toggleObj.value = value
                    
                    if toggleObj.value then
                        smoothMoveGoWoosh(toggleObj.switchFrame, {BackgroundColor3 = groupObj.Library.config.AccentColor}, 0.2)
                        smoothMoveGoWoosh(toggleObj.circleFrame, {
                            Position = UDim2.new(0, onPosX, 0, circlePosY),
                            BackgroundColor3 = Color3.new(1, 1, 1)
                        }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    else
                        smoothMoveGoWoosh(toggleObj.switchFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.2)
                        smoothMoveGoWoosh(toggleObj.circleFrame, {
                            Position = UDim2.new(0, offPosX, 0, circlePosY),
                            BackgroundColor3 = Color3.fromRGB(75, 75, 75)
                        }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    end
                    
                    toggleConfig.Callback(toggleObj.value)
                end
                
                toggleClickButton.MouseButton1Click:Connect(function()
                    toggleObj:Set(not toggleObj.value)
                end)

                local rowClickButton = makeThingExist("TextButton", {
                    Name = "ToggleRowButton",
                    Text = "",
                    BackgroundColor3 = groupObj.Library.config.AccentColor,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 6, 0, yPosition - 2),
                    Size = UDim2.new(1, -(switchWidth + 26), 0, 24 * mobileScaleFactor),
                    AutoButtonColor = false,
                    Parent = groupObj.mainFrame
                })

                makeThingExist("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = rowClickButton
                })

                rowClickButton.MouseButton1Click:Connect(function()
                    toggleObj:Set(not toggleObj.value)
                end)
                rowClickButton.MouseEnter:Connect(function()
                    smoothMoveGoWoosh(rowClickButton, {BackgroundTransparency = 0.92}, 0.12)
                    smoothMoveGoWoosh(toggleObj.labelText, {TextColor3 = Color3.fromRGB(205, 205, 210)}, 0.12)
                end)
                rowClickButton.MouseLeave:Connect(function()
                    smoothMoveGoWoosh(rowClickButton, {BackgroundTransparency = 1}, 0.12)
                    smoothMoveGoWoosh(toggleObj.labelText, {TextColor3 = Color3.fromRGB(124, 124, 124)}, 0.12)
                end)

                if toggleConfig.Default then
                    toggleConfig.Callback(true)
                end
                
                groupObj.elementYPos = groupObj.elementYPos + 28 * mobileScaleFactor
                updateGroupSizeYay()
                
                table.insert(groupObj.elementsInGroup, toggleObj)
                return toggleObj
            end
            
            function groupObj:AddSlider(sliderConfig)
                sliderConfig = sliderConfig or {}
                sliderConfig.Name = sliderConfig.Name or "Slider"
                sliderConfig.Min = sliderConfig.Min or 0
                sliderConfig.Max = sliderConfig.Max or 100
                sliderConfig.Default = sliderConfig.Default or sliderConfig.Min
                sliderConfig.Increment = sliderConfig.Increment or 1
                sliderConfig.Callback = sliderConfig.Callback or function() end
                
                local sliderObj = {}
                sliderObj.value = sliderConfig.Default
                
                local yPosition = groupObj.elementYPos
                local sliderWidth = 238 * mobileScaleFactor
                local sliderHeight = 14 * mobileScaleFactor
                local handleSize = 18 * mobileScaleFactor
                
                sliderObj.labelText = makeThingExist("TextLabel", {
                    Name = "SliderLabel",
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(124, 124, 124),
                    Text = sliderConfig.Name,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.new(),
                    TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(0, 120 * mobileScaleFactor, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = groupObj.mainFrame
                })
                
                sliderObj.backgroundFrame = makeThingExist("Frame", {
                    Name = "SliderBackground",
                    BackgroundColor3 = Color3.fromRGB(32, 32, 32),
                    Position = UDim2.new(0, 10, 0, yPosition + 24 * mobileScaleFactor),
                    BorderColor3 = Color3.new(),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, sliderWidth, 0, sliderHeight),
                    ClipsDescendants = false,
                    Active = true,
                    Parent = groupObj.mainFrame
                })
                
                makeThingExist("UICorner", {
                    Name = "UICorner",
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderObj.backgroundFrame
                })
                
                local percentage = (sliderObj.value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)
                
                sliderObj.fillFrame = makeThingExist("Frame", {
                    Name = "SliderFill",
                    BackgroundColor3 = groupObj.Library.config.AccentColor,
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderColor3 = Color3.new(),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, math.max(sliderHeight, sliderWidth * percentage), 0, sliderHeight),
                    Parent = sliderObj.backgroundFrame
                })
                
                makeThingExist("UICorner", {
                    Name = "UICorner",
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderObj.fillFrame
                })

                sliderObj.handleFrame = makeThingExist("Frame", {
                    Name = "SliderHandle",
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Position = UDim2.new(0, math.clamp(sliderWidth * percentage - handleSize/2, 0, sliderWidth - handleSize), 0.5, -handleSize/2),
                    BorderColor3 = Color3.new(),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, handleSize, 0, handleSize),
                    ZIndex = 2,
                    Parent = sliderObj.backgroundFrame
                })
                
                makeThingExist("UICorner", {
                    Name = "UICorner",
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderObj.handleFrame
                })

                makeThingExist("UIStroke", {
                    Name = "UIStroke",
                    Color = groupObj.Library.config.AccentColor,
                    Thickness = 2,
                    Parent = sliderObj.handleFrame
                })
                
                sliderObj.valueLabelText = makeThingExist("TextLabel", {
                    Name = "SliderValueLabel",
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(124, 124, 124),
                    Text = tostring(sliderObj.value) .. " / " .. tostring(sliderConfig.Max),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -80 * mobileScaleFactor, 0, yPosition),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.new(),
                    TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(0, 70 * mobileScaleFactor, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = groupObj.mainFrame
                })
                
                local sliderClickButton = makeThingExist("TextButton", {
                    Name = "SliderClickButton",
                    Text = "",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -handleSize/2, 0, -handleSize/2),
                    Size = UDim2.new(1, handleSize, 1, handleSize),
                    ZIndex = 3,
                    Active = true,
                    Parent = sliderObj.backgroundFrame
                })
                
                local isDraggingSlider = false
                
                function sliderObj:Set(value)
                    value = math.clamp(value, sliderConfig.Min, sliderConfig.Max)
                    value = math.floor(value / sliderConfig.Increment + 0.5) * sliderConfig.Increment
                    value = math.round(value * 1000) / 1000
                    sliderObj.value = value
                    
                    local percentage = (value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)
                    local fillWidth = math.max(sliderHeight, sliderWidth * percentage)
                    local handleX = math.clamp(sliderWidth * percentage - handleSize/2, 0, sliderWidth - handleSize)
                    
                    smoothMoveGoWoosh(sliderObj.fillFrame, {Size = UDim2.new(0, fillWidth, 0, sliderHeight)}, 0.1)
                    smoothMoveGoWoosh(sliderObj.handleFrame, {Position = UDim2.new(0, handleX, 0.5, -handleSize/2)}, 0.1)
                    sliderObj.valueLabelText.Text = tostring(value) .. " / " .. tostring(sliderConfig.Max)
                    
                    sliderConfig.Callback(value)
                end
                
                local function handleSliderInput(inputPos)
                    local percentage = math.clamp((inputPos.X - sliderObj.backgroundFrame.AbsolutePosition.X) / sliderObj.backgroundFrame.AbsoluteSize.X, 0, 1)
                    local value = sliderConfig.Min + (sliderConfig.Max - sliderConfig.Min) * percentage
                    sliderObj:Set(value)
                end
                
                sliderClickButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isDraggingSlider = true
                        handleSliderInput(input.Position)
                    end
                end)
                
                sliderClickButton.InputChanged:Connect(function(input)
                    if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        handleSliderInput(input.Position)
                    end
                end)
                
                thisInputServiceGoesHard.InputChanged:Connect(function(input)
                    if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        handleSliderInput(input.Position)
                    end
                end)
                
                thisInputServiceGoesHard.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isDraggingSlider = false
                    end
                end)
                
                if sliderConfig.Default ~= sliderConfig.Min then
                    sliderConfig.Callback(sliderConfig.Default)
                end
                
                groupObj.elementYPos = groupObj.elementYPos + 46 * mobileScaleFactor
                updateGroupSizeYay()
                
                table.insert(groupObj.elementsInGroup, sliderObj)
                return sliderObj
            end
            
            function groupObj:AddButton(buttonConfig)
                buttonConfig = buttonConfig or {}
                buttonConfig.Name = buttonConfig.Name or "Button"
                buttonConfig.Icon = buttonConfig.Icon
                buttonConfig.Locked = buttonConfig.Locked or false
                buttonConfig.Callback = buttonConfig.Callback or function() end
                
                local buttonObj = {}
                buttonObj.isLocked = buttonConfig.Locked
                
                local yPosition = groupObj.elementYPos
                local buttonWidth = 238 * mobileScaleFactor
                
                buttonObj.mainFrame = makeThingExist("Frame", {
                    Name = "ButtonFrame",
                    BackgroundColor3 = buttonObj.isLocked and Color3.fromRGB(24, 24, 24) or Color3.fromRGB(32, 32, 32),
                    Position = UDim2.new(0, 10, 0, yPosition),
                    BorderColor3 = Color3.new(),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, buttonWidth, 0, 26 * mobileScaleFactor),
                    Parent = groupObj.mainFrame
                })
                
                makeThingExist("UICorner", {
                    Name = "UICorner",
                    CornerRadius = UDim.new(0, 6),
                    Parent = buttonObj.mainFrame
                })
                
                local buttonStrokeThing = makeThingExist("UIStroke", {
                    Name = "UIStroke",
                    Color = buttonObj.isLocked and Color3.fromRGB(32, 32, 32) or Color3.fromRGB(48, 48, 48),
                    Parent = buttonObj.mainFrame
                })
                
                makeThingExist("UIGradient", {
                    Name = "UIGradient",
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(0.493, Color3.fromRGB(150, 150, 150)),
                        ColorSequenceKeypoint.new(0.509, Color3.fromRGB(150, 150, 150)),
                        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                    }),
                    Rotation = 260,
                    Parent = buttonStrokeThing
                })
                
                local textXPos = 8
                if buttonConfig.Icon then
                    makeThingExist("ImageLabel", {
                        Name = "ButtonIcon",
                        ImageColor3 = buttonObj.isLocked and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(125, 125, 125),
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Image = buttonConfig.Icon,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0.5, -8 * mobileScaleFactor),
                        BorderColor3 = Color3.new(),
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 16 * mobileScaleFactor, 0, 16 * mobileScaleFactor),
                        Parent = buttonObj.mainFrame
                    })
                    textXPos = 30
                end
                
                buttonObj.labelText = makeThingExist("TextLabel", {
                    Name = "ButtonLabel",
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextColor3 = buttonObj.isLocked and Color3.fromRGB(46, 46, 46) or Color3.fromRGB(120, 120, 120),
                    Text = buttonConfig.Name .. (buttonObj.isLocked and " (locked)" or ""),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, textXPos * mobileScaleFactor, 0, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.new(),
                    TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(1, -textXPos * mobileScaleFactor - 10, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = buttonObj.mainFrame
                })
                
                local buttonClickButton = makeThingExist("TextButton", {
                    Name = "ButtonClickButton",
                    Text = "",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = buttonObj.mainFrame
                })
                
                buttonClickButton.MouseButton1Click:Connect(function()
                    if not buttonObj.isLocked then
                        buttonConfig.Callback()
                    end
                end)
                
                buttonClickButton.MouseEnter:Connect(function()
                    if not buttonObj.isLocked then
                        smoothMoveGoWoosh(buttonObj.mainFrame, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
                    end
                end)
                
                buttonClickButton.MouseLeave:Connect(function()
                    if not buttonObj.isLocked then
                        smoothMoveGoWoosh(buttonObj.mainFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.2)
                    end
                end)
                
                groupObj.elementYPos = groupObj.elementYPos + 32 * mobileScaleFactor
                updateGroupSizeYay()
                
                table.insert(groupObj.elementsInGroup, buttonObj)
                return buttonObj
            end
            
            function groupObj:AddKeybind(keybindConfig)
                keybindConfig = keybindConfig or {}
                keybindConfig.Name = keybindConfig.Name or "Keybind"
                keybindConfig.Default = keybindConfig.Default or Enum.KeyCode.Unknown
                keybindConfig.Callback = keybindConfig.Callback or function() end
                keybindConfig.ChangedCallback = keybindConfig.ChangedCallback or function() end
                
                local keybindObj = {}
                keybindObj.value = keybindConfig.Default
                keybindObj.isListening = false
                
                local yPosition = groupObj.elementYPos
                
                keybindObj.labelText = makeThingExist("TextLabel", {
                    Name = "KeybindLabel",
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(124, 124, 124),
                    Text = keybindConfig.Name,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.new(),
                    TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(0, 120 * mobileScaleFactor, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = groupObj.mainFrame
                })
                
                local keyText = keybindObj.value == Enum.KeyCode.Unknown and "None" or keybindObj.value.Name
                local keyWidth = math.max(48 * mobileScaleFactor, howWideIsThisText(keyText, 12 * mobileScaleFactor) + 30 * mobileScaleFactor)
                
                keybindObj.buttonFrame = makeThingExist("Frame", {
                    Name = "KeybindButton",
                    BackgroundColor3 = Color3.fromRGB(32, 32, 32),
                    Position = UDim2.new(1, -keyWidth - 10, 0, yPosition),
                    BorderColor3 = Color3.new(),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, keyWidth, 0, 21 * mobileScaleFactor),
                    Parent = groupObj.mainFrame
                })
                
                makeThingExist("UICorner", {
                    Name = "UICorner",
                    CornerRadius = UDim.new(1, 0),
                    Parent = keybindObj.buttonFrame
                })
                
                local keybindStrokeThing = makeThingExist("UIStroke", {
                    Name = "UIStroke",
                    Color = Color3.fromRGB(40, 40, 40),
                    Parent = keybindObj.buttonFrame
                })
                
                keybindObj.keyLabelText = makeThingExist("TextLabel", {
                    Name = "KeyLabel",
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(113, 113, 113),
                    Text = keyText,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.new(),
                    TextSize = 12 * mobileScaleFactor,
                    Size = UDim2.new(1, -28 * mobileScaleFactor, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = keybindObj.buttonFrame
                })
                
                keybindObj.keyboardIconImg = makeThingExist("ImageLabel", {
                    Name = "KeyboardIcon",
                    ImageColor3 = Color3.fromRGB(76, 76, 76),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Image = "rbxassetid://10723416765",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -18 * mobileScaleFactor, 0.5, -7 * mobileScaleFactor),
                    BorderColor3 = Color3.new(),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 14 * mobileScaleFactor, 0, 14 * mobileScaleFactor),
                    Parent = keybindObj.buttonFrame
                })
                
                local keybindClickButton = makeThingExist("TextButton", {
                    Name = "KeybindClickButton",
                    Text = "",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = keybindObj.buttonFrame
                })
                
                local function updateKeybindSizeYay(text)
                    local newWidth = math.max(48 * mobileScaleFactor, howWideIsThisText(text, 12 * mobileScaleFactor) + 30 * mobileScaleFactor)
                    smoothMoveGoWoosh(keybindObj.buttonFrame, {
                        Size = UDim2.new(0, newWidth, 0, 21 * mobileScaleFactor),
                        Position = UDim2.new(1, -newWidth - 10, 0, yPosition)
                    }, 0.15)
                end
                
                function keybindObj:Set(key)
                    keybindObj.value = key
                    local keyText = key == Enum.KeyCode.Unknown and "None" or key.Name
                    keybindObj.keyLabelText.Text = keyText
                    updateKeybindSizeYay(keyText)
                    keybindConfig.ChangedCallback(key)
                end
                
                keybindClickButton.MouseButton1Click:Connect(function()
                    keybindObj.isListening = true
                    keybindObj.keyLabelText.Text = "..."
                    updateKeybindSizeYay("...")
                    smoothMoveGoWoosh(keybindObj.buttonFrame, {BackgroundColor3 = Color3.fromRGB(48, 48, 48)}, 0.2)
                    smoothMoveGoWoosh(keybindStrokeThing, {Color = Color3.fromRGB(83, 83, 83)}, 0.2)
                end)
                
                thisInputServiceGoesHard.InputBegan:Connect(function(input, gameProcessed)
                    if keybindObj.isListening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            keybindObj.isListening = false
                            keybindObj:Set(input.KeyCode)
                            smoothMoveGoWoosh(keybindObj.buttonFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.2)
                            smoothMoveGoWoosh(keybindStrokeThing, {Color = Color3.fromRGB(40, 40, 40)}, 0.2)
                        end
                    elseif not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == keybindObj.value then
                            keybindConfig.Callback()
                        end
                    end
                end)
                
                groupObj.elementYPos = groupObj.elementYPos + 28 * mobileScaleFactor
                updateGroupSizeYay()
                
                table.insert(groupObj.elementsInGroup, keybindObj)
                return keybindObj
            end
            
            function groupObj:AddDropdown(dropdownConfig)
                dropdownConfig = dropdownConfig or {}
                dropdownConfig.Name = dropdownConfig.Name or "Dropdown"
                dropdownConfig.Options = dropdownConfig.Options or {"Option 1", "Option 2", "Option 3"}
                dropdownConfig.Default = dropdownConfig.Default or dropdownConfig.Options[1]
                dropdownConfig.Callback = dropdownConfig.Callback or function() end
                
                local dropdownObj = {}
                dropdownObj.value = dropdownConfig.Default
                dropdownObj.isOpen = false
                
                local yPosition = groupObj.elementYPos
                
                dropdownObj.labelText = makeThingExist("TextLabel", {
                    Name = "DropdownLabel",
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(124, 124, 124),
                    Text = dropdownConfig.Name,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.new(),
                    TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(0, 100 * mobileScaleFactor, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = groupObj.mainFrame
                })
                
                local displayText = dropdownObj.value or "None"
                local buttonWidth = math.max(70 * mobileScaleFactor, howWideIsThisText(displayText, 12 * mobileScaleFactor) + 30 * mobileScaleFactor)
                
                dropdownObj.buttonFrame = makeThingExist("Frame", {
                    Name = "DropdownButton",
                    BackgroundColor3 = Color3.fromRGB(32, 32, 32),
                    Position = UDim2.new(1, -buttonWidth - 10, 0, yPosition),
                    BorderColor3 = Color3.new(),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, buttonWidth, 0, 21 * mobileScaleFactor),
                    Parent = groupObj.mainFrame
                })
                
                makeThingExist("UICorner", {
                    Name = "UICorner",
                    CornerRadius = UDim.new(1, 0),
                    Parent = dropdownObj.buttonFrame
                })
                
                local dropdownStrokeThing = makeThingExist("UIStroke", {
                    Name = "UIStroke",
                    Color = Color3.fromRGB(44, 44, 44),
                    Parent = dropdownObj.buttonFrame
                })
                
                dropdownObj.selectedLabelText = makeThingExist("TextLabel", {
                    Name = "SelectedLabel",
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(84, 84, 84),
                    Text = displayText,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.new(),
                    TextSize = 12 * mobileScaleFactor,
                    Size = UDim2.new(1, -28 * mobileScaleFactor, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = dropdownObj.buttonFrame
                })
                
                dropdownObj.arrowImg = makeThingExist("ImageLabel", {
                    Name = "DropdownArrow",
                    ImageColor3 = Color3.fromRGB(80, 80, 80),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Image = "rbxassetid://111626678408582",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20 * mobileScaleFactor, 0.5, -7 * mobileScaleFactor),
                    BorderColor3 = Color3.new(),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 14 * mobileScaleFactor, 0, 14 * mobileScaleFactor),
                    Parent = dropdownObj.buttonFrame
                })
                
                dropdownObj.optionHolderFrame = makeThingExist("Frame", {
                    Name = "DropdownOptionHolder",
                    BackgroundColor3 = Color3.fromRGB(16, 16, 16),
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderColor3 = Color3.new(),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 122 * mobileScaleFactor, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 9999,
                    Active = true,
                    Parent = groupObj.Library.dropdownHolderRef
                })
                
                makeThingExist("UICorner", {
                    Name = "UICorner",
                    CornerRadius = UDim.new(0, 6),
                    Parent = dropdownObj.optionHolderFrame
                })
                
                makeThingExist("UIStroke", {
                    Name = "UIStroke",
                    Color = Color3.fromRGB(40, 40, 40),
                    Parent = dropdownObj.optionHolderFrame
                })
                
                makeThingExist("TextLabel", {
                    Name = "DropdownTitle",
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextColor3 = Color3.new(1, 1, 1),
                    Text = dropdownConfig.Name,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 8 * mobileScaleFactor),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.new(),
                    TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(1, -24, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10000,
                    Parent = dropdownObj.optionHolderFrame
                })
                
                dropdownObj.optionContainerFrame = makeThingExist("Frame", {
                    Name = "OptionContainer",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 30 * mobileScaleFactor),
                    Size = UDim2.new(1, 0, 0, 0),
                    ZIndex = 10000,
                    Parent = dropdownObj.optionHolderFrame
                })
                
                local function createOptionsYay()
                    for _, child in pairs(dropdownObj.optionContainerFrame:GetChildren()) do
                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    local optY = 0
                    for _, option in ipairs(dropdownConfig.Options) do
                        local isSelected = dropdownObj.value == option
                        
                        local optionLabelText = makeThingExist("TextLabel", {
                            Name = isSelected and "SelectedOption" or "UnselectedOption",
                            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                            TextColor3 = isSelected and groupObj.Library.config.AccentColor or Color3.fromRGB(124, 124, 124),
                            Text = option,
                            BackgroundColor3 = Color3.new(1, 1, 1),
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 12, 0, optY),
                            BorderSizePixel = 0,
                            BorderColor3 = Color3.new(),
                            TextSize = 14 * mobileScaleFactor,
                            Size = UDim2.new(1, -24, 0, 18 * mobileScaleFactor),
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 10001,
                            Parent = dropdownObj.optionContainerFrame
                        })
                        
                        local optionClickButton = makeThingExist("TextButton", {
                            Name = "OptionClickButton",
                            Text = "",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 0, 0, optY),
                            Size = UDim2.new(1, 0, 0, 20 * mobileScaleFactor),
                            ZIndex = 10002,
                            Parent = dropdownObj.optionContainerFrame
                        })
                        
                        optionClickButton.MouseButton1Click:Connect(function()
                            dropdownObj.value = option
                            dropdownObj.isOpen = false
                            if groupObj.Library.__ddOpen then
                                groupObj.Library.__ddOpen[dropdownObj] = nil
                            end
                            smoothMoveGoWoosh(dropdownObj.optionHolderFrame, {Size = UDim2.new(0, 122 * mobileScaleFactor, 0, 0)}, 0.2)
                            smoothMoveGoWoosh(dropdownObj.arrowImg, {Rotation = 0}, 0.2)
                            task.delay(0.2, function()
                                if dropdownObj.optionHolderFrame and dropdownObj.optionHolderFrame.Parent then
                                    dropdownObj.optionHolderFrame.Visible = false
                                end
                            end)
                            
                            dropdownObj.selectedLabelText.Text = option
                            local newWidth = math.max(70 * mobileScaleFactor, howWideIsThisText(option, 12 * mobileScaleFactor) + 30 * mobileScaleFactor)
                            smoothMoveGoWoosh(dropdownObj.buttonFrame, {
                                Size = UDim2.new(0, newWidth, 0, 21 * mobileScaleFactor),
                                Position = UDim2.new(1, -newWidth - 10, 0, yPosition)
                            }, 0.15)
                            
                            createOptionsYay()
                            dropdownConfig.Callback(option)
                        end)
                        
                        optY = optY + 22 * mobileScaleFactor
                    end
                end
                
                createOptionsYay()
                
                local dropdownClickButton = makeThingExist("TextButton", {
                    Name = "DropdownClickButton",
                    Text = "",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = dropdownObj.buttonFrame
                })
                
                local function updateDropdownPositionYay()
                    local buttonAbsPos = dropdownObj.buttonFrame.AbsolutePosition
                    local buttonAbsSize = dropdownObj.buttonFrame.AbsoluteSize
                    dropdownObj.optionHolderFrame.Position = UDim2.new(0, buttonAbsPos.X, 0, buttonAbsPos.Y + buttonAbsSize.Y + 5)
                end
                
                local function closeThisDropdown()
                    dropdownObj.isOpen = false
                    if groupObj.Library.__ddOpen then
                        groupObj.Library.__ddOpen[dropdownObj] = nil
                    end
                    smoothMoveGoWoosh(dropdownObj.optionHolderFrame, {Size = UDim2.new(0, 122 * mobileScaleFactor, 0, 0)}, 0.2)
                    smoothMoveGoWoosh(dropdownObj.arrowImg, {Rotation = 0}, 0.2)
                    task.delay(0.2, function()
                        if not dropdownObj.isOpen and dropdownObj.optionHolderFrame and dropdownObj.optionHolderFrame.Parent then
                            dropdownObj.optionHolderFrame.Visible = false
                        end
                    end)
                end

                dropdownObj.__close = closeThisDropdown

                dropdownClickButton.MouseButton1Click:Connect(function()
                    if dropdownObj.isOpen then
                        closeThisDropdown()
                        return
                    end

                    groupObj.Library:CloseDropdowns()
                    dropdownObj.isOpen = true
                    if groupObj.Library.__ddOpen then
                        groupObj.Library.__ddOpen[dropdownObj] = closeThisDropdown
                    end
                    updateDropdownPositionYay()
                    dropdownObj.optionHolderFrame.Visible = true
                    local height = (35 + (#dropdownConfig.Options * 22)) * mobileScaleFactor
                    smoothMoveGoWoosh(dropdownObj.optionHolderFrame, {Size = UDim2.new(0, 122 * mobileScaleFactor, 0, height)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    smoothMoveGoWoosh(dropdownObj.arrowImg, {Rotation = 180}, 0.2)
                end)

                dropdownClickButton.MouseEnter:Connect(function()
                    smoothMoveGoWoosh(dropdownStrokeThing, {Color = groupObj.Library.config.AccentColor}, 0.15)
                end)
                dropdownClickButton.MouseLeave:Connect(function()
                    if not dropdownObj.isOpen then
                        smoothMoveGoWoosh(dropdownStrokeThing, {Color = Color3.fromRGB(44, 44, 44)}, 0.15)
                    end
                end)
                
                function dropdownObj:Set(value)
                    dropdownObj.value = value
                    dropdownObj.selectedLabelText.Text = tostring(value)
                    local newWidth = math.max(70 * mobileScaleFactor, howWideIsThisText(tostring(value), 12 * mobileScaleFactor) + 30 * mobileScaleFactor)
                    dropdownObj.buttonFrame.Size = UDim2.new(0, newWidth, 0, 21 * mobileScaleFactor)
                    dropdownObj.buttonFrame.Position = UDim2.new(1, -newWidth - 10, 0, yPosition)
                    createOptionsYay()
                    dropdownConfig.Callback(value)
                end

                function dropdownObj:SetOptions(newOptions)
                    dropdownConfig.Options = newOptions or {}
                    if dropdownObj.isOpen then
                        dropdownObj.isOpen = false
                        dropdownObj.optionHolderFrame.Visible = false
                        dropdownObj.optionHolderFrame.Size = UDim2.new(0, 122 * mobileScaleFactor, 0, 0)
                        dropdownObj.arrowImg.Rotation = 0
                    end
                    createOptionsYay()
                end
                
                groupObj.elementYPos = groupObj.elementYPos + 28 * mobileScaleFactor
                updateGroupSizeYay()
                
                table.insert(groupObj.elementsInGroup, dropdownObj)
                return dropdownObj
            end
            
            function groupObj:AddDivider()
                local yPosition = groupObj.elementYPos
                
                local dividerFrame = makeThingExist("Frame", {
                    Name = "DividerFrame",
                    BackgroundColor3 = Color3.fromRGB(36, 36, 36),
                    Position = UDim2.new(0, 10, 0, yPosition + 4 * mobileScaleFactor),
                    BorderColor3 = Color3.new(),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0.92, 0, 0, 1),
                    Parent = groupObj.mainFrame
                })
                
                makeThingExist("UIGradient", {
                    Name = "UIGradient",
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(108, 108, 108)),
                        ColorSequenceKeypoint.new(0.514, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(108, 108, 108))
                    }),
                    Parent = dividerFrame
                })
                
                groupObj.elementYPos = groupObj.elementYPos + 12 * mobileScaleFactor
                updateGroupSizeYay()
                
                return dividerFrame
            end
            
            function groupObj:AddLabel(labelConfig)
                labelConfig = labelConfig or {}
                labelConfig.Text = labelConfig.Text or "Label"
                
                local yPosition = groupObj.elementYPos
                
                local labelText = makeThingExist("TextLabel", {
                    Name = "LabelText",
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(124, 124, 124),
                    Text = labelConfig.Text,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.new(),
                    TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(0.92, 0, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = groupObj.mainFrame
                })
                
                groupObj.elementYPos = groupObj.elementYPos + 24 * mobileScaleFactor
                updateGroupSizeYay()
                
                return labelText
            end
            
            function groupObj:AddInput(inputConfig)
                inputConfig = inputConfig or {}
                inputConfig.Name = inputConfig.Name or "Input"
                inputConfig.Default = inputConfig.Default or ""
                inputConfig.Placeholder = inputConfig.Placeholder or ""
                inputConfig.Callback = inputConfig.Callback or function() end

                local inputObj = {}
                inputObj.value = tostring(inputConfig.Default)

                local yPosition = groupObj.elementYPos
                local boxWidth = 110 * mobileScaleFactor

                inputObj.labelText = makeThingExist("TextLabel", {
                    Name = "InputLabel",
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(124, 124, 124),
                    Text = inputConfig.Name,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition),
                    BorderSizePixel = 0,
                    TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(0, 110 * mobileScaleFactor, 0, 21 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = groupObj.mainFrame
                })

                inputObj.boxFrame = makeThingExist("Frame", {
                    Name = "InputBoxFrame",
                    BackgroundColor3 = Color3.fromRGB(32, 32, 32),
                    Position = UDim2.new(1, -boxWidth - 10, 0, yPosition),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, boxWidth, 0, 21 * mobileScaleFactor),
                    Parent = groupObj.mainFrame
                })

                makeThingExist("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = inputObj.boxFrame
                })

                local inputStroke = makeThingExist("UIStroke", {
                    Color = Color3.fromRGB(44, 44, 44),
                    Parent = inputObj.boxFrame
                })

                inputObj.textBox = makeThingExist("TextBox", {
                    Name = "InputTextBox",
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextColor3 = Color3.new(1, 1, 1),
                    PlaceholderText = inputConfig.Placeholder,
                    PlaceholderColor3 = Color3.fromRGB(84, 84, 84),
                    Text = inputObj.value,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    BorderSizePixel = 0,
                    TextSize = 12 * mobileScaleFactor,
                    Size = UDim2.new(1, -16, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = inputObj.boxFrame
                })

                local function commit(text)
                    text = tostring(text or "")
                    if inputConfig.Numeric then
                        text = text:gsub("[^%d%.%-]", "")
                    end
                    inputObj.value = text
                    if inputObj.textBox.Text ~= text then
                        inputObj.textBox.Text = text
                    end
                    inputConfig.Callback(text)
                end

                inputObj.textBox.Focused:Connect(function()
                    smoothMoveGoWoosh(inputStroke, {Color = groupObj.Library.config.AccentColor}, 0.15)
                end)
                inputObj.textBox.FocusLost:Connect(function()
                    smoothMoveGoWoosh(inputStroke, {Color = Color3.fromRGB(44, 44, 44)}, 0.15)
                    commit(inputObj.textBox.Text)
                end)
                if not inputConfig.Finished then
                    inputObj.textBox:GetPropertyChangedSignal("Text"):Connect(function()
                        if inputObj.textBox:IsFocused() then
                            inputObj.value = inputObj.textBox.Text
                        end
                    end)
                end

                function inputObj:Set(text)
                    commit(text)
                end

                groupObj.elementYPos = groupObj.elementYPos + 28 * mobileScaleFactor
                updateGroupSizeYay()

                table.insert(groupObj.elementsInGroup, inputObj)
                return inputObj
            end

            function groupObj:AddParagraph(paraConfig)
                paraConfig = paraConfig or {}
                local wrapWidth = groupWidth - 20

                local function measure(t)
                    local ok, size = pcall(function()
                        return textServiceBeLikeText:GetTextSize(tostring(t):gsub("<[^>]->", ""), 13 * mobileScaleFactor, Enum.Font.GothamSemibold, Vector2.new(wrapWidth, math.huge))
                    end)
                    if ok and size then
                        return math.max(size.Y + 6, 20 * mobileScaleFactor)
                    end
                    return 20 * mobileScaleFactor
                end

                local paraObj = {}
                local startY = groupObj.elementYPos
                local h = measure(paraConfig.Text or "")

                paraObj.height = h
                paraObj.labelText = makeThingExist("TextLabel", {
                    Name = "ParagraphText",
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(150, 150, 150),
                    Text = paraConfig.Text or "",
                    RichText = true,
                    TextWrapped = true,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, startY),
                    BorderSizePixel = 0,
                    TextSize = 13 * mobileScaleFactor,
                    Size = UDim2.new(0, wrapWidth, 0, h),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    Parent = groupObj.mainFrame
                })

                function paraObj:SetText(t)
                    paraObj.labelText.Text = tostring(t)
                    local nh = measure(t)
                    local delta = nh - paraObj.height
                    if delta ~= 0 then
                        local curY = paraObj.labelText.Position.Y.Offset
                        paraObj.height = nh
                        paraObj.labelText.Size = UDim2.new(0, wrapWidth, 0, nh)
                        for _, child in ipairs(groupObj.mainFrame:GetChildren()) do
                            if child ~= paraObj.labelText and child:IsA("GuiObject") then
                                local p = child.Position
                                if p.Y.Offset > curY then
                                    child.Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset + delta)
                                end
                            end
                        end
                        groupObj.elementYPos = groupObj.elementYPos + delta
                        updateGroupSizeYay()
                    end
                end

                groupObj.elementYPos = groupObj.elementYPos + h + 4 * mobileScaleFactor
                updateGroupSizeYay()

                table.insert(groupObj.elementsInGroup, paraObj)
                return paraObj
            end

            function groupObj:AddColor(colorConfig)
                colorConfig = colorConfig or {}
                colorConfig.Name = colorConfig.Name or "Color"
                colorConfig.Default = colorConfig.Default or Color3.new(1, 1, 1)
                colorConfig.Callback = colorConfig.Callback or function() end

                local colorObj = {}
                colorObj.value = colorConfig.Default

                local yPosition = groupObj.elementYPos
                local swatchSize = 21 * mobileScaleFactor
                local hexWidth = 74 * mobileScaleFactor

                colorObj.labelText = makeThingExist("TextLabel", {
                    Name = "ColorLabel",
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(124, 124, 124),
                    Text = colorConfig.Name,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition),
                    BorderSizePixel = 0,
                    TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(0, 110 * mobileScaleFactor, 0, swatchSize),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = groupObj.mainFrame
                })

                local hexFrame = makeThingExist("Frame", {
                    Name = "ColorHexFrame",
                    BackgroundColor3 = Color3.fromRGB(32, 32, 32),
                    Position = UDim2.new(1, -(hexWidth + swatchSize + 16), 0, yPosition),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, hexWidth, 0, swatchSize),
                    Parent = groupObj.mainFrame
                })

                makeThingExist("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = hexFrame
                })

                makeThingExist("UIStroke", {
                    Color = Color3.fromRGB(44, 44, 44),
                    Parent = hexFrame
                })

                local hexBox = makeThingExist("TextBox", {
                    Name = "ColorHexBox",
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextColor3 = Color3.new(1, 1, 1),
                    Text = "#" .. colorObj.value:ToHex(),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 6, 0, 0),
                    BorderSizePixel = 0,
                    TextSize = 12 * mobileScaleFactor,
                    Size = UDim2.new(1, -12, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    Parent = hexFrame
                })

                colorObj.swatchFrame = makeThingExist("Frame", {
                    Name = "ColorSwatch",
                    BackgroundColor3 = colorObj.value,
                    Position = UDim2.new(1, -(swatchSize + 10), 0, yPosition),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, swatchSize, 0, swatchSize),
                    Parent = groupObj.mainFrame
                })

                makeThingExist("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = colorObj.swatchFrame
                })

                makeThingExist("UIStroke", {
                    Color = Color3.fromRGB(44, 44, 44),
                    Parent = colorObj.swatchFrame
                })

                function colorObj:Set(col)
                    if typeof(col) ~= "Color3" then
                        return
                    end
                    colorObj.value = col
                    colorObj.swatchFrame.BackgroundColor3 = col
                    hexBox.Text = "#" .. col:ToHex()
                    colorConfig.Callback(col)
                end

                hexBox.FocusLost:Connect(function()
                    local raw = hexBox.Text:gsub("#", ""):gsub("%s", "")
                    local ok, col = pcall(Color3.fromHex, raw)
                    if ok and col then
                        colorObj:Set(col)
                    else
                        hexBox.Text = "#" .. colorObj.value:ToHex()
                    end
                end)

                groupObj.elementYPos = groupObj.elementYPos + 28 * mobileScaleFactor
                updateGroupSizeYay()

                table.insert(groupObj.elementsInGroup, colorObj)
                return colorObj
            end

            updateGroupSizeYay()
            tabObj.groupPositions[groupConfig.Side] = yPosStart + groupObj.mainFrame.Size.Y.Offset + 15 * mobileScaleFactor

            table.insert(tabObj.groupsInTab, groupObj)
            return groupObj
        end
        
        table.insert(sectionObj.tabsInSection, tabObj)
        table.insert(sectionObj.Library.tabsGoWoosh, tabObj)
        
        if #sectionObj.Library.tabsGoWoosh == 1 then
            tabObj:Activate()
        end
        
        task.defer(function()
            local tabsHeight = sectionObj.tabLayoutThing.AbsoluteContentSize.Y
            sectionObj.tabHolderFrame.Size = UDim2.new(1, -16, 0, tabsHeight)
            sectionObj.containerFrame.Size = UDim2.new(0, 154 * mobileScaleFactor, 0, 32 * mobileScaleFactor + tabsHeight + 12)
        end)
        
        return tabObj
    end
    
    table.insert(self.sectionsAreAwesome, sectionObj)
    return sectionObj
end

function superMegaAwesomeLibrary:SetAccentColor(color)
    self.config.AccentColor = color
end

function superMegaAwesomeLibrary:Destroy()
    if self.__titleAnimConn then
        pcall(function()
            self.__titleAnimConn:Disconnect()
        end)
        self.__titleAnimConn = nil
    end
    if self.screenGuiYay and self.screenGuiYay.Parent then
        self.screenGuiYay:Destroy()
    end
end

superMegaAwesomeLibrary.Toggles = {}
superMegaAwesomeLibrary.Options = {}
superMegaAwesomeLibrary.Scheme = {
    AccentColor = Color3.fromRGB(2, 133, 255),
    BackgroundColor = Color3.fromRGB(16, 16, 16),
    MainColor = Color3.fromRGB(18, 18, 18),
    OutlineColor = Color3.fromRGB(33, 33, 33),
    FontColor = Color3.new(1, 1, 1),
}

local activeUI

local tipFrame, tipLabel
local function tipEnsure()
    if tipFrame and tipFrame.Parent then
        return true
    end
    if not activeUI or not activeUI.screenGuiYay or not activeUI.screenGuiYay.Parent then
        return false
    end
    tipFrame = makeThingExist("Frame", {
        Name = "SharedTooltip",
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 100, 0, 24),
        Visible = false,
        ZIndex = 20000,
        Parent = activeUI.screenGuiYay
    })
    makeThingExist("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = tipFrame
    })
    makeThingExist("UIStroke", {
        Color = Color3.fromRGB(45, 45, 45),
        Parent = tipFrame
    })
    tipLabel = makeThingExist("TextLabel", {
        Name = "SharedTooltipText",
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        TextColor3 = Color3.fromRGB(210, 210, 210),
        Text = "",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 4),
        Size = UDim2.new(1, -16, 1, -8),
        TextSize = 12 * mobileScaleFactor,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 20001,
        Parent = tipFrame
    })
    return true
end

local function tipMove(x, y)
    if not tipFrame then
        return
    end
    local cam = workspace.CurrentCamera
    local vw = cam and cam.ViewportSize.X or 1920
    local vh = cam and cam.ViewportSize.Y or 1080
    local w = tipFrame.Size.X.Offset
    local h = tipFrame.Size.Y.Offset
    tipFrame.Position = UDim2.new(0, math.clamp(x + 16, 0, vw - w - 4), 0, math.clamp(y + 12, 0, vh - h - 4))
end

local function tipShow(text, x, y)
    if not tipEnsure() then
        return
    end
    local size = textServiceBeLikeText:GetTextSize(text, 12 * mobileScaleFactor, Enum.Font.GothamSemibold, Vector2.new(220 * mobileScaleFactor, math.huge))
    tipLabel.Text = text
    tipFrame.Size = UDim2.new(0, math.min(size.X, 220 * mobileScaleFactor) + 18, 0, size.Y + 10)
    tipFrame.Visible = true
    tipMove(x, y)
end

local function tipHide()
    if tipFrame then
        tipFrame.Visible = false
    end
end

local function tipAttach(inst, text)
    if not inst or type(text) ~= "string" or #text == 0 then
        return
    end
    pcall(function()
        inst.MouseEnter:Connect(function(x, y)
            tipShow(text, x, y)
        end)
        inst.MouseMoved:Connect(function(x, y)
            if tipFrame and tipFrame.Visible then
                tipMove(x, y)
            end
        end)
        inst.MouseLeave:Connect(tipHide)
    end)
end

function superMegaAwesomeLibrary:UpdateColorsUsingRegistry()
    if not activeUI then
        return
    end
    local scheme = superMegaAwesomeLibrary.Scheme
    local pairsToSwap = {
        { activeUI.config.AccentColor, scheme.AccentColor },
        { activeUI.config.BackgroundColor, scheme.BackgroundColor },
        { activeUI.config.SecondaryColor, scheme.MainColor },
    }
    activeUI.config.AccentColor = scheme.AccentColor
    activeUI.config.BackgroundColor = scheme.BackgroundColor
    activeUI.config.SecondaryColor = scheme.MainColor
    for _, swap in ipairs(pairsToSwap) do
        local old, new = swap[1], swap[2]
        if old and new and old ~= new then
            for _, d in ipairs(activeUI.screenGuiYay:GetDescendants()) do
                pcall(function()
                    if (d:IsA("Frame") or d:IsA("TextButton") or d:IsA("TextBox") or d:IsA("ScrollingFrame")) and d.BackgroundColor3 == old then
                        d.BackgroundColor3 = new
                    elseif d:IsA("TextLabel") then
                        if d.BackgroundColor3 == old then
                            d.BackgroundColor3 = new
                        end
                        if d.TextColor3 == old then
                            d.TextColor3 = new
                        end
                    elseif d:IsA("ImageLabel") and d.ImageColor3 == old then
                        d.ImageColor3 = new
                    elseif d:IsA("UIStroke") and d.Color == old then
                        d.Color = new
                    end
                end)
            end
        end
    end
end

local function wrapGroup(g, tabmeta)
    local Lib = superMegaAwesomeLibrary
    local w = {}

    local function sreg(label, inst)
        if activeUI and tabmeta and type(label) == "string" and #label > 0 then
            table.insert(activeUI.searchIndex, {
                label = label,
                tab = tabmeta.name,
                go = tabmeta.activate,
                inst = inst,
            })
        end
    end

    function w:AddToggle(idx, c)
        c = c or {}
        local entry = { Type = "Toggle", Value = c.Default and true or false }
        local fired = false
        local base = g:AddToggle({
            Name = c.Text or tostring(idx),
            Default = c.Default and true or false,
            Callback = function(v)
                entry.Value = v and true or false
                if c.Callback then
                    local ok, err = pcall(c.Callback, entry.Value)
                    if not ok then
                        warn("[ui] toggle callback error: " .. tostring(err))
                    end
                end
                fired = true
            end,
        })
        entry.__base = base
        function entry:SetValue(v)
            base:Set(v and true or false)
        end
        entry.Set = entry.SetValue
        if idx then
            Lib.Toggles[idx] = entry
        end
        tipAttach(base.labelText, c.Tooltip)
        tipAttach(base.switchFrame, c.Tooltip)
        sreg(c.Text or tostring(idx), base.labelText)
        return entry
    end

    function w:AddSlider(idx, c)
        c = c or {}
        local entry = { Type = "Slider", Value = c.Default or c.Min or 0 }
        local inc = 1
        if c.Rounding and c.Rounding > 0 then
            inc = 1 / (10 ^ c.Rounding)
        end
        local base = g:AddSlider({
            Name = c.Text or tostring(idx),
            Min = c.Min or 0,
            Max = c.Max or 100,
            Default = c.Default or c.Min or 0,
            Increment = inc,
            Callback = function(v)
                entry.Value = v
                if c.Callback then
                    local ok, err = pcall(c.Callback, v)
                    if not ok then
                        warn("[ui] slider callback error: " .. tostring(err))
                    end
                end
            end,
        })
        entry.__base = base
        function entry:SetValue(v)
            base:Set(tonumber(v) or 0)
        end
        entry.Set = entry.SetValue
        if idx then
            Lib.Options[idx] = entry
        end
        tipAttach(base.labelText, c.Tooltip)
        tipAttach(base.backgroundFrame, c.Tooltip)
        sreg(c.Text or tostring(idx), base.labelText)
        return entry
    end

    function w:AddDropdown(idx, c)
        c = c or {}
        local values = c.Values or {}
        local default = c.Default
        if type(default) == "number" then
            default = values[default]
        end
        default = default or values[1]
        local entry = { Type = "Dropdown", Value = default, Multi = c.Multi and true or false }
        local base = g:AddDropdown({
            Name = c.Text or tostring(idx),
            Options = values,
            Default = default,
            Callback = function(v)
                entry.Value = v
                if c.Callback then
                    local ok, err = pcall(c.Callback, v)
                    if not ok then
                        warn("[ui] dropdown callback error: " .. tostring(err))
                    end
                end
            end,
        })
        entry.__base = base
        function entry:SetValue(v)
            if type(v) == "table" then
                for key, on in pairs(v) do
                    if on then
                        v = key
                        break
                    end
                end
            end
            base:Set(v)
        end
        entry.Set = entry.SetValue
        function entry:SetValues(list)
            base:SetOptions(list or {})
        end
        if idx then
            Lib.Options[idx] = entry
        end
        tipAttach(base.labelText, c.Tooltip)
        tipAttach(base.buttonFrame, c.Tooltip)
        sreg(c.Text or tostring(idx), base.labelText)
        return entry
    end

    function w:AddInput(idx, c)
        c = c or {}
        local entry = { Type = "Input", Value = tostring(c.Default or "") }
        local base = g:AddInput({
            Name = c.Text or tostring(idx),
            Default = c.Default or "",
            Placeholder = c.Placeholder or "",
            Numeric = c.Numeric,
            Finished = c.Finished,
            Callback = function(v)
                entry.Value = v
                if c.Callback then
                    local ok, err = pcall(c.Callback, v)
                    if not ok then
                        warn("[ui] input callback error: " .. tostring(err))
                    end
                end
            end,
        })
        entry.__base = base
        function entry:SetValue(v)
            base:Set(tostring(v or ""))
        end
        entry.Set = entry.SetValue
        if idx then
            Lib.Options[idx] = entry
        end
        tipAttach(base.labelText, c.Tooltip)
        tipAttach(base.boxFrame, c.Tooltip)
        sreg(c.Text or tostring(idx), base.labelText)
        return entry
    end

    function w:AddButton(a, b)
        local text, func, tooltip
        if type(a) == "table" then
            text = a.Text or "Button"
            func = a.Func or a.Callback or function() end
            tooltip = a.Tooltip
        else
            text = tostring(a)
            func = b or function() end
        end
        local base = g:AddButton({
            Name = text,
            Callback = function()
                local ok, err = pcall(func)
                if not ok then
                    warn("[ui] button callback error: " .. tostring(err))
                end
            end,
        })
        tipAttach(base.mainFrame, tooltip)
        sreg(text, base.mainFrame)
        return base
    end

    function w:AddLabel(text, wrap)
        local para = g:AddParagraph({ Text = tostring(text or ""), Wrap = wrap and true or false })
        local obj = {}
        function obj:SetText(t)
            para:SetText(t)
        end
        function obj:AddColorPicker(idx, cc)
            cc = cc or {}
            local centry = { Type = "ColorPicker", Value = cc.Default or Color3.new(1, 1, 1), Transparency = 0 }
            local cbase = g:AddColor({
                Name = cc.Title or tostring(text),
                Default = centry.Value,
                Callback = function(col)
                    centry.Value = col
                    if cc.Callback then
                        pcall(cc.Callback, col)
                    end
                end,
            })
            centry.__base = cbase
            function centry:SetValueRGB(col)
                cbase:Set(col)
            end
            centry.SetValue = centry.SetValueRGB
            if idx then
                Lib.Options[idx] = centry
            end
            return obj
        end
        return obj
    end

    function w:AddDivider()
        return g:AddDivider()
    end

    function w:AddKeybind(idx, c)
        c = c or {}
        local entry = { Type = "KeyPicker", Value = c.Default or Enum.KeyCode.Unknown, Mode = c.Mode or "Press" }
        local base = g:AddKeybind({
            Name = c.Text or tostring(idx),
            Default = c.Default or Enum.KeyCode.Unknown,
            Callback = function()
                if c.Callback then
                    local ok, err = pcall(c.Callback)
                    if not ok then
                        warn("[ui] keybind callback error: " .. tostring(err))
                    end
                end
            end,
            ChangedCallback = function(key)
                entry.Value = key
                if c.ChangedCallback then
                    pcall(c.ChangedCallback, key)
                end
            end,
        })
        entry.__base = base
        function entry:SetValue(v)
            if typeof(v) == "EnumItem" then
                base:Set(v)
            end
        end
        entry.Set = entry.SetValue
        if idx then
            Lib.Options[idx] = entry
        end
        tipAttach(base.labelText, c.Tooltip)
        tipAttach(base.buttonFrame, c.Tooltip)
        sreg(c.Text or tostring(idx), base.labelText)
        return entry
    end

    w.__base = g
    return w
end

local baseNotify = superMegaAwesomeLibrary.Notify
function superMegaAwesomeLibrary:Notify(config)
    local target = self
    if type(self) ~= "table" or rawget(self, "notificationHolderFrame") == nil then
        target = activeUI
    end
    if not target then
        return
    end
    return baseNotify(target, config)
end

function superMegaAwesomeLibrary:CreateWindow(cfg)
    cfg = cfg or {}
    local key = cfg.ToggleKeybind
    if typeof(key) ~= "EnumItem" then
        key = Enum.KeyCode.RightControl
    end
    local ui = superMegaAwesomeLibrary.new({
        Name = cfg.Title or "menu",
        AccentColor = superMegaAwesomeLibrary.Scheme.AccentColor,
        BackgroundColor = superMegaAwesomeLibrary.Scheme.BackgroundColor,
        SecondaryColor = superMegaAwesomeLibrary.Scheme.MainColor,
        ToggleKey = key,
    })
    activeUI = ui
    tipEnsure()

    local section = ui:CreateSection({ Name = cfg.SectionName or "Menu" })
    local win = {}
    win.__ui = ui

    function win:AddTab(name, icon)
        local tab = section:AddTab({ Name = tostring(name), Description = cfg.Footer or "" })
        local tabmeta = {
            name = tostring(name),
            activate = function()
                tab:Activate()
            end,
        }
        local tw = {}
        tw.__base = tab
        function tw:AddLeftGroupbox(gname)
            return wrapGroup(tab:AddGroup({ Name = tostring(gname), Side = "Left" }), tabmeta)
        end
        function tw:AddRightGroupbox(gname)
            return wrapGroup(tab:AddGroup({ Name = tostring(gname), Side = "Right" }), tabmeta)
        end
        return tw
    end

    function win:Destroy()
        ui:Destroy()
    end

    function win:SetVisibility(v)
        if (v and not ui.isToggledOn) or (not v and ui.isToggledOn) then
            ui:ToggleUI()
        end
    end

    return win
end

return superMegaAwesomeLibrary
