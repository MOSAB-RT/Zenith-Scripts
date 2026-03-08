-- ============================================================
--  Mosab Westbound | CYBER UI
--  RightCtrl = Hide/Show | Drag from TitleBar
-- ============================================================

-- WHITELIST
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not ({["mairjdyr"]=true})[LocalPlayer.Name] then
    warn("[CYBER//WEST] ACCESS DENIED: "..LocalPlayer.Name); return
end

-- SERVICES
local RunService             = game:GetService("RunService")
local UserInputService       = game:GetService("UserInputService")
local Lighting               = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService           = game:GetService("TweenService")
local StarterGui             = game:GetService("StarterGui")
local Camera                 = workspace.CurrentCamera

-- SETTINGS
local S = {
    AimPlayers=false, AimAnimals=false, WallCheck=false,
    SilentAim=false,  SilentSmooth=0.15,
    FOV=150,          -- screen pixels
    ShowFOV=false,
    PlayerName=false, PlayerHP=false, PlayerBox=false,
    AnimalESP=false,  ShowDist=false, ESPDist=10000, TextSize=12,
    PlayerColor=Color3.fromRGB(0,255,180),
    AnimalColor=Color3.fromRGB(255,200,0),
    InstantInteract=false, TPWalk=false, TPSpeed=2,
    FullBright=false, Noclip=false, SpeedBoost=false, SpeedVal=16,
}

-- FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness=1.5; FOVCircle.Filled=false
FOVCircle.Color=Color3.fromRGB(220,30,30)
FOVCircle.Transparency=1; FOVCircle.Visible=false

-- COLORS
local C = {
    BG      = Color3.fromRGB(10,10,14),
    BG2     = Color3.fromRGB(18,18,24),
    Panel   = Color3.fromRGB(22,22,30),
    Red     = Color3.fromRGB(180,30,30),
    RedDark = Color3.fromRGB(70,10,10),
    Accent  = Color3.fromRGB(220,50,50),
    White   = Color3.fromRGB(235,235,235),
    Gray    = Color3.fromRGB(120,120,140),
    Green   = Color3.fromRGB(50,200,100),
    Border  = Color3.fromRGB(90,20,20),
    OFF     = Color3.fromRGB(50,50,62),
}

-- HELPERS
local function New(cls, props, parent)
    local o=Instance.new(cls)
    for k,v in pairs(props) do o[k]=v end
    if parent then o.Parent=parent end
    return o
end
local function RC(p,r)  New("UICorner",{CornerRadius=UDim.new(0,r or 4)},p) end
local function Str(p,c,t) New("UIStroke",{Color=c or C.Border,Thickness=t or 1},p) end
local function Pad(p,l,r,t,b)
    New("UIPadding",{PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r),
        PaddingTop=UDim.new(0,t),PaddingBottom=UDim.new(0,b)},p)
end

-- ============================================================
-- GUI ROOT
-- ============================================================
local Gui = New("ScreenGui",{
    Name="CyberWest", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset=true,
}, LocalPlayer:WaitForChild("PlayerGui"))

-- WINDOW
local Win = New("Frame",{
    Size=UDim2.new(0,580,0,520),
    Position=UDim2.new(0.5,-290,0.5,-260),
    BackgroundColor3=C.BG, BackgroundTransparency=0.05,
    BorderSizePixel=0, ClipsDescendants=false,
},Gui)
RC(Win,6); Str(Win,C.Red,1.5)

-- TITLE BAR
local TBar = New("Frame",{
    Size=UDim2.new(1,0,0,42),
    BackgroundColor3=C.Red, BackgroundTransparency=0.05,
    BorderSizePixel=0,
},Win)
RC(TBar,6)
New("Frame",{Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),
    BackgroundColor3=C.Red,BackgroundTransparency=0.05,BorderSizePixel=0},TBar)

New("TextLabel",{
    Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,14,0,0),
    BackgroundTransparency=1,
    Text="Mosab Westbound   |   OPERATOR: "..LocalPlayer.Name.."   |   ONLINE",
    TextColor3=C.White, TextSize=13, Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left,
},TBar)

local XBtn=New("TextButton",{
    Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-36,0.5,-14),
    BackgroundColor3=C.RedDark, Text="X", TextColor3=C.White,
    TextSize=13, Font=Enum.Font.GothamBold,
    BorderSizePixel=0, AutoButtonColor=false,
},TBar)
RC(XBtn,4)
XBtn.MouseButton1Click:Connect(function() Gui:Destroy() end)

