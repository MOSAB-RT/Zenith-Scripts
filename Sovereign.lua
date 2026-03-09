-- ╔══════════════════════════════════════════════╗
--   MOSAB WESTBOUND  |  GLASS UI  |  v8
--   Dark Navy · Animated · RightCtrl = Hide/Show
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

local S = {
    AimPlayers=false, AimAnimals=false, WallCheck=false,
    SilentAim=false, SilentSmooth=0.15, FOV=150, ShowFOV=false,
    PlayerName=false, PlayerHP=false, PlayerBox=false,
    AnimalESP=false, ShowDist=false, ESPDist=10000, TextSize=12,
    PlayerColor=Color3.fromRGB(0,200,255),
    AnimalColor=Color3.fromRGB(255,200,0),
    Interact=false, TPWalk=false, TPSpeed=2,
    FullBright=false, Noclip=false, SpeedBoost=false, SpeedVal=16,
}

local FOVC = Drawing.new("Circle")
FOVC.Thickness=1.5; FOVC.Filled=false
FOVC.Color=Color3.fromRGB(30,120,255); FOVC.Transparency=1; FOVC.Visible=false

-- ── DARK NAVY COLOR PALETTE ───────────────────
local C = {
    BG      = Color3.fromRGB(4,6,18),
    Panel   = Color3.fromRGB(8,12,28),
    Row     = Color3.fromRGB(12,18,40),
    Neon    = Color3.fromRGB(20,100,255),
    NeonBr  = Color3.fromRGB(80,170,255),
    NeonDk  = Color3.fromRGB(5,18,55),
    White   = Color3.fromRGB(220,230,255),
    Muted   = Color3.fromRGB(90,110,160),
    OFF     = Color3.fromRGB(20,25,50),
    Green   = Color3.fromRGB(40,200,95),
    Border  = Color3.fromRGB(20,80,200),
    BorderDk= Color3.fromRGB(8,18,55),
    Accent  = Color3.fromRGB(0,60,160),
}

-- ── HELPERS ──────────────────────────────────
local function tw(o,t,p,style,dir)
    TW:Create(o,TweenInfo.new(t,style or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),p):Play()
end
local function twS(o,t,p) tw(o,t,p,Enum.EasingStyle.Back,Enum.EasingDirection.Out) end
local function twE(o,t,p) tw(o,t,p,Enum.EasingStyle.Elastic,Enum.EasingDirection.Out) end
local function twC(o,t,p) tw(o,t,p,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out) end

local function New(cls,props,parent)
    local o=Instance.new(cls)
    for k,v in pairs(props) do o[k]=v end
    if parent then o.Parent=parent end
    return o
