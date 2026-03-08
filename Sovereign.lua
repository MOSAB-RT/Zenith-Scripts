-- ╔══════════════════════════════════════════════════════════╗
--   Mosab Westbound  |  CYBER UI  |  v4 FINAL
--   RightCtrl = Hide/Show  |  Drag from TitleBar
-- ╚══════════════════════════════════════════════════════════╝

-- ── WHITELIST ─────────────────────────────────────────────
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not ({["mairjdyr"]=true})[LocalPlayer.Name] then
    warn("[CYBER//WEST] ACCESS DENIED"); return
end

-- ── SERVICES ──────────────────────────────────────────────
local Run   = game:GetService("RunService")
local UIS   = game:GetService("UserInputService")
local Light = game:GetService("Lighting")
local PPS   = game:GetService("ProximityPromptService")
local Tween = game:GetService("TweenService")
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
    GodMode=false,
}

-- ── FOV CIRCLE ────────────────────────────────────────────
local FOVC = Drawing.new("Circle")
FOVC.Thickness=1.5; FOVC.Filled=false
FOVC.Color=Color3.fromRGB(220,30,30)
FOVC.Transparency=1; FOVC.Visible=false

-- ── PALETTE ───────────────────────────────────────────────
local C = {
    BG      = Color3.fromRGB(8,8,12),
    BG2     = Color3.fromRGB(14,14,20),
    Panel   = Color3.fromRGB(16,16,24),
    Red     = Color3.fromRGB(185,28,28),
    RedD    = Color3.fromRGB(60,8,8),
    RedB    = Color3.fromRGB(230,60,60),
    Accent  = Color3.fromRGB(220,45,45),
    White   = Color3.fromRGB(238,238,238),
    Gray    = Color3.fromRGB(115,115,135),
    Green   = Color3.fromRGB(45,195,95),
    Border  = Color3.fromRGB(100,18,18),
    Border2 = Color3.fromRGB(140,30,30),
    OFF     = Color3.fromRGB(45,45,58),
}

-- ── HELPERS ───────────────────────────────────────────────
local function New(cls,props,par)
    local o=Instance.new(cls)
    for k,v in pairs(props) do o[k]=v end
    if par then o.Parent=par end
    return o
end
local function RC(p,r) New("UICorner",{CornerRadius=UDim.new(0,r or 5)},p) end
local function Stroke(p,col,th,trans)
    New("UIStroke",{Color=col or C.Border,Thickness=th or 1,Transparency=trans or 0},p)
end
local function Grad(p,c0,c1,rot)
    New("UIGradient",{Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,c0),
        ColorSequenceKeypoint.new(1,c1),
    },Rotation=rot or 90},p)
end
local function Shadow(p)
    -- fake drop shadow via a slightly bigger darker frame behind
    local s=New("Frame",{
        Size=UDim2.new(1,6,1,6),Position=UDim2.new(0,-3,0,3),
        BackgroundColor3=Color3.fromRGB(0,0,0),
        BackgroundTransparency=0.55,BorderSizePixel=0,ZIndex=p.ZIndex-1,
    },p.Parent)
    RC(s,8)
    s.Parent=p.Parent
    p.Parent=p.Parent -- re-set to keep order
    return s
end

-- ── ROOT GUI ──────────────────────────────────────────────
local Gui=New("ScreenGui",{
    Name="CyberWest",ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset=true,
},LocalPlayer:WaitForChild("PlayerGui"))

-- ── WINDOW ────────────────────────────────────────────────
local Win=New("Frame",{
    Size=UDim2.new(0,590,0,530),
    Position=UDim2.new(0.5,-295,0.5,-265),
    BackgroundColor3=C.BG,BorderSizePixel=0,
    ClipsDescendants=false,
},Gui)
RC(Win,8)
Grad(Win, Color3.fromRGB(14,10,16), Color3.fromRGB(8,8,12), 135)
Stroke(Win,C.Border2,1.5)

