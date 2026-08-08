-- ==================================================
-- MOTE HUB BETA 1.7 - FIX ESP TRACER LINE & FLY MODE
-- ==================================================

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--------------------------------------------------
-- CẤU HÌNH TRẠNG THÁI (FLAGS)
--------------------------------------------------
local Flags = {
    AntiAFK = true,
    MonsterNotify = true,
    SmartFullbright = false,
    FullbrightIntensity = 50,
    AutoLootAndDoor = false,
    
    ESPDoor = false,
    ESPItems = false,
    ESPMonster = false,
    ESPPlayer = false,
    
    NoClip = false,
    DoorsJump = false,
    SpeedHack = false,
    SpeedMultiplier = 1.0,
    ThirdPerson = false,
    FlyCarpet = false,
    
    Language = "VIE",
    Theme = "YellowBlack",
    TextSize = 13
}

local OriginalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

--------------------------------------------------
-- PALETTE MÀU THEME MENU
--------------------------------------------------
local Themes = {
    YellowBlack = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(255, 215, 0), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) },
    RedBlack = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(239, 68, 68), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) },
    GreenBlack = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(34, 197, 94), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) },
    PinkBlack = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(236, 72, 153), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) }
}

local Translations = {
    VIE = { Main = "Main", ESP = "ESP", Experimental = "Thử Nghiệm", Info = "Info", Settings = "Settings", AntiAFK = "1. Anti-AFK", MonsterNotify = "2. Cảnh Báo Quái Vật", Fullbright = "3. Nhìn Trong Bóng Tối", AutoLoot = "4. Auto Mở Cửa Key & Loot", NoClip = "1. NoClip (Xuyên Tường)", Jump = "2. Nút Nhảy DOORS", Speed = "3. Speed Hack", ThirdPerson = "4. Góc Nhìn Thứ 3", FlyCarpet = "5. Bay Sáng Tạo (Minecraft Fly)", ThemeTitle = "1. Đổi Màu Menu", LangTitle = "2. Ngôn Ngữ (Language)", FontSizeTitle = "3. Kích Thước Chữ", Author = "Tác Giả: By Mờ Tê", Facebook = "Facebook: Nguyễn minh tân", Version = "Phiên Bản: Mote Hub Beta 1.7" },
    ENG = { Main = "Main", ESP = "ESP", Experimental = "Experimental", Info = "Info", Settings = "Settings", AntiAFK = "1. Anti-AFK", MonsterNotify = "2. Monster Notify", Fullbright = "3. Fullbright", AutoLoot = "4. Auto Key & Loot", NoClip = "1. NoClip", Jump = "2. DOORS Jump Button", Speed = "3. Speed Hack", ThirdPerson = "4. Third Person View", FlyCarpet = "5. Creative Fly (Minecraft)", ThemeTitle = "1. Change Theme", LangTitle = "2. Language", FontSizeTitle = "3. Text Size", Author = "Author: By Mote", Facebook = "Facebook: Nguyen minh tan", Version = "Version: Mote Hub Beta 1.7" }
}

--------------------------------------------------
-- 1. TÍNH NĂNG BAY SÁNG TẠO (MINECRAFT FLY MODE)
--------------------------------------------------
local flyBodyVel = nil
local flyBodyGyro = nil
local flyVerticalSpeed = 0

RunService.RenderStepped:Connect(function()
    if Flags.FlyCarpet and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if hrp and humanoid and humanoid.Health > 0 then
            if not flyBodyVel or not flyBodyVel.Parent then
                flyBodyVel = Instance.new("BodyVelocity")
                flyBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                flyBodyVel.Parent = hrp
            end
            if not flyBodyGyro or not flyBodyGyro.Parent then
                flyBodyGyro = Instance.new("BodyGyro")
                flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                flyBodyGyro.P = 9000
                flyBodyGyro.Parent = hrp
            end
            
            humanoid.PlatformStand = true
            flyBodyGyro.CFrame = Camera.CFrame
            
            local moveDir = humanoid.MoveDirection
            local speed = (Flags.SpeedHack and (16 * Flags.SpeedMultiplier) or 20)
            flyBodyVel.Velocity = (moveDir * speed) + Vector3.new(0, flyVerticalSpeed, 0)
        end
    else
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
        end
        if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        flyVerticalSpeed = 0
    end
end)

--------------------------------------------------
-- 2. TÍNH NĂNG GÓC NHÌN THỨ 3 (FIX CAMERA KHÔNG KHÓA)
--------------------------------------------------
local savedMinZoom = LocalPlayer.CameraMinZoomDistance
local savedMaxZoom = LocalPlayer.CameraMaxZoomDistance

