-- ==================================================
-- MOTE HUB BETA 3.01 - ULTIMATE OPTIMIZED & FIXED ESP ITEMS (FLOOR 1 & 2)
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

local HasDrawing = false
pcall(function()
    if Drawing and typeof(Drawing.new) == "function" then
        HasDrawing = true
    end
end)

--------------------------------------------------
-- CẤU HÌNH TRẠNG THÁI (FLAGS)
--------------------------------------------------
local Flags = {
    AntiAFK = true,
    MonsterNotify = true,
    SmartFullbright = false,
    FullbrightIntensity = 50,
    
    ESPDoor = false,
    ESPItems = false,
    ESPMonster = false,
    ESPLever = false,
    ESPChest = false,
    ESPPlayer = false,
    
    AutoDrawersLoot = false,
    AutoKeyDoor = false,
    
    NoClip = false,
    DoorsJump = false,
    SpeedHack = false,
    SpeedMultiplier = 1.0,
    AntiRubberband = true,
    FreecamSoul = false,
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
-- PALETTE MÀU THEME MENU & MÀU ESP
--------------------------------------------------
local Themes = {
    YellowBlack = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(255, 215, 0), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) },
    RedBlack    = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(239, 68, 68), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) },
    GreenBlack  = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(34, 197, 94), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) },
    PinkBlack   = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(236, 72, 153), Accent = Color3.fromRGB(236, 72, 153), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) }
}

local ESPColors = {
    Monster = Color3.fromRGB(255, 40, 40),
    Door    = Color3.fromRGB(0, 255, 128),
    Lever   = Color3.fromRGB(255, 255, 0),
    Chest   = Color3.fromRGB(200, 100, 255),
    Items   = Color3.fromRGB(0, 255, 255),
    Player  = Color3.fromRGB(255, 140, 0)
}

local Translations = {
    VIE = { Main = "Main", ESP = "ESP", Automation = "Tự Động", Experimental = "Thử Nghiệm", Settings = "Cài Đặt", AntiAFK = "1. Anti-AFK", MonsterNotify = "2. Cảnh Báo Quái Vật (Báo Đi)", Fullbright = "3. Nhìn Trong Bóng Tối (Fix Hant)", AutoDrawers = "1. Auto Mở Tủ (3 Tủ) & Loot Đồ", AutoDoorKey = "2. Auto Mở Cửa Bằng Key", NoClip = "1. NoClip (Xuyên Tường)", Jump = "2. Nút Nhảy DOORS (1 Lần)", Speed = "3. Speed Hack (Max 10x)", Freecam = "4. Khảm Giả (Linh Hồn Tách Xác)", FlyCarpet = "5. Bay Sáng Tạo", ThemeTitle = "1. Đổi Màu Menu", LangTitle = "2. Ngôn Ngữ", FontSizeTitle = "3. Kích Thước Chữ", Author = "Tác Giả: By Mờ Tê", Facebook = "Facebook: Nguyễn minh tân", Version = "Phiên Bản: Mote Hub Beta 3.01 (Optimized)" },
    ENG = { Main = "Main", ESP = "ESP", Automation = "Automation", Experimental = "Experimental", Settings = "Settings", AntiAFK = "1. Anti-AFK", MonsterNotify = "2. Monster Notify (Safe Leave)", Fullbright = "3. Fullbright (Hant Fix)", AutoDrawers = "1. Auto Open 3 Drawers & Auto Loot", AutoDoorKey = "2. Auto Key Door", NoClip = "1. NoClip", Jump = "2. DOORS Jump Button (Single)", Speed = "3. Speed Hack (Up to 10x)", Freecam = "4. Freecam Soul (Spectate Fly)", FlyCarpet = "5. Creative Fly", ThemeTitle = "1. Change Theme", LangTitle = "2. Language", FontSizeTitle = "3. Text Size", Author = "Author: By Mote", Facebook = "Facebook: Nguyen minh tan", Version = "Version: Mote Hub Beta 3.01 (Optimized)" }
}

--------------------------------------------------
-- GIAO DIỆN MÀN HÌNH CHÍNH
--------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoteHub_Beta301"
screenGui.ResetOnSpawn = false

pcall(function()
    if gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = CoreGui
    end
end)
if not screenGui.Parent then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

--------------------------------------------------
-- BẢNG DỮ LIỆU VẬT THỂ VÀ QUÁI VẬT
--------------------------------------------------
local ImportantItems = {
    ["keyobtain"] = "🔑 Chìa Khóa", ["key"] = "🔑 Chìa Khóa", ["masterkey"] = "🔑 Chìa Khóa Master",
    ["skeletonkey"] = "💀 Chìa Khóa Đầu Lâu", ["flashlight"] = "🔦 Đèn Pin", ["candle"] = "🕯️ Nến",
    ["crucifix"] = "✝️ Cây Thánh Giá", ["lockpick"] = "🗝️ Lockpick", ["bandage"] = "🩹 Băng Gạc",
    ["vitamins"] = "💊 Vitamin", ["battery"] = "🔋 Pin",
    ["glowstick"] = "💡 Que Phát Sáng", ["shears"] = "✂️ Kéo Cắt Cây", ["starlight"] = "🌟 Bình Starlight",
    ["bandagepack"] = "🩹 Hộp Băng Gạc", ["batterypack"] = "🔋 Hộp Pin", ["bulklight"] = "🔦 Đèn Pin Công Nghiệp",
    ["laserpointer"] = "🔴 Đèn Laser", ["alarmclock"] = "⏰ Đồng Hồ Báo Thức", ["compass"] = "🧭 La Bàn",
    ["strafe"] = "🌟 Bình Starlight", ["pickaxe"] = "⛏️ Cuốc"
}

