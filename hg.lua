-- Lấy Place ID và Job ID
local placeId = game.PlaceId
local jobId = game.JobId

-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
   if not Rayfield then
    warn("Không thể tải HG Hub!")
    return
end

local Players = game:GetService("Players")

-- Tạo cửa sổ GUI
local Window = Rayfield:CreateWindow({
    Name = "HG❤Hub",
    LoadingTitle = "Đang tải...",
    LoadingSubtitle = "by HenGi",
    ConfigurationSaving = {Enabled = true,
        FolderName = "HGhub",
        FileName = "Settings"},
    KeySystem = false
})

-- Tabs
local UtilityTab = Window:CreateTab("Utility", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4859271243)
local ServerTab = Window:CreateTab("Server", 9180622665)

-- Biến
local JumpEnabled = false
local SpeedEnabled = false
local TeleportEnabled = false
local NoclipEnabled = false
local DefaultJump = game.Players.LocalPlayer.Character.Humanoid.JumpPower
local DefaultSpeed = game.Players.LocalPlayer.Character.Humanoid.WalkSpeed
local JumpPower = 100
local Speed = 50
local LastTeleportTime = 0  -- Lưu thời gian dịch chuyển lần cuối
local SpeedLock = false  -- Kiểm soát vòng lặp giữ tốc độ

-- Nhảy Cao Toggle
UtilityTab:CreateToggle({
    Name = "Nhảy Cao",
    CurrentValue = false,
    Callback = function(Value)
        JumpEnabled = Value
        if JumpEnabled then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = JumpPower
        else
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = DefaultJump
        end
    end
})

-- Nhảy Cao Slider
local JumpSlider = UtilityTab:CreateSlider({
    Name = "Chiều Cao Nhảy",
    Range = {50, 1000},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(Value)
        JumpPower = Value
        if JumpEnabled then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = JumpPower
        end
    end
})

-- Chạy Nhanh Toggle (Giữ nguyên tốc độ)
UtilityTab:CreateToggle({
    Name = "Chạy Nhanh",
    CurrentValue = false,
    Callback = function(Value)
        SpeedEnabled = Value
        local Humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if SpeedEnabled then
            SpeedLock = true
            task.spawn(function()
                while SpeedLock and Humanoid do
                    if Humanoid.WalkSpeed ~= Speed then
                        Humanoid.WalkSpeed = Speed  -- Cài lại tốc độ nếu bị thay đổi
                    end
                    wait(0.1)  -- Kiểm tra lại mỗi 0.1 giây
                end
            end)
        else
            SpeedLock = false
            if Humanoid then
                Humanoid.WalkSpeed = DefaultSpeed  -- Trả về tốc độ gốc khi tắt hack
            end
        end
    end
})

-- Chạy Nhanh Slider
local SpeedSlider = UtilityTab:CreateSlider({
    Name = "Tốc Độ Chạy",
    Range = {16, 1000},
    Increment = 10,
    CurrentValue = 50,
    Callback = function(Value)
        Speed = Value
        if SpeedEnabled then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Speed
        end
    end
})

-- Toggle Dịch Chuyển Khi Ấn
UtilityTab:CreateToggle({
    Name = "Dịch Chuyển Khi Ấn",
    CurrentValue = false,
    Callback = function(Value)
        TeleportEnabled = Value
    end
})

-- Lắng nghe sự kiện chuột (hồi chiêu 2 giây)
local mouse = game.Players.LocalPlayer:GetMouse()
mouse.Button1Down:Connect(function()
    if TeleportEnabled then
        local currentTime = tick()
        if currentTime - LastTeleportTime >= 2 then  -- Kiểm tra hồi chiêu
            local position = mouse.Hit.p
            local character = game.Players.LocalPlayer.Character
            if character then
                character:MoveTo(position)
                LastTeleportTime = currentTime  -- Cập nhật thời gian dịch chuyển
            end
        else
            Rayfield:Notify({
                Title = "Dịch Chuyển",
                Content = "Bạn phải đợi 2 giây trước khi dịch chuyển tiếp!",
                Duration = 1.5
            })
        end
    end
end)

