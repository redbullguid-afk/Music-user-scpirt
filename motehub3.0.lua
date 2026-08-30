
-- ==================================================
-- MOTE HUB BETA 3.01 - ULTIMATE OPTIMIZED & FIXED ESP ITEMS (FLOOR 1 & 2) + CUSTOM ITEMS
-- ==================================================[cite: 9]

local Players = game:GetService("Players")[cite: 9]
local VirtualUser = game:GetService("VirtualUser")[cite: 9]
local UserInputService = game:GetService("UserInputService")[cite: 9]
local RunService = game:GetService("RunService")[cite: 9]
local Workspace = game:GetService("Workspace")[cite: 9]
local Lighting = game:GetService("Lighting")[cite: 9]
local CoreGui = game:GetService("CoreGui")[cite: 9]
local StarterGui = game:GetService("StarterGui")[cite: 9]
local TweenService = game:GetService("TweenService")[cite: 9]

local LocalPlayer = Players.LocalPlayer[cite: 9]
local Camera = Workspace.CurrentCamera[cite: 9]

local HasDrawing = false[cite: 9]
pcall(function()
    if Drawing and typeof(Drawing.new) == "function" then
        HasDrawing = true
    end
end)[cite: 9]

--------------------------------------------------
-- CẤU HÌNH TRẠNG THÁI (FLAGS)
--------------------------------------------------[cite: 9]
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
}[cite: 9]

local OriginalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}[cite: 9]

--------------------------------------------------
-- PALETTE MÀU THEME MENU & MÀU ESP
--------------------------------------------------[cite: 9]
local Themes = {
    YellowBlack = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(255, 215, 0), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) },
    RedBlack    = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(239, 68, 68), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) },
    GreenBlack  = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(34, 197, 94), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) },
    PinkBlack   = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(236, 72, 153), Accent = Color3.fromRGB(236, 72, 153), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) }
}[cite: 9]

local ESPColors = {
    Monster = Color3.fromRGB(255, 40, 40),
    Door    = Color3.fromRGB(0, 255, 128),
    Lever   = Color3.fromRGB(255, 255, 0),
    Chest   = Color3.fromRGB(200, 100, 255),
    Items   = Color3.fromRGB(0, 255, 255),
    Player  = Color3.fromRGB(255, 140, 0)
}[cite: 9]

local Translations = {
    VIE = { Main = "Main", ESP = "ESP", Automation = "Tự Động", Experimental = "Thử Nghiệm", Settings = "Cài Đặt", AntiAFK = "1. Anti-AFK", MonsterNotify = "2. Cảnh Báo Quái Vật (Báo Đi)", Fullbright = "3. Nhìn Trong Bóng Tối (Fix Hant)", AutoDrawers = "1. Auto Mở Tủ (3 Tủ) & Loot Đồ", AutoDoorKey = "2. Auto Mở Cửa Bằng Key", NoClip = "1. NoClip (Xuyên Tường)", Jump = "2. Nút Nhảy DOORS (1 Lần)", Speed = "3. Speed Hack (Max 10x)", Freecam = "4. Khảm Giả (Linh Hồn Tách Xác)", FlyCarpet = "5. Bay Sáng Tạo", ThemeTitle = "1. Đổi Màu Menu", LangTitle = "2. Ngôn Ngữ", FontSizeTitle = "3. Kích Thước Chữ", Author = "Tác Giả: By Mờ Tê", Facebook = "Facebook: Nguyễn minh tân", Version = "Phiên Bản: Mote Hub Beta 3.01 (Optimized)" },
    ENG = { Main = "Main", ESP = "ESP", Automation = "Automation", Experimental = "Experimental", Settings = "Settings", AntiAFK = "1. Anti-AFK", MonsterNotify = "2. Monster Notify (Safe Leave)", Fullbright = "3. Fullbright (Hant Fix)", AutoDrawers = "1. Auto Open 3 Drawers & Auto Loot", AutoDoorKey = "2. Auto Key Door", NoClip = "1. NoClip", Jump = "2. DOORS Jump Button (Single)", Speed = "3. Speed Hack (Up to 10x)", Freecam = "4. Freecam Soul (Spectate Fly)", FlyCarpet = "5. Creative Fly", ThemeTitle = "1. Change Theme", LangTitle = "2. Language", FontSizeTitle = "3. Text Size", Author = "Author: By Mote", Facebook = "Facebook: Nguyen minh tan", Version = "Version: Mote Hub Beta 3.01 (Optimized)" }
}[cite: 9]

