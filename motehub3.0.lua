-- ==================================================
-- MOTE HUB BETA 1.0 - SMART SCANNING & AUTO LOOT
-- Unified Door & Loot System + Smart Object Scanning
-- ==================================================

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Bảng quản lý trạng thái Bật/Tắt
local Flags = {
    AntiAFK = true,
    SpeedHack = false,
    SmartFullbright = true,
    ESPDoor = true,
    ESPItems = true,
    ESPMonster = true,
    ESPPlayer = false,
    DoorsJump = false,
    AutoLootAndDoor = true, -- Gộp: Tự động nhặt đồ & Mở cửa chìa khóa
    AutoMinigame = true,
    FlyCarpet = false,
    MonsterNotify = true
}

local SpeedMultiplier = 1.3
local lastSeekNotifyTime = 0
local figureDetectedNotified = false

-- Lưu trữ thiết lập ánh sáng mặc định NGUYÊN BẢN ban đầu của game
local OriginalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

--------------------------------------------------
-- 1. TÍNH NĂNG BỔ TRỢ & SMART FULLBRIGHT
--------------------------------------------------
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if Flags.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end)
end)

local lastBaseSpeed = 16
RunService.Stepped:Connect(function()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and Flags.SpeedHack then
            local currentSpeed = humanoid.WalkSpeed
            if currentSpeed > 0 and math.abs(currentSpeed - (lastBaseSpeed * SpeedMultiplier)) > 0.5 then
                lastBaseSpeed = currentSpeed
            end
            humanoid.WalkSpeed = lastBaseSpeed * SpeedMultiplier
        end
    end
end)

local isFullbrightApplied = false

task.spawn(function()
    while task.wait(0.3) do
        if Flags.SmartFullbright then
            pcall(function()
                local currentAmb = Lighting.Ambient
                local isDarkRoom = Workspace:FindFirstChild("Ambience_Dark", true) 
                    or (currentAmb.R < 0.1 and currentAmb.G < 0.1 and currentAmb.B < 0.1)

                if isDarkRoom then
                    if not isFullbrightApplied then
                        isFullbrightApplied = true
                        Lighting.Brightness = 1.2
                        Lighting.ClockTime = 14
                        Lighting.FogEnd = 1000000
                        Lighting.GlobalShadows = false
                        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
                        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
                    end
                else
                    if isFullbrightApplied then
                        isFullbrightApplied = false
                        Lighting.Brightness = OriginalLighting.Brightness
                        Lighting.ClockTime = OriginalLighting.ClockTime
                        Lighting.FogEnd = OriginalLighting.FogEnd
                        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
                        Lighting.Ambient = OriginalLighting.Ambient
                        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
                    end
                end
            end)
        else
            if isFullbrightApplied then
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
    end
end)

--------------------------------------------------
-- 2. HỆ THỐNG QUÉT THÔNG MINH & LOOT/CỬA TỔNG HỢP (DELAY 0.3S)
--------------------------------------------------
local carpetPart = Instance.new("Part")
carpetPart.Name = "MoteHub_MagicCarpet"
carpetPart.Size = Vector3.new(6, 0.4, 6)
carpetPart.Material = Enum.Material.Neon
carpetPart.Color = Color3.fromRGB(160, 32, 240)
carpetPart.Transparency = 0.3
carpetPart.Anchored = true
carpetPart.CanCollide = true

RunService.RenderStepped:Connect(function()
    if Flags.FlyCarpet and LocalPlayer.Character then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if rootPart and humanoid and humanoid.Health > 0 then
            carpetPart.Parent = Workspace
            carpetPart.CFrame = rootPart.CFrame * CFrame.new(0, -3.1, 0)
        else
            carpetPart.Parent = nil
        end
    else
        carpetPart.Parent = nil
    end
end)