end
local function Corner(p,r) New("UICorner",{CornerRadius=UDim.new(0,r or 10)},p) end
local function Outline(p,col,sz,tr) New("UIStroke",{Color=col or C.Border,Thickness=sz or 1,Transparency=tr or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p) end
local function Grad(p,a,b,rot)
    New("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,a),ColorSequenceKeypoint.new(1,b)},Rotation=rot or 90},p)
end

local function Pulse(f)
    local s=f.Size
    tw(f,0.06,{Size=UDim2.new(s.X.Scale,s.X.Offset-4,s.Y.Scale,s.Y.Offset-4)})
    task.delay(0.06,function() twS(f,0.25,{Size=s}) end)
end

-- Shimmer effect on a frame
local function AddShimmer(parent)
    local sh=New("Frame",{
        Size=UDim2.new(0,60,1,0),Position=UDim2.new(-0.1,0,0,0),
        BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.85,
        BorderSizePixel=0,ZIndex=parent.ZIndex+5,ClipsDescendants=false,
    },parent)
    Corner(sh,4)
    New("UIGradient",{
        Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(0.5,Color3.fromRGB(150,180,255)),
            ColorSequenceKeypoint.new(1,Color3.new(1,1,1)),
        },
        Transparency=NumberSequence.new{
            NumberSequenceKeypoint.new(0,1),
            NumberSequenceKeypoint.new(0.5,0.7),
            NumberSequenceKeypoint.new(1,1),
        },
        Rotation=80,
    },sh)
    -- Animate shimmer loop
    local function shimmerLoop()
        sh.Position=UDim2.new(-0.15,0,0,0)
        tw(sh,1.4,{Position=UDim2.new(1.15,0,0,0)},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
        task.delay(3.5,shimmerLoop)
    end
    task.delay(math.random()*2,shimmerLoop)
end

-- Glow pulse on borders
local function AddGlowPulse(stroke)
    local function glowLoop()
        tw(stroke,1.2,{Transparency=0.3},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
        task.delay(1.2,function()
            tw(stroke,1.2,{Transparency=0.7},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            task.delay(1.2,glowLoop)
        end)
    end
    glowLoop()
end

-- ── GUI ROOT ─────────────────────────────────
local Gui=New("ScreenGui",{
    Name="GlassWestV8",ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Global,
    IgnoreGuiInset=true,
},LocalPlayer:WaitForChild("PlayerGui"))

-- Window — start tiny for intro anim
local Win=New("Frame",{
    Size=UDim2.new(0,0,0,0),
    Position=UDim2.new(0.5,0,0.5,0),
    AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundColor3=C.BG,BackgroundTransparency=0.04,
    BorderSizePixel=0,ClipsDescendants=false,ZIndex=10,
},Gui)
Corner(Win,12)
Grad(Win,Color3.fromRGB(10,14,35),Color3.fromRGB(3,5,15),145)
local winStroke=Outline(Win,C.Border,1.5,0.3)
AddGlowPulse(winStroke)

-- Intro: bounce open
task.defer(function()
    twE(Win,0.7,{Size=UDim2.new(0,600,0,540),Position=UDim2.new(0.5,-300,0.5,-270)})
end)

-- Scanline overlay
local sl=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=9,ClipsDescendants=true},Win)
for i=1,20 do
    New("Frame",{
        Size=UDim2.new(1,0,0,1),
        Position=UDim2.new(0,0,(i-1)/20,0),
        BackgroundColor3=Color3.fromRGB(30,80,200),
        BackgroundTransparency=0.97,BorderSizePixel=0,ZIndex=9,
    },sl)
end

-- Corner accent dots
for _,pos in ipairs({{0,0},{1,0},{0,1},{1,1}}) do
    local dot=New("Frame",{
        Size=UDim2.new(0,6,0,6),
        Position=UDim2.new(pos[1],pos[1]==0 and 4 or -10,pos[2],pos[2]==0 and 4 or -10),
        BackgroundColor3=C.NeonBr,BorderSizePixel=0,ZIndex=11,
    },Win)
    Corner(dot,3)
    -- pulse the dots
    task.spawn(function()
        while true do
            tw(dot,0.8,{BackgroundTransparency=0.2},Enum.EasingStyle.Sine)
            task.wait(0.8)
            tw(dot,0.8,{BackgroundTransparency=0.8},Enum.EasingStyle.Sine)
            task.wait(0.8)
        end
    end)
end

-- ── TITLEBAR ─────────────────────────────────
local TBar=New("Frame",{
    Size=UDim2.new(1,0,0,48),BackgroundColor3=C.NeonDk,
    BorderSizePixel=0,ZIndex=11,
},Win)
Corner(TBar,12)
Grad(TBar,Color3.fromRGB(5,30,90),Color3.fromRGB(3,12,40),180)
-- bottom half cover for corner bleed
New("Frame",{Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),
    BackgroundColor3=Color3.fromRGB(3,12,40),BorderSizePixel=0,ZIndex=11},TBar)
-- bottom glow line
local tbarLine=New("Frame",{Size=UDim2.new(1,-40,0,1),Position=UDim2.new(0,20,1,-1),
    BackgroundColor3=C.NeonBr,BorderSizePixel=0,ZIndex=12},TBar)
-- animate line
task.spawn(function()
    while true do
        tw(tbarLine,1.5,{BackgroundColor3=C.Neon,BackgroundTransparency=0.3},Enum.EasingStyle.Sine)
        task.wait(1.5)
        tw(tbarLine,1.5,{BackgroundColor3=C.NeonBr,BackgroundTransparency=0},Enum.EasingStyle.Sine)
        task.wait(1.5)
    end
end)

AddShimmer(TBar)

-- Title icon blip
local iconBlip=New("Frame",{
    Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,14,0.5,-4),
    BackgroundColor3=C.NeonBr,BorderSizePixel=0,ZIndex=14,
},TBar)
Corner(iconBlip,4)
task.spawn(function()
    while true do
        tw(iconBlip,0.5,{BackgroundColor3=C.Neon,BackgroundTransparency=0.1},Enum.EasingStyle.Sine)
        task.wait(0.5)
        tw(iconBlip,0.5,{BackgroundColor3=C.NeonBr,BackgroundTransparency=0},Enum.EasingStyle.Sine)
        task.wait(0.5)
    end
end)

New("TextLabel",{
    Size=UDim2.new(1,-60,1,0),Position=UDim2.new(0,28,0,0),
    BackgroundTransparency=1,
    Text="MOSAB WESTBOUND  ·  "..LocalPlayer.Name.."  ·  ONLINE",
    TextColor3=C.White,TextSize=12,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left,
    TextStrokeTransparency=0.4,TextStrokeColor3=C.Neon,ZIndex=12,
},TBar)

local XBtn=New("TextButton",{
    Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-36,0.5,-14),
    BackgroundColor3=C.NeonDk,Text="✕",TextColor3=C.NeonBr,
    TextSize=14,Font=Enum.Font.GothamBold,
    BorderSizePixel=0,AutoButtonColor=false,ZIndex=13,
},TBar)
Corner(XBtn,7); Outline(XBtn,C.Border,1,0.3)
XBtn.MouseEnter:Connect(function() tw(XBtn,0.15,{BackgroundColor3=Color3.fromRGB(20,60,180)}) end)
XBtn.MouseLeave:Connect(function() tw(XBtn,0.15,{BackgroundColor3=C.NeonDk}) end)
XBtn.MouseButton1Click:Connect(function()
    Pulse(XBtn)
    -- close animation
    twC(Win,0.35,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)})
    task.delay(0.38,function() Gui:Destroy() end)
end)

-- Drag
do
    local drag,ds,ws=false,nil,nil
    TBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;ds=i.Position;ws=Win.Position end
    end)
    TBar.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            Win.Position=UDim2.new(ws.X.Scale,ws.X.Offset+d.X,ws.Y.Scale,ws.Y.Offset+d.Y)
        end
    end)
end

