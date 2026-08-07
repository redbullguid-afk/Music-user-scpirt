-- ==================================================
-- MOTEHUB V6.7 - BETA BUILD
-- Gộp: ESP Tên + Khoảng Cách (No Highlight), Notice Thông Minh, Semi-Auto Loot
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
    InfiniteJump = false,
    SemiAutoLoot = true
}

local SpeedMultiplier = 1.3
local CurrentDoorNumber = 0
local isLooting = false

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
-- 1. TỐI ƯU HỆ THỐNG & SPEED HACK
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

-- Speed Hack
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

-- Fullbright
local isFullbrightActive = false
task.spawn(function()
    while task.wait(0.5) do
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

-- Nhảy Vô Hạn
UserInputService.JumpRequest:Connect(function()
    if Flags.InfiniteJump and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

--------------------------------------------------
-- 2. ESP CỬA (CHỈ CHỮ & KHOẢNG CÁCH)
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

    local isDupe = false
    local expectedDoor = CurrentDoorNumber + 1

    if doorModel.Name == "DoorFake" or doorModel:FindFirstChild("Hidden") or doorModel:FindFirstChild("Dupe") then
        isDupe = true
    elseif CurrentDoorNumber > 0 and doorNum ~= expectedDoor then
        isDupe = true
    end

    if isDupe then return end

    local billboard = doorPart:FindFirstChild("Mote_DoorTag") or Instance.new("BillboardGui")
    billboard.Name = "Mote_DoorTag"
    billboard.Adornee = doorPart
    billboard.Size = UDim2.new(0, 160, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true

    local label = billboard:FindFirstChild("TextLabel") or Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextSize = 13
    label.Font = Enum.Font.SourceSansBold
    label.TextColor3 = Color3.fromRGB(0, 255, 128)
    label.Parent = billboard
    billboard.Parent = doorPart

    task.spawn(function()
        while doorModel and doorModel.Parent do
            if Flags.ESPDoor and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                billboard.Enabled = true
                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - doorPart.Position).Magnitude)
                label.Text = string.format("Cửa %d\n[%d studs]", doorNum, dist)
            else
                billboard.Enabled = false
            end
            task.wait(0.2)
        end
    end)
end

-- Đếm cửa
task.spawn(function()
    while task.wait(0.4) do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pPos = LocalPlayer.Character.HumanoidRootPart.Position
            local currentRooms = Workspace:FindFirstChild("CurrentRooms")
            if currentRooms then
                for _, room in ipairs(currentRooms:GetChildren()) do
                    if room:IsA("Model") and tonumber(room.Name) then
                        local roomNum = tonumber(room.Name)
                        if roomNum > CurrentDoorNumber then
                            local roomPrimary = room.PrimaryPart or room:FindFirstChildWhichIsA("BasePart")
                            if roomPrimary and (roomPrimary.Position - pPos).Magnitude < 70 then
                                CurrentDoorNumber = roomNum
                                for _, d in ipairs(room:GetDescendants()) do
                                    if d:IsA("Model") and (d.Name == "Door" or d.Name == "DoorFake") then
                                        setupDoorESP(d)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

--------------------------------------------------
-- 3. ESP VẬT PHẨM & SEMI-AUTO LOOT
--------------------------------------------------
local ValidItems = {
    ["KeyObtain"] = "Chìa khóa", ["Key"] = "Chìa khóa", ["MasterKey"] = "Chìa khóa vạn năng",
    ["Flashlight"] = "Đèn pin", ["Candle"] = "Nến", ["Crucifix"] = "Thánh giá",
    ["Lockpick"] = "Móc khóa", ["Bandage"] = "Băng gạc", ["Vitamins"] = "Vitamin",
    ["Battery"] = "Pin", ["Shears"] = "Kéo", ["HerbOfViridis"] = "Thảo dược",
    ["ShakableLight"] = "Đèn lắc", ["Bulklight"] = "Đèn bão",
    ["LeverForGate"] = "⚡ Công Tắc Cửa", ["Lever"] = "⚡ Công Tắc Cửa", ["GateButton"] = "⚡ Nút Bấm Cửa",
    ["LiveHintBook"] = "📘 Sách (50)", ["Book"] = "📘 Sách (50)", ["HintBook"] = "📘 Sách (50)",
    ["FuseInPlainSight"] = "🔋 Cầu Chì (100)", ["Fuse"] = "🔋 Cầu Chì (100)",
    ["Coins"] = "Tiền Gold", ["Gold"] = "Tiền Gold"
}

local function applyItemESP(obj)
    if not (obj:IsA("Model") or obj:IsA("Tool") or obj:IsA("BasePart")) then return end
    local displayName = ValidItems[obj.Name]
    if not displayName then return end

    local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end

    local billboard = targetPart:FindFirstChild("Mote_ItemTag") or Instance.new("BillboardGui")
    billboard.Name = "Mote_ItemTag"
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 140, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 1.2, 0)
    billboard.AlwaysOnTop = true

    local label = billboard:FindFirstChild("TextLabel") or Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextSize = 12
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard
    billboard.Parent = targetPart

    task.spawn(function()
        while obj and obj.Parent do
            if Flags.ESPItems and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                billboard.Enabled = true
                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude)
                label.Text = string.format("%s\n[%d studs]", displayName, dist)
            else
                billboard.Enabled = false
            end
            task.wait(0.25)
        end
    end)
