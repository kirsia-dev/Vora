-- VIOLENCE DISTRICT DETECTION (PC + Mobile)
local function __VoraHub_Init_Main__()

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local Teams             = game:GetService("Teams")
local GuiService        = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer       = Players.LocalPlayer
local Camera            = Workspace.CurrentCamera

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local VoraLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/juansyahrz17-prog/Coralx/refs/heads/main/lib.lua"))()

if isMobile then UI.Mobile = true end
print("[Universal] Platform:", isMobile and "MOBILE" or "PC")

if not isMobile then
    local _cursorOn = false
    local _cursorManual = false

    local function _setCursor(state)
        _cursorOn = state
        _cursorManual = true
        pcall(function()
            UserInputService.MouseIconEnabled = state
            UserInputService.MouseBehavior = state
                and Enum.MouseBehavior.Default
                or Enum.MouseBehavior.LockCenter
        end)

        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.AutoRotate = not state
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        
        if input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt then
            _setCursor(not _cursorOn)
        end
    end)

    task.spawn(function()
        while true do
            if _cursorManual then
                pcall(function()
                    if _cursorOn then
                        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                        UserInputService.MouseIconEnabled = true
                    else
                        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                        UserInputService.MouseIconEnabled = false
                    end
                end)
            end
            task.wait(0.1)
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if _cursorOn then _setCursor(true) end
    end)

    print("[VD] ALT Toggle Cursor Ready (PC only)")
end

-- SAFE DRAWING UTILS
local DrawingAvailable = (function()
    if isMobile then return false end
    local ok, result = pcall(function()
        return typeof(Drawing) == "table" and Drawing.new ~= nil
    end)
    return ok and result or false
end)()

local function SafeDrawing(typ)
    if not DrawingAvailable then return nil end
    local ok, res = pcall(function() return Drawing.new(typ) end)
    return ok and res or nil
end

local function SafeRemove(obj)
    if obj and obj.Remove then pcall(function() obj:Remove() end) end
end

local MobileESP = {}

-- UTILITY FUNCTIONS
local function clamp(v, min, max)
    return math.max(min, math.min(max, v))
end

local Perf = {
    DrawingESPInterval        = 0.05,
    NextDrawingESP            = 0,
}

-- CONFIG
getgenv().VD = getgenv().VD or {
    -- PC Drawing ESP
    MaxDistance           = 2000,
    -- Generator / Healing
    AutoSkillcheck        = false,
    AutoSkillcheckMode    = "Normal",
    -- Visual / UI
    HideSkillUI           = false,
    Fullbright            = false,
    -- Movement
    Speed                 = false,
    SpeedValue            = 16,
    Jump                  = false,
    JumpValue             = 50,
    InfiniteJump          = false,
    Noclip                = false,
    Moonwalk              = false,
    MoonwalkZigzagSpeed   = 11,
    MoonwalkBoostPower    = 1.08,
    InvisibleNotVisual    = false,
    InvisibleSpeed        = 5,
    AntiAFK               = false,
    BypassGate            = false,
    -- Internal
    Destroyed             = false,
    -- Auto features

    AUTO_LeaveGen         = false,
    AUTO_LeaveDist        = 18,
    AUTO_Attack           = false,
    AUTO_AttackRange      = 12,
    HITBOX_Enabled        = false,
    HITBOX_Size           = 15,
    AUTO_ToFAim           = false,
    AUTO_ToFAimRange      = 90,
    AUTO_ToFDotThreshold  = 0.5,
    AUTO_ToFDebug         = false,
    AUTO_ToFTracer        = false,

    SURV_FleeKiller       = false,
    SURV_FleeDistance     = 40,
    SURV_SwiftVault       = false,
    SURV_SwiftVaultV2     = false,
    SURV_SwiftVaultSpeed  = 13,
    SURV_AutoPallet       = false,
    SURV_AutoPalletDist   = 20,
    SURV_AutoParry        = false,
    SURV_ParryDistance    = 8,
    SURV_ShowParryCircle  = false,
    SURV_AntiKnock        = false,
    -- Killer features
    KILLER_DestroyPallets = false,
    KILLER_NoPalletStun   = false,
    KILLER_AutoHook       = false,
    KILLER_AntiBlind      = false,
    KILLER_NoSlowdown     = false,
    KILLER_DoubleTap      = false,
    KILLER_InfiniteLunge  = false,
    KILLER_CustomMasked   = "Richard",
    -- Speed
    SPEED_Enabled         = false,
    SPEED_Value           = 32,
    SPEED_Method          = "Attribute",
    -- Visual extras
    NO_Fog                = false,
    CAM_FOVEnabled        = false,
    CAM_FOV               = 90,
    CAM_ThirdPerson       = false,
    CAM_ShiftLock         = false,
    CAM_InfinityZoom      = false,
    -- Config
    AntiFallDamage        = false,
    FLING_Enabled         = false,
    FLING_Strength        = 10000,
    -- Beat game
    BEAT_Survivor         = false,
    BEAT_Killer           = false,
    TP_Offset             = 3,
    -- Drawing / Advanced ESP
    DRAWING_ESP           = false,
    ESP_Skeleton          = false,
    ESP_Offscreen         = false,
    CROSS_Enabled         = false,
    CROSS_Style           = "Dot",
    CROSS_Size            = 3,
    CROSS_Thickness       = 4,
    CROSS_Gap             = 6,
    CROSS_PosX            = 0,
    CROSS_PosY            = 0,
    CROSS_Color           = Color3.fromRGB(255, 255, 255),
    ESP_Velocity          = false,
    ESP_ClosestHook       = false,
    AIM_Enabled           = false,

    AIM_UseRMB            = false,
    AIM_FOV               = 120,
    AIM_Smooth            = 0.3,
    AIM_TargetPart        = "Head",
    AIM_VisCheck          = false,
    AIM_ShowFOV           = false,
    AIM_Predict           = false,
    SURV_FirstPerson       = false,
    -- Spear aimbot
    SPEAR_Aimbot          = false,
    SPEAR_Gravity         = 50,
    SPEAR_Speed           = 100,
    -- Radar
    RADAR_Enabled         = false,
    RADAR_Size            = 150,
    RADAR_Range           = 250,
    RADAR_Transparency    = 0.2,
    RADAR_Circle          = false,
    RADAR_ShowKiller      = false,
    RADAR_ShowSurvivor    = false,
    RADAR_ShowGenerator   = false,
    RADAR_ShowPallet      = false,
    RADAR_ShowHook        = false,
    RADAR_ShowGate        = false,
    RADAR_ShowWindow      = false,
    RADAR_ShowZombie      = false,
    SURV_WarnKiller       = false
}

local VD = getgenv().VD

-- ADVANCED CROSSHAIR (GUI Fallback / Port)
local CrosshairGui = nil

local function clearCrosshair()
    if CrosshairGui then
        pcall(function() CrosshairGui:Destroy() end)
        CrosshairGui = nil
    end
end

local function VD_UpdateCrosshair()
    clearCrosshair()
    if not VD.CROSS_Enabled then return end

    local cam = workspace.CurrentCamera
    if not cam then return end

    local style = VD.CROSS_Style or "Dot"
    local size = tonumber(VD.CROSS_Size) or 3
    local gap = tonumber(VD.CROSS_Gap) or 6
    local thick = tonumber(VD.CROSS_Thickness) or 4
    local color = typeof(VD.CROSS_Color) == "Color3" and VD.CROSS_Color or Color3.fromRGB(255, 255, 255)
    
    local offsetX = tonumber(VD.CROSS_PosX) or 0
    local offsetY = tonumber(VD.CROSS_PosY) or 0

    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    local parent = (ok and core) and core or game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if not parent then return end

    CrosshairGui = Instance.new("ScreenGui")
    CrosshairGui.Name = "Vora_Crosshair"
    CrosshairGui.DisplayOrder = 999999
    CrosshairGui.IgnoreGuiInset = true
    CrosshairGui.Parent = parent

    local centerFrame = Instance.new("Frame")
    centerFrame.Name = "Center"
    centerFrame.BackgroundTransparency = 1
    centerFrame.Position = UDim2.new(0.5, offsetX, 0.5, offsetY)
    centerFrame.Size = UDim2.new(0,0,0,0)
    centerFrame.Parent = CrosshairGui

    if style == "Dot" then
        local dot = Instance.new("Frame")
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Size = UDim2.new(0, size * 2, 0, size * 2)
        dot.BackgroundColor3 = color
        dot.BorderSizePixel = 0
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = dot
        dot.Parent = centerFrame

    elseif style == "Plus" or style == "X" then
        local length = size * 3
        for i = 1, 4 do
            local line = Instance.new("Frame")
            line.AnchorPoint = Vector2.new(0.5, 0.5)
            line.BackgroundColor3 = color
            line.BorderSizePixel = 0
            
            local angle = (i - 1) * 90
            if style == "X" then angle = angle + 45 end
            
            line.Rotation = angle
            line.Size = UDim2.new(0, length, 0, thick)
            
            local rad = math.rad(angle)
            local dirX = math.cos(rad)
            local dirY = math.sin(rad)
            
            local dist = gap + (length / 2)
            line.Position = UDim2.new(0, math.floor(dirX * dist + 0.5), 0, math.floor(dirY * dist + 0.5))
            line.Parent = centerFrame
        end

    elseif style == "Box" then
        local half = gap + size * 2
        
        local t = Instance.new("Frame")
        t.BackgroundColor3 = color; t.BorderSizePixel = 0; t.AnchorPoint = Vector2.new(0.5, 0.5)
        t.Size = UDim2.new(0, half * 2 + thick, 0, thick)
        t.Position = UDim2.new(0, 0, 0, -half)
        t.Parent = centerFrame

        local b = Instance.new("Frame")
        b.BackgroundColor3 = color; b.BorderSizePixel = 0; b.AnchorPoint = Vector2.new(0.5, 0.5)
        b.Size = UDim2.new(0, half * 2 + thick, 0, thick)
        b.Position = UDim2.new(0, 0, 0, half)
        b.Parent = centerFrame

        local l = Instance.new("Frame")
        l.BackgroundColor3 = color; l.BorderSizePixel = 0; l.AnchorPoint = Vector2.new(0.5, 0.5)
        l.Size = UDim2.new(0, thick, 0, half * 2 - thick)
        l.Position = UDim2.new(0, -half, 0, 0)
        l.Parent = centerFrame

        local r = Instance.new("Frame")
        r.BackgroundColor3 = color; r.BorderSizePixel = 0; r.AnchorPoint = Vector2.new(0.5, 0.5)
        r.Size = UDim2.new(0, thick, 0, half * 2 - thick)
        r.Position = UDim2.new(0, half, 0, 0)
        r.Parent = centerFrame
    end
end
getgenv().VD_UpdateCrosshair = VD_UpdateCrosshair

local VD_DefaultOffFlags = {
    "AutoSkillcheck",
    "HideSkillUI",
    "Fullbright",
    "Speed",
    "Jump",
    "InfiniteJump",
    "Noclip",
    "Moonwalk",
    "InvisibleNotVisual",
    "AntiAFK",
    "BypassGate",
    "AUTO_Attack",
    "HITBOX_Enabled",
    "AUTO_ToFAim",
    "AUTO_ToFTracer",
    "SURV_FleeKiller",
    "SURV_SwiftVault",
    "SURV_SwiftVaultV2",
    "SURV_AutoPallet",
    "SURV_AutoParry",
    "SURV_ShowParryCircle",
    "SURV_AntiKnock",
    "KILLER_DestroyPallets",
    "KILLER_NoPalletStun",
    "KILLER_AutoHook",
    "KILLER_AntiBlind",
    "KILLER_NoSlowdown",
    "KILLER_DoubleTap",
    "KILLER_InfiniteLunge",
    "SPEED_Enabled",
    "NO_Fog",
    "CAM_FOVEnabled",
    "CAM_ThirdPerson",
    "CAM_ShiftLock",
    "CAM_InfinityZoom",
    "AntiFallDamage",
    "FLING_Enabled",
    "BEAT_Survivor",
    "BEAT_Killer",
    "DRAWING_ESP",
    "ESP_Skeleton",
    "ESP_Offscreen",
    "ESP_Velocity",
    "ESP_ClosestHook",
    "CROSS_Enabled",
    "CROSS_Style",
    "CROSS_Size",
    "CROSS_Thickness",
    "CROSS_Gap",
    "CROSS_PosX",
    "CROSS_PosY",
    "CROSS_Color",
    "AIM_Enabled",

    "AIM_UseRMB",
    "AIM_VisCheck",
    "AIM_ShowFOV",
    "AIM_Predict",
    "SURV_FirstPerson",
    "SPEAR_Aimbot",
    "RADAR_Enabled",
    "RADAR_Circle",
    "RADAR_ShowKiller",
    "RADAR_ShowSurvivor",
    "RADAR_ShowGenerator",
    "RADAR_ShowPallet",
    "RADAR_ShowHook",
    "RADAR_ShowGate",
    "RADAR_ShowWindow",
    "RADAR_ShowZombie",
    "SURV_WarnKiller",
}

for _, flagName in ipairs(VD_DefaultOffFlags) do
    VD[flagName] = false
end


-- CONFIGURATION SYSTEM (Save & Load)
local function GetSafeGuiParent()
    if gethui then return gethui() end
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then return core end
    return LocalPlayer:FindFirstChild("PlayerGui")
end


local VD_ChamsFolder = nil
local function GetSafeChamsFolder()
    local pg = GetSafeGuiParent()
    if not pg then return workspace end
    if VD_ChamsFolder and VD_ChamsFolder.Parent then return VD_ChamsFolder end

    local f = pg:FindFirstChild("Vora_WorkspaceChams")
    if not f then
        f = Instance.new("Folder")
        f.Name = "Vora_WorkspaceChams"
        f.Parent = pg
    end
    VD_ChamsFolder = f
    return f
end

local ConfigFolderName = "VoraHub"
local HttpService = game:GetService("HttpService")

if makefolder and isfolder and not isfolder(ConfigFolderName) then
    makefolder(ConfigFolderName)
end

getgenv().CurrentConfigName = "Default"

local function GetConfigList()
    local list = {}
    if listfiles and isfolder and isfolder(ConfigFolderName) then
        for _, file in pairs(listfiles(ConfigFolderName)) do
            if file:sub(-5) == ".json" then
                local filename = file:match("([^/\\]+)%.json$")
                if filename then
                    table.insert(list, filename)
                end
            end
        end
    end
    if #list == 0 then table.insert(list, "Default") end
    return list
end

local function Vora_SaveConfig(name)
    name = (name and name ~= "") and name or getgenv().CurrentConfigName
    if not name or name == "" then name = "Default" end
    local path = ConfigFolderName .. "/" .. name .. ".json"
    pcall(function()
        if writefile then
            writefile(path, HttpService:JSONEncode(VD))
        end
    end)
end

local VD_To_Flag = {
    InfiniteJump = "Infinite Jump",
    KILLER_AntiBlind = "Anti Blind (Flashlight)",
    Fullbright = "Fullbright (lighting preset)",
    AIM_VisCheck = "Visibility Check",
    AutoSkillcheck = "Auto Skillcheck",
    AutoSkillcheckMode = "Skillcheck Mode",
    HideSkillUI = "Hide Skillcheck UI",
    SpeedValue = "Speed Value",
    AIM_Enabled = "Enable Aimbot",
    HITBOX_Size = "Hitbox Size",
    SURV_FleeKiller = "Flee Killer",
    SURV_FleeDistance = "Flee Distance",
    SURV_AutoVault      = "SwiftVault",
    SURV_FastVault      = "SwiftVaultV2",
    SURV_VaultSpeed     = "SwiftVaultSpeed",
    SURV_AutoPallet     = "Pallet Reflex",
    SURV_AutoPalletDist = "Pallet Trigger Range",
    SURV_AutoParry      = "Auto Parry",
    SURV_ParryDistance  = "Parry Distance Trigger",
    SURV_ShowParryCircle = "Show Parry Range Circle",
    SURV_AntiKnock = "Anti Knock",
    MaxDistance = "Max ESP Distance",
    KILLER_InfiniteLunge = "Infinite Lunge",
    KILLER_DestroyPallets = "Destroy Pallets",
    KILLER_CustomMasked = "Custom Masked",
    Speed = "Speed Hack",
    CAM_FOV = "Camera FOV",
    ESP_Offscreen = "ESP Offscreen Arrows",
    KILLER_DoubleTap = "Double Tap",    CAM_FOVEnabled = "Enable Camera FOV override",
    FLING_Strength = "Fling Strength",
    ESP_Skeleton = "ESP Skeleton",
    Noclip = "Noclip",
    Moonwalk = "Moonwalk",
    MoonwalkZigzagSpeed = "Moonwalk Zigzag Speed",
    MoonwalkBoostPower = "Moonwalk Boost Power",
    BEAT_Killer = "Beat Killer (auto kill)",
    AIM_Predict = "Prediction",
    AIM_ShowFOV = "Show FOV Circle",
    KILLER_AutoHook = "Auto Hook",
    Jump = "Jump Hack",
    KILLER_NoSlowdown = "No Slowdown",
    SPEAR_Gravity = "Spear Gravity",
    AIM_UseRMB = "Use RMB to aim",
    CAM_ShiftLock = "Shift Lock (auto face camera)",
    Destroyed = "Solid UI Mode (No Transparency)",
    AUTO_AttackRange = "Attack Range",
    AIM_FOV = "FOV Size (aim radius on screen)",
    DRAWING_ESP = "Master Turn On Drawing ESP",    
    KILLER_NoPalletStun = "Remove Palletwrong (All)",
    CAM_ThirdPerson = "Third Person (Killer only)",
    CAM_InfinityZoom = "Infinity Zoom Out",
    AntiFallDamage = "Anti Fall Damage",
    AUTO_ToFAim = "Auto Aim Twist of Fate",
    AUTO_ToFTracer = "ToF Tracer",
    AUTO_ToFAimRange = "ToF Aim Range (studs)",
    AUTO_ToFDotThreshold = "Aim Strictness",
    InvisibleNotVisual = "Invisible Not Visual",
    InvisibleSpeed = "Invisible Speed",
    AntiAFK = "Anti AFK",
    BypassGate = "Bypass Gate",
    HITBOX_Enabled = "Hitbox Expand",
    NO_Fog = "No Fog (remove fog/post effects)",
    FLING_Enabled = "Enable Fling",
    AIM_Smooth = "Smoothness",
    SPEAR_Speed = "Spear Speed",
    SPEAR_Aimbot = "Spear Aimbot",
    SURV_FirstPerson = "First Person Camera (Survivor)",
    JumpValue = "Jump Power",
    AUTO_Attack = "Auto Attack",

    ESP_Velocity = "ESP Velocity Arrows",
    BEAT_Survivor = "Beat Survivor (auto exit)",
    SURV_WarnKiller = "Survivor Killer Warning",
}

local function Vora_LoadConfig(name)
    name = (name and name ~= "") and name or getgenv().CurrentConfigName
    if not name or name == "" then name = "Default" end
    local path = ConfigFolderName .. "/" .. name .. ".json"
    pcall(function()
        if readfile and isfile and isfile(path) then
            local data = HttpService:JSONDecode(readfile(path))
            for key, value in pairs(data) do
                VD[key] = value
                local flagName = VD_To_Flag[key]
                if flagName and Window and Window.ConfigElements and Window.ConfigElements[flagName] then
                    pcall(function()
                        local elem = Window.ConfigElements[flagName]
                        if elem.Set then elem:Set(value) end
                    end)
                end
            end
            if getgenv().Vora_SyncLoadedFeatures then pcall(getgenv().Vora_SyncLoadedFeatures) end
        end
    end)
end

local function Vora_DeleteConfig(name)
    name = (name and name ~= "") and name or getgenv().CurrentConfigName
    if not name or name == "" or name == "Default" then return end
    local path = ConfigFolderName .. "/" .. name .. ".json"
    pcall(function()
        if isfile and isfile(path) and delfile then
            delfile(path)
            print("[VD Config] Deleted:", name)
        end
    end)
end

-- SAVE ORIGINAL LIGHTING
local originalLighting = {
    Brightness     = Lighting.Brightness,
    ClockTime      = Lighting.ClockTime,
    FogEnd         = Lighting.FogEnd,
    FogStart       = Lighting.FogStart,
    GlobalShadows  = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}
do
    local atm  = Lighting:FindFirstChildOfClass("Atmosphere")
    local blur = Lighting:FindFirstChildOfClass("BlurEffect")
    local cc   = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    local sr   = Lighting:FindFirstChildOfClass("SunRaysEffect")
    if atm then
        originalLighting.Atmosphere = {
            Density = atm.Density,
            Offset = atm.Offset,
            Glare = atm.Glare,
            Haze = atm
                .Haze
        }
    end
    if blur then originalLighting.Blur = { Size = blur.Size } end
    if cc then originalLighting.ColorCorrection = { Enabled = cc.Enabled } end
    if sr then originalLighting.SunRays = { Enabled = sr.Enabled } end
end

-- CHARACTER REFS
local Character, Humanoid, Root

local function updateChar(char)
    Character = char or LocalPlayer.Character
    if Character then
        task.spawn(function()
            Humanoid = Character:WaitForChild("Humanoid", 5)
            Root     = Character:WaitForChild("HumanoidRootPart", 5)
        end)
    else
        Humanoid, Root = nil, nil
    end
end
updateChar()
LocalPlayer.CharacterAdded:Connect(updateChar)
LocalPlayer.CharacterRemoving:Connect(function(char)
    if char == Character or char == LocalPlayer.Character then
        Character, Humanoid, Root = nil, nil, nil
    end
end)

-- HELPERS: TEAM / COLORS
local TeamColor  = Color3.fromRGB(0, 255, 0)
local EnemyColor = Color3.fromRGB(255, 0, 0)

local function isTeammate(player)
    return LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team
end

local function getPlayerColor(player)
    return isTeammate(player) and TeamColor or EnemyColor
end

-- CENTRALIZED METAMETHOD HOOK (__namecall)
local AntiFailHooked = false
local oldNamecall

local Vora_ToFFireRemote = nil

local function setupAntiFail()
    if getgenv().Vora_AntiFailHooked then return end
    getgenv().Vora_AntiFailHooked = true
    task.spawn(function()
        local ok, err = pcall(function()
            local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
            local Events  = ReplicatedStorage:WaitForChild("Events", 10)
            if not Remotes then
                warn("AntiFail: Remotes not found")
                return
            end
            local tofItems  = Remotes:FindFirstChild("Items")
            local tofFolder = tofItems and tofItems:FindFirstChild("Twist of Fate")
            Vora_ToFFireRemote = tofFolder and tofFolder:FindFirstChild("Fire")
            if Vora_ToFFireRemote then
                print("ToF AutoAim: remote Fire ditemukan")
            end

            local _tofDeferred = false

            oldNamecall      = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args   = { ... }
                local argCount = select("#", ...)

                if VD.AntiFallDamage and method == "FireServer" then
                    local ok, name = pcall(function() return self.Name:lower() end)
                    if ok and (name:find("falldamage") or name:find("fall") or name:find("ragdollfall")) then
                        return
                    end
                end

-- AUTO AIM: TWIST OF FATE (Improved v2)
                if _tofDeferred then
                elseif Vora_ToFFireRemote and VD.AUTO_ToFAim
                and self == Vora_ToFFireRemote
                and method == "FireServer"
                and not checkcaller() then

                if typeof(args[1]) == "Instance" and typeof(args[2]) == "Vector3" then
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

                if myRoot then
                local bestRoot, bestDist = nil, (VD.AUTO_ToFAimRange or 60)
                for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer
                                    and plr.Team and plr.Team.Name == "Killer"
                                    and plr.Character then
                local kroot = plr.Character:FindFirstChild("HumanoidRootPart")
                local khum  = plr.Character:FindFirstChildOfClass("Humanoid")
                if kroot and khum and khum.Health > 0 then
                                        local d = (kroot.Position - myRoot.Position).Magnitude
                if d <= bestDist then
                                            bestDist = d
                                            bestRoot = kroot
                                        end
                                    end
                                end
                            end

                if bestRoot then
                local gunPart = args[1]
                local gunPos
                pcall(function() gunPos = gunPart.Position end)
                gunPos = gunPos or myRoot.Position

                local targetCenter = bestRoot.Position

                local BULLET_SPEED = 200
                local dist         = (targetCenter - gunPos).Magnitude
                local travelTime   = dist / BULLET_SPEED

                local rawVel    = bestRoot.AssemblyLinearVelocity
                local flatVel   = Vector3.new(rawVel.X, 0, rawVel.Z)
                local targetPos = targetCenter + (flatVel * travelTime)

                local dir    = targetPos - gunPos
                local newDir = (dir.Magnitude > 0.01) and dir.Unit or args[2]

                local camLook      = workspace.CurrentCamera.CFrame.LookVector
                local dotCheck     = camLook:Dot(newDir)
                local dotThreshold = VD.AUTO_ToFDotThreshold or 0.5
                if dotCheck < dotThreshold then
                        return
                                end

                                _tofDeferred = true
                                task.defer(function()
                                    pcall(function()
                                        Vora_ToFFireRemote:FireServer(args[1], newDir)
                                    end)
                                    _tofDeferred = false
                                end)
                                return
                            end
                        end
                    end
                end

                if oldNamecall then
                    return oldNamecall(self, ...)
                end
            end)

            getgenv().Vora_oldNamecall = oldNamecall
            print("AntiFail: hooked")
        end)
        if not ok then warn("AntiFail setup failed:", err) end
    end)
end
setupAntiFail()

-- FIRST PERSON CAMERA (Survivor)
local _fpWasSet = false
local _fpOriginal = nil

local function RestoreFirstPersonCamera()
    if not _fpWasSet then return end
    _fpWasSet = false

    pcall(function()
        if _fpOriginal then
            LocalPlayer.CameraMode = _fpOriginal.CameraMode or Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = _fpOriginal.CameraMaxZoomDistance or 128
            LocalPlayer.CameraMinZoomDistance = _fpOriginal.CameraMinZoomDistance or 0.5
        else
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = 128
        end
    end)

    local char = LocalPlayer.Character
    if char then
        local head = char:FindFirstChild("Head")
        if head then head.LocalTransparencyModifier = 0 end
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Accessory") then
                local handle = obj:FindFirstChild("Handle")
                if handle then handle.LocalTransparencyModifier = 0 end
            end
        end
    end

    _fpOriginal = nil
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if VD.SURV_FirstPerson then
            local isSurvivor = LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors"
            if isSurvivor then
                if not _fpWasSet then
                    _fpOriginal = {
                        CameraMode = LocalPlayer.CameraMode,
                        CameraMaxZoomDistance = LocalPlayer.CameraMaxZoomDistance,
                        CameraMinZoomDistance = LocalPlayer.CameraMinZoomDistance,
                    }
                end

                if LocalPlayer.CameraMode ~= Enum.CameraMode.LockFirstPerson then
                    LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
                end
                if LocalPlayer.CameraMaxZoomDistance ~= 0 then
                    LocalPlayer.CameraMaxZoomDistance = 0
                end

                local char = LocalPlayer.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    if head then
                        head.LocalTransparencyModifier = 1
                    end

                    for _, obj in ipairs(char:GetChildren()) do
                        if obj:IsA("Accessory") then
                            local handle = obj:FindFirstChild("Handle")
                            if handle then
                                handle.LocalTransparencyModifier = 1
                            end
                        end
                    end
                end

                _fpWasSet = true
            elseif _fpWasSet then
                RestoreFirstPersonCamera()
            end
        elseif _fpWasSet then
            RestoreFirstPersonCamera()
        end
    end)
end)

