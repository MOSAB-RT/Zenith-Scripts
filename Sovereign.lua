-- ╔══════════════════════════════════════════════════════════╗
--   Mosab Westbound  |  GLASS UI  |  v5
--   RightCtrl = Hide/Show  |  Drag from TitleBar
-- ╚══════════════════════════════════════════════════════════╝

-- ── WHITELIST ─────────────────────────────────────────────
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not ({["mairjdyr"]=true,["omar_35412"]=true})[LocalPlayer.Name] then
    warn("[GLASS//WEST] ACCESS DENIED"); return
end

-- ── SERVICES ──────────────────────────────────────────────
local Run   = game:GetService("RunService")
local UIS   = game:GetService("UserInputService")
local Light = game:GetService("Lighting")
local PPS   = game:GetService("ProximityPromptService")
local TW    = game:GetService("TweenService")
local SGui  = game:GetService("StarterGui")
local Cam   = workspace.CurrentCamera

-- ── SETTINGS ──────────────────────────────────────────────
local S = {
    AimPlayers=false, AimAnimals=false, WallCheck=false,
    SilentAim=false,  SilentSmooth=0.15, FOV=150, ShowFOV=false,
    PlayerName=false, PlayerHP=false, PlayerBox=false,
    AnimalESP=false,  ShowDist=false, ESPDist=10000, TextSize=12,
    PlayerColor=Color3.fromRGB(0,255,180),
    AnimalColor=Color3.fromRGB(255,200,0),
    Interact=false, TPWalk=false, TPSpeed=2,
    FullBright=false, Noclip=false, SpeedBoost=false, SpeedVal=16,
    GodMode=false, SpawnProt=false,
}

-- ── FOV CIRCLE ────────────────────────────────────────────
local FOVC = Drawing.new("Circle")
FOVC.Thickness=1.5; FOVC.Filled=false
FOVC.Color=Color3.fromRGB(220,30,30); FOVC.Transparency=1; FOVC.Visible=false

-- ── PALETTE ───────────────────────────────────────────────
local C = {
    -- Glass base
    Glass      = Color3.fromRGB(12, 12, 18),
    GlassPanel = Color3.fromRGB(20, 18, 28),
    GlassRow   = Color3.fromRGB(16, 14, 24),

    -- Neon Red
    Neon       = Color3.fromRGB(255, 40,  40),
    NeonDim    = Color3.fromRGB(180, 20,  20),
    NeonDark   = Color3.fromRGB(60,  8,   8),
    NeonGlow   = Color3.fromRGB(255, 80,  80),

    -- Text
    White      = Color3.fromRGB(240, 238, 245),
    Muted      = Color3.fromRGB(140, 135, 160),
    Dim        = Color3.fromRGB(75,  72,  95),

    -- State
    OFF        = Color3.fromRGB(38,  36,  52),
    Green      = Color3.fromRGB(40,  210, 100),

    -- Borders
    BorderGlow = Color3.fromRGB(200, 30,  30),
    BorderSub  = Color3.fromRGB(50,  30,  60),
}

-- ── TWEEN HELPERS ─────────────────────────────────────────
local function T(obj, t, props)
    TW:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end
local function TSpring(obj, t, props)
    TW:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props):Play()
end

