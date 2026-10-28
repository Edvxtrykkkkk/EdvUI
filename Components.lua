--[[
    WindUI — Reusable Component Library
    Implements Button, Toggle, Slider, Dropdown, Input, Keybind, Paragraph,
    Section, Divider, Colorpicker, Expandable, and SelectOptionList.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Parent.System.Theme)
local Icons = require(script.Parent.Icons)

local Components = {}
Components.__index = Components

local function CreateCard(parent: Instance, name: string, minHeight: number?): Frame
    local card = Instance.new("Frame")
    card.Name = name or "ComponentCard"
    card.BackgroundColor3 = Theme.GetColor("Card")
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, 0, 0, minHeight or 44)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.ClipsDescendants = true
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.GetColor("Outline")
    stroke.Thickness = 1
    stroke.Parent = card

    Theme.Register(card, "BackgroundColor3", "Card")
    Theme.Register(stroke, "Color", "Outline")

    return card
end

-- =========================================================================
-- 1. BUTTON COMPONENT
-- =========================================================================
function Components.Button(container: Instance, config: {
    Title: string,
    Description: string?,
    Icon: string?,
    Callback: (() -> ())?,
})
    local card = CreateCard(container, "ButtonCard", 42)

    local btn = Instance.new("TextButton")
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = card

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = card

    local iconId = Icons.Resolve(config.Icon)
    local iconImg: ImageLabel? = nil
    if iconId then
        iconImg = Instance.new("ImageLabel")
        iconImg.BackgroundTransparency = 1
        iconImg.Size = UDim2.new(0, 18, 0, 18)
        iconImg.Position = UDim2.new(0, 0, 0.5, -9)
        iconImg.Image = iconId
        iconImg.ImageColor3 = Theme.GetColor("Icon")
        iconImg.Parent = card
        Theme.Register(iconImg, "ImageColor3", "Icon")
    end

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, iconId and 26 or 0, 0, 0)
    titleLbl.Size = UDim2.new(1, iconId and -26 or 0, 0, config.Description and 18 or 22)
    titleLbl.Font = Theme.GetFont("Semibold")
    titleLbl.Text = config.Title or "Button"
    titleLbl.TextColor3 = Theme.GetColor("Text")
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card
    Theme.Register(titleLbl, "TextColor3", "Text")

    local descLbl: TextLabel? = nil
    if config.Description then
        descLbl = Instance.new("TextLabel")
        descLbl.BackgroundTransparency = 1
        descLbl.Position = UDim2.new(0, iconId and 26 or 0, 0, 18)
        descLbl.Size = UDim2.new(1, iconId and -26 or 0, 0, 16)
        descLbl.Font = Theme.GetFont("Regular")
        descLbl.Text = config.Description
        descLbl.TextColor3 = Theme.GetColor("SubText")
        descLbl.TextSize = 11
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.Parent = card
        Theme.Register(descLbl, "TextColor3", "SubText")
    end

    local isDisabled = false

    btn.MouseEnter:Connect(function()
        if isDisabled then return end
        TweenService:Create(card, TweenInfo.new(0.2), { BackgroundColor3 = Theme.GetColor("Active") }):Play()
    end)

    btn.MouseLeave:Connect(function()
        if isDisabled then return end
        TweenService:Create(card, TweenInfo.new(0.2), { BackgroundColor3 = Theme.GetColor("Card") }):Play()
    end)

    btn.MouseButton1Down:Connect(function()
        if isDisabled then return end
        TweenService:Create(card, TweenInfo.new(0.1), { BackgroundColor3 = Theme.GetColor("ButtonHover") }):Play()
    end)

    btn.MouseButton1Up:Connect(function()
        if isDisabled then return end
        TweenService:Create(card, TweenInfo.new(0.15), { BackgroundColor3 = Theme.GetColor("Active") }):Play()
        if config.Callback then
            task.spawn(function()
                local ok, err = pcall(config.Callback)
                if not ok then
                    warn("[WindUI:Button Error]", err)
                end
            end)
        end
    end)

    return {
        SetTitle = function(self, newTitle: string)
            titleLbl.Text = newTitle
        end,
        SetDescription = function(self, newDesc: string)
            if descLbl then descLbl.Text = newDesc end
        end,
        SetDisabled = function(self, disabled: boolean)
            isDisabled = disabled
            card.BackgroundTransparency = disabled and 0.5 or 0
        end,
        Destroy = function(self)
            Theme.Unregister(card)
            card:Destroy()
        end
    }
