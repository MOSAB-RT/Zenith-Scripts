-- ╔══════════════════════════════════════════════════════════════╗
--   ZENITH  |  v16  |  CYBER GLASS EDITION
--   RightCtrl = Hide/Show  |  Drag TitleBar  |  X = Full Exit
-- ╚══════════════════════════════════════════════════════════════╝

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

-- ── STATE ────────────────────────────────────────────────────
local S = {
    AimPlayers=false, AimAnimals=false, WallCheck=false,
    SilentAim=false, SilentSmooth=0.15, FOV=150, ShowFOV=false, LockTarget=false,
    PlayerName=false, PlayerHP=false, PlayerBox=false, BoxSize=1,
    AnimalESP=false, ShowDist=false, ESPDist=10000, TextSize=12,
    PlayerColor=Color3.fromRGB(0,200,255),
    AnimalColor=Color3.fromRGB(255,200,0),
    Tracers=false, TracerThickness=1.5, TracerTransp=0.15,
    TracerColor=Color3.fromRGB(0,200,255),
    FullBright=false, NightMode=false,
    Interact=false, TPWalk=false, TPSpeed=2,
    Noclip=false, SpeedBoost=false, SpeedVal=16,
}

local _savedLight = {
    ClockTime     = Light.ClockTime,
    Brightness    = Light.Brightness,
    GlobalShadows = Light.GlobalShadows,
    FogEnd        = Light.FogEnd,
    Ambient       = Light.Ambient,
    OutdoorAmbient= Light.OutdoorAmbient,
}
local function RestoreLight()
    pcall(function()
        Light.ClockTime     = _savedLight.ClockTime
        Light.Brightness    = _savedLight.Brightness
        Light.GlobalShadows = _savedLight.GlobalShadows
        Light.FogEnd        = _savedLight.FogEnd
        Light.Ambient       = _savedLight.Ambient
        Light.OutdoorAmbient= _savedLight.OutdoorAmbient
    end)
end

-- ── FOV CIRCLE ───────────────────────────────────────────────
local FOVC = Drawing.new("Circle")
FOVC.Thickness=2; FOVC.Filled=false
FOVC.Color=Color3.fromRGB(0,180,255); FOVC.Transparency=1; FOVC.Visible=false

-- ── TRACER POOL ──────────────────────────────────────────────
local tracerPool = {}
local function GetOrMakeTracer(pl)
    if not tracerPool[pl] then
        local ln=Drawing.new("Line")
        ln.Thickness=1.5; ln.Color=S.TracerColor
        ln.Transparency=0.15; ln.Visible=false
        tracerPool[pl]={line=ln}
    end
    return tracerPool[pl]
end
local function RemoveTracer(pl)
    local t=tracerPool[pl]
    if t then pcall(function() t.line:Remove() end); tracerPool[pl]=nil end
end
Players.PlayerRemoving:Connect(RemoveTracer)
Players.PlayerAdded:Connect(function(pl)
    pl.CharacterRemoving:Connect(function()
        local t=tracerPool[pl]; if t then t.line.Visible=false end
    end)
end)

-- ── CYBER GLASS PALETTE ──────────────────────────────────────
local C = {
    BG       = Color3.fromRGB(2, 6, 18),
    Glass    = Color3.fromRGB(8, 16, 40),
    GlassLt  = Color3.fromRGB(14, 28, 65),
    Row      = Color3.fromRGB(10, 22, 55),
    Cyan     = Color3.fromRGB(0, 210, 255),
    CyanBr   = Color3.fromRGB(120, 235, 255),
    CyanDk   = Color3.fromRGB(0, 60, 100),
    Purple   = Color3.fromRGB(160, 80, 255),
    PurpleBr = Color3.fromRGB(200, 140, 255),
    White    = Color3.fromRGB(220, 235, 255),
    Muted    = Color3.fromRGB(80, 110, 160),
    OFF      = Color3.fromRGB(12, 20, 50),
    Green    = Color3.fromRGB(0, 220, 130),
    Red      = Color3.fromRGB(255, 60, 80),
    Border   = Color3.fromRGB(0, 150, 220),
    BorderDk = Color3.fromRGB(8, 20, 60),
    Gold     = Color3.fromRGB(255, 200, 60),
}

-- ── HELPERS ──────────────────────────────────────────────────
local function tw(o,t,p,style,dir)
    TW:Create(o,TweenInfo.new(t,style or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),p):Play()
end
local function New(cls,props,par)
    local o=Instance.new(cls)
    for k,v in pairs(props) do o[k]=v end
    if par then o.Parent=par end; return o
end
local function Corner(p,r) New("UICorner",{CornerRadius=UDim.new(0,r or 10)},p) end
local function Stroke(p,col,sz,tr)
    local s=Instance.new("UIStroke")
    s.Color=col or C.Border; s.Thickness=sz or 1; s.Transparency=tr or 0; s.Parent=p; return s
end
local function Grad(p,a,b,rot)
    New("UIGradient",{Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,a),ColorSequenceKeypoint.new(1,b)},Rotation=rot or 90},p)
end

-- Pulse animation on click
local function Pulse(f)
    local s=f.Size
    tw(f,0.06,{Size=UDim2.new(s.X.Scale,s.X.Offset-5,s.Y.Scale,s.Y.Offset-4)})
    task.delay(0.06,function() tw(f,0.22,{Size=s},Enum.EasingStyle.Back,Enum.EasingDirection.Out) end)
end