-- Hide/Show with animation
local shown=true
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.RightControl then
        shown=not shown
        if shown then
            Win.Visible=true
            twE(Win,0.5,{Size=UDim2.new(0,600,0,540),Position=UDim2.new(0.5,-300,0.5,-270)})
        else
            twC(Win,0.3,{Size=UDim2.new(0,600,0,0),Position=UDim2.new(0.5,-300,0.5,-270)})
            task.delay(0.31,function() Win.Visible=false end)
        end
    end
end)

-- ── STATUS BAR ───────────────────────────────
local SBar=New("Frame",{
    Size=UDim2.new(1,-20,0,30),Position=UDim2.new(0,10,0,54),
    BackgroundColor3=C.Panel,BackgroundTransparency=0.3,
    BorderSizePixel=0,ZIndex=11,
},Win)
Corner(SBar,7); Outline(SBar,C.BorderDk,1,0.2)
Grad(SBar,Color3.fromRGB(8,18,50),Color3.fromRGB(4,8,25),180)

for _,d in ipairs({
    {0,    "THREAT","ELEVATED", C.NeonBr},
    {0.33, "CIPHER","AES-256",  C.Green},
    {0.66, "TOKEN", tostring(math.random(1e5,9e5)), C.White},
}) do
    local f=New("Frame",{Size=UDim2.new(0.33,0,1,0),Position=UDim2.new(d[1],0,0,0),BackgroundTransparency=1,ZIndex=11},SBar)
    New("TextLabel",{Size=UDim2.new(1,0,0.45,0),BackgroundTransparency=1,Text=d[2],TextColor3=C.Muted,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=11},f)
    New("TextLabel",{Size=UDim2.new(1,0,0.55,0),Position=UDim2.new(0,0,0.45,0),BackgroundTransparency=1,Text=d[3],TextColor3=d[4],TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=11},f)
end

New("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,90),
    BackgroundColor3=C.BorderDk,BorderSizePixel=0,ZIndex=11},Win)

-- ── TAB BAR ──────────────────────────────────
local TabBar=New("Frame",{
    Size=UDim2.new(1,-20,0,34),Position=UDim2.new(0,10,0,96),
    BackgroundTransparency=1,BorderSizePixel=0,ZIndex=11,
},Win)
New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5)},TabBar)