-- ── INSTANCE FACTORY ──────────────────────────────────────
local function New(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function RC(p, r)
    New("UICorner", {CornerRadius = UDim.new(0, r or 12)}, p)
end

local function Stroke(p, col, thick, trans)
    New("UIStroke", {
        Color       = col   or C.BorderGlow,
        Thickness   = thick or 1,
        Transparency= trans or 0,
    }, p)
end

local function Gradient(p, c0, c1, rot)
    New("UIGradient", {
        Color    = ColorSequence.new{
            ColorSequenceKeypoint.new(0, c0),
            ColorSequenceKeypoint.new(1, c1),
        },
        Rotation = rot or 90,
    }, p)
end

local function Padding(p, all)
    New("UIPadding", {
        PaddingLeft   = UDim.new(0, all),
        PaddingRight  = UDim.new(0, all),
        PaddingTop    = UDim.new(0, all),
        PaddingBottom = UDim.new(0, all),
    }, p)
end

-- ── PULSE ANIMATION (click feedback) ──────────────────────
local function Pulse(frame)
    local orig = frame.Size
    T(frame, 0.08, {Size = UDim2.new(
        orig.X.Scale, orig.X.Offset - 4,
        orig.Y.Scale, orig.Y.Offset - 4)})
    task.delay(0.08, function()
        TSpring(frame, 0.25, {Size = orig})
    end)
end

-- ╔══════════════════════════════════════════════════════════╗
--   GUI ROOT
-- ╚══════════════════════════════════════════════════════════╝
local Gui = New("ScreenGui", {
    Name            = "GlassWest",
    ResetOnSpawn    = false,
    ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset  = true,
}, LocalPlayer:WaitForChild("PlayerGui"))

-- ── OUTER GLOW (fake bloom) ────────────────────────────────
local OuterGlow = New("Frame", {
    Size                  = UDim2.new(0, 616, 0, 556),
    Position              = UDim2.new(0.5, -308, 0.5, -278),
    BackgroundColor3      = C.Neon,
    BackgroundTransparency= 0.88,
    BorderSizePixel       = 0,
}, Gui)
RC(OuterGlow, 16)

-- ── MAIN WINDOW ───────────────────────────────────────────
local Win = New("Frame", {
    Size                  = UDim2.new(0, 600, 0, 540),
    Position              = UDim2.new(0.5, -300, 0.5, -270),
    BackgroundColor3      = C.Glass,
    BackgroundTransparency= 0.12,
    BorderSizePixel       = 0,
    ClipsDescendants      = false,
}, Gui)
RC(Win, 12)
Gradient(Win,
    Color3.fromRGB(18, 14, 26),
    Color3.fromRGB(8,  8,  14),
    150)
Stroke(Win, C.BorderGlow, 1.5, 0)

-- ── TITLE BAR ─────────────────────────────────────────────
local TBar = New("Frame", {
    Size             = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = C.NeonDark,
    BorderSizePixel  = 0,
}, Win)
RC(TBar, 12)
Gradient(TBar,
    Color3.fromRGB(90, 10, 10),
    Color3.fromRGB(30, 5,  5),
    180)

-- square off bottom corners of titlebar
New("Frame", {
    Size             = UDim2.new(1, 0, 0.5, 0),
    Position         = UDim2.new(0, 0, 0.5, 0),
    BackgroundColor3 = Color3.fromRGB(30, 5, 5),
    BorderSizePixel  = 0,
}, TBar)

-- thin accent line at bottom of titlebar
New("Frame", {
    Size             = UDim2.new(1, -40, 0, 1),
    Position         = UDim2.new(0, 20, 1, -1),
    BackgroundColor3 = C.NeonGlow,
    BorderSizePixel  = 0,
}, TBar)

-- title text
New("TextLabel", {
    Size                  = UDim2.new(1, -60, 1, 0),
    Position              = UDim2.new(0, 16, 0, 0),
    BackgroundTransparency= 1,
    Text                  = "  MOSAB WESTBOUND   ·   " .. LocalPlayer.Name .. "   ·   ONLINE",
    TextColor3            = C.White,
    TextSize              = 13,
    Font                  = Enum.Font.GothamBold,
    TextXAlignment        = Enum.TextXAlignment.Left,
    TextStrokeTransparency= 0.4,
    TextStrokeColor3      = C.Neon,
}, TBar)

-- close button
local XBtn = New("TextButton", {
    Size             = UDim2.new(0, 30, 0, 30),
    Position         = UDim2.new(1, -40, 0.5, -15),
    BackgroundColor3 = C.NeonDark,
    Text             = "X",
    TextColor3       = C.White,
    TextSize         = 14,
    Font             = Enum.Font.GothamBold,
    BorderSizePixel  = 0,
    AutoButtonColor  = false,
}, TBar)
RC(XBtn, 8)
Stroke(XBtn, C.NeonGlow, 1, 0.3)

XBtn.MouseEnter:Connect(function()
    T(XBtn, 0.15, {BackgroundColor3 = C.Neon})
end)
XBtn.MouseLeave:Connect(function()
    T(XBtn, 0.15, {BackgroundColor3 = C.NeonDark})
end)
XBtn.MouseButton1Click:Connect(function()
    Pulse(XBtn)
    task.delay(0.1, function() Gui:Destroy() end)
end)

-- ── DRAG ──────────────────────────────────────────────────
do
    local dragging, dragStart, winStart
    TBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = i.Position
            winStart  = Win.Position
        end
    end)
    TBar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            local np = UDim2.new(
                winStart.X.Scale, winStart.X.Offset + d.X,
                winStart.Y.Scale, winStart.Y.Offset + d.Y)
            Win.Position      = np
            OuterGlow.Position = UDim2.new(
                winStart.X.Scale, winStart.X.Offset + d.X - 8,
                winStart.Y.Scale, winStart.Y.Offset + d.Y - 8)
        end
    end)
end

-- RightCtrl toggle
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightControl then
        local showing = not Win.Visible
        Win.Visible       = showing
        OuterGlow.Visible = showing
    end
end)

-- ── STATUS BAR ────────────────────────────────────────────
local SBar = New("Frame", {
    Size             = UDim2.new(1, -24, 0, 34),
    Position         = UDim2.new(0, 12, 0, 54),
    BackgroundColor3 = C.GlassPanel,
    BackgroundTransparency = 0.3,
    BorderSizePixel  = 0,
}, Win)
RC(SBar, 8)
Stroke(SBar, C.BorderSub, 1, 0.2)
Gradient(SBar,
    Color3.fromRGB(28, 14, 28),
    Color3.fromRGB(14, 14, 22),
    180)

local function StatusCell(label, value, vc, xpct)
    local f = New("Frame", {
        Size                  = UDim2.new(0.33, 0, 1, 0),
        Position              = UDim2.new(xpct, 0, 0, 0),
        BackgroundTransparency= 1,
    }, SBar)
    New("TextLabel", {
        Size                  = UDim2.new(1, 0, 0.44, 0),
        BackgroundTransparency= 1,
        Text                  = label,
        TextColor3            = C.Muted,
        TextSize              = 9,
        Font                  = Enum.Font.Gotham,
        TextXAlignment        = Enum.TextXAlignment.Center,
    }, f)
    New("TextLabel", {
        Size                  = UDim2.new(1, 0, 0.56, 0),
        Position              = UDim2.new(0, 0, 0.44, 0),
        BackgroundTransparency= 1,
        Text                  = value,
        TextColor3            = vc,
        TextSize              = 11,
        Font                  = Enum.Font.GothamBold,
        TextXAlignment        = Enum.TextXAlignment.Center,
    }, f)
end
StatusCell("THREAT", "ELEVATED",  C.Neon,  0)
StatusCell("CIPHER", "AES-256",   C.Green, 0.33)
StatusCell("TOKEN",  tostring(math.random(1e5, 9e5)), C.White, 0.66)

-- thin divider
New("Frame", {
    Size             = UDim2.new(1, -24, 0, 1),
    Position         = UDim2.new(0, 12, 0, 94),
    BackgroundColor3 = C.BorderSub,
    BorderSizePixel  = 0,
}, Win)

-- ── TAB BAR ───────────────────────────────────────────────
local TabBar = New("Frame", {
    Size                  = UDim2.new(1, -24, 0, 36),
    Position              = UDim2.new(0, 12, 0, 100),
    BackgroundTransparency= 1,
    BorderSizePixel       = 0,
}, Win)
New("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding       = UDim.new(0, 6),
}, TabBar)

