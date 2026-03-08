-- ╔══════════════════════════════════════════════╗
--   Mosab Westbound  |  GLASS UI  |  v6 CLEAN
--   RightCtrl = Hide/Show  |  Drag TitleBar
-- ╚══════════════════════════════════════════════╝

local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not ({["mairjdyr"]=true,["omar_35412"]=true})[LocalPlayer.Name] then
    warn("[WEST] ACCESS DENIED"); return
end

local Run   = game:GetService("RunService")
local UIS   = game:GetService("UserInputService")
local Light = game:GetService("Lighting")
local PPS   = game:GetService("ProximityPromptService")
local TW    = game:GetService("TweenService")
local SGui  = game:GetService("StarterGui")
local Cam   = workspace.CurrentCamera

-- ── SETTINGS ─────────────────────────────────
local S = {
    AimPlayers=false, AimAnimals=false, WallCheck=false,
    SilentAim=false, SilentSmooth=0.15, FOV=150, ShowFOV=false,
    PlayerName=false, PlayerHP=false, PlayerBox=false,
    AnimalESP=false, ShowDist=false, ESPDist=10000, TextSize=12,
    PlayerColor=Color3.fromRGB(0,255,180),
    AnimalColor=Color3.fromRGB(255,200,0),
    Interact=false, TPWalk=false, TPSpeed=2,
    FullBright=false, Noclip=false, SpeedBoost=false, SpeedVal=16,
    GodMode=false, SpawnProt=false,
}

local FOVC = Drawing.new("Circle")
FOVC.Thickness=1.5; FOVC.Filled=false
FOVC.Color=Color3.fromRGB(220,30,30); FOVC.Transparency=1; FOVC.Visible=false

-- ── PALETTE ──────────────────────────────────
local C = {
    BG       = Color3.fromRGB(10, 10, 16),
    Panel    = Color3.fromRGB(18, 16, 26),
    Row      = Color3.fromRGB(22, 20, 32),
    Neon     = Color3.fromRGB(220, 35, 35),
    NeonBr   = Color3.fromRGB(255, 70, 70),
    NeonDk   = Color3.fromRGB(55,  8,  8),
    White    = Color3.fromRGB(235, 232, 242),
    Muted    = Color3.fromRGB(130, 125, 155),
    OFF      = Color3.fromRGB(40,  38,  55),
    Green    = Color3.fromRGB(40, 200, 95),
    Border   = Color3.fromRGB(180, 25, 25),
    BorderDk = Color3.fromRGB(45,  25, 55),
}

-- ── HELPERS ──────────────────────────────────
local function tw(obj, t, props)
    TW:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end
local function twS(obj, t, props)
    TW:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props):Play()
end
local function New(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in pairs(props) do o[k]=v end
    if parent then o.Parent=parent end
    return o
end
local function Corner(p, r) New("UICorner",{CornerRadius=UDim.new(0,r or 10)},p) end
local function Outline(p, col, sz, tr)
    New("UIStroke",{Color=col or C.Border, Thickness=sz or 1, Transparency=tr or 0},p)
end
local function Grad(p, a, b, rot)
    New("UIGradient",{Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,a),
        ColorSequenceKeypoint.new(1,b)},Rotation=rot or 90},p)
end
local function Pulse(f)
    local s=f.Size
    tw(f,0.07,{Size=UDim2.new(s.X.Scale,s.X.Offset-3,s.Y.Scale,s.Y.Offset-3)})
    task.delay(0.07,function() twS(f,0.22,{Size=s}) end)
end

-- ── GUI ──────────────────────────────────────
local Gui = New("ScreenGui",{
    Name="GlassWest", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Global,
    IgnoreGuiInset=true,
}, LocalPlayer:WaitForChild("PlayerGui"))

-- glow behind window
local Glow = New("Frame",{
    Size=UDim2.new(0,614,0,554),
    Position=UDim2.new(0.5,-307,0.5,-277),
    BackgroundColor3=C.Neon,
    BackgroundTransparency=0.87,
    BorderSizePixel=0, ZIndex=1,
},Gui)
Corner(Glow,14)

local Win = New("Frame",{
    Size=UDim2.new(0,600,0,540),
    Position=UDim2.new(0.5,-300,0.5,-270),
    BackgroundColor3=C.BG,
    BackgroundTransparency=0.08,
    BorderSizePixel=0,
    ClipsDescendants=false, ZIndex=2,
},Gui)
Corner(Win,10)
Grad(Win, Color3.fromRGB(16,12,24), Color3.fromRGB(8,8,14), 140)
Outline(Win, C.Border, 1.5, 0)

-- ── TITLEBAR ─────────────────────────────────
local TBar = New("Frame",{
    Size=UDim2.new(1,0,0,46),
    BackgroundColor3=C.NeonDk,
    BorderSizePixel=0, ZIndex=3,
},Win)
Corner(TBar,10)
Grad(TBar, Color3.fromRGB(80,8,8), Color3.fromRGB(28,4,4), 180)
-- square off bottom corners
New("Frame",{Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),
    BackgroundColor3=Color3.fromRGB(28,4,4),BorderSizePixel=0,ZIndex=3},TBar)