-- Ripple effect on click
local function Ripple(parent,x,y)
    local rp=New("Frame",{
        Size=UDim2.new(0,0,0,0),
        Position=UDim2.new(0,x - parent.AbsolutePosition.X,0,y - parent.AbsolutePosition.Y),
        BackgroundColor3=C.CyanBr,BackgroundTransparency=0.55,
        BorderSizePixel=0,ZIndex=parent.ZIndex+10,ClipsDescendants=false,
    },parent)
    Corner(rp,999)
    tw(rp,0.55,{Size=UDim2.new(0,220,0,220),Position=UDim2.new(0,x-parent.AbsolutePosition.X-110,0,y-parent.AbsolutePosition.Y-110),BackgroundTransparency=1},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
    task.delay(0.6,function() pcall(function() rp:Destroy() end) end)
end

-- Scan line shimmer
local function Shimmer(parent,zi)
    local sh=New("Frame",{Size=UDim2.new(0,60,1,0),Position=UDim2.new(-0.15,0,0,0),
        BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.82,
        BorderSizePixel=0,ZIndex=zi or (parent.ZIndex+3),ClipsDescendants=true},parent)
    Corner(sh,4)
    New("UIGradient",{
        Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(0.5,Color3.fromRGB(160,220,255)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))},
        Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),
            NumberSequenceKeypoint.new(0.5,0.55),NumberSequenceKeypoint.new(1,1)},
        Rotation=75},sh)
    local function loop()
        sh.Position=UDim2.new(-0.18,0,0,0)
        tw(sh,1.6,{Position=UDim2.new(1.18,0,0,0)},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
        task.delay(3.5+math.random()*2.5,loop)
    end
    task.delay(math.random()*2.5,loop)
end

-- Floating particles (decorative dots that drift upward)
local function SpawnParticle(parent)
    local px = math.random(5, parent.AbsoluteSize.X - 5)
    local p=New("Frame",{
        Size=UDim2.new(0,math.random(2,4),0,math.random(2,4)),
        Position=UDim2.new(0,px,1,0),
        BackgroundColor3=math.random()>0.5 and C.Cyan or C.Purple,
        BackgroundTransparency=math.random()*0.4,
        BorderSizePixel=0,ZIndex=parent.ZIndex+20,
    },parent)
    Corner(p,4)
    tw(p,math.random(3,6)+math.random(),{Position=UDim2.new(0,px+math.random(-20,20),0,-8),BackgroundTransparency=1},Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
    task.delay(6.5,function() pcall(function() p:Destroy() end) end)
end

-- Neon glow border animation
local function AnimateGlow(stroke,colA,colB,speed)
    task.spawn(function()
        while stroke and stroke.Parent do
            tw(stroke,speed or 1.8,{Transparency=0.7,Color=colA}); task.wait(speed or 1.8)
            tw(stroke,speed or 1.8,{Transparency=0.05,Color=colB}); task.wait(speed or 1.8)
        end
    end)
end

-- Holographic flicker
local function HoloFlicker(frame)
    task.spawn(function()
        while frame and frame.Parent do
            task.wait(math.random(4,12))
            local orig=frame.BackgroundTransparency
            for _=1,math.random(1,3) do
                frame.BackgroundTransparency=orig+0.4; task.wait(0.04)
                frame.BackgroundTransparency=orig; task.wait(0.04)
            end
        end
    end)
end

-- ── INPUT ────────────────────────────────────────────────────
local _aSl=nil; local _aCPSl=nil
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then _aSl=nil; _aCPSl=nil end
end)
UIS.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement then
        if _aSl    then _aSl(i.Position.X)   end
        if _aCPSl  then _aCPSl(i.Position.X) end
    end
end)

-- ╔══════════════════════════════════════════════════════════════╗
--   GUI ROOT — CYBER GLASS WORLD
-- ╚══════════════════════════════════════════════════════════════╝
local Gui=New("ScreenGui",{Name="WestV16",ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Global,IgnoreGuiInset=true,
},LocalPlayer:WaitForChild("PlayerGui"))

-- Ambient background overlay (full-screen subtle glow)
local BgGlow=New("Frame",{
    Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,0,0,0),
    BackgroundColor3=Color3.fromRGB(0,30,80),BackgroundTransparency=0.96,
    BorderSizePixel=0,ZIndex=1,
},Gui)

-- Main Window
local Win=New("Frame",{
    Size=UDim2.new(0,640,0,580),Position=UDim2.new(0.5,-320,0.5,-290),
    BackgroundColor3=C.BG,BackgroundTransparency=0.06,
    BorderSizePixel=0,ClipsDescendants=false,ZIndex=10,
},Gui)
Corner(Win,14)
Grad(Win,Color3.fromRGB(8,18,48),Color3.fromRGB(2,5,16),148)

-- Outer glow frame (larger frame behind for glow effect)
local winGlow=New("Frame",{
    Size=UDim2.new(1,20,1,20),Position=UDim2.new(0,-10,0,-10),
    BackgroundColor3=Color3.fromRGB(0,100,200),BackgroundTransparency=0.88,
    BorderSizePixel=0,ZIndex=9,
},Win)
Corner(winGlow,18)
task.spawn(function()
    while Gui and Gui.Parent do
        tw(winGlow,2.2,{BackgroundColor3=Color3.fromRGB(100,0,255),BackgroundTransparency=0.92}); task.wait(2.2)
        tw(winGlow,2.2,{BackgroundColor3=Color3.fromRGB(0,150,255),BackgroundTransparency=0.86}); task.wait(2.2)
    end
end)

local winStroke=Stroke(Win,C.Cyan,1.8,0.3)
task.spawn(function()
    while winStroke and winStroke.Parent do
        tw(winStroke,2.0,{Transparency=0.1,Color=C.CyanBr}); task.wait(2.0)
        tw(winStroke,2.0,{Transparency=0.6,Color=C.Cyan}); task.wait(2.0)
    end
end)

-- Particle emitter on window
task.spawn(function()
    while Gui and Gui.Parent do
        task.wait(0.8+math.random()*0.6)
        pcall(function() SpawnParticle(Win) end)
    end
end)

-- ── TITLE BAR ────────────────────────────────────────────────
local TBar=New("Frame",{Size=UDim2.new(1,0,0,52),BackgroundColor3=C.CyanDk,BorderSizePixel=0,ZIndex=11},Win)
Corner(TBar,14)
-- Fill bottom corners
New("Frame",{Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),
    BackgroundColor3=Color3.fromRGB(2,18,52),BorderSizePixel=0,ZIndex=11},TBar)
Grad(TBar,Color3.fromRGB(0,40,120),Color3.fromRGB(2,12,48),180)
Shimmer(TBar,15)

-- Title bar animated bottom line
local tLine=New("Frame",{Size=UDim2.new(0,0,0,2),Position=UDim2.new(0,0,1,-2),
    BackgroundColor3=C.CyanBr,BorderSizePixel=0,ZIndex=13},TBar)
