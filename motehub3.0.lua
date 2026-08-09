-- ==================================================
-- MOTE HUB BETA 2.5 - FULL MONSTERS NOTIFY & SMART SEEK COOLDOWN
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
    ESPLever = false,
    ESPChest = false,
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
-- PALETTE MÀU THEME MENU & MÀU ESP
--------------------------------------------------
local Themes = {
    YellowBlack = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(255, 215, 0), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) },
    RedBlack = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(239, 68, 68), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) },
    GreenBlack = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(34, 197, 94), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) },
    PinkBlack = { FrameBg = Color3.fromRGB(15, 15, 15), HeaderBg = Color3.fromRGB(236, 72, 153), Accent = Color3.fromRGB(236, 72, 153), InnerBg = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255, 255, 255) }
}

local ESPColors = {
    Monster = Color3.fromRGB(255, 40, 40),    -- 🔴 Đỏ Rực (Quái vật)
    Door    = Color3.fromRGB(0, 255, 128),   -- 🟢 Xanh Lá (Cửa)
    Lever   = Color3.fromRGB(255, 255, 0),   -- 🟡 Vàng Chói (Cần gạt / Breaker)
    Chest   = Color3.fromRGB(200, 100, 255), -- 🟣 Tím (Rương đồ)
    Items   = Color3.fromRGB(0, 255, 255),   -- 🔵 Cyan (Sách, Cầu trì, Items)
    Player  = Color3.fromRGB(255, 140, 0)    -- 🟠 Cam Sáng (Người chơi)
}

local Translations = {
    VIE = { Main = "Main", ESP = "ESP", Experimental = "Thử Nghiệm", Info = "Info", Settings = "Settings", AntiAFK = "1. Anti-AFK", MonsterNotify = "2. Cảnh Báo Quái Vật Thông Minh", Fullbright = "3. Nhìn Trong Bóng Tối", AutoLoot = "4. Auto Mở Cửa Key & Loot", NoClip = "1. NoClip (Xuyên Tường)", Jump = "2. Nút Nhảy DOORS", Speed = "3. Speed Hack (Tối đa x4)", ThirdPerson = "4. Góc Nhìn Thứ 3", FlyCarpet = "5. Bay Sáng Tạo (Minecraft Fly)", ThemeTitle = "1. Đổi Màu Menu", LangTitle = "2. Ngôn Ngữ (Language)", FontSizeTitle = "3. Kích Thước Chữ", Author = "Tác Giả: By Mờ Tê", Facebook = "Facebook: Nguyễn minh tân", Version = "Phiên Bản: Mote Hub Beta 2.5" },
    ENG = { Main = "Main", ESP = "ESP", Experimental = "Experimental", Info = "Info", Settings = "Settings", AntiAFK = "1. Anti-AFK", MonsterNotify = "2. Smart Monster Notify", Fullbright = "3. Fullbright", AutoLoot = "4. Auto Key & Loot", NoClip = "1. NoClip", Jump = "2. DOORS Jump Button", Speed = "3. Speed Hack (Up to x4)", ThirdPerson = "4. Third Person View", FlyCarpet = "5. Creative Fly (Minecraft)", ThemeTitle = "1. Change Theme", LangTitle = "2. Language", FontSizeTitle = "3. Text Size", Author = "Author: By Mote", Facebook = "Facebook: Nguyen minh tan", Version = "Version: Mote Hub Beta 2.5" }
}

--------------------------------------------------
-- BẢNG DỮ LIỆU VẬT THỂ VÀ DANH SÁCH QUÁI VẬT MỞ RỘNG
--------------------------------------------------
local ImportantItems = {
    ["KeyObtain"] = "🔑 Chìa Khóa", ["Key"] = "🔑 Chìa Khóa", ["MasterKey"] = "🔑 Chìa Khóa Master",
    ["SkeletonKey"] = "💀 Chìa Khóa Đầu Lâu",
    ["Flashlight"] = "🔦 Đèn Pin", ["Candle"] = "🕯️ Nến", ["Crucifix"] = "✝️ Cây Thánh Giá",
    ["Lockpick"] = "🗝️ Lockpick", ["Bandage"] = "🩹 Băng Gạc", ["Vitamins"] = "💊 Vitamin",
    ["Battery"] = "🔋 Pin", 
    ["LiveHintBook"] = "📘 Sách", 
    ["FuseInPlainSight"] = "🔋 Cầu Chì", 
    ["Lighter"] = "🔥 Bật Lửa"
}