-- glow outline effect
local glow=New("Frame",{
    Size=UDim2.new(1,4,1,4),Position=UDim2.new(0,-2,0,-2),
    BackgroundColor3=C.Red,BackgroundTransparency=0.82,
    BorderSizePixel=0,ZIndex=0,
},Win)
RC(glow,10)

-- ── TITLE BAR ─────────────────────────────────────────────
local TBar=New("Frame",{
    Size=UDim2.new(1,0,0,44),
    BackgroundColor3=C.Red,BorderSizePixel=0,
},Win)
RC(TBar,8)
Grad(TBar, Color3.fromRGB(210,35,35), Color3.fromRGB(130,18,18), 180)
New("Frame",{Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),
    BackgroundColor3=Color3.fromRGB(155,20,20),BorderSizePixel=0},TBar)
Stroke(TBar,Color3.fromRGB(255,80,80),1,0.5)

-- accent line under titlebar
New("Frame",{
    Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),
    BackgroundColor3=C.RedB,BorderSizePixel=0,
},TBar)

New("TextLabel",{
    Size=UDim2.new(1,-54,1,0),Position=UDim2.new(0,14,0,0),
    BackgroundTransparency=1,
    Text="Mosab Westbound   ·   "..LocalPlayer.Name.."   ·   ONLINE",
    TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left,
    TextStrokeTransparency=0.6,TextStrokeColor3=Color3.new(0,0,0),
},TBar)

local XBtn=New("TextButton",{
    Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-36,0.5,-14),
    BackgroundColor3=C.RedD,Text="✕",TextColor3=C.White,
    TextSize=13,Font=Enum.Font.GothamBold,
    BorderSizePixel=0,AutoButtonColor=false,
},TBar)
RC(XBtn,5)
Stroke(XBtn,C.Border2,1)
XBtn.MouseEnter:Connect(function() Tween:Create(XBtn,TweenInfo.new(0.1),{BackgroundColor3=C.Red}):Play() end)
XBtn.MouseLeave:Connect(function() Tween:Create(XBtn,TweenInfo.new(0.1),{BackgroundColor3=C.RedD}):Play() end)
XBtn.MouseButton1Click:Connect(function() Gui:Destroy() end)

-- ── DRAG ──────────────────────────────────────────────────
do
    local drag,ds,ws
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
        end
    end)
end

-- RIGHT CTRL TOGGLE
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.RightControl then
        Win.Visible=not Win.Visible
    end
end)

-- ── INFO BAR ──────────────────────────────────────────────
local IBar=New("Frame",{
    Size=UDim2.new(1,-20,0,32),Position=UDim2.new(0,10,0,50),
    BackgroundColor3=C.BG2,BorderSizePixel=0,
},Win)
RC(IBar,6)
Grad(IBar,Color3.fromRGB(22,14,14),Color3.fromRGB(14,14,20),180)
Stroke(IBar,C.Border,1)

local function ICell(lbl,val,vc,xpct)
    local f=New("Frame",{Size=UDim2.new(0.33,0,1,0),
        Position=UDim2.new(xpct,0,0,0),BackgroundTransparency=1},IBar)
    New("TextLabel",{Size=UDim2.new(1,0,0.42,0),BackgroundTransparency=1,
        Text=lbl,TextColor3=C.Gray,TextSize=9,Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Center},f)
    New("TextLabel",{Size=UDim2.new(1,0,0.58,0),Position=UDim2.new(0,0,0.42,0),
        BackgroundTransparency=1,Text=val,TextColor3=vc,TextSize=11,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center},f)
end
ICell("THREAT LEVEL","ELEVATED",C.Accent,0)
ICell("ENCRYPTION","AES-256",C.Green,0.33)
ICell("SESSION",tostring(math.random(100000,999999)),C.White,0.66)

-- separator line
New("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,88),
    BackgroundColor3=C.Border,BorderSizePixel=0},Win)

