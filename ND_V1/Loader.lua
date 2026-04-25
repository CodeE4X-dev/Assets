if _G.v == true then
    return
end

wait()

_G.v = true

repeat
    wait()
until game:IsLoaded()

local Players = game:GetService('Players')
local HttpService = game:GetService('HttpService')
local TweenService = game:GetService('TweenService')
local Lighting = game:GetService('Lighting')
local CoreGui = game:GetService('CoreGui')
local RunService = game:GetService('RunService')
local SERVER_HTTP = 'http://194.13.80.145:8989'
local SERVER_WS = 'ws://194.13.80.145:8989/client-ws'
local plr = Players.LocalPlayer

local requestFn = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request) or (krnl and krnl.request)

local function logInfo(msg) print('[NodeX] \u{25C6} INFO  | ' .. tostring(msg)) end
local function logOk(msg)   print('[NodeX] \u{2714} OK    | ' .. tostring(msg)) end
local function logTry(msg)  print('[NodeX] \u{27F3} TRY   | ' .. tostring(msg)) end
local function logWarn(msg) warn ('[NodeX] \u{26A0} WARN  | ' .. tostring(msg)) end
local function logErr(msg)  warn ('[NodeX] \u{2716} ERROR | ' .. tostring(msg)) end

local function _shortBody(s, n)
    s = tostring(s or '')
    s = s:gsub('[\r\n\t]', ' ')
    if #s <= n then return s end
    return s:sub(1, n) .. '...'
end

local function httpGetRaw(url)
    if requestFn then
        local ok, res = pcall(requestFn, {
            Url = url,
            Method = 'GET',
            Headers = { Accept = 'application/json' },
        })
        if not ok then return 0, nil, tostring(res) end
        if type(res) ~= 'table' then return 0, nil, 'invalid response' end
        local code = res.StatusCode or res.status_code or res.Status or 0
        local body = res.Body or res.body or ''
        return tonumber(code) or 0, body, nil
    end
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if not ok then return 0, nil, tostring(body) end
    return 200, body, nil
end

local function httpGetJsonRetry(url, label, maxAttempts, onAttempt)
    maxAttempts = maxAttempts or 3
    local lastErr
    for attempt = 1, maxAttempts do
        if onAttempt then onAttempt(attempt, maxAttempts, lastErr) end
        logTry(string.format('%s attempt %d/%d -> %s', label or 'GET', attempt, maxAttempts, url))
        local code, body, err = httpGetRaw(url)
        if (code == 200 or code == 0 and body) and body and body ~= '' then
            local okDec, data = pcall(HttpService.JSONDecode, HttpService, body)
            if okDec then
                logOk(string.format('%s success on attempt %d (HTTP %s)', label or 'GET', attempt, tostring(code)))
                return data, attempt, nil
            else
                lastErr = string.format('JSON decode error: %s | body: %s', tostring(data), _shortBody(body, 80))
                logErr(string.format('%s attempt %d/%d - %s', label or 'GET', attempt, maxAttempts, lastErr))
            end
        else
            lastErr = string.format('HTTP %s | err: %s | body: %s', tostring(code), tostring(err or 'nil'), _shortBody(body or '', 80))
            logErr(string.format('%s attempt %d/%d failed - %s', label or 'GET', attempt, maxAttempts, lastErr))
        end
        if attempt < maxAttempts then task.wait(2) end
    end
    return nil, maxAttempts, lastErr
end