local MonsterAdvice = {
    ["Rush"] = "Trốn vô tủ mau!", ["Ambush"] = "Trốn vô tủ mau!", ["Seek"] = "Chuẩn bị chạy trốn Seek!",
    ["Screech"] = "Xoay người nhìn nó ngay!", ["Eyes"] = "Không nhìn vào nó!", ["Halt"] = "Chú ý đổi hướng di chuyển!",
    ["Figure"] = "Đi cúi người (Crouch), giữ khoảng cách!", ["Hide"] = "Rời khỏi tủ ngay!", ["Jack"] = "Chờ 1 chút rồi mở lại tủ!",
    ["Timothy"] = "Nhện giật mình trong hộc bàn!", ["Dread"] = "Mở cửa tiến lên phía trước mau!", ["A-60"] = "Trốn vô tủ ngay!", ["A-120"] = "Trốn vô tủ ngay!",
    ["Giggle"] = "Nhìn lên trần nhà và ném Glowstick!", ["Grumble"] = "Chạy thật nhanh, tránh đường cụt!", ["Gloombat"] = "Tắt đèn, đừng soi đèn vào bầy dơi!"
}

local function getItemLabel(name)
    if not name or name == "" then return nil end
    local lowerName = name:lower()
    
    if ImportantItems[lowerName] then return ImportantItems[lowerName] end
    
    -- Tối ưu nhận diện cho Floor 2 (Hỗ trợ cấu trúc Drops và PickupItems)
    for key, label in pairs(ImportantItems) do
        if lowerName == key or lowerName == (key .. "item") or lowerName == ("item_" .. key)
        or lowerName == (key .. "drop") or lowerName == ("drop" .. key) 
        or lowerName == ("pickup" .. key) or lowerName == (key .. "pickup") then
            return label
        end
    end
    return nil
end

local function isContainerOrLocker(obj)
    local current = obj
    while current and current ~= Workspace do
        local n = current.Name:lower()
        if n:find("drawer") or n:find("chest") or n:find("lootbox") or n:find("locker") or n:find("cabinet") or n:find("wardrobe") or n:find("lock") or n:find("shelf") or n:find("table") or n:find("dupe") or n:find("bookshelf") or n:find("keyboard") then
            return true
        end
        current = current.Parent
    end
    return false
end

local function isRealRoomDoor(obj)
    if not obj or not obj:IsA("Model") then return false end
    if obj.Name ~= "Door" and obj.Name ~= "DoorModel" then return false end
    
    for _, child in ipairs(obj:GetChildren()) do
        local cName = child.Name:lower()
        if cName:find("dupe") or cName:find("fake") then
            return false
        end
    end
    
    if obj:FindFirstChild("Hidden") and not obj:FindFirstChild("Sign") and not obj:FindFirstChild("Lock") then
        if obj.Parent and tonumber(obj.Parent.Name) then
            return false 
        end
    end
    return true
end

--------------------------------------------------
-- HỆ THỐNG FONT SIZE REAL-TIME
--------------------------------------------------
local TextSizeRegister = {}
local function registerTextLabel(label)
    table.insert(TextSizeRegister, label)
    label.TextSize = Flags.TextSize
end
local function updateAllTextSizes()
    for _, lbl in ipairs(TextSizeRegister) do
        if lbl and lbl.Parent then lbl.TextSize = Flags.TextSize end
    end
end

--------------------------------------------------
-- HÀM TƯƠNG TÁC SAFE PROXIMITY PROMPT
--------------------------------------------------
local function safeInteract(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration)
            prompt:InputHoldEnd()
        end
    end)
    return true
end

--------------------------------------------------
-- LOGIC AUTO MỞ TỦ & AUTO LOOT
--------------------------------------------------
local activeDrawersCount = 0
local MAX_SIMULTANEOUS_DRAWERS = 3
local DRAWER_COOLDOWN = 0.6
local MAX_LOOT_DIST = 6