-- CHỨC NĂNG QUÉT PHÂN BIỆT ĐỐI TƯỢNG (SMART SCANNING)
local function scanAndClassifyObject(prompt)
    if not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return nil end
    local parent = prompt.Parent
    if not parent then return nil end

    local parentName = parent.Name:lower()
    local modelName = parent.Parent and parent.Parent.Name:lower() or ""
    local promptText = (prompt.ObjectText .. " " .. prompt.ActionText):lower()

    -- 1. Phân loại: Cửa khóa cần chìa
    if parentName:find("door") or modelName:find("door") or promptText:find("unlock") or promptText:find("key") or promptText:find("mở") then
        return "DOOR_LOCKED"
    end

    -- 2. Phân loại: Tủ, kệ, ngăn kéo
    if parentName:find("drawer") or parentName:find("knob") or parentName:find("cabinet") or parentName:find("dresser") or parentName:find("desk") or parentName:find("locker") or parentName:find("chest") then
        return "CONTAINER"
    end
    if modelName:find("drawer") or modelName:find("cabinet") or modelName:find("dresser") or modelName:find("desk") or modelName:find("locker") or modelName:find("chest") then
        return "CONTAINER"
    end

    -- 3. Phân loại: Tiền, Vàng, Vật phẩm nhặt được
    if parentName:find("gold") or parentName:find("coin") or modelName:find("gold") or modelName:find("coin") or promptText:find("gold") or promptText:find("coin") or promptText:find("xu") or promptText:find("take") or promptText:find("lấy") then
        return "LOOT_ITEM"
    end

    return nil
end