end

-- LOGIC SEMI-AUTO LOOT
local function interactPrompt(prompt)
    if not prompt or not prompt.Enabled or isLooting then return end
    isLooting = true
    pcall(function()
        fireproximityprompt(prompt)
    end)
    task.wait(0.15)
    isLooting = false
end

-- Lia tâm giữa màn hình tự nhặt
task.spawn(function()
    while task.wait(0.1) do
        if Flags.SemiAutoLoot and LocalPlayer.Character then
            local unitRay = Camera:ViewportPointToRay(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterAncestorsOfInstances = {LocalPlayer.Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude

            local rayResult = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 8, raycastParams)

            if rayResult and rayResult.Instance then
                local hitObj = rayResult.Instance
                local prompt = hitObj:FindFirstChildWhichIsA("ProximityPrompt", true) 
                              or (hitObj.Parent and hitObj.Parent:FindFirstChildWhichIsA("ProximityPrompt", true))

                if prompt and prompt.Enabled then
                    local parentName = prompt.Parent and prompt.Parent.Name or ""
                    if ValidItems[parentName] or ValidItems[hitObj.Name] then
                        interactPrompt(prompt)
                    end
                end
            end
        end
    end
end)

-- Bấm E mở tủ tự nhặt đồ
local function lootNearbyDrawerItems(drawerPart)
    task.wait(0.2)
    if not drawerPart then return end
    local pos = drawerPart.Position

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if ValidItems[obj.Name] then
            local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if targetPart and (targetPart.Position - pos).Magnitude <= 4 then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and prompt.Enabled then
                    interactPrompt(prompt)
                end
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not Flags.SemiAutoLoot then return end

    if input.KeyCode == Enum.KeyCode.E or input.UserInputType == Enum.UserInputType.Touch then
        local unitRay = Camera:ViewportPointToRay(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local rayResult = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 8)

        if rayResult and rayResult.Instance then
            local hitObj = rayResult.Instance
            local name = hitObj.Name:lower()
            local parentName = hitObj.Parent and hitObj.Parent.Name:lower() or ""

            if name:find("drawer") or name:find("container") or parentName:find("drawer") or parentName:find("desk") then
                task.spawn(function()
                    lootNearbyDrawerItems(hitObj)
                end)
            end
        end
    end
end)

--------------------------------------------------
-- 4. ESP QUÁI VẬT & NOTICE THÔNG MINH
--------------------------------------------------
local MonsterInfo = {
    ["RushMoving"] = { Name = "Rush", Advice = "Trốn vào tủ hoặc hầm ngay!" },
    ["AmbushMoving"] = { Name = "Ambush", Advice = "Trốn tủ và chuẩn bị ra/vào lại liên tục!" },
    ["FigureRig"] = { Name = "Figure", Advice = "Hãy ngồi xuống và đi rón rén!" },
    ["SeekMoving"] = { Name = "Seek", Advice = "Chuẩn bị chạy vượt rào cản!" },
    ["SeekRig"] = { Name = "Seek", Advice = "Chuẩn bị chạy vượt rào cản!" },
    ["Screech"] = { Name = "Screech", Advice = "Quay camera nhìn thẳng vào nó!" },
    ["Eyes"] = { Name = "Eyes", Advice = "Đừng nhìn thẳng vào nó!" },
    ["Halt"] = { Name = "Halt", Advice = "Quay đầu đi ngược lại khi màn hình nhấp nháy!" },
    ["Snare"] = { Name = "Snare", Advice = "Cẩn thận dưới chân, tránh bẫy gai!" },
    ["A60"] = { Name = "A-60", Advice = "Trốn vào tủ ngay lập tức!" },
    ["A120"] = { Name = "A-120", Advice = "Trốn tủ cẩn thận, nó di chuyển chậm!" },
    ["A90"] = { Name = "A-90", Advice = "DỪNG LẠI NGAY! Không di chuyển hay xoay camera!" },
    ["Giggle"] = { Name = "Giggle", Advice = "Né trần nhà, chớ đứng dưới nó!" },
    ["Grumble"] = { Name = "Grumble", Advice = "Giữ khoảng cách xa!" },
    ["Dread"] = { Name = "Dread", Advice = "Mở cửa phòng mới thật nhanh!" }
}

local notifiedMonsters = {}

