-- ==================================================
-- MOTEHUB SCRIPT - FULL FEATURES (+ AIR WALK)
-- ==================================================

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- Thông báo bắt đầu tải
StarterGui:SetCore("SendNotification", {
    Title = "MoteHub Script",
    Text = "Đang khởi tạo các tính năng...",
    Duration = 3
})

--------------------------------------------------
-- 1. TÍNH NĂNG ANTI-AFK (CHỐNG KICK TREO MÁY)
--------------------------------------------------
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    
    StarterGui:SetCore("SendNotification", {
        Title = "Anti-AFK",
        Text = "Đã tự động tương tác để tránh bị kick!",
        Duration = 3
    })
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

if LocalPlayer.Character then
    setupDoubleJump(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(setupDoubleJump)

UserInputService.JumpRequest:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        if canDoubleJump and not hasDoubleJumped and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            hasDoubleJumped = true
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

--------------------------------------------------
-- 3. TÍNH NĂNG AIR WALK (ĐI TRÊN KHÔNG TRUNG)
--------------------------------------------------
local airWalkPart = Instance.new("Part")
airWalkPart.Name = "MoteHub_AirWalkPlatform"
airWalkPart.Size = Vector3.new(6, 1, 6)
airWalkPart.Transparency = 1 -- Tàng hình (Đổi thành 0.5 nếu muốn thấy nền)
airWalkPart.Anchored = true
airWalkPart.CanCollide = true

RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
        local rootPart = character.HumanoidRootPart
        local humanoid = character.Humanoid
        
        -- Chỉ kích hoạt sàn khi nhân vật đang ở trên không và sống
        if humanoid.Health > 0 and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            airWalkPart.Parent = workspace
            airWalkPart.CFrame = CFrame.new(rootPart.Position.X, rootPart.Position.Y - 3.2, rootPart.Position.Z)
        elseif humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
            airWalkPart.Parent = nil
        end
    else
        airWalkPart.Parent = nil
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

        -- Tạo Highlight (Khung viền ESP)
        if not character:FindFirstChild("MoteHub_Highlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "MoteHub_Highlight"
            highlight.Adornee = character
            highlight.FillColor = Color3.fromRGB(0, 255, 128)      -- Màu thân: Xanh lục
            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)    -- Màu viền: Vàng
            highlight.FillTransparency = 0.6
            highlight.OutlineTransparency = 0
            highlight.Parent = character
        end

        -- Tạo BillboardGui (Thẻ tên & Khoảng cách trên đầu)
        if not head:FindFirstChild("MoteHub_NameTag") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "MoteHub_NameTag"
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true

            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.TextStrokeTransparency = 0
            textLabel.TextSize = 13
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.Parent = billboard
            billboard.Parent = head

            -- Cập nhật khoảng cách liên tục
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if character and character:Parent() and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                    local targetPos = rootPart.Position
                    local distance = math.floor((myPos - targetPos).Magnitude)
                    
                    textLabel.Text = string.format("%s\n[%d studs]", player.DisplayName, distance)
                else
                    connection:Disconnect()
                end
            end)
        end
    end

    if player.Character then
        applyESP(player.Character)
    end
    player.CharacterAdded:Connect(applyESP)
end

-- Áp dụng ESP cho người chơi hiện tại và người mới vào
for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end
Players.PlayerAdded:Connect(createESP)

--------------------------------------------------
-- THÔNG BÁO HOÀN TẤT
--------------------------------------------------
task.wait(1)
StarterGui:SetCore("SendNotification", {
    Title = "MoteHub Script",
    Text = "Đã bật: Anti-AFK, Double Jump, Air Walk & ESP!",
    Duration = 5
})