-- Bảng hướng dẫn hành động riêng cho TẤT CẢ các con quái
local MonsterAdvice = {
    ["Rush"] = "Trốn vô tủ mau!",
    ["Ambush"] = "Trốn vô tủ mau!",
    ["Seek"] = "Chuẩn bị chạy trốn Seek!",
    ["Screech"] = "Xoay người nhìn nó ngay!",
    ["Eyes"] = "Không nhìn vào nó!",
    ["Halt"] = "Chú ý đổi hướng di chuyển!",
    ["Figure"] = "Đi cúi người (Crouch), giữ khoảng cách!",
    ["Hide"] = "Rời khỏi tủ ngay!",
    ["Jack"] = "Chờ 1 chút rồi mở lại tủ!",
    ["Dupe"] = "Cẩn thận cửa giả!",
    ["Timothy"] = "Nhện giật mình trong hộc bàn!",
    ["Dread"] = "Mở cửa tiến lên phía trước mau!",
    ["A-60"] = "Trốn vô tủ / chỗ nấp ngay!",
    ["A-120"] = "Trốn vô tủ ngay!"
}

--------------------------------------------------
-- HỆ THỐNG CẬP NHẬT FONT SIZE REAL-TIME
--------------------------------------------------
local TextSizeRegister = {}

local function registerTextLabel(label)
    table.insert(TextSizeRegister, label)
    label.TextSize = Flags.TextSize
end

local function updateAllTextSizes()
    for _, lbl in ipairs(TextSizeRegister) do
        if lbl and lbl.Parent then
            lbl.TextSize = Flags.TextSize
        end
    end
end

--------------------------------------------------
-- TÍNH NĂNG TỐC ĐỘ, NOCLIP, BAY & CAM
--------------------------------------------------
RunService.RenderStepped:Connect(function(dt)
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if Flags.SpeedHack and hrp and humanoid and humanoid.Health > 0 then
            if humanoid.MoveDirection.Magnitude > 0 then
                local extraSpeedMultiplier = Flags.SpeedMultiplier - 1
                if extraSpeedMultiplier > 0 then
                    local moveDelta = humanoid.MoveDirection * (16 * extraSpeedMultiplier) * dt
                    hrp.CFrame = hrp.CFrame + moveDelta
                end
            end
        end

        if Flags.NoClip then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end
end)

local flyBodyVel, flyBodyGyro = nil, nil
local flyVerticalSpeed = 0

RunService.RenderStepped:Connect(function()
    if Flags.FlyCarpet and LocalPlayer.Character then
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
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
        end
        if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        flyVerticalSpeed = 0
    end
end)

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
-- ESP CHỮ ĐƠN GIẢN
--------------------------------------------------
local function createBillboard(targetPart, text, color, flagName)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Mote_ESP_" .. flagName
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 160, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextSize = 13
    label.Font = Enum.Font.SourceSansBold
    label.TextColor3 = color
    label.Parent = billboard

    billboard.Parent = targetPart

    task.spawn(function()
        while targetPart and targetPart.Parent and targetPart:IsDescendantOf(Workspace) do
            if Flags[flagName] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                billboard.Enabled = true
                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude)
                label.Text = string.format("%s\n[%d studs]", text, dist)
            else
                billboard.Enabled = false
            end
            task.wait(0.2)
        end
        pcall(function() billboard:Destroy() end)
    end)
end

--------------------------------------------------
-- ESP NGƯỜI CHƠI (HIGHLIGHT, BOX, TRACER, NAME)
--------------------------------------------------
local function setupFullPlayerESP(plr)
    if plr == LocalPlayer then return end

    local function applyESPToCharacter(char)
        if not char then return end
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        local head = char:WaitForChild("Head", 5)
        if not hrp or not head then return end

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
        bb.Size = UDim2.new(0, 160, 0, 30)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = true

        local label = bb:FindFirstChild("TextLabel") or Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 14
        label.TextColor3 = ESPColors.Player
        label.Parent = bb
        bb.Parent = head

        local box = Drawing.new("Square")
        box.Visible = false; box.Color = ESPColors.Player; box.Thickness = 1.5; box.Filled = false

        local line = Drawing.new("Line")
        line.Visible = false; line.Color = ESPColors.Player; line.Thickness = 1.5

        local renderConnection
        renderConnection = RunService.RenderStepped:Connect(function()
            if not char or not char.Parent or not hrp or not hrp.Parent or not Players:FindFirstChild(plr.Name) then
                hl:Destroy(); bb:Destroy(); box:Remove(); line:Remove()
                if renderConnection then renderConnection:Disconnect() end
                return
            end

            if Flags.ESPPlayer then
                hl.Enabled = true; bb.Enabled = true
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                    label.Text = string.format("👤 %s\n[%d studs]", plr.DisplayName, dist)
                end

                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 1.5

                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                    box.Visible = true

                    line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Visible = true
                else
                    box.Visible = false; line.Visible = false
                end
            else
                hl.Enabled = false; bb.Enabled = false; box.Visible = false; line.Visible = false
            end
        end)
    end

    if plr.Character then applyESPToCharacter(plr.Character) end
    plr.CharacterAdded:Connect(applyESPToCharacter)