-- ── SCROLL ───────────────────────────────────
local Scroll=New("ScrollingFrame",{
    Size=UDim2.new(1,-20,1,-138),Position=UDim2.new(0,10,0,136),
    BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=3,ScrollBarImageColor3=C.NeonBr,
    CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ClipsDescendants=true,ZIndex=11,
},Win)
New("UIPadding",{PaddingBottom=UDim.new(0,10)},Scroll)
New("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},Scroll)

-- ╔══════════════════════════════════════════════╗
--   COLOR PICKER
-- ╚══════════════════════════════════════════════╝
local CPop=New("Frame",{
    Size=UDim2.new(0,240,0,152),BackgroundColor3=C.Panel,BackgroundTransparency=0.05,
    BorderSizePixel=0,Visible=false,ZIndex=900,
},Gui)
Corner(CPop,10); Outline(CPop,C.NeonBr,1.5,0)
Grad(CPop,Color3.fromRGB(8,18,50),Color3.fromRGB(4,8,25),130)
New("TextLabel",{Size=UDim2.new(1,-26,0,18),Position=UDim2.new(0,10,0,4),BackgroundTransparency=1,
    Text="COLOR EDITOR",TextColor3=C.NeonBr,TextSize=11,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=901},CPop)
local cpX=New("TextButton",{Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-26,0,2),
    BackgroundColor3=C.NeonDk,Text="✕",TextColor3=C.NeonBr,TextSize=11,Font=Enum.Font.GothamBold,
    BorderSizePixel=0,AutoButtonColor=false,ZIndex=902},CPop)
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
    New("TextLabel",{Size=UDim2.new(0,12,0,12),Position=UDim2.new(0,8,0,y+10),
        BackgroundTransparency=1,Text=ch.lbl,TextColor3=ch.col,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=901},CPop)
    local valLbl=New("TextLabel",{Size=UDim2.new(0,30,0,12),Position=UDim2.new(1,-38,0,y+10),
        BackgroundTransparency=1,Text="255",TextColor3=C.White,TextSize=10,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right,ZIndex=901},CPop)
    local tr=New("Frame",{Size=UDim2.new(1,-54,0,12),Position=UDim2.new(0,22,0,y+11),
        BackgroundColor3=C.NeonDk,BorderSizePixel=0,ZIndex=901},CPop)
    Corner(tr,6)
    local fi=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=ch.col,BorderSizePixel=0,ZIndex=902},tr)
    Corner(fi,6)
    local cpBtn=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=903},tr)
    local cpSliding=false
    local function cpSet(px)
        local pct=math.clamp((px-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        cpRGB[ch.k]=math.floor(pct*255); fi.Size=UDim2.new(pct,0,1,0); valLbl.Text=tostring(cpRGB[ch.k])
        local col=Color3.fromRGB(cpRGB.r,cpRGB.g,cpRGB.b)
        for _,cb in ipairs(cpCBs) do cb(col) end
    end
    cpBtn.MouseButton1Down:Connect(function() cpSliding=true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then cpSliding=false end end)
    UIS.InputChanged:Connect(function(i)
        if cpSliding and i.UserInputType==Enum.UserInputType.MouseMovement then cpSet(i.Position.X) end
    end)
    cpSliders[ch.k]={tr=tr,fi=fi,vl=valLbl}
end

local cpPrev=New("Frame",{Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,8,1,-20),
    BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=901},CPop)
Corner(cpPrev,5)

local function OpenCP(anchor,curCol,onCh)
    cpRGB.r=math.floor(curCol.R*255); cpRGB.g=math.floor(curCol.G*255); cpRGB.b=math.floor(curCol.B*255)
    for _,k in ipairs({"r","g","b"}) do
        local v=cpRGB[k]; cpSliders[k].fi.Size=UDim2.new(v/255,0,1,0); cpSliders[k].vl.Text=tostring(v)
    end
    cpPrev.BackgroundColor3=curCol
    cpCBs={onCh,function(c) cpPrev.BackgroundColor3=c end}
    local ap=anchor.AbsolutePosition; local ss=Gui.AbsoluteSize
    local px=math.clamp(ap.X-120,4,ss.X-244)
    local py=ap.Y+anchor.AbsoluteSize.Y+6
    if py+160>ss.Y then py=ap.Y-160 end
    CPop.Position=UDim2.new(0,px,0,py)
    CPop.Size=UDim2.new(0,0,0,152)
    CPop.Visible=true
    twE(CPop,0.4,{Size=UDim2.new(0,240,0,152)})
end

-- ╔══════════════════════════════════════════════╗
--   TABS
-- ╚══════════════════════════════════════════════╝
local TPages,TBtns={},{}
local activeTab=nil

local function SwitchTab(name)
    for n,pg in pairs(TPages) do
        if n==name then
            pg.Visible=true
            -- slide in from right
            pg.Position=UDim2.new(0.3,0,0,0)
            pg.BackgroundTransparency=1
            twC(pg,0.3,{Position=UDim2.new(0,0,0,0)})
        else
            pg.Visible=false
        end
    end
    for n,b in pairs(TBtns) do
        if n==name then
            tw(b,0.2,{BackgroundColor3=C.Neon,TextColor3=C.White})
            twE(b,0.35,{Size=UDim2.new(0,115,1,2)})
            -- underline
            if b:FindFirstChild("UL") then b.UL.BackgroundTransparency=0 end
        else
            tw(b,0.2,{BackgroundColor3=C.NeonDk,TextColor3=C.Muted})
            tw(b,0.2,{Size=UDim2.new(0,115,1,0)})
            if b:FindFirstChild("UL") then b.UL.BackgroundTransparency=1 end
        end
    end
    CPop.Visible=false
    activeTab=name
end

local function MakeTab(name)
    local btn=New("TextButton",{Size=UDim2.new(0,115,1,0),BackgroundColor3=C.NeonDk,
        Text=name,TextColor3=C.Muted,TextSize=12,Font=Enum.Font.GothamBold,
        BorderSizePixel=0,AutoButtonColor=false,ZIndex=12},TabBar)
    Corner(btn,7); Outline(btn,C.BorderDk,1,0.3)
    -- underline accent
    local ul=New("Frame",{
        Name="UL",Size=UDim2.new(0.7,0,0,2),
        Position=UDim2.new(0.15,0,1,-2),
        BackgroundColor3=C.NeonBr,BackgroundTransparency=1,
        BorderSizePixel=0,ZIndex=13,
    },btn)
    Corner(ul,1)

    local pg=New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,Visible=false,BorderSizePixel=0,ZIndex=12},Scroll)
    New("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},pg)

    btn.MouseEnter:Connect(function()
        if activeTab~=name then tw(btn,0.12,{BackgroundColor3=Color3.fromRGB(8,40,120)}) end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab~=name then tw(btn,0.12,{BackgroundColor3=C.NeonDk}) end
    end)
    btn.MouseButton1Click:Connect(function()
        Pulse(btn)
        SwitchTab(name)
    end)
    TPages[name]=pg; TBtns[name]=btn; return pg
end

-- ╔══════════════════════════════════════════════╗
--   SECTION + WIDGETS
-- ╚══════════════════════════════════════════════╝
local function MakeSection(page,title)
    local sec=New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=C.Panel,BackgroundTransparency=0.15,
        BorderSizePixel=0,ZIndex=13,Parent=page})
    Corner(sec,10)
    local secStroke=Outline(sec,C.BorderDk,1,0.2)
    Grad(sec,Color3.fromRGB(10,16,42),Color3.fromRGB(4,8,20),145)
    New("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},sec)
    New("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},sec)

    -- Animated border glow on hover
    sec.MouseEnter:Connect(function()
        tw(secStroke,0.2,{Color=C.Border,Transparency=0,Thickness=1.5})
    end)
    sec.MouseLeave:Connect(function()
        tw(secStroke,0.3,{Color=C.BorderDk,Transparency=0.3,Thickness=1})
    end)

    local hdr=New("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=C.NeonDk,BackgroundTransparency=0.05,
        BorderSizePixel=0,LayoutOrder=0,ZIndex=14,Parent=sec})
    Corner(hdr,7)
    Grad(hdr,Color3.fromRGB(5,30,90),Color3.fromRGB(3,12,45),180)
    Outline(hdr,C.Border,1,0.3)
    AddShimmer(hdr)

    -- Animated dot in header
    local hdot=New("Frame",{
        Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,8,0.5,-3),
        BackgroundColor3=C.NeonBr,BorderSizePixel=0,ZIndex=15,
    },hdr)
    Corner(hdot,3)
    task.spawn(function()
        while true do
            tw(hdot,0.7,{BackgroundTransparency=0.1},Enum.EasingStyle.Sine)
            task.wait(0.7)
            tw(hdot,0.7,{BackgroundTransparency=0.8},Enum.EasingStyle.Sine)
            task.wait(0.7)
        end
    end)

    New("TextLabel",{Size=UDim2.new(1,-18,1,0),Position=UDim2.new(0,18,0,0),BackgroundTransparency=1,
        Text=title,TextColor3=C.NeonBr,TextSize=11,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextStrokeTransparency=0.4,TextStrokeColor3=C.Neon,ZIndex=15},hdr)

    local order=0
    local function nxt() order=order+1; return order end
    local function MakeRow(h)
        local r=New("Frame",{Size=UDim2.new(1,0,0,h),BackgroundColor3=C.Row,
            BackgroundTransparency=0.35,BorderSizePixel=0,LayoutOrder=nxt(),ZIndex=14,Parent=sec})
        Corner(r,8); Outline(r,C.BorderDk,1,0.55)
        return r
    end

    -- ── TOGGLE ───────────────────────────────
    local function NewToggle(lbl,desc,cb)
        local row=MakeRow(50)
        -- indicator strip on left
        local strip=New("Frame",{
            Size=UDim2.new(0,3,0.7,0),Position=UDim2.new(0,0,0.15,0),
            BackgroundColor3=C.Muted,BorderSizePixel=0,ZIndex=15,
        },row)
        Corner(strip,2)

        New("TextLabel",{Size=UDim2.new(1,-68,0,20),Position=UDim2.new(0,12,0,6),BackgroundTransparency=1,
            Text=lbl,TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextStrokeTransparency=0.6,TextStrokeColor3=Color3.new(0,0,0),ZIndex=15},row)
        New("TextLabel",{Size=UDim2.new(1,-68,0,14),Position=UDim2.new(0,12,0,27),BackgroundTransparency=1,
            Text=desc,TextColor3=C.Muted,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15},row)

        local pill=New("Frame",{Size=UDim2.new(0,46,0,24),Position=UDim2.new(1,-56,0.5,-12),
            BackgroundColor3=C.OFF,BorderSizePixel=0,ZIndex=15},row)
        Corner(pill,12); Outline(pill,C.BorderDk,1,0.4)
        -- pill inner glow
        local pillGrad=New("UIGradient",{
            Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(30,40,80)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,15,35))},
            Rotation=90,
        },pill)

        local knob=New("Frame",{Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,2,0.5,-10),
            BackgroundColor3=C.Muted,BorderSizePixel=0,ZIndex=16},pill)
        Corner(knob,10)
        -- knob shadow
        Outline(knob,Color3.fromRGB(0,0,0),1,0.5)

        local btn=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=17},row)
        local state=false

        btn.MouseEnter:Connect(function()
            tw(row,0.15,{BackgroundTransparency=0.15})
            tw(strip,0.15,{BackgroundColor3=state and C.Neon or Color3.fromRGB(60,80,140)})
        end)
        btn.MouseLeave:Connect(function()
            tw(row,0.15,{BackgroundTransparency=0.35})
            tw(strip,0.15,{BackgroundColor3=state and C.Neon or C.Muted})
        end)

        btn.MouseButton1Click:Connect(function()
            state=not state; cb(state); Pulse(row)
            if state then
                tw(pill,0.22,{BackgroundColor3=C.Neon})
                pillGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(20,80,220)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,50,160))}
                twS(knob,0.28,{Position=UDim2.new(1,-22,0.5,-10),BackgroundColor3=C.White})
                tw(strip,0.2,{BackgroundColor3=C.Neon})
                -- mini flash on row
                tw(row,0.05,{BackgroundColor3=Color3.fromRGB(15,30,80)})
                task.delay(0.1,function() tw(row,0.2,{BackgroundColor3=C.Row}) end)
            else
                tw(pill,0.22,{BackgroundColor3=C.OFF})
                pillGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(30,40,80)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,15,35))}
                twS(knob,0.28,{Position=UDim2.new(0,2,0.5,-10),BackgroundColor3=C.Muted})
                tw(strip,0.2,{BackgroundColor3=C.Muted})
            end
        end)
    end

    -- ── SLIDER ───────────────────────────────
    local function NewSlider(lbl,desc,maxV,minV,cb)
        local row=MakeRow(70)
        New("TextLabel",{Size=UDim2.new(0.65,0,0,20),Position=UDim2.new(0,12,0,5),BackgroundTransparency=1,
            Text=lbl,TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextStrokeTransparency=0.6,TextStrokeColor3=Color3.new(0,0,0),ZIndex=15},row)
        local vLbl=New("TextLabel",{Size=UDim2.new(0.35,-12,0,20),Position=UDim2.new(0.65,0,0,5),
            BackgroundTransparency=1,Text=tostring(minV),TextColor3=C.NeonBr,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Right,ZIndex=15},row)
        New("TextLabel",{Size=UDim2.new(1,-24,0,13),Position=UDim2.new(0,12,0,26),BackgroundTransparency=1,
            Text=desc,TextColor3=C.Muted,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15},row)

        local track=New("Frame",{Size=UDim2.new(1,-24,0,14),Position=UDim2.new(0,12,0,46),
            BackgroundColor3=C.NeonDk,BorderSizePixel=0,ZIndex=15},row)
        Corner(track,7); Outline(track,C.BorderDk,1,0.3)
        Grad(track,Color3.fromRGB(6,14,40),Color3.fromRGB(3,8,25),180)

        local fill=New("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.Neon,BorderSizePixel=0,ZIndex=16},track)
        Corner(fill,7)
        Grad(fill,C.NeonBr,C.Neon,180)

        local dot=New("Frame",{Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,-9,0.5,-9),
            BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=18},track)
        Corner(dot,9); Outline(dot,C.NeonBr,1.5,0.2)
        -- dot inner
        New("Frame",{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0.5,-4,0.5,-4),
            BackgroundColor3=C.Neon,BorderSizePixel=0,ZIndex=19},dot)
        Corner(dot:FindFirstChild("Frame"),4)

        local sliding=false
        local function SetPct(px)
            local ap=track.AbsolutePosition; local as=track.AbsoluteSize
            if as.X==0 then return end
            local pct=math.clamp((px-ap.X)/as.X,0,1)
            local v=math.clamp(math.floor(minV+pct*(maxV-minV)),minV,maxV)
            local rp=(maxV==minV) and 0 or (v-minV)/(maxV-minV)
            fill.Size=UDim2.new(rp,0,1,0)
            dot.Position=UDim2.new(rp,-9,0.5,-9)
            vLbl.Text=tostring(v); cb(v)
        end
        SetPct(track.AbsolutePosition.X)

        local tBtn=New("TextButton",{Size=UDim2.new(1,10,1,10),Position=UDim2.new(0,-5,0.5,-7),
            BackgroundTransparency=1,Text="",ZIndex=19},track)
        tBtn.MouseButton1Down:Connect(function(x,_) sliding=true; SetPct(x) end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                sliding=false
                -- snap dot animation
                twE(dot,0.2,{Size=UDim2.new(0,18,0,18)})
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then
                SetPct(i.Position.X)
                dot.Size=UDim2.new(0,22,0,22) -- expand while dragging
                dot.Position=UDim2.new(dot.Position.X.Scale,-11,0.5,-11)
            end
        end)

        local hb=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=14},row)
        hb.MouseEnter:Connect(function() tw(row,0.15,{BackgroundTransparency=0.15}) end)
        hb.MouseLeave:Connect(function() tw(row,0.15,{BackgroundTransparency=0.35}) end)
    end

    -- ── COLOR PICKER ─────────────────────────
    local function NewColorPicker(lbl,desc,defCol,cb)
        local row=MakeRow(50)
        New("TextLabel",{Size=UDim2.new(1,-72,0,20),Position=UDim2.new(0,12,0,6),BackgroundTransparency=1,
            Text=lbl,TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextStrokeTransparency=0.6,TextStrokeColor3=Color3.new(0,0,0),ZIndex=15},row)
        New("TextLabel",{Size=UDim2.new(1,-72,0,14),Position=UDim2.new(0,12,0,27),BackgroundTransparency=1,
            Text=desc,TextColor3=C.Muted,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15},row)
        local cur=defCol
        local sw=New("Frame",{Size=UDim2.new(0,40,0,32),Position=UDim2.new(1,-50,0.5,-16),
            BackgroundColor3=defCol,BorderSizePixel=0,ZIndex=15},row)
        Corner(sw,8); Outline(sw,C.NeonBr,1.5,0.2)
        local swBtn=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=16},sw)
        swBtn.MouseButton1Click:Connect(function()
            Pulse(sw)
            if CPop.Visible then CPop.Visible=false
            else OpenCP(sw,cur,function(col) cur=col; sw.BackgroundColor3=col; cb(col) end) end
        end)
        local hb=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=14},row)
        hb.MouseEnter:Connect(function() tw(row,0.15,{BackgroundTransparency=0.15}) end)
        hb.MouseLeave:Connect(function() tw(row,0.15,{BackgroundTransparency=0.35}) end)
    end

    return {NewToggle=NewToggle,NewSlider=NewSlider,NewColorPicker=NewColorPicker}