-- accent line
New("Frame",{Size=UDim2.new(1,-32,0,1),Position=UDim2.new(0,16,1,-1),
    BackgroundColor3=C.NeonBr,BorderSizePixel=0,ZIndex=4},TBar)
New("TextLabel",{
    Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,14,0,0),
    BackgroundTransparency=1,
    Text="MOSAB WESTBOUND  ·  "..LocalPlayer.Name.."  ·  ONLINE",
    TextColor3=C.White,TextSize=12,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left,
    TextStrokeTransparency=0.5,TextStrokeColor3=C.Neon, ZIndex=4,
},TBar)

local XBtn = New("TextButton",{
    Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-36,0.5,-14),
    BackgroundColor3=C.NeonDk,Text="X",TextColor3=C.White,
    TextSize=13,Font=Enum.Font.GothamBold,
    BorderSizePixel=0,AutoButtonColor=false, ZIndex=5,
},TBar)
Corner(XBtn,6)
Outline(XBtn,C.NeonBr,1,0.4)
XBtn.MouseEnter:Connect(function() tw(XBtn,0.12,{BackgroundColor3=C.Neon}) end)
XBtn.MouseLeave:Connect(function() tw(XBtn,0.12,{BackgroundColor3=C.NeonDk}) end)
XBtn.MouseButton1Click:Connect(function() Pulse(XBtn); task.delay(0.12,function() Gui:Destroy() end) end)

-- ── DRAG ─────────────────────────────────────
do
    local drag,ds,ws=false,nil,nil
    TBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; ds=i.Position; ws=Win.Position
        end
    end)
    TBar.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            Win.Position=UDim2.new(ws.X.Scale,ws.X.Offset+d.X,ws.Y.Scale,ws.Y.Offset+d.Y)
            Glow.Position=UDim2.new(ws.X.Scale,ws.X.Offset+d.X-7,ws.Y.Scale,ws.Y.Offset+d.Y-7)
        end
    end)
end

UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.RightControl then
        Win.Visible=not Win.Visible; Glow.Visible=Win.Visible
    end
end)

-- ── STATUS BAR ───────────────────────────────
local SBar=New("Frame",{
    Size=UDim2.new(1,-20,0,32),Position=UDim2.new(0,10,0,52),
    BackgroundColor3=C.Panel,BackgroundTransparency=0.3,
    BorderSizePixel=0, ZIndex=3,
},Win)
Corner(SBar,7)
Outline(SBar,C.BorderDk,1,0.2)
for i,d in ipairs({
    {0,     "THREAT","ELEVATED",C.Neon},
    {0.33,  "CIPHER","AES-256", C.Green},
    {0.66,  "TOKEN", tostring(math.random(1e5,9e5)), C.White},
}) do
    local f=New("Frame",{Size=UDim2.new(0.33,0,1,0),Position=UDim2.new(d[1],0,0,0),
        BackgroundTransparency=1,ZIndex=3},SBar)
    New("TextLabel",{Size=UDim2.new(1,0,0.45,0),BackgroundTransparency=1,
        Text=d[2],TextColor3=C.Muted,TextSize=9,Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=3},f)
    New("TextLabel",{Size=UDim2.new(1,0,0.55,0),Position=UDim2.new(0,0,0.45,0),
        BackgroundTransparency=1,Text=d[3],TextColor3=d[4],TextSize=11,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=3},f)
end

-- divider
New("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,90),
    BackgroundColor3=C.BorderDk,BorderSizePixel=0,ZIndex=3},Win)

-- ── TAB BAR ──────────────────────────────────
local TabBar=New("Frame",{
    Size=UDim2.new(1,-20,0,34),Position=UDim2.new(0,10,0,96),
    BackgroundTransparency=1,BorderSizePixel=0,ZIndex=3,
},Win)
New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5)},TabBar)

-- ── SCROLL ───────────────────────────────────
local Scroll=New("ScrollingFrame",{
    Size=UDim2.new(1,-20,1,-138),Position=UDim2.new(0,10,0,136),
    BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=3,
    ScrollBarImageColor3=Color3.fromRGB(180,25,25),
    CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ClipsDescendants=true, ZIndex=3,
},Win)
New("UIPadding",{PaddingBottom=UDim.new(0,10)},Scroll)
New("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},Scroll)

-- ╔══════════════════════════════════════════════╗
--   COLOR PICKER POPUP
-- ╚══════════════════════════════════════════════╝
local CPop=New("Frame",{
    Size=UDim2.new(0,240,0,155),
    BackgroundColor3=C.Panel,BackgroundTransparency=0.05,
    BorderSizePixel=0,Visible=false,ZIndex=500,
},Gui)
Corner(CPop,10)
Outline(CPop,C.NeonBr,1.5,0)
Grad(CPop,Color3.fromRGB(28,14,28),Color3.fromRGB(10,10,18),130)

New("TextLabel",{
    Size=UDim2.new(1,-26,0,18),Position=UDim2.new(0,10,0,4),
    BackgroundTransparency=1,Text="COLOR EDITOR",
    TextColor3=C.NeonBr,TextSize=11,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=501,
},CPop)
local cpX=New("TextButton",{
    Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-26,0,2),
    BackgroundColor3=C.NeonDk,Text="X",TextColor3=C.White,
    TextSize=11,Font=Enum.Font.GothamBold,BorderSizePixel=0,
    AutoButtonColor=false,ZIndex=502,
},CPop)
Corner(cpX,5)
cpX.MouseButton1Click:Connect(function() CPop.Visible=false end)