--------------------------------------------------
-- GIAO DIỆN MÀN HÌNH CHÍNH
--------------------------------------------------[cite: 9]
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoteHub_Beta301"
screenGui.ResetOnSpawn = false

pcall(function()
    if gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = CoreGui
    end
end)[cite: 9]
if not screenGui.Parent then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end[cite: 9]

--------------------------------------------------
-- BẢNG DỮ LIỆU VẬT THỂ VÀ QUÁI VẬT (Đã bổ sung Sách, Cầu chì, Cốc bia)
--------------------------------------------------[cite: 9]
local ImportantItems = {
    ["keyobtain"] = "🔑 Chìa Khóa", ["key"] = "🔑 Chìa Khóa", ["masterkey"] = "🔑 Chìa Khóa Master",
    ["skeletonkey"] = "💀 Chìa Khóa Đầu Lâu", ["flashlight"] = "🔦 Đèn Pin", ["candle"] = "🕯️ Nến",
    ["crucifix"] = "✝️ Cây Thánh Giá", ["lockpick"] = "🗝️ Lockpick", ["bandage"] = "🩹 Băng Gạc",
    ["vitamins"] = "💊 Vitamin", ["battery"] = "🔋 Pin",
    ["glowstick"] = "💡 Que Phát Sáng", ["shears"] = "✂️ Kéo Cắt Cây", ["starlight"] = "🌟 Bình Starlight",
    ["bandagepack"] = "🩹 Hộp Băng Gạc", ["batterypack"] = "🔋 Hộp Pin", ["bulklight"] = "🔦 Đèn Pin Công Nghiệp",
    ["laserpointer"] = "🔴 Đèn Laser", ["alarmclock"] = "⏰ Đồng Hồ Báo Thức", ["compass"] = "🧭 La Bàn",
    ["strafe"] = "🌟 Bình Starlight", ["pickaxe"] = "⛏️ Cuốc",
    -- Bổ sung các vật phẩm theo yêu cầu:
    ["book"] = "📖 Sách (Cửa 50)",
    ["fuse"] = "⚡ Cầu Chì (Cửa 100 / Floor 2)",
    ["beer"] = "🍺 Cốc Bia (Phòng Gạt Cần)",
    ["beerglass"] = "🍺 Cốc Bia (Phòng Gạt Cần)",
    ["pint"] = "🍺 Cốc Bia (Phòng Gạt Cần)"
}[cite: 9]

local MonsterAdvice = {
    ["Rush"] = "Trốn vô tủ mau!", ["Ambush"] = "Trốn vô tủ mau!", ["Seek"] = "Chuẩn bị chạy trốn Seek!",
    ["Screech"] = "Xoay người nhìn nó ngay!", ["Eyes"] = "Không nhìn vào nó!", ["Halt"] = "Chú ý đổi hướng di chuyển!",
    ["Figure"] = "Đi cúi người (Crouch), giữ khoảng cách!", ["Hide"] = "Rời khỏi tủ ngay!", ["Jack"] = "Chờ 1 chút rồi mở lại tủ!",
    ["Timothy"] = "Nhện giật mình trong hộc bàn!", ["Dread"] = "Mở cửa tiến lên phía trước mau!", ["A-60"] = "Trốn vô tủ ngay!", ["A-120"] = "Trốn vô tủ ngay!",
    ["Giggle"] = "Nhìn lên trần nhà và ném Glowstick!", ["Grumble"] = "Chạy thật nhanh, tránh đường cụt!", ["Gloombat"] = "Tắt đèn, đừng soi đèn vào bầy dơi!"
}[cite: 9]

local function getItemLabel(name)
    if not name or name == "" then return nil end
    local lowerName = name:lower()
    
    if ImportantItems[lowerName] then return ImportantItems[lowerName] end
    
    for key, label in pairs(ImportantItems) do
        if lowerName == key or lowerName == (key .. "item") or lowerName == ("item_" .. key) then
            return label
        end
    end
    return nil
end[cite: 9]

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
end[cite: 9]

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
end[cite: 9]

--------------------------------------------------
-- HỆ THỐNG FONT SIZE REAL-TIME
--------------------------------------------------[cite: 9]
local TextSizeRegister = {}
local function registerTextLabel(label)
    table.insert(TextSizeRegister, label)
    label.TextSize = Flags.TextSize
