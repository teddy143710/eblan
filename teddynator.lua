-- Arsenal Mobile Cheat Script
-- Compatible with: Delta, Fluxus, Codex, etc.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
local Settings = {
    FOVEnabled = false,
    FOVSize = 100,
    FOVColor = Color3.fromRGB(255, 255, 255),
    WallHackEnabled = false,
    FPSBoostEnabled = false,
    WHColor = Color3.fromRGB(255, 0, 0)
}

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArsenalCheat"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 400)
MainFrame.Position = UDim2.new(0, 10, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "⚡ Arsenal Cheat"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Scroll Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollFrame

-- Function to create section headers
local function CreateSection(text)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, 0, 0, 25)
    Section.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Section.Text = "  " .. text
    Section.TextColor3 = Color3.fromRGB(255, 255, 255)
    Section.Font = Enum.Font.GothamBold
    Section.TextSize = 13
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.Parent = ScrollFrame
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 4)
    SectionCorner.Parent = Section
end

-- Function to create toggle buttons
local function CreateToggle(text, callback)
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(1, 0, 0, 30)
    Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Toggle.Text = "  " .. text .. ": OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    Toggle.Font = Enum.Font.Gotham
    Toggle.TextSize = 13
    Toggle.TextXAlignment = Enum.TextXAlignment.Left
    Toggle.Parent = ScrollFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 4)
    ToggleCorner.Parent = Toggle
    
    local enabled = false
    Toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            Toggle.Text = "  " .. text .. ": ON"
            Toggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            Toggle.Text = "  " .. text .. ": OFF"
            Toggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        callback(enabled)
    end)
    
    return Toggle
end

