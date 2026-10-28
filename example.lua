--[[
    WindUI — Complete Showcase Example
    Replicates the exact layout and controls from the provided design reference:
    - Vind Ui Reborn (Complete Showcase · v2.9.0-modular)
    - Profile card: SkFOrest (@luis_akz4)
    - Sidebar tabs & category
    - SubTabs: Auto Farm, Settings, Visuals, Profiles
    - Sliders, Toggles, Dropdowns, Expandables, Sections
]]

-- Load WindUI (when testing locally in Studio, require the main module or use bundle)
local WindUI = require(game:GetService("ReplicatedStorage"):WaitForChild("WindUI").main)

-- 1. Create Main Window
local Window = WindUI:CreateWindow({
    Title = "Vind Ui Reborn",
    Author = "Complete Showcase · v2.9.0-modular",
    Icon = "sparkles",
    Profile = {
        Username = "SkFOrest",
        Handle = "@luis_akz4",
        Avatar = "rbxassetid://10709799567",
    }
})

-- Welcome Notification
WindUI:Notify({
    Title = "WindUI Reborn",
    Content = "Showcase loaded successfully. Welcome back, SkFOrest!",
    Icon = "sparkles",
    Duration = 4,
    Type = "Success",
})

-- 2. Sidebar Navigation Tabs
local ComponentsTab = Window:CreateTab({
    Title = "Components",
    Icon = "grid",
})

local LoadoutsTab = Window:CreateTab({
    Title = "Loadouts",
    Icon = "swords",
})

local AdminTab = Window:CreateTab({
    Title = "Admin",
    Icon = "shield",
    Locked = true,
})

local AboutTab = Window:CreateTab({
    Title = "About",
    Icon = "info",
})

local EmptyTab = Window:CreateTab({
    Title = "Empty",
    Icon = "grid",
})

-- Add Category Separator
Window:AddCategory("Examples")

-- 3. Sections Tab (The active showcase tab seen in reference image)
local SectionsTab = Window:CreateTab({
    Title = "Sections",
    Icon = "layers",
})

-- SubTabs matching the top pill bar
local AutoFarmSub = SectionsTab:CreateSubTab({
    Title = "Auto Farm",
    Icon = "sprout",
})

local SettingsSub = SectionsTab:CreateSubTab({
    Title = "Settings",
    Icon = "sliders-horizontal",
})

local VisualsSub = SectionsTab:CreateSubTab({
    Title = "Visuals",
    Icon = "eye",
})

local ProfilesSub = SectionsTab:CreateSubTab({
    Title = "Profiles",
    Icon = "folder",
})

-- =========================================================================
-- Populate "Auto Farm" SubTab (Exact match to screenshot!)
-- =========================================================================

-- Slider: "Intensity 50"
AutoFarmSub:Slider({
    Title = "Intensity",
    Value = {
        Min = 0,
        Max = 100,
        Default = 50,
        Step = 1,
    },
    Callback = function(val)
        print("Intensity changed to:", val)
    end,
})

-- Expandable: "Advanced >"
local AdvancedGroup = AutoFarmSub:Expandable({
    Title = "Advanced",
    DefaultExpanded = false,
})
AdvancedGroup:Button({
    Title = "Optimize Raycasts",
    Description = "Reduces CPU cycles when raycasting targets.",
    Callback = function()
        WindUI:Notify({
            Title = "Advanced",
            Content = "Raycast optimization enabled.",
            Type = "Info",
        })
    end
})

-- Section Group: "General v"
local GeneralSection = AutoFarmSub:Section({
    Title = "General",
    Collapsible = true,
    DefaultCollapsed = false,
})

-- Inner Toggle: "Enable Auto Farm"
GeneralSection:Toggle({
    Title = "Enable Auto Farm",
    Value = false,
    Callback = function(enabled)
        print("Auto Farm status:", enabled)
        WindUI:Notify({
            Title = "Auto Farm",
            Content = enabled and "Auto farm activated." or "Auto farm paused.",
            Icon = "sprout",
            Type = enabled and "Success" or "Warning",
        })
    end,
})

-- Inner Dropdown: "Mode: Nearest v"
GeneralSection:Dropdown({
    Title = "Mode",
    Values = { "Nearest", "Highest Level", "Lowest Health", "Custom Target" },
    Value = "Nearest",
    Callback = function(mode)
        print("Selected mode:", mode)
    end,
})

-- Expandable: "Limits >"
local LimitsGroup = AutoFarmSub:Expandable({
    Title = "Limits",
    DefaultExpanded = false,
})
LimitsGroup:Slider({
    Title = "Max Distance (studs)",
    Value = { Min = 10, Max = 500, Default = 150 },
    Callback = function(d) print("Distance limit:", d) end
})
LimitsGroup:Toggle({
    Title = "Ignore Obstacles",
    Value = true,
    Callback = function(v) print("Ignore obstacles:", v) end
})

-- =========================================================================
-- Populate Appearance Tab
-- =========================================================================
local AppearanceTab = Window:CreateTab({
    Title = "Appearance",
    Icon = "palette",
})

AppearanceTab:Paragraph({
    Title = "Theme Customization",
    Content = "WindUI features a primary monochrome dark aesthetic with smooth reactive color switching and mobile-responsive layout.",
})

AppearanceTab:Dropdown({
    Title = "Active Theme",
    Values = { "Monochrome", "Dark", "Midnight", "Light" },
    Value = "Monochrome",
    Callback = function(themeName)
        WindUI:SetTheme(themeName)
        WindUI:Notify({
            Title = "Theme Switched",
            Content = "Applied " .. themeName .. " theme.",
            Icon = "palette",
            Type = "Info",
        })
    end,
})

AppearanceTab:Colorpicker({
    Title = "Accent Color",
    Default = Color3.fromHex("#FAFAFA"),
    Callback = function(col)
        print("Accent updated:", col)
    end
})

AppearanceTab:Keybind({
    Title = "Toggle UI Keybind",
    Default = Enum.KeyCode.RightControl,
    Callback = function()
        Window:Toggle()
    end,
})

-- Components Tab Showcase
ComponentsTab:Paragraph({
    Title = "Component Library",
    Content = "Interactive controls including Toggles, Sliders, Dropdowns, Inputs, Keybinds, Buttons, and Expandables.",
})

ComponentsTab:Input({
    Title = "Custom Nickname",
    Placeholder = "Enter display name...",
    Callback = function(txt)
        print("Nickname:", txt)
    end
})

ComponentsTab:Button({
    Title = "Trigger Test Notification",
    Description = "Sends a stacked notification with animated progress timer.",
    Icon = "bell",
    Callback = function()
        WindUI:Notify({
            Title = "Alert",
            Content = "This is a live test notification from WindUI Components.",
            Duration = 3,
            Type = "Info",
        })
    end,
})

AboutTab:Paragraph({
    Title = "WindUI Reborn",
    Content = "Crafted with modular Luau architecture, high precision UI strokes, and reactive theme bindings. Version 2.9.0-modular.",
})

return Window
