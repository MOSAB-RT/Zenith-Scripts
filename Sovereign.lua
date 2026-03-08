-- ██████████████████████████████████████████████████████████████
-- ██                                                          ██
-- ██   ░░░░  CYBER//WEST  ░░░░   AUTHORIZED ACCESS ONLY      ██
-- ██   [ OPERATOR: mairjdyr ] [ CLEARANCE: LEVEL-MAX ]       ██
-- ██                                                          ██
-- ██████████████████████████████████████████████████████████████

-- ============================================================
--  WHITELIST SYSTEM — ONLY mairjdyr CAN EXECUTE
-- ============================================================
local Players    = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local WHITELIST = {
    ["mairjdyr"] = true,
}

if not WHITELIST[LocalPlayer.Name] then
    -- Silent terminate — no error shown to others
    warn("[CYBER//WEST] >> ACCESS DENIED: " .. LocalPlayer.Name .. " is not an authorized operator.")
    return
end

-- ============================================================
-- BOOT SEQUENCE UI (Cyber flavor)
-- ============================================================
local StarterGui = game:GetService("StarterGui")
local function CyberNotify(title, body, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = title,
            Text     = body,
            Duration = dur or 4,
        })
    end)
end

CyberNotify("◈ CYBER//WEST", "[ IDENTITY VERIFIED ] Welcome, " .. LocalPlayer.Name, 5)
task.wait(0.5)
CyberNotify("◈ SYS INIT", "[ LOADING MODULES... ] Stand by.", 3)
task.wait(0.8)

-- ============================================================
-- LOAD UI LIBRARY
-- ============================================================
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"
))()

local Window = Library.CreateLib(
    "◈ CYBER//WEST  ·  OPERATOR: " .. LocalPlayer.Name .. "  ·  STATUS: ONLINE",
    "GrapeTheme"
)

-- ============================================================
-- SERVICES
-- ============================================================
local RunService             = game:GetService("RunService")
local UserInputService       = game:GetService("UserInputService")
local Lighting               = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")

local Camera = workspace.CurrentCamera

-- ============================================================
-- SETTINGS
-- ============================================================
local Settings = {
    AimPlayers          = false,
    AimAnimals          = false,
    WallCheck           = false,
    SilentAim           = false,
    SilentAimSmoothing  = 0.15,
    FOV                 = 150,
    ShowFOVCircle       = false,

    PlayerName   = false,
    PlayerHP     = false,
    PlayerBox    = false,
    AnimalESP    = false,
    ShowDistance = false,
    ESPDistance  = 10000,
    TextSize     = 12,
    PlayerColor  = Color3.fromRGB(0, 255, 180),    -- Cyber teal
    AnimalColor  = Color3.fromRGB(255, 200, 0),    -- Cyber gold

    InstantInteract = false,
    TPWalk          = false,
    TPWalkSpeed     = 2,
    FullBright      = false,
    Noclip          = false,
    SpeedBoost      = false,
    SpeedValue      = 16,
}

-- ============================================================
-- FOV CIRCLE  (neon cyan)
-- ============================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness    = 1.5
FOVCircle.Color        = Color3.fromRGB(0, 255, 220)
FOVCircle.Filled       = false
FOVCircle.Transparency = 1
FOVCircle.Visible      = false

-- ============================================================
-- TABS  — cyber-themed names
-- ============================================================
local TabCombat  = Window:NewTab("[ COMBAT ]")
local TabVisuals = Window:NewTab("[ VISUALS ]")
local TabWorld   = Window:NewTab("[ WORLD ]")

-- SECTIONS
local SecAimbot      = TabCombat:NewSection("◈ AIMBOT  PROTOCOL")
local SecPlayerESP   = TabVisuals:NewSection("◈ PLAYER  SCANNER")
local SecWorldESP    = TabVisuals:NewSection("◈ WORLD   SCANNER")
local SecVisConfig   = TabVisuals:NewSection("◈ DISPLAY CONFIG")
local SecUtility     = TabWorld:NewSection("◈ UTILITY  MODULE")
local SecMovement    = TabWorld:NewSection("◈ MOVEMENT OVERRIDE")