end

for _, p in ipairs(Players:GetPlayers()) do setupFullPlayerESP(p) end
Players.PlayerAdded:Connect(setupFullPlayerESP)

--------------------------------------------------
-- SMART MONSTER NOTIFIER (BÁO TẤT CẢ QUÁI + CHUẨN COOLDOWN SEEK 3 PHÚT)
--------------------------------------------------
local notifiedMonsters = {}
local lastSeekNoticeTime = 0 -- Đếm thời gian cho Seek (giới hạn 3 phút)

local function triggerSmartMonsterNotice(monsterObj, rawMonsterName)
    if not Flags.MonsterNotify then return end
    if notifiedMonsters[monsterObj] then return end

    local nameLower = rawMonsterName:lower()

    -- QUẢN LÝ COOLDOWN DÀNH RIÊNG CHO SEEK (TỐI ĐA 1 LẦN/3 PHÚT)
    if nameLower:find("seek") then
        local currentTime = tick()
        if currentTime - lastSeekNoticeTime < 180 then
            return -- Đang trong 3 phút chờ, không phát thông báo lặp lại
        end
        lastSeekNoticeTime = currentTime
    end

    notifiedMonsters[monsterObj] = true

    local actionText = MonsterAdvice[rawMonsterName] or "Cẩn thận quái vật này!"

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🚨 CẢNH BÁO QUÁI VẬT!",
            Text = rawMonsterName .. " đã xuất hiện! " .. actionText,
            Duration = 5
        })
    end)

    -- Theo dõi khi quái vật bị xóa khỏi Workspace
    monsterObj.AncestryChanged:Connect(function(_, parent)
        if not parent then
            notifiedMonsters[monsterObj] = nil
            
            -- ĐẶC BIỆT: Nhắc nhở riêng khi Ambush đã đi hẳn
            if nameLower:find("ambush") and Flags.MonsterNotify then
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "✅ AN TOÀN!",
                        Text = "Ambush đã đi rồi!",
                        Duration = 4
                    })
                end)
            end
        end
    end)
end

local function processObject(obj)
    pcall(function()
        if not obj then return end
        local nameLower = obj.Name:lower()

        -- ❌ BỎ QUA HOÀN TOÀN TẤT CẢ TRANH MẮT, VẬT TRANG TRÍ HOẶC SEEK_EYES
        if nameLower:find("painting") or nameLower:find("frame") or nameLower:find("eyes_seek") or nameLower:find("seek_eyes") or nameLower:find("prop") or nameLower:find("decal") then
            return
        end

        -- 1. ESP Cửa
        if (obj.Name == "Door" or nameLower == "door") and obj:IsA("Model") and not obj:FindFirstChild("Mote_ESP_ESPDoor", true) then
            local doorPart = obj:FindFirstChild("Door") or obj:FindFirstChildWhichIsA("BasePart")
            if doorPart then createBillboard(doorPart, "🚪 Cửa", ESPColors.Door, "ESPDoor") end
        end

        -- 2. ESP Cần Gạt / Breaker / Switch
        if (nameLower:find("lever") or nameLower:find("breaker") or nameLower:find("switch") or nameLower:find("electric")) and not obj:FindFirstChild("Mote_ESP_ESPLever", true) then
            local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if targetPart then createBillboard(targetPart, "🕹️ Cần Gạt / Cầu Chì", ESPColors.Lever, "ESPLever") end
        end

        -- 3. ESP Rương Đồ
        if (nameLower:find("chest") or nameLower:find("box")) and not nameLower:find("drawer") and not nameLower:find("cabinet") and not obj:FindFirstChild("Mote_ESP_ESPChest", true) then
            local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if targetPart then createBillboard(targetPart, "📦 Rương Đồ", ESPColors.Chest, "ESPChest") end
        end

        -- 4. NHẬN DIỆN VÀ CẢNH BÁO TẤT CẢ CÁC LOẠI QUÁI VẬT
        local detectedMonsterName = nil

        if nameLower:find("rushmoving") or nameLower == "rush" then detectedMonsterName = "Rush"
        elseif nameLower:find("ambushmoving") or nameLower == "ambush" then detectedMonsterName = "Ambush"
        elseif nameLower:find("seekmoving") or (nameLower == "seek" and obj:IsA("Model")) then detectedMonsterName = "Seek"
        elseif nameLower == "screech" then detectedMonsterName = "Screech"
        elseif nameLower == "eyes" then detectedMonsterName = "Eyes"
        elseif nameLower == "halt" then detectedMonsterName = "Halt"
        elseif nameLower:find("figurerig") or nameLower == "figure" then detectedMonsterName = "Figure"
        elseif nameLower == "hide" then detectedMonsterName = "Hide"
        elseif nameLower == "jack" then detectedMonsterName = "Jack"
        elseif nameLower:find("dupe") then detectedMonsterName = "Dupe"
        elseif nameLower:find("timothy") or nameLower:find("spider") then detectedMonsterName = "Timothy"
        elseif nameLower == "dread" then detectedMonsterName = "Dread"
        elseif nameLower == "a60" or nameLower == "a-60" then detectedMonsterName = "A-60"
        elseif nameLower == "a120" or nameLower == "a-120" then detectedMonsterName = "A-120"
        end

        if detectedMonsterName then
            local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if targetPart and not obj:FindFirstChild("Mote_ESP_ESPMonster", true) then
                createBillboard(targetPart, "⚠️ " .. detectedMonsterName, ESPColors.Monster, "ESPMonster")
            end
            triggerSmartMonsterNotice(obj, detectedMonsterName)
        end

        -- 5. ESP Vật Phẩm (Chìa Khóa, Đèn, Sách, Cầu Trì)
        if ImportantItems[obj.Name] and not obj:FindFirstChild("Mote_ESP_ESPItems", true) then
            local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if targetPart then createBillboard(targetPart, ImportantItems[obj.Name], ESPColors.Items, "ESPItems") end
        end
    end)