task.spawn(function()
    while task.wait(0.3) do
        if Flags.AutoDrawersLoot and LocalPlayer.Character then
            pcall(function()
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local playerPos = hrp.Position
                    for _, prompt in ipairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            local parent = prompt.Parent
                            if parent then
                                local targetPart = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart", true)
                                if targetPart then
                                    local dist = (targetPart.Position - playerPos).Magnitude
                                    if dist <= MAX_LOOT_DIST then
                                        local nameLower = parent.Name:lower()
                                        local pNameLower = (parent.Parent and parent.Parent.Name:lower()) or ""
                                        
                                        local isLootItem = getItemLabel(parent.Name) or getItemLabel(parent.Parent and parent.Parent.Name or "")
                                            or prompt.ActionText:lower():find("take", 1, true) or prompt.ActionText:lower():find("loot", 1, true)

                                        if isLootItem then
                                            safeInteract(prompt)
                                        elseif (nameLower:find("drawer", 1, true) or pNameLower:find("drawer", 1, true) or nameLower:find("knob", 1, true) or nameLower:find("closet", 1, true)) then
                                            if activeDrawersCount < MAX_SIMULTANEOUS_DRAWERS then
                                                activeDrawersCount = activeDrawersCount + 1
                                                task.spawn(function()
                                                    safeInteract(prompt)
                                                    task.wait(DRAWER_COOLDOWN)
                                                    activeDrawersCount = math.max(0, activeDrawersCount - 1)
                                                end)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------
-- LOGIC AUTO MỞ CỬA BẰNG KEY
--------------------------------------------------
task.spawn(function()
    while task.wait(0.2) do
        if Flags.AutoKeyDoor and LocalPlayer.Character then
            pcall(function()
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local char = LocalPlayer.Character
                
                local hasKey = char:FindFirstChild("Key") or char:FindFirstChild("KeyObtain") or LocalPlayer.Backpack:FindFirstChild("Key") or LocalPlayer.Backpack:FindFirstChild("KeyObtain")
                
                if hrp and hasKey then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if isRealRoomDoor(obj) then
                            local doorPart = obj:FindFirstChild("Door") or obj:FindFirstChildWhichIsA("BasePart")
                            if doorPart then
                                local dist = (doorPart.Position - hrp.Position).Magnitude
                                if dist <= 8 then
                                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    if prompt and prompt.Enabled then safeInteract(prompt) end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------
-- TÍNH NĂNG SPEED HACK, NOCLIP & FREECAM
--------------------------------------------------
RunService.Stepped:Connect(function()
    if Flags.NoClip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if hrp and humanoid and humanoid.Health > 0 then
            if Flags.SpeedHack then
                local naturalSpeed = 16
                if humanoid.WalkSpeed > 16 and humanoid.WalkSpeed < 50 then
                    naturalSpeed = humanoid.WalkSpeed
                end
                local targetSpeed = naturalSpeed * Flags.SpeedMultiplier
                humanoid.WalkSpeed = targetSpeed
                
                if humanoid.MoveDirection.Magnitude > 0 then
                    local extraMultiplier = Flags.SpeedMultiplier - 1
                    if extraMultiplier > 0 then
                        local moveDelta = humanoid.MoveDirection * (naturalSpeed * extraMultiplier) * dt
                        hrp.CFrame = hrp.CFrame + moveDelta
                        
                        if Flags.AntiRubberband then
                            local targetVel = humanoid.MoveDirection * targetSpeed
                            hrp.AssemblyLinearVelocity = Vector3.new(targetVel.X, hrp.AssemblyLinearVelocity.Y, targetVel.Z)
                        end
                    end
                end
            end
        end
    end
end)

local flyBodyVel, flyBodyGyro = nil, nil
local flyVerticalSpeed = 0

RunService.RenderStepped:Connect(function()
    if Flags.FlyCarpet and LocalPlayer.Character and not Flags.FreecamSoul then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if hrp and humanoid and humanoid.Health > 0 then
            if not flyBodyVel or not flyBodyVel.Parent then
                flyBodyVel = Instance.new("BodyVelocity"); flyBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9); flyBodyVel.Parent = hrp
            end
            if not flyBodyGyro or not flyBodyGyro.Parent then
                flyBodyGyro = Instance.new("BodyGyro"); flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9); flyBodyGyro.P = 9000; flyBodyGyro.Parent = hrp
            end
            
            humanoid.PlatformStand = true
            flyBodyGyro.CFrame = Camera.CFrame
            local moveDir = humanoid.MoveDirection
            local speed = 20 * Flags.SpeedMultiplier
            flyBodyVel.Velocity = (moveDir * speed) + Vector3.new(0, flyVerticalSpeed, 0)
        end
    else
        if LocalPlayer.Character and not Flags.FreecamSoul then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
        end
        if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        if not Flags.FreecamSoul then flyVerticalSpeed = 0 end
    end
end)

local freecamPart = nil
local isFreecamActive = false

local function setFreecamState(state)
    Flags.FreecamSoul = state
    if state then
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if humanoid then humanoid.PlatformStand = true end
        hrp.Anchored = true

        if not freecamPart or not freecamPart.Parent then
            freecamPart = Instance.new("Part")
            freecamPart.Name = "Mote_Freecam_Soul"
            freecamPart.Size = Vector3.new(0.5, 0.5, 0.5)
            freecamPart.Transparency = 1
            freecamPart.CanCollide = false
            freecamPart.Anchored = true
            freecamPart.Parent = Workspace
        end
        freecamPart.CFrame = Camera.CFrame

        Camera.CameraSubject = freecamPart
        Camera.CameraType = Enum.CameraType.Custom
        isFreecamActive = true
    else
        isFreecamActive = false
        if LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hrp then hrp.Anchored = false end
            if humanoid then 
                humanoid.PlatformStand = false 
                Camera.CameraSubject = humanoid
            end
        end
        Camera.CameraType = Enum.CameraType.Custom
        if freecamPart then freecamPart:Destroy(); freecamPart = nil end
    end
end

RunService.RenderStepped:Connect(function(dt)
    if isFreecamActive and freecamPart and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local moveDir = humanoid and humanoid.MoveDirection or Vector3.new(0, 0, 0)
        local speed = 25 * Flags.SpeedMultiplier
        
        local horizontalMove = Vector3.new(moveDir.X, 0, moveDir.Z)
        local verticalMove = Vector3.new(0, flyVerticalSpeed, 0) * dt
        
        freecamPart.Position = freecamPart.Position + (horizontalMove * speed * dt) + verticalMove
    end
end)

--------------------------------------------------
-- HỆ THỐNG ESP QUẢN LÝ TẬP TRUNG
--------------------------------------------------
local TrackedESPs = setmetatable({}, { __mode = "k" })

local function getSafePart(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    end
    return obj:FindFirstChildWhichIsA("BasePart", true)
end

local function getObjectPrompt(targetObj)
    if not targetObj then return nil end
    local prompt = targetObj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then return prompt end
    
    if targetObj.Parent and targetObj.Parent ~= Workspace then
        prompt = targetObj.Parent:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then return prompt end
        
        local ancestor = targetObj.Parent.Parent
        while ancestor and ancestor ~= Workspace do
            if ancestor:IsA("Model") then
                if ancestor.Name:lower():find("room") then break end
                prompt = ancestor:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then return prompt end
            end
            ancestor = ancestor.Parent
        end
    end
    return nil
end

local function isItemValidAndUncollected(targetObj)
    if not targetObj or not targetObj.Parent or not targetObj:IsDescendantOf(Workspace) then
        return false
    end

    local current = targetObj
    while current and current ~= Workspace do
        -- Sửa lỗi ESP biến mất ở Floor 2: Chỉ lấy Player thật sự để tránh quét nhầm các Model/Cơ chế có chứa Humanoid
        if Players:GetPlayerFromCharacter(current) then
            return false
        end
        current = current.Parent
    end

    local prompt = getObjectPrompt(targetObj)
    if prompt and prompt.Parent == nil then return false end
    return true
end

local function isTooCloseToExistingItemESP(pos)
    for obj, flags in pairs(TrackedESPs) do
        if flags["ESPItems"] then
            local part = getSafePart(obj)
            if part and (part.Position - pos).Magnitude <= 3 then
                return true
            end
        end
    end
    return false
end

local function createBillboard(targetObj, text, color, flagName)
    if not targetObj then return end
    if TrackedESPs[targetObj] and TrackedESPs[targetObj][flagName] then return end

    local targetPart = getSafePart(targetObj)
    if not targetPart then return end

    if not TrackedESPs[targetObj] then TrackedESPs[targetObj] = {} end
    TrackedESPs[targetObj][flagName] = true

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Mote_ESP_" .. flagName
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 160, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Parent = screenGui 

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextSize = 13
    label.Font = Enum.Font.SourceSansBold
    label.TextColor3 = color
    label.Parent = billboard

    local connections = {}
    local isCleaned = false

    local function cleanESP()
        if isCleaned then return end
        isCleaned = true
        for _, conn in ipairs(connections) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
        pcall(function() billboard:Destroy() end)
        if TrackedESPs[targetObj] then TrackedESPs[targetObj][flagName] = nil end
    end

    if flagName == "ESPItems" then
        local prompt = getObjectPrompt(targetObj)
        if prompt then
            table.insert(connections, prompt.Triggered:Connect(function()
                task.wait(0.05)
                cleanESP()
            end))
            table.insert(connections, prompt.TriggerEnded:Connect(function()
                task.wait(0.05)
                if not isItemValidAndUncollected(targetObj) then cleanESP() end
            end))
        end

        table.insert(connections, targetObj.AncestryChanged:Connect(function(_, parent)
            if not parent or not targetObj:IsDescendantOf(Workspace) then cleanESP() end
        end))
    end

    task.spawn(function()
        while targetObj and targetObj.Parent and targetObj:IsDescendantOf(Workspace) and not isCleaned do
            if flagName == "ESPItems" then
                if not isItemValidAndUncollected(targetObj) then
                    cleanESP()
                    break
                end
            end

            if Flags[flagName] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                billboard.Enabled = true
                local charPos = LocalPlayer.Character.HumanoidRootPart.Position
                local dist = math.floor((charPos - targetPart.Position).Magnitude)
                label.Text = string.format("%s\n[%d studs]", text, dist)
            else
                billboard.Enabled = false
            end
            task.wait(0.1)
        end
        cleanESP()
    end)
end

--------------------------------------------------
-- CẢNH BÁO QUÁI VẬT & QUÉT VẬT THỂ
--------------------------------------------------
local activeMonstersList = {}
local lastNoticeTimes = {}

local function triggerSmartMonsterNotice(monsterObj, rawMonsterName)
    if not Flags.MonsterNotify or activeMonstersList[monsterObj] then return end
    activeMonstersList[monsterObj] = rawMonsterName

    local now = tick()
    if not lastNoticeTimes[rawMonsterName] or (now - lastNoticeTimes[rawMonsterName] >= 5) then
        lastNoticeTimes[rawMonsterName] = now
        local actionText = MonsterAdvice[rawMonsterName] or "Cẩn thận quái vật này!"

        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "🚨 CẢNH BÁO: " .. rawMonsterName:upper(),
                Text = actionText,
                Duration = 4
            })
        end)
    end

    local conn
    conn = monsterObj.AncestryChanged:Connect(function(_, parent)
        if not parent or not monsterObj:IsDescendantOf(Workspace) then
            if conn then conn:Disconnect() end
            activeMonstersList[monsterObj] = nil
            if rawMonsterName == "Rush" or rawMonsterName == "Ambush" or rawMonsterName == "A-60" or rawMonsterName == "A-120" then
                pcall(function()
                    StarterGui:SetCore("SendNotification", { Title = "🟢 AN TOÀN!", Text = rawMonsterName .. " đã đi qua hẳn! Bạn có thể ra khỏi tủ.", Duration = 4 })
                end)
            end
        end
    end)