-- DRAG
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
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            Win.Position=UDim2.new(ws.X.Scale,ws.X.Offset+d.X,ws.Y.Scale,ws.Y.Offset+d.Y)
        end
    end)
end

-- RIGHT CTRL TOGGLE
UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.RightControl then Win.Visible=not Win.Visible end
end)

-- INFO BAR
local IBar=New("Frame",{
    Size=UDim2.new(1,-20,0,30),Position=UDim2.new(0,10,0,48),
    BackgroundColor3=C.BG2, BorderSizePixel=0,
},Win)
RC(IBar,4); Str(IBar,C.Border)

local function InfoCell(lbl,val,vc,xpct)
    local f=New("Frame",{Size=UDim2.new(0.33,0,1,0),Position=UDim2.new(xpct,0,0,0),BackgroundTransparency=1},IBar)
    New("TextLabel",{Size=UDim2.new(1,0,0.45,0),BackgroundTransparency=1,Text=lbl,
        TextColor3=C.Gray,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Center},f)
    New("TextLabel",{Size=UDim2.new(1,0,0.55,0),Position=UDim2.new(0,0,0.45,0),BackgroundTransparency=1,
        Text=val,TextColor3=vc,TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center},f)
end
InfoCell("THREAT LEVEL","ELEVATED",C.Accent,0)
InfoCell("ENCRYPTION","AES-256",C.Green,0.33)
InfoCell("SESSION",tostring(math.random(100000,999999)),C.White,0.66)

-- TAB BAR
local TBarF=New("Frame",{
    Size=UDim2.new(1,-20,0,32),Position=UDim2.new(0,10,0,84),
    BackgroundTransparency=1, BorderSizePixel=0,
},Win)
New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5)},TBarF)

-- SCROLL
local Scroll=New("ScrollingFrame",{
    Size=UDim2.new(1,-20,1,-124),Position=UDim2.new(0,10,0,122),
    BackgroundTransparency=1, BorderSizePixel=0,
    ScrollBarThickness=3, ScrollBarImageColor3=C.Red,
    CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ClipsDescendants=true,
},Win)
Pad(Scroll,0,0,0,10)
New("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},Scroll)

-- ============================================================
-- COLOR PICKER OVERLAY (parented to Gui — floats above everything)
-- ============================================================
local ColorPopup = New("Frame",{
    Size=UDim2.new(0,240,0,148),
    BackgroundColor3=C.Panel, BorderSizePixel=0,
    Visible=false, ZIndex=100,
},Gui)
RC(ColorPopup,6); Str(ColorPopup,C.Red,1.5)
Pad(ColorPopup,12,12,10,10)

local cpTitle=New("TextLabel",{
    Size=UDim2.new(1,0,0,16), BackgroundTransparency=1,
    Text="COLOR PICKER", TextColor3=C.Accent,
    TextSize=11, Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=101,
},ColorPopup)

-- Close button for popup
local cpClose=New("TextButton",{
    Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-22,0,-3),
    BackgroundColor3=C.RedDark, Text="X",
    TextColor3=C.White, TextSize=11, Font=Enum.Font.GothamBold,
    BorderSizePixel=0, AutoButtonColor=false, ZIndex=102,
},ColorPopup)
RC(cpClose,4)
cpClose.MouseButton1Click:Connect(function() ColorPopup.Visible=false end)

-- RGB sliders inside popup
local cpChannels = {}
local cpCallbacks = {}
local cpRGB = {r=255,g=255,b=255}

local chDefs = {
    {name="R", key="r", col=Color3.fromRGB(220,60,60)},
    {name="G", key="g", col=Color3.fromRGB(60,200,80)},
    {name="B", key="b", col=Color3.fromRGB(60,130,220)},
}