local function httpGetTextRetry(url, label, maxAttempts, onAttempt)
    maxAttempts = maxAttempts or 3
    local lastErr, lastCode
    for attempt = 1, maxAttempts do
        if onAttempt then onAttempt(attempt, maxAttempts, lastErr) end
        logTry(string.format('%s attempt %d/%d -> %s', label or 'GET', attempt, maxAttempts, url))
        local code, body, err = httpGetRaw(url)
        lastCode = code
        if (code == 200 or (code == 0 and body)) and body and body ~= '' then
            logOk(string.format('%s fetched on attempt %d (HTTP %s, %d bytes)', label or 'GET', attempt, tostring(code), #body))
            return body, attempt, nil, code
        end
        lastErr = string.format('HTTP %s | err: %s | body: %s', tostring(code), tostring(err or 'nil'), _shortBody(body or '', 80))
        logErr(string.format('%s attempt %d/%d failed - %s', label or 'GET', attempt, maxAttempts, lastErr))
        if attempt < maxAttempts then task.wait(2) end
    end
    return nil, maxAttempts, lastErr, lastCode
end

local function httpPostJson(url, payload)
    if not requestFn then
        return nil, 'no request fn'
    end

    local body = HttpService:JSONEncode(payload or {})
    local ok, res = pcall(requestFn, {
        Url = url,
        Method = 'POST',
        Headers = {
            ['Content-Type'] = 'application/json',
            Accept = 'application/json',
        },
        Body = body,
    })

    if not ok then
        return nil, tostring(res)
    end

    return res
end

logInfo('Booting from ' .. SERVER_HTTP)
local config, cfgAttempts, cfgErr = httpGetJsonRetry(SERVER_HTTP .. '/api/config', 'config', 3)

if not config then
    logErr(string.format('Failed to fetch config after %d attempts: %s', cfgAttempts or 3, tostring(cfgErr)))
    warn('[NodeX] Failed to fetch config from ' .. SERVER_HTTP .. ' - ' .. tostring(cfgErr))
    return
end
logOk(string.format('Config loaded (took %d attempt%s)', cfgAttempts or 1, (cfgAttempts or 1) == 1 and '' or 's'))

local loaders = config.loaders or {}
local loaderDelay = tonumber(config.loaderDelay) or 10
local totalSteps = math.max(#loaders, 1)

local function detectHwid()
    local hwid
    local ok = pcall(function()
        if gethwid then
            hwid = tostring(gethwid())
        end
    end)

    if ok and hwid and hwid ~= '' then
        return hwid
    end

    local ok2 = pcall(function()
        local rs = game:GetService('RbxAnalyticsService')

        hwid = tostring(rs:GetClientId())
    end)

    if ok2 and hwid and hwid ~= '' then
        return hwid
    end

    local ok3 = pcall(function()
        hwid = tostring((syn and syn.get_hwid and syn.get_hwid()) or 'unknown')
    end)

    if ok3 and hwid and hwid ~= '' then
        return hwid
    end

    return 'unknown'
end
local function detectExecutor()
    local ok, name = pcall(function()
        if identifyexecutor then
            local n = identifyexecutor()

            if type(n) == 'string' then
                return n
            end
        end
        if getexecutorname then
            local n = getexecutorname()

            if type(n) == 'string' then
                return n
            end
        end

        return 'unknown'
    end)

    if ok and name then
        return name
    end

    return 'unknown'
end

local HWID = detectHwid()
local EXECUTOR = detectExecutor()

local addErrorUi
local errorReportSent = 0
local ERROR_REPORT_LIMIT = 20

local function looksLikeHtml(body)
    if type(body) ~= 'string' or #body == 0 then return false end
    local trimmed = body:match('^%s*(.-)%s*$') or ''
    if #trimmed == 0 then return false end
    if string.sub(trimmed, 1, 1) == '<' then return true end
    local lower = string.lower(string.sub(trimmed, 1, 200))
    if string.find(lower, '<!doctype', 1, true) or string.find(lower, '<html', 1, true) then return true end
    return false
end

local function reportError(stage, detail, urlStr, httpCode, bodyPreview, moduleIdx, moduleTotal)
    pcall(function()
        if addErrorUi then
            addErrorUi(stage, detail, urlStr, httpCode)
        end
    end)
    if errorReportSent >= ERROR_REPORT_LIMIT then return end
    errorReportSent = errorReportSent + 1
    task.spawn(function()
        local payload = {
            stage = tostring(stage or 'unknown'),
            detail = tostring(detail or ''),
            url = tostring(urlStr or ''),
            httpCode = tonumber(httpCode) or 0,
            bodyPreview = _shortBody(bodyPreview or '', 500),
            moduleIndex = tonumber(moduleIdx) or 0,
            moduleTotal = tonumber(moduleTotal) or 0,
            user = plr and plr.Name or '',
            userid = plr and plr.UserId or 0,
            hwid = HWID,
            place = tostring(game.PlaceId),
            job = tostring(game.JobId),
            executor = EXECUTOR,
            ts = os.time(),
        }
        pcall(function()
            httpPostJson(SERVER_HTTP .. '/api/error-report', payload)
        end)
    end)
end

local COLOR = {
    bg = Color3.fromRGB(8, 10, 16),
    bgDeep = Color3.fromRGB(3, 4, 8),
    panel = Color3.fromRGB(20, 22, 32),
    panel2 = Color3.fromRGB(30, 33, 46),
    stroke = Color3.fromRGB(48, 52, 70),
    strokeHi = Color3.fromRGB(86, 96, 138),
    text = Color3.fromRGB(244, 246, 252),
    sub = Color3.fromRGB(172, 178, 196),
    muted = Color3.fromRGB(108, 114, 134),
    dim = Color3.fromRGB(72, 78, 96),
    accent = Color3.fromRGB(120, 145, 255),
    accentHi = Color3.fromRGB(170, 195, 255),
    accentSoft = Color3.fromRGB(40, 48, 96),
    purple = Color3.fromRGB(180, 140, 255),
    cyan = Color3.fromRGB(120, 200, 255),
    pink = Color3.fromRGB(240, 140, 220),
    success = Color3.fromRGB(110, 220, 160),
    warn = Color3.fromRGB(240, 200, 120),
    danger = Color3.fromRGB(240, 120, 130),
    star = Color3.fromRGB(255, 205, 90),
    starHi = Color3.fromRGB(255, 225, 140),
    starDim = Color3.fromRGB(70, 74, 92),
    glass = Color3.fromRGB(200, 210, 255),
    glassTint = Color3.fromRGB(42, 50, 90),
}

local function mk(class, props, children)
    local o = Instance.new(class)

    for k, v in pairs(props or {})do
        o[k] = v
    end
    for _, c in ipairs(children or {})do
        c.Parent = o
    end

    return o
end
local function tween(inst, t, props, style, dir)
    local tw = TweenService:Create(inst, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)

    tw:Play()

    return tw
end
local function lerp(a, b, t)
    return a + (b - a) * t
end
local function clamp(v, lo, hi)
    if v < lo then
        return lo
    end
    if v > hi then
        return hi
    end

    return v
end
local function lerpColor(a, b, t)
    return Color3.new(lerp(a.R, b.R, t), lerp(a.G, b.G, t), lerp(a.B, b.B, t))
end
local function randf(a, b)
    return a + math.random() * (b - a)
end
local function shortStr(s, n)
    s = tostring(s or '')

    if #s <= n then
        return s
    end

    return s:sub(1, n - 1) .. '\u{2026}'
end

pcall(function()
    local hui = (gethui and gethui()) or CoreGui

    for _, child in ipairs(hui:GetChildren())do
        if child.Name == 'NodeX_Loader' or child.Name == 'NodeX_Changelog' then
            child:Destroy()
        end
    end
end)

for _, e in ipairs(Lighting:GetChildren())do
    if e.Name == 'NodeX_LoaderBlur' then
        e:Destroy()
    end
end

local screenGui = mk('ScreenGui', {
    Name = 'NodeX_Loader',
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 9999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local okParent = pcall(function()
    screenGui.Parent = (gethui and gethui()) or CoreGui
end)

if not okParent then
    screenGui.Parent = plr:WaitForChild('PlayerGui')
end

local blur = mk('BlurEffect', {
    Name = 'NodeX_LoaderBlur',
    Size = 0,
    Parent = Lighting,
})
local dim = mk('Frame', {
    Name = 'Dim',
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = screenGui,
})

mk('UIGradient', {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 12, 20)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(4, 6, 12)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 3, 6)),
    }),
    Parent = dim,
})

local gridLayer = mk('Frame', {
    Name = 'Grid',
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = screenGui,
})

local function addGridLine(isVertical, scale)
    local line = mk('Frame', {
        BackgroundColor3 = COLOR.strokeHi,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = gridLayer,
    })

    if isVertical then
        line.Size = UDim2.new(0, 1, 1, 0)
        line.Position = UDim2.new(scale, 0, 0, 0)
    else
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, scale, 0)
    end

    return line
end

local gridLines = {
    addGridLine(true, 0.1),
    addGridLine(true, 0.25),
    addGridLine(true, 0.75),
    addGridLine(true, 0.9),
    addGridLine(false, 0.18),
    addGridLine(false, 0.82),
}
local centerGlow = mk('Frame', {
    Name = 'CenterGlow',
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.48),
    Size = UDim2.fromOffset(820, 820),
    BackgroundColor3 = COLOR.accent,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = screenGui,
})

mk('UICorner', {
    CornerRadius = UDim.new(1, 0),
    Parent = centerGlow,
})
mk('UIGradient', {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 165, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 80, 160)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.35, 0.92),
        NumberSequenceKeypoint.new(1, 1),
    }),
    Parent = centerGlow,
})

local particleLayer = mk('Frame', {
    Name = 'Particles',
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = screenGui,
})
local particles = {}
local PARTICLE_COUNT = 52

local function spawnParticle(i)
    local size = math.random(2, 5)
    local tone

    if i % 4 == 0 then
        tone = COLOR.purple
    elseif i % 4 == 1 then
        tone = COLOR.accent
    elseif i % 4 == 2 then
        tone = COLOR.cyan
    else
        tone = COLOR.pink
    end

    local p = mk('Frame', {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(size, size),
        Position = UDim2.fromScale(math.random(), math.random()),
        BackgroundColor3 = tone,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = particleLayer,
    })

    mk('UICorner', {
        CornerRadius = UDim.new(1, 0),
        Parent = p,
    })

    particles[i] = {
        inst = p,
        speed = randf(0.012, 0.04),
        drift = randf(-6E-3, 0.006),
        baseT = randf(0.55, 0.85),
        phase = randf(0, math.pi * 2),
    }
end

for i = 1, PARTICLE_COUNT do
    spawnParticle(i)
end