end

-- =========================================================================
-- 2. TOGGLE COMPONENT (Pill switch matching reference screenshot)
-- =========================================================================
function Components.Toggle(container: Instance, config: {
    Title: string,
    Description: string?,
    Value: boolean?,
    Callback: ((boolean) -> ())?,
})
    local card = CreateCard(container, "ToggleCard", 44)
    local state = config.Value == true

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, 0, 0, 0)
    titleLbl.Size = UDim2.new(1, -60, 0, config.Description and 18 or 24)
    titleLbl.Font = Theme.GetFont("Semibold")
    titleLbl.Text = config.Title or "Toggle"
    titleLbl.TextColor3 = Theme.GetColor("Text")
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card
    Theme.Register(titleLbl, "TextColor3", "Text")

    local descLbl: TextLabel? = nil
    if config.Description then
        descLbl = Instance.new("TextLabel")
        descLbl.BackgroundTransparency = 1
        descLbl.Position = UDim2.new(0, 0, 0, 18)
        descLbl.Size = UDim2.new(1, -60, 0, 16)
        descLbl.Font = Theme.GetFont("Regular")
        descLbl.Text = config.Description
        descLbl.TextColor3 = Theme.GetColor("SubText")
        descLbl.TextSize = 11
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.Parent = card
        Theme.Register(descLbl, "TextColor3", "SubText")
    end

    -- Switch pill track
    local track = Instance.new("Frame")
    track.AnchorPoint = Vector2.new(1, 0.5)
    track.Position = UDim2.new(1, 0, 0.5, 0)
    track.Size = UDim2.new(0, 40, 0, 22)
    track.BackgroundColor3 = state and Color3.fromHex("#E4E4E7") or Color3.fromHex("#27272A")
    track.BorderSizePixel = 0
    track.Parent = card

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local trackStroke = Instance.new("UIStroke")
    trackStroke.Color = Theme.GetColor("Outline")
    trackStroke.Thickness = 1
    trackStroke.Parent = track

    -- Switch thumb knob
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.AnchorPoint = Vector2.new(0, 0.5)
    thumb.Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    thumb.BackgroundColor3 = state and Color3.fromHex("#101010") or Color3.fromHex("#A1A1AA")
    thumb.BorderSizePixel = 0
    thumb.Parent = track

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb

    local clickBtn = Instance.new("TextButton")
    clickBtn.BackgroundTransparency = 1
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.Text = ""
    clickBtn.Parent = card

    local isDisabled = false

    local function UpdateVisual(animate: boolean)
        local targetThumbPos = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        local targetTrackColor = state and Color3.fromHex("#FAFAFA") or Color3.fromHex("#27272A")
        local targetThumbColor = state and Color3.fromHex("#101010") or Color3.fromHex("#A1A1AA")

        if animate then
            local info = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            TweenService:Create(thumb, info, { Position = targetThumbPos, BackgroundColor3 = targetThumbColor }):Play()
            TweenService:Create(track, info, { BackgroundColor3 = targetTrackColor }):Play()
        else
            thumb.Position = targetThumbPos
            thumb.BackgroundColor3 = targetThumbColor
            track.BackgroundColor3 = targetTrackColor
        end
    end

    clickBtn.MouseButton1Click:Connect(function()
        if isDisabled then return end
        state = not state
        UpdateVisual(true)
        if config.Callback then
            task.spawn(function()
                local ok, err = pcall(config.Callback, state)
                if not ok then warn("[WindUI:Toggle Error]", err) end
            end)
        end
    end)

    return {
        SetValue = function(self, val: boolean)
            state = val == true
            UpdateVisual(true)
            if config.Callback then
                task.spawn(pcall, config.Callback, state)
            end
        end,
        GetValue = function(self): boolean
            return state
        end,
        SetDisabled = function(self, disabled: boolean)
            isDisabled = disabled
            card.BackgroundTransparency = disabled and 0.5 or 0
        end,
        Destroy = function(self)
            Theme.Unregister(card)
            card:Destroy()
        end
    }
