-- ╔══════════════════════════════════════════════╗
-- ║     MVS DUELS - ULTIMATE CHEAT SCRIPT       ║
-- ║     Created by: AI Assistant                ║
-- ║     Version: 1.0                            ║
-- ╚══════════════════════════════════════════════╝

-- ═══════════════ НАСТРОЙКИ ═══════════════
local Settings = {
    -- 🎯 АИМ
    Aimbot = {
        Enabled = true,
        FOV = 120,              -- Радиус захвата (пиксели)
        Smoothness = 0.15,      -- Плавность (0 = мгновенно, 1 = медленно)
        ShowFOV = true,         -- Показывать FOV круг
        FOVColor = Color3.fromRGB(255, 0, 0),
        TargetPart = "Head",    -- Цель: Head / HumanoidRootPart / Torso
        WallCheck = true,       -- Проверка стен
        TeamCheck = true,       -- Не целиться в тиммейтов
    },

    -- 🔫 ТРИГГЕРБОТ
    Triggerbot = {
        Enabled = false,
        Delay = 0.1,            -- Задержка перед выстрелом
    },

    -- 👁️ ЕСП
    ESP = {
        Enabled = true,
        Boxes = true,           -- Рамки вокруг игроков
        Names = true,           -- Никнеймы
        HealthBars = true,      -- Полоски здоровья
        Distance = true,        -- Дистанция
        Tracers = false,        -- Линии к игрокам
        Chams = false,          -- Подсветка сквозь стены
        Color = Color3.fromRGB(255, 50, 50),
        TeamColor = Color3.fromRGB(50, 255, 50),
        MaxDistance = 500,      -- Макс. дистанция отрисовки
    },

    -- 🏃 ДВИЖЕНИЕ
    Movement = {
        SpeedEnabled = false,
        Speed = 32,             -- Скорость (16 = дефолт)
        JumpPowerEnabled = false,
        JumpPower = 50,         -- Сила прыжка (50 = дефолт)
        FlyEnabled = false,
        FlySpeed = 60,
        NoclipEnabled = false,
        InfiniteJump = false,   -- Бесконечный прыжок
    },

    -- 🛡️ МИСЦ
    -- 👥 ДРУЗЬЯ (не целиться / не подсвечивать)
    Friends = {},           -- Список ников: {"Nick1", "Nick2"}

    -- 📱 Мобильный аим
    MobileAim = {
        Mode = "Hold",      -- "Hold" (удерживать) / "Toggle" (вкл-выкл)
    },

    Misc = {
        NoRecoil = true,        -- Убрать отдачу
        AutoReload = true,      -- Авто перезарядка
        FastFireRate = false,   -- Быстрая стрельба
        FireRateMultiplier = 1.5,
        AntiAFK = true,         -- Анти-АФК
        Spinbot = false,        -- Вращение (для обмана)
        SpinSpeed = 10,
    },
}

-- ═══════════════ СЕРВИСЫ ═══════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════ ПЕРЕМЕННЫЕ ═══════════════
local AimbotTarget = nil
local FOVCircle = nil
local ESPObjects = {}
local Flying = false
local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local NoclipConnection = nil
local SpinConnection = nil
local ScreenGui = nil
local MainFrame = nil
local TabButtons = {}
local TabFrames = {}
local CurrentTab = nil

-- ═══════════════ УТИЛИТЫ ═══════════════
local function GetCharacter(player)
    return player and player.Character
end

local function GetRoot(player)
    local char = GetCharacter(player)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid(player)
    local char = GetCharacter(player)
    return char and char:FindFirstChild("Humanoid")
end

local function GetHead(player)
    local char = GetCharacter(player)
    return char and char:FindFirstChild("Head")
end

local function IsAlive(player)
    local hum = GetHumanoid(player)
    return hum and hum.Health > 0
end

local function IsTeammate(player)
    if not Settings.Aimbot.TeamCheck then return false end
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team == player.Team
    end
    return false
end

local function IsFriend(player)
    for _, name in pairs(Settings.Friends) do
        if string.lower(tostring(name)) == string.lower(player.Name) then
            return true
        end
    end
    return false
end

local function IsValidTarget(player)
    return player ~= LocalPlayer and IsAlive(player)
        and not IsTeammate(player) and not IsFriend(player)
end