RunService.RenderStepped:Connect(function()
    if Flags.ThirdPerson and LocalPlayer.Character then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMinZoomDistance = 8
        LocalPlayer.CameraMaxZoomDistance = 15
    else
        LocalPlayer.CameraMinZoomDistance = savedMinZoom
        LocalPlayer.CameraMaxZoomDistance = savedMaxZoom
    end
end)

--------------------------------------------------
-- 3. HỆ THỐNG ESP PLAYER CHUẨN XÁC (FIX LỆCH SỢI DÂY)
--------------------------------------------------
local PlayerESPContainer = {}

local function createPlayerESP(plr)
    if plr == LocalPlayer then return end
    
    local box = Drawing.new("Square")
    box.Visible = false; box.Color = Color3.fromRGB(0, 255, 128); box.Thickness = 1.5; box.Filled = false
    
    local line = Drawing.new("Line")
    line.Visible = false; line.Color = Color3.fromRGB(0, 255, 128); line.Thickness = 1
    
    local text = Drawing.new("Text")
    text.Visible = false; text.Color = Color3.fromRGB(255, 255, 255); text.Size = 13; text.Center = true; text.Outline = true

    PlayerESPContainer[plr] = { Box = box, Line = line, Text = text }
end

local function removePlayerESP(plr)
    if PlayerESPContainer[plr] then
        pcall(function()
            PlayerESPContainer[plr].Box:Remove()
            PlayerESPContainer[plr].Line:Remove()
            PlayerESPContainer[plr].Text:Remove()
        end)
        PlayerESPContainer[plr] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do createPlayerESP(p) end
Players.PlayerAdded:Connect(createPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)

RunService.RenderStepped:Connect(function()
    for plr, esp in pairs(PlayerESPContainer) do
        if Flags.ESPPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myHRP = LocalPlayer.Character.HumanoidRootPart
            local targetHRP = plr.Character.HumanoidRootPart
            local head = plr.Character:FindFirstChild("Head") or targetHRP
            
            local pos, onScreen = Camera:WorldToViewportPoint(targetHRP.Position)
            
            if onScreen then
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(targetHRP.Position - Vector3.new(0, 3, 0))
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 1.8
                
                -- Khung Viền Box
                esp.Box.Size = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                esp.Box.Visible = true
                
                -- Sợi dây nối Tracer chuẩn
                -- Tính điểm xuất phát ngay tại giữa mép dưới màn hình (chuẩn theo camera viewport)
                local screenCenterBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 10)
                
                esp.Line.From = screenCenterBottom
                esp.Line.To = Vector2.new(pos.X, legPos.Y)
                esp.Line.Visible = true
                
                -- Tên & Khoảng cách
                local dist = math.floor((myHRP.Position - targetHRP.Position).Magnitude)
                esp.Text.Text = string.format("%s\n[%d studs]", plr.DisplayName, dist)
                esp.Text.Position = Vector2.new(pos.X, pos.Y - height / 2 - 28)
                esp.Text.Visible = true
            else
                esp.Box.Visible = false; esp.Line.Visible = false; esp.Text.Visible = false
            end
        else
            esp.Box.Visible = false; esp.Line.Visible = false; esp.Text.Visible = false
        end
    end
end)

--------------------------------------------------
-- 4. LOGIC AUTO LOOT & CỬA
--------------------------------------------------
local function isPromptValid(prompt)
    if not prompt or not prompt.Parent or not prompt.Enabled then return false end
    local parent = prompt.Parent
    if parent:GetAttribute("Opened") == true or parent:GetAttribute("State") == true or parent:GetAttribute("Open") == true then return false end
    if parent.Parent and (parent.Parent:GetAttribute("Opened") == true or parent.Parent:GetAttribute("Open") == true) then return false end
    return true
end

local function scanAndClassifyObject(prompt)
    if not isPromptValid(prompt) then return nil end
    local parent = prompt.Parent
    local parentName = parent.Name:lower()
    local modelName = parent.Parent and parent.Parent.Name:lower() or ""

    if parentName:find("lock") or modelName:find("lock") or parentName:find("door") or modelName:find("door") then
        if prompt.ActionText:lower():find("unlock") or prompt.ObjectText:lower():find("lock") or prompt.ActionText:lower():find("mở") then
            return "DOOR_LOCKED"
        end
    end
    if parentName:find("drawer") or parentName:find("knob") or parentName:find("cabinet") or parentName:find("dresser") or parentName:find("desk") or modelName:find("drawer") or modelName:find("cabinet") then
        return "CONTAINER"
    end
    if parentName:find("gold") or parentName:find("coin") or modelName:find("gold") or prompt.ActionText:lower():find("take") or prompt.ActionText:lower():find("lấy") then
        return "LOOT_ITEM"
    end
    return nil
