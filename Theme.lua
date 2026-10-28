--[[
    WindUI — Theme & Typography System
    Manages semantic color palettes, reactive element binding, and typography
]]

local TweenService = game:GetService("TweenService")

local Theme = {}
Theme.__index = Theme

-- Default Monochrome palette specified in design prompt
local THEMES = {
    Monochrome = {
        Name = "Monochrome",
        Background = Color3.fromHex("#101010"),
        Card = Color3.fromHex("#141416"),
        Accent = Color3.fromHex("#18181B"),
        Active = Color3.fromHex("#27272A"),
        Outline = Color3.fromHex("#27272A"),
        OutlineBright = Color3.fromHex("#3F3F46"),
        Text = Color3.fromHex("#FFFFFF"),
        SubText = Color3.fromHex("#A1A1AA"),
        Placeholder = Color3.fromHex("#71717A"),
        Button = Color3.fromHex("#27272A"),
        ButtonHover = Color3.fromHex("#3F3F46"),
        Icon = Color3.fromHex("#A1A1AA"),
        IconActive = Color3.fromHex("#FFFFFF"),
        Success = Color3.fromHex("#22C55E"),
        Warning = Color3.fromHex("#F59E0B"),
        Error = Color3.fromHex("#EF4444"),
        Info = Color3.fromHex("#3B82F6"),
    },
    Dark = {
        Name = "Dark",
        Background = Color3.fromHex("#09090B"),
        Card = Color3.fromHex("#121215"),
        Accent = Color3.fromHex("#18181B"),
        Active = Color3.fromHex("#27272A"),
        Outline = Color3.fromHex("#27272A"),
        OutlineBright = Color3.fromHex("#3F3F46"),
        Text = Color3.fromHex("#FAFAFA"),
        SubText = Color3.fromHex("#A1A1AA"),
        Placeholder = Color3.fromHex("#71717A"),
        Button = Color3.fromHex("#27272A"),
        ButtonHover = Color3.fromHex("#3F3F46"),
        Icon = Color3.fromHex("#A1A1AA"),
        IconActive = Color3.fromHex("#FFFFFF"),
        Success = Color3.fromHex("#22C55E"),
        Warning = Color3.fromHex("#F59E0B"),
        Error = Color3.fromHex("#EF4444"),
        Info = Color3.fromHex("#3B82F6"),
    },
    Midnight = {
        Name = "Midnight",
        Background = Color3.fromHex("#080A10"),
        Card = Color3.fromHex("#0E121D"),
        Accent = Color3.fromHex("#13192B"),
        Active = Color3.fromHex("#1D253F"),
        Outline = Color3.fromHex("#1E293B"),
        OutlineBright = Color3.fromHex("#334155"),
        Text = Color3.fromHex("#F8FAFC"),
        SubText = Color3.fromHex("#94A3B8"),
        Placeholder = Color3.fromHex("#64748B"),
        Button = Color3.fromHex("#1E293B"),
        ButtonHover = Color3.fromHex("#334155"),
        Icon = Color3.fromHex("#94A3B8"),
        IconActive = Color3.fromHex("#38BDF8"),
        Success = Color3.fromHex("#10B981"),
        Warning = Color3.fromHex("#F59E0B"),
        Error = Color3.fromHex("#F43F5E"),
        Info = Color3.fromHex("#0EA5E9"),
    },
    Light = {
        Name = "Light",
        Background = Color3.fromHex("#F4F4F5"),
        Card = Color3.fromHex("#FFFFFF"),
        Accent = Color3.fromHex("#E4E4E7"),
        Active = Color3.fromHex("#D4D4D8"),
        Outline = Color3.fromHex("#E4E4E7"),
        OutlineBright = Color3.fromHex("#D4D4D8"),
        Text = Color3.fromHex("#09090B"),
        SubText = Color3.fromHex("#71717A"),
        Placeholder = Color3.fromHex("#A1A1AA"),
        Button = Color3.fromHex("#E4E4E7"),
        ButtonHover = Color3.fromHex("#D4D4D8"),
        Icon = Color3.fromHex("#71717A"),
        IconActive = Color3.fromHex("#09090B"),
        Success = Color3.fromHex("#16A34A"),
        Warning = Color3.fromHex("#D97706"),
        Error = Color3.fromHex("#DC2626"),
        Info = Color3.fromHex("#2563EB"),
    }
}

local currentTheme = THEMES.Monochrome
local registeredElements = {} -- Array of { instance = Instance, property = string, colorKey = string }

-- Typography config
local Fonts = {
    Regular = Enum.Font.GothamMedium,
    Bold = Enum.Font.GothamBold,
    Semibold = Enum.Font.GothamSemibold,
    Code = Enum.Font.Code,
}

function Theme.GetFont(style: string?): Enum.Font
    return Fonts[style or "Regular"] or Enum.Font.GothamMedium
end

function Theme.GetThemes()
    return THEMES
end

function Theme.GetCurrentTheme()
    return currentTheme
end

function Theme.GetColor(colorKey: string): Color3
    return currentTheme[colorKey] or currentTheme.Text
end

function Theme.AddTheme(themeData: { [string]: any })
    assert(type(themeData) == "table", "Theme data must be a table")
    assert(themeData.Name, "Theme must have a Name")

    local base = table.clone(THEMES.Monochrome)
    for k, v in pairs(themeData) do
        base[k] = v
    end
    THEMES[themeData.Name] = base
    return base
end

function Theme.SetTheme(name: string)
    local target = THEMES[name]
    if not target then
        warn(string.format("[WindUI:Theme] Theme '%s' not found. Available: Monochrome, Dark, Midnight, Light", tostring(name)))
        return
    end

    currentTheme = target

    -- Smoothly tween all registered UI elements to the new theme
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    for i = #registeredElements, 1, -1 do
        local entry = registeredElements[i]
        if entry.instance and entry.instance.Parent then
            local newColor = target[entry.colorKey]
            if newColor then
                pcall(function()
                    TweenService:Create(entry.instance, tweenInfo, {
                        [entry.property] = newColor
                    }):Play()
                end)
            end
        else
            table.remove(registeredElements, i)
        end
    end
end

function Theme.Register(instance: Instance, property: string, colorKey: string)
    if not instance then return end

    -- Set initial color
    local color = Theme.GetColor(colorKey)
    if color then
        pcall(function()
            (instance :: any)[property] = color
        end)
    end

    table.insert(registeredElements, {
        instance = instance,
        property = property,
        colorKey = colorKey,
    })
end

function Theme.Unregister(instance: Instance)
    for i = #registeredElements, 1, -1 do
        if registeredElements[i].instance == instance then
            table.remove(registeredElements, i)
        end
    end
end

return Theme
