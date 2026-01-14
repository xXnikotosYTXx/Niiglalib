--[[
    PROJECT SPECTRE UI LIBRARY - REDESIGN V2.1 (POLISHED)
    Visual Style: Pixel Perfect, Rounded Square Sliders, Enhanced Animations
]]

local Library = {
    Version = "2.1.0",
    Name = "Project Spectre",
    Unloaded = false
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Global Tables
if not getgenv().Options then getgenv().Options = {} end
if not getgenv().Toggles then getgenv().Toggles = {} end
local Options = getgenv().Options
local Toggles = getgenv().Toggles

-- Setup Classes
local Window = {}
local Tab = {}
local Groupbox = {}

Window.__index = Window
Tab.__index = Tab
Groupbox.__index = Groupbox

-- Utility: Tweet
function Library:Tween(instance, properties, duration)
    local tween = TweenService:Create(instance, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

function Library:Create(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then instance[prop] = value end
    end
    if properties.Parent then instance.Parent = properties.Parent end
    return instance
end

function Library:AddCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = instance
    return corner
end

function Library:AddStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Library.Theme.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Transparency = 0
    stroke.Parent = instance
    return stroke
end

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
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ==========================================
-- THEME SYSTEM
-- ==========================================
Library.Theme = {
    -- Dark blue/black background
    Background = Color3.fromRGB(18, 18, 24),
    Sidebar = Color3.fromRGB(14, 14, 18),
    MainFrame = Color3.fromRGB(18, 18, 24),
    
    -- Element colors
    ElementBackground = Color3.fromRGB(24, 24, 32),
    ElementBackgroundHover = Color3.fromRGB(32, 32, 42),
    
    -- Text
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(140, 140, 155),
    
    -- Accent (Periwinkle/Violet)
    Accent = Color3.fromRGB(108, 92, 231), -- #6c5ce7
    AccentHover = Color3.fromRGB(128, 112, 251),
    
    -- Utility
    Border = Color3.fromRGB(35, 35, 45),
    Success = Color3.fromRGB(46, 204, 113)
}

-- ==========================================
-- WINDOW CREATION (VERTICAL SIDEBAR)
-- ==========================================
function Library:CreateWindow(config)
    config = config or {}
    
    -- Cleanup
    if game.CoreGui:FindFirstChild("SpectreUI_V2") then
        game.CoreGui:FindFirstChild("SpectreUI_V2"):Destroy()
    end
    
    local screenGui = self:Create("ScreenGui", {
        Name = "SpectreUI_V2", Parent = game.CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false
    })
    
    if syn and syn.protect_gui then syn.protect_gui(screenGui) elseif gethui then pcall(function() screenGui.Parent = gethui() end) end
    
    -- Main Container
    local mainFrame = self:Create("Frame", {
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = config.Size or UDim2.new(0, 750, 0, 500),
        BackgroundColor3 = self.Theme.Background, BorderSizePixel = 0
    })
    self:AddCorner(mainFrame, 6) -- Reduced from 10 to 6 for sharper, less "curved" look
    self:AddStroke(mainFrame, self.Theme.Border, 1)
    
    -- Sidebar (Fixed Width 200px)
    local sidebar = self:Create("Frame", {
        Parent = mainFrame, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0, 200, 1, 0),
        BackgroundColor3 = self.Theme.Sidebar, BorderSizePixel = 0, ZIndex = 2
    })
    self:AddCorner(sidebar, 6)
    
    -- Masking the right side of the sidebar to make it flush with content
    local sidebarCover = self:Create("Frame", {
        Parent = sidebar, Position = UDim2.new(1, -6, 0, 0), Size = UDim2.new(0, 6, 1, 0),
        BackgroundColor3 = self.Theme.Sidebar, BorderSizePixel = 0, ZIndex = 2
    })
    
    -- Sidebar Divider Line
    local sidebarLine = self:Create("Frame", {
        Parent = sidebar, Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = self.Theme.Border, BorderSizePixel = 0, ZIndex = 3
    })
    
    -- Sidebar Title
    local titleFrame = self:Create("Frame", {
        Parent = sidebar, Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, ZIndex = 3
    })
    local titleLabel = self:Create("TextLabel", {
        Parent = titleFrame, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1, Text = config.Title or "SPECTRE", Font = Enum.Font.GothamBold,
        TextSize = 22, TextColor3 = self.Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Tab Container
    local tabContainer = self:Create("ScrollingFrame", {
        Parent = sidebar, Position = UDim2.new(0, 0, 0, 60), Size = UDim2.new(1, 0, 1, -60),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, ZIndex = 3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0,0,0,0), ClipDescendants = true
    })
    self:Create("UIListLayout", {
        Parent = tabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)
    })
    self:Create("UIPadding", {
        Parent = tabContainer, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)
    })
    
    -- Content Area
    local contentFrame = self:Create("Frame", {
        Parent = mainFrame, Position = UDim2.new(0, 201, 0, 0), Size = UDim2.new(1, -201, 1, 0), -- Offset by 1px stroke
        BackgroundTransparency = 1, ClipsDescendants = true
    })
    self:Create("UIPadding", { Parent = contentFrame, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20) })
    
    self:MakeDraggable(sidebar, mainFrame)
    
    return setmetatable({
        ScreenGui = screenGui, MainFrame = mainFrame, TabContainer = tabContainer, ContentFrame = contentFrame, Tabs = {}, CurrentTab = nil
    }, Window)