do
    if getgenv().Vora_VD_VisualESP_Cleanup then
        pcall(getgenv().Vora_VD_VisualESP_Cleanup)
    end

    local LP = LocalPlayer
    local Vora_Dead = false
    local Vora_ControlsAdded = false

    local Vora_ESPState = {
        PlayerMasterESP = false,
        WorldMasterESP = false,
        ESPFillTransparency = 0.95,
        ESPOutlineTransparency = 0.3,
        ESPTextSize = 12,

        SurvivorESP = false,
        KillerESP = false,
        SpectatorESP = false,
        Nametags = false,
        DistanceESP = false,
        SurvivorItemsESP = false,

        SurvivorColor = Color3.fromRGB(0, 255, 0),
        KillerColor = Color3.fromRGB(255, 0, 0),
        SpectatorColor = Color3.fromRGB(255, 255, 255),

        GeneratorESP = false,
        HookESP = false,
        GateESP = false,
        WindowESP = false,
        PalletESP = false,
        SCPZombieESP = false,
        WorldNametags = false,
        WorldDistanceESP = false,

        GeneratorColor = Color3.fromRGB(0, 170, 255),
        HookColor = Color3.fromRGB(255, 0, 0),
        GateColor = Color3.fromRGB(255, 225, 0),
        WindowColor = Color3.fromRGB(255, 255, 255),
        PalletColor = Color3.fromRGB(255, 140, 0),
        SCPZombieColor = Color3.fromRGB(128, 0, 128),
    }

    getgenv().Vora_VD_VisualESP_State = Vora_ESPState

    local Vora_WorldReg = {
        Generator = {},
        Hook = {},
        Gate = {},
        Window = {},
        Palletwrong = {},
        SCPZombie = {},
    }

    local Vora_MapAdd, Vora_MapRem = {}, {}
    local Vora_PlayerConns = {}
    local Vora_Connections = {}
    local Vora_PalletState = setmetatable({}, { __mode = "k" })
    local Vora_WindowState = setmetatable({}, { __mode = "k" })
    local Vora_InstanceIds = setmetatable({}, { __mode = "k" })
    local Vora_NextId = 0
    local Vora_PlayerLoopThread = nil
    local Vora_WorldLoopThread = nil
    local Vora_ESPFolder = nil

    local Vora_DisplayNames = {
        ["Motion Tracker"] = true,
        ["Gate"] = true,
        ["Flashlight"] = true,
        ["Bandage"] = true,
        ["Parrying Dagger"] = true,
        ["Adrenaline Shot"] = true,
        ["Twist of Fate"] = true,
        ["Shadow Clone"] = true,
        ["Holy Water"] = true,
        ["WaxBound Candle"] = true,
        ["Riot Shield"] = true,
        ["Emperor"] = true,
        ["AWP"] = true,
    }

    local function Vora_Alive(inst)
        if not inst then return false end
        local ok, parent = pcall(function() return inst.Parent end)
        return ok and parent ~= nil
    end

    local function Vora_Clamp(n, lo, hi)
        n = tonumber(n) or lo
        if n < lo then return lo end
        if n > hi then return hi end
        return n
    end

    local function Vora_PlayerKey(player)
        local id = player and player.UserId
        if id and id ~= 0 then return tostring(id) end
        return tostring(player and player.Name or "Unknown")
    end

    local function Vora_EspId(inst)
        if not inst then return "nil" end
        local id = Vora_InstanceIds[inst]
        if id then return id end
        Vora_NextId = Vora_NextId + 1
        id = tostring(Vora_NextId)
        Vora_InstanceIds[inst] = id
        return id
    end

    local function Vora_GetESPParent()
        local okCore, core = pcall(function() return game:GetService("CoreGui") end)
        if okCore and core then return core end
        if gethui then
            local okHui, hui = pcall(gethui)
            if okHui and hui then return hui end
        end
        local playerGui = LP and LP:FindFirstChildOfClass("PlayerGui")
        if playerGui then return playerGui end
        return Workspace
    end

    local function Vora_GetESPFolder()
        if Vora_ESPFolder and Vora_ESPFolder.Parent then
            return Vora_ESPFolder
        end

        local parent = Vora_GetESPParent()
        local old = parent:FindFirstChild("VoraHub_VisualESP") or parent:FindFirstChild("VoraHub_ESP")
        if old then old:Destroy() end

        local folder = Instance.new("Folder")
        folder.Name = "VoraHub_VisualESP"
        folder.Parent = parent
        Vora_ESPFolder = folder
        return folder
    end

    local function Vora_ClearPrefix(prefix, keepName)
        local folder = Vora_GetESPFolder()
        local keptExact = false
        for _, child in ipairs(folder:GetChildren()) do
            if child.Name:sub(1, #prefix) == prefix then
                if child.Name == keepName and not keptExact then
                    keptExact = true
                else
                    child:Destroy()
                end
            end
        end
    end

    local function Vora_SafeNotify(title, content, duration)
        pcall(function()
            if Window and Window.Notify then
                Window:Notify({
                    Title = title,
                    Content = content,
                    Duration = duration or 2,
                    Icon = "lucide:info",
                })
            end
        end)
    end

    local function Vora_ValidPart(part)
        return part and Vora_Alive(part) and part:IsA("BasePart")
    end

    local function Vora_FirstBasePart(inst)
        if not Vora_Alive(inst) then return nil end
        if inst:IsA("BasePart") then return inst end
        if inst:IsA("Model") then
            if inst.PrimaryPart and inst.PrimaryPart:IsA("BasePart") and Vora_Alive(inst.PrimaryPart) then
                return inst.PrimaryPart
            end
            local part = inst:FindFirstChildWhichIsA("BasePart", true)
            if Vora_ValidPart(part) then return part end
        end
        if inst:IsA("Tool") then
            local handle = inst:FindFirstChild("Handle") or inst:FindFirstChildWhichIsA("BasePart")
            if Vora_ValidPart(handle) then return handle end
        end
        return nil
    end

    local function Vora_GetRole(player)
        local teamName = player.Team and player.Team.Name and player.Team.Name:lower() or ""
        if teamName:find("killer") then return "Killer" end
        if teamName:find("survivor") then return "Survivor" end
        if teamName:find("spect") then return "Spectator" end
        return "Survivor"
    end

    local function Vora_PlayerRoleEnabled(player)
        local role = Vora_GetRole(player)
        if role == "Killer" then return Vora_ESPState.KillerESP end
        if role == "Spectator" then return Vora_ESPState.SpectatorESP end
        return Vora_ESPState.SurvivorESP
    end

    local function Vora_PlayerColor(player)
        local role = Vora_GetRole(player)
        if role == "Killer" then return Vora_ESPState.KillerColor end
        if role == "Spectator" then return Vora_ESPState.SpectatorColor end
        return Vora_ESPState.SurvivorColor
    end

    getgenv().Vora_VD_VisualESP_HasPlayerText = function(player)
        if not player or player == LP then return false end
        return Vora_ESPState.PlayerMasterESP
            and Vora_PlayerRoleEnabled(player)
            and (Vora_ESPState.Nametags or Vora_ESPState.DistanceESP)
    end

    local function Vora_EnsureHighlight(name, adornee, color, isPlayer)
        if not (adornee and Vora_Alive(adornee)) then return nil end
        local folder = Vora_GetESPFolder()
        Vora_ClearPrefix(name, name)

        local hl = folder:FindFirstChild(name)
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = name
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = folder
        end

        hl.Adornee = adornee
        hl.FillColor = color
        hl.OutlineColor = color
        if isPlayer then
            hl.FillTransparency = Vora_ESPState.ESPFillTransparency
            hl.OutlineTransparency = Vora_ESPState.ESPOutlineTransparency
        else
            hl.FillTransparency = 0.98
            hl.OutlineTransparency = 0.5
        end
        hl.Enabled = true
        return hl
    end

    local function Vora_DestroyChild(name)
        local folder = Vora_GetESPFolder()
        local child = folder:FindFirstChild(name)
        if child then child:Destroy() end
    end

    local function Vora_ClearPlayerESP(player)
        if not player or player == LP then return end
        local key = Vora_PlayerKey(player)
        Vora_DestroyChild("Vora_PlayerHL_" .. key)
        Vora_DestroyChild("Vora_PlayerTag_" .. key)
        Vora_DestroyChild("Vora_PlayerItem_" .. key)
    end

    local function Vora_ClearAllPlayerESP()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP then
                Vora_ClearPlayerESP(player)
            end
        end
    end

    local function Vora_GetSurvivorItem(player)
        local character = player.Character
        if not character then return nil end
        for _, obj in ipairs(character:GetDescendants()) do
            if obj:IsA("Tool") or obj:IsA("Accessory") or obj:IsA("Model") then
                if Vora_DisplayNames[obj.Name] then
                    return obj.Name
                end
            end
        end
        return nil
    end

    local function Vora_GetItemImageId(itemName)
        local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
        if not itemsFolder then return nil end
        local itemObj = itemsFolder:FindFirstChild(itemName)
        if not itemObj then return nil end

        if itemObj:IsA("Decal") or itemObj:IsA("Texture") then return itemObj.Texture end
        local texture = itemObj:FindFirstChildWhichIsA("Decal", true) or itemObj:FindFirstChildWhichIsA("Texture", true)
        if texture then return texture.Texture end
        local namedTexture = itemObj:FindFirstChild("Texture", true)
        if namedTexture and (namedTexture:IsA("Decal") or namedTexture:IsA("Texture")) then
            return namedTexture.Texture
        end
        return nil
    end

    local function Vora_SetBillboardLine(parent, index, count, data)
        local label = parent:FindFirstChild("Line" .. index)
        if not label then
            label = Instance.new("TextLabel")
            label.Name = "Line" .. index
            label.BackgroundTransparency = 1
            label.BorderSizePixel = 0
            label.Font = Enum.Font.Gotham
            label.TextStrokeTransparency = 0.65
            label.TextStrokeColor3 = Color3.new(0, 0, 0)
            label.Parent = parent
        end
        label.Size = UDim2.new(1, 0, 1 / count, 0)
        label.Position = UDim2.new(0, 0, (index - 1) / count, 0)
        label.TextSize = Vora_ESPState.ESPTextSize
        label.TextColor3 = data.Color
        label.Text = data.Text
    end

    local function Vora_PruneBillboardLines(parent, count)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("TextLabel") then
                local index = tonumber(child.Name:match("%d+"))
                if index and index > count then
                    child:Destroy()
                end
            end
        end
    end

    local function Vora_UpdatePlayerTag(player, character, head, color)
        local key = Vora_PlayerKey(player)
        local tagName = "Vora_PlayerTag_" .. key
        local folder = Vora_GetESPFolder()
        Vora_ClearPrefix("Vora_PlayerTag_" .. key, tagName)

        if not Vora_ValidPart(head) then
            Vora_DestroyChild(tagName)
            return
        end

        local lines = {}
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
        local distanceText = ""
        if Vora_ESPState.DistanceESP and root and targetRoot then
            distanceText = "[" .. tostring(math.floor((root.Position - targetRoot.Position).Magnitude)) .. "m]"
        end

        local nameText = Vora_ESPState.Nametags and player.Name or ""
        local mainLine = ""
        if nameText ~= "" and distanceText ~= "" then
            mainLine = nameText .. " " .. distanceText
        elseif nameText ~= "" then
            mainLine = nameText
        elseif distanceText ~= "" then
            mainLine = distanceText
        end

        if mainLine ~= "" then
            table.insert(lines, { Text = mainLine, Color = color })
        end

        if #lines == 0 then
            Vora_DestroyChild(tagName)
            return
        end

        local tag = folder:FindFirstChild(tagName)
        if not tag then
            tag = Instance.new("BillboardGui")
            tag.Name = tagName
            tag.AlwaysOnTop = true
            tag.LightInfluence = 0
            tag.MaxDistance = 0
            tag.Parent = folder
        end

        tag.Adornee = head
        tag.Enabled = true
        tag.Size = UDim2.new(0, 220, 0, #lines * 20)
        tag.StudsOffset = Vector3.new(0, 2.65, 0)

        for i, data in ipairs(lines) do
            Vora_SetBillboardLine(tag, i, #lines, data)
        end
        Vora_PruneBillboardLines(tag, #lines)
    end

    local function Vora_UpdatePlayerItemIcon(player, torso)
        local key = Vora_PlayerKey(player)
        local iconName = "Vora_PlayerItem_" .. key
        local folder = Vora_GetESPFolder()
        Vora_ClearPrefix("Vora_PlayerItem_" .. key, iconName)

        if not Vora_ValidPart(torso) then
            Vora_DestroyChild(iconName)
            return
        end

        local itemName = Vora_GetSurvivorItem(player)
        local imageId = itemName and Vora_GetItemImageId(itemName) or nil
        if not imageId then
            Vora_DestroyChild(iconName)
            return
        end

        local icon = folder:FindFirstChild(iconName)
        if not icon then
            icon = Instance.new("BillboardGui")
            icon.Name = iconName
            icon.AlwaysOnTop = true
            icon.LightInfluence = 0
            icon.MaxDistance = 0
            icon.Size = UDim2.fromOffset(20, 20)
            icon.StudsOffset = Vector3.new(0, 0, -1.6)
            icon.Parent = folder

            local image = Instance.new("ImageLabel")
            image.Name = "ImageLabel"
            image.BackgroundTransparency = 1
            image.Size = UDim2.fromScale(1, 1)
            image.Parent = icon
        end

        icon.Adornee = torso
        icon.Enabled = true
        local image = icon:FindFirstChild("ImageLabel")
        if image then image.Image = imageId end
    end

    local Vora_ApplyPlayerESP
    Vora_ApplyPlayerESP = function(player)
        if Vora_Dead or not player or player == LP then return end
        local character = player.Character
        if not (character and Vora_Alive(character)) then
            Vora_ClearPlayerESP(player)
            return
        end

        local key = Vora_PlayerKey(player)
        local enabled = Vora_ESPState.PlayerMasterESP and Vora_PlayerRoleEnabled(player)
        if not enabled then
            Vora_ClearPlayerESP(player)
            return
        end

        local color = Vora_PlayerColor(player)
        local head = character:FindFirstChild("Head")
        local torso = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")

        Vora_EnsureHighlight("Vora_PlayerHL_" .. key, character, color, true)
        Vora_UpdatePlayerTag(player, character, head, color)

        if Vora_GetRole(player) == "Survivor" and Vora_ESPState.SurvivorItemsESP then
            Vora_UpdatePlayerItemIcon(player, torso)
        else
            Vora_DestroyChild("Vora_PlayerItem_" .. key)
        end
    end

    local function Vora_RefreshAllPlayers()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP then
                pcall(Vora_ApplyPlayerESP, player)
            end
        end
    end

    local function Vora_StartPlayerLoop()
        if Vora_PlayerLoopThread then return end
        Vora_PlayerLoopThread = task.spawn(function()
            while not Vora_Dead and Vora_ESPState.PlayerMasterESP do
                Vora_RefreshAllPlayers()
                task.wait(0.25)
            end
            Vora_PlayerLoopThread = nil
        end)
    end

    local function Vora_WatchPlayer(player)
        if player == LP then return end
        if Vora_PlayerConns[player] then
            for _, conn in ipairs(Vora_PlayerConns[player]) do
                if conn then pcall(function() conn:Disconnect() end) end
            end
        end

        Vora_PlayerConns[player] = {}
        table.insert(Vora_PlayerConns[player], player.CharacterAdded:Connect(function(char)
            Vora_ClearPlayerESP(player)
            task.delay(0.15, function()
                if not Vora_Dead then pcall(Vora_ApplyPlayerESP, player) end
            end)
        end))
        table.insert(Vora_PlayerConns[player], player.CharacterRemoving:Connect(function()
            Vora_ClearPlayerESP(player)
        end))
        table.insert(Vora_PlayerConns[player], player:GetPropertyChangedSignal("Team"):Connect(function()
            Vora_ClearPlayerESP(player)
            pcall(Vora_ApplyPlayerESP, player)
        end))

        if player.Character then
            pcall(Vora_ApplyPlayerESP, player)
        end
    end

    local function Vora_UnwatchPlayer(player)
        Vora_ClearPlayerESP(player)
        if Vora_PlayerConns[player] then
            for _, conn in ipairs(Vora_PlayerConns[player]) do
                if conn then pcall(function() conn:Disconnect() end) end
            end
        end
        Vora_PlayerConns[player] = nil
    end

    local function Vora_PickWorldPart(model, cat)
        if not (modVoraand Vora_Alive(model)) then return nil end
        if cat == "Generator" then
            local hitbox = model:FindFirstChild("HitBox", true) or model:FindFirstChild("GeneratorPoint", true)
            if Vora_ValidPart(hitbox) then return hitbox end
        elseif cat == "Palletwrong" then
            local candidates = {
                model:FindFirstChild("HumanoidRootPart", true),
                model:FindFirstChild("PrimaryPartPallet", true),
                model:FindFirstChild("Primary1", true),
                model:FindFirstChild("Primary2", true),
                model:FindFirstChild("PalletPoint", true),
                model:FindFirstChild("PalletPointSlide", true),
            }
            for _, part in ipairs(candidates) do
                if Vora_ValidPart(part) then return part end
            end
        elseif cat == "Window" then
            local vault = model:FindFirstChild("VaultPoint", true) or model:FindFirstChild("VaultTrigger", true)
            if Vora_ValidPart(vault) then return vault end
        elseif cat == "SCPZombie" then
            local root = model:FindFirstChild("HumanoidRootPart", true)
            if Vora_ValidPart(root) then return root end
            local torso = model:FindFirstChild("UpperTorso", true) or model:FindFirstChild("Torso", true)
            if Vora_ValidPart(torso) then return torso end
            return nil
        end
        return Vora_FirstBasePart(model)
    end

    local function Vora_GeneratorLabel(model)
        local pct = tonumber(model:GetAttribute("RepairProgress")) or 0
        if pct >= 0 and pct <= 1.001 then pct = pct * 100 end
        pct = Vora_Clamp(pct, 0, 100)

        local repairers = tonumber(model:GetAttribute("PlayersRepairingCount")) or 0
        local paused = model:GetAttribute("ProgressPaused") == true
        local kickcount = tonumber(model:GetAttribute("kickcount")) or 0
        local abyss50 = model:GetAttribute("Abyss50Triggered") == true

        local parts = { "Gen " .. tostring(math.floor(pct + 0.5)) .. "%" }
        if repairers > 0 then table.insert(parts, "(" .. repairers .. "p)") end
        if paused then table.insert(parts, "Pause") end
        if abyss50 then table.insert(parts, "Warn") end
        if kickcount > 0 then table.insert(parts, "K:" .. kickcount) end

        local hue = Vora_Clamp((pct / 100) * 0.33, 0, 0.33)
        return table.concat(parts, " "), Color3.fromHSV(hue, 1, 1)
    end

    local function Vora_HasBasePart(model)
        if not (model and Vora_Alive(model)) then return false end
        return model:FindFirstChildWhichIsA("BasePart", true) ~= nil
    end

    local function Vora_IsPalletGone(model)
        if not Vora_Alive(model) then return true end
        if not model:IsDescendantOf(Workspace) then return true end
        if Vora_PalletState[model] == "DEST" then return true end
        local ok, destroyed = pcall(function() return model:GetAttribute("Destroyed") end)
        if ok and destroyed == true then return true end
        return not Vora_HasBasePart(model)
    end

    local function Vora_WorldKey(cat, model)
        return "Vora_World_" .. cat .. "_" .. Vora_EspId(model)
    end

    local function Vora_ClearWorldVisual(cat, model)
        if not model then return end
        Vora_DestroyChild(Vora_WorldKey(cat, model) .. "_HL")
        Vora_DestroyChild(Vora_WorldKey(cat, model) .. "_Tag")
    end

    local function Vora_RemoveWorldEntry(cat, model)
        if not Vora_WorldReg[cat] or not Vora_WorldReg[cat][model] then return end
        Vora_ClearWorldVisual(cat, model)
        Vora_WorldReg[cat][model] = nil
    end

    local function Vora_EnsureWorldEntry(cat, model)
        if not Vora_Alive(model) or not Vora_WorldReg[cat] or Vora_WorldReg[cat][model] then return end
        if cat == "Palletwrong" and Vora_IsPalletGone(model) then return end
        local part = Vora_PickWorldPart(model, cat)
        if not Vora_ValidPart(part) then return end
        Vora_WorldReg[cat][model] = { part = part }
    end

    local function Vora_RegisterWorldDescendant(obj)
        if not Vora_Alive(obj) then return end
        local validCats = { Generator = true, Hook = true, Gate = true, Window = true, Palletwrong = true }

        if obj:IsA("Model") then
            if validCats[obj.Name] then
                Vora_EnsureWorldEntry(obj.Name, obj)
                return
            end
            local lower = obj.Name:lower()
            if lower:find("scp") or lower:find("zombie") then
                Vora_EnsureWorldEntry("SCPZombie", obj)
            end
            return
        end

        if obj:IsA("BasePart") then
            local parent = obj.Parent
            while parent and parent ~= Workspace do
                if parent:IsA("Model") then
                    if validCats[parent.Name] then
                        Vora_EnsureWorldEntry(parent.Name, parent)
                        return
                    end
                    local lower = parent.Name:lower()
                    if lower:find("scp") or lower:find("zombie") then
                        Vora_EnsureWorldEntry("SCPZombie", parent)
                        return
                    end
                end
                parent = parent.Parent
            end
        end
    end

    local function Vora_UnregisterWorldDescendant(obj)
        if not obj then return end
        local validCats = { Generator = true, Hook = true, Gate = true, Window = true, Palletwrong = true }

        if obj:IsA("Model") then
            if validCats[obj.Name] then
                Vora_RemoveWorldEntry(obj.Name, obj)
                return
            end
            local lower = obj.Name:lower()
            if lower:find("scp") or lower:find("zombie") then
                Vora_RemoveWorldEntry("SCPZombie", obj)
            end
            return
        end

        if obj:IsA("BasePart") then
            for cat, models in pairs(Vora_WorldReg) do
                for model, entry in pairs(models) do
                    if entry.part == obj then
                        Vora_RemoveWorldEntry(cat, model)
                    end
                end
            end
        end
    end

    local function Vora_AttachESPRoot(root)
        if not root or Vora_MapAdd[root] then return end
        Vora_MapAdd[root] = root.DescendantAdded:Connect(Vora_RegisterWorldDescendant)
        Vora_MapRem[root] = root.DescendantRemoving:Connect(Vora_UnregisterWorldDescendant)
        for _, descendant in ipairs(root:GetDescendants()) do
            Vora_RegisterWorldDescendant(descendant)
        end
    end

    local function Vora_RefreshESPRoots()
        for _, conn in pairs(Vora_MapAdd) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
        for _, conn in pairs(Vora_MapRem) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
        Vora_MapAdd, Vora_MapRem = {}, {}

        for cat, models in pairs(Vora_WorldReg) do
            for model in pairs(models) do
                Vora_ClearWorldVisual(cat, model)
            end
            Vora_WorldReg[cat] = {}
        end

        local map = Workspace:FindFirstChild("Map")
        local map1 = Workspace:FindFirstChild("Map1")
        if map then Vora_AttachESPRoot(map) end
        if map1 then Vora_AttachESPRoot(map1) end
    end

    local function Vora_LabelForPallet(model)
        local state = Vora_PalletState[model] or "UP"
        if state == "DOWN" then return "Pallet (down)" end
        if state == "DEST" then return "Pallet (destroyed)" end
        if state == "SLIDE" then return "Pallet (slide)" end
        return "Pallet"
    end

    local function Vora_LabelForWindow(model)
        local state = Vora_WindowState[model] or "READY"
        if state == "BUSY" then return "Window (busy)" end
        return "Window"
    end

    local function Vora_AnyWorldEnabled()
        return Vora_ESPState.WorldMasterESP and (
            Vora_ESPState.GeneratorESP or
            Vora_ESPState.HookESP or
            Vora_ESPState.GateESP or
            Vora_ESPState.WindowESP or
            Vora_ESPState.PalletESP or
            Vora_ESPState.SCPZombieESP
        )
    end

    local function Vora_WorldCategoryData(cat)
        if cat == "Generator" then return Vora_ESPState.GeneratorESP, Vora_ESPState.GeneratorColor end
        if cat == "Hook" then return Vora_ESPState.HookESP, Vora_ESPState.HookColor end
        if cat == "Gate" then return Vora_ESPState.GateESP, Vora_ESPState.GateColor end
        if cat == "Window" then return Vora_ESPState.WindowESP, Vora_ESPState.WindowColor end
        if cat == "Palletwrong" then return Vora_ESPState.PalletESP, Vora_ESPState.PalletColor end
        if cat == "SCPZombie" then return Vora_ESPState.SCPZombieESP, Vora_ESPState.SCPZombieColor end
        return false, Color3.new(1, 1, 1)
    end

    local function Vora_UpdateWorldTag(cat, model, part, color)
        local key = Vora_WorldKey(cat, model)
        local tagName = key .. "_Tag"
        local folder = Vora_GetESPFolder()
        Vora_ClearPrefix(tagName, tagName)

        if not Vora_ValidPart(part) then
            Vora_DestroyChild(tagName)
            return
        end

        local lines = {}
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local distanceText = ""
        if Vora_ESPState.WorldDistanceESP and root then
            distanceText = "[" .. tostring(math.floor((root.Position - part.Position).Magnitude)) .. "m]"
        end

        local nameText = ""
        local labelColor = color
        if Vora_ESPState.WorldNametags then
            if cat == "Generator" then
                local txt, genColor = Vora_GeneratorLabel(model)
                nameText = txt
                labelColor = genColor
            elseif cat == "Palletwrong" then
                nameText = Vora_LabelForPallet(model)
            elseif cat == "Window" then
                nameText = Vora_LabelForWindow(model)
            elseif cat == "SCPZombie" then
                nameText = model.Name
            else
                nameText = cat
            end
        end

        local mainLine = ""
        if nameText ~= "" and distanceText ~= "" then
            mainLine = nameText .. " " .. distanceText
        elseif nameText ~= "" then
            mainLine = nameText
        elseif distanceText ~= "" then
            mainLine = distanceText
        end

        if mainLine ~= "" then
            table.insert(lines, { Text = mainLine, Color = labelColor })
        end

        if #lines == 0 then
            Vora_DestroyChild(tagName)
            return
        end

        local tag = folder:FindFirstChild(tagName)
        if not tag then
            tag = Instance.new("BillboardGui")
            tag.Name = tagName
            tag.AlwaysOnTop = true
            tag.LightInfluence = 0
            tag.MaxDistance = 0
            tag.Parent = folder
        end

        tag.Adornee = part
        tag.Enabled = true
        tag.Size = UDim2.new(0, 220, 0, #lines * 20)
        tag.StudsOffset = Vector3.new(0, 2.5, 0)

        for i, data in ipairs(lines) do
            Vora_SetBillboardLine(tag, i, #lines, data)
        end
        Vora_PruneBillboardLines(tag, #lines)
    end

    local function Vora_ClearAllWorldESP()
        for cat, models in pairs(Vora_WorldReg) do
            for model in pairs(models) do
                Vora_ClearWorldVisual(cat, model)
            end
        end
    end

    local function Vora_StartWorldLoop()
        if Vora_WorldLoopThread then return end
        Vora_WorldLoopThread = task.spawn(function()
            while not Vora_Dead and Vora_AnyWorldEnabled() do
                for cat, models in pairs(Vora_WorldReg) do
                    local enabled, color = Vora_WorldCategoryData(cat)
                    if enabled and Vora_ESPState.WorldMasterESP then
                        local n = 0
                        for model, entry in pairs(models) do
                            if cat == "Palletwrong" and Vora_IsPalletGone(model) then
                                Vora_RemoveWorldEntry(cat, model)
                            elseif model and Vora_Alive(model) then
                                local part = entry.part
                                if not Vora_ValidPart(part) or (model:IsA("Model") and not part:IsDescendantOf(model)) then
                                    entry.part = Vora_PickWorldPart(model, cat)
                                    part = entry.part
                                end

                                if Vora_ValidPart(part) then
                                    local key = Vora_WorldKey(cat, model)
                                    Vora_EnsureHighlight(key .. "_HL", model, color, false)
                                    Vora_UpdateWorldTag(cat, model, part, color)
                                else
                                    Vora_RemoveWorldEntry(cat, model)
                                end
                            else
                                Vora_RemoveWorldEntry(cat, model)
                            end

                            n = n + 1
                            if n % 60 == 0 then task.wait() end
                        end
                    else
                        for model in pairs(models) do
                            Vora_ClearWorldVisual(cat, model)
                        end
                    end
                end
                task.wait(0.25)
            end
            Vora_WorldLoopThread = nil
        end)
    end

    local function Vora_Selected(selected, name)
        if type(selected) ~= "table" then return false end
        if selected[name] ~= nil then return selected[name] == true end
        for _, value in pairs(selected) do
            if value == name then return true end
        end
        return false
    end

    getgenv().Vora_AddVisualESPControls = function(VisualTabRef)
        if not VisualTabRef or Vora_ControlsAdded then return end
        Vora_ControlsAdded = true

        local settingsSection = VisualTabRef:AddSection({
            Position = "Center",
            Name = "Highlight ESP Settings",
            Icon = "solar:settings-bold",
            Box = true,
            BoxBorder = true,
            Opened = false,
        })

        settingsSection:AddSlider({
            Name = "ESP Fill Transparency",
            Flag = "Vora ESP Fill Transparency",
            Min = 0,
            Max = 1,
            Default = Vora_ESPState.ESPFillTransparency,
            Increment = 0.01,
            Callback = function(value)
                Vora_ESPState.ESPFillTransparency = value
                Vora_RefreshAllPlayers()
            end,
        })

        settingsSection:AddSlider({
            Name = "ESP Outline Transparency",
            Flag = "Vora ESP Outline Transparency",
            Min = 0,
            Max = 1,
            Default = Vora_ESPState.ESPOutlineTransparency,
            Increment = 0.01,
            Callback = function(value)
                Vora_ESPState.ESPOutlineTransparency = value
                Vora_RefreshAllPlayers()
            end,
        })

        settingsSection:AddSlider({
            Name = "ESP Text Size",
            Flag = "Vora ESP Text Size",
            Min = 8,
            Max = 22,
            Default = Vora_ESPState.ESPTextSize,
            Increment = 1,
            Callback = function(value)
                Vora_ESPState.ESPTextSize = value
                Vora_RefreshAllPlayers()
            end,
        })

        local playerSection = VisualTabRef:AddSection({
            Position = "Center",
            Name = "Player Highlight ESP",
            Icon = "solar:users-group-rounded-bold",
            Box = true,
            BoxBorder = true,
            Opened = false,
        })

        playerSection:AddToggle({
            Name = "Enable Player ESP",
            Flag = "Vora Enable Player ESP",
            Default = false,
            Callback = function(state)
                Vora_ESPState.PlayerMasterESP = state
                if state then
                    Vora_StartPlayerLoop()
                    Vora_RefreshAllPlayers()
                else
                    Vora_ClearAllPlayerESP()
                end
            end,
        })

        playerSection:AddDropdown({
            Name = "Select Player ESP",
            Flag = "Vora Select Player ESP",
            Values = { "Survivor ESP", "Killer ESP", "Spectator ESP", "Survivor Items ESP" },
            Multi = true,
            AllowNone = true,
            Default = {},
            Callback = function(selected)
                Vora_ESPState.SurvivorESP = Vora_Selected(selected, "Survivor ESP")
                Vora_ESPState.KillerESP = Vora_Selected(selected, "Killer ESP")
                Vora_ESPState.SpectatorESP = Vora_Selected(selected, "Spectator ESP")
                Vora_ESPState.SurvivorItemsESP = Vora_Selected(selected, "Survivor Items ESP")

                if Vora_ESPState.PlayerMasterESP then
                    Vora_StartPlayerLoop()
                    Vora_RefreshAllPlayers()
                else
                    Vora_ClearAllPlayerESP()
                end
            end,
        })

        playerSection:AddToggle({
            Name = "Player Nametags",
            Flag = "Vora Player Nametags",
            Default = false,
            Callback = function(state)
                Vora_ESPState.Nametags = state
                if Vora_ESPState.PlayerMasterESP then
                    Vora_StartPlayerLoop()
                    Vora_RefreshAllPlayers()
                else
                    Vora_ClearAllPlayerESP()
                end
            end,
        })

        playerSection:AddToggle({
            Name = "Player Distance ESP",
            Flag = "Vora Player Distance ESP",
            Default = false,
            Callback = function(state)
                Vora_ESPState.DistanceESP = state
                if Vora_ESPState.PlayerMasterESP then
                    Vora_StartPlayerLoop()
                    Vora_RefreshAllPlayers()
                else
                    Vora_ClearAllPlayerESP()
                end
            end,
        })

        playerSection:AddToggle({
            Name = "Survivor Killer Warning (!)",
            Flag = "Survivor Killer Warning",
            Default = false,
            Callback = function(state)
                VD.SURV_WarnKiller = state
            end,
        })

        pcall(function() playerSection:AddDivider({ Text = "Colors" }) end)
        playerSection:AddColorPicker({ Name = "Survivor Color", Flag = "Vora Survivor Color", Default = Vora_ESPState.SurvivorColor, Callback = function(color) Vora_ESPState.SurvivorColor = color; Vora_RefreshAllPlayers() end })
        playerSection:AddColorPicker({ Name = "Killer Color", Flag = "Vora Killer Color", Default = Vora_ESPState.KillerColor, Callback = function(color) Vora_ESPState.KillerColor = color; Vora_RefreshAllPlayers() end })
        playerSection:AddColorPicker({ Name = "Spectator Color", Flag = "Vora Spectator Color", Default = Vora_ESPState.SpectatorColor, Callback = function(color) Vora_ESPState.SpectatorColor = color; Vora_RefreshAllPlayers() end })

        local worldSection = VisualTabRef:AddSection({
            Position = "Center",
            Name = "World Highlight ESP",
            Icon = "solar:map-point-wave-bold",
            Box = true,
            BoxBorder = true,
            Opened = false,
        })

        worldSection:AddToggle({
            Name = "Enable World ESP",
            Flag = "Vora Enable World ESP",
            Default = false,
            Callback = function(state)
                Vora_ESPState.WorldMasterESP = state
                if state then
                    Vora_RefreshESPRoots()
                    if Vora_AnyWorldEnabled() then Vora_StartWorldLoop() end
                else
                    Vora_ClearAllWorldESP()
                end
            end,
        })

        worldSection:AddDropdown({
            Name = "Select World Objects",
            Flag = "Vora Select World Objects",
            Values = { "Generators", "Hooks", "Gates", "Windows", "Pallets", "SCP / Zombie" },
            Multi = true,
            AllowNone = true,
            Default = {},
            Callback = function(selected)
                Vora_ESPState.GeneratorESP = Vora_Selected(selected, "Generators")
                Vora_ESPState.HookESP = Vora_Selected(selected, "Hooks")
                Vora_ESPState.GateESP = Vora_Selected(selected, "Gates")
                Vora_ESPState.WindowESP = Vora_Selected(selected, "Windows")
                Vora_ESPState.PalletESP = Vora_Selected(selected, "Pallets")
                Vora_ESPState.SCPZombieESP = Vora_Selected(selected, "SCP / Zombie")

                if Vora_ESPState.WorldMasterESP and Vora_AnyWorldEnabled() then
                    Vora_RefreshESPRoots()
                    Vora_StartWorldLoop()
                else
                    Vora_ClearAllWorldESP()
                end
            end,
        })

        worldSection:AddToggle({
            Name = "World Nametags",
            Flag = "Vora World Nametags",
            Default = false,
            Callback = function(state)
                Vora_ESPState.WorldNametags = state
                if Vora_ESPState.WorldMasterESP and Vora_AnyWorldEnabled() then Vora_StartWorldLoop() else Vora_ClearAllWorldESP() end
            end,
        })

        worldSection:AddToggle({
            Name = "World Distance ESP",
            Flag = "Vora World Distance ESP",
            Default = false,
            Callback = function(state)
                Vora_ESPState.WorldDistanceESP = state
                if Vora_ESPState.WorldMasterESP and Vora_AnyWorldEnabled() then Vora_StartWorldLoop() else Vora_ClearAllWorldESP() end
            end,
        })

        pcall(function() worldSection:AddDivider({ Text = "Colors" }) end)
        worldSection:AddColorPicker({ Name = "Generator Color", Flag = "Vora Generator Color", Default = Vora_ESPState.GeneratorColor, Callback = function(color) Vora_ESPState.GeneratorColor = color end })
        worldSection:AddColorPicker({ Name = "Hook Color", Flag = "Vora Hook Color", Default = Vora_ESPState.HookColor, Callback = function(color) Vora_ESPState.HookColor = color end })
        worldSection:AddColorPicker({ Name = "Gate Color", Flag = "Vora Gate Color", Default = Vora_ESPState.GateColor, Callback = function(color) Vora_ESPState.GateColor = color end })
        worldSection:AddColorPicker({ Name = "Window Color", Flag = "Vora Window Color", Default = Vora_ESPState.WindowColor, Callback = function(color) Vora_ESPState.WindowColor = color end })
        worldSection:AddColorPicker({ Name = "Pallet Color", Flag = "Vora Pallet Color", Default = Vora_ESPState.PalletColor, Callback = function(color) Vora_ESPState.PalletColor = color end })
        worldSection:AddColorPicker({ Name = "SCP / Zombie Color", Flag = "Vora SCP Zombie Color", Default = Vora_ESPState.SCPZombieColor, Callback = function(color) Vora_ESPState.SCPZombieColor = color end })
    end

    for _, player in ipairs(Players:GetPlayers()) do
        Vora_WatchPlayer(player)
    end

    table.insert(Vora_Connections, Players.PlayerAdded:Connect(Vora_WatchPlayer))
    table.insert(Vora_Connections, Players.PlayerRemoving:Connect(Vora_UnwatchPlayer))
    table.insert(Vora_Connections, Workspace.ChildAdded:Connect(function(child)
        if child.Name == "Map" or child.Name == "Map1" then
            Vora_AttachESPRoot(child)
            if Vora_ESPState.WorldMasterESP and Vora_AnyWorldEnabled() then Vora_StartWorldLoop() end
        end
    end))
    table.insert(Vora_Connections, Workspace.ChildRemoved:Connect(function(child)
        if child.Name == "Map" or child.Name == "Map1" then
            Vora_RefreshESPRoots()
        end
    end))

    Vora_RefreshESPRoots()

    getgenv().Vora_VD_VisualESP_Cleanup = function()
        Vora_Dead = true
        Vora_ClearAllPlayerESP()
        Vora_ClearAllWorldESP()

        for _, conn in ipairs(Vora_Connections) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
        for _, conns in pairs(Vora_PlayerConns) do
            for _, conn in ipairs(conns) do
                if conn then pcall(function() conn:Disconnect() end) end
            end
        end
        for _, conn in pairs(Vora_MapAdd) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
        for _, conn in pairs(Vora_MapRem) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
        if Vora_ESPFolder and Vora_ESPFolder.Parent then
            Vora_ESPFolder:Destroy()
        end
    end

    Vora_SafeNotify("Visual ESP", "Highlight ESP V2 loaded. Anti double nametag aktif.", 3)
end

-- FULLBRIGHT
task.spawn(function()
    while not VD.Destroyed do
        if VD.Fullbright then
            Lighting.Brightness     = 2
            Lighting.ClockTime      = 14
            Lighting.GlobalShadows  = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Lighting.FogStart       = 0
            Lighting.FogEnd         = 100000
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("Atmosphere") then
                    v.Density = 0; v.Offset = 0; v.Glare = 0; v.Haze = 0
                end
                if v:IsA("BlurEffect") then v.Size = 0 end
                if v:IsA("ColorCorrectionEffect") then v.Enabled = false end
                if v:IsA("SunRaysEffect") then v.Enabled = false end
            end
        else
            Lighting.Brightness     = originalLighting.Brightness
            Lighting.ClockTime      = originalLighting.ClockTime
            Lighting.FogEnd         = originalLighting.FogEnd
            Lighting.FogStart       = originalLighting.FogStart or 0
            Lighting.GlobalShadows  = originalLighting.GlobalShadows
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("Atmosphere") and originalLighting.Atmosphere then
                    v.Density = originalLighting.Atmosphere.Density or 0.3
                    v.Offset  = originalLighting.Atmosphere.Offset or 0.25
                    v.Glare   = originalLighting.Atmosphere.Glare or 0
                    v.Haze    = originalLighting.Atmosphere.Haze or 0
                end
                if v:IsA("BlurEffect") and originalLighting.Blur then v.Size = originalLighting.Blur.Size or 0 end
                if v:IsA("ColorCorrectionEffect") and originalLighting.ColorCorrection then
                    v.Enabled = originalLighting
                        .ColorCorrection.Enabled or false
                end
                if v:IsA("SunRaysEffect") and originalLighting.SunRays then
                    v.Enabled = originalLighting.SunRays.Enabled or
                        false
                end
            end
        end
        task.wait(0.5)
    end
end)

-- MOVEMENT & NOCLIP
local originalCanCollide = {}

RunService.Stepped:Connect(function()
    if VD.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, descendant in ipairs(char:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    if originalCanCollide[descendant] == nil then
                        originalCanCollide[descendant] = descendant.CanCollide
                    end
                    descendant.CanCollide = false
                end
            end
        end
    end
end)

getgenv().VD_DisableNoclip = function()
    for part, canCollide in pairs(originalCanCollide) do
        if part and part.Parent then
            pcall(function() part.CanCollide = canCollide end)
        end
    end
    originalCanCollide = {}
end

LocalPlayer.CharacterRemoving:Connect(function(char)
    if char == LocalPlayer.Character then
        originalCanCollide = {}
    end
end)

RunService.Heartbeat:Connect(function(deltaTime)
    local myChar = LocalPlayer.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if myHum then
        if VD.Speed and myHum.WalkSpeed ~= VD.SpeedValue then myHum.WalkSpeed = VD.SpeedValue end
        if VD.Jump and myHum.JumpPower ~= VD.JumpValue then myHum.JumpPower = VD.JumpValue end
    end

end)

UserInputService.JumpRequest:Connect(function()
    local myChar = LocalPlayer.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if VD.InfiniteJump and myHum then
        myHum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- HIDE SKILL CHECK UI
local cachedPlayerGui = LocalPlayer:WaitForChild("PlayerGui")
RunService.RenderStepped:Connect(function()
    if VD.HideSkillUI then
        if not cachedPlayerGui then cachedPlayerGui = LocalPlayer:FindFirstChild("PlayerGui") end
        local a = cachedPlayerGui and cachedPlayerGui:FindFirstChild("SkillCheckPromptGui")
        local b = cachedPlayerGui and cachedPlayerGui:FindFirstChild("SkillCheckPromptGui-con")
        if a and a.Enabled then a.Enabled = false end
        if b and b.Enabled then b.Enabled = false end
    end
end)

-- AUTO PARRY + AUTO SKILLCHECK (ported from survivor)
local function VD_Notify(title, content, duration)
    pcall(function()
        if Window and Window.Notify then
            Window:Notify({
                Title = title,
                Content = content,
                Duration = duration or 2,
                Icon = "lucide:info",
            })
        end
    end)
end

local VD_Parry = {
    PreciseDistanceEnabled = true,
    MaxDistance = 14,
    CanParry = true,
    IsParrying = false,
    CooldownEndTime = 0,
    KillerAnimator = nil,
    KillerChar = nil,
    KillerPlayer = nil,
    Connections = {},
    FiredTracks = {},
    RenderConnection = nil,
    LastStatus = "Off",
}

local VD_ParryAnimation = Instance.new("Animation")
VD_ParryAnimation.AnimationId = "rbxassetid://109133187196613"

local VD_ParryRange = Instance.new("CylinderHandleAdornment")
VD_ParryRange.Name = "Vora_ParryRange"
VD_ParryRange.Radius = VD.SURV_ParryDistance or 8
VD_ParryRange.InnerRadius = math.max(0.1, (VD.SURV_ParryDistance or 8) - 0.15)
VD_ParryRange.Height = 0.01
VD_ParryRange.Color3 = Color3.fromRGB(128, 128, 128)
VD_ParryRange.AlwaysOnTop = false
VD_ParryRange.Adornee = Workspace:FindFirstChildOfClass("Terrain")
VD_ParryRange.Transparency = 1
VD_ParryRange.Parent = GetSafeGuiParent()

local VD_ATTACK_ANIMS = {
    ["rbxassetid://113255068724446"] = true,
    ["rbxassetid://74968262036854"] = true,
    ["rbxassetid://110355011987939"] = true,
    ["rbxassetid://139369275981139"] = true,
    ["rbxassetid://132817836308238"] = true,
    ["rbxassetid://129784271201071"] = true,
    ["rbxassetid://133963973694098"] = true,
    ["rbxassetid://117042998468241"] = true,
    ["rbxassetid://105374834496520"] = true,
    ["rbxassetid://111920872708571"] = true,
    ["rbxassetid://78432063483146"] = true,
    ["rbxassetid://118907603246885"] = true,
    ["rbxassetid://138720291317243"] = true,
    ["rbxassetid://115244153053858"] = true,
    ["rbxassetid://130593238885843"] = true,
    ["rbxassetid://122812055447896"] = true,
    ["rbxassetid://78935059863801"] = true,
    ["rbxassetid://135002183282873"] = true,
    ["rbxassetid://121216847022485"] = true,
}

local function VD_UpdateParryRange()
    if not VD.SURV_ShowParryCircle or not VD.SURV_AutoParry then
        VD_ParryRange.Transparency = 1
        return
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        VD_ParryRange.Transparency = 1
        return
    end

    local currentMaxDist = VD_Parry.PreciseDistanceEnabled and (VD.SURV_ParryDistance or 8) or VD_Parry.MaxDistance
    VD_ParryRange.Transparency = 0.4
    VD_ParryRange.Radius = currentMaxDist
    VD_ParryRange.InnerRadius = math.max(0.1, currentMaxDist - 0.15)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { char }
    params.FilterType = Enum.RaycastFilterType.Exclude

    local ray = Workspace:Raycast(root.Position, Vector3.new(0, -15, 0), params)
    local groundPos = ray and ray.Position or (root.Position - Vector3.new(0, 3, 0))
    VD_ParryRange.CFrame = CFrame.new(groundPos + Vector3.new(0, 0.05, 0)) * CFrame.Angles(math.pi / 2, 0, 0)
end

local function VD_GetParryRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local items = remotes and remotes:FindFirstChild("Items")
    local dagger = items and items:FindFirstChild("Parrying Dagger")
    return dagger and dagger:FindFirstChild("parry")
end

local function VD_RefreshLocalCombatCache()
    local char = LocalPlayer.Character
    Root = char and char:FindFirstChild("HumanoidRootPart") or Root
    Humanoid = char and char:FindFirstChildOfClass("Humanoid") or Humanoid
end

local function VD_KillerLookingAtMe()
    if not VD_Parry.KillerChar or not Root then return true end
    local killerRoot = VD_Parry.KillerChar:FindFirstChild("HumanoidRootPart")
    if not killerRoot then return true end
    local delta = Root.Position - killerRoot.Position
    if delta.Magnitude <= 0.01 then return true end
    return killerRoot.CFrame.LookVector:Dot(delta.Unit) > 0.6
end

local function VD_PlayParryAnimation()
    if not Humanoid then return end
    pcall(function()
        local anim = Humanoid:LoadAnimation(VD_ParryAnimation)
        anim:Play()
    end)
end

local function VD_FaceKillerForDuration(duration)
    local enemyRoot = VD_Parry.KillerChar and VD_Parry.KillerChar:FindFirstChild("HumanoidRootPart")
    if not enemyRoot or not Root then return end
    local startTime = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if tick() - startTime >= duration or not enemyRoot.Parent or not Root then
            if conn then conn:Disconnect() end
            return
        end
        local targetPos = enemyRoot.Position
        local myPos = Root.Position
        local flatTarget = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)
        if (flatTarget - myPos).Magnitude > 0.01 then
            Root.CFrame = CFrame.lookAt(myPos, flatTarget)
        end
        if Camera then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
        end
    end)
end

local function VD_DoParry(track, bypassThreshold)
    if not VD_Parry.CanParry or not VD.SURV_AutoParry or VD_Parry.IsParrying then return false end
    if not Root then VD_RefreshLocalCombatCache() end
    if not Root then return false end

    local enemyRoot = VD_Parry.KillerChar and VD_Parry.KillerChar:FindFirstChild("HumanoidRootPart")
    if not enemyRoot then return false end

    local allowedDistance = VD_Parry.PreciseDistanceEnabled and (VD.SURV_ParryDistance or 8) or VD_Parry.MaxDistance
    if (enemyRoot.Position - Root.Position).Magnitude > allowedDistance then return false end
    if not VD_KillerLookingAtMe() then return false end

    if track then
        if VD_Parry.FiredTracks[track] then return false end
        if not bypassThreshold and track.TimePosition > 0.05 then return false end
        VD_Parry.FiredTracks[track] = true
        pcall(function()
            track.Stopped:Once(function()
                VD_Parry.FiredTracks[track] = nil
            end)
        end)
    end

    local parryRemote = VD_GetParryRemote()
    if not parryRemote then return false end

    VD_Parry.CanParry = false
    VD_Parry.IsParrying = true
    VD_FaceKillerForDuration(1)
    pcall(function() parryRemote:FireServer() end)
    VD_PlayParryAnimation()
    if Humanoid then
        local originalSpeed = Humanoid.WalkSpeed > 0 and Humanoid.WalkSpeed or 16
        Humanoid.WalkSpeed = 0
        task.delay(1, function()
            if Humanoid then Humanoid.WalkSpeed = originalSpeed end
        end)
    end

    VD_Parry.CooldownEndTime = tick() + 80
    task.delay(2, function() VD_Parry.IsParrying = false end)
    task.delay(80, function() VD_Parry.CanParry = true end)
    return true
end

local function VD_ResetKillerHook()
    for _, conn in ipairs(VD_Parry.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    VD_Parry.Connections = {}
    VD_Parry.KillerAnimator = nil
    VD_Parry.KillerChar = nil
    VD_Parry.KillerPlayer = nil
    VD_Parry.FiredTracks = {}
end

local function VD_GetKillerPlayer()
    local killerTeam = Teams:FindFirstChild("Killer")
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and ((killerTeam and player.Team == killerTeam) or (player.Team and player.Team.Name == "Killer")) then
            return player
        end
    end
    return nil
end

local function VD_OnKillerTrack(track)
    local anim = track and track.Animation
    if anim and VD_ATTACK_ANIMS[anim.AnimationId] and not VD_Parry.PreciseDistanceEnabled then
        VD_DoParry(track, false)
    end
end

local function VD_HookKiller()
    if not VD.SURV_AutoParry then return false end
    local killer = VD_GetKillerPlayer()
    if not killer then
        VD_ResetKillerHook()
        return false
    end
    if VD_Parry.KillerPlayer == killer and VD_Parry.KillerAnimator then return true end

    VD_ResetKillerHook()
    VD_Parry.KillerPlayer = killer
    VD_Parry.KillerChar = killer.Character
    if not VD_Parry.KillerChar then return false end
    local hum = VD_Parry.KillerChar and VD_Parry.KillerChar:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if not animator then return false end

    VD_Parry.KillerAnimator = animator
    table.insert(VD_Parry.Connections, animator.AnimationPlayed:Connect(VD_OnKillerTrack))
    return true
end

local function VD_QuickCheckParry()
    if not VD.SURV_AutoParry or not VD_Parry.CanParry or VD_Parry.IsParrying then return false end
    if not VD_Parry.KillerAnimator or not VD_Parry.KillerChar then return false end
    if not Root then VD_RefreshLocalCombatCache() end
    if not Root then return false end

    local enemyRoot = VD_Parry.KillerChar:FindFirstChild("HumanoidRootPart")
    if not enemyRoot then return false end
    local distance = (enemyRoot.Position - Root.Position).Magnitude

    for _, track in ipairs(VD_Parry.KillerAnimator:GetPlayingAnimationTracks()) do
        local anim = track.Animation
        if anim and VD_ATTACK_ANIMS[anim.AnimationId] then
            if VD_Parry.PreciseDistanceEnabled then
                if distance <= (VD.SURV_ParryDistance or 8) then
                    return VD_DoParry(track, true)
                end
            elseif not VD_Parry.FiredTracks[track] and track.TimePosition <= 0.05 then
                return VD_DoParry(track, false)
            end
        end
    end
    return false
end

local function VD_SetAutoParry(state)
    VD.SURV_AutoParry = state == true
    if VD.SURV_AutoParry then
        VD_RefreshLocalCombatCache()
        VD_HookKiller()
        VD_Parry.CanParry = true
        VD_Parry.IsParrying = false
        VD_Parry.CooldownEndTime = 0
        VD_Parry.LastStatus = ""
        if not VD_Parry.RenderConnection then
            VD_Parry.RenderConnection = RunService.RenderStepped:Connect(function()
                VD_UpdateParryRange()
                if not VD.SURV_AutoParry then return end
                if not VD_Parry.KillerAnimator then VD_HookKiller() end
                VD_QuickCheckParry()
            end)
        end
        VD_Notify("Auto Parry", "Enabled", 2)
    else
        VD_ResetKillerHook()
        VD_Parry.CanParry = false
        VD_Parry.IsParrying = false
        VD_Parry.CooldownEndTime = 0
        VD_ParryRange.Transparency = 1
        if VD_Parry.RenderConnection then
            VD_Parry.RenderConnection:Disconnect()
            VD_Parry.RenderConnection = nil
        end
        VD_Notify("Auto Parry", "Disabled", 2)
    end
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local AutoSkill = {
    LastGoalRotation = nil,
    HasClickedThisGoal = false,
    LastLineRotation = nil,
    LastTick = nil,
    WasActive = false,
    PerfectLastGoalRotation = nil,
    PerfectHasClickedThisGoal = false,
    PerfectLastLineRotation = nil,
    PerfectLastTick = nil,
    PerfectWasActive = false,
    InstantLastTriggerTick = 0,
    InstantLastGoalRotation = 0,
    InstantLastGoalInstance = nil,
    InstantCurrentGoalID = 0,
    InstantHasClicked = false,
    InstantForcingRotation = false,
    InstantRotationConnection = nil,
}

local function VD_PressSkill()
    if isMobile then
        local btn = PlayerGui:FindFirstChild("check", true)
        if btn and btn:IsA("GuiObject") then
            local pos = btn.AbsolutePosition
            local size = btn.AbsoluteSize
            local inset = GuiService:GetGuiInset()
            local x = pos.X + (size.X / 2) + inset.X
            local y = pos.Y + (size.Y / 2) + inset.Y
            pcall(function() VirtualInputManager:SendTouchEvent(8822, Enum.UserInputState.Begin.Value, x, y) end)
            task.wait(0.01)
            pcall(function() VirtualInputManager:SendTouchEvent(8822, Enum.UserInputState.End.Value, x, y) end)
            pcall(function()
                if firesignal and btn.MouseButton1Click then
                    firesignal(btn.MouseButton1Click)
                end
            end)
        end
    else
        pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game) end)
        task.wait(0.01)
        pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
    end
end

local function VD_GetSkillCheck()
    for _, guiName in ipairs({ "SkillCheckPromptGui", "SkillCheckPromptGui-con" }) do
        local gui = PlayerGui:FindFirstChild(guiName, true)
        if gui then
            local check = gui:FindFirstChild("Check", true)
            if check and check.Visible then
                local line = check:FindFirstChild("Line", true)
                local goal = check:FindFirstChild("Goal", true)
                if line and goal then return line, goal end
            end
        end
    end
end

local function VD_AngularDelta(from, to)
    local d = to - from
    if d > 180 then d = d - 360 end
    if d < -180 then d = d + 360 end
    return d
end

local function VD_CrossedZone(prevLr, lr, startPos, endPos)
    local function inZone(r)
        if startPos > endPos then
            return r >= startPos or r <= endPos
        end
        return r >= startPos and r <= endPos
    end
    if inZone(lr) then return true end
    if prevLr == nil then return false end
    local delta = VD_AngularDelta(prevLr, lr)
    local steps = math.abs(math.floor(delta))
    if steps < 2 then return false end
    local stepSize = delta / steps
    for i = 1, steps do
        if inZone((prevLr + stepSize * i) % 360) then return true end
    end
    return false
end

local function VD_NormalSkillcheckUpdate()
    local line, goal = VD_GetSkillCheck()
    if not (line and goal) then
        AutoSkill.LastGoalRotation = nil
        AutoSkill.HasClickedThisGoal = false
        AutoSkill.LastLineRotation = nil
        AutoSkill.LastTick = nil
        AutoSkill.WasActive = false
        return
    end

    local lr = line.Rotation % 360
    local gr = goal.Rotation % 360
    local now = os.clock()
    if not AutoSkill.WasActive then
        AutoSkill.WasActive = true
        AutoSkill.HasClickedThisGoal = false
        AutoSkill.LastGoalRotation = gr
        AutoSkill.LastLineRotation = lr
        AutoSkill.LastTick = now
        return
    end
    if AutoSkill.LastGoalRotation and math.abs(VD_AngularDelta(AutoSkill.LastGoalRotation, gr)) > 5 then
        AutoSkill.HasClickedThisGoal = false
        AutoSkill.LastLineRotation = nil
        AutoSkill.LastTick = nil
    end
    AutoSkill.LastGoalRotation = gr
    if AutoSkill.HasClickedThisGoal then
        AutoSkill.LastLineRotation = lr
        AutoSkill.LastTick = now
        return
    end
    if AutoSkill.LastLineRotation and AutoSkill.LastTick then
        local dt = now - AutoSkill.LastTick
        if dt > 0 then
            local lineSpeed = VD_AngularDelta(AutoSkill.LastLineRotation, lr) / dt
            local predicted = (lr + lineSpeed * dt * 0) % 360
            if VD_CrossedZone(AutoSkill.LastLineRotation, predicted, (gr + 104) % 360, (gr + 109) % 360) then
                AutoSkill.HasClickedThisGoal = true
                task.spawn(function()
                    task.wait(0.03)
                    VD_PressSkill()
                end)
            end
        end
    end
    AutoSkill.LastLineRotation = lr
    AutoSkill.LastTick = now
end

local function VD_PerfectSkillcheckUpdate()
    local line, goal = VD_GetSkillCheck()
    if not (line and goal) then
        AutoSkill.PerfectLastGoalRotation = nil
        AutoSkill.PerfectHasClickedThisGoal = false
        AutoSkill.PerfectLastLineRotation = nil
        AutoSkill.PerfectLastTick = nil
        AutoSkill.PerfectWasActive = false
        return
    end

    local lr = line.Rotation % 360
    local gr = goal.Rotation % 360
    local now = os.clock()
    if not AutoSkill.PerfectWasActive then
        AutoSkill.PerfectWasActive = true
        AutoSkill.PerfectHasClickedThisGoal = false
        AutoSkill.PerfectLastGoalRotation = gr
        AutoSkill.PerfectLastLineRotation = lr
        AutoSkill.PerfectLastTick = now
        return
    end
    if AutoSkill.PerfectLastGoalRotation and math.abs(VD_AngularDelta(AutoSkill.PerfectLastGoalRotation, gr)) > 5 then
        AutoSkill.PerfectHasClickedThisGoal = false
        AutoSkill.PerfectLastLineRotation = nil
        AutoSkill.PerfectLastTick = nil
    end
    AutoSkill.PerfectLastGoalRotation = gr
    if AutoSkill.PerfectHasClickedThisGoal then
        AutoSkill.PerfectLastLineRotation = lr
        AutoSkill.PerfectLastTick = now
        return
    end
    if AutoSkill.PerfectLastLineRotation and AutoSkill.PerfectLastTick then
        local dt = now - AutoSkill.PerfectLastTick
        if dt > 0 then
            local lineSpeed = VD_AngularDelta(AutoSkill.PerfectLastLineRotation, lr) / dt
            local predicted = (lr + lineSpeed * dt * 0) % 360
            if VD_CrossedZone(AutoSkill.PerfectLastLineRotation, predicted, (gr + 104) % 360, (gr + 108) % 360) then
                AutoSkill.PerfectHasClickedThisGoal = true
                VD_PressSkill()
            end
        end
    end
    AutoSkill.PerfectLastLineRotation = lr
    AutoSkill.PerfectLastTick = now
end

local function VD_InstantSkillcheckUpdate()
    local line, goal = VD_GetSkillCheck()
    if not (line and goal) then
        AutoSkill.InstantHasClicked = false
        AutoSkill.InstantLastGoalRotation = 0
        AutoSkill.InstantLastGoalInstance = nil
        AutoSkill.InstantCurrentGoalID = 0
        if AutoSkill.InstantRotationConnection then
            AutoSkill.InstantRotationConnection:Disconnect()
            AutoSkill.InstantRotationConnection = nil
        end
        return
    end

    local gr = goal.Rotation % 360
    local perfectRot = (gr + 106) % 360
    if not AutoSkill.InstantForcingRotation then
        AutoSkill.InstantForcingRotation = true
        pcall(function() line.Rotation = perfectRot end)
        AutoSkill.InstantForcingRotation = false
    end

    local diff = math.abs(gr - AutoSkill.InstantLastGoalRotation)
    if diff > 180 then diff = 360 - diff end
    local isNewGoal = diff > 0.5 or AutoSkill.InstantLastGoalInstance ~= goal
    if isNewGoal then
        AutoSkill.InstantHasClicked = false
        AutoSkill.InstantCurrentGoalID = AutoSkill.InstantCurrentGoalID + 1
        local assignedID = AutoSkill.InstantCurrentGoalID
        if AutoSkill.InstantRotationConnection then AutoSkill.InstantRotationConnection:Disconnect() end
        AutoSkill.InstantRotationConnection = line:GetPropertyChangedSignal("Rotation"):Connect(function()
            if AutoSkill.InstantForcingRotation then return end
            AutoSkill.InstantForcingRotation = true
            pcall(function()
                local _, cGoal = VD_GetSkillCheck()
                if cGoal then line.Rotation = (cGoal.Rotation % 360 + 106) % 360 end
            end)
            AutoSkill.InstantForcingRotation = false
        end)
        if not AutoSkill.InstantHasClicked then
            AutoSkill.InstantHasClicked = true
            task.spawn(function()
                task.wait(0.05)
                if AutoSkill.InstantCurrentGoalID == assignedID then
                    local cl, cg = VD_GetSkillCheck()
                    if cl and cg and tick() - AutoSkill.InstantLastTriggerTick > 0.03 then
                        AutoSkill.InstantLastTriggerTick = tick()
                        VD_PressSkill()
                    end
                end
            end)
        end
    end
    AutoSkill.InstantLastGoalRotation = gr
    AutoSkill.InstantLastGoalInstance = goal
end

RunService.RenderStepped:Connect(function()
    if not VD.AutoSkillcheck then return end
    if VD.AutoSkillcheckMode == "Perfect" then
        VD_PerfectSkillcheckUpdate()
    elseif VD.AutoSkillcheckMode == "Instant" then
        VD_InstantSkillcheckUpdate()
    else
        VD_NormalSkillcheckUpdate()
    end
end)

local function VD_SetAutoSkillcheck(state)
    VD.AutoSkillcheck = state == true
    if not VD.AutoSkillcheck then
        if AutoSkill.InstantRotationConnection then
            AutoSkill.InstantRotationConnection:Disconnect()
            AutoSkill.InstantRotationConnection = nil
        end
        AutoSkill.InstantHasClicked = false
        AutoSkill.WasActive = false
        AutoSkill.PerfectWasActive = false
        VD_Notify("Auto Skillcheck", "Disabled", 2)
    else
        VD_Notify("Auto Skillcheck", "Enabled (" .. tostring(VD.AutoSkillcheckMode or "Normal") .. " Mode)", 2)
    end
end

-- INSTANT HEAL & AUTO HEAL ALL
InstantHealSelf = false
AutoHealAll = false
AutoHealAllConnection = nil
InstantHealConnection = nil

function doSelfHeal()
	local char = LocalPlayer.Character
	if not char then return end
	local skillCheckRemote = ReplicatedStorage.Remotes.Healing.SkillCheckResultEvent
	pcall(function() skillCheckRemote:FireServer("success", 100, char) end)
end

function doSelfHealTrue()
	local char = LocalPlayer.Character
	if not char then return end
	local healRemote = ReplicatedStorage.Remotes.Healing.HealEvent
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	pcall(function() healRemote:FireServer(hrp, true) end)
end

function doSelfHealFalse()
	local char = LocalPlayer.Character
	if not char then return end
	local healRemote = ReplicatedStorage.Remotes.Healing.HealEvent
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	pcall(function() healRemote:FireServer(hrp, false) end)
end

function doOthersHealSkillCheck(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return end
	local skillCheckRemote = ReplicatedStorage.Remotes.Healing.SkillCheckResultEvent
	pcall(function() skillCheckRemote:FireServer("success", 100, targetPlayer.Character) end)
end

function doOthersHealTrue(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return end
	local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not targetHRP then return end
	local healRemote = ReplicatedStorage.Remotes.Healing.HealEvent
	pcall(function() healRemote:FireServer(targetHRP, true) end)
end

function doOthersHealFalse(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return end
	local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not targetHRP then return end
	local healRemote = ReplicatedStorage.Remotes.Healing.HealEvent
	pcall(function() healRemote:FireServer(targetHRP, false) end)
end

function setInstantHealSelf(v)
    InstantHealSelf = v
    if v then
        local skillCheckTimer = 0
		local healTrueTimer = 0
		local healFalseTimer = 0
		local healTrueActive = false
        if InstantHealConnection then InstantHealConnection:Disconnect() end
        InstantHealConnection = RunService.Heartbeat:Connect(function(dt)
            if not InstantHealSelf then return end
            local myChar = LocalPlayer.Character
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            if not myHum or myHum.Health >= myHum.MaxHealth * 0.9 then return end
            skillCheckTimer = skillCheckTimer + dt
			if skillCheckTimer >= 0.05 then skillCheckTimer = 0; doSelfHeal() end
			healTrueTimer = healTrueTimer + dt
			if healTrueTimer >= 0.06 and not healTrueActive then
				healTrueTimer = 0; healTrueActive = true; doSelfHealTrue()
			end
			healFalseTimer = healFalseTimer + dt
			if healFalseTimer >= 0.09 and healTrueActive then
				healFalseTimer = 0; healTrueActive = false; doSelfHealFalse(); healTrueTimer = -0.10
			end
        end)
    else
        if InstantHealConnection then InstantHealConnection:Disconnect(); InstantHealConnection = nil end
    end
end

function setAutoHealAll(v)
    AutoHealAll = v
    if v then
        local timers = {}
        if AutoHealAllConnection then AutoHealAllConnection:Disconnect() end
        AutoHealAllConnection = RunService.Heartbeat:Connect(function(dt)
            if not AutoHealAll then return end
            for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					local hrp = player.Character:FindFirstChild("HumanoidRootPart")
					local hum = player.Character:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 and hum.Health < hum.MaxHealth * 0.9 then
						if not timers[player] then
							timers[player] = {sc = 0, t = 0, f = 0, active = false}
						end
						local tm = timers[player]
						tm.sc = tm.sc + dt
						if tm.sc >= 0.05 then tm.sc = 0; doOthersHealSkillCheck(player) end
						tm.t = tm.t + dt
						if tm.t >= 0.09 and not tm.active then
							tm.t = 0; tm.active = true; doOthersHealTrue(player)
						end
						tm.f = tm.f + dt
						if tm.f >= 0.07 and tm.active then
							tm.f = 0; tm.active = false; doOthersHealFalse(player); tm.t = -0.10
						end
					else
						timers[player] = nil
					end
				end
			end
        end)
    else
        if AutoHealAllConnection then AutoHealAllConnection:Disconnect(); AutoHealAllConnection = nil end
    end
end

-- GEN BOOST BYPASS
GenBypass = {
    Enabled     = false,
    Button      = nil,
    UI          = nil,
    Cache       = {},
    CacheTimer  = 0,
    Processed   = {},
    HotkeyCode  = Enum.KeyCode.G,
}

function GB_GetAllGenerators()
    local now = tick()
    if now - GenBypass.CacheTimer < 5 then return GenBypass.Cache end
    GenBypass.Cache = {}
    GenBypass.CacheTimer = now
    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return GenBypass.Cache end
    pcall(function()
        for _, v in pairs(mapFolder:GetDescendants()) do
            if not v:IsA("Model") then continue end
            if v.Name ~= "Generator" then continue end
            local isReal = v:GetAttribute("RepairProgress") ~= nil
                or v:GetAttribute("kickcount") ~= nil
                or v:GetAttribute("ProgressRepair") ~= nil
            if isReal then table.insert(GenBypass.Cache, v) end
        end
    end)
    return GenBypass.Cache
end

function GB_GetPoints(genModel)
    local points = {}
    pcall(function()
        for _, obj in pairs(genModel:GetChildren()) do
            if obj.Name:find("GeneratorPoint") and obj:IsA("BasePart") then
                table.insert(points, obj)
            end
        end
    end)
    return points
end

function GB_WaitRepairing(point, timeout)
    local start = tick()
    while tick() - start < (timeout or 1) do
        if point:GetAttribute("IsRepairing") == true then return true end
        task.wait(0.05)
    end
    return false
end

function GB_DoRepair(targetPoint)
    local genModel = targetPoint.Parent
    if GenBypass.Processed[genModel] then return end
    GenBypass.Processed[genModel] = true

    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then GenBypass.Processed[genModel] = nil return end

    local RepairEvent = ReplicatedStorage:FindFirstChild("Remotes")
        and ReplicatedStorage.Remotes:FindFirstChild("Generator")
        and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")

    local originalCFrame = hrp.CFrame
    pcall(function()
        for _, point in pairs(GB_GetPoints(genModel)) do
            if point ~= targetPoint and point.Parent then
                hrp.Anchored = true
                hrp.CFrame = point.CFrame
                task.wait(0.15)
                pcall(function() if RepairEvent then RepairEvent:FireServer(point, true) end end)
                if not GB_WaitRepairing(point, 0.8) then
                    pcall(function() if RepairEvent then RepairEvent:FireServer(point, false) end end)
                    task.wait(0.1)
                    hrp.CFrame = point.CFrame
                    task.wait(0.15)
                    pcall(function() if RepairEvent then RepairEvent:FireServer(point, true) end end)
                    GB_WaitRepairing(point, 0.5)
                end
                hrp.Anchored = false
                task.wait(0.05)
            end
        end
    end)
    pcall(function()
        if hrp and hrp.Parent then
            hrp.Anchored = false
            hrp.CFrame = originalCFrame
        end
    end)
    task.wait(0.1)
    pcall(function() if RepairEvent then RepairEvent:FireServer(targetPoint, false) end end)
end

function GB_GetNearestPoint()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local bestPoint, bestDist = nil, math.huge
    for _, gen in pairs(GB_GetAllGenerators()) do
        for _, point in pairs(GB_GetPoints(gen)) do
            local d = (hrp.Position - point.Position).Magnitude
            if d < bestDist then bestDist = d; bestPoint = point end
        end
    end
    return bestPoint, bestDist
end

function GB_IsPromptVisible()
    local ok, frame = pcall(function()
        return LocalPlayer.PlayerGui.pcprompts.Frame.GeneratorRepair
    end)
    return ok and frame and frame.Visible
end

function GB_UpdateButton()
    if GenBypass.Button then
        GenBypass.Button.Visible = GenBypass.Enabled and isMobile
    end
end

function GB_CreateButton()
    local oldUI = LocalPlayer.PlayerGui:FindFirstChild("BypassGenUI")
    if oldUI then oldUI:Destroy() end

    GenBypass.UI = Instance.new("ScreenGui")
    GenBypass.UI.Name = "BypassGenUI"
    GenBypass.UI.ResetOnSpawn = false
    GenBypass.UI.IgnoreGuiInset = true
    GenBypass.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")

    GenBypass.Button = Instance.new("ImageButton")
    GenBypass.Button.Name = "BypassGenButton"
    GenBypass.Button.Size = UDim2.new(0, 60, 0, 60)
    GenBypass.Button.Position = UDim2.new(0.88, 0, 0.55, 0)
    GenBypass.Button.AnchorPoint = Vector2.new(0.5, 0.5)
    GenBypass.Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GenBypass.Button.BackgroundTransparency = 0.15
    GenBypass.Button.AutoButtonColor = true
    GenBypass.Button.Visible = false
    GenBypass.Button.ZIndex = 10
    GenBypass.Button.Parent = GenBypass.UI
    Instance.new("UICorner", GenBypass.Button).CornerRadius = UDim.new(1, 0)
    
    local s = Instance.new("UIStroke", GenBypass.Button)
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Thickness = 2; s.Transparency = 0.2
    
    local lbl = Instance.new("TextLabel", GenBypass.Button)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "BYPASS"
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBlack
    lbl.ZIndex = 11

    local function applyShine(obj, baseColor)
        local grad = Instance.new("UIGradient", obj)
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, baseColor),
            ColorSequenceKeypoint.new(0.4, baseColor),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.6, baseColor),
            ColorSequenceKeypoint.new(1, baseColor)
        })
        grad.Rotation = 45
        grad.Offset = Vector2.new(-1, -1)
        
        task.spawn(function()
            local TweenService = game:GetService("TweenService")
            local ti = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
            local tw = TweenService:Create(grad, ti, { Offset = Vector2.new(1, 1) })
            tw:Play()
        end)
    end
    
    applyShine(GenBypass.Button, Color3.fromRGB(20, 0, 30))
    applyShine(lbl, Color3.fromRGB(255, 0, 255))
    applyShine(s, Color3.fromRGB(255, 0, 255))

    GenBypass.Button.MouseButton1Click:Connect(function()
        if not GenBypass.Enabled then return end
        local bestPoint, bestDist = GB_GetNearestPoint()
        if bestPoint and bestDist <= 8 then GB_DoRepair(bestPoint) end
    end)
end

GB_CreateButton()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    GB_CreateButton()
    GB_UpdateButton()
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if isMobile then return end
    if input.KeyCode == GenBypass.HotkeyCode and GenBypass.Enabled then
        if not GB_IsPromptVisible() then return end
        local bestPoint, bestDist = GB_GetNearestPoint()
        if not bestPoint or bestDist > 8 then return end
        if GenBypass.Processed[bestPoint.Parent] then return end
        GB_DoRepair(bestPoint)
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not GenBypass.Enabled then return end
    if not GB_IsPromptVisible() then return end
    local bestPoint, bestDist = GB_GetNearestPoint()
    if not bestPoint or bestDist > 8 then return end
    if GenBypass.Processed[bestPoint.Parent] then return end
    GB_DoRepair(bestPoint)
end)

task.spawn(function()
    while true do
        task.wait(2)
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for genModel in pairs(GenBypass.Processed) do
                if not genModel or not genModel.Parent then
                    GenBypass.Processed[genModel] = nil
                    continue
                end
                local nearAny = false
                for _, point in pairs(GB_GetPoints(genModel)) do
                    if point.Parent and (hrp.Position - point.Position).Magnitude <= 10 then
                        nearAny = true; break
                    end
                end
                if not nearAny then GenBypass.Processed[genModel] = nil end
            end
        end
    end
end)

function setGenBypass(v)
    GenBypass.Enabled = v
    GB_UpdateButton()
end

function setAutoCrouch(v)
    VD.AutoCrouch = v
    if v then
        task.spawn(function()
            while VD.AutoCrouch do
                pcall(function()
                    ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer("Crouchingserver", true)
                end)
                task.wait(0.20)
            end
        end)
    end
end

-- INF GRAB (MYERS)
MyersGrabData = {
    Enabled = false,
    UI = nil,
    Button = nil,
    DragLocked = false,
    Dragging = false,
    DragStart = nil,
    DragStartPos = nil,
    HotkeyCode = Enum.KeyCode.H,
}

function getMyersTarget()
    local char = LocalPlayer.Character
    if not char then return nil end
    local myHRP = char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local candidates = {}
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                table.insert(candidates, {
                    player = player,
                    dist   = (hrp.Position - myHRP.Position).Magnitude,
                    health = hum.Health
                })
            end
        end
    end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    for _, c in ipairs(candidates) do
        return c.player
    end
    return nil
end

function doMyersGrab()
    if not MyersGrabData.Enabled then return end
    local target = getMyersTarget()
    if not target or not target.Character then return end
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        ReplicatedStorage.Remotes.Killers.Stalker.grab:FireServer(target.Character)
    end)
end

function setupMyersGrabBtn()
    local oldUI = LocalPlayer.PlayerGui:FindFirstChild("MyersGrabUI")
    if oldUI then oldUI:Destroy() end

    MyersGrabData.UI = Instance.new("ScreenGui")
    MyersGrabData.UI.Name = "MyersGrabUI"
    MyersGrabData.UI.ResetOnSpawn = false
    MyersGrabData.UI.IgnoreGuiInset = true
    MyersGrabData.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")

    MyersGrabData.Button = Instance.new("ImageButton")
    MyersGrabData.Button.Name = "MyersGrabButton"
    MyersGrabData.Button.Size = UDim2.new(0, 60, 0, 60)
    MyersGrabData.Button.Position = UDim2.new(0.7, 0, 0.75, 0)
    MyersGrabData.Button.AnchorPoint = Vector2.new(0.5, 0.5)
    MyersGrabData.Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MyersGrabData.Button.BackgroundTransparency = 0.15
    MyersGrabData.Button.AutoButtonColor = true
    MyersGrabData.Button.Visible = false
    MyersGrabData.Button.ZIndex = 10
    MyersGrabData.Button.Parent = MyersGrabData.UI
    Instance.new("UICorner", MyersGrabData.Button).CornerRadius = UDim.new(1, 0)
    
    local s = Instance.new("UIStroke", MyersGrabData.Button)
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Thickness = 2; s.Transparency = 0.2
    
    local lbl = Instance.new("TextLabel", MyersGrabData.Button)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "GRAB"
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBlack
    lbl.ZIndex = 11

    local function applyShine(obj, baseColor)
        local grad = Instance.new("UIGradient", obj)
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, baseColor),
            ColorSequenceKeypoint.new(0.4, baseColor),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.6, baseColor),
            ColorSequenceKeypoint.new(1, baseColor)
        })
        grad.Rotation = 45
        grad.Offset = Vector2.new(-1, -1)
        
        task.spawn(function()
            local TweenService = game:GetService("TweenService")
            local ti = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
            local tw = TweenService:Create(grad, ti, { Offset = Vector2.new(1, 1) })
            tw:Play()
        end)
    end
    
    applyShine(MyersGrabData.Button, Color3.fromRGB(20, 0, 30))
    applyShine(lbl, Color3.fromRGB(255, 0, 255))
    applyShine(s, Color3.fromRGB(255, 0, 255))

    MyersGrabData.Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if MyersGrabData.DragLocked then return end
            MyersGrabData.Dragging = true
            MyersGrabData.DragStart = input.Position
            MyersGrabData.DragStartPos = MyersGrabData.Button.Position
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if MyersGrabData.Dragging and not MyersGrabData.DragLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - MyersGrabData.DragStart
            MyersGrabData.Button.Position = UDim2.new(
                MyersGrabData.DragStartPos.X.Scale, MyersGrabData.DragStartPos.X.Offset + delta.X, 
                MyersGrabData.DragStartPos.Y.Scale, MyersGrabData.DragStartPos.Y.Offset + delta.Y
            )
        end
    end)

    MyersGrabData.Button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            MyersGrabData.Dragging = false
        end
    end)

    MyersGrabData.Button.MouseButton1Click:Connect(doMyersGrab)