-- Xuyên Tường (Noclip)
function ToggleNoclip()
    while NoclipEnabled do
        for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
        wait(0.1)
    end
end

UtilityTab:CreateToggle({
    Name = "Xuyên Tường (Noclip)",
    CurrentValue = false,
    Callback = function(Value)
        NoclipEnabled = Value
        if NoclipEnabled then
            task.spawn(ToggleNoclip)
        end
    end
})

-- Nút Reset (Không reset xuyên tường)
UtilityTab:CreateButton({
    Name = "Reset",
    Callback = function()
        -- Reset tốc độ chạy
        Speed = 50
        SpeedSlider:Set(Speed)
        if SpeedEnabled then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Speed
        end
        
        -- Reset chiều cao nhảy
        JumpPower = 100
        JumpSlider:Set(JumpPower)
        if JumpEnabled then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = JumpPower
        end

        -- Reset dịch chuyển
        TeleportEnabled = false

        Rayfield:Notify({
            Title = "Reset Thành Công",
            Content = "Đã reset tất cả (trừ xuyên tường)!",
            Duration = 2
        })
    end
})

-- Giảm Lag và xóa animation, pratice và texture
local function ReduceLagAndRemoveAnimations()
    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass("Terrain")

    -- Tắt hiệu ứng ánh sáng
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 999999
    Lighting.Brightness = 1

    -- Xóa hiệu ứng không cần thiết
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v:Destroy()
        elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("MeshPart") then
            v.Transparency = 1
            if v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
            end
        end
    end

    -- Giảm chất lượng Terrain
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end

    -- Xóa mọi animation của nhân vật và kỹ năng
    local Character = game.Players.LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            local AnimateScript = Character:FindFirstChild("Animate")
            if AnimateScript then
                AnimateScript:Destroy()  -- Xóa tất cả animation của nhân vật
            end
            -- Tắt tất cả các animation hiện tại
            for _, animation in pairs(Humanoid:GetChildren()) do
                if animation:IsA("Animation") then
                    animation:Stop()
                end
            end
        end
    end

    -- Xóa animation của skill (tìm các Animation liên quan đến kỹ năng)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Animation") then
            v:Destroy()
        end
    end

    Rayfield:Notify({
        Title = "Giảm Lag và Xóa Animation",
        Content = "Đã bật chế độ giảm lag và xóa tất cả animation, pratice và texture!",
        Duration = 2
    })
end

-- Cài đặt Giảm Lag
SettingsTab:CreateToggle({
    Name = "Giảm Lag",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            ReduceLagAndRemoveAnimations()  -- Bật giảm lag
        else
            Rayfield:Notify({
                Title = "Giảm Lag",
                Content = "Chế độ giảm lag đã bị tắt!",
                Duration = 2
            })
        end
      end
})
-- Biến để theo dõi trạng thái bật/tắt thông báo
local HideNotifications = false

-- Tạo Toggle để bật/tắt việc ẩn thông báo
SettingsTab:CreateToggle({
    Name = "Ẩn Thông Báo",
    CurrentValue = false,
    Callback = function(Value)
        HideNotifications = Value
        -- Lắng nghe thông báo trong PlayerGui và ẩn chúng nếu HideNotifications = true
        game:GetService("Players").PlayerAdded:Connect(function(player)
            player.PlayerGui.ChildAdded:Connect(function(child)
                if child:IsA("TextLabel") or child:IsA("BillboardGui") then
                    if HideNotifications then
                        child.Visible = false  -- Ẩn thông báo
                    else
                        child.Visible = true   -- Hiển thị lại thông báo
                    end
                end
            end)
        end)
    end
})

-- Thêm chức năng Server Hop
ServerTab:CreateButton({
    Name = "Server Hop (Chuyển Server)",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(placeId)  -- Chuyển tới server cùng Place ID
    end
})

-- Thêm chức năng Rejoin (Tham gia lại server)
ServerTab:CreateButton({
    Name = "Rejoin (Tham gia lại)",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:TeleportToPlaceInstance(placeId, jobId)  -- Quay lại server hiện tại
    end
    })