-- ── TAB BAR ───────────────────────────────────────────────
local TBarF=New("Frame",{
    Size=UDim2.new(1,-20,0,34),Position=UDim2.new(0,10,0,94),
    BackgroundTransparency=1,BorderSizePixel=0,
},Win)
New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6)},TBarF)

-- ── SCROLL ────────────────────────────────────────────────
local Scroll=New("ScrollingFrame",{
    Size=UDim2.new(1,-20,1,-138),Position=UDim2.new(0,10,0,134),
    BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=3,ScrollBarImageColor3=C.Red,
    CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ClipsDescendants=true,
},Win)
New("UIPadding",{PaddingBottom=UDim.new(0,10)},Scroll)
New("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},Scroll)

-- ── COLOR PICKER (global overlay) ─────────────────────────
local CPop=New("Frame",{
    Size=UDim2.new(0,248,0,158),
    BackgroundColor3=C.Panel,BorderSizePixel=0,
    Visible=false,ZIndex=200,
},Gui)
RC(CPop,8)
Grad(CPop,Color3.fromRGB(28,16,16),Color3.fromRGB(12,12,18),135)
Stroke(CPop,C.RedB,1.5)
New("UIPadding",{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12),
    PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10)},CPop)

New("TextLabel",{Size=UDim2.new(1,-26,0,16),Position=UDim2.new(0,0,0,0),
    BackgroundTransparency=1,Text="COLOR EDITOR",TextColor3=C.Accent,
    TextSize=11,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=201},CPop)

local cpX=New("TextButton",{
    Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-22,0,-2),
    BackgroundColor3=C.RedD,Text="✕",TextColor3=C.White,
    TextSize=11,Font=Enum.Font.GothamBold,
    BorderSizePixel=0,AutoButtonColor=false,ZIndex=202,
},CPop)
RC(cpX,4); Stroke(cpX,C.Border2,1)
cpX.MouseButton1Click:Connect(function() CPop.Visible=false end)

local cpRGB={r=255,g=255,b=255}
local cpCBs={}
local cpChDefs={
    {k="r",n="R",col=Color3.fromRGB(220,60,60)},
    {k="g",n="G",col=Color3.fromRGB(60,200,80)},
    {k="b",n="B",col=Color3.fromRGB(60,130,220)},
}
local cpInfo={}