-- ── SCROLL AREA ───────────────────────────────────────────
local Scroll = New("ScrollingFrame", {
    Size                  = UDim2.new(1, -24, 1, -148),
    Position              = UDim2.new(0, 12, 0, 144),
    BackgroundTransparency= 1,
    BorderSizePixel       = 0,
    ScrollBarThickness    = 3,
    ScrollBarImageColor3  = Color3.fromRGB(180,30,30),
    CanvasSize            = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize   = Enum.AutomaticSize.Y,
    ClipsDescendants      = true,
}, Win)
New("UIPadding",  {PaddingBottom = UDim.new(0, 12)}, Scroll)
New("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, Scroll)

-- ╔══════════════════════════════════════════════════════════╗
--   COLOR PICKER OVERLAY
-- ╚══════════════════════════════════════════════════════════╝
local CPop = New("Frame", {
    Size             = UDim2.new(0, 250, 0, 162),
    BackgroundColor3 = C.GlassPanel,
    BackgroundTransparency = 0.08,
    BorderSizePixel  = 0,
    Visible          = false,
    ZIndex           = 200,
}, Gui)
RC(CPop, 12)
Gradient(CPop,
    Color3.fromRGB(30, 16, 30),
    Color3.fromRGB(12, 12, 20),
    135)
Stroke(CPop, C.NeonGlow, 1.5, 0)
Padding(CPop, 12)

New("TextLabel", {
    Size                  = UDim2.new(1, -28, 0, 18),
    BackgroundTransparency= 1,
    Text                  = "COLOR EDITOR",
    TextColor3            = C.NeonGlow,
    TextSize              = 11,
    Font                  = Enum.Font.GothamBold,
    TextXAlignment        = Enum.TextXAlignment.Left,
    ZIndex                = 201,
}, CPop)

local cpClose = New("TextButton", {
    Size             = UDim2.new(0, 24, 0, 24),
    Position         = UDim2.new(1, -24, 0, -2),
    BackgroundColor3 = C.NeonDark,
    Text             = "X",
    TextColor3       = C.White,
    TextSize         = 11,
    Font             = Enum.Font.GothamBold,
    BorderSizePixel  = 0,
    AutoButtonColor  = false,
    ZIndex           = 202,
}, CPop)
RC(cpClose, 6)
cpClose.MouseButton1Click:Connect(function() CPop.Visible = false end)

local cpRGB  = {r=255, g=255, b=255}
local cpCBs  = {}
local cpInfo = {}
local cpChDefs = {
    {k="r", n="R", col=Color3.fromRGB(255,70,70)},
    {k="g", n="G", col=Color3.fromRGB(70,210,90)},
    {k="b", n="B", col=Color3.fromRGB(70,140,230)},
}

for idx, ch in ipairs(cpChDefs) do
    local yy = 22 + (idx-1)*40

    New("TextLabel", {
        Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,0,0,yy+10),
        BackgroundTransparency=1, Text=ch.n, TextColor3=ch.col,
        TextSize=11, Font=Enum.Font.GothamBold, ZIndex=201, Parent=CPop,
    })

    local vl = New("TextLabel", {
        Size=UDim2.new(0,34,0,14), Position=UDim2.new(1,-34,0,yy+10),
        BackgroundTransparency=1, Text="255", TextColor3=C.White,
        TextSize=10, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right, ZIndex=201, Parent=CPop,
    })

    local tr = New("Frame", {
        Size=UDim2.new(1,-54,0,14), Position=UDim2.new(0,18,0,yy+11),
        BackgroundColor3=C.NeonDark, BorderSizePixel=0, ZIndex=201, Parent=CPop,
    })
    RC(tr, 7)
    Stroke(tr, C.BorderSub, 1, 0.3)

    local fi = New("Frame", {
        Size=UDim2.new(1,0,1,0), BackgroundColor3=ch.col,
        BorderSizePixel=0, ZIndex=202, Parent=tr,
    })
    RC(fi, 7)

    cpInfo[ch.k] = {tr=tr, fi=fi, vl=vl}

    local function slide(px)
        local pct = math.clamp((px - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
        local v   = math.floor(pct * 255)
        cpRGB[ch.k] = v
        fi.Size     = UDim2.new(pct, 0, 1, 0)
        vl.Text     = tostring(v)
        local col   = Color3.fromRGB(cpRGB.r, cpRGB.g, cpRGB.b)
        for _, cb in ipairs(cpCBs) do cb(col) end
    end

    local sliding = false
    tr.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true; slide(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
            slide(i.Position.X)
        end
    end)
end

local cpPrev = New("Frame", {
    Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,1,-16),
    BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=201, Parent=CPop,
})
RC(cpPrev, 6)

local function OpenCP(swFrame, curCol, onCh)
    cpRGB.r = math.floor(curCol.R * 255)
    cpRGB.g = math.floor(curCol.G * 255)
    cpRGB.b = math.floor(curCol.B * 255)
    for _, ch in ipairs(cpChDefs) do
        local inf = cpInfo[ch.k]
        local v   = cpRGB[ch.k]
        inf.fi.Size  = UDim2.new(v/255, 0, 1, 0)
        inf.vl.Text  = tostring(v)
    end
    cpPrev.BackgroundColor3 = curCol
    cpCBs = {onCh, function(c) cpPrev.BackgroundColor3 = c end}
    local ap = swFrame.AbsolutePosition
    local as = swFrame.AbsoluteSize
    local ss = Gui.AbsoluteSize
    local px = math.clamp(ap.X + as.X/2 - 125, 4, ss.X - 254)
    local py = ap.Y + as.Y + 8
    if py + 170 > ss.Y then py = ap.Y - 170 end
    CPop.Position = UDim2.new(0, px, 0, py)
    CPop.Visible  = true
end

-- ╔══════════════════════════════════════════════════════════╗
--   TAB SYSTEM
-- ╚══════════════════════════════════════════════════════════╝
local TPages, TBtns = {}, {}

local function SwitchTab(name)
    for n, pg in pairs(TPages) do pg.Visible = (n == name) end
    for n, b  in pairs(TBtns)  do
        if n == name then
            T(b, 0.18, {BackgroundColor3 = C.Neon,  TextColor3 = C.White})
        else
            T(b, 0.18, {BackgroundColor3 = C.NeonDark, TextColor3 = C.Muted})
        end
    end
    CPop.Visible = false
end

local function NewTab(name, icon)
    local label = icon and (icon .. "  " .. name) or name
    local btn = New("TextButton", {
        Size             = UDim2.new(0, 118, 1, 0),
        BackgroundColor3 = C.NeonDark,
        Text             = label,
        TextColor3       = C.Muted,
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        BorderSizePixel  = 0,
        AutoButtonColor  = false,
    }, TabBar)
    RC(btn, 8)
    Stroke(btn, C.BorderSub, 1, 0.2)

    local pg = New("Frame", {
        Size               = UDim2.new(1, 0, 0, 0),
        AutomaticSize      = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Visible            = false,
        BorderSizePixel    = 0,
        Parent             = Scroll,
    })
    New("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, pg)

    btn.MouseEnter:Connect(function()
        if TBtns[name] and TPages[name] and not TPages[name].Visible then
            T(btn, 0.12, {BackgroundColor3 = C.NeonDim})
        end
    end)
    btn.MouseLeave:Connect(function()
        if not TPages[name].Visible then
            T(btn, 0.12, {BackgroundColor3 = C.NeonDark})
        end
    end)
    btn.MouseButton1Click:Connect(function()
        Pulse(btn); SwitchTab(name)
    end)

    TPages[name] = pg
    TBtns[name]  = btn
    return pg
end

-- ╔══════════════════════════════════════════════════════════╗
--   SECTION + WIDGET BUILDER
-- ╚══════════════════════════════════════════════════════════╝
local function NewSection(page, title)
    local sec = New("Frame", {
        Size                  = UDim2.new(1, 0, 0, 0),
        AutomaticSize         = Enum.AutomaticSize.Y,
        BackgroundColor3      = C.GlassPanel,
        BackgroundTransparency= 0.22,
        BorderSizePixel       = 0,
        Parent                = page,
    })
    RC(sec, 10)
    Stroke(sec, C.BorderSub, 1, 0.1)
    Gradient(sec,
        Color3.fromRGB(24, 16, 32),
        Color3.fromRGB(10, 10, 16),
        145)
    New("UIPadding", {
        PaddingLeft   = UDim.new(0, 10),
        PaddingRight  = UDim.new(0, 10),
        PaddingTop    = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 10),
    }, sec)
    New("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, sec)

    -- section header
    local hdr = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = C.NeonDark,
        BackgroundTransparency = 0.1,
        BorderSizePixel  = 0,
        LayoutOrder      = 0,
        Parent           = sec,
    })
    RC(hdr, 7)
    Gradient(hdr,
        Color3.fromRGB(80, 10, 10),
        Color3.fromRGB(35, 5, 5),
        180)
    Stroke(hdr, C.NeonDim, 1, 0.3)

    New("TextLabel", {
        Size                  = UDim2.new(1, -12, 1, 0),
        Position              = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency= 1,
        Text                  = title,
        TextColor3            = C.NeonGlow,
        TextSize              = 11,
        Font                  = Enum.Font.GothamBold,
        TextXAlignment        = Enum.TextXAlignment.Left,
        TextStrokeTransparency= 0.5,
        TextStrokeColor3      = C.Neon,
    }, hdr)

    local orderN = 0
    local function nxt() orderN = orderN + 1; return orderN end

    -- ── ROW BASE ──────────────────────────────────────────
    local function MakeRow(h)
        local row = New("Frame", {
            Size             = UDim2.new(1, 0, 0, h),
            BackgroundColor3 = C.GlassRow,
            BackgroundTransparency = 0.35,
            BorderSizePixel  = 0,
            LayoutOrder      = nxt(),
            Parent           = sec,
        })
        RC(row, 8)
        Stroke(row, C.BorderSub, 1, 0.4)
        return row
    end

    -- ── iOS TOGGLE ────────────────────────────────────────
    local function NewToggle(label, desc, cb)
        local row = MakeRow(52)

        New("TextLabel", {
            Size=UDim2.new(1,-72,0,22), Position=UDim2.new(0,14,0,7),
            BackgroundTransparency=1, Text=label,
            TextColor3=C.White, TextSize=13, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextStrokeTransparency=0.6, TextStrokeColor3=Color3.new(0,0,0),
        }, row)
        New("TextLabel", {
            Size=UDim2.new(1,-72,0,16), Position=UDim2.new(0,14,0,29),
            BackgroundTransparency=1, Text=desc,
            TextColor3=C.Muted, TextSize=10, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, row)

        -- iOS pill
        local pill = New("Frame", {
            Size=UDim2.new(0,46,0,24), Position=UDim2.new(1,-58,0.5,-12),
            BackgroundColor3=C.OFF, BorderSizePixel=0,
        }, row)
        RC(pill, 12)
        Stroke(pill, C.Dim, 1, 0.2)

        local knob = New("Frame", {
            Size=UDim2.new(0,20,0,20), Position=UDim2.new(0,2,0.5,-10),
            BackgroundColor3=C.White, BorderSizePixel=0,
        }, pill)
        RC(knob, 10)

        -- hover glow on row
        local rowHover = false
        local hitbox = New("TextButton", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", Parent=row,
        })
        hitbox.MouseEnter:Connect(function()
            rowHover = true
            T(row, 0.15, {BackgroundTransparency = 0.15})
        end)
        hitbox.MouseLeave:Connect(function()
            rowHover = false
            T(row, 0.15, {BackgroundTransparency = 0.35})
        end)

        local state = false
        hitbox.MouseButton1Click:Connect(function()
            state = not state
            cb(state)
            Pulse(row)
            if state then
                T(pill,  0.2, {BackgroundColor3 = C.Neon})
                T(knob,  0.2, {Position = UDim2.new(1,-22,0.5,-10), BackgroundColor3 = C.White})
                -- glow when ON
                T(pill, 0.2, {BackgroundColor3 = C.Neon})
                Stroke(pill, C.NeonGlow, 1, 0)
            else
                T(pill,  0.2, {BackgroundColor3 = C.OFF})
                T(knob,  0.2, {Position = UDim2.new(0,2,0.5,-10), BackgroundColor3 = C.Muted})
                Stroke(pill, C.Dim, 1, 0.2)
            end
        end)
    end

    -- ── SLIDER ────────────────────────────────────────────
    local function NewSlider(label, desc, maxV, minV, cb)
        local row = MakeRow(72)

        New("TextLabel", {
            Size=UDim2.new(0.7,0,0,22), Position=UDim2.new(0,14,0,6),
            BackgroundTransparency=1, Text=label,
            TextColor3=C.White, TextSize=13, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextStrokeTransparency=0.6, TextStrokeColor3=Color3.new(0,0,0),
        }, row)

        local vLbl = New("TextLabel", {
            Size=UDim2.new(0.3,-14,0,22), Position=UDim2.new(0.7,0,0,6),
            BackgroundTransparency=1, Text=tostring(minV),
            TextColor3=C.NeonGlow, TextSize=13, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Right,
        }, row)

        New("TextLabel", {
            Size=UDim2.new(1,-28,0,14), Position=UDim2.new(0,14,0,29),
            BackgroundTransparency=1, Text=desc,
            TextColor3=C.Muted, TextSize=10, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, row)

        -- track container (no ClipsDescendants so dot shows)
        local track = New("Frame", {
            Size=UDim2.new(1,-28,0,16), Position=UDim2.new(0,14,0,50),
            BackgroundColor3=C.NeonDark, BorderSizePixel=0,
            ClipsDescendants=false,
        }, row)
        RC(track, 8)
        Stroke(track, C.BorderSub, 1, 0.3)

        -- fill bar inside track
        local fill = New("Frame", {
            Size=UDim2.new(0,0,1,0),
            BackgroundColor3=C.Neon, BorderSizePixel=0,
            ClipsDescendants=false,
        }, track)
        RC(fill, 8)
        Gradient(fill, C.NeonGlow, C.Neon, 180)

        -- dot on top of fill, centered vertically on the track
        local dot = New("Frame", {
            Size=UDim2.new(0,18,0,18),
            Position=UDim2.new(1,-9,0.5,-9),
            BackgroundColor3=C.White, BorderSizePixel=0,
            ZIndex=5,
        }, fill)
        RC(dot, 9)
        Stroke(dot, C.Muted, 1, 0.3)

        local function SetVal(v)
            v = math.clamp(math.floor(v), minV, maxV)
            local pct = maxV == minV and 0 or (v - minV) / (maxV - minV)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            vLbl.Text = tostring(v)
            cb(v)
        end
        SetVal(minV)

        -- hover glow on row
        local hitbox2 = New("TextButton", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="",
            ZIndex=2, Parent=row,
        })
        hitbox2.MouseEnter:Connect(function() T(row, 0.15, {BackgroundTransparency=0.15}) end)
        hitbox2.MouseLeave:Connect(function() T(row, 0.15, {BackgroundTransparency=0.35}) end)

        -- track hitbox — فوق كل شيء، هنا يبدأ الـ sliding
        local sliding = false
        local trackBtn = New("TextButton", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="",
            ZIndex=10, Parent=track,
        })

        local function calcAndSet(inputX)
            local pct = math.clamp(
                (inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            SetVal(minV + pct * (maxV - minV))
        end

        trackBtn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                calcAndSet(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = false
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                calcAndSet(i.Position.X)
            end
        end)
    end

    -- ── COLOR PICKER ──────────────────────────────────────
    local function NewColorPicker(label, desc, defCol, cb)
        local row = MakeRow(52)

        New("TextLabel", {
            Size=UDim2.new(1,-80,0,22), Position=UDim2.new(0,14,0,7),
            BackgroundTransparency=1, Text=label,
            TextColor3=C.White, TextSize=13, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextStrokeTransparency=0.6, TextStrokeColor3=Color3.new(0,0,0),
        }, row)
        New("TextLabel", {
            Size=UDim2.new(1,-80,0,16), Position=UDim2.new(0,14,0,29),
            BackgroundTransparency=1, Text=desc,
            TextColor3=C.Muted, TextSize=10, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, row)

        local curCol = defCol
        local sw = New("Frame", {
            Size=UDim2.new(0,44,0,34), Position=UDim2.new(1,-54,0.5,-17),
            BackgroundColor3=defCol, BorderSizePixel=0,
        }, row)
        RC(sw, 8)
        Stroke(sw, C.NeonGlow, 1.5, 0.2)

        local swBtn = New("TextButton", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", Parent=sw,
        })
        swBtn.MouseEnter:Connect(function() T(sw, 0.1, {}) end)
        swBtn.MouseButton1Click:Connect(function()
            Pulse(sw)
            if CPop.Visible then
                CPop.Visible = false
            else
                OpenCP(sw, curCol, function(col)
                    curCol = col
                    sw.BackgroundColor3 = col
                    cb(col)
                end)
            end
        end)
    end

    return {NewToggle=NewToggle, NewSlider=NewSlider, NewColorPicker=NewColorPicker}
end -- END NewSection

-- ╔══════════════════════════════════════════════════════════╗
--   BUILD TABS & SECTIONS
-- ╚══════════════════════════════════════════════════════════╝
local PC = NewTab("COMBAT",  nil)
local PV = NewTab("VISUALS", nil)
local PW = NewTab("WORLD",   nil)
SwitchTab("COMBAT")

local SA  = NewSection(PC, "AIMBOT PROTOCOL")
local SPE = NewSection(PV, "PLAYER SCANNER")
local SWE = NewSection(PV, "WORLD SCANNER")
local SVC = NewSection(PV, "DISPLAY CONFIG")
local SU  = NewSection(PW, "UTILITY MODULE")
local SM  = NewSection(PW, "MOVEMENT OVERRIDE")

-- ╔══════════════════════════════════════════════════════════╗
--   GAME LOGIC
-- ╚══════════════════════════════════════════════════════════╝
local function GetRoot(o)
    if o:IsA("BasePart") then return o end
    if o:IsA("Model") then
        return o.PrimaryPart
            or o:FindFirstChild("HumanoidRootPart")
            or o:FindFirstChildWhichIsA("BasePart")
    end
end

local function GetDist(pos)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        return math.floor((c.HumanoidRootPart.Position - pos).Magnitude)
    end
    return 0
end

local function IsVis(tp)
    if not tp then return false end
    local c = LocalPlayer.Character
    if not c or not c:FindFirstChild("Head") then return false end
    local p = RaycastParams.new()
    p.FilterDescendantsInstances = {c}
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.IgnoreWater = true
    local r = workspace:Raycast(Cam.CFrame.Position, tp.Position - Cam.CFrame.Position, p)
    return r and r.Instance:IsDescendantOf(tp.Parent) or (r == nil)
end

local function AName(o)
    local n = o.Name:lower()
    local pre = n:find("legendary") and "[LEG] " or ""
    local m = {
        {"crow","Crow"},{"dire wolf","Dire Wolf"},{"direwolf","Dire Wolf"},
        {"wolf","Wolf"},{"coyote","Coyote"},{"fox","Fox"},
        {"grizzly","Grizzly"},{"black bear","Black Bear"},{"bear","Bear"},
        {"bison","Bison"},{"buffalo","Bison"},{"buck","Deer"},
        {"doe","Deer"},{"fawn","Deer"},{"deer","Deer"},
        {"horse","Horse"},{"cow","Cow"},{"cattle","Cow"},
        {"pig","Pig"},{"boar","Boar"},{"rabbit","Rabbit"},
        {"bunny","Rabbit"},{"chicken","Chicken"},
    }
    for _, e in ipairs(m) do if n:find(e[1]) then return pre..e[2] end end
    return o.Name
end

-- ── AIMBOT ────────────────────────────────────────────────
local function GetTarget()
    local tp, cd = nil, S.FOV
    local center = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)

    local function chk(part)
        local pos, vis = Cam:WorldToViewportPoint(part.Position)
        if not vis then return end
        local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if mag < cd then tp = part; cd = mag end
    end

    if S.AimPlayers then
        for _, v in ipairs(Players:GetPlayers()) do
            if v == LocalPlayer then continue end
            local ch  = v.Character; if not ch then continue end
            local hd  = ch:FindFirstChild("Head")
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if not hd or not hum or hum.Health <= 0 then continue end
            if S.WallCheck and not IsVis(hd) then continue end
            chk(hd)
        end
    end

    if S.AimAnimals then
        for _, fn in ipairs({"Harvestables","Animals","NPCS"}) do
            local folder = workspace:FindFirstChild(fn); if not folder then continue end
            for _, v in ipairs(folder:GetChildren()) do
                if not v:IsA("Model") then continue end
                local hum = v:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then continue end
                local rp = GetRoot(v); if not rp then continue end
                if S.WallCheck and not IsVis(rp) then continue end
                chk(rp)
            end
        end
    end
    return tp
end

-- ── ESP ───────────────────────────────────────────────────
local function ManageESP(char, text, color, tag, show, dist, isP)
    local rp = isP
        and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        or GetRoot(char)
    if not rp then return end
    local inRange = isP or (dist <= S.ESPDist)
    local bb = rp:FindFirstChild(tag)
    if show and inRange then
        if not bb then
            bb = Instance.new("BillboardGui")
            bb.Name="GWE_"..tag; bb.Adornee=rp
            bb.AlwaysOnTop=true; bb.Size=UDim2.new(0,200,0,60)
            bb.StudsOffset=Vector3.new(0,3,0); bb.Parent=rp
            local lb = Instance.new("TextLabel", bb)
            lb.Name="L"; lb.BackgroundTransparency=1; lb.Size=UDim2.new(1,0,1,0)
            lb.TextStrokeTransparency=0.3; lb.TextStrokeColor3=Color3.new(0,0,0)
            lb.Font=Enum.Font.Code
        end
        local lb = rp:FindFirstChild("GWE_"..tag) and rp:FindFirstChild("GWE_"..tag):FindFirstChild("L")
        if lb then
            lb.TextSize  = S.TextSize
            lb.TextColor3= color
            lb.Text      = text .. (S.ShowDist and ("  [" .. dist .. "m]") or "")
        end
    else
        local b = rp:FindFirstChild("GWE_"..tag)
        if b then b:Destroy() end
    end
end

local function CleanAESP()
    for _, fn in ipairs({"Harvestables","Animals","NPCS"}) do
        local f = workspace:FindFirstChild(fn); if not f then continue end
        for _, a in ipairs(f:GetChildren()) do
            local rp = GetRoot(a)
            if rp then
                local t = rp:FindFirstChild("GWE_ANIM")
                if t then t:Destroy() end
            end
        end
    end
end

-- Animal ESP loop
task.spawn(function()
    while true do
        task.wait(1)
        if not S.AnimalESP then continue end
        for _, fn in ipairs({"Harvestables","Animals","NPCS"}) do
            local folder = workspace:FindFirstChild(fn); if not folder then continue end
            for _, v in ipairs(folder:GetChildren()) do
                if not v:IsA("Model") then continue end
                local rp  = GetRoot(v); if not rp then continue end
                local hum = v:FindFirstChildOfClass("Humanoid")
                local lb  = AName(v)
                if hum and hum.Health <= 0 then lb = "[DEAD] " .. lb end
                ManageESP(v, lb, S.AnimalColor, "ANIM", true, GetDist(rp.Position), false)
            end
        end
    end
end)

-- Player ESP loop
task.spawn(function()
    while true do
        task.wait(0.1)
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local c   = p.Character; if not c then continue end
            local hum = c:FindFirstChildOfClass("Humanoid")
            local rp  = c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
            if rp and hum and hum.Health > 0 then
                local dist = GetDist(rp.Position)
                local show = S.PlayerName or S.PlayerHP
                local txt  = ""
                if S.PlayerName then txt = "[ " .. p.Name .. " ]" end
                if S.PlayerHP   then
                    txt = txt .. (txt ~= "" and "\n" or "")
                        .. "HP " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                end
                ManageESP(c, txt, S.PlayerColor, "PLYR", show, dist, true)
                local hl = c:FindFirstChild("GWPH")
                if S.PlayerBox then
                    if not hl then
                        hl = Instance.new("Highlight"); hl.Name="GWPH"; hl.Parent=c
                    end
                    hl.FillColor         = S.PlayerColor
                    hl.FillTransparency  = 0.65
                    hl.OutlineColor      = C.Neon
                    hl.OutlineTransparency = 0
                elseif hl then hl:Destroy() end
            else
                local b  = c:FindFirstChild("GWE_PLYR", true); if b  then b:Destroy()  end
                local hl = c:FindFirstChild("GWPH");            if hl then hl:Destroy() end
            end
        end
    end
end)

-- FullBright handled in RenderStepped

-- ── NOCLIP ────────────────────────────────────────────────
local noclipConn
local function SetNoclip(on)
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    local char = LocalPlayer.Character; if not char then return end
    if on then
        local function off(p) if p:IsA("BasePart") then p.CanCollide = false end end
        for _, p in ipairs(char:GetDescendants()) do off(p) end
        noclipConn = char.DescendantAdded:Connect(off)
    else
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end

-- ── SPEED ─────────────────────────────────────────────────
local function ApplySpeed()
    local c = LocalPlayer.Character; if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = S.SpeedBoost and S.SpeedVal or 16 end
end

-- ── GOD MODE ──────────────────────────────────────────────
local godConns = {}

-- ── GOD MODE — SERVER SIDE HOOK ──────────────────────────
-- نعترض كل RemoteEvent/RemoteFunction يرسل damage
-- ونوقف أي call فيه كلمة damage/hit/hurt/take

local _origFireServer
local _origInvokeServer
local godHooked = false

local function HookRemotes()
    if godHooked then return end
    godHooked = true

    -- الـ keywords اللي تدل على damage remote
    local dmgKeys = {
        "damage","dmg","hit","hurt","takehit","takedmg",
        "takedamage","dealdam","dealdmg","applydmg",
        "applydamage","onhit","struck","wound","injure",
    }

    local function isDamageRemote(name)
        if not name then return false end
        local low = name:lower()
        for _, k in ipairs(dmgKeys) do
            if low:find(k) then return true end
        end
        return false
    end

    -- Hook FireServer
    local mt = getrawmetatable(game)
    if mt then
        local oldNI = mt.__newindex
        local oldNam = mt.__namecall

        -- Xeno supports sethiddenproperty / hookmetamethod
        if hookmetamethod then
            local origNam = hookmetamethod(game, "__namecall", function(self, ...)
                if not S.GodMode then return origNam(self, ...) end
                local method = getnamecallmethod()
                if method == "FireServer" or method == "InvokeServer" then
                    if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
                        if isDamageRemote(self.Name) then
                            return -- block it
                        end
                    end
                end
                return origNam(self, ...)
            end)
        end
    end
end

local function ApplyGodMode(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local savedMax = hum.MaxHealth

    -- طبقة 1: hook الـ remotes عبر hookmetamethod
    pcall(HookRemotes)

    -- طبقة 1b: نبحث عن damage remotes بالاسم ونربط عليها مباشرة
    -- هذا fallback لو hookmetamethod ما يدعمه Xeno
    local dmgKeys2 = {"damage","dmg","hit","hurt","takehit","takedmg","takedamage"}
    local function scanRemotes(parent)
        if not parent then return end
        for _, obj in ipairs(parent:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local low = obj.Name:lower()
                for _, k in ipairs(dmgKeys2) do
                    if low:find(k) then
                        -- وجدنا remote مشبوه، نربط OnClientEvent
                        -- لو السيرفر يرسل damage event للـ client
                        pcall(function()
                            if obj:IsA("RemoteEvent") then
                                obj.OnClientEvent:Connect(function()
                                    -- لما السيرفر يرسل damage نرجع HP فوري
                                    if S.GodMode and hum and hum.Parent then
                                        task.defer(function()
                                            if hum.Parent then
                                                hum.Health = savedMax
                                            end
                                        end)
                                    end
                                end)
                            end
                        end)
                    end
                end
            end
        end
    end
    task.delay(2, function() -- انتظر اللعبة تحمل
        scanRemotes(workspace)
        scanRemotes(game:GetService("ReplicatedStorage"))
    end)

    -- طبقة 2: Heartbeat يرجع HP فوري كل frame
    local c1 = Run.Heartbeat:Connect(function()
        if not S.GodMode then return end
        if not hum.Parent then return end
        if hum.Health < savedMax then
            hum.Health = savedMax
        end
    end)

    -- طبقة 3: منع BreakJoints
    local c2 = char.ChildAdded:Connect(function(obj)
        if not S.GodMode then return end
        if obj.Name == "BreakJointsOnDeath" or obj.Name == "BreakJoints" then
            task.defer(function() pcall(function() obj:Destroy() end) end)
        end
    end)

    table.insert(godConns, c1)
    table.insert(godConns, c2)
end

local function RemoveGodMode()
    godHooked = false
    for _, conn in ipairs(godConns) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(godConns)
end

local function SetGodMode(on)
    RemoveGodMode()
    if on then ApplyGodMode(LocalPlayer.Character) end
end

-- ── SPAWN PROTECTION ──────────────────────────────────────
local spawnProtConn

local function EnableSpawnProt(char)
    if spawnProtConn then spawnProtConn:Disconnect(); spawnProtConn = nil end
    if not char then return end

    -- الـ Spawn Protection في Westbound تروح لو:
    -- 1) سحبت سلاح  2) خرجت من المنطقة  3) انتهت 30 ثانية
    -- نحن نمنع رقم 1 فقط (الوحيد اللي نقدر نتحكم فيه client-side)

    local active = true
    task.delay(32, function() active = false end) -- 32 ثانية احتياط

    -- لما يضيف Tool للـ character نرجعه للـ backpack فوري
    spawnProtConn = char.ChildAdded:Connect(function(obj)
        if not active then return end
        if obj:IsA("Tool") then
            task.defer(function()
                if not active then return end
                local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
                if bp and obj and obj.Parent == char then
                    obj.Parent = bp
                end
            end)
        end
    end)

    -- أيضاً كل 0.5 ثانية نتأكد ما في tool مجهز
    task.spawn(function()
        while active do
            task.wait(0.5)
            local c2 = LocalPlayer.Character; if not c2 then break end
            local tool = c2:FindFirstChildOfClass("Tool")
            local bp   = LocalPlayer:FindFirstChildOfClass("Backpack")
            if tool and bp then
                tool.Parent = bp
            end
        end
    end)