end

-- =========================================================================
-- 3. SLIDER COMPONENT (Matching "Intensity 50" from reference)
-- =========================================================================
function Components.Slider(container: Instance, config: {
    Title: string,
    Description: string?,
    Value: {
        Min: number?,
        Max: number?,
        Default: number?,
        Step: number?,
        Precision: number?,
    }?,
    Callback: ((number) -> ())?,
})
    local valCfg = config.Value or {}
    local min = valCfg.Min or 0
    local max = valCfg.Max or 100
    local step = valCfg.Step or 1
    local precision = valCfg.Precision or 0
    local currentVal = math.clamp(valCfg.Default or min, min, max)

    local card = CreateCard(container, "SliderCard", 54)

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = card

    local headerRow = Instance.new("Frame")
    headerRow.BackgroundTransparency = 1
    headerRow.Size = UDim2.new(1, 0, 0, 18)
    headerRow.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size = UDim2.new(1, -60, 1, 0)
    titleLbl.Font = Theme.GetFont("Semibold")
    titleLbl.Text = config.Title or "Slider"
    titleLbl.TextColor3 = Theme.GetColor("Text")
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerRow
    Theme.Register(titleLbl, "TextColor3", "Text")

    local valueLbl = Instance.new("TextLabel")
    valueLbl.BackgroundTransparency = 1
    valueLbl.AnchorPoint = Vector2.new(1, 0)
    valueLbl.Position = UDim2.new(1, 0, 0, 0)
    valueLbl.Size = UDim2.new(0, 50, 1, 0)
    valueLbl.Font = Theme.GetFont("Regular")
    valueLbl.Text = string.format("%." .. tostring(precision) .. "f", currentVal)
    valueLbl.TextColor3 = Theme.GetColor("SubText")
    valueLbl.TextSize = 13
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    valueLbl.Parent = headerRow
    Theme.Register(valueLbl, "TextColor3", "SubText")

    -- Slider track bar
    local track = Instance.new("Frame")
    track.BackgroundColor3 = Theme.GetColor("Accent")
    track.BorderSizePixel = 0
    track.Size = UDim2.new(1, 0, 0, 5)
    track.Position = UDim2.new(0, 0, 0, 28)
    track.Parent = card

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    -- Fill bar
    local pct = (max > min) and ((currentVal - min) / (max - min)) or 0
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Color3.fromHex("#FAFAFA")
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    -- Thumb knob
    local thumb = Instance.new("Frame")
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(pct, 0, 0.5, 0)
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.BackgroundColor3 = Color3.fromHex("#FFFFFF")
    thumb.BorderSizePixel = 0
    thumb.Parent = track

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb

    local dragging = false
    local isDisabled = false

    local function SetValueInternal(newVal: number, fireCallback: boolean)
        if step > 0 then
            newVal = math.round((newVal - min) / step) * step + min
        end
        newVal = math.clamp(newVal, min, max)
        currentVal = newVal

        local newPct = (max > min) and ((currentVal - min) / (max - min)) or 0
        fill.Size = UDim2.new(newPct, 0, 1, 0)
        thumb.Position = UDim2.new(newPct, 0, 0.5, 0)
        valueLbl.Text = string.format("%." .. tostring(precision) .. "f", currentVal)

        if fireCallback and config.Callback then
            task.spawn(pcall, config.Callback, currentVal)
        end
    end

    local function UpdateFromInput(input: InputObject)
        local trackAbsPos = track.AbsolutePosition.X
        local trackAbsSize = track.AbsoluteSize.X
        local rel = math.clamp((input.Position.X - trackAbsPos) / trackAbsSize, 0, 1)
        local calculated = min + rel * (max - min)
        SetValueInternal(calculated, true)
    end

    card.InputBegan:Connect(function(input)
        if isDisabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateFromInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {
        SetValue = function(self, val: number)
            SetValueInternal(val, true)
        end,
        GetValue = function(self): number
            return currentVal
        end,
        SetDisabled = function(self, disabled: boolean)
            isDisabled = disabled
            card.BackgroundTransparency = disabled and 0.5 or 0
        end,
        Destroy = function(self)
            Theme.Unregister(card)
            card:Destroy()
        end
    }
end

-- =========================================================================
-- 4. DROPDOWN COMPONENT (Matching "Mode: Nearest v")
-- =========================================================================
function Components.Dropdown(container: Instance, config: {
    Title: string,
    Description: string?,
    Values: { string }?,
    Value: (string | { string })?,
    Multi: boolean?,
    Callback: ((any) -> ())?,
})
    local values = config.Values or {}
    local multi = config.Multi == true
    local selected = config.Value or (multi and {} or values[1] or "")
    local isOpen = false

    local card = CreateCard(container, "DropdownCard", 44)

    local headerBtn = Instance.new("TextButton")
    headerBtn.BackgroundTransparency = 1
    headerBtn.Size = UDim2.new(1, 0, 0, 44)
    headerBtn.Text = ""
    headerBtn.Parent = card

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = headerBtn

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    titleLbl.Font = Theme.GetFont("Semibold")
    titleLbl.Text = config.Title or "Dropdown"
    titleLbl.TextColor3 = Theme.GetColor("Text")
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn
    Theme.Register(titleLbl, "TextColor3", "Text")

    local currentDisplay = Instance.new("TextLabel")
    currentDisplay.BackgroundTransparency = 1
    currentDisplay.AnchorPoint = Vector2.new(1, 0.5)
    currentDisplay.Position = UDim2.new(1, -20, 0.5, 0)
    currentDisplay.Size = UDim2.new(0.45, 0, 1, 0)
    currentDisplay.Font = Theme.GetFont("Regular")
    currentDisplay.Text = type(selected) == "table" and table.concat(selected, ", ") or tostring(selected)
    currentDisplay.TextColor3 = Theme.GetColor("SubText")
    currentDisplay.TextSize = 13
    currentDisplay.TextXAlignment = Enum.TextXAlignment.Right
    currentDisplay.Parent = headerBtn
    Theme.Register(currentDisplay, "TextColor3", "SubText")

    local chevron = Instance.new("ImageLabel")
    chevron.BackgroundTransparency = 1
    chevron.AnchorPoint = Vector2.new(1, 0.5)
    chevron.Position = UDim2.new(1, 0, 0.5, 0)
    chevron.Size = UDim2.new(0, 14, 0, 14)
    chevron.Image = Icons.Resolve("chevron-down") or ""
    chevron.ImageColor3 = Theme.GetColor("SubText")
    chevron.Parent = headerBtn
    Theme.Register(chevron, "ImageColor3", "SubText")

    -- List container
    local listFrame = Instance.new("Frame")
    listFrame.BackgroundTransparency = 1
    listFrame.Position = UDim2.new(0, 0, 0, 44)
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.Visible = false
    listFrame.ClipsDescendants = true
    listFrame.Parent = card

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = listFrame

    local function RefreshOptions()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, val in ipairs(values) do
            local optBtn = Instance.new("TextButton")
            optBtn.BackgroundColor3 = Theme.GetColor("Accent")
            optBtn.BorderSizePixel = 0
            optBtn.Size = UDim2.new(1, -28, 0, 32)
            optBtn.Position = UDim2.new(0, 14, 0, 0)
            optBtn.Font = Theme.GetFont("Regular")
            optBtn.Text = "   " .. tostring(val)
            optBtn.TextColor3 = Theme.GetColor("Text")
            optBtn.TextSize = 12
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.AutoButtonColor = false
            optBtn.Parent = listFrame

            local optCorner = Instance.new("UICorner")
            optCorner.CornerRadius = UDim.new(0, 6)
            optCorner.Parent = optBtn

            local isChosen = (type(selected) == "table" and table.find(selected, val)) or (selected == val)
            if isChosen then
                optBtn.BackgroundColor3 = Theme.GetColor("ButtonHover")
            end

            optBtn.MouseButton1Click:Connect(function()
                if multi then
                    if type(selected) ~= "table" then selected = {} end
                    local idx = table.find(selected, val)
                    if idx then
                        table.remove(selected, idx)
                    else
                        table.insert(selected, val)
                    end
                    currentDisplay.Text = table.concat(selected, ", ")
                else
                    selected = val
                    currentDisplay.Text = tostring(val)
                    -- Close dropdown
                    isOpen = false
                    listFrame.Visible = false
                    card.Size = UDim2.new(1, 0, 0, 44)
                    chevron.Rotation = 0
                end

                RefreshOptions()
                if config.Callback then
                    task.spawn(pcall, config.Callback, selected)
                end
            end)
        end
    end

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            RefreshOptions()
            listFrame.Visible = true
            local listHeight = math.min(#values * 34 + 8, 180)
            listFrame.Size = UDim2.new(1, 0, 0, listHeight)
            card.Size = UDim2.new(1, 0, 0, 44 + listHeight + 8)
            chevron.Rotation = 180
        else
            listFrame.Visible = false
            card.Size = UDim2.new(1, 0, 0, 44)
            chevron.Rotation = 0
        end
    end)

    return {
        SetValue = function(self, val: any)
            selected = val
            currentDisplay.Text = type(selected) == "table" and table.concat(selected, ", ") or tostring(selected)
            RefreshOptions()
            if config.Callback then task.spawn(pcall, config.Callback, selected) end
        end,
        SetValues = function(self, newVals: { string })
            values = newVals
            RefreshOptions()
        end,
        GetValue = function(self): any
            return selected
        end,
        Destroy = function(self)
            Theme.Unregister(card)
            card:Destroy()
        end
    }
end

-- =========================================================================
-- 5. INPUT COMPONENT
-- =========================================================================
function Components.Input(container: Instance, config: {
    Title: string,
    Placeholder: string?,
    Default: string?,
    Callback: ((string) -> ())?,
})
    local card = CreateCard(container, "InputCard", 44)
    local currentText = config.Default or ""

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size = UDim2.new(0.45, 0, 1, 0)
    titleLbl.Font = Theme.GetFont("Semibold")
    titleLbl.Text = config.Title or "Input"
    titleLbl.TextColor3 = Theme.GetColor("Text")
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card
    Theme.Register(titleLbl, "TextColor3", "Text")

    -- Input box container
    local boxFrame = Instance.new("Frame")
    boxFrame.AnchorPoint = Vector2.new(1, 0.5)
    boxFrame.Position = UDim2.new(1, 0, 0.5, 0)
    boxFrame.Size = UDim2.new(0.5, 0, 0, 28)
    boxFrame.BackgroundColor3 = Theme.GetColor("Accent")
    boxFrame.BorderSizePixel = 0
    boxFrame.Parent = card

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = boxFrame

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Theme.GetColor("Outline")
    boxStroke.Thickness = 1
    boxStroke.Parent = boxFrame

    local textBox = Instance.new("TextBox")
    textBox.BackgroundTransparency = 1
    textBox.Size = UDim2.new(1, -16, 1, 0)
    textBox.Position = UDim2.new(0, 8, 0, 0)
    textBox.Font = Theme.GetFont("Regular")
    textBox.Text = currentText
    textBox.PlaceholderText = config.Placeholder or "Type here..."
    textBox.PlaceholderColor3 = Theme.GetColor("Placeholder")
    textBox.TextColor3 = Theme.GetColor("Text")
    textBox.TextSize = 12
    textBox.ClearTextOnFocus = false
    textBox.Parent = boxFrame

    textBox.FocusLost:Connect(function(enterPressed)
        currentText = textBox.Text
        if config.Callback then
            task.spawn(pcall, config.Callback, currentText)
        end
    end)

    return {
        SetValue = function(self, val: string)
            currentText = val
            textBox.Text = val
            if config.Callback then task.spawn(pcall, config.Callback, val) end
        end,
        GetValue = function(self): string
            return currentText
        end,
        Destroy = function(self)
            Theme.Unregister(card)
            card:Destroy()
        end
    }
end

-- =========================================================================
-- 6. KEYBIND COMPONENT
-- =========================================================================
function Components.Keybind(container: Instance, config: {
    Title: string,
    Default: Enum.KeyCode?,
    Callback: (() -> ())?,
    Changed: ((Enum.KeyCode) -> ())?,
})
    local card = CreateCard(container, "KeybindCard", 44)
    local currentKey = config.Default or Enum.KeyCode.RightControl
    local listening = false

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size = UDim2.new(0.6, 0, 1, 0)
    titleLbl.Font = Theme.GetFont("Semibold")
    titleLbl.Text = config.Title or "Keybind"
    titleLbl.TextColor3 = Theme.GetColor("Text")
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card
    Theme.Register(titleLbl, "TextColor3", "Text")

    local keyBtn = Instance.new("TextButton")
    keyBtn.AnchorPoint = Vector2.new(1, 0.5)
    keyBtn.Position = UDim2.new(1, 0, 0.5, 0)
    keyBtn.Size = UDim2.new(0, 70, 0, 26)
    keyBtn.BackgroundColor3 = Theme.GetColor("Accent")
    keyBtn.BorderSizePixel = 0
    keyBtn.Font = Theme.GetFont("Code")
    keyBtn.Text = currentKey.Name
    keyBtn.TextColor3 = Theme.GetColor("Text")
    keyBtn.TextSize = 11
    keyBtn.Parent = card

    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 6)
    keyCorner.Parent = keyBtn

    local keyStroke = Instance.new("UIStroke")
    keyStroke.Color = Theme.GetColor("Outline")
    keyStroke.Thickness = 1
    keyStroke.Parent = keyBtn

    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            currentKey = input.KeyCode
            keyBtn.Text = currentKey.Name
            if config.Changed then
                task.spawn(pcall, config.Changed, currentKey)
            end
        elseif not listening and not gpe and input.KeyCode == currentKey then
            if config.Callback then
                task.spawn(pcall, config.Callback)
            end
        end
    end)

    return {
        SetKey = function(self, key: Enum.KeyCode)
            currentKey = key
            keyBtn.Text = key.Name
            if config.Changed then task.spawn(pcall, config.Changed, key) end
        end,
        Destroy = function(self)
            Theme.Unregister(card)
            card:Destroy()
        end
    }
