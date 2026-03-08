-- ============================================================
--  CYBER//WEST  |  OPERATOR: mairjdyr  |  CLEARANCE: MAX
--  Custom UI - No Library - Full Phantom Style
-- ============================================================

-- ============================================================
-- WHITELIST
-- ============================================================
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local WHITELIST = { ["mairjdyr"] = true }

if not WHITELIST[LocalPlayer.Name] then
    warn("[CYBER//WEST] ACCESS DENIED: " .. LocalPlayer.Name)
    return
end

-- ============================================================
-- SERVICES
-- ============================================================
local RunService             = game:GetService("RunService")
local UserInputService       = game:GetService("UserInputService")
local Lighting               = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService           = game:GetService("TweenService")
local StarterGui             = game:GetService("StarterGui")

local Camera = workspace.CurrentCamera

-- ============================================================
-- SETTINGS
-- ============================================================
local Settings = {
    AimPlayers         = false,
    AimAnimals         = false,
    WallCheck          = false,
    SilentAim          = false,
    SilentAimSmoothing = 0.15,
    FOV                = 150,
    ShowFOVCircle      = false,

    PlayerName   = false,
    PlayerHP     = false,
    PlayerBox    = false,
    AnimalESP    = false,
    ShowDistance = false,
    ESPDistance  = 10000,
    TextSize     = 12,
    PlayerColor  = Color3.fromRGB(0, 255, 180),
    AnimalColor  = Color3.fromRGB(255, 200, 0),

    InstantInteract = false,
    TPWalk          = false,
    TPWalkSpeed     = 2,
    FullBright      = false,
    Noclip          = false,
    SpeedBoost      = false,
    SpeedValue      = 16,
}

-- ============================================================
-- FOV CIRCLE
-- ============================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness    = 1.5
FOVCircle.Color        = Color3.fromRGB(220, 30, 30)
FOVCircle.Filled       = false
FOVCircle.Transparency = 1
FOVCircle.Visible      = false

-- ============================================================
-- COLORS
-- ============================================================
local C = {
    BG       = Color3.fromRGB(10, 10, 14),
    BG2      = Color3.fromRGB(16, 16, 22),
    Panel    = Color3.fromRGB(20, 20, 28),
    Red      = Color3.fromRGB(180, 30, 30),
    RedDark  = Color3.fromRGB(80, 12, 12),
    Accent   = Color3.fromRGB(220, 50, 50),
    White    = Color3.fromRGB(230, 230, 230),
    Gray     = Color3.fromRGB(130, 130, 150),
    Green    = Color3.fromRGB(50, 200, 100),
    Border   = Color3.fromRGB(80, 20, 20),
    OFF      = Color3.fromRGB(55, 55, 65),
}

-- ============================================================
-- MAKE HELPER
-- ============================================================
local function Make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function Corner(parent, r)
    return Make("UICorner", { CornerRadius = UDim.new(0, r or 4) }, parent)
end

local function Stroke(parent, color, thick)
    return Make("UIStroke", { Color = color or C.Border, Thickness = thick or 1 }, parent)
end

-- ============================================================
-- ROOT GUI
-- ============================================================
local Gui = Make("ScreenGui", {
    Name           = "CyberWest",
    ResetOnSpawn   = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, LocalPlayer:WaitForChild("PlayerGui"))

-- ============================================================
-- MAIN WINDOW FRAME
-- ============================================================
local Win = Make("Frame", {
    Name                 = "Window",
    Size                 = UDim2.new(0, 560, 0, 490),
    Position             = UDim2.new(0.5, -280, 0.5, -245),
    BackgroundColor3     = C.BG,
    BackgroundTransparency = 0.06,
    BorderSizePixel      = 0,
}, Gui)
Corner(Win, 6)
Stroke(Win, C.Red, 1.5)

-- Drag logic
do
    local drag, dStart, wStart
    Win.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; dStart = i.Position; wStart = Win.Position
        end
    end)
    Win.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dStart
            Win.Position = UDim2.new(wStart.X.Scale, wStart.X.Offset + d.X, wStart.Y.Scale, wStart.Y.Offset + d.Y)
        end
    end)
end