-- Animate line expanding on load
tw(tLine,1.2,{Size=UDim2.new(1,0,0,2)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
task.spawn(function()
    task.wait(1.2)
    while Gui and Gui.Parent do
        tw(tLine,1.6,{BackgroundColor3=C.Purple,BackgroundTransparency=0.4}); task.wait(1.6)
        tw(tLine,1.6,{BackgroundColor3=C.CyanBr,BackgroundTransparency=0}); task.wait(1.6)
    end
end)

-- Status dot — right side of title text, balanced
local sDot=New("Frame",{
    Size=UDim2.new(0,8,0,8),
    Position=UDim2.new(0,14,0.5,-4),
    BackgroundColor3=C.Green,BorderSizePixel=0,ZIndex=20},TBar)
Corner(sDot,4)
-- Outer glow ring
local sDotGlow=New("Frame",{
    Size=UDim2.new(0,8,0,8),
    Position=UDim2.new(0,14,0.5,-4),
    BackgroundTransparency=1,BorderSizePixel=0,ZIndex=19},TBar)
Corner(sDotGlow,8)
Stroke(sDotGlow,C.Green,1.2,0)
-- Dot pulse
task.spawn(function()
    while Gui and Gui.Parent do
        tw(sDot,0.8,{BackgroundTransparency=0.1,BackgroundColor3=C.Green}); task.wait(0.8)
        tw(sDot,0.8,{BackgroundTransparency=0.65,BackgroundColor3=Color3.fromRGB(0,180,110)}); task.wait(0.8)
    end
end)
-- Ring expand
task.spawn(function()
    while Gui and Gui.Parent do
        sDotGlow.Size=UDim2.new(0,8,0,8); sDotGlow.Position=UDim2.new(0,14,0.5,-4)
        local st=sDotGlow:FindFirstChildOfClass("UIStroke"); if st then st.Transparency=0.1 end
        tw(sDotGlow,1.0,{Size=UDim2.new(0,22,0,22),Position=UDim2.new(0,7,0.5,-11)},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        if st then tw(st,1.0,{Transparency=1}) end
        task.wait(2.4)
    end
end)

New("TextLabel",{Size=UDim2.new(1,-100,1,0),Position=UDim2.new(0,30,0,0),
    BackgroundTransparency=1,Text="ZENITH",
    TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left,
    TextStrokeTransparency=1,ZIndex=18},TBar)

-- Version badge (cyan style, no purple)
local verBadge=New("Frame",{Size=UDim2.new(0,34,0,20),Position=UDim2.new(1,-84,0.5,-10),
    BackgroundColor3=Color3.fromRGB(0,50,100),BackgroundTransparency=0.15,BorderSizePixel=0,ZIndex=18},TBar)
Corner(verBadge,5); Stroke(verBadge,C.CyanBr,1,0.35)
New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="v16",
    TextColor3=C.CyanBr,TextSize=10,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Center,ZIndex=19},verBadge)

-- Close button
local XBtn=New("TextButton",{
    Size=UDim2.new(0,30,0,30),
    Position=UDim2.new(1,-40,0.5,-15),
    BackgroundColor3=Color3.fromRGB(140,22,22),
    Text="X",TextColor3=Color3.new(1,0.85,0.85),
    TextSize=12,Font=Enum.Font.GothamBold,
    BorderSizePixel=0,AutoButtonColor=false,ZIndex=20},TBar)
Corner(XBtn,8)
Stroke(XBtn,Color3.fromRGB(200,50,50),1,0.25)
XBtn.MouseEnter:Connect(function()
    tw(XBtn,0.1,{BackgroundColor3=Color3.fromRGB(210,35,35),TextColor3=Color3.new(1,1,1)})
end)
XBtn.MouseLeave:Connect(function()
    tw(XBtn,0.1,{BackgroundColor3=Color3.fromRGB(140,22,22),TextColor3=Color3.new(1,0.85,0.85)})
end)

-- ── FULL CLEANUP ─────────────────────────────────────────────
local function FullCleanup()
    for pl,_ in pairs(tracerPool) do RemoveTracer(pl) end
    pcall(function() FOVC:Remove() end)
    for _,p in ipairs(Players:GetPlayers()) do
        local c=p.Character; if not c then continue end
        for _,tag in ipairs({"GWPLYR","GWPH"}) do
            local o=c:FindFirstChild(tag,true)
            if o then pcall(function() o:Destroy() end) end
        end
    end
    for _,fn in ipairs({"Harvestables","Animals","NPCS"}) do
        local f=workspace:FindFirstChild(fn); if not f then continue end
        for _,a in ipairs(f:GetChildren()) do
            local rp=a:FindFirstChildWhichIsA("BasePart")
            if rp then local t=rp:FindFirstChild("GWANIM"); if t then pcall(function() t:Destroy() end) end end
        end
    end
    RestoreLight()
    pcall(function()
        local c=LocalPlayer.Character; if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end
    end)
    pcall(function()
        local c=LocalPlayer.Character; if not c then return end
        local h=c:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=16 end
    end)
    -- Fade out then destroy
    tw(Win,0.3,{BackgroundTransparency=1}); tw(winGlow,0.3,{BackgroundTransparency=1})
    task.delay(0.32,function() pcall(function() Gui:Destroy() end) end)
end

XBtn.MouseButton1Click:Connect(function()
    Pulse(XBtn)
    -- Death flash effect
    local flash=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.Red,BackgroundTransparency=0.6,BorderSizePixel=0,ZIndex=999},Win)
    tw(flash,0.3,{BackgroundTransparency=1})
    task.delay(0.3,function() pcall(function() flash:Destroy() end) end)
    task.delay(0.2,FullCleanup)
end)

-- ── DRAG ─────────────────────────────────────────────────────
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

-- Hide/Show shortcut
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.RightControl then
        if Win.Visible then
            tw(Win,0.2,{BackgroundTransparency=1})
            task.delay(0.21,function() Win.Visible=false; Win.BackgroundTransparency=0.06 end)
        else
            Win.Visible=true; Win.BackgroundTransparency=1
            tw(Win,0.22,{BackgroundTransparency=0.06})
        end
    end
end)

-- ── STATUS BAR ───────────────────────────────────────────────
local SBar=New("Frame",{Size=UDim2.new(1,-20,0,32),Position=UDim2.new(0,10,0,58),
    BackgroundColor3=C.Glass,BackgroundTransparency=0.2,BorderSizePixel=0,ZIndex=11},Win)
Corner(SBar,8); Stroke(SBar,C.BorderDk,1,0.15)
Grad(SBar,Color3.fromRGB(6,16,50),Color3.fromRGB(2,8,24),180)

local statusData={
    {0,    "STATUS", "ACTIVE",  C.Green},
    {0.33, "CIPHER", "AES-256", C.CyanBr},
    {0.67, "TOKEN",  tostring(math.random(1e5,9e5)), C.Gold},
}
for _,d in ipairs(statusData) do
    local f=New("Frame",{Size=UDim2.new(0.33,0,1,0),Position=UDim2.new(d[1],0,0,0),BackgroundTransparency=1,ZIndex=11},SBar)
    local lbl1=New("TextLabel",{Size=UDim2.new(1,0,0.45,0),BackgroundTransparency=1,Text=d[2],TextColor3=C.Muted,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=11},f)
    local lbl2=New("TextLabel",{Size=UDim2.new(1,0,0.55,0),Position=UDim2.new(0,0,0.45,0),BackgroundTransparency=1,Text=d[3],TextColor3=d[4],TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=11},f)
    -- Animate status labels typing in
    task.spawn(function()
        task.wait(0.4+d[1])
        lbl2.Text=""; for i=1,#d[3] do lbl2.Text=d[3]:sub(1,i); task.wait(0.06) end
    end)
end
-- Divider lines between status sections
for _,x in ipairs({0.33,0.67}) do
    New("Frame",{Size=UDim2.new(0,1,0.6,0),Position=UDim2.new(x,0,0.2,0),
        BackgroundColor3=C.BorderDk,BackgroundTransparency=0.2,BorderSizePixel=0,ZIndex=12},SBar)
end

