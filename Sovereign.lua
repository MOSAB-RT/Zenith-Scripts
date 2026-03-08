-- ╔══════════════════════════════════════════════╗
--   Mosab Westbound  |  GLASS UI  |  v7.9 PRO
--   Optimization: High Performance (No Freeze)
--   Dedicated to: Abu Al-Bayan
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
    PlayerColor=Color3.fromRGB(0,255,180),
    AnimalColor=Color3.fromRGB(255,200,0),
    Interact=false, TPWalk=false, TPSpeed=2,
    FullBright=false, Noclip=false, SpeedBoost=false, SpeedVal=16,
    GodMod=false,
}

local FOVC = Drawing.new("Circle")
FOVC.Thickness=1.5; FOVC.Filled=false; FOVC.Color=Color3.fromRGB(220,30,30); FOVC.Transparency=1; FOVC.Visible=false

local C = {
    BG=Color3.fromRGB(10,10,16), Panel=Color3.fromRGB(18,16,26),
    Row=Color3.fromRGB(22,20,32), Neon=Color3.fromRGB(220,35,35),
    NeonBr=Color3.fromRGB(255,70,70), NeonDk=Color3.fromRGB(55,8,8),
    White=Color3.fromRGB(235,232,242), Muted=Color3.fromRGB(130,125,155),
    OFF=Color3.fromRGB(40,38,55), Green=Color3.fromRGB(40,200,95),
    Border=Color3.fromRGB(180,25,25), BorderDk=Color3.fromRGB(45,25,55),
}

-- ── UI HELPERS ──────────────────────────────────
local function tw(o,t,p) TW:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end
local function twS(o,t,p) TW:Create(o,TweenInfo.new(t,Enum.EasingStyle.Back,Enum.EasingDirection.Out),p):Play() end
local function New(cls,props,parent)
    local o=Instance.new(cls)
    for k,v in pairs(props) do o[k]=v end
    if parent then o.Parent=parent end
    return o
end
local function Corner(p,r) New("UICorner",{CornerRadius=UDim.new(0,r or 10)},p) end
local function Outline(p,col,sz,tr) New("UIStroke",{Color=col or C.Border,Thickness=sz or 1,Transparency=tr or 0},p) end
local function Grad(p,a,b,rot)
    New("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,a),ColorSequenceKeypoint.new(1,b)},Rotation=rot or 90},p)
end
local function Pulse(f)
    local s=f.Size
    tw(f,0.07,{Size=UDim2.new(s.X.Scale,s.X.Offset-3,s.Y.Scale,s.Y.Offset-3)})
    task.delay(0.07,function() twS(f,0.22,{Size=s}) end)
end

-- ── GUI ROOT ─────────────────────────────────
local Gui=New("ScreenGui",{Name="GlassWest",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Global,IgnoreGuiInset=true},LocalPlayer:WaitForChild("PlayerGui"))
local Win=New("Frame",{Size=UDim2.new(0,600,0,540),Position=UDim2.new(0.5,-300,0.5,-270),BackgroundColor3=C.BG,BackgroundTransparency=0.06,BorderSizePixel=0,ZIndex=10},Gui)
Corner(Win,10); Grad(Win,Color3.fromRGB(16,12,24),Color3.fromRGB(8,8,14),140); Outline(Win,C.Border,1.5,0)

-- Titlebar
local TBar=New("Frame",{Size=UDim2.new(1,0,0,46),BackgroundColor3=C.NeonDk,BorderSizePixel=0,ZIndex=11},Win)
Corner(TBar,10); Grad(TBar,Color3.fromRGB(80,8,8),Color3.fromRGB(28,4,4),180)
New("Frame",{Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=Color3.fromRGB(28,4,4),BorderSizePixel=0,ZIndex=11},TBar)
New("TextLabel",{Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text="MOSAB WESTBOUND  ·  PRO MAX",TextColor3=C.White,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12},TBar)

local XBtn=New("TextButton",{Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-36,0.5,-14),BackgroundColor3=C.NeonDk,Text="X",TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=13},TBar)
Corner(XBtn,6); XBtn.MouseButton1Click:Connect(function() Gui:Destroy() end)

do -- Dragging System
    local drag,ds,ws=false,nil,nil
    TBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;ds=i.Position;ws=Win.Position end end)
    TBar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    UIS.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ds; Win.Position=UDim2.new(ws.X.Scale,ws.X.Offset+d.X,ws.Y.Scale,ws.Y.Offset+d.Y) end end)
