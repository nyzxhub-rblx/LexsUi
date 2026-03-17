local Library = {}

local UIS = game:GetService("UserInputService")

function Library:CreateWindow(cfg)

local Title = cfg.Title or "Window"
local Icon = cfg.Icon or "rbxassetid://7733960981"

local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui
gui.Name = "LexsUI"

local Main = Instance.new("Frame",gui)
Main.Size = UDim2.new(0,600,0,400)
Main.Position = UDim2.new(0.5,-300,0.5,-200)
Main.BackgroundColor3 = Color3.fromRGB(30,30,30)
Main.BorderSizePixel = 0

-- background (kamu bisa edit)
local Background = Instance.new("Frame",Main)
Background.Size = UDim2.new(1,0,1,0)
Background.BackgroundTransparency = 1

local Top = Instance.new("Frame",Main)
Top.Size = UDim2.new(1,0,0,35)
Top.BackgroundColor3 = Color3.fromRGB(20,20,20)

local TitleLabel = Instance.new("TextLabel",Top)
TitleLabel.Size = UDim2.new(1,-100,1,0)
TitleLabel.Position = UDim2.new(0,10,0,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.new(1,1,1)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.Text = ""

task.spawn(function()
for i=1,#Title do
TitleLabel.Text = string.sub(Title,1,i)
task.wait(0.03)
end
end)

-- close
local Close = Instance.new("TextButton",Top)
Close.Size = UDim2.new(0,35,1,0)
Close.Position = UDim2.new(1,-35,0,0)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200,60,60)

Close.MouseButton1Click:Connect(function()
gui:Destroy()
end)

-- minimize
local Min = Instance.new("TextButton",Top)
Min.Size = UDim2.new(0,35,1,0)
Min.Position = UDim2.new(1,-70,0,0)
Min.Text = "-"

local minimized=false

Min.MouseButton1Click:Connect(function()

minimized = not minimized

for _,v in pairs(Main:GetChildren()) do
if v~=Top then
v.Visible = not minimized
end
end

end)

-- drag window
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

UIS.InputChanged:Connect(function(input)

if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then

local delta=input.Position-dragStart

Main.Position=UDim2.new(
startPos.X.Scale,
startPos.X.Offset+delta.X,
startPos.Y.Scale,
startPos.Y.Offset+delta.Y
)

end

end)

UIS.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 then
dragging=false
end
end)

-- floating icon
local IconBtn = Instance.new("ImageButton",gui)
IconBtn.Size = UDim2.new(0,50,0,50)
IconBtn.Position = UDim2.new(0,10,0.5,-25)
IconBtn.Image = Icon
IconBtn.BackgroundTransparency = 1

local iconDrag=false
local iconStart
local iconPos

IconBtn.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 then
iconDrag=true
iconStart=input.Position
iconPos=IconBtn.Position
end
end)

UIS.InputChanged:Connect(function(input)
if iconDrag then
local delta=input.Position-iconStart
IconBtn.Position=UDim2.new(
iconPos.X.Scale,
iconPos.X.Offset+delta.X,
iconPos.Y.Scale,
iconPos.Y.Offset+delta.Y
)
end
end)

UIS.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 then
iconDrag=false
end
end)

IconBtn.MouseButton1Click:Connect(function()
Main.Visible = not Main.Visible
end)

-- tabs
local Tabs = Instance.new("Frame",Main)
Tabs.Size = UDim2.new(0,140,1,-35)
Tabs.Position = UDim2.new(0,0,0,35)
Tabs.BackgroundColor3 = Color3.fromRGB(25,25,25)

local TabLayout = Instance.new("UIListLayout",Tabs)

-- pages
local Pages = Instance.new("Frame",Main)
Pages.Size = UDim2.new(1,-140,1,-35)
Pages.Position = UDim2.new(0,140,0,35)
Pages.BackgroundTransparency = 1

local Window = {}

function Window:Tab(cfg)

local TabName = cfg.Title or "Tab"