for idx,ch in ipairs(chDefs) do
    local yy = 20 + (idx-1)*38

    New("TextLabel",{
        Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,0,0,yy+10),
        BackgroundTransparency=1, Text=ch.name,
        TextColor3=ch.col, TextSize=11, Font=Enum.Font.GothamBold,
        ZIndex=101, Parent=ColorPopup,
    })

    local vLbl=New("TextLabel",{
        Size=UDim2.new(0,30,0,14), Position=UDim2.new(1,-30,0,yy+10),
        BackgroundTransparency=1, Text="255",
        TextColor3=C.White, TextSize=10, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right, ZIndex=101, Parent=ColorPopup,
    })

    local tr=New("Frame",{
        Size=UDim2.new(1,-50,0,16), Position=UDim2.new(0,18,0,yy+9),
        BackgroundColor3=C.RedDark, BorderSizePixel=0, ZIndex=101, Parent=ColorPopup,
    })
    RC(tr,8)

    local fi=New("Frame",{
        Size=UDim2.new(1,0,1,0), BackgroundColor3=ch.col,
        BorderSizePixel=0, ZIndex=102, Parent=tr,
    })
    RC(fi,8)

    cpChannels[ch.key] = {track=tr, fill=fi, label=vLbl}

    local function applySlide(px)
        local pct=math.clamp((px-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        local v=math.floor(pct*255)
        cpRGB[ch.key]=v
        fi.Size=UDim2.new(pct,0,1,0)
        vLbl.Text=tostring(v)
        -- call active callback
        for _,cb2 in ipairs(cpCallbacks) do cb2(Color3.fromRGB(cpRGB.r,cpRGB.g,cpRGB.b)) end
    end

    local sl=false
    tr.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=true; applySlide(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sl and i.UserInputType==Enum.UserInputType.MouseMovement then applySlide(i.Position.X) end
    end)
end

-- Swatch preview in popup
local cpSwatch=New("Frame",{
    Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,1,-20),
    BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0, ZIndex=101, Parent=ColorPopup,
})
RC(cpSwatch,4)

-- Update popup to reflect a color + set active callback
local function OpenColorPopup(swatchBtn, currentColor, onChangeCb)
    -- set RGB
    cpRGB.r=math.floor(currentColor.R*255)
    cpRGB.g=math.floor(currentColor.G*255)
    cpRGB.b=math.floor(currentColor.B*255)

    for _,ch in ipairs(chDefs) do
        local info=cpChannels[ch.key]
        local v=cpRGB[ch.key]
        info.fill.Size=UDim2.new(v/255,0,1,0)
        info.label.Text=tostring(v)
    end
    cpSwatch.BackgroundColor3=currentColor

    -- update callback list
    cpCallbacks = {
        onChangeCb,
        function(col) cpSwatch.BackgroundColor3=col end,
    }

    -- position popup near the swatch button
    local absPos = swatchBtn.AbsolutePosition
    local absSize = swatchBtn.AbsoluteSize
    local screenSize = Gui.AbsoluteSize

    local px = absPos.X + absSize.X/2 - 120
    local py = absPos.Y + absSize.Y + 6

    -- keep in screen
    px = math.clamp(px, 4, screenSize.X - 244)
    if py + 155 > screenSize.Y then py = absPos.Y - 155 end

    ColorPopup.Position = UDim2.new(0, px, 0, py)
    ColorPopup.Visible  = true
end

-- Close popup if clicking outside
UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.UserInputType==Enum.UserInputType.MouseButton1 and ColorPopup.Visible then
        -- small delay so swatch click registers first
        task.delay(0.05, function()
            -- will be closed by cpClose or by opening another one
        end)
    end
end)

-- ============================================================
-- TABS
-- ============================================================
local TabPages,TabBtns={},{}

local function SwitchTab(name)
    for n,pg in pairs(TabPages) do pg.Visible=(n==name) end
    for n,b in pairs(TabBtns) do
        b.BackgroundColor3 = n==name and C.Red or C.BG2
        b.TextColor3       = n==name and C.White or C.Gray
    end
    ColorPopup.Visible=false
end

