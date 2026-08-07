-- Thông báo bắt đầu tải
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Anti-AFK",
    Text = "Đang tải script...",
    Duration = 3
})

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")

-- Ngăn chặn Roblox đá người chơi khi đứng yên 20 phút
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    
    -- Thông báo khi vừa chống bị kick thành công
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Anti-AFK",
        Text = "Đã tự động tương tác để tránh bị kick!",
        Duration = 3
    })
end)

-- Thông báo kích hoạt thành công
task.wait(1)
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Anti-AFK",
    Text = "Kích hoạt thành công! Bạn có thể treo máy.",
    Duration = 5
})