end

local function isPartOfOtherMonster(targetObj)
    local current = targetObj.Parent
    while current and current ~= Workspace do
        local n = current.Name:lower()
        if n:find("seek") or n:find("giggle") or n:find("gloombat") or n:find("grumble") or n:find("figure") or n:find("rush") or n:find("ambush") or n:find("halt") or n:find("screech") then
            return true
        end
        current = current.Parent
    end
    return false
end

local function processObject(obj)
    pcall(function()
        if not obj or not obj.Parent then return end
        local nameLower = obj.Name:lower()

        local monsterModel = nil
        local detectedMonsterName = nil

        if nameLower:find("giggle", 1, true) then detectedMonsterName = "Giggle"; monsterModel = obj:IsA("Model") and obj or obj.Parent
        elseif nameLower:find("rushmoving", 1, true) or nameLower == "rush" then detectedMonsterName = "Rush"; monsterModel = obj:IsA("Model") and obj or obj.Parent
        elseif nameLower:find("ambushmoving", 1, true) or nameLower == "ambush" then detectedMonsterName = "Ambush"; monsterModel = obj:IsA("Model") and obj or obj.Parent
        elseif nameLower:find("seekmoving", 1, true) or nameLower == "seekrig" or nameLower:find("seek", 1, true) then detectedMonsterName = "Seek"; monsterModel = obj:IsA("Model") and obj or obj.Parent
        elseif nameLower == "screech" then detectedMonsterName = "Screech"; monsterModel = obj:IsA("Model") and obj or obj.Parent
        elseif nameLower == "eyes" or nameLower == "eyesmoving" then
            if not isPartOfOtherMonster(obj) then
                detectedMonsterName = "Eyes"; monsterModel = obj:IsA("Model") and obj or obj.Parent
            end
        elseif nameLower == "halt" or nameLower == "haltmoving" then detectedMonsterName = "Halt"; monsterModel = obj:IsA("Model") and obj or obj.Parent
        elseif nameLower:find("figure", 1, true) then
            local potentialModel = obj:IsA("Model") and obj or obj.Parent
            if potentialModel and (potentialModel:FindFirstChild("HumanoidRootPart") or potentialModel:FindFirstChild("Root") or potentialModel:FindFirstChildOfClass("Humanoid")) then
                detectedMonsterName = "Figure"; monsterModel = potentialModel
            end
        elseif nameLower == "a60" or nameLower == "a-60" then detectedMonsterName = "A-60"; monsterModel = obj:IsA("Model") and obj or obj.Parent
        elseif nameLower == "a120" or nameLower == "a-120" then detectedMonsterName = "A-120"; monsterModel = obj:IsA("Model") and obj or obj.Parent
        elseif nameLower:find("grumble", 1, true) then detectedMonsterName = "Grumble"; monsterModel = obj:IsA("Model") and obj or obj.Parent
        elseif nameLower:find("gloombat", 1, true) then detectedMonsterName = "Gloombat"; monsterModel = obj:IsA("Model") and obj or obj.Parent
        end

        if detectedMonsterName and monsterModel then
            createBillboard(monsterModel, "⚠️ " .. detectedMonsterName, ESPColors.Monster, "ESPMonster")
            triggerSmartMonsterNotice(monsterModel, detectedMonsterName)
            return
        end

        local itemLabel = getItemLabel(obj.Name)
        if not itemLabel and obj.Parent then itemLabel = getItemLabel(obj.Parent.Name) end
        if not itemLabel and obj.Parent and obj.Parent.Parent then itemLabel = getItemLabel(obj.Parent.Parent.Name) end

        -- Sửa lỗi ESP cho Floor 2: Đọc trực tiếp ProximityPrompt để bắt tên vật phẩm bị đổi sang cấu trúc Drop/Loot
        local targetESPObj = obj
        if not itemLabel then
            local prompt = obj:IsA("ProximityPrompt") and obj or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and prompt.ObjectText and prompt.ObjectText ~= "" then
                local pText = prompt.ObjectText:lower()
                for key, label in pairs(ImportantItems) do
                    if pText:find(key) then
                        itemLabel = label
                        targetESPObj = prompt.Parent or obj
                        break
                    end
                end
            end
        end

        if itemLabel then
            local isHeld = false
            local ancestor = targetESPObj.Parent
            while ancestor and ancestor ~= Workspace do
                -- Sửa lỗi loại trừ nhầm các cơ chế của Floor 2
                if Players:GetPlayerFromCharacter(ancestor) then isHeld = true; break end
                ancestor = ancestor.Parent
            end

            if not isHeld then
                local tPart = getSafePart(targetESPObj)
                if tPart and not isTooCloseToExistingItemESP(tPart.Position) then
                    createBillboard(targetESPObj, itemLabel, ESPColors.Items, "ESPItems")
                end
            end
            return
        end

        if isRealRoomDoor(obj) then
            createBillboard(obj, "🚪 Cửa", ESPColors.Door, "ESPDoor")
        end

        if nameLower:find("lever", 1, true) or nameLower:find("breaker", 1, true) or nameLower:find("switch", 1, true) then
            createBillboard(obj, "🕹️ Cần Gạt / Cầu Chì", ESPColors.Lever, "ESPLever")
        end

        if nameLower:find("chest", 1, true) or nameLower == "lootbox" then
            createBillboard(obj, "📦 Rương Đồ", ESPColors.Chest, "ESPChest")
        end
    end)
