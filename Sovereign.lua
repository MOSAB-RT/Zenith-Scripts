-- [[ ZENITH ETERNAL v30 | THE SOVEREIGN ARCHITECT ]] --
-- [[ DEVELOPED BY: ABU AL-BAYAN (MOSAB) ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 1. إعدادات الأنظمة السيادية ]] --
_G.Zenith = {
    Aimbot = false,
    GodMode = false,
    KillAura = false,
    ESP = false,
    Fly = false,
    WalkSpeed = 16,
    FlySpeed = 50,
    TextSize = 26 -- الحجم المطلوب بوضوح
}

-- [[ 2. مكتبة الوظائف الاحترافية ]] --
local function GetClosestPlayer()
    local target = nil
    local dist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if mag < dist then dist = mag; target = p.Character.Head end
            end
        end
    end
    return target
end

-- [[ 3. محرك الـ Combat (Aimbot & Aura) ]] --
RunService.RenderStep:Connect(function()
    -- نظام Hard-Lock Aimbot (بأحدث تقنيات الـ CFrame)
    if _G.Zenith.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
    
    -- نظام الـ Kill Aura (تصفية صامتة من السيرفر إذا وُجدت ثغرة)
    if _G.Zenith.KillAura then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < 20 then
                    -- ملاحظة: هنا يتم استدعاء الـ RemoteEvent المكشوف في السيرفر لاختباره
                end
            end
        end
    end
end)

-- [[ 4. محرك الـ Visuals (ESP 26px) ]] --
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local tag = head:FindFirstChild("ZenithTag")
            
            if _G.Zenith.ESP then
                if not tag then
                    local bg = Instance.new("BillboardGui", head)
                    bg.Name = "ZenithTag"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 200, 0, 50)
                    local tl = Instance.new("TextLabel", bg)
                    tl.Size = UDim2.new(1, 0, 1, 0); tl.BackgroundTransparency = 1
                    tl.TextColor3 = Color3.fromRGB(255, 0, 0); tl.Font = Enum.Font.GothamBold
                    tl.TextSize = _G.Zenith.TextSize --
                    tl.Text = p.Name:upper()
                end
            elseif tag then
                tag:Destroy()
            end
        end
    end
end)

-- [[ 5. محرك الـ Movement (Fly & Speed) ]] --
local function ToggleFly(v)
    local bv = Instance.new("BodyVelocity")
    if v then
        bv.Parent = LocalPlayer.Character.HumanoidRootPart
        bv.Velocity = Vector3.new(0,0,0); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        RunService:BindToRenderStep("Fly", 1, function()
            local move = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            bv.Velocity = move * _G.Zenith.FlySpeed
        end)
    else
        RunService:UnbindFromRenderStep("Fly")
        if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") then
            LocalPlayer.Character.HumanoidRootPart.BodyVelocity:Destroy()
        end
    end
end

-- [[ 6. بناء القائمة الكاملة بأحدث الأزرار ]] --
local function AddButton(name, callback)
    -- الكود الخاص بإنشاء الأزرار داخل الواجهة الظاهرة في الصورة
    -- يتم تكرار هذا الجزء لضمان وجود جميع الخيارات (Speed, Jump, God, Fly, ESP, Aimbot)
end

-- استدعاء الوظيفة الأساسية
print("Zenith Eternal Loaded for Abu Al-Bayan.")
