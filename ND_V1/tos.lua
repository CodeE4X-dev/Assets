if _G.Iscx == true then return end
wait()
_G.Iscx = true
repeat wait() until game:IsLoaded()
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local CoreGui           = game:GetService("CoreGui")
local RunService        = game:GetService("RunService")

local TOS_URL     = "https://suyo.my.id/tos"
local MAIN_URL    = "https://suyo.my.id/main"
local TOS_FILE    = "nodex_confirm_tos.txt"

local function hasToSConfirmed()
    local ok, res = pcall(isfile, TOS_FILE)
    if not ok or not res then return false end
    local ok2, data = pcall(readfile, TOS_FILE)
    return ok2 and data ~= nil
end

local function writeToSConfirmed()
    local ok = pcall(writefile, TOS_FILE, "confirmed")
    return ok
end

local function executeMain()
    task.spawn(function()
        local ok, src = pcall(game.HttpGet, game, MAIN_URL)
        if not ok or not src then return end
        local fn, err = loadstring(src)
        if not fn then warn("[NodeX] loadstring failed:", err) return end
        pcall(fn)
    end)
end

if hasToSConfirmed() then
    executeMain()
    return
end

local COLOR = {
    bg          = Color3.fromRGB(18, 19, 24),
    panel       = Color3.fromRGB(26, 28, 36),
    panel2      = Color3.fromRGB(34, 37, 48),
    stroke      = Color3.fromRGB(52, 56, 72),
    strokeHi    = Color3.fromRGB(90, 100, 140),
    text        = Color3.fromRGB(240, 242, 250),
    subtext     = Color3.fromRGB(158, 164, 182),
    muted       = Color3.fromRGB(108, 114, 132),
    accent      = Color3.fromRGB(120, 145, 255),
    accentHi    = Color3.fromRGB(150, 170, 255),
    danger      = Color3.fromRGB(235, 85, 95),
    link        = Color3.fromRGB(130, 185, 255),
}

local function mk(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = o end
    return o
end

local function tween(inst, t, props, style, dir)
    local tw = TweenService:Create(inst, TweenInfo.new(
        t,
        style or Enum.EasingStyle.Quint,
        dir or Enum.EasingDirection.Out
    ), props)
    tw:Play()
    return tw
end

if CoreGui:FindFirstChild("NodeX_ToS") then
    CoreGui.NodeX_ToS:Destroy()
end

local screenGui = mk("ScreenGui", {
    Name = "NodeX_ToS",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 9999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local ok = pcall(function()
    screenGui.Parent = (gethui and gethui()) or CoreGui
end)
if not ok then
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local blur = mk("BlurEffect", {
    Name = "NodeX_ToS_Blur",
    Size = 0,
    Parent = Lighting,
})

local overlay = mk("Frame", {
    Name = "Overlay",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = screenGui,
})

local Root = mk("CanvasGroup", {
    Name = "Root",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(420, 280),
    BackgroundTransparency = 1,
    GroupTransparency = 1,
    Parent = screenGui,
})

local shadow = mk("ImageLabel", {
    Name = "Shadow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(1, 60, 1, 60),
    BackgroundTransparency = 1,
    Image = "rbxassetid://5028857084",
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 0.35,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24, 24, 276, 276),
    Parent = Root,
})

local popup = mk("Frame", {
    Name = "Popup",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLOR.bg,
    BorderSizePixel = 0,
    Parent = Root,
})
mk("UICorner", { CornerRadius = UDim.new(0, 12), Parent = popup })
mk("UIStroke", { Color = COLOR.stroke, Thickness = 1, Parent = popup })
mk("UIGradient", {
    Rotation = 135,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 28, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 19, 24)),
    }),
    Parent = popup,
})

local titleBar = mk("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundTransparency = 1,
    Active = true,
    Parent = popup,
})

local titleAccent = mk("Frame", {
    Size = UDim2.fromOffset(4, 16),
    Position = UDim2.new(0, 16, 0.5, -8),
    BackgroundColor3 = COLOR.accent,
    BorderSizePixel = 0,
    Parent = titleBar,
})
mk("UICorner", { CornerRadius = UDim.new(1, 0), Parent = titleAccent })

mk("TextLabel", {
    Text = "NodeX — Terms of Service",
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextColor3 = COLOR.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 28, 0, 0),
    Size = UDim2.new(1, -80, 1, 0),
    Parent = titleBar,
})

mk("Frame", {
    Size = UDim2.new(1, -32, 0, 1),
    Position = UDim2.new(0, 16, 1, 0),
    BackgroundColor3 = COLOR.stroke,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    Parent = titleBar,
})