-- ============================================================
-- HELPERS
-- ============================================================
local function GetRootPart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart
            or obj:FindFirstChild("HumanoidRootPart")
            or obj:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local function GetDist(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return math.floor((char.HumanoidRootPart.Position - pos).Magnitude)
    end
    return 0
end

local function IsVisible(targetPart)
    if not targetPart then return false end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return false end

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { char }
    params.FilterType  = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true

    local result = workspace:Raycast(
        Camera.CFrame.Position,
        targetPart.Position - Camera.CFrame.Position,
        params
    )
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

local function CleanAnimalName(obj)
    local name   = tostring(obj.Name):lower()
    local prefix = name:find("legendary") and "⭐ " or ""
    local nameMap = {
        {"crow","Crow"},{"dire wolf","Dire Wolf"},{"direwolf","Dire Wolf"},
        {"wolf","Wolf"},{"coyote","Coyote"},{"fox","Fox"},
        {"grizzly","Grizzly"},{"black bear","Black Bear"},{"bear","Bear"},
        {"bison","Bison"},{"buffalo","Bison"},{"buck","Deer"},
        {"doe","Deer"},{"fawn","Deer"},{"deer","Deer"},
        {"horse","Horse"},{"cow","Cow"},{"cattle","Cow"},
        {"pig","Pig"},{"boar","Boar"},{"rabbit","Rabbit"},
        {"bunny","Rabbit"},{"chicken","Chicken"},
    }
    for _, e in ipairs(nameMap) do
        if name:find(e[1]) then return prefix .. e[2] end
    end
    return obj.Name
end

-- ============================================================
-- AIMBOT
-- ============================================================
local function GetClosestTarget()
    local targetPart  = nil
    local closestDist = Settings.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

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
                if mag < closestDist then targetPart = head; closestDist = mag end
            end
        end
    end

    if Settings.AimAnimals then
        for _, folderName in ipairs({"Harvestables","Animals","NPCS"}) do
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
                    if mag < closestDist then targetPart = rp; closestDist = mag end
                end
            end
        end
    end

    return targetPart
end

-- ============================================================
-- ESP BILLBOARD
-- ============================================================
local function ManageESP(char, text, color, tag, shouldShow, dist, isPlayer)
    local rootPart = isPlayer
        and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        or GetRootPart(char)
    if not rootPart then return end

    local inRange   = isPlayer or (dist <= Settings.ESPDistance)
    local billboard = rootPart:FindFirstChild(tag)

    if shouldShow and inRange then
        if not billboard then
            billboard = Instance.new("BillboardGui")
            billboard.Name        = tag
            billboard.Adornee     = rootPart
            billboard.AlwaysOnTop = true
            billboard.Size        = UDim2.new(0, 200, 0, 60)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.Parent      = rootPart

            local label = Instance.new("TextLabel", billboard)
            label.Name                   = "TextL"
            label.BackgroundTransparency = 1
            label.Size                   = UDim2.new(1, 0, 1, 0)
            label.TextStrokeTransparency = 0.3
            label.TextStrokeColor3       = Color3.new(0, 0, 0)
            label.Font                   = Enum.Font.Code  -- monospace = cyber look
        end

        local label = billboard:FindFirstChild("TextL")
        if label then
            label.TextSize   = Settings.TextSize
            label.TextColor3 = color
            local distText   = Settings.ShowDistance and ("  [" .. dist .. "m]") or ""
            label.Text       = text .. distText
        end
    else
        if billboard then billboard:Destroy() end
    end
end

-- ============================================================
-- ANIMAL ESP LOOP
-- ============================================================
task.spawn(function()
    while true do
        task.wait(1)
        if not Settings.AnimalESP then continue end
        for _, folderName in ipairs({"Harvestables","Animals","NPCS"}) do
            local folder = workspace:FindFirstChild(folderName)
            if not folder then continue end
            for _, v in ipairs(folder:GetChildren()) do
                if v:IsA("Model") then
                    local rp = GetRootPart(v)
                    if rp then
                        local dist  = GetDist(rp.Position)
                        local hum   = v:FindFirstChildOfClass("Humanoid")
                        local label = CleanAnimalName(v)
                        if hum and hum.Health <= 0 then label = "☠ " .. label end
                        ManageESP(v, label, Settings.AnimalColor, "OverlordAnimalESP", true, dist, false)
                    end
                end
            end
        end
    end
end)

local function CleanAnimalESP()
    for _, folderName in ipairs({"Harvestables","Animals","NPCS"}) do
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
-- NOCLIP
-- ============================================================
RunService.Stepped:Connect(function()
    if not Settings.Noclip then return end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- ============================================================
-- SPEED
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
-- MAIN RENDER LOOP
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
        Lighting.ClockTime     = 14
        Lighting.Brightness    = 2
        Lighting.GlobalShadows = false
        Lighting.FogEnd        = 100000
    end

    -- TP-Walk
    if Settings.TPWalk then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0 then
                char:TranslateBy(hum.MoveDirection * Settings.TPWalkSpeed * 0.1)
            end
        end
    end

    -- Player ESP
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

            if Settings.PlayerName then dText = "[ " .. p.Name .. " ]" end
            if Settings.PlayerHP then
                local hp    = math.floor(hum.Health)
                local maxHp = math.floor(hum.MaxHealth)
                dText = dText .. (dText ~= "" and "\n" or "") .. "HP: " .. hp .. "/" .. maxHp
            end

            ManageESP(char, dText, Settings.PlayerColor, "OverlordPlayerESP", shouldShow, dist, true)

            local highlight = char:FindFirstChild("OverlordHigh")
            if Settings.PlayerBox then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name   = "OverlordHigh"
                    highlight.Parent = char
                end
                highlight.FillColor           = Settings.PlayerColor
                highlight.FillTransparency    = 0.65
                highlight.OutlineColor        = Color3.fromRGB(0, 255, 200)
                highlight.OutlineTransparency = 0
            elseif highlight then
                highlight:Destroy()
            end
        else
            local b = char:FindFirstChild("OverlordPlayerESP", true)
            if b then b:Destroy() end
            local h = char:FindFirstChild("OverlordHigh")
            if h then h:Destroy() end
        end
    end
end)

-- ============================================================
-- UI: [ COMBAT ] TAB
-- ============================================================
SecAimbot:NewToggle("► TARGET PLAYERS",      "RMB → Lock onto players",          function(v) Settings.AimPlayers  = v end)
SecAimbot:NewToggle("► TARGET ANIMALS",      "RMB → Lock onto wildlife",         function(v) Settings.AimAnimals  = v end)
SecAimbot:NewToggle("► WALL PENETRATION OFF","Only aim at visible targets",       function(v) Settings.WallCheck   = v end)
SecAimbot:NewToggle("► SILENT FIRE",         "LMB → Smooth silent aim",          function(v) Settings.SilentAim   = v end)
SecAimbot:NewSlider("► FOV RADIUS",          "Lock-on range (pixels)", 800, 50,  function(v) Settings.FOV         = v end)
SecAimbot:NewSlider("► SILENT SMOOTHING",    "1=instant  50=butter", 50, 1,      function(v) Settings.SilentAimSmoothing = v / 100 end)
SecAimbot:NewToggle("► RENDER FOV RING",     "Show targeting perimeter",         function(v) Settings.ShowFOVCircle = v end)

-- ============================================================
-- UI: [ VISUALS ] TAB
-- ============================================================
SecPlayerESP:NewToggle("► SCAN: USERNAME",   "Render player identity tag",       function(v) Settings.PlayerName = v end)
SecPlayerESP:NewToggle("► SCAN: HEALTH BAR", "Render HP / MaxHP",               function(v) Settings.PlayerHP   = v end)
SecPlayerESP:NewToggle("► SCAN: BODY BOX",   "Highlight player silhouette",      function(v) Settings.PlayerBox  = v end)

SecWorldESP:NewToggle("► FAUNA TRACKER",     "Detect all wildlife (dead/alive)", function(v)
    Settings.AnimalESP = v
    if not v then CleanAnimalESP() end
end)
SecWorldESP:NewToggle("► DISTANCE OVERLAY",  "Show range to targets",            function(v) Settings.ShowDistance = v end)

SecVisConfig:NewSlider("► MAX FAUNA RANGE",  "Fauna ESP max distance", 20000, 500, function(v) Settings.ESPDistance = v end)
SecVisConfig:NewSlider("► LABEL SIZE",        "Tag font size",         20, 8,      function(v) Settings.TextSize    = v end)
SecVisConfig:NewColorPicker("► PLAYER TAG COLOR", "Player label tint",  Settings.PlayerColor, function(v) Settings.PlayerColor = v end)
SecVisConfig:NewColorPicker("► FAUNA TAG COLOR",  "Wildlife label tint",Settings.AnimalColor, function(v) Settings.AnimalColor = v end)

-- ============================================================
-- UI: [ WORLD ] TAB
-- ============================================================
SecUtility:NewToggle("► FULLBRIGHT OVERRIDE", "Force max light / no fog",         function(v) Settings.FullBright      = v end)
SecUtility:NewToggle("► INSTANT PROMPT",      "Zero hold duration on interact",   function(v) Settings.InstantInteract = v end)
SecUtility:NewToggle("► TP-WALK",             "Safe teleport movement hack",      function(v) Settings.TPWalk          = v end)
SecUtility:NewSlider("► TP SPEED FACTOR",     "TP-Walk multiplier", 15, 1,        function(v) Settings.TPWalkSpeed     = v end)

SecMovement:NewToggle("► NOCLIP",             "Phase through geometry",           function(v)
    Settings.Noclip = v
    if not v then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)
SecMovement:NewToggle("► SPEED OVERRIDE",     "Boost walk speed",                 function(v)
    Settings.SpeedBoost = v
    ApplySpeed()
end)
SecMovement:NewSlider("► WALK SPEED",         "Speed units (default 16)", 100, 16, function(v)
    Settings.SpeedValue = v
    ApplySpeed()
end)

-- ============================================================
-- PROXIMITY PROMPT INSTANT
-- ============================================================
ProximityPromptService.PromptShown:Connect(function(prompt)
    if Settings.InstantInteract then prompt.HoldDuration = 0 end
end)

-- ============================================================
-- RESPAWN — RE-APPLY SPEED
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 5)
    ApplySpeed()
end)

-- ============================================================
-- FINAL BOOT NOTIFY
-- ============================================================
task.wait(0.5)
CyberNotify(
    "◈ CYBER//WEST  [ ARMED ]",
    "[ ALL MODULES ONLINE ]  Operator: " .. LocalPlayer.Name,
    6
)