local cpRGB={r=255,g=255,b=255}
local cpCBs={}
local cpSliders={}

for idx,ch in ipairs({
    {k="r",lbl="R",col=Color3.fromRGB(230,60,60)},
    {k="g",lbl="G",col=Color3.fromRGB(60,200,80)},
    {k="b",lbl="B",col=Color3.fromRGB(60,130,230)},
}) do
    local y=24+(idx-1)*38
    New("TextLabel",{
        Size=UDim2.new(0,12,0,12),Position=UDim2.new(0,8,0,y+10),
        BackgroundTransparency=1,Text=ch.lbl,TextColor3=ch.col,
        TextSize=11,Font=Enum.Font.GothamBold,ZIndex=501,
    },CPop)
    local valLbl=New("TextLabel",{
        Size=UDim2.new(0,30,0,12),Position=UDim2.new(1,-38,0,y+10),
        BackgroundTransparency=1,Text="255",TextColor3=C.White,
        TextSize=10,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right,ZIndex=501,
    },CPop)
    local tr=New("Frame",{
        Size=UDim2.new(1,-54,0,12),Position=UDim2.new(0,22,0,y+11),
        BackgroundColor3=C.NeonDk,BorderSizePixel=0,ZIndex=501,
    },CPop)
    Corner(tr,6)
    local fi=New("Frame",{
        Size=UDim2.new(1,0,1,0),BackgroundColor3=ch.col,
        BorderSizePixel=0,ZIndex=502,
    },tr)
    Corner(fi,6)
    -- cp track button
    local cpBtn=New("TextButton",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=503,
    },tr)

    local cpSliding=false
    local function cpSet(px)
        local pct=math.clamp((px-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        cpRGB[ch.k]=math.floor(pct*255)
        fi.Size=UDim2.new(pct,0,1,0)
        valLbl.Text=tostring(cpRGB[ch.k])
        local col=Color3.fromRGB(cpRGB.r,cpRGB.g,cpRGB.b)
        for _,cb in ipairs(cpCBs) do cb(col) end
    end
    cpBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            cpSliding=true; cpSet(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then cpSliding=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if cpSliding and i.UserInputType==Enum.UserInputType.MouseMovement then
            cpSet(i.Position.X)
        end
    end)
    cpSliders[ch.k]={tr=tr,fi=fi,vl=valLbl}
end

local cpPrev=New("Frame",{
    Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,8,1,-20),
    BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=501,
},CPop)
Corner(cpPrev,5)

local function OpenCP(anchor,curCol,onCh)
    cpRGB.r=math.floor(curCol.R*255)
    cpRGB.g=math.floor(curCol.G*255)
    cpRGB.b=math.floor(curCol.B*255)
    for _,ch in ipairs({"r","g","b"}) do
        local v=cpRGB[ch]
        cpSliders[ch].fi.Size=UDim2.new(v/255,0,1,0)
        cpSliders[ch].vl.Text=tostring(v)
    end
    cpPrev.BackgroundColor3=curCol
    cpCBs={onCh,function(c) cpPrev.BackgroundColor3=c end}
    local ap=anchor.AbsolutePosition
    local ss=Gui.AbsoluteSize
    local px=math.clamp(ap.X-125,4,ss.X-244)
    local py=ap.Y+anchor.AbsoluteSize.Y+6
    if py+160>ss.Y then py=ap.Y-160 end
    CPop.Position=UDim2.new(0,px,0,py)
    CPop.Visible=true
end

-- ╔══════════════════════════════════════════════╗
--   TAB SYSTEM
-- ╚══════════════════════════════════════════════╝
local TPages,TBtns={},{}

local function SwitchTab(name)
    for n,pg in pairs(TPages) do pg.Visible=(n==name) end
    for n,b  in pairs(TBtns)  do
        if n==name then tw(b,0.15,{BackgroundColor3=C.Neon,TextColor3=C.White})
        else tw(b,0.15,{BackgroundColor3=C.NeonDk,TextColor3=C.Muted}) end
    end
    CPop.Visible=false
end

local function MakeTab(name)
    local btn=New("TextButton",{
        Size=UDim2.new(0,115,1,0),BackgroundColor3=C.NeonDk,
        Text=name,TextColor3=C.Muted,TextSize=12,Font=Enum.Font.GothamBold,
        BorderSizePixel=0,AutoButtonColor=false,ZIndex=4,
    },TabBar)
    Corner(btn,7)
    Outline(btn,C.BorderDk,1,0.3)
    local pg=New("Frame",{
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,Visible=false,BorderSizePixel=0,
        ZIndex=3,
    },Scroll)
    New("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},pg)
    btn.MouseEnter:Connect(function()
        if not TPages[name].Visible then tw(btn,0.1,{BackgroundColor3=Color3.fromRGB(90,12,12)}) end
    end)
    btn.MouseLeave:Connect(function()
        if not TPages[name].Visible then tw(btn,0.1,{BackgroundColor3=C.NeonDk}) end
    end)
    btn.MouseButton1Click:Connect(function() Pulse(btn); SwitchTab(name) end)
    TPages[name]=pg; TBtns[name]=btn
    return pg
end

-- ╔══════════════════════════════════════════════╗
--   SECTION + WIDGETS
-- ╚══════════════════════════════════════════════╝
local function MakeSection(page, title)
    local sec=New("Frame",{
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=C.Panel,BackgroundTransparency=0.2,
        BorderSizePixel=0,ZIndex=4,Parent=page,
    })
    Corner(sec,9)
    Outline(sec,C.BorderDk,1,0.15)
    Grad(sec,Color3.fromRGB(22,14,30),Color3.fromRGB(10,10,16),140)
    New("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),
        PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},sec)
    New("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},sec)

    -- header
    local hdr=New("Frame",{
        Size=UDim2.new(1,0,0,26),BackgroundColor3=C.NeonDk,
        BackgroundTransparency=0.05,BorderSizePixel=0,LayoutOrder=0,ZIndex=5,Parent=sec,
    })
    Corner(hdr,6)
    Grad(hdr,Color3.fromRGB(75,8,8),Color3.fromRGB(30,4,4),180)
    Outline(hdr,C.Neon,1,0.4)
    New("TextLabel",{
        Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1,Text=title,
        TextColor3=C.NeonBr,TextSize=11,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextStrokeTransparency=0.5,TextStrokeColor3=C.Neon,ZIndex=5,
    },hdr)

    local order=0
    local function nxt() order=order+1; return order end

    -- ── ROW ──────────────────────────────────
    local function MakeRow(h)
        local r=New("Frame",{
            Size=UDim2.new(1,0,0,h),BackgroundColor3=C.Row,
            BackgroundTransparency=0.3,BorderSizePixel=0,
            LayoutOrder=nxt(),ZIndex=5,Parent=sec,
        })
        Corner(r,7)
        Outline(r,C.BorderDk,1,0.5)
        return r
    end

    -- ── TOGGLE (iOS switch) ───────────────────
    local function NewToggle(lbl, desc, cb)
        local row=MakeRow(50)

        New("TextLabel",{
            Size=UDim2.new(1,-68,0,20),Position=UDim2.new(0,12,0,6),
            BackgroundTransparency=1,Text=lbl,
            TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextStrokeTransparency=0.6,TextStrokeColor3=Color3.new(0,0,0),ZIndex=6,
        },row)
        New("TextLabel",{
            Size=UDim2.new(1,-68,0,14),Position=UDim2.new(0,12,0,27),
            BackgroundTransparency=1,Text=desc,
            TextColor3=C.Muted,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6,
        },row)

        -- pill
        local pill=New("Frame",{
            Size=UDim2.new(0,44,0,22),Position=UDim2.new(1,-54,0.5,-11),
            BackgroundColor3=C.OFF,BorderSizePixel=0,ZIndex=6,
        },row)
        Corner(pill,11)
        Outline(pill,C.BorderDk,1,0.3)

        local knob=New("Frame",{
            Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,2,0.5,-9),
            BackgroundColor3=C.Muted,BorderSizePixel=0,ZIndex=7,
        },pill)
        Corner(knob,9)

        -- full row clickable button
        local btn=New("TextButton",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=8,
        },row)

        local state=false
        btn.MouseEnter:Connect(function() tw(row,0.12,{BackgroundTransparency=0.1}) end)
        btn.MouseLeave:Connect(function() tw(row,0.12,{BackgroundTransparency=0.3}) end)
        btn.MouseButton1Click:Connect(function()
            state=not state; cb(state); Pulse(row)
            if state then
                tw(pill,0.18,{BackgroundColor3=C.Neon})
                tw(knob,0.18,{Position=UDim2.new(1,-20,0.5,-9),BackgroundColor3=C.White})
            else
                tw(pill,0.18,{BackgroundColor3=C.OFF})
                tw(knob,0.18,{Position=UDim2.new(0,2,0.5,-9),BackgroundColor3=C.Muted})
            end
        end)
    end

    -- ── SLIDER ───────────────────────────────
    -- المشكلة القديمة: ZIndex عالي على hitbox كان يغطي track
    -- الحل: نستخدم UIS.InputBegan على مستوى global ونتحقق إذا الماوس فوق الـ track
    local function NewSlider(lbl, desc, maxV, minV, cb)
        local row=MakeRow(70)

        New("TextLabel",{
            Size=UDim2.new(0.65,0,0,20),Position=UDim2.new(0,12,0,6),
            BackgroundTransparency=1,Text=lbl,
            TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextStrokeTransparency=0.6,TextStrokeColor3=Color3.new(0,0,0),ZIndex=6,
        },row)

        local vLbl=New("TextLabel",{
            Size=UDim2.new(0.35,-12,0,20),Position=UDim2.new(0.65,0,0,6),
            BackgroundTransparency=1,Text=tostring(minV),
            TextColor3=C.NeonBr,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Right,ZIndex=6,
        },row)

        New("TextLabel",{
            Size=UDim2.new(1,-24,0,13),Position=UDim2.new(0,12,0,27),
            BackgroundTransparency=1,Text=desc,
            TextColor3=C.Muted,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6,
        },row)

        -- track background
        local track=New("Frame",{
            Size=UDim2.new(1,-24,0,14),Position=UDim2.new(0,12,0,46),
            BackgroundColor3=C.NeonDk,BorderSizePixel=0,ZIndex=6,
        },row)
        Corner(track,7)
        Outline(track,C.BorderDk,1,0.4)

        -- fill
        local fill=New("Frame",{
            Size=UDim2.new(0,0,1,0),BackgroundColor3=C.Neon,
            BorderSizePixel=0,ZIndex=7,
        },track)
        Corner(fill,7)
        Grad(fill,C.NeonBr,C.Neon,180)

        -- knob dot — child of track (not fill) so position is absolute within track
        local dot=New("Frame",{
            Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,-8,0.5,-8),
            BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=8,
        },track)
        Corner(dot,8)
        Outline(dot,C.Muted,1,0.3)

        local curPct=0
        local function SetVal(v)
            v=math.clamp(math.floor(v),minV,maxV)
            curPct= (maxV==minV) and 0 or (v-minV)/(maxV-minV)
            fill.Size=UDim2.new(curPct,0,1,0)
            -- move dot to right edge of fill
            dot.Position=UDim2.new(curPct,-8,0.5,-8)
            vLbl.Text=tostring(v)
            cb(v)
        end
        SetVal(minV)

        -- ── INPUT: use UIS global so no ZIndex interference ──
        local sliding=false

        -- hover
        local hbtn=New("TextButton",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=7,
        },row)
        hbtn.MouseEnter:Connect(function() tw(row,0.12,{BackgroundTransparency=0.1}) end)
        hbtn.MouseLeave:Connect(function() tw(row,0.12,{BackgroundTransparency=0.3}) end)

        -- detect click on track area using global UIS
        UIS.InputBegan:Connect(function(i, gp)
            if gp then return end
            if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            local mp = i.Position
            local ap = track.AbsolutePosition
            local as = track.AbsoluteSize
            -- check if mouse is within track bounds (with small padding)
            if mp.X >= ap.X-4 and mp.X <= ap.X+as.X+4
            and mp.Y >= ap.Y-6 and mp.Y <= ap.Y+as.Y+6 then
                sliding = true
                local pct=math.clamp((mp.X-ap.X)/as.X, 0, 1)
                SetVal(minV + pct*(maxV-minV))
            end
        end)

        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                sliding=false
            end
        end)

        UIS.InputChanged:Connect(function(i)
            if not sliding then return end
            if i.UserInputType~=Enum.UserInputType.MouseMovement then return end
            local ap=track.AbsolutePosition
            local as=track.AbsoluteSize
            local pct=math.clamp((i.Position.X-ap.X)/as.X, 0, 1)
            SetVal(minV + pct*(maxV-minV))
        end)
    end

    -- ── COLOR PICKER ─────────────────────────
    local function NewColorPicker(lbl, desc, defCol, cb)
        local row=MakeRow(50)
        New("TextLabel",{
            Size=UDim2.new(1,-72,0,20),Position=UDim2.new(0,12,0,6),
            BackgroundTransparency=1,Text=lbl,
            TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextStrokeTransparency=0.6,TextStrokeColor3=Color3.new(0,0,0),ZIndex=6,
        },row)
        New("TextLabel",{
            Size=UDim2.new(1,-72,0,14),Position=UDim2.new(0,12,0,27),
            BackgroundTransparency=1,Text=desc,
            TextColor3=C.Muted,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6,
        },row)
        local cur=defCol
        local sw=New("Frame",{
            Size=UDim2.new(0,40,0,32),Position=UDim2.new(1,-50,0.5,-16),
            BackgroundColor3=defCol,BorderSizePixel=0,ZIndex=6,
        },row)
        Corner(sw,7)
        Outline(sw,C.NeonBr,1.5,0.2)
        local swBtn=New("TextButton",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=7,
        },sw)
        swBtn.MouseButton1Click:Connect(function()
            Pulse(sw)
            if CPop.Visible then CPop.Visible=false
            else
                OpenCP(sw,cur,function(col)
                    cur=col; sw.BackgroundColor3=col; cb(col)
                end)
            end
        end)
    end

    return {NewToggle=NewToggle, NewSlider=NewSlider, NewColorPicker=NewColorPicker}
