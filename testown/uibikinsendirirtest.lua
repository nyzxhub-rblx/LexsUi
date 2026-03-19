-- // Version : 0.2.0 | ConfigSection | Main.lua

local HttpService = game:GetService("HttpService") 
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local BASE = "https://raw.githubusercontent.com/nhfudzfsrzggt/brigida/refs/heads/main/"
local function load(path) return loadstring(game:HttpGet(BASE .. path))() end
local function loadUrl(url) return loadstring(game:HttpGet(url))() end

local ColorModule    = load("src/elements/color.lua")
local ElementsModule = load("src/elements/Elements.lua")
local KeybindModule  = load("src/elements/keybind.lua")
local DialogModule   = load("src/elements/dialog.lua")
local TabsModule          = loadUrl("https://fitri324.pythonanywhere.com/Tabs.lua/raw")
local SearchModule        = loadUrl("https://fitri324.pythonanywhere.com/Search.lua/raw")
local _ColorpickerSetup   = loadUrl("https://fitri324.pythonanywhere.com/Colorpicker.lua/raw")

local defaultIcons = load("src/elements/icon/basic.lua")
local lucideIcons  = load("src/elements/icon/lucide.lua")
local solarIcons   = load("src/elements/icon/solar.lua")

local Icons = {}
for name, id in pairs(defaultIcons) do
    Icons[name] = id
end
for name, id in pairs(lucideIcons) do
    Icons["lucide:" .. name] = id
end
for name, id in pairs(solarIcons) do
    Icons["solar:" .. name] = id
end

local function getIconId(iconName)
    if not iconName or iconName == "" then
        return ""
    end
    if iconName:match("^%d+$") then
        return "rbxassetid://" .. iconName
    end
    if Icons[iconName] then
        return Icons[iconName]
    end
    if iconName:match("^https?://") then
        return iconName
    end
    return ""
end

local function getColor(colorInput)
    if typeof(colorInput) == "Color3" then
        return colorInput
    end
    if type(colorInput) == "string" then
        if ColorModule[colorInput] then
            return ColorModule[colorInput]
        else
            warn("Color '" .. colorInput .. "' not found, using Default")
            return ColorModule["Default"] or Color3.fromRGB(0, 208, 255)
        end
    end
    return ColorModule["Default"] or Color3.fromRGB(0, 208, 255)
end

local ConfigFolder = "Lexs UI"
local ConfigFile = ""
local ConfigData = {}
local Elements = {}
local CURRENT_VERSION = nil
local AUTO_SAVE = false
local AUTO_LOAD = false

function SaveConfig()
    if writefile and ConfigFile ~= "" then
        ConfigData._version = CURRENT_VERSION
        writefile(ConfigFile, HttpService:JSONEncode(ConfigData))
    end
end

function LoadConfigFromFile()
    if not CURRENT_VERSION or ConfigFile == "" then return end
    if isfile and isfile(ConfigFile) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success and type(result) == "table" then
            if result._version == CURRENT_VERSION then
                ConfigData = result
            else
                ConfigData = { _version = CURRENT_VERSION }
            end
        else
            ConfigData = { _version = CURRENT_VERSION }
        end
    else
        ConfigData = { _version = CURRENT_VERSION }
    end
end

function LoadConfigElements()
    for key, element in pairs(Elements) do
        if ConfigData[key] ~= nil and element.Set then
            element:Set(ConfigData[key], true)
        end
    end
end

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")
local viewport = workspace.CurrentCamera.ViewportSize

local function isMobileDevice()
    return UserInputService.TouchEnabled
        and not UserInputService.KeyboardEnabled
        and not UserInputService.MouseEnabled
end

local isMobile = isMobileDevice()

local function safeSize(pxWidth, pxHeight)
    local scaleX = pxWidth / viewport.X
    local scaleY = pxHeight / viewport.Y
    if isMobile then
        if scaleX > 0.5 then scaleX = 0.5 end
        if scaleY > 0.3 then scaleY = 0.3 end
    end
    return UDim2.new(scaleX, 0, scaleY, 0)
end

local function MakeDraggable(topbarobject, object, GuiConfig)
    local function CustomPos(topbarobject, object)
        local Dragging, DragInput, DragStart, StartPosition

        local function UpdatePos(input)
            local Delta = input.Position - DragStart
            local pos = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
            local Tween = TweenService:Create(object, TweenInfo.new(0.2), { Position = pos })
            Tween:Play()
        end

        topbarobject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartPosition = object.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)

        topbarobject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                DragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then
                UpdatePos(input)
            end
        end)
    end

    local function CustomSize(object)
        local Dragging, DragInput, DragStart, StartSize
        local minSizeX, minSizeY
        local defSizeX, defSizeY

        local cfgW = (GuiConfig and GuiConfig.Size and GuiConfig.Size.X.Offset) or 640
        local cfgH = (GuiConfig and GuiConfig.Size and GuiConfig.Size.Y.Offset) or 400

        if isMobile then
            minSizeX, minSizeY = 100, 100
            defSizeX = math.min(cfgW, 470)
            defSizeY = math.min(cfgH, 270)
        else
            minSizeX, minSizeY = 100, 100
            defSizeX = cfgW
            defSizeY = cfgH
        end

        object.Size = UDim2.new(0, defSizeX, 0, defSizeY)

        local changesizeobject = Instance.new("Frame")
        changesizeobject.AnchorPoint = Vector2.new(1, 1)
        changesizeobject.BackgroundTransparency = 1
        changesizeobject.Size = UDim2.new(0, 40, 0, 40)
        changesizeobject.Position = UDim2.new(1, 20, 1, 20)
        changesizeobject.Name = "changesizeobject"
        changesizeobject.Parent = object

        local function UpdateSize(input)
            local Delta = input.Position - DragStart
            local newWidth = StartSize.X.Offset + Delta.X
            local newHeight = StartSize.Y.Offset + Delta.Y
            newWidth = math.max(newWidth, minSizeX)
            newHeight = math.max(newHeight, minSizeY)
            local Tween = TweenService:Create(object, TweenInfo.new(0.2), { Size = UDim2.new(0, newWidth, 0, newHeight) })
            Tween:Play()
        end

        changesizeobject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartSize = object.Size
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)

        changesizeobject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                DragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then
                UpdateSize(input)
            end
        end)
    end

    CustomSize(object)
    CustomPos(topbarobject, object)
end

function CircleClick(Button, X, Y)
    spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.8999999761581421
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Name = "Circle"
        Circle.Parent = Button

        local NewX = X - Circle.AbsolutePosition.X
        local NewY = Y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        local Size = 0
        if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.Y * 1.5
        elseif Button.AbsoluteSize.X == Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        end

        local Time = 0.5
        Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size / 2, 0.5, -Size / 2), "Out", "Quad",
            Time, false, nil)
        for i = 1, 10 do
            Circle.ImageTransparency = Circle.ImageTransparency + 0.01
            wait(Time / 10)
        end
        Circle:Destroy()
    end)
end

local _CPGui          = nil
local _CPPanel        = nil
local _CPPanelButtons = nil
local _CPPanelRefs    = nil
local _CPActive       = nil

local _ColorpickerModule = nil
local function _InitColorpicker(AccentColor, MainDropShadow)
    if _ColorpickerModule then return end
    _ColorpickerModule = _ColorpickerSetup(
        TweenService, UserInputService, CoreGui,
        getIconId, ConfigData, AUTO_SAVE, SaveConfig, ElementsModule
    )
end

local function _MakeColorPicker(Config, SectionAdd, CountItem, AccentColor, MainDropShadow)
    _InitColorpicker(AccentColor, MainDropShadow)
    if not _ColorpickerModule then
        warn("[LexsUI] Colorpicker.lua gagal dimuat dari server")
        return {}
    end
    return _ColorpickerModule.MakeColorPicker(Config, SectionAdd, CountItem, AccentColor, MainDropShadow)
end

local LexsUI = {}