end

-- =========================================================================
-- 7. PARAGRAPH COMPONENT
-- =========================================================================
function Components.Paragraph(container: Instance, config: {
    Title: string,
    Content: string,
    Icon: string?,
})
    local card = CreateCard(container, "ParagraphCard", 50)

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = card

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 4)
    list.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size = UDim2.new(1, 0, 0, 18)
    titleLbl.Font = Theme.GetFont("Bold")
    titleLbl.Text = config.Title or "Paragraph"
    titleLbl.TextColor3 = Theme.GetColor("Text")
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.LayoutOrder = 1
    titleLbl.Parent = card
    Theme.Register(titleLbl, "TextColor3", "Text")

    local contentLbl = Instance.new("TextLabel")
    contentLbl.BackgroundTransparency = 1
    contentLbl.Size = UDim2.new(1, 0, 0, 0)
    contentLbl.AutomaticSize = Enum.AutomaticSize.Y
    contentLbl.Font = Theme.GetFont("Regular")
    contentLbl.Text = config.Content or ""
    contentLbl.TextColor3 = Theme.GetColor("SubText")
    contentLbl.TextSize = 12
    contentLbl.TextWrapped = true
    contentLbl.TextXAlignment = Enum.TextXAlignment.Left
    contentLbl.LayoutOrder = 2
    contentLbl.Parent = card
    Theme.Register(contentLbl, "TextColor3", "SubText")

    return {
        SetTitle = function(self, t: string) titleLbl.Text = t end,
        SetContent = function(self, c: string) contentLbl.Text = c end,
        Destroy = function(self)
            Theme.Unregister(card)
            card:Destroy()
        end
    }
