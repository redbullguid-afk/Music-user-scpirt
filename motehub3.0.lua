-- ==================================================
-- MOTEHUB V6.3 - BẢN TỔNG HỢP (GỘP 1 FILE FULL)
-- Fix: ESP Cửa, Speed Hack (Seek/Vitamin), Fullbright & Tab Thử Nghiệm
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

-- Bảng trạng thái
local Flags = {
    AntiAFK = true,
    FlyCarpet = false,
    Fullbright = false,
    ESPPlayer = false,
    ESPMonster = true,
    ESPItems = true,
    ESPDoor = true,
    MonsterNotify = true,
    SpeedHack = false,
    InfiniteJump = false
}

local SpeedMultiplier = 1.3
local CurrentDoorNumber = 0

-- Lưu cấu hình Lighting gốc
local OriginalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

--------------------------------------------------
-- 1. BỔ TRỢ & SỬA LỖI TỐC ĐỘ / LIGHTING
--------------------------------------------------

-- Anti-AFK
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

-- Thảm Bay
local carpetPart = Instance.new("Part")
carpetPart.Name = "MoteHub_MagicCarpet"
carpetPart.Size = Vector3.new(6, 0.4, 6)
carpetPart.Material = Enum.Material.Neon
carpetPart.Color = Color3.fromRGB(0, 255, 128)
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

-- Speed Hack (Tương thích với Seek & Vitamin)
local lastBaseSpeed = 16
RunService.Stepped:Connect(function()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if Flags.SpeedHack then
                local currentSpeed = humanoid.WalkSpeed
                if currentSpeed > 0 and math.abs(currentSpeed - (lastBaseSpeed * SpeedMultiplier)) > 0.5 then
                    lastBaseSpeed = currentSpeed
                end
                humanoid.WalkSpeed = lastBaseSpeed * SpeedMultiplier
            end
        end
    end
end)

