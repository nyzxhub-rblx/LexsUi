local Library = {}
Library.__index = Library

local UIS = game:GetService("UserInputService")

function Library:CreateWindow(settings)
    local Title = settings.Title or "Window"

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WindLikeUI"
    ScreenGui.Parent = game.CoreGui

    local Main = Instance.new("Frame")
    Main.Parent = ScreenGui
    Main.Size = UDim2.new(0,500,0,350)
    Main.Position = UDim2.new(0.5,-250,0.5,-175)
    Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Main.BorderSizePixel = 0

    local Top = Instance.new("Frame")
    Top.Parent = Main
    Top.Size = UDim2.new(1,0,0,35)
    Top.BackgroundColor3 = Color3.fromRGB(20,20,20)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Top
    TitleLabel.Size = UDim2.new(1,0,1,0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.new(1,1,1)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14

    local TabsFrame = Instance.new("Frame")
    TabsFrame.Parent = Main
    TabsFrame.Size = UDim2.new(0,120,1,-35)
    TabsFrame.Position = UDim2.new(0,0,0,35)
    TabsFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)

    local Content = Instance.new("Frame")
    Content.Parent = Main
    Content.Size = UDim2.new(1,-120,1,-35)
    Content.Position = UDim2.new(0,120,0,35)
    Content.BackgroundTransparency = 1

    local TabLayout = Instance.new("UIListLayout", TabsFrame)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- draggable
    local dragging, dragInput, dragStart, startPos

    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    Top.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    local Window = {}

    function Window:CreateTab(name)

        local TabButton = Instance.new("TextButton")
        TabButton.Parent = TabsFrame
        TabButton.Size = UDim2.new(1,0,0,35)
        TabButton.Text = name
        TabButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
        TabButton.TextColor3 = Color3.new(1,1,1)
        TabButton.BorderSizePixel = 0

        local TabFrame = Instance.new("Frame")
        TabFrame.Parent = Content
        TabFrame.Size = UDim2.new(1,0,1,0)
        TabFrame.Visible = false
        TabFrame.BackgroundTransparency = 1

        local Layout = Instance.new("UIListLayout", TabFrame)
        Layout.Padding = UDim.new(0,5)

        TabButton.MouseButton1Click:Connect(function()
            for _,v in pairs(Content:GetChildren()) do
                if v:IsA("Frame") then
                    v.Visible = false
                end
            end
            TabFrame.Visible = true
        end)

        local Tab = {}

        function Tab:AddButton(data)

            local Button = Instance.new("TextButton")
            Button.Parent = TabFrame
            Button.Size = UDim2.new(1,-10,0,35)
            Button.Text = data.Title
            Button.BackgroundColor3 = Color3.fromRGB(35,35,35)
            Button.TextColor3 = Color3.new(1,1,1)
            Button.BorderSizePixel = 0

            Button.MouseButton1Click:Connect(function()
                if data.Callback then
                    data.Callback()
                end
            end)

        end

        function Tab:AddToggle(data)

            local state = data.Default or false

            local Toggle = Instance.new("TextButton")
            Toggle.Parent = TabFrame
            Toggle.Size = UDim2.new(1,-10,0,35)
            Toggle.Text = data.Title.." : "..tostring(state)
            Toggle.BackgroundColor3 = Color3.fromRGB(35,35,35)
            Toggle.TextColor3 = Color3.new(1,1,1)
            Toggle.BorderSizePixel = 0

            Toggle.MouseButton1Click:Connect(function()

                state = not state
                Toggle.Text = data.Title.." : "..tostring(state)

                if data.Callback then
                    data.Callback(state)
                end

            end)

        end

        function Tab:AddInput(data)

            local Box = Instance.new("TextBox")
            Box.Parent = TabFrame
            Box.Size = UDim2.new(1,-10,0,35)
            Box.PlaceholderText = data.Title
            Box.BackgroundColor3 = Color3.fromRGB(35,35,35)
            Box.TextColor3 = Color3.new(1,1,1)
            Box.BorderSizePixel = 0

            Box.FocusLost:Connect(function()

                if data.Callback then
                    data.Callback(Box.Text)
                end

            end)

        end

        return Tab
    end

    return Window
end

return Library