local function cornerAccent(ax, ay, posX, posY)
    local c = mk('Frame', {
        AnchorPoint = Vector2.new(ax, ay),
        Position = UDim2.new(posX, ax == 0 and 28 or -28, posY, ay == 0 and 28 or -28),
        Size = UDim2.fromOffset(60, 60),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = screenGui,
    })

    mk('Frame', {
        BackgroundColor3 = COLOR.accent,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, ay, ay == 0 and 0 or -2),
        Parent = c,
    })
    mk('Frame', {
        BackgroundColor3 = COLOR.accent,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 2, 1, 0),
        Position = UDim2.new(ax, ax == 0 and 0 or -2, 0, 0),
        Parent = c,
    })

    return c
end

local tl = cornerAccent(0, 0, 0, 0)
local tr = cornerAccent(1, 0, 1, 0)
local bl = cornerAccent(0, 1, 0, 1)
local br = cornerAccent(1, 1, 1, 1)
local CENTER_W, CENTER_H = 520, 420
local FB_W_PRE, FB_H_PRE = 290, 420
local FB_GAP_PRE = 26
local HOLDER_W = CENTER_W + FB_GAP_PRE + FB_W_PRE
local HOLDER_H = math.max(CENTER_H, FB_H_PRE)

local mainHolder = mk('Frame', {
    Name = 'MainHolder',
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(HOLDER_W, HOLDER_H),
    BackgroundTransparency = 1,
    Parent = screenGui,
})
local mainScale = mk('UIScale', { Scale = 1, Parent = mainHolder })

local function fitMainToScreen()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local pad = 16
    local s = math.min((vp.X - pad) / HOLDER_W, (vp.Y - pad) / HOLDER_H, 1)
    if s < 0.22 then s = 0.22 end
    mainScale.Scale = s
end
fitMainToScreen()
do
    local cam = workspace.CurrentCamera
    if cam then cam:GetPropertyChangedSignal('ViewportSize'):Connect(fitMainToScreen) end
end
workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
    local c = workspace.CurrentCamera
    if c then
        c:GetPropertyChangedSignal('ViewportSize'):Connect(fitMainToScreen)
        fitMainToScreen()
    end
end)

local center = mk('CanvasGroup', {
    Name = 'Center',
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 0, 0.5, 0),
    Size = UDim2.fromOffset(CENTER_W, CENTER_H),
    BackgroundTransparency = 1,
    GroupTransparency = 1,
    Parent = mainHolder,
})
local logoHolder = mk('Frame', {
    Name = 'LogoHolder',
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 10),
    Size = UDim2.fromOffset(120, 120),
    BackgroundTransparency = 1,
    Parent = center,
})
local ring1 = mk('Frame', {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(118, 118),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = logoHolder,
})

mk('UICorner', {
    CornerRadius = UDim.new(1, 0),
    Parent = ring1,
})

local ring1Stroke = mk('UIStroke', {
    Color = COLOR.accent,
    Thickness = 2,
    Transparency = 0.45,
    Parent = ring1,
})

mk('UIGradient', {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLOR.accent),
        ColorSequenceKeypoint.new(0.5, COLOR.purple),
        ColorSequenceKeypoint.new(1, COLOR.cyan),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.35, 0),
        NumberSequenceKeypoint.new(0.55, 1),
        NumberSequenceKeypoint.new(1, 1),
    }),
    Parent = ring1Stroke,
})

local ring2 = mk('Frame', {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(92, 92),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = logoHolder,
})

mk('UICorner', {
    CornerRadius = UDim.new(1, 0),
    Parent = ring2,
})

local ring2Stroke = mk('UIStroke', {
    Color = COLOR.purple,
    Thickness = 1,
    Transparency = 0.6,
    Parent = ring2,
})

mk('UIGradient', {
    Rotation = -120,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLOR.purple),
        ColorSequenceKeypoint.new(1, COLOR.accent),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.25, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(0.75, 1),
        NumberSequenceKeypoint.new(1, 1),
    }),
    Parent = ring2Stroke,
})

local orbit = mk('Frame', {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(118, 118),
    BackgroundTransparency = 1,
    Parent = logoHolder,
})
local orbitDots = {}

for i = 1, 3 do
    local angle = (i - 1) * 120
    local holder = mk('Frame', {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Rotation = angle,
        Parent = orbit,
    })
    local dot = mk('Frame', {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = (i == 1) and COLOR.accent or (i == 2) and COLOR.purple or COLOR.cyan,
        BorderSizePixel = 0,
        Parent = holder,
    })

    mk('UICorner', {
        CornerRadius = UDim.new(1, 0),
        Parent = dot,
    })
    mk('UIStroke', {
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        Transparency = 0.7,
        Parent = dot,
    })

    orbitDots[i] = dot
end

local pulse = mk('Frame', {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(78, 78),
    BackgroundColor3 = COLOR.accentSoft,
    BorderSizePixel = 0,
    Parent = logoHolder,
})

mk('UICorner', {
    CornerRadius = UDim.new(1, 0),
    Parent = pulse,
})

local pulseStroke = mk('UIStroke', {
    Color = COLOR.accent,
    Thickness = 1,
    Transparency = 0.35,
    Parent = pulse,
})

mk('UIGradient', {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 60, 130)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 34, 80)),
    }),
    Parent = pulse,
})

local brandLetter = mk('TextLabel', {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(80, 80),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 42,
    TextColor3 = COLOR.text,
    Text = 'N',
    Parent = logoHolder,
})

mk('UIStroke', {
    Color = COLOR.accentHi,
    Thickness = 1,
    Transparency = 0.6,
    Parent = brandLetter,
})

local titleLabel = mk('TextLabel', {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 148),
    Size = UDim2.new(1, -40, 0, 34),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 28,
    TextColor3 = COLOR.text,
    Text = 'NodeX',
    TextTransparency = 1,
    Parent = center,
})

mk('UIStroke', {
    Color = COLOR.accent,
    Thickness = 1,
    Transparency = 0.85,
    Parent = titleLabel,
})

local titleBadge = mk('Frame', {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 184),
    Size = UDim2.fromOffset(120, 20),
    BackgroundColor3 = COLOR.accentSoft,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = center,
})

mk('UICorner', {
    CornerRadius = UDim.new(1, 0),
    Parent = titleBadge,
})

local titleBadgeStroke = mk('UIStroke', {
    Color = COLOR.accent,
    Thickness = 1,
    Transparency = 1,
    Parent = titleBadge,
})
local titleBadgeText = mk('TextLabel', {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = COLOR.accentHi,
    TextTransparency = 1,
    Text = 'INITIALIZING',
    Parent = titleBadge,
})
local statusLabel = mk('TextLabel', {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 216),
    Size = UDim2.new(1, -60, 0, 22),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextColor3 = COLOR.sub,
    TextTransparency = 1,
    Text = 'Preparing environment\u{2026}',
    Parent = center,
})
local BAR_W, BAR_H = 380, 8
local barWrap = mk('Frame', {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 262),
    Size = UDim2.fromOffset(BAR_W, BAR_H + 12),
    BackgroundTransparency = 1,
    Parent = center,
})
local barTrack = mk('Frame', {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(BAR_W, BAR_H),
    BackgroundColor3 = COLOR.panel,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Parent = barWrap,
})