end

-- =========================================================================
-- 8. SECTION COMPONENT (Matching "General v" from reference screenshot)
-- =========================================================================
function Components.Section(container: Instance, config: {
    Title: string,
    Collapsible: boolean?,
    DefaultCollapsed: boolean?,
})
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = "Section_" .. (config.Title or "Group")
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Size = UDim2.new(1, 0, 0, 0)
    sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
    sectionFrame.Parent = container

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 8)
    list.Parent = sectionFrame

    -- Header row
    local header = Instance.new("TextButton")
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 24)
    header.Text = ""
    header.LayoutOrder = 1
    header.Parent = sectionFrame

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size = UDim2.new(1, -30, 1, 0)
    titleLbl.Font = Theme.GetFont("Bold")
    titleLbl.Text = config.Title or "Section"
    titleLbl.TextColor3 = Theme.GetColor("SubText")
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = header
    Theme.Register(titleLbl, "TextColor3", "SubText")

    local chevron = Instance.new("ImageLabel")
    chevron.BackgroundTransparency = 1
    chevron.AnchorPoint = Vector2.new(1, 0.5)
    chevron.Position = UDim2.new(1, 0, 0.5, 0)
    chevron.Size = UDim2.new(0, 16, 0, 16)
    chevron.Image = Icons.Resolve("chevron-down") or ""
    chevron.ImageColor3 = Theme.GetColor("SubText")
    chevron.Parent = header
    Theme.Register(chevron, "ImageColor3", "SubText")

    -- Content child container
    local contentFrame = Instance.new("Frame")
    contentFrame.BackgroundTransparency = 1
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.AutomaticSize = Enum.AutomaticSize.Y
    contentFrame.LayoutOrder = 2
    contentFrame.Parent = sectionFrame

    local contentList = Instance.new("UIListLayout")
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Padding = UDim.new(0, 6)
    contentList.Parent = contentFrame

    local isCollapsed = config.DefaultCollapsed == true
    if isCollapsed then
        contentFrame.Visible = false
        chevron.Rotation = -90
    end

    if config.Collapsible ~= false then
        header.MouseButton1Click:Connect(function()
            isCollapsed = not isCollapsed
            contentFrame.Visible = not isCollapsed
            chevron.Rotation = isCollapsed and -90 or 0
        end)
    end

    local sectionHandle = {
        Container = contentFrame,
        Destroy = function(self)
            sectionFrame:Destroy()
        end
    }

    -- Attach component creation helpers directly to the section!
    for key, fn in pairs(Components) do
        if type(fn) == "function" and key ~= "Section" and key ~= "Divider" then
            (sectionHandle :: any)[key] = function(self, childConfig)
                return fn(contentFrame, childConfig)
            end
        end
    end

    return sectionHandle
