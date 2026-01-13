-- PROJECT SPECTRE - SAVE MANAGER
-- Handles configuration saving and loading

local HttpService = game:GetService("HttpService")

local SaveManager = {
    Library = nil,
    Folder = "ProjectSpectre",
    IgnoreIndexes = {},
    ConfigSubFolder = "Configs"
}

function SaveManager:SetLibrary(library)
    self.Library = library
end

function SaveManager:SetFolder(folder)
    self.Folder = folder or "ProjectSpectre"
end

function SaveManager:SetIgnoreIndexes(indexes)
    for _, index in pairs(indexes) do
        self.IgnoreIndexes[index] = true
    end
end

function SaveManager:IgnoreThemeSettings()
    self.IgnoreIndexes['ThemeSelector'] = true
end

function SaveManager:BuildConfigSection(tab)
    if not self.Library then
        warn("[SaveManager] Library not set!")
        return
    end
    
    local configBox = tab:AddRightGroupbox('Configuration')
    
    configBox:AddLabel('Config Manager')
    configBox:AddDivider()
    
    configBox:AddInput('ConfigName', {
        Default = 'MyConfig',
        Numeric = false,
        Finished = true,
        Text = 'Config Name',
        Placeholder = 'config name...'
    })
    
    configBox:AddButton({
        Text = 'Save Config',
        Func = function()
            local name = getgenv().Options.ConfigName.Value
            self:SaveConfig(name)
        end,
        Tooltip = 'Save current settings'
    })
    
    configBox:AddButton({
        Text = 'Load Config',
        Func = function()
            local name = getgenv().Options.ConfigName.Value
            self:LoadConfig(name)
        end,
        Tooltip = 'Load saved settings'
    })
    
    configBox:AddButton({
        Text = 'Delete Config',
        Func = function()
            local name = getgenv().Options.ConfigName.Value
            self:DeleteConfig(name)
        end,
        Tooltip = 'Delete saved config'
    })
    
    configBox:AddToggle('AutoLoad', {
        Text = 'Auto Load',
        Default = false,
        Tooltip = 'Automatically load config on startup'
    })
end

function SaveManager:SaveConfig(name)
    if not self.Library then return end
    
    local configData = {
        Options = {},
        Toggles = {}
    }
    
    -- Save Options
    for idx, option in pairs(getgenv().Options) do
        if not self.IgnoreIndexes[idx] then
            configData.Options[idx] = option.Value
        end
    end
    
    -- Save Toggles
    for idx, toggle in pairs(getgenv().Toggles) do
        if not self.IgnoreIndexes[idx] then
            configData.Toggles[idx] = toggle.Value
        end
    end
    
    local success, err = pcall(function()
        if not isfolder(self.Folder) then
            makefolder(self.Folder)
        end
        if not isfolder(self.Folder .. "/" .. self.ConfigSubFolder) then
            makefolder(self.Folder .. "/" .. self.ConfigSubFolder)
        end
        
        local filePath = self.Folder .. "/" .. self.ConfigSubFolder .. "/" .. name .. ".json"
        local encoded = HttpService:JSONEncode(configData)
        writefile(filePath, encoded)
    end)
    
    if success then
        print("[SaveManager] Saved config:", name)
    else
        warn("[SaveManager] Failed to save:", err)
    end
end

function SaveManager:LoadConfig(name)
    if not self.Library then return end
    
    local success, result = pcall(function()
        local filePath = self.Folder .. "/" .. self.ConfigSubFolder .. "/" .. name .. ".json"
        if not isfile(filePath) then
            return nil, "Config not found"
        end
        
        local content = readfile(filePath)
        return HttpService:JSONDecode(content)
    end)
    
    if not success or not result then
        warn("[SaveManager] Failed to load:", result)
        return
    end
    
    -- Load Options
    for idx, value in pairs(result.Options or {}) do
        if getgenv().Options[idx] then
            getgenv().Options[idx]:SetValue(value)
        end
    end
    
    -- Load Toggles
    for idx, value in pairs(result.Toggles or {}) do
        if getgenv().Toggles[idx] then
            getgenv().Toggles[idx]:SetValue(value)
        end
    end
    
    print("[SaveManager] Loaded config:", name)
end

function SaveManager:DeleteConfig(name)
    local success, err = pcall(function()
        local filePath = self.Folder .. "/" .. self.ConfigSubFolder .. "/" .. name .. ".json"
        if isfile(filePath) then
            delfile(filePath)
        end
    end)
    
    if success then
        print("[SaveManager] Deleted config:", name)
    else
        warn("[SaveManager] Failed to delete:", err)
    end
end

function SaveManager:LoadAutoloadConfig()
    -- Check if AutoLoad toggle is enabled
    if getgenv().Toggles.AutoLoad and getgenv().Toggles.AutoLoad.Value then
        local configName = getgenv().Options.ConfigName.Value or "MyConfig"
        self:LoadConfig(configName)
    end
end

return SaveManager