end

-- ── CHARACTER ADDED ───────────────────────────────────────
LocalPlayer.CharacterAdded:Connect(function(c)
    table.clear(godConns)
    task.wait(0.3)
    if S.GodMode    then ApplyGodMode(c) end
    if S.SpawnProt  then EnableSpawnProt(c) end
    if S.SpeedBoost then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = S.SpeedVal end
    end
    if S.Noclip then task.wait(0.1); SetNoclip(true) end
end)

-- ── RENDER LOOP (lightweight) ─────────────────────────────
Run.RenderStepped:Connect(function()
    FOVC.Visible  = S.ShowFOV
    FOVC.Radius   = S.FOV
    FOVC.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)

    local ap = GetTarget()
    if ap then
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            Cam.CFrame = CFrame.new(Cam.CFrame.Position, ap.Position)
        end
        if S.SilentAim and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            Cam.CFrame = Cam.CFrame:Lerp(
                CFrame.new(Cam.CFrame.Position, ap.Position), S.SilentSmooth)
        end
    end

    if S.TPWalk then
        local c = LocalPlayer.Character; if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h and h.MoveDirection.Magnitude > 0 then
                c:TranslateBy(h.MoveDirection * S.TPSpeed * 0.1)
            end
        end
    end

    if S.FullBright then
        Light.ClockTime     = 14
        Light.Brightness    = 2
        Light.GlobalShadows = false
        Light.FogEnd        = 100000
    end