end

-- ╔══════════════════════════════════════════════╗
--   BUILD TABS
-- ╚══════════════════════════════════════════════╝
local PC=MakeTab("COMBAT")
local PV=MakeTab("VISUALS")
local PW=MakeTab("WORLD")
SwitchTab("COMBAT")

local SA  = MakeSection(PC,"AIMBOT PROTOCOL")
local SPE = MakeSection(PV,"PLAYER SCANNER")
local SWE = MakeSection(PV,"WORLD SCANNER")
local SVC = MakeSection(PV,"DISPLAY CONFIG")
local SU  = MakeSection(PW,"UTILITY MODULE")
local SM  = MakeSection(PW,"MOVEMENT OVERRIDE")

-- ╔══════════════════════════════════════════════╗
--   GAME LOGIC
-- ╚══════════════════════════════════════════════╝
local function GetRoot(o)
    if o:IsA("BasePart") then return o end
    if o:IsA("Model") then
        return o.PrimaryPart or o:FindFirstChild("HumanoidRootPart") or o:FindFirstChildWhichIsA("BasePart")
    end
end
local function GetDist(pos)
    local c=LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        return math.floor((c.HumanoidRootPart.Position-pos).Magnitude)
    end; return 0
end
local function IsVis(tp)
    if not tp then return false end
    local c=LocalPlayer.Character; if not c or not c:FindFirstChild("Head") then return false end
    local p=RaycastParams.new(); p.FilterDescendantsInstances={c}; p.FilterType=Enum.RaycastFilterType.Exclude; p.IgnoreWater=true
    local r=workspace:Raycast(Cam.CFrame.Position,tp.Position-Cam.CFrame.Position,p)
    return r and r.Instance:IsDescendantOf(tp.Parent) or (r==nil)