end

task.spawn(function()
    for _, obj in ipairs(Workspace:GetDescendants()) do processObject(obj) end
end)
Workspace.DescendantAdded:Connect(processObject)

--------------------------------------------------
-- ESP NGƯỜI CHƠI
--------------------------------------------------
local function getHealthColor(percent)
    if percent >= 0.9 then
        return Color3.fromRGB(50, 255, 50)
    elseif percent >= 0.7 then
        return Color3.fromRGB(34, 139, 34)
    elseif percent >= 0.4 then
        return Color3.fromRGB(255, 255, 0)
    elseif percent >= 0.2 then
        return Color3.fromRGB(255, 140, 0)
    else
        return Color3.fromRGB(255, 50, 50)
    end
end

local function setupFullPlayerESP(plr)
    if plr == LocalPlayer then return end

    local function applyESPToCharacter(char)
        if not char then return end
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        local head = char:WaitForChild("Head", 5)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not hrp or not head or not humanoid then return end

        local hl = char:FindFirstChild("Mote_Player_Highlight") or Instance.new("Highlight")
        hl.Name = "Mote_Player_Highlight"
        hl.FillColor = ESPColors.Player
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char

        local bb = head:FindFirstChild("Mote_Player_Billboard") or Instance.new("BillboardGui")
        bb.Name = "Mote_Player_Billboard"
        bb.Adornee = head
        bb.Size = UDim2.new(0, 200, 0, 45)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true 
        bb.LightInfluence = 0 

        local label = bb:FindFirstChild("TextLabel") or Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 30)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 14
        label.TextColor3 = ESPColors.Player
        label.Parent = bb
        
        local healthBg = bb:FindFirstChild("HealthBg") or Instance.new("Frame")
        healthBg.Name = "HealthBg"
        healthBg.Size = UDim2.new(0, 80, 0, 7)
        healthBg.Position = UDim2.new(0.5, -40, 0, 32)
        healthBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        healthBg.BorderSizePixel = 1
        healthBg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        healthBg.Parent = bb

        local healthFill = healthBg:FindFirstChild("HealthFill") or Instance.new("Frame")
        healthFill.Name = "HealthFill"
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        healthFill.BorderSizePixel = 0
        healthFill.Parent = healthBg

        bb.Parent = head

        local box, line
        if HasDrawing then
            pcall(function()
                box = Drawing.new("Square"); box.Visible = false; box.Color = ESPColors.Player; box.Thickness = 1.5; box.Filled = false
                line = Drawing.new("Line"); line.Visible = false; line.Thickness = 1.5
            end)
        end

        local renderConnection
        renderConnection = RunService.RenderStepped:Connect(function()
            if not char or not char.Parent or not hrp or not hrp.Parent or not humanoid or not humanoid.Parent or humanoid.Health <= 0 or not Players:FindFirstChild(plr.Name) then
                hl:Destroy(); bb:Destroy()
                if HasDrawing then
                    pcall(function() 
                        if box then box:Remove() end 
                        if line then line:Remove() end 
                    end)
                end
                if renderConnection then renderConnection:Disconnect() end
                return
            end

            if Flags.ESPPlayer then
                hl.Enabled = true; bb.Enabled = true
                local localChar = LocalPlayer.Character
                local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")
                local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                local currentHealthColor = getHealthColor(healthPercent)

                if localHrp then
                    local dist = math.floor((localHrp.Position - hrp.Position).Magnitude)
                    label.Text = string.format("👤 %s\n[%d studs] | %d%%", plr.DisplayName, dist, math.floor(healthPercent * 100))
                end
                
                if healthFill then
                    healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                    healthFill.BackgroundColor3 = currentHealthColor
                end

                if HasDrawing and box then
                    pcall(function()
                        local targetPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                            local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                            local height = math.abs(headPos.Y - legPos.Y)
                            local width = height / 1.5

                            box.Size = Vector2.new(width, height)
                            box.Position = Vector2.new(targetPos.X - width / 2, targetPos.Y - height / 2)
                            box.Visible = true
                            
                            if line then
                                if localHrp then
                                    local myPos, _ = Camera:WorldToViewportPoint(localHrp.Position)
                                    line.From = Vector2.new(myPos.X, myPos.Y)
                                else
                                    local viewportSize = Camera.ViewportSize
                                    line.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                                end
                                line.To = Vector2.new(targetPos.X, targetPos.Y)
                                line.Color = currentHealthColor
                                line.Visible = true
                            end
                        else
                            box.Visible = false
                            if line then line.Visible = false end
                        end
                    end)
                end
            else
                hl.Enabled = false; bb.Enabled = false
                if HasDrawing then
                    pcall(function() 
                        if box then box.Visible = false end
                        if line then line.Visible = false end
                    end)
                end
            end
        end)
    end

    if plr.Character then applyESPToCharacter(plr.Character) end
    plr.CharacterAdded:Connect(applyESPToCharacter)