end)

-- ╔══════════════════════════════════════════════════════════╗
--   POPULATE UI
-- ╚══════════════════════════════════════════════════════════╝
SA.NewToggle("Target Players",   "RMB — Lock onto players",                function(v) S.AimPlayers=v end)
SA.NewToggle("Target Animals",   "RMB — Lock onto wildlife",               function(v) S.AimAnimals=v end)
SA.NewToggle("Wall Check",       "Only aim at visible targets",            function(v) S.WallCheck=v end)
SA.NewToggle("Silent Fire",      "LMB — Smooth silent aim",                function(v) S.SilentAim=v end)
SA.NewSlider("FOV Radius",       "Aim radius in pixels",       800, 10,   function(v) S.FOV=v end)
SA.NewSlider("Silent Smoothing", "1=instant  50=smooth",       50,  1,    function(v) S.SilentSmooth=v/100 end)
SA.NewToggle("Show FOV Ring",    "Render FOV circle on screen",             function(v) S.ShowFOV=v end)

SPE.NewToggle("Name ESP",   "Show player username",         function(v) S.PlayerName=v end)
SPE.NewToggle("Health ESP", "Show HP / Max HP",             function(v) S.PlayerHP=v end)
SPE.NewToggle("Box ESP",    "Highlight player silhouette",  function(v) S.PlayerBox=v end)

