-- [[ ZENITH ETERNAL v30 | THE SOVEREIGN ARCHITECT ]] --
-- [[ OWNER: ABU AL-BAYAN | EXECUTOR: XENO ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- [[ 1. الأنظمة والبيانات ]] --
_G.Zenith = {
    Aimbot = false,
    ESP = false,
    Fly = false,
    Speed = 16,
    TextSize = 26 --
}

-- [[ 2. إنشاء الواجهة الرسومية (الأزرار) ]] --
local function CreateMainHub()
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "ZenithHub"

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 400, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(200, 0, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true

    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(180, 0, 0)

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "ZENITH ETERNAL v30 | ABU AL-BAYAN"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16

    local Container = Instance.new("ScrollingFrame", MainFrame)
    Container.Size = UDim2.new(1, -20, 1, -60)
    Container.Position = UDim2.new(0, 10, 0, 50)
    Container.BackgroundTransparency = 1
    Container.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    Container.ScrollBarThickness = 4

    local UIList = Instance.new("UIListLayout", Container)
    UIList.Padding = UDim.new(0, 8)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- دالة إنشاء الأزرار (Buttons Generator)
    local function NewButton(name, callback)
        local btn = Instance.new("TextButton", Container)
        btn.Size = UDim2.new(0.9, 0, 0, 45)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.Text = name .. " : OFF"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        
        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = name .. (state and " : ON" or " : OFF")
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 35)
            callback(state)
        end)
        
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 6)
    end

    -- [[ 3. ربط الأزرار بالأنظمة ]] --
    NewButton("HARD-LOCK AIMBOT", function(v) _G.Zenith.Aimbot = v end)
    NewButton("ESP (26PX) VISUALS", function(v) _G.Zenith.ESP = v end)
    NewButton("PHANTOM FLY", function(v) _G.Zenith.Fly = v end)
    
    NewButton("SUPER SPEED (100)", function(v) 
        LocalPlayer.Character.Humanoid.WalkSpeed = v and 100 or 16 
    end)

    NewButton("INFINITE JUMP", function(v)
        _G.InfJump = v
        UserInputService.JumpRequest:Connect(function()
            if _G.InfJump then LocalPlayer.Character.Humanoid:ChangeState("Jumping") end
        end)
    end)
end

-- [[ 4. تفعيل الوظائف الخلفية ]] --
RunService.RenderStepped:Connect(function()
    -- نظام الـ ESP (26px)
    if _G.Zenith.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                if not head:FindFirstChild("ZenithTag") then
                    local bg = Instance.new("BillboardGui", head)
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

CreateMainHub()