end

for _, p in ipairs(Players:GetPlayers()) do setupFullPlayerESP(p) end
Players.PlayerAdded:Connect(setupFullPlayerESP)

--------------------------------------------------
-- ANTI-AFK & FULLBRIGHT (FIX MÀN HÌNH XANH LÈ)
--------------------------------------------------
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if Flags.AntiAFK then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end
    end)
end)

local isFullbrightApplied = false
local originalEffectStates = {}

task.spawn(function()
    while task.wait(0.3) do
        if Flags.SmartFullbright then
            pcall(function()
                local val = (Flags.FullbrightIntensity / 100) * 2
                Lighting.Brightness = math.max(0.5, val)
                Lighting.ClockTime = 14
                Lighting.FogEnd = 1000000
                Lighting.GlobalShadows = false
                local ambValue = math.floor((Flags.FullbrightIntensity / 100) * 255)
                Lighting.Ambient = Color3.fromRGB(ambValue, ambValue, ambValue)
                Lighting.OutdoorAmbient = Color3.fromRGB(ambValue, ambValue, ambValue)
                
                if not isFullbrightApplied then
                    originalEffectStates = {}
                    for _, child in ipairs(Lighting:GetChildren()) do
                        if child:IsA("BlurEffect") or child:IsA("ColorCorrectionEffect") or child:IsA("Atmosphere") or child:IsA("DepthOfFieldEffect") then
                            originalEffectStates[child] = child.Enabled
                            child.Enabled = false
                        end
                    end
                end
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
                for child, originalState in pairs(originalEffectStates) do
                    if child and child.Parent then
                        child.Enabled = originalState
                    end
                end
                originalEffectStates = {}
            end)
        end
    end
end)

--------------------------------------------------
-- GIAO DIỆN MOTE HUB
--------------------------------------------------
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

local function getText(key) return Translations[Flags.Language][key] or key end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 520, 0, 360)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
mainFrame.BackgroundColor3 = Themes[Flags.Theme].FrameBg
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
makeDraggable(mainFrame)
local mainUICorner = Instance.new("UICorner"); mainUICorner.CornerRadius = UDim.new(0, 8); mainUICorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 0, 40)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🌟 MOTE HUB BETA 3.01 (OPTIMIZED)"
titleLabel.TextColor3 = Themes[Flags.Theme].Accent
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = mainFrame
local closeBtnCorner = Instance.new("UICorner"); closeBtnCorner.CornerRadius = UDim.new(0, 6); closeBtnCorner.Parent = closeBtn
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 35)
tabContainer.Position = UDim2.new(0, 10, 0, 45)
tabContainer.BackgroundColor3 = Themes[Flags.Theme].HeaderBg
tabContainer.Parent = mainFrame
local tabContainerCorner = Instance.new("UICorner"); tabContainerCorner.CornerRadius = UDim.new(0, 6); tabContainerCorner.Parent = tabContainer

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -20, 1, -100)
contentContainer.Position = UDim2.new(0, 10, 0, 90)
contentContainer.BackgroundColor3 = Themes[Flags.Theme].InnerBg
contentContainer.Parent = mainFrame
local contentContainerCorner = Instance.new("UICorner"); contentContainerCorner.CornerRadius = UDim.new(0, 6); contentContainerCorner.Parent = contentContainer

local Tabs = {}; local Pages = {}; local activeTab = nil

