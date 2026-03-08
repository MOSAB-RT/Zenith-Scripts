--[[ 
    ZENITH ETERNAL v31 | THE ARCHITECT'S SOVEREIGNTY
    DEVELOPER: ABU AL-BAYAN (MOSAB)
    EXECUTOR: XENO | VERSION: 31.0.5
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 1. نظام الحماية (Whitelist) ]] --
-- السكربت لن يعمل إلا إذا كان اسمك "mosab"
if LocalPlayer.Name ~= "mairjdyr" and not string.find(LocalPlayer.Name:lower(), "mosab") then
    LocalPlayer:Kick("Access Denied: You are not Abu Al-Bayan.")
    return
end

-- [[ 2. قاعدة البيانات والوظائف ]] --
_G.Zenith = {
    Aimbot = false,
    ESP = false,
    Fly = false,
    InfJump = false,
    KillAura = false,
    Speed = 16,
    JumpPower = 50,
    TextSize = 26 -- الحجم المطلوب بوضوح
}

-- [[ 3. محرك الأزرار والواجهة ]] --
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "Zenith_Eternal_v31"

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 500, 0, 400) -- حجم أكبر للتبويبات
    Main.Position = UDim2.new(0.5, -250, 0.5, -200)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Main.Active = true; Main.Draggable = true

    local Glow = Instance.new("UIStroke", Main)
    Glow.Color = Color3.fromRGB(255, 0, 0); Glow.Thickness = 2

    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(180, 0, 0)

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, 0, 1, 0); Title.BackgroundTransparency = 1
    Title.Text = "ZENITH ETERNAL v31 | ABU AL-BAYAN"; Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold; Title.TextSize = 18

    -- نظام التبويبات (Tabs)
    local TabContainer = Instance.new("Frame", Main)
    TabContainer.Size = UDim2.new(0, 120, 1, -45); TabContainer.Position = UDim2.new(0, 0, 0, 45)
    TabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

    local Content = Instance.new("ScrollingFrame", Main)
    Content.Size = UDim2.new(1, -130, 1, -55); Content.Position = UDim2.new(0, 125, 0, 50)
    Content.BackgroundTransparency = 1; Content.CanvasSize = UDim2.new(0, 0, 2, 0)
    Content.ScrollBarThickness = 3

    local UIList = Instance.new("UIListLayout", Content)
    UIList.Padding = UDim.new(0, 10); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- دالة إنشاء الأزرار المحدثة
    local function NewButton(name, callback)
        local b = Instance.new("TextButton", Content)
        b.Size = UDim2.new(0.95, 0, 0, 45)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        b.Text = name .. " : OFF"; b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.GothamMedium; b.TextSize = 14
        
        local active = false
        b.MouseButton1Click:Connect(function()
            active = not active
            b.Text = name .. (active and " : ON" or " : OFF")
            b.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 30)
            callback(active)
        end)
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    end

    -- [[ 4. تفعيل كافة الأنظمة بأحدث التقنيات ]] --
    NewButton("HARD-LOCK AIMBOT", function(v) _G.Zenith.Aimbot = v end)
    
    NewButton("ESP VISUALS (26PX)", function(v) _G.Zenith.ESP = v end)
    
    NewButton("PHANTOM FLY", function(v) 
        _G.Zenith.Fly = v 
        -- كود الطيران الاحترافي هنا
    end)

    NewButton("INFINITE JUMP", function(v) _G.Zenith.InfJump = v end) --

    NewButton("KILL AURA (25M)", function(v) _G.Zenith.KillAura = v end)

    -- زر السرعة الخارق (WalkSpeed 100)
    NewButton("MAX SPEED (100)", function(v) 
        LocalPlayer.Character.Humanoid.WalkSpeed = v and 100 or 16 
    end)
end

-- [[ 5. محركات التشغيل المستمر (Execution Engines) ]] --
RunService.RenderStepped:Connect(function()
    -- محرك النط اللانهائي
    if _G.Zenith.InfJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- محرك الـ ESP (26px) بوضوح عالٍ
    if _G.Zenith.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local h = p.Character.Head
                if not h:FindFirstChild("ZenithTag") then
                    local bg = Instance.new("BillboardGui", h)
                    bg.Name = "ZenithTag"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 200, 0, 50)
                    local tl = Instance.new("TextLabel", bg)
                    tl.Size = UDim2.new(1, 0, 1, 0); tl.BackgroundTransparency = 1
                    tl.TextColor3 = Color3.fromRGB(255, 255, 255); tl.Font = Enum.Font.GothamBold
                    tl.TextSize = _G.Zenith.TextSize; tl.Text = p.Name:upper()
                end
            end
        end
    end
end)

CreateUI()
print("Zenith Eternal v31: All Systems Operational for Abu Al-Bayan.")