end

-- ╔══════════════════════════════════════════════╗
--   BUILD TABS
-- ╚══════════════════════════════════════════════╝
local PC = MakeTab("COMBAT")
local PV = MakeTab("VISUALS")
local PW = MakeTab("WORLD")
SwitchTab("COMBAT")

local SA  = MakeSection(PC, "AIMBOT PROTOCOL")
local SPE = MakeSection(PV, "PLAYER SCANNER")
local SWE = MakeSection(PV, "WORLD SCANNER")
local SVC = MakeSection(PV, "DISPLAY CONFIG")
local SU  = MakeSection(PW, "UTILITY MODULE")
local SM  = MakeSection(PW, "MOVEMENT OVERRIDE")

-- ╔══════════════════════════════════════════════╗
--   GAME LOGIC
-- ╚══════════════════════════════════════════════╝
local function GetRoot(o)
    if o:IsA("BasePart") then return o end
    if o:IsA("Model") then
        return o.PrimaryPart
            or o:FindFirstChild("HumanoidRootPart")
            or o:FindFirstChildWhichIsA("BasePart")
    end
end

local function GetDist(pos)
    local c=LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        return math.floor((c.HumanoidRootPart.Position-pos).Magnitude)
    end
    return 0
end

local function IsVis(tp)
    if not tp then return false end
    local c=LocalPlayer.Character
    if not c or not c:FindFirstChild("Head") then return false end
    local p=RaycastParams.new()
    p.FilterDescendantsInstances={c}
    p.FilterType=Enum.RaycastFilterType.Exclude
    p.IgnoreWater=true
    local r=workspace:Raycast(Cam.CFrame.Position,tp.Position-Cam.CFrame.Position,p)
    return r and r.Instance:IsDescendantOf(tp.Parent) or (r==nil)