for idx,ch in ipairs(cpChDefs) do
    local y=20+(idx-1)*40

    New("TextLabel",{
        Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,0,0,y+10),
        BackgroundTransparency=1,Text=ch.n,TextColor3=ch.col,
        TextSize=11,Font=Enum.Font.GothamBold,ZIndex=201,Parent=CPop,
    })
    local vl=New("TextLabel",{
        Size=UDim2.new(0,32,0,14),Position=UDim2.new(1,-32,0,y+10),
        BackgroundTransparency=1,Text="255",TextColor3=C.White,
        TextSize=10,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right,ZIndex=201,Parent=CPop,
    })
    local tr=New("Frame",{
        Size=UDim2.new(1,-52,0,16),Position=UDim2.new(0,18,0,y+9),
        BackgroundColor3=C.RedD,BorderSizePixel=0,ZIndex=201,Parent=CPop,
    })
    RC(tr,8); Stroke(tr,C.Border,1)
    local fi=New("Frame",{Size=UDim2.new(1,0,1,0),
        BackgroundColor3=ch.col,BorderSizePixel=0,ZIndex=202,Parent=tr})
    RC(fi,8)

    cpInfo[ch.k]={tr=tr,fi=fi,vl=vl}

    local function slide(px)
        local pct=math.clamp((px-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        local v=math.floor(pct*255)
        cpRGB[ch.k]=v
        fi.Size=UDim2.new(pct,0,1,0)
        vl.Text=tostring(v)
        local col=Color3.fromRGB(cpRGB.r,cpRGB.g,cpRGB.b)
        for _,cb in ipairs(cpCBs) do cb(col) end
    end
    local sl=false
    tr.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=true;slide(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if sl and i.UserInputType==Enum.UserInputType.MouseMovement then slide(i.Position.X) end
    end)
end

-- preview swatch inside popup
local cpPrev=New("Frame",{
    Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,0,1,-18),
    BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=201,Parent=CPop,
})
RC(cpPrev,5)

local function OpenCP(swatchFrame, curCol, onCh)
    cpRGB.r=math.floor(curCol.R*255)
    cpRGB.g=math.floor(curCol.G*255)
    cpRGB.b=math.floor(curCol.B*255)
    for _,ch in ipairs(cpChDefs) do
        local inf=cpInfo[ch.k]; local v=cpRGB[ch.k]
        inf.fi.Size=UDim2.new(v/255,0,1,0); inf.vl.Text=tostring(v)
    end
    cpPrev.BackgroundColor3=curCol
    cpCBs={onCh, function(c) cpPrev.BackgroundColor3=c end}

    local ap=swatchFrame.AbsolutePosition
    local as=swatchFrame.AbsoluteSize
    local ss=Gui.AbsoluteSize
    local px=math.clamp(ap.X+as.X/2-124, 4, ss.X-252)
    local py=ap.Y+as.Y+8
    if py+165>ss.Y then py=ap.Y-165 end
    CPop.Position=UDim2.new(0,px,0,py)
    CPop.Visible=true
end

-- ── TABS ──────────────────────────────────────────────────
local TPages,TBtns={},{}

local function SwitchTab(name)
    for n,pg in pairs(TPages) do pg.Visible=(n==name) end
    for n,b in pairs(TBtns) do
        if n==name then
            b.BackgroundColor3=C.Red
            b.TextColor3=C.White
            Tween:Create(b,TweenInfo.new(0.12),{BackgroundColor3=C.Red}):Play()
        else
            b.BackgroundColor3=C.BG2
            b.TextColor3=C.Gray
        end
    end
    CPop.Visible=false
end

local function NewTab(name)
    local btn=New("TextButton",{
        Size=UDim2.new(0,112,1,0),BackgroundColor3=C.BG2,
        Text=name,TextColor3=C.Gray,TextSize=12,Font=Enum.Font.GothamBold,
        BorderSizePixel=0,AutoButtonColor=false,
    },TBarF)
    RC(btn,6); Stroke(btn,C.Border,1)
    Grad(btn,Color3.fromRGB(22,14,14),Color3.fromRGB(14,14,20),180)

    local pg=New("Frame",{
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,Visible=false,BorderSizePixel=0,Parent=Scroll,
    })
    New("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},pg)
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    TPages[name]=pg; TBtns[name]=btn
    return pg
end

-- ── SECTION BUILDER ───────────────────────────────────────
local function NewSection(page, title)
    local sec=New("Frame",{
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=C.Panel,BackgroundTransparency=0,
        BorderSizePixel=0,Parent=page,
    })
    RC(sec,7); Stroke(sec,C.Border,1)
    Grad(sec,Color3.fromRGB(20,14,20),Color3.fromRGB(10,10,16),135)
    New("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),
        PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,10)},sec)
    New("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},sec)

    -- header
    local hdr=New("Frame",{
        Size=UDim2.new(1,0,0,26),BackgroundColor3=C.RedD,
        BorderSizePixel=0,LayoutOrder=0,Parent=sec,
    })
    RC(hdr,5); Stroke(hdr,C.Border2,1)
    Grad(hdr,Color3.fromRGB(100,16,16),Color3.fromRGB(50,8,8),180)

    New("TextLabel",{
        Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1,Text="⬡  "..title,
        TextColor3=C.RedB,TextSize=11,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
    },hdr)

    local ON=0
    local function nxt() ON=ON+1; return ON end

    -- ── TOGGLE ──
    local function NewToggle(lbl,desc,cb)
        local row=New("Frame",{
            Size=UDim2.new(1,0,0,48),BackgroundColor3=C.BG2,
            BorderSizePixel=0,LayoutOrder=nxt(),Parent=sec,
        })
        RC(row,6); Stroke(row,C.Border,1)
        Grad(row,Color3.fromRGB(20,16,24),Color3.fromRGB(14,14,20),180)

        New("TextLabel",{
            Size=UDim2.new(1,-66,0,20),Position=UDim2.new(0,12,0,6),
            BackgroundTransparency=1,Text=lbl,
            TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
        },row)
        New("TextLabel",{
            Size=UDim2.new(1,-66,0,16),Position=UDim2.new(0,12,0,27),
            BackgroundTransparency=1,Text=desc,
            TextColor3=C.Gray,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
        },row)

        -- pill toggle
        local pill=New("Frame",{
            Size=UDim2.new(0,44,0,22),Position=UDim2.new(1,-54,0.5,-11),
            BackgroundColor3=C.OFF,BorderSizePixel=0,
        },row)
        RC(pill,11); Stroke(pill,C.Border,1)
        local knob=New("Frame",{
            Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,2,0.5,-9),
            BackgroundColor3=C.White,BorderSizePixel=0,
        },pill)
        RC(knob,9)

        local state=false
        New("TextButton",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Parent=row,
        }).MouseButton1Click:Connect(function()
            state=not state; cb(state)
            local ti=TweenInfo.new(0.18,Enum.EasingStyle.Quad)
            if state then
                Tween:Create(pill,ti,{BackgroundColor3=C.Red}):Play()
                Tween:Create(knob,ti,{Position=UDim2.new(1,-20,0.5,-9),BackgroundColor3=C.White}):Play()
            else
                Tween:Create(pill,ti,{BackgroundColor3=C.OFF}):Play()
                Tween:Create(knob,ti,{Position=UDim2.new(0,2,0.5,-9),BackgroundColor3=C.Gray}):Play()
            end
        end)
    end

    -- ── SLIDER ──
    local function NewSlider(lbl,desc,maxV,minV,cb)
        local row=New("Frame",{
            Size=UDim2.new(1,0,0,68),BackgroundColor3=C.BG2,
            BorderSizePixel=0,LayoutOrder=nxt(),Parent=sec,
        })
        RC(row,6); Stroke(row,C.Border,1)
        Grad(row,Color3.fromRGB(20,16,24),Color3.fromRGB(14,14,20),180)

        New("TextLabel",{
            Size=UDim2.new(0.7,0,0,20),Position=UDim2.new(0,12,0,6),
            BackgroundTransparency=1,Text=lbl,
            TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
        },row)
        local vLbl=New("TextLabel",{
            Size=UDim2.new(0.3,-12,0,20),Position=UDim2.new(0.7,0,0,6),
            BackgroundTransparency=1,Text=tostring(minV),
            TextColor3=C.RedB,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Right,
        },row)
        New("TextLabel",{
            Size=UDim2.new(1,-20,0,14),Position=UDim2.new(0,12,0,27),
            BackgroundTransparency=1,Text=desc,
            TextColor3=C.Gray,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
        },row)

        -- track
        local track=New("Frame",{
            Size=UDim2.new(1,-24,0,20),Position=UDim2.new(0,12,0,46),
            BackgroundColor3=C.RedD,BorderSizePixel=0,
        },row)
        RC(track,10); Stroke(track,C.Border,1)

        local fill=New("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.Red,BorderSizePixel=0},track)
        RC(fill,10)
        Grad(fill,C.RedB,C.Red,180)

        local dot=New("Frame",{
            Size=UDim2.new(0,18,0,18),Position=UDim2.new(1,-18,0.5,-9),
            BackgroundColor3=C.White,BorderSizePixel=0,
        },fill)
        RC(dot,9); Stroke(dot,C.Gray,1)

        local function SetVal(v)
            v=math.clamp(math.floor(v),minV,maxV)
            local pct=maxV==minV and 0 or (v-minV)/(maxV-minV)
            fill.Size=UDim2.new(pct,0,1,0)
            vLbl.Text=tostring(v); cb(v)
        end
        SetVal(minV)

        local sl=false
        track.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                sl=true
                SetVal(minV+math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*(maxV-minV))
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=false end
        end)
        UIS.InputChanged:Connect(function(i)
            if sl and i.UserInputType==Enum.UserInputType.MouseMovement then
                SetVal(minV+math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*(maxV-minV))
            end
        end)
    end

    -- ── COLOR PICKER ──
    local function NewColorPicker(lbl,desc,defCol,cb)
        local row=New("Frame",{
            Size=UDim2.new(1,0,0,48),BackgroundColor3=C.BG2,
            BorderSizePixel=0,LayoutOrder=nxt(),Parent=sec,
        })
        RC(row,6); Stroke(row,C.Border,1)
        Grad(row,Color3.fromRGB(20,16,24),Color3.fromRGB(14,14,20),180)

        New("TextLabel",{
            Size=UDim2.new(1,-82,0,20),Position=UDim2.new(0,12,0,6),
            BackgroundTransparency=1,Text=lbl,
            TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
        },row)
        New("TextLabel",{
            Size=UDim2.new(1,-82,0,16),Position=UDim2.new(0,12,0,27),
            BackgroundTransparency=1,Text=desc,
            TextColor3=C.Gray,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
        },row)

        local curCol=defCol
        local sw=New("Frame",{
            Size=UDim2.new(0,42,0,32),Position=UDim2.new(1,-52,0.5,-16),
            BackgroundColor3=defCol,BorderSizePixel=0,
        },row)
        RC(sw,6); Stroke(sw,C.Border2,1.5)

        -- checkerboard hint
        New("TextLabel",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
            Text="⬛",TextColor3=Color3.fromRGB(255,255,255),
            TextTransparency=0.85,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Center,
        },sw)

        New("TextButton",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Parent=sw,
        }).MouseButton1Click:Connect(function()
            if CPop.Visible then
                CPop.Visible=false
            else
                OpenCP(sw,curCol,function(col)
                    curCol=col; sw.BackgroundColor3=col; cb(col)
                end)
            end
        end)
    end

    return {NewToggle=NewToggle,NewSlider=NewSlider,NewColorPicker=NewColorPicker}