New("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,94),BackgroundColor3=C.BorderDk,BorderSizePixel=0,ZIndex=11},Win)

-- ╔══════════════════════════════════════════════════════════════╗
--   COLOR PICKER POPUP
-- ╚══════════════════════════════════════════════════════════════╝
local CPop=New("Frame",{Size=UDim2.new(0,250,0,158),BackgroundColor3=C.Glass,BackgroundTransparency=0.05,
    BorderSizePixel=0,Visible=false,ZIndex=900},Gui)
Corner(CPop,12); Stroke(CPop,C.CyanBr,1.8,0)
Grad(CPop,Color3.fromRGB(6,18,58),Color3.fromRGB(2,8,26),130)
Shimmer(CPop,902)

New("TextLabel",{Size=UDim2.new(1,-30,0,20),Position=UDim2.new(0,10,0,4),BackgroundTransparency=1,
    Text="  COLOR EDITOR",TextColor3=C.CyanBr,TextSize=11,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=901},CPop)
local cpX=New("TextButton",{Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-28,0,2),
    BackgroundColor3=Color3.fromRGB(130,20,20),Text="✕",TextColor3=Color3.new(1,1,1),
    TextSize=11,Font=Enum.Font.GothamBold,BorderSizePixel=0,AutoButtonColor=false,ZIndex=902},CPop)
Corner(cpX,5)
cpX.MouseButton1Click:Connect(function()
    tw(CPop,0.15,{BackgroundTransparency=1})
    task.delay(0.16,function() CPop.Visible=false; CPop.BackgroundTransparency=0.05 end)
end)

local cpRGB={r=255,g=255,b=255}; local cpCBs={}; local cpSliders={}
local chDefs={{k="r",lbl="R",col=Color3.fromRGB(255,70,70)},{k="g",lbl="G",col=Color3.fromRGB(50,210,90)},{k="b",lbl="B",col=Color3.fromRGB(60,140,240)}}
for idx,ch in ipairs(chDefs) do
    local y=26+(idx-1)*40
    New("TextLabel",{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,8,0,y+9),BackgroundTransparency=1,
        Text=ch.lbl,TextColor3=ch.col,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=901},CPop)
    local valLbl=New("TextLabel",{Size=UDim2.new(0,32,0,14),Position=UDim2.new(1,-40,0,y+9),
        BackgroundTransparency=1,Text="255",TextColor3=C.White,TextSize=10,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right,ZIndex=901},CPop)
    local tr=New("Frame",{Size=UDim2.new(1,-56,0,14),Position=UDim2.new(0,24,0,y+9),
        BackgroundColor3=C.OFF,BorderSizePixel=0,ZIndex=901},CPop)
    Corner(tr,7); Stroke(tr,C.BorderDk,1,0.4)
    local fi=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=ch.col,BorderSizePixel=0,ZIndex=902},tr)
    Corner(fi,7)
    local thumb=New("Frame",{Size=UDim2.new(0,14,0,14),Position=UDim2.new(1,-7,0.5,-7),
        BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=903},tr)
    Corner(thumb,7); Stroke(thumb,ch.col,1.5,0)
    local cpBtn=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=904},tr)
    local function cpSet(px)
        if not CPop.Visible then return end
        local pct=math.clamp((px-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        cpRGB[ch.k]=math.floor(pct*255); fi.Size=UDim2.new(pct,0,1,0)
        thumb.Position=UDim2.new(pct,-7,0.5,-7); valLbl.Text=tostring(cpRGB[ch.k])
        local col=Color3.fromRGB(cpRGB.r,cpRGB.g,cpRGB.b)
        for _,cb in ipairs(cpCBs) do cb(col) end
    end
    cpBtn.MouseButton1Down:Connect(function(x) _aCPSl=cpSet; cpSet(x) end)
    cpSliders[ch.k]={tr=tr,fi=fi,vl=valLbl,thumb=thumb}
end

local cpPrev=New("Frame",{Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,8,1,-20),
    BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=901},CPop)
Corner(cpPrev,6); Stroke(cpPrev,C.CyanBr,1,0.4)

local function OpenCP(anchor,curCol,onCh)
    cpRGB.r=math.floor(curCol.R*255); cpRGB.g=math.floor(curCol.G*255); cpRGB.b=math.floor(curCol.B*255)
    for _,k in ipairs({"r","g","b"}) do
        local v=cpRGB[k]
        cpSliders[k].fi.Size=UDim2.new(v/255,0,1,0)
        cpSliders[k].thumb.Position=UDim2.new(v/255,-7,0.5,-7)
        cpSliders[k].vl.Text=tostring(v)
    end
    cpPrev.BackgroundColor3=curCol
    cpCBs={onCh,function(col) cpPrev.BackgroundColor3=col end}
    local ap=anchor.AbsolutePosition; local ss=Gui.AbsoluteSize
    local px=math.clamp(ap.X-125,4,ss.X-254)
    local py=ap.Y+anchor.AbsoluteSize.Y+6
    if py+165>ss.Y then py=ap.Y-165 end
    CPop.Position=UDim2.new(0,px,0,py)
    CPop.Size=UDim2.new(0,12,0,12); CPop.BackgroundTransparency=1; CPop.Visible=true
    tw(CPop,0.3,{Size=UDim2.new(0,250,0,158),BackgroundTransparency=0.05},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
end

-- ╔══════════════════════════════════════════════════════════════╗
--   TABS — COMBAT · VISUALS · WORLD · MOVEMENT
-- ╚══════════════════════════════════════════════════════════════╝
local TabBar=New("Frame",{Size=UDim2.new(1,-20,0,38),Position=UDim2.new(0,10,0,98),
    BackgroundTransparency=1,BorderSizePixel=0,ZIndex=11},Win)
New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5)},TabBar)

