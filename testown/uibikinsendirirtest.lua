local Library = {}

local UIS = game:GetService("UserInputService")

function Library:CreateWindow(config)

local Title = config.Title or "Window"
local Theme = config.Theme or Color3.fromRGB(0,170,255)
local Icon = config.Icon or "rbxassetid://7733960981"

local ScreenGui = Instance.new("ScreenGui",game.CoreGui)
ScreenGui.Name = "LexsUI"

local Main = Instance.new("Frame",ScreenGui)
Main.Size = UDim2.new(0,520,0,360)
Main.Position = UDim2.new(0.5,-260,0.5,-180)
Main.BackgroundColor3 = Color3.fromRGB(30,30,30)
Main.BorderSizePixel = 0

local Top = Instance.new("Frame",Main)
Top.Size = UDim2.new(1,0,0,35)
Top.BackgroundColor3 = Color3.fromRGB(25,25,25)

local TitleLabel = Instance.new("TextLabel",Top)
TitleLabel.Size = UDim2.new(1,-80,1,0)
TitleLabel.Position = UDim2.new(0,10,0,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.new(1,1,1)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.Text = ""

-- typing animation
task.spawn(function()
for i=1,#Title do
TitleLabel.Text = string.sub(Title,1,i)
task.wait(0.04)
end
end)

-- close
local Close = Instance.new("TextButton",Top)
Close.Size = UDim2.new(0,35,1,0)
Close.Position = UDim2.new(1,-35,0,0)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200,60,60)
Close.TextColor3 = Color3.new(1,1,1)

Close.MouseButton1Click:Connect(function()
ScreenGui:Destroy()
end)

-- minimize
local Min = Instance.new("TextButton",Top)
Min.Size = UDim2.new(0,35,1,0)
Min.Position = UDim2.new(1,-70,0,0)
Min.Text = "-"
Min.BackgroundColor3 = Theme
Min.TextColor3 = Color3.new(1,1,1)

local minimized=false

Min.MouseButton1Click:Connect(function()
minimized = not minimized
for _,v in pairs(Main:GetChildren()) do
if v~=Top then
v.Visible = not minimized
end
end
end)

-- drag
local dragging=false
local dragStart
local startPos

Top.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 then
dragging=true
dragStart=input.Position
startPos=Main.Position
end
end)

UIS.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 then
dragging=false
end
end)

UIS.InputChanged:Connect(function(input)
if dragging then
local delta=input.Position-dragStart
Main.Position=UDim2.new(
startPos.X.Scale,
startPos.X.Offset+delta.X,
startPos.Y.Scale,
startPos.Y.Offset+delta.Y
)
end
end)

-- floating icon
local IconButton = Instance.new("ImageButton",ScreenGui)
IconButton.Size = UDim2.new(0,50,0,50)
IconButton.Position = UDim2.new(0,10,0.5,-25)
IconButton.Image = Icon
IconButton.BackgroundTransparency = 1

local draggingIcon=false
local iconStart
local iconPos

IconButton.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 then
draggingIcon=true
iconStart=input.Position
iconPos=IconButton.Position
end
end)

UIS.InputChanged:Connect(function(input)
if draggingIcon then
local delta=input.Position-iconStart
IconButton.Position=UDim2.new(
iconPos.X.Scale,
iconPos.X.Offset+delta.X,
iconPos.Y.Scale,
iconPos.Y.Offset+delta.Y
)
end
end)

UIS.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 then
draggingIcon=false
end
end)

IconButton.MouseButton1Click:Connect(function()
Main.Visible = not Main.Visible
end)

-- content
local Content = Instance.new("Frame",Main)
Content.Size = UDim2.new(1,-10,1,-45)
Content.Position = UDim2.new(0,5,0,40)
Content.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout",Content)
Layout.Padding = UDim.new(0,6)

local Window = {}

function Window:AddButton(data)

local B = Instance.new("TextButton",Content)
B.Size = UDim2.new(1,0,0,35)
B.BackgroundColor3 = Color3.fromRGB(40,40,40)
B.TextColor3 = Color3.new(1,1,1)
B.Text = data.Title

B.MouseButton1Click:Connect(function()
data.Callback()
end)

end

function Window:AddToggle(data)

local state = data.Default or false

local T = Instance.new("TextButton",Content)
T.Size = UDim2.new(1,0,0,35)
T.BackgroundColor3 = Color3.fromRGB(40,40,40)
T.TextColor3 = Color3.new(1,1,1)

local function update()
T.Text = data.Title.." : "..tostring(state)
end

update()

T.MouseButton1Click:Connect(function()
state = not state
update()
data.Callback(state)
end)

end

function Window:AddInput(data)

local Box = Instance.new("TextBox",Content)
Box.Size = UDim2.new(1,0,0,35)
Box.PlaceholderText = data.Title
Box.BackgroundColor3 = Color3.fromRGB(40,40,40)
Box.TextColor3 = Color3.new(1,1,1)

Box.FocusLost:Connect(function()
data.Callback(Box.Text)
end)

end

function Window:AddParagraph(data)

local P = Instance.new("TextLabel",Content)
P.Size = UDim2.new(1,0,0,50)
P.BackgroundTransparency = 1
P.TextColor3 = Color3.new(1,1,1)
P.TextWrapped = true
P.Text = data.Text

end

function Window:AddSlider(data)

local Value = data.Default or 0
local Max = data.Max or 100

local Frame = Instance.new("Frame",Content)
Frame.Size = UDim2.new(1,0,0,40)
Frame.BackgroundColor3 = Color3.fromRGB(40,40,40)

local Fill = Instance.new("Frame",Frame)
Fill.BackgroundColor3 = Theme
Fill.Size = UDim2.new(Value/Max,0,1,0)

Frame.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 then

local move
move = UIS.InputChanged:Connect(function(i)

if i.UserInputType==Enum.UserInputType.MouseMovement then

local percent = math.clamp(
(i.Position.X-Frame.AbsolutePosition.X)/Frame.AbsoluteSize.X,
0,1)

Fill.Size = UDim2.new(percent,0,1,0)

local val = math.floor(percent*Max)

data.Callback(val)

end

end)

UIS.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 then
move:Disconnect()
end
end)

end
end)

end

return Window

end

return Library