end
local function AName(o)
    local n=o.Name:lower(); local pre=n:find("legendary") and "[LEG] " or ""
    local m={{"crow","Crow"},{"dire wolf","Dire Wolf"},{"direwolf","Dire Wolf"},{"wolf","Wolf"},
        {"coyote","Coyote"},{"fox","Fox"},{"grizzly","Grizzly"},{"black bear","Black Bear"},
        {"bear","Bear"},{"bison","Bison"},{"buffalo","Bison"},{"buck","Deer"},{"doe","Deer"},
        {"fawn","Deer"},{"deer","Deer"},{"horse","Horse"},{"cow","Cow"},{"cattle","Cow"},
        {"pig","Pig"},{"boar","Boar"},{"rabbit","Rabbit"},{"bunny","Rabbit"},{"chicken","Chicken"}}
    for _,e in ipairs(m) do if n:find(e[1]) then return pre..e[2] end end; return o.Name
end

-- Aimbot
local function GetTarget()
    local tp,cd=nil,S.FOV
    local center=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
    local function chk(part)
        local pos,vis=Cam:WorldToViewportPoint(part.Position); if not vis then return end
        local mag=(Vector2.new(pos.X,pos.Y)-center).Magnitude
        if mag<cd then tp=part; cd=mag end
    end
    if S.AimPlayers then
        for _,v in ipairs(Players:GetPlayers()) do
            if v==LocalPlayer then continue end
            local ch=v.Character; if not ch then continue end
            local hd=ch:FindFirstChild("Head"); local hum=ch:FindFirstChildOfClass("Humanoid")
            if not hd or not hum or hum.Health<=0 then continue end
            if S.WallCheck and not IsVis(hd) then continue end; chk(hd)
        end
    end
    if S.AimAnimals then
        for _,fn in ipairs({"Harvestables","Animals","NPCS"}) do
            local folder=workspace:FindFirstChild(fn); if not folder then continue end
            for _,v in ipairs(folder:GetChildren()) do
                if not v:IsA("Model") then continue end
                local hum=v:FindFirstChildOfClass("Humanoid"); if hum and hum.Health<=0 then continue end
                local rp=GetRoot(v); if not rp then continue end
                if S.WallCheck and not IsVis(rp) then continue end; chk(rp)
            end
        end
    end
    return tp