local Scroll=New("ScrollingFrame",{
    Size=UDim2.new(1,-20,1,-148),Position=UDim2.new(0,10,0,144),
    BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=3,ScrollBarImageColor3=C.CyanBr,
    CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ClipsDescendants=true,ZIndex=11,
},Win)
New("UIPadding",{PaddingBottom=UDim.new(0,12)},Scroll)
New("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},Scroll)

local TAB_IDX={COMBAT=1,VISUALS=2,WORLD=3,MOVEMENT=4}
local TPages,TBtns,TUnders={},{},{}
local _curTab=nil

local function SwitchTab(name)
    if name==_curTab then return end
    CPop.Visible=false
    local prevTab=_curTab; _curTab=name

    for n,pg in pairs(TPages) do
        if n==name then
            -- Show new page instantly at correct position, then fade in
            pg.Position=UDim2.new(0,0,0,0)
            pg.BackgroundTransparency=1
            pg.Visible=true
            tw(pg,0.22,{BackgroundTransparency=0},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        else
            -- Hide old page immediately — no sliding, no glitch
            pg.Visible=false
            pg.Position=UDim2.new(0,0,0,0)
        end
    end

    for n,btn in pairs(TBtns) do
        if n==name then
            tw(btn,0.15,{BackgroundColor3=Color3.fromRGB(0,80,180),TextColor3=C.White})
            local ul=TUnders[n]
            if ul then
                ul.Size=UDim2.new(0,0,0,2); ul.Position=UDim2.new(0.5,0,1,-2); ul.BackgroundTransparency=0
                tw(ul,0.28,{Size=UDim2.new(0.85,0,0,2),Position=UDim2.new(0.075,0,1,-2)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
            end
        else
            tw(btn,0.12,{BackgroundColor3=C.CyanDk,TextColor3=C.Muted})
            local ul=TUnders[n]
            if ul then tw(ul,0.12,{Size=UDim2.new(0,0,0,2),BackgroundTransparency=1}) end
        end
    end
end

local tabIcons={COMBAT="⚔",VISUALS="👁",WORLD="🌐",MOVEMENT="⚡"}
local function MakeTab(name)
    local btn=New("TextButton",{Size=UDim2.new(0,150,1,0),BackgroundColor3=C.CyanDk,
        Text=(tabIcons[name] or "").. "  "..name,TextColor3=C.Muted,TextSize=11,Font=Enum.Font.GothamBold,
        BorderSizePixel=0,AutoButtonColor=false,ZIndex=12},TabBar)
    Corner(btn,9); Stroke(btn,C.BorderDk,1,0.4)

    local ul=New("Frame",{Size=UDim2.new(0,0,0,2),Position=UDim2.new(0.5,0,1,-2),
        BackgroundColor3=C.CyanBr,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=13},btn)
    Corner(ul,1); TUnders[name]=ul

    local pg=New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,Visible=false,BorderSizePixel=0,ZIndex=12},Scroll)
    New("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},pg)

    btn.MouseEnter:Connect(function()
        if _curTab~=name then
            tw(btn,0.12,{BackgroundColor3=Color3.fromRGB(0,50,130)})
            tw(btn,0.12,{TextColor3=C.White})
        end
    end)
    btn.MouseLeave:Connect(function()
        if _curTab~=name then
            tw(btn,0.12,{BackgroundColor3=C.CyanDk})
            tw(btn,0.12,{TextColor3=C.Muted})
        end
    end)
    btn.MouseButton1Click:Connect(function()
        Pulse(btn); Ripple(btn,UIS:GetMouseLocation().X,UIS:GetMouseLocation().Y); SwitchTab(name)
    end)

    TPages[name]=pg; TBtns[name]=btn; return pg
end

-- ╔══════════════════════════════════════════════════════════════╗
--   SECTION + WIDGETS
-- ╚══════════════════════════════════════════════════════════════╝
local function MakeSection(page,title)
    local sec=New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=C.Glass,BackgroundTransparency=0.15,
        BorderSizePixel=0,ZIndex=13,Parent=page})
    Corner(sec,10)
    local secSt=Stroke(sec,C.Cyan,1,0.75)
    Grad(sec,Color3.fromRGB(8,18,52),Color3.fromRGB(2,8,22),138)
    New("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},sec)
    New("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},sec)
    sec.MouseEnter:Connect(function() tw(secSt,0.2,{Color=C.Cyan,Transparency=0.2,Thickness=1.5}) end)
    sec.MouseLeave:Connect(function() tw(secSt,0.28,{Color=C.Cyan,Transparency=0.75,Thickness=1}) end)

    -- Section header
    local hdr=New("Frame",{Size=UDim2.new(1,0,0,30),BackgroundColor3=C.CyanDk,
        BackgroundTransparency=0.05,BorderSizePixel=0,LayoutOrder=0,ZIndex=14,Parent=sec})
    Corner(hdr,8); Grad(hdr,Color3.fromRGB(0,45,120),Color3.fromRGB(0,18,62),180)
    Stroke(hdr,C.Border,1,0.4); Shimmer(hdr,17)

    -- Pulsing dot
    local hdot=New("Frame",{Size=UDim2.new(0,7,0,7),Position=UDim2.new(0,9,0.5,-3.5),
        BackgroundColor3=C.CyanBr,BorderSizePixel=0,ZIndex=17},hdr)
    Corner(hdot,4)
    -- Dot ring
    local hdotRing=New("Frame",{Size=UDim2.new(0,7,0,7),Position=UDim2.new(0,9,0.5,-3.5),
        BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=16},hdr)
    Corner(hdotRing,8); Stroke(hdotRing,C.CyanBr,1,0)
    task.spawn(function()
        while hdr and hdr.Parent do
            tw(hdot,0.6,{BackgroundTransparency=0,BackgroundColor3=C.CyanBr}); task.wait(0.6)
            tw(hdot,0.6,{BackgroundTransparency=0.8,BackgroundColor3=C.Purple}); task.wait(0.6)
        end
    end)
    task.spawn(function()
        while hdr and hdr.Parent do
            hdotRing.Size=UDim2.new(0,7,0,7); hdotRing.Position=UDim2.new(0,9,0.5,-3.5)
            local rs=hdotRing:FindFirstChildOfClass("UIStroke")
            if rs then rs.Transparency=0 end
            tw(hdotRing,0.8,{Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,3.5,0.5,-9)},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
            if rs then tw(rs,0.8,{Transparency=1}) end
            task.wait(2.5)
        end
    end)

    New("TextLabel",{Size=UDim2.new(1,-24,1,0),Position=UDim2.new(0,22,0,0),
        BackgroundTransparency=1,Text=title,TextColor3=C.CyanBr,TextSize=12,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,TextStrokeTransparency=1,ZIndex=16},hdr)

    local order=0
    local function nxt() order=order+1; return order end

    local function MakeRow(h)
        local r=New("Frame",{Size=UDim2.new(1,0,0,h),BackgroundColor3=C.Row,
            BackgroundTransparency=0.25,BorderSizePixel=0,LayoutOrder=nxt(),ZIndex=14,Parent=sec})
        Corner(r,8); Stroke(r,C.Cyan,1,0.88)
        r.MouseEnter:Connect(function()
            tw(r,0.12,{BackgroundTransparency=0.08})
            tw(r:FindFirstChildOfClass("UIStroke"),0.12,{Color=C.Cyan,Transparency=0.5})
        end)
        r.MouseLeave:Connect(function()
            tw(r,0.12,{BackgroundTransparency=0.25})
            tw(r:FindFirstChildOfClass("UIStroke"),0.12,{Color=C.Cyan,Transparency=0.88})
        end)
        return r
    end

    -- TOGGLE WIDGET
    local function NewToggle(lbl,desc,cb)
        local row=MakeRow(54)
        -- Left accent strip
        local strip=New("Frame",{Size=UDim2.new(0,3,0.55,0),Position=UDim2.new(0,0,0.225,0),
            BackgroundColor3=C.CyanDk,BorderSizePixel=0,ZIndex=15},row)
        Corner(strip,2)
        New("TextLabel",{Size=UDim2.new(1,-76,0,22),Position=UDim2.new(0,13,0,8),
            BackgroundTransparency=1,Text=lbl,TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15},row)
        New("TextLabel",{Size=UDim2.new(1,-76,0,14),Position=UDim2.new(0,13,0,30),
            BackgroundTransparency=1,Text=desc,TextColor3=C.Muted,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15},row)
        -- Toggle pill
        local pill=New("Frame",{Size=UDim2.new(0,50,0,26),Position=UDim2.new(1,-60,0.5,-13),
            BackgroundColor3=C.OFF,BorderSizePixel=0,ZIndex=15},row)
        Corner(pill,13); Stroke(pill,C.BorderDk,1,0.3)
        -- Knob
        local knob=New("Frame",{Size=UDim2.new(0,22,0,22),Position=UDim2.new(0,2,0.5,-11),
            BackgroundColor3=C.CyanDk,BorderSizePixel=0,ZIndex=16},pill)
        Corner(knob,11); Stroke(knob,C.BorderDk,1,0.4)
        -- ON glow fill
        local pillFill=New("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.Cyan,
            BackgroundTransparency=0.4,BorderSizePixel=0,ZIndex=15.5},pill)
        Corner(pillFill,13)

        local clickBtn=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=17},row)
        local state=false
        clickBtn.MouseButton1Click:Connect(function()
            state=not state; cb(state)
            Pulse(row)
            -- Ripple on pill
            Ripple(pill,pill.AbsolutePosition.X+25,pill.AbsolutePosition.Y+13)
            if state then
                tw(pill,0.22,{BackgroundColor3=Color3.fromRGB(0,50,100)})
                tw(pillFill,0.22,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=0.35})
                tw(knob,0.25,{Position=UDim2.new(1,-24,0.5,-11),BackgroundColor3=C.White},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
                tw(strip,0.18,{BackgroundColor3=C.Cyan})
                local ks=knob:FindFirstChildOfClass("UIStroke") or Stroke(knob,C.CyanBr,1.5,0)
                tw(ks,0.2,{Color=C.CyanBr,Transparency=0})
            else
                tw(pill,0.22,{BackgroundColor3=C.OFF})
                tw(pillFill,0.18,{Size=UDim2.new(0,0,1,0),BackgroundTransparency=0.4})
                tw(knob,0.25,{Position=UDim2.new(0,2,0.5,-11),BackgroundColor3=C.CyanDk},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
                tw(strip,0.18,{BackgroundColor3=C.CyanDk})
                local ks=knob:FindFirstChildOfClass("UIStroke")
                if ks then tw(ks,0.2,{Color=C.BorderDk,Transparency=0.4}) end
            end
        end)
    end

    -- SLIDER WIDGET
    local function NewSlider(lbl,desc,maxV,minV,cb)
        local row=MakeRow(72)
        New("TextLabel",{Size=UDim2.new(0.62,0,0,22),Position=UDim2.new(0,13,0,6),
            BackgroundTransparency=1,Text=lbl,TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15},row)
        local vLbl=New("TextLabel",{Size=UDim2.new(0.38,-13,0,22),Position=UDim2.new(0.62,0,0,6),
            BackgroundTransparency=1,Text=tostring(minV),TextColor3=C.CyanBr,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Right,ZIndex=15},row)
        New("TextLabel",{Size=UDim2.new(1,-26,0,14),Position=UDim2.new(0,13,0,28),
            BackgroundTransparency=1,Text=desc,TextColor3=C.Muted,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15},row)
        local track=New("Frame",{Size=UDim2.new(1,-26,0,18),Position=UDim2.new(0,13,0,48),
            BackgroundColor3=C.OFF,BorderSizePixel=0,ZIndex=15},row)
        Corner(track,9); Stroke(track,C.BorderDk,1,0.4)
        local fill=New("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.Cyan,BorderSizePixel=0,ZIndex=16},track)
        Corner(fill,9)
        New("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,C.CyanBr),ColorSequenceKeypoint.new(1,C.Cyan)},Rotation=180},fill)
        -- Glow on fill
        local fillGlow=New("Frame",{Size=UDim2.new(1,0,1,6),Position=UDim2.new(0,0,0,-3),
            BackgroundColor3=C.Cyan,BackgroundTransparency=0.8,BorderSizePixel=0,ZIndex=15.5},fill)
        Corner(fillGlow,9)

        local sknob=New("Frame",{Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,-10,0.5,-10),
            BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=18},track)
        Corner(sknob,10); Stroke(sknob,C.CyanBr,2,0.2)

        local function SetPct(px)
            local ap=track.AbsolutePosition; local as=track.AbsoluteSize
            if as.X==0 then return end
            local pct=math.clamp((px-ap.X)/as.X,0,1)
            local v=math.clamp(math.floor(minV+pct*(maxV-minV)),minV,maxV)
            local rp=(maxV==minV) and 0 or (v-minV)/(maxV-minV)
            fill.Size=UDim2.new(rp,0,1,0); sknob.Position=UDim2.new(rp,-10,0.5,-10)
            vLbl.Text=tostring(v); cb(v)
        end
        task.defer(function() SetPct(track.AbsolutePosition.X) end)

        local tBtn=New("TextButton",{Size=UDim2.new(1,14,1,14),Position=UDim2.new(0,-7,0.5,-7),
            BackgroundTransparency=1,Text="",ZIndex=19},track)
        tBtn.MouseButton1Down:Connect(function(x)
            _aSl=SetPct; SetPct(x)
            tw(sknob,0.2,{Size=UDim2.new(0,26,0,26)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
            tw(fillGlow,0.2,{BackgroundTransparency=0.55})
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 and _aSl==SetPct then
                tw(sknob,0.22,{Size=UDim2.new(0,20,0,20)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
                tw(fillGlow,0.2,{BackgroundTransparency=0.8})
            end
        end)
    end

    -- COLOR PICKER WIDGET
    local function NewColorPicker(lbl,desc,defCol,cb)
        local row=MakeRow(54)
        New("TextLabel",{Size=UDim2.new(1,-76,0,22),Position=UDim2.new(0,13,0,8),
            BackgroundTransparency=1,Text=lbl,TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15},row)
        New("TextLabel",{Size=UDim2.new(1,-76,0,14),Position=UDim2.new(0,13,0,30),
            BackgroundTransparency=1,Text=desc,TextColor3=C.Muted,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15},row)
        local cur=defCol
        local sw=New("Frame",{Size=UDim2.new(0,44,0,36),Position=UDim2.new(1,-54,0.5,-18),
            BackgroundColor3=defCol,BorderSizePixel=0,ZIndex=15},row)
        Corner(sw,9); Stroke(sw,C.CyanBr,1.5,0.2)
        -- Checkerboard hint
        local swBtn=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="🎨",
            TextSize=14,TextColor3=Color3.new(1,1,1),Font=Enum.Font.Gotham,ZIndex=16},sw)
        swBtn.TextTransparency=0.65
        swBtn.MouseEnter:Connect(function() tw(sw,0.12,{Size=UDim2.new(0,48,0,38),Position=UDim2.new(1,-56,0.5,-19)}) end)
        swBtn.MouseLeave:Connect(function() tw(sw,0.12,{Size=UDim2.new(0,44,0,36),Position=UDim2.new(1,-54,0.5,-18)}) end)
        swBtn.MouseButton1Click:Connect(function()
            Pulse(sw)
            if CPop.Visible then
                tw(CPop,0.15,{BackgroundTransparency=1})
                task.delay(0.16,function() CPop.Visible=false; CPop.BackgroundTransparency=0.05 end)
            else OpenCP(sw,cur,function(col) cur=col; sw.BackgroundColor3=col; cb(col) end) end
        end)
    end

    return {NewToggle=NewToggle,NewSlider=NewSlider,NewColorPicker=NewColorPicker}
end

-- ╔══════════════════════════════════════════════════════════════╗
--   BUILD TABS
-- ╚══════════════════════════════════════════════════════════════╝
local PC = MakeTab("COMBAT")
local PV = MakeTab("VISUALS")
local PW = MakeTab("WORLD")
local PM = MakeTab("MOVEMENT")
SwitchTab("COMBAT")

local SA  = MakeSection(PC, "⚔  AIMBOT SYSTEM")
local SPE = MakeSection(PV, "👤  PLAYER ESP")
local SWE = MakeSection(PV, "🐾  WORLD ESP")
local SVC = MakeSection(PV, "🎨  DISPLAY CONFIG")
local SU  = MakeSection(PW, "⚙  UTILITY")
local SM  = MakeSection(PM, "🏃  MOVEMENT")

-- ╔══════════════════════════════════════════════════════════════╗
--   GAME LOGIC (unchanged)
-- ╚══════════════════════════════════════════════════════════════╝
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
    local p=RaycastParams.new(); p.FilterDescendantsInstances={c}
    p.FilterType=Enum.RaycastFilterType.Exclude; p.IgnoreWater=true
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
    for _,e in ipairs(m) do if n:find(e[1]) then return pre..e[2] end end
    return o.Name
end

local _lockedTarget=nil
local function IsAlive(part)
    if not part or not part.Parent then return false end
    local hum=part.Parent:FindFirstChildOfClass("Humanoid")
        or (part.Parent.Parent and part.Parent.Parent:FindFirstChildOfClass("Humanoid"))
    return hum and hum.Health>0
end

local function GetTarget()
    if S.LockTarget and _lockedTarget and IsAlive(_lockedTarget) then
        local _,vis=Cam:WorldToViewportPoint(_lockedTarget.Position)
        if vis then return _lockedTarget end
    end
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
    if S.LockTarget then _lockedTarget=tp end
    return tp
end

local function ManageESP(char,text,color,tag,show,dist,isP,hum)
    local rp=isP and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")) or GetRoot(char)
    if not rp then return end
    if show and (isP or dist<=S.ESPDist) then
        local bb=rp:FindFirstChild(tag)
        if not bb then
            bb=Instance.new("BillboardGui"); bb.Name=tag; bb.Adornee=rp
            bb.AlwaysOnTop=true; bb.Size=UDim2.new(0,200,0,72)
            bb.StudsOffset=Vector3.new(0,2.8,0); bb.Parent=rp
            local lb=Instance.new("TextLabel",bb); lb.Name="L"
            lb.BackgroundTransparency=1; lb.Size=UDim2.new(1,0,0,22)
            lb.TextStrokeTransparency=0.25; lb.TextStrokeColor3=Color3.new(0,0,0)
            lb.Font=Enum.Font.GothamBold; lb.TextYAlignment=Enum.TextYAlignment.Top
            local hbg=Instance.new("Frame",bb); hbg.Name="HBG"
            hbg.Size=UDim2.new(0.7,0,0,7); hbg.Position=UDim2.new(0.15,0,0,26)
            hbg.BackgroundColor3=Color3.fromRGB(15,15,15); hbg.BackgroundTransparency=0.3; hbg.BorderSizePixel=0
            Instance.new("UICorner",hbg).CornerRadius=UDim.new(0,3)
            local hfill=Instance.new("Frame",hbg); hfill.Name="F"; hfill.Size=UDim2.new(1,0,1,0); hfill.BorderSizePixel=0
            Instance.new("UICorner",hfill).CornerRadius=UDim.new(0,3)
            local hnum=Instance.new("TextLabel",bb); hnum.Name="HN"
            hnum.BackgroundTransparency=1; hnum.Size=UDim2.new(1,0,0,14); hnum.Position=UDim2.new(0,0,0,36)
            hnum.TextStrokeTransparency=0.3; hnum.TextStrokeColor3=Color3.new(0,0,0)
            hnum.Font=Enum.Font.GothamBold; hnum.TextSize=9
        end
        local lb=bb:FindFirstChild("L"); local hbg=bb:FindFirstChild("HBG"); local hnum=bb:FindFirstChild("HN")
        if lb then lb.TextSize=S.TextSize; lb.TextColor3=color; lb.Text=text..(S.ShowDist and ("  ["..dist.."m]") or "") end
        local showHP=isP and hum and S.PlayerHP
        if hbg then hbg.Visible=showHP or false end
        if hnum then hnum.Visible=showHP or false end
        if showHP then
            local pct=math.clamp(hum.Health/hum.MaxHealth,0,1)
            local fill=hbg:FindFirstChild("F")
            if fill then fill.Size=UDim2.new(pct,0,1,0); fill.BackgroundColor3=Color3.fromRGB(math.floor(255*(1-pct)),math.floor(200*pct),40) end
            if hnum then hnum.TextColor3=color; hnum.Text=math.floor(hum.Health).." / "..math.floor(hum.MaxHealth) end
        end
    else
        local bb=rp:FindFirstChild(tag); if bb then bb:Destroy() end
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

task.spawn(function() while true do task.wait(0.15)
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LocalPlayer then continue end
        pcall(function()
            local c=p.Character; if not c then return end
            local hum=c:FindFirstChildOfClass("Humanoid")
            local rp=c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
            if rp and hum and hum.Health>0 then
                local dist=GetDist(rp.Position)
                local show=S.PlayerName or S.PlayerHP
                local txt=S.PlayerName and ("[ "..p.Name.." ]") or ""
                ManageESP(c,txt,S.PlayerColor,"GWPLYR",show,dist,true,hum)
                local hl=c:FindFirstChild("GWPH")
                if S.PlayerBox then
                    if not hl then hl=Instance.new("Highlight"); hl.Name="GWPH"; hl.Parent=c end
                    hl.FillColor=S.PlayerColor
                    hl.FillTransparency=math.clamp(1-S.BoxSize*0.35,0.4,0.9)
                    hl.OutlineColor=C.Cyan; hl.OutlineTransparency=0
                elseif hl then hl:Destroy() end
            else
                local b=c:FindFirstChild("GWPLYR",true); if b then b:Destroy() end
                local hl=c:FindFirstChild("GWPH"); if hl then hl:Destroy() end
            end
        end)
    end
end end)

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

-- ╔══════════════════════════════════════════════════════════════╗
--   RENDER LOOP
-- ╚══════════════════════════════════════════════════════════════╝

Run.RenderStepped:Connect(function()
    -- TRACERS
    local bot=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y)
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl==LocalPlayer then continue end
        local td=GetOrMakeTracer(pl)
        local ch=pl.Character; local hd=ch and ch:FindFirstChild("Head")
        local hum=ch and ch:FindFirstChildOfClass("Humanoid")
        local ok=ch and hd and hum and hum.Health>0 and hd:IsDescendantOf(workspace)
        if ok then
            local p3,on=Cam:WorldToViewportPoint(hd.Position)
            if on and S.Tracers then
                td.line.From=bot; td.line.To=Vector2.new(p3.X,p3.Y)
                td.line.Color=S.TracerColor
                td.line.Thickness=math.max(0.5,S.TracerThickness)
                td.line.Transparency=S.TracerTransp
                td.line.Visible=true
            else td.line.Visible=false end
        else td.line.Visible=false end
    end

    -- FOV
    FOVC.Visible=S.ShowFOV; FOVC.Radius=S.FOV
    FOVC.Position=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)

    -- AIMBOT
    local ap=GetTarget()
    if ap then
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            Cam.CFrame=CFrame.new(Cam.CFrame.Position,ap.Position)
        end
        if S.SilentAim and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,ap.Position),S.SilentSmooth)
        end
    end

    -- TP WALK
    if S.TPWalk then
        local c=LocalPlayer.Character; if c then
            local h=c:FindFirstChildOfClass("Humanoid")
            if h and h.MoveDirection.Magnitude>0 then c:TranslateBy(h.MoveDirection*S.TPSpeed*0.1) end
        end
    end
end)

