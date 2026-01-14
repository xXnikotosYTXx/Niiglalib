
local Library = {
    Version = "1.0.0",
    Name = "Project Spectre",
    Unloaded = false
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Global tables for options
if not getgenv().Options then getgenv().Options = {} end
if not getgenv().Toggles then getgenv().Toggles = {} end

local Options = getgenv().Options
local Toggles = getgenv().Toggles

-- Theme colors (dark purple/blue sci-fi theme for "Spectre")
Library.Theme = {
    -- Main colors
    Background = Color3.fromRGB(15, 15, 20),
    MainFrame = Color3.fromRGB(20, 20, 28),
    SecondaryFrame = Color3.fromRGB(25, 25, 35),
    
    -- Accent colors (purple/cyan for "Spectre" theme)
    Accent = Color3.fromRGB(138, 43, 226), -- Purple
    AccentHover = Color3.fromRGB(155, 89, 235),
    Secondary = Color3.fromRGB(0, 174, 219), -- Cyan
    
    -- Text
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(160, 160, 170),
    DisabledText = Color3.fromRGB(100, 100, 110),
    
    -- UI Elements
    Border = Color3.fromRGB(40, 40, 50),
    ElementBackground = Color3.fromRGB(28, 28, 38),
    ElementBackgroundHover = Color3.fromRGB(33, 33, 43),
    
    -- Status colors
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Error = Color3.fromRGB(231, 76, 60)
}

-- Utility functions
function Library:Tween(instance, properties, duration, easing)
    duration = duration or 0.3
    easing = easing or Enum.EasingStyle.Quart
    
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration, easing, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

function Library:Create(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Library:AddCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 4)
    corner.Parent = instance
    return corner
end

function Library:AddStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or self.Theme.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Transparency = 0.5
    stroke.Parent = instance
    return stroke
end

-- Make window draggable
function Library:MakeDraggable(handle, frame)
    local dragging, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Make window resizable
function Library:MakeResizable(frame, minSize)
    minSize = minSize or Vector2.new(400, 300)
    
    local resizeHandle = self:Create("Frame", {
        Parent = frame,
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = 100
    })
    
    local resizing, resizeStart, startSize
    
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = frame.AbsoluteSize
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and resizing then
            local delta = input.Position - resizeStart
            local newWidth = math.max(minSize.X, startSize.X + delta.X)
            local newHeight = math.max(minSize.Y, startSize.Y + delta.Y)
            frame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
end

-- Create main window
function Library:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Project Spectre"
    local center = config.Center or true
    local autoShow = config.AutoShow ~= false
    local size = config.Size or UDim2.new(0, 600, 0, 450)
    
    -- Clean up old instances
    pcall(function()
        if game.CoreGui:FindFirstChild("SpectreUI") then
            game.CoreGui:FindFirstChild("SpectreUI"):Destroy()
        end
    end)
    
    -- Create ScreenGui (FIXED for executor)
    local screenGui = self:Create("ScreenGui", {
        Name = "SpectreUI",
        Parent = game.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Protect GUI for executors
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
    elseif gethui then
        pcall(function()
            screenGui.Parent = gethui()
        end)
    end
    
    -- Main container
    local mainFrame = self:Create("Frame", {
        Parent = screenGui,
        AnchorPoint = center and Vector2.new(0.5, 0.5) or Vector2.new(0, 0),
        Position = center and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0, 50, 0, 50),
        Size = size,
        BackgroundColor3 = self.Theme.MainFrame,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = autoShow
    })
    self:AddCorner(mainFrame, 8)
    self:AddStroke(mainFrame, self.Theme.Border, 1)
    
    -- Topbar
    local topbar = self:Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = self.Theme.SecondaryFrame,
        BorderSizePixel = 0
    })
    self:AddCorner(topbar, 8)
    
    -- Topbar extension (make bottom flat)
    local topbarExt = self:Create("Frame", {
        Parent = topbar,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
        BackgroundColor3 = self.Theme.SecondaryFrame,
        BorderSizePixel = 0
    })
    
    -- Title with gradient effect
    local titleLabel = self:Create("TextLabel", {
        Parent = topbar,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -100, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextSize = 16,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Accent line under title
    local accentLine = self:Create("Frame", {
        Parent = topbar,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0
    })
    
    -- Close button
    local closeBtn = self:Create("TextButton", {
        Parent = topbar,
        Position = UDim2.new(1, -30, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        BackgroundColor3 = self.Theme.ElementBackground,
        Text = "??",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = self.Theme.Text,
        BorderSizePixel = 0
    })
    self:AddCorner(closeBtn, 4)
    
    closeBtn.MouseButton1Click:Connect(function()
        Library:Unload()
    end)
    
    closeBtn.MouseEnter:Connect(function()
        self:Tween(closeBtn, {BackgroundColor3 = self.Theme.Error}, 0.2)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        self:Tween(closeBtn, {BackgroundColor3 = self.Theme.ElementBackground}, 0.2)
    end)
    
    -- Tab container
    local tabContainer = self:Create("Frame", {
        Parent = mainFrame,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0
    })
    
    local tabList = self:Create("UIListLayout", {
        Parent = tabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    self:Create("UIPadding", {
        Parent = tabContainer,
        PaddingLeft = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 4)
    })
    
    -- Content area
    local contentFrame = self:Create("Frame", {
        Parent = mainFrame,
        Position = UDim2.new(0, 0, 0, 70),
        Size = UDim2.new(1, 0, 1, -70),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    
    -- Make draggable and resizable
    self:MakeDraggable(topbar, mainFrame)
    self:MakeResizable(mainFrame, Vector2.new(500, 400))
    
    -- Window object
    local Window = {
        Tabs = {},
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        TabContainer = tabContainer,
        ContentFrame = contentFrame,
        CurrentTab = nil
    }
    
    Library.Window = Window
    
    return Window
end

-- Add tab to window
function Window:AddTab(name)
    local tabButton = Library:Create("TextButton", {
        Parent = self.TabContainer,
        Size = UDim2.new(0, 120, 1, -8),
        BackgroundColor3 = Library.Theme.SecondaryFrame,
        Text = name,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Library.Theme.SubText,
        BorderSizePixel = 0
    })
    Library:AddCorner(tabButton, 4)
    
    local tabContent = Library:Create("Frame", {
        Parent = self.ContentFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false
    })
    
    -- Left and right columns
    local leftColumn = Library:Create("ScrollingFrame", {
        Parent = tabContent,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(0.5, -12, 1, -16),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local rightColumn = Library:Create("ScrollingFrame", {
        Parent = tabContent,
        Position = UDim2.new(0.5, 4, 0, 8),
        Size = UDim2.new(0.5, -12, 1, -16),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local leftLayout = Library:Create("UIListLayout", {
        Parent = leftColumn,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    local rightLayout = Library:Create("UIListLayout", {
        Parent = rightColumn,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    local Tab = {
        Name = name,
        Button = tabButton,
        Content = tabContent,
        LeftColumn = leftColumn,
        RightColumn = rightColumn,
        Window = self
    }
    
    -- Tab activation
    local function activate()
        for _, tab in pairs(self.Tabs) do
            tab.Content.Visible = false
            Library:Tween(tab.Button, {
                BackgroundColor3 = Library.Theme.SecondaryFrame,
                TextColor3 = Library.Theme.SubText
            }, 0.2)
        end
        
        tabContent.Visible = true
        Library:Tween(tabButton, {
            BackgroundColor3 = Library.Theme.Accent,
            TextColor3 = Library.Theme.Text
        }, 0.2)
        
        self.CurrentTab = Tab
    end
    
    tabButton.MouseButton1Click:Connect(activate)
    
    -- Auto-activate first tab
    if #self.Tabs == 0 then
        activate()
    end
    
    table.insert(self.Tabs, Tab)
    
    return Tab
end

-- Add left groupbox to tab
function Tab:AddLeftGroupbox(name)
    return self:AddGroupbox(name, self.LeftColumn)
end

-- Add right groupbox to tab  
function Tab:AddRightGroupbox(name)
    return self:AddGroupbox(name, self.RightColumn)
end

-- Add groupbox
function Tab:AddGroupbox(name, parent)
    local groupbox = Library:Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Library.Theme.SecondaryFrame,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    Library:AddCorner(groupbox, 6)
    Library:AddStroke(groupbox, Library.Theme.Border, 1)
    
    local header = Library:Create("TextLabel", {
        Parent = groupbox,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Library.Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local container = Library:Create("Frame", {
        Parent = groupbox,
        Position = UDim2.new(0, 8, 0, 35),
        Size = UDim2.new(1, -16, 1, -43),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    local layout = Library:Create("UIListLayout", {
        Parent = container,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })
    
    Library:Create("UIPadding", {
        Parent = groupbox,
        PaddingBottom = UDim.new(0, 8)
    })
    
    local Groupbox = {
        Name = name,
        Frame = groupbox,
        Container = container,
        Tab = self
    }
    
    return Groupbox
end

-- Unload library
function Library:Unload()
    self.Unloaded = true
    if self.Window and self.Window.ScreenGui then
        self.Window.ScreenGui:Destroy()
    end
    
    if self.OnUnloadCallback then
        self.OnUnloadCallback()
    end
end

function Library:OnUnload(callback)
    self.OnUnloadCallback = callback
end

-- Set watermark
Library.Watermark = nil

function Library:SetWatermark(text)
    if not self.Watermark then
        local watermark = self:Create("ScreenGui", {
            Name = "SpectreWatermark",
            Parent = game.CoreGui,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false
        })
        
        local frame = self:Create("Frame", {
            Parent = watermark,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(0, 200, 0, 25),
            BackgroundColor3 = self.Theme.MainFrame,
            BorderSizePixel = 0
        })
        self:AddCorner(frame, 4)
        self:AddStroke(frame, self.Theme.Accent, 1)
        
        local label = self:Create("TextLabel", {
            Parent = frame,
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = text or "",
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = self.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        self.Watermark = {Frame = frame, Label = label}
    else
        self.Watermark.Label.Text = text or ""
        local textSize = game:GetService("TextService"):GetTextSize(
            text or "",
            self.Watermark.Label.TextSize,
            self.Watermark.Label.Font,
            Vector2.new(10000, 25)
        )
        self.Watermark.Frame.Size = UDim2.new(0, textSize.X + 16, 0, 25)
    end
end

function Library:SetWatermarkVisibility(visible)
    if self.Watermark then
        self.Watermark.Frame.Visible = visible
    end
end

-- return Library -- REMOVED: Premature return causing syntax error

-- ========== TOGGLE ==========
function Groupbox:AddToggle(idx, config)
    config = config or {}
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local tooltip = config.Tooltip
    local callback = config.Callback or function() end
    
    local toggled = default
    
    local container = Library:Create("Frame", {
        Parent = self.Container,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1
    })
    
    -- Checkbox
    local checkbox = Library:Create("Frame", {
        Parent = container,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 0, 0.5, -8),
        BackgroundColor3 = Library.Theme.ElementBackground,
        BorderSizePixel = 0
    })
    Library:AddCorner(checkbox, 3)
    Library:AddStroke(checkbox, Library.Theme.Border, 1)
    
    -- Checkmark
    local checkmark = Library:Create("TextLabel", {
        Parent = checkbox,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "???",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Library.Theme.Accent,
        TextTransparency = toggled and 0 or 1
    })
    
    -- Label
    local label = Library:Create("TextLabel", {
        Parent = container,
        Position = UDim2.new(0, 24, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Library.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local function UpdateValue()
        Library:Tween(checkmark, {TextTransparency = toggled and 0 or 1}, 0.2)
        Library:Tween(checkbox, {
            BackgroundColor3 = toggled and Library.Theme.Accent or Library.Theme.ElementBackground
        }, 0.2)
        callback(toggled)
    end
    
    local button = Library:Create("TextButton", {
        Parent = container,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    button.MouseButton1Click:Connect(function()
        toggled = not toggled
        UpdateValue()
    end)
    
    UpdateValue()
    
    local Toggle = {
        Value = toggled,
        SetValue = function(self, value)
            toggled = value
            self.Value = value
            UpdateValue()
        end,
        OnChanged = function(self, func)
            callback = func
        end
    }
    
    Toggles[idx] = Toggle
    return Toggle
end

-- ========== BUTTON ==========
function Groupbox:AddButton(config)
    config = config or {}
    local text = config.Text or "Button"
    local func = config.Func or function() end
    local doubleClick = config.DoubleClick or false
    local tooltip = config.Tooltip
    
    local button = Library:Create("TextButton", {
        Parent = self.Container,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Library.Theme.ElementBackground,
        Text = text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Library.Theme.Text,
        BorderSizePixel = 0
    })
    Library:AddCorner(button, 4)
    
    local clickCount = 0
    local lastClick = 0
    
    button.MouseButton1Click:Connect(function()
        if doubleClick then
            local now = tick()
            if now - lastClick < 0.5 then
                clickCount = clickCount + 1
                if clickCount >= 2 then
                    func()
                    clickCount = 0
                end
            else
                clickCount = 1
            end
            lastClick = now
        else
            func()
        end
        
        Library:Tween(button, {TextSize = 11}, 0.1)
        task.wait(0.1)
        Library:Tween(button, {TextSize = 13}, 0.1)
    end)
    
    button.MouseEnter:Connect(function()
        Library:Tween(button, {BackgroundColor3 = Library.Theme.ElementBackgroundHover}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        Library:Tween(button, {BackgroundColor3 = Library.Theme.ElementBackground}, 0.2)
    end)
    
    local Button = {
        AddButton = function(self, subConfig)
            -- Sub-button support
            return Groupbox:AddButton(subConfig)
        end
    }
    
    return Button
end

-- ========== LABEL ==========
function Groupbox:AddLabel(text, wrap)
    local label = Library:Create("TextLabel", {
        Parent = self.Container,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = text or "Label",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Library.Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = wrap or false,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    return label
end

-- ========== DIVIDER ==========
function Groupbox:AddDivider()
    local divider = Library:Create("Frame", {
        Parent = self.Container,
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Library.Theme.Border,
        BorderSizePixel = 0
    })
    
    return divider
end

-- ========== SLIDER ==========
function Groupbox:AddSlider(idx, config)
    config = config or {}
    local text = config.Text or "Slider"
    local default = config.Default or 0
    local min = config.Min or 0
    local max = config.Max or 100
    local rounding = config.Rounding or 0
    local suffix = config.Suffix or ""
    local compact = config.Compact or false
    local callback = config.Callback or function() end
    
    local value = default
    
    local container = Library:Create("Frame", {
        Parent = self.Container,
        Size = UDim2.new(1, 0, 0, compact and 30 or 45),
        BackgroundTransparency = 1
    })
    
    if not compact then
        local label = Library:Create("TextLabel", {
            Parent = container,
            Size = UDim2.new(0.7, 0, 0, 15),
            BackgroundTransparency = 1,
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Library.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end
    
    local valueLabel = Library:Create("TextLabel", {
        Parent = container,
        Position = UDim2.new(0.7, 0, 0, compact and 0 or 0),
        Size = UDim2.new(0.3, 0, 0, 15),
        BackgroundTransparency = 1,
        Text = tostring(value) .. suffix,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Library.Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    local sliderBack = Library:Create("Frame", {
        Parent = container,
        Position = UDim2.new(0, 0, 0, compact and 18 or 20),
        Size = UDim2.new(1, 0, 0, 6),
        BackgroundColor3 = Library.Theme.ElementBackground,
        BorderSizePixel = 0
    })
    Library:AddCorner(sliderBack, 3)
    
    local sliderFill = Library:Create("Frame", {
        Parent = sliderBack,
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Library.Theme.Accent,
        BorderSizePixel = 0
    })
    Library:AddCorner(sliderFill, 3)
    
    local dragging = false
    
    local function UpdateValue(input)
        local pos = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
        value = math.floor((min + (max - min) * pos) * (10 ^ rounding) + 0.5) / (10 ^ rounding)
        valueLabel.Text = tostring(value) .. suffix
        Library:Tween(sliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
        callback(value)
    end
    
    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateValue(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateValue(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    local Slider = {
        Value = value,
        SetValue = function(self, val)
            value = math.clamp(val, min, max)
            self.Value = value
            valueLabel.Text = tostring(value) .. suffix
            sliderFill.Size = UDim2.new(math.clamp((value - min) / (max - min), 0, 1), 0, 1, 0)
            callback(value)
        end,
        OnChanged = function(self, func)
            callback = func
        end
    }
    
    Options[idx] = Slider
    return Slider
end

-- ========== INPUT/TEXTBOX ==========
function Groupbox:AddInput(idx, config)
    config = config or {}
    local text = config.Text or "Input"
    local default = config.Default or ""
    local numeric = config.Numeric or false
    local finished = config.Finished or false
    local placeholder = config.Placeholder or "Enter text..."
    local callback = config.Callback or function() end
    
    local container = Library:Create("Frame", {
        Parent = self.Container,
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundTransparency = 1
    })
    
    local label = Library:Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 15),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Library.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local inputBox = Library:Create("TextBox", {
        Parent = container,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundColor3 = Library.Theme.ElementBackground,
        Text = default,
        PlaceholderText = placeholder,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Library.Theme.Text,
        PlaceholderColor3 = Library.Theme.SubText,
        BorderSizePixel = 0,
        ClearTextOnFocus = false
    })
    Library:AddCorner(inputBox, 4)
    
    Library:Create("UIPadding", {
        Parent = inputBox,
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6)
    })
    
    if numeric then
        inputBox:GetPropertyChangedSignal("Text"):Connect(function()
            inputBox.Text = inputBox.Text:gsub("[^%d%.]+", "")
        end)
    end
    
    if finished then
        inputBox.FocusLost:Connect(function()
            callback(inputBox.Text)
        end)
    else
        inputBox:GetPropertyChangedSignal("Text"):Connect(function()
            callback(inputBox.Text)
        end)
    end
    
    local Input = {
        Value = default,
        SetValue = function(self, val)
            inputBox.Text = tostring(val)
            self.Value = val
        end,
        OnChanged = function(self, func)
            callback = func
        end
    }
    
    Options[idx] = Input
    return Input
end

-- ========== DROPDOWN ==========
function Groupbox:AddDropdown(idx, config)
    config = config or {}
    local text = config.Text or "Dropdown"
    local values = config.Values or {"Option 1", "Option 2"}
    local default = config.Default or 1
    local multi = config.Multi or false
    local callback = config.Callback or function() end
    
    local selected = multi and {} or (type(default) == "number" and values[default] or default)
    if multi and type(default) == "table" then
        selected = default
    end
    
    local container = Library:Create("Frame", {
        Parent = self.Container,
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundTransparency = 1,
        ClipsDescendants = false
    })
    
    local label = Library:Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 15),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Library.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local dropdownButton = Library:Create("TextButton", {
        Parent = container,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundColor3 = Library.Theme.ElementBackground,
        Text = "",
        BorderSizePixel = 0
    })
    Library:AddCorner(dropdownButton, 4)
    
    local dropdownLabel = Library:Create("TextLabel", {
        Parent = dropdownButton,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        BackgroundTransparency = 1,
        Text = multi and "..." or tostring(selected),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Library.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local arrow = Library:Create("TextLabel", {
        Parent = dropdownButton,
        Position = UDim2.new(1, -20, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        BackgroundTransparency = 1,
        Text = "???",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Library.Theme.SubText
    })
    
    local optionsFrame = Library:Create("Frame", {
        Parent = container,
        Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Library.Theme.SecondaryFrame,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 100,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    Library:AddCorner(optionsFrame, 4)
    Library:AddStroke(optionsFrame, Library.Theme.Border, 1)
    
    local optionsLayout = Library:Create("UIListLayout", {
        Parent = optionsFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    Library:Create("UIPadding", {
        Parent = optionsFrame,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4)
    })
    
    for _, option in ipairs(values) do
        local optButton = Library:Create("TextButton", {
            Parent = optionsFrame,
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundColor3 = Library.Theme.ElementBackground,
            Text = option,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Library.Theme.Text,
            BorderSizePixel = 0
        })
        Library:AddCorner(optButton, 3)
        
        optButton.MouseButton1Click:Connect(function()
            if multi then
                selected[option] = not selected[option]
                callback(selected)
            else
                selected = option
                dropdownLabel.Text = option
                optionsFrame.Visible = false
                callback(option)
            end
        end)
        
        optButton.MouseEnter:Connect(function()
            Library:Tween(optButton, {BackgroundColor3 = Library.Theme.Accent}, 0.2)
        end)
        
        optButton.MouseLeave:Connect(function()
            Library:Tween(optButton, {BackgroundColor3 = Library.Theme.ElementBackground}, 0.2)
        end)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        optionsFrame.Visible = not optionsFrame.Visible
        Library:Tween(arrow, {Rotation = optionsFrame.Visible and 180 or 0}, 0.2)
    end)
    
    local Dropdown = {
        Value = selected,
        SetValue = function(self, val)
            if multi and type(val) == "table" then
                selected = val
            else
                selected = val
                dropdownLabel.Text = tostring(val)
            end
            self.Value = selected
            callback(selected)
        end,
        OnChanged = function(self, func)
            callback = func
        end
    }
    
    Options[idx] = Dropdown
    return Dropdown
end



return Library