local function NewTab(name)
    local btn=New("TextButton",{
        Size=UDim2.new(0,110,1,0),BackgroundColor3=C.BG2,
        Text=name,TextColor3=C.Gray,TextSize=12,Font=Enum.Font.GothamBold,
        BorderSizePixel=0,AutoButtonColor=false,
    },TBarF)
    RC(btn,4); Str(btn,C.Border)
    local pg=New("Frame",{
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,Visible=false,BorderSizePixel=0,Parent=Scroll,
    })
    New("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},pg)
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    TabPages[name]=pg; TabBtns[name]=btn
    return pg
end

-- ============================================================
-- SECTION BUILDER
-- ============================================================
local function NewSection(page, title)
    local sec=New("Frame",{
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=C.Panel,BackgroundTransparency=0.08,
        BorderSizePixel=0,Parent=page,
    })
    RC(sec,5); Str(sec,C.Border)
    Pad(sec,10,10,8,10)
    New("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},sec)

    local hdr=New("Frame",{
        Size=UDim2.new(1,0,0,24),BackgroundColor3=C.RedDark,
        BorderSizePixel=0,LayoutOrder=0,Parent=sec,
    })
    RC(hdr,3)
    New("TextLabel",{
        Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1,Text=title,
        TextColor3=C.Accent,TextSize=11,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
    },hdr)

    local orderN=0
    local function nextN() orderN=orderN+1; return orderN end

    -- TOGGLE
    local function NewToggle(label,desc,cb)
        local row=New("Frame",{
            Size=UDim2.new(1,0,0,46),BackgroundColor3=C.BG2,
            BorderSizePixel=0,LayoutOrder=nextN(),Parent=sec,
        })
        RC(row,4); Str(row,C.Border)

        New("TextLabel",{
            Size=UDim2.new(1,-64,0,20),Position=UDim2.new(0,12,0,6),
            BackgroundTransparency=1,Text=label,
            TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
        },row)
        New("TextLabel",{
            Size=UDim2.new(1,-64,0,16),Position=UDim2.new(0,12,0,26),
            BackgroundTransparency=1,Text=desc,
            TextColor3=C.Gray,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
        },row)

        local pill=New("Frame",{
            Size=UDim2.new(0,40,0,20),Position=UDim2.new(1,-52,0.5,-10),
            BackgroundColor3=C.OFF,BorderSizePixel=0,
        },row)
        RC(pill,10)
        local knob=New("Frame",{
            Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,2,0.5,-8),
            BackgroundColor3=C.White,BorderSizePixel=0,
        },pill)
        RC(knob,8)

        local state=false
        New("TextButton",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Parent=row,
        }).MouseButton1Click:Connect(function()
            state=not state; cb(state)
            local ti=TweenInfo.new(0.15)
            TweenService:Create(pill,ti,{BackgroundColor3=state and C.Red or C.OFF}):Play()
            TweenService:Create(knob,ti,{Position=state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
        end)
    end

    -- SLIDER
    local function NewSlider(label,desc,maxV,minV,cb)
        local row=New("Frame",{
            Size=UDim2.new(1,0,0,66),BackgroundColor3=C.BG2,
            BorderSizePixel=0,LayoutOrder=nextN(),Parent=sec,
        })
        RC(row,4); Str(row,C.Border)

        New("TextLabel",{
            Size=UDim2.new(0.72,0,0,20),Position=UDim2.new(0,12,0,6),
            BackgroundTransparency=1,Text=label,
            TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
        },row)
        local valLbl=New("TextLabel",{
            Size=UDim2.new(0.28,-12,0,20),Position=UDim2.new(0.72,0,0,6),
            BackgroundTransparency=1,Text=tostring(minV),
            TextColor3=C.Accent,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Right,
        },row)
        New("TextLabel",{
            Size=UDim2.new(1,-20,0,14),Position=UDim2.new(0,12,0,27),
            BackgroundTransparency=1,Text=desc,
            TextColor3=C.Gray,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
        },row)

        local track=New("Frame",{
            Size=UDim2.new(1,-24,0,18),Position=UDim2.new(0,12,0,44),
            BackgroundColor3=C.RedDark,BorderSizePixel=0,
        },row)
        RC(track,9); Str(track,C.Border)
        local fill=New("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.Red,BorderSizePixel=0},track)
        RC(fill,9)
        local dot=New("Frame",{
            Size=UDim2.new(0,16,0,16),Position=UDim2.new(1,-16,0.5,-8),
            BackgroundColor3=C.White,BorderSizePixel=0,
        },fill)
        RC(dot,8)

        local function SetVal(v)
            v=math.clamp(math.floor(v),minV,maxV)
            local pct=maxV==minV and 0 or (v-minV)/(maxV-minV)
            fill.Size=UDim2.new(pct,0,1,0)
            valLbl.Text=tostring(v); cb(v)
        end
        SetVal(minV)

        local sliding=false
        track.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                sliding=true
                SetVal(minV+math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*(maxV-minV))
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then
                SetVal(minV+math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*(maxV-minV))
            end
        end)
    end

    -- COLOR PICKER (uses global popup)
    local function NewColorPicker(label,desc,defaultColor,cb)
        local row=New("Frame",{
            Size=UDim2.new(1,0,0,46),BackgroundColor3=C.BG2,
            BorderSizePixel=0,LayoutOrder=nextN(),Parent=sec,
        })
        RC(row,4); Str(row,C.Border)

        New("TextLabel",{
            Size=UDim2.new(1,-80,0,20),Position=UDim2.new(0,12,0,6),
            BackgroundTransparency=1,Text=label,
            TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
        },row)
        New("TextLabel",{
            Size=UDim2.new(1,-80,0,16),Position=UDim2.new(0,12,0,26),
            BackgroundTransparency=1,Text=desc,
            TextColor3=C.Gray,TextSize=10,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
        },row)

        local currentColor = defaultColor
        local swatch=New("Frame",{
            Size=UDim2.new(0,38,0,30),Position=UDim2.new(1,-50,0.5,-15),
            BackgroundColor3=defaultColor,BorderSizePixel=0,
        },row)
        RC(swatch,5); Str(swatch,C.Border)

        local swBtn=New("TextButton",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Parent=swatch,
        })
        swBtn.MouseButton1Click:Connect(function()
            if ColorPopup.Visible then
                ColorPopup.Visible=false
            else
                OpenColorPopup(swatch, currentColor, function(col)
                    currentColor=col
                    swatch.BackgroundColor3=col
                    cb(col)
                end)
            end
        end)
    end

    return {NewToggle=NewToggle, NewSlider=NewSlider, NewColorPicker=NewColorPicker}
end -- END NewSection

-- ============================================================
-- BUILD TABS & SECTIONS
-- ============================================================
local PCombat  = NewTab("COMBAT")
local PVisuals = NewTab("VISUALS")
local PWorld   = NewTab("WORLD")
SwitchTab("COMBAT")

local SecAimbot    = NewSection(PCombat,  "AIMBOT PROTOCOL")
local SecPlayerESP = NewSection(PVisuals, "PLAYER SCANNER")
local SecWorldESP  = NewSection(PVisuals, "WORLD SCANNER")
local SecVisCfg    = NewSection(PVisuals, "DISPLAY CONFIG")
local SecUtility   = NewSection(PWorld,   "UTILITY MODULE")
local SecMovement  = NewSection(PWorld,   "MOVEMENT OVERRIDE")

-- ============================================================
-- GAME HELPERS
-- ============================================================
local function GetRoot(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
    end
end

local function GetDist(pos)
    local c=LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        return math.floor((c.HumanoidRootPart.Position-pos).Magnitude)
    end
    return 0
end

local function IsVisible(tp)
    if not tp then return false end
    local c=LocalPlayer.Character
    if not c or not c:FindFirstChild("Head") then return false end
    local p=RaycastParams.new()
    p.FilterDescendantsInstances={c}; p.FilterType=Enum.RaycastFilterType.Exclude; p.IgnoreWater=true
    local res=workspace:Raycast(Camera.CFrame.Position,tp.Position-Camera.CFrame.Position,p)
    if res then return res.Instance:IsDescendantOf(tp.Parent) end
    return true
end

local function AnimalName(obj)
    local n=obj.Name:lower()
    local pre=n:find("legendary") and "[LEG] " or ""
    local map={
        {"crow","Crow"},{"dire wolf","Dire Wolf"},{"direwolf","Dire Wolf"},
        {"wolf","Wolf"},{"coyote","Coyote"},{"fox","Fox"},
        {"grizzly","Grizzly"},{"black bear","Black Bear"},{"bear","Bear"},
        {"bison","Bison"},{"buffalo","Bison"},{"buck","Deer"},
        {"doe","Deer"},{"fawn","Deer"},{"deer","Deer"},
        {"horse","Horse"},{"cow","Cow"},{"cattle","Cow"},
        {"pig","Pig"},{"boar","Boar"},{"rabbit","Rabbit"},{"bunny","Rabbit"},{"chicken","Chicken"},
    }
    for _,e in ipairs(map) do if n:find(e[1]) then return pre..e[2] end end
    return obj.Name
end

-- ============================================================
-- AIMBOT — screen-space pixel distance to crosshair
-- FOV slider now goes up to 800px which covers full screen
-- ============================================================
local function GetTarget()
    local tp, cd = nil, S.FOV
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    local function CheckPart(part)
        if not part then return end
        local pos, vis = Camera:WorldToViewportPoint(part.Position)
        if not vis then return end
        local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if mag < cd then tp=part; cd=mag end
    end

    if S.AimPlayers then
        for _,v in ipairs(Players:GetPlayers()) do
            if v==LocalPlayer then continue end
            local ch=v.Character; if not ch then continue end
            local head=ch:FindFirstChild("Head")
            local hum=ch:FindFirstChildOfClass("Humanoid")
            if not head or not hum or hum.Health<=0 then continue end
            if S.WallCheck and not IsVisible(head) then continue end
            CheckPart(head)
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
                if S.WallCheck and not IsVisible(rp) then continue end
                CheckPart(rp)
            end
        end
    end

    return tp
end

-- ============================================================
-- ESP
-- ============================================================
local function ManageESP(char,text,color,tag,show,dist,isPlayer)
    local rp = isPlayer
        and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        or GetRoot(char)
    if not rp then return end
    local inRange = isPlayer or (dist<=S.ESPDist)
    local bb=rp:FindFirstChild(tag)
    if show and inRange then
        if not bb then
            bb=Instance.new("BillboardGui"); bb.Name=tag; bb.Adornee=rp
            bb.AlwaysOnTop=true; bb.Size=UDim2.new(0,200,0,60)
            bb.StudsOffset=Vector3.new(0,3,0); bb.Parent=rp
            local lbl=Instance.new("TextLabel",bb)
            lbl.Name="L"; lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,0,1,0)
            lbl.TextStrokeTransparency=0.3; lbl.TextStrokeColor3=Color3.new(0,0,0)
            lbl.Font=Enum.Font.Code
        end
        local lbl=bb:FindFirstChild("L")
        if lbl then
            lbl.TextSize=S.TextSize; lbl.TextColor3=color
            lbl.Text=text..(S.ShowDist and ("  ["..dist.."m]") or "")
        end
    else
        if bb then bb:Destroy() end
    end
end

local function CleanAnimalESP()
    for _,fn in ipairs({"Harvestables","Animals","NPCS"}) do
        local f=workspace:FindFirstChild(fn); if not f then continue end
        for _,a in ipairs(f:GetChildren()) do
            local rp=GetRoot(a)
            if rp then local t=rp:FindFirstChild("CWAnimalESP"); if t then t:Destroy() end end
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
                if v:IsA("Model") then
                    local rp=GetRoot(v); if not rp then continue end
                    local hum=v:FindFirstChildOfClass("Humanoid")
                    local lbl=AnimalName(v)
                    if hum and hum.Health<=0 then lbl="[DEAD] "..lbl end
                    ManageESP(v,lbl,S.AnimalColor,"CWAnimalESP",true,GetDist(rp.Position),false)
                end
            end
        end
    end
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if not S.Noclip then return end
    local c=LocalPlayer.Character; if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end
    end
end)

