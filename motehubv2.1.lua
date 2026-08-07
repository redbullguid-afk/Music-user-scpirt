-- ==================================================
-- MOTEHUB V5.0 - ALL-IN-ONE MENU EDITION
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

-- Bảng trạng thái tổng hợp
local Flags = {
    AntiAFK = true,
    FlyCarpet = false,
    Fullbright = false,
    ESPPlayer = false,
    ESPMonster = false,
    ESPItems = false,
    MonsterNotify = true,
    SpeedHack = false
}

local SpeedMultiplier = 1.5

--------------------------------------------------
-- 1. HỆ THỐNG BỔ TRỢ (MAIN UTILITIES)
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
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if Flags.SpeedHack then
                humanoid.WalkSpeed = 16 * SpeedMultiplier
            elseif humanoid.WalkSpeed ~= 16 then
                humanoid.WalkSpeed = 16
            end
        end
    end
end)

-- Fullbright (Nhìn đêm)
task.spawn(function()
    while task.wait(0.2) do
        if Flags.Fullbright then
            pcall(function()
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 1000000
                Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)

                for _, v in ipairs(Lighting:GetChildren()) do
                    if v:IsA("Atmosphere") or v:IsA("PostEffect") then
                        v.Enabled = false
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------
-- 2. HỆ THỐNG ESP & CẢNH BÁO
--------------------------------------------------
local ValidItems = {
    ["KeyObtain"] = "Chìa khóa", ["Key"] = "Chìa khóa", ["MasterKey"] = "Chìa khóa vạn năng",
    ["Flashlight"] = "Đèn pin", ["Candle"] = "Nến", ["Crucifix"] = "Thánh giá",
    ["Lockpick"] = "Móc khóa", ["Bandage"] = "Băng gạc", ["Vitamins"] = "Vitamin",
    ["Battery"] = "Pin", ["Shears"] = "Kéo", ["HerbOfViridis"] = "Thảo dược",
    ["ShakableLight"] = "Đèn lắc", ["Bulklight"] = "Đèn bão"
}

local ValidMonsters = {
    ["RushMoving"] = "Rush", ["AmbushMoving"] = "Ambush", ["FigureRig"] = "Figure",
    ["SeekMoving"] = "Seek", ["Seek"] = "Seek", ["Screech"] = "Screech",
    ["Eyes"] = "Eyes", ["Halt"] = "Halt", ["Snare"] = "Snare",
    ["A60"] = "A-60", ["A120"] = "A-120", ["A90"] = "A-90",
    ["Giggle"] = "Giggle", ["Grumble"] = "Grumble", ["Dread"] = "Dread"
}

-- ESP Người chơi
local function applyPlayerESP(player)
    if player == LocalPlayer then return end
    local function setupCharacter(character)
        if not character then return end
        local head = character:WaitForChild("Head", 5)
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if not head or not rootPart then return end

        local highlight = character:FindFirstChild("MoteHub_PlayerHighlight") or Instance.new("Highlight")
        highlight.Name = "MoteHub_PlayerHighlight"
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(0, 255, 128)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
        highlight.FillTransparency = 0.6
        highlight.Parent = character

        local billboard = head:FindFirstChild("MoteHub_PlayerTag") or Instance.new("BillboardGui")
        billboard.Name = "MoteHub_PlayerTag"
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

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if character and character.Parent and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myRoot = LocalPlayer.Character.HumanoidRootPart
                highlight.Enabled = Flags.ESPPlayer
                billboard.Enabled = Flags.ESPPlayer
                if Flags.ESPPlayer then
                    local distance = math.floor((myRoot.Position - rootPart.Position).Magnitude)
                    textLabel.Text = string.format("%s\n[%d studs]", player.DisplayName, distance)
                end
            else
                if connection then connection:Disconnect() end
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

-- Kiểm tra xem vật phẩm có nằm trong tủ chưa mở hay không
local function isInsideClosedContainer(obj)
    local current = obj.Parent
    while current and current ~= Workspace do
        local name = current.Name:lower()
        if name:find("drawer") or name:find("chest") or name:find("closet") or name:find("desk") then
            local openVal = current:FindFirstChild("Opened") or current:FindFirstChild("Open")
            if openVal and openVal:IsA("BoolValue") and not openVal.Value then
                return true
            elseif not openVal then
                return true
            end
        end
        current = current.Parent
    end
    return false
end

-- ESP Vật phẩm
local function applyItemESP(obj)
    if not (obj:IsA("Model") or obj:IsA("Tool") or obj:IsA("BasePart")) then return end
    local displayName = ValidItems[obj.Name]
    if not displayName then return end
    if obj.Parent and ValidItems[obj.Parent.Name] then return end

    if isInsideClosedContainer(obj) then
        local oldHL = obj:FindFirstChild("MoteHub_ItemESP")
        if oldHL then oldHL.Enabled = false end
        return
    end

    local highlight = obj:FindFirstChild("MoteHub_ItemESP") or Instance.new("Highlight")
    highlight.Name = "MoteHub_ItemESP"
    highlight.Adornee = obj
    highlight.FillColor = Color3.fromRGB(0, 200, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Enabled = Flags.ESPItems
    highlight.Parent = obj

    local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
    if targetPart then
        local billboard = targetPart:FindFirstChild("MoteHub_ItemTag") or Instance.new("BillboardGui")
        billboard.Name = "MoteHub_ItemTag"
        billboard.Adornee = targetPart
        billboard.Size = UDim2.new(0, 120, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 1.5, 0)
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
end

-- ESP Quái vật & Cảnh báo
local notifiedMonsters = {}

local function applyMonsterESP(obj)
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return end
    local displayName = nil
    for name, label in pairs(ValidMonsters) do
        if obj.Name == name or obj.Name:find(name) then
            displayName = label
            break
        end
    end

    if not displayName then return end
    if obj.Parent and ValidMonsters[obj.Parent.Name] then return end

    if Flags.MonsterNotify and not notifiedMonsters[obj] then
        notifiedMonsters[obj] = true
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "⚠️ CẢNH BÁO QUÁI VẬT!",
                Text = displayName .. " vừa xuất hiện! Hãy trốn ngay!",
                Duration = 5
            })
        end)
    end

    local highlight = obj:FindFirstChild("MoteHub_MonsterESP") or Instance.new("Highlight")
    highlight.Name = "MoteHub_MonsterESP"
    highlight.Adornee = obj
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.3
    highlight.Enabled = Flags.ESPMonster
    highlight.Parent = obj

    local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
    if targetPart then
        local billboard = targetPart:FindFirstChild("MoteHub_MonsterTag") or Instance.new("BillboardGui")
        billboard.Name = "MoteHub_MonsterTag"
        billboard.Adornee = targetPart
        billboard.Size = UDim2.new(0, 140, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = Flags.ESPMonster

        local label = billboard:FindFirstChild("TextLabel") or Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 50, 50)
        label.TextStrokeTransparency = 0
        label.TextSize = 13
        label.Font = Enum.Font.SourceSansBold
        label.Text = "⚠️ " .. displayName
        label.Parent = billboard
        billboard.Parent = targetPart
    end