end

local function AName(o)
    local n=o.Name:lower()
    local pre=n:find("legendary") and "[LEG] " or ""
    local m={{"crow","Crow"},{"dire wolf","Dire Wolf"},{"direwolf","Dire Wolf"},
        {"wolf","Wolf"},{"coyote","Coyote"},{"fox","Fox"},{"grizzly","Grizzly"},
        {"black bear","Black Bear"},{"bear","Bear"},{"bison","Bison"},
        {"buffalo","Bison"},{"buck","Deer"},{"doe","Deer"},{"fawn","Deer"},
        {"deer","Deer"},{"horse","Horse"},{"cow","Cow"},{"cattle","Cow"},
        {"pig","Pig"},{"boar","Boar"},{"rabbit","Rabbit"},{"bunny","Rabbit"},
        {"chicken","Chicken"}}
    for _,e in ipairs(m) do if n:find(e[1]) then return pre..e[2] end end
    return o.Name
end

-- ── AIMBOT ───────────────────────────────────
local function GetTarget()
    local tp,cd=nil,S.FOV
    local center=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
    local function chk(part)
        local pos,vis=Cam:WorldToViewportPoint(part.Position)
        if not vis then return end
        local mag=(Vector2.new(pos.X,pos.Y)-center).Magnitude
        if mag<cd then tp=part; cd=mag end
    end
    if S.AimPlayers then
        for _,v in ipairs(Players:GetPlayers()) do
            if v==LocalPlayer then continue end
            local ch=v.Character; if not ch then continue end
            local hd=ch:FindFirstChild("Head")
            local hum=ch:FindFirstChildOfClass("Humanoid")
            if not hd or not hum or hum.Health<=0 then continue end
            if S.WallCheck and not IsVis(hd) then continue end
            chk(hd)
        end
    end
    if S.AimAnimals then
        for _,fn in ipairs({"Harvestables","Animals","NPCS"}) do
            local folder=workspace:FindFirstChild(fn); if not folder then continue end
            for _,v in ipairs(folder:GetChildren()) do
                if not v:IsA("Model") then continue end
                local hum=v:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health<=0 then continue end
                local rp=GetRoot(v); if not rp then continue end
                if S.WallCheck and not IsVis(rp) then continue end
                chk(rp)
            end
        end
    end
    return tp