-- SPEED
local function ApplySpeed()
    local c=LocalPlayer.Character; if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed=S.SpeedBoost and S.SpeedVal or 16 end
end

-- ============================================================
-- RENDER LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible=S.ShowFOV
    FOVCircle.Radius=S.FOV
    FOVCircle.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)

    local ap=GetTarget()
    if ap then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            Camera.CFrame=CFrame.new(Camera.CFrame.Position,ap.Position)
        end
        if S.SilentAim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            Camera.CFrame=Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position,ap.Position), S.SilentSmooth)
        end
    end

    if S.FullBright then
        Lighting.ClockTime=14; Lighting.Brightness=2
        Lighting.GlobalShadows=false; Lighting.FogEnd=100000
    end

    if S.TPWalk then
        local c=LocalPlayer.Character; if c then
            local h=c:FindFirstChildOfClass("Humanoid")
            if h and h.MoveDirection.Magnitude>0 then
                c:TranslateBy(h.MoveDirection*S.TPSpeed*0.1)
            end
        end
    end

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
                    .."HP: "..math.floor(h.Health).."/"..math.floor(h.MaxHealth)
            end
            ManageESP(c,txt,S.PlayerColor,"CWPlayerESP",show,dist,true)
            local hl=c:FindFirstChild("CWHigh")
            if S.PlayerBox then
                if not hl then
                    hl=Instance.new("Highlight"); hl.Name="CWHigh"; hl.Parent=c
                end
                hl.FillColor=S.PlayerColor; hl.FillTransparency=0.65
                hl.OutlineColor=Color3.fromRGB(220,50,50); hl.OutlineTransparency=0
            elseif hl then hl:Destroy() end
        else
            local b=c:FindFirstChild("CWPlayerESP",true); if b then b:Destroy() end
            local hl=c:FindFirstChild("CWHigh"); if hl then hl:Destroy() end
        end
    end