end

task.spawn(function()
    while true do
        task.wait(0.25)
        if Flags.AutoLootAndDoor and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local hasKey = false
            for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
                if item:IsA("Tool") and (item.Name:find("Key") or item.Name:find("KeyObtain")) then hasKey = true break end
            end
            if not hasKey and LocalPlayer:FindFirstChild("Backpack") then
                for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if item:IsA("Tool") and (item.Name:find("Key") or item.Name:find("KeyObtain")) then hasKey = true break end
                end
            end

            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if not Flags.AutoLootAndDoor then break end
                if prompt:IsA("ProximityPrompt") then
                    local category = scanAndClassifyObject(prompt)
                    if category then
                        local targetPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                        if targetPart then
                            local dist = (hrp.Position - targetPart.Position).Magnitude
                            if category == "DOOR_LOCKED" and hasKey and dist <= prompt.MaxActivationDistance + 3 then
                                pcall(function() fireproximityprompt(prompt) end)
                            elseif (category == "CONTAINER" or category == "LOOT_ITEM") and dist <= prompt.MaxActivationDistance then
                                pcall(function() fireproximityprompt(prompt) end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

--------------------------------------------------
-- SPEED HACK, NOCLIP & FULLBRIGHT
--------------------------------------------------
RunService.Stepped:Connect(function()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if Flags.SpeedHack then
                humanoid.WalkSpeed = 16 * Flags.SpeedMultiplier
            elseif humanoid.WalkSpeed ~= 16 then
                humanoid.WalkSpeed = 16
            end
        end
        if Flags.NoClip then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end
end)

task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if Flags.AntiAFK then
            pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
        end
    end)
end)

local isFullbrightApplied = false
task.spawn(function()
    while task.wait(0.3) do
        if Flags.SmartFullbright then
            pcall(function()
                local val = (Flags.FullbrightIntensity / 100) * 2
                Lighting.Brightness = math.max(0.5, val)
                Lighting.ClockTime = 14; Lighting.FogEnd = 1000000; Lighting.GlobalShadows = false
                local ambValue = math.floor((Flags.FullbrightIntensity / 100) * 255)
                Lighting.Ambient = Color3.fromRGB(ambValue, ambValue, ambValue)
                Lighting.OutdoorAmbient = Color3.fromRGB(ambValue, ambValue, ambValue)
                isFullbrightApplied = true
            end)
        elseif isFullbrightApplied then
            isFullbrightApplied = false
            pcall(function()
                Lighting.Brightness = OriginalLighting.Brightness
                Lighting.ClockTime = OriginalLighting.ClockTime
                Lighting.FogEnd = OriginalLighting.FogEnd
                Lighting.GlobalShadows = OriginalLighting.GlobalShadows
                Lighting.Ambient = OriginalLighting.Ambient
                Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
            end)
        end
    end
end)

--------------------------------------------------
-- ESP CỬA, ITEM VÀ NOTIFY QUÁI
--------------------------------------------------
local ImportantItems = { ["KeyObtain"] = "🔑 Key", ["Key"] = "🔑 Key", ["MasterKey"] = "🔑 Master Key", ["Flashlight"] = "🔦 Flashlight", ["Candle"] = "🕯️ Candle", ["Crucifix"] = "✝️ Crucifix", ["Lockpick"] = "🗝️ Lockpick", ["Bandage"] = "🩹 Bandage", ["Vitamins"] = "💊 Vitamins", ["Battery"] = "🔋 Battery", ["LiveHintBook"] = "📘 Book", ["FuseInPlainSight"] = "🔋 Fuse" }
local MonsterInfo = { ["RushMoving"] = { Name = "Rush", Advice = "Trốn vào tủ ngay!" }, ["AmbushMoving"] = { Name = "Ambush", Advice = "Trốn tủ & chuẩn bị ra/vào!" }, ["FigureRig"] = { Name = "Figure", Advice = "CẢNH BÁO: Figure ở gần!" }, ["Screech"] = { Name = "Screech", Advice = "Nhìn thẳng vào nó!" }, ["Eyes"] = { Name = "Eyes", Advice = "Đừng nhìn nó!" }, ["Halt"] = { Name = "Halt", Advice = "Đổi hướng đi ngược lại!" }, ["A60"] = { Name = "A-60", Advice = "Trốn tủ ngay!" }, ["A120"] = { Name = "A-120", Advice = "Trốn tủ cẩn thận!" } }
local notifiedMonsters = {}

