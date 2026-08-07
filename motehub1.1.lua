-- ==================================================
-- MOTEHUB V2 FINAL - COMPLETE SCRIPT
-- ==================================================

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- Bảng trạng thái Bật/Tắt tính năng
local Flags = {
    AntiAFK = true,
    DoubleJump = false,
    AirWalk = false,
    ESP = false
}

--------------------------------------------------
-- 1. TÍNH NĂNG ANTI-AFK (CHỐNG KICK TREO MÁY)
--------------------------------------------------
LocalPlayer.Idled:Connect(function()
    if Flags.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

--------------------------------------------------
-- 2. TÍNH NĂNG DOUBLE JUMP (NHẢY 2 LẦN)
--------------------------------------------------
local canDoubleJump = false
local hasDoubleJumped = false

local function setupDoubleJump(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Freefall then
            canDoubleJump = true
        elseif newState == Enum.HumanoidStateType.Landed then
            canDoubleJump = false
            hasDoubleJumped = false
        end
    end)
end

if LocalPlayer.Character then setupDoubleJump(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupDoubleJump)

UserInputService.JumpRequest:Connect(function()
    if Flags.DoubleJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        if canDoubleJump and not hasDoubleJumped and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            hasDoubleJumped = true
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

--------------------------------------------------
-- 3. TÍNH NĂNG AIR WALK (TỐI ƯU 1 SÀN DUY NHẤT)
--------------------------------------------------
-- Khởi tạo duy nhất 1 sàn tàng hình bên ngoài vòng lặp
local airPlatform = Instance.new("Part")
airPlatform.Name = "MoteHub_AirWalkPlatform"
airPlatform.Size = Vector3.new(7, 1, 7)
airPlatform.Transparency = 1 -- Tàng hình (Đổi thành 0.5 nếu muốn thấy sàn)
airPlatform.Anchored = true
airPlatform.CanCollide = true

local lockedY = nil -- Lưu độ cao cố định để không bị bay lên

RunService.RenderStepped:Connect(function()
    if Flags.AirWalk and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = LocalPlayer.Character.HumanoidRootPart
        
        -- Lấy độ cao cố định ngay dưới chân khi bắt đầu bật Air Walk
        if not lockedY then
            lockedY = rootPart.Position.Y - 3.2
            airPlatform.Parent = workspace
        end
        
        -- Chỉ cập nhật vị trí X, Z theo nhân vật (giữ nguyên độ cao Y)
        airPlatform.CFrame = CFrame.new(rootPart.Position.X, lockedY, rootPart.Position.Z)
    else
        -- Tắt Air Walk -> Xóa sàn và reset độ cao
        lockedY = nil
        airPlatform.Parent = nil
    end
end)

--------------------------------------------------
-- 4. TÍNH NĂNG ESP PLAYER (MÀU VIỀN + TÊN + KHOẢNG CÁCH)
--------------------------------------------------
local function createESP(player)
    if player == LocalPlayer then return end

    local function applyESP(character)
        if not character then return end
        local head = character:WaitForChild("Head", 5)
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if not head or not rootPart then return end

        -- Highlight (Màu viền)
        local highlight = character:FindFirstChild("MoteHub_Highlight") or Instance.new("Highlight")
        highlight.Name = "MoteHub_Highlight"
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(0, 255, 128)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
        highlight.FillTransparency = 0.6
        highlight.Enabled = Flags.ESP
        highlight.Parent = character

        -- NameTag (Hiển thị tên & khoảng cách trên đầu)
        local billboard = head:FindFirstChild("MoteHub_NameTag") or Instance.new("BillboardGui")
        billboard.Name = "MoteHub_NameTag"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = Flags.ESP

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
            if character and character:Parent() and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                highlight.Enabled = Flags.ESP
                billboard.Enabled = Flags.ESP
                if Flags.ESP then
                    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                    local distance = math.floor((myPos - rootPart.Position).Magnitude)
                    textLabel.Text = string.format("%s\n[%d studs]", player.DisplayName, distance)
                end
            else
                connection:Disconnect()
            end
        end)
    end

    if player.Character then applyESP(player.Character) end
    player.CharacterAdded:Connect(applyESP)
end

for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

--------------------------------------------------
-- 5. GIAO DIỆN MENU (GUI MENU)
--------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoteHub_GUI"
screenGui.ResetOnSpawn = false

pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Nút bấm ẩn/hiện Menu
local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Name = "ToggleMenuBtn"
toggleMenuBtn.Size = UDim2.new(0, 80, 0, 35)
toggleMenuBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleMenuBtn.TextColor3 = Color3.fromRGB(0, 255, 128)
toggleMenuBtn.Text = "MoteHub"
toggleMenuBtn.Font = Enum.Font.SourceSansBold
toggleMenuBtn.TextSize = 14
toggleMenuBtn.Parent = screenGui

-- Bảng khung Menu chính
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 230)
mainFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
titleLabel.Text = "MoteHub V2 Menu"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

-- Hàm tạo các nút Toggle Bật/Tắt
local function createToggleButton(name, flagName, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 35)
    btn.Position = UDim2.new(0.075, 0, 0, posY)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = mainFrame

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

-- Khởi tạo nút bấm cho Menu
createToggleButton("Anti-AFK", "AntiAFK", 45)
createToggleButton("Double Jump", "DoubleJump", 90)
createToggleButton("Air Walk", "AirWalk", 135)
createToggleButton("ESP Player", "ESP", 180)

-- Sự kiện ẩn/hiện Menu
toggleMenuBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

StarterGui:SetCore("SendNotification", {
    Title = "MoteHub V2",
    Text = "Kích hoạt thành công! Bấm nút MoteHub để mở Menu.",
    Duration = 4
})