-- VÒNG LẶP XỬ LÝ LOOT & MỞ CỬA CÓ DELAY 0.3S
task.spawn(function()
    while true do
        task.wait(0.3) -- Giảm thời gian chờ xuống đúng 0.3s theo yêu cầu
        if Flags.AutoLootAndDoor and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local hasKey = LocalPlayer.Character:FindFirstChild("Key") or LocalPlayer.Backpack:FindFirstChild("Key") or LocalPlayer.Character:FindFirstChild("KeyObtain") or LocalPlayer.Backpack:FindFirstChild("KeyObtain")

            for _, prompt in ipairs(Workspace:GetDescendants()) do
                local category = scanAndClassifyObject(prompt)

                if category then
                    local targetPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                    if targetPart then
                        local dist = (hrp.Position - targetPart.Position).Magnitude

                        -- Xử lý Cửa khóa
                        if category == "DOOR_LOCKED" and hasKey then
                            if dist <= prompt.MaxActivationDistance + 2 then
                                pcall(function() fireproximityprompt(prompt) end)
                            end
                        -- Xử lý Tủ / Kệ / Vàng / Item
                        elseif category == "CONTAINER" or category == "LOOT_ITEM" then
                            if dist <= prompt.MaxActivationDistance then
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
-- 3. HỆ THỐNG ESP (CỬA, VẬT PHẨM, RƯƠNG, QUÁI VẬT)
--------------------------------------------------
local ImportantItems = {
    ["KeyObtain"] = "🔑 Chìa Khóa", ["Key"] = "🔑 Chìa Khóa", ["MasterKey"] = "🔑 Chìa Khóa Vạn Năng",
    ["Flashlight"] = "🔦 Đèn Pin", ["Candle"] = "🕯️ Nến", ["Crucifix"] = "✝️ Thánh Giá",
    ["Lockpick"] = "🗝️ Móc Khóa", ["Bandage"] = "🩹 Băng Gạc", ["Vitamins"] = "💊 Vitamin",
    ["Battery"] = "🔋 Pin", ["Shears"] = "✂️ Kéo", ["HerbOfViridis"] = "🌿 Thảo Dược",
    ["ShakableLight"] = "🔦 Đèn Lắc", ["Bulklight"] = "🔦 Đèn Bão", ["LeverForGate"] = "⚡ Công Tắc",
    ["Lever"] = "⚡ Công Tắc", ["GateButton"] = "⚡ Nút Bấm Cửa", ["LiveHintBook"] = "📘 Sách",
    ["Book"] = "📘 Sách", ["HintBook"] = "📘 Sách", ["FuseInPlainSight"] = "🔋 Cầu Chì", ["Fuse"] = "🔋 Cầu Chì"
}

local MonsterInfo = {
    ["RushMoving"] = { Name = "Rush", Advice = "Trốn vào tủ hoặc hầm ngay!" },
    ["AmbushMoving"] = { Name = "Ambush", Advice = "Trốn tủ và chuẩn bị ra/vào lại!" },
    ["FigureRig"] = { Name = "Figure", Advice = "Ngồi xuống và đi rón rén!" },
    ["Screech"] = { Name = "Screech", Advice = "Quay camera nhìn thẳng vào nó!" },
    ["Eyes"] = { Name = "Eyes", Advice = "Đừng nhìn thẳng vào nó!" },
    ["Halt"] = { Name = "Halt", Advice = "Quay đầu đi ngược lại!" },
    ["Snare"] = { Name = "Snare", Advice = "Cẩn thận dưới chân, né bẫy gai!" },
    ["A60"] = { Name = "A-60", Advice = "Trốn tủ ngay lập tức!" },
    ["A120"] = { Name = "A-120", Advice = "Trốn tủ cẩn thận!" },
    ["A90"] = { Name = "A-90", Advice = "DỪNG LẠI NGAY! Không di chuyển!" },
    ["Giggle"] = { Name = "Giggle", Advice = "Tránh đứng dưới trần nhà!" },
    ["Grumble"] = { Name = "Grumble", Advice = "Giữ khoảng cách xa!" },
    ["Dread"] = { Name = "Dread", Advice = "Mở cửa phòng mới thật nhanh!" }
}

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

        if obj.Name == "Chest" or (obj.Name:find("Chest") and not obj.Name:find("Monster")) then
            if not obj:FindFirstChild("Mote_ChestTag", true) then
                local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if targetPart then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "Mote_ChestTag"; billboard.Adornee = targetPart; billboard.Size = UDim2.new(0, 140, 0, 30); billboard.StudsOffset = Vector3.new(0, 1.5, 0); billboard.AlwaysOnTop = true
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1; label.TextColor3 = Color3.fromRGB(255, 200, 50); label.TextStrokeTransparency = 0; label.TextSize = 12; label.Font = Enum.Font.SourceSansBold; label.Parent = billboard
                    billboard.Parent = targetPart
                    task.spawn(function()
                        while obj and obj.Parent do
                            if Flags.ESPItems and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                billboard.Enabled = true
                                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude)
                                label.Text = string.format("🧰 Rương Đồ\n[%d studs]", dist)
                            else billboard.Enabled = false end
                            task.wait(0.3)
                        end
                    end)
                end
            end
        elseif ImportantItems[obj.Name] then
            if not obj:FindFirstChild("Mote_ItemTag", true) then
                local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if targetPart then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "Mote_ItemTag"; billboard.Adornee = targetPart; billboard.Size = UDim2.new(0, 140, 0, 30); billboard.StudsOffset = Vector3.new(0, 1.2, 0); billboard.AlwaysOnTop = true
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1; label.TextColor3 = Color3.fromRGB(0, 255, 255); label.TextStrokeTransparency = 0; label.TextSize = 12; label.Font = Enum.Font.SourceSansBold; label.Parent = billboard
                    billboard.Parent = targetPart
                    task.spawn(function()
                        while obj and obj.Parent do
                            if Flags.ESPItems and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                billboard.Enabled = true
                                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude)
                                label.Text = string.format("%s\n[%d studs]", ImportantItems[obj.Name], dist)
                            else billboard.Enabled = false end
                            task.wait(0.3)
                        end
                    end)
                end
            end
        end

        if obj.Name:find("Seek") then
            local currentTime = tick()
            if Flags.MonsterNotify and (currentTime - lastSeekNotifyTime >= 180) then
                lastSeekNotifyTime = currentTime
                pcall(function()
                    StarterGui:SetCore("SendNotification", { Title = "⚠️ SEEK BẮT ĐẦU XUẤT HIỆN!", Text = "Chuẩn bị chạy vượt rào cản!", Duration = 6 })
                end)
            end
            return
        end

        local monsterData = MonsterInfo[obj.Name]
        if monsterData and not (obj.Parent and MonsterInfo[obj.Parent.Name]) then
            if Flags.MonsterNotify and not notifiedMonsters[obj] then
                notifiedMonsters[obj] = true
                pcall(function()
                    StarterGui:SetCore("SendNotification", { Title = "⚠️ " .. monsterData.Name .. " XUẤT HIỆN!", Text = monsterData.Advice, Duration = 5 })
                end)
            end
            local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if targetPart and not obj:FindFirstChild("Mote_MonsterTag", true) then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "Mote_MonsterTag"; billboard.Adornee = targetPart; billboard.Size = UDim2.new(0, 160, 0, 35); billboard.StudsOffset = Vector3.new(0, 2, 0); billboard.AlwaysOnTop = true
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1; label.TextColor3 = Color3.fromRGB(255, 50, 50); label.TextStrokeTransparency = 0; label.TextSize = 13; label.Font = Enum.Font.SourceSansBold; label.Parent = billboard
                billboard.Parent = targetPart
                task.spawn(function()
                    while obj and obj.Parent do
                        if Flags.ESPMonster and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            billboard.Enabled = true
                            local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude)
                            label.Text = string.format("👹 %s\n[%d studs]", monsterData.Name, dist)
                        else billboard.Enabled = false end
                        task.wait(0.2)
                    end
                end)
            end
        end
    end)