end

-- Vòng lặp quét thế giới
task.spawn(function()
    local function processObject(obj)
        pcall(function()
            applyItemESP(obj)
            applyMonsterESP(obj)
        end)
    end

    Workspace.DescendantAdded:Connect(processObject)
    
    local function setupCameraListener(cam)
        if cam then
            cam.DescendantAdded:Connect(processObject)
            for _, child in ipairs(cam:GetDescendants()) do processObject(child) end
        end
    end
    setupCameraListener(Workspace.CurrentCamera)
    Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        setupCameraListener(Workspace.CurrentCamera)
    end)

    while task.wait(0.8) do
        if Flags.ESPMonster or Flags.ESPItems then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if Flags.ESPItems then applyItemESP(obj) end
                if Flags.ESPMonster then applyMonsterESP(obj) end
            end
        end
    end
end)

--------------------------------------------------
-- 3. GIAO DIỆN GUI MENU TỔNG HỢP
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
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Nút tròn mở Menu
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

-- Khung Menu Chính
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 320)
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
titleLabel.Text = "MOTE HUB - UNIFIED"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 15
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleLabel

-- Thanh chuyển Tab
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0.9, 0, 0, 30)
tabContainer.Position = UDim2.new(0.05, 0, 0.13, 0)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local mainTabBtn = Instance.new("TextButton")
mainTabBtn.Size = UDim2.new(0.48, 0, 1, 0)
mainTabBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 85)
mainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mainTabBtn.Text = "Bổ Trợ"
mainTabBtn.Font = Enum.Font.SourceSansBold
mainTabBtn.TextSize = 14
mainTabBtn.Parent = tabContainer