-- Biến kiểm soát
local targetEntityName = "" -- Tên thực thể được nhập
local aliveEntities = {} -- Danh sách thực thể còn sống

-- Danh sách thả xuống (Dropdown) hiển thị thực thể còn sống (giữ nguyên nếu bạn vẫn muốn)
local EntityDropdown = UtilityTab:CreateDropdown({
    Name = "Thực thể còn sống",
    Options = {"Nhấn cập nhật"},
    Callback = function(Value)
        targetEntityName = Value
        Rayfield:Notify({
            Title = "Thực thể được chọn",
            Content = "Đã chọn thực thể: " .. Value,
            Duration = 3
        })
    end,
})

-- Nút cập nhật danh sách thực thể còn sống
UtilityTab:CreateButton({
    Name = "Cập nhật thực thể còn sống",
    Callback = function()
        aliveEntities = {} -- Xóa danh sách cũ
        for _, entity in pairs(workspace:GetDescendants()) do
            local humanoid = entity:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                table.insert(aliveEntities, entity.Name)
            end
        end
        EntityDropdown:Refresh(aliveEntities, targetEntityName)
        Rayfield:Notify({
            Title = "Cập nhật thành công",
            Content = "Danh sách thực thể còn sống đã được làm mới!",
            Duration = 3
        })
    end,
})

-- Ô nhập tên thực thể để giết hoặc dịch chuyển
UtilityTab:CreateInput({
    Name = "Nhập tên thực thể",
    PlaceholderText = "Ví dụ: HG DEPZAI",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        targetEntityName = Value
        Rayfield:Notify({
            Title = "Tên thực thể",
            Content = "Đã đặt tên thực thể: " .. Value,
            Duration = 3
        })
    end,
})

-- Nút giết thực thể theo tên
UtilityTab:CreateButton({
    Name = "Giết thực thể theo tên",
    Callback = function()
        if targetEntityName == "" then
            Rayfield:Notify({
                Title = "Lỗi",
                Content = "Vui lòng nhập tên thực thể trước!",
                Duration = 3
            })
            return
        end
        local killedCount = 0
        for _, entity in pairs(workspace:GetDescendants()) do
            local humanoid = entity:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and entity.Name == targetEntityName then
                humanoid.Health = 0
                killedCount = killedCount + 1
            end
        end
        Rayfield:Notify({
            Title = "Kill Entities",
            Content = "Đã giết " .. killedCount .. " thực thể có tên '" .. targetEntityName .. "'!",
            Duration = 5
        })
    end,
})

-- Nút dịch chuyển đến thực thể theo tên nhập
UtilityTab:CreateButton({
    Name = "Dịch chuyển đến thực thể",
    Callback = function()
        if targetEntityName == "" then
            Rayfield:Notify({
                Title = "Lỗi",
                Content = "Vui lòng nhập tên thực thể trước!",
                Duration = 3
            })
            return
        end

        local player = Players.LocalPlayer
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            Rayfield:Notify({
                Title = "Lỗi",
                Content = "Không tìm thấy nhân vật của bạn!",
                Duration = 3
            })
            return
        end

        -- Tìm thực thể đầu tiên khớp với tên đã nhập
        for _, entity in pairs(workspace:GetDescendants()) do
            local humanoid = entity:FindFirstChildOfClass("Humanoid")
            local rootPart = entity:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and entity.Name == targetEntityName and rootPart then
                -- Dịch chuyển người chơi đến vị trí của thực thể
                character.HumanoidRootPart.CFrame = rootPart.CFrame + Vector3.new(0, 5, 0) -- Dịch lên trên một chút để tránh kẹt
                Rayfield:Notify({
                    Title = "Dịch chuyển",
                    Content = "Đã dịch chuyển đến '" .. targetEntityName .. "'!",
                    Duration = 3
                })
                return -- Thoát sau khi dịch chuyển đến thực thể đầu tiên
            end
        end

        Rayfield:Notify({
            Title = "Lỗi",
            Content = "Không tìm thấy thực thể '" .. targetEntityName .. "' còn sống!",
            Duration = 3
        })
    end,
})

