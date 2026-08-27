-- ==================================================
-- MOTE HUB BETA 2.92 - FULL FIXED UI & FEATURES
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

--------------------------------------------------
-- BẢNG DỮ LIỆU VẬT THỂ VÀ QUÁI VẬT (FLOOR 1 & FLOOR 2)
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
                            if targetPart and (targetPart.Position - playerPos).Magnitude <= 5 then
                                local nameLower = parent.Name:lower()
                                local isLootItem = nameLower:find("gold") or nameLower:find("coin") or ImportantItems[parent.Name] or prompt.ActionText:lower():find("take")
                                if isLootItem then
                                    safeInteract(prompt)
                                elseif (nameLower:find("drawer") or nameLower:find("knob") or nameLower:find("closet")) and activeDrawersCount < 3 then
                                    activeDrawersCount = activeDrawersCount + 1
                                    task.spawn(function()
                                        safeInteract(prompt)
                                        task.wait(0.6)
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
                        local doorPart = obj:FindFirstChild("Door") or obj:FindFirstChildWhichIsA("BasePart")
                        if doorPart and (doorPart.Position - hrp.Position).Magnitude <= 8 then
                            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt and prompt.Enabled then safeInteract(prompt) end
                        end
                    end
                end
            end
        end
    end
end)

--------------------------------------------------
-- TỐC ĐỘ, NOCLIP & BAY
--------------------------------------------------
RunService.RenderStepped:Connect(function(dt)
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if Flags.SpeedHack and hrp and humanoid and humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0 then
            local extra = Flags.SpeedMultiplier - 1
            if extra > 0 then hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * (16 * extra) * dt) end
        end

        if Flags.NoClip then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end
end)

--------------------------------------------------
-- ESP BILLBOARD SYSTEM
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
-- QUÉT ESP VẬT THỂ
--------------------------------------------------
local scannedESPObjects = {}
task.spawn(function()
    while task.wait(1.5) do
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not scannedESPObjects[obj] then
                local name = obj.Name
                local displayName = ImportantItems[name] or ImportantItems[obj.Parent and obj.Parent.Name or ""]
                if displayName then
                    scannedESPObjects[obj] = true
                    local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                    if targetPart then createBillboard(targetPart, displayName, ESPColors.Items, "ESPItems") end
                end
            end
        end
    end
end)

--------------------------------------------------
-- ESP NGƯỜI CHƠI (CẬP NHẬT: HIỂN THỊ MÁU X/Y HP)
--------------------------------------------------
local function setupFullPlayerESP(plr)
    if plr == LocalPlayer then return end

    local function applyESPToCharacter(char)
        if not char then return end
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        local head = char:WaitForChild("Head", 5)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not hrp or not head or not humanoid then return end

        local hl = Instance.new("Highlight")
        hl.FillColor = ESPColors.Player
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.Parent = char

        local bb = Instance.new("BillboardGui")
        bb.Adornee = head
        bb.Size = UDim2.new(0, 200, 0, 40)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = true

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 13
        label.TextColor3 = ESPColors.Player
        label.Parent = bb
        bb.Parent = head

        local box = Drawing.new("Square")
        box.Visible = false; box.Color = ESPColors.Player; box.Thickness = 1.5

        local line = Drawing.new("Line")
        line.Visible = false; line.Color = ESPColors.Player; line.Thickness = 1.5

        local renderConnection
        renderConnection = RunService.RenderStepped:Connect(function()
            if not char or not char.Parent or not hrp or not hrp.Parent then
                hl:Destroy(); bb:Destroy(); box:Remove(); line:Remove()
                if renderConnection then renderConnection:Disconnect() end
                return
            end

            if Flags.ESPPlayer and humanoid.Health > 0 then
                hl.Enabled = true; bb.Enabled = true
                local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local dist = myHrp and math.floor((myHrp.Position - hrp.Position).Magnitude) or 0
                label.Text = string.format("%s [%d/%d HP]\n[%d studs]", plr.DisplayName, math.floor(humanoid.Health), math.floor(humanoid.MaxHealth), dist)

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
-- PHẦN DỰNG GIAO DIỆN MENU (UI GENERATOR - SỬA LỖI MÀN HÌNH ĐEN)
--------------------------------------------------
if CoreGui:FindFirstChild("MoteHubGUI") then CoreGui.MoteHubGUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MoteHubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 270)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -135)
MainFrame.BackgroundColor3 = Themes[Flags.Theme].FrameBg
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Header
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