end

setupMyersGrabBtn()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    setupMyersGrabBtn()
    if MyersGrabData.Button then
        MyersGrabData.Button.Visible = MyersGrabData.Enabled
    end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == MyersGrabData.HotkeyCode and MyersGrabData.Enabled then
        doMyersGrab()
    end
end)

function setMyersGrab(v)
    MyersGrabData.Enabled = v
    if MyersGrabData.Button then
        MyersGrabData.Button.Visible = v
    end
end

function setMyersDragLocked(v)
    MyersGrabData.DragLocked = v
end

-- VEIL AIMBOT (PREDICTION)
VeilConfig = {
    Enabled              = false,
    ShowFOV              = true,
    FOV                  = 150,
    SpearSpeed           = 165,
    Gravity              = workspace.Gravity * 0.5,
    MaxDist              = 200,
    AutoPredict          = false,
    TargetPart           = "Torso",
    HorizontalPredictFactor = 2.8,
}

VeilState = {
    chargingSpear    = false,
    touchInput       = nil,
    attackCooldown   = false,
    passiveCooldown  = false,
    remoteHooked     = false,
    lastPredictedPos = nil,
}

VeilVelocityCache = {}

VeilDraw = {
    FOVCircle = Drawing.new("Circle"),
    Highlight = Instance.new("Highlight"),
    Tracer    = Drawing.new("Circle"),
}

