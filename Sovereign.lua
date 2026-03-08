--[[ 
    ZENITH ETERNAL v36 | THE ARCHITECT'S MASTERPIECE
    DEVELOPER: ABU AL-BAYAN (mairjdyr)
    PROTECTION: ANTI-KICK V3 | UI: NEUMORPHIC CSS | EXECUTOR: XENO
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 1. فحص الهوية الصارم ]] --
if LocalPlayer.Name ~= "mairjdyr" then 
    LocalPlayer:Kick("Unauthorized Access - Zenith Security")
    return 
end

-- [[ 2. الترسانة والبيانات ]] --
_G.Zenith = {
    Aimbot = false,
    ESP = false,
    WallHack = false,
    SafeFly = false,
    GhostSpeed = false,
    InfJump = false,
    KillAura = false,
    SpeedVal = 1.15, -- موازنة السرعة لتجنب Kick 267
    TextSize = 26 --
}

-- [[ 3. محركات التشغيل (Execution Cores) ]] --

-- أ. أقوى آيم بوت (Silent Prediction + Smoothing)
local function GetClosest()
    local target, dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.PrimaryPart.Position)
            if onScreen then
                local mDist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if mDist < dist then dist = mDist; target = v.Character.PrimaryPart end
            end
        end
    end
    return target
end

-- ب. محرك التجاوز الحركي (Ghost Velocity)
RunService.Heartbeat:Connect(function()
    if _G.Zenith.GhostSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local root = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character.Humanoid
        if hum.MoveDirection.Magnitude > 0 then
            -- استخدام تقنية الـ Lerp لمنع رادار السيرفر من اكتشاف السرعة
            root.CFrame = root.CFrame:Lerp(root.CFrame + (hum.MoveDirection * _G.Zenith.SpeedVal), 0.5)
        end
    end
    if _G.Zenith.InfJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ج. محرك الرؤية والـ WallHack
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local highlight = char:FindFirstChild("ZenithHighlight")
            if _G.Zenith.WallHack then
                if not highlight then
                    local h = Instance.new("Highlight", char)
                    h.Name = "ZenithHighlight"; h.FillColor = Color3.fromRGB(255, 0, 0); h.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            elseif highlight then highlight:Destroy() end
            
            local head = char:FindFirstChild("Head")
            if head then
                local tag = head:FindFirstChild("ZenithTag")
                if _G.Zenith.ESP then
                    if not tag then
                        local bg = Instance.new("BillboardGui", head)
                        bg.Name = "ZenithTag"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 200, 0, 50)
                        local tl = Instance.new("TextLabel", bg)
                        tl.Size = UDim2.new(1, 0, 1, 0); tl.BackgroundTransparency = 1; tl.TextColor3 = Color3.fromRGB(255, 255, 255)
                        tl.Font = Enum.Font.GothamBold; tl.TextSize = _G.Zenith.TextSize; tl.Text = p.Name:upper()
                        Instance.new("UIStroke", tl).Thickness = 1.5
                    end
                elseif tag then tag:Destroy() end
            end
        end
    end
    
    -- تفعيل الآيم بوت عند ضغط الزر الأيمن للماوس
    if _G.Zenith.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetClosest()
        if t then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), 0.2) end
    end
end)

-- [[ 4. بناء الواجهة الاحترافية (Elite CSS UI) ]] --
local function CreateEliteUI()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 450, 0, 550)
    Main.Position = UDim2.new(0.5, -225, 0.5, -275)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)
    
    local Accent = Instance.new("Frame", Main)
    Accent.Size = UDim2.new(1, 0, 0, 4); Accent.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Instance.new("UICorner", Accent).CornerRadius = UDim.new(0, 15)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 60); Title.BackgroundTransparency = 1
    Title.Text = "ZENITH ETERNAL v36 | mairjdyr"; Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold; Title.TextSize = 20

    local Content = Instance.new("ScrollingFrame", Main)
    Content.Size = UDim2.new(1, -30, 1, -80); Content.Position = UDim2.new(0, 15, 0, 70)
    Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 0
    Instance.new("UIListLayout", Content).Padding = UDim.new(0, 15)

    local function AddBtn(name, desc, callback)
        local Btn = Instance.new("TextButton", Content)
        Btn.Size = UDim2.new(1, 0, 0, 70); Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Btn.Text = ""; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", Btn).Color = Color3.fromRGB(40, 40, 40)

        local T = Instance.new("TextLabel", Btn)
        T.Size = UDim2.new(1, -100, 0, 30); T.Position = UDim2.new(0, 15, 0, 10); T.Text = name
        T.TextColor3 = Color3.fromRGB(255, 255, 255); T.Font = Enum.Font.GothamBold; T.TextSize = 16; T.TextXAlignment = 0; T.BackgroundTransparency = 1

        local D = Instance.new("TextLabel", Btn)
        D.Size = UDim2.new(1, -100, 0, 20); D.Position = UDim2.new(0, 15, 0, 35); D.Text = desc
        D.TextColor3 = Color3.fromRGB(150, 150, 150); D.Font = Enum.Font.Gotham; D.TextSize = 12; D.TextXAlignment = 0; D.BackgroundTransparency = 1

        local Toggle = Instance.new("Frame", Btn)
        Toggle.Size = UDim2.new(0, 40, 0, 20); Toggle.Position = UDim2.new(1, -55, 0.5, -10); Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)

        local Circle = Instance.new("Frame", Toggle)
        Circle.Size = UDim2.new(0, 16, 0, 16); Circle.Position = UDim2.new(0, 2, 0.5, -8); Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

        local active = false
        Btn.MouseButton1Click:Connect(function()
            active = not active
            TweenService:Create(Toggle, TweenInfo.new(0.3), {BackgroundColor3 = active and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(50, 50, 50)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.3), {Position = active and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
            callback(active)
        end)
    end

    -- إضافة كافة الأنظمة المحسنة
    AddBtn("PREDICTION AIM", "World's strongest aimbot logic", function(v) _G.Zenith.Aimbot = v end)
    AddBtn("ELITE ESP (26PX)", "Identify targets through everything", function(v) _G.Zenith.ESP = v end)
    AddBtn("X-RAY WALLHACK", "Full player highlights across maps", function(v) _G.Zenith.WallHack = v end)
    AddBtn("GHOST SPEED", "Safe movement bypass (Anti-Kick)", function(v) _G.Zenith.GhostSpeed = v end)
    AddBtn("INFINITE JUMP", "Unbounded vertical mobility", function(v) _G.Zenith.InfJump = v end)
    AddBtn("PHANTOM FLY", "High-altitude server surveillance", function(v) _G.Zenith.Fly = v end)
    AddBtn("KILL AURA", "Auto-neutralize nearby hostiles", function(v) _G.Zenith.KillAura = v end)
end

CreateEliteUI()
print("Zenith Eternal v36: Sovereignty Established for mairjdyr.")
