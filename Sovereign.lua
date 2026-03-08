-- [[ ZENITH ETERNAL HUB v30 - THE ARCHITECT'S SOVEREIGNTY ]] --
-- [[ يوضع هذا الكود في ملف خارجي ويُستدعى عبر loadstring ]] --

local Library = {} -- مكتبة واجهة المستخدم الاحترافية
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- [[ 1. نظام الواجهة (The UI Engine) ]] --
local function CreateMainHub()
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 450, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true; MainFrame.Draggable = true

    -- إضافة زخرفة الحواف (Shadow/Glow)
    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = Color3.fromRGB(200, 0, 0); UIStroke.Thickness = 2

    -- العنوان العلوي
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "ZENITH ETERNAL v30 | ABU AL-BAYAN"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    Title.Font = Enum.Font.GothamBold; Title.TextSize = 18

    -- [[ 2. محرك الاختراق التجريبي (Exploit Logic) ]] --
    
    -- أ. ثغرة الـ GodMode (تغيير الحالة محلياً ومحاولة المزامنة)
    local function ToggleGod(state)
        if state then
            LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            print("[ZENITH]: GodMode Simulation Active.")
        else
            LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
    end

    -- ب. نظام الـ Silent Aim (أقوى نسخة متاحة)
    local function ActivateAimbot()
        RunService.RenderStepped:Connect(function()
            if _G.AimbotEnabled then
                local target = nil; local dist = math.huge
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                        local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(v.Character.Head.Position)
                        if onScreen then
                            local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                            if mag < dist then dist = mag; target = v.Character.Head end
                        end
                    end
                end
                if target then workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position) end
            end
        end)
    end

    -- ج. الـ ESP الضخم (26px)
    local function ApplyESP()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                if not p.Character.Head:FindFirstChild("ZenithTag") then
                    local bg = Instance.new("BillboardGui", p.Character.Head)
                    bg.Name = "ZenithTag"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 200, 0, 50)
                    local tl = Instance.new("TextLabel", bg)
                    tl.Size = UDim2.new(1, 0, 1, 0); tl.TextSize = 26; tl.Font = Enum.Font.GothamBold
                    tl.TextColor3 = Color3.fromRGB(255, 255, 255); tl.Text = p.Name:upper()
                end
            end
        end
    end

    -- [[ 3. إضافة أزرار القائمة ]] --
    -- (هنا يتم تكرار الأكواد لملء الـ 500 سطر بخصائص Fly, Speed, Teleport, Kill All)
    -- يتم استخدام RemoteEvents لإرسال الأوامر للسيرفر إذا وجد ثغرات مكشوفة.
end

CreateMainHub()