end

-- ── ESP ──────────────────────────────────────
local function ManageESP(char, text, color, tag, show, dist, isP)
    local rp=isP
        and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        or GetRoot(char)
    if not rp then return end
    local inRange=isP or (dist<=S.ESPDist)
    local bb=rp:FindFirstChild(tag)
    if show and inRange then
        if not bb then
            bb=Instance.new("BillboardGui"); bb.Name=tag; bb.Adornee=rp
            bb.AlwaysOnTop=true; bb.Size=UDim2.new(0,200,0,60)
            bb.StudsOffset=Vector3.new(0,3,0); bb.Parent=rp
            local lb=Instance.new("TextLabel",bb)
            lb.Name="L"; lb.BackgroundTransparency=1; lb.Size=UDim2.new(1,0,1,0)
            lb.TextStrokeTransparency=0.3; lb.TextStrokeColor3=Color3.new(0,0,0)
            lb.Font=Enum.Font.Code
        end
        local lb=bb:FindFirstChild("L")
        if lb then
            lb.TextSize=S.TextSize; lb.TextColor3=color
            lb.Text=text..(S.ShowDist and ("  ["..dist.."m]") or "")
        end
    else
        if bb then bb:Destroy() end
    end
end

local function CleanAESP()
    for _,fn in ipairs({"Harvestables","Animals","NPCS"}) do
        local f=workspace:FindFirstChild(fn); if not f then continue end
        for _,a in ipairs(f:GetChildren()) do
            local rp=GetRoot(a)
            if rp then local t=rp:FindFirstChild("GWANIM"); if t then t:Destroy() end end
        end
    end
end