end

-- ── BUILD TABS & SECTIONS ─────────────────────────────────
local PC=NewTab("COMBAT")
local PV=NewTab("VISUALS")
local PW=NewTab("WORLD")
SwitchTab("COMBAT")

local SA  = NewSection(PC,"AIMBOT PROTOCOL")
local SPE = NewSection(PV,"PLAYER SCANNER")
local SWE = NewSection(PV,"WORLD SCANNER")
local SVC = NewSection(PV,"DISPLAY CONFIG")
local SU  = NewSection(PW,"UTILITY MODULE")
local SM  = NewSection(PW,"MOVEMENT OVERRIDE")

-- ── GAME HELPERS ──────────────────────────────────────────
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
    local m={
        {"crow","Crow"},{"dire wolf","Dire Wolf"},{"direwolf","Dire Wolf"},
        {"wolf","Wolf"},{"coyote","Coyote"},{"fox","Fox"},
        {"grizzly","Grizzly"},{"black bear","Black Bear"},{"bear","Bear"},
        {"bison","Bison"},{"buffalo","Bison"},{"buck","Deer"},
        {"doe","Deer"},{"fawn","Deer"},{"deer","Deer"},
        {"horse","Horse"},{"cow","Cow"},{"cattle","Cow"},
        {"pig","Pig"},{"boar","Boar"},{"rabbit","Rabbit"},
        {"bunny","Rabbit"},{"chicken","Chicken"},
    }
    for _,e in ipairs(m) do if n:find(e[1]) then return pre..e[2] end end
    return o.Name
