return function()

    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")

    local player = Players.LocalPlayer
    local PlayerGui = player:WaitForChild("PlayerGui")

    local Lib = {}
    local NotifCount = 0

    function Lib:MakeNotify(options)
        local Title = options.Title or "Notification"
        local Content = options.Content or ""
        local Delay = options.Delay or 3
        local Icon = options.Icon or ""

        -- lucide convert
        if Icon:find("lucide:") then
            local icons = {
                check = "rbxassetid://7733658504",
                x = "rbxassetid://7733658504",
                alert = "rbxassetid://7733658504"
            }
            Icon = icons[Icon:gsub("lucide:", "")] or ""
        end

        NotifCount += 1

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = PlayerGui
        ScreenGui.IgnoreGuiInset = true

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0, 300, 0, 75)

        -- 🔥 POSISI KANAN BAWAH + STACK
        Frame.Position = UDim2.new(1, 320, 1, -100 - ((NotifCount-1) * 85))

        Frame.BackgroundColor3 = Color3.fromRGB(10,10,10)
        Frame.Parent = ScreenGui

        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

        local Stroke = Instance.new("UIStroke", Frame)
        Stroke.Thickness = 2

        local Gradient = Instance.new("UIGradient", Stroke)
        Gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
        }

        local IconLabel = Instance.new("ImageLabel")
        IconLabel.Size = UDim2.new(0, 40, 0, 40)
        IconLabel.Position = UDim2.new(0, 10, 0.5, -20)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Image = Icon
        IconLabel.Parent = Frame

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, -60, 0, 25)
        TitleLabel.Position = UDim2.new(0, 55, 0, 5)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = Title
        TitleLabel.TextColor3 = Color3.new(1,1,1)
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextSize = 16
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = Frame

        local ContentLabel = Instance.new("TextLabel")
        ContentLabel.Size = UDim2.new(1, -60, 0, 40)
        ContentLabel.Position = UDim2.new(0, 55, 0, 30)
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.Text = Content
        ContentLabel.TextColor3 = Color3.fromRGB(200,200,200)
        ContentLabel.Font = Enum.Font.Gotham
        ContentLabel.TextSize = 14
        ContentLabel.TextWrapped = true
        ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
        ContentLabel.Parent = Frame

        -- BAR
        local BarBG = Instance.new("Frame")
        BarBG.Size = UDim2.new(1, 0, 0, 3)
        BarBG.Position = UDim2.new(0, 0, 1, -3)
        BarBG.BackgroundColor3 = Color3.fromRGB(30,30,30)
        BarBG.Parent = Frame

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(1, 0, 1, 0)
        Bar.Parent = BarBG

        local BarGradient = Instance.new("UIGradient", Bar)
        BarGradient.Color = Gradient.Color

        -- MASUK
        TweenService:Create(Frame, TweenInfo.new(0.3), {
            Position = UDim2.new(1, -320, 1, -100 - ((NotifCount-1) * 85))
        }):Play()

        -- PROGRESS
        TweenService:Create(Bar, TweenInfo.new(Delay), {
            Size = UDim2.new(0, 0, 1, 0)
        }):Play()

        -- HAPUS
        task.delay(Delay, function()
            TweenService:Create(Frame, TweenInfo.new(0.3), {
                Position = UDim2.new(1, 320, 1, -100)
            }):Play()

            task.wait(0.3)
            ScreenGui:Destroy()
            NotifCount -= 1
        end)
    end

    return Lib
end