end

-- ==========================================
-- TABS
-- ==========================================
function Window:AddTab(name)
    local button = Library:Create("TextButton", {
        Parent = self.TabContainer, Size = UDim2.new(1, 0, 0, 38), -- Slightly smaller height
        BackgroundColor3 = Library.Theme.Sidebar, BackgroundTransparency = 1,
        Text = "", AutoButtonColor = false
    })
    Library:AddCorner(button, 6)
    
    local indicator = Library:Create("Frame", {
        Parent = button, Position = UDim2.new(0, 0, 0.25, 0), Size = UDim2.new(0, 3, 0.5, 0),
        BackgroundColor3 = Library.Theme.Accent, BackgroundTransparency = 1
    })
    Library:AddCorner(indicator, 2)
    
    local icon = Library:Create("TextLabel", {
        Parent = button, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0, 20, 1, 0),
        BackgroundTransparency = 1, Text = string.sub(name, 1, 1), Font = Enum.Font.GothamBold,
        TextSize = 16, TextColor3 = Library.Theme.SubText
    })
    
    local label = Library:Create("TextLabel", {
        Parent = button, Position = UDim2.new(0, 40, 0, 0), Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1, Text = name, Font = Enum.Font.GothamMedium, -- Medium font for cleaner look
        TextSize = 14, TextColor3 = Library.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local content = Library:Create("ScrollingFrame", {
        Parent = self.ContentFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        ScrollBarThickness = 2, BorderSizePixel = 0, Visible = false, AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local leftCol = Library:Create("Frame", {
        Parent = content, Position = UDim2.new(0,0,0,0), Size = UDim2.new(0.485, 0, 1, 0), BackgroundTransparency = 1
    }); Library:Create("UIListLayout", { Parent = leftCol, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder })
    
    local rightCol = Library:Create("Frame", {
        Parent = content, Position = UDim2.new(0.515,0,0,0), Size = UDim2.new(0.485, 0, 1, 0), BackgroundTransparency = 1
    }); Library:Create("UIListLayout", { Parent = rightCol, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder })

    local tabObj = setmetatable({
        Button = button, Indicator = indicator, Label = label, Icon = icon, Content = content,
        Left = leftCol, Right = rightCol, Window = self
    }, Tab)
    
    local function Activate()
        if self.CurrentTab then
            Library:Tween(self.CurrentTab.Label, {TextColor3 = Library.Theme.SubText})
            Library:Tween(self.CurrentTab.Icon, {TextColor3 = Library.Theme.SubText})
            Library:Tween(self.CurrentTab.Button, {BackgroundTransparency = 1})
            Library:Tween(self.CurrentTab.Indicator, {BackgroundTransparency = 1})
            self.CurrentTab.Content.Visible = false
        end
        
        self.CurrentTab = tabObj
        tabObj.Content.Visible = true
        Library:Tween(tabObj.Label, {TextColor3 = Library.Theme.Text})
        Library:Tween(tabObj.Icon, {TextColor3 = Library.Theme.Text})
        Library:Tween(tabObj.Button, {BackgroundTransparency = 0.95, BackgroundColor3 = Library.Theme.Accent})
        Library:Tween(tabObj.Indicator, {BackgroundTransparency = 0})
    end
    
    button.MouseButton1Click:Connect(Activate)
    
    button.MouseEnter:Connect(function()
        if self.CurrentTab ~= tabObj then
            Library:Tween(label, {TextColor3 = Library.Theme.Text})
            Library:Tween(button, {BackgroundTransparency = 0.98, BackgroundColor3 = Library.Theme.Text})
        end
    end)
    button.MouseLeave:Connect(function()
        if self.CurrentTab ~= tabObj then
            Library:Tween(label, {TextColor3 = Library.Theme.SubText})
            Library:Tween(button, {BackgroundTransparency = 1})
        end
    end)
    
    if not self.CurrentTab then Activate() end
    return tabObj
end

function Tab:AddLeftGroupbox(name) return self:AddGroupbox(name, self.Left) end
function Tab:AddRightGroupbox(name) return self:AddGroupbox(name, self.Right) end

function Tab:AddGroupbox(name, parent)
    local box = Library:Create("Frame", {
        Parent = parent, Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Library.Theme.ElementBackground,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    Library:AddCorner(box, 6)
    
    if name and name ~= "" then
        Library:Create("TextLabel", {
            Parent = box, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -30, 0, 36),
            BackgroundTransparency = 1, Text = name, Font = Enum.Font.GothamBold,
            TextSize = 13, TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left
        })
    end
    
    local container = Library:Create("Frame", {
        Parent = box, Position = UDim2.new(0, 10, 0, name and name~="" and 36 or 10),
        Size = UDim2.new(1, -20, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y
    })
    Library:Create("UIListLayout", { Parent = container, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10) })
    Library:Create("UIPadding", { Parent = box, PaddingBottom = UDim.new(0, 15) })
    
    return setmetatable({ Container = container }, Groupbox)
end

-- ==========================================
-- COMPONENTS
-- ==========================================

function Groupbox:AddToggle(idx, config)
    local toggled = config.Default or false
    local callback = config.Callback or function() end
    
    local frame = Library:Create("Frame", {
        Parent = self.Container, Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1
    })
    
    local label = Library:Create("TextLabel", {
        Parent = frame, Size = UDim2.new(0.8, 0, 1, 0), BackgroundTransparency = 1,
        Text = config.Text or "Toggle", Font = Enum.Font.GothamMedium, TextSize = 13,
        TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local switch = Library:Create("Frame", {
        Parent = frame, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 36, 0, 20), BackgroundColor3 = Library.Theme.Border
    })
    Library:AddCorner(switch, 20)
    
    local handle = Library:Create("Frame", {
        Parent = switch, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16), BackgroundColor3 = Library.Theme.Text
    })
    Library:AddCorner(handle, 20)
    
    local function Update()
        Library:Tween(switch, {BackgroundColor3 = toggled and Library.Theme.Accent or Library.Theme.Border}, 0.2)
        Library:Tween(handle, {Position = UDim2.new(0, toggled and 18 or 2, 0.5, 0)}, 0.2)
        callback(toggled)
    end
    
    local btn = Library:Create("TextButton", {
        Parent = frame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""
    })
    btn.MouseButton1Click:Connect(function() toggled = not toggled; Update() end)
    
    -- Animation: Switch Hover
    btn.MouseEnter:Connect(function()
        if not toggled then Library:Tween(switch, {BackgroundColor3 = Library.Theme.ElementBackgroundHover}, 0.2) end
    end)
    btn.MouseLeave:Connect(function()
        if not toggled then Library:Tween(switch, {BackgroundColor3 = Library.Theme.Border}, 0.2) end
    end)

    Update()
    Options[idx] = { Value = toggled, SetValue = function(s, v) toggled = v; Update() end }
end

function Groupbox:AddSlider(idx, config)
    local min, max = config.Min or 0, config.Max or 100
    local rounding = config.Rounding or 1
    local value = config.Default or min
    local callback = config.Callback or function() end
    
    local frame = Library:Create("Frame", {
        Parent = self.Container, Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1
    })
    
    local label = Library:Create("TextLabel", {
        Parent = frame, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
        Text = config.Text or "Slider", Font = Enum.Font.GothamMedium, TextSize = 13,
        TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local valLabel = Library:Create("TextLabel", {
        Parent = frame, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
        Text = tostring(value), Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Right
    })
    
    local track = Library:Create("Frame", {
        Parent = frame, Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = Library.Theme.ElementBackgroundHover
    })
    Library:AddCorner(track, 4) -- Rounded rectangle track
    
    local fill = Library:Create("Frame", {
        Parent = track, Size = UDim2.new((value-min)/(max-min), 0, 1, 0),
        BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0
    })
    Library:AddCorner(fill, 4)
    
    -- Knob: Rounded Square as requested
    local knob = Library:Create("Frame", {
        Parent = fill, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = Color3.new(1,1,1)
    })
    Library:AddCorner(knob, 4) -- Radius 4 = Rounded Square (not circle)
    
    local function Update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * pos
        value = math.floor(value * (10^rounding) + 0.5) / (10^rounding)
        
        Library:Tween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.05)
        valLabel.Text = tostring(value)
        callback(value)
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Update(input)
            Library:Tween(knob, {Size = UDim2.new(0, 18, 0, 18)}, 0.1) -- Click animation (grow)
            
            local move = UserInputService.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
            local endC; endC = UserInputService.InputEnded:Connect(function(i) 
                if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                    move:Disconnect(); endC:Disconnect() 
                    Library:Tween(knob, {Size = UDim2.new(0, 14, 0, 14)}, 0.1) -- Release animation (shrink)
                end 
            end)
        end
    end)
    
    -- Hover Animation for Knob
    local hoverZone = Library:Create("TextButton", {
        Parent = track, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""
    })
    hoverZone.MouseEnter:Connect(function()
        Library:Tween(knob, {BackgroundColor3 = Library.Theme.AccentHover}, 0.2)
    end)
    hoverZone.MouseLeave:Connect(function()
        Library:Tween(knob, {BackgroundColor3 = Color3.new(1,1,1)}, 0.2)
    end)
    
    Options[idx] = { Value = value }
end

return Library