local TabButton = Instance.new("TextButton",Tabs)
TabButton.Size = UDim2.new(1,0,0,35)
TabButton.Text = TabName
TabButton.BackgroundColor3 = Color3.fromRGB(35,35,35)

local Page = Instance.new("ScrollingFrame",Pages)
Page.Size = UDim2.new(1,0,1,0)
Page.CanvasSize = UDim2.new(0,0,0,0)
Page.ScrollBarThickness = 4
Page.Visible = false
Page.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout",Page)
Layout.Padding = UDim.new(0,6)

TabButton.MouseButton1Click:Connect(function()

for _,v in pairs(Pages:GetChildren()) do
if v:IsA("ScrollingFrame") then
v.Visible=false
end
end

Page.Visible=true

end)

local Tab = {}

function Tab:Section(cfg)

local SectionTitle = cfg.Title or "Section"

local SectionFrame = Instance.new("Frame",Page)
SectionFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
SectionFrame.Size = UDim2.new(1,-10,0,0)

local SecTitle = Instance.new("TextLabel",SectionFrame)
SecTitle.Size = UDim2.new(1,0,0,25)
SecTitle.BackgroundTransparency = 1
SecTitle.Text = SectionTitle
SecTitle.TextColor3 = Color3.new(1,1,1)
SecTitle.Font = Enum.Font.GothamBold
SecTitle.TextSize = 14

local Layout = Instance.new("UIListLayout",SectionFrame)
Layout.Padding = UDim.new(0,5)

local Section = {}

function Section:Toggle(cfg)

local state = cfg.Default or false

local Toggle = Instance.new("TextButton",SectionFrame)
Toggle.Size = UDim2.new(1,-10,0,30)
Toggle.BackgroundColor3 = Color3.fromRGB(50,50,50)

local function update()
Toggle.Text = cfg.Title.." : "..tostring(state)
end

update()

Toggle.MouseButton1Click:Connect(function()

state = not state
update()

if cfg.Callback then
cfg.Callback(state)
end

end)

end

function Section:Button(cfg)

local Btn = Instance.new("TextButton",SectionFrame)
Btn.Size = UDim2.new(1,-10,0,30)
Btn.Text = cfg.Title
Btn.BackgroundColor3 = Color3.fromRGB(50,50,50)

Btn.MouseButton1Click:Connect(function()

if cfg.Callback then
cfg.Callback()
end

end)

end

function Section:Input(cfg)

local Box = Instance.new("TextBox",SectionFrame)
Box.Size = UDim2.new(1,-10,0,30)
Box.PlaceholderText = cfg.Title
Box.BackgroundColor3 = Color3.fromRGB(50,50,50)

Box.FocusLost:Connect(function()

if cfg.Callback then
cfg.Callback(Box.Text)
end

end)

end

function Section:Slider(cfg)

local Max = cfg.Max or 100

local Slider = Instance.new("Frame",SectionFrame)
Slider.Size = UDim2.new(1,-10,0,30)
Slider.BackgroundColor3 = Color3.fromRGB(50,50,50)

local Fill = Instance.new("Frame",Slider)
Fill.Size = UDim2.new(0,0,1,0)
Fill.BackgroundColor3 = Color3.fromRGB(0,170,255)

Slider.InputBegan:Connect(function(input)

if input.UserInputType==Enum.UserInputType.MouseButton1 then

local move

move = UIS.InputChanged:Connect(function(i)

if i.UserInputType==Enum.UserInputType.MouseMovement then

local percent = math.clamp(
(i.Position.X-Slider.AbsolutePosition.X)/Slider.AbsoluteSize.X,
0,1)

Fill.Size = UDim2.new(percent,0,1,0)

local val = math.floor(percent*Max)

if cfg.Callback then
cfg.Callback(val)
end

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

function Section:Paragraph(cfg)

local P = Instance.new("TextLabel",SectionFrame)
P.Size = UDim2.new(1,-10,0,40)
P.BackgroundTransparency = 1
P.TextWrapped = true
P.TextColor3 = Color3.new(1,1,1)
P.Text = cfg.Text

end

return Section

end

return Tab

end

return Window

end

return Library