end

for _, obj in ipairs(Workspace:GetDescendants()) do processObject(obj) end
Workspace.DescendantAdded:Connect(processObject)

--------------------------------------------------
-- 4. HỆ THỐNG ESP NGƯỜI CHƠI
--------------------------------------------------
local PlayerESPObjects = {}

local function createPlayerESP(player)
    if player == LocalPlayer then return end

    local text = Drawing.new("Text")
    text.Size = 14; text.Center = true; text.Outline = true; text.OutlineColor = Color3.fromRGB(0, 0, 0); text.Color = Color3.fromRGB(180, 100, 255); text.Visible = false
    local line = Drawing.new("Line")
    line.Thickness = 1.5; line.Color = Color3.fromRGB(180, 100, 255); line.Transparency = 0.8; line.Visible = false

    PlayerESPObjects[player] = { Text = text, Line = line }
end

local function removePlayerESP(player)
    if PlayerESPObjects[player] then
        pcall(function() PlayerESPObjects[player].Text:Remove() end)
        pcall(function() PlayerESPObjects[player].Line:Remove() end)
        PlayerESPObjects[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do createPlayerESP(p) end
Players.PlayerAdded:Connect(createPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)

RunService.RenderStepped:Connect(function()
    for player, esp in pairs(PlayerESPObjects) do
        if Flags.ESPPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local myHrp = LocalPlayer.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local dist = math.floor((myHrp.Position - hrp.Position).Magnitude)
                esp.Text.Text = string.format("👤 %s\n[%d studs]", player.DisplayName or player.Name, dist)
                esp.Text.Position = Vector2.new(screenPos.X, screenPos.Y - 25)
                esp.Text.Visible = true

                esp.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.Line.To = Vector2.new(screenPos.X, screenPos.Y)
                esp.Line.Visible = true
            else
                esp.Text.Visible = false
                esp.Line.Visible = false
            end
        else
            esp.Text.Visible = false
            esp.Line.Visible = false
        end
    end
end)

--------------------------------------------------
-- 5. AUTO MINIGAME TỦ & CẢNH BÁO FIGURE
--------------------------------------------------
task.spawn(function()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    PlayerGui.ChildAdded:Connect(function(child)
        if Flags.AutoMinigame and (child.Name == "Heartbeat" or child.Name:find("Minigame")) then
            task.spawn(function()
                while child and child.Parent do
                    pcall(function()
                        local heartbeatFrame = child:FindFirstChild("Frame") or child
                        if heartbeatFrame then
                            for _, elem in ipairs(heartbeatFrame:GetDescendants()) do
                                if (elem:IsA("ImageButton") or elem:IsA("TextButton")) and elem.Visible then
                                    firesignal(elem.MouseButton1Click)
                                end
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end)
        end
    end)
end)

task.spawn(function()
    while task.wait(0.4) do
        if Flags.MonsterNotify and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local figure = Workspace:FindFirstChild("FigureRig", true)
            if figure and figure:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - figure.HumanoidRootPart.Position).Magnitude
                if dist < 18 then
                    if not figureDetectedNotified then
                        figureDetectedNotified = true
                        pcall(function()
                            StarterGui:SetCore("SendNotification", { Title = "🚨 CẢNH BÁO: FIGURE Ở CỰC GẦN!", Text = "Figure đang tiến gần! Ngồi xuống ngay!", Duration = 4 })
                        end)
                    end
                else figureDetectedNotified = false end
            end
        end
    end
end)

--------------------------------------------------
-- 6. GIAO DIỆN GUI (MOTE HUB BETA 1.0)
--------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoteHub_Beta1"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
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
circleBtn.Size = UDim2.new(0, 52, 0, 52); circleBtn.Position = UDim2.new(0.05, 0, 0.2, 0); circleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); circleBtn.TextColor3 = Color3.fromRGB(255, 215, 0); circleBtn.Text = "mote"; circleBtn.Font = Enum.Font.GothamBold; circleBtn.TextSize = 13; circleBtn.Parent = screenGui
makeDraggable(circleBtn)