end)

-- ============================================================
-- POPULATE UI
-- ============================================================
SecAimbot.NewToggle("Target Players",   "RMB - Lock onto players",            function(v) S.AimPlayers=v end)
SecAimbot.NewToggle("Target Animals",   "RMB - Lock onto wildlife",           function(v) S.AimAnimals=v end)
SecAimbot.NewToggle("Wall Check",       "Only aim at visible targets",        function(v) S.WallCheck=v end)
SecAimbot.NewToggle("Silent Fire",      "LMB - Smooth silent aim",            function(v) S.SilentAim=v end)
SecAimbot.NewSlider("FOV Radius",       "Aim radius in pixels (800=fullscreen)", 800, 10,
    function(v) S.FOV=v end)
SecAimbot.NewSlider("Silent Smoothing", "1=instant  50=smooth",   50, 1,
    function(v) S.SilentSmooth=v/100 end)
SecAimbot.NewToggle("Show FOV Ring",    "Render FOV circle",                  function(v) S.ShowFOV=v end)

SecPlayerESP.NewToggle("Name ESP",      "Show player username",               function(v) S.PlayerName=v end)
SecPlayerESP.NewToggle("Health ESP",    "Show HP / Max HP",                   function(v) S.PlayerHP=v end)
SecPlayerESP.NewToggle("Box ESP",       "Highlight player model",             function(v) S.PlayerBox=v end)