local closeBtn = mk("TextButton", {
    Name = "Close",
    Text = "×",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = COLOR.subtext,
    BackgroundColor3 = COLOR.panel,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.new(1, -40, 0.5, -14),
    Parent = titleBar,
})
mk("UICorner", { CornerRadius = UDim.new(0, 6), Parent = closeBtn })

local content = mk("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -40, 1, -110),
    Position = UDim2.new(0, 20, 0, 54),
    BackgroundTransparency = 1,
    Parent = popup,
})

local message = mk("TextLabel", {
    Name = "Message",
    Text = "By clicking <b>Continue</b>, you agree to the vex.cc Terms of Service. Please review the link below before proceeding.",
    RichText = true,
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextColor3 = COLOR.subtext,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    LineHeight = 1.25,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 50),
    Parent = content,
})

local linkBox = mk("Frame", {
    Name = "LinkBox",
    Size = UDim2.new(1, 0, 0, 42),
    Position = UDim2.new(0, 0, 0, 60),
    BackgroundColor3 = COLOR.panel,
    BorderSizePixel = 0,
    Parent = content,
})
mk("UICorner", { CornerRadius = UDim.new(0, 8), Parent = linkBox })
local linkStroke = mk("UIStroke", { Color = COLOR.stroke, Thickness = 1, Parent = linkBox })

mk("TextLabel", {
    Text = "🔗",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = COLOR.muted,
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(24, 24),
    Position = UDim2.new(0, 10, 0.5, -12),
    Parent = linkBox,
})

local linkText = mk("TextLabel", {
    Name = "LinkText",
    Text = TOS_URL,
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextColor3 = COLOR.link,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -108, 1, 0),
    Position = UDim2.new(0, 38, 0, 0),
    Parent = linkBox,
})

local copyBtn = mk("TextButton", {
    Name = "Copy",
    Text = "Copy",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = COLOR.text,
    BackgroundColor3 = COLOR.panel2,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Size = UDim2.fromOffset(58, 28),
    Position = UDim2.new(1, -66, 0.5, -14),
    Parent = linkBox,
})
mk("UICorner", { CornerRadius = UDim.new(0, 6), Parent = copyBtn })
local copyStroke = mk("UIStroke", { Color = COLOR.stroke, Thickness = 1, Parent = copyBtn })

local footer = mk("Frame", {
    Name = "Footer",
    Size = UDim2.new(1, -40, 0, 40),
    Position = UDim2.new(0, 20, 1, -56),
    BackgroundTransparency = 1,
    Parent = popup,
})

local cancelBtn = mk("TextButton", {
    Name = "Cancel",
    Text = "Cancel",
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextColor3 = COLOR.text,
    BackgroundColor3 = COLOR.panel,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Size = UDim2.new(0.38, -6, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    Parent = footer,
})
mk("UICorner", { CornerRadius = UDim.new(0, 8), Parent = cancelBtn })
local cancelStroke = mk("UIStroke", { Color = COLOR.stroke, Thickness = 1, Parent = cancelBtn })

local continueBtn = mk("TextButton", {
    Name = "Continue",
    Text = "Continue",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundColor3 = COLOR.accent,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Size = UDim2.new(0.62, -6, 1, 0),
    Position = UDim2.new(0.38, 6, 0, 0),
    Parent = footer,
})
mk("UICorner", { CornerRadius = UDim.new(0, 8), Parent = continueBtn })
mk("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 165, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 125, 235)),
    }),
    Parent = continueBtn,
})

local loader = mk("Frame", {
    Name = "Loader",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLOR.bg,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Visible = false,
    Parent = popup,
})
mk("UICorner", { CornerRadius = UDim.new(0, 12), Parent = loader })

local spinner = mk("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, -18),
    Size = UDim2.fromOffset(36, 36),
    BackgroundTransparency = 1,
    Parent = loader,
})
local spinnerRing = mk("ImageLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Image = "rbxassetid://4965945816",
    ImageColor3 = COLOR.accent,
    ImageTransparency = 1,
    Parent = spinner,
})

local loaderText = mk("TextLabel", {
    Text = "Loading vex.cc...",
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextColor3 = COLOR.subtext,
    TextTransparency = 1,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0.5, 22),
    Parent = loader,
})

local dragging, dragStart, startPos = false
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Root.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        Root.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