-- Tab Navigation Left
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 100, 1, -45)
TabBar.Position = UDim2.new(0, 5, 0, 40)
TabBar.BackgroundColor3 = Themes[Flags.Theme].InnerBg
TabBar.Parent = MainFrame

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 6)
TabBarCorner.Parent = TabBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 4)
TabListLayout.Parent = TabBar

-- Display Area Right
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -115, 1, -45)
ContentArea.Position = UDim2.new(0, 110, 0, 40)
ContentArea.BackgroundColor3 = Themes[Flags.Theme].InnerBg
ContentArea.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 6)
ContentCorner.Parent = ContentArea

local Tabs = {}
local TabButtons = {}

local function createTab(name)
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Size = UDim2.new(1, -10, 1, -10)
    tabScroll.Position = UDim2.new(0, 5, 0, 5)
    tabScroll.BackgroundTransparency = 1
    tabScroll.ScrollBarThickness = 4
    tabScroll.Visible = false
    tabScroll.Parent = ContentArea

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 5)
    list.Parent = tabScroll

    Tabs[name] = tabScroll

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 30)
    tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 13
    tabBtn.Parent = TabBar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        for tName, tFrame in pairs(Tabs) do
            tFrame.Visible = (tName == name)
        end
        for bName, bBtn in pairs(TabButtons) do
            bBtn.BackgroundColor3 = (bName == name) and Themes[Flags.Theme].Accent or Color3.fromRGB(35, 35, 35)
            bBtn.TextColor3 = (bName == name) and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
        end
    end)

    TabButtons[name] = tabBtn
end

local function createToggle(tabName, text, flagName, callback)
    local parent = Tabs[tabName]
    if not parent then return end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 28)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.Parent = parent

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 4)
    fCorner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.Position = UDim2.new(1, -26, 0, 3)
    btn.BackgroundColor3 = Flags[flagName] and Themes[Flags.Theme].Accent or Color3.fromRGB(60, 60, 60)
    btn.Text = Flags[flagName] and "✓" or ""
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = frame

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 4)
    bCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        Flags[flagName] = not Flags[flagName]
        btn.BackgroundColor3 = Flags[flagName] and Themes[Flags.Theme].Accent or Color3.fromRGB(60, 60, 60)
        btn.Text = Flags[flagName] and "✓" or ""
        if callback then callback(Flags[flagName]) end
    end)
end

-- Dựng 5 Tab Giao diện
createTab("Main")
createTab("ESP")
createTab("Automation")
createTab("Experimental")
createTab("Settings")

-- Thêm các nút bấm Toggle vào các Tab
createToggle("Main", "1. Anti-AFK (Chống văng)", "AntiAFK")
createToggle("Main", "2. Cảnh Báo Quái Vật", "MonsterNotify")
createToggle("Main", "3. Nhìn Trong Bóng Tối", "SmartFullbright")

createToggle("ESP", "1. ESP Người Chơi [HP/Tracer]", "ESPPlayer")
createToggle("ESP", "2. ESP Vật Phẩm / Đồ Đạc", "ESPItems")
createToggle("ESP", "3. ESP Cửa (Doors)", "ESPDoor")
createToggle("ESP", "4. ESP Quái Vật", "ESPMonster")

createToggle("Automation", "1. Auto Mở Tủ & Loot Đồ", "AutoDrawersLoot")
createToggle("Automation", "2. Auto Mở Cửa Bằng Key", "AutoKeyDoor")

createToggle("Experimental", "1. NoClip (Xuyên Tường)", "NoClip")
createToggle("Experimental", "2. Speed Hack (Tăng Tốc)", "SpeedHack")

-- Mặc định hiển thị Tab Main
Tabs["Main"].Visible = true
TabButtons["Main"].BackgroundColor3 = Themes[Flags.Theme].Accent
TabButtons["Main"].TextColor3 = Color3.fromRGB(0, 0, 0)

--------------------------------------------------
-- NÚT BẬT / TẮT MENU TỰ ĐỘNG
--------------------------------------------------
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "MoteHub_ToggleButton"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.Text = "MOTE"
ToggleBtn.TextColor3 = Themes[Flags.Theme].Accent
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
    Text = "Menu đã hiển thị đầy đủ các nút chức năng!",
    Duration = 5
})