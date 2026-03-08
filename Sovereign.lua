-- ============================================================
--  🌵 Yusuf Westbound OP Script | IMPROVED VERSION
--  Fixes: Performance, Memory Leaks, Silent Aim, TP-Walk
--  Additions: Noclip, Speed Boost, Animal Kill ESP, Auto-Aim Toggle
-- ============================================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🌵 Mosab Westbound OP Script | TR", "GrapeTheme")

-- ============================================================
-- SERVICES
-- ============================================================
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local Lighting            = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService        = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- ============================================================
-- SETTINGS (Central Config)
-- ============================================================
local Settings = {
    -- Aimbot
    AimPlayers   = false,
    AimAnimals   = false,
    WallCheck    = false,
    SilentAim    = false,
    SilentAimSmoothing = 0.15,  -- NEW: smoother lerp value
    FOV          = 150,
    ShowFOVCircle = false,

    -- ESP
    PlayerName   = false,
    PlayerHP     = false,
    PlayerBox    = false,
    AnimalESP    = false,
    ShowDistance = false,
    ESPDistance  = 10000,
    TextSize     = 12,
    PlayerColor  = Color3.fromRGB(255, 0, 0),
    AnimalColor  = Color3.fromRGB(255, 165, 0),

    -- World / Utility
    InstantInteract = false,
    TPWalk          = false,
    TPWalkSpeed     = 2,
    FullBright      = false,
    Noclip          = false,   -- NEW
    SpeedBoost      = false,   -- NEW
    SpeedValue      = 16,      -- NEW (default WalkSpeed is 16)
}

-- ============================================================
-- FOV CIRCLE DRAWING
-- ============================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness    = 1.5
FOVCircle.Color        = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled       = false
FOVCircle.Transparency = 1
FOVCircle.Visible      = false

-- ============================================================
-- UI TABS & SECTIONS
-- ============================================================
local Main    = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local World   = Window:NewTab("World")

local CombatSec      = Main:NewSection("Aimbot Settings")
local ESPSec         = Visuals:NewSection("Player ESP")
local WorldESPSec    = Visuals:NewSection("World ESP")
local VisualSettings = Visuals:NewSection("Global Visual Settings")
local WorldSec       = World:NewSection("Utility")
local MoveSec        = World:NewSection("Movement")  -- NEW

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- Get root part from any object
local function GetRootPart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart
            or obj:FindFirstChild("HumanoidRootPart")
            or obj:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

