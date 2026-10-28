--[[
    WindUI — Environment Manager
    Defensive environment detection, GUI parenting, and lifecycle cleanup
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Environment = {}
Environment.__index = Environment

local LIBRARY_TAG = "WindUI_Library_Root_Instance"

function Environment.GetParent(): Instance
    -- 1. Try executor gethui() if safely available
    local success, result = pcall(function()
        if typeof(gethui) == "function" then
            return gethui()
        end
        return nil
    end)
    if success and result and typeof(result) == "Instance" then
        return result
    end

    -- 2. Try CoreGui if permission allows
    local coreSuccess, coreResult = pcall(function()
        return CoreGui
    end)
    if coreSuccess and coreResult and typeof(coreResult) == "Instance" then
        -- Test if we can parent to CoreGui without error
        local testTest = pcall(function()
            local test = Instance.new("Folder")
            test.Parent = CoreGui
            test:Destroy()
        end)
        if testTest then
            return CoreGui
        end
    end

    -- 3. Standard fallback: LocalPlayer PlayerGui
    local player = Players.LocalPlayer
    if player then
        local playerGui = player:FindFirstChildWhichIsA("PlayerGui") or player:WaitForChild("PlayerGui", 5)
        if playerGui then
            return playerGui
        end
    end

    return CoreGui
end

function Environment.GenerateSafeName(): string
    -- Generate 32 bytes of safe hex randomness for unique naming
    local hexChars = "0123456789abcdef"
    local buffer = {}
    for i = 1, 32 do
        local rand = math.random(1, #hexChars)
        table.insert(buffer, string.sub(hexChars, rand, rand))
    end
    return "WindUI_" .. table.concat(buffer)
end

function Environment.CleanupPreviousInstances(parent: Instance?)
    local targetParent = parent or Environment.GetParent()
    if not targetParent then return end

    pcall(function()
        for _, child in ipairs(targetParent:GetChildren()) do
            if child:IsA("ScreenGui") and child:GetAttribute(LIBRARY_TAG) == true then
                child:Destroy()
            end
        end
    end)
end

function Environment.CreateScreenGui(): ScreenGui
    local parent = Environment.GetParent()
    Environment.CleanupPreviousInstances(parent)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = Environment.GenerateSafeName()
    screenGui:SetAttribute(LIBRARY_TAG, true)
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 1000

    -- Protect parenting
    pcall(function()
        screenGui.Parent = parent
    end)

    return screenGui
end

return Environment