mk('UICorner', {
    CornerRadius = UDim.new(1, 0),
    Parent = barTrack,
})
mk('UIStroke', {
    Color = COLOR.stroke,
    Thickness = 1,
    Transparency = 0.4,
    Parent = barTrack,
})
mk('UIGradient', {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 14, 22)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 24, 36)),
    }),
    Parent = barTrack,
})

local barFill = mk('Frame', {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 0, 0.5, 0),
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = COLOR.accent,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = barTrack,
})

mk('UICorner', {
    CornerRadius = UDim.new(1, 0),
    Parent = barFill,
})
mk('UIGradient', {
    Rotation = 0,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 130, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 140, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 200, 255)),
    }),
    Parent = barFill,
})

local shimmer = mk('Frame', {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, -80, 0.5, 0),
    Size = UDim2.new(0, 80, 1, 0),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.55,
    BorderSizePixel = 0,
    Parent = barFill,
})

mk('UIGradient', {
    Rotation = 0,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.35),
        NumberSequenceKeypoint.new(1, 1),
    }),
    Parent = shimmer,
})

local barGlow = mk('Frame', {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 0, 0.5, 0),
    Size = UDim2.new(0, 0, 1, 14),
    BackgroundColor3 = COLOR.accent,
    BackgroundTransparency = 0.78,
    BorderSizePixel = 0,
    Parent = barTrack,
})

mk('UICorner', {
    CornerRadius = UDim.new(1, 0),
    Parent = barGlow,
})

for i = 1, 9 do
    mk('Frame', {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(i / 10, 0, 0.5, 0),
        Size = UDim2.fromOffset(1, 4),
        BackgroundColor3 = COLOR.strokeHi,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Parent = barTrack,
    })
end

local metaRow = mk('Frame', {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 290),
    Size = UDim2.new(0, BAR_W, 0, 20),
    BackgroundTransparency = 1,
    Parent = center,
})
local pctLabel = mk('TextLabel', {
    Size = UDim2.new(0.5, 0, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = COLOR.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    TextTransparency = 1,
    Text = '0%',
    Parent = metaRow,
})
local stepLabel = mk('TextLabel', {
    Position = UDim2.new(0.5, 0, 0, 0),
    Size = UDim2.new(0.5, 0, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = COLOR.muted,
    TextXAlignment = Enum.TextXAlignment.Right,
    TextYAlignment = Enum.TextYAlignment.Center,
    TextTransparency = 1,
    Text = '0 / ' .. totalSteps,
    Parent = metaRow,
})
local stepRow = mk('Frame', {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 318),
    Size = UDim2.new(0, BAR_W, 0, 10),
    BackgroundTransparency = 1,
    Parent = center,
})

mk('UIListLayout', {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = stepRow,
})

local stepDots = {}

for i = 1, totalSteps do
    local d = mk('Frame', {
        Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = COLOR.stroke,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        LayoutOrder = i,
        Parent = stepRow,
    })

    mk('UICorner', {
        CornerRadius = UDim.new(1, 0),
        Parent = d,
    })

    stepDots[i] = d
end

local TIPS = {
    'Tip \u{2014} NodeX runs multiple loaders in sequence for stability.',
    'Tip \u{2014} stay on this screen until all modules finish loading.',
    'Tip \u{2014} slow network? The loader waits between modules by design.',
    'Tip \u{2014} you can safely minimize Roblox during loading.',
    'Tip \u{2014} modules are fetched fresh each session from our CDN.',
    'Tip \u{2014} leaving a rating helps us ship better features faster.',
}
local tipLabel = mk('TextLabel', {
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -28),
    Size = UDim2.new(1, -40, 0, 16),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = COLOR.muted,
    TextTransparency = 1,
    Text = TIPS[1],
    Parent = center,
})
local footer = mk('TextLabel', {
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -8),
    Size = UDim2.new(1, -40, 0, 12),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = COLOR.dim,
    TextTransparency = 1,
    Text = 'NodeX  \u{2022}  secure loader',
    Parent = center,
})
local FB_W, FB_H = FB_W_PRE, FB_H_PRE
local FB_GAP = FB_GAP_PRE
local feedback = mk('CanvasGroup', {
    Name = 'Feedback',
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, CENTER_W + FB_GAP, 0.5, 0),
    Size = UDim2.fromOffset(FB_W, FB_H),
    BackgroundTransparency = 1,
    GroupTransparency = 1,
    Parent = mainHolder,
})

mk('ImageLabel', {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(1, 60, 1, 60),
    BackgroundTransparency = 1,
    Image = 'rbxassetid://5028857084',
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 0.55,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24, 24, 276, 276),
    Parent = feedback,
})

local fbBody = mk('Frame', {
    Name = 'Body',
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLOR.glassTint,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
    Parent = feedback,
})

mk('UICorner', {
    CornerRadius = UDim.new(0, 18),
    Parent = fbBody,
})
mk('UIGradient', {
    Rotation = 110,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 82, 140)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(34, 40, 70)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 26, 48)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.25),
        NumberSequenceKeypoint.new(0.4, 0.45),
        NumberSequenceKeypoint.new(1, 0.6),
    }),
    Parent = fbBody,
})

local fbStroke = mk('UIStroke', {
    Color = COLOR.glass,
    Thickness = 1.2,
    Transparency = 0.55,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Parent = fbBody,
})

mk('UIGradient', {
    Rotation = 135,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 230, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 100, 160)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.5, 0.55),
        NumberSequenceKeypoint.new(1, 0.85),
    }),
    Parent = fbStroke,
})

local fbHighlight = mk('Frame', {
    Size = UDim2.new(1, -32, 0, 1),
    Position = UDim2.new(0, 16, 0, 1),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.7,
    BorderSizePixel = 0,
    Parent = fbBody,
})

mk('UIGradient', {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    }),
    Parent = fbHighlight,
})

local fbContent = mk('Frame', {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Parent = fbBody,
})

mk('UIPadding', {
    PaddingTop = UDim.new(0, 22),
    PaddingBottom = UDim.new(0, 18),
    PaddingLeft = UDim.new(0, 22),
    PaddingRight = UDim.new(0, 22),
    Parent = fbContent,
})
mk('TextLabel', {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 12),
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = COLOR.accentHi,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = 'FEEDBACK',
    Parent = fbContent,
})
mk('TextLabel', {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 16),
    Size = UDim2.new(1, 0, 0, 26),
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = COLOR.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "How's NodeX?",
    Parent = fbContent,
})
mk('TextLabel', {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 44),
    Size = UDim2.new(1, 0, 0, 14),
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = COLOR.sub,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = 'Tap a star \u{2014} tell us anything.',
    Parent = fbContent,
})

local starsRow = mk('Frame', {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 72),
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundTransparency = 1,
    Parent = fbContent,
})

mk('UIListLayout', {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = starsRow,
})

local stars = {}
local currentRating = 0
local hoverRating = 0