local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(1, 0); btnCorner.Parent = circleBtn
local btnStroke = Instance.new("UIStroke"); btnStroke.Color = Color3.fromRGB(255, 215, 0); btnStroke.Thickness = 2; btnStroke.Parent = circleBtn

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 390); mainFrame.Position = UDim2.new(0.35, 0, 0.2, 0); mainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28); mainFrame.BorderSizePixel = 0; mainFrame.Visible = false; mainFrame.Parent = screenGui
makeDraggable(mainFrame)

local frameCorner = Instance.new("UICorner"); frameCorner.CornerRadius = UDim.new(0, 12); frameCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 38); titleLabel.BackgroundColor3 = Color3.fromRGB(12, 14, 18); titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0); titleLabel.Text = "MOTE HUB BETA 1.0"; titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextSize = 14; titleLabel.Parent = mainFrame
local titleCorner = Instance.new("UICorner"); titleCorner.CornerRadius = UDim.new(0, 12); titleCorner.Parent = titleLabel

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0.94, 0, 0, 30); tabContainer.Position = UDim2.new(0.03, 0, 0.12, 0); tabContainer.BackgroundTransparency = 1; tabContainer.Parent = mainFrame

local tab1Btn = Instance.new("TextButton")
tab1Btn.Size = UDim2.new(0.23, 0, 1, 0); tab1Btn.BackgroundColor3 = Color3.fromRGB(255, 170, 0); tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255); tab1Btn.Text = "Bổ Trợ"; tab1Btn.Font = Enum.Font.SourceSansBold; tab1Btn.TextSize = 11; tab1Btn.Parent = tabContainer
local t1C = Instance.new("UICorner"); t1C.CornerRadius = UDim.new(0, 6); t1C.Parent = tab1Btn

local tab2Btn = Instance.new("TextButton")
tab2Btn.Size = UDim2.new(0.23, 0, 1, 0); tab2Btn.Position = UDim2.new(0.25, 0, 0, 0); tab2Btn.BackgroundColor3 = Color3.fromRGB(40, 44, 52); tab2Btn.TextColor3 = Color3.fromRGB(180, 180, 180); tab2Btn.Text = "ESP"; tab2Btn.Font = Enum.Font.SourceSansBold; tab2Btn.TextSize = 11; tab2Btn.Parent = tabContainer
local t2C = Instance.new("UICorner"); t2C.CornerRadius = UDim.new(0, 6); t2C.Parent = tab2Btn

local tab3Btn = Instance.new("TextButton")
tab3Btn.Size = UDim2.new(0.25, 0, 1, 0); tab3Btn.Position = UDim2.new(0.50, 0, 0, 0); tab3Btn.BackgroundColor3 = Color3.fromRGB(40, 44, 52); tab3Btn.TextColor3 = Color3.fromRGB(180, 180, 180); tab3Btn.Text = "Tự Động"; tab3Btn.Font = Enum.Font.SourceSansBold; tab3Btn.TextSize = 11; tab3Btn.Parent = tabContainer
local t3C = Instance.new("UICorner"); t3C.CornerRadius = UDim.new(0, 6); t3C.Parent = tab3Btn