-- Sửa lỗi Fullbright (Nhìn bóng tối khôi phục gốc khi tắt)
local isFullbrightActive = false
task.spawn(function()
    while task.wait(0.2) do
        if Flags.Fullbright then
            isFullbrightActive = true
            pcall(function()
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 1000000
                Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            end)
        elseif isFullbrightActive then
            isFullbrightActive = false
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

-- Bật Nhảy Vô Hạn (Tab Thử Nghiệm)
UserInputService.JumpRequest:Connect(function()
    if Flags.InfiniteJump and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

--------------------------------------------------
-- 2. ESP CỬA & BỘ ĐẾM DUPE
--------------------------------------------------
local function setupDoorESP(doorModel)
    if not doorModel or not doorModel:IsA("Model") then return end
    if doorModel.Name ~= "Door" and doorModel.Name ~= "DoorFake" then return end

    local doorPart = doorModel:FindFirstChild("Door") or doorModel:FindFirstChildWhichIsA("BasePart")
    if not doorPart then return end

    local doorNum = nil
    local sign = doorModel:FindFirstChild("Sign") or doorModel:FindFirstChild("SignModel")
    if sign then
        local st = sign:FindFirstChildWhichIsA("TextLabel", true) or sign:FindFirstChildWhichIsA("SurfaceGui", true)
        if st and st:IsA("TextLabel") and tonumber(st.Text) then
            doorNum = tonumber(st.Text)
        end
    end

    if not doorNum and doorModel.Parent and tonumber(doorModel.Parent.Name) then
        doorNum = tonumber(doorModel.Parent.Name)
    end

    if not doorNum then return end

    if doorPart:FindFirstChild("Mote_DoorTag") then
        doorPart.Mote_DoorTag:Destroy()
    end

    local isDupe = false
    local expectedDoor = CurrentDoorNumber + 1

    if doorModel.Name == "DoorFake" or doorModel:FindFirstChild("Hidden") or doorModel:FindFirstChild("Dupe") then
        isDupe = true
    elseif CurrentDoorNumber > 0 and doorNum ~= expectedDoor then
        isDupe = true
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Mote_DoorTag"
    billboard.Adornee = doorPart
    billboard.Size = UDim2.new(0, 160, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Flags.ESPDoor

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold

    if isDupe then
        label.TextColor3 = Color3.fromRGB(255, 50, 50)
        label.Text = "⚠️ CỬA GIẢ (" .. doorNum .. ")"
    else
        label.TextColor3 = Color3.fromRGB(0, 255, 128)
        label.Text = "Cửa (" .. doorNum .. ")"
    end

    label.Parent = billboard
    billboard.Parent = doorPart
end

task.spawn(function()
    while task.wait(0.4) do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pPos = LocalPlayer.Character.HumanoidRootPart.Position
            local currentRooms = Workspace:FindFirstChild("CurrentRooms") or Workspace
            for _, room in ipairs(currentRooms:GetChildren()) do
                if room:IsA("Model") and tonumber(room.Name) then
                    local roomNum = tonumber(room.Name)
                    if roomNum > CurrentDoorNumber then
                        local roomPrimary = room.PrimaryPart or room:FindFirstChildWhichIsA("BasePart")
                        if roomPrimary and (roomPrimary.Position - pPos).Magnitude < 70 then
                            CurrentDoorNumber = roomNum
                        end
                    end
                end
            end
        end
    end
end)

--------------------------------------------------
-- 3. ESP VẬT PHẨM (SÂU TRONG TỦ & RƯƠNG)
--------------------------------------------------
local ValidItems = {
    ["KeyObtain"] = "Chìa khóa", ["Key"] = "Chìa khóa", ["MasterKey"] = "Chìa khóa vạn năng",
    ["Flashlight"] = "Đèn pin", ["Candle"] = "Nến", ["Crucifix"] = "Thánh giá",
    ["Lockpick"] = "Móc khóa", ["Bandage"] = "Băng gạc", ["Vitamins"] = "Vitamin",
    ["Battery"] = "Pin", ["Shears"] = "Kéo", ["HerbOfViridis"] = "Thảo dược",
    ["ShakableLight"] = "Đèn lắc", ["Bulklight"] = "Đèn bão",
    ["LeverForGate"] = "⚡ Công Tắc Cửa", ["Lever"] = "⚡ Công Tắc Cửa", ["GateButton"] = "⚡ Nút Bấm Cửa",
    ["LiveHintBook"] = "📘 Sách (50)", ["Book"] = "📘 Sách (50)", ["HintBook"] = "📘 Sách (50)",
    ["FuseInPlainSight"] = "🔋 Cầu Chì (100)", ["Fuse"] = "🔋 Cầu Chì (100)"
}

local function applyItemESP(obj)
    if not (obj:IsA("Model") or obj:IsA("Tool") or obj:IsA("BasePart")) then return end
    local displayName = ValidItems[obj.Name]
    if not displayName then return end

    local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end

    local highlight = obj:FindFirstChild("Mote_ItemESP") or Instance.new("Highlight")
    highlight.Name = "Mote_ItemESP"
    highlight.Adornee = obj
    highlight.FillColor = Color3.fromRGB(0, 200, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.3
    highlight.Enabled = Flags.ESPItems
    highlight.Parent = obj

    local billboard = targetPart:FindFirstChild("Mote_ItemTag") or Instance.new("BillboardGui")
    billboard.Name = "Mote_ItemTag"
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 130, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 1.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Flags.ESPItems

    local label = billboard:FindFirstChild("TextLabel") or Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextSize = 12
    label.Font = Enum.Font.SourceSansBold
    label.Text = displayName
    label.Parent = billboard
    billboard.Parent = targetPart
end

local function scanContainers(parentObj)
    for _, child in ipairs(parentObj:GetChildren()) do
        local cName = child.Name:lower()
        if cName:find("drawer") or cName:find("wardrobe") or cName:find("locker") or cName:find("chest") or cName:find("table") then
            for _, innerObj in ipairs(child:GetDescendants()) do
                applyItemESP(innerObj)
            end
        end
    end
end

--------------------------------------------------
-- 4. ESP QUÁI VẬT & NGƯỜI CHƠI
--------------------------------------------------
local ValidMonsters = {
    ["RushMoving"] = "Rush", ["AmbushMoving"] = "Ambush", ["FigureRig"] = "Figure",
    ["SeekMoving"] = "Seek", ["Seek"] = "Seek", ["Screech"] = "Screech",
    ["Eyes"] = "Eyes", ["Halt"] = "Halt", ["Snare"] = "Snare",
    ["A60"] = "A-60", ["A120"] = "A-120", ["A90"] = "A-90",
    ["Giggle"] = "Giggle", ["Grumble"] = "Grumble", ["Dread"] = "Dread"
}
local notifiedMonsters = {}

local function applyMonsterESP(obj)
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return end
    local displayName = nil
    for name, label in pairs(ValidMonsters) do
        if obj.Name == name or obj.Name:find(name) then displayName = label; break end
    end
    if not displayName then return end
    if obj.Parent and ValidMonsters[obj.Parent.Name] then return end

    if Flags.MonsterNotify and not notifiedMonsters[obj] then
        notifiedMonsters[obj] = true
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title = "⚠️ QUÁI VẬT!", Text = displayName .. " xuất hiện!", Duration = 4})
        end)
    end

    local highlight = obj:FindFirstChild("Mote_MonsterESP") or Instance.new("Highlight")
    highlight.Name = "Mote_MonsterESP"
    highlight.Adornee = obj
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.3
    highlight.Enabled = Flags.ESPMonster
    highlight.Parent = obj
end

local function applyPlayerESP(player)
    if player == LocalPlayer then return end
    local function setupCharacter(character)
        if not character then return end
        local head = character:WaitForChild("Head", 5)
        if not head then return end

        local highlight = character:FindFirstChild("Mote_PlayerHighlight") or Instance.new("Highlight")
        highlight.Name = "Mote_PlayerHighlight"
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(0, 255, 128)
        highlight.FillTransparency = 0.6
        highlight.Parent = character

        local billboard = head:FindFirstChild("Mote_PlayerTag") or Instance.new("BillboardGui")
        billboard.Name = "Mote_PlayerTag"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true

        local textLabel = billboard:FindFirstChild("TextLabel") or Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextSize = 13
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.Parent = billboard
        billboard.Parent = head

        RunService.RenderStepped:Connect(function()
            if character and character.Parent and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                highlight.Enabled = Flags.ESPPlayer
                billboard.Enabled = Flags.ESPPlayer
                if Flags.ESPPlayer then
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude)
                    textLabel.Text = string.format("%s\n[%d studs]", player.DisplayName, dist)
                end
            end
        end)
    end
    if player.Character then setupCharacter(player.Character) end
    player.CharacterAdded:Connect(setupCharacter)