-- ============================================================
-- TITLE BAR
-- ============================================================
local TBar = Make("Frame", {
    Size             = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = C.Red,
    BackgroundTransparency = 0.05,
    BorderSizePixel  = 0,
}, Win)
Corner(TBar, 6)
-- square bottom corners
Make("Frame", {
    Size = UDim2.new(1,0,0.5,0), Position = UDim2.new(0,0,0.5,0),
    BackgroundColor3 = C.Red, BackgroundTransparency = 0.05, BorderSizePixel = 0,
}, TBar)

Make("TextLabel", {
    Size = UDim2.new(1,-50,1,0), Position = UDim2.new(0,14,0,0),
    BackgroundTransparency = 1,
    Text = "CYBER//WEST   |   OPERATOR: "..LocalPlayer.Name.."   |   ONLINE",
    TextColor3 = C.White, TextSize = 12, Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, TBar)

local XBtn = Make("TextButton", {
    Size = UDim2.new(0,26,0,26), Position = UDim2.new(1,-34,0.5,-13),
    BackgroundColor3 = C.RedDark,
    Text = "X", TextColor3 = C.White, TextSize = 12, Font = Enum.Font.GothamBold,
    BorderSizePixel = 0, AutoButtonColor = false,
}, TBar)
Corner(XBtn, 4)
XBtn.MouseButton1Click:Connect(function() Gui:Destroy() end)

-- ============================================================
-- INFO BAR  (THREAT / ENCRYPTION / SESSION)
-- ============================================================
local IBar = Make("Frame", {
    Size = UDim2.new(1,-20,0,28), Position = UDim2.new(0,10,0,46),
    BackgroundColor3 = C.BG2, BorderSizePixel = 0,
}, Win)
Corner(IBar, 4); Stroke(IBar, C.Border)

local function InfoCell(label, value, vc, xpct)
    local f = Make("Frame", {
        Size = UDim2.new(0.33,0,1,0),
        Position = UDim2.new(xpct,0,0,0),
        BackgroundTransparency = 1,
    }, IBar)
    Make("TextLabel", {
        Size = UDim2.new(1,0,0.45,0),
        BackgroundTransparency=1, Text=label,
        TextColor3=C.Gray, TextSize=9, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Center,
    }, f)
    Make("TextLabel", {
        Size=UDim2.new(1,0,0.55,0), Position=UDim2.new(0,0,0.45,0),
        BackgroundTransparency=1, Text=value,
        TextColor3=vc, TextSize=11, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Center,
    }, f)
end
InfoCell("THREAT LEVEL","ELEVATED", C.Accent, 0)
InfoCell("ENCRYPTION",  "AES-256",  C.Green,  0.33)
InfoCell("SESSION",     tostring(math.random(100000,999999)), C.White, 0.66)

-- ============================================================
-- TAB BAR
-- ============================================================
local TBarF = Make("Frame", {
    Size = UDim2.new(1,-20,0,30), Position = UDim2.new(0,10,0,80),
    BackgroundTransparency = 1, BorderSizePixel = 0,
}, Win)
Make("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5) }, TBarF)

-- Scroll content
local Scroll = Make("ScrollingFrame", {
    Size = UDim2.new(1,-20,1,-118), Position = UDim2.new(0,10,0,116),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 3, ScrollBarImageColor3 = C.Red,
    CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, Win)
Make("UIPadding", { PaddingBottom=UDim.new(0,8) }, Scroll)
Make("UIListLayout", { Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder }, Scroll)

local TabPages = {}
local TabBtns  = {}

local function SwitchTab(name)
    for n, pg in pairs(TabPages) do pg.Visible = (n==name) end
    for n, b  in pairs(TabBtns)  do
        if n==name then b.BackgroundColor3=C.Red; b.TextColor3=C.White
        else            b.BackgroundColor3=C.BG2; b.TextColor3=C.Gray end
    end
end

local function NewTab(name)
    local btn = Make("TextButton", {
        Size=UDim2.new(0,108,1,0),
        BackgroundColor3=C.BG2,
        Text=name, TextColor3=C.Gray, TextSize=12, Font=Enum.Font.GothamBold,
        BorderSizePixel=0, AutoButtonColor=false,
    }, TBarF)
    Corner(btn,4); Stroke(btn,C.Border)

    local pg = Make("Frame", {
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, Visible=false, BorderSizePixel=0,
        Parent=Scroll,
    })
    Make("UIListLayout", { Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder }, pg)

    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    TabPages[name]=pg; TabBtns[name]=btn
    return pg
end

-- ============================================================
-- SECTION + WIDGETS BUILDER
-- ============================================================
local function NewSection(page, title)
    local sec = Make("Frame", {
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=C.Panel, BackgroundTransparency=0.08,
        BorderSizePixel=0, Parent=page,
    })
    Corner(sec,5); Stroke(sec,C.Border)
    Make("UIPadding", {
        PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10),
        PaddingTop=UDim.new(0,8),   PaddingBottom=UDim.new(0,8),
    }, sec)
    Make("UIListLayout", { Padding=UDim.new(0,5), SortOrder=Enum.SortOrder.LayoutOrder }, sec)

    -- Header
    local hdr = Make("Frame", {
        Size=UDim2.new(1,0,0,22), BackgroundColor3=C.RedDark,
        BorderSizePixel=0, LayoutOrder=0, Parent=sec,
    })
    Corner(hdr,3)
    Make("TextLabel", {
        Size=UDim2.new(1,-10,1,0), Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1, Text=title,
        TextColor3=C.Accent, TextSize=11, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, hdr)

    local order = {0}
    local function nextOrder() order[1]=order[1]+1; return order[1] end

    -- ── Toggle ──
    local function NewToggle(label, desc, cb)
        local row = Make("Frame", {
            Size=UDim2.new(1,0,0,38), BackgroundColor3=C.BG2,
            BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=sec,
        })
        Corner(row,4); Stroke(row,C.Border)

        Make("TextLabel", {
            Size=UDim2.new(1,-60,0,18), Position=UDim2.new(0,10,0,4),
            BackgroundTransparency=1, Text=label,
            TextColor3=C.White, TextSize=12, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, row)
        Make("TextLabel", {
            Size=UDim2.new(1,-60,0,14), Position=UDim2.new(0,10,0,22),
            BackgroundTransparency=1, Text=desc,
            TextColor3=C.Gray, TextSize=9, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, row)

        local pill = Make("Frame", {
            Size=UDim2.new(0,38,0,18), Position=UDim2.new(1,-48,0.5,-9),
            BackgroundColor3=C.OFF, BorderSizePixel=0,
        }, row)
        Corner(pill,9)
        local knob = Make("Frame", {
            Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,2,0.5,-7),
            BackgroundColor3=C.White, BorderSizePixel=0,
        }, pill)
        Corner(knob,7)

        local state = false
        Make("TextButton", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", Parent=row,
        }).MouseButton1Click:Connect(function()
            state = not state
            cb(state)
            local ti = TweenInfo.new(0.15)
            if state then
                TweenService:Create(pill,ti,{BackgroundColor3=C.Red}):Play()
                TweenService:Create(knob,ti,{Position=UDim2.new(1,-16,0.5,-7)}):Play()
            else
                TweenService:Create(pill,ti,{BackgroundColor3=C.OFF}):Play()
                TweenService:Create(knob,ti,{Position=UDim2.new(0,2,0.5,-7)}):Play()
            end
        end)
    end

    -- ── Slider ──
    local function NewSlider(label, desc, maxV, minV, cb)
        local row = Make("Frame", {
            Size=UDim2.new(1,0,0,52), BackgroundColor3=C.BG2,
            BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=sec,
        })
        Corner(row,4); Stroke(row,C.Border)

        Make("TextLabel", {
            Size=UDim2.new(0.7,0,0,18), Position=UDim2.new(0,10,0,4),
            BackgroundTransparency=1, Text=label,
            TextColor3=C.White, TextSize=12, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, row)

        local valLbl = Make("TextLabel", {
            Size=UDim2.new(0.3,-10,0,18), Position=UDim2.new(0.7,0,0,4),
            BackgroundTransparency=1, Text=tostring(minV),
            TextColor3=C.Accent, TextSize=12, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Right,
        }, row)

        Make("TextLabel", {
            Size=UDim2.new(1,-20,0,12), Position=UDim2.new(0,10,0,23),
            BackgroundTransparency=1, Text=desc,
            TextColor3=C.Gray, TextSize=9, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, row)

        local track = Make("Frame", {
            Size=UDim2.new(1,-20,0,4), Position=UDim2.new(0,10,0,40),
            BackgroundColor3=C.Border, BorderSizePixel=0,
        }, row)
        Corner(track,2)
        local fill = Make("Frame", {
            Size=UDim2.new(0,0,1,0), BackgroundColor3=C.Red, BorderSizePixel=0,
        }, track)
        Corner(fill,2)

        local function SetVal(v)
            v = math.clamp(math.floor(v), minV, maxV)
            local pct = (v-minV)/(maxV-minV)
            fill.Size = UDim2.new(pct,0,1,0)
            valLbl.Text = tostring(v)
            cb(v)
        end
        SetVal(minV)

        local sliding = false
        track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
        UserInputService.InputChanged:Connect(function(i)
            if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then
                local pct = math.clamp((i.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
                SetVal(minV + pct*(maxV-minV))
            end
        end)
    end

    return { NewToggle=NewToggle, NewSlider=NewSlider }
end

-- ============================================================
-- BUILD TABS
-- ============================================================
local PageCombat  = NewTab("COMBAT")
local PageVisuals = NewTab("VISUALS")
local PageWorld   = NewTab("WORLD")
SwitchTab("COMBAT")

local SecAimbot    = NewSection(PageCombat,  "AIMBOT PROTOCOL")
local SecPlayerESP = NewSection(PageVisuals, "PLAYER SCANNER")
local SecWorldESP  = NewSection(PageVisuals, "WORLD SCANNER")
local SecVisConfig = NewSection(PageVisuals, "DISPLAY CONFIG")
local SecUtility   = NewSection(PageWorld,   "UTILITY MODULE")
local SecMovement  = NewSection(PageWorld,   "MOVEMENT OVERRIDE")

-- ============================================================
-- GAME HELPERS
-- ============================================================
local function GetRootPart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
    end
end

local function GetDist(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return math.floor((char.HumanoidRootPart.Position - pos).Magnitude)
    end
    return 0
end

local function IsVisible(tp)
    if not tp then return false end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return false end
    local p = RaycastParams.new()
    p.FilterDescendantsInstances={char}; p.FilterType=Enum.RaycastFilterType.Exclude; p.IgnoreWater=true
    local r = workspace:Raycast(Camera.CFrame.Position, tp.Position - Camera.CFrame.Position, p)
    if r then return r.Instance:IsDescendantOf(tp.Parent) end
    return true
end

local function CleanAnimalName(obj)
    local n = obj.Name:lower()
    local p = n:find("legendary") and "[LEG] " or ""
    local m = {
        {"crow","Crow"},{"dire wolf","Dire Wolf"},{"direwolf","Dire Wolf"},
        {"wolf","Wolf"},{"coyote","Coyote"},{"fox","Fox"},
        {"grizzly","Grizzly"},{"black bear","Black Bear"},{"bear","Bear"},
        {"bison","Bison"},{"buffalo","Bison"},{"buck","Deer"},
        {"doe","Deer"},{"fawn","Deer"},{"deer","Deer"},
        {"horse","Horse"},{"cow","Cow"},{"cattle","Cow"},
        {"pig","Pig"},{"boar","Boar"},{"rabbit","Rabbit"},{"bunny","Rabbit"},{"chicken","Chicken"},
    }
    for _, e in ipairs(m) do if n:find(e[1]) then return p..e[2] end end
    return obj.Name
end

-- ============================================================
-- AIMBOT
-- ============================================================
local function GetClosestTarget()
    local tp, cd = nil, Settings.FOV
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    if Settings.AimPlayers then
        for _, v in ipairs(Players:GetPlayers()) do
            if v==LocalPlayer then continue end
            local c=v.Character; if not c then continue end
            local h=c:FindFirstChild("Head"); local hm=c:FindFirstChildOfClass("Humanoid")
            if not h or not hm or hm.Health<=0 then continue end
            if Settings.WallCheck and not IsVisible(h) then continue end
            local pos,vis=Camera:WorldToViewportPoint(h.Position)
            if vis then local m=(Vector2.new(pos.X,pos.Y)-center).Magnitude; if m<cd then tp=h;cd=m end end
        end
    end

    if Settings.AimAnimals then
        for _, fn in ipairs({"Harvestables","Animals","NPCS"}) do
            local folder=workspace:FindFirstChild(fn); if not folder then continue end
            for _, v in ipairs(folder:GetChildren()) do
                if not v:IsA("Model") then continue end
                local hm=v:FindFirstChildOfClass("Humanoid"); if hm and hm.Health<=0 then continue end
                local rp=GetRootPart(v); if not rp then continue end
                if Settings.WallCheck and not IsVisible(rp) then continue end
                local pos,vis=Camera:WorldToViewportPoint(rp.Position)
                if vis then local m=(Vector2.new(pos.X,pos.Y)-center).Magnitude; if m<cd then tp=rp;cd=m end end
            end
        end
    end
    return tp
end

-- ============================================================
-- ESP
-- ============================================================
local function ManageESP(char, text, color, tag, shouldShow, dist, isPlayer)
    local rp = isPlayer and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")) or GetRootPart(char)
    if not rp then return end
    local inRange = isPlayer or (dist <= Settings.ESPDistance)
    local bb = rp:FindFirstChild(tag)
    if shouldShow and inRange then
        if not bb then
            bb = Instance.new("BillboardGui")
            bb.Name=tag; bb.Adornee=rp; bb.AlwaysOnTop=true
            bb.Size=UDim2.new(0,200,0,60); bb.StudsOffset=Vector3.new(0,3,0); bb.Parent=rp
            local lbl=Instance.new("TextLabel",bb)
            lbl.Name="TextL"; lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,0,1,0)
            lbl.TextStrokeTransparency=0.3; lbl.TextStrokeColor3=Color3.new(0,0,0); lbl.Font=Enum.Font.Code
        end
        local lbl=bb:FindFirstChild("TextL")
        if lbl then lbl.TextSize=Settings.TextSize; lbl.TextColor3=color; lbl.Text=text..(Settings.ShowDistance and ("  ["..dist.."m]") or "") end
    else
        if bb then bb:Destroy() end
    end
end

local function CleanAnimalESP()
    for _, fn in ipairs({"Harvestables","Animals","NPCS"}) do
        local f=workspace:FindFirstChild(fn); if not f then continue end
        for _, a in ipairs(f:GetChildren()) do
            local rp=GetRootPart(a); if rp then local t=rp:FindFirstChild("OverlordAnimalESP"); if t then t:Destroy() end end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if not Settings.AnimalESP then continue end
        for _, fn in ipairs({"Harvestables","Animals","NPCS"}) do
            local folder=workspace:FindFirstChild(fn); if not folder then continue end
            for _, v in ipairs(folder:GetChildren()) do
                if v:IsA("Model") then
                    local rp=GetRootPart(v); if not rp then continue end
                    local dist=GetDist(rp.Position)
                    local hm=v:FindFirstChildOfClass("Humanoid")
                    local lbl=CleanAnimalName(v)
                    if hm and hm.Health<=0 then lbl="[DEAD] "..lbl end
                    ManageESP(v, lbl, Settings.AnimalColor, "OverlordAnimalESP", true, dist, false)
                end
            end
        end
    end
end)

-- ============================================================
-- NOCLIP
-- ============================================================
RunService.Stepped:Connect(function()
    if not Settings.Noclip then return end
    local c=LocalPlayer.Character; if not c then return end
    for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end end
end)

-- ============================================================
-- SPEED
-- ============================================================
local function ApplySpeed()
    local c=LocalPlayer.Character; if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=Settings.SpeedBoost and Settings.SpeedValue or 16 end
end

-- ============================================================
-- RENDER LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible=Settings.ShowFOVCircle
    FOVCircle.Radius=Settings.FOV
    FOVCircle.Position=Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    local ap=GetClosestTarget()
    if ap then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            Camera.CFrame=CFrame.new(Camera.CFrame.Position, ap.Position)
        end
        if Settings.SilentAim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,ap.Position), Settings.SilentAimSmoothing)
        end
    end

    if Settings.FullBright then
        Lighting.ClockTime=14; Lighting.Brightness=2
        Lighting.GlobalShadows=false; Lighting.FogEnd=100000
    end

    if Settings.TPWalk then
        local c=LocalPlayer.Character; if c then
            local h=c:FindFirstChildOfClass("Humanoid")
            if h and h.MoveDirection.Magnitude>0 then c:TranslateBy(h.MoveDirection*Settings.TPWalkSpeed*0.1) end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p==LocalPlayer then continue end
        local c=p.Character; if not c then continue end
        local h=c:FindFirstChildOfClass("Humanoid")
        local rp=c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
        if rp and h and h.Health>0 then
            local dist=GetDist(rp.Position)
            local show=Settings.PlayerName or Settings.PlayerHP
            local txt=""
            if Settings.PlayerName then txt="[ "..p.Name.." ]" end
            if Settings.PlayerHP then txt=txt..(txt~="" and "\n" or "").."HP: "..math.floor(h.Health).."/"..math.floor(h.MaxHealth) end
            ManageESP(c, txt, Settings.PlayerColor, "OverlordPlayerESP", show, dist, true)
            local hl=c:FindFirstChild("OverlordHigh")
            if Settings.PlayerBox then
                if not hl then hl=Instance.new("Highlight"); hl.Name="OverlordHigh"; hl.Parent=c end
                hl.FillColor=Settings.PlayerColor; hl.FillTransparency=0.65
                hl.OutlineColor=Color3.fromRGB(220,50,50); hl.OutlineTransparency=0
            elseif hl then hl:Destroy() end
        else
            local b=c:FindFirstChild("OverlordPlayerESP",true); if b then b:Destroy() end
            local hl=c:FindFirstChild("OverlordHigh"); if hl then hl:Destroy() end
        end
    end
end)

-- ============================================================
-- POPULATE UI
-- ============================================================
SecAimbot.NewToggle("Target Players",   "RMB - Lock onto players",          function(v) Settings.AimPlayers=v end)
SecAimbot.NewToggle("Target Animals",   "RMB - Lock onto wildlife",         function(v) Settings.AimAnimals=v end)
SecAimbot.NewToggle("Wall Check",       "Only aim at visible targets",      function(v) Settings.WallCheck=v end)
SecAimbot.NewToggle("Silent Fire",      "LMB - Smooth silent aim",          function(v) Settings.SilentAim=v end)
SecAimbot.NewSlider("FOV Radius",       "Lock-on range in pixels", 800, 50, function(v) Settings.FOV=v end)
SecAimbot.NewSlider("Silent Smoothing", "1=instant  50=smooth",    50,  1,  function(v) Settings.SilentAimSmoothing=v/100 end)
SecAimbot.NewToggle("Show FOV Ring",    "Render targeting circle",          function(v) Settings.ShowFOVCircle=v end)

SecPlayerESP.NewToggle("Name ESP",      "Show player username",             function(v) Settings.PlayerName=v end)
SecPlayerESP.NewToggle("Health ESP",    "Show HP / Max HP",                 function(v) Settings.PlayerHP=v end)
SecPlayerESP.NewToggle("Box ESP",       "Highlight player model",           function(v) Settings.PlayerBox=v end)

SecWorldESP.NewToggle("Animal ESP",     "Track all wildlife",               function(v) Settings.AnimalESP=v; if not v then CleanAnimalESP() end end)
SecWorldESP.NewToggle("Show Distance",  "Display range to target",          function(v) Settings.ShowDistance=v end)

SecVisConfig.NewSlider("Max Animal Range","Fauna ESP distance", 20000, 500, function(v) Settings.ESPDistance=v end)
SecVisConfig.NewSlider("Label Size",      "ESP font size",      20,    8,   function(v) Settings.TextSize=v end)

SecUtility.NewToggle("Full Bright",     "Force max light, remove fog",      function(v) Settings.FullBright=v end)
SecUtility.NewToggle("Instant Interact","Zero hold duration on prompts",    function(v) Settings.InstantInteract=v end)
SecUtility.NewToggle("TP-Walk",         "Safe teleport movement hack",      function(v) Settings.TPWalk=v end)
SecUtility.NewSlider("TP Speed",        "TP-Walk multiplier", 15, 1,        function(v) Settings.TPWalkSpeed=v end)

SecMovement.NewToggle("Noclip",         "Phase through walls",              function(v)
    Settings.Noclip=v
    if not v then
        local c=LocalPlayer.Character; if c then
            for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end
        end
    end
end)
SecMovement.NewToggle("Speed Boost",    "Override walk speed",              function(v) Settings.SpeedBoost=v; ApplySpeed() end)
SecMovement.NewSlider("Walk Speed",     "Speed value (default 16)", 100, 16, function(v) Settings.SpeedValue=v; ApplySpeed() end)

-- ============================================================
-- PROXIMITY + RESPAWN
-- ============================================================
ProximityPromptService.PromptShown:Connect(function(p) if Settings.InstantInteract then p.HoldDuration=0 end end)
LocalPlayer.CharacterAdded:Connect(function(c) c:WaitForChild("Humanoid",5); ApplySpeed() end)

-- ============================================================
-- BOOT NOTIFY
-- ============================================================
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title="CYBER//WEST  [ ARMED ]",
        Text="[ ALL MODULES ONLINE ]  Operator: "..LocalPlayer.Name,
        Duration=5,
    })
end)