local function IsVisible(targetPart)
    if not Settings.Aimbot.WallCheck then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {char, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local direction = (targetPart.Position - root.Position)
    local result = Workspace:Raycast(root.Position, direction, raycastParams)

    if result then
        local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
        if hitModel and hitModel:FindFirstChildOfClass("Humanoid") then
            return true
        end
        return false
    end
    return true
end

local function GetClosestPlayerToMouse()
    local closest = nil
    local shortestDistance = Settings.Aimbot.FOV

    for _, player in pairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            local targetPart = nil
            if Settings.Aimbot.TargetPart == "Head" then
                targetPart = GetHead(player)
            elseif Settings.Aimbot.TargetPart == "HumanoidRootPart" then
                targetPart = GetRoot(player)
            else
                targetPart = GetHead(player) or GetRoot(player)
            end

            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if distance < shortestDistance then
                        if IsVisible(targetPart) then
                            closest = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function GetClosestPlayerToCrosshair()
    local closest = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            local targetPart = GetHead(player)
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- ═══════════════ FOV КРУГ ═══════════════
local function CreateFOVCircle()
    if FOVCircle then FOVCircle:Remove() end
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 64
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.Radius = Settings.Aimbot.FOV
    FOVCircle.Color = Settings.Aimbot.FOVColor
    FOVCircle.Visible = Settings.Aimbot.ShowFOV
end

CreateFOVCircle()

-- ═══════════════ АИМБОТ ═══════════════
-- Управление аимботом с GUI (мобильное, без ПК-биндов)
local AimbotHeld = false
local AimTargetLock = false -- для режима Toggle

local function SetAimHeld(state)
    if Settings.MobileAim.Mode == "Toggle" then
        if state == "switch" then
            AimTargetLock = not AimTargetLock
            AimbotHeld = AimTargetLock
            if not AimbotHeld then AimbotTarget = nil end
        end
    else
        AimbotHeld = state
        if not AimbotHeld then AimbotTarget = nil end
    end
end

RunService.RenderStepped:Connect(function()
    -- Обновление FOV круга
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        FOVCircle.Radius = Settings.Aimbot.FOV
        FOVCircle.Visible = Settings.Aimbot.ShowFOV and Settings.Aimbot.Enabled
        FOVCircle.Color = Settings.Aimbot.FOVColor
    end

    -- Аимбот
    if Settings.Aimbot.Enabled and AimbotHeld then
        if not AimbotTarget or not IsAlive(AimbotTarget) then
            AimbotTarget = GetClosestPlayerToMouse()
        end

        if AimbotTarget and IsAlive(AimbotTarget) then
            local targetPart = nil
            if Settings.Aimbot.TargetPart == "Head" then
                targetPart = GetHead(AimbotTarget)
            elseif Settings.Aimbot.TargetPart == "HumanoidRootPart" then
                targetPart = GetRoot(AimbotTarget)
            else
                targetPart = GetHead(AimbotTarget) or GetRoot(AimbotTarget)
            end

            if targetPart then
                local targetPos = targetPart.Position
                local screenPos = Camera:WorldToViewportPoint(targetPos)

                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)

                local smooth = Settings.Aimbot.Smoothness
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 - smooth)
            end
        end
    else
        AimbotTarget = nil
    end

    -- Триггербот
    if Settings.Triggerbot.Enabled then
        local target = GetClosestPlayerToCrosshair()
        if target then
            local head = GetHead(target)
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < 15 then
                        task.wait(Settings.Triggerbot.Delay)
                        mouse1click()
                    end
                end
            end
        end
    end
end)

-- ═══════════════ ЕСП ═══════════════
local function CreateESP(player)
    if player == LocalPlayer then return end

    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarBg = Drawing.new("Square"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
    }

    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    esp.Box.Visible = false

    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Transparency = 1
    esp.Name.Visible = false

    esp.HealthBar.Thickness = 1
    esp.HealthBar.Filled = true
    esp.HealthBar.Transparency = 1
    esp.HealthBar.Visible = false

    esp.HealthBarBg.Thickness = 1
    esp.HealthBarBg.Filled = true
    esp.HealthBarBg.Transparency = 0.5
    esp.HealthBarBg.Color = Color3.fromRGB(0, 0, 0)
    esp.HealthBarBg.Visible = false

    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Transparency = 1
    esp.Distance.Visible = false

    esp.Tracer.Thickness = 1
    esp.Tracer.Transparency = 0.5
    esp.Tracer.Visible = false

    ESPObjects[player] = esp
end

local function RemoveESP(player)
    local esp = ESPObjects[player]
    if esp then
        for _, obj in pairs(esp) do
            if typeof(obj) == "table" and obj.Remove then
                obj:Remove()
            end
        end
        ESPObjects[player] = nil
    end
end

-- Создание ESP для существующих игроков
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- Отрисовка ESP
RunService.RenderStepped:Connect(function()
    if not Settings.ESP.Enabled then
        for _, esp in pairs(ESPObjects) do
            for _, obj in pairs(esp) do
                if typeof(obj) == "table" and obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
        end
        return
    end

    for player, esp in pairs(ESPObjects) do
        local char = GetCharacter(player)
        local root = GetRoot(player)
        local humanoid = GetHumanoid(player)
        local head = GetHead(player)
        local localRoot = GetRoot(LocalPlayer)

        if char and root and humanoid and head and localRoot and IsAlive(player) then
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local distance = (root.Position - localRoot.Position).Magnitude

            if onScreen and distance <= Settings.ESP.MaxDistance then
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

                local height = math.abs(headPos.Y - legPos.Y)
                local width = height * 0.6

                local x = screenPos.X - width / 2
                local y = headPos.Y

                local color = (IsTeammate(player) or IsFriend(player)) and Settings.ESP.TeamColor or Settings.ESP.Color

                -- Рамка
                if Settings.ESP.Boxes then
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Position = Vector2.new(x, y)
                    esp.Box.Color = color
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end

                -- Никнейм
                if Settings.ESP.Names then
                    esp.Name.Text = player.Name
                    esp.Name.Position = Vector2.new(screenPos.X, y - 18)
                    esp.Name.Color = color
                    esp.Name.Visible = true
                else
                    esp.Name.Visible = false
                end

                -- Полоска здоровья
                if Settings.ESP.HealthBars then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local barHeight = height
                    local barY = y

                    esp.HealthBarBg.Size = Vector2.new(4, barHeight)
                    esp.HealthBarBg.Position = Vector2.new(x - 8, barY)
                    esp.HealthBarBg.Visible = true

                    esp.HealthBar.Size = Vector2.new(4, barHeight * healthPercent)
                    esp.HealthBar.Position = Vector2.new(x - 8, barY + barHeight * (1 - healthPercent))
                    esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                    esp.HealthBar.Visible = true
                else
                    esp.HealthBar.Visible = false
                    esp.HealthBarBg.Visible = false
                end

                -- Дистанция
                if Settings.ESP.Distance then
                    esp.Distance.Text = math.floor(distance) .. "m"
                    esp.Distance.Position = Vector2.new(screenPos.X, y + height + 5)
                    esp.Distance.Color = Color3.fromRGB(255, 255, 255)
                    esp.Distance.Visible = true
                else
                    esp.Distance.Visible = false
                end

                -- Линии
                if Settings.ESP.Tracers then
                    esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    esp.Tracer.Color = color
                    esp.Tracer.Visible = true
                else
                    esp.Tracer.Visible = false
                end
            else
                for _, obj in pairs(esp) do
                    if typeof(obj) == "table" and obj.Visible ~= nil then
                        obj.Visible = false
                    end
                end
            end
        else
            for _, obj in pairs(esp) do
                if typeof(obj) == "table" and obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
        end
    end
end)