local tab4Btn = Instance.new("TextButton")
tab4Btn.Size = UDim2.new(0.22, 0, 1, 0); tab4Btn.Position = UDim2.new(0.77, 0, 0, 0); tab4Btn.BackgroundColor3 = Color3.fromRGB(40, 44, 52); tab4Btn.TextColor3 = Color3.fromRGB(180, 180, 180); tab4Btn.Text = "Info"; tab4Btn.Font = Enum.Font.SourceSansBold; tab4Btn.TextSize = 11; tab4Btn.Parent = tabContainer
local t4C = Instance.new("UICorner"); t4C.CornerRadius = UDim.new(0, 6); t4C.Parent = tab4Btn

local page1 = Instance.new("Frame"); page1.Size = UDim2.new(1, 0, 0.78, 0); page1.Position = UDim2.new(0, 0, 0.22, 0); page1.BackgroundTransparency = 1; page1.Visible = true; page1.Parent = mainFrame
local page2 = Instance.new("Frame"); page2.Size = UDim2.new(1, 0, 0.78, 0); page2.Position = UDim2.new(0, 0, 0.22, 0); page2.BackgroundTransparency = 1; page2.Visible = false; page2.Parent = mainFrame
local page3 = Instance.new("Frame"); page3.Size = UDim2.new(1, 0, 0.78, 0); page3.Position = UDim2.new(0, 0, 0.22, 0); page3.BackgroundTransparency = 1; page3.Visible = false; page3.Parent = mainFrame
local page4 = Instance.new("Frame"); page4.Size = UDim2.new(1, 0, 0.78, 0); page4.Position = UDim2.new(0, 0, 0.22, 0); page4.BackgroundTransparency = 1; page4.Visible = false; page4.Parent = mainFrame

local function createCustomButton(parent, name, flagName, posY, activeColor, inactiveColor)
    inactiveColor = inactiveColor or Color3.fromRGB(45, 48, 56)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.86, 0, 0, 32)
    btn.Position = UDim2.new(0.07, 0, 0, posY)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = parent

    local btnC = Instance.new("UICorner"); btnC.CornerRadius = UDim.new(0, 8); btnC.Parent = btn

    local function updateState()
        if Flags[flagName] then
            btn.BackgroundColor3 = activeColor
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = name .. ": BẬT"
        else
            btn.BackgroundColor3 = inactiveColor
            btn.TextColor3 = Color3.fromRGB(170, 170, 170)
            btn.Text = name .. ": TẮT"
        end
    end

    btn.MouseButton1Click:Connect(function()
        Flags[flagName] = not Flags[flagName]
        updateState()
    end)
    updateState()
    return btn
end

-- TAB 1: BỔ TRỢ
createCustomButton(page1, "1. Anti-AFK", "AntiAFK", 10, Color3.fromRGB(230, 160, 0))

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.86, 0, 0, 32); speedBtn.Position = UDim2.new(0.07, 0, 0, 50); speedBtn.Font = Enum.Font.SourceSansBold; speedBtn.TextSize = 13; speedBtn.Parent = page1
local speedC = Instance.new("UICorner"); speedC.CornerRadius = UDim.new(0, 8); speedC.Parent = speedBtn
local function updateSpeedUI()
    if Flags.SpeedHack then
        speedBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        speedBtn.Text = string.format("2. Speed Hack: BẬT (x%.1f)", SpeedMultiplier)
    else
        speedBtn.BackgroundColor3 = Color3.fromRGB(45, 48, 56)
        speedBtn.TextColor3 = Color3.fromRGB(170, 170, 170)
        speedBtn.Text = "2. Speed Hack: TẮT"
    end