end

-- ESP
local function ManageESP(char,text,color,tag,show,dist,isP)
    local rp=isP and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")) or GetRoot(char)
    if not rp then return end
    local inRange=isP or (dist<=S.ESPDist)
    local bb=rp:FindFirstChild(tag)
    if show and inRange then
        if not bb then
            bb=Instance.new("BillboardGui"); bb.Name=tag; bb.Adornee=rp
            bb.AlwaysOnTop=true; bb.Size=UDim2.new(0,200,0,60)
            bb.StudsOffset=Vector3.new(0,3,0); bb.Parent=rp
            local lb=Instance.new("TextLabel",bb); lb.Name="L"
            lb.BackgroundTransparency=1; lb.Size=UDim2.new(1,0,1,0)
            lb.TextStrokeTransparency=0.3; lb.TextStrokeColor3=Color3.new(0,0,0)
            lb.Font=Enum.Font.Code
        end
        local lb=bb:FindFirstChild("L")
        if lb then lb.TextSize=S.TextSize; lb.TextColor3=color; lb.Text=text..(S.ShowDist and ("  ["..dist.."m]") or "") end
    else if bb then bb:Destroy() end end
end
local function CleanAESP()
    for _,fn in ipairs({"Harvestables","Animals","NPCS"}) do
        local f=workspace:FindFirstChild(fn); if not f then continue end
        for _,a in ipairs(f:GetChildren()) do
            local rp=GetRoot(a); if rp then local t=rp:FindFirstChild("GWANIM"); if t then t:Destroy() end end
        end
    end
end

task.spawn(function() while true do task.wait(1)
    if not S.AnimalESP then continue end
    for _,fn in ipairs({"Harvestables","Animals","NPCS"}) do
        local folder=workspace:FindFirstChild(fn); if not folder then continue end
        for _,v in ipairs(folder:GetChildren()) do
            if not v:IsA("Model") then continue end
            local rp=GetRoot(v); if not rp then continue end
            local hum=v:FindFirstChildOfClass("Humanoid")
            local lb=AName(v); if hum and hum.Health<=0 then lb="[DEAD] "..lb end
            ManageESP(v,lb,S.AnimalColor,"GWANIM",true,GetDist(rp.Position),false)
        end
    end
end end)

task.spawn(function() while true do task.wait(0.1)
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LocalPlayer then continue end
        local c=p.Character; if not c then continue end
        local hum=c:FindFirstChildOfClass("Humanoid")
        local rp=c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
        if rp and hum and hum.Health>0 then
            local dist=GetDist(rp.Position); local show=S.PlayerName or S.PlayerHP; local txt=""
            if S.PlayerName then txt="[ "..p.Name.." ]" end
            if S.PlayerHP then txt=txt..(txt~="" and "\n" or "").."HP "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth) end
            ManageESP(c,txt,S.PlayerColor,"GWPLYR",show,dist,true)
            local hl=c:FindFirstChild("GWPH")
            if S.PlayerBox then
                if not hl then hl=Instance.new("Highlight"); hl.Name="GWPH"; hl.Parent=c end
                hl.FillColor=S.PlayerColor; hl.FillTransparency=0.65; hl.OutlineColor=C.Neon; hl.OutlineTransparency=0
            elseif hl then hl:Destroy() end
        else
            local b=c:FindFirstChild("GWPLYR",true); if b then b:Destroy() end
            local hl=c:FindFirstChild("GWPH"); if hl then hl:Destroy() end
        end
    end