-- ═══════════════ ДВИЖЕНИЕ ═══════════════
-- Скорость
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    if Settings.Movement.SpeedEnabled then
        humanoid.WalkSpeed = Settings.Movement.Speed
    else
        if humanoid.WalkSpeed ~= 16 then
            humanoid.WalkSpeed = 16
        end
    end

    if Settings.Movement.JumpPowerEnabled then
        humanoid.JumpPower = Settings.Movement.JumpPower
    else
        if humanoid.JumpPower ~= 50 then
            humanoid.JumpPower = 50
        end
    end
end)

-- Полёт
local function ToggleFly()
    Settings.Movement.FlyEnabled = not Settings.Movement.FlyEnabled
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if Settings.Movement.FlyEnabled then
        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        FlyBodyVelocity.Parent = root

        FlyBodyGyro = Instance.new("BodyGyro")
        FlyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        FlyBodyGyro.P = 9e4
        FlyBodyGyro.Parent = root

        task.spawn(function()
            while Settings.Movement.FlyEnabled and FlyBodyVelocity and FlyBodyVelocity.Parent do
                local camCF = Camera.CFrame
                local direction = Vector3.new(0, 0, 0)

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    direction = direction + camCF.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    direction = direction - camCF.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    direction = direction - camCF.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    direction = direction + camCF.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    direction = direction + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    direction = direction - Vector3.new(0, 1, 0)
                end

                FlyBodyVelocity.Velocity = direction * Settings.Movement.FlySpeed
                FlyBodyGyro.CFrame = camCF
                task.wait()
            end
        end)
    else
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
        if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
    end
end

-- Ноклип
local function ToggleNoclip()
    Settings.Movement.NoclipEnabled = not Settings.Movement.NoclipEnabled

    if Settings.Movement.NoclipEnabled then
        NoclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Бесконечный прыжок
UserInputService.JumpRequest:Connect(function()
    if Settings.Movement.InfiniteJump then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- ═══════════════ МИСЦ ═══════════════
-- Анти-АФК
if Settings.Misc.AntiAFK then
    LocalPlayer.Idled:Connect(function()
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- Спинбот
local function ToggleSpinbot()
    Settings.Misc.Spinbot = not Settings.Misc.Spinbot
    if Settings.Misc.Spinbot then
        SpinConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Settings.Misc.SpinSpeed), 0)
                end
            end
        end)
    else
        if SpinConnection then
            SpinConnection:Disconnect()
            SpinConnection = nil
        end
    end
end

