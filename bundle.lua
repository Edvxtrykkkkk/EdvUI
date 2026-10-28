--[[
    WindUI — Standalone Single-File Distribution Bundle
    Version: 2.9.0-modular
    Can be loaded directly via loadstring() or pasted into Roblox Studio.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local WindUI = {
    Version = "2.9.0-modular"
}

-- [1] ENVIRONMENT
local Environment = {}
do
    local LIBRARY_TAG = "WindUI_Library_Root_Instance"

    function Environment.GetParent(): Instance
        local success, result = pcall(function()
            if typeof(gethui) == "function" then return gethui() end
            return nil
        end)
        if success and result and typeof(result) == "Instance" then return result end

        local coreSuccess, coreResult = pcall(function() return CoreGui end)
        if coreSuccess and coreResult and typeof(coreResult) == "Instance" then
            local testTest = pcall(function()
                local test = Instance.new("Folder")
                test.Parent = CoreGui
                test:Destroy()
            end)
            if testTest then return CoreGui end
        end

        local player = Players.LocalPlayer
        if player then
            local playerGui = player:FindFirstChildWhichIsA("PlayerGui") or player:WaitForChild("PlayerGui", 5)
            if playerGui then return playerGui end
        end
        return CoreGui
    end

    function Environment.GenerateSafeName(): string
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
        pcall(function() screenGui.Parent = parent end)
        return screenGui
    end
end

-- [2] THEME
local Theme = {}
do
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
            Text = Color3.fromHex("#FAFAFA"),
            SubText = Color3.fromHex("#A1A1AA"),
            Placeholder = Color3.fromHex("#71717A"),
            Button = Color3.fromHex("#27272A"),
            Icon = Color3.fromHex("#A1A1AA"),
            Success = Color3.fromHex("#22C55E"),
            Warning = Color3.fromHex("#F59E0B"),
            Error = Color3.fromHex("#EF4444"),
            Info = Color3.fromHex("#3B82F6"),
        },
        Light = {
            Name = "Light",
            Background = Color3.fromHex("#F4F4F5"),
            Card = Color3.fromHex("#FFFFFF"),
            Accent = Color3.fromHex("#E4E4E7"),
            Active = Color3.fromHex("#D4D4D8"),
            Outline = Color3.fromHex("#E4E4E7"),
            Text = Color3.fromHex("#09090B"),
            SubText = Color3.fromHex("#71717A"),
            Placeholder = Color3.fromHex("#A1A1AA"),
            Button = Color3.fromHex("#E4E4E7"),
            Icon = Color3.fromHex("#71717A"),
            Success = Color3.fromHex("#16A34A"),
            Warning = Color3.fromHex("#D97706"),
            Error = Color3.fromHex("#DC2626"),
            Info = Color3.fromHex("#2563EB"),
        }
    }

    local current = THEMES.Monochrome
    local registered = {}

    function Theme.GetFont(style)
        return (style == "Bold" and Enum.Font.GothamBold) or (style == "Code" and Enum.Font.Code) or Enum.Font.GothamMedium
    end

    function Theme.GetColor(k)
        return current[k] or current.Text
    end

    function Theme.SetTheme(name)
        if THEMES[name] then
            current = THEMES[name]
            local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            for i = #registered, 1, -1 do
                local entry = registered[i]
                if entry.instance and entry.instance.Parent then
                    local nc = current[entry.colorKey]
                    if nc then
                        pcall(function()
                            TweenService:Create(entry.instance, info, { [entry.prop] = nc }):Play()
                        end)
                    end
                else
                    table.remove(registered, i)
                end
            end
        end
    end

    function Theme.Register(inst, prop, colorKey)
        if not inst then return end
        pcall(function() inst[prop] = Theme.GetColor(colorKey) end)
        table.insert(registered, { instance = inst, prop = prop, colorKey = colorKey })
    end

    function Theme.AddTheme(tbl)
        if tbl and tbl.Name then
            local b = table.clone(THEMES.Monochrome)
            for k, v in pairs(tbl) do b[k] = v end
            THEMES[tbl.Name] = b
        end
    end
end

-- [3] ICONS
local Icons = {}
do
    local MAP = {
        ["sparkles"] = "rbxassetid://10709796116",
        ["door-open"] = "rbxassetid://10709796245",
        ["house"] = "rbxassetid://10709796384",
        ["settings"] = "rbxassetid://10709796512",
        ["search"] = "rbxassetid://10709796637",
        ["shield"] = "rbxassetid://10709796781",
        ["lock"] = "rbxassetid://10709796899",
        ["grid"] = "rbxassetid://10709797014",
        ["swords"] = "rbxassetid://10709797148",
        ["info"] = "rbxassetid://10709797274",
        ["palette"] = "rbxassetid://10709797395",
        ["layers"] = "rbxassetid://10709797523",
        ["sprout"] = "rbxassetid://10709797645",
        ["eye"] = "rbxassetid://10709797769",
        ["folder"] = "rbxassetid://10709797887",
        ["sliders-horizontal"] = "rbxassetid://10709798012",
        ["check"] = "rbxassetid://10709798135",
        ["x"] = "rbxassetid://10709798254",
        ["chevron-right"] = "rbxassetid://10709798379",
        ["chevron-down"] = "rbxassetid://10709798492",
        ["minus"] = "rbxassetid://10709798843",
        ["maximize"] = "rbxassetid://10709798967",
        ["bell"] = "rbxassetid://10709799081",
    }
    function Icons.Resolve(name)
        if not name or name == "" then return nil end
        if string.match(name, "^rbxasset") or string.match(name, "^http") then return name end
        return MAP[string.lower(name)] or MAP["sparkles"]
    end