local function processObject(obj)
    pcall(function()
        if not (obj:IsA("Model") or obj:IsA("Tool") or obj:IsA("BasePart")) then return end
        if obj.Name == "Door" and obj:IsA("Model") and not obj:FindFirstChild("Mote_DoorTag", true) then
            local doorPart = obj:FindFirstChild("Door") or obj:FindFirstChildWhichIsA("BasePart")
            if doorPart then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "Mote_DoorTag"; billboard.Adornee = doorPart; billboard.Size = UDim2.new(0, 160, 0, 35); billboard.StudsOffset = Vector3.new(0, 2.5, 0); billboard.AlwaysOnTop = true
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1; label.TextStrokeTransparency = 0; label.TextSize = 13; label.Font = Enum.Font.SourceSansBold; label.TextColor3 = Color3.fromRGB(0, 255, 128); label.Parent = billboard
                billboard.Parent = doorPart
                task.spawn(function()
                    while obj and obj.Parent do
                        if Flags.ESPDoor and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            billboard.Enabled = true
                            local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - doorPart.Position).Magnitude)
                            label.Text = string.format("🚪 Cửa\n[%d studs]", dist)
                        else billboard.Enabled = false end
                        task.wait(0.25)
                    end
                end)
            end
        end

        if ImportantItems[obj.Name] and not obj:FindFirstChild("Mote_ItemTag", true) then
            local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "Mote_ItemTag"; billboard.Adornee = targetPart; billboard.Size = UDim2.new(0, 140, 0, 30); billboard.StudsOffset = Vector3.new(0, 1.2, 0); billboard.AlwaysOnTop = true
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1; label.TextColor3 = Color3.fromRGB(0, 255, 255); label.TextStrokeTransparency = 0; label.TextSize = 12; label.Font = Enum.Font.SourceSansBold; label.Parent = billboard
                billboard.Parent = targetPart
                task.spawn(function()
                    while obj and obj.Parent and obj:IsDescendantOf(Workspace) do
                        if Flags.ESPItems and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            billboard.Enabled = true
                            local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude)
                            label.Text = string.format("%s\n[%d studs]", ImportantItems[obj.Name], dist)
                        else billboard.Enabled = false end
                        task.wait(0.2)
                    end
                    pcall(function() billboard:Destroy() end)
                end)
            end
        end

        local monsterData = MonsterInfo[obj.Name]
        if monsterData and not notifiedMonsters[obj] then
            if Flags.MonsterNotify then
                notifiedMonsters[obj] = true
                pcall(function() StarterGui:SetCore("SendNotification", { Title = "⚠️ " .. monsterData.Name .. "!", Text = monsterData.Advice, Duration = 5 }) end)
            end
        end
    end)
end

for _, obj in ipairs(Workspace:GetDescendants()) do processObject(obj) end
Workspace.DescendantAdded:Connect(processObject)

--------------------------------------------------
-- THIẾT KẾ GIAO DIỆN NGANG (HORIZONTAL UI)
--------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoteHub_Beta17"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local circleBtn = Instance.new("TextButton")
circleBtn.Size = UDim2.new(0, 50, 0, 50); circleBtn.Position = UDim2.new(0.05, 0, 0.2, 0); circleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); circleBtn.TextColor3 = Themes.YellowBlack.Accent; circleBtn.Text = "mote"; circleBtn.Font = Enum.Font.GothamBold; circleBtn.TextSize = 13; circleBtn.Parent = screenGui
makeDraggable(circleBtn)
local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(1, 0); btnCorner.Parent = circleBtn
local btnStroke = Instance.new("UIStroke"); btnStroke.Color = Themes.YellowBlack.Accent; btnStroke.Thickness = 2; btnStroke.Parent = circleBtn

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 520, 0, 280); mainFrame.Position = UDim2.new(0.25, 0, 0.3, 0); mainFrame.BackgroundColor3 = Themes.YellowBlack.FrameBg; mainFrame.BorderSizePixel = 0; mainFrame.Visible = false; mainFrame.Parent = screenGui
makeDraggable(mainFrame)
local frameCorner = Instance.new("UICorner"); frameCorner.CornerRadius = UDim.new(0, 10); frameCorner.Parent = mainFrame
local frameStroke = Instance.new("UIStroke"); frameStroke.Color = Themes.YellowBlack.Accent; frameStroke.Thickness = 2; frameStroke.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 36); titleLabel.BackgroundColor3 = Themes.YellowBlack.HeaderBg; titleLabel.TextColor3 = Themes.YellowBlack.Accent; titleLabel.Text = "   MOTE HUB BETA 1.7"; titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextSize = 14; titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.Parent = mainFrame
local titleCorner = Instance.new("UICorner"); titleCorner.CornerRadius = UDim.new(0, 10); titleCorner.Parent = titleLabel

