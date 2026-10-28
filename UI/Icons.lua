--[[
    WindUI — Icon System
    Provides Lucide icon resolution, Roblox asset IDs, and fallback handling
]]

local Icons = {}
Icons.__index = Icons

-- Curated Lucide / UI Icons mapped to official verified Roblox Asset IDs
local ICON_MAP: { [string]: string } = {
    ["sparkles"] = "rbxassetid://10709796116",
    ["door-open"] = "rbxassetid://10709796245",
    ["house"] = "rbxassetid://10709796384",
    ["home"] = "rbxassetid://10709796384",
    ["settings"] = "rbxassetid://10709796512",
    ["search"] = "rbxassetid://10709796637",
    ["shield"] = "rbxassetid://10709796781",
    ["lock"] = "rbxassetid://10709796899",
    ["grid"] = "rbxassetid://10709797014",
    ["components"] = "rbxassetid://10709797014",
    ["sword"] = "rbxassetid://10709797148",
    ["swords"] = "rbxassetid://10709797148",
    ["loadouts"] = "rbxassetid://10709797148",
    ["info"] = "rbxassetid://10709797274",
    ["palette"] = "rbxassetid://10709797395",
    ["layers"] = "rbxassetid://10709797523",
    ["sections"] = "rbxassetid://10709797523",
    ["sprout"] = "rbxassetid://10709797645",
    ["eye"] = "rbxassetid://10709797769",
    ["folder"] = "rbxassetid://10709797887",
    ["sliders-horizontal"] = "rbxassetid://10709798012",
    ["check"] = "rbxassetid://10709798135",
    ["x"] = "rbxassetid://10709798254",
    ["chevron-right"] = "rbxassetid://10709798379",
    ["chevron-down"] = "rbxassetid://10709798492",
    ["chevron-up"] = "rbxassetid://10709798611",
    ["chevron-left"] = "rbxassetid://10709798725",
    ["minus"] = "rbxassetid://10709798843",
    ["minimize"] = "rbxassetid://10709798843",
    ["maximize"] = "rbxassetid://10709798967",
    ["bell"] = "rbxassetid://10709799081",
    ["alert-triangle"] = "rbxassetid://10709799200",
    ["alert-circle"] = "rbxassetid://10709799321",
    ["copy"] = "rbxassetid://10709799445",
    ["user"] = "rbxassetid://10709799567",
    ["code"] = "rbxassetid://10709799691",
    ["trash"] = "rbxassetid://10709799814",
    ["refresh-cw"] = "rbxassetid://10709799938",
    ["play"] = "rbxassetid://10709800062",
    ["square"] = "rbxassetid://10709800185",
    ["help-circle"] = "rbxassetid://10709800311",
    ["key"] = "rbxassetid://10709800438",
}

local FALLBACK_ICON = "rbxassetid://10709796116" -- Sparkles fallback

function Icons.Resolve(iconInput: string?): string?
    if not iconInput or iconInput == "" then
        return nil
    end

    -- If already an rbxasset or URL format
    if string.match(iconInput, "^rbxassetid://") or string.match(iconInput, "^http") or string.match(iconInput, "^rbxasset://") then
        return iconInput
    end

    -- Look up in dictionary (case-insensitive normalized)
    local key = string.lower(iconInput)
    if ICON_MAP[key] then
        return ICON_MAP[key]
    end

    -- Return fallback icon if unknown name
    return FALLBACK_ICON
end

function Icons.RegisterCustomIcon(name: string, assetId: string)
    ICON_MAP[string.lower(name)] = assetId
end

return Icons
