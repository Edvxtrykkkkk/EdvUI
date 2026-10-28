--[[
    WindUI — Master Public Entry Point
    Version: 2.9.0-modular
    Modular Roblox Luau UI Library
]]

local Environment = require(script.System.Environment)
local Theme = require(script.System.Theme)
local Icons = require(script.UI.Icons)
local Notify = require(script.UI.Notify)
local MainUI = require(script.UI.MainUI)
local Components = require(script.UI.Components)

local WindUI = {
    Version = "2.9.0-modular",
    Environment = Environment,
    Theme = Theme,
    Icons = Icons,
    NotifyModule = Notify,
    Components = Components,
}
WindUI.__index = WindUI

local currentScreenGui: ScreenGui? = nil
local activeWindows = {}

function WindUI:GetScreenGui(): ScreenGui
    if currentScreenGui and currentScreenGui.Parent then
        return currentScreenGui
    end
    currentScreenGui = Environment.CreateScreenGui()
    return currentScreenGui
end

function WindUI:CreateWindow(config: MainUI.WindowConfig)
    local screenGui = self:GetScreenGui()
    local window = MainUI.CreateWindow(screenGui, config)
    table.insert(activeWindows, window)
    return window
end

function WindUI:AddTheme(themeData: { [string]: any })
    return Theme.AddTheme(themeData)
end

function WindUI:SetTheme(name: string)
    Theme.SetTheme(name)
end

function WindUI:Notify(config: Notify.NotifyConfig)
    local screenGui = self:GetScreenGui()
    Notify.Show(screenGui, config)
end

function WindUI:Destroy()
    for _, win in ipairs(activeWindows) do
        pcall(function() win:Destroy() end)
    end
    table.clear(activeWindows)
    if currentScreenGui then
        currentScreenGui:Destroy()
        currentScreenGui = nil
    end
end

return WindUI
