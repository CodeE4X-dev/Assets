local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Theme = {
    Background = Color3.fromRGB(24, 24, 27),     
    TitleBar = Color3.fromRGB(39, 39, 42),       
    PrimaryBtn = Color3.fromRGB(59, 130, 246),   
    PrimaryHover = Color3.fromRGB(96, 165, 250), 
    SecondaryBtn = Color3.fromRGB(63, 63, 70),   
    SecondaryHover = Color3.fromRGB(82, 82, 91), 
    Danger = Color3.fromRGB(239, 68, 68),        
    TextWhite = Color3.fromRGB(250, 250, 250),
    TextGray = Color3.fromRGB(161, 161, 170)
}

local function checkToSConfirmed()
    local success = pcall(function()
        return readfile("cutie_confirm_tos.txt")
    end)
    return success
end

local function createToSFile()
    local success = pcall(function()
        writefile("cutie_confirm_tos.txt", "confirmed")
    end)
    return success
end

local function executeMain()
    local scriptSrc = [[
        loadstring(game:HttpGet("https://api.cutie.lt/Main"))()
    ]]
    local success, func = pcall(loadstring, scriptSrc)
    if success and func then
        pcall(func)
    end
end

local function showToSGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Cutie_ToS"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local gethui = gethui or function() return game:GetService("CoreGui") end
    local successParent = pcall(function() screenGui.Parent = gethui() end)
    if not successParent then
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 1 
    overlay.BorderSizePixel = 0
    overlay.Parent = screenGui

    local popup = Instance.new("CanvasGroup")
    popup.Name = "Popup"
    popup.Size = UDim2.new(0, 400, 0, 220)
    popup.Position = UDim2.new(0.5, -200, 0.55, -110) 
    popup.BackgroundColor3 = Theme.Background
    popup.BorderSizePixel = 0
    popup.GroupTransparency = 1 
    popup.Parent = screenGui

    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0, 10)
    popupCorner.Parent = popup

    local popupStroke = Instance.new("UIStroke")
    popupStroke.Color = Color3.fromRGB(60, 60, 65)
    popupStroke.Thickness = 1
    popupStroke.Parent = popup

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Theme.TitleBar
    titleBar.BorderSizePixel = 0
    titleBar.Parent = popup

    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, 10)
    titleBarCorner.Parent = titleBar
    
    local titleBarBottomFix = Instance.new("Frame")
    titleBarBottomFix.Size = UDim2.new(1, 0, 0, 10)
    titleBarBottomFix.Position = UDim2.new(0, 0, 1, -10)
    titleBarBottomFix.BackgroundColor3 = Theme.TitleBar
    titleBarBottomFix.BorderSizePixel = 0
    titleBarBottomFix.Parent = titleBar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Cutie - Terms of Service"
    title.TextColor3 = Theme.TextWhite
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local closeBtn = Instance.new("ImageButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -30, 0.5, -10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = "rbxassetid://10747383580"
    closeBtn.ImageColor3 = Theme.TextGray
    closeBtn.Parent = titleBar

    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(1, -40, 0, 30)
    message.Position = UDim2.new(0, 20, 0, 55)
    message.BackgroundTransparency = 1
    message.Text = "Before you continue, please review our Terms of Service."
    message.TextColor3 = Theme.TextWhite
    message.Font = Enum.Font.GothamMedium
    message.TextSize = 13
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.Parent = popup

    local linkBox = Instance.new("Frame")
    linkBox.Size = UDim2.new(1, -40, 0, 36)
    linkBox.Position = UDim2.new(0, 20, 0, 95)
    linkBox.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    linkBox.Parent = popup
    Instance.new("UICorner", linkBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", linkBox).Color = Color3.fromRGB(50, 50, 55)

    local linkText = Instance.new("TextLabel")
    linkText.Size = UDim2.new(1, -80, 1, 0)
    linkText.Position = UDim2.new(0, 12, 0, 0)
    linkText.BackgroundTransparency = 1
    linkText.Text = "https://api.cutie.lt/cutie-tos"
    linkText.TextColor3 = Theme.PrimaryHover
    linkText.Font = Enum.Font.Gotham
    linkText.TextSize = 12
    linkText.TextXAlignment = Enum.TextXAlignment.Left
    linkText.Parent = linkBox

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 60, 0, 24)
    copyBtn.Position = UDim2.new(1, -66, 0.5, -12)
    copyBtn.BackgroundColor3 = Theme.SecondaryBtn
    copyBtn.Text = "Copy"
    copyBtn.TextColor3 = Theme.TextWhite
    copyBtn.Font = Enum.Font.GothamMedium
    copyBtn.TextSize = 12
    copyBtn.Parent = linkBox
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 4)

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0, 100, 0, 36)
    cancelBtn.Position = UDim2.new(1, -250, 1, -50)
    cancelBtn.BackgroundColor3 = Theme.SecondaryBtn
    cancelBtn.Text = "Decline"
    cancelBtn.TextColor3 = Theme.TextWhite
    cancelBtn.Font = Enum.Font.GothamMedium
    cancelBtn.TextSize = 13
    cancelBtn.Parent = popup
    Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 6)

    local continueBtn = Instance.new("TextButton")
    continueBtn.Size = UDim2.new(0, 120, 0, 36)
    continueBtn.Position = UDim2.new(1, -140, 1, -50)
    continueBtn.BackgroundColor3 = Theme.PrimaryBtn
    continueBtn.Text = "I Agree"
    continueBtn.TextColor3 = Theme.TextWhite
    continueBtn.Font = Enum.Font.GothamBold
    continueBtn.TextSize = 13
    continueBtn.Parent = popup
    Instance.new("UICorner", continueBtn).CornerRadius = UDim.new(0, 6)

    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = popup.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            popup.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    local function addHover(btn, normalColor, hoverColor)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
        end)
    end

    addHover(continueBtn, Theme.PrimaryBtn, Theme.PrimaryHover)
    addHover(cancelBtn, Theme.SecondaryBtn, Theme.SecondaryHover)
    addHover(copyBtn, Theme.SecondaryBtn, Theme.SecondaryHover)

    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {ImageColor3 = Theme.Danger}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {ImageColor3 = Theme.TextGray}):Play()
    end)


    local function closeUI()
        TweenService:Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        local closeTween = TweenService:Create(popup, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            GroupTransparency = 1,
            Position = UDim2.new(0.5, -200, 0.55, -110) 
        })
        closeTween:Play()
        closeTween.Completed:Wait()
        screenGui:Destroy()
    end

    copyBtn.MouseButton1Click:Connect(function()
        local success = pcall(function() setclipboard("https://api.cutie.lt/cutie-tos") end)
        if success then
            local oldText = copyBtn.Text
            copyBtn.Text = "Copied!"
            copyBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94) -- Green
            task.wait(1.5)
            copyBtn.Text = oldText
            copyBtn.BackgroundColor3 = Theme.SecondaryBtn
        end
    end)

    continueBtn.MouseButton1Click:Connect(function()
        if createToSFile() then
            task.spawn(closeUI)
            executeMain()
        end
    end)

    cancelBtn.MouseButton1Click:Connect(closeUI)
    closeBtn.MouseButton1Click:Connect(closeUI)

    TweenService:Create(overlay, TweenInfo.new(0.4), {BackgroundTransparency = 0.5}):Play()
    TweenService:Create(popup, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        GroupTransparency = 0,
        Position = UDim2.new(0.5, -200, 0.5, -110) 
    }):Play()
end

if checkToSConfirmed() then
    executeMain()
else
    showToSGUI()
end