SWE.NewToggle("Animal ESP",    "Track all wildlife",             function(v) S.AnimalESP=v; if not v then CleanAESP() end end)
SWE.NewToggle("Show Distance", "Display range to each target",  function(v) S.ShowDist=v end)

SVC.NewSlider("Max Animal Range", "Fauna ESP max distance", 20000, 500, function(v) S.ESPDist=v end)
SVC.NewSlider("Label Size",       "ESP font size",          20,   8,   function(v) S.TextSize=v end)
SVC.NewColorPicker("Player ESP Color", "Color for player labels", S.PlayerColor, function(v) S.PlayerColor=v end)
SVC.NewColorPicker("Animal ESP Color", "Color for animal labels", S.AnimalColor, function(v) S.AnimalColor=v end)
SVC.NewColorPicker("FOV Ring Color",   "Color of the aim circle", FOVC.Color,    function(v) FOVC.Color=v end)

SU.NewToggle("Full Bright",      "Force max lighting",            function(v) S.FullBright=v end)
SU.NewToggle("Instant Interact", "Zero hold duration on prompts", function(v) S.Interact=v end)
SU.NewToggle("TP-Walk",          "Safe teleport movement hack",   function(v) S.TPWalk=v end)
SU.NewSlider("TP Speed",         "TP-Walk speed multiplier", 15, 1, function(v) S.TPSpeed=v end)