local tabNav = Instance.new("Frame")
tabNav.Size = UDim2.new(0.96, 0, 0, 30); tabNav.Position = UDim2.new(0.02, 0, 0.15, 0); tabNav.BackgroundTransparency = 1; tabNav.Parent = mainFrame

local tabs, pages = {}, {}
local tabNames = {"Main", "ESP", "Experimental", "Info", "Settings"}

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(0.96, 0, 0.72, 0); contentFrame.Position = UDim2.new(0.02, 0, 0.26, 0); contentFrame.BackgroundColor3 = Themes.YellowBlack.InnerBg; contentFrame.BorderSizePixel = 0; contentFrame.Parent = mainFrame
local contentCorner = Instance.new("UICorner"); contentCorner.CornerRadius = UDim.new(0, 8); contentCorner.Parent = contentFrame

local registeredUIElements = { ToggleStrokes = {} }

local function applyTheme()
    local t = Themes[Flags.Theme]
    mainFrame.BackgroundColor3 = t.FrameBg; frameStroke.Color = t.Accent
    titleLabel.BackgroundColor3 = t.HeaderBg; titleLabel.TextColor3 = t.Accent
    circleBtn.TextColor3 = t.Accent; btnStroke.Color = t.Accent

    for idx, btn in ipairs(tabs) do
        if pages[idx].Visible then
            btn.BackgroundColor3 = t.Accent; btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); btn.TextColor3 = t.Text
        end
    end

    for _, obj in ipairs(registeredUIElements.ToggleStrokes) do
        if obj.FlagValue then obj.Stroke.Color = t.Accent else obj.Stroke.Color = Color3.fromRGB(80, 80, 80) end
        if obj.Dot then obj.Dot.BackgroundColor3 = obj.FlagValue and t.Accent or Color3.fromRGB(150, 150, 150) end
    end
end

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.19, 0, 1, 0); btn.Position = UDim2.new((i - 1) * 0.202, 0, 0, 0); btn.BackgroundColor3 = (i == 1) and Themes.YellowBlack.Accent or Color3.fromRGB(35, 35, 35); btn.TextColor3 = (i == 1) and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 12; btn.Text = Translations[Flags.Language][name] or name; btn.Parent = tabNav
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -10, 1, -10); page.Position = UDim2.new(0, 5, 0, 5); page.BackgroundTransparency = 1; page.ScrollBarThickness = 4; page.Visible = (i == 1); page.Parent = contentFrame
    
    tabs[i] = btn; pages[i] = page

    btn.MouseButton1Click:Connect(function()
        for j, p in ipairs(pages) do
            p.Visible = (j == i)
            tabs[j].BackgroundColor3 = (j == i) and Themes[Flags.Theme].Accent or Color3.fromRGB(35, 35, 35)
            tabs[j].TextColor3 = (j == i) and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        end
    end)
end

local function createToggleSwitch(parent, labelText, flagName, posY, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.96, 0, 0, 32); container.Position = UDim2.new(0.02, 0, 0, posY); container.BackgroundTransparency = 1; container.Parent = parent

    local textLbl = Instance.new("TextLabel")
    textLbl.Size = UDim2.new(0.7, 0, 1, 0); textLbl.BackgroundTransparency = 1; textLbl.Text = labelText; textLbl.Font = Enum.Font.SourceSansBold; textLbl.TextSize = Flags.TextSize; textLbl.TextColor3 = Color3.fromRGB(255, 255, 255); textLbl.TextXAlignment = Enum.TextXAlignment.Left; textLbl.Parent = container

    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 44, 0, 22); toggleBg.Position = UDim2.new(1, -48, 0.5, -11); toggleBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15); toggleBg.Text = ""; toggleBg.AutoButtonColor = false; toggleBg.Parent = container
    local toggleCorner = Instance.new("UICorner"); toggleCorner.CornerRadius = UDim.new(1, 0); toggleCorner.Parent = toggleBg
    local toggleStroke = Instance.new("UIStroke"); toggleStroke.Thickness = 1.5; toggleStroke.Parent = toggleBg

    local toggleDot = Instance.new("Frame")
    toggleDot.Size = UDim2.new(0, 16, 0, 16); toggleDot.Parent = toggleBg
    local dotCorner = Instance.new("UICorner"); dotCorner.CornerRadius = UDim.new(1, 0); dotCorner.Parent = toggleDot

    local record = { Stroke = toggleStroke, Dot = toggleDot, FlagValue = Flags[flagName] }
    table.insert(registeredUIElements.ToggleStrokes, record)

    local function updateVisual(animated)
        local isON = Flags[flagName]
        record.FlagValue = isON
        local tTheme = Themes[Flags.Theme]
        local targetPos = isON and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetColor = isON and tTheme.Accent or Color3.fromRGB(150, 150, 150)
        local targetStroke = isON and tTheme.Accent or Color3.fromRGB(80, 80, 80)

        if animated then
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {Position = targetPos, BackgroundColor3 = targetColor}):Play()
            TweenService:Create(toggleStroke, TweenInfo.new(0.2), {Color = targetStroke}):Play()
        else
            toggleDot.Position = targetPos; toggleDot.BackgroundColor3 = targetColor; toggleStroke.Color = targetStroke
        end
    end

    toggleBg.MouseButton1Click:Connect(function()
        Flags[flagName] = not Flags[flagName]
        updateVisual(true)
        if callback then callback(Flags[flagName]) end
    end)

    updateVisual(false)
    return container