local function createTab(name, transKey)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.2, 0, 1, 0)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = getText(transKey)
    tabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 13
    registerTextLabel(tabBtn)
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = contentContainer
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    
    Tabs[name] = tabBtn; Pages[name] = page
    
    tabBtn.MouseButton1Click:Connect(function()
        if activeTab == name then return end
        activeTab = name
        for tName, btn in pairs(Tabs) do
            if tName == name then
                btn.TextColor3 = Themes[Flags.Theme].Accent
                TweenService:Create(btn, TweenInfo.new(0.2), {TextSize = Flags.TextSize + 1}):Play()
                Pages[tName].Visible = true
            else
                btn.TextColor3 = Color3.fromRGB(150, 150, 150)
                TweenService:Create(btn, TweenInfo.new(0.2), {TextSize = Flags.TextSize}):Play()
                Pages[tName].Visible = false
            end
        end
    end)
    
    return tabBtn, page
end

local function addToggle(page, labelText, flagKey, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.Parent = page
    local fCorner = Instance.new("UICorner"); fCorner.CornerRadius = UDim.new(0, 6); fCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Themes[Flags.Theme].Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    registerTextLabel(label)
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 45, 0, 22)
    toggleBtn.Position = UDim2.new(1, -55, 0.5, -11)
    toggleBtn.BackgroundColor3 = Flags[flagKey] and Themes[Flags.Theme].Accent or Color3.fromRGB(60, 60, 60)
    toggleBtn.Text = ""
    toggleBtn.Parent = frame
    local tCorner = Instance.new("UICorner"); tCorner.CornerRadius = UDim.new(1, 0); tCorner.Parent = toggleBtn
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = Flags[flagKey] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = toggleBtn
    local cCorner = Instance.new("UICorner"); cCorner.CornerRadius = UDim.new(1, 0); cCorner.Parent = circle
    
    toggleBtn.MouseButton1Click:Connect(function()
        Flags[flagKey] = not Flags[flagKey]
        local isEnabled = Flags[flagKey]
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = isEnabled and Themes[Flags.Theme].Accent or Color3.fromRGB(60, 60, 60)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = isEnabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
        if callback then callback(isEnabled) end
    end)
    return label
end

local function addSlider(page, labelText, flagKey, min, max, isFloat, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.Parent = page
    local fCorner = Instance.new("UICorner"); fCorner.CornerRadius = UDim.new(0, 6); fCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = labelText .. ": " .. tostring(Flags[flagKey])
    label.TextColor3 = Themes[Flags.Theme].Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    registerTextLabel(label)
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, 32)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBg.Parent = frame
    local bgCorner = Instance.new("UICorner"); bgCorner.CornerRadius = UDim.new(1, 0); bgCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    local pct = (Flags[flagKey] - min) / (max - min)
    sliderFill.Size = UDim2.new(pct, 0, 1, 0)
    sliderFill.BackgroundColor3 = Themes[Flags.Theme].Accent
    sliderFill.Parent = sliderBg
    local fillCorner = Instance.new("UICorner"); fillCorner.CornerRadius = UDim.new(1, 0); fillCorner.Parent = sliderFill
    
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(pct, -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Text = ""
    knob.Parent = sliderBg
    local kCorner = Instance.new("UICorner"); kCorner.CornerRadius = UDim.new(1, 0); kCorner.Parent = knob
    
    local dragging = false
    local function updateSlider(input)
        local relX = math.clamp(input.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
        local pct = relX / sliderBg.AbsoluteSize.X
        local val = min + (max - min) * pct
        if not isFloat then val = math.floor(val + 0.5) else val = math.floor(val * 10) / 10 end
        
        Flags[flagKey] = val
        label.Text = labelText .. ": " .. tostring(val)
        sliderFill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -7, 0.5, -7)
        if callback then callback(val) end
    end
    
    knob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
    end)
    return label
end

local tabMainBtn, pageMain = createTab("Main", "Main")
local tabEspBtn, pageEsp = createTab("ESP", "ESP")
local tabAutoBtn, pageAuto = createTab("Automation", "Automation")
local tabExpBtn, pageExp = createTab("Experimental", "Experimental")
local tabSetBtn, pageSet = createTab("Settings", "Settings")

local uiElements = {}

uiElements.AntiAFK = addToggle(pageMain, getText("AntiAFK"), "AntiAFK")
uiElements.MonsterNotify = addToggle(pageMain, getText("MonsterNotify"), "MonsterNotify")
uiElements.Fullbright = addToggle(pageMain, getText("Fullbright"), "SmartFullbright")
uiElements.FullbrightIntensity = addSlider(pageMain, "   ↳ Độ sáng Fullbright (%)", "FullbrightIntensity", 0, 100, false)

addToggle(pageEsp, "1. Cửa ESP (Door)", "ESPDoor")
addToggle(pageEsp, "2. Vật Phẩm ESP (Items)", "ESPItems")
addToggle(pageEsp, "3. Quái Vật ESP (Monsters)", "ESPMonster")
addToggle(pageEsp, "4. Cầu Dao / Cần Gạt ESP (Lever)", "ESPLever")
addToggle(pageEsp, "5. Rương Đồ ESP (Chest)", "ESPChest")
addToggle(pageEsp, "6. Người Chơi Khác ESP", "ESPPlayer")

uiElements.AutoDrawers = addToggle(pageAuto, getText("AutoDrawers"), "AutoDrawersLoot")
uiElements.AutoDoorKey = addToggle(pageAuto, getText("AutoDoorKey"), "AutoKeyDoor")

uiElements.NoClip = addToggle(pageExp, getText("NoClip"), "NoClip")
local jumpBtnLabel = nil
local function setupJumpButton()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = getText("Jump")
    btn.TextColor3 = Themes[Flags.Theme].Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = pageExp
    local bCorner = Instance.new("UICorner"); bCorner.CornerRadius = UDim.new(0, 6); bCorner.Parent = btn
    registerTextLabel(btn)
    jumpBtnLabel = btn
    
    btn.MouseButton1Click:Connect(function()
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.JumpPower = 50
                humanoid.Jump = true
            end
        end
    end)