SecWorldESP.NewToggle("Animal ESP",     "Track all wildlife",
    function(v) S.AnimalESP=v; if not v then CleanAnimalESP() end end)
SecWorldESP.NewToggle("Show Distance",  "Display range to targets",           function(v) S.ShowDist=v end)

SecVisCfg.NewSlider("Max Animal Range","Fauna ESP max distance", 20000, 500,  function(v) S.ESPDist=v end)
SecVisCfg.NewSlider("Label Size",      "ESP font size",          20,  8,      function(v) S.TextSize=v end)
SecVisCfg.NewColorPicker("Player ESP Color","Color for player tags",   S.PlayerColor, function(v) S.PlayerColor=v end)
SecVisCfg.NewColorPicker("Animal ESP Color","Color for animal tags",   S.AnimalColor, function(v) S.AnimalColor=v end)
SecVisCfg.NewColorPicker("FOV Ring Color",  "Color of the FOV circle", FOVCircle.Color, function(v) FOVCircle.Color=v end)

SecUtility.NewToggle("Full Bright",     "Force max light, remove fog",        function(v) S.FullBright=v end)
SecUtility.NewToggle("Instant Interact","Zero hold duration on prompts",      function(v) S.InstantInteract=v end)
SecUtility.NewToggle("TP-Walk",         "Safe teleport movement hack",        function(v) S.TPWalk=v end)
SecUtility.NewSlider("TP Speed",        "TP-Walk speed factor", 15, 1,        function(v) S.TPSpeed=v end)

SecMovement.NewToggle("Noclip",         "Phase through walls",                function(v)
    S.Noclip=v
    if not v then
        local c=LocalPlayer.Character; if c then
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=true end
            end
        end
    end
end)
SecMovement.NewToggle("Speed Boost",    "Override walk speed",                function(v) S.SpeedBoost=v; ApplySpeed() end)
SecMovement.NewSlider("Walk Speed",     "Speed value (default 16)", 100, 16,  function(v) S.SpeedVal=v; ApplySpeed() end)

-- ============================================================
-- PROXIMITY + RESPAWN
-- ============================================================
ProximityPromptService.PromptShown:Connect(function(p)
    if S.InstantInteract then p.HoldDuration=0 end
end)
LocalPlayer.CharacterAdded:Connect(function(c)
    c:WaitForChild("Humanoid",5); ApplySpeed()
end)

-- ============================================================
-- BOOT
-- ============================================================
pcall(function()
    StarterGui:SetCore("SendNotification",{
        Title="Mosab Westbound  [ ARMED ]",
        Text="All modules online  |  RightCtrl = Hide/Show",
        Duration=5,
    })
end)