end

local function createSlider(parent, labelText, minVal, maxVal, currentVal, posY, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.96, 0, 0, 40); container.Position = UDim2.new(0.02, 0, 0, posY); container.BackgroundTransparency = 1; container.Parent = parent

    local textLbl = Instance.new("TextLabel")
    textLbl.Size = UDim2.new(0.7, 0, 0, 18); textLbl.BackgroundTransparency = 1; textLbl.Text = labelText .. ": " .. tostring(currentVal); textLbl.Font = Enum.Font.SourceSansBold; textLbl.TextSize = Flags.TextSize; textLbl.TextColor3 = Color3.fromRGB(255, 255, 255); textLbl.TextXAlignment = Enum.TextXAlignment.Left; textLbl.Parent = container

    local sliderTrack = Instance.new("TextButton")
    sliderTrack.Size = UDim2.new(1, 0, 0, 8); sliderTrack.Position = UDim2.new(0, 0, 0, 24); sliderTrack.BackgroundColor3 = Color3.fromRGB(15, 15, 15); sliderTrack.Text = ""; sliderTrack.AutoButtonColor = false; sliderTrack.Parent = container
    local trackCorner = Instance.new("UICorner"); trackCorner.CornerRadius = UDim.new(1, 0); trackCorner.Parent = sliderTrack

    local sliderFill = Instance.new("Frame")
    local initRatio = math.clamp((currentVal - minVal) / (maxVal - minVal), 0, 1)
    sliderFill.Size = UDim2.new(initRatio, 0, 1, 0); sliderFill.BackgroundColor3 = Themes[Flags.Theme].Accent; sliderFill.BorderSizePixel = 0; sliderFill.Parent = sliderTrack
    local fillCorner = Instance.new("UICorner"); fillCorner.CornerRadius = UDim.new(1, 0); fillCorner.Parent = sliderFill

    local isDragging = false
    local function updateValue(input)
        local posX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(posX, 0, 1, 0)
        local val = math.floor(minVal + (maxVal - minVal) * posX * 10) / 10
        textLbl.Text = labelText .. ": " .. tostring(val)
        if callback then callback(val) end
    end

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true; updateValue(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateValue(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end
    end)

    return container
end

--------------------------------------------------
-- NÚT NHẢY & CỤM ĐIỀU KHIỂN NÂNG HẠ ĐỘ CAO BAY
--------------------------------------------------
local jumpButtonUI = Instance.new("TextButton")
jumpButtonUI.Size = UDim2.new(0, 55, 0, 55); jumpButtonUI.Position = UDim2.new(0.85, 0, 0.7, 0); jumpButtonUI.BackgroundColor3 = Color3.fromRGB(20, 20, 20); jumpButtonUI.TextColor3 = Color3.fromRGB(255, 255, 255); jumpButtonUI.Text = "NHẢY"; jumpButtonUI.Font = Enum.Font.GothamBold; jumpButtonUI.TextSize = 12; jumpButtonUI.Visible = false; jumpButtonUI.Parent = screenGui
makeDraggable(jumpButtonUI)
local jc = Instance.new("UICorner"); jc.CornerRadius = UDim.new(1, 0); jc.Parent = jumpButtonUI
local js = Instance.new("UIStroke"); js.Color = Color3.fromRGB(255, 255, 255); js.Thickness = 2; js.Parent = jumpButtonUI

jumpButtonUI.MouseButton1Click:Connect(function()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and hrp then
            humanoid.UseJumpPower = true; humanoid.JumpPower = 65
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 55, hrp.AssemblyLinearVelocity.Z)
        end
    end
end)

