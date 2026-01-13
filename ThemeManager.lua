-- PROJECT SPECTRE - THEME MANAGER
-- Handles theme customization and application

local ThemeManager = {
    Library = nil,
    BuiltInThemes = {}
}

-- Built-in themes
ThemeManager.BuiltInThemes = {
    ['Spectre Purple'] = {
        Background = Color3.fromRGB(15, 15, 20),
        MainFrame = Color3.fromRGB(20, 20, 28),
        SecondaryFrame = Color3.fromRGB(25, 25, 35),
        Accent = Color3.fromRGB(138, 43, 226),
        AccentHover = Color3.fromRGB(155, 89, 235),
        Secondary = Color3.fromRGB(0, 174, 219),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(160, 160, 170),
        DisabledText = Color3.fromRGB(100, 100, 110),
        Border = Color3.fromRGB(40, 40, 50),
        ElementBackground = Color3.fromRGB(28, 28, 38),
        ElementBackgroundHover = Color3.fromRGB(33, 33, 43),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60)
    },
    ['Dark Blue'] = {
        Background = Color3.fromRGB(10, 15, 25),
        MainFrame = Color3.fromRGB(15, 20, 30),
        SecondaryFrame = Color3.fromRGB(20, 25, 35),
        Accent = Color3.fromRGB(0, 122, 204),
        AccentHover = Color3.fromRGB(30, 144, 255),
        Secondary = Color3.fromRGB(100, 181, 246),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(160, 160, 170),
        DisabledText = Color3.fromRGB(100, 100, 110),
        Border = Color3.fromRGB(40, 45, 55),
        ElementBackground = Color3.fromRGB(25, 30, 40),
        ElementBackgroundHover = Color3.fromRGB(30, 35, 45),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60)
    },
    ['Cyber Red'] = {
        Background = Color3.fromRGB(20, 10, 10),
        MainFrame = Color3.fromRGB(28, 15, 15),
        SecondaryFrame = Color3.fromRGB(35, 20, 20),
        Accent = Color3.fromRGB(220, 20, 60),
        AccentHover = Color3.fromRGB(255, 50, 80),
        Secondary = Color3.fromRGB(255, 100, 120),
        Text = Color3.fromRGB(245, 240, 240),
        SubText = Color3.fromRGB(170, 160, 160),
        DisabledText = Color3.fromRGB(110, 100, 100),
        Border = Color3.fromRGB(50, 40, 40),
        ElementBackground = Color3.fromRGB(38, 28, 28),
        ElementBackgroundHover = Color3.fromRGB(43, 33, 33),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60)
    }
}

function ThemeManager:SetLibrary(library)
    self.Library = library
end

function ThemeManager:SetFolder(folder)
    self.Folder = folder or "ProjectSpectre"
end

function ThemeManager:ApplyTheme(themeName)
    if not self.Library then
        warn("[ThemeManager] Library not set!")
        return
    end
    
    local theme = self.BuiltInThemes[themeName]
    if not theme then
        warn("[ThemeManager] Theme not found:", themeName)
        return
    end
    
    for key, color in pairs(theme) do
        self.Library.Theme[key] = color
    end
    
    print("[ThemeManager] Applied theme:", themeName)
end

function ThemeManager:ApplyToTab(tab)
    if not self.Library then
        warn("[ThemeManager] Library not set!")
        return
    end
    
    local themeBox = tab:AddRightGroupbox('Theme Manager')
    
    themeBox:AddLabel('Select Theme')
    themeBox:AddDivider()
    
    local themeNames = {}
    for name in pairs(self.BuiltInThemes) do
        table.insert(themeNames, name)
    end
    table.sort(themeNames)
    
    themeBox:AddDropdown('ThemeSelector', {
        Values = themeNames,
        Default = 'Spectre Purple',
        Multi = false,
        Text = 'Theme',
        Callback = function(Value)
            self:ApplyTheme(Value)
        end
    })
    
    themeBox:AddButton({
        Text = 'Reload UI',
        Func = function()
            if self.Library.Window then
                self.Library.Window.ScreenGui:Destroy()
            end
        end,
        Tooltip = 'Reload UI to apply theme fully'
    })
end

function ThemeManager:ApplyToGroupbox(groupbox)
    -- Similar to ApplyToTab but for a specific groupbox
    groupbox:AddLabel('Theme Manager')
    groupbox:AddDivider()
    
    local themeNames = {}
    for name in pairs(self.BuiltInThemes) do
        table.insert(themeNames, name)
    end
    table.sort(themeNames)
    
    groupbox:AddDropdown('ThemeSelector', {
        Values = themeNames,
        Default = 'Spectre Purple',
        Multi = false,
        Text = 'Theme',
        Callback = function(Value)
            self:ApplyTheme(Value)
        end
    })
end

return ThemeManager