end
speedBtn.MouseButton1Click:Connect(function()
    if not Flags.SpeedHack then
        Flags.SpeedHack = true; SpeedMultiplier = 1.3
    elseif SpeedMultiplier == 1.3 then SpeedMultiplier = 1.5
    else
        Flags.SpeedHack = false
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end
    updateSpeedUI()
end)
updateSpeedUI()

createCustomButton(page1, "3. Nhìn Bóng Tối Thông Minh", "SmartFullbright", 90, Color3.fromRGB(220, 200, 0))

-- TAB 2: ESP
createCustomButton(page2, "ESP Cửa", "ESPDoor", 10, Color3.fromRGB(0, 180, 216))
createCustomButton(page2, "ESP Vật Phẩm & Rương", "ESPItems", 50, Color3.fromRGB(0, 119, 182))
createCustomButton(page2, "ESP Quái Vật", "ESPMonster", 90, Color3.fromRGB(217, 4, 41))
createCustomButton(page2, "ESP Người Chơi", "ESPPlayer", 130, Color3.fromRGB(114, 9, 183))

-- TAB 3: TỰ ĐỘNG (GỘP MỞ CỬA & LOOT)
local jumpButtonUI = Instance.new("TextButton")
jumpButtonUI.Size = UDim2.new(0, 60, 0, 60); jumpButtonUI.Position = UDim2.new(0.05, 0, 0.05, 0); jumpButtonUI.BackgroundColor3 = Color3.fromRGB(138, 43, 226); jumpButtonUI.TextColor3 = Color3.fromRGB(255, 255, 255); jumpButtonUI.Text = "NHẢY"; jumpButtonUI.Font = Enum.Font.GothamBold; jumpButtonUI.TextSize = 14; jumpButtonUI.Visible = false; jumpButtonUI.Parent = screenGui
makeDraggable(jumpButtonUI)

local jumpCorner = Instance.new("UICorner"); jumpCorner.CornerRadius = UDim.new(1, 0); jumpCorner.Parent = jumpButtonUI
local jumpStroke = Instance.new("UIStroke"); jumpStroke.Color = Color3.fromRGB(255, 255, 255); jumpStroke.Thickness = 2; jumpStroke.Parent = jumpButtonUI