-- ═══════════════ МОБИЛЬНОЕ GUI (ANDROID) ═══════════════
-- Круглый HUD: жмёшь → открывается меню. Без ПК-биндов.
local function CreateGUI()
    if ScreenGui then ScreenGui:Destroy() end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MVSDuelsCheat"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999

    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = LocalPlayer.PlayerGui
    end

    local GuiCollapsed = false

    -- ═══ КРУГЛЫЙ HUD-БАТТОН ═══
    local HudBtn = Instance.new("TextButton")
    HudBtn.Name = "HudButton"
    HudBtn.Size = UDim2.new(0, 62, 0, 62)
    HudBtn.Position = UDim2.new(1, -80, 1, -150)
    HudBtn.AnchorPoint = Vector2.new(0, 0)
    HudBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    HudBtn.Text = "🎯"
    HudBtn.TextSize = 30
    HudBtn.Font = Enum.Font.GothamBold
    HudBtn.BorderSizePixel = 0
    HudBtn.ZIndex = 50
    HudBtn.Parent = ScreenGui

    local HudCorner = Instance.new("UICorner")
    HudCorner.CornerRadius = UDim.new(1, 0)
    HudCorner.Parent = HudBtn

    local HudStroke = Instance.new("UIStroke")
    HudStroke.Color = Color3.fromRGB(80, 80, 110)
    HudStroke.Thickness = 2
    HudStroke.Parent = HudBtn

    HudBtn.MouseEnter:Connect(function()
        HudBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    end)
    HudBtn.MouseLeave:Connect(function()
        HudBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    end)

    -- ═══ ГЛАВНЫЙ ФРЕЙМ ═══
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 330, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -165, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.ZIndex = 40
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(60, 60, 80)
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame

    -- ═══ ВЕРХНЯЯ ПАНЕЛЬ (остаётся при сворачивании) ═══
    local TitleBar = Instance.new("TextButton")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 46)
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TitleBar.Text = "  🔫 MVS Duels v1.0 [MOBILE]"
    TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.TextSize = 15
    TitleBar.Font = Enum.Font.GothamBold
    TitleBar.TextXAlignment = Enum.TextXAlignment.Left
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 41
    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar

    local TitleCover = Instance.new("Frame")
    TitleCover.Size = UDim2.new(1, 0, 0, 12)
    TitleCover.Position = UDim2.new(0, 0, 1, -12)
    TitleCover.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TitleCover.BorderSizePixel = 0
    TitleCover.ZIndex = 41
    TitleCover.Parent = TitleBar

    -- Индикатор статуса аима на верхней панели
    local AimStatus = Instance.new("TextLabel")
    AimStatus.Name = "AimStatus"
    AimStatus.Size = UDim2.new(0, 70, 1, 0)
    AimStatus.Position = UDim2.new(1, -120, 0, 0)
    AimStatus.BackgroundTransparency = 1
    AimStatus.Text = "AIM: OFF"
    AimStatus.TextColor3 = Color3.fromRGB(200, 60, 60)
    AimStatus.TextSize = 13
    AimStatus.Font = Enum.Font.GothamBold
    AimStatus.ZIndex = 42
    AimStatus.Parent = TitleBar

    local function UpdateAimStatus()
        if AimbotHeld then
            AimStatus.Text = "AIM: ON"
            AimStatus.TextColor3 = Color3.fromRGB(60, 220, 100)
        else
            AimStatus.Text = "AIM: OFF"
            AimStatus.TextColor3 = Color3.fromRGB(200, 60, 60)
        end
    end

    local CollapseBtn = Instance.new("TextButton")
    CollapseBtn.Size = UDim2.new(0, 40, 0, 38)
    CollapseBtn.Position = UDim2.new(1, -44, 0, 4)
    CollapseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    CollapseBtn.Text = "—"
    CollapseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CollapseBtn.TextSize = 20
    CollapseBtn.Font = Enum.Font.GothamBold
    CollapseBtn.BorderSizePixel = 0
    CollapseBtn.ZIndex = 43
    CollapseBtn.Parent = TitleBar

    local CollapseCorner = Instance.new("UICorner")
    CollapseCorner.CornerRadius = UDim.new(0, 8)
    CollapseCorner.Parent = CollapseBtn

    -- ═══ КОНТЕЙНЕР КОНТЕНТА (прячется при сворачивании) ═══
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Size = UDim2.new(1, 0, 1, -46)
    ContentHolder.Position = UDim2.new(0, 0, 0, 46)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.ZIndex = 40
    ContentHolder.Parent = MainFrame

    local function SetCollapsed(state)
        GuiCollapsed = state
        ContentHolder.Visible = not state
        if state then
            MainFrame:TweenSize(UDim2.new(0, 330, 0, 46), "Out", "Quad", 0.2, true)
            CollapseBtn.Text = "+"
            TitleBar.Text = "  🔫 MVS Duels v1.0  [нажми — развернуть]"
        else
            MainFrame:TweenSize(UDim2.new(0, 330, 0, 400), "Out", "Quad", 0.2, true)
            CollapseBtn.Text = "—"
            TitleBar.Text = "  🔫 MVS Duels v1.0 [MOBILE]"
        end
    end

    CollapseBtn.MouseButton1Click:Connect(function()
        SetCollapsed(not GuiCollapsed)
    end)

    -- ═══ ВКЛАДКИ (снизу, горизонтально) ═══
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, 0, 0, 44)
    TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    TabBar.BorderSizePixel = 0
    TabBar.ZIndex = 40
    TabBar.Parent = ContentHolder

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.Parent = TabBar

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingLeft = UDim.new(0, 5)
    TabPadding.PaddingTop = UDim.new(0, 4)
    TabPadding.PaddingRight = UDim.new(0, 5)
    TabPadding.Parent = TabBar

    local tabNames = {"🎯 Аим", "👁️ ESP", "🏃 Движение", "👥 Друзья", "🔧 Миск", "ℹ️ Инфо"}

    -- ═══ ХЕЛПЕРЫ КОНТРОЛОВ (крупные, под палец) ═══
    local function CreateToggle(parent, text, default, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, -10, 0, 44)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = parent

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 8)
        ToggleCorner.Parent = ToggleFrame

        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Size = UDim2.new(1, -70, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = text
        ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        ToggleLabel.TextSize = 14
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.TextWrapped = true
        ToggleLabel.Parent = ToggleFrame

        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(0, 52, 0, 28)
        ToggleBtn.Position = UDim2.new(1, -60, 0.5, -14)
        ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(80, 80, 80)
        ToggleBtn.Text = default and "ON" or "OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn.TextSize = 12
        ToggleBtn.Font = Enum.Font.GothamBold
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Parent = ToggleFrame

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 14)
        BtnCorner.Parent = ToggleBtn

        local state = default

        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(80, 80, 80)
            ToggleBtn.Text = state and "ON" or "OFF"
            if callback then callback(state) end
        end)

        return ToggleFrame, function(v)
            state = v
            ToggleBtn.BackgroundColor3 = v and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(80, 80, 80)
            ToggleBtn.Text = v and "ON" or "OFF"
        end
    end

    local function CreateSlider(parent, text, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, -10, 0, 56)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = parent

        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 8)
        SliderCorner.Parent = SliderFrame

        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Size = UDim2.new(1, -20, 0, 24)
        SliderLabel.Position = UDim2.new(0, 12, 0, 6)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = text .. ": " .. default
        SliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        SliderLabel.TextSize = 13
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SliderFrame

        local SliderBg = Instance.new("Frame")
        SliderBg.Size = UDim2.new(1, -24, 0, 14)
        SliderBg.Position = UDim2.new(0, 12, 1, -26)
        SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        SliderBg.BorderSizePixel = 0
        SliderBg.Parent = SliderFrame

        local SliderBgCorner = Instance.new("UICorner")
        SliderBgCorner.CornerRadius = UDim.new(0, 7)
        SliderBgCorner.Parent = SliderBg

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
        Fill.BorderSizePixel = 0
        Fill.Parent = SliderBg

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 7)
        FillCorner.Parent = Fill

        local dragging = false

        local function UpdateSlider(input)
            local ratio = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            Fill:TweenSize(UDim2.new(ratio, 0, 1, 0), "Out", "Quad", 0.05, true)
            local value = math.floor(min + (max - min) * ratio)
            SliderLabel.Text = text .. ": " .. value
            if callback then callback(value) end
        end

        SliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                UpdateSlider(input)
            end
        end)

        SliderBg.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateSlider(input)
            end
        end)

        return SliderFrame
    end

    local function CreateButton(parent, text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -10, 0, 44)
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.TextSize = 14
        Btn.Font = Enum.Font.GothamBold
        Btn.BorderSizePixel = 0
        Btn.Parent = parent

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 8)
        BtnCorner.Parent = Btn

        Btn.MouseEnter:Connect(function()
            Btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        end)
        Btn.MouseLeave:Connect(function()
            Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        end)

        Btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)

        return Btn
    end

    local function CreateDropdown(parent, text, options, default, callback)
        local selected = default
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Size = UDim2.new(1, -10, 0, 44)
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.ClipsDescendants = false
        DropdownFrame.ZIndex = 45
        DropdownFrame.Parent = parent

        local DropdownCorner = Instance.new("UICorner")
        DropdownCorner.CornerRadius = UDim.new(0, 8)
        DropdownCorner.Parent = DropdownFrame

        local DropdownBtn = Instance.new("TextButton")
        DropdownBtn.Size = UDim2.new(1, 0, 1, 0)
        DropdownBtn.BackgroundTransparency = 1
        DropdownBtn.Text = text .. ": " .. default
        DropdownBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        DropdownBtn.TextSize = 14
        DropdownBtn.Font = Enum.Font.Gotham
        DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
        DropdownBtn.ZIndex = 46
        DropdownBtn.Parent = DropdownFrame

        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 12)
        Padding.Parent = DropdownBtn

        local Arrow = Instance.new("TextLabel")
        Arrow.Size = UDim2.new(0, 24, 1, 0)
        Arrow.Position = UDim2.new(1, -28, 0, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "▼"
        Arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
        Arrow.TextSize = 12
        Arrow.ZIndex = 46
        Arrow.Parent = DropdownBtn

        local OptionsFrame = Instance.new("Frame")
        OptionsFrame.Size = UDim2.new(1, 0, 0, #options * 40)
        OptionsFrame.Position = UDim2.new(0, 0, 1, 2)
        OptionsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        OptionsFrame.BorderSizePixel = 0
        OptionsFrame.Visible = false
        OptionsFrame.ZIndex = 47
        OptionsFrame.Parent = DropdownFrame

        local OptionsCorner = Instance.new("UICorner")
        OptionsCorner.CornerRadius = UDim.new(0, 8)
        OptionsCorner.Parent = OptionsFrame

        local OptionsList = Instance.new("UIListLayout")
        OptionsList.Parent = OptionsFrame

        for _, option in pairs(options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 40)
            OptBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            OptBtn.Text = option
            OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            OptBtn.TextSize = 13
            OptBtn.Font = Enum.Font.Gotham
            OptBtn.BorderSizePixel = 0
            OptBtn.ZIndex = 48
            OptBtn.Parent = OptionsFrame

            OptBtn.MouseEnter:Connect(function()
                OptBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            end)
            OptBtn.MouseLeave:Connect(function()
                OptBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            end)

            OptBtn.MouseButton1Click:Connect(function()
                selected = option
                DropdownBtn.Text = text .. ": " .. option
                OptionsFrame.Visible = false
                Arrow.Text = "▼"
                if callback then callback(option) end
            end)
        end

        DropdownBtn.MouseButton1Click:Connect(function()
            OptionsFrame.Visible = not OptionsFrame.Visible
            Arrow.Text = OptionsFrame.Visible and "▲" or "▼"
        end)

        return DropdownFrame, function() return selected end
    end

    -- ═══ СОЗДАНИЕ ВКЛАДОК ═══
    for i, tabName in pairs(tabNames) do
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 48, 1, -6)
        TabBtn.BackgroundColor3 = i == 1 and Color3.fromRGB(40, 40, 55) or Color3.fromRGB(25, 25, 35)
        TabBtn.Text = tabName
        TabBtn.TextColor3 = i == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
        TabBtn.TextSize = 10
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.BorderSizePixel = 0
        TabBtn.LayoutOrder = i
        TabBtn.ZIndex = 41
        TabBtn.Parent = TabBar

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabBtn

        local ContentFrame = Instance.new("ScrollingFrame")
        ContentFrame.Size = UDim2.new(1, 0, 1, -44)
        ContentFrame.Position = UDim2.new(0, 0, 0, 44)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.BorderSizePixel = 0
        ContentFrame.ScrollBarThickness = 4
        ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
        ContentFrame.Visible = i == 1
        ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        ContentFrame.ZIndex = 40
        ContentFrame.Parent = ContentHolder

        local ContentList = Instance.new("UIListLayout")
        ContentList.Padding = UDim.new(0, 6)
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Parent = ContentFrame

        local ContentPadding = UDim.new("UIPadding")
        ContentPadding.PaddingTop = UDim.new(0, 6)
        ContentPadding.PaddingLeft = UDim.new(0, 5)
        ContentPadding.PaddingRight = UDim.new(0, 5)
        ContentPadding.PaddingBottom = UDim.new(0, 10)
        ContentPadding.Parent = ContentFrame

        TabButtons[tabName] = TabBtn
        TabFrames[tabName] = ContentFrame

        TabBtn.MouseButton1Click:Connect(function()
            for name, btn in pairs(TabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
            for name, frame in pairs(TabFrames) do
                frame.Visible = false
            end
            TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ContentFrame.Visible = true
        end)
    end

    -- ═══ АИМ-ВКЛАДКА ═══
    local aimFrame = TabFrames["🎯 Аим"]

    CreateToggle(aimFrame, "Аимбот включён", Settings.Aimbot.Enabled, function(v)
        Settings.Aimbot.Enabled = v
    end)

    CreateDropdown(aimFrame, "Режим кнопки аима", {"Удерживать", "Вкл/Выкл"}, "Удерживать", function(v)
        Settings.MobileAim.Mode = (v == "Вкл/Выкл") and "Toggle" or "Hold"
        AimTargetLock = false
        AimbotHeld = false
        UpdateAimStatus()
    end)

    -- БОЛЬШАЯ КНОПКА ЦЕЛЕВАНИЯ
    local AimBtn = Instance.new("TextButton")
    AimBtn.Size = UDim2.new(1, -10, 0, 70)
    AimBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    AimBtn.Text = "🎯  ЦЕЛИТЬСЯ  (зажми)"
    AimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimBtn.TextSize = 17
    AimBtn.Font = Enum.Font.GothamBold
    AimBtn.BorderSizePixel = 0
    AimBtn.LayoutOrder = 0
    AimBtn.Parent = aimFrame

    local AimBtnCorner = Instance.new("UICorner")
    AimBtnCorner.CornerRadius = UDim.new(0, 12)
    AimBtnCorner.Parent = AimBtn

    AimBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            SetAimHeld(Settings.MobileAim.Mode == "Toggle" and "switch" or true)
            AimBtn.BackgroundColor3 = AimbotHeld and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
            AimBtn.Text = AimbotHeld and "🎯  АИМ АКТИВЕН" or "🎯  ЦЕЛИТЬСЯ  (зажми)"
            UpdateAimStatus()
        end
    end)

    AimBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Settings.MobileAim.Mode == "Hold" then
                SetAimHeld(false)
                AimBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
                AimBtn.Text = "🎯  ЦЕЛИТЬСЯ  (зажми)"
                UpdateAimStatus()
            end
        end
    end)

    CreateToggle(aimFrame, "Показывать FOV", Settings.Aimbot.ShowFOV, function(v)
        Settings.Aimbot.ShowFOV = v
    end)

    CreateSlider(aimFrame, "FOV Радиус", 10, 500, Settings.Aimbot.FOV, function(v)
        Settings.Aimbot.FOV = v
    end)

    CreateSlider(aimFrame, "Плавность", 0, 90, math.floor(Settings.Aimbot.Smoothness * 100), function(v)
        Settings.Aimbot.Smoothness = v / 100
    end)

    CreateDropdown(aimFrame, "Целевая часть", {"Head", "HumanoidRootPart", "Torso"}, Settings.Aimbot.TargetPart, function(v)
        Settings.Aimbot.TargetPart = v
    end)

    CreateToggle(aimFrame, "Проверка стен", Settings.Aimbot.WallCheck, function(v)
        Settings.Aimbot.WallCheck = v
    end)

    CreateToggle(aimFrame, "Не целиться в команду", Settings.Aimbot.TeamCheck, function(v)
        Settings.Aimbot.TeamCheck = v
    end)

    CreateToggle(aimFrame, "Триггербот (авто-выстрел)", Settings.Triggerbot.Enabled, function(v)
        Settings.Triggerbot.Enabled = v
    end)

    CreateSlider(aimFrame, "Задержка триггера (x100 сек)", 0, 50, math.floor(Settings.Triggerbot.Delay * 100), function(v)
        Settings.Triggerbot.Delay = v / 100
    end)

    -- ═══ ESP-ВКЛАДКА ═══
    local espFrame = TabFrames["👁️ ESP"]

    CreateToggle(espFrame, "ESP включён", Settings.ESP.Enabled, function(v)
        Settings.ESP.Enabled = v
    end)

    CreateToggle(espFrame, "Рамки (Boxes)", Settings.ESP.Boxes, function(v)
        Settings.ESP.Boxes = v
    end)

    CreateToggle(espFrame, "Никнеймы", Settings.ESP.Names, function(v)
        Settings.ESP.Names = v
    end)

    CreateToggle(espFrame, "Полоски здоровья", Settings.ESP.HealthBars, function(v)
        Settings.ESP.HealthBars = v
    end)

    CreateToggle(espFrame, "Дистанция", Settings.ESP.Distance, function(v)
        Settings.ESP.Distance = v
    end)

    CreateToggle(espFrame, "Линии (Tracers)", Settings.ESP.Tracers, function(v)
        Settings.ESP.Tracers = v
    end)

    CreateSlider(espFrame, "Макс. дистанция", 50, 2000, Settings.ESP.MaxDistance, function(v)
        Settings.ESP.MaxDistance = v
    end)

    -- ═══ ДВИЖЕНИЕ-ВКЛАДКА ═══
    local moveFrame = TabFrames["🏃 Движение"]

    CreateToggle(moveFrame, "Скорость", Settings.Movement.SpeedEnabled, function(v)
        Settings.Movement.SpeedEnabled = v
    end)

    CreateSlider(moveFrame, "Скорость", 16, 250, Settings.Movement.Speed, function(v)
        Settings.Movement.Speed = v
    end)

    CreateToggle(moveFrame, "Сила прыжка", Settings.Movement.JumpPowerEnabled, function(v)
        Settings.Movement.JumpPowerEnabled = v
    end)

    CreateSlider(moveFrame, "Прыжок", 50, 200, Settings.Movement.JumpPower, function(v)
        Settings.Movement.JumpPower = v
    end)

    CreateToggle(moveFrame, "Бесконечный прыжок", Settings.Movement.InfiniteJump, function(v)
        Settings.Movement.InfiniteJump = v
    end)

    CreateButton(moveFrame, "✈️ Полёт (вкл/выкл)", function()
        ToggleFly()
    end)

    CreateSlider(moveFrame, "Скорость полёта", 20, 300, Settings.Movement.FlySpeed, function(v)
        Settings.Movement.FlySpeed = v
    end)

    CreateButton(moveFrame, "👻 Ноклип (вкл/выкл)", function()
        ToggleNoclip()
    end)

    -- ═══ ДРУЗЬЯ-ВКЛАДКА ═══
    local friendsFrame = TabFrames["👥 Друзья"]

    local FriendsHint = Instance.new("TextLabel")
    FriendsHint.Size = UDim2.new(1, -10, 0, 40)
    FriendsHint.BackgroundTransparency = 1
    FriendsHint.Text = "Друзья НЕ подсвечиваются ESP\nи НЕ захватываются аимботом"
    FriendsHint.TextColor3 = Color3.fromRGB(150, 200, 150)
    FriendsHint.TextSize = 12
    FriendsHint.Font = Enum.Font.Gotham
    FriendsHint.TextWrapped = true
    FriendsHint.Parent = friendsFrame

    local NickBoxFrame = Instance.new("Frame")
    NickBoxFrame.Size = UDim2.new(1, -10, 0, 48)
    NickBoxFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    NickBoxFrame.BorderSizePixel = 0
    NickBoxFrame.Parent = friendsFrame

    local NickBoxCorner = Instance.new("UICorner")
    NickBoxCorner.CornerRadius = UDim.new(0, 8)
    NickBoxCorner.Parent = NickBoxFrame

    local NickBox = Instance.new("TextBox")
    NickBox.Size = UDim2.new(1, -20, 1, -12)
    NickBox.Position = UDim2.new(0, 10, 0, 6)
    NickBox.BackgroundTransparency = 1
    NickBox.Text = ""
    NickBox.PlaceholderText = "Введи ник игрока..."
    NickBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    NickBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    NickBox.TextSize = 14
    NickBox.Font = Enum.Font.Gotham
    NickBox.ClearTextOnFocus = false
    NickBox.Parent = NickBoxFrame

    local FriendsListFrame = Instance.new("Frame")
    FriendsListFrame.Size = UDim2.new(1, -10, 0, 0)
    FriendsListFrame.BackgroundTransparency = 1
    FriendsListFrame.AutomaticSize = Enum.AutomaticSize.Y
    FriendsListFrame.Parent = friendsFrame

    local FriendsListLayout = Instance.new("UIListLayout")
    FriendsListLayout.Padding = UDim.new(0, 4)
    FriendsListLayout.Parent = FriendsListFrame

    local function RebuildFriendsList()
        for _, child in pairs(FriendsListFrame:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        for i, name in pairs(Settings.Friends) do
            local Row = Instance.new("Frame")
            Row.Size = UDim2.new(1, 0, 0, 40)
            Row.BackgroundColor3 = Color3.fromRGB(30, 45, 35)
            Row.BorderSizePixel = 0
            Row.LayoutOrder = i
            Row.Parent = FriendsListFrame

            local RowCorner = Instance.new("UICorner")
            RowCorner.CornerRadius = UDim.new(0, 8)
            RowCorner.Parent = Row

            local RowLabel = Instance.new("TextLabel")
            RowLabel.Size = UDim2.new(1, -60, 1, 0)
            RowLabel.Position = UDim2.new(0, 12, 0, 0)
            RowLabel.BackgroundTransparency = 1
            RowLabel.Text = "👤 " .. name
            RowLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
            RowLabel.TextSize = 14
            RowLabel.Font = Enum.Font.Gotham
            RowLabel.TextXAlignment = Enum.TextXAlignment.Left
            RowLabel.Parent = Row

            local RemoveBtn = Instance.new("TextButton")
            RemoveBtn.Size = UDim2.new(0, 44, 0, 30)
            RemoveBtn.Position = UDim2.new(1, -52, 0.5, -15)
            RemoveBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            RemoveBtn.Text = "✕"
            RemoveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            RemoveBtn.TextSize = 16
            RemoveBtn.Font = Enum.Font.GothamBold
            RemoveBtn.BorderSizePixel = 0
            RemoveBtn.Parent = Row

            local RemoveCorner = Instance.new("UICorner")
            RemoveCorner.CornerRadius = UDim.new(0, 8)
            RemoveCorner.Parent = RemoveBtn

            RemoveBtn.MouseButton1Click:Connect(function()
                table.remove(Settings.Friends, i)
                RebuildFriendsList()
            end)
        end
        if #Settings.Friends == 0 then
            local Empty = Instance.new("TextLabel")
            Empty.Size = UDim2.new(1, 0, 0, 30)
            Empty.BackgroundTransparency = 1
            Empty.Text = "— список пуст —"
            Empty.TextColor3 = Color3.fromRGB(100, 100, 110)
            Empty.TextSize = 12
            Empty.Font = Enum.Font.Gotham
            Empty.Parent = FriendsListFrame
        end
    end

    CreateButton(friendsFrame, "➕ Добавить в друзья", function()
        local nick = string.gsub(NickBox.Text, "^%s*(.-)%s*$", "%1")
        if nick ~= "" then
            local exists = false
            for _, n in pairs(Settings.Friends) do
                if string.lower(n) == string.lower(nick) then exists = true break end
            end
            if not exists then
                table.insert(Settings.Friends, nick)
            end
            NickBox.Text = ""
            RebuildFriendsList()
        end
    end)

    CreateButton(friendsFrame, "🧹 Очистить список", function()
        Settings.Friends = {}
        RebuildFriendsList()
    end)

    RebuildFriendsList()

    -- ═══ МИСЦ-ВКЛАДКА ═══
    local miscFrame = TabFrames["🔧 Миск"]

    CreateToggle(miscFrame, "Анти-АФК", Settings.Misc.AntiAFK, function(v)
        Settings.Misc.AntiAFK = v
    end)

    CreateButton(miscFrame, "🌀 Спинбот (вкл/выкл)", function()
        ToggleSpinbot()
    end)

    CreateSlider(miscFrame, "Скорость спина", 1, 50, Settings.Misc.SpinSpeed, function(v)
        Settings.Misc.SpinSpeed = v
    end)

    CreateButton(miscFrame, "🔄 Перезапустить GUI", function()
        CreateGUI()
    end)

    CreateButton(miscFrame, "❌ Удалить чит", function()
        ScreenGui:Destroy()
        if FOVCircle then FOVCircle:Remove() end
        for _, esp in pairs(ESPObjects) do
            for _, obj in pairs(esp) do
                if typeof(obj) == "table" and obj.Remove then
                    obj:Remove()
                end
            end
        end
        if NoclipConnection then NoclipConnection:Disconnect() end
        if SpinConnection then SpinConnection:Disconnect() end
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
    end)

    -- ═══ ИНФО-ВКЛАДКА ═══
    local infoFrame = TabFrames["ℹ️ Инфо"]

    local InfoText = Instance.new("TextLabel")
    InfoText.Size = UDim2.new(1, -10, 0, 380)
    InfoText.BackgroundTransparency = 1
    InfoText.Text = [[
📋 MVS DUELS CHEAT v1.0 [MOBILE]

🎯 УПРАВЛЕНИЕ:
• Круглая кнопка 🎯 — открыть/закрыть меню
• «—» на панели — свернуть меню
  (верхняя полоса с текстом останется,
  нажми на неё чтобы развернуть)
• Зажми 🎯 ЦЕЛИТЬСЯ — аимбот работает
  пока держишь (или вкл/выкл в настройках)

👥 ДРУЗЬЯ:
• Вкладка «Друзья» — введи ник,
  жми ➕. Друзья не подсвечиваются
  и не захватываются аимом.

⚙️ СОВЕТЫ:
• FOV 150-250 — комфортно
• Плавность 10-20 — легит
• Плавность 0 — мгновенный аим
• ESP MaxDistance 500-1000

⚠️ Используй на свой страх и риск!
    ]]
    InfoText.TextColor3 = Color3.fromRGB(180, 180, 180)
    InfoText.TextSize = 12
    InfoText.Font = Enum.Font.Code
    InfoText.TextXAlignment = Enum.TextXAlignment.Left
    InfoText.TextYAlignment = Enum.TextYAlignment.Top
    InfoText.TextWrapped = true
    InfoText.Parent = infoFrame

    -- ═══ HUD-КНОПКА: ПОКАЗ/СКРЫТЬ МЕНЮ ═══
    HudBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
        HudBtn.Text = MainFrame.Visible and "✕" or "🎯"
    end)

    MainFrame.Visible = true
    UpdateAimStatus()
end

-- ═══════════════ ЗАПУСК ═══════════════
CreateGUI()

print("═══════════════════════════════")
print("  ✅ MVS Duels Cheat [MOBILE]")
print("  🎯 Круглая кнопка — меню")
print("  🎯 Зажми ЦЕЛИТЬСЯ — аим")
print("═══════════════════════════════")