end
local function updateAllTextSizes()
    for _, lbl in ipairs(TextSizeRegister) do
        if lbl and lbl.Parent then lbl.TextSize = Flags.TextSize end
    end
end[cite: 9]

--------------------------------------------------
-- HÀM TƯƠNG TÁC SAFE PROXIMITY PROMPT
--------------------------------------------------[cite: 9]
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
end[cite: 9]

--------------------------------------------------
-- LOGIC AUTO MỞ TỦ & AUTO LOOT
--------------------------------------------------[cite: 9]
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
end)[cite: 9]

--------------------------------------------------
-- LOGIC AUTO MỞ CỬA BẰNG KEY
--------------------------------------------------[cite: 9]
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
end)[cite: 9]

--------------------------------------------------
-- TÍNH NĂNG SPEED HACK, NOCLIP & FREECAM
--------------------------------------------------[cite: 9]
RunService.Stepped:Connect(function()
    if Flags.NoClip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)[cite: 9]

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
end)[cite: 9]

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
end)[cite: 9]

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
end[cite: 9]

RunService.RenderStepped:Connect(function(dt)
    if isFreecamActive and freecamPart and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local moveDir = humanoid and humanoid.MoveDirection or Vector3.new(0, 0, 0)
        local speed = 25 * Flags.SpeedMultiplier
        
        local horizontalMove = Vector3.new(moveDir.X, 0, moveDir.Z)
        local verticalMove = Vector3.new(0, flyVerticalSpeed, 0) * dt
        
        freecamPart.Position = freecamPart.Position + (horizontalMove * speed * dt) + verticalMove
    end
end)[cite: 9]

--------------------------------------------------
-- HỆ THỐNG ESP QUẢN LÝ TẬP TRUNG (FIXED CHO FLOOR 2)
--------------------------------------------------[cite: 9]
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
    
    local current = targetObj.Parent
    while current and current ~= Workspace do
        prompt = current:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then return prompt end
        current = current.Parent
    end
    return nil
end

local function isItemValidAndUncollected(targetObj)
    if not targetObj or not targetObj.Parent or not targetObj:IsDescendantOf(Workspace) then
        return false
    end

    local current = targetObj
    while current and current ~= Workspace do
        if current:FindFirstChildOfClass("Humanoid") or Players:GetPlayerFromCharacter(current) then
            return false
        end
        current = current.Parent
    end

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
        local function setupPromptConnection()
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
        end
        setupPromptConnection()

        table.insert(connections, targetObj.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("ProximityPrompt") then
                setupPromptConnection()
            end
        end))

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
end[cite: 9]

--------------------------------------------------
-- CẢNH BÁO QUÁI VẬT & QUÉT VẬT THỂ
--------------------------------------------------[cite: 9]
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

        if not itemLabel then
            for _, desc in ipairs(obj:GetDescendants()) do
                itemLabel = getItemLabel(desc.Name)
                if itemLabel then break end
                if desc:IsA("ProximityPrompt") then
                    local act = (desc.ActionText or ""):lower()
                    if act:find("take") or act:find("grab") or act:find("pick") or act:find("collect") then
                        itemLabel = getItemLabel(desc.Parent.Name) or getItemLabel(obj.Name) or "📦 Vật Phẩm"
                        break
                    end
                end
            end
        end

        if itemLabel then
            local isHeld = false
            local ancestor = obj.Parent
            while ancestor and ancestor ~= Workspace do
                if ancestor:FindFirstChildOfClass("Humanoid") then isHeld = true; break end
                ancestor = ancestor.Parent
            end

            if not isHeld then
                local tPart = getSafePart(obj)
                if tPart and not isTooCloseToExistingItemESP(tPart.Position) then
                    createBillboard(obj, itemLabel, ESPColors.Items, "ESPItems")
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
Workspace.DescendantAdded:Connect(processObject)[cite: 9]

--------------------------------------------------
-- ESP NGƯỜI CHƠI
--------------------------------------------------[cite: 9]
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
Players.PlayerAdded:Connect(setupFullPlayerESP)[cite: 9]

--------------------------------------------------
-- ANTI-AFK & FULLBRIGHT
--------------------------------------------------[cite: 9]
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
end)[cite: 9]