local function applyMonsterESP(obj)
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return end
    
    local lowerName = obj.Name:lower()
    if lowerName:find("painting") or lowerName:find("hand") or lowerName:find("decal") or lowerName:find("texture") or lowerName:find("trigger") then
        return
    end

    local monsterData = nil
    for name, data in pairs(MonsterInfo) do
        if obj.Name == name or (name == "SeekMoving" and obj.Name:find("Seek")) then
            if data.Name == "Seek" then
                if obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Humanoid") then
                    monsterData = data
                    break
                end
            else
                monsterData = data
                break
            end
        end
    end
    
    if not monsterData then return end
    if obj.Parent and MonsterInfo[obj.Parent.Name] then return end

    -- Notice Thông Minh
    if Flags.MonsterNotify and not notifiedMonsters[obj] then
        notifiedMonsters[obj] = true
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "⚠️ " .. monsterData.Name .. " XUẤT HIỆN!",
                Text = monsterData.Advice,
                Duration = 5
            })
        end)
    end

    local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end

    local billboard = targetPart:FindFirstChild("Mote_MonsterTag") or Instance.new("BillboardGui")
    billboard.Name = "Mote_MonsterTag"
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 160, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    local label = billboard:FindFirstChild("TextLabel") or Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 50, 50)
    label.TextStrokeTransparency = 0
    label.TextSize = 13
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard
    billboard.Parent = targetPart

    task.spawn(function()
        while obj and obj.Parent do
            if Flags.ESPMonster and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                billboard.Enabled = true
                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude)
                label.Text = string.format("👹 %s\n[%d studs]", monsterData.Name, dist)
            else
                billboard.Enabled = false
            end
            task.wait(0.2)
        end
    end)
end

--------------------------------------------------
-- 5. ESP NGƯỜI CHƠI (CHỈ CHỮ & KHOẢNG CÁCH)
--------------------------------------------------
local function applyPlayerESP(player)
    if player == LocalPlayer then return end
    local function setupCharacter(character)
        if not character then return end
        local head = character:WaitForChild("Head", 5)
        if not head then return end

        local billboard = head:FindFirstChild("Mote_PlayerTag") or Instance.new("BillboardGui")
        billboard.Name = "Mote_PlayerTag"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 160, 0, 35)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true

        local textLabel = billboard:FindFirstChild("TextLabel") or Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextSize = 13
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.Parent = billboard
        billboard.Parent = head

        task.spawn(function()
            while character and character.Parent do
                if Flags.ESPPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    billboard.Enabled = true
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude)
                    textLabel.Text = string.format("👤 %s\n[%d studs]", player.DisplayName, dist)
                else
                    billboard.Enabled = false
                end
                task.wait(0.2)
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
-- 6. TỐI ƯU HÓA BỘ QUÉT
--------------------------------------------------
local function processObject(obj)
    pcall(function()
        applyItemESP(obj)
        applyMonsterESP(obj)
        setupDoorESP(obj)
    end)
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    processObject(obj)
end

Workspace.DescendantAdded:Connect(processObject)

--------------------------------------------------
-- 7. GIAO DIỆN GUI MOTEHUB V6.7
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
mainFrame.Size = UDim2.new(0, 260, 0, 380)
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
titleLabel.Text = "MOTE HUB V6.7 (BETA)"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleLabel

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0.92, 0, 0, 30)
tabContainer.Position = UDim2.new(0.04, 0, 0.11, 0)
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
testTabBtn.Text = "Khác"
testTabBtn.Font = Enum.Font.SourceSansBold
testTabBtn.TextSize = 12
testTabBtn.Parent = tabContainer

local mainTabPage = Instance.new("Frame")
mainTabPage.Size = UDim2.new(1, 0, 0.8, 0)
mainTabPage.Position = UDim2.new(0, 0, 0.2, 0)
mainTabPage.BackgroundTransparency = 1
mainTabPage.Visible = true
mainTabPage.Parent = mainFrame

local espTabPage = Instance.new("Frame")
espTabPage.Size = UDim2.new(1, 0, 0.8, 0)
espTabPage.Position = UDim2.new(0, 0, 0.2, 0)
espTabPage.BackgroundTransparency = 1
espTabPage.Visible = false
espTabPage.Parent = mainFrame

local testTabPage = Instance.new("Frame")
testTabPage.Size = UDim2.new(1, 0, 0.8, 0)
testTabPage.Position = UDim2.new(0, 0, 0.2, 0)
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
createToggleButton(mainTabPage, "Lia Tâm Nhặt Đồ", "SemiAutoLoot", 48)
createToggleButton(mainTabPage, "Thảm Bay (Fly)", "FlyCarpet", 86)

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.85, 0, 0, 30)
speedBtn.Position = UDim2.new(0.075, 0, 0, 124)
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

createToggleButton(espTabPage, "ESP Cửa Thật", "ESPDoor", 5)
createToggleButton(espTabPage, "ESP Vật Phẩm", "ESPItems", 40)
createToggleButton(espTabPage, "ESP Quái Vật", "ESPMonster", 75)
createToggleButton(espTabPage, "ESP Người Chơi", "ESPPlayer", 110)
createToggleButton(espTabPage, "Cảnh Báo Thông Minh", "MonsterNotify", 145)

createToggleButton(testTabPage, "Nhìn Bóng Tối", "Fullbright", 10)
createToggleButton(testTabPage, "Nhảy Vô Hạn", "InfiniteJump", 48)

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
        Title = "MOTE HUB V6.7 BETA",
        Text = "Đã gộp hoàn chỉnh ESP gọn và Notice thông minh!",
        Duration = 4
    })
end)