-- ╔══════════════════════════════════════════════════════════════╗
--   POPULATE TABS — ALL ENGLISH
-- ╚══════════════════════════════════════════════════════════════╝

-- COMBAT
SA.NewToggle("Target Players",   "RMB — lock onto players",             function(v) S.AimPlayers=v end)
SA.NewToggle("Target Animals",   "RMB — lock onto animals & NPCs",      function(v) S.AimAnimals=v end)
SA.NewToggle("Wall Check",       "Only aim at visible targets",          function(v) S.WallCheck=v end)
SA.NewToggle("Silent Fire",      "LMB — smooth silent aim",             function(v) S.SilentAim=v end)
SA.NewToggle("Lock Target",      "Keep locked after first acquisition",  function(v) S.LockTarget=v; if not v then _lockedTarget=nil end end)
SA.NewSlider("FOV Radius",       "Aim circle radius in pixels", 800,10,  function(v) S.FOV=v end)
SA.NewSlider("Silent Smoothing", "1 = instant   50 = smooth",  50,1,    function(v) S.SilentSmooth=v/100 end)
SA.NewToggle("Show FOV Ring",    "Draw the FOV circle on screen",        function(v) S.ShowFOV=v end)
SA.NewColorPicker("FOV Color",   "FOV ring color", FOVC.Color,           function(v) FOVC.Color=v end)