local flyControlFrame = Instance.new("Frame")
flyControlFrame.Size = UDim2.new(0, 45, 0, 95); flyControlFrame.Position = UDim2.new(0.02, 0, 0.5, 0); flyControlFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); flyControlFrame.Visible = false; flyControlFrame.Parent = screenGui
makeDraggable(flyControlFrame)
local ccC = Instance.new("UICorner"); ccC.CornerRadius = UDim.new(0, 8); ccC.Parent = flyControlFrame
local ccS = Instance.new("UIStroke"); ccS.Color = Color3.fromRGB(160, 32, 240); ccS.Thickness = 2; ccS.Parent = flyControlFrame

local btnUp = Instance.new("TextButton")
btnUp.Size = UDim2.new(1, 0, 0.5, 0); btnUp.BackgroundTransparency = 1; btnUp.Text = "▲"; btnUp.TextColor3 = Color3.fromRGB(0, 255, 128); btnUp.Font = Enum.Font.GothamBold; btnUp.TextSize = 18; btnUp.Parent = flyControlFrame

local btnDown = Instance.new("TextButton")
btnDown.Size = UDim2.new(1, 0, 0.5, 0); btnDown.Position = UDim2.new(0, 0, 0.5, 0); btnDown.BackgroundTransparency = 1; btnDown.Text = "▼"; btnDown.TextColor3 = Color3.fromRGB(255, 50, 50); btnDown.Font = Enum.Font.GothamBold; btnDown.TextSize = 18; btnDown.Parent = flyControlFrame

btnUp.MouseButton1Down:Connect(function() flyVerticalSpeed = 25 end)
btnUp.MouseButton1Up:Connect(function() flyVerticalSpeed = 0 end)
btnDown.MouseButton1Down:Connect(function() flyVerticalSpeed = -25 end)
btnDown.MouseButton1Up:Connect(function() flyVerticalSpeed = 0 end)

--------------------------------------------------
-- ĐỔ NỘI DUNG CÁC TAB
--------------------------------------------------
-- TAB 1: MAIN
createToggleSwitch(pages[1], Translations[Flags.Language].AntiAFK, "AntiAFK", 5)
createToggleSwitch(pages[1], Translations[Flags.Language].MonsterNotify, "MonsterNotify", 40)
createToggleSwitch(pages[1], Translations[Flags.Language].Fullbright, "SmartFullbright", 75)
createSlider(pages[1], "  └ Độ Sáng", 0, 100, Flags.FullbrightIntensity, 110, function(val) Flags.FullbrightIntensity = val end)
createToggleSwitch(pages[1], Translations[Flags.Language].AutoLoot, "AutoLootAndDoor", 155)

-- TAB 2: ESP
createToggleSwitch(pages[2], "ESP Cửa (Door)", "ESPDoor", 5)
createToggleSwitch(pages[2], "ESP Vật Phẩm (Items)", "ESPItems", 40)
createToggleSwitch(pages[2], "ESP Quái Vật (Monster)", "ESPMonster", 75)
createToggleSwitch(pages[2], "ESP Người Chơi (Box/Line/Dist)", "ESPPlayer", 110)

-- TAB 3: THỬ NGHIỆM
createToggleSwitch(pages[3], Translations[Flags.Language].NoClip, "NoClip", 5)
createToggleSwitch(pages[3], Translations[Flags.Language].Jump, "DoorsJump", 40, function(st) jumpButtonUI.Visible = st end)
createToggleSwitch(pages[3], Translations[Flags.Language].Speed, "SpeedHack", 75)
createSlider(pages[3], "  └ Tốc Độ", 1.0, 3.0, Flags.SpeedMultiplier, 110, function(val) Flags.SpeedMultiplier = val end)
createToggleSwitch(pages[3], Translations[Flags.Language].ThirdPerson, "ThirdPerson", 155)
createToggleSwitch(pages[3], Translations[Flags.Language].FlyCarpet, "FlyCarpet", 190, function(st) flyControlFrame.Visible = st end)

-- TAB 4: INFO
local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(0.96, 0, 0.9, 0); infoLbl.Position = UDim2.new(0.02, 0, 0.05, 0); infoLbl.BackgroundTransparency = 1; infoLbl.TextColor3 = Color3.fromRGB(255, 255, 255); infoLbl.Font = Enum.Font.SourceSansBold; infoLbl.TextSize = 14; infoLbl.TextYAlignment = Enum.TextYAlignment.Top; infoLbl.TextXAlignment = Enum.TextXAlignment.Left; infoLbl.Parent = pages[4]