jumpButtonUI.MouseButton1Click:Connect(function()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50
            humanoid.JumpHeight = 7.2
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local doorsJumpBtn = createCustomButton(page3, "Nút Nhảy DOORS", "DoorsJump", 10, Color3.fromRGB(138, 43, 226))
doorsJumpBtn.MouseButton1Click:Connect(function()
    jumpButtonUI.Visible = Flags.DoorsJump
end)

-- NÚT TÍNH NĂNG GỘP CỦA TỰ ĐỘNG
createCustomButton(page3, "Auto Mở Cửa Key & Auto Loot (0.3s)", "AutoLootAndDoor", 50, Color3.fromRGB(16, 185, 129))
createCustomButton(page3, "Tự Chơi Minigame Tủ", "AutoMinigame", 90, Color3.fromRGB(245, 158, 11))
createCustomButton(page3, "Thảm Bay (Fly)", "FlyCarpet", 130, Color3.fromRGB(99, 102, 241))
createCustomButton(page3, "Cảnh Báo Thông Minh", "MonsterNotify", 170, Color3.fromRGB(239, 68, 68))

-- TAB 4: INFO
local infoContainer = Instance.new("Frame")
infoContainer.Size = UDim2.new(0.88, 0, 0.88, 0); infoContainer.Position = UDim2.new(0.06, 0, 0.04, 0); infoContainer.BackgroundColor3 = Color3.fromRGB(28, 32, 42); infoContainer.Parent = page4

local infoCorner = Instance.new("UICorner"); infoCorner.CornerRadius = UDim.new(0, 10); infoCorner.Parent = infoContainer
local infoStroke = Instance.new("UIStroke"); infoStroke.Color = Color3.fromRGB(0, 204, 255); infoStroke.Thickness = 1.5; infoStroke.Parent = infoContainer

local adminTitle = Instance.new("TextLabel")
adminTitle.Size = UDim2.new(1, 0, 0, 30); adminTitle.Position = UDim2.new(0, 0, 0.05, 0); adminTitle.BackgroundTransparency = 1; adminTitle.Text = "👑 THÔNG TIN ADMIN 👑"; adminTitle.Font = Enum.Font.GothamBold; adminTitle.TextColor3 = Color3.fromRGB(255, 215, 0); adminTitle.TextSize = 14; adminTitle.Parent = infoContainer

local authorLabel = Instance.new("TextLabel")
authorLabel.Size = UDim2.new(0.9, 0, 0, 40); authorLabel.Position = UDim2.new(0.05, 0, 0.22, 0); authorLabel.BackgroundColor3 = Color3.fromRGB(36, 40, 52); authorLabel.Text = "  Tác Giả: By Mờ Tê"; authorLabel.Font = Enum.Font.SourceSansBold; authorLabel.TextColor3 = Color3.fromRGB(0, 255, 204); authorLabel.TextSize = 14; authorLabel.TextXAlignment = Enum.TextXAlignment.Left; authorLabel.Parent = infoContainer
local aC = Instance.new("UICorner"); aC.CornerRadius = UDim.new(0, 6); aC.Parent = authorLabel

local fbLabel = Instance.new("TextLabel")
fbLabel.Size = UDim2.new(0.9, 0, 0, 40); fbLabel.Position = UDim2.new(0.05, 0, 0.44, 0); fbLabel.BackgroundColor3 = Color3.fromRGB(36, 40, 52); fbLabel.Text = "  Facebook: Nguyễn minh tân"; fbLabel.Font = Enum.Font.SourceSansBold; fbLabel.TextColor3 = Color3.fromRGB(24, 119, 242); fbLabel.TextSize = 13; fbLabel.TextXAlignment = Enum.TextXAlignment.Left; fbLabel.Parent = infoContainer
local fbC = Instance.new("UICorner"); fbC.CornerRadius = UDim.new(0, 6); fbC.Parent = fbLabel

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(0.9, 0, 0, 35); versionLabel.Position = UDim2.new(0.05, 0, 0.66, 0); versionLabel.BackgroundColor3 = Color3.fromRGB(36, 40, 52); versionLabel.Text = "  Phiên Bản: Mote Hub Beta 1.0"; versionLabel.Font = Enum.Font.SourceSansBold; versionLabel.TextColor3 = Color3.fromRGB(255, 255, 255); versionLabel.TextSize = 12; versionLabel.TextXAlignment = Enum.TextXAlignment.Left; versionLabel.Parent = infoContainer
local vC = Instance.new("UICorner"); vC.CornerRadius = UDim.new(0, 6); vC.Parent = versionLabel

local function switchTab(activeBtn, activePage)
    page1.Visible = false; page2.Visible = false; page3.Visible = false; page4.Visible = false
    tab1Btn.BackgroundColor3 = Color3.fromRGB(40, 44, 52); tab1Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    tab2Btn.BackgroundColor3 = Color3.fromRGB(40, 44, 52); tab2Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    tab3Btn.BackgroundColor3 = Color3.fromRGB(40, 44, 52); tab3Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    tab4Btn.BackgroundColor3 = Color3.fromRGB(40, 44, 52); tab4Btn.TextColor3 = Color3.fromRGB(180, 180, 180)

    activePage.Visible = true
    if activeBtn == tab1Btn then
        activeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    elseif activeBtn == tab2Btn then
        activeBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
    elseif activeBtn == tab3Btn then
        activeBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    else
        activeBtn.BackgroundColor3 = Color3.fromRGB(0, 204, 255)
    end
    activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

tab1Btn.MouseButton1Click:Connect(function() switchTab(tab1Btn, page1) end)
tab2Btn.MouseButton1Click:Connect(function() switchTab(tab2Btn, page2) end)
tab3Btn.MouseButton1Click:Connect(function() switchTab(tab3Btn, page3) end)
tab4Btn.MouseButton1Click:Connect(function() switchTab(tab4Btn, page4) end)

circleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "MOTE HUB BETA 1.0",
        Text = "Đã gộp Mở cửa/Loot đồ + Smart Scanning (0.3s delay) thành công!",
        Duration = 5
    })
end)
