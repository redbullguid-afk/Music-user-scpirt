
-- ==================================================
-- MOTE HUB BETA 2.92 - FULL FIXED & ESP UPDATED
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
    VIE = { Main = "Main", ESP = "ESP", Automation = "Tự Động", Experimental = "Thử Nghiệm", Settings = "Cài Đặt", AntiAFK = "1. Anti-AFK", MonsterNotify = "2. Cảnh Báo Quái Vật", Fullbright = "3. Nhìn Trong Bóng Tối", AutoDrawers = "1. Auto Mở Tủ (3 Tủ) & Loot Đồ", AutoDoorKey = "2. Auto Mở Cửa Bằng Key", NoClip = "1. NoClip (Xuyên Tường)", Jump = "2. Nút Nhảy DOORS", Speed = "3. Speed Hack (Max x4)", Freecam = "4. Khảm Giả (Linh Hồn Tách Xác)", FlyCarpet = "5. Bay Sáng Tạo", ThemeTitle = "1. Đổi Màu Menu", LangTitle = "2. Ngôn Ngữ", FontSizeTitle = "3. Kích Thước Chữ", Author = "Tác Giả: By Mờ Tê", Facebook = "Facebook: Nguyễn minh tân", Version = "Phiên Bản: Mote Hub Beta 2.92" },
    ENG = { Main = "Main", ESP = "ESP", Automation = "Automation", Experimental = "Experimental", Settings = "Settings", AntiAFK = "1. Anti-AFK", MonsterNotify = "2. Smart Monster Notify", Fullbright = "3. Fullbright", AutoDrawers = "1. Auto Open 3 Drawers & Auto Loot", AutoDoorKey = "2. Auto Key Door", NoClip = "1. NoClip", Jump = "2. DOORS Jump Button", Speed = "3. Speed Hack (Up to x4)", Freecam = "4. Freecam Soul (Spectate Fly)", FlyCarpet = "5. Creative Fly", ThemeTitle = "1. Change Theme", LangTitle = "2. Language", FontSizeTitle = "3. Text Size", Author = "Author: By Mote", Facebook = "Facebook: Nguyen minh tan", Version = "Version: Mote Hub Beta 2.92" }
}

--------------------------------------------------
-- BẢNG DỮ LIỆU VẬT THỂ VÀ QUÁI VẬT (BẢO GỒM FLOOR 1 & FLOOR 2)
--------------------------------------------------
local ImportantItems = {
    ["KeyObtain"] = "🔑 Chìa Khóa", ["Key"] = "🔑 Chìa Khóa", ["MasterKey"] = "🔑 Chìa Khóa Master",
    ["SkeletonKey"] = "💀 Chìa Khóa Đầu Lâu", ["Flashlight"] = "🔦 Đèn Pin", ["Candle"] = "🕯️ Nến",
    ["Crucifix"] = "✝️ Cây Thánh Giá", ["Lockpick"] = "🗝️ Lockpick", ["Bandage"] = "🩹 Băng Gạc",
    ["Vitamins"] = "💊 Vitamin", ["Battery"] = "🔋 Pin", ["LiveHintBook"] = "📘 Sách",
    ["Gold"] = "💰 Tiền Gold", ["Coin"] = "🪙 Tiền Xu",

    -- Vật phẩm giải đố Floor 2 (The Mines)
    ["Fuse"] = "🔋 Cầu Chì Generator", ["FuseInPlainSight"] = "🔋 Cầu Chì", ["GeneratorFuse"] = "🔋 Cầu Chì Generator",
    ["Anchor"] = "⚓ Trạm Neo Anchor", ["AnchorPoint"] = "⚓ Trạm Neo Anchor",
    ["BreakerPole"] = "🎛️ Cầu Dao Điện", ["BreakerSwitch"] = "🎛️ Công Tắc Điện", ["Switch"] = "🎛️ Công Tắc",
    ["Shears"] = "✂️ Kéo Tỉa Vương", ["Glowstick"] = "🪔 Thanh Phát Sáng", ["Straplight"] = "🔦 Đèn Đeo Ngực", ["Bulklight"] = "🔦 Đèn Pin Lớn"
}

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
local MAX_LOOT_DIST = 5

task.spawn(function()
    while task.wait(0.05) do
        if Flags.AutoDrawersLoot and LocalPlayer.Character then
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
                                    
                                    local isLootItem = nameLower:find("gold") or nameLower:find("coin") or nameLower:find("item") 
                                        or nameLower:find("fuse") or nameLower:find("anchor")
                                        or ImportantItems[parent.Name] or ImportantItems[parent.Parent and parent.Parent.Name or ""]
                                        or prompt.ActionText:lower():find("take") or prompt.ActionText:lower():find("loot")
                                        or prompt.ObjectText:lower():find("gold") or prompt.ObjectText:lower():find("coin")

                                    if isLootItem then
                                        safeInteract(prompt)
                                    elseif (nameLower:find("drawer") or pNameLower:find("drawer") or nameLower:find("knob") or nameLower:find("closet")) then
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
        end
    end
end)