local function updateInfoText()
    local lang = Translations[Flags.Language]
    infoLbl.Text = string.format("👑 MOTE HUB SYSTEM INFO 👑\n\n• %s\n• %s\n• %s", lang.Author, lang.Facebook, lang.Version)
end
updateInfoText()

-- TAB 5: SETTINGS
local themeLbl = Instance.new("TextLabel")
themeLbl.Size = UDim2.new(0.96, 0, 0, 20); themeLbl.Position = UDim2.new(0.02, 0, 0, 5); themeLbl.BackgroundTransparency = 1; themeLbl.Text = Translations[Flags.Language].ThemeTitle; themeLbl.Font = Enum.Font.SourceSansBold; themeLbl.TextSize = 13; themeLbl.TextColor3 = Color3.fromRGB(255, 255, 255); themeLbl.TextXAlignment = Enum.TextXAlignment.Left; themeLbl.Parent = pages[5]

local themeBtns = { { Name = "Vàng Đen", Key = "YellowBlack", Pos = 0 }, { Name = "Đỏ Đen", Key = "RedBlack", Pos = 0.25 }, { Name = "Xanh Đen", Key = "GreenBlack", Pos = 0.50 }, { Name = "Hồng Đen", Key = "PinkBlack", Pos = 0.75 } }
for _, tData in ipairs(themeBtns) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.23, 0, 0, 25); b.Position = UDim2.new(tData.Pos, 0, 0, 28); b.BackgroundColor3 = Color3.fromRGB(35, 35, 35); b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Text = tData.Name; b.Font = Enum.Font.SourceSansBold; b.TextSize = 11; b.Parent = pages[5]
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = b
    b.MouseButton1Click:Connect(function() Flags.Theme = tData.Key; applyTheme() end)
end

local langLbl = Instance.new("TextLabel")
langLbl.Size = UDim2.new(0.96, 0, 0, 20); langLbl.Position = UDim2.new(0.02, 0, 0, 62); langLbl.BackgroundTransparency = 1; langLbl.Text = Translations[Flags.Language].LangTitle; langLbl.Font = Enum.Font.SourceSansBold; langLbl.TextSize = 13; langLbl.TextColor3 = Color3.fromRGB(255, 255, 255); langLbl.TextXAlignment = Enum.TextXAlignment.Left; langLbl.Parent = pages[5]

local btnVie = Instance.new("TextButton")
btnVie.Size = UDim2.new(0.46, 0, 0, 25); btnVie.Position = UDim2.new(0, 0, 0, 85); btnVie.BackgroundColor3 = Color3.fromRGB(35, 35, 35); btnVie.TextColor3 = Color3.fromRGB(255, 255, 255); btnVie.Text = "Tiếng Việt"; btnVie.Font = Enum.Font.SourceSansBold; btnVie.TextSize = 12; btnVie.Parent = pages[5]
local vC = Instance.new("UICorner"); vC.CornerRadius = UDim.new(0, 4); vC.Parent = btnVie

local btnEng = Instance.new("TextButton")
btnEng.Size = UDim2.new(0.5, 0, 0, 25); btnEng.Position = UDim2.new(0.5, 0, 0, 85); btnEng.BackgroundColor3 = Color3.fromRGB(35, 35, 35); btnEng.TextColor3 = Color3.fromRGB(255, 255, 255); btnEng.Text = "English"; btnEng.Font = Enum.Font.SourceSansBold; btnEng.TextSize = 12; btnEng.Parent = pages[5]
local eC = Instance.new("UICorner"); eC.CornerRadius = UDim.new(0, 4); eC.Parent = btnEng

local function refreshLanguage()
    for i, name in ipairs(tabNames) do tabs[i].Text = Translations[Flags.Language][name] or name end
    updateInfoText(); themeLbl.Text = Translations[Flags.Language].ThemeTitle; langLbl.Text = Translations[Flags.Language].LangTitle
end

btnVie.MouseButton1Click:Connect(function() Flags.Language = "VIE"; refreshLanguage() end)
btnEng.MouseButton1Click:Connect(function() Flags.Language = "ENG"; refreshLanguage() end)

createSlider(pages[5], Translations[Flags.Language].FontSizeTitle, 10, 18, Flags.TextSize, 120, function(val) Flags.TextSize = val end)

circleBtn.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)

applyTheme()

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "MOTE HUB BETA 1.7",
        Text = "Đã Fix chuẩn xác sợi dây ESP nối từ mép dưới màn hình!",
        Duration = 5
    })
end)