local espTabBtn = Instance.new("TextButton")
espTabBtn.Size = UDim2.new(0.48, 0, 1, 0)
espTabBtn.Position = UDim2.new(0.52, 0, 0, 0)
espTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
espTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
espTabBtn.Text = "ESP & Ra-đa"
espTabBtn.Font = Enum.Font.SourceSansBold
espTabBtn.TextSize = 14
espTabBtn.Parent = tabContainer

-- Trang nội dung
local mainTabPage = Instance.new("Frame")
mainTabPage.Size = UDim2.new(1, 0, 0.75, 0)
mainTabPage.Position = UDim2.new(0, 0, 0.24, 0)
mainTabPage.BackgroundTransparency = 1
mainTabPage.Visible = true
mainTabPage.Parent = mainFrame

local espTabPage = Instance.new("Frame")
espTabPage.Size = UDim2.new(1, 0, 0.75, 0)
espTabPage.Position = UDim2.new(0, 0, 0.24, 0)
espTabPage.BackgroundTransparency = 1
espTabPage.Visible = false
espTabPage.Parent = mainFrame

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

-- Thêm nút tab Bổ Trợ
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
        speedBtn.Text = string.format("Speed Hack: BẬT (%.1fx)", SpeedMultiplier)
    else
        speedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        speedBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        speedBtn.Text = "Speed Hack: TẮT"
    end
end

speedBtn.MouseButton1Click:Connect(function()
    if not Flags.SpeedHack then
        Flags.SpeedHack = true
        SpeedMultiplier = 1.5
    elseif SpeedMultiplier == 1.5 then
        SpeedMultiplier = 2.0
    else
        Flags.SpeedHack = false
    end
    updateSpeedUI()
end)
updateSpeedUI()

-- Thêm nút tab ESP
createToggleButton(espTabPage, "ESP Người Chơi", "ESPPlayer", 5)
createToggleButton(espTabPage, "ESP Quái Vật", "ESPMonster", 40)
createToggleButton(espTabPage, "ESP Vật Phẩm", "ESPItems", 75)
createToggleButton(espTabPage, "Cảnh Báo Quái", "MonsterNotify", 110)
createToggleButton(espTabPage, "Nhìn Bóng Tối", "Fullbright", 145)

-- Chuyển đổi TAB
mainTabBtn.MouseButton1Click:Connect(function()
    mainTabPage.Visible = true
    espTabPage.Visible = false
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 85)
    mainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    espTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    espTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

espTabBtn.MouseButton1Click:Connect(function()
    mainTabPage.Visible = false
    espTabPage.Visible = true
    espTabBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 85)
    espTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

circleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "MOTE HUB V5.0",
        Text = "Menu tổng hợp đã sẵn sàng!",
        Duration = 3
    })
end)