end

-- ── AIMBOT ────────────────────────────────────────────────
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
            local head=ch:FindFirstChild("Head")
            local hum=ch:FindFirstChildOfClass("Humanoid")
            if not head or not hum or hum.Health<=0 then continue end
            if S.WallCheck and not IsVis(head) then continue end
            chk(head)
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

-- ── ESP ───────────────────────────────────────────────────
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
            if rp then local t=rp:FindFirstChild("CWAEP"); if t then t:Destroy() end end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if not S.AnimalESP then continue end
        for _,fn in ipairs({"Harvestables","Animals","NPCS"}) do
            local folder=workspace:FindFirstChild(fn); if not folder then continue end
            for _,v in ipairs(folder:GetChildren()) do
                if not v:IsA("Model") then continue end
                local rp=GetRoot(v); if not rp then continue end
                local hum=v:FindFirstChildOfClass("Humanoid")
                local lb=AName(v)
                if hum and hum.Health<=0 then lb="[DEAD] "..lb end
                ManageESP(v,lb,S.AnimalColor,"CWAEP",true,GetDist(rp.Position),false)
            end
        end
    end
end)

-- ── NOCLIP — FIXED (no per-frame loop, uses DescendantAdded) ─
-- Cache character parts and disable collision on new ones only
local noclipConn
local function SetNoclip(on)
    if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
    local char=LocalPlayer.Character
    if not char then return end
    if on then
        local function disablePart(p)
            if p:IsA("BasePart") then p.CanCollide=false end
        end
        for _,p in ipairs(char:GetDescendants()) do disablePart(p) end
        noclipConn=char.DescendantAdded:Connect(disablePart)
    else
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=true end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(c)
    c:WaitForChild("Humanoid",5)
    if S.Noclip then
        task.wait(0.1); SetNoclip(true)
    end
    if S.SpeedBoost then
        local h=c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed=S.SpeedVal end
    end