-- Distance from local player to world position
local function GetDist(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return math.floor((char.HumanoidRootPart.Position - pos).Magnitude)
    end
    return 0
end

-- Raycast visibility check
local function IsVisible(targetPart)
    if not targetPart then return false end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return false end

    local origin    = Camera.CFrame.Position
    local direction = targetPart.Position - origin

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { char }
    params.FilterType   = Enum.RaycastFilterType.Exclude
    params.IgnoreWater  = true

    local result = workspace:Raycast(origin, direction, params)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

-- Clean animal display name
local function CleanAnimalName(obj)
    local name   = tostring(obj.Name):lower()
    local prefix = name:find("legendary") and "⭐ " or ""

    local nameMap = {
        { "crow",                   "Crow"       },
        { "dire wolf",              "Dire Wolf"  },
        { "direwolf",               "Dire Wolf"  },
        { "wolf",                   "Wolf"       },
        { "coyote",                 "Coyote"     },
        { "fox",                    "Fox"        },
        { "grizzly",                "Grizzly"    },
        { "black bear",             "Black Bear" },
        { "bear",                   "Bear"       },
        { "bison",                  "Bison"      },
        { "buffalo",                "Bison"      },
        { "buck",                   "Deer"       },
        { "doe",                    "Deer"       },
        { "fawn",                   "Deer"       },
        { "deer",                   "Deer"       },
        { "horse",                  "Horse"      },
        { "cow",                    "Cow"        },
        { "cattle",                 "Cow"        },
        { "pig",                    "Pig"        },
        { "boar",                   "Boar"       },
        { "rabbit",                 "Rabbit"     },
        { "bunny",                  "Rabbit"     },
        { "chicken",                "Chicken"    },
    }

    for _, entry in ipairs(nameMap) do
        if name:find(entry[1]) then
            return prefix .. entry[2]
        end
    end
    return obj.Name
end

-- ============================================================
-- AIMBOT: GET CLOSEST TARGET
-- ============================================================
local function GetClosestTarget()
    local targetPart = nil
    local closestDist = Settings.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Players
    if Settings.AimPlayers then
        for _, v in ipairs(Players:GetPlayers()) do
            if v == LocalPlayer then continue end
            local char = v.Character
            if not char then continue end
            local head = char:FindFirstChild("Head")
            local hum  = char:FindFirstChildOfClass("Humanoid")
            if not head or not hum or hum.Health <= 0 then continue end
            if Settings.WallCheck and not IsVisible(head) then continue end

            local pos, vis = Camera:WorldToViewportPoint(head.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mag < closestDist then
                    targetPart  = head
                    closestDist = mag
                end
            end
        end
    end

    -- Animals / NPCs
    if Settings.AimAnimals then
        for _, folderName in ipairs({"Harvestables", "Animals", "NPCS"}) do
            local folder = workspace:FindFirstChild(folderName)
            if not folder then continue end
            for _, v in ipairs(folder:GetChildren()) do
                if not v:IsA("Model") then continue end
                local hum = v:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then continue end
                local rp = GetRootPart(v)
                if not rp then continue end
                if Settings.WallCheck and not IsVisible(rp) then continue end

                local pos, vis = Camera:WorldToViewportPoint(rp.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag < closestDist then
                        targetPart  = rp
                        closestDist = mag
                    end
                end
            end
        end
    end

    return targetPart
end

-- ============================================================
-- ESP: MANAGE BILLBOARDS
-- ============================================================
local function ManageESP(char, text, color, tag, shouldShow, dist, isPlayer)
    local rootPart
    if isPlayer then
        rootPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    else
        rootPart = GetRootPart(char)
    end
    if not rootPart then return end

    local inRange = isPlayer or (dist <= Settings.ESPDistance)
    local billboard = rootPart:FindFirstChild(tag)

    if shouldShow and inRange then
        -- Create billboard if missing
        if not billboard then
            billboard = Instance.new("BillboardGui")
            billboard.Name        = tag
            billboard.Adornee     = rootPart
            billboard.AlwaysOnTop = true
            billboard.Size        = UDim2.new(0, 200, 0, 60)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.Parent      = rootPart

            local label = Instance.new("TextLabel", billboard)
            label.Name                  = "TextL"
            label.BackgroundTransparency = 1
            label.Size                  = UDim2.new(1, 0, 1, 0)
            label.TextStrokeTransparency = 0.4
            label.TextStrokeColor3      = Color3.new(0, 0, 0)
            label.Font                  = Enum.Font.SourceSansBold
            label.TextScaled            = false
        end

        local label = billboard:FindFirstChild("TextL")
        if label then
            label.TextSize  = Settings.TextSize
            label.TextColor3 = color
            local distText  = Settings.ShowDistance and ("  [" .. dist .. "m]") or ""
            label.Text      = text .. distText
        end
    else
        if billboard then billboard:Destroy() end
    end
end

-- ============================================================
-- ANIMAL ESP LOOP (every 1s to save performance)
-- ============================================================
task.spawn(function()
    while true do
        task.wait(1)
        if not Settings.AnimalESP then continue end

        for _, folderName in ipairs({"Harvestables", "Animals", "NPCS"}) do
            local folder = workspace:FindFirstChild(folderName)
            if not folder then continue end
            for _, v in ipairs(folder:GetChildren()) do
                if v:IsA("Model") then
                    local rp = GetRootPart(v)
                    if rp then
                        local dist = GetDist(rp.Position)
                        local hum  = v:FindFirstChildOfClass("Humanoid")
                        -- Show [DEAD] if animal is dead
                        local label = CleanAnimalName(v)
                        if hum and hum.Health <= 0 then
                            label = "💀 " .. label
                        end
                        ManageESP(v, label, Settings.AnimalColor, "OverlordAnimalESP", true, dist, false)
                    end
                end
            end
        end
    end
end)

-- Clean up animal ESP when disabled
local function CleanAnimalESP()
    for _, folderName in ipairs({"Harvestables", "Animals", "NPCS"}) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, animal in ipairs(folder:GetChildren()) do
                local rp = GetRootPart(animal)
                if rp then
                    local tag = rp:FindFirstChild("OverlordAnimalESP")
                    if tag then tag:Destroy() end
                end
            end
        end
    end
end

-- ============================================================
-- NOCLIP (NEW)
-- ============================================================
RunService.Stepped:Connect(function()
    if Settings.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- ============================================================
-- SPEED BOOST (NEW)
-- ============================================================
local function ApplySpeed()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Settings.SpeedBoost and Settings.SpeedValue or 16
        end
    end
end

-- ============================================================
-- RENDER LOOP (Main)
-- ============================================================
RunService.RenderStepped:Connect(function()
    -- FOV Circle
    FOVCircle.Visible  = Settings.ShowFOVCircle
    FOVCircle.Radius   = Settings.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Aimbot
    local aimPart = GetClosestTarget()
    if aimPart then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
        end
        if Settings.SilentAim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, aimPart.Position),
                Settings.SilentAimSmoothing
            )
        end
    end

    -- Full Bright
    if Settings.FullBright then
        Lighting.ClockTime    = 14
        Lighting.Brightness   = 2
        Lighting.GlobalShadows = false
        Lighting.FogEnd       = 100000
    end

    -- TP-Walk (Safe Speed Hack)
    if Settings.TPWalk then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum.MoveDirection.Magnitude > 0 then
                char:TranslateBy(hum.MoveDirection * Settings.TPWalkSpeed * 0.1)
            end
        end
    end

    -- Player ESP (runs every frame for accuracy)
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if not char then continue end

        local hum = char:FindFirstChildOfClass("Humanoid")
        local rp  = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")

        if rp and hum and hum.Health > 0 then
            local dist       = GetDist(rp.Position)
            local shouldShow = Settings.PlayerName or Settings.PlayerHP
            local dText      = ""

            if Settings.PlayerName then dText = "👤 " .. p.Name end
            if Settings.PlayerHP then
                local hp      = math.floor(hum.Health)
                local maxHp   = math.floor(hum.MaxHealth)
                local hpLine  = "❤ " .. hp .. "/" .. maxHp
                dText = dText .. (dText ~= "" and "\n" or "") .. hpLine
            end

            ManageESP(char, dText, Settings.PlayerColor, "OverlordPlayerESP", shouldShow, dist, true)

            -- Box (Highlight)
            local highlight = char:FindFirstChild("OverlordHigh")
            if Settings.PlayerBox then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name   = "OverlordHigh"
                    highlight.Parent = char
                end
                highlight.FillColor         = Settings.PlayerColor
                highlight.FillTransparency  = 0.6
                highlight.OutlineColor      = Color3.new(1, 1, 1)
                highlight.OutlineTransparency = 0
            elseif highlight then
                highlight:Destroy()
            end
        else
            -- Cleanup dead/left players
            local b = char:FindFirstChild("OverlordPlayerESP", true)
            if b then b:Destroy() end
            local h = char:FindFirstChild("OverlordHigh")
            if h then h:Destroy() end
        end
    end
end)

-- ============================================================
-- UI: COMBAT SECTION
-- ============================================================
CombatSec:NewToggle("Aim at Players",   "Right Click → Aim at players",     function(v) Settings.AimPlayers  = v end)
CombatSec:NewToggle("Aim at Animals",   "Right Click → Aim at animals",     function(v) Settings.AimAnimals  = v end)
CombatSec:NewToggle("Wall Check",       "Only aim at visible targets",       function(v) Settings.WallCheck   = v end)
CombatSec:NewToggle("Silent Aim",       "Left Click → Smooth aim (no snap)", function(v) Settings.SilentAim   = v end)
CombatSec:NewSlider("FOV Radius",       "Aim range in pixels", 800, 50,     function(v) Settings.FOV         = v end)
CombatSec:NewSlider("Silent Aim Smoothing", "Lower = faster snap (0.05–0.5)", 50, 1, function(v)
    Settings.SilentAimSmoothing = v / 100
end)
CombatSec:NewToggle("Show FOV Circle",  "Visualize aim range circle",        function(v) Settings.ShowFOVCircle = v end)

-- ============================================================
-- UI: PLAYER ESP SECTION
-- ============================================================
ESPSec:NewToggle("Name ESP",   "Show player usernames",  function(v) Settings.PlayerName = v end)
ESPSec:NewToggle("Health ESP", "Show HP / Max HP",       function(v) Settings.PlayerHP   = v end)
ESPSec:NewToggle("Box ESP",    "Highlight player model", function(v) Settings.PlayerBox  = v end)

-- ============================================================
-- UI: WORLD ESP SECTION
-- ============================================================
WorldESPSec:NewToggle("Enable Animal ESP", "Show wildlife (includes dead)", function(v)
    Settings.AnimalESP = v
    if not v then CleanAnimalESP() end
end)
WorldESPSec:NewToggle("Show Distance", "Display distance to target", function(v) Settings.ShowDistance = v end)

-- ============================================================
-- UI: VISUAL SETTINGS
-- ============================================================
VisualSettings:NewSlider("Max Animal ESP Range", "Max distance (studs)", 20000, 500, function(v) Settings.ESPDistance = v end)
VisualSettings:NewSlider("Text Size",            "ESP label font size",   20, 8,    function(v) Settings.TextSize    = v end)
VisualSettings:NewColorPicker("Player ESP Color", "Color for player labels", Settings.PlayerColor, function(v) Settings.PlayerColor = v end)
VisualSettings:NewColorPicker("Animal ESP Color", "Color for animal labels", Settings.AnimalColor, function(v) Settings.AnimalColor = v end)

-- ============================================================
-- UI: WORLD / UTILITY SECTION
-- ============================================================
WorldSec:NewToggle("Full Bright",        "Remove darkness & fog",     function(v) Settings.FullBright      = v end)
WorldSec:NewToggle("Instant Interact",   "Skip hold duration prompts",function(v) Settings.InstantInteract = v end)
WorldSec:NewToggle("TP-Walk",            "Safe teleport speed hack",  function(v) Settings.TPWalk          = v end)
WorldSec:NewSlider("TP Speed",           "TP-Walk speed factor", 15, 1, function(v) Settings.TPWalkSpeed   = v end)

-- ============================================================
-- UI: MOVEMENT SECTION (NEW)
-- ============================================================
MoveSec:NewToggle("Noclip", "Walk through walls", function(v)
    Settings.Noclip = v
    -- Restore collision on disable
    if not v then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

MoveSec:NewToggle("Speed Boost", "Increase walk speed", function(v)
    Settings.SpeedBoost = v
    ApplySpeed()
end)

MoveSec:NewSlider("Walk Speed", "Custom speed (default 16)", 100, 16, function(v)
    Settings.SpeedValue = v
    ApplySpeed()
end)

-- ============================================================
-- PROXIMITY PROMPT: INSTANT INTERACT
-- ============================================================
ProximityPromptService.PromptShown:Connect(function(prompt)
    if Settings.InstantInteract then
        prompt.HoldDuration = 0
    end
end)

-- ============================================================
-- CHARACTER RESPAWN: RE-APPLY SPEED
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 5)
    ApplySpeed()
end)

-- ============================================================
-- STARTUP NOTIFY
-- ============================================================
Library:Notify("✅ Script Loaded", "Yusuf Westbound OP — Improved Version", 5)
