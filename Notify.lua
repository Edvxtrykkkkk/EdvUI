--[[
    WindUI — Notification System
    Stacked notifications with entrance/exit tweens, progress indicators, and theme integration
]]

local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.System.Theme)
local Icons = require(script.Parent.Icons)

local Notify = {}
Notify.__index = Notify

local notifyContainer: Frame? = nil
local activeNotifications = {}

local function EnsureContainer(screenGui: ScreenGui): Frame
    if notifyContainer and notifyContainer.Parent then
        return notifyContainer
    end

    local container = Instance.new("Frame")
    container.Name = "WindUI_NotifyContainer"
    container.BackgroundTransparency = 1
    container.AnchorPoint = Vector2.new(1, 1)
    container.Position = UDim2.new(1, -20, 1, -20)
    container.Size = UDim2.new(0, 320, 1, -40)
    container.ZIndex = 2000
    container.Parent = screenGui

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container

    notifyContainer = container
    return container
end

export type NotifyConfig = {
    Title: string,
    Content: string,
    Icon: string?,
    Duration: number?,
    Type: ("Success" | "Warning" | "Error" | "Info")?,
}

function Notify.Show(screenGui: ScreenGui, config: NotifyConfig)
    local container = EnsureContainer(screenGui)
    local duration = config.Duration or 4
    local notifType = config.Type or "Info"

    -- Type color lookup
    local typeColorKey = "Info"
    if notifType == "Success" then
        typeColorKey = "Success"
    elseif notifType == "Warning" then
        typeColorKey = "Warning"
    elseif notifType == "Error" then
        typeColorKey = "Error"
    end

    -- Card Frame
    local card = Instance.new("Frame")
    card.Name = "Notification"
    card.Size = UDim2.new(1, 0, 0, 0) -- Starts at 0 height for expansion
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Theme.GetColor("Card")
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.BackgroundTransparency = 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.GetColor("Outline")
    stroke.Thickness = 1
    stroke.Transparency = 1
    stroke.Parent = card

    Theme.Register(card, "BackgroundColor3", "Card")
    Theme.Register(stroke, "Color", "Outline")

    -- Content layout
    local contentFrame = Instance.new("Frame")
    contentFrame.BackgroundTransparency = 1
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.AutomaticSize = Enum.AutomaticSize.Y
    contentFrame.Parent = card

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = contentFrame

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 4)
    list.Parent = contentFrame

    -- Header row
    local headerRow = Instance.new("Frame")
    headerRow.BackgroundTransparency = 1
    headerRow.Size = UDim2.new(1, 0, 0, 20)
    headerRow.LayoutOrder = 1
    headerRow.Parent = contentFrame

    -- Left icon or indicator
    local iconId = Icons.Resolve(config.Icon or (notifType == "Success" and "check" or (notifType == "Error" and "x" or "info")))
    if iconId then
        local iconImg = Instance.new("ImageLabel")
        iconImg.BackgroundTransparency = 1
        iconImg.Size = UDim2.new(0, 18, 0, 18)
        iconImg.Position = UDim2.new(0, 0, 0.5, -9)
        iconImg.Image = iconId
        iconImg.ImageColor3 = Theme.GetColor(typeColorKey)
        iconImg.Parent = headerRow
    end

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, iconId and 24 or 0, 0, 0)
    titleLbl.Size = UDim2.new(1, iconId and -48 or -24, 1, 0)
    titleLbl.Font = Theme.GetFont("Bold")
    titleLbl.Text = config.Title or "Notification"
    titleLbl.TextColor3 = Theme.GetColor("Text")
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerRow
    Theme.Register(titleLbl, "TextColor3", "Text")

    -- Close button
    local closeBtn = Instance.new("ImageButton")
    closeBtn.BackgroundTransparency = 1
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.Position = UDim2.new(1, 0, 0.5, 0)
    closeBtn.Size = UDim2.new(0, 16, 0, 16)
    closeBtn.Image = Icons.Resolve("x") or ""
    closeBtn.ImageColor3 = Theme.GetColor("SubText")
    closeBtn.Parent = headerRow
    Theme.Register(closeBtn, "ImageColor3", "SubText")

    -- Content text
    if config.Content and config.Content ~= "" then
        local contentLbl = Instance.new("TextLabel")
        contentLbl.BackgroundTransparency = 1
        contentLbl.Size = UDim2.new(1, 0, 0, 0)
        contentLbl.AutomaticSize = Enum.AutomaticSize.Y
        contentLbl.Font = Theme.GetFont("Regular")
        contentLbl.Text = config.Content
        contentLbl.TextColor3 = Theme.GetColor("SubText")
        contentLbl.TextSize = 12
        contentLbl.TextWrapped = true
        contentLbl.TextXAlignment = Enum.TextXAlignment.Left
        contentLbl.LayoutOrder = 2
        contentLbl.Parent = contentFrame
        Theme.Register(contentLbl, "TextColor3", "SubText")
    end

    -- Timer progress bar at the bottom
    local progressTrack = Instance.new("Frame")
    progressTrack.BackgroundColor3 = Theme.GetColor("Accent")
    progressTrack.BorderSizePixel = 0
    progressTrack.Size = UDim2.new(1, 0, 0, 2)
    progressTrack.Position = UDim2.new(0, 0, 1, -2)
    progressTrack.Parent = card

    local progressBar = Instance.new("Frame")
    progressBar.BackgroundColor3 = Theme.GetColor(typeColorKey)
    progressBar.BorderSizePixel = 0
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.Parent = progressTrack

    card.Parent = container

    -- Entrance animation
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(card, tweenInfo, { BackgroundTransparency = 0.05 }):Play()
    TweenService:Create(stroke, tweenInfo, { Transparency = 0 }):Play()

    -- Progress countdown
    local progressTween = TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    })
    progressTween:Play()

    local isDismissed = false
    local function Dismiss()
        if isDismissed then return end
        isDismissed = true

        local exitTween = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        })
        TweenService:Create(stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Transparency = 1
        }):Play()

        exitTween:Play()
        exitTween.Completed:Connect(function()
            Theme.Unregister(card)
            Theme.Unregister(stroke)
            card:Destroy()
        end)
    end

    closeBtn.MouseButton1Click:Connect(Dismiss)
    task.delay(duration, Dismiss)
end

return Notify
