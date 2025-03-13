-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Tạo cửa sổ GUI
local Window = Rayfield:CreateWindow({
    Name = "Auto Clicker",
    LoadingTitle = "Đang tải...",
    LoadingSubtitle = "by HenGi",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

-- Tạo tab chính
local MainTab = Window:CreateTab("Main", 4483362458)

-- Biến Auto Click & tốc độ
local AutoClick = false
local ClickSpeed = 0.1 -- Mặc định 0.1 giây/click
local ClickPosition = Vector2.new(500, 300) -- Vị trí mặc định

-- Tạo GUI hình mũi tên nhỏ
local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
local Arrow = Instance.new("Frame", ScreenGui)

Arrow.Size = UDim2.new(0, 20, 0, 20) -- Kích thước mũi tên
Arrow.Position = UDim2.new(0, ClickPosition.X, 0, ClickPosition.Y) -- Vị trí ban đầu
Arrow.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Màu đỏ
Arrow.Active = true
Arrow.Draggable = true -- Cho phép kéo mũi tên

-- Hàm Auto Click
function AutoClicker()
    while AutoClick do
        wait(ClickSpeed) -- Dùng tốc độ đã chọn
        ClickPosition = Vector2.new(Arrow.AbsolutePosition.X, Arrow.AbsolutePosition.Y)
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(ClickPosition.X, ClickPosition.Y, 0, true, game, 1)
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(ClickPosition.X, ClickPosition.Y, 0, false, game, 1)
    end
end

-- Toggle bật/tắt Auto Click
MainTab:CreateToggle({
    Name = "Bật/Tắt Auto Click",
    CurrentValue = false,
    Callback = function(Value)
        AutoClick = Value
        if AutoClick then
            AutoClicker()
        end
    end
})

-- Slider điều chỉnh tốc độ click
MainTab:CreateSlider({
    Name = "Tốc Độ Click (giây)",
    Range = {0.05, 1},
    Increment = 0.01,
    CurrentValue = 0.1,
    Callback = function(Value)
        ClickSpeed = Value
    end
})

-- Button cập nhật vị trí từ mũi tên
MainTab:CreateButton({
    Name = "Lấy vị trí từ mũi tên",
    Callback = function()
        ClickPosition = Vector2.new(Arrow.AbsolutePosition.X, Arrow.AbsolutePosition.Y)
        Rayfield:Notify({
            Title = "Vị trí Click",
            Content = "Tọa độ: X = " .. ClickPosition.X .. ", Y = " .. ClickPosition.Y,
            Duration = 2
        })
    end
})