end)

-- ── SPEED ─────────────────────────────────────────────────
local function ApplySpeed()
    local c=LocalPlayer.Character; if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed=S.SpeedBoost and S.SpeedVal or 16 end
end

-- ── RENDER LOOP ───────────────────────────────────────────
Run.RenderStepped:Connect(function()
    FOVC.Visible=S.ShowFOV
    FOVC.Radius=S.FOV
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
            if h and h.MoveDirection.Magnitude>0 then
                c:TranslateBy(h.MoveDirection*S.TPSpeed*0.1)
            end
        end
    end
end)

-- FullBright في loop منفصل — كل ثانية يكفي
task.spawn(function()
    while true do
        task.wait(1)
        if S.FullBright then
            Light.ClockTime=14; Light.Brightness=2
            Light.GlobalShadows=false; Light.FogEnd=100000
        end
    end
end)

-- ── PLAYER ESP LOOP (separate from RenderStepped) ─────────
task.spawn(function()
    while true do
        task.wait(0.1)
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LocalPlayer then continue end
            local c=p.Character; if not c then continue end
            local h=c:FindFirstChildOfClass("Humanoid")
            local rp=c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
            if rp and h and h.Health>0 then
                local dist=GetDist(rp.Position)
                local show=S.PlayerName or S.PlayerHP
                local txt=""
                if S.PlayerName then txt="[ "..p.Name.." ]" end
                if S.PlayerHP then
                    txt=txt..(txt~="" and "\n" or "")
                        .."HP "..math.floor(h.Health).."/"..math.floor(h.MaxHealth)
                end
                ManageESP(c,txt,S.PlayerColor,"CWPEP",show,dist,true)
                local hl=c:FindFirstChild("CWPH")
                if S.PlayerBox then
                    if not hl then hl=Instance.new("Highlight"); hl.Name="CWPH"; hl.Parent=c end
                    hl.FillColor=S.PlayerColor; hl.FillTransparency=0.65
                    hl.OutlineColor=Color3.fromRGB(220,50,50); hl.OutlineTransparency=0
                elseif hl then hl:Destroy() end
            else
                local b=c:FindFirstChild("CWPEP",true); if b then b:Destroy() end
                local hl=c:FindFirstChild("CWPH"); if hl then hl:Destroy() end
            end
        end
    end
end)


