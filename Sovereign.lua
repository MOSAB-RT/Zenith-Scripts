--[[ 
    ZENITH ETERNAL v32 | THE ARCHITECT'S SOVEREIGNTY
    DEVELOPER: ABU AL-BAYAN (MOSAB)
    AUTHORIZED USER: mairjdyr
    EXECUTOR: XENO | VERSION: 32.0.0
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 1. نظام الحماية بالاسم (Whitelist) ]] --
if LocalPlayer.Name ~= "mairjdyr" then
    LocalPlayer:Kick("Access Denied: You are not authorized.")
    return
end

-- [[ 2. قاعدة البيانات المركزية ]] --
_G.Zenith = {
    Aimbot = false,
    ESP = false,
    Fly = false,
    InfJump = false,
    SpeedValue = 16,
    FlySpeed = 50,
    TextSize = 26 -- الحجم المطلوب بوضوح
}

-- [[ 3. محركات التشغيل الاحترافية (Logic Engines) ]] --

-- أ. نظام السرعة الآمن (CFrame Bypass)
RunService.Heartbeat:Connect(function()
    if _G.Zenith.SpeedValue > 16 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hum = LocalPlayer.Character.Humanoid
        if hum.MoveDirection.Magnitude > 0 then
            LocalPlayer.Character:TranslateBy(hum.MoveDirection * (_G.Zenith.SpeedValue / 50))
        end
    end
end)

-- ب. نظام الـ Fly المطور (BodyVelocity)
local flyBV = Instance.new("BodyVelocity")
local function ToggleFly(state)
    if state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        flyBV.Parent = LocalPlayer.Character.HumanoidRootPart
        flyBV.Velocity = Vector3.new(0,0,0)
        flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    else
        flyBV.Parent = nil
    end
end

-- ج. نظام الـ ESP الذكي (يختفي فوراً عند الإيقاف)
local function UpdateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local tag = p.Character.Head:FindFirstChild("ZenithTag")
            if _G.Zenith.ESP then
                if not tag then
                    local bg = Instance.new("BillboardGui", p.Character.Head)
                    bg.Name = "ZenithTag"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 200, 0, 50)
                    local tl = Instance.new("TextLabel", bg)
                    tl.Size = UDim2.new(1, 0, 1, 0); tl.BackgroundTransparency = 1
                    tl.TextColor3 = Color3.fromRGB(255, 0, 0); tl.Font = Enum.Font.GothamBold
                    tl.TextSize = _G.Zenith.TextSize; tl.Text = p.Name:upper()
                end
            elseif tag then
                tag:Destroy()
            end
        end
    end
end

-- د. نظام الـ Aimbot (Raycast Precision)
local function GetClosest()
    local target = nil
    local shortestDist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.PrimaryPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if dist < shortestDist then shortestDist = dist; target = v.Character.PrimaryPart end
            end
        end
    end
    return target
end

-- [[ 4. محرك التحديث المستمر ]] --
RunService.RenderStepped:Connect(function()
    if _G.Zenith.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetClosest()
        if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position) end
    end
    UpdateESP()
    if _G.Zenith.InfJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    if _G.Zenith.Fly then ToggleFly(true) else ToggleFly(false) end
end)

-- [[ 5. بناء الواجهة الرسومية (GUI) ]] --
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 400, 0, 450)
    Main.Position = UDim2.new(0.5, -200, 0.5, -225)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.Active = true; Main.Draggable = true
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(255, 0, 0)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 45); Title.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    Title.Text = "ZENITH v32 | mairjdyr"; Title.TextColor3 = Color3.fromRGB(255,255,255); Title.Font = Enum.Font.GothamBold

    local Content = Instance.new("ScrollingFrame", Main)
    Content.Size = UDim2.new(1, -20, 1, -60); Content.Position = UDim2.new(0, 10, 0, 55)
    Content.BackgroundTransparency = 1; Content.CanvasSize = UDim2.new(0,0,2,0)
    Instance.new("UIListLayout", Content).Padding = UDim.new(0, 10)

    local function NewBtn(txt, callback)
        local b = Instance.new("TextButton", Content)
        b.Size = UDim2.new(0.95, 0, 0, 45); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        b.Text = txt .. " : OFF"; b.TextColor3 = Color3.fromRGB(255,255,255)
        local active = false
        b.MouseButton1Click:Connect(function()
            active = not active
            b.Text = txt .. (active and " : ON" or " : OFF")
            b.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 30)
            callback(active)
        end)
    end

    NewBtn("HARD-LOCK AIMBOT", function(v) _G.Zenith.Aimbot = v end)
    NewBtn("ESP (26PX)", function(v) _G.Zenith.ESP = v end)
    NewBtn("PHANTOM FLY", function(v) _G.Zenith.Fly = v end)
    NewBtn("INF JUMP", function(v) _G.Zenith.InfJump = v end)
    NewBtn("MAX SPEED", function(v) _G.Zenith.SpeedValue = v and 100 or 16 end)
end

CreateUI()
print("Zenith v32 Loaded for mairjdyr.")