end

for _, obj in ipairs(Workspace:GetDescendants()) do processObject(obj) end
Workspace.DescendantAdded:Connect(processObject)

--------------------------------------------------
-- AUTO LOOT & CỬA
--------------------------------------------------
local function isPromptValid(prompt)
    if not prompt or not prompt.Parent or not prompt.Enabled then return false end
    local parent = prompt.Parent
    if parent:GetAttribute("Opened") == true or parent:GetAttribute("State") == true or parent:GetAttribute("Open") == true then return false end
    return true
end

local function scanAndClassifyObject(prompt)
    if not isPromptValid(prompt) then return nil end
    local parent = prompt.Parent
    local parentName = parent.Name:lower()

    if parentName:find("lock") or parentName:find("door") then
        if prompt.ActionText:lower():find("unlock") or prompt.ActionText:lower():find("mở") then return "DOOR_LOCKED" end
    end
    if parentName:find("chest") or parentName:find("gold") or prompt.ActionText:lower():find("take") or prompt.ActionText:lower():find("lấy") then
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
                if item:IsA("Tool") and (item.Name:find("Key") or item.Name:find("KeyObtain") or item.Name:find("SkeletonKey")) then hasKey = true break end
            end
            if not hasKey and LocalPlayer:FindFirstChild("Backpack") then
                for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if item:IsA("Tool") and (item.Name:find("Key") or item.Name:find("KeyObtain") or item.Name:find("SkeletonKey")) then hasKey = true break end
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
                            elseif category == "LOOT_ITEM" and dist <= prompt.MaxActivationDistance then
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
-- ANTI-AFK & FULLBRIGHT
--------------------------------------------------
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if Flags.AntiAFK then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end
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
-- GIAO DIỆN MOTE HUB (BETA 2.5)
--------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoteHub_Beta25"
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
mainFrame.Size = UDim2.new(0, 520, 0, 280); mainFrame.Position = UDim2.new(0.25, 0, 0.3, 0); mainFrame.AnchorPoint = Vector2.new(0.5, 0.5); mainFrame.BackgroundColor3 = Themes.YellowBlack.FrameBg; mainFrame.BorderSizePixel = 0; mainFrame.Visible = false; mainFrame.ClipsDescendants = true; mainFrame.Parent = screenGui
makeDraggable(mainFrame)

local frameCorner = Instance.new("UICorner"); frameCorner.CornerRadius = UDim.new(0, 10); frameCorner.Parent = mainFrame
local frameStroke = Instance.new("UIStroke"); frameStroke.Color = Themes.YellowBlack.Accent; frameStroke.Thickness = 2; frameStroke.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 36); titleLabel.BackgroundColor3 = Themes.YellowBlack.HeaderBg; titleLabel.TextColor3 = Themes.YellowBlack.Accent; titleLabel.Text = "   MOTE HUB BETA 2.5"; titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextSize = 14; titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.Parent = mainFrame
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