end
setupJumpButton()

uiElements.SpeedHack = addToggle(pageExp, getText("Speed"), "SpeedHack")
uiElements.SpeedMult = addSlider(pageExp, "   ↳ Tốc Độ (x)", "SpeedMultiplier", 1.0, 10.0, true)
uiElements.AntiRubberband = addToggle(pageExp, "   ↳ Anti-Rubberband (Chống giật ngược)", "AntiRubberband")
uiElements.Freecam = addToggle(pageExp, getText("Freecam"), "FreecamSoul", function(state) setFreecamState(state) end)
uiElements.FlyCarpet = addToggle(pageExp, getText("FlyCarpet"), "FlyCarpet")

local function updateLanguage()
    tabMainBtn.Text = getText("Main")
    tabEspBtn.Text = getText("ESP")
    tabAutoBtn.Text = getText("Automation")
    tabExpBtn.Text = getText("Experimental")
    tabSetBtn.Text = getText("Settings")
    
    uiElements.AntiAFK.Text = getText("AntiAFK")
    uiElements.MonsterNotify.Text = getText("MonsterNotify")
    uiElements.Fullbright.Text = getText("Fullbright")
    
    uiElements.AutoDrawers.Text = getText("AutoDrawers")
    uiElements.AutoDoorKey.Text = getText("AutoDoorKey")
    
    uiElements.NoClip.Text = getText("NoClip")
    if jumpBtnLabel then jumpBtnLabel.Text = getText("Jump") end
    uiElements.SpeedHack.Text = getText("Speed")
    uiElements.Freecam.Text = getText("Freecam")
    uiElements.FlyCarpet.Text = getText("FlyCarpet")
end

local themeOptions = {"YellowBlack", "RedBlack", "GreenBlack", "PinkBlack"}
local currentThemeIdx = 1
local themeBtn = Instance.new("TextButton")
themeBtn.Size = UDim2.new(1, 0, 0, 35)
themeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
themeBtn.Text = getText("ThemeTitle") .. ": " .. themeOptions[currentThemeIdx]
themeBtn.TextColor3 = Themes[Flags.Theme].Text
themeBtn.Font = Enum.Font.Gotham
themeBtn.TextSize = 13
themeBtn.Parent = pageSet
local tCorner = Instance.new("UICorner"); tCorner.CornerRadius = UDim.new(0, 6); tCorner.Parent = themeBtn
registerTextLabel(themeBtn)
uiElements.ThemeTitle = themeBtn

themeBtn.MouseButton1Click:Connect(function()
    currentThemeIdx = (currentThemeIdx % #themeOptions) + 1
    Flags.Theme = themeOptions[currentThemeIdx]
    themeBtn.Text = getText("ThemeTitle") .. ": " .. Flags.Theme
    mainFrame.BackgroundColor3 = Themes[Flags.Theme].FrameBg
    tabContainer.BackgroundColor3 = Themes[Flags.Theme].HeaderBg
    contentContainer.BackgroundColor3 = Themes[Flags.Theme].InnerBg
    titleLabel.TextColor3 = Themes[Flags.Theme].Accent
    if Tabs[activeTab] then Tabs[activeTab].TextColor3 = Themes[Flags.Theme].Accent end
end)

local langBtn = Instance.new("TextButton")
langBtn.Size = UDim2.new(1, 0, 0, 35)
langBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
langBtn.Text = getText("LangTitle") .. ": " .. Flags.Language
langBtn.TextColor3 = Themes[Flags.Theme].Text
langBtn.Font = Enum.Font.Gotham
langBtn.TextSize = 13
langBtn.Parent = pageSet
local lCorner = Instance.new("UICorner"); lCorner.CornerRadius = UDim.new(0, 6); lCorner.Parent = langBtn
registerTextLabel(langBtn)
uiElements.LangTitle = langBtn

langBtn.MouseButton1Click:Connect(function()
    Flags.Language = Flags.Language == "VIE" and "ENG" or "VIE"
    langBtn.Text = getText("LangTitle") .. ": " .. Flags.Language
    themeBtn.Text = getText("ThemeTitle") .. ": " .. Flags.Theme
    updateLanguage()
end)

addSlider(pageSet, "3. Kích thước chữ (Text Size)", "TextSize", 10, 20, false, function() updateAllTextSizes() end)

local layoutTab = Instance.new("UIListLayout")
layoutTab.FillDirection = Enum.FillDirection.Horizontal
layoutTab.SortOrder = Enum.SortOrder.LayoutOrder
layoutTab.Parent = tabContainer

tabMainBtn.Parent = tabContainer
tabEspBtn.Parent = tabContainer
tabAutoBtn.Parent = tabContainer
tabExpBtn.Parent = tabContainer
tabSetBtn.Parent = tabContainer

activeTab = "Main"
Tabs["Main"].TextColor3 = Themes[Flags.Theme].Accent
Pages["Main"].Visible = true

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.E then
        mainFrame.Visible = not mainFrame.Visible
    end
    
    if isFreecamActive and Flags.FreecamSoul then
        if input.KeyCode == Enum.KeyCode.Space then flyVerticalSpeed = 25 * Flags.SpeedMultiplier
        elseif input.KeyCode == Enum.KeyCode.LeftControl then flyVerticalSpeed = -25 * Flags.SpeedMultiplier end
    end
    if Flags.FlyCarpet and not Flags.FreecamSoul then
        if input.KeyCode == Enum.KeyCode.Space then flyVerticalSpeed = 20 * Flags.SpeedMultiplier
        elseif input.KeyCode == Enum.KeyCode.LeftControl then flyVerticalSpeed = -20 * Flags.SpeedMultiplier end
    end
end)
UserInputService.InputEnded:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl then flyVerticalSpeed = 0 end
end)