--------------------------------------------------
-- GIAO DIỆN MOTE HUB
--------------------------------------------------[cite: 9]
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
mainFrame.Size = UDim2.new(0, 520, 0, 280); mainFrame.Position = UDim2.new(0.25, 0, 0.3, 0); mainFrame.AnchorPoint = Vector2.new(0.5, 0.5); mainFrame.BackgroundColor3 = Themes.YellowBlack.FrameBg; mainFrame.BorderSizePixel = 0; mainFrame.Visible = false; mainFrame.ClipsDescendants = true; mainFrame.Parent = screenGui
makeDraggable(mainFrame)

local frameCorner = Instance.new("UICorner"); frameCorner.CornerRadius = UDim.new(0, 10); frameCorner.Parent = mainFrame
local frameStroke = Instance.new("UIStroke"); frameStroke.Color = Themes.YellowBlack.Accent; frameStroke.Thickness = 2; frameStroke.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 36); titleLabel.BackgroundColor3 = Themes.YellowBlack.HeaderBg; titleLabel.TextColor3 = Themes.YellowBlack.Accent; titleLabel.Text = "   MOTE HUB BETA 3.01"; titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextSize = 14; titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.Parent = mainFrame
local titleCorner = Instance.new("UICorner"); titleCorner.CornerRadius = UDim.new(0, 10); titleCorner.Parent = titleLabel

local tabNav = Instance.new("Frame")
tabNav.Size = UDim2.new(0.96, 0, 0, 30); tabNav.Position = UDim2.new(0.02, 0, 0.15, 0); tabNav.BackgroundTransparency = 1; tabNav.Parent = mainFrame

local tabs, pages = {}, {}
local tabNames = {"Main", "ESP", "Automation", "Experimental", "Settings"}

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
    btn.Size = UDim2.new(0.19, 0, 1, 0); btn.Position = UDim2.new((i - 1) * 0.202, 0, 0, 0); btn.BackgroundColor3 = (i == 1) and Themes.YellowBlack.Accent or Color3.fromRGB(35, 35, 35); btn.TextColor3 = (i == 1) and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.SourceSansBold; btn.Text = Translations[Flags.Language][name] or name; btn.Parent = tabNav
    registerTextLabel(btn)
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
    textLbl.Size = UDim2.new(0.7, 0, 1, 0); textLbl.BackgroundTransparency = 1; textLbl.Text = labelText; textLbl.Font = Enum.Font.SourceSansBold; textLbl.TextColor3 = Color3.fromRGB(255, 255, 255); textLbl.TextXAlignment = Enum.TextXAlignment.Left; textLbl.Parent = container
    registerTextLabel(textLbl)

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
            TweenService:Create(toggleBg, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 48, 0, 24)}):Play()
            task.delay(0.1, function()
                TweenService:Create(toggleBg, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 44, 0, 22)}):Play()
            end)
            TweenService:Create(toggleDot, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPos, BackgroundColor3 = targetColor}):Play()
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
    textLbl.Size = UDim2.new(0.7, 0, 0, 18); textLbl.BackgroundTransparency = 1; textLbl.Text = labelText .. ": " .. tostring(currentVal); textLbl.Font = Enum.Font.SourceSansBold; textLbl.TextColor3 = Color3.fromRGB(255, 255, 255); textLbl.TextXAlignment = Enum.TextXAlignment.Left; textLbl.Parent = container
    registerTextLabel(textLbl)

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
        local val = math.floor((minVal + (maxVal - minVal) * posX) * 10) / 10
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
            local state = humanoid:GetState()
            if state ~= Enum.HumanoidStateType.Freefall and state ~= Enum.HumanoidStateType.Jumping then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = 38
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 38, hrp.AssemblyLinearVelocity.Z)
            end
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

local function updateFlyControlVisibility() flyControlFrame.Visible = Flags.FlyCarpet or Flags.FreecamSoul end

-- TAB 1
createToggleSwitch(pages[1], Translations[Flags.Language].AntiAFK, "AntiAFK", 5)
createToggleSwitch(pages[1], Translations[Flags.Language].MonsterNotify, "MonsterNotify", 40)
createToggleSwitch(pages[1], Translations[Flags.Language].Fullbright, "SmartFullbright", 75)
createSlider(pages[1], "  └ Độ Sáng", 0, 100, Flags.FullbrightIntensity, 110, function(val) Flags.FullbrightIntensity = val end)