end

UIS.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.RightControl then Win.Visible=not Win.Visible end end)

-- Tab System
local TabBar=New("Frame",{Size=UDim2.new(1,-20,0,34),Position=UDim2.new(0,10,0,96),BackgroundTransparency=1,ZIndex=11},Win)
New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5)},TabBar)
local Scroll=New("ScrollingFrame",{Size=UDim2.new(1,-20,1,-140),Position=UDim2.new(0,10,0,138),BackgroundTransparency=1,ScrollBarThickness=3,ScrollBarImageColor3=C.Border,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=11},Win)
New("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},Scroll)

local TPages,TBtns={},{}
local function SwitchTab(name)
    for n,pg in pairs(TPages) do pg.Visible=(n==name) end
    for n,b  in pairs(TBtns) do tw(b,0.15,{BackgroundColor3=(n==name and C.Neon or C.NeonDk),TextColor3=(n==name and C.White or C.Muted)}) end
end

local function MakeTab(name)
    local btn=New("TextButton",{Size=UDim2.new(0,115,1,0),BackgroundColor3=C.NeonDk,Text=name,TextColor3=C.Muted,TextSize=12,Font=Enum.Font.GothamBold,BorderSizePixel=0,ZIndex=12},TabBar)
    Corner(btn,7); Outline(btn,C.BorderDk,1,0.3)
    local pg=New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Visible=false,ZIndex=12},Scroll)
    New("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},pg)
    btn.MouseButton1Click:Connect(function() Pulse(btn); SwitchTab(name) end)
    TPages[name]=pg; TBtns[name]=btn; return pg
end

local function MakeSection(page,title)
    local sec=New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.Panel,BackgroundTransparency=0.2,ZIndex=13,Parent=page})
    Corner(sec,9); Outline(sec,C.BorderDk,1,0.15); Grad(sec,Color3.fromRGB(22,14,30),Color3.fromRGB(10,10,16),140)
    New("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},sec)
    New("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},sec)
    local hdr=New("Frame",{Size=UDim2.new(1,0,0,26),BackgroundColor3=C.NeonDk,ZIndex=14,Parent=sec})
    Corner(hdr,6); Grad(hdr,Color3.fromRGB(75,8,8),Color3.fromRGB(30,4,4),180)
    New("TextLabel",{Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=title,TextColor3=C.NeonBr,TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=14},hdr)
    
    return {
        NewToggle = function(lbl,desc,cb)
            local r=New("Frame",{Size=UDim2.new(1,0,0,50),BackgroundColor3=C.Row,BackgroundTransparency=0.3,ZIndex=14,Parent=sec})
            Corner(r,7); New("TextLabel",{Size=UDim2.new(1,-68,0,20),Position=UDim2.new(0,12,0,6),BackgroundTransparency=1,Text=lbl,TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15},r)
            New("TextLabel",{Size=UDim2.new(1,-68,0,14),Position=UDim2.new(0,12,0,27),BackgroundTransparency=1,Text=desc,TextColor3=C.Muted,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15},r)
            local p=New("Frame",{Size=UDim2.new(0,44,0,22),Position=UDim2.new(1,-54,0.5,-11),BackgroundColor3=C.OFF,ZIndex=15},r); Corner(p,11)
            local k=New("Frame",{Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,2,0.5,-9),BackgroundColor3=C.Muted,ZIndex=16},p); Corner(k,9)
            local b=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=17},r)
            local st=false; b.MouseButton1Click:Connect(function() st=not st; cb(st); tw(p,0.18,{BackgroundColor3=(st and C.Neon or C.OFF)}); tw(k,0.18,{Position=(st and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9))}) end)
        end,
        NewSlider = function(lbl,desc,maxV,minV,cb)
            local r=New("Frame",{Size=UDim2.new(1,0,0,68),BackgroundColor3=C.Row,BackgroundTransparency=0.3,ZIndex=14,Parent=sec})
            Corner(r,7); New("TextLabel",{Size=UDim2.new(0.65,0,0,20),Position=UDim2.new(0,12,0,5),BackgroundTransparency=1,Text=lbl,TextColor3=C.White,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15},r)
            local vL=New("TextLabel",{Size=UDim2.new(0.35,-12,0,20),Position=UDim2.new(0.65,0,0,5),BackgroundTransparency=1,Text=tostring(minV),TextColor3=C.NeonBr,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=15},r)
            local tr=New("Frame",{Size=UDim2.new(1,-24,0,16),Position=UDim2.new(0,12,0,44),BackgroundColor3=C.NeonDk,ZIndex=15},r); Corner(tr,8)
            local fi=New("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.Neon,ZIndex=16},tr); Corner(fi,8)
            local b=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=19},tr)
            local s=false; local function up(px) local pct=math.clamp((px-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1); local v=math.floor(minV+pct*(maxV-minV)); fi.Size=UDim2.new(pct,0,1,0); vL.Text=tostring(v); cb(v) end
            b.MouseButton1Down:Connect(function() s=true end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then s=false end end)
            UIS.InputChanged:Connect(function(i) if s and i.UserInputType==Enum.UserInputType.MouseMovement then up(i.Position.X) end end)
        end
    }