-- VISUALS — PLAYER
SPE.NewToggle("Name ESP",        "Show player name above head",          function(v) S.PlayerName=v end)
SPE.NewToggle("Health ESP",      "HP bar and numbers",                   function(v) S.PlayerHP=v end)
SPE.NewToggle("Box ESP",         "Highlight player model",               function(v) S.PlayerBox=v end)
SPE.NewSlider("Box Opacity",     "Highlight density 1–5",     5,1,       function(v) S.BoxSize=v end)
SPE.NewToggle("Tracers",         "Draw lines from screen bottom",        function(v) S.Tracers=v end)
SPE.NewSlider("Tracer Width",    "Line thickness 1–6",        6,1,       function(v) S.TracerThickness=v end)
SPE.NewSlider("Tracer Alpha",    "0 = solid   90 = faint",   90,0,       function(v) S.TracerTransp=v/100 end)
SPE.NewColorPicker("Tracer Color","Tracer line color", S.TracerColor,    function(v) S.TracerColor=v end)
SPE.NewColorPicker("Player Color","ESP label color", S.PlayerColor,      function(v) S.PlayerColor=v end)

-- VISUALS — WORLD
SWE.NewToggle("Animal ESP",      "Track animals & harvestables",         function(v) S.AnimalESP=v; if not v then CleanAESP() end end)
SWE.NewToggle("Show Distance",   "Display distance to target",           function(v) S.ShowDist=v end)