-- TAB 2
createToggleSwitch(pages[2], "🟢 ESP Cửa (Door)", "ESPDoor", 5)
createToggleSwitch(pages[2], "🔵 ESP Vật Phẩm (Floor 1 & 2 Items)", "ESPItems", 40)
createToggleSwitch(pages[2], "🔴 ESP Quái Vật (Bao gồm Floor 2)", "ESPMonster", 75)
createToggleSwitch(pages[2], "🟡 ESP Cần Gạt / Breaker Box", "ESPLever", 110)
createToggleSwitch(pages[2], "🟣 ESP Rương Đồ (Chest)", "ESPChest", 145)
createToggleSwitch(pages[2], "🟠 ESP Người Chơi", "ESPPlayer", 180)

-- TAB 3
createToggleSwitch(pages[3], Translations[Flags.Language].AutoDrawers, "AutoDrawersLoot", 5)
createToggleSwitch(pages[3], Translations[Flags.Language].AutoDoorKey, "AutoKeyDoor", 40)

-- TAB 4
createToggleSwitch(pages[4], Translations[Flags.Language].NoClip, "NoClip", 5)
createToggleSwitch(pages[4], Translations[Flags.Language].Jump, "DoorsJump", 40, function(st) jumpButtonUI.Visible = st end)
createToggleSwitch(pages[4], Translations[Flags.Language].Speed, "SpeedHack", 75)
createSlider(pages[4], "  └ Tốc Độ (1.0x - 10.0x)", 1.0, 10.0, Flags.SpeedMultiplier, 110, function(val) Flags.SpeedMultiplier = val end)
createToggleSwitch(pages[4], "🛡️ Anti Rubberband (Chống Giật Về)", "AntiRubberband", 155)
createToggleSwitch(pages[4], Translations[Flags.Language].Freecam, "FreecamSoul", 190, function(st) setFreecamState(st); updateFlyControlVisibility() end)
createToggleSwitch(pages[4], Translations[Flags.Language].FlyCarpet, "FlyCarpet", 225, function(st) updateFlyControlVisibility() end)

-- TAB 5
local themeLbl = Instance.new("TextLabel")
themeLbl.Size = UDim2.new(0.96, 0, 0, 20); themeLbl.Position = UDim2.new(0.02, 0, 0, 5); themeLbl.BackgroundTransparency = 1; themeLbl.Text = Translations[Flags.Language].ThemeTitle; themeLbl.Font = Enum.Font.SourceSansBold; themeLbl.TextColor3 = Color3.fromRGB(255, 255, 255); themeLbl.TextXAlignment = Enum.TextXAlignment.Left; themeLbl.Parent = pages[5]
registerTextLabel(themeLbl)

local themeBtns = { { Name = "Vàng Đen", Key = "YellowBlack", Pos = 0 }, { Name = "Đỏ Đen", Key = "RedBlack", Pos = 0.25 }, { Name = "Xanh Đen", Key = "GreenBlack", Pos = 0.50 }, { Name = "Hồng Đen", Key = "PinkBlack", Pos = 0.75 } }
for _, tData in ipairs(themeBtns) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.23, 0, 0, 25); b.Position = UDim2.new(tData.Pos, 0, 0, 28); b.BackgroundColor3 = Color3.fromRGB(35, 35, 35); b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Text = tData.Name; b.Font = Enum.Font.SourceSansBold; b.Parent = pages[5]
    registerTextLabel(b)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = b
    b.MouseButton1Click:Connect(function() Flags.Theme = tData.Key; applyTheme() end)
end

local langLbl = Instance.new("TextLabel")
langLbl.Size = UDim2.new(0.96, 0, 0, 20); langLbl.Position = UDim2.new(0.02, 0, 0, 62); langLbl.BackgroundTransparency = 1; langLbl.Text = Translations[Flags.Language].LangTitle; langLbl.Font = Enum.Font.SourceSansBold; langLbl.TextColor3 = Color3.fromRGB(255, 255, 255); langLbl.TextXAlignment = Enum.TextXAlignment.Left; langLbl.Parent = pages[5]
registerTextLabel(langLbl)

local btnVie = Instance.new("TextButton")
btnVie.Size = UDim2.new(0.46, 0, 0, 25); btnVie.Position = UDim2.new(0, 0, 0, 85); btnVie.BackgroundColor3 = Color3.fromRGB(35, 35, 35); btnVie.TextColor3 = Color3.fromRGB(255, 255, 255); btnVie.Text = "Tiếng Việt"; btnVie.Font = Enum.Font.SourceSansBold; btnVie.Parent = pages[5]
registerTextLabel(btnVie)
local vC = Instance.new("UICorner"); vC.CornerRadius = UDim.new(0, 4); vC.Parent = btnVie