function LexsUI:MakeNotify(NotifyConfig)
    NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title       = NotifyConfig.Title or "Lexs Hub"
    NotifyConfig.Description = NotifyConfig.Description or "Notification"
    NotifyConfig.Content     = NotifyConfig.Content or "Content"
    NotifyConfig.Color       = getColor(NotifyConfig.Color or Color3.fromRGB(0, 208, 255))
    NotifyConfig.Time        = NotifyConfig.Time or 0.5
    NotifyConfig.Delay       = NotifyConfig.Delay or 5

    local NotifyFunction = {}

    spawn(function()
        if not CoreGui:FindFirstChild("NotifyGui") then
            local NotifyGui = Instance.new("ScreenGui")
            NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            NotifyGui.Name = "NotifyGui"
            NotifyGui.Parent = CoreGui
        end

        if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
            local NotifyLayout = Instance.new("Frame")
            NotifyLayout.AnchorPoint = Vector2.new(1, 1)
            NotifyLayout.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            NotifyLayout.BackgroundTransparency = 0.999
            NotifyLayout.BorderSizePixel = 0
            NotifyLayout.Position = UDim2.new(1, -30, 1, -30)
            NotifyLayout.Size = UDim2.new(0, 320, 1, 0)
            NotifyLayout.Name = "NotifyLayout"
            NotifyLayout.Parent = CoreGui.NotifyGui

            local Count = 0
            CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(function()
                Count = 0
                for _, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
                    TweenService:Create(
                        v,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                        { Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * Count)) }
                    ):Play()
                    Count = Count + 1
                end
            end)
        end

        local NotifyPosHeigh = 0
        for _, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
            NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
        end

        local NotifyFrame     = Instance.new("Frame")
        local NotifyFrameReal = Instance.new("Frame")
        local UICorner        = Instance.new("UICorner")
        local UIStroke        = Instance.new("UIStroke")
        local LeftIcon        = Instance.new("ImageLabel")
        local LeftIconCorner  = Instance.new("UICorner")
        local ContentFrame    = Instance.new("Frame")
        local Top             = Instance.new("Frame")
        local TitleLabel      = Instance.new("TextLabel")
        local DescLabel       = Instance.new("TextLabel")
        local Close           = Instance.new("TextButton")
        local CloseImg        = Instance.new("ImageLabel")
        local ContentLabel    = Instance.new("TextLabel")

        NotifyFrame.BackgroundTransparency = 1
        NotifyFrame.BorderSizePixel = 0
        NotifyFrame.Size = UDim2.new(1, 0, 0, 70)
        NotifyFrame.Name = "NotifyFrame"
        NotifyFrame.AnchorPoint = Vector2.new(0, 1)
        NotifyFrame.Position = UDim2.new(0, 0, 1, -NotifyPosHeigh)
        NotifyFrame.Parent = CoreGui.NotifyGui.NotifyLayout

        NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        NotifyFrameReal.BorderSizePixel = 0
        NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
        NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
        NotifyFrameReal.Name = "NotifyFrameReal"
        NotifyFrameReal.Parent = NotifyFrame

        UICorner.CornerRadius = UDim.new(0, 10)
        UICorner.Parent = NotifyFrameReal

        UIStroke.Color = Color3.fromRGB(40, 40, 45)
        UIStroke.Thickness = 1
        UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        UIStroke.Parent = NotifyFrameReal

        LeftIcon.Image = "rbxassetid://17495379799"
        LeftIcon.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        LeftIcon.BackgroundTransparency = 0
        LeftIcon.BorderSizePixel = 0
        LeftIcon.Position = UDim2.new(0, 0, 0, 0)
        LeftIcon.Size = UDim2.new(0, 55, 1, 0)
        LeftIcon.ScaleType = Enum.ScaleType.Fit
        LeftIcon.Parent = NotifyFrameReal
        
        LeftIconCorner.Parent = LeftIcon
        LeftIconCorner.CornerRadius = UDim.new(0, 10)

        local contentX = hasIcon and 55 or 0
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.BorderSizePixel = 0
        ContentFrame.Position = UDim2.new(0, contentX, 0, 0)
        ContentFrame.Size = UDim2.new(1, -contentX, 1, 0)
        ContentFrame.Name = "ContentFrame"
        ContentFrame.Parent = NotifyFrameReal

        Top.BackgroundTransparency = 1
        Top.BorderSizePixel = 0
        Top.Size = UDim2.new(1, 0, 0, 36)
        Top.Name = "Top"
        Top.Parent = ContentFrame

        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.Text = NotifyConfig.Title
        TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
        TitleLabel.TextSize = 14
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Size = UDim2.new(1, -50, 1, 0)
        TitleLabel.Position = UDim2.new(0, 10, 0, 0)
        TitleLabel.Parent = Top

        DescLabel.Font = Enum.Font.GothamMedium
        DescLabel.Text = NotifyConfig.Description
        DescLabel.TextColor3 = NotifyConfig.Color
        DescLabel.TextSize = 13
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.BackgroundTransparency = 1
        DescLabel.Size = UDim2.new(1, 0, 1, 0)
        DescLabel.Position = UDim2.new(0, TitleLabel.TextBounds.X + 15, 0, 0)
        DescLabel.Parent = Top

        Close.Text = ""
        Close.AnchorPoint = Vector2.new(1, 0.5)
        Close.BackgroundTransparency = 1
        Close.Position = UDim2.new(1, -8, 0.5, 0)
        Close.Size = UDim2.new(0, 24, 0, 24)
        Close.Name = "Close"
        Close.Parent = Top

        CloseImg.Image = "rbxassetid://9886659671"
        CloseImg.ImageColor3 = Color3.fromRGB(160, 160, 165)
        CloseImg.AnchorPoint = Vector2.new(0.5, 0.5)
        CloseImg.BackgroundTransparency = 1
        CloseImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        CloseImg.Size = UDim2.new(0.7, 0, 0.7, 0)
        CloseImg.Parent = Close

        ContentLabel.Font = Enum.Font.Gotham
        ContentLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
        ContentLabel.TextSize = 13
        ContentLabel.Text = NotifyConfig.Content
        ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
        ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.Position = UDim2.new(0, 10, 0, 30)
        ContentLabel.Size = UDim2.new(1, -20, 0, 13)
        ContentLabel.TextWrapped = true
        ContentLabel.Parent = ContentFrame
        ContentLabel.Size = UDim2.new(1, -20, 0, 13 + (13 * (ContentLabel.TextBounds.X // ContentLabel.AbsoluteSize.X)))

        if ContentLabel.AbsoluteSize.Y < 27 then
            NotifyFrame.Size = UDim2.new(1, 0, 0, 70)
        else
            NotifyFrame.Size = UDim2.new(1, 0, 0, ContentLabel.AbsoluteSize.Y + 43)
        end

        local waitbruh = false
        function NotifyFunction:Close()
            if waitbruh then return false end
            waitbruh = true
            TweenService:Create(
                NotifyFrameReal,
                TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                { Position = UDim2.new(0, 400, 0, 0) }
            ):Play()
            task.wait(tonumber(NotifyConfig.Time) / 1.2)
            NotifyFrame:Destroy()
        end

        Close.Activated:Connect(function()
            NotifyFunction:Close()
        end)

        TweenService:Create(
            NotifyFrameReal,
            TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Position = UDim2.new(0, 0, 0, 0) }
        ):Play()

        task.wait(tonumber(NotifyConfig.Delay))
        NotifyFunction:Close()
    end)

    return NotifyFunction
end

function lexs(msg, delay, color, title, desc)
    return LexsUI:MakeNotify({
        Title       = title or "Lexs Hub",
        Description = desc or "Notification",
        Content     = msg or "Content",
        Color       = color or Color3.fromRGB(0, 208, 255),
        Delay       = delay or 4,
    })
end

Notify = Nt

function LexsUI:Dialog(DialogConfig)
    return DialogModule(DialogConfig)
end

function LexsUI:AddConfigSection(Tab, SectionConfig)
    local sectionName, sectionIcon
    if type(SectionConfig) == "string" then
        sectionName = SectionConfig
        sectionIcon = ""
    elseif type(SectionConfig) == "table" then
        sectionName = SectionConfig.Name or "Configuration"
        sectionIcon = SectionConfig.Icon or ""
    else
        sectionName = "Configuration"
        sectionIcon = ""
    end

    local cfgFolder = ConfigFolder .. "/Config"

    if isfolder and makefolder then
        if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
        if not isfolder(cfgFolder)    then makefolder(cfgFolder)    end
    end

    local AUTOLOAD_FILE   = ConfigFolder .. "/autoload.txt"
    local currentAutoload = ""
    if isfile and isfile(AUTOLOAD_FILE) then
        pcall(function() currentAutoload = readfile(AUTOLOAD_FILE) end)
    end

    local function toPath(name)
        return cfgFolder .. "/" .. name .. ".json"
    end

    local function getList()
        local list = {}
        if not (listfiles and isfolder) then return list end
        local ok, files = pcall(listfiles, cfgFolder)
        if not ok then return list end
        for _, path in ipairs(files) do
            local n = path:match("([^/\\]+)%.json$")
            if n then table.insert(list, n) end
        end
        table.sort(list)
        return list
    end

    local function saveConfig(name)
        if not writefile then return false end
        ConfigData._version = CURRENT_VERSION
        local ok = pcall(writefile, toPath(name), HttpService:JSONEncode(ConfigData))
        return ok
    end

    local function loadConfig(name)
        local path = toPath(name)
        if not (isfile and isfile(path)) then return false end
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if ok and type(data) == "table" then
            if data._version == CURRENT_VERSION then
                ConfigData = data
                LoadConfigElements()
                return true
            else
                Nt("Version mismatch on '" .. name .. "'!", 3, Color3.fromRGB(255, 165, 0))
            end
        end
        return false
    end

    local function deleteConfig(name)
        local path = toPath(name)
        if isfile and isfile(path) then
            pcall(delfile, path)
            return true
        end
        return false
    end

    local function setAutoload(name)
        if writefile then
            pcall(writefile, AUTOLOAD_FILE, name)
            currentAutoload = name
        end
    end

    local function clearAutoload()
        if isfile and isfile(AUTOLOAD_FILE) then
            pcall(delfile, AUTOLOAD_FILE)
        end
        currentAutoload = ""
    end

    local Sections = Tab:AddSection({ Title = sectionName, Icon = sectionIcon, Open = true })

    local selectedConfig = nil
    local dropdownRef    = nil
    local autoloadLabel  = nil

    local nameInput = Sections:AddInput({
        Title       = "Config name",
        Placeholder = "Enter config name...",
        Default     = "",
        Flag        = "CHX_ConfigNameInput",
        Callback    = function() end,
    })

    Sections:AddButton({
        Title    = "Create config",
        Version  = "V2",
        Icon     = "lucide:file-plus",
        Callback = function()
            local raw  = nameInput and nameInput.Value or ""
            local name = raw:match("^%s*(.-)%s*$"):gsub("[^%w_%-]", "_")
            if name == "" then
                Nt("Config name cannot be empty!", 3, Color3.fromRGB(255, 80, 80))
                return
            end
            if saveConfig(name) then
                Nt("Config '" .. name .. "' created!", 3, Color3.fromRGB(80, 220, 100))
                if dropdownRef then
                    dropdownRef:SetValues(getList(), selectedConfig)
                end
            else
                Nt("Failed to create config!", 3, Color3.fromRGB(255, 80, 80))
            end
        end,
    })

    dropdownRef = Sections:AddDropdown({
        Title    = "Config list",
        Options  = getList(),
        Default  = nil,
        Flag     = "CHX_ConfigListDropdown",
        Callback = function(val)
            selectedConfig = val
        end,
    })

    Sections:AddButton({
        Title    = "Load config",
        Version  = "V2",
        Icon     = "lucide:folder-open",
        Callback = function()
            if not selectedConfig then
                Nt("Select a config first!", 3, Color3.fromRGB(255, 165, 0))
                return
            end
            if loadConfig(selectedConfig) then
                Nt("Loaded '" .. selectedConfig .. "'!", 3, Color3.fromRGB(80, 220, 100))
            else
                Nt("Failed to load config!", 3, Color3.fromRGB(255, 80, 80))
            end
        end,
    })

    Sections:AddButton({
        Title    = "Overwrite config",
        Version  = "V2",
        Icon     = "lucide:save",
        Callback = function()
            if not selectedConfig then
                Nt("Select a config first!", 3, Color3.fromRGB(255, 165, 0))
                return
            end
            if saveConfig(selectedConfig) then
                Nt("Overwritten '" .. selectedConfig .. "'!", 3, Color3.fromRGB(80, 220, 100))
            else
                Nt("Failed to overwrite config!", 3, Color3.fromRGB(255, 80, 80))
            end
        end,
    })

    Sections:AddButton({
        Title    = "Delete config",
        Version  = "V2",
        Icon     = "lucide:trash-2",
        Callback = function()
            if not selectedConfig then
                Nt("Select a config first!", 3, Color3.fromRGB(255, 165, 0))
                return
            end
            local name = selectedConfig
            if deleteConfig(name) then
                if currentAutoload == name then
                    clearAutoload()
                    if autoloadLabel then
                        autoloadLabel:SetContent("none")
                    end
                end
                selectedConfig = nil
                if dropdownRef then
                    dropdownRef:SetValues(getList(), nil)
                end
                Nt("Deleted '" .. name .. "'!", 3, Color3.fromRGB(80, 220, 100))
            else
                Nt("Failed to delete config!", 3, Color3.fromRGB(255, 80, 80))
            end
        end,
    })

    Sections:AddButton({
        Title    = "Refresh list",
        Version  = "V2",
        Icon     = "lucide:refresh-cw",
        Callback = function()
            if dropdownRef then
                dropdownRef:SetValues(getList(), selectedConfig)
            end
            Nt("List refreshed!", 2, Color3.fromRGB(80, 180, 255))
        end,
    })

    Sections:AddButton({
        Title    = "Set as autoload",
        Version  = "V2",
        Icon     = "lucide:star",
        Callback = function()
            if not selectedConfig then
                Nt("Select a config first!", 3, Color3.fromRGB(255, 165, 0))
                return
            end
            setAutoload(selectedConfig)
            if autoloadLabel then
                autoloadLabel:SetContent(selectedConfig)
            end
            Nt("Autoload set to '" .. selectedConfig .. "'!", 3, Color3.fromRGB(80, 220, 100))
        end,
    })

    Sections:AddButton({
        Title    = "Reset autoload",
        Version  = "V2",
        Icon     = "lucide:star-off",
        Callback = function()
            clearAutoload()
            if autoloadLabel then
                autoloadLabel:SetContent("none")
            end
            Nt("Autoload cleared!", 2, Color3.fromRGB(255, 165, 0))
        end,
    })

    autoloadLabel = Sections:AddParagraph({
        Title   = "Current autoload config",
        Content = currentAutoload ~= "" and currentAutoload or "none",
    })

    if currentAutoload ~= "" then
        task.defer(function()
            task.wait(0.5)
            if loadConfig(currentAutoload) then
                Nt("Auto-loaded: " .. currentAutoload, 3, Color3.fromRGB(80, 220, 100))
            end
        end)
    end

    return Sections
end

function LexsUI:Window(GuiConfig)
    GuiConfig               = GuiConfig or {}
    GuiConfig.Title         = GuiConfig.Title or "Lexs Hub"
    GuiConfig.Footer        = GuiConfig.Footer or "Lexs"
    GuiConfig.Content       = GuiConfig.Content or ""
    GuiConfig.ShowUser      = GuiConfig.ShowUser or false
    GuiConfig.Color         = getColor(GuiConfig.Color or "Default")
    GuiConfig["Tab Width"]  = GuiConfig["Tab Width"] or 120
    GuiConfig.Version       = GuiConfig.Version or 1
    GuiConfig.Uitransparent = GuiConfig.Uitransparent or 0.15
    GuiConfig.Image         = GuiConfig.Image or "103875081318049"
    GuiConfig.Icon          = GuiConfig.Icon or "rbxassetid://103875081318049
    GuiConfig.Configname    = GuiConfig.Configname or "Lexs UI"
    GuiConfig.Size          = GuiConfig.Size or UDim2.fromOffset(640, 400)
    GuiConfig.Search        = GuiConfig.Search ~= nil and GuiConfig.Search or false
    GuiConfig.BackgroundVideo = GuiConfig.BackgroundVideo or ""

    GuiConfig.Config = GuiConfig.Config or {}
    GuiConfig.Config.AutoSave = GuiConfig.Config.AutoSave ~= nil and GuiConfig.Config.AutoSave or true
    GuiConfig.Config.AutoLoad = GuiConfig.Config.AutoLoad ~= nil and GuiConfig.Config.AutoLoad or true

    CURRENT_VERSION = GuiConfig.Version
    AUTO_SAVE       = GuiConfig.Config.AutoSave
    AUTO_LOAD       = GuiConfig.Config.AutoLoad

    ConfigFolder = GuiConfig.Configname

    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    if not isfolder(ConfigFolder .. "/Config") then makefolder(ConfigFolder .. "/Config") end

    local gameName = tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
    gameName = gameName:gsub("[^%w_ ]", "")
    gameName = gameName:gsub("%s+", "_")
    ConfigFile = ConfigFolder .. "/Config/CHX_" .. gameName .. ".json"

    if AUTO_LOAD then LoadConfigFromFile() end

    ElementsModule:Initialize(GuiConfig, SaveConfig, ConfigData, Icons)

    local ks = GuiConfig.KeySystem
    if ks then
        local keyResolved = false

        local KsGui = Instance.new("ScreenGui")
        KsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        KsGui.Name = "KeySystemGui"
        KsGui.ResetOnSpawn = false
        KsGui.Parent = CoreGui

        local Card = Instance.new("Frame")
        Card.AnchorPoint = Vector2.new(0.5, 0.5)
        Card.Position = UDim2.new(0.5, 0, 0.45, 0)
        Card.Size = UDim2.new(0, 300, 0, 178)
        Card.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
        Card.BackgroundTransparency = 1
        Card.BorderSizePixel = 0
        Card.ZIndex = 101
        Card.Parent = KsGui

        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 10)
        CardCorner.Parent = Card

        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = Color3.fromRGB(38, 38, 48)
        CardStroke.Thickness = 1
        CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        CardStroke.Parent = Card

        local IconBox = Instance.new("Frame")
        IconBox.Size = UDim2.new(0, 24, 0, 24)
        IconBox.Position = UDim2.new(0, 14, 0, 16)
        IconBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        IconBox.BorderSizePixel = 0
        IconBox.ZIndex = 102
        IconBox.Parent = Card
        local IconBoxCorner = Instance.new("UICorner")
        IconBoxCorner.CornerRadius = UDim.new(0, 6)
        IconBoxCorner.Parent = IconBox
        local IconBoxStroke = Instance.new("UIStroke")
        IconBoxStroke.Color = Color3.fromRGB(50, 50, 62)
        IconBoxStroke.Thickness = 1
        IconBoxStroke.Parent = IconBox

        local KsIconImg = Instance.new("ImageLabel")
        KsIconImg.AnchorPoint = Vector2.new(0.5, 0.5)
        KsIconImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        KsIconImg.Size = UDim2.new(0, 13, 0, 13)
        KsIconImg.BackgroundTransparency = 1
        KsIconImg.BorderSizePixel = 0
        local ksIconId = getIconId(ks.Icon or "")
        KsIconImg.Image = (ksIconId ~= "") and ksIconId or "rbxassetid://6031094678"
        KsIconImg.ImageColor3 = Color3.fromRGB(180, 180, 190)
        KsIconImg.ScaleType = Enum.ScaleType.Fit
        KsIconImg.ZIndex = 103
        KsIconImg.Parent = IconBox

        local KsTitle = Instance.new("TextLabel")
        KsTitle.Font = Enum.Font.GothamBold
        KsTitle.Text = ks.Title or GuiConfig.Title or "Key System"
        KsTitle.TextColor3 = Color3.fromRGB(232, 232, 238)
        KsTitle.TextSize = 14
        KsTitle.TextXAlignment = Enum.TextXAlignment.Left
        KsTitle.BackgroundTransparency = 1
        KsTitle.BorderSizePixel = 0
        KsTitle.AnchorPoint = Vector2.new(0, 0.5)
        KsTitle.Position = UDim2.new(0, 44, 0, 28)
        KsTitle.Size = UDim2.new(1, -58, 0, 18)
        KsTitle.ZIndex = 102
        KsTitle.Parent = Card

        local HDivider = Instance.new("Frame")
        HDivider.Size = UDim2.new(1, 0, 0, 1)
        HDivider.Position = UDim2.new(0, 0, 0, 50)
        HDivider.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
        HDivider.BorderSizePixel = 0
        HDivider.ZIndex = 102
        HDivider.Parent = Card

        local KsNote = Instance.new("TextLabel")
        KsNote.Font = Enum.Font.Gotham
        KsNote.Text = ks.Note or ""
        KsNote.TextColor3 = Color3.fromRGB(95, 95, 108)
        KsNote.TextSize = 12
        KsNote.TextXAlignment = Enum.TextXAlignment.Left
        KsNote.BackgroundTransparency = 1
        KsNote.BorderSizePixel = 0
        KsNote.Position = UDim2.new(0, 14, 0, 60)
        KsNote.Size = UDim2.new(1, -28, 0, 14)
        KsNote.ZIndex = 102
        KsNote.Parent = Card

        local InputBg = Instance.new("Frame")
        InputBg.Position = UDim2.new(0, 14, 0, 84)
        InputBg.Size = UDim2.new(1, -28, 0, 32)
        InputBg.BackgroundColor3 = Color3.fromRGB(22, 22, 29)
        InputBg.BorderSizePixel = 0
        InputBg.ZIndex = 102
        InputBg.Parent = Card
        local InputBgCorner = Instance.new("UICorner")
        InputBgCorner.CornerRadius = UDim.new(0, 7)
        InputBgCorner.Parent = InputBg
        local InputBgStroke = Instance.new("UIStroke")
        InputBgStroke.Color = Color3.fromRGB(44, 44, 56)
        InputBgStroke.Thickness = 1
        InputBgStroke.Parent = InputBg

        local InputIcon = Instance.new("ImageLabel")
        InputIcon.AnchorPoint = Vector2.new(0, 0.5)
        InputIcon.Position = UDim2.new(0, 9, 0.5, 0)
        InputIcon.Size = UDim2.new(0, 13, 0, 13)
        InputIcon.BackgroundTransparency = 1
        InputIcon.Image = "rbxassetid://6031094678"
        InputIcon.ImageColor3 = Color3.fromRGB(75, 75, 88)
        InputIcon.ScaleType = Enum.ScaleType.Fit
        InputIcon.ZIndex = 103
        InputIcon.Parent = InputBg

        local KsInput = Instance.new("TextBox")
        KsInput.Font = Enum.Font.Gotham
        KsInput.PlaceholderText = ks.Placeholder or "Enter Key"
        KsInput.PlaceholderColor3 = Color3.fromRGB(65, 65, 78)
        KsInput.Text = ks.Default or ""
        KsInput.TextColor3 = Color3.fromRGB(210, 210, 222)
        KsInput.TextSize = 12
        KsInput.TextXAlignment = Enum.TextXAlignment.Left
        KsInput.BackgroundTransparency = 1
        KsInput.BorderSizePixel = 0
        KsInput.ClearTextOnFocus = false
        KsInput.Position = UDim2.new(0, 28, 0, 0)
        KsInput.Size = UDim2.new(1, -34, 1, 0)
        KsInput.ZIndex = 103
        KsInput.Parent = InputBg

        KsInput.Focused:Connect(function()
            TweenService:Create(InputBgStroke, TweenInfo.new(0.18), {
                Color = GuiConfig.Color, Transparency = 0.45
            }):Play()
        end)
        KsInput.FocusLost:Connect(function()
            TweenService:Create(InputBgStroke, TweenInfo.new(0.18), {
                Color = Color3.fromRGB(44, 44, 56), Transparency = 0
            }):Play()
        end)

        local BDivider = Instance.new("Frame")
        BDivider.Size = UDim2.new(1, 0, 0, 1)
        BDivider.Position = UDim2.new(0, 0, 0, 128)
        BDivider.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
        BDivider.BorderSizePixel = 0
        BDivider.ZIndex = 102
        BDivider.Parent = Card

        local BtnRow = Instance.new("Frame")
        BtnRow.BackgroundTransparency = 1
        BtnRow.BorderSizePixel = 0
        BtnRow.Position = UDim2.new(0, 14, 0, 136)
        BtnRow.Size = UDim2.new(1, -28, 0, 30)
        BtnRow.ZIndex = 102
        BtnRow.Parent = Card

        local BtnList = Instance.new("UIListLayout")
        BtnList.FillDirection = Enum.FillDirection.Horizontal
        BtnList.HorizontalAlignment = Enum.HorizontalAlignment.Right
        BtnList.VerticalAlignment = Enum.VerticalAlignment.Center
        BtnList.Padding = UDim.new(0, 6)
        BtnList.SortOrder = Enum.SortOrder.LayoutOrder
        BtnList.Parent = BtnRow

        local function ShakeCard()
            local origPos = Card.Position
            local offsets = {7, -7, 5, -5, 3, -3, 0}
            for _, ox in ipairs(offsets) do
                Card.Position = UDim2.new(
                    origPos.X.Scale, origPos.X.Offset + ox,
                    origPos.Y.Scale, origPos.Y.Offset
                )
                task.wait(0.04)
            end
            Card.Position = origPos
        end

        local ksClosing = false
        local function CloseKeySystem()
            if ksClosing then return end
            ksClosing = true
            TweenService:Create(Card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0.56, 0),
                BackgroundTransparency = 1,
            }):Play()
            task.delay(0.25, function()
                pcall(function() KsGui:Destroy() end)
            end)
        end

        local buttons = ks.Buttons or {}
        if #buttons == 0 then
            buttons = {
                { Name = "Exit" },
                { Name = "Submit" },
            }
        end

        for i, btnCfg in ipairs(buttons) do
            local isPrimary = (btnCfg.Style == "primary")
                or (btnCfg.Name == "Submit")
                or (i == #buttons)

            local Btn = Instance.new("TextButton")
            Btn.Font = Enum.Font.GothamBold
            Btn.Text = ""
            Btn.AutomaticSize = Enum.AutomaticSize.X
            Btn.Size = UDim2.new(0, 0, 1, 0)
            Btn.BorderSizePixel = 0
            Btn.LayoutOrder = i
            Btn.ZIndex = 103
            Btn.Parent = BtnRow

            if isPrimary then
                Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 62)
                Btn.BackgroundTransparency = 0
            else
                Btn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
                Btn.BackgroundTransparency = 0
            end

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 7)
            BtnCorner.Parent = Btn

            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = isPrimary and Color3.fromRGB(65, 65, 80) or Color3.fromRGB(44, 44, 56)
            BtnStroke.Thickness = 1
            BtnStroke.Parent = Btn

            local BtnPadding = Instance.new("UIPadding")
            BtnPadding.PaddingLeft  = UDim.new(0, 10)
            BtnPadding.PaddingRight = UDim.new(0, 10)
            BtnPadding.Parent = Btn

            local BtnInner = Instance.new("Frame")
            BtnInner.BackgroundTransparency = 1
            BtnInner.BorderSizePixel = 0
            BtnInner.AutomaticSize = Enum.AutomaticSize.X
            BtnInner.Size = UDim2.new(0, 0, 1, 0)
            BtnInner.ZIndex = 103
            BtnInner.Parent = Btn

            local BtnInnerList = Instance.new("UIListLayout")
            BtnInnerList.FillDirection = Enum.FillDirection.Horizontal
            BtnInnerList.VerticalAlignment = Enum.VerticalAlignment.Center
            BtnInnerList.Padding = UDim.new(0, 5)
            BtnInnerList.Parent = BtnInner

            local iconId = getIconId(btnCfg.Icon or "")
            if iconId and iconId ~= "" then
                local BtnIcon = Instance.new("ImageLabel")
                BtnIcon.BackgroundTransparency = 1
                BtnIcon.BorderSizePixel = 0
                BtnIcon.Size = UDim2.new(0, 12, 0, 12)
                BtnIcon.Image = iconId
                BtnIcon.ImageColor3 = Color3.fromRGB(180, 180, 195)
                BtnIcon.ScaleType = Enum.ScaleType.Fit
                BtnIcon.LayoutOrder = 0
                BtnIcon.ZIndex = 104
                BtnIcon.Parent = BtnInner
            end

            local BtnLabel = Instance.new("TextLabel")
            BtnLabel.Font = Enum.Font.GothamBold
            BtnLabel.Text = btnCfg.Name or "Button"
            BtnLabel.TextColor3 = Color3.fromRGB(195, 195, 208)
            BtnLabel.TextSize = 12
            BtnLabel.BackgroundTransparency = 1
            BtnLabel.BorderSizePixel = 0
            BtnLabel.AutomaticSize = Enum.AutomaticSize.X
            BtnLabel.Size = UDim2.new(0, 0, 1, 0)
            BtnLabel.LayoutOrder = 1
            BtnLabel.ZIndex = 104
            BtnLabel.Parent = BtnInner

            local normBg = isPrimary and Color3.fromRGB(50,50,62) or Color3.fromRGB(26,26,34)
            local hovBg  = isPrimary and Color3.fromRGB(62,62,78) or Color3.fromRGB(34,34,44)
            Btn.MouseEnter:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.12), { BackgroundColor3 = hovBg }):Play()
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.12), { BackgroundColor3 = normBg }):Play()
            end)

            Btn.MouseButton1Click:Connect(function()
                local currentKey = KsInput.Text
                if btnCfg.Callback then
                    pcall(function()
                        local result = btnCfg.Callback(currentKey)
                        if result == true then
                            keyResolved = true
                            CloseKeySystem()
                        elseif result == false then
                            TweenService:Create(InputBgStroke, TweenInfo.new(0.1), {
                                Color = Color3.fromRGB(220, 55, 55), Transparency = 0
                            }):Play()
                            task.delay(0.7, function()
                                TweenService:Create(InputBgStroke, TweenInfo.new(0.3), {
                                    Color = Color3.fromRGB(44,44,56), Transparency = 0
                                }):Play()
                            end)
                            task.spawn(ShakeCard)
                        else
                            local isCloseBtn = btnCfg.Close == true
                                or btnCfg.Name == "Exit"
                                or btnCfg.Name == "Close"
                                or btnCfg.Name == "Cancel"
                            if isCloseBtn then
                                CloseKeySystem()
                            end
                        end
                    end)
                else
                    CloseKeySystem()
                end
            end)
        end

        TweenService:Create(Card, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 0,
        }):Play()

        repeat task.wait(0.1) until keyResolved or not KsGui.Parent

        if not keyResolved then
            pcall(function() KsGui:Destroy() end)
            return nil
        end
    end

    local GuiFunc = {}

    local Lexsss           = Instance.new("ScreenGui")
    local DropShadowHolder  = Instance.new("Frame")
    local DropShadow        = Instance.new("ImageLabel")
    local Main              = Instance.new("Frame")
    local UICorner          = Instance.new("UICorner")
    local MainStroke        = Instance.new("UIStroke")
    local Top               = Instance.new("Frame")
    local TitleIcon         = Instance.new("ImageLabel")
    local TextLabel         = Instance.new("TextLabel")
    local UICorner1         = Instance.new("UICorner")
    local TextLabel1        = Instance.new("TextLabel")
    local Close             = Instance.new("TextButton")
    local ImageLabel1       = Instance.new("ImageLabel")
    local Min               = Instance.new("TextButton")
    local ImageLabel2       = Instance.new("ImageLabel")

    Lexsss.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Lexsss.Name = "Lexsss"
    Lexsss.ResetOnSpawn = false
    Lexsss.Parent = game:GetService("CoreGui")

    DropShadowHolder.BackgroundTransparency = 1
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)

    local baseW = GuiConfig.Size.X.Offset
    local baseH = GuiConfig.Size.Y.Offset
    if isMobile then
        DropShadowHolder.Size = safeSize(math.min(baseW, 470), math.min(baseH, 270))
    else
        DropShadowHolder.Size = safeSize(baseW, baseH)
    end

    DropShadowHolder.ZIndex = 0
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = Lexsss

    DropShadowHolder.Position = UDim2.new(
        0, (Lexsss.AbsoluteSize.X // 2 - DropShadowHolder.Size.X.Offset // 2),
        0, (Lexsss.AbsoluteSize.Y // 2 - DropShadowHolder.Size.Y.Offset // 2)
    )

    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
    DropShadow.ImageTransparency = 1
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.BorderSizePixel = 0
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 47, 1, 47)
    DropShadow.ZIndex = 0
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder

    if GuiConfig.Theme then
        Main:Destroy()
        Main = Instance.new("ImageLabel")
        Main.Image = "rbxassetid://" .. GuiConfig.Theme
        Main.ScaleType = Enum.ScaleType.Crop
        Main.BackgroundTransparency = 1
        Main.ImageTransparency = GuiConfig.ThemeTransparency or GuiConfig.Uitransparent or 0.15
    else
        Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Main.BackgroundTransparency = GuiConfig.Uitransparent
    end

    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, -47, 1, -47)
    Main.Name = "Main"
    Main.Parent = DropShadow

    MainStroke.Thickness = 1.2
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Transparency = 0.6
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = Main

    UICorner.Parent = Main

    local ColorTint = Instance.new("Frame")
    ColorTint.Name = "ColorTint"
    ColorTint.Size = UDim2.new(1, 0, 1, 0)
    ColorTint.BackgroundColor3 = GuiConfig.Color
    ColorTint.BackgroundTransparency = 0.93
    ColorTint.BorderSizePixel = 0
    ColorTint.ZIndex = 0

    local ImageWrapper = Instance.new("Frame")
    ImageWrapper.Name = "ImageWrapper"
    ImageWrapper.Parent = Main
    ImageWrapper.BackgroundTransparency = 1
    ImageWrapper.Size = UDim2.new(1, 0, 1, 0)
    ImageWrapper.Position = UDim2.new(0, 0, 0, 0)
    ImageWrapper.ZIndex = 0
    ImageWrapper.ClipsDescendants = true
    ColorTint.Parent = Main

    local ThemeImage = Instance.new("ImageLabel")
    ThemeImage.Name = "ThemeImage"
    ThemeImage.Parent = ImageWrapper
    ThemeImage.BackgroundTransparency = 1
    ThemeImage.AnchorPoint = Vector2.new(1, 1)
    ThemeImage.Position = UDim2.new(1, 0, 1, 0)
    ThemeImage.Size = UDim2.new(0.55, 0, 1.0, 0)
    ThemeImage.ZIndex = 0
    ThemeImage.Image = "rbxassetid://4953666718"
    ThemeImage.ImageTransparency = 1
    ThemeImage.ScaleType = Enum.ScaleType.Fit

    local ThemeGradient = Instance.new("UIGradient")
    ThemeGradient.Rotation = 135
    ThemeGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.45, 0.8),
        NumberSequenceKeypoint.new(0.75, 0.2),
        NumberSequenceKeypoint.new(1, 0)
    })
    ThemeGradient.Parent = ThemeImage

    if GuiConfig.BackgroundVideo ~= "" then
        local VideoFrame = Instance.new("VideoFrame")
        VideoFrame.Name = "BackgroundVideo"
        VideoFrame.Parent = ImageWrapper
        VideoFrame.BackgroundTransparency = 1
        VideoFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        VideoFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        VideoFrame.Size = UDim2.new(1, 0, 1, 0)
        VideoFrame.ZIndex = 0
        VideoFrame.Video = "rbxassetid://" .. GuiConfig.BackgroundVideo
        VideoFrame.Volume = 0
        VideoFrame.Looped = true
        VideoFrame.Playing = true
        local VideoCorner = Instance.new("UICorner")
        VideoCorner.CornerRadius = UDim.new(0, 8)
        VideoCorner.Parent = VideoFrame
        local VideoGradient = Instance.new("UIGradient")
        VideoGradient.Rotation = 135
        VideoGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.4),
            NumberSequenceKeypoint.new(0.5, 0.15),
            NumberSequenceKeypoint.new(1, 0)
        })
        VideoGradient.Parent = VideoFrame
        VideoFrame:GetPropertyChangedSignal("IsLoaded"):Connect(function()
            if VideoFrame.IsLoaded then
                VideoFrame.Playing = true
            end
        end)
    end

    Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Top.BackgroundTransparency = 0.999
    Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 38)
    Top.Name = "Top"
    Top.Parent = Main

    TitleIcon.Name = "TitleIcon"
    TitleIcon.Parent = Top
    TitleIcon.BackgroundTransparency = 1
    TitleIcon.BorderSizePixel = 0
    TitleIcon.AnchorPoint = Vector2.new(0, 0.5)
    TitleIcon.Position = UDim2.new(0, 10, 0.5, 0)
    TitleIcon.Size = UDim2.new(0, 20, 0, 20)
    TitleIcon.Image = "rbxassetid://" .. GuiConfig.Image

    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Text = ""
    TextLabel.TextColor3 = GuiConfig.Color
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 0.999
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Size = UDim2.new(1, -135, 1, 0)
    TextLabel.Position = UDim2.new(0, 35, 0, 0)
    TextLabel.Parent = Top

    UICorner1.Parent = Top

    TextLabel1.Font = Enum.Font.GothamBold
    TextLabel1.Text = ""
    TextLabel1.TextColor3 = GuiConfig.Color
    TextLabel1.TextSize = 14
    TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel1.BackgroundTransparency = 0.999
    TextLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel1.BorderSizePixel = 0
    TextLabel1.Size = UDim2.new(1, -(TextLabel.TextBounds.X + 104), 1, 0)
    TextLabel1.Position = UDim2.new(0, 25 + TextLabel.TextBounds.X + 10, 0, 0)
    TextLabel1.Parent = Top

    local TagContainer = Instance.new("Frame")
    TagContainer.Name = "TagContainer"
    TagContainer.BackgroundTransparency = 1
    TagContainer.BorderSizePixel = 0
    TagContainer.ClipsDescendants = false
    TagContainer.AnchorPoint = Vector2.new(1, 0.5)
    TagContainer.Position = UDim2.new(1, -70, 0.5, 0)
    TagContainer.Size = UDim2.new(0, 200, 0, 26)
    TagContainer.ZIndex = 2
    TagContainer.Parent = Top

    local TagListLayout = Instance.new("UIListLayout")
    TagListLayout.FillDirection = Enum.FillDirection.Horizontal
    TagListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    TagListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TagListLayout.Padding = UDim.new(0, 5)
    TagListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TagListLayout.Parent = TagContainer

    local function UpdateTagPosition()
        local titleW  = TextLabel.TextBounds.X
        local footerW = TextLabel1.TextBounds.X
        local textEnd = 35 + titleW + 10 + footerW + 10
        local rightBound = -70
        local availableW = Top.AbsoluteSize.X + rightBound - textEnd
        if availableW < 0 then availableW = 0 end
        TagContainer.Size = UDim2.new(0, math.min(availableW, 300), 0, 26)
        TagContainer.Position = UDim2.new(1, rightBound, 0.5, 0)
    end

    TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(UpdateTagPosition)
    TextLabel1:GetPropertyChangedSignal("TextBounds"):Connect(UpdateTagPosition)
    Top:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateTagPosition)
    UpdateTagPosition()

    local function UpdateFooterPosition()
        local titleWidth = TextLabel.TextBounds.X
        TextLabel1.Position = UDim2.new(0, 25 + titleWidth + 10, 0, 0)
        TextLabel1.Size = UDim2.new(1, -(titleWidth + 104), 1, 0)
        UpdateTagPosition()
    end

    TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(UpdateFooterPosition)
    UpdateFooterPosition()

    if GuiConfig.Animation then
        TextLabel1.Visible = false
        task.spawn(function()
            local function typeOut(text, charDelay)
                TextLabel.Text = ""
                for i = 1, #text do
                    TextLabel.Text = string.sub(text, 1, i)
                    task.wait(charDelay)
                end
            end

            local function typeErase(charDelay)
                local current = TextLabel.Text
                for i = #current, 1, -1 do
                    TextLabel.Text = string.sub(current, 1, i - 1)
                    task.wait(charDelay)
                end
                TextLabel.Text = ""
            end

            local titleText = GuiConfig.Title
            local footerText = GuiConfig.Footer
            local charDelay = GuiConfig.TypeDelay or 0.07
            local pauseTime = GuiConfig.TypePause or 2.5

            while true do
                typeOut(titleText, charDelay)
                task.wait(pauseTime)
                typeErase(charDelay)
                task.wait(0.15)
                typeOut(footerText, charDelay)
                task.wait(pauseTime)
                typeErase(charDelay)
                task.wait(0.15)
            end
        end)
    else
        TextLabel.Text  = GuiConfig.Title
        TextLabel1.Text = GuiConfig.Footer
    end

    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.TextColor3 = Color3.fromRGB(0, 0, 0)
    Close.TextSize = 14
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Close.BackgroundTransparency = 0.999
    Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(1, -8, 0.5, 0)
    Close.Size = UDim2.new(0, 25, 0, 25)
    Close.Name = "Close"
    Close.Parent = Top

    ImageLabel1.Image = "rbxassetid://9886659671"
    ImageLabel1.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel1.BackgroundTransparency = 0.999
    ImageLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel1.BorderSizePixel = 0
    ImageLabel1.Position = UDim2.new(0.49, 0, 0.5, 0)
    ImageLabel1.Size = UDim2.new(1, -8, 1, -8)
    ImageLabel1.Parent = Close

    Min.Font = Enum.Font.SourceSans
    Min.Text = ""
    Min.TextColor3 = Color3.fromRGB(0, 0, 0)
    Min.TextSize = 14
    Min.AnchorPoint = Vector2.new(1, 0.5)
    Min.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Min.BackgroundTransparency = 0.999
    Min.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Min.BorderSizePixel = 0
    Min.Position = UDim2.new(1, -38, 0.5, 0)
    Min.Size = UDim2.new(0, 25, 0, 25)
    Min.Name = "Min"
    Min.Parent = Top

    ImageLabel2.Image = "rbxassetid://9886659276"
    ImageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel2.BackgroundTransparency = 0.999
    ImageLabel2.ImageTransparency = 0.2
    ImageLabel2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel2.BorderSizePixel = 0
    ImageLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
    ImageLabel2.Size = UDim2.new(1, -9, 1, -9)
    ImageLabel2.Parent = Min

    if GuiConfig.Content and GuiConfig.Content ~= "" then
        local ContentFrame = Instance.new("Frame")
        ContentFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ContentFrame.BorderSizePixel = 0
        ContentFrame.Size = UDim2.new(1, 0, 0, 25)
        ContentFrame.Position = UDim2.new(0, 0, 0, 38)
        ContentFrame.Name = "ContentFrame"
        ContentFrame.Parent = Main

        local ContentLabel = Instance.new("TextLabel")
        ContentLabel.Font = Enum.Font.GothamBold
        ContentLabel.Text = GuiConfig.Content
        ContentLabel.TextColor3 = GuiConfig.Color
        ContentLabel.TextSize = 14
        ContentLabel.TextXAlignment = Enum.TextXAlignment.Center
        ContentLabel.TextYAlignment = Enum.TextYAlignment.Center
        ContentLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ContentLabel.BorderSizePixel = 0
        ContentLabel.Size = UDim2.new(1, -20, 1, 0)
        ContentLabel.Position = UDim2.new(0, 10, 0, 0)
        ContentLabel.Parent = ContentFrame

        local Divider = Instance.new("Frame")
        Divider.BackgroundColor3 = GuiConfig.Color
        Divider.BackgroundTransparency = 0.8
        Divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Divider.BorderSizePixel = 0
        Divider.Size = UDim2.new(1, -20, 0, 1)
        Divider.Position = UDim2.new(0, 10, 1, -1)
        Divider.Parent = ContentFrame
    end

    local LayersTab        = Instance.new("Frame")
    local UICorner2        = Instance.new("UICorner")
    local DecideFrame      = Instance.new("Frame")
    local Layers           = Instance.new("Frame")
    local UICorner6        = Instance.new("UICorner")
    local NameTab          = Instance.new("TextLabel")
    local LayersReal       = Instance.new("Frame")
    local LayersFolder     = Instance.new("Folder")
    local LayersPageLayout = Instance.new("UIPageLayout")

    local topOffset
    if GuiConfig.Content and GuiConfig.Content ~= "" then
        topOffset = 38 + 25 + 10
    else
        topOffset = 50
    end

    LayersTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LayersTab.BackgroundTransparency = 0.999
    LayersTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LayersTab.BorderSizePixel = 0
    LayersTab.Position = UDim2.new(0, 9, 0, topOffset)
    LayersTab.Size = UDim2.new(0, GuiConfig["Tab Width"], 1, -(topOffset + 9))
    LayersTab.Name = "LayersTab"
    LayersTab.Parent = Main

    UICorner2.CornerRadius = UDim.new(0, 2)
    UICorner2.Parent = LayersTab

    local ScrollTab    = Instance.new("ScrollingFrame")
    local UIListLayout = Instance.new("UIListLayout")

    ScrollTab.CanvasSize = UDim2.new(0, 0, 1.1, 0)
    ScrollTab.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    ScrollTab.ScrollBarThickness = 0
    ScrollTab.Active = true
    ScrollTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ScrollTab.BackgroundTransparency = 0.999
    ScrollTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ScrollTab.BorderSizePixel = 0
    ScrollTab.Name = "ScrollTab"

    local searchOffset = 0

    if GuiConfig.Search then
        searchOffset = 34
        SearchModule(GuiConfig, LayersTab, LayersFolder, LayersPageLayout, TweenService, searchOffset)
    end

    if GuiConfig.ShowUser then
        ScrollTab.Position = UDim2.new(0, 0, 0, searchOffset)
        ScrollTab.Size = UDim2.new(1, 0, 1, -(40 + searchOffset))
    else
        ScrollTab.Position = UDim2.new(0, 0, 0, searchOffset)
        ScrollTab.Size = UDim2.new(1, 0, 1, -searchOffset)
    end

    ScrollTab.Parent = LayersTab

    UIListLayout.Padding = UDim.new(0, 2)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollTab

    local function UpdateSize1()
        local OffsetY = 0
        for _, child in ScrollTab:GetChildren() do
            if child.Name ~= "UIListLayout" then
                OffsetY = OffsetY + 3 + child.Size.Y.Offset
            end
        end
        ScrollTab.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
    end
    ScrollTab.ChildAdded:Connect(UpdateSize1)
    ScrollTab.ChildRemoved:Connect(UpdateSize1)

    if GuiConfig.ShowUser then
        local PlayerFooter = Instance.new("Frame")
        PlayerFooter.Name = "PlayerFooter"
        PlayerFooter.AnchorPoint = Vector2.new(0, 1)
        PlayerFooter.BackgroundTransparency = 1
        PlayerFooter.BorderSizePixel = 0
        PlayerFooter.Position = UDim2.new(0, 3, 1, -3)
        PlayerFooter.Size = UDim2.new(1, -18, 0, 40)
        PlayerFooter.Parent = LayersTab
        PlayerFooter.ZIndex = 100

        local PlayerAvatar = Instance.new("ImageLabel")
        PlayerAvatar.Name = "PlayerAvatar"
        PlayerAvatar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        PlayerAvatar.BackgroundTransparency = 0.2
        PlayerAvatar.BorderSizePixel = 0
        PlayerAvatar.AnchorPoint = Vector2.new(0, 0.5)
        PlayerAvatar.Position = UDim2.new(0, 0, 0.5, 2)
        PlayerAvatar.Size = UDim2.new(0, 26, 0, 26)
        PlayerAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
        PlayerAvatar.Parent = PlayerFooter

        local AvatarCorner = Instance.new("UICorner")
        AvatarCorner.CornerRadius = UDim.new(1, 0)
        AvatarCorner.Parent = PlayerAvatar

        local AvatarStroke = Instance.new("UIStroke")
        AvatarStroke.Color = GuiConfig.Color
        AvatarStroke.Thickness = 1.2
        AvatarStroke.Transparency = 0.5
        AvatarStroke.Parent = PlayerAvatar

        local PlayerName = Instance.new("TextLabel")
        PlayerName.Name = "PlayerName"
        PlayerName.Font = Enum.Font.GothamBold

        local displayName = LocalPlayer.DisplayName
        local shortName = displayName
        if #displayName > 3 then
            shortName = string.sub(displayName, 1, 3) .. "***"
        end
        PlayerName.Text = "Welcome, " .. shortName

        PlayerName.TextColor3 = Color3.fromRGB(180, 180, 180)
        PlayerName.TextSize = 11
        PlayerName.TextXAlignment = Enum.TextXAlignment.Left
        PlayerName.BackgroundTransparency = 1
        PlayerName.Position = UDim2.new(0, 32, 0, 0)
        PlayerName.Size = UDim2.new(1, -32, 1, 0)
        PlayerName.TextTruncate = Enum.TextTruncate.None
        PlayerName.Parent = PlayerFooter
    end

    _G.ScrollTab = ScrollTab

    DecideFrame.AnchorPoint = Vector2.new(0.5, 0)
    DecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DecideFrame.BackgroundTransparency = 0.85
    DecideFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DecideFrame.BorderSizePixel = 0
    DecideFrame.Position = UDim2.new(0.5, 0, 0, 38)
    DecideFrame.Size = UDim2.new(1, 0, 0, 1)
    DecideFrame.Name = "DecideFrame"
    DecideFrame.Parent = Main

    Layers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Layers.BackgroundTransparency = 0.999
    Layers.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Layers.BorderSizePixel = 0
    Layers.Position = UDim2.new(0, GuiConfig["Tab Width"] + 18, 0, topOffset)
    Layers.Size = UDim2.new(1, -(GuiConfig["Tab Width"] + 9 + 18), 1, -(topOffset + 9))
    Layers.Name = "Layers"
    Layers.Parent = Main

    UICorner6.CornerRadius = UDim.new(0, 2)
    UICorner6.Parent = Layers

    NameTab.Font = Enum.Font.GothamBold
    NameTab.Text = ""
    NameTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameTab.TextSize = 24
    NameTab.TextWrapped = true
    NameTab.TextXAlignment = Enum.TextXAlignment.Left
    NameTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    NameTab.BackgroundTransparency = 0.999
    NameTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    NameTab.BorderSizePixel = 0
    NameTab.Size = UDim2.new(1, 0, 0, 30)
    NameTab.Name = "NameTab"
    NameTab.Parent = Layers

    LayersReal.AnchorPoint = Vector2.new(0, 1)
    LayersReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LayersReal.BackgroundTransparency = 0.999
    LayersReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LayersReal.BorderSizePixel = 0
    LayersReal.ClipsDescendants = true
    LayersReal.Position = UDim2.new(0, 0, 1, 0)
    LayersReal.Size = UDim2.new(1, 0, 1, -33)
    LayersReal.Name = "LayersReal"
    LayersReal.Parent = Layers

    LayersFolder.Name = "LayersFolder"
    LayersFolder.Parent = LayersReal

    LayersPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LayersPageLayout.Name = "LayersPageLayout"
    LayersPageLayout.Parent = LayersFolder
    LayersPageLayout.TweenTime = 0.5
    LayersPageLayout.EasingDirection = Enum.EasingDirection.InOut
    LayersPageLayout.EasingStyle = Enum.EasingStyle.Quad

    function GuiFunc:DestroyGui()
        if CoreGui:FindFirstChild("Lexsss") then
            Lexsss:Destroy()
        end
    end

    function GuiFunc:SetToggleKey(keyCode)
        GuiConfig.Keybind = keyCode
    end

    function GuiFunc:Tag(TagConfig)
        TagConfig = TagConfig or {}
        TagConfig.Title = TagConfig.Title or "Tag"
        TagConfig.Icon  = TagConfig.Icon or ""

        local function resolveColor(c)
            if typeof(c) == "Color3" then
                return c
            elseif type(c) == "string" then
                if c:sub(1,1) == "#" then
                    return Color3.fromHex(c)
                else
                    return getColor(c)
                end
            end
            return GuiConfig.Color
        end

        local tagColor = resolveColor(TagConfig.Color)

        local TagFrame = Instance.new("Frame")
        TagFrame.BackgroundColor3 = tagColor
        TagFrame.BackgroundTransparency = 0
        TagFrame.BorderSizePixel = 0
        TagFrame.AutomaticSize = Enum.AutomaticSize.X
        TagFrame.Size = UDim2.new(0, 0, 0, 22)
        TagFrame.Name = "Tag"
        TagFrame.ClipsDescendants = false
        TagFrame.Parent = TagContainer

        local TagCorner = Instance.new("UICorner")
        TagCorner.CornerRadius = UDim.new(1, 0)
        TagCorner.Parent = TagFrame

        local TagStroke = Instance.new("UIStroke")
        TagStroke.Color = tagColor
        TagStroke.Thickness = 1.5
        TagStroke.Transparency = 0.4
        TagStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        TagStroke.Parent = TagFrame

        local TagPadding = Instance.new("UIPadding")
        TagPadding.PaddingLeft = UDim.new(0, 8)
        TagPadding.PaddingRight = UDim.new(0, 8)
        TagPadding.Parent = TagFrame

        local TagInner = Instance.new("Frame")
        TagInner.BackgroundTransparency = 1
        TagInner.BorderSizePixel = 0
        TagInner.AutomaticSize = Enum.AutomaticSize.X
        TagInner.Size = UDim2.new(0, 0, 1, 0)
        TagInner.Parent = TagFrame

        local TagInnerList = Instance.new("UIListLayout")
        TagInnerList.FillDirection = Enum.FillDirection.Horizontal
        TagInnerList.VerticalAlignment = Enum.VerticalAlignment.Center
        TagInnerList.Padding = UDim.new(0, 4)
        TagInnerList.Parent = TagInner

        local TagIcon = Instance.new("ImageLabel")
        TagIcon.BackgroundTransparency = 1
        TagIcon.BorderSizePixel = 0
        TagIcon.Size = UDim2.new(0, 12, 0, 12)
        TagIcon.ImageColor3 = Color3.fromRGB(15, 15, 15)
        TagIcon.ScaleType = Enum.ScaleType.Fit
        TagIcon.LayoutOrder = 0
        TagIcon.Parent = TagInner

        local function applyIcon(iconName)
            local id = getIconId(iconName or "")
            TagIcon.Image = id
            TagIcon.Visible = (id ~= "")
        end
        applyIcon(TagConfig.Icon)

        local TagLabel = Instance.new("TextLabel")
        TagLabel.Font = Enum.Font.GothamBold
        TagLabel.Text = TagConfig.Title
        TagLabel.TextColor3 = Color3.fromRGB(15, 15, 15)
        TagLabel.TextSize = 11
        TagLabel.BackgroundTransparency = 1
        TagLabel.BorderSizePixel = 0
        TagLabel.AutomaticSize = Enum.AutomaticSize.X
        TagLabel.Size = UDim2.new(0, 0, 1, 0)
        TagLabel.LayoutOrder = 1
        TagLabel.Parent = TagInner

        task.defer(UpdateTagPosition)

        local TagApi = {}

        function TagApi:SetTitle(newTitle)
            TagLabel.Text = tostring(newTitle or "")
            task.defer(UpdateTagPosition)
        end

        function TagApi:SetIcon(iconName)
            applyIcon(iconName)
            task.defer(UpdateTagPosition)
        end

        function TagApi:SetColor(colorInput)
            local newColor = resolveColor(colorInput)
            TweenService:Create(TagFrame, TweenInfo.new(0.2), { BackgroundColor3 = newColor }):Play()
            TweenService:Create(TagStroke, TweenInfo.new(0.2), { Color = newColor }):Play()
        end

        function TagApi:Destroy()
            TagFrame:Destroy()
            task.defer(UpdateTagPosition)
        end

        TagApi.Frame = TagFrame
        return TagApi
    end

    Min.Activated:Connect(function()
        CircleClick(Min, Mouse.X, Mouse.Y)
        DropShadowHolder.Visible = false
    end)

    Close.Activated:Connect(function()
        CircleClick(Close, Mouse.X, Mouse.Y)
        LexsUI:Dialog({
            Title = GuiConfig.Configname .. " Window",
            Content = "Do you want to close this window?\nYou will not be able to open it again",
            Buttons = {
                {
                    Name = "Yes",
                    Callback = function()
                        if Lexsss then Lexsss:Destroy() end
                        if GuiFunc._toggleGui then
                            pcall(function() GuiFunc._toggleGui:Destroy() end)
                            GuiFunc._toggleGui = nil
                        end
                    end
                },
                {
                    Name = "Cancel",
                    Callback = function() end
                }
            }
        })
    end)

    function GuiFunc:ToggleUI()
        if GuiFunc._toggleGui then
            pcall(function() GuiFunc._toggleGui:Destroy() end)
            GuiFunc._toggleGui = nil
        end

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = game:GetService("CoreGui")
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Name = "ToggleUIButton"

        GuiFunc._toggleGui = ScreenGui

        local MainButton = Instance.new("ImageLabel")
        MainButton.Parent = ScreenGui
        MainButton.Size = UDim2.new(0, 40, 0, 40)
        MainButton.Position = UDim2.new(0, 20, 0, 100)
        MainButton.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        MainButton.BackgroundTransparency = 0.1
        MainButton.Image = "rbxassetid://" .. GuiConfig.Image
        MainButton.ScaleType = Enum.ScaleType.Fit

        local UICornerBtn = Instance.new("UICorner")
        UICornerBtn.CornerRadius = UDim.new(0, 8)
        UICornerBtn.Parent = MainButton

        local Button = Instance.new("TextButton")
        Button.Parent = MainButton
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = ""

        Button.MouseButton1Click:Connect(function()
            if DropShadowHolder then
                DropShadowHolder.Visible = not DropShadowHolder.Visible
            end
        end)

        local dragging = false
        local dragStart, startPos

        local function update(input)
            local delta = input.Position - dragStart
            MainButton.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end

        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MainButton.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
    end

    GuiFunc:ToggleUI()

    GuiConfig.Keybind = GuiConfig.Keybind or Enum.KeyCode.RightShift

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == GuiConfig.Keybind then
            DropShadowHolder.Visible = not DropShadowHolder.Visible
        end
    end)

    MakeDraggable(Top, DropShadowHolder, GuiConfig)

    local MoreBlur          = Instance.new("Frame")
    local DropShadowHolder1 = Instance.new("Frame")
    local DropShadow1       = Instance.new("ImageLabel")
    local UICorner28        = Instance.new("UICorner")
    local ConnectButton     = Instance.new("TextButton")

    MoreBlur.AnchorPoint = Vector2.new(1, 1)
    MoreBlur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MoreBlur.BackgroundTransparency = 0.999
    MoreBlur.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MoreBlur.BorderSizePixel = 0
    MoreBlur.ClipsDescendants = true
    MoreBlur.Position = UDim2.new(1, 8, 1, 8)
    MoreBlur.Size = UDim2.new(1, 154, 1, 54)
    MoreBlur.Visible = false
    MoreBlur.Name = "MoreBlur"
    MoreBlur.Parent = Layers

    DropShadowHolder1.BackgroundTransparency = 1
    DropShadowHolder1.BorderSizePixel = 0
    DropShadowHolder1.Size = UDim2.new(1, 0, 1, 0)
    DropShadowHolder1.ZIndex = 0
    DropShadowHolder1.Name = "DropShadowHolder"
    DropShadowHolder1.Parent = MoreBlur

    DropShadow1.Image = "rbxassetid://6015897843"
    DropShadow1.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow1.ImageTransparency = 1
    DropShadow1.ScaleType = Enum.ScaleType.Slice
    DropShadow1.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow1.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow1.BackgroundTransparency = 1
    DropShadow1.BorderSizePixel = 0
    DropShadow1.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow1.Size = UDim2.new(1, 35, 1, 35)
    DropShadow1.ZIndex = 0
    DropShadow1.Name = "DropShadow"
    DropShadow1.Parent = DropShadowHolder1

    UICorner28.Parent = MoreBlur

    ConnectButton.Font = Enum.Font.SourceSans
    ConnectButton.Text = ""
    ConnectButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    ConnectButton.TextSize = 14
    ConnectButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ConnectButton.BackgroundTransparency = 0.999
    ConnectButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ConnectButton.BorderSizePixel = 0
    ConnectButton.Size = UDim2.new(1, 0, 1, 0)
    ConnectButton.Name = "ConnectButton"
    ConnectButton.Parent = MoreBlur

    local DropdownSelect     = Instance.new("Frame")
    local UICorner36         = Instance.new("UICorner")
    local UIStroke14         = Instance.new("UIStroke")
    local DropdownSelectReal = Instance.new("Frame")
    local DropdownFolder     = Instance.new("Folder")
    local DropPageLayout     = Instance.new("UIPageLayout")

    DropdownSelect.AnchorPoint = Vector2.new(1, 0.5)
    DropdownSelect.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropdownSelect.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DropdownSelect.BorderSizePixel = 0
    DropdownSelect.LayoutOrder = 1
    DropdownSelect.Position = UDim2.new(1, 172, 0.5, 0)
    DropdownSelect.Size = UDim2.new(0, 160, 1, -16)
    DropdownSelect.Name = "DropdownSelect"
    DropdownSelect.ClipsDescendants = true
    DropdownSelect.Parent = MoreBlur

    ConnectButton.Activated:Connect(function()
        if MoreBlur.Visible then
            TweenService:Create(DropdownSelect, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 172, 0.5, 0)
            }):Play()
            TweenService:Create(MoreBlur, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 0.999
            }):Play()
            task.wait(0.3)
            MoreBlur.Visible = false
        end
    end)

    UICorner36.CornerRadius = UDim.new(0, 6)
    UICorner36.Parent = DropdownSelect

    UIStroke14.Color = GuiConfig.Color
    UIStroke14.Thickness = 1.5
    UIStroke14.Transparency = 0.7
    UIStroke14.Parent = DropdownSelect

    DropdownSelectReal.AnchorPoint = Vector2.new(0.5, 0.5)
    DropdownSelectReal.BackgroundColor3 = Color3.fromRGB(0, 27, 98)
    DropdownSelectReal.BackgroundTransparency = 0.7
    DropdownSelectReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DropdownSelectReal.BorderSizePixel = 0
    DropdownSelectReal.LayoutOrder = 1
    DropdownSelectReal.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropdownSelectReal.Size = UDim2.new(1, 1, 1, 1)
    DropdownSelectReal.Name = "DropdownSelectReal"
    DropdownSelectReal.Parent = DropdownSelect

    DropdownFolder.Name = "DropdownFolder"
    DropdownFolder.Parent = DropdownSelectReal

    DropPageLayout.EasingDirection = Enum.EasingDirection.InOut
    DropPageLayout.EasingStyle = Enum.EasingStyle.Quad
    DropPageLayout.TweenTime = 0.01
    DropPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DropPageLayout.FillDirection = Enum.FillDirection.Vertical
    DropPageLayout.Archivable = false
    DropPageLayout.Name = "DropPageLayout"
    DropPageLayout.Parent = DropdownFolder

    local Tabs = TabsModule(
        GuiConfig,
        LayersFolder,
        LayersPageLayout,
        _G.ScrollTab,
        NameTab,
        MoreBlur,
        DropdownFolder,
        DropdownSelect,
        DropPageLayout,
        Elements,
        ElementsModule,
        KeybindModule,
        Mouse,
        TweenService,
        getIconId,
        CircleClick,
        SaveConfig,
        ConfigData
    )

    for k, v in pairs(Tabs) do
        GuiFunc[k] = v
    end

    local origAddTab = GuiFunc.AddTab
    GuiFunc.AddTab = function(self, TabConfig)
        local Sections = origAddTab(self, TabConfig)
        local origAddSection = Sections.AddSection
        Sections.AddSection = function(self2, SectionConfig)
            local Items = origAddSection(self2, SectionConfig)

            local _itemCount = 0

            function Items:AddColorpicker(Config)
                local sa = rawget(self, "_sectionAdd") or (type(self) == "table" and self._sectionAdd)
                local ci = (type(self) == "table" and rawget(self, "_getCountItem") and self._getCountItem()) or _itemCount

                if not sa then
                    local origToggle = Items.AddToggle
                    if origToggle then
                        local origCreate = ElementsModule.CreateToggle
                        local probeFrame = nil
                        ElementsModule.CreateToggle = function(self_em, parent, cfg, ci2, ...)
                            probeFrame = parent
                            ElementsModule.CreateToggle = origCreate
                            return { Set = function() end, GetValue = function() return false end,
                                     Value = false, IgnoreConfig = false, Class = "Toggle" }
                        end
                        pcall(function()
                            Items:AddToggle({ Title = "__probe__", Default = false, Callback = function() end })
                        end)
                        ElementsModule.CreateToggle = origCreate
                        sa = probeFrame
                        if sa then
                            for _, child in ipairs(sa:GetChildren()) do
                                if child:IsA("Frame") and child:FindFirstChild("ToggleTitle") then
                                    local tt = child:FindFirstChild("ToggleTitle")
                                    if tt and tt.Text == "__probe__" then
                                        child:Destroy()
                                        break
                                    end
                                end
                            end
                        end
                    end
                end

                if not sa then
                    warn("[LexsUI] AddColorpicker: tidak bisa deteksi parent section.")
                    return {}
                end

                local api = _MakeColorPicker(Config, sa, ci, GuiConfig.Color, DropShadowHolder)
                _itemCount = _itemCount + 1
                return api
            end

            Items.AddColorPicker = Items.AddColorpicker
            return Items
        end
        return Sections
    end

    return GuiFunc
end

LexsUI = Lexs

return Lexs