-- Function to create sliders
local function CreateSlider(text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 45)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SliderFrame.Parent = ScrollFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 4)
    SliderCorner.Parent = SliderFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, -10, 0, 20)
    SliderLabel.Position = UDim2.new(0, 5, 0, 2)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = text .. ": " .. default
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextSize = 12
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, -10, 0, 6)
    SliderBG.Position = UDim2.new(0, 5, 0, 28)
    SliderBG.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderBG.BorderSizePixel = 0
    SliderBG.Parent = SliderFrame
    
    local SliderBGCorner = Instance.new("UICorner")
    SliderBGCorner.CornerRadius = UDim.new(1, 0)
    SliderBGCorner.Parent = SliderBG
    
    local SliderButton = Instance.new("Frame")
    SliderButton.Size = UDim2.new(0, 14, 0, 14)
    SliderButton.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.BorderSizePixel = 0
    SliderButton.Parent = SliderBG
    
    local SliderBtnCorner = Instance.new("UICorner")
    SliderBtnCorner.CornerRadius = UDim.new(1, 0)
    SliderBtnCorner.Parent = SliderButton
    
    local dragging = false
    
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        SliderButton.Position = UDim2.new(pos, -7, 0.5, -7)
        SliderLabel.Text = text .. ": " .. value
        callback(value)
    end
    
    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    SliderButton.InputEnded:Connect(function(input)
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

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Settings.FOVSize
FOVCircle.Color = Settings.FOVColor
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- Wall Hack Storage
local ESPObjects = {}

-- FPS Boost Settings
local FPSBoostConnection = nil

-- Create UI Sections
CreateSection("🎯 FOV Circle")
CreateToggle("FOV Circle", function(enabled)
    Settings.FOVEnabled = enabled
    FOVCircle.Visible = enabled
end)

CreateSlider("FOV Size", 0, 360, 100, function(value)
    Settings.FOVSize = value
    FOVCircle.Radius = value
end)

CreateSection("👁️ Wall Hack")
CreateToggle("Wall Hack", function(enabled)
    Settings.WallHackEnabled = enabled
    if not enabled then
        for _, obj in pairs(ESPObjects) do
            if obj.Highlight then
                obj.Highlight.Enabled = false
            end
        end
    end
end)

CreateSlider("WH Transparency", 0, 100, 50, function(value)
    for _, obj in pairs(ESPObjects) do
        if obj.Highlight then
            obj.Highlight.FillTransparency = value / 100
        end
    end
end)

CreateSection("⚡ FPS Boost")
CreateToggle("FPS Boost", function(enabled)
    Settings.FPSBoostEnabled = enabled
    
    if enabled then
        -- Disable shadows
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").FogEnd = 9e9
        
        -- Disable particles and effects
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                v.Enabled = false
            end
            if v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
            if v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
            end
        end
        
        -- Lower graphics quality
        settings().Rendering.QualityLevel = 1
        
        -- Disable streaming
        if sethiddenproperty then
            sethiddenproperty(workspace, "StreamingMode", Enum.StreamingMode.Disabled)
        end
        
        -- FPS Connection for continuous optimization
        FPSBoostConnection = RunService.Heartbeat:Connect(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") and v.Enabled then
                    v.Enabled = false
                end
            end
        end)
    else
        game:GetService("Lighting").GlobalShadows = true
        if FPSBoostConnection then
            FPSBoostConnection:Disconnect()
            FPSBoostConnection = nil
        end
    end
end)

CreateSection("🎨 Settings")
CreateToggle("Hide UI", function(enabled)
    MainFrame.Visible = not enabled
end)

-- FOV Circle Update
RunService.RenderStepped:Connect(function()
    if Settings.FOVEnabled then
        local screenCenter = Camera.ViewportSize / 2
        FOVCircle.Position = Vector2.new(screenCenter.X, screenCenter.Y)
        FOVCircle.Radius = Settings.FOVSize
        FOVCircle.Color = Settings.FOVColor
    end
end)

-- Wall Hack Function
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local function ApplyESP(character)
        if not character then return end
        
        -- Wait for character to load
        local humanoid = character:WaitForChild("Humanoid", 3)
        local rootPart = character:WaitForChild("HumanoidRootPart", 3)
        
        if not humanoid or not rootPart then return end
        
        -- Create Highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP"
        highlight.FillColor = Settings.WHColor
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Enabled = Settings.WallHackEnabled
        highlight.Parent = character
        
        ESPObjects[player] = {
            Highlight = highlight,
            Character = character
        }
        
        -- Remove ESP when character dies
        humanoid.Died:Connect(function()
            if ESPObjects[player] and ESPObjects[player].Highlight then
                ESPObjects[player].Highlight:Destroy()
                ESPObjects[player] = nil
            end
        end)
    end
    
    -- Apply ESP to existing character
    if player.Character then
        ApplyESP(player.Character)
    end
    
    -- Apply ESP when character spawns
    player.CharacterAdded:Connect(ApplyESP)
end

-- Remove ESP when player leaves
local function RemoveESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].Highlight then
            ESPObjects[player].Highlight:Destroy()
        end
        ESPObjects[player] = nil
    end
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-- Setup ESP for new players
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- Update ESP visibility
RunService.Heartbeat:Connect(function()
    if Settings.WallHackEnabled then
        for player, obj in pairs(ESPObjects) do
            if obj.Highlight and player.Character and player.Character:FindFirstChild("Humanoid") then
                if player.Character.Humanoid.Health > 0 then
                    obj.Highlight.Enabled = true
                    obj.Highlight.FillColor = Settings.WHColor
                else
                    obj.Highlight.Enabled = false
                end
            end
        end
    end
end)

-- Notification
local function Notify(text)
    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Size = UDim2.new(0, 200, 0, 40)
    NotifyFrame.Position = UDim2.new(0.5, -100, 0, -50)
    NotifyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    NotifyFrame.BorderSizePixel = 0
    NotifyFrame.Parent = ScreenGui
    
    local NotifyCorner = Instance.new("UICorner")
    NotifyCorner.CornerRadius = UDim.new(0, 6)
    NotifyCorner.Parent = NotifyFrame
    
    local NotifyLabel = Instance.new("TextLabel")
    NotifyLabel.Size = UDim2.new(1, -10, 1, 0)
    NotifyLabel.Position = UDim2.new(0, 5, 0, 0)
    NotifyLabel.BackgroundTransparency = 1
    NotifyLabel.Text = text
    NotifyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifyLabel.Font = Enum.Font.GothamBold
    NotifyLabel.TextSize = 14
    NotifyLabel.Parent = NotifyFrame
    
    -- Animate in
    NotifyFrame:TweenPosition(UDim2.new(0.5, -100, 0, 20), "Out", "Quad", 0.3, true)
    
    -- Remove after 3 seconds
    task.delay(3, function()
        NotifyFrame:TweenPosition(UDim2.new(0.5, -100, 0, -50), "Out", "Quad", 0.3, true, function()
            NotifyFrame:Destroy()
        end)
    end)
end

Notify("Arsenal Cheat Loaded! ✓")