end

task.spawn(function()
    for _, p in ipairs(Players:GetPlayers()) do applyPlayerESP(p) end
    Players.PlayerAdded:Connect(applyPlayerESP)
end)

--------------------------------------------------
-- 5. QUÉT TỰ ĐỘNG KHÔNG GIAN GAME
--------------------------------------------------
task.spawn(function()
    local function processObject(obj)
        pcall(function()
            applyItemESP(obj)
            applyMonsterESP(obj)
            setupDoorESP(obj)
        end)
    end

    Workspace.DescendantAdded:Connect(processObject)

    while task.wait(0.6) do
        for _, obj in ipairs(Workspace:GetChildren()) do scanContainers(obj) end
        for _, obj in ipairs(Workspace:GetDescendants()) do processObject(obj) end
    end
end)

--------------------------------------------------
-- 6. GIAO DIỆN GUI MOTEHUB
--------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoteHub_GUI"
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
circleBtn.Size = UDim2.new(0, 50, 0, 50)
circleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
circleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
circleBtn.TextColor3 = Color3.fromRGB(0, 255, 128)
circleBtn.Text = "mote"
circleBtn.Font = Enum.Font.GothamBold
circleBtn.TextSize = 13
circleBtn.Parent = screenGui
makeDraggable(circleBtn)

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = circleBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(0, 255, 128)
btnStroke.Thickness = 2
btnStroke.Parent = circleBtn

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 350)
mainFrame.Position = UDim2.new(0.35, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui
makeDraggable(mainFrame)

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
titleLabel.Text = "MOTE HUB V6.3"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleLabel

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0.92, 0, 0, 30)
tabContainer.Position = UDim2.new(0.04, 0, 0.12, 0)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local mainTabBtn = Instance.new("TextButton")
mainTabBtn.Size = UDim2.new(0.31, 0, 1, 0)
mainTabBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 85)
mainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mainTabBtn.Text = "Bổ Trợ"
mainTabBtn.Font = Enum.Font.SourceSansBold
mainTabBtn.TextSize = 12
mainTabBtn.Parent = tabContainer

local espTabBtn = Instance.new("TextButton")
espTabBtn.Size = UDim2.new(0.31, 0, 1, 0)
espTabBtn.Position = UDim2.new(0.34, 0, 0, 0)
espTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
espTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
espTabBtn.Text = "ESP"
espTabBtn.Font = Enum.Font.SourceSansBold
espTabBtn.TextSize = 12
espTabBtn.Parent = tabContainer

local testTabBtn = Instance.new("TextButton")
testTabBtn.Size = UDim2.new(0.32, 0, 1, 0)
testTabBtn.Position = UDim2.new(0.68, 0, 0, 0)
testTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
testTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
testTabBtn.Text = "Thử Nghiệm ;)"
testTabBtn.Font = Enum.Font.SourceSansBold
testTabBtn.TextSize = 11
testTabBtn.Parent = tabContainer