VeilDraw.FOVCircle.Color     = Color3.fromRGB(255, 0, 255)
VeilDraw.FOVCircle.Thickness = 1.5
VeilDraw.FOVCircle.Filled    = false
VeilDraw.FOVCircle.Visible   = false

VeilDraw.Highlight.Name                = "VD_VeilTarget"
VeilDraw.Highlight.FillColor           = Color3.fromRGB(255, 0, 0)
VeilDraw.Highlight.OutlineColor        = Color3.fromRGB(255, 255, 255)
VeilDraw.Highlight.FillTransparency    = 0.5
VeilDraw.Highlight.OutlineTransparency = 0

VeilDraw.Tracer.Thickness = 2
VeilDraw.Tracer.Radius    = 5
VeilDraw.Tracer.Color     = Color3.fromRGB(255, 0, 255)
VeilDraw.Tracer.Filled    = true
VeilDraw.Tracer.Visible   = false

function Veil_GetRealVelocity(part, playerName)
    if not part then return Vector3.zero end
    local currentPos = part.Position
    local currentTime = tick()
    if not VeilVelocityCache[playerName] then
        VeilVelocityCache[playerName] = {lastPos = currentPos, lastTime = currentTime, velocity = Vector3.zero}
        return Vector3.zero
    end
    local cache = VeilVelocityCache[playerName]
    local dt = currentTime - cache.lastTime
    if dt > 0.01 then
        local rawVelocity = (currentPos - cache.lastPos) / dt
        if rawVelocity.Magnitude < 100 then
            cache.velocity = cache.velocity:Lerp(rawVelocity, 0.4)
        end
    end
    cache.lastPos = currentPos
    cache.lastTime = currentTime
    return cache.velocity
end

function veil_getTargetPart(char)
    if VeilConfig.TargetPart == "Head" then
        return char:FindFirstChild("Head")
    elseif VeilConfig.TargetPart == "Root" then
        return char:FindFirstChild("HumanoidRootPart")
    else
        return char:FindFirstChild("Torso")
            or char:FindFirstChild("UpperTorso")
            or char:FindFirstChild("HumanoidRootPart")
    end
end

function veil_getClosestSurvivor()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local cam      = workspace.CurrentCamera
    local center   = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local bestDist = VeilConfig.FOV
    local bestTarget = nil

    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" and p.Character then
            local char = p.Character
            local hum  = char:FindFirstChildOfClass("Humanoid")
            local part = veil_getTargetPart(char)
            if hum and hum.Health > 0 and part then
                local dist3D = (part.Position - myRoot.Position).Magnitude
                if dist3D <= VeilConfig.MaxDist then
                    local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist2D < bestDist then
                            bestDist   = dist2D
                            bestTarget = { Player = p, Part = part }
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

function veil_setupInterceptor()
    if VeilState.remoteHooked then return end
    task.spawn(function()
        pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                if getnamecallmethod() == "FireServer" and not checkcaller() then
                    if self.Name == "Spearthrow" and VeilConfig.Enabled then
                        return nil
                    end
                end
                return oldNamecall(self, ...)
            end)
            VeilState.remoteHooked = true
        end)
    end)
end
veil_setupInterceptor()

function veil_fire()
    if VeilState.attackCooldown then return end
    VeilState.attackCooldown = true
    task.delay(2, function() VeilState.attackCooldown = false end)

    local myChar    = LocalPlayer.Character
    local startPart = myChar and (myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart"))
    if not startPart then return end

    local startPos   = startPart.Position
    local targetInfo = veil_getClosestSurvivor()
    local aimDir

    if targetInfo and targetInfo.Part then
        local targetPart = targetInfo.Part
        local targetPlayer = targetInfo.Player
        local targetPos = targetPart.Position

        local velocity = Veil_GetRealVelocity(targetPart, targetPlayer.Name)
        local horizontalVel = Vector3.new(velocity.X, 0, velocity.Z)
        local speed = horizontalVel.Magnitude

        local distance = (targetPos - startPos).Magnitude
        local timeToHit = distance / VeilConfig.SpearSpeed

        local horizontalPrediction = Vector3.zero
        if speed > 4 then
            local factor = VeilConfig.HorizontalPredictFactor
            horizontalPrediction = horizontalVel.Unit * factor
        end
        local predictedPos = targetPos + horizontalPrediction

        local distMult = math.clamp(distance / 100, 1, 2.5)
        local autoGravity = math.max(0, distance - 8)
        local gravity = VeilConfig.AutoPredict and autoGravity or VeilConfig.Gravity
        local drop = 0.5 * gravity * (timeToHit ^ 2) * distMult
        local finalPos = predictedPos + Vector3.new(0, drop, 0)

        aimDir = (finalPos - startPos).Unit
        VeilState.lastPredictedPos = finalPos
    else
        aimDir = workspace.CurrentCamera.CFrame.LookVector
        VeilState.lastPredictedPos = nil
    end

    pcall(function()
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if remotes then
            local killers = remotes:FindFirstChild("Killers")
            if killers then
                local veil = killers:FindFirstChild("Veil")
                if veil and veil:FindFirstChild("Spearthrow") then
                    veil.Spearthrow:FireServer(aimDir, VeilConfig.SpearSpeed, startPos)
                end
            end
        end
    end)

    VeilDraw.FOVCircle.Color = Color3.fromRGB(255, 0, 255)
    if not VeilState.passiveCooldown then
        VeilState.passiveCooldown = true
        task.delay(30, function()
            VeilDraw.FOVCircle.Color = Color3.fromRGB(255, 0, 255)
            VeilState.passiveCooldown = false
        end)
    end
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    local isTouch = input.UserInputType == Enum.UserInputType.Touch
    if gp and not isTouch then return end
    local char = LocalPlayer.Character
    local isSpearMode = char and char:GetAttribute("spearmode") == true
    if not VeilConfig.Enabled then return end
    if not isSpearMode then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        VeilState.chargingSpear = true
    elseif isTouch then
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then
            local slasher = pGui:FindFirstChild("Slasher-mob")
            if slasher then
                local ctrl = slasher:FindFirstChild("Controls")
                if ctrl then
                    local attackBtn = ctrl:FindFirstChild("attack")
                    if attackBtn and attackBtn.Visible then
                        local pos     = input.Position
                        local absPos  = attackBtn.AbsolutePosition
                        local absSize = attackBtn.AbsoluteSize
                        if pos.X >= absPos.X and pos.X <= absPos.X + absSize.X
                        and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y then
                            VeilState.chargingSpear = true
                            VeilState.touchInput    = input
                        end
                    end
                end
            end
        end
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input, gp)
    if VeilState.chargingSpear
    and (input == VeilState.touchInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
        VeilState.chargingSpear = false
        if VeilState.touchInput == input then VeilState.touchInput = nil end
        veil_fire()
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    local cam         = workspace.CurrentCamera
    local myChar      = LocalPlayer.Character
    local isSpearMode = myChar and myChar:GetAttribute("spearmode") == true

    if VeilConfig.Enabled and VeilConfig.ShowFOV and isSpearMode then
        VeilDraw.FOVCircle.Visible  = true
        VeilDraw.FOVCircle.Radius   = VeilConfig.FOV
        VeilDraw.FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    else
        VeilDraw.FOVCircle.Visible = false
    end

    if VeilState.chargingSpear and VeilConfig.Enabled and isSpearMode then
        local target = veil_getClosestSurvivor()
        if target and target.Part and target.Part.Parent then
            VeilDraw.Highlight.Parent = target.Part.Parent
        else
            VeilDraw.Highlight.Parent = nil
        end
    else
        VeilDraw.Highlight.Parent = nil
    end

    if VeilConfig.Enabled and isSpearMode and VeilState.lastPredictedPos then
        local screenPos, onScreen = cam:WorldToViewportPoint(VeilState.lastPredictedPos)
        local viewport = cam.ViewportSize
        local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

        if onScreen then
            VeilDraw.Tracer.Position = Vector2.new(screenPos.X, screenPos.Y)
        else
            local dx = screenPos.X - center.X
            local dy = screenPos.Y - center.Y
            if math.abs(dx) < 1 and math.abs(dy) < 1 then
                VeilDraw.Tracer.Position = center
            else
                local angle = math.atan2(dy, dx)
                local maxX = viewport.X / 2 - 10
                local maxY = viewport.Y / 2 - 10
                local scaleX = maxX / math.abs(dx)
                local scaleY = maxY / math.abs(dy)
                local scale = math.min(scaleX, scaleY)
                local borderPos = Vector2.new(
                    center.X + dx * scale,
                    center.Y + dy * scale
                )
                VeilDraw.Tracer.Position = borderPos
            end
        end
        VeilDraw.Tracer.Visible = true
    else
        VeilDraw.Tracer.Visible = false
    end
end)

-- UI TABS

local Tabs = {
    Home = Window:AddTab({ Name = "Discord", Icon = "rbxassetid://94434236999817"}),
    Main = Window:AddTab({ Name = "Main", Icon = "rbxassetid://98755624629571"}),
    Visual = Window:AddTab({ Name = "Visual", Icon = "rbxassetid://100033680381365"}),
    Player = Window:AddTab({ Name = "Players", Icon = "rbxassetid://108483430622128"}),
    Survivor = Window:AddTab({ Name = "Survivors", Icon = "rbxassetid://110987169760162"}),
    Killer = Window:AddTab({ Name = "Killers", Icon = "rbxassetid://82472368671405"}),
    Aim = Window:AddTab({ Name = "Aim", Icon = "rbxassetid://134242818164054"}),
    Mapping = Window:AddTab({ Name = "Map", Icon = "rbxassetid://95107167260947"}),
    Misc = Window:AddTab({ Name = "Miscellaneous", Icon = "rbxassetid://70386228443175"}),
    Settings = Window:AddTab({ Name = "Settings", Icon = "rbxassetid://80758916183665"})
}

if Window then

do -- Masukin ke dalam Tab Players
    local movSection = Tabs.Player:AddSection({
        Position = "Center",
        Name = "Movement",
        Icon      = "solar:running-round-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })

    movSection:AddToggle({
        Default = false,
        Name = "Auto Crouch BETA", Locked = getgenv().VoraHubTier ~= "Premium", TextLocked = "Premium Required",
        Flag = "Auto Crouch BETA",
        Callback = function(v)
            if v and getgenv().VoraHubTier ~= "Premium" then
                pcall(VD_Notify, "Premium Required âœ¨", "Fitur Auto Crouch BETA hanya untuk pengguna Key Premium!", 5)
                return
            end
            setAutoCrouch(v)
        end
    })

    movSection:AddToggle({
        Default = false,
        Name = "Speed Hack", Flag = "Speed Hack",
        Callback = function(v)
            VD.Speed = v
            if not v then
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum.WalkSpeed = 16 end) end
            end
        end
    })
    movSection:AddSlider({
        Name = "Speed Value", Flag = "Speed Value",
        Min = 16, Max = 200, Default = 16,
        Callback = function(v)
            VD.SpeedValue =
                v
        end
    })
    movSection:AddToggle({
        Default = false,
        Name = "Jump Hack", Flag = "Jump Hack",
        Callback = function(v)
            VD.Jump = v
            if not v then
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum.JumpPower = 50 end) end
            end
        end
    })
    movSection:AddSlider({
        Name = "Jump Power", Flag = "Jump Power",
        Min = 50, Max = 300, Default = 50,
        Callback = function(v)
            VD.JumpValue =
                v
        end
    })
    movSection:AddToggle({ Default = false, Name = "Infinite Jump", Flag = "Infinite Jump", Callback = function(v) VD.InfiniteJump = v end })
    movSection:AddToggle({ Default = false, Name = "Anti Fall Damage", Flag = "Anti Fall Damage", Callback = function(v) VD.AntiFallDamage = v end })
    movSection:AddToggle({ Default = false, Name = "Noclip", Flag = "Noclip", Callback = function(v) 
        VD.Noclip = v 
        if not v and getgenv().VD_DisableNoclip then pcall(getgenv().VD_DisableNoclip) end
    end })
    movSection:AddToggle({ Default = false, Name = "Moonwalk", Flag = "Moonwalk", Callback = function(v) VD.Moonwalk = v end })
    movSection:AddSlider({
        Name = "Moonwalk Zigzag Speed", Flag = "Moonwalk Zigzag Speed",
        Min = 1, Max = 30, Default = 11,
        Callback = function(v)
            VD.MoonwalkZigzagSpeed = v
        end
    })
    movSection:AddSlider({
        Name = "Moonwalk Boost Power", Flag = "Moonwalk Boost Power",
        Min = 1, Max = 2, Default = 1.08, Increment = 0.01,
        Callback = function(v)
            VD.MoonwalkBoostPower = v
        end
    })
    movSection:AddToggle({ Default = false, Name = "Invisible Not Visual", Locked = getgenv().VoraHubTier ~= "Premium", TextLocked = "Premium Required", Flag = "Invisible Not Visual", Callback = function(v) 
        if v and getgenv().VoraHubTier ~= "Premium" then
            pcall(VD_Notify, "Premium Required âœ¨", "Fitur Invisible Not Visual hanya untuk pengguna Key Premium!", 5)
            return
        end
        VD.InvisibleNotVisual = v; if not v then pcall(VD_SetInvisibleNotVisual, false) end 
    end })
    movSection:AddSlider({
        Name = "Invisible Speed", Flag = "Invisible Speed",
        Min = 1, Max = 999, Default = 5,
        Callback = function(v)
            VD.InvisibleSpeed = v
        end
    })
    movSection:AddToggle({ Default = false, Name = "Anti AFK", Flag = "Anti AFK", Callback = function(v) VD.AntiAFK = v end })
end