--------------------------------------------------
-- TẠO TOGGLE VÀ SLIDER
--------------------------------------------------
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

--------------------------------------------------
-- CONTROL BUTTONS
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
-- NỘI DUNG TẤT CẢ TABS
--------------------------------------------------
-- TAB 1: MAIN
createToggleSwitch(pages[1], Translations[Flags.Language].AntiAFK, "AntiAFK", 5)
createToggleSwitch(pages[1], Translations[Flags.Language].MonsterNotify, "MonsterNotify", 40)
createToggleSwitch(pages[1], Translations[Flags.Language].Fullbright, "SmartFullbright", 75)
createSlider(pages[1], "  └ Độ Sáng", 0, 100, Flags.FullbrightIntensity, 110, function(val) Flags.FullbrightIntensity = val end)
createToggleSwitch(pages[1], Translations[Flags.Language].AutoLoot, "AutoLootAndDoor", 155)

-- TAB 2: ESP
createToggleSwitch(pages[2], "🟢 ESP Cửa (Door)", "ESPDoor", 5)
createToggleSwitch(pages[2], "🔵 ESP Vật Phẩm (Sách, Cầu Trì, Items)", "ESPItems", 40)
createToggleSwitch(pages[2], "🔴 ESP Quái Vật (Bao gồm Seek real)", "ESPMonster", 75)
createToggleSwitch(pages[2], "🟡 ESP Cần Gạt / Breaker Box", "ESPLever", 110)
createToggleSwitch(pages[2], "🟣 ESP Rương Đồ (Chest)", "ESPChest", 145)
createToggleSwitch(pages[2], "🟠 ESP Người Chơi (Full Highlight, Box, Tracer)", "ESPPlayer", 180)

-- TAB 3: THỬ NGHIỆM
createToggleSwitch(pages[3], Translations[Flags.Language].NoClip, "NoClip", 5)
createToggleSwitch(pages[3], Translations[Flags.Language].Jump, "DoorsJump", 40, function(st) jumpButtonUI.Visible = st end)
createToggleSwitch(pages[3], Translations[Flags.Language].Speed, "SpeedHack", 75)
createSlider(pages[3], "  └ Tốc Độ (1.0x - 4.0x)", 1.0, 4.0, Flags.SpeedMultiplier, 110, function(val) Flags.SpeedMultiplier = val end)
createToggleSwitch(pages[3], Translations[Flags.Language].ThirdPerson, "ThirdPerson", 155)
createToggleSwitch(pages[3], Translations[Flags.Language].FlyCarpet, "FlyCarpet", 190, function(st) flyControlFrame.Visible = st end)

-- TAB 4: INFO
local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(0.96, 0, 0.9, 0); infoLbl.Position = UDim2.new(0.02, 0, 0.05, 0); infoLbl.BackgroundTransparency = 1; infoLbl.TextColor3 = Color3.fromRGB(255, 255, 255); infoLbl.Font = Enum.Font.SourceSansBold; infoLbl.TextYAlignment = Enum.TextYAlignment.Top; infoLbl.TextXAlignment = Enum.TextXAlignment.Left; infoLbl.Parent = pages[4]
registerTextLabel(infoLbl)

local function updateInfoText()
    local lang = Translations[Flags.Language]
    infoLbl.Text = string.format("👑 MOTE HUB SYSTEM INFO 👑\n\n• %s\n• %s\n• %s", lang.Author, lang.Facebook, lang.Version)
end
updateInfoText()

-- TAB 5: SETTINGS
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

local function refreshLanguage()
    for i, name in ipairs(tabNames) do tabs[i].Text = Translations[Flags.Language][name] or name end
    updateInfoText(); themeLbl.Text = Translations[Flags.Language].ThemeTitle; langLbl.Text = Translations[Flags.Language].LangTitle
end

btnVie.MouseButton1Click:Connect(function() Flags.Language = "VIE"; refreshLanguage() end)
btnEng.MouseButton1Click:Connect(function() Flags.Language = "ENG"; refreshLanguage() end)

createSlider(pages[5], Translations[Flags.Language].FontSizeTitle, 10, 18, Flags.TextSize, 120, function(val)
    Flags.TextSize = math.floor(val)
    updateAllTextSizes()
end)

--------------------------------------------------
-- MỞ / TẮT MENU
--------------------------------------------------
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
        Title = "MOTE HUB BETA 2.5",
        Text = "Đã cập nhật cảnh báo TẤT CẢ Quái Vật & Lọc Bỏ Tranh Seek!",
        Duration = 5
    })
end)