local function applyStarVisual(index, active, hovered)
    local s = stars[index]

    if not s then
        return
    end
    if active then
        tween(s.label, 0.15, {
            TextColor3 = COLOR.star,
            TextSize = hovered and 34 or 30,
        })
        tween(s.stroke, 0.15, {
            Transparency = 0.35,
            Color = COLOR.starHi,
        })
    else
        tween(s.label, 0.15, {
            TextColor3 = hovered and COLOR.starHi or COLOR.starDim,
            TextSize = hovered and 32 or 28,
        })
        tween(s.stroke, 0.15, {
            Transparency = hovered and 0.4 or 0.9,
            Color = hovered and COLOR.star or COLOR.stroke,
        })
    end
end
local function refreshStars()
    local shown = hoverRating > 0 and hoverRating or currentRating

    for i = 1, 5 do
        local active = i <= shown
        local hovered = hoverRating > 0 and i <= hoverRating

        applyStarVisual(i, active, hovered)
    end
end

for i = 1, 5 do
    local holder = mk('TextButton', {
        AutoButtonColor = false,
        Size = UDim2.fromOffset(38, 42),
        BackgroundTransparency = 1,
        Text = '',
        LayoutOrder = i,
        Parent = starsRow,
    })
    local label = mk('TextLabel', {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(36, 36),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 28,
        TextColor3 = COLOR.starDim,
        Text = '\u{2605}',
        Parent = holder,
    })
    local stroke = mk('UIStroke', {
        Color = COLOR.stroke,
        Thickness = 1,
        Transparency = 0.9,
        Parent = label,
    })

    stars[i] = {
        btn = holder,
        label = label,
        stroke = stroke,
    }

    holder.MouseEnter:Connect(function()
        hoverRating = i

        refreshStars()
    end)
    holder.MouseLeave:Connect(function()
        hoverRating = 0

        refreshStars()
    end)
    holder.MouseButton1Click:Connect(function()
        currentRating = i
        hoverRating = 0

        refreshStars()

        for k = 1, i do
            local s = stars[k]
            local burst = mk('TextLabel', {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(36, 36),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 28,
                TextColor3 = COLOR.starHi,
                Text = '\u{2605}',
                TextTransparency = 0,
                Parent = s.btn,
            })

            tween(burst, 0.5, {
                TextSize = 56,
                TextTransparency = 1,
            })
            task.delay(0.55, function()
                if burst then
                    burst:Destroy()
                end
            end)
        end
    end)
end

local RATING_WORDS = {
    [0] = {
        'Pick a star to start',
        COLOR.muted,
    },
    [1] = {
        'Awful',
        Color3.fromRGB(235, 110, 120),
    },
    [2] = {
        'Meh',
        Color3.fromRGB(240, 170, 110),
    },
    [3] = {
        'Okay',
        Color3.fromRGB(240, 210, 120),
    },
    [4] = {
        'Good',
        Color3.fromRGB(170, 220, 130),
    },
    [5] = {
        'Amazing',
        Color3.fromRGB(120, 230, 170),
    },
}
local ratingWord = mk('TextLabel', {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 124),
    Size = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextColor3 = COLOR.muted,
    Text = RATING_WORDS[0][1],
    Parent = fbContent,
})
local commentWrap = mk('Frame', {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 152),
    Size = UDim2.new(1, 0, 0, 92),
    BackgroundColor3 = Color3.fromRGB(30, 36, 60),
    BackgroundTransparency = 0.55,
    BorderSizePixel = 0,
    Parent = fbContent,
})

mk('UICorner', {
    CornerRadius = UDim.new(0, 12),
    Parent = commentWrap,
})

local commentStroke = mk('UIStroke', {
    Color = COLOR.glass,
    Thickness = 1,
    Transparency = 0.75,
    Parent = commentWrap,
})

mk('UIGradient', {
    Rotation = 120,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 72, 120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 28, 50)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(1, 0.7),
    }),
    Parent = commentWrap,
})
mk('UIPadding', {
    PaddingTop = UDim.new(0, 9),
    PaddingBottom = UDim.new(0, 9),
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12),
    Parent = commentWrap,
})

local commentBox = mk('TextBox', {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = COLOR.text,
    PlaceholderText = 'Anything to share? (optional)',
    PlaceholderColor3 = COLOR.muted,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    ClearTextOnFocus = false,
    MultiLine = true,
    Text = '',
    Parent = commentWrap,
})
local commentCount = mk('TextLabel', {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -6, 1, -2),
    Size = UDim2.fromOffset(60, 12),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = COLOR.muted,
    TextXAlignment = Enum.TextXAlignment.Right,
    Text = '0 / 280',
    Parent = commentWrap,
})

commentBox.Focused:Connect(function()
    tween(commentStroke, 0.15, {
        Color = COLOR.accentHi,
        Transparency = 0.4,
    })
end)
commentBox.FocusLost:Connect(function()
    tween(commentStroke, 0.15, {
        Color = COLOR.glass,
        Transparency = 0.75,
    })
end)
commentBox:GetPropertyChangedSignal('Text'):Connect(function()
    if #commentBox.Text > 280 then
        commentBox.Text = commentBox.Text:sub(1, 280)
    end

    commentCount.Text = string.format('%d / 280', #commentBox.Text)
    commentCount.TextColor3 = (#commentBox.Text >= 260) and COLOR.warn or COLOR.muted
end)

local submitBtn = mk('TextButton', {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 256),
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = COLOR.accent,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = COLOR.text,
    Text = 'Submit',
    Parent = fbContent,
})

mk('UICorner', {
    CornerRadius = UDim.new(0, 12),
    Parent = submitBtn,
})
mk('UIGradient', {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 115, 230)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(1, 0.35),
    }),
    Parent = submitBtn,
})

local submitStroke = mk('UIStroke', {
    Color = COLOR.accentHi,
    Thickness = 1,
    Transparency = 0.4,
    Parent = submitBtn,
})
local rtIdentity = mk('TextLabel', {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 304),
    Size = UDim2.new(1, 0, 0, 12),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = COLOR.muted,
    Text = string.format('Submitting as @%s', plr and plr.Name or 'you'),
    Parent = fbContent,
})
local rtFeedback = mk('TextLabel', {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 320),
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextColor3 = COLOR.sub,
    Text = '',
    Parent = fbContent,
})
local thanksLayer = mk('CanvasGroup', {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    GroupTransparency = 1,
    Visible = false,
    Parent = fbBody,
})
local thanksBg = mk('Frame', {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(22, 42, 32),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Parent = thanksLayer,
})

mk('UICorner', {
    CornerRadius = UDim.new(0, 18),
    Parent = thanksBg,
})
mk('UIGradient', {
    Rotation = 135,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 110, 88)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 28, 24)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 0.55),
    }),
    Parent = thanksBg,
})
mk('UIStroke', {
    Color = COLOR.success,
    Thickness = 1,
    Transparency = 0.55,
    Parent = thanksBg,
})

local thanksCheck = mk('TextLabel', {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 120),
    Size = UDim2.fromOffset(90, 90),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 64,
    TextColor3 = COLOR.success,
    Text = '\u{2713}',
    Parent = thanksBg,
})

mk('TextLabel', {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 214),
    Size = UDim2.new(1, -40, 0, 24),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = COLOR.text,
    Text = 'Thanks!',
    Parent = thanksBg,
})