do -- Masukin ke dalam Tab Visual
    pcall(function()
        if getgenv().Vora_AddVisualESPControls then
            getgenv().Vora_AddVisualESPControls(VisualTab)
        end
    end)

    local otherEsp = VisualTab:AddSection({
        Position = "Center",
        Name = "Other Markers",
        Icon      = "solar:map-point-wave-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })
    otherEsp:AddToggle({ Default = false, Name = "Master Turn On Drawing ESP (PC Only!)", Flag = "Master Turn On Drawing ESP", Callback = function(v) VD.DRAWING_ESP = v end })
    otherEsp:AddSlider({
        Name = "Max ESP Distance", Flag = "Max ESP Distance",
        Min = 500, Max = 5000, Default = 2000,
        Callback = function(v)
            VD.MaxDistance = v
        end
    })
    otherEsp:AddToggle({ Default = false, Name = "ESP Skeleton (PC Only!)", Flag = "ESP Skeleton", Callback = function(v) VD.ESP_Skeleton = v end })
    otherEsp:AddToggle({ Default = false, Name = "ESP Velocity Arrows (PC Only!)", Flag = "ESP Velocity Arrows", Callback = function(v) VD.ESP_Velocity = v end })
    otherEsp:AddToggle({ Default = false, Name = "ESP Offscreen Arrows (PC Only!)", Flag = "ESP Offscreen Arrows", Callback = function(v) VD.ESP_Offscreen = v end })
end

do -- Masukin ke dalam Tab Aim
    local aimbotSection = AimFeatureTabs.Aimbot:AddSection({
        Position = "Center",
        Name = "Aimbot",
        Icon      = "solar:target-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })

    aimbotSection:AddToggle({ Default = false, Name = "Enable Aimbot", Flag = "Enable Aimbot", Callback = function(v) VD.AIM_Enabled = v end })

    aimbotSection:AddToggle({ Default = false, Name = "Use RMB to aim", Flag = "Use RMB to aim", Callback = function(v) VD.AIM_UseRMB = v end })
    aimbotSection:AddToggle({ Default = false, Name = "Show FOV Circle", Flag = "Show FOV Circle", Callback = function(v) VD.AIM_ShowFOV = v end })
    aimbotSection:AddSlider({
        Name = "FOV Size (aim radius on screen)", Flag = "FOV Size (aim radius on screen)",
        Min = 20, Max = 400, Default = 120,
        Callback = function(
            v)
            VD.AIM_FOV = v
        end
    })
    aimbotSection:AddSlider({
        Name = "Smoothness (Speed Aim)", Flag = "Smoothness",
        Min = 0.1, Max = 10, Default = 0.3, Increment = 0.05,
        Callback = function(v)
            VD.AIM_Smooth = v
        end
    })

    aimbotSection:AddToggle({ Default = false, Name = "Visibility Check", Flag = "Visibility Check", Callback = function(v) VD.AIM_VisCheck = v end })
    aimbotSection:AddToggle({ Default = false, Name = "Prediction", Flag = "Prediction", Callback = function(v) VD.AIM_Predict = v end })

    local crosshairSection = AimFeatureTabs.Aimbot:AddSection({
        Position = "Center",
        Name = "Advanced Crosshair",
        Icon      = "solar:target-broken",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })

    crosshairSection:AddToggle({ Default = false, Name = "Enable Crosshair", Flag = "CROSS_Enabled", Callback = function(v) VD.CROSS_Enabled = v pcall(VD_UpdateCrosshair) end })
    crosshairSection:AddColorPicker({ Name = "Crosshair Color", Flag = "CROSS_Color", Default = VD.CROSS_Color or Color3.fromRGB(255, 255, 255), Callback = function(v) VD.CROSS_Color = v pcall(VD_UpdateCrosshair) end })
    crosshairSection:AddDropdown({ Name = "Crosshair Style", Flag = "CROSS_Style", Default = "Dot", Values = { "Dot", "Plus", "X", "Box" }, Multi = false, Callback = function(v) VD.CROSS_Style = type(v) == "table" and v[1] or v pcall(VD_UpdateCrosshair) end })
    crosshairSection:AddSlider({ Name = "Crosshair Size", Flag = "CROSS_Size", Min = 1, Max = 100, Default = 3, Increment = 1, Callback = function(v) VD.CROSS_Size = v pcall(VD_UpdateCrosshair) end })
    crosshairSection:AddSlider({ Name = "Crosshair Thickness", Flag = "CROSS_Thickness", Min = 1, Max = 20, Default = 4, Increment = 1, Callback = function(v) VD.CROSS_Thickness = v pcall(VD_UpdateCrosshair) end })
    crosshairSection:AddSlider({ Name = "Crosshair Gap", Flag = "CROSS_Gap", Min = 0, Max = 50, Default = 6, Increment = 1, Callback = function(v) VD.CROSS_Gap = v pcall(VD_UpdateCrosshair) end })
    crosshairSection:AddSlider({ Name = "Position X Offset", Flag = "CROSS_PosX", Min = -500, Max = 500, Default = 0, Increment = 1, Callback = function(v) VD.CROSS_PosX = v pcall(VD_UpdateCrosshair) end })
    crosshairSection:AddSlider({ Name = "Position Y Offset", Flag = "CROSS_PosY", Min = -500, Max = 500, Default = 0, Increment = 1, Callback = function(v) VD.CROSS_PosY = v pcall(VD_UpdateCrosshair) end })

    local spearSection = AimFeatureTabs.Spear:AddSection({
        Position = "Center",
        Name = "Spear Aimbot",
        Icon      = "solar:sword-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })

    spearSection:AddToggle({ Default = false, Name = "Spear Aimbot", Flag = "Spear Aimbot", Callback = function(v) VD.SPEAR_Aimbot = v end })

    spearSection:AddSlider({
        Name = "Spear Gravity", Flag = "Spear Gravity",
        Min = 10, Max = 200, Default = 50,
        Callback = function(v)
            VD.SPEAR_Gravity =
                v
        end
    })
    spearSection:AddSlider({
        Name = "Spear Speed", Flag = "Spear Speed",
        Min = 50, Max = 300, Default = 100,
        Callback = function(v)
            VD.SPEAR_Speed =
                v
        end
    })

    spearSection:AddDivider({ Text = "Veil Prediction" })

    spearSection:AddToggle({ Default = false, Name = "Silent Aim Spear (Veil)", Locked = getgenv().VoraHubTier ~= "Premium", TextLocked = "Premium Required", Flag = "Silent Aim Spear (Veil)", Callback = function(v) 
        if v and getgenv().VoraHubTier ~= "Premium" then
            pcall(VD_Notify, "Premium Required âœ¨", "Fitur Silent Aim Spear (Veil) hanya untuk pengguna Key Premium!", 5)
            return
        end
        VeilConfig.Enabled = v 
    end })
    spearSection:AddToggle({ Default = true, Name = "Show FOV Circle", Flag = "Show FOV Circle", Callback = function(v) VeilConfig.ShowFOV = v end })
    spearSection:AddSlider({ Name = "FOV Radius", Flag = "FOV Radius", Min = 50, Max = 500, Default = 150, Callback = function(v) VeilConfig.FOV = v end })
    spearSection:AddToggle({ Default = false, Name = "Auto Predict", Flag = "Auto Predict", Callback = function(v) VeilConfig.AutoPredict = v end })
    spearSection:AddSlider({ Name = "Spear Speed", Flag = "Spear Speed", Min = 50, Max = 300, Default = 165, Callback = function(v) VeilConfig.SpearSpeed = v end })
    spearSection:AddSlider({ Name = "Gravity", Flag = "Gravity", Min = 0, Max = 300, Default = math.floor(workspace.Gravity * 0.5), Callback = function(v) VeilConfig.Gravity = v end })
    spearSection:AddSlider({ Name = "Horizontal Vector", Flag = "Horizontal Vector", Min = 0, Max = 10, Default = 2.8, Decimals = 1, Callback = function(v) VeilConfig.HorizontalPredictFactor = v end })
    spearSection:AddDropdown({ Name = "Target Part", Flag = "Target Part", Values = {"Torso", "Head", "Root"}, Default = "Torso", Multi = false, Callback = function(v)
        if type(v) == "table" then v = v[1] end
        VeilConfig.TargetPart = v
    end })

    local tofAimSection = AimFeatureTabs.AutoAim:AddSection({
        Position = "Center",
        Name = "Auto Aim",
        Icon      = "solar:magic-stick-3-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })
    tofAimSection:AddToggle({ Default = false, Name = "Auto Aim Twist of Fate", Locked = getgenv().VoraHubTier ~= "Premium", TextLocked = "Premium Required", Flag = "Auto Aim Twist of Fate", Callback = function(v) 
        if v and getgenv().VoraHubTier ~= "Premium" then
            pcall(VD_Notify, "Premium Required âœ¨", "Fitur Auto Aim Twist of Fate hanya untuk pengguna Key Premium!", 5)
            return
        end
        VD.AUTO_ToFAim = v 
    end })
    tofAimSection:AddToggle({ Default = false, Name = "ToF Tracer", Locked = getgenv().VoraHubTier ~= "Premium", TextLocked = "Premium Required", Flag = "ToF Tracer", Callback = function(v) 
        if v and getgenv().VoraHubTier ~= "Premium" then
            pcall(VD_Notify, "Premium Required âœ¨", "Fitur ToF Tracer hanya untuk pengguna Key Premium!", 5)
            return
        end
        VD.AUTO_ToFTracer = v 
    end })
    tofAimSection:AddSlider({
        Name = "ToF Aim Range (studs)", Flag = "ToF Aim Range (studs)",
        Min = 20, Max = 180, Default = 90,
        Callback = function(v)
            VD.AUTO_ToFAimRange = v
        end
    })
    tofAimSection:AddSlider({
        Name = "Aim Strictness (0: Segala arah, 1: Lurus)", Flag = "Aim Strictness",
        Min = 0, Max = 1, Default = 0.5, Increment = 0.05,
        Callback = function(v)
            VD.AUTO_ToFDotThreshold = v
        end
    })
end

do -- Masukin ke dalam Tab Main
    local camSection = VisualFeatureTabs.Camera:AddSection({
        Position = "Center",
        Name = "Camera",
        Icon      = "solar:camera-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })

    camSection:AddToggle({ Default = false, Name = "Enable Camera FOV override", Flag = "Enable Camera FOV override", Callback = function(v) VD.CAM_FOVEnabled = v end })
    camSection:AddSlider({
        Name = "Camera FOV", Flag = "Camera FOV",
        Min = 30, Max = 140, Default = 90,
        Callback = function(v)
            VD.CAM_FOV =
                v
        end
    })
    camSection:AddToggle({ Default = false, Name = "Third Person (Killer only)", Flag = "Third Person (Killer only)", Callback = function(v) VD.CAM_ThirdPerson = v end })
    camSection:AddToggle({ Default = false, Name = "Shift Lock (auto face camera)", Flag = "Shift Lock (auto face camera)", Callback = function(v) VD.CAM_ShiftLock = v end })
    camSection:AddToggle({ Default = false, Name = "Infinity Zoom Out", Flag = "Infinity Zoom Out", Callback = function(v) 
        VD.CAM_InfinityZoom = v 
        LocalPlayer.CameraMaxZoomDistance = v and math.huge or 128 
        LocalPlayer.CameraMinZoomDistance = v and 0 or 0.5 
    end })

    local visualSection = VisualFeatureTabs.Lighting:AddSection({
        Position = "Center",
        Name = "Visual",
        Icon      = "solar:sun-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })

    visualSection:AddToggle({ Default = false, Name = "No Fog (remove fog/post effects)", Flag = "No Fog (remove fog/post effects)", Callback = function(v) VD.NO_Fog = v end })
    visualSection:AddToggle({ Default = false, Name = "Fullbright (lighting preset)", Flag = "Fullbright (lighting preset)", Callback = function(v) VD.Fullbright = v end })
end

do -- Masukin ke dalam Tab Survivors
    local combatSurv = MainFeatureTabs.Survivor:AddSection({
        Position = "Center",
        Name = "Survivor",
        Icon      = "solar:shield-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })

    combatSurv:AddToggle({ Default = false, Name = "Swift Vault", Flag = "SwiftVault", Callback = function(v) VD.SURV_AutoVault = v end })
    combatSurv:AddToggle({ Default = false, Name = "Swift Vault V2", Locked = getgenv().VoraHubTier ~= "Premium", TextLocked = "Premium Required", Flag = "SURV_SwiftVaultV2", Callback = function(v) 
        if v and getgenv().VoraHubTier ~= "Premium" then
            pcall(VD_Notify, "Premium Required âœ¨", "Fitur Swift Vault V2 hanya untuk pengguna Key Premium!", 5)
            return
        end
        VD.SURV_FastVault = v 
        if not v then
            local char = LocalPlayer.Character
            if char then char:SetAttribute("vaultspeed", 1) end
        end
    end })
    combatSurv:AddSlider({
        Name = "Vault Speed", Flag = "SURV_SwiftVaultSpeed",
        Min = 10, Max = 20, Default = 13, Increment = 1,
        Callback = function(v) VD.SURV_VaultSpeed = v end
    })
    combatSurv:AddToggle({ Default = false, Name = "Pallet Reflex", Flag = "Pallet Reflex", Callback = function(v) VD.SURV_AutoPallet = v end })
    combatSurv:AddSlider({
        Name = "Pallet Trigger Range (studs)", Flag = "Pallet Trigger Range",
        Min = 5, Max = 50, Default = 20, Increment = 1,
        Callback = function(v) VD.SURV_AutoPalletDist = v end
    })
    combatSurv:AddToggle({ Default = false, Name = "Anti Knock", Locked = getgenv().VoraHubTier ~= "Premium", TextLocked = "Premium Required", Flag = "Anti Knock", Callback = function(v) 
        if v and getgenv().VoraHubTier ~= "Premium" then
            pcall(VD_Notify, "Premium Required âœ¨", "Fitur Anti Knock hanya untuk pengguna Key Premium!", 5)
            return
        end
        VD.SURV_AntiKnock = v 
    end })
    combatSurv:AddToggle({ Default = false, Name = "Instant Heal (Self)", Flag = "Instant Heal (Self)", Callback = function(v) setInstantHealSelf(v) end })
    combatSurv:AddToggle({ Default = false, Name = "Auto Heal All", Locked = getgenv().VoraHubTier ~= "Premium", TextLocked = "Premium Required", Flag = "Auto Heal All", Callback = function(v) 
        if v and getgenv().VoraHubTier ~= "Premium" then
            pcall(VD_Notify, "Premium Required âœ¨", "Fitur Auto Heal All hanya untuk pengguna Key Premium!", 5)
            return
        end
        setAutoHealAll(v) 
    end })

    combatSurv:AddToggle({
        Default = false, Name = "First Person Camera (Survivor)", Flag = "First Person Camera (Survivor)", Callback = function(v)
        VD.SURV_FirstPerson = v
        if not v then
            pcall(RestoreFirstPersonCamera)
        end
    end })
    combatSurv:AddToggle({ Default = false, Name = "Auto Parry", Flag = "Auto Parry", Callback = function(v) VD_SetAutoParry(v) end })
    combatSurv:AddSlider({
        Name = "Parry Distance Trigger", Flag = "Parry Distance Trigger",
        Min = 2, Max = 25, Default = 8, Increment = 1,
        Callback = function(v)
            VD.SURV_ParryDistance = v
        end
    })
    combatSurv:AddToggle({
        Default = false, Name = "Show Parry Range Circle", Flag = "Show Parry Range Circle", Callback = function(v)
        VD.SURV_ShowParryCircle = v
        if not v then VD_ParryRange.Transparency = 1 end
    end })
end

do -- Masukin ke dalam Tab Killer
    local combatKiller = MainKillerFeatureTabs.Killer:AddSection({
        Position = "Center",
        Name = "Killer",
        Icon      = "solar:danger-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })

    combatKiller:AddToggle({ Default = false, Name = "Auto Attack", Flag = "Auto Attack", Callback = function(v) VD.AUTO_Attack = v end })
    combatKiller:AddToggle({ Default = false, Name = "Inf Grab (Myers)", Locked = getgenv().VoraHubTier ~= "Premium", TextLocked = "Premium Required", Flag = "Inf Grab (Myers)", Callback = function(v) 
        if v and getgenv().VoraHubTier ~= "Premium" then
            pcall(VD_Notify, "Premium Required âœ¨", "Fitur Inf Grab (Myers) hanya untuk pengguna Key Premium!", 5)
            return
        end
        setMyersGrab(v) 
    end })
    combatKiller:AddToggle({ Default = false, Name = "Undraggable Button (Inf Grab)", Locked = getgenv().VoraHubTier ~= "Premium", TextLocked = "Premium Required", Flag = "Undraggable Button (Inf Grab)", Callback = function(v) 
        if v and getgenv().VoraHubTier ~= "Premium" then
            pcall(VD_Notify, "Premium Required âœ¨", "Fitur Undraggable Button (Inf Grab) hanya untuk pengguna Key Premium!", 5)
            return
        end
        setMyersDragLocked(v) 
    end })
    combatKiller:AddSlider({
        Name = "Attack Range", Flag = "Attack Range",
        Min = 5, Max = 20, Default = 12,
        Callback = function(v)
            VD.AUTO_AttackRange =
                v
        end
    })
    combatKiller:AddToggle({ Default = false, Name = "Hitbox Expand", Flag = "Hitbox Expand", Callback = function(v) VD.HITBOX_Enabled = v end })
    combatKiller:AddSlider({
        Name = "Hitbox Size", Flag = "Hitbox Size",
        Min = 5, Max = 40, Default = 15,
        Callback = function(v)
            VD.HITBOX_Size =
                v
        end
    })
    combatKiller:AddToggle({ Default = false, Name = "Double Tap", Flag = "Double Tap", Callback = function(v) VD.KILLER_DoubleTap = v end })
    combatKiller:AddToggle({ Default = false, Name = "Infinite Lunge", Flag = "Infinite Lunge", Callback = function(v) VD.KILLER_InfiniteLunge = v end })

    local utilKiller = MainKillerFeatureTabs.Utilities:AddSection({
        Position = "Center",
        Name = "Utilities",
        Icon      = "solar:settings-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })

    utilKiller:AddToggle({ Default = false, Name = "Auto Hook", Flag = "Auto Hook", Callback = function(v) VD.KILLER_AutoHook = v end })
    utilKiller:AddToggle({ Default = false, Name = "Destroy Pallets", Flag = "Destroy Pallets", Callback = function(v) VD.KILLER_DestroyPallets = v end })
    utilKiller:AddToggle({
        Default = false,
        Name = "Anti Blind (Flashlight)", Flag = "Anti Blind (Flashlight)",
        Callback = function(v)
            VD.KILLER_AntiBlind = v; pcall(SetupAntiBlind)
        end
    })
    utilKiller:AddToggle({
        Default = false,
        Name = "Remove Palletwrong (All)", Flag = "Remove Palletwrong (All)",
        Callback = function(v)
            VD.KILLER_NoPalletStun = v; pcall(SetupNoPalletStun)
        end
    })
    utilKiller:AddToggle({ Default = false, Name = "No Slowdown", Flag = "No Slowdown", Callback = function(v) VD.KILLER_NoSlowdown = v end })
    utilKiller:AddToggle({ Default = false, Name = "Beat Killer (auto kill)", Flag = "Beat Killer (auto kill)", Callback = function(v) VD.BEAT_Killer = v end })
    pcall(function()
        local customMaskedMasks = {"Richard", "Tony", "Brandon", "Jake", "Richter", "Graham", "Alex"}
        utilKiller:AddDropdown({
            Name = "Custom Masked",
            Locked = getgenv().VoraHubTier ~= "Premium",
            TextLocked = "Premium Required",
            Flag = "Custom Masked",
            Values = customMaskedMasks,
            Multi = false,
            Default = VD.KILLER_CustomMasked or "Richard",
            Callback = function(v)
                if v and getgenv().VoraHubTier ~= "Premium" then
                    return
                end
                if type(v) == "table" then
                    v = v[1]
                end
                VD.KILLER_CustomMasked = v or "Richard"
            end
        })
        utilKiller:AddButton({
            Name = "Apply Custom Masked",
            Locked = getgenv().VoraHubTier ~= "Premium",
            TextLocked = "Premium Required",
            Callback = function()
                if getgenv().VoraHubTier ~= "Premium" then
                    pcall(VD_Notify, "Premium Required âœ¨", "Fitur Custom Masked hanya untuk pengguna Key Premium!", 5)
                    return
                end
                pcall(Vora_ApplyCustomMasked, VD.KILLER_CustomMasked)
            end
        })
        utilKiller:AddButton({
            Name = "Random Custom Masked",
            Locked = getgenv().VoraHubTier ~= "Premium",
            TextLocked = "Premium Required",
            Callback = function()
                if getgenv().VoraHubTier ~= "Premium" then
                    pcall(VD_Notify, "Premium Required âœ¨", "Fitur Custom Masked hanya untuk pengguna Key Premium!", 5)
                    return
                end
                local mask = customMaskedMasks[math.random(1, #customMaskedMasks)]
                VD.KILLER_CustomMasked = mask
                pcall(Vora_ApplyCustomMasked, mask)
            end
        })
    end)
end

do -- Masukin ke dalam Tab Main
    local escapeSurv = MainFeatureTabs.Escape:AddSection({
        Position = "Center",
        Name = "Escape",
        Icon      = "solar:exit-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })

    escapeSurv:AddToggle({ Default = false, Name = "Bypass Gate", Flag = "Bypass Gate", Callback = function(v) VD.BypassGate = v; if not v then pcall(VD_RestoreGateParts) end end })
    escapeSurv:AddToggle({ Default = false, Name = "Beat Survivor (auto exit)", Locked = getgenv().VoraHubTier ~= "Premium", TextLocked = "Premium Required", Flag = "Beat Survivor (auto exit)", Callback = function(v) 
        if v and getgenv().VoraHubTier ~= "Premium" then
            pcall(VD_Notify, "Premium Required âœ¨", "Fitur Beat Survivor hanya untuk pengguna Key Premium!", 5)
            return
        end
        VD.BEAT_Survivor = v 
    end })

    escapeSurv:AddToggle({ Default = false, Name = "Flee Killer", Flag = "Flee Killer", Callback = function(v) VD.SURV_FleeKiller = v end })
    escapeSurv:AddSlider({
        Name = "Flee Distance", Flag = "Flee Distance",
        Min = 15, Max = 80, Default = 40,
        Callback = function(v) VD.SURV_FleeDistance = v end
    })
end

do -- Masukin ke dalam Tab Main

    local genAuto = MainFeatureTabs.Automation:AddSection({
        Position = "Center",
        Name = "Automation",
        Icon      = "solar:bolt-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })


    genAuto:AddToggle({ Default = false, Name = "Auto Skillcheck", Flag = "Auto Skillcheck", Callback = function(v) VD_SetAutoSkillcheck(v) end })
    genAuto:AddToggle({ Default = false, Name = "Hide Skillcheck UI", Flag = "Hide Skillcheck UI", Callback = function(v) VD.HideSkillUI = v end })
    genAuto:AddToggle({ Default = false, Name = "Boost Gen Bypass", Locked = getgenv().VoraHubTier ~= "Premium", TextLocked = "Premium Required", Flag = "Boost Gen Bypass", Callback = function(v) 
        if v and getgenv().VoraHubTier ~= "Premium" then
            pcall(VD_Notify, "Premium Required âœ¨", "Fitur Boost Gen Bypass hanya untuk pengguna Key Premium!", 5)
            return
        end
        setGenBypass(v) 
    end })
    genAuto:AddDropdown({
        Name = "Skillcheck Mode",
        Flag = "Skillcheck Mode",
        Values = { "Normal", "Perfect", "Instant" },
        Default = "Normal",
        DisabledOptions = getgenv().VoraHubTier ~= "Premium" and { "Instant" } or {},
        Multi = false,
        Callback = function(option)
            if type(option) == "table" then option = option[1] end
            if option == "Instant" and getgenv().VoraHubTier ~= "Premium" then
                pcall(VD_Notify, "Premium Required âœ¨", "Opsi Instant hanya untuk pengguna Key Premium!", 5)
                return
            end
            VD.AutoSkillcheckMode = option or "Normal"
            if VD.AutoSkillcheckMode ~= "Instant" and AutoSkill.InstantRotationConnection then
                AutoSkill.InstantRotationConnection:Disconnect()
                AutoSkill.InstantRotationConnection = nil
                AutoSkill.InstantHasClicked = false
            end
            VD_Notify("Skillcheck Mode", tostring(VD.AutoSkillcheckMode) .. " selected", 2)
        end
    })
end

do -- Masukin ke dalam Misc
    local flingSection = PlayerFeatureTabs.Fling:AddSection({
        Position = "Center",
        Name = "Fling",
        Icon      = "solar:wind-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })

    flingSection:AddToggle({ Default = false, Name = "Enable Fling", Locked = getgenv().VoraHubTier ~= "Premium", TextLocked = "Premium Required", Flag = "Enable Fling", Callback = function(v) 
        if v and getgenv().VoraHubTier ~= "Premium" then
            pcall(VD_Notify, "Premium Required âœ¨", "Fitur Fling hanya untuk pengguna Key Premium!", 5)
            return
        end
        VD.FLING_Enabled = v 
    end })
    flingSection:AddSlider({
        Name = "Fling Strength", Flag = "Fling Strength",
        Min = 1000, Max = 50000, Default = 10000,
        Callback = function(
            v)
            VD.FLING_Strength = v
        end
    })

    flingSection:AddButton({ Name = "Fling Nearest", Locked = getgenv().VoraHubTier ~= "Premium", TextLocked = "Premium Required", Callback = function() 
        if getgenv().VoraHubTier ~= "Premium" then
            pcall(VD_Notify, "Premium Required âœ¨", "Fitur Fling hanya untuk pengguna Key Premium!", 5)
            return
        end
        pcall(function() Vora_FlingNearest() end) 
    end })
    flingSection:AddButton({ Name = "Fling All", Locked = getgenv().VoraHubTier ~= "Premium", TextLocked = "Premium Required", Callback = function() 
        if getgenv().VoraHubTier ~= "Premium" then
            pcall(VD_Notify, "Premium Required âœ¨", "Fitur Fling hanya untuk pengguna Key Premium!", 5)
            return
        end
        pcall(Vora_FlingAll) 
    end })
end

-- PLAYER EMOTE SYSTEM (Imported from Panduhub.lua)
local EMOTES = {
    ["Friday Night"] = { Animation = "rbxassetid://83229063951016", Sound = "rbxassetid://85355610204255" },
    ["Backflip"] = { Animation = "rbxassetid://130593238885843" },
    ["WarCry"] = { Animation = "rbxassetid://106871536134254" },
    ["24 Hour Cinderella"] = { Animation = "rbxassetid://117042998468241" },
    ["Applause"] = { Animation = "rbxassetid://118907603246885" },
    ["Arm Swing"] = { Animation = "rbxassetid://111920872708571" },
    ["California Girls"] = { Animation = "rbxassetid://82666958311998" },
    ["Christmas Spirit"] = { Animation = "rbxassetid://121216847022485" },
    ["Floating Rest"] = { Animation = "rbxassetid://135002183282873" },
}

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function stopEmote()
    local character = getCharacter()
    if not character then
        return
    end
    local sound = character:FindFirstChild("PanduEmoteSound", true)
    if sound then
        sound:Destroy()
    end
    local humanoid = getHumanoid()
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            if track:GetAttribute("PanduEmote") then
                track:Stop(0.15)
            end
        end
    end
end

local function playEmote(name)
    stopEmote()
    local data = EMOTES[name]
    if not data then
        VD_Notify("Emote", "ID emote ini tidak dapat dipastikan dari VM: " .. tostring(name), 5)
        return
    end
    local humanoid = getHumanoid()
    local root = getRoot()
    if not humanoid then
        return
    end
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    local animation = Instance.new("Animation")
    animation.AnimationId = data.Animation
    local track = animator:LoadAnimation(animation)
    track:SetAttribute("PanduEmote", true)
    track.Looped = true
    track:Play(0.15)
    if data.Sound and root then
        local sound = Instance.new("Sound")
        sound.Name = "PanduEmoteSound"
        sound.SoundId = data.Sound
        sound.Volume = 2
        sound.Looped = true
        sound.Parent = root
        sound:Play()
    end
end

do -- Masukin ke dalam Tab Misc
    local emoteSection = PlayerFeatureTabs.Emote:AddSection({
        Position = "Center",
        Name = "Player Emote [BETA]",
        Icon      = "solar:music-note-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })

    VD.SelectedEmote = "Friday Night"
    VD.EmoteEnabled = false

    emoteSection:AddToggle({
        Default = false,
        Name = "Enable Emote",
        Flag = "Enable Emote",
        Callback = function(v)
            VD.EmoteEnabled = v
            if v then
                playEmote(VD.SelectedEmote)
            else
                stopEmote()
            end
        end
    })

    emoteSection:AddDropdown({
        Name = "Select Emote",
        Flag = "Select Emote",
        Values = {
            "Friday Night", "WarCry", "24 Hour Cinderella", "Applause", "Arm Swing", "Backflip", "California Girls", "Christmas Spirit", "Floating Rest"
        },
        Default = "Friday Night",
        Multi = false,
        Callback = function(option)
            if type(option) == "table" then option = option[1] end
            VD.SelectedEmote = option or "Friday Night"
            if VD.EmoteEnabled then
                playEmote(VD.SelectedEmote)
            end
        end
    })
end

do -- Masukin ke dalam Tab Misc
    local funSection = PlayerMiscFeatureTabs.Fun:AddSection({
        Position = "Center",
        Name = "Spoof Stats [Visual Only]",
        Icon = "solar:gamepad-bold",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local spoofLevel, spoofGears, spoofScrews = "0", "0", "0"

    funSection:AddTextInput({
        Name = "Set Level",
        Flag = "SpoofLevel",
        Numeric = true,
        Default = "0",
        Callback = function(value) spoofLevel = value end
    })

    funSection:AddTextInput({
        Name = "Set Gears",
        Flag = "SpoofGears",
        Numeric = true,
        Default = "0",
        Callback = function(value) spoofGears = value end
    })

    funSection:AddTextInput({
        Name = "Set Screws",
        Flag = "SpoofScrews",
        Numeric = true,
        Default = "0",
        Callback = function(value) spoofScrews = value end
    })

    funSection:AddButton({
        Name = "Apply Spoof Data",
        Callback = function()
            local p = LocalPlayer
            if p then
                p:SetAttribute("Level", tonumber(spoofLevel) or 0)
                p:SetAttribute("Gears", tonumber(spoofGears) or 0)
                p:SetAttribute("Screws", tonumber(spoofScrews) or 0)
                if VD_Notify then
                    VD_Notify("Spoof Data", "Level, Gears, dan Screws diperbarui", 3)
                end
            end
        end
    })
end

do -- Masukin ke dalam Tab Settings
    local streamerSection = PlayerMiscFeatureTabs.Streamer:AddSection({
        Position = "Center",
        Name = "Streamer Mode",
        Icon      = "solar:users-group-rounded-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })

    local FakeNameConnection = nil

    local function shouldHideNameObject(object)
        local ok, isTextObj = pcall(function()
            return object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")
        end)
        if not ok or not isTextObj then
            return false
        end
        local text = ""
        pcall(function() text = tostring(object.Text or "") end)
        return text == LocalPlayer.Name or text == LocalPlayer.DisplayName or text:find(LocalPlayer.Name, 1, true) ~= nil
    end

    local function enableFakeName(enabled)
        if FakeNameConnection then
            pcall(function() FakeNameConnection:Disconnect() end)
            FakeNameConnection = nil
        end
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not playerGui then
            return
        end
        local function process(object)
            if shouldHideNameObject(object) then
                object.Visible = not enabled
            end
        end
        for _, descendant in ipairs(playerGui:GetDescendants()) do
            process(descendant)
        end
        if enabled then
            FakeNameConnection = playerGui.DescendantAdded:Connect(function(object)
                task.defer(process, object)
            end)
        end
    end

    streamerSection:AddToggle({
        Default = false,
        Name = "Hide Name",
        Flag = "Hide Name",
        Callback = function(v)
            pcall(enableFakeName, v)
        end
    })
end

do -- Masukin ke dalam Tab Settings
    local avatarSection = PlayerMiscFeatureTabs.Avatar:AddSection({
        Position = "Center",
        Name = "Copy Avatar",
        Icon      = "solar:users-group-rounded-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })

    local ORIGINAL_DESC = nil
    local CURRENT_AVATAR = nil
    local Applying = false
    local RespawnConnection = nil

    local RANDOM_IDS = {978663613, 5261700291, 1846241644, 4993456331, 424866237, 4312175249}

    local function CaptureOriginal()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            local ok, desc = pcall(function() return hum:GetAppliedDescription() end)
            if ok and desc then ORIGINAL_DESC = desc end
        end
    end

    -- Initial capture
    CaptureOriginal()
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        CaptureOriginal()
    end)

    local function SafeClearCharacter(char)
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") or v:IsA("CharacterMesh") or v:IsA("ShirtGraphic") then
                pcall(function() v:Destroy() end)
            end
        end
        local face = char:FindFirstChild("Head") and char.Head:FindFirstChild("face")
        if face then pcall(function() face:Destroy() end) end
    end

    local function ResolveUser(input)
        local txt = tostring(input):gsub("%s+", "")
        local id = tonumber(txt)
        if id then
            local ok, name = pcall(function() return Players:GetNameFromUserIdAsync(id) end)
            if ok then return id, name end
        else
            local ok, uid = pcall(function() return Players:GetUserIdFromNameAsync(txt) end)
            if ok then
                local ok2, name = pcall(function() return Players:GetNameFromUserIdAsync(uid) end)
                if ok2 then return uid, name end
            end
        end
        return nil, nil
    end

    local function MorphChar(char, name, desc)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            SafeClearCharacter(char)
            pcall(function()
                hum:ApplyDescriptionClientServer(desc)
                hum.DisplayName = name
            end)
        end
    end

    local function ApplyAvatar(userid)
        if Applying then return end
        Applying = true
        task.spawn(function()
            local id, name = ResolveUser(userid)
            if not id then
                VD_Notify("Copy Avatar", "User tidak ditemukan!", 3)
                Applying = false
                return
            end
            local success, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(id) end)
            if not success or not desc then
                VD_Notify("Copy Avatar", "Gagal mengambil avatar!", 3)
                Applying = false
                return
            end

            CURRENT_AVATAR = {id = id, name = name, desc = desc}
            if RespawnConnection then
                pcall(function() RespawnConnection:Disconnect() end)
                RespawnConnection = nil
            end
            if LocalPlayer.Character then
                MorphChar(LocalPlayer.Character, name, desc)
            end

            RespawnConnection = LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.4)
                if CURRENT_AVATAR then
                    MorphChar(char, name, desc)
                end
            end)

            VD_Notify("Copy Avatar", "Berhasil menyalin avatar " .. name, 3)
            Applying = false
        end)
    end

    VD.AvatarTargetInput = ""
    VD.AvatarTargetPlayer = ""

    local function getPlayerNames()
        local names = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(names, player.Name)
            end
        end
        table.sort(names)
        return names
    end

    local playerDropdown = avatarSection:AddDropdown({
        Name = "Select Player Online",
        Flag = "AvatarTargetPlayer",
        Values = getPlayerNames(),
        Multi = false,
        Callback = function(option)
            if type(option) == "table" then option = option[1] end
            VD.AvatarTargetPlayer = option or ""
        end
    })

    local function updatePlayerList()
        local names = getPlayerNames()
        pcall(function() playerDropdown:SetValues(names) end)
    end

    Players.PlayerAdded:Connect(updatePlayerList)
    Players.PlayerRemoving:Connect(updatePlayerList)

    avatarSection:AddButton({
        Name = "APPLY AVATAR",
        Callback = function()
            local target = (VD.AvatarTargetInput ~= "") and VD.AvatarTargetInput or VD.AvatarTargetPlayer
            if target and target ~= "" and target ~= "Pilih Player..." then
                ApplyAvatar(target)
            else
                VD_Notify("Copy Avatar", "Masukkan username/ID atau pilih player online terlebih dahulu!", 3)
            end
        end
    })

    avatarSection:AddButton({
        Name = "RANDOM AVATAR",
        Callback = function()
            local randId = RANDOM_IDS[math.random(1, #RANDOM_IDS)]
            ApplyAvatar(randId)
        end
    })

    avatarSection:AddButton({
        Name = "RESET AVATAR",
        Callback = function()
            if ORIGINAL_DESC and LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    SafeClearCharacter(LocalPlayer.Character)
                    pcall(function()
                        hum:ApplyDescriptionClientServer(ORIGINAL_DESC)
                        hum.DisplayName = LocalPlayer.DisplayName
                    end)
                end
            end
            CURRENT_AVATAR = nil
            if RespawnConnection then
                pcall(function() RespawnConnection:Disconnect() end)
                RespawnConnection = nil
            end
            VD_Notify("Copy Avatar", "Avatar berhasil direset!", 3)
        end
    })
end

end -- end if Window then

print("Vora HUB Violence District v1.4.2 Loaded")
if VD_Notify then
    VD_Notify("VoraHub", "Violence District v1.4.2 Loaded Successfully!", 5)
end

-- ROLE HELPERS
local function GetRole()
    if not LocalPlayer.Team then return "Unknown" end
    local name = LocalPlayer.Team.Name
    if name == "Killer" then return "Killer" end
    if name == "Survivors" then return "Survivor" end
    return "Lobby"
end

local function IsKiller(player)
    return player and player.Team and player.Team.Name == "Killer"
end

local function IsSurvivor(player)
    return player and player.Team and player.Team.Name == "Survivors"
end

function Vora_ApplyCustomMasked(maskName)
    local selectedMask = maskName or VD.KILLER_CustomMasked or "Richard"
    if type(selectedMask) == "table" then
        selectedMask = selectedMask[1]
    end
    if type(selectedMask) ~= "string" or selectedMask == "" then
        selectedMask = "Richard"
    end

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local killers = remotes and remotes:FindFirstChild("Killers")
    local masked = killers and killers:FindFirstChild("Masked")
    local activatePower = masked and masked:FindFirstChild("Activatepower")

    if activatePower and activatePower:IsA("RemoteEvent") then
        activatePower:FireServer(selectedMask)
        return true
    end
    return false
end

local function VD_GetGameValue(obj, name)
    if typeof(obj) ~= "Instance" then return nil end
    local attr = obj:GetAttribute(name)
    if attr ~= nil then return attr end
    local child = obj:FindFirstChild(name)
    if child and child:IsA("ValueBase") then return child.Value end
    return nil
end

local function VD_IsStatusActive(value)
    return value == true or (type(value) == "number" and value > 0)
end

local function VD_RunAntiKnock()
    if not VD.SURV_AntiKnock or GetRole() ~= "Survivor" then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum then return end

    local isKnocked = VD_IsStatusActive(VD_GetGameValue(char, "Knocked"))
        or VD_IsStatusActive(VD_GetGameValue(char, "IsKnocked"))
    local isCarried = VD_IsStatusActive(VD_GetGameValue(char, "Carried"))
        or VD_IsStatusActive(VD_GetGameValue(char, "IsCarried"))
        or VD_IsStatusActive(VD_GetGameValue(char, "Grabbed"))

    if not isKnocked and not isCarried then return end
    local now = tick()
    if VD._LastAntiKnock and now - VD._LastAntiKnock < 0.3 then return end
    VD._LastAntiKnock = now

    for _, flag in ipairs({ "Knocked", "IsKnocked", "Carried", "IsCarried", "Grabbed", "Ragdolled", "Captured", "Disabled" }) do
        pcall(function()
            if char:GetAttribute(flag) ~= nil then char:SetAttribute(flag, false) end
            local obj = char:FindFirstChild(flag)
            if obj and obj:IsA("BoolValue") then
                obj.Value = false
            elseif obj and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                obj.Value = 0
            end
        end)
    end

    pcall(function()
        hum.PlatformStand = false
        hum.Sit = false
        hum.AutoRotate = true
        if hum:GetState() == Enum.HumanoidStateType.Physics
            or hum:GetState() == Enum.HumanoidStateType.Ragdoll
            or hum:GetState() == Enum.HumanoidStateType.FallingDown
            or hum:GetState() == Enum.HumanoidStateType.PlatformStanding then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if root then root.AssemblyLinearVelocity = Vector3.zero end
        task.defer(function()
            pcall(function()
                hum.Health = hum.MaxHealth
                hum.WalkSpeed = math.max(hum.WalkSpeed, 16)
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end)
        end)
    end)
end

local function VD_ClearSurvivorWarnings()
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local warn = root and root:FindFirstChild("Vora_SurvivorKillerWarn")
        if warn then warn:Destroy() end
    end
end

local VD_WarnIconPaths = {
    Yellow = "/tmp/codex-web-uploads/f-LtzTRl/file_000000004f9871fa9d73773e3af21740.png",
    Purple = "/tmp/codex-web-uploads/f-Yo5gYu/file_00000000fb90720782fb54bce5fe8099.png",
}
local VD_WarnIconAssetIds = {
    Yellow = "113063284092207",
    Purple = "87337602602637",
}
local VD_WarnIconCache = {}

local function VD_FormatAssetId(assetId)
    assetId = tostring(assetId or "")
    if assetId == "" then return nil end
    if assetId:find("rbxassetid://", 1, true) then return assetId end
    if assetId:find("rbxthumb://", 1, true) then return assetId end
    if assetId:match("^%d+$") then
        return "rbxthumb://type=Asset&id=" .. assetId .. "&w=150&h=150"
    end
    return "rbxassetid://" .. assetId
end

local function VD_GetWarnIcon(colorName, path)
    local asset = VD_FormatAssetId(VD_WarnIconAssetIds[colorName])
    if asset then return asset end
    if VD_WarnIconCache[path] ~= nil then return VD_WarnIconCache[path] or nil end
    if not getcustomasset then
        VD_WarnIconCache[path] = false
        return nil
    end
    local ok, asset = pcall(getcustomasset, path)
    VD_WarnIconCache[path] = ok and asset or false
    return VD_WarnIconCache[path] or nil
end

local function VD_EnsureWarnImage(parent, name, image, position)
    local img = parent:FindFirstChild(name)
    if not img then
        img = Instance.new("ImageLabel")
        img.Name = name
        img.BackgroundTransparency = 1
        img.ImageTransparency = 0
        img.ScaleType = Enum.ScaleType.Fit
        img.ZIndex = 2
        img.Parent = parent
    end
    img.Image = image or ""
    img.Position = position or UDim2.fromScale(0, 0)
    img.Size = UDim2.fromScale(0.5, 1)
    img.Visible = image ~= nil
    return img
end

local function VD_UpdateSurvivorWarnings()
    if not VD.SURV_WarnKiller then
        if VD._WarnKillerActive then
            VD_ClearSurvivorWarnings()
            VD._WarnKillerActive = false
        end
        return
    end
    local now = tick()
    if VD._WarnKillerVorat and now < VD._WarnKillerVorat then return end
    VD._WarnKillerVorat = now + 0.15
    VD._WarnKillerActive = true

    local killers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsKiller(player) and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then table.insert(killers, root) end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if IsSurvivor(player) and player.Character then
            local char = player.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local nearest = math.huge
                for _, killerRoot in ipairs(killers) do
                    nearest = math.min(nearest, (root.Position - killerRoot.Position).Magnitude)
                end

                local warn = root:FindFirstChild("Vora_SurvivorKillerWarn")
                if nearest <= 60 then
                    local danger = nearest <= 40
                    if not warn then
                        warn = Instance.new("BillboardGui")
                        warn.Name = "Vora_SurvivorKillerWarn"
                        warn.Adornee = root
                        warn.AlwaysOnTop = true
                        warn.Size = UDim2.new(0, 76, 0, 44)
                        warn.StudsOffset = Vector3.new(0, 4.8, 0)
                        warn.MaxDistance = 2000
                        warn.Parent = root

                        local label = Instance.new("TextLabel")
                        label.Name = "FallbackLabel"
                        label.BackgroundTransparency = 1
                        label.Size = UDim2.fromScale(1, 1)
                        label.Font = Enum.Font.GothamBlack
                        label.TextScaled = true
                        label.Visible = false
                        label.Parent = warn

                        local stroke = Instance.new("UIStroke")
                        stroke.Thickness = 1.5
                        stroke.Color = Color3.new(0, 0, 0)
                        stroke.Parent = label
                    end
                    local yellowIcon = VD_GetWarnIcon("Yellow", VD_WarnIconPaths.Yellow)
                    local purpleIcon = VD_GetWarnIcon("Purple", VD_WarnIconPaths.Purple)
                    local canUseImages = yellowIcon ~= nil and (not danger or purpleIcon ~= nil)
                    warn.Size = danger and UDim2.new(0, 76, 0, 56) or UDim2.new(0, 56, 0, 56)

                    local yellow = VD_EnsureWarnImage(warn, "YellowIcon", yellowIcon, UDim2.fromScale(0, 0))
                    local purple = VD_EnsureWarnImage(warn, "PurpleIcon", purpleIcon, UDim2.fromScale(0.38, 0))
                    yellow.Size = danger and UDim2.fromScale(0.62, 1) or UDim2.fromScale(1, 1)
                    purple.Size = UDim2.fromScale(0.62, 1)
                    yellow.Visible = canUseImages
                    purple.Visible = canUseImages and danger

                    local label = warn:FindFirstChild("FallbackLabel")
                    if label then
                        label.Visible = not canUseImages
                        label.Text = danger and "!!" or "!"
                        label.TextColor3 = danger and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(255, 225, 0)
                    end
                elseif warn then
                    warn:Destroy()
                end
            end
        end
    end
end

local VD_GateOriginal = setmetatable({}, { __mode = "k" })
local function VD_SetPartState(part, props)
    if not part or not part:IsA("BasePart") then return end
    if not VD_GateOriginal[part] then
        VD_GateOriginal[part] = {
            Transparency = part.Transparency,
            CanCollide = part.CanCollide,
        }
    end
    pcall(function()
        if props.Transparency ~= nil then part.Transparency = props.Transparency end
        if props.CanCollide ~= nil then part.CanCollide = props.CanCollide end
    end)
end

function VD_RestoreGateParts()
    for part, props in pairs(VD_GateOriginal) do
        if part and part.Parent then
            pcall(function()
                part.Transparency = props.Transparency
                part.CanCollide = props.CanCollide
            end)
        end
    end
    VD_GateOriginal = setmetatable({}, { __mode = "k" })
end

local function VD_UpdateBypassGate()
    if not VD.BypassGate then
        if Vorat(VD_GateOriginal) then VD_RestoreGateParts() end
        return
    end
    if VD._VoratBypassGate and tick() < VD._VoratBypassGate then return end
    VD._VoratBypassGate = tick() + 1
    for _, gate in ipairs(Workspace:GetDescendants()) do
        if gate:IsA("Model") and gate.Name == "Gate" then
            VD_SetPartState(gate:FindFirstChild("LeftGate"), { Transparency = 1, CanCollide = false })
            VD_SetPartState(gate:FindFirstChild("RightGate"), { Transparency = 1, CanCollide = false })
            VD_SetPartState(gate:FindFirstChild("LeftGate-end"), { Transparency = 0, CanCollide = true })
            VD_SetPartState(gate:FindFirstChild("RightGate-end"), { Transparency = 0, CanCollide = true })
            VD_SetPartState(gate:FindFirstChild("Box"), { CanCollide = false })
        end
    end
end

local VD_InvisibleNV = {
    Active = false,
    Seat = nil,
    Weld = nil,
    OriginalSpeed = nil,
    Position = Vector3.new(-25.95, 84, 3537.55),
}

local function VD_SetCharacterTransparency(character, transparency)
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") or descendant:IsA("Decal") then
            pcall(function() descendant.Transparency = transparency end)
        end
    end
end

function VD_SetInvisibleNotVisual(state)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not hum or not root or not torso then return end

    if state then
        if VD_InvisibleNV.Active then
            hum.WalkSpeed = VD.InvisibleSpeed or 16
            return
        end

        VD_InvisibleNV.Active = true
        VD_InvisibleNV.OriginalSpeed = hum.WalkSpeed
        local savedCFrame = root.CFrame

        char:MoveTo(VD_InvisibleNV.Position)
        task.wait(0.15)

        local seat = Instance.new("Seat")
        seat.Name = "Vora_InvisibleSeat"
        seat.Anchored = false
        seat.CanCollide = false
        seat.Transparency = 1
        seat.CFrame = CFrame.new(VD_InvisibleNV.Position)
        seat.Parent = Workspace

        local weld = Instance.new("Weld")
        weld.Part0 = seat
        weld.Part1 = torso
        weld.Parent = seat

        VD_InvisibleNV.Seat = seat
        VD_InvisibleNV.Weld = weld

        task.wait()
        seat.CFrame = savedCFrame
        VD_SetCharacterTransparency(char, 0.5)
        hum.WalkSpeed = VD.InvisibleSpeed or 16
    else
        VD.InvisibleNotVisual = false
        VD_InvisibleNV.Active = false
        if VD_InvisibleNV.Seat and VD_InvisibleNV.Seat.Parent then
            pcall(function() VD_InvisibleNV.Seat:Destroy() end)
        end
        VD_InvisibleNV.Seat = nil
        VD_InvisibleNV.Weld = nil
        VD_SetCharacterTransparency(char, 0)
        if VD_InvisibleNV.OriginalSpeed then
            hum.WalkSpeed = VD_InvisibleNV.OriginalSpeed
        end
        VD_InvisibleNV.OriginalSpeed = nil
    end
end

local function VD_UpdateInvisibleNotVisual()
    if not VD.InvisibleNotVisual then
        if VD_InvisibleNV.Active then VD_SetInvisibleNotVisual(false) end
        return
    end
    VD_SetInvisibleNotVisual(true)
end

local VD_MoonwalkState = {
    LastEnabled = false,
    Yaw = nil,
    Sway = 0,
}

local function VD_UpdateMoonwalk(deltaTime)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local cam = Workspace.CurrentCamera

    if VD.Moonwalk ~= VD_MoonwalkState.LastEnabled then
        if hum then hum.AutoRotate = not VD.Moonwalk end
        VD_MoonwalkState.LastEnabled = VD.Moonwalk
        if VD.Moonwalk and root then
            local _, y = root.CFrame:ToEulerAnglesYXZ()
            VD_MoonwalkState.Yaw = math.deg(y)
        end
    end

    if not VD.Moonwalk then
        if hum and not hum.AutoRotate then hum.AutoRotate = true end
        return
    end
    if not root or not hum or not cam or hum.Health <= 0 then return end

    hum.AutoRotate = false
    local look = cam.CFrame.LookVector
    local targetYaw = math.deg(math.atan2(look.X, look.Z)) + 180
    local currentYaw = VD_MoonwalkState.Yaw or targetYaw
    local diff = (targetYaw - currentYaw + 180) % 360 - 180
    local lerpSpeed = 0.22 * math.clamp((deltaTime or 1 / 60) * 60, 0, 3)
    currentYaw = currentYaw + diff * lerpSpeed
    VD_MoonwalkState.Yaw = currentYaw

    local moving = hum.MoveDirection.Magnitude > 0.01
    local targetSway = 0
    if moving then
        targetSway = math.sin(tick() * (VD.MoonwalkZigzagSpeed or 11)) * 48
    end
    VD_MoonwalkState.Sway = (VD_MoonwalkState.Sway or 0) + (targetSway - (VD_MoonwalkState.Sway or 0)) * 0.38
    root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(currentYaw + VD_MoonwalkState.Sway), 0)

    if moving then
        hum:Move(hum.MoveDirection * (VD.MoonwalkBoostPower or 1.08), false)
    end
end

LocalPlayer.CharacterRemoving:Connect(function()
    if VD_InvisibleNV.Seat and VD_InvisibleNV.Seat.Parent then
        pcall(function() VD_InvisibleNV.Seat:Destroy() end)
    end
    VD_InvisibleNV.Active = false
    VD_InvisibleNV.Seat = nil
    VD_InvisibleNV.Weld = nil
    VD_MoonwalkState.LastEnabled = false
    VD_MoonwalkState.Yaw = nil
    VD_MoonwalkState.Sway = 0
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if VD.InvisibleNotVisual then pcall(VD_SetInvisibleNotVisual, true) end
end)

local VD_PalletwrongConnection = nil
local VD_PalletwrongScanning = false

local function VD_DestroyPalletwrong(inst)
    if inst and inst:IsA("Model") and inst.Name == "Palletwrong" then
        pcall(function() inst:Destroy() end)
    end
end

local function VD_StartRemovePalletwrong()
    if VD_PalletwrongConnection then return end

    VD_PalletwrongConnection = Workspace.DescendantAdded:Connect(function(inst)
        if VD.KILLER_NoPalletStun then
            VD_DestroyPalletwrong(inst)
        end
    end)

    if VD_PalletwrongScanning then return end
    VD_PalletwrongScanning = true
    task.spawn(function()
        local descendants = Workspace:GetDescendants()
        for i, inst in ipairs(descendants) do
            if not VD.KILLER_NoPalletStun then break end
            VD_DestroyPalletwrong(inst)
            if i % 250 == 0 then task.wait() end
        end
        VD_PalletwrongScanning = false
    end)
end

local function VD_StopRemovePalletwrong()
    if VD_PalletwrongConnection then
        pcall(function() VD_PalletwrongConnection:Disconnect() end)
        VD_PalletwrongConnection = nil
    end
    VD_PalletwrongScanning = false
end

local function VD_UpdateRemovePalletwrong()
    if VD.KILLER_NoPalletStun then
        VD_StartRemovePalletwrong()
    else
        VD_StopRemovePalletwrong()
    end
end

do
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if not VD.AntiAFK then return end
        pcall(function()
            vu:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(0.2)
            vu:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end)
    end)
end

-- MAP CACHE (Generators / Gates / Hooks / Pallets / Windows)
local Vora_Cache = {
    Generators  = {},
    Gates       = {},
    Hooks       = {},
    Pallets     = {},
    Windows     = {},
    ClosestHook = nil,
    ExitPos     = nil
}

local function Vora_ScanMap()
    local map = Workspace:FindFirstChild("Map")
    if not map then
        Vora_Cache = {
            Generators = {}, Zombies = {}, Gates = {}, Hooks = {}, Pallets = {}, Windows = {}, ClosestHook = nil, ExitPos = nil, ExitPart = nil
        }
        return
    end

    local newGens, newZombies, newGates, newHooks, newPallets, newWindows = {}, {}, {}, {}, {}, {}
    local exitPos = nil
    local exitPart = nil

    if map:FindFirstChild("churchbell") then
        exitPart = map:FindFirstChild("churchbell")
        if exitPart:IsA("Model") then exitPart = exitPart.PrimaryPart or exitPart:FindFirstChildWhichIsA("BasePart") end
        if exitPart then exitPos = exitPart.Position else exitPos = Vector3.new(760.98, -20.14, -78.48) end
    end

    local finish = map:FindFirstChild("Finishline") or map:FindFirstChild("FinishLine") or map:FindFirstChild("Fininshline")
    if finish then
        local fp = finish:IsA("BasePart") and finish or (finish:IsA("Model") and finish:FindFirstChildWhichIsA("BasePart"))
        if fp then exitPos = fp.Position; exitPart = fp end
    end

    for _, obj in ipairs(map:GetDescendants()) do
        if obj:IsA("Model") then
            local part = obj:FindFirstChild("HitBox", true) or obj:FindFirstChild("GeneratorPoint", true) or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
            if part then
                local n = obj.Name
                if n == "Generator" then
                    table.insert(newGens, { model = obj, part = part })
                elseif n == "Gate" or n == "ExitGate" or obj:FindFirstChild("ExitLever") then
                    table.insert(newGates, { model = obj, part = part })
                elseif n == "Hook" then
                    table.insert(newHooks, { model = obj, part = part })
                elseif n == "Palletwrong" or n:lower():find("pallet") then
                    table.insert(newPallets, { model = obj, part = part })
                elseif n == "Window" then
                    table.insert(newWindows, { model = obj, part = part })
                end
            end
        elseif obj:IsA("BasePart") then
            if not exitPos and obj.Name:lower():find("finish") then
                exitPos = obj.Position
                exitPart = obj
            end
            if not exitPos and obj:IsA("MeshPart") then
                if obj.Material == Enum.Material.Limestone then
                    exitPos = Vector3.new(-947.90, 152.12, -7579.52)
                    exitPart = obj
                elseif obj.Material == Enum.Material.Leather then
                    exitPos = Vector3.new(1546.12, 152.21, -796.72)
                    exitPart = obj
                end
            end
            if obj.Name == "VaultTrigger" then
                table.insert(newWindows, { model = obj.Parent, part = obj })
            if obj.Name == "VaultPoint" and obj.Parent and obj.Parent.Name == "VaultTrigger" then
                table.insert(newWindows, { model = obj.Parent, part = obj })
            end
            if obj.Name == "PalletPoint" or obj.Name == "PalletPointSlide" then
                table.insert(newPallets, { model = obj.Parent, part = obj })
            end
        end
    end

    Vora_Cache.Generators = newGens
    Vora_Cache.Gates      = newGates
    Vora_Cache.Hooks      = newHooks
    Vora_Cache.Pallets    = newPallets
    Vora_Cache.Windows    = newWindows
    Vora_Cache.ExitPos    = exitPos
    Vora_Cache.ExitPart   = exitPart
    print("[Vora ScanMap] Generators:", #newGens, "Gates:", #newGates, "Hooks:", #newHooks, "Windows:", #newWindows)

    local root           = Root
    if root and #Vora_Cache.Hooks > 0 then
        local closest, closestDist = nil, math.huge
        for _, hook in ipairs(Vora_Cache.Hooks) do
            if hook.part then
                local d = (hook.part.Position - root.Position).Magnitude
                if d < closestDist then
                    closestDist = d; closest = hook
                end
            end
        end
        Vora_Cache.ClosestHook = closest
    end
end

-- RADAR SYSTEM
local radarGui = nil
local radarFrame = nil
local radarDots = {}
local radarObjectDots = {}

local RADAR_COLORS = {
    Killer    = Color3.fromRGB(255, 80, 80),     -- merah terang (tetap agar mudah dikenali)
    Survivor  = Color3.fromRGB(255, 255, 255),   -- putih
    Generator = Color3.fromRGB(0, 220, 255),     -- cyan
    Gate      = Color3.fromRGB(180, 240, 255),   -- cyan muda
    Pallet    = Color3.fromRGB(100, 220, 255),   -- cyan sedang
    Hook      = Color3.fromRGB(200, 200, 255),   -- putih kebiruan
    Window    = Color3.fromRGB(0, 200, 240),     -- cyan
    Zombie    = Color3.fromRGB(160, 255, 240)    -- cyan-hijau
}

local MaskColors = {
    Abysswalker = Color3.fromRGB(110, 20, 255),
    Cure = Color3.fromRGB(0, 100, 255),
    Hidden = Color3.fromRGB(170, 170, 170),
    Killer = Color3.fromRGB(255, 40, 40),
    Masked = Color3.fromRGB(255, 90, 20),
    Stalker = Color3.fromRGB(255, 0, 140),
    Veil = Color3.fromRGB(0, 200, 255),
    Slasher = Color3.fromRGB(180, 0, 255),
}

local function GetKillerColorForRadar(killerPlayer)
    return RADAR_COLORS.Killer
end

local function CreateRadarGUI()
    local parent = GetSafeGuiParent()
    if not parent then return false end
    
    if radarGui then pcall(function() radarGui:Destroy() end) end
    
    radarGui = Instance.new("ScreenGui")
    radarGui.Name = "VoraHub_RadarGUI"
    radarGui.ResetOnSpawn = false
    radarGui.IgnoreGuiInset = true
    radarGui.Parent = parent
    
    radarFrame = Instance.new("Frame")
    radarFrame.Name = "RadarFrame"
    radarFrame.Size = UDim2.new(0, VD.RADAR_Size, 0, VD.RADAR_Size)
    radarFrame.Position = UDim2.new(0, 10, 0, 120)
    radarFrame.BackgroundColor3 = Color3.fromRGB(5, 18, 25)
    radarFrame.BackgroundTransparency = 1 - VD.RADAR_Transparency
    radarFrame.BorderSizePixel = 0
    radarFrame.Active = true
    radarFrame.Draggable = true
    radarFrame.Parent = radarGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = VD.RADAR_Circle and UDim.new(1, 0) or UDim.new(0, 8)
    corner.Parent = radarFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 220, 255)
    stroke.Thickness = 2
    stroke.Parent = radarFrame

    -- Gradient latar radar: gelap bawah → sedikit cyan di atas
    local radarGrad = Instance.new("UIGradient")
    radarGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 30, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 12, 20))
    })
    radarGrad.Rotation = 90
    radarGrad.Parent = radarFrame
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, 0, 0, 20)
    titleText.BackgroundTransparency = 1
    titleText.Text = "◈ VORAHUB RADAR ◈"
    titleText.TextColor3 = Color3.fromRGB(0, 220, 255)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 12
    titleText.Parent = radarFrame
    
    local crossH = Instance.new("Frame")
    crossH.Size = UDim2.new(1, -40, 0, 1)
    crossH.Position = UDim2.new(0, 20, 0.5, 0)
    crossH.BackgroundColor3 = Color3.fromRGB(0, 180, 220)
    crossH.BackgroundTransparency = 0.5
    crossH.BorderSizePixel = 0
    crossH.Parent = radarFrame
    
    local crossV = Instance.new("Frame")
    crossV.Size = UDim2.new(0, 1, 1, -40)
    crossV.Position = UDim2.new(0.5, 0, 0, 20)
    crossV.BackgroundColor3 = Color3.fromRGB(0, 180, 220)
    crossV.BackgroundTransparency = 0.5
    crossV.BorderSizePixel = 0
    crossV.Parent = radarFrame
    
    local centerDot = Instance.new("Frame")
    centerDot.Size = UDim2.new(0, 8, 0, 8)
    centerDot.Position = UDim2.new(0.5, -4, 0.5, -4)
    centerDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    centerDot.BorderSizePixel = 0
    centerDot.Parent = radarFrame
    local centerDotStroke = Instance.new("UIStroke")
    centerDotStroke.Color = Color3.fromRGB(0, 220, 255)
    centerDotStroke.Thickness = 1.5
    centerDotStroke.Parent = centerDot
    
    local centerCorner = Instance.new("UICorner")
    centerCorner.CornerRadius = UDim.new(1, 0)
    centerCorner.Parent = centerDot
    
    local rangeText = Instance.new("TextLabel")
    rangeText.Name = "RangeText"
    rangeText.Size = UDim2.new(1, 0, 0, 14)
    rangeText.Position = UDim2.new(0, 0, 1, -14)
    rangeText.BackgroundTransparency = 1
    rangeText.Text = "Range: ".. VD.RADAR_Range.. "m"
    rangeText.TextColor3 = Color3.fromRGB(0, 200, 240)
    rangeText.Font = Enum.Font.Gotham
    rangeText.TextSize = 10
    rangeText.Parent = radarFrame
    
    radarDots = {}
    for i = 1, 30 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 6, 0, 6)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.BorderSizePixel = 0
        dot.Visible = false
        dot.Parent = radarFrame
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        table.insert(radarDots, dot)
    end
    
    radarObjectDots = {}
    for i = 1, 80 do
        local objDot = Instance.new("Frame")
        objDot.Size = UDim2.new(0, 4, 0, 4)
        objDot.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
        objDot.BorderSizePixel = 0
        objDot.Visible = false
        objDot.Parent = radarFrame
        local objCorner = Instance.new("UICorner")
        objCorner.CornerRadius = UDim.new(1, 0)
        objCorner.Parent = objDot
        table.insert(radarObjectDots, objDot)
    end
    
    return true
end

local function UpdateRadar()
    if not VD.RADAR_Enabled then
        if radarGui then radarGui.Enabled = false end
        return
    end
    
    if not radarGui or not radarFrame or not radarGui.Parent then
        if not CreateRadarGUI() then return end
    end
    
    radarGui.Enabled = true
    radarFrame.Visible = true
    
    local camera = workspace.CurrentCamera
    local root = Root or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
    if not camera or not root then return end
    
    radarFrame.Size = UDim2.new(0, VD.RADAR_Size, 0, VD.RADAR_Size)
    radarFrame.BackgroundTransparency = 1 - VD.RADAR_Transparency
    
    local corner = radarFrame:FindFirstChildOfClass("UICorner")
    if corner then
        corner.CornerRadius = VD.RADAR_Circle and UDim.new(1, 0) or UDim.new(0, 8)
    end
    
    local rangeText = radarFrame:FindFirstChild("RangeText")
    if rangeText then rangeText.Text = "Range: ".. VD.RADAR_Range.. "m" end
    
    for _, dot in ipairs(radarDots) do dot.Visible = false end
    for _, dot in ipairs(radarObjectDots) do dot.Visible = false end
    
    local halfSize = VD.RADAR_Size / 2
    local margin = 5
    local usableHalf = halfSize - margin
    local scale = usableHalf / VD.RADAR_Range
    
    local cameraLook = camera.CFrame.LookVector
    local playerAngle = math.atan2(-cameraLook.X, -cameraLook.Z)
    local cosAngle = math.cos(playerAngle)
    local sinAngle = math.sin(playerAngle)
    local playerPos = root.Position
    
    local function WorldToRadar(worldPos)
        local deltaX = worldPos.X - playerPos.X
        local deltaZ = worldPos.Z - playerPos.Z
        local distance = math.sqrt(deltaX * deltaX + deltaZ * deltaZ)
        if distance > VD.RADAR_Range then return nil end
        
        local rotatedX = deltaX * cosAngle - deltaZ * sinAngle
        local rotatedZ = deltaX * sinAngle + deltaZ * cosAngle
        local radarX = rotatedX * scale
        local radarY = rotatedZ * scale
        local clampedX = math.clamp(radarX, -usableHalf + 4, usableHalf - 4)
        local clampedY = math.clamp(radarY, -usableHalf + 4, usableHalf - 4)
        return Vector2.new(halfSize + clampedX, halfSize + clampedY)
    end
    
    local dotIndex = 1
    local objIndex = 1
    local drawnPlayers = {}
    local drawnObjects = {}
    
    local function AddObjectDot(pos, color, size, identifier)
        if not pos or drawnObjects[identifier] then return end
        drawnObjects[identifier] = true
        if objIndex <= #radarObjectDots then
            local dot = radarObjectDots[objIndex]
            dot.Size = UDim2.new(0, size, 0, size)
            dot.Position = UDim2.new(0, pos.X - (size/2), 0, pos.Y - (size/2))
            dot.BackgroundColor3 = color
            dot.Visible = true
            objIndex = objIndex + 1
        end
    end

    if VD.RADAR_ShowKiller or VD.RADAR_ShowSurvivor then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if playerRoot then
                    local isKiller = IsKiller(player)
                    local shouldShow = (isKiller and VD.RADAR_ShowKiller) or (not isKiller and VD.RADAR_ShowSurvivor)
                    if shouldShow and not drawnPlayers[player.UserId] then
                        local pos = WorldToRadar(playerRoot.Position)
                        if pos and dotIndex <= #radarDots then
                            drawnPlayers[player.UserId] = true
                            local dot = radarDots[dotIndex]
                            if isKiller then
                                dot.Size = UDim2.new(0, 7, 0, 7)
                                dot.Position = UDim2.new(0, pos.X - 3.5, 0, pos.Y - 3.5)
                                dot.BackgroundColor3 = GetKillerColorForRadar(player)
                            else
                                dot.Size = UDim2.new(0, 6, 0, 6)
                                dot.Position = UDim2.new(0, pos.X - 3, 0, pos.Y - 3)
                                dot.BackgroundColor3 = RADAR_COLORS.Survivor
                            end
                            dot.Visible = true
                            dotIndex = dotIndex + 1
                        end
                    end
                end
            end
        end
    end

    if VD.RADAR_ShowGenerator then
        for _, gen in ipairs(Vora_Cache.Generators or {}) do
            if gen.model and gen.model.Parent and gen.part then
                local pos = WorldToRadar(gen.part.Position)
                if pos then AddObjectDot(pos, RADAR_COLORS.Generator, 5, "gen_" .. tostring(gen.model)) end
            end
        end
    end

    if VD.RADAR_ShowPallet then
        for _, pallet in ipairs(_Cache.Pallets or {}) do
            if pallet.model and pallet.model.Parent and pallet.part then
                local isBroken = false
                local ok, db = pcall(function() return pallet.model:GetAttribute("Destroyed") or pallet.model:GetAttribute("Broken") or pallet.model:GetAttribute("IsBroken") end)
                if ok and db then isBroken = true end
                if not isBroken and not pallet.model:FindFirstChildWhichIsA("BasePart", true) then
                    isBroken = true
                end
                if not isBroken then
                    local pos = WorldToRadar(pallet.part.Position)
                    if pos then AddObjectDot(pos, RADAR_COLORS.Pallet, 4, "pallet_" .. tostring(pallet.model)) end
                end
            end
        end
    end

    if VD.RADAR_ShowHook then
        for _, hook in ipairs(Vora_Cache.Hooks or {}) do
            if hook.model and hook.model.Parent and hook.part then
                local pos = WorldToRadar(hook.part.Position)
                if pos then AddObjectDot(pos, RADAR_COLORS.Hook, 5, "hook_" .. tostring(hook.model)) end
            end
        end
    end

    if VD.RADAR_ShowGate then
        for _, gate in ipairs(Vora_Cache.Gates or {}) do
            if gate.model and gate.model.Parent and gate.part then
                local pos = WorldToRadar(gate.part.Position)
                if pos then AddObjectDot(pos, RADAR_COLORS.Gate, 5, "gate_" .. tostring(gate.model)) end
            end
        end
    end

    if VD.RADAR_ShowWindow then
        for _, window in ipairs(Vora_Cache.Windows or {}) do
            if window.model and window.model.Parent and window.part then
                local pos = WorldToRadar(window.part.Position)
                if pos then AddObjectDot(pos, RADAR_COLORS.Window, 4, "window_" .. tostring(window.model)) end
            end
        end
    end

    if VD.RADAR_ShowZombie then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
                local lower = obj.Name:lower()
                if lower:find("scp") or lower:find("zombie") or lower:find("servant") or lower:find("infected") or lower:find("walker") then
                    local refPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                    if refPart then
                        local pos = WorldToRadar(refPart.Position)
                        if pos then AddObjectDot(pos, RADAR_COLORS.Zombie, 5, "zombie_" .. tostring(obj)) end
                    end
                end
            end
        end
    end
end

-- TELEPORT HELPERS
local originalCanCollide = {}

local function Vora_TeleportToPosition(pos)
    if not pos then return false end
    local root = Root
    if not root then return false end

    if LocalPlayer.Character then
        root.Anchored = true
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                if originalCanCollide[part] == nil then originalCanCollide[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    end

    root.CFrame = CFrame.new(pos + Vector3.new(0, VD.TP_Offset, 0))

    task.delay(0.3, function()
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    pcall(function()
                        part.CanCollide = (originalCanCollide[part] ~= nil) and originalCanCollide[part] or true
                    end)
                end
            end
            root.Anchored = false
        end
        originalCanCollide = {}
    end)
    return true
end

function Vora_TeleportToGenerator(index)
    if not Vora_Cache or not Vora_Cache.Generators or #Vora_Cache.Generators == 0 then print("[Vora HUB] Generator tidak ditemukan") return false end

    local sorted = {}
    for _, gen in ipairs(Vora_Cache.Generators) do
        table.insert(sorted, {gen = gen, dist = (Root and (gen.part.Position - Root.Position).Magnitude) or math.huge})
    end
    table.sort(sorted, function(a, b) return a.dist < b.dist end)

    local target = sorted[index or 1]
    if not target then return false end
    return Vora_TeleportToPosition(target.gen.part.Position)
end

function Vora_TeleportToGate()
    if not Vora_Cache or not Vora_Cache.Gates or #Vora_Cache.Gates == 0 then print("[Vora HUB] Gate tidak ditemukan") return false end
    local closest, closestDist = nil, math.huge
    for _, gate in ipairs(Vora_Cache.Gates) do
        local dist = (Root and (gate.part.Position - Root.Position).Magnitude) or math.huge
        if dist < closestDist then
            closestDist = dist
            closest = gate
        end
    end

    if not closest then return false end
    return Vora_TeleportToPosition(closest.part.Position)
end

function Vora_TeleportToHook()
    if not Vora_Cache or not Vora_Cache.ClosestHook then print("[Vora HUB] Hook tidak ditemukan") return false end
    return Vora_TeleportToPosition(Vora_Cache.ClosestHook.part.Position)
end

-- MAP CHANGE DETECTION
local CurrentMapName = nil
local MapWatchConnections = {}
local MapScanQueued       = false

local function DisconnectMapWatchers()
    for _, conn in ipairs(MapWatchConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    MapWatchConnections = {}
end

local function CheckMapChange()
    local map = Workspace:FindFirstChild("Map")
    local mapName = map and map.Name or "Unknown"
    if CurrentMapName ~= mapName then
        VD._BeatSurvivorDone = false
        VD._BeatKillerDone = false
        VD._LastTeleAway = 0
        VD._KillerTarget = nil
    end
    CurrentMapName = mapName

    Vora_ScanMap()
end

local function QueueMapScan(delaySec)
    if MapScanQueued then return end
    MapScanQueued = true
    task.delay(delaySec or 0.15, function()
        MapScanQueued = false
        if VD.Destroyed then return end
        CheckMapChange()
    end)
end

local function WatchCurrentMap(map)
    DisconnectMapWatchers()
    if not map then return end

    local function onDescendantAdded(descendant)
        if descendant:IsA("Model") or descendant:IsA("Folder") then
            local n = descendant.Name:lower()
            if n:find("generator") or n:find("mesin") or n:find("pallet") or n:find("window") or n:find("hook") or n:find("gate") then
                task.delay(0.5, function()
                    if not descendant.Parent then return end
                    local part = descendant:FindFirstChild("HitBox", true) or descendant:FindFirstChild("GeneratorPoint", true) or descendant.PrimaryPart or descendant:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        if n:find("generator") or n:find("mesin") then table.insert(Vora_Cache.Generators, {model=descendant, part=part})
                        elseif n:find("pallet") then table.insert(Vora_Cache.Pallets, {model=descendant, part=part})
                        elseif n:find("window") then table.insert(Vora_Cache.Windows, {model=descendant, part=part})
                        elseif n:find("hook") then table.insert(Vora_Cache.Hooks, {model=descendant, part=part})
                        elseif n:find("gate") then table.insert(Vora_Cache.Gates, {model=descendant, part=part})
                        end
                    end
                end)
            end
        end
    end

    table.insert(MapWatchConnections, map.DescendantAdded:Connect(onDescendantAdded))

    table.insert(MapWatchConnections, map.AncestryChanged:Connect(function(_, parent)
        if not parent then QueueMapScan(0.05) end
    end))
end

Workspace.ChildAdded:Connect(function(child)
    if child and child.Name == "Map" then
        WatchCurrentMap(child)
        QueueMapScan(0.05)
    end
end)

Workspace.ChildRemoved:Connect(function(child)
    if child and child.Name == "Map" then
        DisconnectMapWatchers()
        QueueMapScan(0.05)
    end
end)

do
    local map = Workspace:FindFirstChild("Map")
    if map then WatchCurrentMap(map) end
    CheckMapChange()
end

-- AUTO ATTACK (Killer)
local function Vora_AutoAttack()
    if not VD.AUTO_Attack or GetRole() ~= "Killer" then return end
    local root = Root
    if not root then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsSurvivor(player) and player.Character then
            local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local tHum = player.Character:FindFirstChildOfClass("Humanoid")

            if tRoot and tHum and tHum.MaxHealth > 0 then
                local pct = tHum.Health / tHum.MaxHealth
                if pct > 0.25 and (tRoot.Position - root.Position).Magnitude <= VD.AUTO_AttackRange then
                    pcall(function()
                        local r = ReplicatedStorage:FindFirstChild("Remotes")
                        local a = r and r:FindFirstChild("Attacks")
                        local b = a and a:FindFirstChild("BasicAttack")
                        if b then b:FireServer(false) end
                    end)
                    break
                end
            end
        end
    end
end

-- TOF TRACER - Sistem prediksi warna real-time
do
    local TweenService = game:GetService("TweenService")

    -- ScreenGui container
    local tracerGui = Instance.new("ScreenGui")
    tracerGui.Name           = "Vora_TofTracer"
    tracerGui.ResetOnSpawn   = false
    tracerGui.IgnoreGuiInset = true
    tracerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    tracerGui.DisplayOrder   = 999
    pcall(function() tracerGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end)

    -- Garis tracer (Frame yang dirotasi)
    local tracerLine = Instance.new("Frame")
    tracerLine.Name                    = "TracerLine"
    tracerLine.BackgroundColor3        = Color3.fromRGB(255, 55, 55)
    tracerLine.BackgroundTransparency  = 0.15
    tracerLine.BorderSizePixel         = 0
    tracerLine.AnchorPoint             = Vector2.new(0.5, 0.5)
    tracerLine.Size                    = UDim2.new(0, 0, 0, 3)
    tracerLine.Visible                 = false
    tracerLine.Parent                  = tracerGui
    Instance.new("UICorner", tracerLine).CornerRadius = UDim.new(1, 0)

    -- Dot di ujung garis (di posisi torso killer)
    local tracerDot = Instance.new("Frame")
    tracerDot.Name                   = "TracerDot"
    tracerDot.BackgroundColor3       = Color3.fromRGB(255, 55, 55)
    tracerDot.BackgroundTransparency = 0.1
    tracerDot.BorderSizePixel        = 0
    tracerDot.AnchorPoint            = Vector2.new(0.5, 0.5)
    tracerDot.Size                   = UDim2.new(0, 10, 0, 10)
    tracerDot.Visible                = false
    tracerDot.Parent                 = tracerGui
    Instance.new("UICorner", tracerDot).CornerRadius = UDim.new(1, 0)

    -- Label status di atas dot
    local tracerLabel = Instance.new("TextLabel")
    tracerLabel.Name                   = "TracerLabel"
    tracerLabel.BackgroundTransparency = 1
    tracerLabel.TextColor3             = Color3.fromRGB(255, 55, 55)
    tracerLabel.TextStrokeTransparency = 0.3
    tracerLabel.Font                   = Enum.Font.GothamBold
    tracerLabel.TextSize               = 13
    tracerLabel.Text                   = "ToF IN RANGE"
    tracerLabel.Size                   = UDim2.new(0, 160, 0, 40)
    tracerLabel.AnchorPoint            = Vector2.new(0.5, 1)
    tracerLabel.Visible                = false
    tracerLabel.Parent                 = tracerGui

    -- Helper: gambar garis AÃ¢â€ â€™B di layar
    local function setLine(fromV2, toV2)
        local delta  = toV2 - fromV2
        local length = delta.Magnitude
        local center = (fromV2 + toV2) / 2
        local angle  = math.deg(math.atan2(delta.Y, delta.X))
        tracerLine.Position = UDim2.new(0, center.X, 0, center.Y)
        tracerLine.Size     = UDim2.new(0, length, 0, 3)
        tracerLine.Rotation = angle
        tracerLine.Visible  = true
    end

    -- State warna sebelumnya (cegah update redundant setiap frame)
    local _lastSafe    = nil
    local _lastDot     = 0

    local COLOR_SAFE   = Color3.fromRGB(0, 220, 100)
    local COLOR_DANGER = Color3.fromRGB(255, 55, 55)

    local _lastTracerScan = 0
    RunService.Heartbeat:Connect(function()
        if not VD.AUTO_ToFAim or not VD.AUTO_ToFTracer then
            tracerLine.Visible  = false
            tracerDot.Visible   = false
            tracerLabel.Visible = false
            _lastSafe = nil
            return
        end
        if tick() - _lastTracerScan < 0.05 then return end
        _lastTracerScan = tick()

        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then
            tracerLine.Visible  = false
            tracerDot.Visible   = false
            tracerLabel.Visible = false
            return
        end

        -- Cari killer terdekat dalam range ToF
        local bestRoot, bestDist = nil, (VD.AUTO_ToFAimRange or 90)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer
                and plr.Team and plr.Team.Name == "Killer"
                and plr.Character then
                local kroot = plr.Character:FindFirstChild("HumanoidRootPart")
                local khum  = plr.Character:FindFirstChildOfClass("Humanoid")
                if kroot and khum and khum.Health > 0 then
                    local d = (kroot.Position - myRoot.Position).Magnitude
                    if d <= bestDist then
                        bestDist = d
                        bestRoot = kroot
                    end
                end
            end
        end

        if not bestRoot then
            tracerLine.Visible  = false
            tracerDot.Visible   = false
            tracerLabel.Visible = false
            _lastSafe = nil
            return
        end

        -- Cari HumanoidRootPart killer (tengah badan)
        local killerChar = bestRoot.Parent
        local targetCenter = bestRoot.Position

        -- Konversi posisi target ke 2D layar (titik ujung garis)
        local cam = workspace.CurrentCamera
        local torsoVP, torsoOnScreen = cam:WorldToViewportPoint(targetCenter)
        if not torsoOnScreen then
            tracerLine.Visible  = false
            tracerDot.Visible   = false
            tracerLabel.Visible = false
            return
        end

        local rightArm = myChar:FindFirstChild("Right Arm") or myRoot
        local armPos = rightArm.Position
        local originPos = armPos - Vector3.new(0, rightArm.Size.Y/2, 0)

        local dir          = targetCenter - myRoot.Position
        local dirUnit      = (dir.Magnitude > 0.01) and dir.Unit or Vector3.new(0,0,1)

        local camLook      = cam.CFrame.LookVector
        local dotVal       = camLook:Dot(dirUnit)
        local dotThreshold = VD.AUTO_ToFDotThreshold or 0.5
        local isSafe       = (dotVal >= dotThreshold)

        if isSafe ~= _lastSafe then
            local targetColor = isSafe and COLOR_SAFE or COLOR_DANGER
            TweenService:Create(tracerLine,  TweenInfo.new(0.1), {BackgroundColor3 = targetColor}):Play()
            TweenService:Create(tracerDot,   TweenInfo.new(0.1), {BackgroundColor3 = targetColor}):Play()
            TweenService:Create(tracerLabel, TweenInfo.new(0.1), {TextColor3 = targetColor}):Play()
            _lastSafe = isSafe
        end

        local dotPct = math.floor(math.clamp(dotVal / dotThreshold * 100, 0, 100))
        local statusText
        if isSafe then
            statusText = "SAFE" .. dotPct .. "%"
        else
            statusText = "DANGER" .. dotPct .. "%"
        end
        tracerLabel.Text = statusText

        local originVP, originOnScreen = cam:WorldToViewportPoint(originPos)

        if not originOnScreen then
            tracerLine.Visible = false
        else
            local screenFrom  = Vector2.new(originVP.X, originVP.Y)
            local screenTorso = Vector2.new(torsoVP.X, torsoVP.Y)

            setLine(screenFrom, screenTorso)
        end

        tracerDot.Position = UDim2.new(0, torsoVP.X, 0, torsoVP.Y)
        tracerDot.Visible  = true

        tracerLabel.Position = UDim2.new(0, torsoVP.X - 80, 0, torsoVP.Y - 16)
        tracerLabel.Visible  = true
    end)
end

-- AUTO VAULT (Survivor) - otomatis saat dekat Window
local _vaultedWindows  = {}
local _lastVaultScan   = 0

RunService.Heartbeat:Connect(function()
    if VD.SURV_FastVault then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                char:SetAttribute("vaultspeed", (VD.SURV_VaultSpeed or 13) / 10)
            end
        end)
    end
    
    if VD.SURV_FleeKiller then
        pcall(function()
            local root = Root
            if not root then return end
            if GetRole() == "Killer" then return end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and IsKiller(player) then
                    local killerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if killerRoot and (killerRoot.Position - root.Position).Magnitude <= (VD.SURV_FleeDistance or 40) then
                        local direction = (root.Position - killerRoot.Position).Unit
                        root.CFrame = CFrame.new(root.Position + direction * ((VD.SURV_FleeDistance or 40) + 15), root.Position + direction * 100)
                        break
                    end
                end
            end
        end)
    end
end)

RunService.Heartbeat:Connect(function()
    if not VD.SURV_AutoVault then return end
    if GetRole() ~= "Survivor" then return end
    if tick() - _lastVaultScan < 0.15 then return end
    _lastVaultScan = tick()

    pcall(function()
        local char   = LocalPlayer.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        local hum    = char and char:FindFirstChildOfClass("Humanoid")
        if not myRoot or not hum or hum.Health <= 0 then return end

        local vel = myRoot.AssemblyLinearVelocity
        if vel.Magnitude < 1 then return end

        local remotes   = ReplicatedStorage:FindFirstChild("Remotes")
        local winFolder = remotes and remotes:FindFirstChild("Window")
        local vaultEv   = winFolder and winFolder:FindFirstChild("VaultCommit")
        if not vaultEv then return end

        local windowGroups = {}
        for _, win in ipairs(Vora_Cache.Windows or {}) do
            local part = win.part or win.model
            if part then
                local rootWindow = part.Parent
                if part.Name == "VaultPoint" and part.Parent and part.Parent.Name == "VaultTrigger" then
                    rootWindow = part.Parent.Parent
                elseif part.Name == "VaultTrigger" and part.Parent then
                    rootWindow = part.Parent
                end

                if rootWindow then
                    windowGroups[rootWindow] = windowGroups[rootWindow] or {}

                    local exists = false
                    for _, p in ipairs(windowGroups[rootWindow]) do
                        if p == part then exists = true break end
                    end
                    if not exists then
                        table.insert(windowGroups[rootWindow], part)
                    end
                end
            end
        end

        for rootWindow, parts in pairs(windowGroups) do
            local function getVTPosition(vt)
                if vt:IsA("BasePart") then
                    return vt.Position
                end
                if vt:IsA("Model") then
                    if vt.PrimaryPart then return vt.PrimaryPart.Position end
                    local bp = vt:FindFirstChildWhichIsA("BasePart", true)
                    if bp then return bp.Position end
                end
                return nil
            end

            local allVTs = {}
            for _, child in ipairs(rootWindow:GetChildren()) do
                if child.Name == "VaultTrigger" then
                    table.insert(allVTs, child)
                end
            end

            if #allVTs == 0 then continue end

            local nearestVT, nearestVTDist = nil, math.huge
            for _, vt in ipairs(allVTs) do
                local pos = getVTPosition(vt)
                if pos then
                    local d = (myRoot.Position - pos).Magnitude
                    if d < nearestVTDist then
                        nearestVTDist = d
                        nearestVT = vt
                    end
                end
            end

            if not nearestVT or nearestVTDist > 6.0 then continue end

            local lastUsed = _vaultedWindows[rootWindow] or 0
            if tick() - lastUsed < 3.0 then continue end

            local finalTarget = nearestVT

            local remotes2 = ReplicatedStorage:FindFirstChild("Remotes")
            local winFold  = remotes2 and remotes2:FindFirstChild("Window")
            if winFold and finalTarget then
                local vaultEvent     = winFold:FindFirstChild("VaultEvent")
                local vaultBindable  = winFold:FindFirstChild("Vaultbindable")
                local fastvault      = winFold:FindFirstChild("fastvault")
                local vaultComplete1 = winFold:FindFirstChild("VaultCompleteEventpart1")
                local vaultComplete  = winFold:FindFirstChild("VaultCompleteEvent")

                if vaultEvent    then pcall(function() vaultEvent:FireServer(finalTarget, true) end) end
                if vaultBindable then pcall(function() vaultBindable:Fire(finalTarget, true) end) end
                if fastvault     then pcall(function() fastvault:FireServer(LocalPlayer) end) end
                if vaultComplete1 then pcall(function() vaultComplete1:FireServer() end) end
                if vaultComplete  then pcall(function() vaultComplete:FireServer(finalTarget, false) end) end
            end

            _vaultedWindows[rootWindow] = tick()
            break
        end

    end)
end)

-- AUTO PALLET DROP (Survivor) - otomatis saat killer dekat
local _lastPalletDrop  = 0
local _usedPallets     = {}

local function getKillerRoot()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if IsSurvivor and IsSurvivor(plr) then continue end
        local char = plr.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then return root end
        end
    end
    return nil
end

local _lastPalletScan = 0
RunService.Heartbeat:Connect(function()
    if not VD.SURV_AutoPallet then return end
    if GetRole() ~= "Survivor" then return end
    if tick() - _lastPalletScan < 0.2 then return end
    _lastPalletScan = tick()
    if tick() - _lastPalletDrop < 2.5 then return end

    pcall(function()
        local char   = LocalPlayer.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        local hum    = char and char:FindFirstChildOfClass("Humanoid")
        if not myRoot or not hum or hum.Health <= 0 then return end

        local killerRoot = getKillerRoot()
        if not killerRoot then return end
        if (myRoot.Position - killerRoot.Position).Magnitude > VD.SURV_AutoPalletDist then return end

        local remotes    = ReplicatedStorage:FindFirstChild("Remotes")
        local palletFold = remotes and remotes:FindFirstChild("Pallet")
        local dropEvent  = palletFold and palletFold:FindFirstChild("PalletDropEvent")
        if not dropEvent then return end

        local bestPalletwrong, bestDist = nil, 8

        local function findPalletPointSlide(model)
            local slide = model:FindFirstChild("PalletPointSlide")
            if slide then return slide end
            for _, child in ipairs(model:GetDescendants()) do
                if child.Name == "PalletPointSlide" then return child end
            end
            return model:FindFirstChild("PalletPoint")
        end

        for _, pal in ipairs(Vora_Cache.Pallets or {}) do
            local palModel = pal.model
            if not palModel then continue end
            if _usedPallets[palModel] then continue end

            local refPart = pal.part or palModel:FindFirstChild("PalletPoint")
                         or palModel:FindFirstChild("PalletPointSlide")
            if not refPart then continue end

            local ok, pos = pcall(function() return refPart.Position end)
            if not ok or not pos then continue end

            local d = (myRoot.Position - pos).Magnitude
            if d < bestDist then
                bestDist = d
                bestPalletwrong = palModel
            end
        end

        if bestPalletwrong then
            local fireTarget = findPalletPointSlide(bestPalletwrong)
            if fireTarget then
                pcall(function() dropEvent:FireServer(fireTarget) end)
                _usedPallets[bestPalletwrong] = true
                _lastPalletDrop = tick()
            end
        end
    end)
end)

-- HITBOX EXPAND (Killer)
local OriginalHitboxSizes = {}

local function Vora_UpdateHitboxes()
    local function restoreAll()
        for player, originalSize in pairs(OriginalHitboxSizes) do
            if player and player.Character then
                local r = player.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    r.Size = originalSize; r.Transparency = 1; r.CanCollide = true
                end
            end
        end
        OriginalHitboxSizes = {}
    end

    if GetRole() ~= "Killer" or not VD.HITBOX_Enabled then
        restoreAll()
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsSurvivor(player) then
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum  = char:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health > 0 then
                    if not OriginalHitboxSizes[player] then
                        OriginalHitboxSizes[player] = root.Size
                    end
                    local sz          = VD.HITBOX_Size
                    root.Size         = Vector3.new(sz, sz, sz)
                    root.CanCollide   = false
                    root.Transparency = 0.7
                elseif root and OriginalHitboxSizes[player] then
                    root.Size                   = OriginalHitboxSizes[player]
                    root.Transparency           = 1
                    root.CanCollide             = true
                    OriginalHitboxSizes[player] = nil
                end
            end
        end
    end
end

-- DESTROY ALL PALLETS (Killer)
local LastPalletDestroyMap = 0

local function Vora_DestroyAllPallets()
    if not VD.KILLER_DestroyPallets or GetRole() ~= "Killer" then return end

    if tick() - LastPalletDestroyMap < 1.5 then return end

    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        local p = r and r:FindFirstChild("Pallet")
        local j = p and p:FindFirstChild("Jason")
        if not j then return end

        local dg = j:FindFirstChild("Destroy-Global")
        local d  = j:FindFirstChild("Destroy")

        if dg then pcall(function() dg:FireServer() end) end

        if d then
            local sentCount = 0
            for _, pallet in ipairs(Vora_Cache.Pallets) do
                if pallet.model then
                    sentCount = sentCount + 1
                    task.spawn(function()
                        pcall(function() d:FireServer(pallet.model) end)
                    end)
                end
            end
        end
    end)

    LastPalletDestroyMap = tick()
end

-- DOUBLE TAP (Killer)
local LastDoubleTapTime = 0

local function Vora_DoubleTap()
    if not VD.KILLER_DoubleTap or GetRole() ~= "Killer" then return end
    if tick() - LastDoubleTapTime < 0.5 then return end
    pcall(function()
        local r  = ReplicatedStorage:FindFirstChild("Remotes")
        local a  = r and r:FindFirstChild("Attacks")
        local ba = a and a:FindFirstChild("BasicAttack")
        if ba then
            ba:FireServer(false)
            task.wait(0.05)
            ba:FireServer(false)
            LastDoubleTapTime = tick()
        end
    end)
end

-- INFINITE LUNGE (Killer)
local function Vora_InfiniteLunge()
    if not VD.KILLER_InfiniteLunge or GetRole() ~= "Killer" then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.Velocity = root.CFrame.LookVector * 100 + Vector3.new(0, 10, 0)
    end
end

-- FLING
function Vora_FlingNearest()
    if not VD.FLING_Enabled then return end
    local root = Root
    if not root then return end
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local tr = player.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local dist = (tr.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist; closest = player
                end
            end
        end
    end
    if closest and closest.Character then
        local tr = closest.Character:FindFirstChild("HumanoidRootPart")
        if tr then
            local originalPos = root.CFrame
            for _ = 1, 10 do
                root.CFrame      = tr.CFrame
                root.Velocity    = Vector3.new(VD.FLING_Strength, VD.FLING_Strength / 2, VD.FLING_Strength)
                root.RotVelocity = Vector3.new(9999, 9999, 9999)
                task.wait()
            end
            root.CFrame      = originalPos
            root.Velocity    = Vector3.zero
            root.RotVelocity = Vector3.zero
        end
    end
end

function Vora_FlingAll()
    if not VD.FLING_Enabled then return end
    local root = Root
    if not root then return end
    local originalPos = root.CFrame
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local tr = player.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                for _ = 1, 5 do
                    root.CFrame      = tr.CFrame
                    root.Velocity    = Vector3.new(VD.FLING_Strength, VD.FLING_Strength / 2, VD.FLING_Strength)
                    root.RotVelocity = Vector3.new(9999, 9999, 9999)
                    task.wait()
                end
            end
        end
    end
    root.CFrame      = originalPos
    root.Velocity    = Vector3.zero
    root.RotVelocity = Vector3.zero
end

-- BEAT GAME SURVIVOR (teleport to exit)
local function Vora_BeatGameSurvivor()
    if not VD.BEAT_Survivor or GetRole() ~= "Survivor" then return end
    local root = Root
    if not root then return end
    local map = Workspace:FindFirstChild("Map")
    if not map then return end

    local exitPos = nil
    local finishPart = nil
    pcall(function()
        if map:FindFirstChild("RooftopHitbox") or map:FindFirstChild("Rooftop") then
            finishPart = map:FindFirstChild("RooftopHitbox") or map:FindFirstChild("Rooftop")
            if finishPart:IsA("Model") then finishPart = finishPart.PrimaryPart or finishPart:FindFirstChildWhichIsA("BasePart") end
            if finishPart then exitPos = finishPart.Position else exitPos = Vector3.new(3098.16, 454.04, -4918.74) end
            return
        end
        if map:FindFirstChild("HooksMeat") then
            finishPart = map:FindFirstChild("HooksMeat")
            if finishPart:IsA("Model") then finishPart = finishPart.PrimaryPart or finishPart:FindFirstChildWhichIsA("BasePart") end
            if finishPart then exitPos = finishPart.Position else exitPos = Vector3.new(1546.12, 152.21, -796.72) end
            return
        end
        if Vora_Cache and Vora_Cache.ExitPos then
            exitPos = Vora_Cache.ExitPos
            finishPart = Vora_Cache.ExitPart
            return
        end
    end)

    if not exitPos then return end
    VD._LastFinishPos    = VD._LastFinishPos or nil
    VD._BeatSurvivorDone = VD._BeatSurvivorDone or false
    if VD._BeatSurvivorDone then return end

    VD._BeatSurvivorDone = true
    VD._LastFinishPos    = exitPos

    task.spawn(function()
        task.delay(4, function()
            if VD._BeatSurvivorDone then VD._BeatSurvivorDone = false end
        end)

        for i = 1, 10 do
            if not Root or not Root.Parent then break end

            pcall(function()
                local event = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("Game"):FindFirstChild("PlayerActionEvent")
                if event then
                    if event:IsA("RemoteEvent") then
                        event:FireServer("ESCAPED", 200)
                    elseif event:IsA("BindableEvent") then
                        event:Fire("ESCAPED", 200)
                    end
                end
            end)

            if firetouchinterest and finishPart then
                pcall(function() firetouchinterest(Root, finishPart, 0) end)
                pcall(function() firetouchinterest(Root, finishPart, 1) end)
            end

            if i == 1 then
                Root.Velocity = Vector3.zero
                if exitPos then
                    Root.CFrame = CFrame.new(exitPos + Vector3.new(0, 3, 0))
                end
            end

            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:MoveTo(exitPos)
                end
            end)

            task.wait(0.2)
        end
    end)
end

-- BEAT GAME KILLER (auto chase & attack survivors)
local function Vora_BeatGameKiller()
    if not VD.BEAT_Killer then
        VD._KillerTarget = nil; return
    end
    if GetRole() ~= "Killer" then
        VD._KillerTarget = nil; return
    end
    local root = Root
    if not root then return end

    local target        = VD._KillerTarget
    local needNewTarget = true
    if target and target.Character then
        local tr = target.Character:FindFirstChild("HumanoidRootPart")
        local th = target.Character:FindFirstChildOfClass("Humanoid")
        if tr and th and th.MaxHealth > 0 and (th.Health / th.MaxHealth) > 0.25 then
            needNewTarget = false
        else
            VD._KillerTarget = nil
        end
    end

    if needNewTarget then
        local survivors = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and IsSurvivor(player) and player.Character then
                local pr = player.Character:FindFirstChild("HumanoidRootPart")
                local ph = player.Character:FindFirstChildOfClass("Humanoid")
                if pr and ph and ph.MaxHealth > 0 and (ph.Health / ph.MaxHealth) > 0.25 then table.insert(survivors, player) end
            end
        end
        if #survivors > 0 then
            local closest, closestDist = nil, math.huge
            for _, player in ipairs(survivors) do
                local pr   = player.Character:FindFirstChild("HumanoidRootPart")
                local dist = (pr.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist; closest = player
                end
            end
            VD._KillerTarget = closest
            target           = closest
        else
            VD._KillerTarget = nil; return
        end
    end

    if not target or not target.Character then return end
    local tr = target.Character:FindFirstChild("HumanoidRootPart")
    local th = target.Character:FindFirstChildOfClass("Humanoid")
    if not tr or not th then
        VD._KillerTarget = nil; return
    end
    if th.MaxHealth <= 0 or (th.Health / th.MaxHealth) <= 0.25 then
        VD._KillerTarget = nil; return
    end

    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
    end

    local dir = (root.Position - tr.Position).Unit
    if dir.Magnitude ~= dir.Magnitude then dir = Vector3.new(1, 0, 0) end
    root.CFrame = CFrame.new(tr.Position + dir * 3 + Vector3.new(0, 1, 0), tr.Position)

    pcall(function()
        local r  = ReplicatedStorage:FindFirstChild("Remotes")
        local a  = r and r:FindFirstChild("Attacks")
        local ba = a and a:FindFirstChild("BasicAttack")
        if ba then ba:FireServer(false) end
    end)
end

-- AUTO HOOK (Killer)
local IsAutoHooking = false

local function Vora_AutoHook()
    if not VD.KILLER_AutoHook or GetRole() ~= "Killer" then return end
    if IsAutoHooking then return end

    local root = Root
    if not root then return end

    local closestDowned, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsSurvivor(player) and player.Character then
            local tr  = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if tr and hum then
                local pct = (hum.MaxHealth > 0) and (hum.Health / hum.MaxHealth) or 0
                if pct <= 0.25 and pct > 0 then
                    local isHooked = false
                    if Vora_Cache and Vora_Cache.Hooks then
                        for _, hh in ipairs(Vora_Cache.Hooks) do
                            if hh.part and (hh.part.Position - tr.Position).Magnitude < 4.5 then
                                isHooked = true; break
                            end
                        end
                    end

                    if not isHooked then
                        local dist = (tr.Position - root.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist; closestDowned = tr
                        end
                    end
                end
            end
        end
    end

    if closestDowned then
        local closestHook, hDist = nil, math.huge
        for _, h in ipairs(Vora_Cache.Hooks) do
            if h.part then
                local hd = (h.part.Position - closestDowned.Position).Magnitude
                if hd < hDist then
                    hDist = hd; closestHook = h
                end
            end
        end

        if closestHook then
            IsAutoHooking = true
            task.spawn(function()
                root.CFrame = CFrame.new(closestDowned.Position + Vector3.new(0, 3, 0), closestDowned.Position)
                task.wait(0.3)

                pcall(function()
                    local vim = game:GetService("VirtualInputManager")
                    vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.05)
                    vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)

                task.wait(0.8)

                if root and root.Parent then
                    root.CFrame = CFrame.new(closestHook.part.Position + Vector3.new(0, 3, 0))
                    task.wait(0.3)

                    pcall(function()
                        local event = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("Carry"):FindFirstChild("HookEvent")
                        if event and event:IsA("RemoteEvent") then
                            local hookPoint = nil
                            if closestHook.model then
                                hookPoint = closestHook.model:FindFirstChild("HookPoint") or closestHook.model:FindFirstChild("HookHitbox")
                            end
                            if not hookPoint then hookPoint = closestHook.part end

                            event:FireServer(hookPoint)
                        end
                    end)
                end

                task.wait(1)
                IsAutoHooking = false
            end)
        end
    end
end

-- MAP SCAN LOOP & MAIN AUTO LOOP
task.spawn(function()
    while not VD.Destroyed do
        if Root and Vora_Cache.Hooks and #Vora_Cache.Hooks > 0 then
            local closest, closestDist = nil, math.huge
            for _, hook in ipairs(Vora_Cache.Hooks) do
                if hook.part then
                    local d = (hook.part.Position - Root.Position).Magnitude
                    if d < closestDist then
                        closestDist = d; closest = hook
                    end
                end
            end
            Vora_Cache.ClosestHook = closest
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while not VD.Destroyed do
        pcall(Vora_AutoAttack)
        pcall(Vora_UpdateHitboxes)
        pcall(Vora_DestroyAllPallets)
        pcall(Vora_DoubleTap)
        pcall(Vora_InfiniteLunge)

        pcall(Vora_BeatGameSurvivor)
        pcall(Vora_BeatGameKiller)
        pcall(Vora_AutoHook)
        task.wait(0.12)
    end
end)

-- DRAWING-BASED ESP (boxes / skeleton / offscreen / velocity)
local function DrawingESP_create()
    local skel = {}
    for i = 1, 14 do
        skel[i] = SafeDrawing("Line")
        if skel[i] then
            skel[i].Thickness = 1; skel[i].Visible = false
        end
    end
    local box = {}
    for i = 1, 4 do
        box[i] = SafeDrawing("Line")
        if box[i] then
            box[i].Thickness = 1; box[i].Visible = false
        end
    end
    return {
        Box       = box,
        Name      = SafeDrawing("Text"),
        Dist      = SafeDrawing("Text"),
        Skel      = skel,
        HealthBg  = SafeDrawing("Square"),
        HealthBar = SafeDrawing("Square"),
        Offscreen = SafeDrawing("Triangle"),
        VelLine   = SafeDrawing("Line"),
        VelArrow  = SafeDrawing("Triangle")
    }
end

local function DrawingESP_setup(esp)
    if not esp then return end
    for _, l in ipairs(esp.Box) do
        if l then
            l.Thickness = 1; l.Visible = false
        end
    end
    for _, l in ipairs(esp.Skel) do
        if l then
            l.Thickness = 1; l.Visible = false
        end
    end
    if esp.Name then
        esp.Name.Size = 14; esp.Name.Font = Drawing.Fonts.UI; esp.Name.Center = true; esp.Name.Outline = true; esp.Name.Visible = false
    end
    if esp.Dist then
        esp.Dist.Size = 12; esp.Dist.Font = Drawing.Fonts.Monospace; esp.Dist.Center = true; esp.Dist.Outline = true; esp.Dist.Color =
            Color3.fromRGB(180, 180, 180); esp.Dist.Visible = false
    end
    if esp.HealthBg then
        esp.HealthBg.Filled = true; esp.HealthBg.Color = Color3.fromRGB(25, 25, 25); esp.HealthBg.Visible = false
    end
    if esp.HealthBar then
        esp.HealthBar.Filled = true; esp.HealthBar.Visible = false
    end
    if esp.Offscreen then
        esp.Offscreen.Filled = true; esp.Offscreen.Visible = false
    end
    if esp.VelLine then
        esp.VelLine.Thickness = 2; esp.VelLine.Color = Color3.fromRGB(0, 255, 255); esp.VelLine.Visible = false
    end
    if esp.VelArrow then
        esp.VelArrow.Filled = true; esp.VelArrow.Color = Color3.fromRGB(0, 255, 255); esp.VelArrow.Visible = false
    end
end

local Bones_R15 = {
    { "Head",       "UpperTorso" }, { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" }
}
local Bones_R6 = {
    { "Head", "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" }, { "Torso", "Left Leg" }, { "Torso", "Right Leg" }
}

local function DrawingESP_cleanup()
    local valid = {}
    for _, p in ipairs(Players:GetPlayers()) do valid[p] = true end
    for player, esp in pairs(DrawingESP.cache) do
        if not valid[player] then
            if esp then
                pcall(function()
                    for _, l in ipairs(esp.Box) do if l then SafeRemove(l) end end
                    for _, l in ipairs(esp.Skel) do if l then SafeRemove(l) end end
                    if esp.Name then SafeRemove(esp.Name) end
                    if esp.Dist then SafeRemove(esp.Dist) end
                    if esp.HealthBg then SafeRemove(esp.HealthBg) end
                    if esp.HealthBar then SafeRemove(esp.HealthBar) end
                    if esp.Offscreen then SafeRemove(esp.Offscreen) end
                    if esp.VelLine then SafeRemove(esp.VelLine) end
                    if esp.VelArrow then SafeRemove(esp.VelArrow) end
                end)
            end
            DrawingESP.cache[player]        = nil
            DrawingESP.velocityData[player] = nil
        end
    end
end

local function DrawingESP_hideAll(esp)
    for _, l in ipairs(esp.Box) do if l then l.Visible = false end end
    for _, l in ipairs(esp.Skel) do if l then l.Visible = false end end
    if esp.Name then esp.Name.Visible = false end
    if esp.Dist then esp.Dist.Visible = false end
    if esp.HealthBg then esp.HealthBg.Visible = false end
    if esp.HealthBar then esp.HealthBar.Visible = false end
    if esp.VelLine then esp.VelLine.Visible = false end
    if esp.VelArrow then esp.VelArrow.Visible = false end
end

local function DrawingESP_render(esp, player, char, cam, screenSize, screenCenter)
    if not esp or not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not head then
        DrawingESP_hideAll(esp); return
    end

    local myRoot = Root
    local dist   = myRoot and (root.Position - myRoot.Position).Magnitude or 0
    if dist > VD.MaxDistance then
        DrawingESP_hideAll(esp); return
    end

    local isKillerPlayer = IsKiller(player)
    local visible = true
    if VD.AIM_VisCheck or VD.AIM_Enabled then
        local camPos                      = cam.CFrame.Position
        local params                      = RaycastParams.new()
        params.FilterType                 = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = { cam, LocalPlayer.Character, char }
        local ray                         = workspace:Raycast(camPos, head.Position - camPos, params)
        visible                           = (ray == nil)
    end

    local col      = isKillerPlayer
        and (visible and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(200, 50, 50))
        or (visible and Color3.fromRGB(0, 220, 255) or Color3.fromRGB(0, 160, 200))
    local skelCol  = visible and Color3.fromRGB(180, 245, 255) or Color3.fromRGB(255, 255, 255)

    local headPos  = head.Position + Vector3.new(0, 0.5, 0)
    local feetPos  = root.Position - Vector3.new(0, 3, 0)
    local rs       = cam:WorldToViewportPoint(root.Position)
    local hs       = cam:WorldToViewportPoint(headPos)
    local fs       = cam:WorldToViewportPoint(feetPos)
    local onScreen = rs.Z > 0 and rs.X > 0 and rs.X < screenSize.X and rs.Y > 0 and rs.Y < screenSize.Y

    if not onScreen then
        DrawingESP_hideAll(esp)
        if VD.ESP_Offscreen then
            local dx    = rs.X - screenCenter.X
            local dy    = rs.Y - screenCenter.Y
            local angle = math.atan2(dy, dx)
            local edge  = 50
            local aX    = math.clamp(screenCenter.X + math.cos(angle) * (screenSize.X / 2 - edge), edge,
                screenSize.X - edge)
            local aY    = math.clamp(screenCenter.Y + math.sin(angle) * (screenSize.Y / 2 - edge), edge,
                screenSize.Y - edge)
            local fwd   = Vector2.new(math.cos(angle), math.sin(angle))
            local right = Vector2.new(-fwd.Y, fwd.X)
            local pos   = Vector2.new(aX, aY)
            local sz    = 12
            if esp.Offscreen then
                esp.Offscreen.PointA  = pos + fwd * sz
                esp.Offscreen.PointB  = pos - fwd * sz / 2 - right * sz / 2
                esp.Offscreen.PointC  = pos - fwd * sz / 2 + right * sz / 2
                esp.Offscreen.Color   = col
                esp.Offscreen.Visible = true
            end
        else
            if esp.Offscreen then esp.Offscreen.Visible = false end
        end
        return
    end

    if esp.Offscreen then esp.Offscreen.Visible = false end

    local boxTop    = hs.Y
    local boxBottom = fs.Y
    local boxHeight = math.abs(boxBottom - boxTop)
    local boxWidth  = boxHeight * 0.6
    local cx        = rs.X

    if esp.Box[1] then
        esp.Box[1].From = Vector2.new(cx - boxWidth / 2, boxTop); esp.Box[1].To = Vector2.new(cx + boxWidth / 2, boxTop); esp.Box[1].Color =
            col; esp.Box[1].Visible = true
    end
    if esp.Box[2] then
        esp.Box[2].From = Vector2.new(cx + boxWidth / 2, boxTop); esp.Box[2].To = Vector2.new(cx + boxWidth / 2,
            boxBottom); esp.Box[2].Color = col; esp.Box[2].Visible = true
    end
    if esp.Box[3] then
        esp.Box[3].From = Vector2.new(cx + boxWidth / 2, boxBottom); esp.Box[3].To = Vector2.new(cx - boxWidth / 2,
            boxBottom); esp.Box[3].Color = col; esp.Box[3].Visible = true
    end
    if esp.Box[4] then
        esp.Box[4].From = Vector2.new(cx - boxWidth / 2, boxBottom); esp.Box[4].To = Vector2.new(cx - boxWidth / 2,
            boxTop); esp.Box[4].Color = col; esp.Box[4].Visible = true
    end

    local visualTextActive = false
    pcall(function()
        local fn = getgenv().NEX_VD_VisualESP_HasPlayerText
        visualTextActive = type(fn) == "function" and fn(player) == true
    end)

    if esp.Name then
        if visualTextActive then
            esp.Name.Visible = false
        else
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(cx, boxTop - 18)
            esp.Name.Color = col
            esp.Name.Visible = true
        end
    end
    if esp.Dist then
        if visualTextActive then
            esp.Dist.Visible = false
        else
            esp.Dist.Text = math.floor(dist) .. "m"
            esp.Dist.Position = Vector2.new(cx, boxBottom + 4)
            esp.Dist.Visible = true
        end
    end

    if VD.ESP_Skeleton and hum then
        local bones = (char:FindFirstChild("Torso") and Bones_R6) or Bones_R15
        for i, b in ipairs(bones) do
            if esp.Skel[i] then
                local p1 = char:FindFirstChild(b[1])
                local p2 = char:FindFirstChild(b[2])
                if p1 and p2 then
                    local s1 = cam:WorldToViewportPoint(p1.Position)
                    local s2 = cam:WorldToViewportPoint(p2.Position)
                    if s1.Z > 0 and s2.Z > 0 then
                        esp.Skel[i].From    = Vector2.new(s1.X, s1.Y)
                        esp.Skel[i].To      = Vector2.new(s2.X, s2.Y)
                        esp.Skel[i].Color   = skelCol
                        esp.Skel[i].Visible = true
                    else
                        esp.Skel[i].Visible = false
                    end
                else
                    esp.Skel[i].Visible = false
                end
            end
        end
    else
        for _, l in ipairs(esp.Skel) do if l then l.Visible = false end end
    end

    -- Velocity arrows
    local vd = DrawingESP.velocityData[player]
    if not vd then
        vd = { pos = root.Position, vel = Vector3.zero, time = tick() }
        DrawingESP.velocityData[player] = vd
    end
    local now = tick()
    local dt  = now - vd.time
    if dt > 0.03 then
        local rawVel = (root.Position - vd.pos) / dt
        vd.vel       = vd.vel * 0.7 + rawVel * 0.3
        vd.pos       = root.Position
        vd.time      = now
    end

    if VD.ESP_Velocity then
        local velFlat = Vector3.new(vd.vel.X, 0, vd.vel.Z)
        local velMag  = velFlat.Magnitude
        if velMag > 2 then
            local futurePos    = root.Position + velFlat.Unit * math.clamp(velMag * 0.4, 5, 20)
            local futureScreen = cam:WorldToViewportPoint(futurePos)
            if futureScreen.Z > 0 then
                if esp.VelLine then
                    esp.VelLine.From = Vector2.new(rs.X, rs.Y); esp.VelLine.To = Vector2.new(futureScreen.X,
                        futureScreen.Y); esp.VelLine.Visible = true
                end
                local dx  = futureScreen.X - rs.X
                local dy  = futureScreen.Y - rs.Y
                local len = math.sqrt(dx * dx + dy * dy)
                if len > 5 and esp.VelArrow then
                    local fx, fy         = dx / len, dy / len
                    esp.VelArrow.PointA  = Vector2.new(futureScreen.X, futureScreen.Y)
                    esp.VelArrow.PointB  = Vector2.new(futureScreen.X - fx * 10 + fy * 5, futureScreen.Y - fy * 10 - fx *
                        5)
                    esp.VelArrow.PointC  = Vector2.new(futureScreen.X - fx * 10 - fy * 5, futureScreen.Y - fy * 10 + fx *
                        5)
                    esp.VelArrow.Visible = true
                elseif esp.VelArrow then
                    esp.VelArrow.Visible = false
                end
            else
                if esp.VelLine then esp.VelLine.Visible = false end
                if esp.VelArrow then esp.VelArrow.Visible = false end
            end
        else
            if esp.VelLine then esp.VelLine.Visible = false end
            if esp.VelArrow then esp.VelArrow.Visible = false end
        end
    else
        if esp.VelLine then esp.VelLine.Visible = false end
        if esp.VelArrow then esp.VelArrow.Visible = false end
    end
end

-- AIMBOT (Camera-based) + Spear Aimbot
local Aimbot = {}
local State  = { AimTarget = nil, AimHolding = false }

function Aimbot.GetClosestTarget(cam)
    if not cam then return nil end
    if GetRole() ~= "Survivor" then return nil end

    local root = Root
    if not root then return nil end

    local closestPlayer = nil
    local closestDist   = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsKiller(player) and player.Character then
            local tr = player.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local dist = (tr.Position - root.Position).Magnitude

                local passVis = true
                if VD.AIM_VisCheck then
                    local camPos = cam.CFrame.Position
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Blacklist
                    params.FilterDescendantsInstances = { cam, LocalPlayer.Character, player.Character }
                    local ray = workspace:Raycast(camPos, tr.Position - camPos, params)
                    passVis = (ray == nil)
                end

                if passVis and dist < closestDist then
                    closestDist = dist
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

function Aimbot.GetPredictedPosition(target, targetPart)
    if not target or not targetPart then return nil end
    local pos = targetPart.Position
    if VD.AIM_Predict then
        local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if root then pos = pos + root.AssemblyLinearVelocity * 0.1 end
    end
    return pos
end

function Aimbot.AimAt(cam, targetPos)
    if not cam or not targetPos then return end
    local cur    = cam.CFrame
    local smooth = VD.AIM_Smooth or 0.3
    cam.CFrame   = cur:Lerp(CFrame.new(cur.Position, targetPos), smooth)
end

function Aimbot.Update(cam, screenSize, screenCenter)
    if not VD.AIM_Enabled or GetRole() ~= "Survivor" then
        State.AimTarget = nil; return
    end
    if VD.AIM_UseRMB and not State.AimHolding then
        State.AimTarget = nil; return
    end
    local target = Aimbot.GetClosestTarget(cam)
    State.AimTarget = target
    if target and target.Character then
        local tr = target.Character:FindFirstChild("HumanoidRootPart")
        if tr then
            local pred = Aimbot.GetPredictedPosition(target, tr)
            if pred then Aimbot.AimAt(cam, pred) end
        end
    end
end

-- Spear Aimbot (gravity compensation)
local function SpearAimbotCalc(targetPos)
    if not VD.SPEAR_Aimbot or GetRole() ~= "Killer" then return nil end
    local root = Root
    if not root then return nil end
    local startPos = root.Position + Vector3.new(0, 2, 0)
    local distance = (targetPos - startPos).Magnitude
    local gravity  = VD.SPEAR_Gravity or 50
    local speed    = VD.SPEAR_Speed or 100
    local time     = distance / speed
    local drop     = 0.5 * gravity * time * time
    return targetPos + Vector3.new(0, drop, 0)
end

local function UpdateSpearAim()
    if not VD.SPEAR_Aimbot or GetRole() ~= "Killer" then return end
    local root = Root
    if not root then return end
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsSurvivor(player) and player.Character then
            local tr = player.Character:FindFirstChild("HumanoidRootPart")
            local th = player.Character:FindFirstChildOfClass("Humanoid")
            if tr and th and th.MaxHealth > 0 and (th.Health / th.MaxHealth) > 0.25 then
                local dist = (tr.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist; closest = player
                end
            end
        end
    end
    if closest and closest.Character then
        local tr = closest.Character:FindFirstChild("HumanoidRootPart")
        if tr then
            local aimPos = SpearAimbotCalc(tr.Position)
            if aimPos then
                local cam = workspace.CurrentCamera
                if cam then cam.CFrame = CFrame.new(cam.CFrame.Position, aimPos) end
            end
        end
    end
end

-- Input handling for Aimbot RMB & Touch (Mobile Support)
UserInputService.InputBegan:Connect(function(input, gpe)
    if State.Unloaded then return end
    if VD.AIM_Enabled and VD.AIM_UseRMB then
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            State.AimHolding = true
        elseif input.UserInputType == Enum.UserInputType.Touch and not gpe then
            State.AimHolding = true
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if State.Unloaded then return end
    if VD.AIM_Enabled and VD.AIM_UseRMB then
        if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
            State.AimHolding = false
            State.AimTarget  = nil
        end
    end
end)


do -- Masukin ke dalam Tab Map
    local tpMapSection = MappingTab:AddSection({
        Position = "Center",
        Name = "Teleport",
        Icon      = "solar:map-point-bold",
        Box       = true,
        BoxBorder = true,
        Opened    = false,
    })
    local function getTeleportPlayerNames()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(names, p.Name) end
        end
        table.sort(names)
        return names
    end

    local tpPlayerDropdown = tpMapSection:AddDropdown({
        Name = "Select Player to Teleport",
        Flag = "TP_TargetPlayer",
        Values = getTeleportPlayerNames(),
        Multi = false,
        Callback = function(option)
            if type(option) == "table" then option = option[1] end
            VD.TP_TargetPlayer = option or ""
        end
    })

    tpMapSection:AddButton({ Name = "Refresh Players", Callback = function()
        pcall(function() tpPlayerDropdown:SetValues(getTeleportPlayerNames()) end)
    end })

    tpMapSection:AddButton({ Name = "Teleport to Player", Callback = function()
        pcall(function()
            local targetName = VD.TP_TargetPlayer
            if not targetName or targetName == "" then return end
            local player = Players:FindFirstChild(targetName)
            local root = Root
            local targetRoot = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root and targetRoot then
                root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
            end
        end)
    end })

    tpMapSection:AddButton({ Name = "TP to Gen", Callback = function() pcall(function() Vora_TeleportToGenerator(1) end) end })
    tpMapSection:AddButton({ Name = "TP to Gate", Callback = function() pcall(NEX_TeleportToGate) end })
    tpMapSection:AddButton({ Name = "TP to Hook", Callback = function() pcall(Vora_TeleportToHook) end })
end

do -- Masukin ke dalam Tab Map
    local radarTab = MappingFeatureTabs.Radar
    if radarTab then
        local radarSection = radarTab:AddSection({
            Position = "Center",
            Name = "Radar Configuration",
            Icon      = "solar:radar-bold",
            Box       = true,
            BoxBorder = true,
            Opened    = false,
        })
        
        radarSection:AddToggle({
            Default = false,
            Name = "Radar Enabled", Flag = "Radar Enabled",
            Callback = function(state)
                VD.RADAR_Enabled = state
                if not state and radarGui then radarGui.Enabled = false end
            end
        })
        
        radarSection:AddSlider({
            Name = "Radar Size", Flag = "Radar Size",
            Min = 100, Max = 300, Default = 150,
            Callback = function(value) VD.RADAR_Size = value end
        })
        
        radarSection:AddSlider({
            Name = "Radar Range", Flag = "Radar Range",
            Min = 50, Max = 500, Default = 250,
            Callback = function(value) VD.RADAR_Range = value end
        })
        
        radarSection:AddSlider({
            Name = "Radar Transparency", Flag = "Radar Transparency",
            Min = 0, Max = 100, Default = 20,
            Callback = function(value) VD.RADAR_Transparency = value / 100 end
        })
        
        radarSection:AddToggle({
            Default = false,
            Name = "Radar Circle Mode", Flag = "Radar Circle Mode",
            Callback = function(state) VD.RADAR_Circle = state end
        })
        
        local radarFilterSection = radarTab:AddSection({
            Position = "Center",
            Name = "Radar Filters",
            Icon      = "solar:filter-bold",
            Box       = true,
            BoxBorder = true,
            Opened    = false,
        })
        
        radarFilterSection:AddToggle({ Default = false, Name = "Show Killer", Flag = "Radar Show Killer", Callback = function(state) VD.RADAR_ShowKiller = state end })
        radarFilterSection:AddToggle({ Default = false, Name = "Show Survivor", Flag = "Radar Show Survivor", Callback = function(state) VD.RADAR_ShowSurvivor = state end })
        radarFilterSection:AddToggle({ Default = false, Name = "Show Generator", Flag = "Radar Show Generator", Callback = function(state) VD.RADAR_ShowGenerator = state end })
        radarFilterSection:AddToggle({ Default = false, Name = "Show Pallet", Flag = "Radar Show Pallet", Callback = function(state) VD.RADAR_ShowPallet = state end })
        radarFilterSection:AddToggle({ Default = false, Name = "Show Hook", Flag = "Radar Show Hook", Callback = function(state) VD.RADAR_ShowHook = state end })
        radarFilterSection:AddToggle({ Default = false, Name = "Show Gate", Flag = "Radar Show Gate", Callback = function(state) VD.RADAR_ShowGate = state end })
        radarFilterSection:AddToggle({ Default = false, Name = "ShowWindow", Flag = "Radar Show Window", Callback = function(state) VD.RADAR_ShowWindow = state end })
        radarFilterSection:AddToggle({ Default = false, Name = "Show Zombie", Flag = "Radar Show Zombie", Callback = function(state) VD.RADAR_ShowZombie = state end })
    end
end

-- REMOVE PALLETWRONG (replaces patched No Pallet Stun)
function SetupNoPalletStun()
    pcall(VD_UpdateRemovePalletwrong)
end

-- ANTI BLIND (Flashlight)
function SetupAntiBlind()
    pcall(function()
        local r  = ReplicatedStorage:FindFirstChild("Remotes")
        local i  = r and r:FindFirstChild("Items")
        local fl = i and i:FindFirstChild("Flashlight")
        local gb = fl and fl:FindFirstChild("GotBlinded")
        if not (gb and gb:IsA("RemoteEvent")) then return end

        local ok, mt = pcall(function() return getrawmetatable(game) end)
        if ok and mt and setreadonly then
            pcall(function()
                setreadonly(mt, false)
                local old = mt.__namecall
                mt.__namecall = newcclosure(function(self, ...)
                    if not checkcaller() and VD.KILLER_AntiBlind and self == gb then
                        local method = getnamecallmethod()
                        if method == "FireServer" and GetRole() == "Killer" then
                            return nil
                        end
                    end
                    return old(self, ...)
                end)
                setreadonly(mt, true)
            end)
        end
    end)
end
pcall(SetupAntiBlind)

-- AUTO AIM: TWIST OF FATE (cache fireRemote saja)
local function SetupToFRemoteCache()
    task.spawn(function()
        local ok, err = pcall(function()
            local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
            local items   = remotes and remotes:WaitForChild("Items", 15)
            local tof     = items and items:WaitForChild("Twist of Fate", 15)
            local fireRemote = tof and tof:WaitForChild("Fire", 15)
            if fireRemote and fireRemote:IsA("RemoteEvent") then
                Vora_ToFFireRemote = fireRemote
                print("[ToF] Fire remote cached:", fireRemote:GetFullName())
            else
                warn("[ToF] Fire remote not found or wrong type")
            end
        end)
        if not ok then warn("[ToF] SetupToFRemoteCache failed:", err) end
    end)
end
pcall(SetupToFRemoteCache)

-- CAMERA / FOV / THIRD PERSON / SHIFT LOCK
local OriginalFOV          = nil
local OriginalCameraType   = nil
local OriginalCameraOffset = nil
local ThirdPersonWasActive = false
local FOVWasActive         = false

local function UpdateCameraFOV()
    local cam = workspace.CurrentCamera
    if not cam then return end

    if VD.CAM_FOVEnabled then
        if not FOVWasActive then
            OriginalFOV = cam.FieldOfView
            FOVWasActive = true
        end
        cam.FieldOfView = VD.CAM_FOV or 90
    elseif FOVWasActive then
        if OriginalFOV then cam.FieldOfView = OriginalFOV end
        OriginalFOV = nil
        FOVWasActive = false
    end
end

local function UpdateThirdPerson()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local shouldBeActive = VD.CAM_ThirdPerson and GetRole() == "Killer"
    if shouldBeActive then
        if not ThirdPersonWasActive then
            OriginalCameraType = cam.CameraType
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            OriginalCameraOffset = hum and hum.CameraOffset or Vector3.new(0, 0, 0)
        end
        cam.CameraType = Enum.CameraType.Custom
        local char     = LocalPlayer.Character
        local hum      = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.CameraOffset = Vector3.new(2, 1, 8) end
        ThirdPersonWasActive = true
    elseif ThirdPersonWasActive then
        if OriginalCameraType then
            cam.CameraType = OriginalCameraType; OriginalCameraType = nil
        end
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.CameraOffset = OriginalCameraOffset or Vector3.new(0, 0, 0) end
        OriginalCameraOffset = nil
        ThirdPersonWasActive = false
    end
end

local _shiftLockWasActive = false

local function UpdateShiftLock()
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local cam  = workspace.CurrentCamera

    if VD.CAM_ShiftLock then
        if not char or not root or not cam then return end

        if hum then hum.AutoRotate = false end
        _shiftLockWasActive = true

        local flatLook = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
        if flatLook.Magnitude > 0.001 then
            local lookUnit = flatLook.Unit
            root.CFrame = CFrame.new(root.Position, root.Position + lookUnit)
        end
    else
        if _shiftLockWasActive then
            if hum then hum.AutoRotate = true end
            _shiftLockWasActive = false
        end
    end
end

-- NO FOG
local FogCache = {}

local function RemoveFog()
    pcall(function()
        local map = Workspace:FindFirstChild("Map")
        if map then
            for _, obj in ipairs(map:GetDescendants()) do
                if obj.Name:lower():find("fog") or obj:IsA("Atmosphere") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") then
                    if not FogCache[obj] then
                        FogCache[obj] = {
                            enabled = obj:IsA("PostEffect") and obj.Enabled or true,
                            parent =
                                obj.Parent
                        }
                    end
                    if obj:IsA("PostEffect") then obj.Enabled = false else obj.Parent = nil end
                end
            end
        end
    end)
    pcall(function()
        local lt = game:GetService("Lighting")
        for _, obj in ipairs(lt:GetChildren()) do
            if obj:IsA("Atmosphere") or obj.Name:lower():find("fog") then
                if not FogCache[obj] then FogCache[obj] = { enabled = true, parent = obj.Parent } end
                if obj:IsA("Atmosphere") then obj.Density = 0 else obj.Parent = nil end
            end
        end
        lt.FogEnd   = 100000
        lt.FogStart = 0
    end)
end

local function RestoreFog()
    pcall(function()
        for obj, data in pairs(FogCache) do
            if obj and data.parent then
                if obj:IsA("PostEffect") then obj.Enabled = data.enabled else obj.Parent = data.parent end
            end
        end
        FogCache = {}
        game:GetService("Lighting").FogEnd = 1000
    end)
end

-- NO SLOWDOWN
local function UpdateNoSlowdown()
    if not VD.KILLER_NoSlowdown or GetRole() ~= "Killer" then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed < 16 then hum.WalkSpeed = VD.SPEED_Value or 16 end
end

-- KUNCI KECEPATAN / ANTI BEKU (__newindex Hook)
function SetupAntiStunSlowdown()
    if getgenv().Vora_AntiStunHooked then return end
    getgenv().Vora_AntiStunHooked = true

    pcall(function()
        local ok, mt = pcall(function() return getrawmetatable(game) end)
        if ok and mt and setreadonly then
            pcall(function()
                setreadonly(mt, false)
                local oldNI = mt.__newindex
                mt.__newindex = newcclosure(function(t, k, v)
                    if not checkcaller() and VD.KILLER_NoSlowdown and GetRole() == "Killer" then
                        if k == "WalkSpeed" and typeof(v) == "number" and v < 16 and typeof(t) == "Instance" and t:IsA("Humanoid") then
                            return oldNI(t, k, VD.SPEED_Value or 16)
                        end
                        if k == "Anchored" and v == true and typeof(t) == "Instance" and t:IsA("BasePart") and t.Name == "HumanoidRootPart" then
                            return oldNI(t, k, false)
                        end
                    end
                    return oldNI(t, k, v)
                end)
                setreadonly(mt, true)
            end)
        end
    end)
end
task.spawn(SetupAntiStunSlowdown)

-- FOV CIRCLE
local FOVCircle = nil
if DrawingAvailable then
    FOVCircle = SafeDrawing("Circle")
    if FOVCircle then
        FOVCircle.Thickness    = 1.5
        FOVCircle.Color        = Color3.fromRGB(0, 220, 255)
        FOVCircle.Filled       = false
        FOVCircle.NumSides     = 64
        FOVCircle.Transparency = 0.4
        FOVCircle.Visible      = false
    end
end

-- RENDERSTEP: Drawing ESP / Aimbot / Camera
local function OnRenderStep()
    if VD.Destroyed then
        if DrawingAvailable then
            for _, esp in pairs(DrawingESP.cache) do
                if esp then
                    for _, l in ipairs(esp.Box) do if l then SafeRemove(l) end end
                    for _, l in ipairs(esp.Skel) do if l then SafeRemove(l) end end
                    if esp.Name then SafeRemove(esp.Name) end
                    if esp.Dist then SafeRemove(esp.Dist) end
                    if esp.HealthBg then SafeRemove(esp.HealthBg) end
                    if esp.HealthBar then SafeRemove(esp.HealthBar) end
                    if esp.Offscreen then SafeRemove(esp.Offscreen) end
                    if esp.VelLine then SafeRemove(esp.VelLine) end
                    if esp.VelArrow then SafeRemove(esp.VelArrow) end
                end
            end
            DrawingESP.cache = {}
if FOVCircle then SafeRemove(FOVCircle) end
        end
        return
    end

    Camera = Workspace.CurrentCamera or Camera
    local cam = Camera
    if not cam then return end
    local screenSize   = cam.ViewportSize
    local screenCenter = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    local now          = tick()
    local canUpdateESP = now >= Perf.NextDrawingESP
    if canUpdateESP then
        Perf.NextDrawingESP = now + Perf.DrawingESPInterval
    end

    -- Drawing ESP & Chams
    if DrawingAvailable then
        if VD.DRAWING_ESP then
            if canUpdateESP then
                DrawingESP_cleanup()

                -- Players
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        if not DrawingESP.cache[player] then
                            DrawingESP.cache[player] = DrawingESP_create()
                            DrawingESP_setup(DrawingESP.cache[player])
                        end
                        DrawingESP_render(DrawingESP.cache[player], player, player.Character, cam, screenSize, screenCenter)
                    end
                end
            end
        else
            for _, esp in pairs(DrawingESP.cache) do
                if esp then
                    pcall(function()
                        for _, l in ipairs(esp.Box) do if l then SafeRemove(l) end end
                        for _, l in ipairs(esp.Skel) do if l then SafeRemove(l) end end
                        if esp.Name then SafeRemove(esp.Name) end
                        if esp.Dist then SafeRemove(esp.Dist) end
                        if esp.HealthBg then SafeRemove(esp.HealthBg) end
                        if esp.HealthBar then SafeRemove(esp.HealthBar) end
                        if esp.Offscreen then SafeRemove(esp.Offscreen) end
                        if esp.VelLine then SafeRemove(esp.VelLine) end
                        if esp.VelArrow then SafeRemove(esp.VelArrow) end
                    end)
                end
            end
            DrawingESP.cache       = {}
        end
    end

    -- Aimbot
    pcall(function()
        if VD.AIM_Enabled then
            Aimbot.Update(cam, cam.ViewportSize, Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2))
        end
    end)

    pcall(UpdateSpearAim)
    UpdateCameraFOV()
    UpdateThirdPerson()
    UpdateShiftLock()

    -- FOV circle
    if FOVCircle and DrawingAvailable then
        if VD.AIM_Enabled and VD.AIM_ShowFOV then
            FOVCircle.Position = screenCenter
            FOVCircle.Radius   = VD.AIM_FOV or 120
            FOVCircle.Color    = State.AimTarget and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 220, 255)
            FOVCircle.Visible  = true
        else
            FOVCircle.Visible = false
        end
    end
end

-- MOBILE GUI (Aimbot Button + FOV Circle)
local MobileGui = { AimBtn=nil, FOVFrame=nil, FOVStroke=nil }

local function CreateMobileUI()
    local pg = GetSafeGuiParent()
    if not pg then return end

    -- === MAIN SCREENGUI ===
    local sg = Instance.new("ScreenGui")
    sg.Name           = "Vora_MobileUI"
    sg.ResetOnSpawn   = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 100
    sg.Parent         = pg
    -- === FOV CIRCLE ===
    local fovF = Instance.new("Frame")
    fovF.Name                 = "FOVCircle"
    fovF.BackgroundTransparency = 1
    fovF.AnchorPoint          = Vector2.new(0.5,0.5)
    fovF.Position             = UDim2.new(0.5,0,0.5,0)
    fovF.Size                 = UDim2.new(0,240,0,240)
    fovF.Visible              = false
    fovF.Parent               = sg
    Instance.new("UICorner", fovF).CornerRadius = UDim.new(1,0)
    local fovStk = Instance.new("UIStroke")
    fovStk.Color = Color3.fromRGB(0,220,255); fovStk.Thickness = 1.5; fovStk.Transparency = 0.2
    fovStk.Parent = fovF
    MobileGui.FOVFrame = fovF; MobileGui.FOVStroke = fovStk

    -- === AIMBOT BUTTON (ScreenGui terpisah agar AlwaysOnTop) ===
    local aimSG = Instance.new("ScreenGui")
    aimSG.Name           = "Vora_AimBtn"
    aimSG.ResetOnSpawn   = false
    aimSG.IgnoreGuiInset = true
    aimSG.ZIndexBehavior = Enum.ZIndexBehavior.AlwaysOnTop
    aimSG.Parent         = pg
    local btn = Instance.new("TextButton")
    btn.Name                = "AimHold"
    btn.Size                = UDim2.new(0,75,0,75)
    btn.Position            = UDim2.new(1,-95,1,-170)
    btn.BackgroundColor3    = Color3.fromRGB(0, 30, 45)
    btn.BackgroundTransparency = 0.1
    btn.Text                = "🎯\nAIM"
    btn.TextColor3          = Color3.fromRGB(0, 220, 255)
    btn.TextSize            = 14
    btn.Font                = Enum.Font.GothamBold
    btn.Visible             = false
    btn.ZIndex              = 20
    btn.Parent              = aimSG
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
    local aStk = Instance.new("UIStroke")
    aStk.Color = Color3.fromRGB(0,220,255); aStk.Thickness = 2; aStk.Parent = btn

    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            State.AimHolding = true
            btn.BackgroundColor3 = Color3.fromRGB(0, 60, 80)
            btn.TextColor3       = Color3.fromRGB(255, 255, 255)
            aStk.Color = Color3.fromRGB(255,255,255)
        end
    end)
    btn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            State.AimHolding = false; State.AimTarget = nil
            btn.BackgroundColor3 = Color3.fromRGB(0, 30, 45)
            btn.TextColor3       = Color3.fromRGB(0, 220, 255)
            aStk.Color = Color3.fromRGB(0,220,255)
        end
    end)
    MobileGui.AimBtn = btn
end

local function UpdateMobileFOV()
    if not MobileGui.FOVFrame then return end
    if VD.AIM_Enabled and VD.AIM_ShowFOV then
        local r = (VD.AIM_FOV or 120)
        MobileGui.FOVFrame.Size = UDim2.new(0, r*2, 0, r*2)
        MobileGui.FOVStroke.Color = State.AimTarget and Color3.fromRGB(255,255,255) or Color3.fromRGB(0,220,255)
        MobileGui.FOVFrame.Visible = true
    else
        MobileGui.FOVFrame.Visible = false
    end
end

task.spawn(function()
    task.wait(2)
    pcall(CreateMobileUI)
end)

-- RENDER LOOP: PC (RenderStepped, pakai Drawing)
if DrawingAvailable then
    RunService.RenderStepped:Connect(OnRenderStep)
end
RunService.RenderStepped:Connect(function()
    pcall(VD_RunCrosshairLoop)
end)

-- HEARTBEAT UNIVERSAL: Berjalan di PC & Mobile
RunService.Heartbeat:Connect(function()
    if VD.Destroyed then return end
    local cam = workspace.CurrentCamera
    if not cam then return end



    if not DrawingAvailable and (not MobileGui.FOVFrame or not MobileGui.FOVFrame.Parent) then
        pcall(CreateMobileUI)
    end

    if not DrawingAvailable then
        UpdateCameraFOV()
        UpdateThirdPerson()
        UpdateShiftLock()
        pcall(UpdateSpearAim)
    end
    if not DrawingAvailable and VD.AIM_Enabled and State.AimHolding then
        local sc = cam.ViewportSize
        pcall(function() Aimbot.Update(cam, sc, Vector2.new(sc.X/2, sc.Y/2)) end)
    end


    if not DrawingAvailable then
        if MobileGui.AimBtn then MobileGui.AimBtn.Visible = VD.AIM_Enabled end
        pcall(UpdateMobileFOV)
    end
    pcall(UpdateRadar)
    pcall(VD_RunAntiKnock)
    pcall(VD_UpdateSurvivorWarnings)
    pcall(VD_UpdateBypassGate)
    pcall(VD_UpdateInvisibleNotVisual)
    pcall(VD_UpdateMoonwalk, deltaTime)
    pcall(VD_UpdateRemovePalletwrong)
end)

-- SYNC BACKEND FEATURES ON CONFIG LOAD
getgenv().Vora_SyncLoadedFeatures = function()

    if type(SetupAntiBlind) == "function" then pcall(SetupAntiBlind) end
    if type(SetupNoPalletStun) == "function" then pcall(SetupNoPalletStun) end
    if type(VD_UpdateCrosshair) == "function" then pcall(VD_UpdateCrosshair) end
end
end
__VoraHub_Init_Main__()