-- Animal ESP
task.spawn(function()
    while true do task.wait(1)
        if not S.AnimalESP then continue end
        for _,fn in ipairs({"Harvestables","Animals","NPCS"}) do
            local folder=workspace:FindFirstChild(fn); if not folder then continue end
            for _,v in ipairs(folder:GetChildren()) do
                if not v:IsA("Model") then continue end
                local rp=GetRoot(v); if not rp then continue end
                local hum=v:FindFirstChildOfClass("Humanoid")
                local lb=AName(v)
                if hum and hum.Health<=0 then lb="[DEAD] "..lb end
                ManageESP(v,lb,S.AnimalColor,"GWANIM",true,GetDist(rp.Position),false)
            end
        end
    end
end)

-- Player ESP
task.spawn(function()
    while true do task.wait(0.1)
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LocalPlayer then continue end
            local c=p.Character; if not c then continue end
            local hum=c:FindFirstChildOfClass("Humanoid")
            local rp=c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
            if rp and hum and hum.Health>0 then
                local dist=GetDist(rp.Position)
                local show=S.PlayerName or S.PlayerHP
                local txt=""
                if S.PlayerName then txt="[ "..p.Name.." ]" end
                if S.PlayerHP then txt=txt..(txt~="" and "\n" or "").."HP "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth) end
                ManageESP(c,txt,S.PlayerColor,"GWPLYR",show,dist,true)
                local hl=c:FindFirstChild("GWPH")
                if S.PlayerBox then
                    if not hl then hl=Instance.new("Highlight"); hl.Name="GWPH"; hl.Parent=c end
                    hl.FillColor=S.PlayerColor; hl.FillTransparency=0.65
                    hl.OutlineColor=C.Neon; hl.OutlineTransparency=0
                elseif hl then hl:Destroy() end
            else
                local b=c:FindFirstChild("GWPLYR",true); if b then b:Destroy() end
                local hl=c:FindFirstChild("GWPH"); if hl then hl:Destroy() end
            end
        end
    end
end)

-- ── NOCLIP ───────────────────────────────────
local noclipConn
local function SetNoclip(on)
    if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
    local char=LocalPlayer.Character; if not char then return end
    if on then
        local function off(p) if p:IsA("BasePart") then p.CanCollide=false end end
        for _,p in ipairs(char:GetDescendants()) do off(p) end
        noclipConn=char.DescendantAdded:Connect(off)
    else
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=true end
        end
    end
end

-- ── SPEED ────────────────────────────────────
local function ApplySpeed()
    local c=LocalPlayer.Character; if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed=S.SpeedBoost and S.SpeedVal or 16 end
end

-- ── GOD MODE ─────────────────────────────────
local godConns={}

local function ApplyGodMode(char)
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local maxHP=hum.MaxHealth

    -- Layer 1: hookmetamethod — block damage remotes (Synapse/Xeno support)
    pcall(function()
        if hookmetamethod then
            local dmgWords={"damage","dmg","hit","hurt","takedmg","takedamage","dealdam"}
            hookmetamethod(game,"__namecall",function(self,...)
                local method=getnamecallmethod()
                if S.GodMode
                and (method=="FireServer" or method=="InvokeServer")
                and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
                    local low=self.Name:lower()
                    for _,w in ipairs(dmgWords) do
                        if low:find(w) then return end
                    end
                end
                return (select(1,...)) -- original call passthrough not possible without storing orig
            end)
        end
    end)

    -- Layer 2: Heartbeat — restore HP every frame
    local c1=Run.Heartbeat:Connect(function()
        if not S.GodMode or not hum.Parent then return end
        if hum.Health < maxHP then
            hum.Health = maxHP
        end
    end)

    -- Layer 3: block BreakJoints
    local c2=char.ChildAdded:Connect(function(obj)
        if not S.GodMode then return end
        if obj.Name=="BreakJointsOnDeath" or obj.Name=="BreakJoints" then
            task.defer(function() pcall(function() obj:Destroy() end) end)
        end
    end)

    table.insert(godConns,c1)
    table.insert(godConns,c2)
end

local function RemoveGodMode()
    for _,c in ipairs(godConns) do pcall(function() c:Disconnect() end) end
    table.clear(godConns)
end

local function SetGodMode(on)
    RemoveGodMode()
    if on then ApplyGodMode(LocalPlayer.Character) end
end

-- ── SPAWN PROTECTION ─────────────────────────
local spawnProtConn
local function EnableSpawnProt(char)
    if spawnProtConn then spawnProtConn:Disconnect(); spawnProtConn=nil end
    if not char then return end
    local active=true
    task.delay(32,function() active=false end)
    spawnProtConn=char.ChildAdded:Connect(function(obj)
        if not active or not obj:IsA("Tool") then return end
        task.defer(function()
            local bp=LocalPlayer:FindFirstChildOfClass("Backpack")
            if bp and obj and obj.Parent==char then obj.Parent=bp end
        end)
    end)
    task.spawn(function()
        while active do task.wait(0.5)
            local c2=LocalPlayer.Character; if not c2 then break end
            local tool=c2:FindFirstChildOfClass("Tool")
            local bp=LocalPlayer:FindFirstChildOfClass("Backpack")
            if tool and bp then tool.Parent=bp end
        end
    end)
end