local thanksBody = mk('TextLabel', {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 242),
    Size = UDim2.new(1, -40, 0, 40),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    LineHeight = 1.3,
    TextColor3 = COLOR.sub,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Center,
    Text = 'Your feedback was recorded.',
    Parent = thanksBg,
})

tween(dim, 0.6, {BackgroundTransparency = 0.15})
tween(blur, 0.6, {Size = 24})
tween(center, 0.6, {GroupTransparency = 0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
task.delay(0.15, function()
    tween(titleLabel, 0.5, {TextTransparency = 0})
end)
task.delay(0.25, function()
    tween(titleBadge, 0.4, {BackgroundTransparency = 0.35})
    tween(titleBadgeStroke, 0.4, {Transparency = 0.2})
    tween(titleBadgeText, 0.4, {TextTransparency = 0})
end)
task.delay(0.35, function()
    tween(statusLabel, 0.5, {TextTransparency = 0})
end)
task.delay(0.45, function()
    tween(pctLabel, 0.4, {TextTransparency = 0})
    tween(stepLabel, 0.4, {TextTransparency = 0})
end)
task.delay(0.6, function()
    tween(tipLabel, 0.5, {TextTransparency = 0.2})
end)
task.delay(0.75, function()
    tween(footer, 0.5, {TextTransparency = 0.15})
end)

feedback.Position = UDim2.new(0, CENTER_W + FB_GAP + 60, 0.5, 0)

task.delay(0.35, function()
    tween(feedback, 0.65, {
        GroupTransparency = 0,
        Position = UDim2.new(0, CENTER_W + FB_GAP, 0.5, 0),
    }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end)

for _, acc in ipairs({
    tl,
    tr,
    bl,
    br,
})do
    acc.Size = UDim2.fromOffset(10, 10)

    tween(acc, 0.6, {
        Size = UDim2.fromOffset(60, 60),
    }, Enum.EasingStyle.Back)
end

local ERR_W, ERR_H = 380, 230
local errorPanel = mk('Frame', {
    Name = 'ErrorPanel',
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 16, 1, -16),
    Size = UDim2.fromOffset(ERR_W, ERR_H),
    BackgroundColor3 = Color3.fromRGB(40, 18, 24),
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 50,
    Parent = screenGui,
})

mk('UICorner', { CornerRadius = UDim.new(0, 12), Parent = errorPanel })
mk('UIStroke', {
    Color = COLOR.danger,
    Thickness = 1,
    Transparency = 0.35,
    Parent = errorPanel,
})
mk('UIGradient', {
    Rotation = 135,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 28, 36)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 12, 18)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(1, 0.45),
    }),
    Parent = errorPanel,
})

local errorHeader = mk('Frame', {
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Parent = errorPanel,
})

local errorTitle = mk('TextLabel', {
    Position = UDim2.new(0, 12, 0, 0),
    Size = UDim2.new(1, -52, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = COLOR.danger,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    Text = 'LOADER ERRORS (0)',
    Parent = errorHeader,
})

local errorClose = mk('TextButton', {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -10, 0.5, 0),
    Size = UDim2.fromOffset(22, 22),
    BackgroundColor3 = Color3.fromRGB(60, 22, 30),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = COLOR.danger,
    Text = 'x',
    Parent = errorHeader,
})

mk('UICorner', { CornerRadius = UDim.new(0, 6), Parent = errorClose })

errorClose.MouseButton1Click:Connect(function()
    errorPanel.Visible = false
end)

local errorScroll = mk('ScrollingFrame', {
    Position = UDim2.new(0, 8, 0, 32),
    Size = UDim2.new(1, -16, 1, -40),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = COLOR.danger,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = errorPanel,
})

mk('UIListLayout', {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = errorScroll,
})

local errorPanelCount = 0

addErrorUi = function(stage, detail, urlStr, httpCode)
    errorPanelCount = errorPanelCount + 1
    errorTitle.Text = string.format('LOADER ERRORS (%d)', errorPanelCount)
    errorPanel.Visible = true

    local item = mk('Frame', {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(60, 22, 30),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        LayoutOrder = errorPanelCount,
        Parent = errorScroll,
    })

    mk('UICorner', { CornerRadius = UDim.new(0, 6), Parent = item })
    mk('UIStroke', {
        Color = COLOR.danger,
        Thickness = 1,
        Transparency = 0.7,
        Parent = item,
    })
    mk('UIPadding', {
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = item,
    })
    mk('UIListLayout', {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = item,
    })

    local headerText = string.upper(tostring(stage or '?'))
    if httpCode and tonumber(httpCode) and tonumber(httpCode) > 0 then
        headerText = headerText .. '  HTTP ' .. tostring(httpCode)
    end

    mk('TextLabel', {
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = COLOR.danger,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = headerText,
        LayoutOrder = 1,
        Parent = item,
    })

    if urlStr and urlStr ~= '' then
        mk('TextLabel', {
            Size = UDim2.new(1, 0, 0, 12),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            TextColor3 = COLOR.muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = tostring(urlStr),
            LayoutOrder = 2,
            Parent = item,
        })
    end

    mk('TextLabel', {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = COLOR.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Text = tostring(detail or '?'),
        LayoutOrder = 3,
        Parent = item,
    })

    mk('TextLabel', {
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextColor3 = COLOR.muted,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = os.date('%H:%M:%S'),
        LayoutOrder = 4,
        Parent = item,
    })
end

local alive = true