end

-- =========================================================================
-- 9. DIVIDER
-- =========================================================================
function Components.Divider(container: Instance, spacing: number?)
    local div = Instance.new("Frame")
    div.Name = "Divider"
    div.BackgroundColor3 = Theme.GetColor("Outline")
    div.BorderSizePixel = 0
    div.Size = UDim2.new(1, 0, 0, 1)
    div.Parent = container

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, spacing or 4)
    pad.PaddingBottom = UDim.new(0, spacing or 4)
    pad.Parent = div

    Theme.Register(div, "BackgroundColor3", "Outline")
    return div
end

-- =========================================================================
-- 10. COLORPICKER COMPONENT
-- =========================================================================
function Components.Colorpicker(container: Instance, config: {
    Title: string,
    Default: Color3?,
    Callback: ((Color3) -> ())?,
})
    local card = CreateCard(container, "ColorpickerCard", 44)
    local currentColor = config.Default or Color3.fromRGB(255, 255, 255)

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size = UDim2.new(0.6, 0, 1, 0)
    titleLbl.Font = Theme.GetFont("Semibold")
    titleLbl.Text = config.Title or "Colorpicker"
    titleLbl.TextColor3 = Theme.GetColor("Text")
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card
    Theme.Register(titleLbl, "TextColor3", "Text")

    -- Color swatch button
    local swatch = Instance.new("TextButton")
    swatch.AnchorPoint = Vector2.new(1, 0.5)
    swatch.Position = UDim2.new(1, 0, 0.5, 0)
    swatch.Size = UDim2.new(0, 36, 0, 22)
    swatch.BackgroundColor3 = currentColor
    swatch.BorderSizePixel = 0
    swatch.Text = ""
    swatch.Parent = card

    local swatchCorner = Instance.new("UICorner")
    swatchCorner.CornerRadius = UDim.new(0, 6)
    swatchCorner.Parent = swatch

    local swatchStroke = Instance.new("UIStroke")
    swatchStroke.Color = Theme.GetColor("Outline")
    swatchStroke.Thickness = 1
    swatchStroke.Parent = swatch

    -- Simple palette presets toggle
    local presets = {
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(239, 68, 68),
        Color3.fromRGB(249, 115, 22),
        Color3.fromRGB(234, 179, 8),
        Color3.fromRGB(34, 197, 94),
        Color3.fromRGB(59, 130, 246),
        Color3.fromRGB(168, 85, 247),
    }
    local presetIdx = 1

    swatch.MouseButton1Click:Connect(function()
        presetIdx = (presetIdx % #presets) + 1
        currentColor = presets[presetIdx]
        swatch.BackgroundColor3 = currentColor
        if config.Callback then
            task.spawn(pcall, config.Callback, currentColor)
        end
    end)

    return {
        SetValue = function(self, col: Color3)
            currentColor = col
            swatch.BackgroundColor3 = col
            if config.Callback then task.spawn(pcall, config.Callback, col) end
        end,
        GetValue = function(self): Color3
            return currentColor
        end,
        Destroy = function(self)
            Theme.Unregister(card)
            card:Destroy()
        end
    }
end

-- =========================================================================
-- 11. EXPANDABLE COMPONENT (Matching "Advanced >" and "Limits >")
-- =========================================================================
function Components.Expandable(container: Instance, config: {
    Title: string,
    Icon: string?,
    DefaultExpanded: boolean?,
})
    local card = CreateCard(container, "ExpandableCard", 44)
    local isExpanded = config.DefaultExpanded == true

    local headerBtn = Instance.new("TextButton")
    headerBtn.BackgroundTransparency = 1
    headerBtn.Size = UDim2.new(1, 0, 0, 44)
    headerBtn.Text = ""
    headerBtn.Parent = card

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = headerBtn

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size = UDim2.new(1, -30, 1, 0)
    titleLbl.Font = Theme.GetFont("Semibold")
    titleLbl.Text = config.Title or "Expandable"
    titleLbl.TextColor3 = Theme.GetColor("Text")
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn
    Theme.Register(titleLbl, "TextColor3", "Text")

    local chevron = Instance.new("ImageLabel")
    chevron.BackgroundTransparency = 1
    chevron.AnchorPoint = Vector2.new(1, 0.5)
    chevron.Position = UDim2.new(1, 0, 0.5, 0)
    chevron.Size = UDim2.new(0, 14, 0, 14)
    chevron.Image = Icons.Resolve("chevron-right") or ""
    chevron.ImageColor3 = Theme.GetColor("SubText")
    chevron.Parent = headerBtn
    Theme.Register(chevron, "ImageColor3", "SubText")

    -- Content frame
    local contentFrame = Instance.new("Frame")
    contentFrame.BackgroundTransparency = 1
    contentFrame.Position = UDim2.new(0, 0, 0, 44)
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.AutomaticSize = Enum.AutomaticSize.Y
    contentFrame.Visible = isExpanded
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = card

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 4)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 14)
    contentPadding.PaddingRight = UDim.new(0, 14)
    contentPadding.Parent = contentFrame

    local contentList = Instance.new("UIListLayout")
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Padding = UDim.new(0, 6)
    contentList.Parent = contentFrame

    if isExpanded then
        chevron.Rotation = 90
    end

    headerBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        contentFrame.Visible = isExpanded
        chevron.Rotation = isExpanded and 90 or 0
    end)

    local expHandle = {
        Container = contentFrame,
        Destroy = function(self)
            card:Destroy()
        end
    }

    for key, fn in pairs(Components) do
        if type(fn) == "function" and key ~= "Expandable" then
            (expHandle :: any)[key] = function(self, childConfig)
                return fn(contentFrame, childConfig)
            end
        end
    end

    return expHandle
end

return Components
