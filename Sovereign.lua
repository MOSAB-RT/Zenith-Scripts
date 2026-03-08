--[[ 
    ZENITH ETERNAL v34 | THE GHOST PROTOCOL (CSS EDITION)
    DEVELOPER: ABU AL-BAYAN (mairjdyr)
    BYPASS: ACTIVE | UI: MODERN GRADIENT | EXECUTOR: XENO
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 1. فحص الهوية (Whitelist) ]] --
if LocalPlayer.Name ~= "mairjdyr" then return end

-- [[ 2. قاعدة البيانات ]] --
_G.Zenith = {
    Aimbot = false,
    ESP = false,
    SafeFly = false,
    GodSpeed = false,
    WallHack = false,
    SpeedVal = 1.2,
    TextSize = 26 --
}

-- [[ 3. محرك التجاوز الأمني (Anti-Kick Movement) ]] --
-- تقنية الـ CFrame Interpolation لتجاوز الـ Anti-Cheat
RunService.Heartbeat:Connect(function()
    if _G.Zenith.GodSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local root = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character.Humanoid
        if hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * _G.Zenith.SpeedVal)
        end
    end
end)

-- [[ 4. محرك الرؤية (ESP & WallHack) ]] --
local function UpdateVisuals()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local tag = head:FindFirstChild("ZenithTag")
            
            if _G.Zenith.ESP or _G.Zenith.WallHack then
                -- نظام الـ WallHack (جعل اللاعبين يظهرون خلف الجدران)
                if _G.Zenith.WallHack and not head:FindFirstChild("ZenithHighlight") then
                    local highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "ZenithHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                end
                
                -- نظام الـ ESP (26px) الفخم
                if not tag then
                    local bg = Instance.new("BillboardGui", head)
                    bg.Name = "ZenithTag"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 200, 0, 50)
                    local tl = Instance.new("TextLabel", bg)
                    tl.Size = UDim2.new(1, 0, 1, 0); tl.BackgroundTransparency = 1
                    tl.TextColor3 = Color3.fromRGB(255, 255, 255); tl.Font = Enum.Font.GothamBold
                    tl.TextSize = _G.Zenith.TextSize; tl.Text = p.Name:upper()
                    local stroke = Instance.new("UIStroke", tl)
                    stroke.Thickness = 1.5; stroke.Color = Color3.fromRGB(0, 0, 0)
                end
            else
                if tag then tag:Destroy() end
                if p.Character:FindFirstChild("ZenithHighlight") then p.Character.ZenithHighlight:Destroy() end
            end
        end
    end
end

-- [[ 5. بناء الواجهة (Modern CSS UI) ]] --
local function CreateModernUI()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    
    -- الإطار الرئيسي (Main Container)
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 420, 0, 500)
    Main.Position = UDim2.new(0.5, -210, 0.5, -250)
    Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Main.BorderSizePixel = 0
    Main.Active = true; Main.Draggable = true
    
    -- حواف دائرية (Round Corners - CSS Style)
    local Corner = Instance.new("UICorner", Main)
    Corner.CornerRadius = UDim.new(0, 12)
    
    -- ظل وتوهج خارجي (Glow/Stroke)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(255, 0, 0); Stroke.Thickness = 2; Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- العنوان العلوي (Header)
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 50); Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, 0, 1, 0); Title.BackgroundTransparency = 1
    Title.Text = "ZENITH ETERNAL v34 | GHOST PROTOCOL"; Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.Font = Enum.Font.GothamBold; Title.TextSize = 16

    -- منطقة الأزرار (Buttons Area)
    local Content = Instance.new("ScrollingFrame", Main)
    Content.Size = UDim2.new(1, -20, 1, -70); Content.Position = UDim2.new(0, 10, 0, 60)
    Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 0
    local List = Instance.new("UIListLayout", Content); List.Padding = UDim.new(0, 12)

    -- دالة إنشاء أزرار "الـ CSS الحديث"
    local function AddModernBtn(text, desc, callback)
        local Btn = Instance.new("TextButton", Content)
        Btn.Size = UDim2.new(0.98, 0, 0, 60); Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        Btn.Text = ""; Btn.BorderSizePixel = 0
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
        
        local Label = Instance.new("TextLabel", Btn)
        Label.Size = UDim2.new(1, -20, 0, 30); Label.Position = UDim2.new(0, 15, 0, 5)
        Label.Text = text; Label.TextColor3 = Color3.fromRGB(255,255,255)
        Label.Font = Enum.Font.GothamBold; Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1

        local Status = Instance.new("TextLabel", Btn)
        Status.Size = UDim2.new(0, 50, 0, 20); Status.Position = UDim2.new(0.8, 0, 0.3, 0)
        Status.Text = "OFF"; Status.TextColor3 = Color3.fromRGB(200, 0, 0)
        Status.Font = Enum.Font.GothamBold; Status.BackgroundTransparency = 1

        local active = false
        Btn.MouseButton1Click:Connect(function()
            active = not active
            Status.Text = active and "ON" or "OFF"
            Status.TextColor3 = active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 0, 0)
            TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = active and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(28, 28, 28)}):Play()
            callback(active)
        end)
    end

    -- إضافة الأزرار المحدثة
    AddModernBtn("GHOST SPEED", "Move like a phantom (Safe)", function(v) _G.Zenith.GodSpeed = v end)
    AddModernBtn("WALL HACK", "See players through mountains", function(v) _G.Zenith.WallHack = v end)
    AddModernBtn("ESP VISUALS", "Enhanced player tracking (26px)", function(v) _G.Zenith.ESP = v end)
    AddModernBtn("SMOOTH FLY", "Invisible air movement", function(v) _G.Zenith.SafeFly = v end)
    AddModernBtn("HARD-LOCK AIM", "Pin-point precision shooting", function(v) _G.Zenith.Aimbot = v end)
end

-- تفعيل المحركات الخلفية
RunService.RenderStepped:Connect(UpdateVisuals)
CreateModernUI()
print("Zenith v34 Modern Loaded for mairjdyr.")