end

-- ── CORE GAME LOGIC ─────────────────────────
local function GetRoot(o) return o:IsA("Model") and (o.PrimaryPart or o:FindFirstChild("HumanoidRootPart")) or o end
local function IsVis(tp)
    local c=LocalPlayer.Character; if not c or not c:FindFirstChild("Head") then return false end
    local p=RaycastParams.new(); p.FilterDescendantsInstances={c}; p.FilterType=Enum.RaycastFilterType.Exclude
    local r=workspace:Raycast(Cam.CFrame.Position, tp.Position-Cam.CFrame.Position, p)
    return not r or r.Instance:IsDescendantOf(tp.Parent)
end

local targetPart = nil
task.spawn(function()
    while task.wait(0.1) do -- Smooth targeting without frame drops
        local tp, cd = nil, S.FOV
        local center = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
        if S.AimPlayers then
            for _,v in ipairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character then
                    local h = v.Character:FindFirstChild("Head")
                    if h and v.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                        local pos, vis = Cam:WorldToViewportPoint(h.Position)
                        if vis then
                            local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if mag < cd then tp = h; cd = mag end
                        end
                    end
                end
            end
        end
        targetPart = tp
    end
end)

-- Exploits Logic
task.spawn(function()
    while task.wait(0.5) do
        if S.GodMod and LocalPlayer.Character then
            for _,t in ipairs(LocalPlayer.Character:GetChildren()) do if t:IsA("Tool") then t.Parent = LocalPlayer.Backpack end end
        end
    end
end)

task.spawn(function()
    while task.wait(28) do if S.GodMod then LocalPlayer:LoadCharacter() end end
end)

Run.RenderStepped:Connect(function()
    FOVC.Visible=S.ShowFOV; FOVC.Radius=S.FOV; FOVC.Position=Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    if targetPart then
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then Cam.CFrame=CFrame.new(Cam.CFrame.Position, targetPart.Position) end
        if S.SilentAim and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position, targetPart.Position), S.SilentSmooth) end
    end
    if S.SpeedBoost and LocalPlayer.Character then
        local h=LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = S.SpeedVal end
    end
    if S.FullBright then Light.ClockTime=14; Light.Brightness=2; Light.GlobalShadows=false end
end)

-- ── BUILD EVERYTHING ────────────────────────
local PC=MakeTab("COMBAT"); local PV=MakeTab("VISUALS"); local PW=MakeTab("WORLD")
local SA=MakeSection(PC,"AIMBOT PROTOCOL"); local SV=MakeSection(PV,"SCANNER CONFIG")
local SU=MakeSection(PW,"UTILITY"); local SM=MakeSection(PW,"MOVEMENT")

SA.NewToggle("Aim Players", "RMB Lock", function(v) S.AimPlayers=v end)
SA.NewToggle("Silent Aim", "LMB Interpolation", function(v) S.SilentAim=v end)
SA.NewToggle("Show FOV", "Circle indicator", function(v) S.ShowFOV=v end)
SA.NewSlider("FOV Size", "Radius", 800, 50, function(v) S.FOV=v end)

SU.NewToggle("God Mode", "Anti-Damage (Respawn)", function(v) S.GodMod=v end)
SU.NewToggle("Full Bright", "Night vision", function(v) S.FullBright=v end)

SM.NewToggle("Speed Boost", "Walk Speed", function(v) S.SpeedBoost=v end)
SM.NewSlider("Speed Value", "Studs/s", 100, 16, function(v) S.SpeedVal=v end)

SwitchTab("COMBAT")
print("Westbound Optimized Script Loaded - Abu Al-Bayan")