task.spawn(function()
    local t0 = os.clock()

    while alive and ring1.Parent do
        local t = os.clock() - t0

        ring1.Rotation = (t * 55) % 360
        ring2.Rotation = (-t * 85) % 360
        orbit.Rotation = (t * 40) % 360

        local s = 1 + math.sin(t * 2.2) * 0.04

        pulse.Size = UDim2.fromOffset(math.floor(78 * s), math.floor(78 * s))
        pulseStroke.Transparency = 0.35 + math.sin(t * 2.2) * 0.25

        local lt = (math.sin(t * 1.8) + 1) * 0.5

        ring1Stroke.Color = lerpColor(COLOR.accent, COLOR.purple, lt)
        ring2Stroke.Color = lerpColor(COLOR.purple, COLOR.cyan, lt)

        RunService.RenderStepped:Wait()
    end
end)
task.spawn(function()
    local t0 = os.clock()

    while alive and brandLetter.Parent do
        local t = os.clock() - t0
        local s = 1 + math.sin(t * 1.6) * 0.03

        brandLetter.TextSize = math.floor(42 * s)

        RunService.RenderStepped:Wait()
    end
end)
task.spawn(function()
    while alive and shimmer.Parent do
        shimmer.Position = UDim2.new(0, -80, 0.5, 0)

        tween(shimmer, 1.2, {
            Position = UDim2.new(1, 40, 0.5, 0),
        }, Enum.EasingStyle.Linear)
        task.wait(1.6)
    end
end)
task.spawn(function()
    local t0 = os.clock()

    while alive and centerGlow.Parent do
        local t = os.clock() - t0
        local s = 1 + math.sin(t * 0.9) * 0.06

        centerGlow.Size = UDim2.fromOffset(math.floor(820 * s), math.floor(820 * s))

        RunService.RenderStepped:Wait()
    end
end)
task.spawn(function()
    while alive and particleLayer.Parent do
        local dt = RunService.RenderStepped:Wait()
        local t = os.clock()

        for _, pd in pairs(particles)do
            local inst = pd.inst

            if inst.Parent then
                local pos = inst.Position
                local newY = pos.Y.Scale - pd.speed * dt
                local newX = pos.X.Scale + pd.drift * dt

                if newY < -5E-2 then
                    newY = 1.05
                    newX = math.random()
                end
                if newX < -5E-2 then
                    newX = 1.05
                elseif newX > 1.05 then
                    newX = -5E-2
                end

                inst.Position = UDim2.fromScale(newX, newY)

                local fade = pd.baseT + math.sin(t * 1.5 + pd.phase) * 0.15

                inst.BackgroundTransparency = clamp(fade, 0.35, 0.95)
            end
        end
    end
end)
task.spawn(function()
    while alive and gridLayer.Parent do
        for _, line in ipairs(gridLines)do
            tween(line, 2, {BackgroundTransparency = 0.9})
        end

        task.wait(2)

        if not alive then
            break
        end

        for _, line in ipairs(gridLines)do
            tween(line, 2, {BackgroundTransparency = 0.97})
        end

        task.wait(2)
    end
end)
task.spawn(function()
    local t0 = os.clock()

    while alive and orbit.Parent do
        local t = os.clock() - t0

        for i, d in ipairs(orbitDots)do
            if d.Parent then
                local s = 1 + math.sin(t * 2 + i) * 0.25

                d.Size = UDim2.fromOffset(math.floor(8 * s), math.floor(8 * s))
            end
        end

        RunService.RenderStepped:Wait()
    end
end)
task.spawn(function()
    local i = 1

    while alive and tipLabel.Parent do
        task.wait(4.5)

        if not alive then
            break
        end

        i = (i % #TIPS) + 1

        tween(tipLabel, 0.3, {TextTransparency = 1})
        task.wait(0.32)

        if not tipLabel.Parent then
            break
        end

        tipLabel.Text = TIPS[i]

        tween(tipLabel, 0.4, {TextTransparency = 0.2})
    end
end)

local closeLoader
local displayedPct = 0
local targetPct = 0

task.spawn(function()
    while alive and barFill.Parent do
        local diff = targetPct - displayedPct

        if math.abs(diff) < 0.001 then
            displayedPct = targetPct
        else
            displayedPct = displayedPct + diff * 0.12
        end

        barFill.Size = UDim2.new(clamp(displayedPct, 0, 1), 0, 1, 0)
        barGlow.Size = UDim2.new(clamp(displayedPct, 0, 1), 0, 1, 14)
        pctLabel.Text = string.format('%d%%', math.floor(displayedPct * 100 + 0.5))

        RunService.RenderStepped:Wait()
    end
end)

local function setProgress(p)
    targetPct = clamp(p, 0, 1)
end
local function setStatus(txt)
    if not statusLabel.Parent then
        return
    end

    tween(statusLabel, 0.18, {TextTransparency = 1})
    task.delay(0.2, function()
        if not statusLabel.Parent then
            return
        end

        statusLabel.Text = txt

        tween(statusLabel, 0.3, {TextTransparency = 0})
    end)
end
local function setStep(cur, total)
    if not stepLabel.Parent then
        return
    end

    stepLabel.Text = string.format('%d / %d', cur, total)

    for i, d in ipairs(stepDots)do
        if i < cur then
            tween(d, 0.25, {
                BackgroundColor3 = COLOR.success,
                BackgroundTransparency = 0,
            })
        elseif i == cur then
            tween(d, 0.25, {
                BackgroundColor3 = COLOR.accent,
                BackgroundTransparency = 0,
            })
        else
            tween(d, 0.25, {
                BackgroundColor3 = COLOR.stroke,
                BackgroundTransparency = 0.3,
            })
        end
    end
end
local function setBadge(txt, color)
    if not titleBadgeText.Parent then
        return
    end

    titleBadgeText.Text = txt
    titleBadgeText.TextColor3 = color or COLOR.accentHi

    tween(titleBadgeStroke, 0.2, {
        Color = color or COLOR.accent,
    })
end

task.spawn(function()
    local last = -1

    while alive and ratingWord.Parent do
        local shown = hoverRating > 0 and hoverRating or currentRating

        if shown ~= last then
            last = shown

            local info = RATING_WORDS[shown]

            if info then
                ratingWord.Text = info[1]

                tween(ratingWord, 0.18, {
                    TextColor3 = info[2],
                })
            end
        end

        RunService.Heartbeat:Wait()
    end
end)

local function shakeSubmit()
    local orig = submitBtn.Position

    for _, dx in ipairs({
        -6,
        6,
        -4,
        4,
        -2,
        2,
        0,
    })do
        submitBtn.Position = UDim2.new(orig.X.Scale, orig.X.Offset + dx, orig.Y.Scale, orig.Y.Offset)

        task.wait(0.03)
    end

    submitBtn.Position = orig
end
local function setRtFeedback(txt, color)
    rtFeedback.Text = txt
    rtFeedback.TextColor3 = color or COLOR.sub
    rtFeedback.TextTransparency = 1

    tween(rtFeedback, 0.2, {TextTransparency = 0})
end

submitBtn.MouseEnter:Connect(function()
    tween(submitBtn, 0.15, {BackgroundTransparency = 0.05})
    tween(submitStroke, 0.15, {Transparency = 0.15})
end)
submitBtn.MouseLeave:Connect(function()
    tween(submitBtn, 0.15, {BackgroundTransparency = 0.2})
    tween(submitStroke, 0.15, {Transparency = 0.4})
end)

local submitted = false

local function submitRating()
    if submitted then
        return
    end
    if currentRating < 1 then
        setRtFeedback('Pick a star first.', COLOR.warn)
        task.spawn(shakeSubmit)

        return
    end

    submitted = true
    submitBtn.Text = 'Sending\u{2026}'
    submitBtn.AutoButtonColor = false

    tween(submitBtn, 0.15, {BackgroundTransparency = 0.4})
    setRtFeedback('Submitting\u{2026}', COLOR.sub)
    task.spawn(function()
        local payload = {
            rating = currentRating,
            comment = commentBox.Text or '',
            user = plr and plr.Name or '',
            userid = plr and plr.UserId or 0,
            hwid = HWID,
            place = tostring(game.PlaceId),
            job = tostring(game.JobId),
            executor = EXECUTOR,
            ts = os.time(),
        }
        local res, err = httpPostJson(SERVER_HTTP .. '/api/rating', payload)
        local ok = res and (res.StatusCode == 200 or res.Success == true)

        if ok then
            thanksBody.Text = string.format('We recorded your %d-star rating.', currentRating)
            thanksLayer.Visible = true

            tween(thanksLayer, 0.35, {GroupTransparency = 0})
            task.spawn(function()
                local t0 = os.clock()

                while thanksCheck.Parent and os.clock() - t0 < 1 do
                    local t = os.clock() - t0
                    local s = 1 + math.sin(t * 6) * 0.12

                    thanksCheck.TextSize = math.floor(64 * s)

                    RunService.RenderStepped:Wait()
                end

                if thanksCheck.Parent then
                    thanksCheck.TextSize = 64
                end
            end)
            task.delay(3, function()
                if closeLoader then
                    closeLoader()
                end
            end)
        else
            submitted = false
            submitBtn.Text = 'Submit'

            tween(submitBtn, 0.15, {BackgroundTransparency = 0.2})
            setRtFeedback('Failed to send. ' .. shortStr(err or 'try again', 40), COLOR.danger)
        end
    end)
end

submitBtn.MouseButton1Click:Connect(submitRating)

local wsConnected = false

local function connectWS()
    if wsConnected then
        return
    end

    local ctor = WebSocket and WebSocket.connect

    if not ctor then
        return
    end

    local ws
    local ok = pcall(function()
        ws = WebSocket.connect(SERVER_WS)
    end)

    if not ok or not ws then
        task.delay(10, connectWS)

        return
    end

    wsConnected = true

    pcall(function()
        ws:Send(HttpService:JSONEncode({
            type = 'hello',
            user = plr and plr.Name or 'unknown',
            userid = plr and plr.UserId or 0,
            place = tostring(game.PlaceId),
            job = tostring(game.JobId),
            hwid = HWID,
            executor = EXECUTOR,
        }))
    end)
    ws.OnMessage:Connect(function(raw)
        local okDec, msg = pcall(HttpService.JSONDecode, HttpService, raw)

        if not okDec or type(msg) ~= 'table' then
            return
        end
        if msg.type == 'ping' then
            pcall(function()
                ws:Send(HttpService:JSONEncode({
                    type = 'pong',
                }))
            end)
        end
    end)
    ws.OnClose:Connect(function()
        wsConnected = false

        task.delay(5, connectWS)
    end)
end

local closed = false

closeLoader = function()
    if closed then
        return
    end

    closed = true
    alive = false

    setBadge('READY', COLOR.success)
    tween(pulseStroke, 0.3, {
        Color = COLOR.success,
    })
    tween(ring1Stroke, 0.3, {
        Color = COLOR.success,
    })
    task.wait(0.55)
    tween(center, 0.45, {GroupTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(feedback, 0.45, {
        GroupTransparency = 1,
        Position = UDim2.new(0, CENTER_W + FB_GAP + 60, 0.5, 0),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(dim, 0.55, {BackgroundTransparency = 1})
    tween(centerGlow, 0.55, {BackgroundTransparency = 1})
    tween(blur, 0.55, {Size = 0})

    for _, acc in ipairs({
        tl,
        tr,
        bl,
        br,
    })do
        tween(acc, 0.35, {
            Size = UDim2.fromOffset(10, 10),
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    end

    task.delay(0.7, function()
        if blur then
            blur:Destroy()
        end
        if screenGui then
            screenGui:Destroy()
        end
    end)
end

local function hostFromUrl(url)
    local host = string.match(url or '', 'https?://([^/]+)')

    return host or (url or 'url')
end
local function shortTail(url)
    local last = string.match(url or '', '([^/]+)$') or ''

    if #last > 22 then
        last = string.sub(last, 1, 10) .. '\u{2026}' .. string.sub(last, -8)
    end

    return last
end
local function runLoaders()
    if #loaders == 0 then
        setStatus('No modules configured.')
        logWarn('No modules configured in /api/config.')
        setProgress(1)
        return
    end

    for i, url in ipairs(loaders)do
        setStep(i, #loaders)
        setBadge(string.format('LOADING  %d/%d', i, #loaders), COLOR.accentHi)
        setStatus(string.format('Fetching  %s  \u{2022}  %s', hostFromUrl(url), shortTail(url)))
        setProgress((i - 1) / #loaders + (0.35 / #loaders))
        logInfo(string.format('Module %d/%d -> %s', i, #loaders, url))

        local body, attempts, fetchErr, lastCode = httpGetTextRetry(url, 'module ' .. i, 3, function(att, max, prev)
            if att > 1 then
                setBadge(string.format('RETRY %d/%d', att, max), COLOR.warn)
                setStatus(string.format('Module %d retry %d/%d \u{2014} %s', i, att, max, _shortBody(prev or 'no detail', 60)))
            end
        end)

        if not body then
            local detail = string.format('HTTP %s | %s', tostring(lastCode or '?'), _shortBody(fetchErr or 'unknown', 90))
            logErr(string.format('Module %d FETCH FAILED after %d attempts - %s', i, attempts or 3, detail))
            setBadge(string.format('FAILED %d', i), COLOR.danger)
            setStatus(string.format('Module %d failed \u{2014} %s', i, _shortBody(detail, 80)))
            setProgress(i / #loaders)
            reportError('fetch', detail, url, lastCode or 0, '', i, #loaders)
        elseif looksLikeHtml(body) then
            local preview = _shortBody(body, 200)
            local detail = string.format('Server returned HTML (%d bytes) instead of Lua. Likely an auth/redirect/error page. URL is probably wrong, behind login, or the file is missing.', #body)
            logErr(string.format('Module %d HTML RESPONSE: %s', i, preview))
            setBadge(string.format('FAILED %d', i), COLOR.danger)
            setStatus(string.format('Module %d \u{2014} server returned HTML, not Lua', i))
            setProgress(i / #loaders)
            reportError('html-response', detail, url, lastCode or 200, body, i, #loaders)
        else
            setStatus(string.format('Executing  module %d  \u{2022}  %s', i, hostFromUrl(url)))
            setBadge(string.format('LOADING  %d/%d', i, #loaders), COLOR.accentHi)
            setProgress((i - 1) / #loaders + (0.75 / #loaders))

            local fn, err = loadstring(body)

            if not fn then
                logErr(string.format('Module %d COMPILE ERROR: %s', i, tostring(err)))
                setBadge(string.format('FAILED %d', i), COLOR.danger)
                setStatus(string.format('Module %d compile error \u{2014} %s', i, _shortBody(tostring(err), 70)))
                reportError('compile', tostring(err), url, lastCode or 200, body, i, #loaders)
            else
                logOk(string.format('Module %d compiled (%d bytes), executing...', i, #body))
                local moduleIdx = i
                local moduleUrl = url
                local moduleTotal = #loaders
                task.spawn(function()
                    local okRun, runErr = pcall(fn)
                    if not okRun then
                        logErr(string.format('Module %d RUNTIME ERROR: %s', moduleIdx, tostring(runErr)))
                        reportError('runtime', tostring(runErr), moduleUrl, 0, '', moduleIdx, moduleTotal)
                    else
                        logOk(string.format('Module %d executed cleanly', moduleIdx))
                    end
                end)
            end

            setProgress(i / #loaders)
        end

        if i < #loaders then
            for remaining = loaderDelay, 1, -1 do
                if not alive then
                    return
                end

                setStatus(string.format('Module %d loaded. Next module in %ds\u{2026}', i, remaining))
                task.wait(1)
            end
        else
            setStatus("All modules loaded. Leave a rating if you'd like.")
            logOk('All modules processed.')
            task.wait(0.4)
        end
    end
end

task.spawn(connectWS)
task.spawn(function()
    task.wait(0.4)
    runLoaders()
    task.delay(45, function()
        closeLoader()
    end)
end)