local function hoverFill(btn, stroke, baseBg, hoverBg, baseStroke, hoverStroke)
    btn.MouseEnter:Connect(function()
        tween(btn, 0.15, { BackgroundColor3 = hoverBg })
        if stroke then tween(stroke, 0.15, { Color = hoverStroke }) end
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.15, { BackgroundColor3 = baseBg })
        if stroke then tween(stroke, 0.15, { Color = baseStroke }) end
    end)
end

hoverFill(cancelBtn, cancelStroke, COLOR.panel, COLOR.panel2, COLOR.stroke, COLOR.strokeHi)
hoverFill(copyBtn, copyStroke, COLOR.panel2, COLOR.stroke, COLOR.stroke, COLOR.strokeHi)

continueBtn.MouseEnter:Connect(function()
    tween(continueBtn, 0.15, { BackgroundColor3 = COLOR.accentHi })
end)
continueBtn.MouseLeave:Connect(function()
    tween(continueBtn, 0.15, { BackgroundColor3 = COLOR.accent })
end)

closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, 0.15, { BackgroundTransparency = 0, TextColor3 = COLOR.text })
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, 0.15, { BackgroundTransparency = 1, TextColor3 = COLOR.subtext })
end)

local function pressAnim(btn)
    btn.MouseButton1Down:Connect(function()
        tween(btn, 0.08, { Size = btn.Size - UDim2.fromOffset(0, 2) })
    end)
    btn.MouseButton1Up:Connect(function()
        tween(btn, 0.12, { Size = btn.Size + UDim2.fromOffset(0, 2) })
    end)
end
pressAnim(continueBtn)
pressAnim(cancelBtn)
pressAnim(copyBtn)

linkBox.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        tween(linkStroke, 0.15, { Color = COLOR.strokeHi })
    end
end)
linkBox.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        tween(linkStroke, 0.15, { Color = COLOR.stroke })
    end
end)

local closed = false

local function fadeIn()
    tween(overlay, 0.25, { BackgroundTransparency = 0.45 })
    tween(blur, 0.35, { Size = 14 })
    Root.Size = UDim2.fromOffset(420, 280) - UDim2.fromOffset(30, 20)
    tween(Root, 0.35, {
        GroupTransparency = 0,
        Size = UDim2.fromOffset(420, 280),
    }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function closeAll(callback)
    if closed then return end
    closed = true
    tween(overlay, 0.2, { BackgroundTransparency = 1 })
    tween(blur, 0.25, { Size = 0 })
    tween(Root, 0.22, {
        GroupTransparency = 1,
        Size = UDim2.fromOffset(420, 280) - UDim2.fromOffset(30, 20),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    task.delay(0.25, function()
        if blur then blur:Destroy() end
        if screenGui then screenGui:Destroy() end
        if callback then callback() end
    end)
end

local function showLoader()
    loader.Visible = true
    tween(loader, 0.2, { BackgroundTransparency = 0.05 })
    tween(spinnerRing, 0.2, { ImageTransparency = 0 })
    tween(loaderText, 0.2, { TextTransparency = 0 })

    local spinConn
    spinConn = RunService.RenderStepped:Connect(function(dt)
        if not spinner.Parent then
            spinConn:Disconnect()
            return
        end
        spinnerRing.Rotation = (spinnerRing.Rotation + dt * 360) % 360
    end)

    local dots, i = { ".", "..", "..." }, 1
    task.spawn(function()
        while loader and loader.Parent and not closed do
            loaderText.Text = "Loading vex.cc" .. dots[i]
            i = i % 3 + 1
            task.wait(0.35)
        end
    end)
end

copyBtn.MouseButton1Click:Connect(function()
    pcall(setclipboard, TOS_URL)
    local prev = copyBtn.Text
    copyBtn.Text = "Copied"
    tween(copyBtn, 0.15, { BackgroundColor3 = COLOR.accent })
    task.delay(1.2, function()
        if copyBtn and copyBtn.Parent then
            copyBtn.Text = prev
            tween(copyBtn, 0.15, { BackgroundColor3 = COLOR.panel2 })
        end
    end)
end)

local function onCancel()
    closeAll()
end

local function onContinue()
    if closed then return end
    if not writeToSConfirmed() then return end

    showLoader()
    task.wait(0.6)
    closeAll(function()
        executeMain()
    end)
end

continueBtn.MouseButton1Click:Connect(onContinue)
cancelBtn.MouseButton1Click:Connect(onCancel)
closeBtn.MouseButton1Click:Connect(onCancel)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or closed then return end
    if input.KeyCode == Enum.KeyCode.Escape then
        onCancel()
    elseif input.KeyCode == Enum.KeyCode.Return then
        onContinue()
    end
end)

fadeIn()