local mainTabPage = Instance.new("Frame")
mainTabPage.Size = UDim2.new(1, 0, 0.78, 0)
mainTabPage.Position = UDim2.new(0, 0, 0.22, 0)
mainTabPage.BackgroundTransparency = 1
mainTabPage.Visible = true
mainTabPage.Parent = mainFrame

local espTabPage = Instance.new("Frame")
espTabPage.Size = UDim2.new(1, 0, 0.78, 0)
espTabPage.Position = UDim2.new(0, 0, 0.22, 0)
espTabPage.BackgroundTransparency = 1
espTabPage.Visible = false
espTabPage.Parent = mainFrame

local testTabPage = Instance.new("Frame")
testTabPage.Size = UDim2.new(1, 0, 0.78, 0)
testTabPage.Position = UDim2.new(0, 0, 0.22, 0)
testTabPage.BackgroundTransparency = 1
testTabPage.Visible = false
testTabPage.Parent = mainFrame

local function createToggleButton(parent, name, flagName, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 30)
    btn.Position = UDim2.new(0.075, 0, 0, posY)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = parent

    local btnC = Instance.new("UICorner")
    btnC.CornerRadius = UDim.new(0, 6)
    btnC.Parent = btn

    local function updateState()
        if Flags[flagName] then
            btn.BackgroundColor3 = Color3.fromRGB(0, 170, 85)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = name .. ": BẬT"
        else
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            btn.Text = name .. ": TẮT"
        end
    end

    btn.MouseButton1Click:Connect(function()
        Flags[flagName] = not Flags[flagName]
        updateState()
    end)
    updateState()
end

createToggleButton(mainTabPage, "Anti-AFK", "AntiAFK", 10)
createToggleButton(mainTabPage, "Thảm Bay (Fly)", "FlyCarpet", 48)

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.85, 0, 0, 30)
speedBtn.Position = UDim2.new(0.075, 0, 0, 86)
speedBtn.Font = Enum.Font.SourceSansBold
speedBtn.TextSize = 13
speedBtn.Parent = mainTabPage

local speedC = Instance.new("UICorner")
speedC.CornerRadius = UDim.new(0, 6)
speedC.Parent = speedBtn

local function updateSpeedUI()
    if Flags.SpeedHack then
        speedBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 85)
        speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        speedBtn.Text = string.format("Speed Hack: BẬT (x%.1f)", SpeedMultiplier)
    else
        speedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        speedBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        speedBtn.Text = "Speed Hack: TẮT"
    end
end

speedBtn.MouseButton1Click:Connect(function()
    if not Flags.SpeedHack then
        Flags.SpeedHack = true
        SpeedMultiplier = 1.3
    elseif SpeedMultiplier == 1.3 then
        SpeedMultiplier = 1.5
    else
        Flags.SpeedHack = false
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end
    updateSpeedUI()
end)
updateSpeedUI()

createToggleButton(espTabPage, "ESP Cửa & Số Cửa", "ESPDoor", 5)
createToggleButton(espTabPage, "ESP Vật Phẩm / Tủ", "ESPItems", 40)
createToggleButton(espTabPage, "ESP Quái Vật", "ESPMonster", 75)
createToggleButton(espTabPage, "ESP Người Chơi", "ESPPlayer", 110)
createToggleButton(espTabPage, "Cảnh Báo Quái", "MonsterNotify", 145)
createToggleButton(espTabPage, "Nhìn Bóng Tối", "Fullbright", 180)

createToggleButton(testTabPage, "Bật Nhảy Vô Hạn ;)", "InfiniteJump", 10)

local function switchTab(activeBtn, activePage)
    mainTabPage.Visible = false
    espTabPage.Visible = false
    testTabPage.Visible = false

    mainTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    espTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    espTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    testTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    testTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)

    activePage.Visible = true
    activeBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 85)
    activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

mainTabBtn.MouseButton1Click:Connect(function() switchTab(mainTabBtn, mainTabPage) end)
espTabBtn.MouseButton1Click:Connect(function() switchTab(espTabBtn, espTabPage) end)
testTabBtn.MouseButton1Click:Connect(function() switchTab(testTabBtn, testTabPage) end)

circleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "MOTE HUB V6.3",
        Text = "Đã khởi chạy thành công!",
        Duration = 4
    })
end)