end

-- [4] NOTIFY
local Notify = {}
do
    local container = nil
    function Notify.Show(screenGui, cfg)
        if not container or not container.Parent then
            container = Instance.new("Frame")
            container.BackgroundTransparency = 1
            container.AnchorPoint = Vector2.new(1, 1)
            container.Position = UDim2.new(1, -20, 1, -20)
            container.Size = UDim2.new(0, 300, 1, -40)
            container.ZIndex = 2000
            container.Parent = screenGui

            local l = Instance.new("UIListLayout")
            l.SortOrder = Enum.SortOrder.LayoutOrder
            l.VerticalAlignment = Enum.VerticalAlignment.Bottom
            l.HorizontalAlignment = Enum.HorizontalAlignment.Right
            l.Padding = UDim.new(0, 8)
            l.Parent = container
        end

        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 0)
        card.AutomaticSize = Enum.AutomaticSize.Y
        card.BackgroundColor3 = Theme.GetColor("Card")
        card.BorderSizePixel = 0
        card.ClipsDescendants = true
        card.Parent = container

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = card

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 10)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        pad.Parent = card

        local stroke = Instance.new("UIStroke")
        stroke.Color = Theme.GetColor("Outline")
        stroke.Parent = card

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, 0, 0, 18)
        title.Font = Theme.GetFont("Bold")
        title.Text = cfg.Title or "Notice"
        title.TextColor3 = Theme.GetColor("Text")
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = card

        local body = Instance.new("TextLabel")
        body.BackgroundTransparency = 1
        body.Size = UDim2.new(1, 0, 0, 0)
        body.AutomaticSize = Enum.AutomaticSize.Y
        body.Position = UDim2.new(0, 0, 0, 20)
        body.Font = Theme.GetFont("Regular")
        body.Text = cfg.Content or ""
        body.TextColor3 = Theme.GetColor("SubText")
        body.TextSize = 11
        body.TextWrapped = true
        body.TextXAlignment = Enum.TextXAlignment.Left
        body.Parent = card

        task.delay(cfg.Duration or 3.5, function()
            TweenService:Create(card, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
            task.wait(0.25)
            card:Destroy()
        end)
    end
end

-- [5] COMPONENTS
local Components = {}
do
    local function Card(parent, h)
        local f = Instance.new("Frame")
        f.BackgroundColor3 = Theme.GetColor("Card")
        f.BorderSizePixel = 0
        f.Size = UDim2.new(1, 0, 0, h or 42)
        f.AutomaticSize = Enum.AutomaticSize.Y
        f.ClipsDescendants = true
        f.Parent = parent

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = f

        local s = Instance.new("UIStroke")
        s.Color = Theme.GetColor("Outline")
        s.Thickness = 1
        s.Parent = f

        Theme.Register(f, "BackgroundColor3", "Card")
        Theme.Register(s, "Color", "Outline")
        return f
    end

    function Components.Button(p, cfg)
        local f = Card(p, 42)
        local btn = Instance.new("TextButton")
        btn.BackgroundTransparency = 1
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.Font = Theme.GetFont("Semibold")
        btn.Text = "  " .. (cfg.Title or "Button")
        btn.TextColor3 = Theme.GetColor("Text")
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = f

        btn.MouseButton1Click:Connect(function()
            if cfg.Callback then task.spawn(pcall, cfg.Callback) end
        end)
        return { SetTitle = function(s, t) btn.Text = "  " .. t end, Destroy = function() f:Destroy() end }
    end

    function Components.Toggle(p, cfg)
        local f = Card(p, 44)
        local state = cfg.Value == true

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        pad.Parent = f

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -60, 1, 0)
        lbl.Font = Theme.GetFont("Semibold")
        lbl.Text = cfg.Title or "Toggle"
        lbl.TextColor3 = Theme.GetColor("Text")
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = f

        local track = Instance.new("Frame")
        track.AnchorPoint = Vector2.new(1, 0.5)
        track.Position = UDim2.new(1, 0, 0.5, 0)
        track.Size = UDim2.new(0, 40, 0, 22)
        track.BackgroundColor3 = state and Color3.fromHex("#E4E4E7") or Color3.fromHex("#27272A")
        track.BorderSizePixel = 0
        track.Parent = f

        local tc = Instance.new("UICorner")
        tc.CornerRadius = UDim.new(1, 0)
        tc.Parent = track

        local thumb = Instance.new("Frame")
        thumb.Size = UDim2.new(0, 16, 0, 16)
        thumb.AnchorPoint = Vector2.new(0, 0.5)
        thumb.Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        thumb.BackgroundColor3 = state and Color3.fromHex("#101010") or Color3.fromHex("#A1A1AA")
        thumb.BorderSizePixel = 0
        thumb.Parent = track

        local thc = Instance.new("UICorner")
        thc.CornerRadius = UDim.new(1, 0)
        thc.Parent = thumb

        local btn = Instance.new("TextButton")
        btn.BackgroundTransparency = 1
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.Text = ""
        btn.Parent = f

        local function Update(anim)
            local pos = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            local col = state and Color3.fromHex("#FAFAFA") or Color3.fromHex("#27272A")
            local thm = state and Color3.fromHex("#101010") or Color3.fromHex("#A1A1AA")
            if anim then
                local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                TweenService:Create(thumb, ti, { Position = pos, BackgroundColor3 = thm }):Play()
                TweenService:Create(track, ti, { BackgroundColor3 = col }):Play()
            else
                thumb.Position = pos
                track.BackgroundColor3 = col
                thumb.BackgroundColor3 = thm
            end
        end

        btn.MouseButton1Click:Connect(function()
            state = not state
            Update(true)
            if cfg.Callback then task.spawn(pcall, cfg.Callback, state) end
        end)

        return {
            SetValue = function(s, v) state = v == true Update(true) end,
            GetValue = function() return state end,
            Destroy = function() f:Destroy() end
        }
    end

    function Components.Slider(p, cfg)
        local val = cfg.Value or {}
        local min = val.Min or 0
        local max = val.Max or 100
        local cur = math.clamp(val.Default or min, min, max)

        local f = Card(p, 52)
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        pad.PaddingTop = UDim.new(0, 8)
        pad.Parent = f

        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Size = UDim2.new(1, -50, 0, 18)
        t.Font = Theme.GetFont("Semibold")
        t.Text = cfg.Title or "Slider"
        t.TextColor3 = Theme.GetColor("Text")
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = f

        local vl = Instance.new("TextLabel")
        vl.BackgroundTransparency = 1
        vl.AnchorPoint = Vector2.new(1, 0)
        vl.Position = UDim2.new(1, 0, 0, 0)
        vl.Size = UDim2.new(0, 45, 0, 18)
        vl.Font = Theme.GetFont("Regular")
        vl.Text = tostring(cur)
        vl.TextColor3 = Theme.GetColor("SubText")
        vl.TextSize = 12
        vl.TextXAlignment = Enum.TextXAlignment.Right
        vl.Parent = f

        local track = Instance.new("Frame")
        track.BackgroundColor3 = Theme.GetColor("Accent")
        track.BorderSizePixel = 0
        track.Size = UDim2.new(1, 0, 0, 5)
        track.Position = UDim2.new(0, 0, 0, 28)
        track.Parent = f

        local trc = Instance.new("UICorner")
        trc.CornerRadius = UDim.new(1, 0)
        trc.Parent = track

        local pct = (max > min) and ((cur - min) / (max - min)) or 0
        local fill = Instance.new("Frame")
        fill.BackgroundColor3 = Color3.fromHex("#FAFAFA")
        fill.BorderSizePixel = 0
        fill.Size = UDim2.new(pct, 0, 1, 0)
        fill.Parent = track

        local thumb = Instance.new("Frame")
        thumb.AnchorPoint = Vector2.new(0.5, 0.5)
        thumb.Position = UDim2.new(pct, 0, 0.5, 0)
        thumb.Size = UDim2.new(0, 14, 0, 14)
        thumb.BackgroundColor3 = Color3.fromHex("#FFFFFF")
        thumb.BorderSizePixel = 0
        thumb.Parent = track

        local thc = Instance.new("UICorner")
        thc.CornerRadius = UDim.new(1, 0)
        thc.Parent = thumb

        local dragging = false
        local function SetVal(nv)
            cur = math.clamp(nv, min, max)
            local np = (max > min) and ((cur - min) / (max - min)) or 0
            fill.Size = UDim2.new(np, 0, 1, 0)
            thumb.Position = UDim2.new(np, 0, 0.5, 0)
            vl.Text = tostring(math.round(cur))
            if cfg.Callback then task.spawn(pcall, cfg.Callback, cur) end
        end

        f.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                SetVal(min + rel * (max - min))
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                SetVal(min + rel * (max - min))
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        return { SetValue = function(s, v) SetVal(v) end, GetValue = function() return cur end, Destroy = function() f:Destroy() end }
    end

    function Components.Dropdown(p, cfg)
        local f = Card(p, 44)
        local vals = cfg.Values or {}
        local sel = cfg.Value or vals[1] or ""
        local open = false

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        pad.Parent = f

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(0.5, 0, 0, 44)
        title.Font = Theme.GetFont("Semibold")
        title.Text = cfg.Title or "Dropdown"
        title.TextColor3 = Theme.GetColor("Text")
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = f

        local disp = Instance.new("TextLabel")
        disp.BackgroundTransparency = 1
        disp.AnchorPoint = Vector2.new(1, 0)
        disp.Position = UDim2.new(1, -20, 0, 0)
        disp.Size = UDim2.new(0.4, 0, 0, 44)
        disp.Font = Theme.GetFont("Regular")
        disp.Text = tostring(sel)
        disp.TextColor3 = Theme.GetColor("SubText")
        disp.TextSize = 13
        disp.TextXAlignment = Enum.TextXAlignment.Right
        disp.Parent = f

        local chev = Instance.new("ImageLabel")
        chev.BackgroundTransparency = 1
        chev.AnchorPoint = Vector2.new(1, 0.5)
        chev.Position = UDim2.new(1, 0, 0, 22)
        chev.Size = UDim2.new(0, 14, 0, 14)
        chev.Image = Icons.Resolve("chevron-down") or ""
        chev.ImageColor3 = Theme.GetColor("SubText")
        chev.Parent = f

        local list = Instance.new("Frame")
        list.BackgroundTransparency = 1
        list.Position = UDim2.new(0, 0, 0, 44)
        list.Size = UDim2.new(1, 0, 0, 0)
        list.Visible = false
        list.Parent = f

        local ll = Instance.new("UIListLayout")
        ll.SortOrder = Enum.SortOrder.LayoutOrder
        ll.Padding = UDim.new(0, 2)
        ll.Parent = list

        for _, item in ipairs(vals) do
            local opt = Instance.new("TextButton")
            opt.BackgroundColor3 = Theme.GetColor("Accent")
            opt.BorderSizePixel = 0
            opt.Size = UDim2.new(1, 0, 0, 28)
            opt.Font = Theme.GetFont("Regular")
            opt.Text = "  " .. tostring(item)
            opt.TextColor3 = Theme.GetColor("Text")
            opt.TextSize = 12
            opt.TextXAlignment = Enum.TextXAlignment.Left
            opt.Parent = list

            local oc = Instance.new("UICorner")
            oc.CornerRadius = UDim.new(0, 6)
            oc.Parent = opt

            opt.MouseButton1Click:Connect(function()
                sel = item
                disp.Text = tostring(sel)
                open = false
                list.Visible = false
                f.Size = UDim2.new(1, 0, 0, 44)
                chev.Rotation = 0
                if cfg.Callback then task.spawn(pcall, cfg.Callback, sel) end
            end)
        end

        local trig = Instance.new("TextButton")
        trig.BackgroundTransparency = 1
        trig.Size = UDim2.new(1, 0, 0, 44)
        trig.Text = ""
        trig.Parent = f

        trig.MouseButton1Click:Connect(function()
            open = not open
            list.Visible = open
            chev.Rotation = open and 180 or 0
            if open then
                local h = #vals * 30 + 4
                list.Size = UDim2.new(1, 0, 0, h)
                f.Size = UDim2.new(1, 0, 0, 44 + h + 6)
            else
                f.Size = UDim2.new(1, 0, 0, 44)
            end
        end)

        return { SetValue = function(s, v) sel = v disp.Text = tostring(v) end, GetValue = function() return sel end, Destroy = function() f:Destroy() end }
    end

    function Components.Section(p, cfg)
        local sec = Instance.new("Frame")
        sec.BackgroundTransparency = 1
        sec.Size = UDim2.new(1, 0, 0, 0)
        sec.AutomaticSize = Enum.AutomaticSize.Y
        sec.Parent = p

        local sl = Instance.new("UIListLayout")
        sl.SortOrder = Enum.SortOrder.LayoutOrder
        sl.Padding = UDim.new(0, 6)
        sl.Parent = sec

        local h = Instance.new("TextButton")
        h.BackgroundTransparency = 1
        h.Size = UDim2.new(1, 0, 0, 22)
        h.Text = ""
        h.Parent = sec

        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Size = UDim2.new(1, -24, 1, 0)
        t.Font = Theme.GetFont("Bold")
        t.Text = cfg.Title or "Section"
        t.TextColor3 = Theme.GetColor("SubText")
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = h

        local chev = Instance.new("ImageLabel")
        chev.BackgroundTransparency = 1
        chev.AnchorPoint = Vector2.new(1, 0.5)
        chev.Position = UDim2.new(1, 0, 0.5, 0)
        chev.Size = UDim2.new(0, 14, 0, 14)
        chev.Image = Icons.Resolve("chevron-down") or ""
        chev.ImageColor3 = Theme.GetColor("SubText")
        chev.Parent = h

        local content = Instance.new("Frame")
        content.BackgroundTransparency = 1
        content.Size = UDim2.new(1, 0, 0, 0)
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Parent = sec

        local cl = Instance.new("UIListLayout")
        cl.SortOrder = Enum.SortOrder.LayoutOrder
        cl.Padding = UDim.new(0, 6)
        cl.Parent = content

        local collapsed = cfg.DefaultCollapsed == true
        if collapsed then
            content.Visible = false
            chev.Rotation = -90
        end

        h.MouseButton1Click:Connect(function()
            collapsed = not collapsed
            content.Visible = not collapsed
            chev.Rotation = collapsed and -90 or 0
        end)

        local sh = { Container = content }
        for k, fn in pairs(Components) do
            if type(fn) == "function" and k ~= "Section" then
                sh[k] = function(s, c) return fn(content, c) end
            end
        end
        return sh
    end

    function Components.Expandable(p, cfg)
        local f = Card(p, 42)
        local exp = cfg.DefaultExpanded == true

        local trig = Instance.new("TextButton")
        trig.BackgroundTransparency = 1
        trig.Size = UDim2.new(1, 0, 0, 42)
        trig.Text = ""
        trig.Parent = f

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        pad.Parent = trig

        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Size = UDim2.new(1, -30, 1, 0)
        t.Font = Theme.GetFont("Semibold")
        t.Text = cfg.Title or "Expandable"
        t.TextColor3 = Theme.GetColor("Text")
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = trig

        local chev = Instance.new("ImageLabel")
        chev.BackgroundTransparency = 1
        chev.AnchorPoint = Vector2.new(1, 0.5)
        chev.Position = UDim2.new(1, 0, 0.5, 0)
        chev.Size = UDim2.new(0, 14, 0, 14)
        chev.Image = Icons.Resolve("chevron-right") or ""
        chev.ImageColor3 = Theme.GetColor("SubText")
        chev.Rotation = exp and 90 or 0
        chev.Parent = trig

        local cFrame = Instance.new("Frame")
        cFrame.BackgroundTransparency = 1
        cFrame.Position = UDim2.new(0, 0, 0, 42)
        cFrame.Size = UDim2.new(1, 0, 0, 0)
        cFrame.AutomaticSize = Enum.AutomaticSize.Y
        cFrame.Visible = exp
        cFrame.Parent = f

        local cPad = Instance.new("UIPadding")
        cPad.PaddingLeft = UDim.new(0, 14)
        cPad.PaddingRight = UDim.new(0, 14)
        cPad.PaddingBottom = UDim.new(0, 10)
        cPad.Parent = cFrame

        local cList = Instance.new("UIListLayout")
        cList.SortOrder = Enum.SortOrder.LayoutOrder
        cList.Padding = UDim.new(0, 6)
        cList.Parent = cFrame

        trig.MouseButton1Click:Connect(function()
            exp = not exp
            cFrame.Visible = exp
            chev.Rotation = exp and 90 or 0
        end)

        local eh = { Container = cFrame }
        for k, fn in pairs(Components) do
            if type(fn) == "function" and k ~= "Expandable" then
                eh[k] = function(s, c) return fn(cFrame, c) end
            end
        end
        return eh
    end

    function Components.Paragraph(p, cfg)
        local f = Card(p, 48)
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        pad.PaddingTop = UDim.new(0, 8)
        pad.PaddingBottom = UDim.new(0, 8)
        pad.Parent = f

        local l = Instance.new("UIListLayout")
        l.SortOrder = Enum.SortOrder.LayoutOrder
        l.Padding = UDim.new(0, 2)
        l.Parent = f

        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Size = UDim2.new(1, 0, 0, 16)
        t.Font = Theme.GetFont("Bold")
        t.Text = cfg.Title or "Paragraph"
        t.TextColor3 = Theme.GetColor("Text")
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = f

        local b = Instance.new("TextLabel")
        b.BackgroundTransparency = 1
        b.Size = UDim2.new(1, 0, 0, 0)
        b.AutomaticSize = Enum.AutomaticSize.Y
        b.Font = Theme.GetFont("Regular")
        b.Text = cfg.Content or ""
        b.TextColor3 = Theme.GetColor("SubText")
        b.TextSize = 11
        b.TextWrapped = true
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Parent = f
        return { Destroy = function() f:Destroy() end }
    end

    function Components.Input(p, cfg)
        local f = Card(p, 44)
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        pad.Parent = f

        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Size = UDim2.new(0.5, 0, 1, 0)
        t.Font = Theme.GetFont("Semibold")
        t.Text = cfg.Title or "Input"
        t.TextColor3 = Theme.GetColor("Text")
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = f

        local box = Instance.new("TextBox")
        box.AnchorPoint = Vector2.new(1, 0.5)
        box.Position = UDim2.new(1, 0, 0.5, 0)
        box.Size = UDim2.new(0.45, 0, 0, 26)
        box.BackgroundColor3 = Theme.GetColor("Accent")
        box.BorderSizePixel = 0
        box.Font = Theme.GetFont("Regular")
        box.Text = cfg.Default or ""
        box.PlaceholderText = cfg.Placeholder or "Type..."
        box.TextColor3 = Theme.GetColor("Text")
        box.TextSize = 12
        box.ClearTextOnFocus = false
        box.Parent = f

        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 6)
        bc.Parent = box

        box.FocusLost:Connect(function()
            if cfg.Callback then task.spawn(pcall, cfg.Callback, box.Text) end
        end)
        return { GetValue = function() return box.Text end, Destroy = function() f:Destroy() end }
    end

    function Components.Keybind(p, cfg)
        local f = Card(p, 44)
        local key = cfg.Default or Enum.KeyCode.RightControl
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        pad.Parent = f

        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Size = UDim2.new(0.6, 0, 1, 0)
        t.Font = Theme.GetFont("Semibold")
        t.Text = cfg.Title or "Keybind"
        t.TextColor3 = Theme.GetColor("Text")
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = f

        local kb = Instance.new("TextButton")
        kb.AnchorPoint = Vector2.new(1, 0.5)
        kb.Position = UDim2.new(1, 0, 0.5, 0)
        kb.Size = UDim2.new(0, 64, 0, 24)
        kb.BackgroundColor3 = Theme.GetColor("Accent")
        kb.BorderSizePixel = 0
        kb.Font = Theme.GetFont("Code")
        kb.Text = key.Name
        kb.TextColor3 = Theme.GetColor("Text")
        kb.TextSize = 11
        kb.Parent = f

        local kbc = Instance.new("UICorner")
        kbc.CornerRadius = UDim.new(0, 6)
        kbc.Parent = kb

        local waiting = false
        kb.MouseButton1Click:Connect(function()
            waiting = true
            kb.Text = "..."
        end)
        UserInputService.InputBegan:Connect(function(inp, gpe)
            if waiting and inp.UserInputType == Enum.UserInputType.Keyboard then
                waiting = false
                key = inp.KeyCode
                kb.Text = key.Name
            elseif not waiting and not gpe and inp.KeyCode == key then
                if cfg.Callback then task.spawn(pcall, cfg.Callback) end
            end
        end)
        return { Destroy = function() f:Destroy() end }
    end

    function Components.Colorpicker(p, cfg)
        local f = Card(p, 44)
        local col = cfg.Default or Color3.fromRGB(255, 255, 255)
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        pad.Parent = f

        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Size = UDim2.new(0.6, 0, 1, 0)
        t.Font = Theme.GetFont("Semibold")
        t.Text = cfg.Title or "Colorpicker"
        t.TextColor3 = Theme.GetColor("Text")
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = f

        local sw = Instance.new("TextButton")
        sw.AnchorPoint = Vector2.new(1, 0.5)
        sw.Position = UDim2.new(1, 0, 0.5, 0)
        sw.Size = UDim2.new(0, 36, 0, 22)
        sw.BackgroundColor3 = col
        sw.BorderSizePixel = 0
        sw.Text = ""
        sw.Parent = f

        local sc = Instance.new("UICorner")
        sc.CornerRadius = UDim.new(0, 6)
        sc.Parent = sw

        local pal = {
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(239, 68, 68),
            Color3.fromRGB(34, 197, 94),
            Color3.fromRGB(59, 130, 246),
            Color3.fromRGB(168, 85, 247),
        }
        local pi = 1
        sw.MouseButton1Click:Connect(function()
            pi = (pi % #pal) + 1
            col = pal[pi]
            sw.BackgroundColor3 = col
            if cfg.Callback then task.spawn(pcall, cfg.Callback, col) end
        end)
        return { GetValue = function() return col end, Destroy = function() f:Destroy() end }
    end
end

-- [6] WINDOW & API
local currentScreenGui = nil

function WindUI:GetScreenGui()
    if currentScreenGui and currentScreenGui.Parent then return currentScreenGui end
    currentScreenGui = Environment.CreateScreenGui()
    return currentScreenGui
end

function WindUI:Notify(cfg)
    Notify.Show(self:GetScreenGui(), cfg)
end

function WindUI:SetTheme(name)
    Theme.SetTheme(name)
end

function WindUI:AddTheme(tbl)
    Theme.AddTheme(tbl)
end

function WindUI:CreateWindow(config)
    local sg = self:GetScreenGui()
    local win = Instance.new("Frame")
    win.Name = "WindUI_MainWindow"
    win.AnchorPoint = Vector2.new(0.5, 0.5)
    win.Position = UDim2.new(0.5, 0, 0.5, 0)
    win.Size = UDim2.new(0, 680, 0, 480)
    win.BackgroundColor3 = Theme.GetColor("Background")
    win.BorderSizePixel = 0
    win.ClipsDescendants = true
    win.Parent = sg

    local winc = Instance.new("UICorner")
    winc.CornerRadius = UDim.new(0, 12)
    winc.Parent = win

    local wins = Instance.new("UIStroke")
    wins.Color = Theme.GetColor("Outline")
    wins.Parent = win

    -- Header
    local header = Instance.new("Frame")
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 52)
    header.Parent = win

    local hpad = Instance.new("UIPadding")
    hpad.PaddingLeft = UDim.new(0, 16)
    hpad.PaddingRight = UDim.new(0, 16)
    hpad.Parent = header

    local logo = Instance.new("ImageLabel")
    logo.BackgroundTransparency = 1
    logo.Position = UDim2.new(0, 0, 0.5, -12)
    logo.Size = UDim2.new(0, 24, 0, 24)
    logo.Image = Icons.Resolve(config.Icon or "sparkles") or ""
    logo.ImageColor3 = Theme.GetColor("Text")
    logo.Parent = header

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, 32, 0, 8)
    titleLbl.Size = UDim2.new(0, 220, 0, 20)
    titleLbl.Font = Theme.GetFont("Bold")
    titleLbl.Text = config.Title or "Vind Ui Reborn"
    titleLbl.TextColor3 = Theme.GetColor("Text")
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = header

    local authLbl = Instance.new("TextLabel")
    authLbl.BackgroundTransparency = 1
    authLbl.Position = UDim2.new(0, 32, 0, 26)
    authLbl.Size = UDim2.new(0, 260, 0, 16)
    authLbl.Font = Theme.GetFont("Regular")
    authLbl.Text = config.Author or "Complete Showcase · v2.9.0-modular"
    authLbl.TextColor3 = Theme.GetColor("SubText")
    authLbl.TextSize = 11
    authLbl.TextXAlignment = Enum.TextXAlignment.Left
    authLbl.Parent = header

    local closeBtn = Instance.new("ImageButton")
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.Position = UDim2.new(1, 0, 0.5, 0)
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = Icons.Resolve("x") or ""
    closeBtn.ImageColor3 = Theme.GetColor("SubText")
    closeBtn.Parent = header

    -- Body
    local body = Instance.new("Frame")
    body.BackgroundTransparency = 1
    body.Position = UDim2.new(0, 0, 0, 52)
    body.Size = UDim2.new(1, 0, 1, -52)
    body.Parent = win

    local sidebar = Instance.new("Frame")
    sidebar.BackgroundTransparency = 1
    sidebar.Size = UDim2.new(0, 180, 1, 0)
    sidebar.Parent = body

    local sPad = Instance.new("UIPadding")
    sPad.PaddingLeft = UDim.new(0, 12)
    sPad.PaddingRight = UDim.new(0, 8)
    sPad.PaddingBottom = UDim.new(0, 12)
    sPad.Parent = sidebar

    local tabList = Instance.new("ScrollingFrame")
    tabList.BackgroundTransparency = 1
    tabList.BorderSizePixel = 0
    tabList.ScrollBarThickness = 0
    tabList.Size = UDim2.new(1, 0, 1, -56)
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabList.Parent = sidebar

    local tlLayout = Instance.new("UIListLayout")
    tlLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tlLayout.Padding = UDim.new(0, 4)
    tlLayout.Parent = tabList

    -- Profile Card
    local pCard = Instance.new("Frame")
    pCard.BackgroundColor3 = Theme.GetColor("Card")
    pCard.Size = UDim2.new(1, 0, 0, 48)
    pCard.Position = UDim2.new(0, 0, 1, -48)
    pCard.Parent = sidebar

    local pcCorner = Instance.new("UICorner")
    pcCorner.CornerRadius = UDim.new(0, 8)
    pcCorner.Parent = pCard

    local profCfg = config.Profile or { Username = "SkFOrest", Handle = "@luis_akz4" }
    local unLbl = Instance.new("TextLabel")
    unLbl.BackgroundTransparency = 1
    unLbl.Position = UDim2.new(0, 40, 0, 8)
    unLbl.Size = UDim2.new(1, -44, 0, 16)
    unLbl.Font = Theme.GetFont("Bold")
    unLbl.Text = profCfg.Username
    unLbl.TextColor3 = Theme.GetColor("Text")
    unLbl.TextSize = 12
    unLbl.TextXAlignment = Enum.TextXAlignment.Left
    unLbl.Parent = pCard

    local hndlLbl = Instance.new("TextLabel")
    hndlLbl.BackgroundTransparency = 1
    hndlLbl.Position = UDim2.new(0, 40, 0, 24)
    hndlLbl.Size = UDim2.new(1, -44, 0, 14)
    hndlLbl.Font = Theme.GetFont("Regular")
    hndlLbl.Text = profCfg.Handle
    hndlLbl.TextColor3 = Theme.GetColor("SubText")
    hndlLbl.TextSize = 10
    hndlLbl.TextXAlignment = Enum.TextXAlignment.Left
    hndlLbl.Parent = pCard

    local av = Instance.new("Frame")
    av.Size = UDim2.new(0, 28, 0, 28)
    av.Position = UDim2.new(0, 6, 0.5, -14)
    av.BackgroundColor3 = Color3.fromHex("#15803D")
    av.Parent = pCard
    local avc = Instance.new("UICorner")
    avc.CornerRadius = UDim.new(0, 6)
    avc.Parent = av

    -- Right view
    local rightView = Instance.new("Frame")
    rightView.BackgroundTransparency = 1
    rightView.Position = UDim2.new(0, 185, 0, 0)
    rightView.Size = UDim2.new(1, -195, 1, -10)
    rightView.Parent = body

    -- Dragging
    local dragging = false
    local dragStart = Vector2.zero
    local startPos = UDim2.new()
    header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = Vector2.new(inp.Position.X, inp.Position.Y)
            startPos = win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(inp.Position.X, inp.Position.Y) - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local isVisible = true
    closeBtn.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        win.Visible = isVisible
    end)

    local tabs = {}
    local function CreateTab(tCfg)
        local tabBtn = Instance.new("TextButton")
        tabBtn.BackgroundColor3 = Theme.GetColor("Card")
        tabBtn.BackgroundTransparency = 1
        tabBtn.Size = UDim2.new(1, 0, 0, 36)
        tabBtn.Text = ""
        tabBtn.Parent = tabList

        local tbc = Instance.new("UICorner")
        tbc.CornerRadius = UDim.new(0, 8)
        tbc.Parent = tabBtn

        local ti = Instance.new("ImageLabel")
        ti.BackgroundTransparency = 1
        ti.Position = UDim2.new(0, 8, 0.5, -8)
        ti.Size = UDim2.new(0, 16, 0, 16)
        ti.Image = Icons.Resolve(tCfg.Icon or "grid") or ""
        ti.ImageColor3 = Theme.GetColor("SubText")
        ti.Parent = tabBtn

        local tt = Instance.new("TextLabel")
        tt.BackgroundTransparency = 1
        tt.Position = UDim2.new(0, 32, 0, 0)
        tt.Size = UDim2.new(1, -36, 1, 0)
        tt.Font = Theme.GetFont("Semibold")
        tt.Text = tCfg.Title or "Tab"
        tt.TextColor3 = Theme.GetColor("SubText")
        tt.TextSize = 12
        tt.TextXAlignment = Enum.TextXAlignment.Left
        tt.Parent = tabBtn

        local tContent = Instance.new("Frame")
        tContent.BackgroundTransparency = 1
        tContent.Size = UDim2.new(1, 0, 1, 0)
        tContent.Visible = false
        tContent.Parent = rightView

        local subBar = Instance.new("Frame")
        subBar.BackgroundTransparency = 1
        subBar.Size = UDim2.new(1, 0, 0, 34)
        subBar.Visible = false
        subBar.Parent = tContent

        local subLayout = Instance.new("UIListLayout")
        subLayout.FillDirection = Enum.FillDirection.Horizontal
        subLayout.Padding = UDim.new(0, 8)
        subLayout.Parent = subBar

        local scroll = Instance.new("ScrollingFrame")
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent = tContent

        local scList = Instance.new("UIListLayout")
        scList.SortOrder = Enum.SortOrder.LayoutOrder
        scList.Padding = UDim.new(0, 8)
        scList.Parent = scroll

        local function Select()
            for _, t in ipairs(tabs) do
                t.Btn.BackgroundTransparency = 1
                t.Txt.TextColor3 = Theme.GetColor("SubText")
                t.Content.Visible = false
            end
            tabBtn.BackgroundColor3 = Theme.GetColor("Active")
            tabBtn.BackgroundTransparency = 0
            tt.TextColor3 = Theme.GetColor("Text")
            tContent.Visible = true
        end

        tabBtn.MouseButton1Click:Connect(Select)
        local tData = { Btn = tabBtn, Txt = tt, Content = tContent }
        table.insert(tabs, tData)
        if #tabs == 1 then Select() end

        local tabHandle = { Container = scroll, Select = Select }
        local subTabs = {}
        function tabHandle:CreateSubTab(sCfg)
            subBar.Visible = true
            scroll.Position = UDim2.new(0, 0, 0, 38)
            scroll.Size = UDim2.new(1, 0, 1, -38)

            local sBtn = Instance.new("TextButton")
            sBtn.BackgroundTransparency = 1
            sBtn.Size = UDim2.new(0, 0, 1, 0)
            sBtn.AutomaticSize = Enum.AutomaticSize.X
            sBtn.Text = "  " .. (sCfg.Title or "Sub") .. "  "
            sBtn.Font = Theme.GetFont("Semibold")
            sBtn.TextColor3 = Theme.GetColor("SubText")
            sBtn.TextSize = 12
            sBtn.Parent = subBar

            local sContent = Instance.new("Frame")
            sContent.BackgroundTransparency = 1
            sContent.Size = UDim2.new(1, 0, 1, 0)
            sContent.Visible = false
            sContent.Parent = scroll

            local scl = Instance.new("UIListLayout")
            scl.SortOrder = Enum.SortOrder.LayoutOrder
            scl.Padding = UDim.new(0, 8)
            scl.Parent = sContent

            local function SelectSub()
                for _, s in ipairs(subTabs) do
                    s.Btn.TextColor3 = Theme.GetColor("SubText")
                    s.Content.Visible = false
                end
                sBtn.TextColor3 = Theme.GetColor("Text")
                sContent.Visible = true
            end
            sBtn.MouseButton1Click:Connect(SelectSub)
            table.insert(subTabs, { Btn = sBtn, Content = sContent })
            if #subTabs == 1 then SelectSub() end

            local sh = { Container = sContent, Select = SelectSub }
            for k, fn in pairs(Components) do
                if type(fn) == "function" then
                    sh[k] = function(s, c) return fn(sContent, c) end
                end
            end
            return sh
        end

        for k, fn in pairs(Components) do
            if type(fn) == "function" then
                tabHandle[k] = function(s, c) return fn(scroll, c) end
            end
        end
        return tabHandle
    end

    return {
        Instance = win,
        CreateTab = CreateTab,
        AddCategory = function(s, title)
            local f = Instance.new("Frame")
            f.BackgroundTransparency = 1
            f.Size = UDim2.new(1, 0, 0, 20)
            f.Parent = tabList
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.Font = Theme.GetFont("Semibold")
            lbl.Text = "   v " .. title
            lbl.TextColor3 = Theme.GetColor("SubText")
            lbl.TextSize = 10
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = f
        end,
        Toggle = function()
            isVisible = not isVisible
            win.Visible = isVisible
        end,
        Destroy = function() win:Destroy() end
    }
end

return WindUI