-- VISUALS — DISPLAY
SVC.NewSlider("Max Animal Range","Max ESP range for animals",20000,500,  function(v) S.ESPDist=v end)
SVC.NewSlider("Label Size",      "ESP text size",             20,8,      function(v) S.TextSize=v end)
SVC.NewColorPicker("Animal Color","Animal label color", S.AnimalColor,   function(v) S.AnimalColor=v end)

-- WORLD — UTILITY
SU.NewToggle("Full Bright",      "Maximum game lighting",                function(v)
    S.FullBright=v
    if v then
        S.NightMode=false
        Light.ClockTime=14; Light.Brightness=2
        Light.GlobalShadows=false; Light.FogEnd=100000
    else
        RestoreLight()
    end
end)
SU.NewToggle("Night Mode",       "Dark sky — better player visibility",  function(v)
    S.NightMode=v
    if v then
        S.FullBright=false
        Light.ClockTime=0; Light.Brightness=0.5
        Light.GlobalShadows=false
        Light.Ambient=Color3.fromRGB(50,60,80)
        Light.OutdoorAmbient=Color3.fromRGB(30,40,60)
    else
        RestoreLight()
    end
end)
SU.NewToggle("Instant Interact", "Skip hold time on interactions",       function(v) S.Interact=v; if v then ApplyInstantInteract() end end)

-- MOVEMENT
SM.NewToggle("Noclip",           "Phase through walls & terrain",        function(v) S.Noclip=v; SetNoclip(v) end)
SM.NewToggle("Speed Boost",      "Increase walk speed",                  function(v) S.SpeedBoost=v; ApplySpeed() end)
SM.NewSlider("Walk Speed",       "Speed value (default 16)", 120,16,     function(v) S.SpeedVal=v; ApplySpeed() end)
SM.NewToggle("TP-Walk",          "Move via teleport steps",              function(v) S.TPWalk=v end)
SM.NewSlider("TP Speed",         "Teleport step strength 1–15", 15,1,    function(v) S.TPSpeed=v end)

-- Instant Interact — proper implementation
local function ApplyInstantInteract()
    -- Apply to all existing prompts in workspace
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            obj.HoldDuration = 0
        end
    end
end

PPS.PromptShown:Connect(function(prompt)
    if S.Interact then
        prompt.HoldDuration = 0
    end
end)

-- Also catch any prompts added dynamically
workspace.DescendantAdded:Connect(function(obj)
    if S.Interact and obj:IsA("ProximityPrompt") then
        obj.HoldDuration = 0
    end
end)

-- ╔══════════════════════════════════════════════════════════════╗
--   BOOT ANIMATION — Window slides in from top
-- ╚══════════════════════════════════════════════════════════════╝
Win.Position=UDim2.new(0.5,-320,0,-300)
Win.BackgroundTransparency=1
tw(Win,0.55,{Position=UDim2.new(0.5,-320,0.5,-290),BackgroundTransparency=0.06},Enum.EasingStyle.Back,Enum.EasingDirection.Out)

pcall(function()
    SGui:SetCore("SendNotification",{
        Title="ZENITH  v16  ✓",
        Text="Cyber Glass · RightCtrl = Hide · X = Full Cleanup",
        Duration=5,
    })
end)
