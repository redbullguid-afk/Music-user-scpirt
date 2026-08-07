-- ==================================================
-- MOTEHUB V3.1 - FLY CARPET, ESP & NIGHT VISION
-- ==================================================

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- Bảng trạng thái Bật/Tắt tính năng
local Flags = {
    AntiAFK = true,
    FlyCarpet = false,
    ESP = false,
    Fullbright = false
}

--------------------------------------------------
-- 1. TÍNH NĂNG ANTI-AFK (CHỐNG KICK TREO MÁY)
--------------------------------------------------
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if Flags.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end)

--------------------------------------------------
-- 2. TÍNH NĂNG THẢM BAY (FLY CARPET)
--------------------------------------------------
local carpetPart = Instance.new("Part")
carpetPart.Name = "MoteHub_MagicCarpet"
carpetPart.Size = Vector3.new(6, 0.4, 6)
carpetPart.Material = Enum.Material.Neon
carpetPart.Color = Color3.fromRGB(0, 255, 128) -- Màu thảm: Xanh lá neon
carpetPart.Transparency = 0.3                   -- Trong suốt nhẹ
carpetPart.Anchored = true
carpetPart.CanCollide = true

task.spawn(function()
    RunService.RenderStepped:Connect(function()
        if Flags.FlyCarpet and LocalPlayer.Character then
            local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            if rootPart and humanoid and humanoid.Health > 0 then
                carpetPart.Parent = workspace
                carpetPart.CFrame = rootPart.CFrame * CFrame.new(0, -3.1, 0)
            else
                carpetPart.Parent = nil
            end
        else
            carpetPart.Parent = nil
        end
    end)
end)

--------------------------------------------------
-- 3. TÍNH NĂNG NHÌN TRONG BÓNG TỐI (FULLBRIGHT)
--------------------------------------------------
local originalBrightness = Lighting.Brightness
local originalClockTime = Lighting.ClockTime
local originalFogEnd = Lighting.FogEnd
local originalGlobalShadows = Lighting.GlobalShadows
local originalAmbient = Lighting.Ambient

task.spawn(function()
    RunService.RenderStepped:Connect(function()
        if Flags.Fullbright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14 -- Đưa thời gian về 14:00 (Buổi trưa)
            Lighting.FogEnd = 100000 -- Xóa sương mù
            Lighting.GlobalShadows = false -- Tắt bóng râm
            Lighting.Ambient = Color3.fromRGB(255, 255, 255) -- Ánh sáng môi trường màu trắng sáng
        else
            -- Giữ nguyên hoặc khôi phục mặc định nếu tắt
            Lighting.GlobalShadows = originalGlobalShadows
        end
    end)
end)

--------------------------------------------------
-- 4. TÍNH NĂNG ESP PLAYER (+ TRACER LINE)
--------------------------------------------------
local function applyESP(player)
    if player == LocalPlayer then return end

    local function setupCharacter(character)
        if not character then return end

        local head = character:WaitForChild("Head", 3)
        local rootPart = character:WaitForChild("HumanoidRootPart", 3)
        if not head or not rootPart then return end

        -- Highlight
        local highlight = character:FindFirstChild("MoteHub_Highlight") or Instance.new("Highlight")
        highlight.Name = "MoteHub_Highlight"
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(0, 255, 128)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
        highlight.FillTransparency = 0.6
        highlight.Enabled = Flags.ESP
        highlight.Parent = character

        -- NameTag
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

        -- Tracer Beam
        local attachmentTarget = rootPart:FindFirstChild("MoteHub_Attachment") or Instance.new("Attachment")
        attachmentTarget.Name = "MoteHub_Attachment"
        attachmentTarget.Parent = rootPart

        local beam = rootPart:FindFirstChild("MoteHub_TracerBeam") or Instance.new("Beam")
        beam.Name = "MoteHub_TracerBeam"
        beam.Attachment1 = attachmentTarget
        beam.Width0 = 0.1
        beam.Width1 = 0.1
        beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 128))
        beam.FaceCamera = true
        beam.Enabled = Flags.ESP
        beam.Parent = rootPart

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if character and character.Parent and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myRoot = LocalPlayer.Character.HumanoidRootPart
                local myAttachment = myRoot:FindFirstChild("MoteHub_MyAttachment") or Instance.new("Attachment")
                myAttachment.Name = "MoteHub_MyAttachment"
                myAttachment.Parent = myRoot

                beam.Attachment0 = myAttachment
                
                highlight.Enabled = Flags.ESP
                billboard.Enabled = Flags.ESP
                beam.Enabled = Flags.ESP

                if Flags.ESP then
                    local distance = math.floor((myRoot.Position - rootPart.Position).Magnitude)
                    textLabel.Text = string.format("%s\n[%d studs]", player.DisplayName, distance)
                end
            else
                if connection then connection:Disconnect() end
                if beam then beam:Destroy() end
            end
        end)
    end

    if player.Character then setupCharacter(player.Character) end
    player.CharacterAdded:Connect(setupCharacter)
end

task.spawn(function()
    for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
    Players.PlayerAdded:Connect(applyESP)
end)

--------------------------------------------------
-- 5. GIAO DIỆN MENU (GUI MOTE HUB)
--------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoteHub_GUI"
screenGui.ResetOnSpawn = false

pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Nút ẩn/hiện Menu
local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Name = "ToggleMenuBtn"
toggleMenuBtn.Size = UDim2.new(0, 80, 0, 35)
toggleMenuBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleMenuBtn.TextColor3 = Color3.fromRGB(0, 255, 128)
toggleMenuBtn.Text = "mote HUB"
toggleMenuBtn.Font = Enum.Font.SourceSansBold
toggleMenuBtn.TextSize = 14
toggleMenuBtn.Parent = screenGui

-- Bảng Menu
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 230)
mainFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Tiêu đề Chữ ký
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "SignatureHeader"
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
titleLabel.Text = "mote HUB"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Parent = mainFrame

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

-- Tạo các nút trong Menu
createToggleButton("Anti-AFK", "AntiAFK", 45)
createToggleButton("Thảm Bay (Fly)", "FlyCarpet", 90)
createToggleButton("Nhìn Bóng Tối", "Fullbright", 135)
createToggleButton("ESP Player", "ESP", 180)

toggleMenuBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

StarterGui:SetCore("SendNotification", {
    Title = "mote HUB",
    Text = "Đã thêm tính năng Nhìn Trong Bóng Tối!",
    Duration = 4
})