end end)

-- Noclip
local noclipConn
local function SetNoclip(on)
    if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
    local char=LocalPlayer.Character; if not char then return end
    if on then
        local function off(p) if p:IsA("BasePart") then p.CanCollide=false end end
        for _,p in ipairs(char:GetDescendants()) do off(p) end
        noclipConn=char.DescendantAdded:Connect(off)
    else
        for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end
    end
end

local function ApplySpeed()
    local c=LocalPlayer.Character; if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed=S.SpeedBoost and S.SpeedVal or 16 end
end

LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    if S.SpeedBoost then local h=c:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=S.SpeedVal end end
    if S.Noclip then task.wait(0.1); SetNoclip(true) end
end)

-- Render Loop
Run.RenderStepped:Connect(function()
    FOVC.Visible=S.ShowFOV; FOVC.Radius=S.FOV
    FOVC.Position=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
    local ap=GetTarget()
    if ap then
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            Cam.CFrame=CFrame.new(Cam.CFrame.Position,ap.Position)
        end
        if S.SilentAim and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,ap.Position),S.SilentSmooth)
        end
    end
    if S.TPWalk then
        local c=LocalPlayer.Character; if c then
            local h=c:FindFirstChildOfClass("Humanoid")
            if h and h.MoveDirection.Magnitude>0 then c:TranslateBy(h.MoveDirection*S.TPSpeed*0.1) end
        end
    end
    if S.FullBright then
        Light.ClockTime=14; Light.Brightness=2; Light.GlobalShadows=false; Light.FogEnd=100000
    end
end)

-- ╔══════════════════════════════════════════════╗
--   POPULATE
-- ╚══════════════════════════════════════════════╝
SA.NewToggle("Target Players",   "RMB — Lock onto players",          function(v) S.AimPlayers=v end)
SA.NewToggle("Target Animals",   "RMB — Lock onto wildlife",         function(v) S.AimAnimals=v end)
SA.NewToggle("Wall Check",       "Only aim at visible targets",      function(v) S.WallCheck=v end)
SA.NewToggle("Silent Fire",      "LMB — Smooth silent aim",          function(v) S.SilentAim=v end)
SA.NewSlider("FOV Radius",       "Aim radius in pixels",  800, 10,  function(v) S.FOV=v end)
SA.NewSlider("Silent Smoothing", "1=instant  50=smooth",  50,  1,   function(v) S.SilentSmooth=v/100 end)
SA.NewToggle("Show FOV Ring",    "Render FOV circle on screen",      function(v) S.ShowFOV=v end)

SPE.NewToggle("Name ESP",   "Show player username",        function(v) S.PlayerName=v end)
SPE.NewToggle("Health ESP", "Show HP / Max HP",            function(v) S.PlayerHP=v end)
SPE.NewToggle("Box ESP",    "Highlight player silhouette", function(v) S.PlayerBox=v end)

SWE.NewToggle("Animal ESP",    "Track all wildlife",          function(v) S.AnimalESP=v; if not v then CleanAESP() end end)
SWE.NewToggle("Show Distance", "Display range to target",     function(v) S.ShowDist=v end)

SVC.NewSlider("Max Animal Range","Fauna ESP max distance",20000,500, function(v) S.ESPDist=v end)
SVC.NewSlider("Label Size",      "ESP font size",          20,  8,   function(v) S.TextSize=v end)
SVC.NewColorPicker("Player ESP Color","Color for player labels",S.PlayerColor,function(v) S.PlayerColor=v end)
SVC.NewColorPicker("Animal ESP Color","Color for animal labels",S.AnimalColor,function(v) S.AnimalColor=v end)
SVC.NewColorPicker("FOV Ring Color",  "Color of aim circle", FOVC.Color,     function(v) FOVC.Color=v end)

SU.NewToggle("Full Bright",      "Force max lighting",            function(v) S.FullBright=v end)
SU.NewToggle("Instant Interact", "Zero hold on prompts",          function(v) S.Interact=v end)
SU.NewToggle("TP-Walk",          "Teleport movement hack",        function(v) S.TPWalk=v end)
SU.NewSlider("TP Speed",         "TP-Walk speed multiplier",15,1, function(v) S.TPSpeed=v end)

SM.NewToggle("Noclip",      "Phase through walls",           function(v) S.Noclip=v; SetNoclip(v) end)
SM.NewToggle("Speed Boost", "Override walk speed",           function(v) S.SpeedBoost=v; ApplySpeed() end)
SM.NewSlider("Walk Speed",  "Speed value (default 16)",100,16,function(v) S.SpeedVal=v; ApplySpeed() end)

PPS.PromptShown:Connect(function(p) if S.Interact then p.HoldDuration=0 end end)

pcall(function()
    SGui:SetCore("SendNotification",{Title="MOSAB WEST  v8  [ ARMED ]",
        Text="Navy Edition · RightCtrl = Hide/Show",Duration=5})
end)