SM.NewToggle("God Mode",      "Infinite HP — 1e308 health",          function(v) S.GodMode=v;  SetGodMode(v) end)
SM.NewToggle("Spawn Protect", "Keep spawn shield for 30s",           function(v)
    S.SpawnProt=v
    if v then EnableSpawnProt(LocalPlayer.Character)
    elseif spawnProtConn then spawnProtConn:Disconnect(); spawnProtConn=nil end
end)
SM.NewToggle("Noclip",        "Phase through walls",                 function(v) S.Noclip=v; SetNoclip(v) end)
SM.NewToggle("Speed Boost",   "Override walk speed",                 function(v) S.SpeedBoost=v; ApplySpeed() end)
SM.NewSlider("Walk Speed",    "Speed value (default 16)", 100, 16,   function(v) S.SpeedVal=v; ApplySpeed() end)

-- ── PROXIMITY ─────────────────────────────────────────────
PPS.PromptShown:Connect(function(p)
    if S.Interact then p.HoldDuration = 0 end
end)

-- ── BOOT NOTIFICATION ─────────────────────────────────────
pcall(function()
    SGui:SetCore("SendNotification", {
        Title    = "Glass West  [ ARMED ]",
        Text     = "All systems online  ·  RightCtrl = Hide/Show",
        Duration = 5,
    })
end)