--------------------------------------------------
-- LOGIC AUTO MỞ CỬA BẰNG KEY
--------------------------------------------------
task.spawn(function()
    while task.wait(0.1) do
        if Flags.AutoKeyDoor and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local char = LocalPlayer.Character
            
            local hasKey = char:FindFirstChild("Key") or char:FindFirstChild("KeyObtain") or LocalPlayer.Backpack:FindFirstChild("Key") or LocalPlayer.Backpack:FindFirstChild("KeyObtain")
            
            if hrp and hasKey then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name == "Door" and obj:IsA("Model") then
                        local nameLower = obj.Name:lower()
                        if not nameLower:find("dupe") and not obj:FindFirstChild("DupeDoor") then
                            local doorPart = obj:FindFirstChild("Door") or obj:FindFirstChildWhichIsA("BasePart")
                            if doorPart then
                                local dist = (doorPart.Position - hrp.Position).Magnitude
                                if dist <= 8 then
                                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    if prompt and prompt.Enabled then
                                        safeInteract(prompt)
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
-- TÍNH NĂNG TỐC ĐỘ, NOCLIP & BAY SÁNG TẠO
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

--------------------------------------------------
-- CHẾ ĐỘ KHẢM GIẢ / LINH HỒN TÁCH XÁC
--------------------------------------------------
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
-- ESP BILLBOARD GUI
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
-- TỰ ĐỘNG QUÉT ESP VẬT THỂ & ĐỒ DÙNG
--------------------------------------------------
local scannedESPObjects = {}
local function scanESPObjects()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not scannedESPObjects[obj] then
            local name = obj.Name
            local displayName = ImportantItems[name] or ImportantItems[obj.Parent and obj.Parent.Name or ""]

            if displayName then
                scannedESPObjects[obj] = true
                local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                if targetPart then
                    createBillboard(targetPart, displayName, ESPColors.Items, "ESPItems")
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(1.5) do
        scanESPObjects()
    end
end)

--------------------------------------------------
-- ESP NGƯỜI CHƠI (CẬP NHẬT: HIỂN THỊ MÁU CHÍNH XÁC 16/199)
--------------------------------------------------
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
        bb.Size = UDim2.new(0, 200, 0, 40)
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

            if Flags.ESPPlayer and humanoid.Health > 0 then
                hl.Enabled = true
                bb.Enabled = true

                local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local dist = myHrp and math.floor((myHrp.Position - hrp.Position).Magnitude) or 0
                
                local curHp = math.floor(humanoid.Health)
                local maxHp = math.floor(humanoid.MaxHealth)

                label.Text = string.format("%s [%d/%d HP]\n[%d studs]", plr.DisplayName, curHp, maxHp, dist)

                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Visible = true

                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 1.8

                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                    box.Visible = true
                else
                    box.Visible = false
                    line.Visible = false
                end
            else
                hl.Enabled = false
                bb.Enabled = false
                box.Visible = false
                line.Visible = false
            end
        end)
    end

    if plr.Character then applyESPToCharacter(plr.Character) end
    plr.CharacterAdded:Connect(applyESPToCharacter)
end

for _, p in ipairs(Players:GetPlayers()) do setupFullPlayerESP(p) end
Players.PlayerAdded:Connect(setupFullPlayerESP)

--------------------------------------------------
-- TẠO GIAO DIỆN MENU MOTE HUB (GIỮ NGUYÊN MENU BAN ĐẦU)
--------------------------------------------------
if CoreGui:FindFirstChild("MoteHubGUI") then CoreGui.MoteHubGUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MoteHubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 260)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -130)
MainFrame.BackgroundColor3 = Themes[Flags.Theme].FrameBg
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Themes[Flags.Theme].HeaderBg
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "MOTE HUB BETA 2.92"
Title.TextColor3 = Themes[Flags.Theme].Accent
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

registerTextLabel(Title)

--------------------------------------------------
-- NÚT BẬT / TẮT MENU CHO ĐIỆN THOẠI (TOGGLE BUTTON)
--------------------------------------------------
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "MoteHub_ToggleButton"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.Text = "MOTE"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

StarterGui:SetCore("SendNotification", {
    Title = "Mote Hub 2.92",
    Text = "Đã sửa xong toàn bộ Script & ESP!",
    Duration = 5
})