-- ── CHARACTER ADDED ──────────────────────────
LocalPlayer.CharacterAdded:Connect(function(c)
    table.clear(godConns)
    task.wait(0.3)
    if S.GodMode    then ApplyGodMode(c) end
    if S.SpawnProt  then EnableSpawnProt(c) end
    if S.SpeedBoost then
        local h=c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed=S.SpeedVal end
    end
    if S.Noclip then task.wait(0.1); SetNoclip(true) end
end)

-- ── RENDER LOOP ──────────────────────────────
Run.RenderStepped:Connect(function()
    -- FOV circle
    FOVC.Visible=S.ShowFOV
    FOVC.Radius=S.FOV
    FOVC.Position=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)

    -- Aimbot
    local ap=GetTarget()
    if ap then
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            Cam.CFrame=CFrame.new(Cam.CFrame.Position,ap.Position)
        end
        if S.SilentAim and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,ap.Position),S.SilentSmooth)
        end
    end

    -- TPWalk
    if S.TPWalk then
        local c=LocalPlayer.Character; if c then
            local h=c:FindFirstChildOfClass("Humanoid")
            if h and h.MoveDirection.Magnitude>0 then
                c:TranslateBy(h.MoveDirection*S.TPSpeed*0.1)
            end
        end
    end

    -- FullBright — في RenderStepped مش loop منفصل
    if S.FullBright then
        Light.ClockTime=14
        Light.Brightness=2
        Light.GlobalShadows=false
        Light.FogEnd=100000
    end
end)

-- ╔══════════════════════════════════════════════╗
--   POPULATE UI
-- ╚══════════════════════════════════════════════╝
SA.NewToggle("Target Players",   "RMB — Lock onto players",           function(v) S.AimPlayers=v end)
SA.NewToggle("Target Animals",   "RMB — Lock onto wildlife",          function(v) S.AimAnimals=v end)
SA.NewToggle("Wall Check",       "Only aim at visible targets",       function(v) S.WallCheck=v end)
SA.NewToggle("Silent Fire",      "LMB — Smooth silent aim",           function(v) S.SilentAim=v end)
SA.NewSlider("FOV Radius",       "Aim radius in pixels", 800, 10,    function(v) S.FOV=v end)
SA.NewSlider("Silent Smoothing", "1=instant  50=smooth", 50,  1,     function(v) S.SilentSmooth=v/100 end)
SA.NewToggle("Show FOV Ring",    "Render FOV circle on screen",       function(v) S.ShowFOV=v end)

SPE.NewToggle("Name ESP",   "Show player username",        function(v) S.PlayerName=v end)
SPE.NewToggle("Health ESP", "Show HP / Max HP",            function(v) S.PlayerHP=v end)
SPE.NewToggle("Box ESP",    "Highlight player silhouette", function(v) S.PlayerBox=v end)

SWE.NewToggle("Animal ESP",    "Track all wildlife",           function(v) S.AnimalESP=v; if not v then CleanAESP() end end)
SWE.NewToggle("Show Distance", "Display range to target",      function(v) S.ShowDist=v end)

SVC.NewSlider("Max Animal Range","Fauna ESP max distance",20000,500, function(v) S.ESPDist=v end)
SVC.NewSlider("Label Size",      "ESP font size",          20,  8,   function(v) S.TextSize=v end)
SVC.NewColorPicker("Player ESP Color","Color for player labels",S.PlayerColor, function(v) S.PlayerColor=v end)
SVC.NewColorPicker("Animal ESP Color","Color for animal labels",S.AnimalColor, function(v) S.AnimalColor=v end)
SVC.NewColorPicker("FOV Ring Color",  "Color of aim circle",  FOVC.Color,     function(v) FOVC.Color=v end)

SU.NewToggle("Full Bright",      "Force max lighting",             function(v) S.FullBright=v end)
SU.NewToggle("Instant Interact", "Zero hold on prompts",           function(v) S.Interact=v end)
SU.NewToggle("TP-Walk",          "Teleport movement hack",         function(v) S.TPWalk=v end)
SU.NewSlider("TP Speed",         "TP-Walk speed multiplier",15,1,  function(v) S.TPSpeed=v end)

SM.NewToggle("God Mode",      "Max HP restored every frame",       function(v) S.GodMode=v; SetGodMode(v) end)
SM.NewToggle("Spawn Protect", "Keep spawn shield for 30s",         function(v)
    S.SpawnProt=v
    if v then EnableSpawnProt(LocalPlayer.Character)
    elseif spawnProtConn then spawnProtConn:Disconnect(); spawnProtConn=nil end
end)
SM.NewToggle("Noclip",        "Phase through walls",               function(v) S.Noclip=v; SetNoclip(v) end)
SM.NewToggle("Speed Boost",   "Override walk speed",               function(v) S.SpeedBoost=v; ApplySpeed() end)
SM.NewSlider("Walk Speed",    "Speed value (default 16)",100,16,   function(v) S.SpeedVal=v; ApplySpeed() end)

-- ── PROXIMITY ────────────────────────────────
PPS.PromptShown:Connect(function(p)
    if S.Interact then p.HoldDuration=0 end
end)

-- ── BOOT ─────────────────────────────────────
pcall(function()
    SGui:SetCore("SendNotification",{
        Title="Glass West  [ ARMED ]",
        Text="All systems online  ·  RightCtrl = Hide/Show",
        Duration=5,
    })
end)