local btnEng = Instance.new("TextButton")
btnEng.Size = UDim2.new(0.5, 0, 0, 25); btnEng.Position = UDim2.new(0.5, 0, 0, 85); btnEng.BackgroundColor3 = Color3.fromRGB(35, 35, 35); btnEng.TextColor3 = Color3.fromRGB(255, 255, 255); btnEng.Text = "English"; btnEng.Font = Enum.Font.SourceSansBold; btnEng.Parent = pages[5]
registerTextLabel(btnEng)
local eC = Instance.new("UICorner"); eC.CornerRadius = UDim.new(0, 4); eC.Parent = btnEng

createSlider(pages[5], Translations[Flags.Language].FontSizeTitle, 10, 18, Flags.TextSize, 120, function(val)
    Flags.TextSize = math.floor(val)
    updateAllTextSizes()
end)

local authorLbl = Instance.new("TextLabel")
authorLbl.Size = UDim2.new(0.96, 0, 0, 20); authorLbl.Position = UDim2.new(0.02, 0, 0, 170); authorLbl.BackgroundTransparency = 1; authorLbl.Text = Translations[Flags.Language].Author; authorLbl.Font = Enum.Font.SourceSansBold; authorLbl.TextColor3 = Color3.fromRGB(255, 215, 0); authorLbl.TextXAlignment = Enum.TextXAlignment.Left; authorLbl.Parent = pages[5]
registerTextLabel(authorLbl)

local fbLbl = Instance.new("TextLabel")
fbLbl.Size = UDim2.new(0.96, 0, 0, 20); fbLbl.Position = UDim2.new(0.02, 0, 0, 195); fbLbl.BackgroundTransparency = 1; fbLbl.Text = Translations[Flags.Language].Facebook; fbLbl.Font = Enum.Font.SourceSansBold; fbLbl.TextColor3 = Color3.fromRGB(200, 200, 200); fbLbl.TextXAlignment = Enum.TextXAlignment.Left; authorLbl.Parent = pages[5]
fbLbl.Parent = pages[5]
registerTextLabel(fbLbl)

local verLbl = Instance.new("TextLabel")
verLbl.Size = UDim2.new(0.96, 0, 0, 20); verLbl.Position = UDim2.new(0.02, 0, 0, 220); verLbl.BackgroundTransparency = 1; verLbl.Text = Translations[Flags.Language].Version; verLbl.Font = Enum.Font.SourceSansBold; verLbl.TextColor3 = Color3.fromRGB(150, 150, 150); verLbl.TextXAlignment = Enum.TextXAlignment.Left; verLbl.Parent = pages[5]
registerTextLabel(verLbl)

local function refreshLanguage()
    for i, name in ipairs(tabNames) do tabs[i].Text = Translations[Flags.Language][name] or name end
    themeLbl.Text = Translations[Flags.Language].ThemeTitle
    langLbl.Text = Translations[Flags.Language].LangTitle
    authorLbl.Text = Translations[Flags.Language].Author
    fbLbl.Text = Translations[Flags.Language].Facebook
    verLbl.Text = Translations[Flags.Language].Version
end

btnVie.MouseButton1Click:Connect(function() Flags.Language = "VIE"; refreshLanguage() end)
btnEng.MouseButton1Click:Connect(function() Flags.Language = "ENG"; refreshLanguage() end)

--------------------------------------------------
-- MỞ / TẮT MENU
--------------------------------------------------[cite: 9]
local isMenuAnimating = false
circleBtn.MouseButton1Click:Connect(function()
    if isMenuAnimating then return end
    isMenuAnimating = true

    if mainFrame.Visible then
        local tweenClose = TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0) })
        tweenClose:Play()
        tweenClose.Completed:Connect(function() mainFrame.Visible = false; isMenuAnimating = false end)
    else
        mainFrame.Size = UDim2.new(0, 0, 0, 0); mainFrame.Visible = true
        local tweenOpen = TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 520, 0, 280) })
        tweenOpen:Play()
        tweenOpen.Completed:Connect(function() isMenuAnimating = false end)
    end
end)

applyTheme()

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "MOTE HUB BETA 3.01",
        Text = "Mote Hub ESP Thêm Sách, Cầu Chì & Cốc Bia Đã Sẵn Sàng!",
        Duration = 4
    })
end)[cite: 9]