-- God Mode loop — يرجع الـ HP لـ max كل 0.1 ثانية
task.spawn(function()
    while true do
        task.wait(0.1)
        if not S.GodMode then continue end
        local c=LocalPlayer.Character; if not c then continue end
        local h=c:FindFirstChildOfClass("Humanoid"); if not h then continue end
        if h.Health < h.MaxHealth then h.Health = h.MaxHealth end
    end
end)

-- ── POPULATE UI ───────────────────────────────────────────
SA.NewToggle("Target Players",   "RMB — Lock onto players",               function(v) S.AimPlayers=v end)
SA.NewToggle("Target Animals",   "RMB — Lock onto wildlife",              function(v) S.AimAnimals=v end)
SA.NewToggle("Wall Check",       "Only aim at visible targets",           function(v) S.WallCheck=v end)
SA.NewToggle("Silent Fire",      "LMB — Smooth silent aim",               function(v) S.SilentAim=v end)
SA.NewSlider("FOV Radius",       "Aim radius in pixels (800=full screen)",800,10, function(v) S.FOV=v end)
SA.NewSlider("Silent Smoothing", "1=instant  50=smooth",                  50, 1,  function(v) S.SilentSmooth=v/100 end)
SA.NewToggle("Show FOV Ring",    "Render FOV circle on screen",           function(v) S.ShowFOV=v end)

SPE.NewToggle("Name ESP",    "Show player username",        function(v) S.PlayerName=v end)
SPE.NewToggle("Health ESP",  "Show HP / Max HP",            function(v) S.PlayerHP=v end)
SPE.NewToggle("Box ESP",     "Highlight player silhouette", function(v) S.PlayerBox=v end)

SWE.NewToggle("Animal ESP",    "Track all wildlife",              function(v) S.AnimalESP=v; if not v then CleanAESP() end end)
SWE.NewToggle("Show Distance", "Display range to each target",   function(v) S.ShowDist=v end)

SVC.NewSlider("Max Animal Range","Fauna ESP max distance",20000,500, function(v) S.ESPDist=v end)
SVC.NewSlider("Label Size",      "ESP font size",         20,  8,   function(v) S.TextSize=v end)
SVC.NewColorPicker("Player ESP Color","Color for player labels",S.PlayerColor, function(v) S.PlayerColor=v end)
SVC.NewColorPicker("Animal ESP Color","Color for animal labels",S.AnimalColor, function(v) S.AnimalColor=v end)
SVC.NewColorPicker("FOV Ring Color",  "Color of the aim circle",FOVC.Color,    function(v) FOVC.Color=v end)

SU.NewToggle("Full Bright",      "Force max light, remove fog",    function(v) S.FullBright=v end)
SU.NewToggle("Instant Interact", "Zero hold on prompts",           function(v) S.Interact=v end)
SU.NewToggle("TP-Walk",          "Safe teleport movement hack",    function(v) S.TPWalk=v end)
SU.NewSlider("TP Speed",         "TP-Walk speed multiplier",15,1,  function(v) S.TPSpeed=v end)

SM.NewToggle("God Mode",   "Max HP — cannot die",           function(v) S.GodMode=v end)
SM.NewToggle("Noclip",     "Phase through walls", function(v)
    S.Noclip=v; SetNoclip(v)
end)
SM.NewToggle("Speed Boost","Override walk speed", function(v) S.SpeedBoost=v; ApplySpeed() end)
SM.NewSlider("Walk Speed", "Speed (default 16)", 100,16, function(v) S.SpeedVal=v; ApplySpeed() end)

-- ── PROXIMITY ─────────────────────────────────────────────
PPS.PromptShown:Connect(function(p) if S.Interact then p.HoldDuration=0 end end)

-- ── BOOT ──────────────────────────────────────────────────
pcall(function()
    SGui:SetCore("SendNotification",{
        Title="Mosab Westbound  [ ARMED ]",
        Text="All modules online  ·  RightCtrl = Hide/Show",
        Duration=5,
    })
end)
